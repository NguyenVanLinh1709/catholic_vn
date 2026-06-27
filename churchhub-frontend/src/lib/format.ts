import type { DayType, MassSchedule } from "./types";
import type { Locale } from "./i18n/config";

export const DAY_TYPE_ORDER: DayType[] = ["WEEKDAY", "SUNDAY", "SPECIAL"];

/** "07:30:00" or "07:30" -> "07:30" (locale-neutral). */
export function formatTime(value: string): string {
  if (!value) return "";
  const [h, m] = value.split(":");
  return `${h ?? "00"}:${m ?? "00"}`;
}

const DATE_LOCALE: Record<Locale, string> = { vi: "vi-VN", en: "en-GB" };

export function formatDate(iso: string | null | undefined, locale: Locale = "vi"): string {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return d.toLocaleDateString(DATE_LOCALE[locale], {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
}

/** Groups schedules by dayType, in display order, each sorted by time. */
export function groupMassSchedules(
  schedules: MassSchedule[],
): { dayType: DayType; items: MassSchedule[] }[] {
  return DAY_TYPE_ORDER.map((dayType) => ({
    dayType,
    items: schedules
      .filter((s) => s.dayType === dayType)
      .sort((a, b) => {
        const dow = (a.dayOfWeek ?? 0) - (b.dayOfWeek ?? 0);
        return dow !== 0 ? dow : a.massTime.localeCompare(b.massTime);
      }),
  })).filter((group) => group.items.length > 0);
}
