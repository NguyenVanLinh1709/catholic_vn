import type { Metadata } from "next";
import "./globals.css";
import { ToastProvider } from "@/components/Toast";
import { I18nProvider } from "@/lib/i18n/provider";
import { getLocale, getTranslations } from "@/lib/i18n/server";

export function generateMetadata(): Metadata {
  const { t } = getTranslations();
  return {
    title: {
      default: t("meta.title"),
      template: "%s | ChurchHub",
    },
    description: t("meta.description"),
  };
}

// Applies the saved (or system) theme before paint to avoid a light/dark flash.
const themeScript = `(function(){try{var t=localStorage.getItem('theme');var m=window.matchMedia('(prefers-color-scheme: dark)').matches;if(t==='dark'||(!t&&m)){document.documentElement.classList.add('dark');}}catch(e){}})();`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const locale = getLocale();
  return (
    <html lang={locale} suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeScript }} />
      </head>
      <body>
        <I18nProvider initialLocale={locale}>
          <ToastProvider>{children}</ToastProvider>
        </I18nProvider>
      </body>
    </html>
  );
}
