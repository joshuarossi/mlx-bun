// The shell: navigation between pages, hash routing, the Developer switch, panel mounting, and the global
// keyboard bindings. The host page supplies the markup (`nav #tabs` with `a.tab[data-tab]` tabs, `section[data-route]`
// pages inside `#app`, `#nav-developer`); the shell drives it and adds a tab and a page for every module panel.
import { $ } from "./dom";
import { createOverlays, type Overlays } from "./overlays";
import { buildPanelPage, type ShellPanel } from "./panels";
import { initTheme } from "./theme";
import { createShortcutSheet, type ShortcutSheet } from "./shortcuts";
import type { Palette } from "./palette";

/** A page's lifecycle: `init` runs once on first entry, `enter` and `leave` every time it is shown or hidden.
 * Extra fields are cross-page calls other pages make through the registry, so they stay loose. */
export interface RouteController {
  init?(): void;
  enter?(): void;
  leave?(): void;
  [extra: string]: unknown;
}

/** A page the host page's markup already carries. */
export interface ShellRoute {
  id: string;
  /** Listed among the developer tools: its tab hides until the Developer switch is on, and opening it turns it on. */
  developer?: boolean;
}

export interface ShellOptions {
  /** The pages in the host's markup, in navigation order. */
  routes: readonly ShellRoute[];
  /** The page shown for an empty or unknown hash. */
  home: string;
  /** Runs after every navigation, with the route now shown (host chrome that depends on the page). */
  onRoute?(route: string): void;
}

export interface ShellStart {
  /** Opened and closed by Cmd/Ctrl+K; it should be in `overlays` so Escape closes it. */
  palette?: Palette;
  /** The host's own key bindings, consulted after the shell's; return true when the event was handled. */
  keys?(event: KeyboardEvent): boolean;
}

export interface Shell {
  /** Page controllers by route id; hosts fill it before the first navigation. */
  readonly controllers: Partial<Record<string, RouteController>>;
  /** What Escape closes. */
  readonly overlays: Overlays;
  readonly shortcuts: ShortcutSheet;
  currentRoute(): string;
  /** Shows the page the hash names (toggling pages and tabs, running controllers). */
  navigate(): void;
  /** Adds a tab and a page for each module panel. Call before `start`. */
  mountPanels(panels: readonly ShellPanel[]): void;
  /** Sets up theme, the service worker, the shortcut sheet, key bindings, hash routing and the Developer switch. */
  start(options?: ShellStart): void;
  isDeveloperMode(): boolean;
  setDeveloperMode(on: boolean): void;
  /** Recomputes the tab row's scroll-edge fades. */
  updateTabFades(): void;
  /** Hides a route's tab for good (a page the build does not carry); the host decides what its page shows instead. */
  markUnavailable(id: string): void;
  /** Navigation targets for the panels mounted so far. */
  panelTargets(): readonly { id: string; title: string }[];
}

export const DEV_KEY = "mlxbun.developer";

