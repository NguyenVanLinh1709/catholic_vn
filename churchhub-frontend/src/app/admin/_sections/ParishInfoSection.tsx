"use client";

import { useEffect, useState } from "react";
import { MapPin } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, Textarea } from "@/components/Field";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import { useI18n } from "@/lib/i18n/provider";
import { isValidPhone } from "@/lib/validation";
import type { Parish } from "@/lib/types";
import type { ParishInput } from "@/lib/api";
import { getMyParish, updateMyParish } from "../actions";

/** Render stored coordinates as a single "lat, lng" string for the location input. */
function formatLocation(lat: number | null | undefined, lng: number | null | undefined): string {
  if (lat == null || lng == null) return "";
  return `${lat}, ${lng}`;
}

/**
 * Parse the location input (a Google-Maps-style "lat, lng" pair) back into
 * coordinates. Returns null when the text is present but malformed.
 */
function parseLocation(value: string): { lat: number | null; lng: number | null } | null {
  const t = value.trim();
  if (!t) return { lat: null, lng: null };
  const m = t.match(/^(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)$/);
  if (!m) return null;
  return { lat: Number(m[1]), lng: Number(m[2]) };
}

export function ParishInfoSection() {
  const toast = useToast();
  const { t } = useI18n();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [parish, setParish] = useState<Parish | null>(null);

  const [form, setForm] = useState<ParishInput>({ name: "" });
  // Coordinates are edited as a single "lat, lng" string (slug is derived
  // server-side from the name, so it is neither shown nor editable here).
  const [location, setLocation] = useState("");

  useEffect(() => {
    let active = true;
    getMyParish().then((res) => {
      if (!active) return;
      if (res.ok && res.data) {
        const p = res.data;
        setParish(p);
        setForm({
          name: p.name,
          address: p.address ?? "",
          phone: p.phone ?? "",
          description: p.description ?? "",
          isActive: p.active,
        });
        setLocation(formatLocation(p.latitude, p.longitude));
      } else if (!res.ok) {
        toast.error(res.message);
      }
      setLoading(false);
    });
    return () => {
      active = false;
    };
  }, [toast]);

  function set<K extends keyof ParishInput>(key: K, value: ParishInput[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function save() {
    if (!form.name.trim()) {
      toast.error(t("parishInfo.nameRequired"));
      return;
    }
    if (!isValidPhone(form.phone)) {
      toast.error(t("validation.phoneInvalid"));
      return;
    }
    const coords = parseLocation(location);
    if (coords === null) {
      toast.error(t("parishInfo.locationInvalid"));
      return;
    }
    setSaving(true);
    const res = await updateMyParish({
      ...form,
      address: emptyToNull(form.address),
      phone: emptyToNull(form.phone),
      description: emptyToNull(form.description),
      latitude: coords.lat,
      longitude: coords.lng,
    });
    setSaving(false);
    if (res.ok) {
      setParish(res.data);
      setLocation(formatLocation(res.data.latitude, res.data.longitude));
      toast.success(t("parishInfo.saved"));
    } else {
      toast.error(res.message);
    }
  }

  return (
    <section className="space-y-4">
      <div>
        <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">{t("parishInfo.title")}</h2>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{t("parishInfo.subtitle")}</p>
      </div>

      {loading ? (
        <LoadingBlock />
      ) : !parish ? (
        <EmptyState
          title={t("parishInfo.loadErrorTitle")}
          description={t("parishInfo.loadErrorDesc")}
        />
      ) : (
        <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
          <div className="space-y-5 p-6">
            <Field label={t("parishInfo.name")} required>
              <Input value={form.name} onChange={(e) => set("name", e.target.value)} />
            </Field>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field label={t("parishInfo.address")}>
                <Input value={form.address ?? ""} onChange={(e) => set("address", e.target.value)} />
              </Field>
              <Field label={t("parishInfo.phone")}>
                <Input
                  value={form.phone ?? ""}
                  onChange={(e) => set("phone", e.target.value)}
                  inputMode="tel"
                  maxLength={10}
                  placeholder="0xxxxxxxxx"
                />
              </Field>
            </div>

            <Field label={t("parishInfo.location")}>
              <div className="relative">
                <MapPin className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400 dark:text-gray-500" />
                <Input
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  placeholder={t("parishInfo.locationPlaceholder")}
                  className="pl-9"
                />
              </div>
              <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                {t("parishInfo.locationHint")}
              </p>
            </Field>

            <Field label={t("parishInfo.description")}>
              <Textarea value={form.description ?? ""} onChange={(e) => set("description", e.target.value)} />
            </Field>

            <label className="flex cursor-pointer items-center justify-between gap-4 rounded-lg border border-gray-200 px-4 py-3 dark:border-gray-800">
              <span>
                <span className="block text-sm font-medium text-gray-900 dark:text-gray-100">
                  {t("parishInfo.active")}
                </span>
                <span className="block text-xs text-gray-500 dark:text-gray-400">
                  {t("parishInfo.activeHint")}
                </span>
              </span>
              <input
                type="checkbox"
                checked={form.isActive ?? true}
                onChange={(e) => set("isActive", e.target.checked)}
                className="h-5 w-5 shrink-0 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
              />
            </label>
          </div>

          <div className="flex justify-end border-t border-gray-100 px-6 py-4 dark:border-gray-800">
            <Button onClick={save} loading={saving}>
              {t("common.saveChanges")}
            </Button>
          </div>
        </div>
      )}
    </section>
  );
}

function emptyToNull(v: string | null | undefined): string | null {
  return v && v.trim() ? v.trim() : null;
}
