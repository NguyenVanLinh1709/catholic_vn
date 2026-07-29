-- =====================================================================
--  Split parish address into structured components (Province + Ward)
--  so parishes can be filtered by region, matching Vietnam's 2025
--  administrative reform (Tỉnh/Thành phố -> Phường/Xã, no district tier).
--  `address` keeps its existing meaning as the free-text detail line
--  (số nhà, đường...).
--
--  Existing seed parishes (V4) only had a single free-text address with
--  no province/ward breakdown, so they're cleared here rather than
--  guessed at. Cascades to their priests/mass_schedules/articles;
--  users.parish_id is ON DELETE SET NULL, so any PARISH_ADMIN accounts
--  are unassigned, not deleted.
-- =====================================================================
DELETE FROM parishes;

ALTER TABLE parishes
    ADD COLUMN province VARCHAR(120),
    ADD COLUMN ward     VARCHAR(150);

CREATE INDEX idx_parishes_province ON parishes (province);