export function createShell(options: ShellOptions): Shell {
  const routes: ShellRoute[] = [...options.routes];
  const controllers: Partial<Record<string, RouteController>> = {};
  const inited: Record<string, boolean> = {};
  const overlays = createOverlays();
  const shortcuts = createShortcutSheet();
  const panelTitles: { id: string; title: string }[] = [];

  const hasRoute = (id: string) => routes.some((route) => route.id === id);
  function currentRoute(): string {
    const h = (location.hash || "").replace(/^#\/?/, "").split("?")[0] || "";
    return hasRoute(h) ? h : options.home;
  }

  /* ── Developer switch: the product page is the home route; developer routes collapse behind one nav switch.
     Persisted; default OFF for a fresh browser, but ON (once) when any other pre-existing mlxbun.* localStorage key is
     found, so a returning user never has tabs yanked away. Deep links still work: entering a developer route with the
     switch off flips it on. ── */

  /** True if any OTHER mlxbun.* key already exists, i.e. this is a returning user. Checked before writing the
   * developer key itself, so it cannot self-detect on a later load. */
  function hasExistingState(): boolean {
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (k && k.startsWith("mlxbun.") && k !== DEV_KEY) return true;
    }
    return false;
  }
  function isDeveloperMode(): boolean {
    const saved = localStorage.getItem(DEV_KEY);
    if (saved != null) return saved === "1";
    // First-ever read: decide and persist the one-time default so it is stable across reloads.
    const on = hasExistingState();
    localStorage.setItem(DEV_KEY, on ? "1" : "0");
    return on;
  }
  /** Reflect developer mode into the DOM: developer-tab visibility and the switch's pressed state. A tab whose page
   * the host marked unavailable (`markUnavailable`, e.g. a diagram that is not shipped) stays hidden regardless. */
  function applyDeveloperMode(on: boolean): void {
    document.querySelectorAll<HTMLElement>("nav .tab[data-dev]").forEach((t) => {
      if (t.dataset.unavailable === "1") { t.style.display = "none"; return; }
      t.style.display = on ? "" : "none";
    });
    const btn = $("nav-developer");
    if (btn) btn.setAttribute("aria-checked", on ? "true" : "false");
    const dot = document.getElementById("nav-developer-dot");
    if (dot) dot.classList.toggle("on", on);
    updateTabFades();
  }
  function setDeveloperMode(on: boolean): void {
    localStorage.setItem(DEV_KEY, on ? "1" : "0");
    applyDeveloperMode(on);
  }
  function ensureDeveloperModeFor(route: string): void {
    if (routes.find((r) => r.id === route)?.developer && !isDeveloperMode()) setDeveloperMode(true);
  }

  /* ── Router: toggles section[data-route]; lazily inits each controller. ── */
  function navigate(): void {
    const route = currentRoute();
    ensureDeveloperModeFor(route); // a deep link to a developer page always flips the switch on
    document.querySelectorAll<HTMLElement>("section[data-route]").forEach((s) => {
      const on = s.dataset.route === route;
      if (on && !s.classList.contains("active")) {
        s.classList.add("active");
        const c = controllers[route];
        if (c) { if (!inited[route]) { inited[route] = true; c.init && c.init(); } c.enter && c.enter(); }
      } else if (!on && s.classList.contains("active")) {
        s.classList.remove("active");
        const c = controllers[s.dataset.route!];
        if (c && c.leave) c.leave();
      }
    });
    document.querySelectorAll<HTMLElement>("nav .tab").forEach((t) => t.classList.toggle("active", t.dataset.tab === route));
    options.onRoute?.(route);
  }

  /** The tab row scrolls with its scrollbar hidden, so overflow read as clipped text: toggle .fade-r/.fade-l so the
   * CSS mask signals "more this way" only when true. */
  function updateTabFades(): void {
    const t = $("tabs");
    const over = t.scrollWidth - t.clientWidth > 1;
    t.classList.toggle("fade-r", over && t.scrollLeft + t.clientWidth < t.scrollWidth - 1);
    t.classList.toggle("fade-l", over && t.scrollLeft > 1);
  }

  function mountPanels(panels: readonly ShellPanel[]): void {
    const outlet = $("app");
    for (const panel of panels) {
      const page = buildPanelPage(panel);
      if (hasRoute(page.id)) throw new Error(`Panel route /${page.id} is already taken`);
      routes.push({ id: page.id, developer: panel.developer !== false });
      controllers[page.id] = page.controller;
      panelTitles.push({ id: page.id, title: panel.title });
      $("tabs").append(page.tab);
      outlet.append(page.section);
    }
  }

  /** Registers the page's service worker: shell-only cache-first, for installability and instant paint. Guarded to
   * where a worker can run and the browser would accept it (https or localhost); failure is silent. */
  function registerServiceWorker(): void {
    if (!("serviceWorker" in navigator)) return;
    const host = location.hostname;
    const isLocalhost = host === "localhost" || host === "127.0.0.1" || host === "::1";
    if (location.protocol !== "https:" && !isLocalhost) return;
    window.addEventListener("load", () => { navigator.serviceWorker.register("/sw.js").catch(() => { /* the app works identically without it */ }); });
  }

  function bindKeys(start: ShellStart): void {
    document.addEventListener("keydown", (e) => {
      const mod = e.metaKey || e.ctrlKey;
      // Cmd/Ctrl+K: the command palette.
      if (mod && (e.key === "k" || e.key === "K")) {
        e.preventDefault();
        start.palette?.toggle();
        return;
      }
      // Cmd/Ctrl+/: the shortcut sheet. Not a browser-reserved combo.
      if (mod && e.key === "/") { e.preventDefault(); shortcuts.toggle(); return; }
      if (start.keys?.(e)) return;
      // Escape alone closes whatever overlay is open, with focus restored to its trigger. It never shadows a plain
      // Escape when nothing is open (a composer's own Escape keeps working: closeTop simply returns false).
      if (e.key === "Escape" && !e.shiftKey && !mod) overlays.closeTop();
    });
  }

  function start(startOptions: ShellStart = {}): void {
    initTheme();
    registerServiceWorker();
    shortcuts.init();
    overlays.add(shortcuts);
    bindKeys(startOptions);
    window.addEventListener("hashchange", navigate);
    $("tabs").addEventListener("scroll", updateTabFades, { passive: true });
    window.addEventListener("resize", updateTabFades);
    updateTabFades();
    applyDeveloperMode(isDeveloperMode());
    const btn = $("nav-developer");
    if (btn) btn.onclick = () => setDeveloperMode(!isDeveloperMode());
  }

  function markUnavailable(id: string): void {
    const tab = document.querySelector<HTMLElement>(`nav .tab[data-tab="${id}"]`);
    if (tab) { tab.dataset.unavailable = "1"; tab.style.display = "none"; }
  }

  return {
    controllers, overlays, shortcuts, currentRoute, navigate, mountPanels, start, isDeveloperMode, setDeveloperMode,
    updateTabFades, markUnavailable, panelTargets: () => panelTitles,
  };
}
