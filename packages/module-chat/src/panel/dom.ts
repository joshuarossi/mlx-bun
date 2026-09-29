// The small DOM and network helpers the panel's files share. A panel imports only its own files, so these are
// its own; they follow the host page's conventions (a `#toasts` container, the `.toast` classes) documented in
// the module's README.
import type { ApiEnvelope } from "../protocol";

export const $ = (id: string): HTMLElement => document.getElementById(id) as HTMLElement;

/** Build a DOM node quickly. */
export function el<K extends keyof HTMLElementTagNameMap>(tag: K, cls?: string, parent?: Element | null): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (parent) parent.appendChild(e);
  return e;
}

/** Toast notification in the host's `#toasts` container (a host without one shows none). kind: "" | "ok" | "err". */
export function toast(msg: string, kind = "", ms = 4200): void {
  const container = document.getElementById("toasts");
  if (!container) return;
  const t = el("div", "toast " + kind, container);
  t.textContent = msg;
  setTimeout(() => { t.style.transition = "opacity .4s,transform .4s"; t.style.opacity = "0"; t.style.transform = "translateY(10px)"; setTimeout(() => t.remove(), 420); }, ms);
}

const injectedStyleIds = new Set<string>();

/** Append a `<style>` block to `<head>` exactly once per `id`. */
export function injectStyles(id: string, css: string): void {
  if (injectedStyleIds.has(id)) return;
  injectedStyleIds.add(id);
  const style = document.createElement("style");
  style.id = id;
  style.textContent = css;
  document.head.appendChild(style);
}

/** A focus trap for a popover or drawer: Tab and Shift+Tab cycle within the container while `isOpen()` is true, and
 * focus returns to whatever triggered it when it closes. */
export interface FocusTrap {
  /** Call right before opening: remembers the trigger to restore focus to. */
  capture(): void;
  /** Call right after closing. */
  restore(): void;
}

export function trapFocus(container: HTMLElement, isOpen: () => boolean): FocusTrap {
  let lastFocused: HTMLElement | null = null;
  const focusables = (): HTMLElement[] => [...container.querySelectorAll(
    'a[href],button:not([disabled]),textarea,input:not([disabled]),select,[tabindex]:not([tabindex="-1"])'
  )].filter((e) => (e as HTMLElement).offsetParent !== null || e === document.activeElement) as HTMLElement[];
  container.addEventListener("keydown", (e) => {
    const ke = e as KeyboardEvent;
    if (ke.key !== "Tab" || !isOpen()) return;
    const items = focusables();
    if (!items.length) return;
    const first = items[0]!, last = items[items.length - 1]!;
    if (ke.shiftKey && document.activeElement === first) { ke.preventDefault(); last.focus(); }
    else if (!ke.shiftKey && document.activeElement === last) { ke.preventDefault(); first.focus(); }
  });
  return {
    capture() { lastFocused = document.activeElement as HTMLElement | null; },
    restore() { if (lastFocused && lastFocused.focus) lastFocused.focus(); lastFocused = null; },
  };
}

/** The page the address names among the sections the host page mounted; an empty or unknown address is the chat. */
export function currentRoute(): string {
  const route = (location.hash || "").replace(/^#\/?/, "").split("?")[0] || "";
  return [...document.querySelectorAll<HTMLElement>("section[data-route]")].some(section => section.dataset.route === route) ? route : "chat";
}

export type ApiOpts = (Omit<RequestInit, "body"> & { body?: unknown }) | undefined;

/** Fetch JSON with graceful error handling. Throws only on transport failure: an HTTP failure is reflected in the
 * returned envelope, so callers can always `await api(...)`. OpenAI-envelope errors (`{error:{message}}`) are
 * unwrapped to a plain string. */
export async function api<T extends ApiEnvelope = ApiEnvelope>(path: string, opts?: ApiOpts): Promise<T> {
  const { body, ...rest } = opts || {};
  const init: RequestInit = {
    headers: { "content-type": "application/json" },
    ...rest,
    ...(body !== undefined ? { body: typeof body === "string" ? body : JSON.stringify(body) } : {}),
  };
  const r = await fetch(path, init);
  const text = await r.text();
  let data: ApiEnvelope;
  try { data = text ? JSON.parse(text) : {}; } catch { data = { ok: false, error: text.slice(0, 400) || ("HTTP " + r.status) }; }
  if (data && data.error && typeof data.error === "object") {
    const errObj = data.error as { message?: string };
    data.error = errObj.message || JSON.stringify(errObj).slice(0, 400);
  }
  if (!r.ok && data.ok === undefined) data = { ok: false, error: (data.error as string) || data.message || ("HTTP " + r.status) };
  return data as T;
}
