export const LOCALES = ["vi", "en"] as const;
export type Locale = (typeof LOCALES)[number];

export const DEFAULT_LOCALE: Locale = "vi";

/** Cookie that holds the chosen language; read on the server, written on the client. */
export const LOCALE_COOKIE = "ch_lang";

/** Full names shown in the language switcher. */
export const LOCALE_LABEL: Record<Locale, string> = {
  vi: "Tiếng Việt",
  en: "English",
};

/** Short codes shown on the toggle button. */
export const LOCALE_SHORT: Record<Locale, string> = {
  vi: "VI",
  en: "EN",
};

export function isLocale(value: string | undefined | null): value is Locale {
  return value === "vi" || value === "en";
}
