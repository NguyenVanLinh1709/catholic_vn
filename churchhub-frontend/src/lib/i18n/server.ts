import "server-only";
import { cookies } from "next/headers";
import type { Locale } from "./config";
import { DEFAULT_LOCALE, LOCALE_COOKIE, isLocale } from "./config";
import type { TranslateFn, TranslateParams, MessageKey } from "./messages";
import { translate } from "./messages";

/** The active locale from the `ch_lang` cookie, for Server Components. */
export function getLocale(): Locale {
  const value = cookies().get(LOCALE_COOKIE)?.value;
  return isLocale(value) ? value : DEFAULT_LOCALE;
}

/** Server-side translator: `const { t, locale } = getTranslations()`. */
export function getTranslations(): { locale: Locale; t: TranslateFn } {
  const locale = getLocale();
  const t: TranslateFn = (key: MessageKey, params?: TranslateParams) =>
    translate(locale, key, params);
  return { locale, t };
}
