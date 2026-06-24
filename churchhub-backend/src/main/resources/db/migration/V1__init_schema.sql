-- =====================================================================
--  Church Info Hub - Database Schema (PostgreSQL)
--  Flyway migration: V1__init_schema.sql
--  Roles: SUPER_ADMIN (toàn hệ thống), PARISH_ADMIN (1 nhà thờ duy nhất)
--  Khách xem không cần tài khoản -> không có role USER.
-- =====================================================================

-- Hỗ trợ tìm kiếm gần đúng theo tên nhà thờ (ILIKE '%...%')
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Hàm dùng chung: tự cập nhật updated_at mỗi khi UPDATE
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
--  PARISHES (Nhà thờ / Giáo xứ)
-- =====================================================================
CREATE TABLE parishes (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    slug        VARCHAR(255) NOT NULL,            -- dùng cho URL: /parishes/{slug}
    address     VARCHAR(500),
    phone       VARCHAR(30),
    latitude    DECIMAL(10, 7),                   -- toạ độ bản đồ (tuỳ chọn)
    longitude   DECIMAL(10, 7),
    description TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,    -- ẩn/hiện thay cho xoá cứng
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_parishes_slug UNIQUE (slug)
);

-- Tìm kiếm tên nhà thờ nhanh với ILIKE / không phân biệt hoa thường
CREATE INDEX idx_parishes_name_trgm ON parishes USING gin (lower(name) gin_trgm_ops);
CREATE INDEX idx_parishes_active    ON parishes (is_active);

CREATE TRIGGER trg_parishes_updated_at
    BEFORE UPDATE ON parishes
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
--  USERS (chỉ tài khoản quản trị)
-- =====================================================================
CREATE TABLE users (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,          -- BCrypt hash
    full_name     VARCHAR(255),
    role          VARCHAR(20)  NOT NULL,
    parish_id     BIGINT,                          -- chỉ PARISH_ADMIN mới có
    enabled       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT fk_users_parish
        FOREIGN KEY (parish_id) REFERENCES parishes (id) ON DELETE SET NULL,
    CONSTRAINT chk_users_role
        CHECK (role IN ('SUPER_ADMIN', 'PARISH_ADMIN')),
    -- Bất biến quan trọng: PARISH_ADMIN bắt buộc gắn 1 nhà thờ,
    -- SUPER_ADMIN không được gắn nhà thờ nào.
    CONSTRAINT chk_users_role_parish CHECK (
        (role = 'PARISH_ADMIN' AND parish_id IS NOT NULL)
        OR (role = 'SUPER_ADMIN' AND parish_id IS NULL)
    )
);

CREATE INDEX idx_users_parish ON users (parish_id);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
--  PRIESTS (Cha quản xứ / Cha phó xứ)
-- =====================================================================
CREATE TABLE priests (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parish_id   BIGINT NOT NULL,
    full_name   VARCHAR(255) NOT NULL,
    role        VARCHAR(30) NOT NULL,             -- PASTOR | PAROCHIAL_VICAR
    phone       VARCHAR(30),
    photo_url   VARCHAR(500),
    order_index INT NOT NULL DEFAULT 0,           -- thứ tự hiển thị
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_priests_parish
        FOREIGN KEY (parish_id) REFERENCES parishes (id) ON DELETE CASCADE,
    CONSTRAINT chk_priests_role
        CHECK (role IN ('PASTOR', 'PAROCHIAL_VICAR'))
);

CREATE INDEX idx_priests_parish ON priests (parish_id);

CREATE TRIGGER trg_priests_updated_at
    BEFORE UPDATE ON priests
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
--  MASS_SCHEDULES (Giờ lễ)
-- =====================================================================
CREATE TABLE mass_schedules (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parish_id   BIGINT NOT NULL,
    day_type    VARCHAR(20) NOT NULL,             -- WEEKDAY | SUNDAY | SPECIAL
    day_of_week SMALLINT,                         -- 1=Thứ2 ... 7=CN (ISO). NULL = áp dụng chung
    mass_time   TIME NOT NULL,
    label       VARCHAR(255),                     -- vd: "Lễ thiếu nhi", "Lễ Vọng"
    note        VARCHAR(500),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_mass_parish
        FOREIGN KEY (parish_id) REFERENCES parishes (id) ON DELETE CASCADE,
    CONSTRAINT chk_mass_day_type
        CHECK (day_type IN ('WEEKDAY', 'SUNDAY', 'SPECIAL')),
    CONSTRAINT chk_mass_day_of_week
        CHECK (day_of_week IS NULL OR day_of_week BETWEEN 1 AND 7)
);

CREATE INDEX idx_mass_parish ON mass_schedules (parish_id);

CREATE TRIGGER trg_mass_updated_at
    BEFORE UPDATE ON mass_schedules
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
--  ARTICLES (Bài viết / sự kiện giáo xứ)
-- =====================================================================
CREATE TABLE articles (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parish_id    BIGINT NOT NULL,
    author_id    BIGINT,                          -- giữ lại bài dù xoá tác giả
    title        VARCHAR(255) NOT NULL,
    slug         VARCHAR(255) NOT NULL,
    content      TEXT,
    cover_url    VARCHAR(500),
    status       VARCHAR(20) NOT NULL DEFAULT 'DRAFT',  -- DRAFT | PUBLISHED
    published_at TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_articles_parish
        FOREIGN KEY (parish_id) REFERENCES parishes (id) ON DELETE CASCADE,
    CONSTRAINT fk_articles_author
        FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_articles_status
        CHECK (status IN ('DRAFT', 'PUBLISHED')),
    -- slug chỉ cần là duy nhất trong phạm vi 1 nhà thờ
    CONSTRAINT uq_articles_parish_slug UNIQUE (parish_id, slug)
);

-- Truy vấn hay dùng: lấy bài đã đăng của 1 nhà thờ, mới nhất trước
CREATE INDEX idx_articles_parish_status_pub
    ON articles (parish_id, status, published_at DESC);

CREATE TRIGGER trg_articles_updated_at
    BEFORE UPDATE ON articles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
--  SEED: tài khoản Super Admin đầu tiên
--  LƯU Ý: password_hash dưới đây là BCrypt của chuỗi "ChangeMe123!".
--  Hãy ĐỔI MẬT KHẨU ngay sau lần đăng nhập đầu tiên,
--  hoặc tạo super admin qua CommandLineRunner ở backend cho an toàn.
-- =====================================================================
INSERT INTO users (email, password_hash, full_name, role, parish_id)
VALUES (
    'superadmin@churchhub.local',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Super Admin',
    'SUPER_ADMIN',
    NULL
);
