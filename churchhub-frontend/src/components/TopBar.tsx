import Link from "next/link";
import { Church } from "lucide-react";
import { getCurrentUser } from "@/lib/auth";
import { UserMenu } from "./UserMenu";
import { ThemeToggle } from "./ThemeToggle";
import { LanguageToggle } from "./LanguageToggle";

/**
 * Global application topbar — shown on every page (public, admin, login).
 * Holds the brand, the language/theme switchers, and the user menu. Section
 * layouts render their own chrome (public footer, admin sidebar) below it.
 */
export function TopBar() {
  const user = getCurrentUser();
  return (
    <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/90 backdrop-blur dark:border-gray-800 dark:bg-gray-900/90">
      <div className="flex h-16 items-center justify-between px-4 sm:px-6">
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
