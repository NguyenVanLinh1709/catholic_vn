-- =====================================================================
--  Seed: parishes of the Ho Chi Minh City archdiocese (TGP Sai Gon),
--  with full Sunday + weekday mass schedules.
--
--  Source data has no address/phone/province/ward - only name + mass
--  times per day, so those columns are left NULL (not guessed).
--
--  Weekday (Mon-Sat) modeling: when a parish's 6 weekday columns are
--  all identical, it's stored as a single WEEKDAY/day_of_week=NULL set
--  (applies to every weekday). When they differ on any day, ALL SIX
--  days are stored as explicit WEEKDAY/day_of_week=1..6 entries instead
--  (never mixed with a NULL entry for the same parish) - a NULL entry
--  would apply unconditionally on top of any day-specific entries per
--  this schema's matching rules, which would double-count masses on
--  the differing day(s).
--
--  14 parish names repeat (distinct parishes sharing a common name,
--  e.g. multiple "Than Giuse" or "Hien Linh") - each is a separate row
--  with its own auto-suffixed slug (-2, -3, ...), matching how
--  ParishService.ensureUniqueSlug would resolve the same collision.
-- =====================================================================

-- 1. Nha tho An Bình (source #1)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('An Bình', 'an-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 2. Nha tho An Lạc (source #2)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('An Lạc', 'an-lac', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:15'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 3. Nha tho An Nhơn (source #3)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('An Nhơn', 'an-nhon', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 4. Nha tho An Phú (source #4)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('An Phú', 'an-phu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 5. Nha tho An Phú (source #5)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('An Phú', 'an-phu-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '12:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 6. Nha tho An Thới Đông (source #6)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('An Thới Đông', 'an-thoi-dong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 7. Nha tho Antôn (source #7)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Antôn', 'anton', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 8. Nha tho Antôn Cầu Ông Lãnh (source #8)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Antôn Cầu Ông Lãnh', 'anton-cau-ong-lanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 9. Nha tho Bà Điểm (source #9)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bà Điểm', 'ba-diem', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 10. Nha tho Ba Thôn (source #10)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Ba Thôn', 'ba-thon', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:45'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:15'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 11. Nha tho Bác Ái (source #11)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bác Ái', 'bac-ai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 12. Nha tho Bắc Dũng (source #12)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bắc Dũng', 'bac-dung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 13. Nha tho Bắc Hà (source #13)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bắc Hà', 'bac-ha', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 14. Nha tho Bạch Đằng (source #14)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bạch Đằng', 'bach-dang', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 15. Nha tho Bàn Cờ (source #15)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bàn Cờ', 'ban-co', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '06:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 16. Nha tho Bến Cát (source #16)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bến Cát', 'ben-cat', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 17. Nha tho Bến Hải (source #17)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bến Hải', 'ben-hai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 18. Nha tho Bình An (source #18)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình An', 'binh-an', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 19. Nha tho Bình An Thượng (source #19)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình An Thượng', 'binh-an-thuong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 20. Nha tho Bình Chánh (source #20)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Chánh', 'binh-chanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 21. Nha tho Bình Chiểu (source #21)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Chiểu', 'binh-chieu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 22. Nha tho Bình Đông (source #22)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Đông', 'binh-dong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 23. Nha tho Bình Hòa (source #23)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Hòa', 'binh-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 24. Nha tho Bình Hưng (source #24)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Hưng', 'binh-hung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 25. Nha tho Bình Lợi (source #25)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Lợi', 'binh-loi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 26. Nha tho Bình Minh (source #26)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Minh', 'binh-minh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 27. Nha tho Bình Phước (source #27)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Phước', 'binh-phuoc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '15:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 28. Nha tho Bình Sơn (source #28)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Sơn', 'binh-son', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 29. Nha tho Bình Thái (source #29)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Thái', 'binh-thai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 30. Nha tho Bình Thọ (source #30)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Thọ', 'binh-tho', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 31. Nha tho Bình Thới (source #31)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Thới', 'binh-thoi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 32. Nha tho Bình Thuận (source #32)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Thuận', 'binh-thuan', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 33. Nha tho Bình Thuận (source #33)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Thuận', 'binh-thuan-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 34. Nha tho Bình Xuyên (source #34)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bình Xuyên', 'binh-xuyen', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 35. Nha tho Bùi Môn (source #35)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bùi Môn', 'bui-mon', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 36. Nha tho Bùi Phát (source #36)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Bùi Phát', 'bui-phat', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 37. Nha tho Cần Giờ (source #37)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Cần Giờ', 'can-gio', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 38. Nha tho Cao Thái (source #38)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Cao Thái', 'cao-thai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:15'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 39. Nha tho Cầu Kho (source #39)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Cầu Kho', 'cau-kho', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:10'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 40. Nha tho Cầu Lớn (source #40)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Cầu Lớn', 'cau-lon', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 41. Nha tho Chánh Hưng (source #41)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chánh Hưng', 'chanh-hung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 42. Nha tho Đức Bà Chánh Toà Sài Gòn (source #42)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Bà Chánh Toà Sài Gòn', 'duc-ba-chanh-toa-sai-gon', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 43. Nha tho Châu Bình (source #43)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Châu Bình', 'chau-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 44. Nha tho Châu Nam (source #44)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Châu Nam', 'chau-nam', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 45. Nha tho Chí Hoà (source #45)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chí Hoà', 'chi-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 46. Nha tho Chính Lộ (source #46)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chính Lộ', 'chinh-lo', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 47. Nha tho Chợ Cầu (source #47)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chợ Cầu', 'cho-cau', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 48. Nha tho Chợ Đũi (source #48)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chợ Đũi', 'cho-dui', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '11:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '15:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '15:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '15:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '15:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '15:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '15:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 49. Nha tho Chợ Quán (source #49)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chợ Quán', 'cho-quan', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 50. Nha tho Chúa Hiển Linh (source #50)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Chúa Hiển Linh', 'chua-hien-linh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 51. Nha tho Công Lý (source #51)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Công Lý', 'cong-ly', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '06:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 52. Nha tho Công Thành (source #52)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Công Thành', 'cong-thanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:45'::time, NULL, NULL),
  ('SUNDAY', 7, '07:45'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 53. Nha tho Đa Minh (source #53)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đa Minh', 'da-minh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '10:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 54. Nha tho Đắc Lộ (source #54)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đắc Lộ', 'dac-lo', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '14:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 55. Nha tho Đồng Hòa (source #55)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đồng Hòa', 'dong-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 56. Nha tho Đông Quang (source #56)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đông Quang', 'dong-quang', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 57. Nha tho Đồng Tiến (source #57)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đồng Tiến', 'dong-tien', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '06:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 58. Nha tho Đức Bà Fatima (source #58)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Bà Fatima', 'duc-ba-fatima', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 59. Nha tho Đức Bà Hoà Bình (source #59)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Bà Hoà Bình', 'duc-ba-hoa-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:15'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 60. Nha tho Đức Mẹ Hằng Cứu Giúp (source #60)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Mẹ Hằng Cứu Giúp', 'duc-me-hang-cuu-giup', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 61. Nha tho Đức Mẹ Hằng Cứu Giúp (source #61)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Mẹ Hằng Cứu Giúp', 'duc-me-hang-cuu-giup-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '10:00'::time, NULL, NULL),
  ('SUNDAY', 7, '14:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('SUNDAY', 7, '20:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '06:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 62. Nha tho Đức Mẹ Vô Nhiễm (source #62)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Mẹ Vô Nhiễm', 'duc-me-vo-nhiem', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 63. Nha tho Đức Tin (source #63)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Đức Tin', 'duc-tin', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 64. Nha tho Fatima Bình Triệu (source #64)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Fatima Bình Triệu', 'fatima-binh-trieu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 65. Nha tho Gia Định (source #65)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Gia Định', 'gia-dinh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:45'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:45'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 66. Nha tho Giáo họ Giuse - Vĩnh Lộc B (source #66)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Giáo họ Giuse - Vĩnh Lộc B', 'giao-ho-giuse-vinh-loc-b', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 67. Nha tho Gò Mây (source #67)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Gò Mây', 'go-may', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 68. Nha tho Gò Vấp (source #68)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Gò Vấp', 'go-vap', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 69. Nha tho Hà Đông (source #69)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hà Đông', 'ha-dong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 70. Nha tho Hà Nội (source #70)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hà Nội', 'ha-noi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:15'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 71. Nha tho Hàng Xanh (source #71)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hàng Xanh', 'hang-xanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:45'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 72. Nha tho Hàng Sanh (source #72)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hàng Sanh', 'hang-sanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 73. Nha tho Hạnh Thông Tây (source #73)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hạnh Thông Tây', 'hanh-thong-tay', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 74. Nha tho Hiển Linh (source #74)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hiển Linh', 'hien-linh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 75. Nha tho Hiển Linh (source #75)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hiển Linh', 'hien-linh-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 76. Nha tho Hiển Linh (source #76)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hiển Linh', 'hien-linh-3', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 77. Nha tho Hòa Bình (source #77)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hòa Bình', 'hoa-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:15'::time, NULL, NULL),
  ('SUNDAY', 7, '17:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 78. Nha tho Hòa Hưng (source #78)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hòa Hưng', 'hoa-hung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 79. Nha tho Hoàng Mai (source #79)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hoàng Mai', 'hoang-mai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 80. Nha tho Hóc Môn (source #80)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hóc Môn', 'hoc-mon', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 81. Nha tho Hợp An (source #81)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hợp An', 'hop-an', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 82. Nha tho Hưng Phú (source #82)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hưng Phú', 'hung-phu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 83. Nha tho Hy Vọng (source #83)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Hy Vọng', 'hy-vong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 84. Nha tho Jeanne d'Arc (source #84)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Jeanne d''Arc', 'jeanne-d-arc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 85. Nha tho Khánh Hội (source #85)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Khánh Hội', 'khanh-hoi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 86. Nha tho Khiết Tâm (source #86)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Khiết Tâm', 'khiet-tam-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:15'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 87. Nha tho Khiết Tâm (source #87)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Khiết Tâm', 'khiet-tam-3', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 88. Nha tho Lạc Quang (source #88)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Lạc Quang', 'lac-quang', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 89. Nha tho Lam Sơn (source #89)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Lam Sơn', 'lam-son', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 90. Nha tho Lạng Sơn (source #90)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Lạng Sơn', 'lang-son', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:45'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 91. Nha tho Lộc Hưng (source #91)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Lộc Hưng', 'loc-hung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 92. Nha tho Long Bình (source #92)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Long Bình', 'long-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 93. Nha tho Long Đại (source #93)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Long Đại', 'long-dai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:45'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 94. Nha tho Long Thạnh Mỹ (source #94)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Long Thạnh Mỹ', 'long-thanh-my', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 95. Nha tho Mạc ty Nho (source #95)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mạc ty Nho', 'mac-ty-nho', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 96. Nha tho Mai Khôi (source #96)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mai Khôi', 'mai-khoi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 97. Nha tho Mai Khôi (source #97)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mai Khôi', 'mai-khoi-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('SUNDAY', 7, '10:30'::time, NULL, NULL),
  ('SUNDAY', 7, '14:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 98. Nha tho Mân Côi (source #98)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mân Côi', 'man-coi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:45'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 99. Nha tho Mẫu Tâm (source #99)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mẫu Tâm', 'mau-tam', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 100. Nha tho Mẫu Tâm (source #100)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mẫu Tâm', 'mau-tam-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:15'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 101. Nha tho Minh Đức (source #101)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Minh Đức', 'minh-duc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 102. Nha tho Môi Khôi (source #102)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Môi Khôi', 'moi-khoi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:20'::time, NULL, NULL),
  ('SUNDAY', 7, '18:20'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 103. Nha tho Mông Triệu (source #103)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mông Triệu', 'mong-trieu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:15'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 104. Nha tho Mông Triệu (source #104)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mông Triệu', 'mong-trieu-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 105. Nha tho Mông Triệu (source #105)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mông Triệu', 'mong-trieu-3', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 106. Nha tho Mỹ Hòa (source #106)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mỹ Hòa', 'my-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 107. Nha tho Mỹ Hòa (source #107)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Mỹ Hòa', 'my-hoa-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 108. Nha tho Nam Hải (source #108)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nam Hải', 'nam-hai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 109. Nha tho Nam Hoà (source #109)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nam Hoà', 'nam-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 110. Nha tho Nam Hưng (source #110)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nam Hưng', 'nam-hung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:45'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 111. Nha tho Nam Thái (source #111)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nam Thái', 'nam-thai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 112. Nha tho Nghĩa Hoà (source #112)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nghĩa Hoà', 'nghia-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 113. Nha tho Nhân Hòa (source #113)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nhân Hòa', 'nhan-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 114. Nha tho Ninh Phát (source #114)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Ninh Phát', 'ninh-phat', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:15'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 115. Nha tho Nữ Vương Hòa Bình (source #115)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Nữ Vương Hòa Bình', 'nu-vuong-hoa-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:15'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 116. Nha tho Phanxicô Đakao (source #116)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phanxicô Đakao', 'phanxico-dakao', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 117. Nha tho Phát Diệm (source #117)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phát Diệm', 'phat-diem', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 118. Nha tho Phú Bình (source #118)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Bình', 'phu-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 119. Nha tho Phú Hải (source #119)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Hải', 'phu-hai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:15'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 120. Nha tho Phú Hạnh (source #120)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Hạnh', 'phu-hanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 121. Nha tho Phú Hiền (source #121)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Hiền', 'phu-hien', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 122. Nha tho Phú Hoà (source #122)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Hoà', 'phu-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 123. Nha tho Phú Hòa (source #123)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Hòa', 'phu-hoa-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 124. Nha tho Phú Hữu (source #124)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Hữu', 'phu-huu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 125. Nha tho Phú Lộc (source #125)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Lộc', 'phu-loc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 126. Nha tho Phú Nhuận (source #126)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Nhuận', 'phu-nhuan', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 127. Nha tho Phú Quý (source #127)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Quý', 'phu-quy', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 128. Nha tho Phú Thọ Hòa (source #128)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Thọ Hòa', 'phu-tho-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 129. Nha tho Phú Trung (source #129)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Trung', 'phu-trung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 130. Nha tho Phú Xuân (source #130)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Phú Xuân', 'phu-xuan', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 131. Nha tho Sao Mai (source #131)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Sao Mai', 'sao-mai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 132. Nha tho Tắc Rỗi (source #132)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tắc Rỗi', 'tac-roi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 133. Nha tho Tam Hà (source #133)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tam Hà', 'tam-ha', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 134. Nha tho Tam Hải (source #134)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tam Hải', 'tam-hai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 135. Nha tho Tân Châu (source #135)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Châu', 'tan-chau', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 136. Nha tho Tân Chí Linh (source #136)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Chí Linh', 'tan-chi-linh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 137. Nha tho Tân Dân (source #137)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Dân', 'tan-dan', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 138. Nha tho Tân Định (source #138)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Định', 'tan-dinh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '06:15'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 139. Nha tho Tân Đông (source #139)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Đông', 'tan-dong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:15'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 140. Nha tho Tân Đức (source #140)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Đức', 'tan-duc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 141. Nha tho Tân Hiệp (source #141)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Hiệp', 'tan-hiep', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 142. Nha tho Tân Hòa (source #142)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Hòa', 'tan-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 143. Nha tho Tân Hưng (source #143)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Hưng', 'tan-hung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:45'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('SUNDAY', 7, '10:00'::time, NULL, NULL),
  ('SUNDAY', 7, '14:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 144. Nha tho Tân Hưng (source #144)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Hưng', 'tan-hung-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 145. Nha tho Tân Hương (source #145)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Hương', 'tan-huong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 146. Nha tho Tân Lập (source #146)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Lập', 'tan-lap', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '14:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 147. Nha tho Tân Mỹ (source #147)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Mỹ', 'tan-my', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 148. Nha tho Tân Phú (source #148)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Phú', 'tan-phu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '16:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 149. Nha tho Tân Phú Hòa (source #149)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Phú Hòa', 'tan-phu-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 150. Nha tho Tân Phước (source #150)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Phước', 'tan-phuoc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 151. Nha tho Tân Quy (source #151)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Quy', 'tan-quy', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 152. Nha tho Tân Sa Châu (source #152)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Sa Châu', 'tan-sa-chau', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '10:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 153. Nha tho Tân Thái Sơn (source #153)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Thái Sơn', 'tan-thai-son', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 154. Nha tho Tân Thành (source #154)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Thành', 'tan-thanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 155. Nha tho Tân Thịnh (source #155)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Thịnh', 'tan-thinh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 156. Nha tho Tân Trang (source #156)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Trang', 'tan-trang', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 157. Nha tho Tân Việt (source #157)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tân Việt', 'tan-viet', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 158. Nha tho Thạch Đà (source #158)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thạch Đà', 'thach-da', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '06:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:15'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:15'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:15'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:15'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:15'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '06:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:15'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 159. Nha tho Thái Bình (source #159)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thái Bình', 'thai-binh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 160. Nha tho Thái Hoà (source #160)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thái Hoà', 'thai-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 161. Nha tho Thăng Long (source #161)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thăng Long', 'thang-long', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 162. Nha tho Thánh Cẩm (source #162)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Cẩm', 'thanh-cam', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 163. Nha tho Thanh Đa (source #163)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thanh Đa', 'thanh-da', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 164. Nha tho Thánh Gẫm (source #164)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Gẫm', 'thanh-gam', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 165. Nha tho Thánh Gia (source #165)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Gia', 'thanh-gia-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 166. Nha tho Thánh Gioan Phaolô II (source #166)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Gioan Phaolô II', 'thanh-gioan-phaolo-ii', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 167. Nha tho Thánh Giuse (source #167)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Giuse', 'thanh-giuse', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 168. Nha tho Thánh Giuse (source #168)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Giuse', 'thanh-giuse-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 169. Nha tho Thánh Giuse (source #169)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Giuse', 'thanh-giuse-3', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 170. Nha tho Thánh Giuse (source #170)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Giuse', 'thanh-giuse-4', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 171. Nha tho Thánh Giuse Thợ (source #171)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Giuse Thợ', 'thanh-giuse-tho', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '06:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 172. Nha tho Thánh Linh (source #172)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Linh', 'thanh-linh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 173. Nha tho Thánh Martinô (source #173)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Martinô', 'thanh-martino', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 174. Nha tho Thánh Martinô (source #174)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Martinô', 'thanh-martino-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 175. Nha tho Thánh Mẫu (source #175)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Mẫu', 'thanh-mau', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 176. Nha tho Thánh Nguyễn Duy Khang (source #176)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Nguyễn Duy Khang', 'thanh-nguyen-duy-khang', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:40'::time, NULL, NULL),
  ('WEEKDAY', NULL, '16:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 177. Nha tho Thánh Nguyễn Duy Khang (source #177)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Nguyễn Duy Khang', 'thanh-nguyen-duy-khang-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:45'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:45'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 178. Nha tho Thánh Phanxicô Xaviê (source #178)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Phanxicô Xaviê', 'thanh-phanxico-xavie', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:15'::time, NULL, NULL),
  ('SUNDAY', 7, '08:45'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 179. Nha tho Thánh Phaolô (source #179)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Phaolô', 'thanh-phaolo', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 180. Nha tho Thánh Phaolô (source #180)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Phaolô', 'thanh-phaolo-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 181. Nha tho Thánh Phaolô (source #181)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Phaolô', 'thanh-phaolo-3', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '08:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 182. Nha tho Thánh Phaolô 3 (source #182)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Phaolô 3', 'thanh-phaolo-3-2', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 183. Nha tho Thánh Tâm (source #183)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Tâm', 'thanh-tam', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 184. Nha tho Thánh Tịnh (source #184)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thánh Tịnh', 'thanh-tinh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 185. Nha tho Thị Nghè (source #185)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thị Nghè', 'thi-nghe', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '15:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 186. Nha tho Thiên Ân (source #186)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thiên Ân', 'thien-an', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:15'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 187. Nha tho Thiên Thần (source #187)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thiên Thần', 'thien-than', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:15'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:15'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:30'::time, 'tiếng Anh', NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 188. Nha tho Thủ Đức (source #188)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thủ Đức', 'thu-duc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:15'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 189. Nha tho Thủ Thiêm (source #189)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thủ Thiêm', 'thu-thiem', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 190. Nha tho Thuận Phát (source #190)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Thuận Phát', 'thuan-phat', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:45'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 191. Nha tho Tống Viết Bường (source #191)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tống Viết Bường', 'tong-viet-buong', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 192. Nha tho Trung Bắc (source #192)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Trung Bắc', 'trung-bac', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 193. Nha tho Trung Chánh (source #193)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Trung Chánh', 'trung-chanh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 194. Nha tho Trung Mỹ Tây (source #194)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Trung Mỹ Tây', 'trung-my-tay', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 195. Nha tho Tử Đình (source #195)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Tử Đình', 'tu-dinh', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 196. Nha tho Từ Đức (source #196)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Từ Đức', 'tu-duc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 197. Nha tho Văn Côi (source #197)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Văn Côi', 'van-coi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 198. Nha tho Vĩnh Hiệp (source #198)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vĩnh Hiệp', 'vinh-hiep', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 199. Nha tho Vĩnh Hoà (source #199)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vĩnh Hoà', 'vinh-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '19:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 200. Nha tho Vĩnh Hội (source #200)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vĩnh Hội', 'vinh-hoi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:15'::time, NULL, NULL),
  ('SUNDAY', 7, '15:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 201. Nha tho Vinh Sơn - Nghĩa Hoà (source #201)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vinh Sơn - Nghĩa Hoà', 'vinh-son-nghia-hoa', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 202. Nha tho Vinh Sơn - Ông Tạ (source #202)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vinh Sơn - Ông Tạ', 'vinh-son-ong-ta', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 203. Nha tho Vinh Sơn Phaolô (source #203)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vinh Sơn Phaolô', 'vinh-son-phaolo', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:15'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 204. Nha tho Vườn Chuối (source #204)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vườn Chuối', 'vuon-chuoi', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '15:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 205. Nha tho Vườn Xoài (source #205)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Vườn Xoài', 'vuon-xoai', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:00'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 206. Nha tho Xây Dựng (source #206)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Xây Dựng', 'xay-dung', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:30'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '04:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 207. Nha tho Xóm Chiếu (source #207)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Xóm Chiếu', 'xom-chieu', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '04:45'::time, NULL, NULL),
  ('SUNDAY', 7, '06:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:30'::time, NULL, NULL),
  ('SUNDAY', 7, '19:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 1, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 2, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 2, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 3, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 3, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 4, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 4, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 5, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:30'::time, NULL, NULL),
  ('WEEKDAY', 6, '04:45'::time, NULL, NULL),
  ('WEEKDAY', 6, '16:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 208. Nha tho Xóm Lách (source #208)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Xóm Lách', 'xom-lach', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '07:00'::time, NULL, NULL),
  ('SUNDAY', 7, '09:00'::time, NULL, NULL),
  ('SUNDAY', 7, '17:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '17:30'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 209. Nha tho Xóm Thuốc (source #209)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Xóm Thuốc', 'xom-thuoc', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '07:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:30'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 1, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 2, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 2, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 3, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 3, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 4, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 4, '18:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 5, '17:45'::time, NULL, NULL),
  ('WEEKDAY', 6, '05:00'::time, NULL, NULL),
  ('WEEKDAY', 6, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);

-- 210. Nha tho Xuân Hiệp (source #210)
WITH p AS (
  INSERT INTO parishes (name, slug, is_active)
  VALUES ('Xuân Hiệp', 'xuan-hiep', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
SELECT p.id, v.day_type, v.dow, v.mass_time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7, '05:00'::time, NULL, NULL),
  ('SUNDAY', 7, '06:30'::time, NULL, NULL),
  ('SUNDAY', 7, '08:30'::time, NULL, NULL),
  ('SUNDAY', 7, '16:00'::time, NULL, NULL),
  ('SUNDAY', 7, '18:00'::time, NULL, NULL),
  ('SUNDAY', 7, '19:30'::time, NULL, NULL),
  ('WEEKDAY', NULL, '05:00'::time, NULL, NULL),
  ('WEEKDAY', NULL, '18:00'::time, NULL, NULL)
) AS v(day_type, dow, mass_time, label, note);
