# CLAUDE.md

Guidance for working in this repository.

## What this is

ChurchHub frontend — a **Next.js 14 (App Router) / React 18 / TypeScript (strict)**
web client for a Catholic parish (nhà thờ / giáo xứ) information site. It renders the
public site (parish list, parish detail, articles) and two admin areas, talking to the
separate Spring Boot backend (`../churchhub-backend`). UI copy is **Vietnamese**.

The defining architectural rule: **JWTs never reach the browser.** Next.js acts as a
Backend-for-Frontend (BFF) that holds tokens in httpOnly cookies and proxies every
backend call server-side.

## Commands

```bash
npm install
npm run dev        # http://localhost:3000
npm run build      # production build
npm run start      # serve the production build
npm run lint       # next lint
npm run typecheck  # tsc --noEmit  (run this after type-level changes)
```

Required env (`.env.local`, see `.env.example`):

```
API_BASE_URL=http://localhost:8080   # backend ORIGIN, no /api, no trailing slash
```

`API_BASE_URL` is deliberately **not** prefixed with `NEXT_PUBLIC_` — it must stay
server-only and never ship to the browser. The backend must be running and reachable,
and its `CORS_ALLOWED_ORIGINS` must include this app's origin.

## Auth & data flow — the important part

**Never call the backend from a client component.** There is exactly one place that
talks to the backend: the server-side fetch wrapper `src/lib/api.ts` (`import "server-only"`).

The flow:
1. **Login** — `POST /api/auth/login` Route Handler (`src/app/api/auth/login/route.ts`)
   calls the backend, then writes `ch_access` + `ch_refresh` as **httpOnly, SameSite=Lax**
   cookies (`src/lib/cookies.ts`). `/api/auth/refresh` rotates them; `/api/auth/logout`
   clears them.
2. **Reads** — Server Components call the typed helpers in `src/lib/api.ts`
   (`listParishes`, `getParishDetail`, …) directly.
3. **Writes** — Client components invoke **server actions** (`"use server"`,
   `src/app/**/actions.ts`) via event handlers; those actions use the same `api.ts`
   wrapper and return a serializable `ActionResult<T>` (`src/lib/action-result.ts`),
   which the UI renders as toasts.

`apiFetch` rules to preserve:
- `auth: true` attaches the access cookie and, on a `401`, calls `tryRefresh()` **once**,
  rotates cookies, and retries. Don't add ad-hoc retry/refresh logic elsewhere.
- Failures throw a typed `ApiError { status, message }`; `friendlyError()` produces
  Vietnamese messages. Surface errors through `ActionResult`, never raw.
- Default cache is `no-store`; pass `revalidate` for cacheable public reads (the public
  helpers already set 15–30s).

## Route protection (`src/middleware.ts`)

Guards `/admin/**` (PARISH_ADMIN or SUPER_ADMIN) and `/super-admin/**` (SUPER_ADMIN only),
redirecting to `/login?next=…`. It decodes the JWT payload **without verifying the
signature** — this is **UI routing only**. The backend is the sole security authority;
every mutating call is re-authorized there by role + parish ownership. Never treat the
decoded session as a security boundary.

## JWT decoding (`src/lib/jwt.ts`)

`decodeAccessToken()` base64url-decodes the payload (no signature check) to drive UI.
Notes that bite: the backend encodes `parishId` as a **string** claim (`"1"` or `"null"`),
and `sub` is the email. `src/lib/auth.ts` (`getCurrentUser()`) is the server-side way to
read the session from the cookie — prefer it over decoding inline.

## Conventions

- **Path alias** `@/*` → `src/*` (see `tsconfig.json`). Strict TS with
  `noUncheckedIndexedAccess`, `noUnusedLocals`, `noUnusedParameters` — keep it clean.
- Public pages live under the `(public)` route group as Server Components (for SEO);
  interactive pieces are Client Components.
- `src/lib/types.ts` mirrors the backend DTOs. Keep it in sync when backend DTOs change —
  this is the contract. Paged responses use the backend `PageResponse` shape
  (`{ content, page, size, totalElements, totalPages, last }`, **0-based** `page`).
- Vietnamese labels and date/time formatting live in `src/lib/format.ts` — reuse them,
  don't hand-format dates or translate role/day enums inline.
- Shared UI primitives are in `src/components/` (`Button`, `Field` incl. `PasswordInput`,
  `Modal`, `Pagination`, `Toast`, `AdminShell`, `ArticleEditor`, `ThemeToggle`, …). Look there
  before building a new one.
- **Dark mode** is class-based (`darkMode: "class"` in `tailwind.config.ts`). `ThemeToggle`
  flips the `dark` class on `<html>` and persists `localStorage.theme`; an inline script in
  `src/app/layout.tsx` applies it before paint (no flash). Style every surface with `dark:`
  variants — convention: page `gray-950`, card `gray-900`, border `gray-800`, primary text
  `gray-100`, secondary text `gray-300/400`. Note `brand` only goes to `900` (no `*-950`).
- Vietnamese date helpers in `src/lib/format.ts`: `formatDate`, and `formatRelativeTime`
  ("3 giờ trước") used by the Facebook-style article timeline on the parish detail page.

## Backend assumptions / gotchas

- The backend exposes parish **detail by slug** but admins only hold a `parishId`.
  `getParishById()` resolves it by scanning `GET /api/parishes?size=2000` — a deliberate
  workaround for a missing by-id endpoint. Don't assume a `/parishes/{id}` GET exists.
- **Create vs update return different shapes.** `createParish()` returns a `ParishDetail`
  (`{parish, priests, massSchedules}`) — read the new id from `res.data.parish.id`, not
  `res.data.id`. `updateParish()` returns a flat `Parish`.
- A parish's admins are managed from the super-admin parish edit popup via
  `setParishAdmins(parishId, userIds)` → `PUT /api/parishes/{id}/admins` (sends the full
  desired set; omitted users get unassigned). The role dropdown in `/super-admin/users` is
  locked to PARISH_ADMIN — there is exactly one (bootstrap-managed) SUPER_ADMIN.
- Parish **search** uses the `name` query param (not `search`/`q`).
- The public article list returns **PUBLISHED only**; `GET /api/articles/{id}` returns a
  draft only to a caller who can manage the parish (pass `auth` accordingly).
- **Image upload** — `src/lib/upload.ts` POSTs to the Route Handler `POST /api/upload`
  (`src/app/api/upload/route.ts`, Node runtime), which stores the file under `public/uploads/`
  and returns a stable same-origin URL (`/uploads/<uuid>.<ext>`). This persists across reloads
  and SSR; the dir is gitignored. (It writes to the local filesystem, so for a read-only/
  serverless host swap in a CDN like Cloudinary — `upload.ts` notes where.) Older records may
  still hold dead `blob:` URLs from the previous stub; those need re-uploading.
- `next.config.mjs` allows remote image hosts (`https://**`) so cover/photo URLs work
  once real uploads are wired.
