import Link from "next/link";
import { MapPin, Phone } from "lucide-react";
import { listParishes, ApiError } from "@/lib/api";
import type { Parish } from "@/lib/types";
import { SearchBar, QueryPagination } from "@/components/QueryControls";
import { EmptyState } from "@/components/Feedback";
import { getTranslations } from "@/lib/i18n/server";

const PAGE_SIZE = 12;

export default async function HomePage({
  searchParams,
}: {
  searchParams: { search?: string; page?: string };
}) {
  const { t } = getTranslations();
  const search = searchParams.search?.trim() || undefined;
  const page = Number(searchParams.page ?? "0") || 0;

  let parishes: Parish[] = [];
  let totalPages = 0;
  let totalElements = 0;
  let loadError: string | null = null;

  try {
    const result = await listParishes({ search, page, size: PAGE_SIZE });
    parishes = result.content;
    totalPages = result.totalPages;
    totalElements = result.totalElements;
  } catch (err) {
    loadError = err instanceof ApiError ? err.message : t("home.loadError");
  }

  return (
    <div className="space-y-6">
      <section className="space-y-2">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("home.title")}</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {t("home.subtitle")}
        </p>
      </section>

      <SearchBar />

      {loadError ? (
        <EmptyState title={t("home.errorTitle")} description={loadError} />
      ) : parishes.length === 0 ? (
        <EmptyState
          title={t("home.emptyTitle")}
          description={
            search ? t("home.emptySearch", { query: search }) : t("home.emptyNoData")
          }
        />
      ) : (
        <>
          <p className="text-sm text-gray-500 dark:text-gray-400">{t("common.results", { count: totalElements })}</p>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {parishes.map((parish) => (
              <ParishCard key={parish.id} parish={parish} />
            ))}
          </div>
          <QueryPagination page={page} totalPages={totalPages} />
        </>
      )}
    </div>
  );
}

function ParishCard({ parish }: { parish: Parish }) {
  return (
    <Link
      href={`/parishes/${parish.slug}`}
      className="group flex h-full flex-col rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-5 shadow-sm transition hover:border-brand-300 hover:shadow-md dark:hover:border-brand-700"
    >
      <h2 className="text-base font-semibold text-gray-900 group-hover:text-brand-700 dark:text-gray-100 dark:group-hover:text-brand-400">
        {parish.name}
      </h2>
      {parish.address && (
        <p className="mt-2 flex items-start gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-gray-400 dark:text-gray-500" />
          <span className="line-clamp-2">{parish.address}</span>
        </p>
      )}
      {parish.phone && (
        <p className="mt-1 flex items-center gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          <Phone className="h-4 w-4 shrink-0 text-gray-400 dark:text-gray-500" />
          {parish.phone}
        </p>
      )}
      {parish.description && (
        <p className="mt-3 line-clamp-3 text-sm text-gray-500 dark:text-gray-400">{parish.description}</p>
      )}
    </Link>
  );
}
