import { getTranslations } from "@/lib/i18n/server";

export function SiteFooter() {
  const { t } = getTranslations();
  return (
    <footer className="border-t border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
      <div className="mx-auto max-w-5xl px-4 py-6 text-center text-sm text-gray-500 dark:text-gray-400">
        {t("footer.copyright", { year: new Date().getFullYear() })}
      </div>
    </footer>
  );
}
