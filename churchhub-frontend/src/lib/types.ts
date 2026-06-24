// Types mirroring the Spring Boot backend DTOs.

export type Role = "SUPER_ADMIN" | "PARISH_ADMIN";
export type PriestRole = "PASTOR" | "PAROCHIAL_VICAR";
export type DayType = "WEEKDAY" | "SUNDAY" | "SPECIAL";
export type ArticleStatus = "DRAFT" | "PUBLISHED";

export interface Parish {
  id: number;
  name: string;
  slug: string;
  address: string | null;
  phone: string | null;
  latitude: number | null;
  longitude: number | null;
  description: string | null;
  active: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface Priest {
  id: number;
  parishId: number;
  fullName: string;
  role: PriestRole;
  phone: string | null;
  photoUrl: string | null;
  orderIndex: number;
}

export interface MassSchedule {
  id: number;
  parishId: number;
  dayType: DayType;
  dayOfWeek: number | null;
  massTime: string; // "HH:mm"
  label: string | null;
  note: string | null;
}

export interface Article {
  id: number;
  parishId: number;
  authorId: number | null;
  title: string;
  slug: string;
  content: string | null;
  coverUrl: string | null;
  status: ArticleStatus;
  publishedAt: string | null;
  createdAt?: string;
  updatedAt?: string;
}

/** Lightweight article projection returned by list endpoints. */
export interface ArticleSummary {
  id: number;
  parishId: number;
  title: string;
  slug: string;
  coverUrl: string | null;
  status: ArticleStatus;
  publishedAt: string | null;
}

/** Detail payload from GET /api/parishes/{slug}. */
export interface ParishDetail {
  parish: Parish;
  priests: Priest[];
  massSchedules: MassSchedule[];
}

export interface AdminUser {
  id: number;
  email: string;
  fullName: string | null;
  role: Role;
  parishId: number | null;
  enabled: boolean;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Paged response shape returned by the backend's PageResponse<T>.
 * (Fields: content, page, size, totalElements, totalPages, last.)
 */
export interface Page<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  last: boolean;
}

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
}

/** Decoded JWT access-token claims used purely for UI routing. */
export interface SessionUser {
  email: string;
  role: Role;
  parishId: number | null;
}
