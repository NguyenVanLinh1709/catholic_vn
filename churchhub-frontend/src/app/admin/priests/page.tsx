"use client";

import { useEffect, useState } from "react";
import { Pencil, Plus, Trash2, User } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, Select } from "@/components/Field";
import { Modal, ConfirmDialog } from "@/components/Modal";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import { uploadImage } from "@/lib/upload";
import { PRIEST_ROLE_LABEL } from "@/lib/format";
import type { Priest, PriestRole } from "@/lib/types";
import type { PriestInput } from "@/lib/api";
import { listMyPriests, createMyPriest, editPriest, removePriest } from "../actions";

const EMPTY: PriestInput = { fullName: "", role: "PASTOR", phone: "", photoUrl: "", orderIndex: 0 };

export default function AdminPriestsPage() {
  const toast = useToast();
  const [loading, setLoading] = useState(true);
  const [priests, setPriests] = useState<Priest[]>([]);

  const [editing, setEditing] = useState<Priest | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState<PriestInput>(EMPTY);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);

  const [deleteTarget, setDeleteTarget] = useState<Priest | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function reload() {
    const res = await listMyPriests();
    if (res.ok) setPriests(res.data);
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

  function openEdit(priest: Priest) {
    setEditing(priest);
    setForm({
      fullName: priest.fullName,
      role: priest.role,
      phone: priest.phone ?? "",
      photoUrl: priest.photoUrl ?? "",
      orderIndex: priest.orderIndex,
    });
    setModalOpen(true);
  }

  async function onPickPhoto(file: File | undefined) {
    if (!file) return;
    setUploading(true);
    try {
      const url = await uploadImage(file);
      setForm((p) => ({ ...p, photoUrl: url }));
      toast.success("Đã tải ảnh lên");
    } catch {
      toast.error("Tải ảnh thất bại");
    } finally {
      setUploading(false);
    }
  }

  async function save() {
    if (!form.fullName.trim()) {
      toast.error("Vui lòng nhập họ tên");
      return;
    }
    setSaving(true);
    const payload: PriestInput = {
      ...form,
      phone: form.phone?.trim() || null,
      photoUrl: form.photoUrl?.trim() || null,
    };
    const res = editing ? await editPriest(editing.id, payload) : await createMyPriest(payload);
    setSaving(false);
    if (res.ok) {
      toast.success(editing ? "Đã cập nhật" : "Đã thêm linh mục");
      setModalOpen(false);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    const res = await removePriest(deleteTarget.id);
    setDeleting(false);
    if (res.ok) {
      toast.success("Đã xoá");
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Linh mục</h1>
        <Button onClick={openCreate}>
          <Plus className="h-4 w-4" />
          Thêm
        </Button>
      </div>

      {loading ? (
        <LoadingBlock />
      ) : priests.length === 0 ? (
        <EmptyState
          title="Chưa có linh mục"
          description="Thêm cha xứ, cha phó cho giáo xứ của bạn."
          action={<Button onClick={openCreate}>Thêm linh mục</Button>}
        />
      ) : (
        <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 text-xs uppercase text-gray-500 dark:bg-gray-800/50 dark:text-gray-400">
              <tr>
                <th className="px-4 py-3">Họ tên</th>
                <th className="px-4 py-3">Chức vụ</th>
                <th className="px-4 py-3">Điện thoại</th>
                <th className="px-4 py-3">Thứ tự</th>
                <th className="px-4 py-3 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {[...priests]
                .sort((a, b) => a.orderIndex - b.orderIndex)
                .map((p) => (
                  <tr key={p.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {p.photoUrl ? (
                          // eslint-disable-next-line @next/next/no-img-element
                          <img src={p.photoUrl} alt="" className="h-9 w-9 rounded-full object-cover" />
                        ) : (
                          <span className="flex h-9 w-9 items-center justify-center rounded-full bg-gray-100 dark:bg-gray-800">
                            <User className="h-4 w-4 text-gray-400 dark:text-gray-500" />
                          </span>
                        )}
                        <span className="font-medium text-gray-900 dark:text-gray-100">{p.fullName}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{PRIEST_ROLE_LABEL[p.role]}</td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{p.phone ?? "—"}</td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{p.orderIndex}</td>
                    <td className="px-4 py-3">
                      <div className="flex justify-end gap-1">
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
      )}

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? "Sửa linh mục" : "Thêm linh mục"}
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
          <Field label="Họ tên" required>
            <Input
              value={form.fullName}
              onChange={(e) => setForm((p) => ({ ...p, fullName: e.target.value }))}
            />
          </Field>
          <Field label="Chức vụ" required>
            <Select
              value={form.role}
              onChange={(e) => setForm((p) => ({ ...p, role: e.target.value as PriestRole }))}
            >
              <option value="PASTOR">{PRIEST_ROLE_LABEL.PASTOR}</option>
              <option value="PAROCHIAL_VICAR">{PRIEST_ROLE_LABEL.PAROCHIAL_VICAR}</option>
            </Select>
          </Field>
          <Field label="Điện thoại">
            <Input
              value={form.phone ?? ""}
              onChange={(e) => setForm((p) => ({ ...p, phone: e.target.value }))}
            />
          </Field>
          <Field label="Thứ tự hiển thị">
            <Input
              type="number"
              value={form.orderIndex ?? 0}
              onChange={(e) => setForm((p) => ({ ...p, orderIndex: Number(e.target.value) }))}
            />
          </Field>
          <Field label="Ảnh">
            <div className="flex items-center gap-3">
              {form.photoUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={form.photoUrl} alt="" className="h-14 w-14 rounded-full object-cover" />
              ) : (
                <span className="flex h-14 w-14 items-center justify-center rounded-full bg-gray-100 dark:bg-gray-800">
                  <User className="h-6 w-6 text-gray-400 dark:text-gray-500" />
                </span>
              )}
              <input
                type="file"
                accept="image/*"
                onChange={(e) => onPickPhoto(e.target.files?.[0])}
                disabled={uploading}
                className="text-sm text-gray-600 dark:text-gray-400 file:mr-3 file:rounded-md file:border-0 file:bg-brand-50 file:px-3 file:py-1.5 file:text-sm file:font-medium file:text-brand-700"
              />
            </div>
          </Field>
        </div>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Xoá linh mục"
        message={`Bạn chắc chắn muốn xoá “${deleteTarget?.fullName}”?`}
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}
