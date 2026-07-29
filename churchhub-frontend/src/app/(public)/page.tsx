import type { Metadata } from "next";
import Link from "next/link";
import { Clock, MapPin, Phone } from "lucide-react";
import { listParishes, listMassSchedules, ApiError } from "@/lib/api";
import type { MassSchedule, Parish } from "@/lib/types";
import {
  formatParishAddress,
  formatTime,
  groupMassSchedules,
  PAGE_SIZES,
} from "@/lib/format";
import { dayTypeLabel } from "@/lib/i18n/labels";
import type { TranslateFn } from "@/lib/i18n/messages";
import {
  SearchBar,
  MassFilter,
  RegionFilter,
  ClearFiltersButton,
  PageSizeSelect,
  QueryPagination,
} from "@/components/QueryControls";
import { EmptyState } from "@/components/Feedback";
import { getTranslations } from "@/lib/i18n/server";
import { parishListJsonLd } from "@/lib/seo";
import { absoluteUrl } from "@/lib/site";
import { VN_PROVINCES } from "@/lib/vn-regions";

const PAGE_SIZE = 12;

interface HomeSearchParams {
  search?: string;
  page?: string;
  size?: string;
  province?: string;
  ward?: string;
  timeFrom?: string;
  timeTo?: string;
}

export function generateMetadata({
  searchParams,
}: {
  searchParams: HomeSearchParams;
}): Metadata {
  const { t } = getTranslations();
  const search = searchParams.search?.trim();

  // Paginated/filtered directory views all consolidate to the directory root.
  // (Next.js strips query strings from metadata URLs, and parish pages are
  // independently indexable via the sitemap, so no discoverability is lost.)
  const canonical = absoluteUrl("/");
  const description = t("home.subtitle");

  return {
    description,
    // Search/filter result pages are thin/duplicate — keep them out of the
    // index but let crawlers follow through to the parish pages.
    ...(search || searchParams.timeFrom || searchParams.timeTo || searchParams.province || searchParams.ward
      ? { robots: { index: false, follow: true } }
      : {}),
    alternates: { canonical },
    openGraph: { url: canonical, description },
  };
}

const TIME_PATTERN = /^([01]\d|2[0-3]):[0-5]\d$/;

function parseTime(value: string | undefined): string | undefined {
  return value && TIME_PATTERN.test(value) ? value : undefined;
}

function parseProvince(value: string | undefined): string | undefined {
  return value && VN_PROVINCES.includes(value) ? value : undefined;
}

function parsePageSize(value: string | undefined): number {
  const n = Number(value);
  return PAGE_SIZES.includes(n) ? n : PAGE_SIZE;
}

