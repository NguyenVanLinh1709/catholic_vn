import type { Role, SessionUser } from "./types";

interface RawClaims {
  sub?: string;
  role?: string;
  // backend encodes parishId as a string claim ("1" or "null").
  parishId?: string | number | null;
  exp?: number;
}

function base64UrlDecode(input: string): string {
  const normalized = input.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized.padEnd(normalized.length + ((4 - (normalized.length % 4)) % 4), "=");
  // atob exists in both the Edge runtime (middleware) and Node 18+.
  const binary = atob(padded);
  // Decode UTF-8 safely.
  const bytes = Uint8Array.from(binary, (c) => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

/** Decodes a JWT payload WITHOUT verifying the signature. UI-routing only. */
export function decodeAccessToken(token: string): SessionUser | null {
  try {
    const parts = token.split(".");
    if (parts.length < 2 || !parts[1]) return null;
    const claims = JSON.parse(base64UrlDecode(parts[1])) as RawClaims;

    if (!claims.sub || !claims.role) return null;
    const role = claims.role as Role;
    if (role !== "SUPER_ADMIN" && role !== "PARISH_ADMIN") return null;

    const rawParish = claims.parishId;
    const parishId =
      rawParish === null || rawParish === undefined || rawParish === "null"
        ? null
        : Number(rawParish);

    return {
      email: claims.sub,
      role,
      parishId: Number.isNaN(parishId as number) ? null : parishId,
    };
  } catch {
    return null;
  }
}

/** True if the token's exp claim is in the past (with a small skew). */
export function isExpired(token: string): boolean {
  try {
    const parts = token.split(".");
    if (!parts[1]) return true;
    const claims = JSON.parse(base64UrlDecode(parts[1])) as RawClaims;
    if (!claims.exp) return false;
    return Date.now() >= claims.exp * 1000 - 5000;
  } catch {
    return true;
  }
}
