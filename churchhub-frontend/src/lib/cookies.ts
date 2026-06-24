// Shared cookie names + options for the BFF auth layer.

export const ACCESS_COOKIE = "ch_access";
export const REFRESH_COOKIE = "ch_refresh";

interface CookieOptions {
  httpOnly: boolean;
  secure: boolean;
  sameSite: "lax" | "strict" | "none";
  path: string;
  maxAge: number;
}

const isProd = process.env.NODE_ENV === "production";

export function accessCookieOptions(maxAgeSeconds: number): CookieOptions {
  return {
    httpOnly: true,
    secure: isProd,
    sameSite: "lax",
    path: "/",
    maxAge: maxAgeSeconds,
  };
}

export function refreshCookieOptions(maxAgeSeconds: number): CookieOptions {
  return {
    httpOnly: true,
    secure: isProd,
    sameSite: "lax",
    path: "/",
    maxAge: maxAgeSeconds,
  };
}

// Refresh tokens default to 7 days (matches backend JWT_REFRESH_EXPIRATION default).
export const REFRESH_MAX_AGE = 7 * 24 * 60 * 60;
