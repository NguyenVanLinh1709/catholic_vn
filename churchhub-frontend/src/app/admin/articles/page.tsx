"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/Button";
import { Badge, LoadingBlock, EmptyState } from "@/components/Feedback";
import { ConfirmDialog } from "@/components/Modal";
import { Pagination } from "@/components/Pagination";
import { useToast } from "@/components/Toast";
import { formatDate } from "@/lib/format";
import { useI18n } from "@/lib/i18n/provider";
import type { ArticleSummary } from "@/lib/types";
import { listMyArticles, removeArticle } from "../actions";

export default function AdminArticlesPage() {
  const toast = useToast();
  const { t, locale } = useI18n();
  const [loading, setLoading] = useState(true);
  const [items, setItems] = useState<ArticleSummary[]>([]);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);

  const [deleteTarget, setDeleteTarget] = useState<ArticleSummary | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function reload(p = page) {
    setLoading(true);
    const res = await listMyArticles(p);
    if (res.ok) {
      setItems(res.data.content);
      setTotalPages(res.data.totalPages);
      setPage(res.data.page);
    } else {
      toast.error(res.message);
    }
    setLoading(false);
  }

  useEffect(() => {
    void reload(0);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function confirmDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    const res = await removeArticle(deleteTarget.id);
    setDeleting(false);
    if (res.ok) {
      toast.success(t("articles.deleted"));
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("articles.title")}</h1>
        <Link href="/admin/articles/new">
          <Button>
            <Plus className="h-4 w-4" />
            {t("articles.create")}
          </Button>
        </Link>
      </div>

      <p className="rounded-lg bg-amber-50 px-4 py-2 text-xs text-amber-700">
        {t("articles.draftNote")}
      </p>

      {loading ? (
        <LoadingBlock label={t("common.loading")} />
      ) : items.length === 0 ? (
        <EmptyState
          title={t("articles.emptyTitle")}
          action={
            <Link href="/admin/articles/new">
              <Button>{t("articles.create")}</Button>
            </Link>
          }
        />
      ) : (
        <>
          <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50 text-xs uppercase text-gray-500 dark:bg-gray-800/50 dark:text-gray-400">
                <tr>
                  <th className="px-4 py-3">{t("articles.colTitle")}</th>
                  <th className="px-4 py-3">{t("articles.colStatus")}</th>
                  <th className="px-4 py-3">{t("articles.colPublishedAt")}</th>
                  <th className="px-4 py-3 text-right">{t("common.actions")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {items.map((a) => (
                  <tr key={a.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50">
                    <td className="px-4 py-3 font-medium text-gray-900 dark:text-gray-100">{a.title}</td>
                    <td className="px-4 py-3">
                      {a.status === "PUBLISHED" ? (
                        <Badge color="green">{t("articles.statusPublished")}</Badge>
                      ) : (
                        <Badge color="amber">{t("articles.statusDraft")}</Badge>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{formatDate(a.publishedAt, locale) || "—"}</td>
                    <td className="px-4 py-3">
                      <div className="flex justify-end gap-1">
                        <Link href={`/admin/articles/${a.id}`}>
                          <Button variant="ghost" size="sm">
                            <Pencil className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Button variant="ghost" size="sm" onClick={() => setDeleteTarget(a)}>
                          <Trash2 className="h-4 w-4 text-red-500" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Pagination page={page} totalPages={totalPages} onChange={(p) => reload(p)} />
        </>
      )}

      <ConfirmDialog
        open={deleteTarget !== null}
        title={t("articles.deleteTitle")}
        message={t("articles.deleteMessage", { title: deleteTarget?.title ?? "" })}
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}
