import "server-only";
import { cookies } from "next/headers";
import { ACCESS_COOKIE } from "./cookies";
import { decodeAccessToken } from "./jwt";
import type { SessionUser } from "./types";

/**
 * Reads + decodes the session from the httpOnly access cookie.
 * Used to render the correct UI; the backend remains the security authority.
 */
export function getCurrentUser(): SessionUser | null {
  const token = cookies().get(ACCESS_COOKIE)?.value;
  if (!token) return null;
  return decodeAccessToken(token);
}

export function isAuthenticated(): boolean {
  return getCurrentUser() !== null;
}
