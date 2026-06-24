"use client";

import { useEffect, useState } from "react";
import { Clock, Pencil, Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, Select } from "@/components/Field";
import { Modal, ConfirmDialog } from "@/components/Modal";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import {
  DAY_TYPE_LABEL,
  DAY_OF_WEEK_LABEL,
  dayOfWeekLabel,
  formatTime,
  groupMassSchedules,
} from "@/lib/format";
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

export default function AdminMassSchedulesPage() {
  const toast = useToast();
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
      toast.error("Vui lòng chọn giờ lễ");
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
      toast.success(editing ? "Đã cập nhật" : "Đã thêm giờ lễ");
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
      toast.success("Đã xoá");
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  const groups = groupMassSchedules(items);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Giờ lễ</h1>
        <Button onClick={openCreate}>
          <Plus className="h-4 w-4" />
          Thêm
        </Button>
      </div>

      {loading ? (
        <LoadingBlock />
      ) : items.length === 0 ? (
        <EmptyState
          title="Chưa có giờ lễ"
          description="Thêm lịch lễ ngày thường, Chúa Nhật hoặc lễ đặc biệt."
          action={<Button onClick={openCreate}>Thêm giờ lễ</Button>}
        />
      ) : (
        <div className="space-y-4">
          {groups.map((group) => (
            <div key={group.dayType} className="rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-5">
              <h2 className="mb-3 font-medium text-gray-900 dark:text-gray-100">{DAY_TYPE_LABEL[group.dayType]}</h2>
              <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                {group.items.map((m) => (
                  <li key={m.id} className="flex items-center gap-3 py-2 text-sm">
                    <Clock className="h-4 w-4 shrink-0 text-brand-500" />
                    <span className="w-14 font-medium text-gray-900 dark:text-gray-100">{formatTime(m.massTime)}</span>
                    <span className="w-24 text-gray-500 dark:text-gray-400">{dayOfWeekLabel(m.dayOfWeek)}</span>
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
        title={editing ? "Sửa giờ lễ" : "Thêm giờ lễ"}
        footer={
          <>
            <Button variant="secondary" onClick={() => setModalOpen(false)} disabled={saving}>
              Huỷ
            </Button>
            <Button onClick={save} loading={saving}>
              Lưu
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          <Field label="Loại ngày" required>
            <Select
              value={form.dayType}
              onChange={(e) => setForm((p) => ({ ...p, dayType: e.target.value as DayType }))}
            >
              <option value="WEEKDAY">{DAY_TYPE_LABEL.WEEKDAY}</option>
              <option value="SUNDAY">{DAY_TYPE_LABEL.SUNDAY}</option>
              <option value="SPECIAL">{DAY_TYPE_LABEL.SPECIAL}</option>
            </Select>
          </Field>
          <Field label="Thứ trong tuần">
            <Select
              value={form.dayOfWeek ?? ""}
              onChange={(e) =>
                setForm((p) => ({
                  ...p,
                  dayOfWeek: e.target.value === "" ? null : Number(e.target.value),
                }))
              }
            >
              <option value="">Mọi ngày (không cụ thể)</option>
              {Object.entries(DAY_OF_WEEK_LABEL).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Select>
          </Field>
          <Field label="Giờ lễ" required>
            <Input
              type="time"
              value={form.massTime}
              onChange={(e) => setForm((p) => ({ ...p, massTime: e.target.value }))}
            />
          </Field>
          <Field label="Nhãn (vd: Lễ thiếu nhi)">
            <Input
              value={form.label ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, label: e.target.value }))}
            />
          </Field>
          <Field label="Ghi chú">
            <Input
              value={form.note ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, note: e.target.value }))}
            />
          </Field>
        </div>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xoá giờ lễ"
        message="Bạn chắc chắn muốn xoá giờ lễ này?"
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}
