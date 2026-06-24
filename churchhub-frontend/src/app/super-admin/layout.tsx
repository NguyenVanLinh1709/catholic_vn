import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { AdminShell } from "@/components/AdminShell";

export default function SuperAdminLayout({ children }: { children: React.ReactNode }) {
  const user = getCurrentUser();
  if (!user) redirect("/login?next=/super-admin/parishes");
  return (
    <AdminShell user={user} section="super">
      {children}
    </AdminShell>
  );
}
