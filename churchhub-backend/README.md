# ChurchHub Backend

API backend cho trang web tổng hợp thông tin **giáo xứ Công giáo** (nhà thờ).
Cung cấp các endpoint công khai để **đọc** thông tin (giáo xứ, linh mục, giờ lễ, bài viết)
và các endpoint **ghi** dành cho quản trị viên, được bảo vệ bằng JWT.

> Frontend (Next.js) nằm ở repo riêng. Đây thuần là **REST API trả về JSON**, không có
> trang giao diện ở `/`.

---

## Mục lục

1. [Công nghệ sử dụng](#1-công-nghệ-sử-dụng)
2. [Mã nguồn hoạt động như thế nào (kiến trúc)](#2-mã-nguồn-hoạt-động-như-thế-nào-kiến-trúc)
3. [Luồng xử lý một request API](#3-luồng-xử-lý-một-request-api)
4. [Cơ chế xác thực & phân quyền (JWT)](#4-cơ-chế-xác-thực--phân-quyền-jwt)
5. [Danh sách API & cách gọi](#5-danh-sách-api--cách-gọi)
6. [Kết nối cơ sở dữ liệu](#6-kết-nối-cơ-sở-dữ-liệu)
7. [Cấu trúc database](#7-cấu-trúc-database)
8. [Chạy dự án ở máy local](#8-chạy-dự-án-ở-máy-local)
9. [Biến môi trường](#9-biến-môi-trường)
10. [Định dạng lỗi](#10-định-dạng-lỗi)

---

## 1. Công nghệ sử dụng

| Thành phần        | Công nghệ                                                   |
|-------------------|------------------------------------------------------------|
| Ngôn ngữ          | Java 21                                                     |
| Framework         | Spring Boot 3.3.4 (Web, Data JPA, Security, Validation)     |
| Cơ sở dữ liệu     | PostgreSQL                                                  |
| Quản lý schema    | Flyway (migration trong `src/main/resources/db/migration`) |
| Xác thực          | JWT — thư viện jjwt 0.12.x, mật khẩu băm bằng BCrypt        |
| Tài liệu API      | springdoc-openapi (Swagger UI)                             |
| Build tool        | Maven                                                       |
| Tiện ích          | Lombok                                                      |

---

## 2. Mã nguồn hoạt động như thế nào (kiến trúc)

### 2.1. Tổ chức package theo **tính năng** (feature-based)

Mỗi nghiệp vụ là một thư mục riêng dưới `com.churchhub`, bên trong gồm đầy đủ
entity, repository, service, controller và thư mục con `dto/`:

```
com.churchhub
├── auth/          Đăng nhập / làm mới token (AuthController, AuthService, dto/)
├── user/          Quản lý tài khoản admin (User, UserService, UserController, dto/)
├── parish/        Giáo xứ — và gộp linh mục + giờ lễ ở màn hình chi tiết
├── priest/        Linh mục
├── massschedule/  Giờ lễ
├── article/       Bài viết / tin tức của giáo xứ
├── registration/  Đăng ký xin làm admin (AdminRegistration)
│
├── config/        Cấu hình hệ thống:
│                  SecurityConfig (chuỗi filter bảo mật), CorsConfig,
│                  OpenApiConfig (Swagger), RestAuthEntryPoint (trả 401/403),
│                  SuperAdminBootstrap (tạo super admin lần đầu)
├── security/      JwtService, JwtAuthenticationFilter, CustomUserDetailsService,
│                  AuthUser (principal), ParishAccessGuard, SecurityUtils
└── common/        Xử lý chung: GlobalExceptionHandler, ApiError, các Exception
                   tuỳ biến, BaseEntity, SlugUtil, PageResponse
```

### 2.2. Phân lớp **nghiêm ngặt** (Controller → Service → Repository)

```
HTTP Request
    │
    ▼
┌─────────────┐  Controller — "mỏng": chỉ map HTTP ↔ DTO rồi gọi service.
│ Controller  │  KHÔNG chứa logic nghiệp vụ. Khai báo phân quyền bằng @PreAuthorize.
└─────────────┘
    │  (DTO request)
    ▼
┌─────────────┐  Service — chứa TOÀN BỘ logic nghiệp vụ + kiểm tra quyền sở hữu
│  Service    │  (gọi parishAccess.assertCanManage()). Mở transaction tại đây.
└─────────────┘
    │  (Entity)
    ▼
┌─────────────┐  Repository — interface Spring Data JPA, thao tác với database.
│ Repository  │
└─────────────┘
    │
    ▼
 PostgreSQL
```

**Các quy tắc bắt buộc trong mã nguồn:**

- **Không bao giờ trả entity ra ngoài API.** Mọi endpoint dùng DTO request/response
  (Java `record`) với factory method `static from(entity)`. Input được kiểm tra bằng
  annotation `jakarta.validation` (`@NotBlank`, `@Email`, …) trên DTO request.
- DTO nằm trong thư mục `dto/` của từng tính năng.
- Mọi lỗi đi qua `common/GlobalExceptionHandler` để trả về JSON đồng nhất. Code nghiệp vụ
  ném các exception tuỳ biến: `NotFoundException` (404), `ForbiddenException` (403),
  `ConflictException` (409), `BadRequestException` (400).
- Endpoint phân trang trả về `common/PageResponse<T>` (không trả thẳng `Page` của Spring).
- **Schema do Flyway sở hữu**, Hibernate chạy ở chế độ `validate` (chỉ kiểm tra, không
  tạo/sửa bảng). Muốn đổi cấu trúc: thêm file migration mới `V*.sql` **và** sửa entity tương ứng.

---

## 3. Luồng xử lý một request API

### 3.1. Request ĐỌC công khai — ví dụ `GET /api/parishes/{slug}`

```
Client
  │  GET /api/parishes/nha-tho-chanh-toa
  ▼
JwtAuthenticationFilter   → không có token cũng không sao (endpoint là permitAll)
  ▼
SecurityConfig            → khớp matcher GET /api/parishes/** = permitAll → cho qua
  ▼
ParishController.getBySlug(slug)
  ▼
ParishService.getBySlug(slug)
  ├─ parishRepository.findBySlug(slug)            → lấy giáo xứ (404 nếu không có)
  ├─ priestRepository.findByParishId...           → lấy danh sách linh mục
  └─ massScheduleRepository.findByParishId...     → lấy giờ lễ
  ▼
ParishDetailResponse.of(parish, priests, schedules)   → gói thành DTO
  ▼
Client nhận JSON: { parish, priests, massSchedules }
```

### 3.2. Request GHI cần đăng nhập — ví dụ `PUT /api/parishes/{id}`

```
Client
  │  PUT /api/parishes/5
  │  Header: Authorization: Bearer <access-token>
  │  Body:   { "name": "...", "address": "..." }
  ▼
JwtAuthenticationFilter
  ├─ Đọc header "Authorization: Bearer ..."
  ├─ jwtService.isAccessToken(token)?   (chỉ chấp nhận access token)
  ├─ extractSubject(token) → email      → CustomUserDetailsService nạp AuthUser
  └─ Đặt Authentication vào SecurityContext (kèm role + parishId)
  ▼
SecurityConfig            → endpoint không phải GET công khai → yêu cầu authenticated
  ▼
@PreAuthorize("hasAnyRole('SUPER_ADMIN','PARISH_ADMIN')")  → kiểm tra ROLE
  ▼
ParishController.update(id, request)
  ▼
ParishService.update(id, request)
  ├─ parishAccess.assertCanManage(id)   → kiểm tra QUYỀN SỞ HỮU:
  │       • SUPER_ADMIN  → luôn cho phép
  │       • PARISH_ADMIN → chỉ khi parishId trùng giáo xứ của họ
  │       • ngược lại     → ném ForbiddenException (403)
  ├─ cập nhật entity, sinh lại slug nếu đổi tên (SlugUtil)
  └─ parishRepository.save(parish)
  ▼
ParishResponse.from(saved)  → trả DTO phẳng
```

> **Hai lớp phân quyền cho mọi thao tác ghi:** (1) **Role** kiểm bằng `@PreAuthorize`
> ở controller; (2) **Quyền sở hữu giáo xứ** kiểm trong service bằng `ParishAccessGuard`.
> Cả hai đều bắt buộc.

---

## 4. Cơ chế xác thực & phân quyền (JWT)

Hệ thống **stateless** (không session). Sau khi đăng nhập, client tự đính kèm token vào
mỗi request.

### 4.1. Luồng đăng nhập và sử dụng token

```
1) POST /api/auth/login   { email, password }
        │  AuthService: tìm user theo email → so khớp BCrypt → kiểm tra enabled
        ▼
   Trả về: { accessToken, refreshToken, tokenType: "Bearer", expiresIn }

2) Gọi API ghi:  Header  Authorization: Bearer <accessToken>
        │  JwtAuthenticationFilter xác thực access token cho từng request
        ▼
   Được phép nếu token hợp lệ + đúng role + đúng quyền sở hữu

3) Khi accessToken hết hạn (mặc định 15 phút):
   POST /api/auth/refresh   { refreshToken }
        ▼
   Trả về cặp token mới
```

### 4.2. Hai loại token (phân biệt bằng claim `type`)

| Loại            | Claim `type` | Thời hạn mặc định | Dùng để                                       |
|-----------------|--------------|-------------------|-----------------------------------------------|
| **Access token**  | `access`   | 15 phút           | Xác thực **mọi** request (gửi qua header)      |
| **Refresh token** | `refresh`  | 7 ngày            | **Chỉ** dùng ở `POST /api/auth/refresh`        |

`JwtAuthenticationFilter` **chỉ chấp nhận access token** để xác thực; refresh token bị từ
chối ở mọi nơi trừ endpoint refresh. Access token mang theo `role` và `parishId` của người dùng.

### 4.3. Vai trò (role)

- **`SUPER_ADMIN`** — quản trị toàn hệ thống, quản lý mọi giáo xứ, quản lý tài khoản admin.
  **Chỉ tồn tại đúng một** super admin; được tạo qua `SuperAdminBootstrap` (hoặc seed).
- **`PARISH_ADMIN`** — chỉ quản lý **giáo xứ của chính mình** (linh mục, giờ lễ, bài viết
  của giáo xứ đó). Một admin gắn với tối đa một giáo xứ (`users.parish_id`).

`ParishAccessGuard` (bean tên `parishAccess`) là nơi thực thi quyền sở hữu, dùng theo 2 cách:

```java
// Cách 1 — SpEL trên controller/service:
@PreAuthorize("@parishAccess.canManage(#parishId, principal)")

// Cách 2 — trong service (ưu tiên khi cần truy DB để biết parishId):
parishAccess.assertCanManage(parishId);
```

---

## 5. Danh sách API & cách gọi

Tất cả endpoint có tiền tố `/api`. Các `GET` công khai là `permitAll`; phần còn lại cần
đăng nhập + đúng quyền.

| Method & path                          | Quyền truy cập                       |
|----------------------------------------|--------------------------------------|
| `POST /auth/login`                     | công khai (rate-limited theo email)  |
| `POST /auth/refresh`                   | công khai (refresh token hợp lệ)     |
| `POST /auth/logout`                    | đã đăng nhập (tăng token_version, vô hiệu hoá mọi token cũ) |
| `POST /registrations`                  | công khai (đăng ký PARISH_ADMIN, rate-limited theo IP) |
| `GET  /registrations?status=`          | SUPER_ADMIN                          |
| `GET  /registrations/{id}`             | SUPER_ADMIN                          |
| `POST /registrations/{id}/approve`     | SUPER_ADMIN (tạo user PARISH_ADMIN)  |
| `POST /registrations/{id}/reject`      | SUPER_ADMIN                          |
| `GET  /parishes?name=&page=&size=`     | công khai (chỉ parish active; SUPER_ADMIN thấy cả inactive) |
| `GET  /parishes/{slug}`                | công khai nếu active (inactive chỉ SUPER_ADMIN/admin sở hữu thấy) |
| `POST /parishes`                       | SUPER_ADMIN                          |
| `PUT  /parishes/{id}`                  | SUPER_ADMIN hoặc PARISH_ADMIN sở hữu |
| `DELETE /parishes/{id}`                | SUPER_ADMIN                          |
| `GET  /parishes/{id}/admins`           | SUPER_ADMIN                          |
| `PUT  /parishes/{id}/admins`           | SUPER_ADMIN (đặt toàn bộ danh sách admin) |
| `GET  /parishes/{id}/priests`          | công khai                            |
| `POST /parishes/{id}/priests`          | SUPER_ADMIN hoặc admin sở hữu        |
| `PUT/DELETE /priests/{id}`             | SUPER_ADMIN hoặc admin sở hữu        |
| `GET  /parishes/{id}/mass-schedules`   | công khai                            |
| `POST /parishes/{id}/mass-schedules`   | SUPER_ADMIN hoặc admin sở hữu        |
| `PUT/DELETE /mass-schedules/{id}`      | SUPER_ADMIN hoặc admin sở hữu        |
| `GET  /parishes/{id}/articles`         | công khai (chỉ bài PUBLISHED, phân trang) |
| `GET  /parishes/{id}/articles/manage`  | admin (gồm cả bài DRAFT)             |
| `GET  /articles/{id}`                  | công khai nếu PUBLISHED, nếu DRAFT thì chỉ admin sở hữu |
| `POST /parishes/{id}/articles`         | SUPER_ADMIN hoặc admin sở hữu        |
| `PUT/DELETE /articles/{id}`            | SUPER_ADMIN hoặc admin sở hữu        |
| `GET/POST /admin/users`                | SUPER_ADMIN                          |
| `PUT/DELETE /admin/users/{id}`         | SUPER_ADMIN                          |

> **Lưu ý hình dạng response:** `POST /api/parishes` trả về `ParishDetailResponse`
> (`{ parish, priests, massSchedules }` — id nằm trong `.parish`) và cho phép gửi kèm
> danh sách `massSchedules`. Còn `PUT /api/parishes/{id}` trả về `ParishResponse` phẳng.

### Ví dụ gọi API bằng `curl`

```bash
# 1) Đăng nhập, lấy access token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@churchhub.local","password":"<mật-khẩu>"}'
# → { "accessToken": "eyJ...", "refreshToken": "eyJ...", "tokenType": "Bearer", "expiresIn": 900000 }

# 2) Gọi endpoint công khai (không cần token)
curl http://localhost:8080/api/parishes?name=chanh%20toa

# 3) Gọi endpoint ghi (đính kèm access token)
curl -X POST http://localhost:8080/api/parishes \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"name":"Giáo xứ Chánh Toà","address":"Nha Trang"}'

# 4) Làm mới token khi access token hết hạn
curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"eyJ..."}'
```

Tài liệu tương tác đầy đủ tại **Swagger UI**: <http://localhost:8080/swagger-ui/index.html>

---

## 6. Kết nối cơ sở dữ liệu

Backend kết nối PostgreSQL qua **Spring Data JPA + HikariCP**. Cấu hình nằm ở
`src/main/resources/application.yml`, nhận giá trị từ biến môi trường (có sẵn giá trị mặc
định cho môi trường dev):

```yaml
spring:
  datasource:
    url:      ${DB_URL:jdbc:postgresql://localhost:5432/churchhub}
    username: ${DB_USERNAME:churchhub}
    password: ${DB_PASSWORD:churchhub}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate     # Hibernate KHÔNG tạo/sửa bảng — chỉ kiểm tra khớp schema
    open-in-view: false
  flyway:
    enabled: true            # Flyway tự chạy migration khi khởi động
    locations: classpath:db/migration
```

### Các bước kết nối

1. **Cài và chạy PostgreSQL** (ví dụ trên macOS dùng Homebrew):
   ```bash
   brew install postgresql@16
   brew services start postgresql@16
   ```

2. **Tạo database và user** khớp với cấu hình mặc định:
   ```bash
   createdb churchhub
   psql -d churchhub -c "CREATE USER churchhub WITH PASSWORD 'churchhub';"
   psql -d churchhub -c "GRANT ALL PRIVILEGES ON DATABASE churchhub TO churchhub;"
   ```
   Hoặc trỏ tới database sẵn có bằng các biến `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`.

3. **Khởi động ứng dụng** — Flyway tự động áp dụng các migration `V1 → V4` để tạo bảng và
   dữ liệu seed. Hibernate sẽ kiểm tra (`validate`) entity có khớp schema không; nếu lệch,
   ứng dụng **không khởi động được**.

4. **Kiểm tra kết nối nhanh:**
   ```bash
   PGPASSWORD=churchhub psql -h localhost -U churchhub -d churchhub -c "\dt"
   ```

> Log khởi động sẽ in dòng `Flyway ... Database: jdbc:postgresql://localhost:5432/churchhub`
> và `Successfully validated N migrations` khi kết nối thành công.

---

## 7. Cấu trúc database

Schema do **Flyway** quản lý trong `src/main/resources/db/migration/`:

| Migration                              | Nội dung                                                    |
|----------------------------------------|------------------------------------------------------------|
| `V1__init_schema.sql`                  | Tạo toàn bộ bảng, ràng buộc, index, trigger, seed ban đầu   |
| `V2__admin_registrations.sql`          | Bảng đăng ký xin làm admin                                  |
| `V3__relax_parish_admin_parish.sql`    | Cho phép PARISH_ADMIN tạm thời chưa gắn giáo xứ (parish_id NULL) |
| `V4__seed_nha_trang_parishes.sql`      | Seed dữ liệu mẫu các giáo xứ Nha Trang                      |

Các bảng chính:

| Bảng                  | Mô tả                                                          |
|-----------------------|---------------------------------------------------------------|
| `parishes`            | Giáo xứ — `slug` duy nhất toàn cục, `is_active` để ẩn/hiện (xoá mềm) |
| `users`              | Tài khoản admin — `role` (SUPER_ADMIN/PARISH_ADMIN), `parish_id`, mật khẩu BCrypt |
| `priests`            | Linh mục thuộc giáo xứ (PASTOR / PAROCHIAL_VICAR)             |
| `mass_schedules`     | Giờ lễ (WEEKDAY/SUNDAY/SPECIAL, `day_of_week` 1–7, `mass_time`) |
| `articles`           | Bài viết — `status` DRAFT/PUBLISHED, slug duy nhất theo từng giáo xứ |
| `admin_registrations`| Yêu cầu xin cấp quyền admin                                    |

Quy ước schema quan trọng:

- **ID** kiểu `BIGINT GENERATED ALWAYS AS IDENTITY` → entity dùng `GenerationType.IDENTITY`.
- **Enum** lưu dạng chuỗi (`@Enumerated(EnumType.STRING)`).
- `created_at` / `updated_at` do **DB tự quản** (DEFAULT `now()` + trigger `set_updated_at()`);
  entity map ở chế độ chỉ-đọc qua `common/BaseEntity` — **không set trong Java**.
- Ràng buộc CHECK: `SUPER_ADMIN` bắt buộc `parish_id = NULL`; từ `V3`, `PARISH_ADMIN` có thể
  tạm thời `parish_id = NULL`.
- Xoá giáo xứ là **xoá cứng** (chỉ SUPER_ADMIN); các bản ghi con cascade theo (`ON DELETE CASCADE`).
- **Slug** sinh từ tên tiếng Việt bằng `common/SlugUtil.slugify()` (bỏ dấu, xử lý đ/Đ); trùng
  thì thêm hậu tố `-2`, `-3`, …

---

## 8. Chạy dự án ở máy local

**Yêu cầu:** Java 21, Maven, PostgreSQL đang chạy (xem [mục 6](#6-kết-nối-cơ-sở-dữ-liệu)).

```bash
# Khai báo biến môi trường (hoặc dùng giá trị mặc định trong application.yml)
export DB_URL="jdbc:postgresql://localhost:5432/churchhub"
export DB_USERNAME="churchhub"
export DB_PASSWORD="churchhub"
export JWT_SECRET="hay-doi-thanh-chuoi-ngau-nhien-dai-it-nhat-32-byte"
# Tuỳ chọn: tự tạo super admin lần đầu khởi động (nếu chưa có super admin nào)
export SUPERADMIN_EMAIL="admin@churchhub.local"
export SUPERADMIN_PASSWORD="DoiMatKhauNgay123!"

# Biên dịch
mvn compile

# Chạy ứng dụng
mvn spring-boot:run

# Build đầy đủ + chạy test
mvn clean verify
```

Sau khi khởi động:
- API chạy ở <http://localhost:8080> (cổng đổi qua `SERVER_PORT`).
- Swagger UI: <http://localhost:8080/swagger-ui/index.html>.
- Gọi `http://localhost:8080/` (gốc) sẽ trả **401** — đây là API JSON, không có trang `/`.

> **Lưu ý về super admin:** nếu seed trong `V1` đã tạo sẵn một SUPER_ADMIN thì
> `SuperAdminBootstrap` sẽ bỏ qua (no-op) — biến `SUPERADMIN_PASSWORD` lúc đó không có tác dụng.
> Hệ thống chỉ cho phép **đúng một** SUPER_ADMIN; màn hình `/api/admin/users` chỉ tạo PARISH_ADMIN.

---

## 9. Biến môi trường

| Biến                     | Bắt buộc | Mặc định                                     | Ghi chú |
|--------------------------|----------|----------------------------------------------|---------|
| `DB_URL`                 | có\*     | `jdbc:postgresql://localhost:5432/churchhub` | JDBC URL |
| `DB_USERNAME`            | có\*     | `churchhub`                                  | |
| `DB_PASSWORD`            | có\*     | `churchhub`                                  | |
| `JWT_SECRET`             | có\*     | (placeholder cho dev)                        | tối thiểu 32 byte cho HS256 |
| `JWT_ACCESS_EXPIRATION`  | không    | `900000` (15 phút)                           | ms |
| `JWT_REFRESH_EXPIRATION` | không    | `604800000` (7 ngày)                         | ms |
| `CORS_ALLOWED_ORIGINS`   | không    | `http://localhost:3000`                      | phân tách bằng dấu phẩy |
| `SUPERADMIN_EMAIL`       | không    | `admin@churchhub.local`                      | tài khoản bootstrap |
| `SUPERADMIN_PASSWORD`    | không    | (rỗng → bỏ qua bootstrap)                     | nhập plaintext, lưu dạng BCrypt |
| `SUPERADMIN_FULL_NAME`   | không    | `Super Admin`                                | |
| `SERVER_PORT`            | không    | `8080`                                        | |

\* Có giá trị mặc định trong `application.yml` nên môi trường dev chạy được ngay; **production
bắt buộc** đặt lại các giá trị này.

---

## 10. Định dạng lỗi

Mọi lỗi đều trả về JSON đồng nhất qua `GlobalExceptionHandler`:

```json
{
  "timestamp": "2026-06-22T10:15:30.123Z",
  "status": 403,
  "error": "Forbidden",
  "message": "You are not allowed to manage parish 5",
  "path": "/api/priests/12"
}
```

Lỗi kiểm tra dữ liệu đầu vào (`400`) có thêm mảng `errors[]` mô tả từng trường bị sai.

| HTTP | Exception nội bộ        | Ý nghĩa                          |
|------|-------------------------|----------------------------------|
| 400  | `BadRequestException`   | Dữ liệu/validation không hợp lệ  |
| 401  | (chưa xác thực)         | Thiếu/sai/hết hạn access token   |
| 403  | `ForbiddenException`    | Đủ đăng nhập nhưng không đủ quyền |
| 404  | `NotFoundException`     | Không tìm thấy tài nguyên        |
| 409  | `ConflictException`     | Xung đột (vd: trùng email, slug, tạo super admin thứ 2) |
