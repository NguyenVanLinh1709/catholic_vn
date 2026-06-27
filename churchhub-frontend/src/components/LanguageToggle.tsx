"use client";

import { useRouter } from "next/navigation";
import { Languages } from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/lib/i18n/provider";
import { LOCALE_LABEL, LOCALE_SHORT, type Locale } from "@/lib/i18n/config";

/**
 * Switches between Vietnamese and English. Updates the client context (re-renders
 * client components) and refreshes the route so Server Components re-render with
 * the new cookie value too.
 */
export function LanguageToggle({ className }: { className?: string }) {
  const router = useRouter();
  const { locale, setLocale, t } = useI18n();

  const next: Locale = locale === "vi" ? "en" : "vi";

  function switchLanguage() {
    setLocale(next);
    router.refresh();
  }

  return (
    <button
      type="button"
      onClick={switchLanguage}
      aria-label={t("lang.switch")}
      title={LOCALE_LABEL[next]}
      className={cn(
        "inline-flex h-9 items-center justify-center gap-1.5 rounded-lg border border-gray-300 px-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800",
        className,
      )}
    >
      <Languages className="h-4 w-4" />
      {LOCALE_SHORT[locale]}
    </button>
  );
}