export default async function HomePage({
  searchParams,
}: {
  searchParams: HomeSearchParams;
}) {
  const { t } = getTranslations();
  const search = searchParams.search?.trim() || undefined;
  const page = Number(searchParams.page ?? "0") || 0;
  const pageSize = parsePageSize(searchParams.size);
  const timeFrom = parseTime(searchParams.timeFrom);
  const timeTo = parseTime(searchParams.timeTo);
  const province = parseProvince(searchParams.province);
  const ward = searchParams.ward?.trim() || undefined;
  const hasFilter = Boolean(timeFrom || timeTo || province || ward);

  let parishes: Parish[] = [];
  let massByParish: Record<number, MassSchedule[]> = {};
  let totalPages = 0;
  let totalElements = 0;
  let loadError: string | null = null;

  try {
    // The mass-schedule and region filters are applied server-side, so the
    // directory list here is already the correctly filtered + paginated page.
    const result = await listParishes({
      search,
      province,
      ward,
      timeFrom,
      timeTo,
      page,
      size: pageSize,
    });
    parishes = result.content;
    totalPages = result.totalPages;
    totalElements = result.totalElements;

    // Fetch each visible parish's mass schedules in parallel, for display only;
    // a single parish failing shouldn't blank out the whole list.
    const massLists = await Promise.all(
      parishes.map((p) => listMassSchedules(p.id).catch(() => [] as MassSchedule[])),
    );
    massByParish = Object.fromEntries(parishes.map((p, i) => [p.id, massLists[i] ?? []]));
  } catch (err) {
    loadError = err instanceof ApiError ? err.message : t("home.loadError");
  }

  const jsonLd =
    parishes.length > 0 ? parishListJsonLd(parishes, massByParish, page * pageSize) : null;

  return (
    <div className="space-y-6">
      {jsonLd && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      )}
      <section className="space-y-2">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("home.title")}</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {t("home.subtitle")}
        </p>
      </section>

      <div className="space-y-3">
        <SearchBar />
        <div className="flex flex-wrap items-center gap-2">
          <RegionFilter />
          <MassFilter />
          <ClearFiltersButton />
        </div>
      </div>

      {loadError ? (
        <EmptyState title={t("home.errorTitle")} description={loadError} />
      ) : parishes.length === 0 ? (
        <EmptyState
          title={t("home.emptyTitle")}
          description={
            hasFilter
              ? t("home.emptyFilter")
              : search
                ? t("home.emptySearch", { query: search })
                : t("home.emptyNoData")
          }
        />
      ) : (
        <>
          <p className="text-sm text-gray-500 dark:text-gray-400">{t("common.results", { count: totalElements })}</p>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {parishes.map((parish) => (
              <ParishCard
                key={parish.id}
                parish={parish}
                massSchedules={massByParish[parish.id] ?? []}
                t={t}
              />
            ))}
          </div>
          <div className="flex flex-wrap justify-center gap-3 [&>nav]:mt-0">
            <QueryPagination page={page} totalPages={totalPages} />
            <PageSizeSelect defaultSize={PAGE_SIZE} />
          </div>
        </>
      )}
    </div>
  );
}

function ParishCard({
  parish,
  massSchedules,
  t,
}: {
  parish: Parish;
  massSchedules: MassSchedule[];
  t: TranslateFn;
}) {
  const massGroups = groupMassSchedules(massSchedules);
  const address = formatParishAddress(parish);
  return (
    <Link
      href={`/parishes/${parish.slug}`}
      className="group flex h-full flex-col rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-5 shadow-sm transition hover:border-brand-300 hover:shadow-md dark:hover:border-brand-700"
    >
      <div className="h-[128px] overflow-hidden">
        <h2 className="line-clamp-1 text-base font-semibold text-gray-900 group-hover:text-brand-700 dark:text-gray-100 dark:group-hover:text-brand-400">
          {parish.name}
        </h2>
        {address && (
          <p className="mt-2 flex items-start gap-1.5 text-sm text-gray-600 dark:text-gray-400">
            <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-gray-400 dark:text-gray-500" />
            <span className="line-clamp-1">{address}</span>
          </p>
        )}
        {parish.phone && (
          <p className="mt-1 flex min-w-0 items-center gap-1.5 text-sm text-gray-600 dark:text-gray-400">
            <Phone className="h-4 w-4 shrink-0 text-gray-400 dark:text-gray-500" />
            <span className="min-w-0 truncate">{parish.phone}</span>
          </p>
        )}
        {parish.description && (
          <p className="mt-2 line-clamp-2 text-sm text-gray-500 dark:text-gray-400">{parish.description}</p>
        )}
      </div>
      <div className="mt-4 border-t border-gray-100 pt-3 dark:border-gray-800">
        <p className="mb-1.5 flex items-center gap-1.5 text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
          <Clock className="h-3.5 w-3.5 text-brand-500" />
          {t("parishDetail.mass")}
        </p>
        {massGroups.length > 0 ? (
          <ul className="space-y-0.5 text-sm text-gray-600 dark:text-gray-400">
            {massGroups.map((group) => (
              <li key={group.dayType} className="flex gap-2">
                <span className="shrink-0 text-gray-500 dark:text-gray-500">
                  {dayTypeLabel(t, group.dayType)}:
                </span>
                <span className="text-gray-700 dark:text-gray-300">
                  {group.items.map((m) => formatTime(m.massTime)).join(", ")}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-gray-400 dark:text-gray-600">{t("parishDetail.massEmpty")}</p>
        )}
      </div>
    </Link>
  );
}
