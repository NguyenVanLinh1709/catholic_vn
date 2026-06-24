import { ApiError } from "./api";

/** Discriminated result returned by server actions to client components. */
export type ActionResult<T = void> =
  | { ok: true; data: T }
  | { ok: false; status: number; message: string };

/** Wraps a server-side operation, converting ApiError into a serializable result. */
export async function runAction<T>(fn: () => Promise<T>): Promise<ActionResult<T>> {
  try {
    const data = await fn();
    return { ok: true, data };
  } catch (err) {
    if (err instanceof ApiError) {
      return { ok: false, status: err.status, message: err.message };
    }
    return { ok: false, status: 500, message: "Đã xảy ra lỗi không mong muốn" };
  }
}
