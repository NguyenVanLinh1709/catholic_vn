import Link from "next/link";
import { Building2, Clock, Newspaper, UserSquare2 } from "lucide-react";
import { getTranslations } from "@/lib/i18n/server";
import type { MessageKey } from "@/lib/i18n/messages";

const cards: {
  href: string;
  labelKey: MessageKey;
  descKey: MessageKey;
  icon: React.ComponentType<{ className?: string }>;
}[] = [
  { href: "/admin/parish", labelKey: "nav.parishInfo", descKey: "admin.overview.parishDesc", icon: Building2 },
  { href: "/admin/priests", labelKey: "nav.priests", descKey: "admin.overview.priestsDesc", icon: UserSquare2 },
  { href: "/admin/mass-schedules", labelKey: "nav.massSchedules", descKey: "admin.overview.massDesc", icon: Clock },
  { href: "/admin/articles", labelKey: "nav.articles", descKey: "admin.overview.articlesDesc", icon: Newspaper },
];

export default function AdminDashboard() {
  const { t } = getTranslations();
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("admin.overview.title")}</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">{t("admin.overview.subtitle")}</p>
      </div>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {cards.map((c) => {
          const Icon = c.icon;
          return (
            <Link
              key={c.href}
              href={c.href}
              className="flex items-start gap-4 rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-5 transition hover:border-brand-300 hover:shadow-md"
            >
              <div className="rounded-lg bg-brand-50 p-2.5">
                <Icon className="h-5 w-5 text-brand-600" />
              </div>
              <div>
                <p className="font-medium text-gray-900 dark:text-gray-100">{t(c.labelKey)}</p>
                <p className="mt-0.5 text-sm text-gray-500 dark:text-gray-400">{t(c.descKey)}</p>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
