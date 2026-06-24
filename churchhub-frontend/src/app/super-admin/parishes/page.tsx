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
import { formatTime } from "@/lib/format";
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
      toast.error("Vui lòng nhập tên nhà thờ");
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
      toast.error(`Đã lưu nhà thờ nhưng có lỗi: ${problems}`);
    } else {
      toast.success(editing ? "Đã cập nhật" : "Đã tạo nhà thờ");
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
      toast.success("Đã xoá nhà thờ");
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Nhà thờ</h1>
        <Button onClick={openCreate}>
          <Plus className="h-4 w-4" />
          Thêm nhà thờ
        </Button>
      </div>

      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400 dark:text-gray-500" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && reload(0, search)}
            placeholder="Tìm theo tên…"
            className="pl-9"
          />
        </div>
        <Button variant="secondary" onClick={() => reload(0, search)}>
          Tìm
        </Button>
      </div>

      {loading ? (
        <LoadingBlock />
      ) : items.length === 0 ? (
        <EmptyState title="Chưa có nhà thờ" action={<Button onClick={openCreate}>Thêm nhà thờ</Button>} />
      ) : (
        <>
          <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50 text-xs uppercase text-gray-500 dark:bg-gray-800/50 dark:text-gray-400">
                <tr>
                  <th className="px-4 py-3">Tên</th>
                  <th className="px-4 py-3">Slug</th>
                  <th className="px-4 py-3">Trạng thái</th>
                  <th className="px-4 py-3 text-right">Thao tác</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {items.map((p) => (
                  <tr key={p.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50">
                    <td className="px-4 py-3 font-medium text-gray-900 dark:text-gray-100">{p.name}</td>
                    <td className="px-4 py-3 text-gray-500 dark:text-gray-400">{p.slug}</td>
                    <td className="px-4 py-3">
                      {p.active ? <Badge color="green">Hoạt động</Badge> : <Badge>Ẩn</Badge>}
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
        title={editing ? "Sửa nhà thờ" : "Thêm nhà thờ"}
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
          <Field label="Tên nhà thờ" required>
            <Input value={form.name} onChange={(e) => setForm((p) => ({ ...p, name: e.target.value }))} />
          </Field>
          <Field label="Địa chỉ">
            <Input
              value={form.address ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, address: e.target.value }))}
            />
          </Field>
          <Field label="Điện thoại">
            <Input
              value={form.phone ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, phone: e.target.value }))}
            />
          </Field>
          <Field label="Mô tả">
            <Textarea
              value={form.description ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, description: e.target.value }))}
            />
          </Field>

          <TimeSlots
            label="Giờ lễ trong tuần"
            times={weekdayTimes}
            onChange={setWeekdayTimes}
          />
          <TimeSlots
            label="Giờ lễ cuối tuần"
            times={weekendTimes}
            onChange={setWeekendTimes}
          />

          {editing && (
            <Field label="Người quản trị giáo xứ">
              {adminPool.length === 0 ? (
                <p className="text-sm text-gray-500 dark:text-gray-400">
                  Chưa có tài khoản quản trị giáo xứ nào. Tạo ở mục “Tài khoản”.
                </p>
              ) : (
                <div className="max-h-44 space-y-1 overflow-y-auto rounded-lg border border-gray-200 p-2">
                  {adminPool.map((u) => {
                    const checked = selectedAdminIds.includes(u.id);
                    const elsewhere = u.parishId !== null && u.parishId !== editing.id;
                    return (
                      <label
                        key={u.id}
                        className="flex items-center gap-2 rounded px-1 py-1 text-sm hover:bg-gray-50 dark:hover:bg-gray-800/50"
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
                          className="h-4 w-4 rounded border-gray-300"
                        />
                        <span className="text-gray-900 dark:text-gray-100">{u.fullName || u.email}</span>
                        <span className="text-gray-400 dark:text-gray-500">{u.email}</span>
                        {elsewhere && !checked && (
                          <span className="ml-auto text-xs text-amber-600">đang ở nhà thờ khác</span>
                        )}
                      </label>
                    );
                  })}
                </div>
              )}
            </Field>
          )}

          <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
            <input
              type="checkbox"
              checked={form.isActive ?? true}
              onChange={(e) => setForm((p) => ({ ...p, isActive: e.target.checked }))}
              className="h-4 w-4 rounded border-gray-300"
            />
            Đang hoạt động
          </label>
        </div>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xoá nhà thờ"
        message={`Xoá “${deleteTarget?.name}”? Toàn bộ linh mục, giờ lễ và bài viết liên quan cũng sẽ bị xoá.`}
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
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
  return (
    <Field label={label}>
      <div className="space-y-2">
        {times.map((time, i) => (
          <div key={i} className="flex items-center gap-2">
            <Clock className="h-4 w-4 shrink-0 text-brand-500" />
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
            >
              <X className="h-4 w-4 text-red-500" />
            </Button>
          </div>
        ))}
        <Button variant="secondary" size="sm" onClick={() => onChange([...times, "07:00"])}>
          <Plus className="h-4 w-4" />
          Thêm khung giờ
        </Button>
      </div>
    </Field>
  );
}
