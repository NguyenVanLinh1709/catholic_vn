import Link from "next/link";
import { Church } from "lucide-react";
import type { SessionUser } from "@/lib/types";
import { getTranslations } from "@/lib/i18n/server";
import { UserMenu } from "./UserMenu";
import { ThemeToggle } from "./ThemeToggle";
import { LanguageToggle } from "./LanguageToggle";

export function SiteHeader({ user }: { user: SessionUser | null }) {
  return (
    <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/90 backdrop-blur dark:border-gray-800 dark:bg-gray-900/90">
      <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-4">
        <Link
          href="/"
          className="inline-flex items-center gap-2 font-semibold text-gray-900 dark:text-gray-100"
        >
          <Church className="h-6 w-6 text-brand-600" />
          <span>ChurchHub</span>
        </Link>
        <div className="flex items-center gap-3">
          <LanguageToggle />
          <ThemeToggle />
          <UserMenu user={user} />
        </div>
      </div>
    </header>
  );
}

export function SiteFooter() {
  const { t } = getTranslations();
  return (
    <footer className="border-t border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
      <div className="mx-auto max-w-5xl px-4 py-6 text-center text-sm text-gray-500 dark:text-gray-400">
        {t("footer.copyright", { year: new Date().getFullYear() })}
      </div>
    </footer>
  );
}
