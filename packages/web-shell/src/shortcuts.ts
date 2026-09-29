import { $ } from "./dom";
import { trapFocus, type FocusTrap } from "./focus";
import type { Overlay } from "./overlays";

/** The keyboard shortcut sheet (Cmd/Ctrl+/). The host page carries `#shortcut-overlay` (with the close button
 * `#sk-close`), the trigger `#nav-shortcuts`, and `#sk-mod-label` / `.sk-mod` spans that show the platform's modifier. */
export interface ShortcutSheet extends Overlay {
  open(): void;
  toggle(): void;
  /** Wires the page; call once at boot, after the markup exists. */
  init(): void;
}

export function createShortcutSheet(): ShortcutSheet {
  let trap: FocusTrap | undefined;
  const isOpen = () => $("shortcut-overlay").classList.contains("open");
  function open(): void {
    trap?.capture();
    $("shortcut-overlay").classList.add("open");
    $("nav-shortcuts").setAttribute("aria-expanded", "true");
    setTimeout(() => $("sk-close").focus(), 30);
  }
  function close(): void {
    $("shortcut-overlay").classList.remove("open");
    $("nav-shortcuts").setAttribute("aria-expanded", "false");
    trap?.restore();
  }
  const toggle = () => isOpen() ? close() : open();
  function init(): void {
    trap = trapFocus($("shortcut-overlay"), isOpen);
    const isMac = /Mac|iPhone|iPad/.test(navigator.platform || navigator.userAgent);
    document.querySelectorAll("#sk-mod-label, .sk-mod").forEach((e) => { e.textContent = isMac ? "⌘" : "Ctrl"; });
    $("nav-shortcuts").onclick = toggle;
    $("sk-close").onclick = close;
    $("shortcut-overlay").addEventListener("click", (e) => { if (e.target === $("shortcut-overlay")) close(); });
  }
  return { isOpen, close, open, toggle, init };
}
