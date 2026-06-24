import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { Church, Clock, MapPin, Phone, User } from "lucide-react";
import { getParishDetail, listParishArticles, ApiError } from "@/lib/api";
import type { ArticleSummary } from "@/lib/types";
import {
  PRIEST_ROLE_LABEL,
  DAY_TYPE_LABEL,
  dayOfWeekLabel,
  formatTime,
  formatRelativeTime,
  groupMassSchedules,
} from "@/lib/format";
import { EmptyState } from "@/components/Feedback";

export async function generateMetadata({
  params,
}: {
  params: { slug: string };
}): Promise<Metadata> {
  try {
    const { parish } = await getParishDetail(params.slug);
    return { title: parish.name, description: parish.description ?? undefined };
  } catch {
    return { title: "Nhà thờ" };
  }
}

export default async function ParishDetailPage({ params }: { params: { slug: string } }) {
  let detail;
  try {
    detail = await getParishDetail(params.slug);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  const { parish, priests, massSchedules } = detail;
  const sortedPriests = [...priests].sort((a, b) => a.orderIndex - b.orderIndex);
  const massGroups = groupMassSchedules(massSchedules);

  let articles: ArticleSummary[] = [];
  try {
    const page = await listParishArticles(parish.id, 0, 6);
    // newest first
    articles = [...page.content].sort((a, b) =>
      (b.publishedAt ?? "").localeCompare(a.publishedAt ?? ""),
    );
  } catch {
    articles = [];
  }

  return (
    <div className="space-y-8">
      <nav className="text-sm text-gray-500 dark:text-gray-400">
        <Link href="/" className="hover:text-brand-700 dark:hover:text-brand-400">
          Trang chủ
        </Link>
        <span className="mx-2">/</span>
        <span className="text-gray-700 dark:text-gray-300">{parish.name}</span>
      </nav>

      <header className="space-y-3 rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-6">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{parish.name}</h1>
        <div className="flex flex-col gap-1.5 text-sm text-gray-600 dark:text-gray-400">
          {parish.address && (
            <p className="flex items-start gap-2">
              <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-gray-400 dark:text-gray-500" />
              {parish.address}
            </p>
          )}
          {parish.phone && (
            <p className="flex items-center gap-2">
              <Phone className="h-4 w-4 shrink-0 text-gray-400 dark:text-gray-500" />
              {parish.phone}
            </p>
          )}
        </div>
        {parish.description && <p className="prose-content pt-2">{parish.description}</p>}
      </header>

      {/* Priests */}
      <section className="space-y-3">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Linh mục</h2>
        {sortedPriests.length === 0 ? (
          <EmptyState title="Chưa có thông tin linh mục" />
        ) : (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            {sortedPriests.map((priest) => (
              <div
                key={priest.id}
                className="flex items-center gap-4 rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-4"
              >
                {priest.photoUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={priest.photoUrl}
                    alt={priest.fullName}
                    className="h-16 w-16 rounded-full object-cover"
                  />
                ) : (
                  <div className="flex h-16 w-16 items-center justify-center rounded-full bg-gray-100 dark:bg-gray-800">
                    <User className="h-7 w-7 text-gray-400 dark:text-gray-500" />
                  </div>
                )}
                <div>
                  <p className="font-medium text-gray-900 dark:text-gray-100">{priest.fullName}</p>
                  <p className="text-sm text-brand-700 dark:text-brand-400">{PRIEST_ROLE_LABEL[priest.role]}</p>
                  {priest.phone && <p className="text-sm text-gray-500 dark:text-gray-400">{priest.phone}</p>}
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Mass schedules */}
      <section className="space-y-3">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Giờ lễ</h2>
        {massGroups.length === 0 ? (
          <EmptyState title="Chưa có thông tin giờ lễ" />
        ) : (
          <div className="space-y-4">
            {massGroups.map((group) => (
              <div key={group.dayType} className="rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-5">
                <h3 className="mb-3 font-medium text-gray-900 dark:text-gray-100">{DAY_TYPE_LABEL[group.dayType]}</h3>
                <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                  {group.items.map((mass) => (
                    <li key={mass.id} className="flex items-center gap-3 py-2 text-sm">
                      <Clock className="h-4 w-4 shrink-0 text-brand-500" />
                      <span className="font-medium text-gray-900 dark:text-gray-100">{formatTime(mass.massTime)}</span>
                      {mass.dayType !== "WEEKDAY" || mass.dayOfWeek !== null ? (
                        <span className="text-gray-500 dark:text-gray-400">{dayOfWeekLabel(mass.dayOfWeek)}</span>
                      ) : null}
                      {mass.label && <span className="text-gray-700 dark:text-gray-300">— {mass.label}</span>}
                      {mass.note && <span className="text-gray-400 dark:text-gray-500">({mass.note})</span>}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Articles — dòng thời gian kiểu Facebook */}
      <section className="space-y-4">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Tin tức &amp; sự kiện</h2>
        {articles.length === 0 ? (
          <EmptyState title="Chưa có bài viết" />
        ) : (
          <div className="mx-auto max-w-xl space-y-4">
            {articles.map((article) => {
              const href = `/parishes/${parish.slug}/articles/${article.slug}`;
              return (
                <article
                  key={article.id}
                  className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 shadow-sm"
                >
                  {/* Header bài đăng: nhận diện giáo xứ + thời gian */}
                  <div className="flex items-center gap-3 p-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-100 dark:bg-brand-900/40">
                      <Church className="h-5 w-5 text-brand-700 dark:text-brand-300" />
                    </div>
                    <div className="min-w-0">
                      <p className="truncate font-semibold text-gray-900 dark:text-gray-100">{parish.name}</p>
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        {formatRelativeTime(article.publishedAt)}
                      </p>
                    </div>
                  </div>

                  {/* Tiêu đề */}
                  <Link href={href} className="block px-4 pb-3">
                    <h3 className="text-base font-medium text-gray-900 hover:text-brand-700 dark:text-gray-100 dark:hover:text-brand-400">
                      {article.title}
                    </h3>
                  </Link>

                  {/* Ảnh bìa */}
                  {article.coverUrl && (
                    <Link href={href} className="block">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img
                        src={article.coverUrl}
                        alt={article.title}
                        className="max-h-[28rem] w-full object-cover"
                      />
                    </Link>
                  )}

                  {/* Footer */}
                  <div className="border-t border-gray-100 px-4 py-2.5 dark:border-gray-800">
                    <Link
                      href={href}
                      className="text-sm font-medium text-brand-700 hover:text-brand-800 dark:text-brand-400 dark:hover:text-brand-300"
                    >
                      Đọc tiếp →
                    </Link>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </div>
  );
}
