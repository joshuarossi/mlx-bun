// DOM helpers panels and the shell share. Nothing touches the document at import time, so the package loads
// (and its entry imports) without a DOM; a server-side inventory can import a panel entry safely.

/** The element with the given id in the document (or the given root); the caller owns the assumption that it exists. */
export const $ = (id: string, root: Document | ShadowRoot = document): HTMLElement => root.getElementById(id) as HTMLElement;

/** Create an element with a class and optional parent. */
export function el<K extends keyof HTMLElementTagNameMap>(tag: K, cls?: string, parent?: Element | DocumentFragment | null): HTMLElementTagNameMap[K] {
  const element = document.createElement(tag);
  if (cls) element.className = cls;
  if (parent) parent.appendChild(element);
  return element;
}

export type Child = Node | string | null | undefined | false;

/** Create an element with attributes and children (`class`, `aria-*`, `data-*` and any other attribute by name). */
export function h<K extends keyof HTMLElementTagNameMap>(tag: K, attributes: Readonly<Record<string, string | number | boolean | undefined>> = {}, ...children: Child[]): HTMLElementTagNameMap[K] {
  const element = document.createElement(tag);
  for (const [name, value] of Object.entries(attributes)) {
    if (value === undefined || value === false) continue;
    element.setAttribute(name, value === true ? "" : String(value));
  }
  for (const child of children) if (child) element.append(child);
  return element;
}

/** Escape the four HTML-significant characters: the one discipline that keeps user and model text out of markup. */
export const esc = (value: unknown): string =>
  String(value ?? "").replace(/[&<>"]/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[char]!);

const injected = new Set<string>();

/** Append a `<style>` to the document head exactly once per id, whatever the call order or count. */
export function injectStyles(id: string, css: string, target: Document = document): void {
  if (injected.has(id) || target.getElementById(id)) return;
  injected.add(id);
  const style = target.createElement("style");
  style.id = id;
  style.textContent = css;
  target.head.appendChild(style);
}

/** A `<style>` element for a shadow root, with the base vocabulary ahead of the panel's own rules. */
export function shadowStyles(ownCss: string, baseCss: string): HTMLStyleElement {
  const style = document.createElement("style");
  style.textContent = baseCss + "\n" + ownCss;
  return style;
}

/** Add a listener and get back the function that removes it, so a panel can drop every listener it added on disconnect. */
export function listen<K extends keyof HTMLElementEventMap>(target: EventTarget, type: K | string, handler: (event: Event) => void, options?: AddEventListenerOptions | boolean): () => void {
  target.addEventListener(type, handler, options);
  return () => target.removeEventListener(type, handler, options);
}

/** Owns a set of removers (listeners, timers, streams) and runs them all once. */
export interface Disposer {
  add(remove: () => void): void;
  /** Runs every registered remover, newest first, and forgets them. */
  dispose(): void;
  readonly size: number;
}

export function createDisposer(): Disposer {
  const removers: (() => void)[] = [];
  return {
    add(remove) { removers.push(remove); },
    dispose() { for (const remove of removers.splice(0).reverse()) remove(); },
    get size() { return removers.length; },
  };
}

/** The deepest active element, following open shadow roots. */
export function deepActiveElement(root: Document = document): HTMLElement | null {
  let active: Element | null = root.activeElement;
  while (active?.shadowRoot?.activeElement) active = active.shadowRoot.activeElement;
  return active as HTMLElement | null;
}

/** A focus trap for a dialog, popover or drawer: Tab and Shift+Tab cycle within the container while `isOpen()` is
 * true, and focus returns to whatever triggered it when it closes (including a control inside an open shadow root). */
export interface FocusTrap {
  /** Call right before opening: remembers the trigger to restore focus to. */
  capture(): void;
  /** Call right after closing. */
  restore(): void;
}

const FOCUSABLE = 'a[href],button:not([disabled]),textarea:not([disabled]),input:not([disabled]),select:not([disabled]),[tabindex]:not([tabindex="-1"])';

export function trapFocus(container: HTMLElement, isOpen: () => boolean): FocusTrap {
  let lastFocused: HTMLElement | null = null;
  const focusables = (): HTMLElement[] => [...container.querySelectorAll<HTMLElement>(FOCUSABLE)]
    .filter((item) => item.offsetParent !== null || item === document.activeElement || item.getRootNode() !== document);
  container.addEventListener("keydown", (event) => {
    const key = event as KeyboardEvent;
    if (key.key !== "Tab" || !isOpen()) return;
    const items = focusables();
    if (!items.length) return;
    const first = items[0]!, last = items[items.length - 1]!;
    const active = deepActiveElement();
    if (key.shiftKey && active === first) { key.preventDefault(); last.focus(); }
    else if (!key.shiftKey && active === last) { key.preventDefault(); first.focus(); }
  });
  return {
    capture() { lastFocused = deepActiveElement(); },
    restore() { if (lastFocused && typeof lastFocused.focus === "function") lastFocused.focus(); lastFocused = null; },
  };
}
