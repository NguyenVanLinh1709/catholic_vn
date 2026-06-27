"use server";

import { revalidatePath } from "next/cache";
import { getCurrentUser } from "@/lib/auth";
import { runAction, type ActionResult } from "@/lib/action-result";
import { ApiError } from "@/lib/api";
import * as api from "@/lib/api";
import { getLocale } from "@/lib/i18n/server";
import { translate } from "@/lib/i18n/messages";
import type {
  Article,
  ArticleSummary,
  MassSchedule,
  Page,
  Parish,
  Priest,
} from "@/lib/types";

/** Resolves the PARISH_ADMIN's own parishId, or throws 403. */
function requireParishId(): number {
  const user = getCurrentUser();
  if (!user) throw new ApiError(401, translate(getLocale(), "error.sessionExpired"));
  if (user.parishId === null) {
    throw new ApiError(403, translate(getLocale(), "error.noParish"));
  }
  return user.parishId;
}

// --- Parish ---------------------------------------------------------------

export async function getMyParish(): Promise<ActionResult<Parish | null>> {
  return runAction(() => api.getParishById(requireParishId()));
}

export async function updateMyParish(input: api.ParishInput): Promise<ActionResult<Parish>> {
  return runAction(async () => {
    const result = await api.updateParish(requireParishId(), input);
    revalidatePath("/admin/parish");
    return result;
  });
}

// --- Priests --------------------------------------------------------------

export async function listMyPriests(): Promise<ActionResult<Priest[]>> {
  return runAction(() => api.listPriests(requireParishId()));
}

export async function createMyPriest(input: api.PriestInput): Promise<ActionResult<Priest>> {
  return runAction(async () => {
    const result = await api.createPriest(requireParishId(), input);
    revalidatePath("/admin/priests");
    return result;
  });
}

export async function editPriest(id: number, input: api.PriestInput): Promise<ActionResult<Priest>> {
  return runAction(async () => {
    const result = await api.updatePriest(id, input);
    revalidatePath("/admin/priests");
    return result;
  });
}

export async function removePriest(id: number): Promise<ActionResult> {
  return runAction(async () => {
    await api.deletePriest(id);
    revalidatePath("/admin/priests");
  });
}

// --- Mass schedules -------------------------------------------------------

export async function listMyMass(): Promise<ActionResult<MassSchedule[]>> {
  return runAction(() => api.listMassSchedules(requireParishId()));
}

export async function createMyMass(
  input: api.MassScheduleInput,
): Promise<ActionResult<MassSchedule>> {
  return runAction(async () => {
    const result = await api.createMassSchedule(requireParishId(), input);
    revalidatePath("/admin/mass-schedules");
    return result;
  });
}

export async function editMass(
  id: number,
  input: api.MassScheduleInput,
): Promise<ActionResult<MassSchedule>> {
  return runAction(async () => {
    const result = await api.updateMassSchedule(id, input);
    revalidatePath("/admin/mass-schedules");
    return result;
  });
}

export async function removeMass(id: number): Promise<ActionResult> {
  return runAction(async () => {
    await api.deleteMassSchedule(id);
    revalidatePath("/admin/mass-schedules");
  });
}

// --- Articles -------------------------------------------------------------

export async function listMyArticles(page = 0): Promise<ActionResult<Page<ArticleSummary>>> {
  return runAction(() => api.listParishArticles(requireParishId(), page, 20));
}

export async function getMyArticle(id: number): Promise<ActionResult<Article>> {
  return runAction(() => api.getArticle(id, true));
}

export async function createMyArticle(input: api.ArticleInput): Promise<ActionResult<Article>> {
  return runAction(async () => {
    const result = await api.createArticle(requireParishId(), input);
    revalidatePath("/admin/articles");
    return result;
  });
}

export async function editArticle(id: number, input: api.ArticleInput): Promise<ActionResult<Article>> {
  return runAction(async () => {
    const result = await api.updateArticle(id, input);
    revalidatePath("/admin/articles");
    return result;
  });
}

export async function removeArticle(id: number): Promise<ActionResult> {
  return runAction(async () => {
    await api.deleteArticle(id);
    revalidatePath("/admin/articles");
  });
}
