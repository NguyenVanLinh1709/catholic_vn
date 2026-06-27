"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ImagePlus, X } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, Select, Textarea } from "@/components/Field";
import { useToast } from "@/components/Toast";
import { uploadImage } from "@/lib/upload";
import { useI18n } from "@/lib/i18n/provider";
import type { Article, ArticleStatus } from "@/lib/types";
import type { ArticleInput } from "@/lib/api";
import { createMyArticle, editArticle } from "@/app/admin/actions";

export function ArticleEditor({ article }: { article?: Article }) {
  const router = useRouter();
  const toast = useToast();
  const { t } = useI18n();

  const [form, setForm] = useState<ArticleInput>({
    title: article?.title ?? "",
    slug: article?.slug ?? "",
    content: article?.content ?? "",
    coverUrl: article?.coverUrl ?? "",
    status: article?.status ?? "DRAFT",
  });
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);

  function set<K extends keyof ArticleInput>(key: K, value: ArticleInput[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function onPickCover(file: File | undefined) {
    if (!file) return;
    setUploading(true);
    try {
      const url = await uploadImage(file);
      set("coverUrl", url);
      toast.success(t("editor.coverUploaded"));
    } catch {
      toast.error(t("common.uploadFailed"));
    } finally {
      setUploading(false);
    }
  }

  async function save(status: ArticleStatus) {
    if (!form.title.trim()) {
      toast.error(t("editor.titleRequired"));
      return;
    }
    setSaving(true);
    const payload: ArticleInput = {
      ...form,
      slug: form.slug?.trim() || undefined,
      content: form.content?.trim() || null,
      coverUrl: form.coverUrl?.trim() || null,
      status,
    };
    const res = article ? await editArticle(article.id, payload) : await createMyArticle(payload);
    setSaving(false);
    if (res.ok) {
      toast.success(article ? t("editor.saved") : t("editor.created"));
      router.push("/admin/articles");
      router.refresh();
    } else {
      toast.error(res.message);
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
        {article ? t("editor.editTitle") : t("editor.createTitle")}
      </h1>

      <div className="space-y-4 rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-6">
        <Field label={t("editor.fieldTitle")} required>
          <Input value={form.title} onChange={(e) => set("title", e.target.value)} />
        </Field>
        <Field label={t("editor.fieldSlug")}>
          <Input
            value={form.slug ?? ""}
            onChange={(e) => set("slug", e.target.value)}
            placeholder={t("editor.slugPlaceholder")}
          />
        </Field>

        <Field label={t("editor.fieldCover")}>
          {form.coverUrl ? (
            <div className="relative w-full max-w-md">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={form.coverUrl} alt="" className="w-full rounded-lg object-cover" />
              <button
                type="button"
                onClick={() => set("coverUrl", "")}
                className="absolute right-2 top-2 rounded-full bg-black/60 p-1 text-white"
                aria-label={t("editor.removeImage")}
              >
                <X className="h-4 w-4" />
              </button>
            </div>
          ) : (
            <label className="flex w-full max-w-md cursor-pointer flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-gray-300 py-8 text-sm text-gray-500 hover:border-brand-300 dark:border-gray-700 dark:text-gray-400">
              <ImagePlus className="h-6 w-6 text-gray-400 dark:text-gray-500" />
              {uploading ? t("common.uploading") : t("editor.chooseCover")}
              <input
                type="file"
                accept="image/*"
                className="hidden"
                disabled={uploading}
                onChange={(e) => onPickCover(e.target.files?.[0])}
              />
            </label>
          )}
        </Field>

        <Field label={t("editor.fieldContent")}>
          <Textarea
            value={form.content ?? ""}
            onChange={(e) => set("content", e.target.value)}
            className="min-h-[260px]"
          />
        </Field>

        <Field label={t("editor.fieldStatus")}>
          <Select
            value={form.status}
            onChange={(e) => set("status", e.target.value as ArticleStatus)}
          >
            <option value="DRAFT">{t("editor.statusDraft")}</option>
            <option value="PUBLISHED">{t("editor.statusPublished")}</option>
          </Select>
        </Field>

        <div className="flex justify-end gap-2">
          <Button variant="secondary" onClick={() => save("DRAFT")} loading={saving}>
            {t("editor.saveDraft")}
          </Button>
          <Button onClick={() => save("PUBLISHED")} loading={saving}>
            {t("editor.publish")}
          </Button>
        </div>
      </div>
    </div>
  );
}
