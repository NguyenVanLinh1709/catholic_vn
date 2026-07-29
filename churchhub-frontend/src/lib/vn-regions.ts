/**
 * The 34 provincial-level units of Vietnam after the July 2025 administrative
 * merger (63 -> 34; district tier abolished, now just Tỉnh/Thành phố ->
 * Phường/Xã). Used as the fixed set of options for the parish "province"
 * field/filter; "ward" (Phường/Xã) stays free text since there's no
 * canonical dataset wired in here.
 */
export const VN_PROVINCES: string[] = [
  "An Giang",
  "Bắc Ninh",
  "Cà Mau",
  "Cao Bằng",
  "Cần Thơ",
  "Gia Lai",
  "Hà Nội",
  "Hà Tĩnh",
  "Hải Phòng",
  "Hưng Yên",
  "Huế",
  "Khánh Hòa",
  "Lai Châu",
  "Lạng Sơn",
  "Lào Cai",
  "Lâm Đồng",
  "Nghệ An",
  "Ninh Bình",
  "Phú Thọ",
  "Quảng Ngãi",
  "Quảng Ninh",
  "Quảng Trị",
  "Sơn La",
  "Tuyên Quang",
  "Thanh Hóa",
  "Thái Nguyên",
  "TP. Hồ Chí Minh",
  "Tây Ninh",
  "Vĩnh Long",
  "Đắk Lắk",
  "Đà Nẵng",
  "Điện Biên",
  "Đồng Nai",
  "Đồng Tháp",
].sort((a, b) => a.localeCompare(b, "vi"));
