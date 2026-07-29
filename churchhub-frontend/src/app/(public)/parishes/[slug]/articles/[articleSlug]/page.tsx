import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getArticle, getParishDetail, listParishArticles, ApiError } from "@/lib/api";
import type { Parish } from "@/lib/types";
import { formatDate } from "@/lib/format";
import { getTranslations } from "@/lib/i18n/server";
import { articleJsonLd, excerpt } from "@/lib/seo";
import { absoluteUrl } from "@/lib/site";

async function resolveArticleId(slug: string, articleSlug: string) {
  const { parish } = await getParishDetail(slug);
  // The backend fetches articles by id; map the slug -> id via the parish list.
  const page = await listParishArticles(parish.id, 0, 200);
  const match = page.content.find((a) => a.slug === articleSlug);
  return match ? { parish, articleId: match.id } : { parish, articleId: null };
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string; articleSlug: string };
}): Promise<Metadata> {
  const { t } = getTranslations();
  const canonical = absoluteUrl(`/parishes/${params.slug}/articles/${params.articleSlug}`);
  try {
    const { articleId } = await resolveArticleId(params.slug, params.articleSlug);
    if (!articleId) return { title: t("articleDetail.fallbackTitle"), alternates: { canonical } };
    const article = await getArticle(articleId);
    const description = article.content ? excerpt(article.content) : undefined;
    return {
      title: article.title,
      description,
      alternates: { canonical },
      openGraph: {
        type: "article",
        url: canonical,
        title: article.title,
        description,
        ...(article.publishedAt ? { publishedTime: article.publishedAt } : {}),
        ...(article.coverUrl ? { images: [article.coverUrl] } : {}),
      },
      twitter: {
        title: article.title,
        description,
        ...(article.coverUrl ? { card: "summary_large_image", images: [article.coverUrl] } : {}),
      },
    };
  } catch {
    return { title: t("articleDetail.fallbackTitle"), alternates: { canonical } };
  }
}

export default async function ArticleDetailPage({
  params,
}: {
  params: { slug: string; articleSlug: string };
}) {
  const { t, locale } = getTranslations();
  let parish: Parish | null = null;
  let articleId: number | null = null;

  try {
    const resolved = await resolveArticleId(params.slug, params.articleSlug);
    parish = resolved.parish;
    articleId = resolved.articleId;
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  if (!parish || !articleId) notFound();

  let article;
  try {
    article = await getArticle(articleId);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  return (
    <article className="mx-auto max-w-3xl space-y-6">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleJsonLd(article, parish)) }}
      />
      <nav className="text-sm text-gray-500 dark:text-gray-400">
        <Link href="/" className="hover:text-brand-700">
          {t("articleDetail.home")}
        </Link>
        <span className="mx-2">/</span>
        <Link href={`/parishes/${parish.slug}`} className="hover:text-brand-700">
          {parish.name}
        </Link>
        <span className="mx-2">/</span>
        <span className="text-gray-700 dark:text-gray-300">{t("articleDetail.crumb")}</span>
      </nav>

      <header className="space-y-2">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-100">{article.title}</h1>
        {article.publishedAt && (
          <p className="text-sm text-gray-400 dark:text-gray-500">{formatDate(article.publishedAt, locale)}</p>
        )}
      </header>

      {article.coverUrl && (
        <div className="relative aspect-video w-full overflow-hidden rounded-xl">
          <Image
            src={article.coverUrl}
            alt={article.title}
            fill
            sizes="(min-width: 768px) 768px, 100vw"
            className="object-cover"
            priority
          />
        </div>
      )}

      {article.content && <div className="prose-content text-base">{article.content}</div>}
    </article>
  );
}
