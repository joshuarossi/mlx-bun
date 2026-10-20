// The shell: navigation between pages, hash routing, the Developer switch, the navigation sheet on narrow screens,
// panel mounting, and the global keyboard bindings. The host page supplies the markup (`#nav` holding `#tabs` with
// `a.tab[data-tab]` tabs and, optionally, group headings marked `data-dev`; pages as `section[data-route]` inside
// `#app`; `#nav-developer`; `#nav-menu` and `#nav-backdrop` for the sheet); the shell drives it and adds a tab and a
// page for every module panel.
import { $, trapFocus, type FocusTrap } from "@mlx-bun/web-kit";
import { SHEET_MEDIA } from "./chrome";
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

/** The navigation rail as a sheet on narrow screens (`#nav.open`), opened by `#nav-menu` and closed by its backdrop,
 * Escape, or any navigation. On wide screens the rail is always visible and these are no-ops in effect. */
export interface NavSheet {
  open(): void;
  close(): void;
  toggle(): void;
  isOpen(): boolean;
}

export interface Shell {
  /** Page controllers by route id; hosts fill it before the first navigation. */
  readonly controllers: Partial<Record<string, RouteController>>;
  /** What Escape closes. */
  readonly overlays: Overlays;
  readonly shortcuts: ShortcutSheet;
  readonly nav: NavSheet;
  currentRoute(): string;
  /** Shows the page the hash names (toggling pages and tabs, running controllers). */
  navigate(): void;
  /** Adds a tab and a page for each module panel. Call before `start`. */
  mountPanels(panels: readonly ShellPanel[]): void;
  /** Sets up theme, the service worker, the shortcut sheet, key bindings, hash routing, the Developer switch and the sheet. */
  start(options?: ShellStart): void;
  isDeveloperMode(): boolean;
  setDeveloperMode(on: boolean): void;
  /** Hides a route's tab for good (a page the build does not carry); the host decides what its page shows instead. */
  markUnavailable(id: string): void;
  /** Navigation targets for the (non-workspace) panels mounted so far. */
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

  /* ── Developer switch: the product pages are always listed; developer tools collapse behind one switch.
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
  /** Reflect developer mode into the DOM: the visibility of developer tabs and their group headings, and the switch's
   * state. A tab whose page the host marked unavailable (`markUnavailable`, e.g. a diagram that is not shipped) stays
   * hidden regardless. */
  function applyDeveloperMode(on: boolean): void {
    document.querySelectorAll<HTMLElement>("#nav [data-dev], nav [data-dev]").forEach((item) => {
      if (item.dataset.unavailable === "1") { item.style.display = "none"; return; }
      item.style.display = on ? "" : "none";
    });
    const btn = $("nav-developer");
    if (btn) btn.setAttribute("aria-checked", on ? "true" : "false");
    const dot = document.getElementById("nav-developer-dot");
    if (dot) dot.classList.toggle("on", on);
  }
  function setDeveloperMode(on: boolean): void {
    localStorage.setItem(DEV_KEY, on ? "1" : "0");
    applyDeveloperMode(on);
  }
  function ensureDeveloperModeFor(route: string): void {
    if (routes.find((r) => r.id === route)?.developer && !isDeveloperMode()) setDeveloperMode(true);
  }

