// The app's shell glue: what the page needs around the generic web shell (`@mlx-bun/web-shell`, which owns
// navigation, hash routing, theme, the Developer switch, the shortcut sheet, the Escape overlay sweep, panel mounting
// and the palette chrome). Here: the app's routes and chrome hooks, the Hugging Face token settings and the shared
// push-to-hub flow, the agent-tools settings (the chat panel's host side), the overlays and key bindings that reach the
// chat panel, the connection pill and model identity polling, and the routes-map probe. The generic helpers the
// per-page modules import from here are re-exported from the shell package. main.ts holds the boot order.

import { $, createShell, toast, trapFocus, type FocusTrap, type Overlay, type Palette, type RouteController } from "@mlx-bun/web-shell";
import { api } from "./api";
import type { ApiEnvelope } from "./protocol";

export { $, el, injectStyles, toast, trapFocus, type FocusTrap } from "@mlx-bun/web-shell";
export type Controller = RouteController;

/* ════════════════════════════════════════════════════════════════════
   THE SHELL — the app's pages and the chrome that depends on the page
   ════════════════════════════════════════════════════════════════════ */
/** The chat panel element's public methods, as the app calls them (the panel is `@mlx-bun/module-chat`'s: the shell mounts
 * it as the first page, and the app reaches it through the element, never through an import). */
export interface ChatPanelApi extends HTMLElement {
  newChat(): void;
  copyLastResponse(): void;
  setCodingTools(enabled: boolean): void;
  refreshAdapters(): void;
  focusComposer(): void;
  toggleThinking(): void;
  recentChats(): { title: string; path: string }[];
  openSession(path: string): boolean;
  exportActiveChat(format?: "md" | "json"): Promise<void>;
  toggleDrawer(): void;
  closeDrawer(): void;
  drawerOpen(): boolean;
  popoverOpen(): boolean;
  closePopover(): boolean;
}
/** The mounted chat panel, once the shell has created it (it does on the first visit, which is the home page's). */
export const chatPanel = (): ChatPanelApi | null => document.querySelector<ChatPanelApi>("mlx-chat-panel");

/** The chat is the product (a workspace panel the shell mounts first); the pages below are developer tools behind the nav's Developer switch. */
export const shell = createShell({
  routes: [
    { id: "quantize", developer: true }, { id: "finetune", developer: true },
    { id: "dataset", developer: true }, { id: "status", developer: true }, { id: "routes", developer: true },
  ],
  home: "chat",
  onRoute(route) {
    // dim the ambient bloom slightly in the chat workspace so text reads cleanly
    $("bloom").style.opacity = route === "chat" ? "0.55" : "1";
    // The mobile drawer hamburger only makes sense on /chat (it opens the recent-chats sidebar, which only exists
    // there): CSS hides it >=760px; this hides it off-route regardless of viewport width.
    $("chat-hamburger").style.display = route === "chat" ? "" : "none";
    if (route !== "chat") chatPanel()?.closeDrawer();
  },
});
/** Page controllers by route id, populated by main.ts; pages reach each other through it. */
export const controllers = shell.controllers;
export const currentRoute = (): string => shell.currentRoute();
export const isDeveloperMode = (): boolean => shell.isDeveloperMode();
export const setDeveloperMode = (on: boolean): void => shell.setDeveloperMode(on);

/* ════════════════════════════════════════════════════════════════════
   SHARED HELPERS
   ════════════════════════════════════════════════════════════════════ */
export const gb = (b: number | null | undefined): string => b == null ? "—" : (b / 2 ** 30).toFixed(2) + " GB";
export const mb = (b: number | null | undefined): string => b == null ? "—" : (b / 2 ** 20).toFixed(1) + " MB";
export const num = (n: number | null | undefined): string => n == null ? "—" : Math.round(n).toLocaleString();

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
 *  Agent tools section — see the block below;
 *  kept in this same init function since it's one modal, one open/close
 *  lifecycle, one focus trap. */
export function initHfSettings(): void {
  $("nav-hf").onclick = openHfSettings;
  $("hf-close").onclick = closeHfSettings;
  $("hf-save").onclick = saveHfToken;
  $("hf-overlay").addEventListener("click", (e) => { if (e.target === $("hf-overlay")) closeHfSettings(); });
  $("hf-token-input").addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter") saveHfToken(); });
  // Escape is handled globally by the shell's overlay sweep (one
  // Escape mechanism for every popover/overlay, not a bespoke one per modal).
  hfOverlayTrap = trapFocus($("hf-overlay"), () => $("hf-overlay").classList.contains("open"));
  refreshHfGear();
  initCodingToolsToggle();
}

/* ════════════════════════════════════════════════════════════════════
   AGENT TOOLS SETTINGS — the codingTools
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

/** Wire the checkbox; the actual set_coding_tools WS send is the chat panel's (`setCodingTools`), since this file owns no
 *  WebSocket. Until the panel exists, localStorage still records the preference (the panel re-sends it on every `ready`
 *  frame), so nothing is lost. */
function initCodingToolsToggle(): void {
  const cb = $("settings-coding-tools") as HTMLInputElement | null;
  if (!cb) return;
  cb.checked = storedCodingToolsPreference();
  cb.onchange = () => {
    const on = cb.checked;
    setStoredCodingToolsPreference(on);
    chatPanel()?.setCodingTools(on);
  };
}

/* ════════════════════════════════════════════════════════════════════
   MOBILE DRAWER — the chat's recent-chats sidebar is a slide-over on narrow viewports. The sidebar, its backdrop and
   its focus trap belong to the chat panel; this is the hamburger in the nav, which is app chrome (shown on the chat
   route only, see the shell's onRoute).
   ════════════════════════════════════════════════════════════════════ */
