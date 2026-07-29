"use client";

import { useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Search } from "lucide-react";
import type { DayType } from "@/lib/types";
import type { MassTimeRange } from "@/lib/format";
import { dayOfWeekLabel, dayTypeLabel } from "@/lib/i18n/labels";
import { useI18n } from "@/lib/i18n/provider";
import { Input, Select } from "./Field";
import { Button } from "./Button";
import { Pagination } from "./Pagination";

/** Search box that drives the `search` query param (resets to page 0). */
export function SearchBar({ placeholder }: { placeholder?: string }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();
  const [value, setValue] = useState(params.get("search") ?? "");

  function submit() {
    const next = new URLSearchParams(params.toString());
    if (value.trim()) next.set("search", value.trim());
    else next.delete("search");
    next.delete("page");
    router.push(`${pathname}?${next.toString()}`);
  }

  return (
    <div className="flex gap-2">
      <div className="relative flex-1">
        <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400 dark:text-gray-500" />
        <Input
          value={value}
          onChange={(e) => setValue(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") submit();
          }}
          placeholder={placeholder ?? t("search.placeholderParish")}
          className="pl-9"
          aria-label={t("search.aria")}
        />
      </div>
      <Button onClick={submit}>{t("common.search")}</Button>
    </div>
  );
}

const DAY_TYPES: DayType[] = ["SUNDAY", "WEEKDAY", "SPECIAL"];
const TIME_RANGES: MassTimeRange[] = ["MORNING", "AFTERNOON", "EVENING"];
const TIME_RANGE_KEY = {
  MORNING: "filter.timeMorning",
  AFTERNOON: "filter.timeAfternoon",
  EVENING: "filter.timeEvening",
} as const;
const DAYS_OF_WEEK = [1, 2, 3, 4, 5, 6, 7];

/**
 * Filters the parish directory by mass day type / day of week / time of day,
 * via the `dayType`, `dayOfWeek` and `time` query params (reset `page` on
 * change, like SearchBar).
 */
export function MassFilter() {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();

  const dayType = params.get("dayType") ?? "";
  const dayOfWeek = params.get("dayOfWeek") ?? "";
  const time = params.get("time") ?? "";

  function update(key: "dayType" | "dayOfWeek" | "time", value: string) {
    const next = new URLSearchParams(params.toString());
    if (value) next.set(key, value);
    else next.delete(key);
    next.delete("page");
    router.push(`${pathname}?${next.toString()}`);
  }

  return (
    <div className="flex flex-wrap gap-2">
      <Select
        value={dayType}
        onChange={(e) => update("dayType", e.target.value)}
        aria-label={t("filter.dayTypeAria")}
        className="w-auto"
      >
        <option value="">{t("filter.dayTypeAll")}</option>
        {DAY_TYPES.map((d) => (
          <option key={d} value={d}>
            {dayTypeLabel(t, d)}
          </option>
        ))}
      </Select>
      <Select
        value={dayOfWeek}
        onChange={(e) => update("dayOfWeek", e.target.value)}
        aria-label={t("filter.dayOfWeekAria")}
        className="w-auto"
      >
        <option value="">{t("filter.dayOfWeekAll")}</option>
        {DAYS_OF_WEEK.map((d) => (
          <option key={d} value={d}>
            {dayOfWeekLabel(t, d)}
          </option>
        ))}
      </Select>
      <Select
        value={time}
        onChange={(e) => update("time", e.target.value)}
        aria-label={t("filter.timeAria")}
        className="w-auto"
      >
        <option value="">{t("filter.timeAll")}</option>
        {TIME_RANGES.map((r) => (
          <option key={r} value={r}>
            {t(TIME_RANGE_KEY[r])}
          </option>
        ))}
      </Select>
    </div>
  );
}

/** Pagination that drives the `page` query param. `page` is 0-based. */
export function QueryPagination({ page, totalPages }: { page: number; totalPages: number }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();

  function go(next: number) {
    const sp = new URLSearchParams(params.toString());
    sp.set("page", String(next));
    router.push(`${pathname}?${sp.toString()}`);
  }

  return <Pagination page={page} totalPages={totalPages} onChange={go} />;
}
