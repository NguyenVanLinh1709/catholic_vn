import { twMerge } from "tailwind-merge";

/**
 * Joins conditional classNames and resolves conflicting Tailwind utilities so a later
 * class (e.g. a caller-supplied override) wins over an earlier one targeting the same
 * CSS property, regardless of the order Tailwind happens to emit them in its generated
 * stylesheet — a plain string-join left that outcome dependent on build mode (dev vs
 * prod produced different orders), which broke component width overrides in production.
 */
export function cn(...classes: Array<string | false | null | undefined>): string {
  return twMerge(classes.filter(Boolean).join(" "));
}
