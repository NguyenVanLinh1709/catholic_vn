"use client";

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
    <nav className="mt-6 flex items-center justify-center gap-1" aria-label={t("pagination.label")}>
      <PageButton disabled={page <= 0} onClick={() => onChange(page - 1)} aria-label={t("pagination.prev")}>
        <ChevronLeft className="h-4 w-4" />
      </PageButton>

      {pages.map((p, i) =>
        p === -1 ? (
          <span key={`gap-${i}`} className="px-2 text-gray-400 dark:text-gray-500">
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
    </nav>
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
        "inline-flex h-9 min-w-9 items-center justify-center rounded-md border px-2 text-sm transition disabled:cursor-not-allowed disabled:opacity-40",
        active
          ? "border-brand-600 bg-brand-600 text-white"
          : "border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:hover:bg-gray-800",
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
