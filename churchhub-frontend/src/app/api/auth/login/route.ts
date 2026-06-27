import { NextResponse } from "next/server";
import { cookies } from "next/headers";
import {
  ACCESS_COOKIE,
  REFRESH_COOKIE,
  REFRESH_MAX_AGE,
  accessCookieOptions,
  refreshCookieOptions,
} from "@/lib/cookies";
import type { TokenResponse } from "@/lib/types";
import { getLocale } from "@/lib/i18n/server";
import { translate } from "@/lib/i18n/messages";

export async function POST(request: Request) {
  const locale = getLocale();
  const base = process.env.API_BASE_URL;
  if (!base) {
    return NextResponse.json({ message: translate(locale, "error.apiNotConfigured") }, { status: 500 });
  }

  let payload: { email?: string; password?: string };
  try {
    payload = await request.json();
  } catch {
    return NextResponse.json({ message: translate(locale, "error.invalidData") }, { status: 400 });
  }

  const { email, password } = payload;
  if (!email || !password) {
    return NextResponse.json({ message: translate(locale, "login.needCredentials") }, { status: 400 });
  }

  const res = await fetch(`${base.replace(/\/$/, "")}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
    cache: "no-store",
  });

  if (!res.ok) {
    const message =
      res.status === 401 ? translate(locale, "error.badCredentials") : translate(locale, "login.failed");
    return NextResponse.json({ message }, { status: res.status === 401 ? 401 : 502 });
  }

  const tokens = (await res.json()) as TokenResponse;
  const store = cookies();
  store.set(
    ACCESS_COOKIE,
    tokens.accessToken,
    accessCookieOptions(Math.floor(tokens.expiresIn / 1000)),
  );
  store.set(REFRESH_COOKIE, tokens.refreshToken, refreshCookieOptions(REFRESH_MAX_AGE));

  return NextResponse.json({ ok: true });
}
