# CLAUDE.md

Guidance for working in this repository.

## What this is

ChurchHub — a Spring Boot 3.3 / Java 21 REST API backend for a Catholic parish
(nhà thờ / giáo xứ) information aggregation site. Public read endpoints; authenticated
write endpoints for two admin roles. No frontend lives here (Next.js client is separate).

## Commands

```bash
mvn compile                 # compile
mvn clean verify            # full build + tests
mvn spring-boot:run         # run locally (needs Postgres + env vars, see below)
```

Required env vars to run: `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`
(min 32 bytes). Optional: `JWT_ACCESS_EXPIRATION` (default 900000ms),
`JWT_REFRESH_EXPIRATION` (default 604800000ms), `CORS_ALLOWED_ORIGINS`
(default `http://localhost:3000`), `SUPERADMIN_EMAIL`/`SUPERADMIN_PASSWORD`/
`SUPERADMIN_FULL_NAME`. Defaults live in `src/main/resources/application.yml`.

Swagger UI when running: http://localhost:8080/swagger-ui/index.html
There is **no** page at `/` — it's a JSON API, so a bare `localhost:8080` returns 401.

## Architecture & conventions

Package layout is **feature-based** under `com.churchhub`, not layer-based:
`auth/`, `user/`, `parish/`, `priest/`, `massschedule/`, `article/`, plus cross-cutting
`config/`, `security/`, `common/`. Each feature folder holds its entity, repository,
service, controller, and a `dto/` subpackage.

Strict layering — keep it this way:
- **Controllers are thin.** They only map HTTP ↔ DTO and delegate. No business logic.
- **Services hold business logic *and* authorization.** Write paths call the ownership
  guard here, not in controllers.
- **Repositories** are Spring Data JPA interfaces.

Other rules in force:
- **Never expose entities over the API.** Every endpoint uses request/response DTOs
  (Java records) with `static from(entity)` factory methods. Validate inputs with
  `jakarta.validation` annotations on request DTOs.
- DTOs/records live in each feature's `dto/` package.
- Errors go through `common/GlobalExceptionHandler` → consistent JSON
  (`{timestamp,status,error,message,path}`, plus `errors[]` for validation). Throw the
  custom exceptions in `common/` (`NotFoundException`→404, `ForbiddenException`→403,
  `ConflictException`→409, `BadRequestException`→400). Don't return ad-hoc error shapes.
