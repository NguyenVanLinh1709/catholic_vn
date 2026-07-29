"use client";

import { useEffect, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Search, X } from "lucide-react";
import { PAGE_SIZES } from "@/lib/format";
import { useI18n } from "@/lib/i18n/provider";
import { VN_PROVINCES } from "@/lib/vn-regions";
import { Input, Select } from "./Field";
import { Button } from "./Button";
import { Pagination } from "./Pagination";

/** Search box that drives the `search` query param (resets to page 0). */
export function SearchBar({ placeholder }: { placeholder?: string }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();
  const searchParam = params.get("search") ?? "";
  const [value, setValue] = useState(searchParam);

  // Keep in sync when the URL changes from elsewhere (clear-all, back/forward),
  // without clobbering in-progress typing (this only fires when the URL itself changes).
  useEffect(() => setValue(searchParam), [searchParam]);

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

/**
 * Filters the parish directory by mass time-of-day range, via the `timeFrom`/`timeTo` query
 * params (HH:mm, both independently optional, reset `page` on change like SearchBar). Only
 * parishes with at least one mass falling inside the entered range are returned.
 */
export function MassFilter() {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();

  const timeFrom = params.get("timeFrom") ?? "";
  const timeTo = params.get("timeTo") ?? "";

  function update(next: { timeFrom?: string; timeTo?: string }) {
    const sp = new URLSearchParams(params.toString());
    const nextFrom = next.timeFrom ?? timeFrom;
    const nextTo = next.timeTo ?? timeTo;
    if (nextFrom) sp.set("timeFrom", nextFrom);
    else sp.delete("timeFrom");
    if (nextTo) sp.set("timeTo", nextTo);
    else sp.delete("timeTo");
    sp.delete("page");
    router.push(`${pathname}?${sp.toString()}`);
  }

  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="text-sm text-gray-500 dark:text-gray-400">{t("filter.timeRangeLabel")}</span>
      <Input
        type="time"
        value={timeFrom}
        onChange={(e) => update({ timeFrom: e.target.value })}
        aria-label={t("filter.timeFromAria")}
        className="w-[7.5rem]"
      />
      <span className="text-gray-400 dark:text-gray-500">–</span>
      <Input
        type="time"
        value={timeTo}
        onChange={(e) => update({ timeTo: e.target.value })}
        aria-label={t("filter.timeToAria")}
        className="w-[7.5rem]"
      />
    </div>
  );
}

/**
 * Filters the parish directory by region via the `province` (exact match,
 * immediate push like MassFilter) and `ward` (substring, submit-on-Enter/blur
 * like SearchBar) query params (reset `page` on change).
 */
export function RegionFilter() {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();

  const province = params.get("province") ?? "";
  const wardParam = params.get("ward") ?? "";
  const [ward, setWard] = useState(wardParam);

  // Keep in sync when the URL changes from elsewhere (clear-all, back/forward),
  // without clobbering in-progress typing (this only fires when the URL itself changes).
  useEffect(() => setWard(wardParam), [wardParam]);

  function push(next: URLSearchParams) {
    next.delete("page");
    router.push(`${pathname}?${next.toString()}`);
  }

  function updateProvince(value: string) {
    const next = new URLSearchParams(params.toString());
    if (value) next.set("province", value);
    else next.delete("province");
    push(next);
  }

  function submitWard() {
    const next = new URLSearchParams(params.toString());
    if (ward.trim()) next.set("ward", ward.trim());
    else next.delete("ward");
    push(next);
  }

  return (
    <div className="flex flex-wrap gap-2">
      <Select
        value={province}
        onChange={(e) => updateProvince(e.target.value)}
        aria-label={t("filter.provinceAria")}
        className="w-36"
      >
        <option value="">{t("filter.provinceAll")}</option>
        {VN_PROVINCES.map((p) => (
          <option key={p} value={p}>
            {p}
          </option>
        ))}
      </Select>
      <Input
        value={ward}
        onChange={(e) => setWard(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Enter") submitWard();
        }}
        onBlur={submitWard}
        placeholder={t("filter.wardPlaceholder")}
        aria-label={t("filter.wardAria")}
        className="w-36"
      />
    </div>
  );
}

const FILTER_PARAMS = ["search", "province", "ward", "timeFrom", "timeTo"] as const;

/**
 * Clears every active directory filter (search, region, mass-time) in one action, resetting
 * `page` but keeping `size`. Renders nothing when no filter is currently active.
 */
export function ClearFiltersButton() {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();

  if (!FILTER_PARAMS.some((key) => params.has(key))) return null;

  function clear() {
    const next = new URLSearchParams(params.toString());
    for (const key of FILTER_PARAMS) next.delete(key);
    next.delete("page");
    const qs = next.toString();
    router.push(qs ? `${pathname}?${qs}` : pathname);
  }

  return (
    <button
      type="button"
      onClick={clear}
      className="inline-flex items-center gap-1 text-sm text-gray-500 transition-colors hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
    >
      <X className="h-3.5 w-3.5" />
      {t("filter.clearAll")}
    </button>
  );
}

/** Picks how many parishes appear per page, via the `size` query param (resets `page` on change). */
export function PageSizeSelect({ defaultSize }: { defaultSize: number }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const { t } = useI18n();

  const size = params.get("size") ?? String(defaultSize);

  function update(value: string) {
    const next = new URLSearchParams(params.toString());
    if (Number(value) === defaultSize) next.delete("size");
    else next.set("size", value);
    next.delete("page");
    router.push(`${pathname}?${next.toString()}`);
  }

  return (
    <div className="w-28 shrink-0">
      <Select
        value={size}
        onChange={(e) => update(e.target.value)}
        aria-label={t("filter.pageSizeAria")}
        className="h-full"
      >
        {PAGE_SIZES.map((n) => (
          <option key={n} value={n}>
            {t("filter.pageSizeOption", { count: n })}
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
