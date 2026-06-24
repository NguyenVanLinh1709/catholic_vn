import "server-only";
import { cookies } from "next/headers";
import {
  ACCESS_COOKIE,
  REFRESH_COOKIE,
  REFRESH_MAX_AGE,
  accessCookieOptions,
  refreshCookieOptions,
} from "./cookies";
import type {
  AdminUser,
  Article,
  ArticleStatus,
  ArticleSummary,
  DayType,
  MassSchedule,
  Page,
  Parish,
  ParishDetail,
  Priest,
  PriestRole,
  Role,
  TokenResponse,
} from "./types";

/** Single error type surfaced to UI: status + a friendly message. */
export class ApiError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

function baseUrl(): string {
  const base = process.env.API_BASE_URL;
  if (!base) throw new ApiError(500, "API_BASE_URL chưa được cấu hình");
  return base.replace(/\/$/, "");
}

async function friendlyError(res: Response): Promise<string> {
  try {
    const data = (await res.json()) as { message?: string; error?: string };
    if (data?.message) return data.message;
    if (data?.error) return data.error;
  } catch {
    /* non-JSON body */
  }
  if (res.status === 401) return "Phiên đăng nhập đã hết hạn";
  if (res.status === 403) return "Bạn không có quyền thực hiện thao tác này";
  if (res.status === 404) return "Không tìm thấy dữ liệu";
  return `Yêu cầu thất bại (${res.status})`;
}

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "DELETE";
  body?: unknown;
  /** Attach the access token and auto-refresh once on 401. */
  auth?: boolean;
  /** Override caching; defaults to no-store. */
  revalidate?: number;
}

/**
 * The single server-side fetch wrapper. Every backend call goes through here.
 * - attaches the access token from the httpOnly cookie (when auth=true)
 * - on 401, calls /api/auth/refresh once, rotates cookies, and retries
 * - throws ApiError on failure
 */
export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = "GET", body, auth = false, revalidate } = options;
  const store = cookies();
  let accessToken = auth ? store.get(ACCESS_COOKIE)?.value : undefined;

  const send = (token?: string): Promise<Response> =>
    fetch(`${baseUrl()}${path}`, {
      method,
      headers: {
        ...(body !== undefined ? { "Content-Type": "application/json" } : {}),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: body !== undefined ? JSON.stringify(body) : undefined,
      ...(revalidate !== undefined
        ? { next: { revalidate } }
        : { cache: "no-store" as RequestCache }),
    });

  let res = await send(accessToken);

  if (res.status === 401 && auth) {
    const refreshed = await tryRefresh();
    if (refreshed) {
      accessToken = refreshed;
      res = await send(accessToken);
    }
  }

  if (!res.ok) throw new ApiError(res.status, await friendlyError(res));
  if (res.status === 204) return undefined as T;

  const text = await res.text();
  return (text ? (JSON.parse(text) as T) : (undefined as T));
}

