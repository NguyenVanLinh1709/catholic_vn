"use client";

import { useEffect, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/lib/i18n/provider";

/**
 * Shared pagination. `page` is 0-based (matches the backend). `onChange`
 * receives the new 0-based page. Render nothing when there's a single page.
 */
export function Pagination({
  page,
  totalPages,
  onChange,
}: {
  page: number;
  totalPages: number;
  onChange: (page: number) => void;
}) {
  const { t } = useI18n();

  if (totalPages <= 1) return null;

  const pages = pageWindow(page, totalPages);

  return (
    <nav
      className="mt-6 inline-flex flex-wrap items-center gap-1 rounded-xl border border-gray-200 bg-white p-1.5 shadow-sm dark:border-gray-800 dark:bg-gray-900"
      aria-label={t("pagination.label")}
    >
      <PageButton disabled={page <= 0} onClick={() => onChange(page - 1)} aria-label={t("pagination.prev")}>
        <ChevronLeft className="h-4 w-4" />
      </PageButton>

      {pages.map((p, i) =>
        p === -1 ? (
          <span
            key={`gap-${i}`}
            className="flex h-9 min-w-9 items-center justify-center text-gray-400 dark:text-gray-500"
          >
            …
          </span>
        ) : (
          <PageButton key={p} active={p === page} onClick={() => onChange(p)}>
            {p + 1}
          </PageButton>
        ),
      )}

      <PageButton
        disabled={page >= totalPages - 1}
        onClick={() => onChange(page + 1)}
        aria-label={t("pagination.next")}
      >
        <ChevronRight className="h-4 w-4" />
      </PageButton>

      <span className="mx-1 h-5 w-px shrink-0 bg-gray-200 dark:bg-gray-700" />

      <GoToPage page={page} totalPages={totalPages} onChange={onChange} />
    </nav>
  );
}

function GoToPage({
  page,
  totalPages,
  onChange,
}: {
  page: number;
  totalPages: number;
  onChange: (page: number) => void;
}) {
  const { t } = useI18n();
  const [value, setValue] = useState(String(page + 1));

  useEffect(() => {
    setValue(String(page + 1));
  }, [page]);

  function submit() {
    const n = Math.trunc(Number(value));
    if (!Number.isFinite(n) || value.trim() === "") {
      setValue(String(page + 1));
      return;
    }
    const clamped = Math.min(Math.max(n, 1), totalPages);
    setValue(String(clamped));
    if (clamped - 1 !== page) onChange(clamped - 1);
  }

  return (
    <form
      className="flex shrink-0 items-center gap-1.5 pl-0.5 text-sm text-gray-500 dark:text-gray-400"
      onSubmit={(e) => {
        e.preventDefault();
        submit();
      }}
    >
      <label htmlFor="pagination-goto">{t("pagination.goToLabel")}</label>
      <input
        id="pagination-goto"
        type="number"
        min={1}
        max={totalPages}
        inputMode="numeric"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onBlur={submit}
        aria-label={t("pagination.goToAria")}
        className="h-9 w-14 rounded-lg border border-gray-200 bg-white text-center text-sm text-gray-900 focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500 dark:border-gray-700 dark:bg-gray-950 dark:text-gray-100 [appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
      />
      <span>/ {totalPages}</span>
    </form>
  );
}

function PageButton({
  active,
  className,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { active?: boolean }) {
  return (
    <button
      type="button"
      className={cn(
        "inline-flex h-9 min-w-9 items-center justify-center rounded-lg px-2 text-sm font-medium transition-colors disabled:cursor-not-allowed disabled:opacity-40",
        active
          ? "bg-brand-600 text-white shadow-sm"
          : "text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800",
        className,
      )}
      {...props}
    />
  );
}

function pageWindow(current: number, total: number): number[] {
  const result: number[] = [];
  const push = (n: number) => result.push(n);
  const first = 0;
  const last = total - 1;

  push(first);
  const start = Math.max(first + 1, current - 1);
  const end = Math.min(last - 1, current + 1);

  if (start > first + 1) push(-1);
  for (let p = start; p <= end; p++) push(p);
  if (end < last - 1) push(-1);
  if (last > first) push(last);

  return result;
}
