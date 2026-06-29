-- Seed: các nhà thờ thuộc Giáo phận Nha Trang (TP. Nha Trang) cùng giờ lễ
-- Chúa nhật (SUNDAY, day_of_week = 7), ngày thường (WEEKDAY, day_of_week = NULL = mọi ngày)
-- và một số mục đặc biệt (SPECIAL). Số điện thoại chuẩn hoá về dạng 0xxxxxxxxx (10 chữ số).

-- 1. Nhà nguyện Toà Giám Mục
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, description, is_active)
  VALUES ('Toà Giám Mục', 'toa-giam-muc', '22 Trần Phú, Tp. Nha Trang', '0583523842',
          'Nhà nguyện Toà Giám Mục Nha Trang.', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Sáng', NULL::text),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL)
) AS v(day_type, dow, t, label, note);

-- 2. Nhà thờ Chính Toà
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Chính Toà', 'chinh-toa', '31 A Thái Nguyên, Tp. Nha Trang', '0583823335', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '07:00', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '09:30', 'Thánh lễ III', NULL),
  ('SUNDAY', 7,    '15:00', 'Chầu Phép Lành', NULL),
  ('SUNDAY', 7,    '16:30', 'Thánh lễ IV', NULL),
  ('SUNDAY', 7,    '18:30', 'Thánh lễ V', NULL),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL),
  ('WEEKDAY', NULL, '17:00', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 3. Nhà thờ Bắc Thành
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Bắc Thành', 'bac-thanh', '38 Lê Thánh Tôn, Tp. Nha Trang', '0583510551', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '07:00', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '16:00', 'Thánh lễ III', NULL),
  ('WEEKDAY', NULL, '05:00', 'Sáng', NULL),
  ('WEEKDAY', NULL, '17:00', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 4. Nhà thờ Phước Hoà
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Phước Hoà', 'phuoc-hoa', '80 Lê Hồng Phong, Tp. Nha Trang', '0583877071', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '07:00', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '15:30', 'Thánh lễ III', NULL),
  ('SUNDAY', 7,    '19:00', 'Thánh lễ IV', NULL),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL),
  ('WEEKDAY', NULL, '17:45', 'Chiều', NULL),
  ('SPECIAL', 4,   '19:30', 'Chầu phép lành', 'Thứ Năm hằng tuần')
) AS v(day_type, dow, t, label, note);

-- 5. Nhà thờ Phước Hải
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Phước Hải', 'phuoc-hai', '30 Trương Định, Tp. Nha Trang', '0583514617', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '07:30', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '15:30', 'Chầu Phép Lành', NULL),
  ('SUNDAY', 7,    '17:00', 'Thánh lễ III', NULL),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL),
  ('WEEKDAY', NULL, '17:30', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 6. Nhà thờ Khiết Tâm
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Khiết Tâm', 'khiet-tam', '17/41 Hoàng Diệu, Tp. Nha Trang', '0583881834', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '07:30', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '17:00', 'Thánh lễ III', NULL),
  ('WEEKDAY', NULL, '17:30', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 7. Nhà thờ Thánh Gia
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Thánh Gia', 'thanh-gia', '10 Võ Thị Sáu, Tp. Nha Trang', '0583883809', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '17:30', 'Lễ chiều Thứ Bảy', NULL::text),
  ('SUNDAY', 7,    '05:30', 'Thánh lễ I', NULL),
  ('SUNDAY', 7,    '07:40', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '14:30', 'Chầu Phép Lành', NULL),
  ('WEEKDAY', NULL, '04:40', 'Sáng', NULL),
  ('WEEKDAY', NULL, '17:30', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 8. Nhà thờ Hoà Thuận (Fatima)
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, description, is_active)
  VALUES ('Hoà Thuận', 'hoa-thuan', '149 Nguyễn Bỉnh Khiêm, Tp. Nha Trang', '0583813661',
          'Còn gọi là nhà thờ Fatima.', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '16:30', 'Thánh lễ II', NULL),
  ('WEEKDAY', NULL, '17:30', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 9. Nhà thờ Thanh Hải
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Thanh Hải', 'thanh-hai', '33-35 Bắc Sơn, Vĩnh Hải, Tp. Nha Trang', '0583834607', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '08:00', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '17:00', 'Thánh lễ III', NULL),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL),
  ('WEEKDAY', NULL, '18:15', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 10. Nhà thờ Vĩnh Phước
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Vĩnh Phước', 'vinh-phuoc', '120 Đường 2/4, Vĩnh Phước, TP. Nha Trang', '0583836970', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '08:15', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '16:00', 'Thánh lễ III', NULL),
  ('WEEKDAY', NULL, '04:30', 'Sáng', NULL),
  ('WEEKDAY', NULL, '17:00', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 11. Nhà thờ Giuse
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, is_active)
  VALUES ('Giuse', 'giuse', '53 Đường Hùng Vương, TP. Nha Trang', '0583825803', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Thánh lễ I', NULL::text),
  ('SUNDAY', 7,    '08:15', 'Thánh lễ II', NULL),
  ('SUNDAY', 7,    '15:00', 'Thánh lễ III', NULL),
  ('SUNDAY', 7,    '18:30', 'Thánh lễ IV', NULL),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL),
  ('WEEKDAY', NULL, '18:15', 'Chiều', NULL)
) AS v(day_type, dow, t, label, note);

-- 12. Nhà thờ Ba Làng
WITH p AS (
  INSERT INTO parishes (name, slug, address, phone, description, is_active)
  VALUES ('Ba Làng', 'ba-lang', 'Vĩnh Hòa, TP. Nha Trang', '0583551944',
          'Ghi chú: Thứ Năm 18g15. Thứ Bảy chầu Thánh Thể. '
          || 'Thứ Năm đầu tháng: Sáng 4g45, chầu Thánh Thể 18g15. '
          || 'Thứ Sáu đầu tháng: Sáng 4g45, chiều 18g15.', true)
  RETURNING id
)
INSERT INTO mass_schedules (parish_id, day_type, day_of_week, mass_time, label, note)
-- Lưu giờ đã trừ 8h: Hibernate (jdbc.time_zone=UTC) cộng lại 8h khi đọc cột TIME
-- vì offset của Asia/Ho_Chi_Minh tại mốc epoch 1970-01-01 là +08. Nhờ vậy giờ "thật"
-- trong VALUES bên dưới hiển thị đúng qua API, khớp với cách app ghi dữ liệu.
SELECT p.id, v.day_type, v.dow::smallint, (v.t::time - INTERVAL '8 hours')::time, v.label, v.note
FROM p CROSS JOIN (VALUES
  ('SUNDAY', 7,    '05:00', 'Sáng', NULL::text),
  ('SUNDAY', 7,    '16:45', 'Chiều', NULL),
  ('WEEKDAY', NULL, '04:45', 'Sáng', NULL),
  ('WEEKDAY', NULL, '18:15', 'Giờ kinh', NULL),
  ('SPECIAL', 4,   '18:15', 'Chầu Thánh Thể', 'Thứ Năm')
) AS v(day_type, dow, t, label, note);
