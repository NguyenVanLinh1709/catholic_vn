import type { MetadataRoute } from "next";
import { listParishes } from "@/lib/api";
import { absoluteUrl } from "@/lib/site";

/**
 * Dynamic sitemap: the directory home plus every parish detail page. Parish
 * pages are public reads, so no auth is needed. Fetched in one large page to
 * mirror the existing "no by-id endpoint" workaround used elsewhere.
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
  } catch {
    // If the backend is unreachable, still return the home entry rather than 500.
  }

  return entries;
}
