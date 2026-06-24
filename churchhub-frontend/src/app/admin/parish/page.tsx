"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/Button";
import { Field, Input, Textarea } from "@/components/Field";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import type { Parish } from "@/lib/types";
import type { ParishInput } from "@/lib/api";
import { getMyParish, updateMyParish } from "../actions";

export default function AdminParishPage() {
  const toast = useToast();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [parish, setParish] = useState<Parish | null>(null);

  const [form, setForm] = useState<ParishInput>({ name: "" });

  useEffect(() => {
    let active = true;
    getMyParish().then((res) => {
      if (!active) return;
      if (res.ok && res.data) {
        const p = res.data;
        setParish(p);
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
      toast.error("Tên nhà thờ không được để trống");
      return;
    }
    setSaving(true);
    const res = await updateMyParish({
      ...form,
      address: emptyToNull(form.address),
      phone: emptyToNull(form.phone),
      description: emptyToNull(form.description),
    });
    setSaving(false);
    if (res.ok) {
      setParish(res.data);
      toast.success("Đã lưu thông tin nhà thờ");
    } else {
      toast.error(res.message);
    }
  }

  if (loading) return <LoadingBlock />;
  if (!parish) {
    return (
      <EmptyState
        title="Không tải được thông tin"
        description="Tài khoản của bạn có thể chưa được gắn với giáo xứ nào."
      />
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Thông tin nhà thờ</h1>

      <div className="space-y-4 rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-6">
        <Field label="Tên nhà thờ" required>
          <Input value={form.name} onChange={(e) => set("name", e.target.value)} />
        </Field>
        <Field label="Slug (đường dẫn)">
          <Input
            value={form.slug ?? ""}
            onChange={(e) => set("slug", e.target.value)}
            placeholder="tự sinh từ tên nếu để trống"
          />
        </Field>
        <Field label="Địa chỉ">
          <Input value={form.address ?? ""} onChange={(e) => set("address", e.target.value)} />
        </Field>
        <Field label="Điện thoại">
          <Input value={form.phone ?? ""} onChange={(e) => set("phone", e.target.value)} />
        </Field>
        <div className="grid grid-cols-2 gap-4">
          <Field label="Vĩ độ (latitude)">
            <Input
              type="number"
              step="any"
              value={form.latitude ?? ""}
              onChange={(e) => set("latitude", e.target.value === "" ? null : Number(e.target.value))}
            />
          </Field>
          <Field label="Kinh độ (longitude)">
            <Input
              type="number"
              step="any"
              value={form.longitude ?? ""}
              onChange={(e) =>
                set("longitude", e.target.value === "" ? null : Number(e.target.value))
              }
            />
          </Field>
        </div>
        <Field label="Mô tả">
          <Textarea value={form.description ?? ""} onChange={(e) => set("description", e.target.value)} />
        </Field>
        <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
          <input
            type="checkbox"
            checked={form.isActive ?? true}
            onChange={(e) => set("isActive", e.target.checked)}
            className="h-4 w-4 rounded border-gray-300"
          />
          Đang hoạt động (hiển thị công khai)
        </label>

        <div className="flex justify-end">
          <Button onClick={save} loading={saving}>
            Lưu thay đổi
          </Button>
        </div>
      </div>
    </div>
  );
}

function emptyToNull(v: string | null | undefined): string | null {
  return v && v.trim() ? v.trim() : null;
}