/** Uses the refresh cookie to mint a new access token; rotates cookies if possible. */
async function tryRefresh(): Promise<string | null> {
  const store = cookies();
  const refreshToken = store.get(REFRESH_COOKIE)?.value;
  if (!refreshToken) return null;

  const res = await fetch(`${baseUrl()}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken }),
    cache: "no-store",
  });
  if (!res.ok) return null;

  const tokens = (await res.json()) as TokenResponse;
  try {
    store.set(ACCESS_COOKIE, tokens.accessToken, accessCookieOptions(Math.floor(tokens.expiresIn / 1000)));
    store.set(REFRESH_COOKIE, tokens.refreshToken, refreshCookieOptions(REFRESH_MAX_AGE));
  } catch {
    // RSC render cannot mutate cookies; the in-memory retry below still succeeds.
  }
  return tokens.accessToken;
}

// ---------------------------------------------------------------------------
// Request payload types
// ---------------------------------------------------------------------------

export interface ParishInput {
  name: string;
  slug?: string;
  address?: string | null;
  phone?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  description?: string | null;
  isActive?: boolean;
}

export interface PriestInput {
  fullName: string;
  role: PriestRole;
  phone?: string | null;
  photoUrl?: string | null;
  orderIndex?: number;
}

export interface MassScheduleInput {
  dayType: DayType;
  dayOfWeek?: number | null;
  massTime: string;
  label?: string | null;
  note?: string | null;
}

export interface ArticleInput {
  title: string;
  slug?: string;
  content?: string | null;
  coverUrl?: string | null;
  status?: ArticleStatus;
}

export interface CreateUserInput {
  email: string;
  password: string;
  fullName?: string | null;
  role: Role;
  parishId?: number | null;
}

export interface UpdateUserInput {
  fullName?: string | null;
  role?: Role;
  parishId?: number | null;
  enabled?: boolean;
  password?: string;
}

// ---------------------------------------------------------------------------
// Public reads
// ---------------------------------------------------------------------------

export function listParishes(params: {
  search?: string;
  page?: number;
  size?: number;
}): Promise<Page<Parish>> {
  const qs = new URLSearchParams();
  if (params.search) qs.set("name", params.search);
  qs.set("page", String(params.page ?? 0));
  qs.set("size", String(params.size ?? 12));
  return apiFetch<Page<Parish>>(`/api/parishes?${qs.toString()}`, { revalidate: 30 });
}

export function getParishDetail(slug: string): Promise<ParishDetail> {
  return apiFetch<ParishDetail>(`/api/parishes/${encodeURIComponent(slug)}`, { revalidate: 30 });
}

/**
 * The backend exposes parish detail by slug only; admins hold a parishId.
 * Resolve via the list endpoint (it returns slug + all fields).
 */
export async function getParishById(id: number): Promise<Parish | null> {
  const page = await apiFetch<Page<Parish>>(`/api/parishes?size=2000`, { auth: true });
  return page.content.find((p) => p.id === id) ?? null;
}

export function listParishArticles(
  parishId: number,
  page = 0,
  size = 10,
): Promise<Page<ArticleSummary>> {
  return apiFetch<Page<ArticleSummary>>(
    `/api/parishes/${parishId}/articles?page=${page}&size=${size}`,
    { revalidate: 15 },
  );
}

export function getArticle(id: number, auth = false): Promise<Article> {
  return apiFetch<Article>(`/api/articles/${id}`, { auth });
}

export function listPriests(parishId: number): Promise<Priest[]> {
  return apiFetch<Priest[]>(`/api/parishes/${parishId}/priests`, { revalidate: 15 });
}

export function listMassSchedules(parishId: number): Promise<MassSchedule[]> {
  return apiFetch<MassSchedule[]>(`/api/parishes/${parishId}/mass-schedules`, { revalidate: 15 });
}

// ---------------------------------------------------------------------------
// Authenticated mutations
// ---------------------------------------------------------------------------

/** Create returns the full detail payload ({ parish, priests, massSchedules }), not a flat parish. */
export function createParish(input: ParishInput): Promise<ParishDetail> {
  return apiFetch<ParishDetail>(`/api/parishes`, { method: "POST", body: input, auth: true });
}

export function updateParish(id: number, input: ParishInput): Promise<Parish> {
  return apiFetch<Parish>(`/api/parishes/${id}`, { method: "PUT", body: input, auth: true });
}

export function deleteParish(id: number): Promise<void> {
  return apiFetch<void>(`/api/parishes/${id}`, { method: "DELETE", auth: true });
}

/** PARISH_ADMIN accounts currently managing a parish. */
export function listParishAdmins(parishId: number): Promise<AdminUser[]> {
  return apiFetch<AdminUser[]>(`/api/parishes/${parishId}/admins`, { auth: true });
}

/** Replace the full set of admins for a parish (assigns listed users, unassigns the rest). */
export function setParishAdmins(parishId: number, userIds: number[]): Promise<AdminUser[]> {
  return apiFetch<AdminUser[]>(`/api/parishes/${parishId}/admins`, {
    method: "PUT",
    body: { userIds },
    auth: true,
  });
}

export function createPriest(parishId: number, input: PriestInput): Promise<Priest> {
  return apiFetch<Priest>(`/api/parishes/${parishId}/priests`, {
    method: "POST",
    body: input,
    auth: true,
  });
}

export function updatePriest(id: number, input: PriestInput): Promise<Priest> {
  return apiFetch<Priest>(`/api/priests/${id}`, { method: "PUT", body: input, auth: true });
}

export function deletePriest(id: number): Promise<void> {
  return apiFetch<void>(`/api/priests/${id}`, { method: "DELETE", auth: true });
}

export function createMassSchedule(parishId: number, input: MassScheduleInput): Promise<MassSchedule> {
  return apiFetch<MassSchedule>(`/api/parishes/${parishId}/mass-schedules`, {
    method: "POST",
    body: input,
    auth: true,
  });
}

export function updateMassSchedule(id: number, input: MassScheduleInput): Promise<MassSchedule> {
  return apiFetch<MassSchedule>(`/api/mass-schedules/${id}`, {
    method: "PUT",
    body: input,
    auth: true,
  });
}

export function deleteMassSchedule(id: number): Promise<void> {
  return apiFetch<void>(`/api/mass-schedules/${id}`, { method: "DELETE", auth: true });
}

export function createArticle(parishId: number, input: ArticleInput): Promise<Article> {
  return apiFetch<Article>(`/api/parishes/${parishId}/articles`, {
    method: "POST",
    body: input,
    auth: true,
  });
}

export function updateArticle(id: number, input: ArticleInput): Promise<Article> {
  return apiFetch<Article>(`/api/articles/${id}`, { method: "PUT", body: input, auth: true });
}

export function deleteArticle(id: number): Promise<void> {
  return apiFetch<void>(`/api/articles/${id}`, { method: "DELETE", auth: true });
}

export function listUsers(page = 0, size = 20): Promise<Page<AdminUser>> {
  return apiFetch<Page<AdminUser>>(`/api/admin/users?page=${page}&size=${size}`, { auth: true });
}

export function createUser(input: CreateUserInput): Promise<AdminUser> {
  return apiFetch<AdminUser>(`/api/admin/users`, { method: "POST", body: input, auth: true });
}

export function updateUser(id: number, input: UpdateUserInput): Promise<AdminUser> {
  return apiFetch<AdminUser>(`/api/admin/users/${id}`, { method: "PUT", body: input, auth: true });
}

export function deleteUser(id: number): Promise<void> {
  return apiFetch<void>(`/api/admin/users/${id}`, { method: "DELETE", auth: true });
}
