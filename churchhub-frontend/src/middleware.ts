import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { ACCESS_COOKIE } from "@/lib/cookies";
import { decodeAccessToken } from "@/lib/jwt";

/**
 * Route protection for UI areas. This only *routes* based on the (unverified)
 * token payload — real authorization is enforced by the backend on every call.
 *
 *   /admin/**        -> PARISH_ADMIN or SUPER_ADMIN
 *   /super-admin/**  -> SUPER_ADMIN only
 *   not logged in / wrong role -> redirect to /login
 */
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const token = request.cookies.get(ACCESS_COOKIE)?.value;
  const user = token ? decodeAccessToken(token) : null;

  if (!user) return redirectToLogin(request);

  if (pathname.startsWith("/super-admin") && user.role !== "SUPER_ADMIN") {
    return redirectToLogin(request);
  }

  if (
    pathname.startsWith("/admin") &&
    user.role !== "PARISH_ADMIN" &&
    user.role !== "SUPER_ADMIN"
  ) {
    return redirectToLogin(request);
  }

  return NextResponse.next();
}

function redirectToLogin(request: NextRequest) {
  const url = request.nextUrl.clone();
  url.pathname = "/login";
  url.search = `?next=${encodeURIComponent(request.nextUrl.pathname)}`;
  return NextResponse.redirect(url);
}

export const config = {
  matcher: ["/admin/:path*", "/super-admin/:path*"],
};
