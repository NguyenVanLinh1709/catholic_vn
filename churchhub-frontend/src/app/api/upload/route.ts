import { NextResponse } from "next/server";
import { mkdir, writeFile } from "fs/promises";
import path from "path";
import { randomUUID } from "crypto";
import { getLocale } from "@/lib/i18n/server";
import { translate } from "@/lib/i18n/messages";

// Needs the Node runtime (filesystem access).
export const runtime = "nodejs";

const MAX_BYTES = 5 * 1024 * 1024; // 5MB

/**
 * Stores an uploaded image under public/uploads and returns a stable, same-origin
 * URL (/uploads/<name>) that persists across reloads — unlike the previous
 * blob: object URL, which only lived in the uploading tab.
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

  const bytes = Buffer.from(await file.arrayBuffer());
  const ext = (file.name.split(".").pop() ?? "jpg").toLowerCase().replace(/[^a-z0-9]/g, "") || "jpg";
  const name = `${randomUUID()}.${ext}`;

  const dir = path.join(process.cwd(), "public", "uploads");
  await mkdir(dir, { recursive: true });
  await writeFile(path.join(dir, name), bytes);

  return NextResponse.json({ url: `/uploads/${name}` });
}
