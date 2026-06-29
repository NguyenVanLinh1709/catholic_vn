import type { Metadata } from "next";
import "./globals.css";
import { ToastProvider } from "@/components/Toast";
import { TopBar } from "@/components/TopBar";
import { I18nProvider } from "@/lib/i18n/provider";
import { getLocale, getTranslations } from "@/lib/i18n/server";
import { SITE_URL } from "@/lib/site";

export function generateMetadata(): Metadata {
  const { t, locale } = getTranslations();
  const title = t("meta.title");
  const description = t("meta.description");
  return {
    metadataBase: new URL(SITE_URL),
    title: {
      default: title,
      template: "%s | ChurchHub",
    },
    description,
    applicationName: "ChurchHub",
    alternates: { canonical: "/" },
    robots: {
      index: true,
      follow: true,
      googleBot: { index: true, follow: true, "max-image-preview": "large" },
    },
    openGraph: {
      type: "website",
      siteName: "ChurchHub",
      locale: locale === "vi" ? "vi_VN" : "en_GB",
      url: "/",
      title,
      description,
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
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
          <ToastProvider>
            <div className="flex min-h-screen flex-col">
              <TopBar />
              <div className="flex flex-1 flex-col">{children}</div>
            </div>
          </ToastProvider>
        </I18nProvider>
      </body>
    </html>
  );
}
