"use client";

/**
 * Uploads an image and returns a persistent, same-origin URL (e.g. /uploads/xxx.jpg).
 *
 * Posts to the Next.js route handler POST /api/upload, which stores the file under
 * public/uploads. The returned URL survives reloads and server-side rendering —
 * unlike a blob: object URL, which only lives in the uploading tab.
 *
 * To switch to a CDN (e.g. Cloudinary unsigned upload), replace the body with a
 * direct POST to the provider and return its secure_url.
 */
export async function uploadImage(file: File): Promise<string> {
  const form = new FormData();
  form.append("file", file);

  const res = await fetch("/api/upload", { method: "POST", body: form });
  if (!res.ok) {
    const data = (await res.json().catch(() => ({}))) as { message?: string };
    throw new Error(data.message ?? "Tải ảnh thất bại");
  }
  const data = (await res.json()) as { url: string };
  return data.url;
}
