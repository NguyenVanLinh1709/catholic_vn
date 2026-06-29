/**
 * Public canonical origin of this site, used for all SEO concerns
 * (metadataBase, canonical URLs, Open Graph, sitemap, robots).
 *
 * Read from NEXT_PUBLIC_SITE_URL; falls back to localhost for dev. Always
 * normalized to have no trailing slash so callers can concatenate paths.
 */
export const SITE_URL = (
  process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"
).replace(/\/$/, "");

/** Absolute URL for a site-relative path (e.g. "/parishes/abc"). */
export function absoluteUrl(path: string): string {
  return `${SITE_URL}${path.startsWith("/") ? path : `/${path}`}`;
}