export function initDrawer(): void {
  $("chat-hamburger").onclick = () => chatPanel()?.toggleDrawer();
}

/** A registered close callback for the memory overlay (memory-panel.ts's initMemoryPanel()) — avoids a circular import (shell.ts
 *  is imported BY memory-panel.ts for $/trapFocus/etc., so shell.ts can't
 *  import memory-panel.ts's closeMemPanel back). */
export let memPanelClose: (() => void) | null = null;
export function setMemPanelClose(fn: (() => void) | null): void { memPanelClose = fn; }

/** Same pattern, for the model picker popover (model-picker.ts). */
export let modelPopClose: (() => void) | null = null;
export function setModelPopClose(fn: (() => void) | null): void { modelPopClose = fn; }

/** Same pattern, for the Model Hub panel (hub.ts) —
 *  opened from the model picker's "Browse models…" action. */
export let hubPanelClose: (() => void) | null = null;
export function setHubPanelClose(fn: (() => void) | null): void { hubPanelClose = fn; }

/** Registered by hub.ts's initHubPanel(); called by model-picker.ts's
 *  "Browse models…" button. Its own body is re-rendered via innerHTML on
 *  every popover open (see refreshModelPop()), so the button can't hold a
 *  handler bound once at boot the way the overlay-close callbacks above
 *  do — model-picker.ts re-wires the click to this registered function
 *  each time it re-renders instead. */
export let openHubFromModelPicker: (() => void) | null = null;
export function setOpenHubFromModelPicker(fn: (() => void) | null): void { openHubFromModelPicker = fn; }

/** The overlays Escape closes, in priority order (the shell adds its shortcut sheet first): each is open when its
 *  element carries `.open` and its page registered a close callback. */
export function registerOverlays(palette: Palette): void {
  const byId = (id: string, close: () => (() => void) | null): Overlay => ({
    isOpen: () => { const e = document.getElementById(id); return !!e && e.classList.contains("open") && close() !== null; },
    close: () => close()!(),
  });
  const add = (overlay: Overlay) => shell.overlays.add(overlay);
  add({ isOpen: () => $("hf-overlay").classList.contains("open"), close: closeHfSettings });
  // The chat panel's popovers (sampling, system prompt, adapter table) close themselves.
  add({ isOpen: () => !!chatPanel()?.popoverOpen(), close: () => { chatPanel()?.closePopover(); } });
  add(byId("mem-overlay", () => memPanelClose));
  add(byId("model-pop", () => modelPopClose));
  add(byId("hub-overlay", () => hubPanelClose));
  add(palette);
  add({ isOpen: () => !!chatPanel()?.drawerOpen(), close: () => chatPanel()?.closeDrawer() });
}

/** The chat's keyboard bindings, consulted after the shell's own. */
export function appKeys(e: KeyboardEvent): boolean {
  const mod = e.metaKey || e.ctrlKey;
  // Cmd/Ctrl+Shift+O: new chat. (Ctrl+Shift+O is free in every major browser; Cmd+Shift+O has no macOS Safari/Chrome reservation either.)
  if (mod && e.shiftKey && (e.key === "O" || e.key === "o")) {
    if (currentRoute() !== "chat") return true; // no-op off the chat route
    e.preventDefault();
    chatPanel()?.newChat();
    return true;
  }
  // Cmd/Ctrl+Shift+C: copy last response.
  if (mod && e.shiftKey && (e.key === "C" || e.key === "c")) {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    chatPanel()?.copyLastResponse();
    return true;
  }
  // Shift+Escape: focus the composer.
  if (e.shiftKey && e.key === "Escape") {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    chatPanel()?.focusComposer();
    return true;
  }
  return false;
}

/* ── Routes tab feature-detection ──
   /dag reads a repo-relative doc that is absent from compiled binaries and npm installs. Probe once at boot with a
   HEAD request; on 404 hide the Routes tab entirely (rather than leaving a dead link that iframes a raw 404) and, if
   the user is already sitting on #/routes, swap in a graceful in-app note instead of the broken iframe. */
export async function initRoutesProbe(): Promise<void> {
  let ok = true;
  try {
    const r = await fetch("/dag", { method: "HEAD" });
    ok = r.ok;
  } catch { ok = false; }
  if (ok) return;
  shell.markUnavailable("routes");
  const section = $("s-routes");
  if (section) {
    section.innerHTML =
      '<div class="wrap" style="max-width:640px;margin:60px auto;text-align:center;color:var(--dim)">' +
      "<h2>Routes map unavailable</h2>" +
      "<p>The training/inference route diagram ships alongside the repo checkout " +
      "and isn't bundled into this build.</p></div>";
  }
  // If a deep link landed here directly, bounce to chat rather than sit on an orphaned nav state with no visible tab pointing at it.
  if (currentRoute() === "routes") location.replace("#/chat");
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
    // The server marks the current model; a server that predates residency lists the served one first.
    const listed: { id: string; current?: boolean }[] = models.data || [];
    const served = listed.find((m) => m.current) || listed[0];
    const next = served ? served.id : null;
    const switched = activeModelId !== null && next !== null && next !== activeModelId;
    activeModelId = next;
    $("nav-model").textContent = activeModelId || "no model";
    // Chat reads the model's capabilities when it connects: an idle chat reconnects to pick them up.
    if (switched) window.dispatchEvent(new CustomEvent("mlx-model-changed", { detail: next }));
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
