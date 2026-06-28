"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Clock, ExternalLink, Pencil, Plus, Search, Trash2, X } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, Textarea } from "@/components/Field";
import { Modal, ConfirmDialog } from "@/components/Modal";
import { Badge, LoadingBlock, EmptyState } from "@/components/Feedback";
import { Pagination } from "@/components/Pagination";
import { useToast } from "@/components/Toast";
import { cn } from "@/lib/utils";
import { formatTime } from "@/lib/format";
import { useI18n } from "@/lib/i18n/provider";
import type { AdminUser, MassSchedule, Parish } from "@/lib/types";
import type { MassScheduleInput, ParishInput } from "@/lib/api";
import {
  listAllParishes,
  createParishAction,
  updateParishAction,
  deleteParishAction,
  listParishMassSchedules,
  createParishMassSchedule,
  deleteParishMassSchedule,
  listAdminAccounts,
  setParishAdminsAction,
} from "../actions";

const EMPTY: ParishInput = { name: "", address: "", phone: "", description: "", isActive: true };

/** Build the mass-schedule payload for a given time slot group. */
function massPayload(dayType: MassScheduleInput["dayType"], massTime: string): MassScheduleInput {
  return {
    dayType,
    dayOfWeek: dayType === "SUNDAY" ? 7 : null,
    massTime,
    label: null,
    note: null,
  };
}

