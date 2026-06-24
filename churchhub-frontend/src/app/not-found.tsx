import Link from "next/link";

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-3 px-4 text-center">
      <p className="text-5xl font-bold text-brand-600">404</p>
      <h1 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Không tìm thấy trang</h1>
      <p className="text-sm text-gray-500 dark:text-gray-400">Nội dung bạn tìm có thể đã bị xoá hoặc không tồn tại.</p>
      <Link href="/" className="mt-2 text-sm font-medium text-brand-700 hover:underline">
        ← Về trang chủ
      </Link>
    </div>
  );
}
