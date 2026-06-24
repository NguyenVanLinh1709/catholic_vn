import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getArticle, getParishDetail, listParishArticles, ApiError } from "@/lib/api";
import { formatDate } from "@/lib/format";

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
  try {
    const { articleId } = await resolveArticleId(params.slug, params.articleSlug);
    if (!articleId) return { title: "Bài viết" };
    const article = await getArticle(articleId);
    return { title: article.title };
  } catch {
    return { title: "Bài viết" };
  }
}

export default async function ArticleDetailPage({
  params,
}: {
  params: { slug: string; articleSlug: string };
}) {
  let parishName = "";
  let parishSlug = params.slug;
  let articleId: number | null = null;

  try {
    const resolved = await resolveArticleId(params.slug, params.articleSlug);
    parishName = resolved.parish.name;
    parishSlug = resolved.parish.slug;
    articleId = resolved.articleId;
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  if (!articleId) notFound();

  let article;
  try {
    article = await getArticle(articleId);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  return (
    <article className="mx-auto max-w-3xl space-y-6">
      <nav className="text-sm text-gray-500 dark:text-gray-400">
        <Link href="/" className="hover:text-brand-700">
          Trang chủ
        </Link>
        <span className="mx-2">/</span>
        <Link href={`/parishes/${parishSlug}`} className="hover:text-brand-700">
          {parishName}
        </Link>
        <span className="mx-2">/</span>
        <span className="text-gray-700 dark:text-gray-300">Bài viết</span>
      </nav>

      <header className="space-y-2">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-100">{article.title}</h1>
        {article.publishedAt && (
          <p className="text-sm text-gray-400 dark:text-gray-500">{formatDate(article.publishedAt)}</p>
        )}
      </header>

      {article.coverUrl && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={article.coverUrl}
          alt={article.title}
          className="w-full rounded-xl object-cover"
        />
      )}

      {article.content && <div className="prose-content text-base">{article.content}</div>}
    </article>
  );
}