  /* ── The navigation sheet (narrow screens). ── */
  const navElement = () => document.getElementById("nav");
  // Open, the sheet is a dialog over the page: Tab and Shift+Tab stay inside it, and closing it returns focus to
  // whatever opened it (the menu button, or the shortcut's focus), never to the page behind the backdrop.
  let sheetTrap: FocusTrap | undefined;
  let sheetFocus: ReturnType<typeof setTimeout> | undefined;
  const nav: NavSheet = {
    isOpen: () => !!navElement()?.classList.contains("open"),
    open() {
      const element = navElement();
      // Already open: the restore target stays what opened it, not a control inside the sheet.
      if (!element || nav.isOpen()) return;
      sheetTrap ??= trapFocus(element, () => nav.isOpen());
      sheetTrap.capture();
      element.classList.add("open");
      document.getElementById("nav-backdrop")?.classList.add("open");
      document.getElementById("nav-menu")?.setAttribute("aria-expanded", "true");
      // The first tab takes focus once the sheet has slid in; a close before then cancels it.
      clearTimeout(sheetFocus);
      sheetFocus = setTimeout(() => { sheetFocus = undefined; if (nav.isOpen()) element.querySelector<HTMLElement>(".tab.active, .tab")?.focus(); }, 30);
    },
    close() {
      if (!nav.isOpen()) return;
      clearTimeout(sheetFocus);
      sheetFocus = undefined;
      const element = navElement();
      element?.classList.remove("open");
      document.getElementById("nav-backdrop")?.classList.remove("open");
      const menu = document.getElementById("nav-menu");
      menu?.setAttribute("aria-expanded", "false");
      const inside = !!element?.contains(document.activeElement);
      sheetTrap?.restore();
      if (inside && element?.contains(document.activeElement)) menu?.focus();
    },
    toggle() { nav.isOpen() ? nav.close() : nav.open(); },
  };

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
    document.querySelectorAll<HTMLElement>("#nav .tab, nav .tab").forEach((t) => {
      const active = t.dataset.tab === route;
      t.classList.toggle("active", active);
      if (active) t.setAttribute("aria-current", "page"); else t.removeAttribute("aria-current");
    });
    nav.close();
    options.onRoute?.(route);
  }

  function mountPanels(panels: readonly ShellPanel[]): void {
    const outlet = $("app");
    for (const panel of panels) {
      if (panel.overlay) {
        const element = document.createElement(panel.tag);
        Object.assign(element, { connection: panel.connection }, panel.properties);
        document.body.append(element);
        continue;
      }
      const page = buildPanelPage(panel);
      if (hasRoute(page.id)) throw new Error(`Panel route /${page.id} is already taken`);
      routes.push({ id: page.id, developer: panel.developer ?? !panel.workspace });
      controllers[page.id] = page.controller;
      // Navigation targets are the tools; a workspace is the page the product opens on.
      if (!panel.workspace) panelTitles.push({ id: page.id, title: panel.title });
      // A workspace leads the tabs.
      if (panel.workspace) $("tabs").prepend(page.tab); else $("tabs").append(page.tab);
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
    overlays.add(nav);
    bindKeys(startOptions);
    window.addEventListener("hashchange", navigate);
    applyDeveloperMode(isDeveloperMode());
    const btn = $("nav-developer");
    if (btn) btn.onclick = () => setDeveloperMode(!isDeveloperMode());
    const menu = document.getElementById("nav-menu");
    if (menu) menu.onclick = () => nav.toggle();
    const backdrop = document.getElementById("nav-backdrop");
    if (backdrop) backdrop.onclick = () => nav.close();
    // A tap on a tab closes the sheet even when it is the current page's (no hash change, so no navigation).
    navElement()?.addEventListener("click", (e) => { if ((e.target as Element).closest(".tab")) nav.close(); });
    // Past the breakpoint the rail is a rail again: a sheet left open closes, so its backdrop and focus trap do not
    // outlive the layout that needed them.
    const sheetMedia = typeof window.matchMedia === "function" ? window.matchMedia(SHEET_MEDIA) : null;
    const onLayout = () => { if (sheetMedia && !sheetMedia.matches) nav.close(); };
    sheetMedia?.addEventListener?.("change", onLayout);
    window.addEventListener("resize", onLayout);
  }

  function markUnavailable(id: string): void {
    const tab = document.querySelector<HTMLElement>(`.tab[data-tab="${id}"]`);
    if (tab) { tab.dataset.unavailable = "1"; tab.style.display = "none"; }
  }

  return {
    controllers, overlays, shortcuts, nav, currentRoute, navigate, mountPanels, start, isDeveloperMode, setDeveloperMode,
    markUnavailable, panelTargets: () => panelTitles,
  };
}
