"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  Newspaper,
  FileText,
  Building2,
  LogOut,
  ShieldAlert,
} from "lucide-react";
import type { SessionUser } from "@/lib/types";
import { cn } from "@/lib/utils";
import { useI18n } from "@/lib/i18n/provider";
import type { MessageKey } from "@/lib/i18n/messages";
import { Button } from "./Button";

type Section = "admin" | "super";
interface NavItem {
  href: string;
  labelKey: MessageKey;
  icon: React.ComponentType<{ className?: string }>;
}

const NAV: Record<Section, NavItem[]> = {
  admin: [
    { href: "/admin", labelKey: "nav.overview", icon: LayoutDashboard },
    { href: "/admin/feed", labelKey: "nav.articles", icon: Newspaper },
    { href: "/admin/articles", labelKey: "nav.articlesManage", icon: FileText },
  ],
  super: [
    { href: "/super-admin/parishes", labelKey: "nav.parishes", icon: Building2 },
    { href: "/super-admin/users", labelKey: "nav.users", icon: Users },
  ],
};

function isAllowed(section: Section, user: SessionUser): boolean {
  if (section === "super") return user.role === "SUPER_ADMIN";
  return user.role === "PARISH_ADMIN" || user.role === "SUPER_ADMIN";
}

export function AdminShell({
  user,
  section,
  children,
}: {
  user: SessionUser;
  section: Section;
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const { t } = useI18n();

  // Client-side role guard (defence in depth alongside middleware).
  if (!isAllowed(section, user)) {
    return (
      <div className="flex flex-1 flex-col items-center justify-center gap-3 px-4 text-center">
        <ShieldAlert className="h-10 w-10 text-red-500" />
        <h1 className="text-lg font-semibold text-gray-900 dark:text-gray-100">{t("shell.noAccessTitle")}</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("shell.noAccessDesc")}</p>
        <Link href="/" className="text-sm font-medium text-brand-700 hover:underline">
          {t("common.backHome")}
        </Link>
      </div>
    );
  }

  async function logout() {
    await fetch("/api/auth/logout", { method: "POST" });
    router.push("/login");
    router.refresh();
  }

  const items = NAV[section];

  // Pick a single active item: the one whose href is the longest prefix of the
  // current path. This stops a section root like "/admin" from also lighting up
  // on its children ("/admin/articles", …) alongside the real page.
  const activeHref = items
    .filter((item) => pathname === item.href || pathname.startsWith(`${item.href}/`))
    .sort((a, b) => b.href.length - a.href.length)[0]?.href;

  return (
    <div className="flex flex-1 bg-gray-50 dark:bg-gray-950">
      <aside className="sticky top-16 hidden h-[calc(100vh-4rem)] w-64 shrink-0 flex-col border-r border-gray-200 bg-white md:flex dark:border-gray-800 dark:bg-gray-900">
        <nav className="flex-1 space-y-1 p-3">
          {items.map((item) => {
            const active = item.href === activeHref;
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition",
                  active
                    ? "bg-brand-50 text-brand-700 dark:bg-brand-900/30 dark:text-brand-300"
                    : "text-gray-600 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800",
                )}
              >
                <Icon className="h-4 w-4" />
                {t(item.labelKey)}
              </Link>
            );
          })}
        </nav>
        <div className="border-t border-gray-100 p-3 dark:border-gray-800">
          <p className="truncate px-3 pb-2 text-xs text-gray-400 dark:text-gray-500">{user.email}</p>
          <Button variant="secondary" size="sm" className="w-full" onClick={logout}>
            <LogOut className="h-4 w-4" />
            {t("shell.logout")}
          </Button>
        </div>
      </aside>

      <main className="mx-auto w-full min-w-0 max-w-4xl flex-1 px-4 py-8">{children}</main>
    </div>
  );
}
