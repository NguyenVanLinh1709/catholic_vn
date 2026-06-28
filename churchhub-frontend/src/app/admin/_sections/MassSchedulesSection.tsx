"use client";

import { useEffect, useState } from "react";
import { Clock, Pencil, Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, Select } from "@/components/Field";
import { Modal, ConfirmDialog } from "@/components/Modal";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import { formatTime, groupMassSchedules } from "@/lib/format";
import { useI18n } from "@/lib/i18n/provider";
import { dayTypeLabel, dayOfWeekLabel } from "@/lib/i18n/labels";
import type { DayType, MassSchedule } from "@/lib/types";
import type { MassScheduleInput } from "@/lib/api";
import { listMyMass, createMyMass, editMass, removeMass } from "../actions";

const EMPTY: MassScheduleInput = {
  dayType: "SUNDAY",
  dayOfWeek: 7,
  massTime: "07:00",
  label: "",
  note: "",
};

export function MassSchedulesSection() {
  const toast = useToast();
  const { t } = useI18n();
  const [loading, setLoading] = useState(true);
  const [items, setItems] = useState<MassSchedule[]>([]);

  const [editing, setEditing] = useState<MassSchedule | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState<MassScheduleInput>(EMPTY);
  const [saving, setSaving] = useState(false);

  const [deleteTarget, setDeleteTarget] = useState<MassSchedule | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function reload() {
    const res = await listMyMass();
    if (res.ok) setItems(res.data);
    else toast.error(res.message);
    setLoading(false);
  }

  useEffect(() => {
    void reload();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function openCreate() {
    setEditing(null);
    setForm(EMPTY);
    setModalOpen(true);
  }

  function openEdit(m: MassSchedule) {
    setEditing(m);
    setForm({
      dayType: m.dayType,
      dayOfWeek: m.dayOfWeek,
      massTime: formatTime(m.massTime),
      label: m.label ?? "",
      note: m.note ?? "",
    });
    setModalOpen(true);
  }

  async function save() {
    if (!form.massTime) {
      toast.error(t("mass.timeRequired"));
      return;
    }
    setSaving(true);
    const payload: MassScheduleInput = {
      ...form,
      label: form.label?.trim() || null,
      note: form.note?.trim() || null,
    };
    const res = editing ? await editMass(editing.id, payload) : await createMyMass(payload);
    setSaving(false);
    if (res.ok) {
      toast.success(editing ? t("common.updated") : t("mass.created"));
      setModalOpen(false);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    const res = await removeMass(deleteTarget.id);
    setDeleting(false);
    if (res.ok) {
      toast.success(t("common.deleted"));
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  const groups = groupMassSchedules(items);

  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">{t("mass.title")}</h2>
        <Button onClick={openCreate}>
          <Plus className="h-4 w-4" />
          {t("common.add")}
        </Button>
      </div>

      {loading ? (
        <LoadingBlock label={t("common.loading")} />
      ) : items.length === 0 ? (
        <EmptyState
          title={t("mass.emptyTitle")}
          description={t("mass.emptyDesc")}
          action={<Button onClick={openCreate}>{t("mass.emptyAction")}</Button>}
        />
      ) : (
        <div className="space-y-4">
          {groups.map((group) => (
            <div key={group.dayType} className="rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-5">
              <h3 className="mb-3 font-medium text-gray-900 dark:text-gray-100">{dayTypeLabel(t, group.dayType)}</h3>
              <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                {group.items.map((m) => (
                  <li key={m.id} className="flex items-center gap-3 py-2 text-sm">
                    <Clock className="h-4 w-4 shrink-0 text-brand-500" />
                    <span className="w-14 font-medium text-gray-900 dark:text-gray-100">{formatTime(m.massTime)}</span>
                    <span className="w-24 text-gray-500 dark:text-gray-400">{dayOfWeekLabel(t, m.dayOfWeek)}</span>
                    <span className="flex-1 text-gray-700 dark:text-gray-300">{m.label ?? ""}</span>
                    <Button variant="ghost" size="sm" onClick={() => openEdit(m)}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => setDeleteTarget(m)}>
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      )}

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? t("mass.editTitle") : t("mass.addTitle")}
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
        <div className="space-y-4">
          <Field label={t("mass.fieldDayType")} required>
            <Select
              value={form.dayType}
              onChange={(e) => setForm((p) => ({ ...p, dayType: e.target.value as DayType }))}
            >
              <option value="WEEKDAY">{dayTypeLabel(t, "WEEKDAY")}</option>
              <option value="SUNDAY">{dayTypeLabel(t, "SUNDAY")}</option>
              <option value="SPECIAL">{dayTypeLabel(t, "SPECIAL")}</option>
            </Select>
          </Field>
          <Field label={t("mass.fieldDayOfWeek")}>
            <Select
              value={form.dayOfWeek ?? ""}
              onChange={(e) =>
                setForm((p) => ({
                  ...p,
                  dayOfWeek: e.target.value === "" ? null : Number(e.target.value),
                }))
              }
            >
              <option value="">{t("mass.dayOfWeekAny")}</option>
              {[1, 2, 3, 4, 5, 6, 7].map((value) => (
                <option key={value} value={value}>
                  {dayOfWeekLabel(t, value)}
                </option>
              ))}
            </Select>
          </Field>
          <Field label={t("mass.fieldTime")} required>
            <Input
              type="time"
              value={form.massTime}
              onChange={(e) => setForm((p) => ({ ...p, massTime: e.target.value }))}
            />
          </Field>
          <Field label={t("mass.fieldLabel")}>
            <Input
              value={form.label ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, label: e.target.value }))}
            />
          </Field>
          <Field label={t("mass.fieldNote")}>
            <Input
              value={form.note ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, note: e.target.value }))}
            />
          </Field>
        </div>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title={t("mass.deleteTitle")}
        message={t("mass.deleteMessage")}
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </section>
  );
}
