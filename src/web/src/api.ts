// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// Thin JSON-fetch helper + the SSE job-stream wrapper used by the
// quantize/finetune/dataset controllers. Behavior-identical port of the
// original inline <script> in app.html (api()/jobStream()).

import type { ApiEnvelope, JobEvent, JobStreamHandlers } from "./protocol";

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
  // (web-ui-pass-plan.md #4).
  if (data && data.error && typeof data.error === "object") {
    const errObj = data.error as { message?: string };
    data.error = errObj.message || JSON.stringify(errObj).slice(0, 400);
  }
  if (!r.ok && data.ok === undefined) data = { ok: false, error: (data.error as string) || data.message || ("HTTP " + r.status) };
  return data as T;
}

/**
 * Wraps an EventSource over /api/jobs/:id/stream and dispatches typed
 * events. Server -> client line protocol (JSON per `data:` line) — see
 * JobEvent in ./protocol.ts (pointer comment there to the server-side
 * source). Returns the EventSource so callers can .close().
 */
export function jobStream(jobId: string, handlers: JobStreamHandlers): EventSource {
  const es = new EventSource("/api/jobs/" + encodeURIComponent(jobId) + "/stream");
  es.onmessage = (ev: MessageEvent) => {
    let e: JobEvent;
    try { e = JSON.parse(ev.data); } catch { return; }
    const fn = handlers[e.type] as ((e: JobEvent) => void) | undefined;
    if (fn) fn(e);
  };
  es.addEventListener("end", () => es.close());
  es.onerror = () => { if (handlers.error) handlers.error(); };
  return es;
}
