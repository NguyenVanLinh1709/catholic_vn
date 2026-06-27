import type { DayType, PriestRole } from "@/lib/types";
import type { Locale } from "./config";
import type { MessageKey, TranslateFn } from "./messages";
import { formatDate } from "@/lib/format";

const DAY_TYPE_KEY: Record<DayType, MessageKey> = {
  WEEKDAY: "day.weekday",
  SUNDAY: "day.sunday",
  SPECIAL: "day.special",
};

const DOW_KEY: Record<number, MessageKey> = {
  1: "dow.1",
  2: "dow.2",
  3: "dow.3",
  4: "dow.4",
  5: "dow.5",
  6: "dow.6",
  7: "dow.7",
};

const PRIEST_ROLE_KEY: Record<PriestRole, MessageKey> = {
  PASTOR: "role.pastor",
  PAROCHIAL_VICAR: "role.vicar",
};

export function dayTypeLabel(t: TranslateFn, dayType: DayType): string {
  return t(DAY_TYPE_KEY[dayType]);
}

export function priestRoleLabel(t: TranslateFn, role: PriestRole): string {
  return t(PRIEST_ROLE_KEY[role]);
}

export function dayOfWeekLabel(t: TranslateFn, day: number | null): string {
  if (day === null) return t("dow.any");
  const key = DOW_KEY[day];
  return key ? t(key) : String(day);
}

/** Facebook-style relative time, localized: "Just now", "3 h ago", … */
export function relativeTime(t: TranslateFn, locale: Locale, iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  const seconds = Math.floor((Date.now() - d.getTime()) / 1000);
  if (seconds < 60) return t("time.justNow");
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return t("time.minutesAgo", { n: minutes });
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return t("time.hoursAgo", { n: hours });
  const days = Math.floor(hours / 24);
  if (days < 7) return t("time.daysAgo", { n: days });
  // Beyond a week, show the absolute date.
  return formatDate(iso, locale);
}
