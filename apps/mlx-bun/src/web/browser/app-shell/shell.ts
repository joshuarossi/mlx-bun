// The app's shell: the generic web shell (`@mlx-bun/web-shell`) over this page's routes, plus the chrome that depends
// on the page: tab order and icons, the host presentation the job panels consume, the overlays Escape closes, the key
// bindings that reach the chat panel, and the routes-map probe. `main.ts` holds the boot order.
import { $ } from "@mlx-bun/web-kit";
import { createShell, toast, type Overlay, type Palette, type RouteController, type ShellPanel } from "@mlx-bun/web-shell";
import { chatPanel } from "./chat-panel";
import { ICONS } from "./icons";
import { pushToHub } from "./publish";
import { activeModelId } from "./server-status";
import { closeSettings, isSettingsOpen } from "./settings";

export type Controller = RouteController;

/** The chat is the product (a workspace panel the shell mounts first); the pages below are developer tools behind the
 * Developer switch. */
export const shell = createShell({
  routes: [{ id: "status", developer: true }, { id: "routes", developer: true }],
  home: "chat",
  onRoute(route) {
    // The recent-chats drawer only exists on the chat page: its top-bar trigger hides elsewhere whatever the width.
    const hamburger = $("chat-hamburger");
    if (hamburger) hamburger.style.display = route === "chat" ? "" : "none";
    if (route !== "chat") chatPanel()?.closeDrawer();
  },
});
export const controllers = shell.controllers;
export const currentRoute = (): string => shell.currentRoute();
export const isDeveloperMode = (): boolean => shell.isDeveloperMode();
export const setDeveloperMode = (on: boolean): void => shell.setDeveloperMode(on);

/** The navigation order: the product pages, then the tools under their heading. */
const ORDER = ["chat", "models", "quantize", "finetune", "dataset", "benchmarks", "metrics", "status", "routes"];

/** Keep the app's navigation order while its pages move into installed panels, group the developer tools under
 * their heading, and give every tab its icon. */
export function mountPanels(panels: readonly ShellPanel[]): void {
  shell.mountPanels(connectPanels(panels));
  const tabs = $("tabs");
  const heading = document.getElementById("tabs-tools");
  const position = (tab: HTMLElement) => { const index = ORDER.indexOf(tab.dataset.tab || ""); return index < 0 ? ORDER.length : index; };
  const sorted = [...tabs.querySelectorAll<HTMLElement>(".tab")].sort((a, b) => position(a) - position(b));
  for (const tab of sorted) {
    const id = tab.dataset.tab || "";
    if (ICONS[id] && !tab.querySelector("svg")) {
      const label = document.createElement("span");
      label.textContent = tab.textContent || id;
      tab.textContent = "";
      tab.insertAdjacentHTML("afterbegin", ICONS[id]);
      tab.append(label);
    }
    if (tab.hasAttribute("data-dev") || !heading) tabs.append(tab); else tabs.insertBefore(tab, heading);
  }
}

/** Presentation the embedding app supplies to the job panels that consume it. */
export function connectPanels(panels: readonly ShellPanel[]): ShellPanel[] {
  return panels.map(panel => {
    if (!["mlx-quantize-panel", "mlx-train-panel", "mlx-datasets-panel"].includes(panel.tag)) return panel;
    return { ...panel, connection: { ...panel.connection, ui: {
      notify: toast,
      publish: pushToHub,
      ...(panel.tag === "mlx-datasets-panel" ? { modelId: () => activeModelId || undefined } : { catalogChanged: () => {
        const status = controllers.status;
        if (status?.refreshLibrary) (status.refreshLibrary as () => void)();
        chatPanel()?.refreshAdapters();
      } }),
    } } };
  });
}

/** A registered close callback for the memory overlay (memory-panel.ts registers it; the shell reaches it here). */
export let memPanelClose: (() => void) | null = null;
export function setMemPanelClose(fn: (() => void) | null): void { memPanelClose = fn; }

/** The overlays Escape closes, in priority order (the shell adds its shortcut sheet and navigation sheet first). */
export function registerOverlays(palette: Palette): void {
  const add = (overlay: Overlay) => shell.overlays.add(overlay);
  add({ isOpen: isSettingsOpen, close: closeSettings });
  // The chat panel's popovers (sampling, system prompt, adapter table) close themselves.
  add({ isOpen: () => !!chatPanel()?.popoverOpen(), close: () => { chatPanel()?.closePopover(); } });
  add({ isOpen: () => { const overlay = document.getElementById("mem-overlay"); return !!overlay && overlay.classList.contains("open") && memPanelClose !== null; }, close: () => memPanelClose?.() });
  add(palette);
  add({ isOpen: () => !!chatPanel()?.drawerOpen(), close: () => chatPanel()?.closeDrawer() });
}

/** The chat's keyboard bindings, consulted after the shell's own. */
export function appKeys(e: KeyboardEvent): boolean {
  const mod = e.metaKey || e.ctrlKey;
  // Cmd/Ctrl+Shift+O: new chat. Free in every major browser.
  if (mod && e.shiftKey && (e.key === "O" || e.key === "o")) {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    chatPanel()?.newChat();
    return true;
  }
  // Cmd/Ctrl+Shift+C: copy the last reply.
  if (mod && e.shiftKey && (e.key === "C" || e.key === "c")) {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    chatPanel()?.copyLastResponse();
    return true;
  }
  // Shift+Escape: focus the message box.
  if (e.shiftKey && e.key === "Escape") {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    chatPanel()?.focusComposer();
    return true;
  }
  return false;
}

/** The top bar's drawer trigger delegates to the chat panel. */
export function initDrawer(): void {
  $("chat-hamburger").onclick = () => chatPanel()?.toggleDrawer();
}

/** `/dag` reads a repository-relative document that is absent from compiled binaries and npm installs. Probe once
 * at boot; on 404 hide the Routes tab and, if the page is already open, show a note instead of a raw 404. */
export async function initRoutesProbe(): Promise<void> {
  let ok = true;
  try { ok = (await fetch("/dag", { method: "HEAD" })).ok; } catch { ok = false; }
  if (ok) return;
  shell.markUnavailable("routes");
  const section = $("s-routes");
  if (section) {
    section.innerHTML = '<div class="shell-panel-scroll"><div class="shell-panel"><div class="empty"><h3>The routes map is not in this build</h3>' +
      "<p>The training and inference route diagram ships with a repository checkout and is not bundled into installed apps.</p></div></div></div>";
  }
  if (currentRoute() === "routes") location.replace("#/chat");
}
