import Link from "next/link";
import { getTranslations } from "@/lib/i18n/server";

export default function NotFound() {
  const { t } = getTranslations();
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-3 px-4 text-center">
      <p className="text-5xl font-bold text-brand-600">404</p>
      <h1 className="text-lg font-semibold text-gray-900 dark:text-gray-100">{t("notFound.title")}</h1>
      <p className="text-sm text-gray-500 dark:text-gray-400">{t("notFound.desc")}</p>
      <Link href="/" className="mt-2 text-sm font-medium text-brand-700 hover:underline">
        {t("common.backHome")}
      </Link>
    </div>
  );
}
