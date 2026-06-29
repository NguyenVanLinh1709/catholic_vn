import type { MetadataRoute } from "next";
import { absoluteUrl } from "@/lib/site";

/**
 * Allow crawling of the public site; keep authenticated/admin areas and API
 * route handlers out of the index. Points crawlers at the sitemap.
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/admin", "/super-admin", "/login", "/api"],
    },
    sitemap: absoluteUrl("/sitemap.xml"),
    host: absoluteUrl("/"),
  };
}
