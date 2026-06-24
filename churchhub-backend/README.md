# ChurchHub Backend

Production-ready Spring Boot API for a Catholic parish (nhà thờ / giáo xứ) information
aggregation site.

## Tech stack

- Java 21, Spring Boot 3.3.x, Maven
- Spring Web, Spring Data JPA, Spring Security, Validation
- Flyway + PostgreSQL
- JWT via `io.jsonwebtoken` (jjwt 0.12.x), passwords hashed with BCrypt
- Lombok, springdoc-openapi (Swagger UI)

## Architecture

```
com.churchhub
├── config/        SecurityConfig, CorsConfig, OpenApiConfig, RestAuthEntryPoint, SuperAdminBootstrap
├── security/      JwtService, JwtAuthenticationFilter, CustomUserDetailsService, AuthUser, ParishAccessGuard
├── auth/          AuthController, AuthService, dto (LoginRequest, TokenResponse, RefreshRequest)
├── user/          User entity, repo, service, controller (admin), dto
├── parish/        Parish + priests/mass-schedules aggregation in detail view
├── priest/
├── massschedule/
├── article/
└── common/        GlobalExceptionHandler, ApiError, exceptions, BaseEntity, SlugUtil, PageResponse
```

Layering is strict: thin controllers → services (business logic + authorization) → repositories.
Entities are never exposed over the API; every endpoint uses request/response DTOs.

## Authorization model

- **Stateless JWT.** `JwtAuthenticationFilter` reads `Authorization: Bearer <token>`. Only
  *access* tokens authenticate requests; *refresh* tokens are accepted only by `/api/auth/refresh`.
- **Role layer** — `SUPER_ADMIN` and `PARISH_ADMIN`, enforced with `@PreAuthorize` /
  `HttpSecurity`.
- **Ownership layer** — `ParishAccessGuard` (bean `parishAccess`):
  - `SUPER_ADMIN` may manage every parish.
  - `PARISH_ADMIN` may manage only resources whose `parishId` equals their own.
  - Anything else → `403 ForbiddenException`.
  Usable as `@PreAuthorize("@parishAccess.canManage(#parishId, principal)")` or from the
  service layer via `parishAccess.assertCanManage(parishId)` (used throughout the write paths).
- All public **GET** read endpoints are `permitAll`; writes require authentication + role/ownership.

## Environment variables

| Variable                 | Required | Default                              | Notes |
|--------------------------|----------|--------------------------------------|-------|
| `DB_URL`                 | yes      | `jdbc:postgresql://localhost:5432/churchhub` | JDBC URL |
| `DB_USERNAME`            | yes      | `churchhub`                          | |
| `DB_PASSWORD`            | yes      | `churchhub`                          | |
| `JWT_SECRET`             | yes      | (dev placeholder)                    | min 32 bytes for HS256 |
| `JWT_ACCESS_EXPIRATION`  | no       | `900000` (15 min)                    | ms |
| `JWT_REFRESH_EXPIRATION` | no       | `604800000` (7 days)                 | ms |
| `CORS_ALLOWED_ORIGINS`   | no       | `http://localhost:3000`              | comma-separated |
| `SUPERADMIN_EMAIL`       | no       | `admin@churchhub.local`              | bootstrap account |
| `SUPERADMIN_PASSWORD`    | no       | (empty → bootstrap skipped)          | plaintext input, stored BCrypt-hashed |
| `SUPERADMIN_FULL_NAME`   | no       | `Super Admin`                        | |
| `SERVER_PORT`            | no       | `8080`                               | |

`spring.jpa.hibernate.ddl-auto=validate` — Hibernate never creates/alters tables; the schema
is owned by Flyway (`src/main/resources/db/migration/V1__init_schema.sql`).

## Run locally

1. Start PostgreSQL and create the database:

   ```bash
   createdb churchhub
   ```

2. Export environment variables:

   ```bash
   export DB_URL="jdbc:postgresql://localhost:5432/churchhub"
   export DB_USERNAME="churchhub"
   export DB_PASSWORD="churchhub"
   export JWT_SECRET="please-change-this-to-a-long-random-secret-at-least-32-bytes"
   export CORS_ALLOWED_ORIGINS="http://localhost:3000"
   # Optional: auto-create a super admin on first boot
   export SUPERADMIN_EMAIL="admin@churchhub.local"
   export SUPERADMIN_PASSWORD="ChangeMe123!"
   ```

3. Run:

   ```bash
   mvn spring-boot:run
   ```

   Flyway applies `V1__init_schema.sql` on startup. Swagger UI: <http://localhost:8080/swagger-ui.html>.

> The migration also seeds `superadmin@churchhub.local` (BCrypt of `ChangeMe123!`). Change this
> password immediately, or rely on the `SuperAdminBootstrap` runner instead and remove the seed.

## API overview (prefix `/api`)

| Method & path                          | Access                          |
|----------------------------------------|---------------------------------|
| `POST /auth/login`                     | public                          |
| `POST /auth/refresh`                   | public (valid refresh token)    |
| `GET  /parishes?name=&page=&size=`     | public (search + paging)        |
| `GET  /parishes/{slug}`                | public (incl. priests + masses) |
| `POST /parishes`                       | SUPER_ADMIN                     |
| `PUT  /parishes/{id}`                   | SUPER_ADMIN or owner PARISH_ADMIN |
| `DELETE /parishes/{id}`                | SUPER_ADMIN                     |
| `GET  /parishes/{id}/priests`          | public                          |
| `POST /parishes/{id}/priests`          | SUPER_ADMIN or owner            |
| `PUT/DELETE /priests/{id}`             | SUPER_ADMIN or owner            |
| `GET  /parishes/{id}/mass-schedules`   | public                          |
| `POST /parishes/{id}/mass-schedules`   | SUPER_ADMIN or owner            |
| `PUT/DELETE /mass-schedules/{id}`      | SUPER_ADMIN or owner            |
| `GET  /parishes/{id}/articles`         | public (PUBLISHED only, paged)  |
| `GET  /articles/{id}`                  | public if PUBLISHED, else owner |
| `POST /parishes/{id}/articles`         | SUPER_ADMIN or owner            |
| `PUT/DELETE /articles/{id}`            | SUPER_ADMIN or owner            |
| `GET/POST /admin/users`                | SUPER_ADMIN                     |
| `PUT/DELETE /admin/users/{id}`         | SUPER_ADMIN                     |

### Error shape

All errors return a consistent JSON body:

```json
{
  "timestamp": "2026-06-22T10:15:30.123Z",
  "status": 403,
  "error": "Forbidden",
  "message": "You are not allowed to manage parish 5",
  "path": "/api/priests/12"
}
```

Validation failures (`400`) additionally include a per-field `errors` array.

## Build & test

```bash
mvn clean verify
```
