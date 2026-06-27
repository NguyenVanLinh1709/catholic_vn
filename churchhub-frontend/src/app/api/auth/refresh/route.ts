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

export async function POST() {
  const locale = getLocale();
  const base = process.env.API_BASE_URL;
  if (!base) {
    return NextResponse.json({ message: translate(locale, "error.apiNotConfigured") }, { status: 500 });
  }

  const store = cookies();
  const refreshToken = store.get(REFRESH_COOKIE)?.value;
  if (!refreshToken) {
    return NextResponse.json({ message: translate(locale, "error.noSession") }, { status: 401 });
  }

  const res = await fetch(`${base.replace(/\/$/, "")}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken }),
    cache: "no-store",
  });

  if (!res.ok) {
    // Refresh failed -> clear cookies so the client is treated as logged out.
    store.delete(ACCESS_COOKIE);
    store.delete(REFRESH_COOKIE);
    return NextResponse.json({ message: translate(locale, "error.sessionExpired") }, { status: 401 });
  }

  const tokens = (await res.json()) as TokenResponse;
  store.set(
    ACCESS_COOKIE,
    tokens.accessToken,
    accessCookieOptions(Math.floor(tokens.expiresIn / 1000)),
  );
  store.set(REFRESH_COOKIE, tokens.refreshToken, refreshCookieOptions(REFRESH_MAX_AGE));

  return NextResponse.json({ ok: true });
}
