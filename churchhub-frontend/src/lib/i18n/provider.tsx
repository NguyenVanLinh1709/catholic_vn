"use client";

import { createContext, useCallback, useContext, useMemo, useState } from "react";
import type { Locale } from "./config";
import { LOCALE_COOKIE } from "./config";
import type { TranslateFn, TranslateParams, MessageKey } from "./messages";
import { translate } from "./messages";

interface I18nContextValue {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: TranslateFn;
}

const I18nContext = createContext<I18nContextValue | null>(null);

/**
 * Holds the active language for client components. The initial value comes from
 * the server (cookie) so the first client render matches SSR — no flash.
 */
export function I18nProvider({
  initialLocale,
  children,
}: {
  initialLocale: Locale;
  children: React.ReactNode;
}) {
  const [locale, setLocaleState] = useState<Locale>(initialLocale);

  const setLocale = useCallback((next: Locale) => {
    // Persist for the server (cookie) and as a client-side fallback.
    document.cookie = `${LOCALE_COOKIE}=${next};path=/;max-age=31536000;samesite=lax`;
    try {
      localStorage.setItem(LOCALE_COOKIE, next);
    } catch {
      /* ignore storage errors */
    }
    document.documentElement.lang = next;
    setLocaleState(next);
  }, []);

  const t = useCallback<TranslateFn>(
    (key: MessageKey, params?: TranslateParams) => translate(locale, key, params),
    [locale],
  );

  const value = useMemo(() => ({ locale, setLocale, t }), [locale, setLocale, t]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n(): I18nContextValue {
  const ctx = useContext(I18nContext);
  if (!ctx) throw new Error("useI18n must be used within <I18nProvider>");
  return ctx;
}
