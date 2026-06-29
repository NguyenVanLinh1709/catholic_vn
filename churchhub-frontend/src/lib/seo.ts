import type { MassSchedule, Parish } from "./types";
import { formatTime } from "./format";
import { absoluteUrl } from "./site";

// schema.org day names, indexed by the backend's dayOfWeek (1=Mon … 7=Sun).
const SCHEMA_DOW: Record<number, string> = {
  1: "Monday",
  2: "Tuesday",
  3: "Wednesday",
  4: "Thursday",
  5: "Friday",
  6: "Saturday",
  7: "Sunday",
};
const WEEKDAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

interface OpeningHours {
  "@type": "OpeningHoursSpecification";
  dayOfWeek: string | string[];
  opens: string;
  closes: string;
}

/**
 * Maps mass schedules to schema.org OpeningHoursSpecification entries so search
 * engines can surface service times. A mass is a point in time, so opens/closes
 * carry the same value. SPECIAL (irregular) schedules are omitted — they have no
 * stable weekly day to express here.
 */
export function massOpeningHours(schedules: MassSchedule[]): OpeningHours[] {
  const specs: OpeningHours[] = [];
  for (const s of schedules) {
    const time = formatTime(s.massTime);
    if (!time) continue;

    let dayOfWeek: string | string[] | null = null;
    if (s.dayType === "SUNDAY") {
      dayOfWeek = "Sunday";
    } else if (s.dayType === "WEEKDAY") {
      dayOfWeek = s.dayOfWeek != null ? (SCHEMA_DOW[s.dayOfWeek] ?? null) : WEEKDAYS;
    }
    if (!dayOfWeek) continue; // SPECIAL or unknown day

    specs.push({ "@type": "OpeningHoursSpecification", dayOfWeek, opens: time, closes: time });
  }
  return specs;
}

/** schema.org Church node for a single parish, including address, geo and mass times. */
export function churchJsonLd(parish: Parish, schedules: MassSchedule[]) {
  const url = absoluteUrl(`/parishes/${parish.slug}`);
  const openingHours = massOpeningHours(schedules);
  return {
    "@type": "Church",
    "@id": url,
    name: parish.name,
    url,
    ...(parish.description ? { description: parish.description } : {}),
    ...(parish.phone ? { telephone: parish.phone } : {}),
    ...(parish.address
      ? { address: { "@type": "PostalAddress", streetAddress: parish.address } }
      : {}),
    ...(parish.latitude != null && parish.longitude != null
      ? { geo: { "@type": "GeoCoordinates", latitude: parish.latitude, longitude: parish.longitude } }
      : {}),
    ...(openingHours.length > 0 ? { openingHoursSpecification: openingHours } : {}),
  };
}

/**
 * An ItemList of churches for the parish directory page. `startPosition` keeps
 * the list positions correct across pagination (0-based page * pageSize).
 */
export function parishListJsonLd(
  parishes: Parish[],
  massByParish: Record<number, MassSchedule[]>,
  startPosition = 0,
) {
  return {
    "@context": "https://schema.org",
    "@type": "ItemList",
    itemListElement: parishes.map((parish, i) => ({
      "@type": "ListItem",
      position: startPosition + i + 1,
      item: churchJsonLd(parish, massByParish[parish.id] ?? []),
    })),
  };
}
