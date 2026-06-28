"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Church } from "lucide-react";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import { useI18n } from "@/lib/i18n/provider";
import { relativeTime } from "@/lib/i18n/labels";
import type { ArticleSummary, Parish } from "@/lib/types";
import { getMyParish, listMyTimeline } from "../actions";

export default function AdminFeedPage() {
  const toast = useToast();
  const { t, locale } = useI18n();
  const [loading, setLoading] = useState(true);
  const [parish, setParish] = useState<Parish | null>(null);
  const [articles, setArticles] = useState<ArticleSummary[]>([]);

  useEffect(() => {
    let active = true;
    Promise.all([getMyParish(), listMyTimeline(0)]).then(([pRes, aRes]) => {
      if (!active) return;
      if (pRes.ok) setParish(pRes.data);
      else toast.error(pRes.message);
      if (aRes.ok) {
        // Newest first.
        setArticles(
          [...aRes.data.content].sort((a, b) =>
            (b.publishedAt ?? "").localeCompare(a.publishedAt ?? ""),
          ),
        );
      } else {
        toast.error(aRes.message);
      }
      setLoading(false);
    });
    return () => {
      active = false;
    };
  }, [toast]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("feed.title")}</h1>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{t("feed.subtitle")}</p>
      </div>

      {loading ? (
        <LoadingBlock label={t("common.loading")} />
      ) : !parish ? (
        <EmptyState title={t("feed.loadError")} />
      ) : articles.length === 0 ? (
        <EmptyState title={t("feed.empty")} />
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
                    <p className="truncate font-semibold text-gray-900 dark:text-gray-100">
                      {parish.name}
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      {relativeTime(t, locale, article.publishedAt)}
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
                    {t("parishDetail.readMore")}
                  </Link>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
