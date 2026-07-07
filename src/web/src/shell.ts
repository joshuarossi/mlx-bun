// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// App shell: DOM helpers, toast, HF settings modal, focus trap, theme,
// keyboard shortcut sheet, mobile drawer, router, connection pill + model
// identity polling, and the global keydown sweep. Behavior-identical port
// of the original inline <script> in app.html. Owns the `controllers`
// registry that the per-tab modules populate (see main.ts for the exact
// registration order, which callers must preserve).

import { api } from "./api";
import type { ApiEnvelope } from "./protocol";

/* ════════════════════════════════════════════════════════════════════
   SHARED HELPERS
   ════════════════════════════════════════════════════════════════════ */
export const $ = (id: string): HTMLElement => document.getElementById(id) as HTMLElement;
export const gb = (b: number | null | undefined): string => b == null ? "—" : (b / 2 ** 30).toFixed(2) + " GB";
export const mb = (b: number | null | undefined): string => b == null ? "—" : (b / 2 ** 20).toFixed(1) + " MB";
export const num = (n: number | null | undefined): string => n == null ? "—" : Math.round(n).toLocaleString();

/** Build a DOM node quickly. */
export function el<K extends keyof HTMLElementTagNameMap>(tag: K, cls?: string, parent?: Element | null): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (parent) parent.appendChild(e);
  return e;
}

/** Toast notification. kind: "" | "ok" | "err". */
export function toast(msg: string, kind = "", ms = 4200): void {
  const t = el("div", "toast " + kind, $("toasts"));
  t.textContent = msg;
  setTimeout(() => { t.style.transition = "opacity .4s,transform .4s"; t.style.opacity = "0"; t.style.transform = "translateY(10px)"; setTimeout(() => t.remove(), 420); }, ms);
}

/* ════════════════════════════════════════════════════════════════════
   HUGGING FACE — shared token settings + push-to-hub flow
   ════════════════════════════════════════════════════════════════════ */

/** Reflect saved-token state on the nav gear. */
export async function refreshHfGear(): Promise<boolean> {
  try {
    const d = await api("/api/settings/hf-token");
    const saved = !!(d && d.ok && (d as { hasToken?: boolean }).hasToken);
    $("nav-hf").classList.toggle("saved", saved);
    $("nav-hf").title = saved ? "Hugging Face token saved · click to replace" : "Hugging Face token settings";
    return saved;
  } catch { return false; }
}

let hfOverlayTrap: FocusTrap | null = null; // set by initHfSettings() below

function openHfSettings(): void {
  const ov = $("hf-overlay"); ov.classList.add("open");
  if (hfOverlayTrap) hfOverlayTrap.capture();
  ($("hf-token-input") as HTMLInputElement).value = ""; $("hf-settings-msg").innerHTML = "";
  $("hf-state").textContent = "Checking for a saved token…";
  api("/api/settings/hf-token").then((d) => {
    const saved = !!(d && d.ok && (d as { hasToken?: boolean }).hasToken);
    $("hf-state").innerHTML = saved
      ? "A write token is <strong>saved</strong>. Enter a new one below to replace it."
      : "No token saved yet. Add a write token to push models and datasets to the Hub.";
  }).catch(() => { $("hf-state").textContent = "Could not reach the server."; });
  setTimeout(() => $("hf-token-input").focus(), 50);
}
function closeHfSettings(): void {
  $("hf-overlay").classList.remove("open");
  if (hfOverlayTrap) hfOverlayTrap.restore();
}

async function saveHfToken(): Promise<void> {
  const tokenInput = $("hf-token-input") as HTMLInputElement;
  const token = tokenInput.value.trim();
  const msg = $("hf-settings-msg");
  if (!token) { msg.innerHTML = '<div class="flash err">Enter a token first.</div>'; return; }
  const btn = $("hf-save") as HTMLButtonElement; btn.disabled = true;
  const d = await api("/api/settings/hf-token", { method: "POST", body: { token } }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
  btn.disabled = false;
  if (!d.ok) { msg.innerHTML = '<div class="flash err">' + escHtml(d.error || "could not save token") + "</div>"; return; }
  msg.innerHTML = '<div class="flash ok">Token saved to <code>~/.mlx-bun/hf.json</code>.</div>';
  tokenInput.value = "";
  refreshHfGear();
  toast("Hugging Face token saved", "ok");
}

// Local esc() copy to avoid a circular import with markdown.ts (shell.ts
// only needs escaping, not the full markdown surface) — identical logic to
// markdown.ts's esc().
function escHtml(s: unknown): string {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);
}

