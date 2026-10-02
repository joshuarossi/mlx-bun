import type { ApiEnvelope, JobEvent, JobStreamHandlers, PanelConnection } from "../protocol";
type ApiOpts = Omit<RequestInit, "body"> & { body?: unknown };
export const esc = (s: unknown): string => String(s ?? "").replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string,string>)[c]!);
export const num = (n: number | null | undefined): string => n == null ? "—" : Math.round(n).toLocaleString();
export function renderSteps(container: HTMLElement, names: string[], cur: number): void {
 container.innerHTML = names.map((name, i) => '<span class="s ' + (i === cur ? "cur" : i < cur ? "done" : "") + '"><span class="n">' + (i+1) + '</span>' + esc(name) + '</span>' + (i < names.length-1 ? '<span class="arrow">&#8594;</span>' : '')).join("");
}
export function panelTools(root: ShadowRoot, connection: () => PanelConnection) {
 const $ = (id: string): HTMLElement => { const node = root.getElementById(id); if (!node) throw new Error(`Missing panel element ${id}`); return node; };
 const url = (path: string): string => {
   const base = new URL(connection().apiBase, location.href);
   base.pathname = base.pathname.replace(/\/api\/[^/]+\/?$/, "") + path;
   base.search = ""; base.hash = "";
   return base.href;
 };
 const toast = (message: string, kind: "ok" | "err" = "ok") => { if (connection().ui?.notify) connection().ui!.notify!(message, kind); else { const out = $("panel-message"); out.textContent = message; out.dataset.kind = kind; } };
 const pushToHub = (container: HTMLElement, source: { kind: "quantize" | "finetune" | "dataset"; job_id?: string; source_path?: string }) => {
   const publish = connection().ui?.publish;
   if (publish) void publish(container, source); else toast("This host has no publishing interface.", "err");
 };
async function api<T extends ApiEnvelope = ApiEnvelope>(path: string, opts?: ApiOpts): Promise<T> {
  const { body, ...rest } = opts || {};
  const init: RequestInit = {
    headers: { "content-type": "application/json" },
    ...rest,
    ...(body !== undefined
      ? { body: typeof body === "string" ? body : JSON.stringify(body) }
      : {}),
  };
  const r = await fetch(url(path), init);
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

/**
 * Wraps an EventSource over /api/jobs/:id/stream and dispatches typed
 * events. Server -> client line protocol (JSON per `data:` line) — see
 * JobEvent in ./protocol.ts (pointer comment there to the server-side
 * source). Returns the EventSource so callers can .close().
 */
function jobStream(jobId: string, handlers: JobStreamHandlers): EventSource {
  const es = new EventSource(url("/api/jobs/" + encodeURIComponent(jobId) + "/stream"));
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

 return { $, api, jobStream, toast, pushToHub };
}
