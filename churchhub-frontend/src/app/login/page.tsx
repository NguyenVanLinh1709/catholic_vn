"use client";

import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { Church } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, PasswordInput } from "@/components/Field";
import { ThemeToggle } from "@/components/ThemeToggle";
import { useToast } from "@/components/Toast";

function LoginForm() {
  const router = useRouter();
  const params = useSearchParams();
  const toast = useToast();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function submit() {
    if (!email || !password) {
      toast.error("Vui lòng nhập email và mật khẩu");
      return;
    }
    setLoading(true);
    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      if (!res.ok) {
        const data = (await res.json().catch(() => ({}))) as { message?: string };
        toast.error(data.message ?? "Đăng nhập thất bại");
        return;
      }
      toast.success("Đăng nhập thành công");
      const next = params.get("next") || "/";
      router.push(next);
      router.refresh();
    } catch {
      toast.error("Không thể kết nối máy chủ");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative w-full max-w-sm space-y-6 rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-8 shadow-sm">
      <div className="absolute right-4 top-4">
        <ThemeToggle />
      </div>
      <div className="flex flex-col items-center gap-2 text-center">
        <Church className="h-10 w-10 text-brand-600" />
        <h1 className="text-xl font-bold text-gray-900 dark:text-gray-100">Đăng nhập quản trị</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">ChurchHub Admin</p>
      </div>

      <div className="space-y-4">
        <Field label="Email" htmlFor="email" required>
          <Input
            id="email"
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && submit()}
            placeholder="admin@churchhub.local"
          />
        </Field>
        <Field label="Mật khẩu" htmlFor="password" required>
          <PasswordInput
            id="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && submit()}
            placeholder="••••••••"
          />
        </Field>
      </div>

      <Button onClick={submit} loading={loading} className="w-full">
        Đăng nhập
      </Button>

      <Link href="/" className="block text-center text-sm text-gray-500 hover:text-brand-700 dark:text-gray-400 dark:hover:text-brand-400">
        ← Về trang chủ
      </Link>
    </div>
  );
}

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50 px-4 dark:bg-gray-950">
      <Suspense fallback={null}>
        <LoginForm />
      </Suspense>
    </div>
  );
}
