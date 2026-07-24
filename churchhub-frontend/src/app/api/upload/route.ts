import { NextResponse } from "next/server";
import { put } from "@vercel/blob";
import { randomUUID } from "crypto";
import { getLocale } from "@/lib/i18n/server";
import { translate } from "@/lib/i18n/messages";

// Needs the Node runtime (Buffer/crypto).
export const runtime = "nodejs";

const MAX_BYTES = 5 * 1024 * 1024; // 5MB

/**
 * Stores an uploaded image in Vercel Blob storage and returns its public URL.
 * Vercel's serverless functions have no persistent/writable filesystem, so files
 * can't be saved under public/ at runtime — Blob storage is the replacement.
 */
export async function POST(request: Request) {
  const form = await request.formData();
  const file = form.get("file");

  const locale = getLocale();
  if (!(file instanceof File)) {
    return NextResponse.json({ message: translate(locale, "upload.missingFile") }, { status: 400 });
  }
  if (!file.type.startsWith("image/")) {
    return NextResponse.json({ message: translate(locale, "upload.imageOnly") }, { status: 400 });
  }
  if (file.size > MAX_BYTES) {
    return NextResponse.json({ message: translate(locale, "upload.tooLarge") }, { status: 400 });
  }

  const ext = (file.name.split(".").pop() ?? "jpg").toLowerCase().replace(/[^a-z0-9]/g, "") || "jpg";
  const name = `${randomUUID()}.${ext}`;

  const blob = await put(name, file, {
    access: "public",
    addRandomSuffix: false,
    contentType: file.type,
  });

  return NextResponse.json({ url: blob.url });
}
