"use client";

/**
 * Uploads an image and returns a persistent URL (Vercel Blob storage).
 *
 * Posts to the Next.js route handler POST /api/upload, which stores the file in
 * Vercel Blob and returns its public URL. Survives reloads and server-side
 * rendering — unlike a blob: object URL, which only lives in the uploading tab.
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
