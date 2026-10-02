// GENERATED-ADJACENT source module — part of the apps/mlx-bun/src/web/browser/*
// split. Built into apps/mlx-bun/dist/web/app.js by
// scripts/build-web.ts.
//
// Thin JSON-fetch helper + the SSE job-stream wrapper used by the
// quantize/finetune/dataset controllers. Behavior-identical port of the
// original inline <script> in app.html (api()/jobStream()).

import type { ApiEnvelope } from "./protocol";

export type ApiOpts = (Omit<RequestInit, "body"> & { body?: unknown }) | undefined;

/** Fetch JSON with graceful error handling. Throws only on transport
 *  failure (network error) — HTTP-level failure is reflected in the
 *  returned envelope, never a throw, so callers can always `await api(...)`
 *  without try/catch for the common case. */
export async function api<T extends ApiEnvelope = ApiEnvelope>(path: string, opts?: ApiOpts): Promise<T> {
  const { body, ...rest } = opts || {};
  const init: RequestInit = {
    headers: { "content-type": "application/json" },
    ...rest,
    ...(body !== undefined
      ? { body: typeof body === "string" ? body : JSON.stringify(body) }
      : {}),
  };
  const r = await fetch(path, init);
  const text = await r.text();
  let data: ApiEnvelope;
  try { data = text ? JSON.parse(text) : {}; } catch { data = { ok: false, error: text.slice(0, 400) || ("HTTP " + r.status) }; }
  // OpenAI-envelope errors are {error:{message,…}} — unwrap to a string so
  // callers can concatenate without printing "[object Object]"
  // (`02d723a:docs/archive/planning/web-ui-pass-plan.md` #4).
  if (data && data.error && typeof data.error === "object") {
    const errObj = data.error as { message?: string };
    data.error = errObj.message || JSON.stringify(errObj).slice(0, 400);
  }
  if (!r.ok && data.ok === undefined) data = { ok: false, error: (data.error as string) || data.message || ("HTTP " + r.status) };
  return data as T;
}
