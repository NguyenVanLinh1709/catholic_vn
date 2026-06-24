package com.churchhub.common;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Generates URL-friendly slugs from Vietnamese text (diacritics removed).
 */
public final class SlugUtil {

    private static final Pattern NON_LATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]+");
    private static final Pattern EDGE_DASHES = Pattern.compile("(^-+)|(-+$)");
    private static final Pattern MULTI_DASH = Pattern.compile("-{2,}");

    private SlugUtil() {
    }

    public static String slugify(String input) {
        if (input == null || input.isBlank()) {
            return "";
        }
        String value = input.trim();
        // Vietnamese-specific: đ/Đ are not decomposed by NFD.
        value = value.replace('đ', 'd').replace('Đ', 'D');
        value = Normalizer.normalize(value, Normalizer.Form.NFD);
        value = value.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        value = WHITESPACE.matcher(value).replaceAll("-");
        value = NON_LATIN.matcher(value).replaceAll("");
        value = MULTI_DASH.matcher(value).replaceAll("-");
        value = EDGE_DASHES.matcher(value).replaceAll("");
        return value.toLowerCase(Locale.ENGLISH);
    }
}
