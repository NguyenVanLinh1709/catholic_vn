import type { DayType, PriestRole, MassSchedule } from "./types";

export const DAY_TYPE_LABEL: Record<DayType, string> = {
  WEEKDAY: "Ngày thường",
  SUNDAY: "Chúa Nhật",
  SPECIAL: "Lễ đặc biệt",
};

export const DAY_TYPE_ORDER: DayType[] = ["WEEKDAY", "SUNDAY", "SPECIAL"];

// ISO: 1=Monday .. 7=Sunday
export const DAY_OF_WEEK_LABEL: Record<number, string> = {
  1: "Thứ Hai",
  2: "Thứ Ba",
  3: "Thứ Tư",
  4: "Thứ Năm",
  5: "Thứ Sáu",
  6: "Thứ Bảy",
  7: "Chúa Nhật",
};

export const PRIEST_ROLE_LABEL: Record<PriestRole, string> = {
  PASTOR: "Cha xứ",
  PAROCHIAL_VICAR: "Cha phó",
};

export function dayOfWeekLabel(day: number | null): string {
  if (day === null) return "Mọi ngày";
  return DAY_OF_WEEK_LABEL[day] ?? `Thứ ${day}`;
}

/** "07:30:00" or "07:30" -> "07:30" */
export function formatTime(value: string): string {
  if (!value) return "";
  const [h, m] = value.split(":");
  return `${h ?? "00"}:${m ?? "00"}`;
}

export function formatDate(iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return d.toLocaleDateString("vi-VN", { day: "2-digit", month: "2-digit", year: "numeric" });
}

/** Facebook-style relative time in Vietnamese: "Vừa xong", "3 giờ trước", "2 ngày trước". */
export function formatRelativeTime(iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  const seconds = Math.floor((Date.now() - d.getTime()) / 1000);
  if (seconds < 60) return "Vừa xong";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes} phút trước`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} giờ trước`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days} ngày trước`;
  // Beyond a week, show the absolute date.
  return formatDate(iso);
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
