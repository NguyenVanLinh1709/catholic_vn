# ChurchHub Frontend

Next.js 14 (App Router) + TypeScript + Tailwind frontend for the ChurchHub parish
information site. It talks to the Spring Boot backend via a server-side BFF layer —
JWTs never touch the browser.

## Tech

- Next.js 14 App Router, React 18, TypeScript (strict)
- Tailwind CSS, hand-written components, `lucide-react` icons
- React Server Components for public pages (SEO); Client Components for interactivity

## Environment

Create `.env.local` (see `.env.example`):

```
API_BASE_URL=http://localhost:8080
```

`API_BASE_URL` is the backend **origin** (the `/api` prefix is added by the fetch
wrapper). It is intentionally **not** prefixed with `NEXT_PUBLIC_` so it stays
server-only and never ships to the browser.

## Run

```bash
npm install
npm run dev        # http://localhost:3000
npm run build      # production build
npm run typecheck  # tsc --noEmit
```

The backend must be running and reachable at `API_BASE_URL`, and its
`CORS_ALLOWED_ORIGINS` must include this app's origin (e.g. `http://localhost:3000`).

## Auth architecture (BFF)

The backend returns `{ accessToken, refreshToken }` in the login response body.
We never store these in `localStorage`. Instead, Next.js Route Handlers act as a
Backend-for-Frontend and keep the tokens in **httpOnly, SameSite=Lax** cookies:

- `POST /api/auth/login` → calls backend `/api/auth/login`, sets `ch_access` + `ch_refresh` cookies.
- `POST /api/auth/refresh` → reads the refresh cookie, calls backend `/api/auth/refresh`, rotates the cookies.
- `POST /api/auth/logout` → clears both cookies.

All authenticated backend calls go through **one** server-side fetch wrapper,
`src/lib/api.ts`:

- attaches the access token from the cookie,
- on `401`, calls refresh **once**, rotates cookies, and retries the request,
- throws a typed `ApiError { status, message }` on failure.

Because cookies are httpOnly, the browser can't read them. Client components never
call the backend directly — they invoke **server actions** (`src/app/**/actions.ts`,
`"use server"`) via `onClick`/`onChange` handlers. Those actions use the same
`api.ts` wrapper and return a serializable `ActionResult<T>` that the UI turns into
friendly toasts.

## Route protection (`src/middleware.ts`)

The middleware decodes the access-token payload (for **UI routing only** — the
backend remains the security authority) and guards:

- `/admin/**` → `PARISH_ADMIN` or `SUPER_ADMIN`
- `/super-admin/**` → `SUPER_ADMIN`
- not logged in / wrong role → redirect to `/login?next=…`

The admin shell also re-checks the role client-side as defence in depth.

## Structure

```
src/
├── app/
│   ├── (public)/                     RSC public site
│   │   ├── page.tsx                  home: search + paged parish list
│   │   ├── parishes/[slug]/          detail: info, priests, mass schedule, articles
│   │   └── parishes/[slug]/articles/[articleSlug]/
│   ├── login/                        login form
│   ├── admin/                        PARISH_ADMIN area (own parish) + actions.ts
│   ├── super-admin/                  SUPER_ADMIN area + actions.ts
│   └── api/auth/{login,refresh,logout}/route.ts   BFF
├── lib/
│   ├── api.ts          server fetch wrapper + typed endpoint helpers
│   ├── auth.ts         getCurrentUser() from cookie
│   ├── jwt.ts          decode (unverified) access token
│   ├── cookies.ts      cookie names + options
│   ├── types.ts        DTO types mirroring the backend
│   ├── format.ts       Vietnamese day/role labels, time/date formatting
│   └── upload.ts       uploadImage() — placeholder, ready for Cloudinary
├── components/         Button, Field, Modal, Pagination, Toast, AdminShell, …
└── middleware.ts
```

## Notes & backend assumptions

- Paged responses use the backend `PageResponse` shape: `{ content, page, size,
  totalElements, totalPages, last }` (0-based `page`). Parish search uses the `name`
  query param.
- The backend exposes parish **detail by slug** and articles **by id**, with the
  public article list returning only `PUBLISHED`. The admin article list therefore
  shows published items; drafts remain editable via their edit URL.
- Image upload is stubbed in `src/lib/upload.ts` (returns a local object URL). Swap
  the body for the documented Cloudinary unsigned upload to enable real uploads.
```