- Paged endpoints return `common/PageResponse<T>` (not Spring's `Page`/`PageImpl`).

## Database — read before changing entities

- Schema is owned by **Flyway**, not Hibernate. `spring.jpa.hibernate.ddl-auto=validate`,
  so Hibernate never creates/alters tables and **will fail startup if an entity doesn't
  match the schema.** Migrations live in `src/main/resources/db/migration/`
  (`V1__init_schema.sql`, `V2__admin_registrations.sql`,
  `V3__relax_parish_admin_parish.sql`).
- To change the schema: add a new `V2__*.sql` migration **and** update the matching entity.
  Don't edit `V1` after it has been applied anywhere.
- `created_at` / `updated_at` are DB-owned (DEFAULT now() + a `set_updated_at()` trigger).
  `common/BaseEntity` maps them read-only (`insertable=false, updatable=false` + `@Generated`).
  Don't set them in Java.
- IDs are `BIGINT GENERATED ALWAYS AS IDENTITY` → `GenerationType.IDENTITY`.
  All enums are stored as strings (`@Enumerated(EnumType.STRING)`).
- The DB enforces a role/parish CHECK invariant: `SUPER_ADMIN` must have `parish_id = NULL`.
  Since `V3`, a `PARISH_ADMIN` **may be temporarily unassigned** (`parish_id = NULL`) — this
  is what lets a parish's admins be added/removed from the parish edit screen. `UserService`
  (`normalizeParish`) mirrors this — keep both in sync.
- Parishes use a *soft* delete concept via `is_active`, but the parish DELETE endpoint is a
  hard delete (SUPER_ADMIN only). Child rows cascade (`ON DELETE CASCADE`).

## Security model (the important part)

Stateless JWT (jjwt 0.12.x), no sessions. Config in `config/SecurityConfig`.

Two authorization layers, both required for writes:
1. **Role** — `SUPER_ADMIN`, `PARISH_ADMIN`. Enforced with `@PreAuthorize` on controllers
   (e.g. parish create/delete and all `/api/admin/users` are SUPER_ADMIN-only) and via
   `HttpSecurity` request matchers.
2. **Parish ownership** — `security/ParishAccessGuard` (Spring bean named `parishAccess`).
   `SUPER_ADMIN` passes everything; `PARISH_ADMIN` only when `resource.parishId ==
   principal.parishId`; otherwise `ForbiddenException` (403). Use it two ways:
   - SpEL: `@PreAuthorize("@parishAccess.canManage(#parishId, principal)")`
   - Service layer (preferred for nested resources whose parishId needs a DB lookup):
     `parishAccess.assertCanManage(parishId)`. This is the pattern used in
     PriestService / MassScheduleService / ArticleService write methods.

Tokens carry a `type` claim (`access` vs `refresh`). The `JwtAuthenticationFilter` only
authenticates **access** tokens; refresh tokens are accepted solely by
`POST /api/auth/refresh`. Don't change one without the other.

`AuthUser` (implements `UserDetails`) is the principal and carries `id`, `role`, `parishId`.
Get the current principal via `security/SecurityUtils.currentUser()` /
`requireCurrentUser()` — don't reach into `SecurityContextHolder` directly in services.

Public reads (`GET /api/parishes/**`, `/priests/**`, `/mass-schedules/**`, `/articles/**`),
`/api/auth/**`, and Swagger are `permitAll`. Everything else needs authentication.

## Slugs

`common/SlugUtil.slugify()` produces URL slugs from Vietnamese text (strips diacritics,
handles đ/Đ). On create/update, if the client omits a slug it's derived from the name/title.
Parish slugs are globally unique; article slugs are unique per parish — services suffix
`-2`, `-3`, … to de-duplicate. Reuse `SlugUtil`; don't hand-roll slug logic.

## Gotchas

- The seed `INSERT` in `V1__init_schema.sql` uses a placeholder BCrypt hash whose plaintext
  is **not** the value its comment claims. Prefer creating the first SUPER_ADMIN via
  `config/SuperAdminBootstrap` (runs only if no SUPER_ADMIN exists and `SUPERADMIN_PASSWORD`
  is set). If both the seed and bootstrap target the same role, the seed wins and bootstrap
  no-ops.
- **Exactly one `SUPER_ADMIN`.** `UserService.assertSingleSuperAdmin` rejects creating or
  promoting a second one (`409 Conflict`). The super admin is bootstrap-managed; the
  `/api/admin/users` UI only ever creates `PARISH_ADMIN`s.
- A parish's admins are managed from the parish itself: `GET /api/parishes/{id}/admins`
  lists them and `PUT /api/parishes/{id}/admins` (`{userIds:[…]}`, SUPER_ADMIN-only) sets the
  full set — listed users are assigned to the parish, previously-assigned-but-omitted users
  are unassigned (`parish_id → NULL`). Many admins per parish; one parish per admin
  (it's the single `users.parish_id` FK, not a join table).
- `POST /api/parishes` returns a **`ParishDetailResponse`** (`{parish, priests, massSchedules}`)
  and accepts an optional embedded `massSchedules` list; `PUT /api/parishes/{id}` returns a flat
  `ParishResponse`. Mind the shape difference (id is under `.parish` on create).
- Article `publishedAt` is stamped once, on first transition to `PUBLISHED`.
- Unpublished (DRAFT) articles are hidden from the public `GET /api/articles/{id}` (404
  unless the caller can manage the parish).