export interface PushToHubOpts {
  kind: "quantize" | "finetune" | "dataset";
  job_id?: string;
  source_path?: string;
}

/**
 * Shared push-to-hub flow, rendered inline inside a done-step card.
 *   pushToHub(panelEl, { kind, job_id?, source_path? })
 * kind: "quantize" | "finetune" | "dataset". Posts to /api/{kind}/push.
 * Walks: ensure token -> repo_id + private -> POST -> success/error flash.
 */
export async function pushToHub(panel: HTMLElement, opts: PushToHubOpts): Promise<void> {
  const { kind, job_id, source_path } = opts;
  panel.innerHTML = '<div class="pushpanel"><div class="flash"><span class="shimmer">checking Hugging Face token…</span></div></div>';
  const wrap = panel.firstChild as HTMLElement;
  let hasToken = false;
  try { const s = await api("/api/settings/hf-token"); hasToken = !!(s && s.ok && (s as { hasToken?: boolean }).hasToken); } catch { /* treat as no token */ }

  const renderForm = () => {
    wrap.innerHTML =
      (!hasToken
        ? '<div class="field"><label>Hugging Face write token</label>' +
          '<input type="password" class="p-token" placeholder="hf_…" autocomplete="off" spellcheck="false">' +
          '<div class="hint">A <strong>write</strong> token from huggingface.co/settings/tokens. Stored locally at <code>~/.mlx-bun/hf.json</code>.</div></div>'
        : "") +
      '<div class="field"><label>Repository id</label>' +
        '<input type="text" class="p-repo" placeholder="you/my-' + escHtml(kind === "dataset" ? "dataset" : "model") + '" autocomplete="off"></div>' +
      '<div class="field"><label class="chk"><input type="checkbox" class="p-priv">Private repository</label></div>' +
      '<div class="p-msg"></div>' +
      '<div class="btnrow" style="margin-top:6px"><button class="btn primary sm p-go">' +
        (hasToken ? "Push" : "Save token &amp; push") + "</button></div>";
    (wrap.querySelector(".p-go") as HTMLButtonElement).onclick = go;
    const focusEl = wrap.querySelector(hasToken ? ".p-repo" : ".p-token") as HTMLElement | null;
    if (focusEl) focusEl.focus();
  };

  async function go(): Promise<void> {
    const msg = wrap.querySelector(".p-msg") as HTMLElement;
    const repo = ((wrap.querySelector(".p-repo") as HTMLInputElement).value || "").trim();
    const priv = (wrap.querySelector(".p-priv") as HTMLInputElement).checked;
    if (!repo) { msg.innerHTML = '<div class="flash err">Enter a repository id (e.g. <code>you/my-model</code>).</div>'; return; }
    const btn = wrap.querySelector(".p-go") as HTMLButtonElement; btn.disabled = true;

    if (!hasToken) {
      const token = ((wrap.querySelector(".p-token") as HTMLInputElement).value || "").trim();
      if (!token) { msg.innerHTML = '<div class="flash err">Enter a write token first.</div>'; btn.disabled = false; return; }
      const sv = await api("/api/settings/hf-token", { method: "POST", body: { token } }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
      if (!sv.ok) { msg.innerHTML = '<div class="flash err">' + escHtml(sv.error || "could not save token") + "</div>"; btn.disabled = false; return; }
      hasToken = true; refreshHfGear();
    }

    msg.innerHTML = '<div class="flash"><span class="shimmer">pushing to ' + escHtml(repo) + "…</span></div>";
    const body: Record<string, unknown> = { repo_id: repo, private: priv };
    if (job_id != null) body.job_id = job_id;
    if (source_path != null) body.source_path = source_path;
    const d = await api("/api/" + kind + "/push", { method: "POST", body }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { msg.innerHTML = '<div class="flash err">' + escHtml(d.error || "push failed") + "</div>"; return; }
    const url = (d as { url?: string }).url || ("https://huggingface.co/" + repo);
    wrap.innerHTML = '<div class="flash ok">Pushed to <a href="' + escHtml(url) + '" target="_blank" rel="noopener" style="text-decoration:underline">' + escHtml(url) + "</a></div>";
    toast("Pushed to Hugging Face", "ok");
  }

  renderForm();
}

/* wire the nav gear + modal once at boot. The modal now also hosts the
 *  Agent tools section (plan §5.4/§6.5/§9 Phase 2) — see the block below;
 *  kept in this same init function since it's one modal, one open/close
 *  lifecycle, one focus trap. */
export function initHfSettings(): void {
  $("nav-hf").onclick = openHfSettings;
  $("hf-close").onclick = closeHfSettings;
  $("hf-save").onclick = saveHfToken;
  $("hf-overlay").addEventListener("click", (e) => { if (e.target === $("hf-overlay")) closeHfSettings(); });
  $("hf-token-input").addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter") saveHfToken(); });
  // Escape is handled globally by closeTopOverlay (plan §7 item 5 — one
  // Escape mechanism for every popover/overlay, not a bespoke one per modal).
  hfOverlayTrap = trapFocus($("hf-overlay"), () => $("hf-overlay").classList.contains("open"));
  refreshHfGear();
  initCodingToolsToggle();
}

/* ════════════════════════════════════════════════════════════════════
   AGENT TOOLS SETTINGS (plan §5.4/§6.5/§9 Phase 2) — the codingTools
   opt-in toggle + the durable "always allow" list. State of record for
   BOTH is server-side (the toggle's enforcement, and the tool-approvals
   config file); this module only reflects what the server last reported
   (coding_tools/tool_approvals ServerMessages, relayed here by chat.ts —
   shell.ts owns no WebSocket) plus the localStorage mirror that lets the
   checkbox restore its last-requested state before the first `ready`
   frame arrives.
   ════════════════════════════════════════════════════════════════════ */
const CODING_TOOLS_KEY = "mlxbun.codingTools";

/** Last requested state (this browser). The server is the actual source of
 *  truth for enforcement — this is only UI restoration so the checkbox
 *  doesn't flash unchecked while waiting on the first `ready`/`coding_tools`
 *  frame after a reload. */
export function storedCodingToolsPreference(): boolean {
  return localStorage.getItem(CODING_TOOLS_KEY) === "1";
}

function setStoredCodingToolsPreference(on: boolean): void {
  localStorage.setItem(CODING_TOOLS_KEY, on ? "1" : "0");
}

/** Reflect the server's coding_tools frame {active, pending} into the
 *  checkbox + the honest status note. `active` is what THIS session's tool
 *  surface actually contains; `pending` is the last request, which only
 *  takes effect on the next new/opened/forked chat — the note says so
 *  explicitly rather than implying the toggle is live immediately. */
export function renderCodingToolsState(active: boolean, pending: boolean): void {
  const cb = $("settings-coding-tools") as HTMLInputElement | null;
  if (cb) cb.checked = pending;
  const note = $("settings-coding-tools-note");
  if (!note) return;
  if (pending && !active) {
    note.style.display = "";
    note.textContent = "Will apply starting with your next new chat (this chat keeps its current tools).";
  } else if (!pending && active) {
    note.style.display = "";
    note.textContent = "Turning this off won't remove tools from the CURRENT chat — start a new chat to fully disable.";
  } else {
    note.style.display = "none";
    note.textContent = "";
  }
}

/** Reflect the durable always-allow set (tool_approvals frame) into the
 *  settings list, each row with a "forget" button. `onForget` is supplied
 *  by chat.ts (it owns the WebSocket) — this module never sends frames
 *  itself, matching pushToHub/refreshHfGear's api()-only pattern above. */
export function renderToolApprovals(tools: readonly string[], onForget: (tool: string) => void): void {
  const list = $("settings-approvals-list");
  if (!list) return;
  if (tools.length === 0) {
    list.innerHTML = '<div class="settings-approvals-empty">No tools are set to always-allow yet.</div>';
    return;
  }
  list.innerHTML = tools.map((t) =>
    '<div class="settings-approval-row"><span class="satool">' + escHtml(t) +
    '</span><button class="saforget" data-tool="' + escHtml(t) + '">Forget</button></div>'
  ).join("");
  list.querySelectorAll<HTMLButtonElement>(".saforget").forEach((btn) => {
    btn.onclick = () => onForget(btn.dataset.tool || "");
  });
}

/** Wire the checkbox; the actual set_coding_tools WS send is delegated to
 *  controllers.chat.setCodingTools (registered by chat.ts's init — same
 *  cross-controller-call pattern as newChat/copyLastResponse above), since
 *  shell.ts owns no WebSocket. controllers.chat is always populated by the
 *  time a user can reach this modal (main.ts's boot order registers it
 *  before any UI is interactive); the guard below is defensive only — if
 *  it's ever missing, localStorage still records the preference (it's
 *  re-sent on the next `ready` frame regardless), it just silently skips
 *  the immediate WS send rather than throwing. */
function initCodingToolsToggle(): void {
  const cb = $("settings-coding-tools") as HTMLInputElement | null;
  if (!cb) return;
  cb.checked = storedCodingToolsPreference();
  cb.onchange = () => {
    const on = cb.checked;
    setStoredCodingToolsPreference(on);
    const setCodingTools = controllers.chat && controllers.chat.setCodingTools as ((enabled: boolean) => void) | undefined;
    if (setCodingTools) setCodingTools(on);
  };
}

/* ════════════════════════════════════════════════════════════════════
   POPOVER / OVERLAY A11Y SWEEP (plan §7 item 5)
   A single reusable focus-trap: Tab/Shift+Tab cycle within the container
   while `isOpen()` is true, and focus returns to whatever triggered the
   overlay when it closes. Applied uniformly to the HF modal, the
   shortcut sheet, the sampling popover, and the drawer — one mechanism,
   not four bespoke ones.
   ════════════════════════════════════════════════════════════════════ */
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

/* ════════════════════════════════════════════════════════════════════
   THEME (plan §7): auto/dark/light, persisted, honors prefers-color-scheme
   when the choice is "auto" (the default). Ambient bloom/shimmer already
   respect prefers-reduced-motion via CSS above — this only handles color.
   ════════════════════════════════════════════════════════════════════ */
const THEME_KEY = "mlxbun.theme"; // "auto" | "dark" | "light"
const themeMedia = window.matchMedia("(prefers-color-scheme: light)");

function effectiveTheme(choice: string): "dark" | "light" {
  if (choice === "dark" || choice === "light") return choice;
  return themeMedia.matches ? "light" : "dark";
}
function applyTheme(choice: string): void {
  document.documentElement.setAttribute("data-theme", effectiveTheme(choice));
  document.querySelectorAll<HTMLButtonElement>("#theme-toggle button").forEach((b) =>
    b.classList.toggle("active", b.dataset.themeChoice === choice));
}
export function setTheme(choice: string): void {
  localStorage.setItem(THEME_KEY, choice);
  applyTheme(choice);
}
export function initTheme(): void {
  const saved = localStorage.getItem(THEME_KEY) || "auto";
  applyTheme(saved);
  document.querySelectorAll<HTMLButtonElement>("#theme-toggle button").forEach((b) =>
    b.addEventListener("click", () => setTheme(b.dataset.themeChoice || "auto")));
  // Live-follow the OS when the user's choice is "auto" (default).
  themeMedia.addEventListener("change", () => {
    if ((localStorage.getItem(THEME_KEY) || "auto") === "auto") applyTheme("auto");
  });
}

/* ════════════════════════════════════════════════════════════════════
   KEYBOARD SHORTCUT SHEET (Cmd/Ctrl+/) + global bindings (plan §7)
   ════════════════════════════════════════════════════════════════════ */
let skTrap: FocusTrap;

function openShortcutSheet(): void {
  skTrap.capture();
  $("shortcut-overlay").classList.add("open");
  $("nav-shortcuts").setAttribute("aria-expanded", "true");
  setTimeout(() => $("sk-close").focus(), 30);
}
function closeShortcutSheet(): void {
  $("shortcut-overlay").classList.remove("open");
  $("nav-shortcuts").setAttribute("aria-expanded", "false");
  skTrap.restore();
}
export function initShortcutSheet(): void {
  skTrap = trapFocus($("shortcut-overlay"), () => $("shortcut-overlay").classList.contains("open"));
  const isMac = /Mac|iPhone|iPad/.test(navigator.platform || navigator.userAgent);
  document.querySelectorAll("#sk-mod-label, .sk-mod").forEach((e) => { e.textContent = isMac ? "⌘" : "Ctrl"; });
  $("nav-shortcuts").onclick = () => {
    $("shortcut-overlay").classList.contains("open") ? closeShortcutSheet() : openShortcutSheet();
  };
  $("sk-close").onclick = closeShortcutSheet;
  $("shortcut-overlay").addEventListener("click", (e) => { if (e.target === $("shortcut-overlay")) closeShortcutSheet(); });
}

/* ════════════════════════════════════════════════════════════════════
   MOBILE DRAWER (plan §5.7/§7/§9 Phase 1 item 1) — chat sidebar becomes a
   slide-over on narrow viewports instead of vanishing outright. Chat-route
   only: the hamburger button is CSS-hidden >=760px and JS-hidden off /chat
   (router() below), so open/close are only ever reachable when relevant.
   ════════════════════════════════════════════════════════════════════ */
let drawerTrap: FocusTrap;

export function openDrawer(): void {
  drawerTrap.capture();
  $("chat-sidebar").classList.add("drawer-open");
  $("chat-drawer-backdrop").classList.add("open");
  $("chat-hamburger").setAttribute("aria-expanded", "true");
  setTimeout(() => { const s = $("chat-sess-search"); if (s) s.focus(); }, 30);
}
export function closeDrawer(): void {
  $("chat-sidebar").classList.remove("drawer-open");
  $("chat-drawer-backdrop").classList.remove("open");
  $("chat-hamburger").setAttribute("aria-expanded", "false");
  drawerTrap.restore();
}
export function initDrawer(): void {
  drawerTrap = trapFocus($("chat-sidebar"), () => $("chat-sidebar").classList.contains("drawer-open"));
  $("chat-hamburger").onclick = () => {
    $("chat-sidebar").classList.contains("drawer-open") ? closeDrawer() : openDrawer();
  };
  $("chat-drawer-backdrop").addEventListener("click", closeDrawer);
}

/** Set by controllers.chat's initSampling() once the popover exists; let
 *  closeTopOverlay's global Escape sweep close it without a second,
 *  divergent Escape listener living inside the controller. */
export let samplingPopoverClose: (() => void) | null = null;
export function setSamplingPopoverClose(fn: (() => void) | null): void { samplingPopoverClose = fn; }

/** Same registered-callback pattern as samplingPopoverClose above, used by
 *  memory-panel.ts's initMemoryPanel() — avoids a circular import (shell.ts
 *  is imported BY memory-panel.ts for $/trapFocus/etc., so shell.ts can't
 *  import memory-panel.ts's closeMemPanel back). */
export let memPanelClose: (() => void) | null = null;
export function setMemPanelClose(fn: (() => void) | null): void { memPanelClose = fn; }

/** Same pattern, for the adapter routing table overlay (adapters-panel.ts,
 *  plan §5.6/§9 Phase 2) — same circular-import reason as memPanelClose. */
export let adaptersPanelClose: (() => void) | null = null;
export function setAdaptersPanelClose(fn: (() => void) | null): void { adaptersPanelClose = fn; }

/** Same pattern, for the model picker popover (model-picker.ts). */
export let modelPopClose: (() => void) | null = null;
export function setModelPopClose(fn: (() => void) | null): void { modelPopClose = fn; }

/** Same pattern, for the system-prompt popover (composer.ts's
 *  initSystemPrompt() — presets v1, plan §9 Phase 2). */
export let sysPromptPopoverClose: (() => void) | null = null;
export function setSysPromptPopoverClose(fn: (() => void) | null): void { sysPromptPopoverClose = fn; }

/** Any open popover/drawer/sheet this Escape binding knows how to close,
 *  checked in a fixed priority order (most-recently-opened-ish first).
 *  Returns true if it closed something, so callers can stop there. */
function closeTopOverlay(): boolean {
  if ($("shortcut-overlay").classList.contains("open")) { closeShortcutSheet(); return true; }
  if ($("hf-overlay").classList.contains("open")) { closeHfSettings(); return true; }
  const samplePop = $("chat-sampling-pop");
  if (samplePop && samplePop.classList.contains("open") && samplingPopoverClose) { samplingPopoverClose(); return true; }
  const sysPop = $("chat-sysprompt-pop");
  if (sysPop && sysPop.classList.contains("open") && sysPromptPopoverClose) { sysPromptPopoverClose(); return true; }
  const memOverlay = $("mem-overlay");
  if (memOverlay && memOverlay.classList.contains("open") && memPanelClose) { memPanelClose(); return true; }
  const adaptersOverlay = $("adapters-overlay");
  if (adaptersOverlay && adaptersOverlay.classList.contains("open") && adaptersPanelClose) { adaptersPanelClose(); return true; }
  const modelPop = $("model-pop");
  if (modelPop && modelPop.classList.contains("open") && modelPopClose) { modelPopClose(); return true; }
  if ($("chat-sidebar").classList.contains("drawer-open")) { closeDrawer(); return true; }
  return false;
}

export function initGlobalKeydown(): void {
  document.addEventListener("keydown", (e) => {
    const mod = e.metaKey || e.ctrlKey;
    // Cmd/Ctrl+/ — shortcut sheet. Not a browser-reserved combo.
    if (mod && e.key === "/") { e.preventDefault(); $("shortcut-overlay").classList.contains("open") ? closeShortcutSheet() : openShortcutSheet(); return; }
    // Cmd/Ctrl+Shift+O — new chat. (Ctrl+Shift+O is free in every major
    // browser; Cmd+Shift+O has no macOS Safari/Chrome reservation either.)
    if (mod && e.shiftKey && (e.key === "O" || e.key === "o")) {
      if (currentRoute() !== "chat") return; // no-op off the chat route
      e.preventDefault();
      const newChat = controllers.chat && controllers.chat.newChat as (() => void) | undefined;
      newChat && newChat();
      return;
    }
    // Cmd/Ctrl+Shift+C — copy last response. Reuses the wave-3 copy action.
    if (mod && e.shiftKey && (e.key === "C" || e.key === "c")) {
      if (currentRoute() !== "chat") return;
      e.preventDefault();
      const copyLastResponse = controllers.chat && controllers.chat.copyLastResponse as (() => void) | undefined;
      copyLastResponse && copyLastResponse();
      return;
    }
    // Shift+Escape — focus the composer (skipped while already typing
    // somewhere else that isn't the composer, so it doesn't steal focus
    // from e.g. the HF token field — but Escape's own overlay-close below
    // still fires first via closeTopOverlay for the "any open thing" case).
    if (e.shiftKey && e.key === "Escape") {
      if (currentRoute() !== "chat") return;
      e.preventDefault();
      $("chat-box").focus();
      return;
    }
    // Escape alone — close whatever overlay is open, with focus restored to
    // its trigger. Never shadows a plain Escape when nothing is open (e.g.
    // the composer's own Escape-to-cancel-edit keeps working, since
    // closeTopOverlay simply returns false and this handler does nothing else).
    if (e.key === "Escape" && !e.shiftKey && !mod) {
      closeTopOverlay();
    }
  });
}

/* ════════════════════════════════════════════════════════════════════
   DEVELOPER TOGGLE (plan §8/§9 Phase 2) — Chat is the product; Quantize /
   Fine-tune / Build Dataset / Status / Curves / Routes are developer tools
   that collapse behind one nav switch. Persisted; default OFF for a fresh
   browser, but default ON (once) when ANY pre-existing mlxbun.* localStorage
   key is found — an existing user never has tabs yanked out from under
   them. Deep links still work: entering a dev route with the toggle off
   flips it on (capability is never unreachable, just not the default view).
   ════════════════════════════════════════════════════════════════════ */
const DEV_KEY = "mlxbun.developer";
/** Dev-only tabs, matching data-tab on the <a class="tab"> elements in nav
 *  (routes' visibility is further gated by the /dag probe below). "curves"
 *  is listed for applyDeveloperMode's DOM sweep even though it can never be
 *  a `Route` — it's a full-page href, not hash-routed, so
 *  ensureDeveloperModeFor(route: Route) below can never match it; a direct
 *  /curves visit reaches a real page load, not the SPA router, so there's
 *  no deep-link case to flip the toggle for. */
const DEV_TABS = ["quantize", "finetune", "dataset", "status", "curves", "routes"] as const;

/** True if any OTHER mlxbun.* key already exists — i.e. this is a returning
 *  user of the app, not a fresh browser profile. Checked BEFORE writing the
 *  developer key itself, so it can't self-detect on a later load. */
function hasExistingMlxbunState(): boolean {
  for (let i = 0; i < localStorage.length; i++) {
    const k = localStorage.key(i);
    if (k && k.startsWith("mlxbun.") && k !== DEV_KEY) return true;
  }
  return false;
}

export function isDeveloperMode(): boolean {
  const saved = localStorage.getItem(DEV_KEY);
  if (saved != null) return saved === "1";
  // First-ever read: decide + persist the one-time default so it's stable
  // across reloads (a fresh browser stays OFF; an existing user's tabs
  // don't flicker between "on" and "off" from the detection re-running).
  const on = hasExistingMlxbunState();
  localStorage.setItem(DEV_KEY, on ? "1" : "0");
  return on;
}

/** Reflect developer mode into the DOM: dev-tab visibility + the toggle's
 *  own pressed state. Safe to call before /dag has been probed — the
 *  routes tab's extra hide (see initRoutesProbe) is independent and only
 *  ever hides further, never re-shows a tab this function would show. */
function applyDeveloperMode(on: boolean): void {
  document.querySelectorAll<HTMLElement>("nav .tab[data-dev]").forEach((t) => {
    // Once /dag has been probed and failed, routes stays hidden regardless
    // of developer mode (dataset routesUnavailable === "1" marks that).
    if (t.dataset.tab === "routes" && t.dataset.routesUnavailable === "1") { t.style.display = "none"; return; }
    t.style.display = on ? "" : "none";
  });
  const btn = $("nav-developer");
  if (btn) btn.setAttribute("aria-checked", on ? "true" : "false");
  const dot = document.getElementById("nav-developer-dot");
  if (dot) dot.classList.toggle("on", on);
  updateTabFades();
}

export function setDeveloperMode(on: boolean): void {
  localStorage.setItem(DEV_KEY, on ? "1" : "0");
  applyDeveloperMode(on);
}

/** Called by the router when a deep link (or brand-new hash) lands on a
 *  dev-only route while developer mode is off — capability must never be
 *  unreachable just because the toggle defaulted off (plan §8). Flips the
 *  preference on (persisted, not a one-time peek) so the tab row itself
 *  stops looking broken/mismatched with what's showing. */
function ensureDeveloperModeFor(route: Route): void {
  if ((DEV_TABS as readonly string[]).includes(route) && !isDeveloperMode()) setDeveloperMode(true);
}

export function initDeveloperToggle(): void {
  applyDeveloperMode(isDeveloperMode());
  const btn = $("nav-developer");
  if (btn) btn.onclick = () => setDeveloperMode(!isDeveloperMode());
}

/* ── Routes tab feature-detection (web-ui-pass-plan.md #17) ──
   /dag readFileSync's a repo-relative doc that's absent from compiled
   binaries/npm installs. Probe once at boot with a HEAD request; on 404
   hide the Routes tab entirely (rather than leaving a dead link that
   iframes a raw 404) and, if the user is already sitting on #/routes, swap
   in a graceful in-app note instead of the broken iframe. Could instead
   embed the artifact server-side like app.html's /curves fallback does —
   left as server.ts territory, not touched here. */
export async function initRoutesProbe(): Promise<void> {
  const tab = document.querySelector<HTMLElement>('nav .tab[data-tab="routes"]');
  let ok = true;
  try {
    const r = await fetch("/dag", { method: "HEAD" });
    ok = r.ok;
  } catch { ok = false; }
  if (ok) return;
  if (tab) { tab.dataset.routesUnavailable = "1"; tab.style.display = "none"; }
  const section = $("s-routes");
  if (section) {
    section.innerHTML =
      '<div class="wrap" style="max-width:640px;margin:60px auto;text-align:center;color:var(--dim)">' +
      "<h2>Routes map unavailable</h2>" +
      "<p>The training/inference route diagram ships alongside the repo checkout " +
      "and isn't bundled into this build.</p></div>";
  }
  // If a deep link landed here directly, bounce to chat rather than sit on
  // an orphaned nav state with no visible tab pointing at it.
  if (currentRoute() === "routes") location.replace("#/chat");
}

/* ════════════════════════════════════════════════════════════════════
   ROUTER  — toggles section[data-route]; lazily inits each controller.
   ════════════════════════════════════════════════════════════════════ */
export const ROUTES = ["chat", "quantize", "finetune", "dataset", "status", "routes"] as const;
export type Route = typeof ROUTES[number];

/** A tab controller: init() runs once (lazy, on first enter); enter()/leave()
 *  run every time the route is (de)activated. Extra fields (refreshAdapters,
 *  newChat, copyLastResponse, refreshLibrary) are controller-specific
 *  cross-calls other controllers use — kept loose (unknown) here since the
 *  registry is shared infrastructure, not a single controller's contract. */
export interface Controller {
  init?(): void;
  enter?(): void;
  leave?(): void;
  [extra: string]: unknown;
}

const inited: Partial<Record<Route, boolean>> = {};
/** name -> { init, enter, leave }. Populated by main.ts in the exact order
 *  the original inline script declared controllers.chat/.quantize/.finetune/
 *  .dataset/.status — load-bearing for the module-init side effects each
 *  IIFE ran at declaration time (e.g. chat's samplingPopoverClose wiring). */
export const controllers: Partial<Record<Route, Controller>> = {};

export function currentRoute(): Route {
  const h = (location.hash || "").replace(/^#\/?/, "").split("?")[0] || "";
  return (ROUTES as readonly string[]).includes(h) ? (h as Route) : "chat";
}

export function router(): void {
  const route = currentRoute();
  ensureDeveloperModeFor(route); // deep link to a dev tab always flips the toggle on
  document.querySelectorAll<HTMLElement>("section[data-route]").forEach((s) => {
    const on = s.dataset.route === route;
    if (on && !s.classList.contains("active")) {
      s.classList.add("active");
      const c = controllers[route];
      if (c) { if (!inited[route]) { inited[route] = true; c.init && c.init(); } c.enter && c.enter(); }
    } else if (!on && s.classList.contains("active")) {
      s.classList.remove("active");
      const c = controllers[s.dataset.route as Route];
      if (c && c.leave) c.leave();
    }
  });
  document.querySelectorAll<HTMLElement>("nav .tab").forEach((t) => t.classList.toggle("active", t.dataset.tab === route));
  // dim the ambient bloom slightly in the chat workspace so text reads cleanly
  $("bloom").style.opacity = route === "chat" ? "0.55" : "1";
  // The mobile drawer hamburger only makes sense on /chat (it opens the
  // recent-chats sidebar, which only exists there) — CSS already hides it
  // >=760px; this hides it off-route regardless of viewport width.
  $("chat-hamburger").style.display = route === "chat" ? "" : "none";
  if (route !== "chat") closeDrawer();
}

/* Nav-tab scroll-edge fades (2026-07-06 jank fix): the tab row scrolls with
   its scrollbar hidden, so overflow read as clipped/broken text. Toggle
   .fade-r/.fade-l so the CSS mask signals "more this way" only when true. */
export function updateTabFades(): void {
  const t = $("tabs");
  const over = t.scrollWidth - t.clientWidth > 1;
  t.classList.toggle("fade-r", over && t.scrollLeft + t.clientWidth < t.scrollWidth - 1);
  t.classList.toggle("fade-l", over && t.scrollLeft > 1);
}

export function initRouter(): void {
  window.addEventListener("hashchange", router);
  $("tabs").addEventListener("scroll", updateTabFades, { passive: true });
  window.addEventListener("resize", updateTabFades);
  updateTabFades();
}

/* ════════════════════════════════════════════════════════════════════
   GLOBAL CONNECTION PILL + MODEL ID  (polled lightly, always on)
   ════════════════════════════════════════════════════════════════════ */
export let activeModelId: string | null = null;

export function setConn(state: string, text: string): void {
  const p = $("nav-conn");
  p.className = "pill " + (state || "");
  $("nav-conn-text").textContent = text;
}

let defaultHelloSub: string | null = null;

export async function pollIdentity(): Promise<void> {
  try {
    const [models, dl] = await Promise.all([
      fetch("/v1/models").then((r) => r.json()),
      fetch("/downloads").then((r) => r.json()).catch(() => ({ downloads: [] })),
    ]);
    activeModelId = models.data && models.data[0] ? models.data[0].id : null;
    $("nav-model").textContent = activeModelId || "no model";
    setConn("ok", "live · localhost");
    updateDownloadIndicator((dl && dl.downloads) || []);
  } catch {
    $("nav-model").textContent = "server unreachable";
    setConn("bad", "unreachable — retrying");
  }
}

interface DownloadInfo {
  state: string;
  repoId: string;
  totalBytes?: number;
  receivedBytes?: number;
}

/** Surface a background model download — the "bigger model arriving while you
 *  chat on the starter" case — as a live nav pill plus a download-aware
 *  greeting in the empty chat state. Hidden when nothing else is downloading. */
export function updateDownloadIndicator(downloads: DownloadInfo[]): void {
  const sub = $("chat-hello-sub");
  if (sub && defaultHelloSub === null) defaultHelloSub = sub.textContent;
  const incoming = downloads.find((d) => d.state === "active" && d.repoId !== activeModelId);
  const pill = $("nav-download");
  if (incoming) {
    const pct = incoming.totalBytes ? Math.floor(((incoming.receivedBytes || 0) / incoming.totalBytes) * 100) : 0;
    const name = incoming.repoId.split("/").pop();
    $("nav-download-text").textContent = "↓ " + name + " · " + pct + "%";
    pill.style.display = "";
    if (sub) sub.textContent = "You're on a small, fast starter model so you can chat right now — a more capable one (" + name + ") is downloading and takes over next launch. Ask me anything, or about mlx-bun itself.";
  } else {
    pill.style.display = "none";
    if (sub && defaultHelloSub !== null) sub.textContent = defaultHelloSub;
  }
}
