"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { LogOut, LayoutDashboard } from "lucide-react";
import type { SessionUser } from "@/lib/types";
import { useI18n } from "@/lib/i18n/provider";
import { Button } from "./Button";

export function UserMenu({ user }: { user: SessionUser | null }) {
  const router = useRouter();
  const { t } = useI18n();
  const [loading, setLoading] = useState(false);

  if (!user) {
    return (
      <Link
        href="/login"
        className="text-sm font-medium text-brand-700 transition hover:text-brand-800"
      >
        {t("header.login")}
      </Link>
    );
  }

  const dashboardHref = user.role === "SUPER_ADMIN" ? "/super-admin/parishes" : "/admin";

  async function logout() {
    setLoading(true);
    try {
      await fetch("/api/auth/logout", { method: "POST" });
      router.push("/");
      router.refresh();
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex items-center gap-3">
      <Link
        href={dashboardHref}
        className="inline-flex items-center gap-1.5 text-sm font-medium text-gray-700 transition hover:text-brand-700 dark:text-gray-300 dark:hover:text-brand-400"
      >
        <LayoutDashboard className="h-4 w-4" />
        {t("header.admin")}
      </Link>
      <Button variant="secondary" size="sm" onClick={logout} loading={loading}>
        <LogOut className="h-4 w-4" />
        {t("shell.logout")}
      </Button>
    </div>
  );
}
