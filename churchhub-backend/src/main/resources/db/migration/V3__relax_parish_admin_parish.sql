-- =====================================================================
--  Relax the user role/parish invariant.
--  Previously a PARISH_ADMIN was REQUIRED to reference a parish. To let a
--  parish's admins be managed (added/removed) from the parish edit screen,
--  a PARISH_ADMIN may now be temporarily unassigned (parish_id NULL).
--  SUPER_ADMIN must still never be tied to a parish.
-- =====================================================================
ALTER TABLE users DROP CONSTRAINT chk_users_role_parish;

ALTER TABLE users ADD CONSTRAINT chk_users_role_parish CHECK (
    role <> 'SUPER_ADMIN' OR parish_id IS NULL
);
