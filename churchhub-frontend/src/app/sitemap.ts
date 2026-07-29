import type { MetadataRoute } from "next";
import { listParishes, listParishArticles } from "@/lib/api";
import type { ArticleSummary } from "@/lib/types";
import { absoluteUrl } from "@/lib/site";

/**
 * Dynamic sitemap: the directory home, every parish detail page, and every
 * published article. Parish/article reads are public, so no auth is needed.
 * Fetched in one large page to mirror the existing "no by-id endpoint"
 * workaround used elsewhere.
 */
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const entries: MetadataRoute.Sitemap = [
    { url: absoluteUrl("/"), changeFrequency: "daily", priority: 1 },
  ];

  try {
    const { content } = await listParishes({ page: 0, size: 2000 });
    for (const parish of content) {
      entries.push({
        url: absoluteUrl(`/parishes/${parish.slug}`),
        lastModified: parish.updatedAt ? new Date(parish.updatedAt) : undefined,
        changeFrequency: "weekly",
        priority: 0.8,
      });
    }

    // One parish's articles failing to load shouldn't drop the rest of the sitemap.
    const articleLists = await Promise.all(
      content.map((parish) =>
        listParishArticles(parish.id, 0, 200)
          .then((page) => ({ slug: parish.slug, articles: page.content }))
          .catch(() => ({ slug: parish.slug, articles: [] as ArticleSummary[] })),
      ),
    );
    for (const { slug, articles } of articleLists) {
      for (const article of articles) {
        entries.push({
          url: absoluteUrl(`/parishes/${slug}/articles/${article.slug}`),
          lastModified: article.publishedAt ? new Date(article.publishedAt) : undefined,
          changeFrequency: "monthly",
          priority: 0.6,
        });
      }
    }
  } catch {
    // If the backend is unreachable, still return the home entry rather than 500.
  }

  return entries;
}
