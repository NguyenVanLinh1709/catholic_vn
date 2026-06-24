import Link from "next/link";
import { Building2, Clock, Newspaper, UserSquare2 } from "lucide-react";

const cards = [
  { href: "/admin/parish", label: "Thông tin nhà thờ", desc: "Cập nhật địa chỉ, mô tả, liên hệ", icon: Building2 },
  { href: "/admin/priests", label: "Linh mục", desc: "Quản lý cha xứ, cha phó", icon: UserSquare2 },
  { href: "/admin/mass-schedules", label: "Giờ lễ", desc: "Lịch lễ ngày thường, Chúa Nhật", icon: Clock },
  { href: "/admin/articles", label: "Bài viết", desc: "Tin tức & sự kiện giáo xứ", icon: Newspaper },
];

export default function AdminDashboard() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Tổng quan</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">Quản lý thông tin giáo xứ của bạn.</p>
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
                <p className="font-medium text-gray-900 dark:text-gray-100">{c.label}</p>
                <p className="mt-0.5 text-sm text-gray-500 dark:text-gray-400">{c.desc}</p>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
