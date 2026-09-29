// DOM helpers shared by the shell and the host's pages. Nothing here touches the
// document at import time, so the package loads (and its entry imports) without a DOM.

export const $ = (id: string): HTMLElement => document.getElementById(id) as HTMLElement;

/** Build a DOM node quickly. */
export function el<K extends keyof HTMLElementTagNameMap>(tag: K, cls?: string, parent?: Element | null): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (parent) parent.appendChild(e);
  return e;
}

/** Toast notification in the host's `#toasts` container. kind: "" | "ok" | "err". */
export function toast(msg: string, kind = "", ms = 4200): void {
  const t = el("div", "toast " + kind, $("toasts"));
  t.textContent = msg;
  setTimeout(() => { t.style.transition = "opacity .4s,transform .4s"; t.style.opacity = "0"; t.style.transform = "translateY(10px)"; setTimeout(() => t.remove(), 420); }, ms);
}

const injectedStyleIds = new Set<string>();

/** Append a `<style>` block to `<head>` exactly once per `id`, whatever the call order or count, for chrome built
 * entirely with createElement (the palette, the panel frame). Rules should reference the host's `:root` design tokens
 * (`var(--card)`, `var(--hairline)`, ...) so the chrome follows the theme; those custom properties cascade from
 * wherever the tag lands. */
export function injectStyles(id: string, css: string): void {
  if (injectedStyleIds.has(id)) return;
  injectedStyleIds.add(id);
  const style = document.createElement("style");
  style.id = id;
  style.textContent = css;
  document.head.appendChild(style);
}
