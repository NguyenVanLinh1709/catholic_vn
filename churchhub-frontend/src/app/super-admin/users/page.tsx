"use client";

import { useEffect, useState } from "react";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/Button";
import { Field, Input, PasswordInput, Select } from "@/components/Field";
import { Modal, ConfirmDialog } from "@/components/Modal";
import { Badge, LoadingBlock, EmptyState } from "@/components/Feedback";
import { Pagination } from "@/components/Pagination";
import { useToast } from "@/components/Toast";
import { useI18n } from "@/lib/i18n/provider";
import type { AdminUser, Parish, Role } from "@/lib/types";
import {
  listUsersAction,
  listParishOptions,
  createUserAction,
  updateUserAction,
  deleteUserAction,
} from "../actions";

interface FormState {
  email: string;
  password: string;
  fullName: string;
  role: Role;
  parishId: number | null;
  enabled: boolean;
}

const EMPTY: FormState = {
  email: "",
  password: "",
  fullName: "",
  role: "PARISH_ADMIN",
  parishId: null,
  enabled: true,
};

export default function SuperUsersPage() {
  const toast = useToast();
  const { t } = useI18n();
  const [loading, setLoading] = useState(true);
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [parishes, setParishes] = useState<Parish[]>([]);

  const [editing, setEditing] = useState<AdminUser | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState<FormState>(EMPTY);
  const [saving, setSaving] = useState(false);

  const [deleteTarget, setDeleteTarget] = useState<AdminUser | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function reload(p = page) {
    setLoading(true);
    const res = await listUsersAction(p);
    if (res.ok) {
      setUsers(res.data.content);
      setTotalPages(res.data.totalPages);
      setPage(res.data.page);
    } else {
      toast.error(res.message);
    }
    setLoading(false);
  }

  useEffect(() => {
    void reload(0);
    listParishOptions().then((res) => {
      if (res.ok) setParishes(res.data);
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function parishName(id: number | null): string {
    if (id === null) return "—";
    return parishes.find((p) => p.id === id)?.name ?? `#${id}`;
  }

  function openCreate() {
    setEditing(null);
    setForm(EMPTY);
    setModalOpen(true);
  }

  function openEdit(u: AdminUser) {
    setEditing(u);
    setForm({
      email: u.email,
      password: "",
      fullName: u.fullName ?? "",
      role: u.role,
      parishId: u.parishId,
      enabled: u.enabled,
    });
    setModalOpen(true);
  }

  async function save() {
    if (!editing && (!form.email.trim() || !form.password)) {
      toast.error(t("superUsers.needCredentials"));
      return;
    }
    if (form.role === "PARISH_ADMIN" && form.parishId === null) {
      toast.error(t("superUsers.parishRequired"));
      return;
    }

    setSaving(true);
    const parishId = form.role === "PARISH_ADMIN" ? form.parishId : null;
    const res = editing
      ? await updateUserAction(editing.id, {
          fullName: form.fullName.trim() || null,
          role: form.role,
          parishId,
          enabled: form.enabled,
          ...(form.password ? { password: form.password } : {}),
        })
      : await createUserAction({
          email: form.email.trim(),
          password: form.password,
          fullName: form.fullName.trim() || null,
          role: form.role,
          parishId,
        });
    setSaving(false);
    if (res.ok) {
      toast.success(editing ? t("superUsers.updated") : t("superUsers.created"));
      setModalOpen(false);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  // Only parish admins are managed here; the lone bootstrap super admin is hidden.
  const visibleUsers = users.filter((u) => u.role !== "SUPER_ADMIN");

  async function confirmDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    const res = await deleteUserAction(deleteTarget.id);
    setDeleting(false);
    if (res.ok) {
      toast.success(t("superUsers.deleted"));
      setDeleteTarget(null);
      void reload();
    } else {
      toast.error(res.message);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t("superUsers.title")}</h1>
        <Button onClick={openCreate}>
          <Plus className="h-4 w-4" />
          {t("superUsers.create")}
        </Button>
      </div>

      {loading ? (
        <LoadingBlock label={t("common.loading")} />
      ) : visibleUsers.length === 0 ? (
        <EmptyState title={t("superUsers.emptyTitle")} action={<Button onClick={openCreate}>{t("superUsers.create")}</Button>} />
      ) : (
        <>
          <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50 text-xs uppercase text-gray-500 dark:bg-gray-800/50 dark:text-gray-400">
                <tr>
                  <th className="px-4 py-3">{t("superUsers.colEmail")}</th>
                  <th className="px-4 py-3">{t("superUsers.colRole")}</th>
                  <th className="px-4 py-3">{t("superUsers.colParish")}</th>
                  <th className="px-4 py-3">{t("superUsers.colStatus")}</th>
                  <th className="px-4 py-3 text-right">{t("common.actions")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                {visibleUsers.map((u) => (
                  <tr key={u.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50">
                    <td className="px-4 py-3">
                      <div className="font-medium text-gray-900 dark:text-gray-100">{u.email}</div>
                      {u.fullName && <div className="text-xs text-gray-500 dark:text-gray-400">{u.fullName}</div>}
                    </td>
                    <td className="px-4 py-3">
                      {u.role === "SUPER_ADMIN" ? (
                        <Badge color="blue">Super Admin</Badge>
                      ) : (
                        <Badge>{t("superUsers.roleParishAdmin")}</Badge>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-400">{parishName(u.parishId)}</td>
                    <td className="px-4 py-3">
                      {u.enabled ? <Badge color="green">{t("superUsers.statusOn")}</Badge> : <Badge color="amber">{t("superUsers.statusOff")}</Badge>}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex justify-end gap-1">
                        <Button variant="ghost" size="sm" onClick={() => openEdit(u)}>
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="sm" onClick={() => setDeleteTarget(u)}>
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
        title={editing ? t("superUsers.editTitle") : t("superUsers.addTitle")}
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
          <Field label={t("superUsers.fieldEmail")} required>
            <Input
              type="email"
              value={form.email}
              disabled={editing !== null}
              onChange={(e) => setForm((p) => ({ ...p, email: e.target.value }))}
            />
          </Field>
          <Field label={editing ? t("superUsers.fieldPasswordNew") : t("superUsers.fieldPassword")} required={!editing}>
            <PasswordInput
              value={form.password}
              onChange={(e) => setForm((p) => ({ ...p, password: e.target.value }))}
              placeholder={editing ? "••••••••" : ""}
            />
          </Field>
          <Field label={t("superUsers.fieldFullName")}>
            <Input
              value={form.fullName}
              onChange={(e) => setForm((p) => ({ ...p, fullName: e.target.value }))}
            />
          </Field>
          {/* Role is fixed: only one (bootstrap-managed) super admin exists, so new/edited
              accounts are always parish admins. The lone super admin shows read-only. */}
          <Field label={t("superUsers.fieldRole")} required>
            <Input
              value={form.role === "SUPER_ADMIN" ? "Super Admin" : t("superUsers.roleParishAdmin")}
              disabled
            />
          </Field>
          {form.role === "PARISH_ADMIN" && (
            <Field label={t("superUsers.fieldParish")} required>
              <Select
                value={form.parishId ?? ""}
                onChange={(e) =>
                  setForm((p) => ({
                    ...p,
                    parishId: e.target.value === "" ? null : Number(e.target.value),
                  }))
                }
              >
                <option value="">{t("superUsers.parishPlaceholder")}</option>
                {parishes.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </Select>
            </Field>
          )}
          {editing && (
            <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
              <input
                type="checkbox"
                checked={form.enabled}
                onChange={(e) => setForm((p) => ({ ...p, enabled: e.target.checked }))}
                className="h-4 w-4 rounded border-gray-300"
              />
              {t("superUsers.enabled")}
            </label>
          )}
        </div>
      </Modal>

      <ConfirmDialog
        open={deleteTarget !== null}
        title={t("superUsers.deleteTitle")}
        message={t("superUsers.deleteMessage", { email: deleteTarget?.email ?? "" })}
        loading={deleting}
        onConfirm={confirmDelete}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}
