-- =====================================================================
--  ADMIN_REGISTRATIONS (self-service parish-admin sign-up requests)
--  Flow: a person registers (email + password + name) -> PENDING.
--  A SUPER_ADMIN approves (assigns a parish, creates the user) or rejects.
-- =====================================================================
CREATE TABLE admin_registrations (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email           VARCHAR(255) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,          -- BCrypt; reused verbatim when the user is created
    full_name       VARCHAR(255),
    status          VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    reject_reason   VARCHAR(500),
    reviewed_by     BIGINT,                          -- super admin who decided
    reviewed_at     TIMESTAMPTZ,
    created_user_id BIGINT,                          -- the users row created on approval
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_reg_reviewed_by
        FOREIGN KEY (reviewed_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT fk_reg_created_user
        FOREIGN KEY (created_user_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_reg_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

-- At most one PENDING request per email (resubmits allowed after a decision).
CREATE UNIQUE INDEX uq_reg_pending_email
    ON admin_registrations (lower(email)) WHERE status = 'PENDING';

CREATE INDEX idx_reg_status ON admin_registrations (status, created_at DESC);

CREATE TRIGGER trg_admin_registrations_updated_at
    BEFORE UPDATE ON admin_registrations
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
