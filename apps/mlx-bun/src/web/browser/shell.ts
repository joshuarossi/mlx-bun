// The app's shell glue: what the page needs around the generic web shell (`@mlx-bun/web-shell`, which owns
// navigation, hash routing, theme, the Developer switch, the shortcut sheet, the Escape overlay sweep, panel mounting
// and the palette chrome). Here: the app's routes and chrome hooks, the Hugging Face token settings and the shared
// push-to-hub flow, the agent-tools settings, the mobile chat drawer, the overlays and key bindings the chat needs,
// the connection pill and model identity polling, and the routes-map probe. The generic helpers the per-page modules
// import from here are re-exported from the shell package. main.ts holds the boot order.

import { $, createShell, toast, trapFocus, type FocusTrap, type Overlay, type Palette, type RouteController } from "@mlx-bun/web-shell";
import { api } from "./api";
import type { ApiEnvelope } from "./protocol";

export { $, el, injectStyles, toast, trapFocus, type FocusTrap } from "@mlx-bun/web-shell";
export type Controller = RouteController;

/* ════════════════════════════════════════════════════════════════════
   THE SHELL — the app's pages and the chrome that depends on the page
   ════════════════════════════════════════════════════════════════════ */
/** Chat is the product; the other pages are developer tools behind the nav's Developer switch. */
export const shell = createShell({
  routes: [
    { id: "chat" }, { id: "quantize", developer: true }, { id: "finetune", developer: true },
    { id: "dataset", developer: true }, { id: "status", developer: true }, { id: "routes", developer: true },
  ],
  home: "chat",
  onRoute(route) {
    // dim the ambient bloom slightly in the chat workspace so text reads cleanly
    $("bloom").style.opacity = route === "chat" ? "0.55" : "1";
    // The mobile drawer hamburger only makes sense on /chat (it opens the recent-chats sidebar, which only exists
    // there): CSS hides it >=760px; this hides it off-route regardless of viewport width.
    $("chat-hamburger").style.display = route === "chat" ? "" : "none";
    if (route !== "chat") closeDrawer();
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
   MOBILE DRAWER — chat sidebar becomes a
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
 *  the shell's Escape sweep close it without a second,
 *  divergent Escape listener living inside the controller. */
export let samplingPopoverClose: (() => void) | null = null;
export function setSamplingPopoverClose(fn: (() => void) | null): void { samplingPopoverClose = fn; }

/** Same registered-callback pattern as samplingPopoverClose above, used by
 *  memory-panel.ts's initMemoryPanel() — avoids a circular import (shell.ts
 *  is imported BY memory-panel.ts for $/trapFocus/etc., so shell.ts can't
 *  import memory-panel.ts's closeMemPanel back). */
export let memPanelClose: (() => void) | null = null;
export function setMemPanelClose(fn: (() => void) | null): void { memPanelClose = fn; }

/** Same pattern, for the adapter routing table overlay (adapters-panel.ts)
 *  — same circular-import reason as memPanelClose. */
export let adaptersPanelClose: (() => void) | null = null;
export function setAdaptersPanelClose(fn: (() => void) | null): void { adaptersPanelClose = fn; }

/** Same pattern, for the system-prompt popover (composer.ts's
 *  initSystemPrompt() — presets v1). */
export let sysPromptPopoverClose: (() => void) | null = null;
export function setSysPromptPopoverClose(fn: (() => void) | null): void { sysPromptPopoverClose = fn; }

/** The overlays Escape closes, in priority order (the shell adds its shortcut sheet first): each is open when its
 *  element carries `.open` and its page registered a close callback. */
export function registerOverlays(palette: Palette): void {
  const byId = (id: string, close: () => (() => void) | null): Overlay => ({
    isOpen: () => { const e = document.getElementById(id); return !!e && e.classList.contains("open") && close() !== null; },
    close: () => close()!(),
  });
  const add = (overlay: Overlay) => shell.overlays.add(overlay);
  add({ isOpen: () => $("hf-overlay").classList.contains("open"), close: closeHfSettings });
  add(byId("chat-sampling-pop", () => samplingPopoverClose));
  add(byId("chat-sysprompt-pop", () => sysPromptPopoverClose));
  add(byId("mem-overlay", () => memPanelClose));
  add(byId("adapters-overlay", () => adaptersPanelClose));
  add(palette);
  add({ isOpen: () => $("chat-sidebar").classList.contains("drawer-open"), close: closeDrawer });
}

/** The chat's keyboard bindings, consulted after the shell's own. */
export function appKeys(e: KeyboardEvent): boolean {
  const mod = e.metaKey || e.ctrlKey;
  // Cmd/Ctrl+Shift+O: new chat. (Ctrl+Shift+O is free in every major browser; Cmd+Shift+O has no macOS Safari/Chrome reservation either.)
  if (mod && e.shiftKey && (e.key === "O" || e.key === "o")) {
    if (currentRoute() !== "chat") return true; // no-op off the chat route
    e.preventDefault();
    const newChat = controllers.chat && controllers.chat.newChat as (() => void) | undefined;
    newChat && newChat();
    return true;
  }
  // Cmd/Ctrl+Shift+C: copy last response.
  if (mod && e.shiftKey && (e.key === "C" || e.key === "c")) {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    const copyLastResponse = controllers.chat && controllers.chat.copyLastResponse as (() => void) | undefined;
    copyLastResponse && copyLastResponse();
    return true;
  }
  // Shift+Escape: focus the composer.
  if (e.shiftKey && e.key === "Escape") {
    if (currentRoute() !== "chat") return true;
    e.preventDefault();
    $("chat-box").focus();
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

/** The nav's model label opens the Models panel (a page the shell mounts from the models module); a switch or an adapter change made
 * there re-reads the served model's identity at once instead of at the next poll. */
export function initModelLink(): void {
  $("nav-model").onclick = () => { location.hash = "#/models"; };
  document.addEventListener("mlx-models-changed", () => { void pollIdentity(); });
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
