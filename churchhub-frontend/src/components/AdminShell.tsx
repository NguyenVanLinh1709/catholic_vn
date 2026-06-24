"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  Church,
  LayoutDashboard,
  Users,
  Newspaper,
  Clock,
  UserSquare2,
  Building2,
  LogOut,
  ShieldAlert,
} from "lucide-react";
import type { SessionUser } from "@/lib/types";
import { cn } from "@/lib/utils";
import { Button } from "./Button";
import { ThemeToggle } from "./ThemeToggle";

type Section = "admin" | "super";
interface NavItem {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
}

const NAV: Record<Section, NavItem[]> = {
  admin: [
    { href: "/admin", label: "Tổng quan", icon: LayoutDashboard },
    { href: "/admin/parish", label: "Thông tin nhà thờ", icon: Building2 },
    { href: "/admin/priests", label: "Linh mục", icon: UserSquare2 },
    { href: "/admin/mass-schedules", label: "Giờ lễ", icon: Clock },
    { href: "/admin/articles", label: "Bài viết", icon: Newspaper },
  ],
  super: [
    { href: "/super-admin/parishes", label: "Nhà thờ", icon: Building2 },
    { href: "/super-admin/users", label: "Tài khoản quản trị", icon: Users },
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

  // Client-side role guard (defence in depth alongside middleware).
  if (!isAllowed(section, user)) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-3 px-4 text-center">
        <ShieldAlert className="h-10 w-10 text-red-500" />
        <h1 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Không có quyền truy cập</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">Tài khoản của bạn không được phép vào khu vực này.</p>
        <Link href="/" className="text-sm font-medium text-brand-700 hover:underline">
          ← Về trang chủ
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

  return (
    <div className="flex min-h-screen bg-gray-50 dark:bg-gray-950">
      <aside className="hidden w-64 shrink-0 flex-col border-r border-gray-200 bg-white md:flex dark:border-gray-800 dark:bg-gray-900">
        <div className="flex h-16 items-center justify-between border-b border-gray-100 px-5 font-semibold text-gray-900 dark:border-gray-800 dark:text-gray-100">
          <span className="inline-flex items-center gap-2">
            <Church className="h-6 w-6 text-brand-600" />
            ChurchHub
          </span>
          <ThemeToggle />
        </div>
        <nav className="flex-1 space-y-1 p-3">
          {items.map((item) => {
            const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
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
                {item.label}
              </Link>
            );
          })}
        </nav>
        <div className="border-t border-gray-100 p-3 dark:border-gray-800">
          <p className="truncate px-3 pb-2 text-xs text-gray-400 dark:text-gray-500">{user.email}</p>
          <Button variant="secondary" size="sm" className="w-full" onClick={logout}>
            <LogOut className="h-4 w-4" />
            Đăng xuất
          </Button>
        </div>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        {/* Mobile top bar */}
        <header className="flex items-center justify-between border-b border-gray-200 bg-white px-4 py-3 md:hidden dark:border-gray-800 dark:bg-gray-900">
          <span className="inline-flex items-center gap-2 font-semibold text-gray-900 dark:text-gray-100">
            <Church className="h-5 w-5 text-brand-600" /> ChurchHub
          </span>
          <div className="flex items-center gap-2">
            <ThemeToggle />
            <Button variant="ghost" size="sm" onClick={logout}>
              <LogOut className="h-4 w-4" />
            </Button>
          </div>
        </header>
        <main className="mx-auto w-full max-w-4xl flex-1 px-4 py-8">{children}</main>
      </div>
    </div>
  );
}