export default function SuperParishesPage() {
  const toast = useToast();
  const { t } = useI18n();
  const [loading, setLoading] = useState(true);
  const [items, setItems] = useState<Parish[]>([]);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [search, setSearch] = useState("");

  const [editing, setEditing] = useState<Parish | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState<ParishInput>(EMPTY);
  const [saving, setSaving] = useState(false);

  // Mass time slots managed inside the popup.
  const [weekdayTimes, setWeekdayTimes] = useState<string[]>([]);
  const [weekendTimes, setWeekendTimes] = useState<string[]>([]);
  // Original schedules (edit mode) so we can diff create/delete on save.
  const [originalMass, setOriginalMass] = useState<MassSchedule[]>([]);

  // Parish-admin assignment (edit mode): the full pool of PARISH_ADMIN accounts
  // and the ids currently selected for this parish.
  const [adminPool, setAdminPool] = useState<AdminUser[]>([]);
  const [selectedAdminIds, setSelectedAdminIds] = useState<number[]>([]);

  const [deleteTarget, setDeleteTarget] = useState<Parish | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function reload(p = page, q = search) {
    setLoading(true);
    const res = await listAllParishes(q.trim() || undefined, p);
    if (res.ok) {
      setItems(res.data.content);
      setTotalPages(res.data.totalPages);
      setPage(res.data.page);
    } else {
      toast.error(res.message);
    }
    setLoading(false);
  }

  async function reloadAdminPool() {
    const res = await listAdminAccounts();
    if (res.ok) setAdminPool(res.data);
  }

  useEffect(() => {
    void reload(0, "");
    void reloadAdminPool();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function openCreate() {
    setEditing(null);
    setForm(EMPTY);
    setWeekdayTimes([]);
    setWeekendTimes([]);
    setOriginalMass([]);
    setSelectedAdminIds([]);
    setModalOpen(true);
  }

  async function openEdit(p: Parish) {
    setEditing(p);
    setForm({
      name: p.name,
      slug: p.slug,
      address: p.address ?? "",
      phone: p.phone ?? "",
      latitude: p.latitude,
      longitude: p.longitude,
      description: p.description ?? "",
      isActive: p.active,
    });
    setWeekdayTimes([]);
    setWeekendTimes([]);
    setOriginalMass([]);
    // Preselect admins already assigned to this parish.
    setSelectedAdminIds(adminPool.filter((u) => u.parishId === p.id).map((u) => u.id));
    setModalOpen(true);
    const res = await listParishMassSchedules(p.id);
    if (res.ok) {
      setOriginalMass(res.data);
      setWeekdayTimes(
        res.data.filter((m) => m.dayType === "WEEKDAY").map((m) => formatTime(m.massTime)),
      );
      setWeekendTimes(
        res.data.filter((m) => m.dayType === "SUNDAY").map((m) => formatTime(m.massTime)),
      );
    }
  }

  async function save() {
    if (!form.name.trim()) {
      toast.error(t("superParishes.nameRequired"));
      return;
    }
    setSaving(true);
    const payload: ParishInput = {
      ...form,
      slug: form.slug?.trim() || undefined,
      address: form.address?.trim() || null,
      phone: form.phone?.trim() || null,
      description: form.description?.trim() || null,
    };
    // Create returns the detail payload (id under .parish); edit reuses the known id.
    let parishId: number;
    if (editing) {
      const res = await updateParishAction(editing.id, payload);
      if (!res.ok) {
        setSaving(false);
        toast.error(res.message);
        return;
      }
      parishId = editing.id;
    } else {
      const res = await createParishAction(payload);
      if (!res.ok) {
        setSaving(false);
        toast.error(res.message);
        return;
      }
      parishId = res.data.parish.id;
    }

    const massError = await syncMassSchedules(parishId);

    // Admin assignment is only managed from the edit popup (a new parish has no id yet).
    let adminError: string | null = null;
    if (editing) {
      const res = await setParishAdminsAction(parishId, selectedAdminIds);
      if (!res.ok) adminError = res.message;
    }

    setSaving(false);
    const problems = [massError, adminError].filter(Boolean).join("; ");
    if (problems) {
      toast.error(t("superParishes.savedWithErrors", { problems }));
    } else {
      toast.success(editing ? t("common.updated") : t("superParishes.created"));
    }
    setModalOpen(false);
    void reload();
    void reloadAdminPool();
  }

  /** Diff the entered weekday/weekend times against existing schedules. */
  async function syncMassSchedules(parishId: number): Promise<string | null> {
    const norm = (t: string) => formatTime(t.trim());
    const desired = [
      ...weekdayTimes.filter(Boolean).map((t) => ({ dayType: "WEEKDAY" as const, time: norm(t) })),
      ...weekendTimes.filter(Boolean).map((t) => ({ dayType: "SUNDAY" as const, time: norm(t) })),
    ];
    const existing = originalMass.map((m) => ({
      id: m.id,
      dayType: m.dayType,
      time: formatTime(m.massTime),
    }));

    const toDelete = existing.filter(
      (e) => !desired.some((d) => d.dayType === e.dayType && d.time === e.time),
    );
    const toCreate = desired.filter(
      (d) => !existing.some((e) => e.dayType === d.dayType && e.time === d.time),
    );

    for (const e of toDelete) {
      const res = await deleteParishMassSchedule(e.id);
      if (!res.ok) return res.message;
    }
    for (const d of toCreate) {
      const res = await createParishMassSchedule(parishId, massPayload(d.dayType, d.time));
      if (!res.ok) return res.message;
    }
    return null;
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    const res = await deleteParishAction(deleteTarget.id);
    setDeleting(false);
    if (res.ok) {
      toast.success(t("superParishes.deleted"));
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("superParishes.title")}</h1>
        <Button onClick={openCreate}>
          <Plus className="h-4 w-4" />
          {t("superParishes.add")}
        </Button>
      </div>

      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400 dark:text-gray-500" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && reload(0, search)}
            placeholder={t("superParishes.searchPlaceholder")}
            className="pl-9"
          />
        </div>
        <Button variant="secondary" onClick={() => reload(0, search)}>
          {t("common.search")}
        </Button>
      </div>

      {loading ? (
        <LoadingBlock label={t("common.loading")} />
      ) : items.length === 0 ? (
        <EmptyState title={t("superParishes.emptyTitle")} action={<Button onClick={openCreate}>{t("superParishes.add")}</Button>} />
      ) : (
        <>
          <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50 text-xs uppercase text-gray-500 dark:bg-gray-800/50 dark:text-gray-400">
                <tr>
                  <th className="px-4 py-3">{t("superParishes.colName")}</th>
                  <th className="px-4 py-3">{t("superParishes.colStatus")}</th>
                  <th className="px-4 py-3 text-right">{t("common.actions")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {items.map((p) => (
                  <tr key={p.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50">
                    <td className="px-4 py-3 font-medium text-gray-900 dark:text-gray-100">{p.name}</td>
                    <td className="px-4 py-3">
                      {p.active ? <Badge color="green">{t("superParishes.statusActive")}</Badge> : <Badge>{t("superParishes.statusHidden")}</Badge>}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex justify-end gap-1">
                        <Link href={`/parishes/${p.slug}`} target="_blank">
                          <Button variant="ghost" size="sm">
                            <ExternalLink className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Button variant="ghost" size="sm" onClick={() => openEdit(p)}>
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="sm" onClick={() => setDeleteTarget(p)}>
                          <Trash2 className="h-4 w-4 text-red-500" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Pagination page={page} totalPages={totalPages} onChange={(p) => reload(p)} />
        </>
      )}

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? t("superParishes.editTitle") : t("superParishes.addTitle")}
        footer={
          <>
            <Button variant="secondary" onClick={() => setModalOpen(false)} disabled={saving}>
              {t("common.cancel")}
            </Button>
            <Button onClick={save} loading={saving}>
              {t("common.save")}
            </Button>
          </>
        }
      >
        <div className="space-y-6">
          <section className="space-y-4">
            <Field label={t("superParishes.fieldName")} required>
              <Input value={form.name} onChange={(e) => setForm((p) => ({ ...p, name: e.target.value }))} />
            </Field>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field label={t("superParishes.fieldAddress")}>
                <Input
                  value={form.address ?? ""}
                  onChange={(e) => setForm((p) => ({ ...p, address: e.target.value }))}
                />
              </Field>
              <Field label={t("superParishes.fieldPhone")}>
                <Input
                  value={form.phone ?? ""}
                  onChange={(e) => setForm((p) => ({ ...p, phone: e.target.value }))}
                />
              </Field>
            </div>
            <Field label={t("superParishes.fieldDescription")}>
              <Textarea
                value={form.description ?? ""}
                onChange={(e) => setForm((p) => ({ ...p, description: e.target.value }))}
              />
            </Field>
          </section>

          <Section title={t("superParishes.sectionMass")}>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <TimeSlots label={t("superParishes.slotWeekday")} times={weekdayTimes} onChange={setWeekdayTimes} />
              <TimeSlots label={t("superParishes.slotWeekend")} times={weekendTimes} onChange={setWeekendTimes} />
            </div>
          </Section>

          {editing && (
            <Section title={t("superParishes.sectionAdmins")}>
              {adminPool.length === 0 ? (
                <p className="rounded-lg border border-dashed border-gray-200 px-4 py-6 text-center text-sm text-gray-500 dark:border-gray-800 dark:text-gray-400">
                  {t("superParishes.adminsEmpty")}
                </p>
              ) : (
                <div className="max-h-56 space-y-1.5 overflow-y-auto pr-1">
                  {adminPool.map((u) => {
                    const checked = selectedAdminIds.includes(u.id);
                    const elsewhere = u.parishId !== null && u.parishId !== editing.id;
                    const name = u.fullName || u.email;
                    return (
                      <label
                        key={u.id}
                        className={cn(
                          "flex cursor-pointer items-center gap-3 rounded-lg border px-3 py-2 transition",
                          checked
                            ? "border-brand-500 bg-brand-50 dark:border-brand-500/60 dark:bg-brand-500/10"
                            : "border-gray-200 hover:bg-gray-50 dark:border-gray-800 dark:hover:bg-gray-800/50",
                        )}
                      >
                        <input
                          type="checkbox"
                          checked={checked}
                          onChange={(e) =>
                            setSelectedAdminIds((ids) =>
                              e.target.checked
                                ? [...ids, u.id]
                                : ids.filter((id) => id !== u.id),
                            )
                          }
                          className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
                        />
                        <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-brand-100 text-xs font-semibold uppercase text-brand-700 dark:bg-brand-500/20 dark:text-brand-300">
                          {initials(name)}
                        </span>
                        <span className="min-w-0 flex-1">
                          <span className="block truncate text-sm font-medium text-gray-900 dark:text-gray-100">
                            {name}
                          </span>
                          <span className="block truncate text-xs text-gray-500 dark:text-gray-400">
                            {u.email}
                          </span>
                        </span>
                        {elsewhere && !checked && (
                          <span className="shrink-0 rounded-full bg-amber-100 px-2 py-0.5 text-xs font-medium text-amber-700 dark:bg-amber-500/15 dark:text-amber-400">
                            {t("superParishes.adminElsewhere")}
                          </span>
                        )}
                      </label>
                    );
                  })}
                </div>
              )}
            </Section>
          )}

          <label className="flex cursor-pointer items-center justify-between gap-4 rounded-lg border border-gray-200 px-4 py-3 dark:border-gray-800">
            <span>
              <span className="block text-sm font-medium text-gray-900 dark:text-gray-100">
                {t("superParishes.active")}
              </span>
              <span className="block text-xs text-gray-500 dark:text-gray-400">
                {t("superParishes.activeHint")}
              </span>
            </span>
            <input
              type="checkbox"
              checked={form.isActive ?? true}
              onChange={(e) => setForm((p) => ({ ...p, isActive: e.target.checked }))}
              className="h-5 w-5 shrink-0 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
            />
          </label>
        </div>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title={t("superParishes.deleteTitle")}
        message={t("superParishes.deleteMessage", { name: deleteTarget?.name ?? "" })}
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}

/** A titled group within the form, separated by a subtle top divider. */
function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="space-y-3 border-t border-gray-100 pt-5 dark:border-gray-800">
      <h3 className="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400">
        {title}
      </h3>
      {children}
    </section>
  );
}

/** Up-to-two-letter initials from a name or email, for the admin avatar. */
function initials(value: string): string {
  const parts = value.trim().split(/\s+/).filter(Boolean);
  if (parts.length >= 2) return (parts[0]![0]! + parts[parts.length - 1]![0]!).toUpperCase();
  return value.slice(0, 2).toUpperCase();
}

/** Editable list of mass times for a day-type group (weekday / weekend). */
function TimeSlots({
  label,
  times,
  onChange,
}: {
  label: string;
  times: string[];
  onChange: (times: string[]) => void;
}) {
  const { t } = useI18n();
  return (
    <Field label={label}>
      <div className="space-y-2">
        {times.length === 0 && (
          <p className="rounded-lg border border-dashed border-gray-200 px-3 py-2 text-xs text-gray-400 dark:border-gray-800 dark:text-gray-500">
            {t("superParishes.slotEmpty")}
          </p>
        )}
        {times.map((time, i) => (
          <div key={i} className="flex items-center gap-2">
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-brand-100 text-brand-600 dark:bg-brand-500/15 dark:text-brand-400">
              <Clock className="h-4 w-4" />
            </span>
            <Input
              type="time"
              value={time}
              onChange={(e) => onChange(times.map((t, j) => (j === i ? e.target.value : t)))}
              className="flex-1"
            />
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onChange(times.filter((_, j) => j !== i))}
              aria-label={t("superParishes.slotRemove")}
            >
              <X className="h-4 w-4 text-red-500" />
            </Button>
          </div>
        ))}
        <Button variant="secondary" size="sm" onClick={() => onChange([...times, "07:00"])}>
          <Plus className="h-4 w-4" />
          {t("superParishes.slotAdd")}
        </Button>
      </div>
    </Field>
  );
}
