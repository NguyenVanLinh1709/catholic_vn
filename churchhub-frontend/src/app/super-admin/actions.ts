"use server";

import { revalidatePath } from "next/cache";
import { runAction, type ActionResult } from "@/lib/action-result";
import * as api from "@/lib/api";
import type { AdminUser, MassSchedule, Page, Parish, ParishDetail } from "@/lib/types";

// --- Parishes -------------------------------------------------------------

export async function listAllParishes(
  search: string | undefined,
  page: number,
): Promise<ActionResult<Page<Parish>>> {
  return runAction(() => api.listParishes({ search, page, size: 12 }));
}

export async function createParishAction(input: api.ParishInput): Promise<ActionResult<ParishDetail>> {
  return runAction(async () => {
    const result = await api.createParish(input);
    revalidatePath("/super-admin/parishes");
    return result;
  });
}

export async function updateParishAction(
  id: number,
  input: api.ParishInput,
): Promise<ActionResult<Parish>> {
  return runAction(async () => {
    const result = await api.updateParish(id, input);
    revalidatePath("/super-admin/parishes");
    return result;
  });
}

export async function deleteParishAction(id: number): Promise<ActionResult> {
  return runAction(async () => {
    await api.deleteParish(id);
    revalidatePath("/super-admin/parishes");
  });
}

// --- Mass schedules (managed from the parish popup) -----------------------

export async function listParishMassSchedules(
  parishId: number,
): Promise<ActionResult<MassSchedule[]>> {
  return runAction(() => api.listMassSchedules(parishId));
}

export async function createParishMassSchedule(
  parishId: number,
  input: api.MassScheduleInput,
): Promise<ActionResult<MassSchedule>> {
  return runAction(() => api.createMassSchedule(parishId, input));
}

export async function deleteParishMassSchedule(id: number): Promise<ActionResult> {
  return runAction(() => api.deleteMassSchedule(id));
}

// --- Parish admins (managed from the parish popup) ------------------------

/** All PARISH_ADMIN accounts, used to pick a parish's administrators. */
export async function listAdminAccounts(): Promise<ActionResult<AdminUser[]>> {
  return runAction(async () => {
    const page = await api.listUsers(0, 1000);
    return page.content.filter((u) => u.role === "PARISH_ADMIN");
  });
}

export async function setParishAdminsAction(
  parishId: number,
  userIds: number[],
): Promise<ActionResult<AdminUser[]>> {
  return runAction(async () => {
    const result = await api.setParishAdmins(parishId, userIds);
    revalidatePath("/super-admin/parishes");
    return result;
  });
}

// --- Users ----------------------------------------------------------------

export async function listUsersAction(page: number): Promise<ActionResult<Page<AdminUser>>> {
  return runAction(() => api.listUsers(page, 20));
}

/** Parishes for the assignment dropdown when creating a PARISH_ADMIN. */
export async function listParishOptions(): Promise<ActionResult<Parish[]>> {
  return runAction(async () => {
    const page = await api.listParishes({ size: 1000 });
    return page.content;
  });
}

export async function createUserAction(input: api.CreateUserInput): Promise<ActionResult<AdminUser>> {
  return runAction(async () => {
    const result = await api.createUser(input);
    revalidatePath("/super-admin/users");
    return result;
  });
}

export async function updateUserAction(
  id: number,
  input: api.UpdateUserInput,
): Promise<ActionResult<AdminUser>> {
  return runAction(async () => {
    const result = await api.updateUser(id, input);
    revalidatePath("/super-admin/users");
    return result;
  });
}

export async function deleteUserAction(id: number): Promise<ActionResult> {
  return runAction(async () => {
    await api.deleteUser(id);
    revalidatePath("/super-admin/users");
  });
}
