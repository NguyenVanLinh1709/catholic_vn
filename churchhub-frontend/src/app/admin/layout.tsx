import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { AdminShell } from "@/components/AdminShell";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = getCurrentUser();
  if (!user) redirect("/login?next=/admin");
  return (
    <AdminShell user={user} section="admin">
      {children}
    </AdminShell>
  );
}
