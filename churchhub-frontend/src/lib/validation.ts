/**
 * Phone-number rule shared by the parish and priest forms: a Vietnamese-style
 * number of exactly 10 digits starting with 0. The field itself is optional, so
 * an empty / whitespace-only value is considered valid (callers normalise it to
 * null before sending). Mirrors the backend `@Pattern(^(0\d{9})?$)`.
 */
export function isValidPhone(value: string | null | undefined): boolean {
  if (value == null) return true;
  const trimmed = value.trim();
  if (trimmed === "") return true;
  return /^0\d{9}$/.test(trimmed);
}
