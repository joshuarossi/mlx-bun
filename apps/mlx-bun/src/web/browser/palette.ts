// Command palette (Cmd/Ctrl+K) — plan §9 Phase 3, beat-matrix Axis 10
// "Command palette" row: ChatGPT/Claude's universal "do anything" entry
// point. Built 100% via createElement (zero app.html markup — a parallel
// agent owns chat.ts/app.html this wave); its own CSS is injected once via
// shell.ts's injectStyles() the same way the panel it opens (hub.ts) has
// its markup live in app.html but this module can't add any of its own.
//
// Actions call EXPORTED functions from the modules that own the behavior
// (newChat/copyLastResponse via controllers.chat — the same
// loosely-typed-registry indirection shell.ts's own global keydown sweep
// and finetune.ts already use to reach chat.ts without a direct import;
// openMemPanel/openHubPanel are plain exports; theme/developer-mode toggles
// are plain exports; thinking-toggle and session-open reuse the existing
// DOM click handlers chat.ts/sessions.ts already wired, via a `.click()` on
// the real control — never a copy of chat.ts's logic).
//
// Full-text "Search messages" delegates to the same GET /api/sessions/search
// endpoint sessions.ts's sidebar fallback uses (src/serve/session-search.ts)
// — one server-side implementation, two presentations.

import { controllers, currentRoute, el, injectStyles, isDeveloperMode, setDeveloperMode, setPaletteClose, setPaletteIsOpen, setPaletteOpen, setTheme, trapFocus, type FocusTrap } from "./shell";
import { openSessionRowByPath, exportSession } from "./sessions";
import { openMemPanel } from "./memory-panel";
import { openHubPanel } from "./hub";
import { api } from "./api";

/* ────────────────────────────────────────────────────────────────────
   Action model
   ──────────────────────────────────────────────────────────────────── */

interface PaletteAction {
  id: string;
  label: string;
  hint?: string;
  /** Actions that only make sense on the chat route are hidden elsewhere
   *  (matching the existing Cmd/Ctrl+Shift+O/C guards in shell.ts). */
  chatOnly?: boolean;
  run(): void | Promise<void>;
}

/** Pure: the static action list, independent of any live session data —
 *  independently testable (tests/using/web-app.test.ts asserts labels/ids without
 *  needing a DOM). Session rows and message-search hits are appended
 *  dynamically in refreshResults() below, not part of this list. */
export function staticActions(): PaletteAction[] {
  return [
    {
      id: "new-chat", label: "New chat", hint: "⌘⇧O", chatOnly: true,
      run() { const fn = controllers.chat && controllers.chat.newChat as (() => void) | undefined; fn && fn(); },
    },
    {
      id: "toggle-thinking", label: "Toggle thinking", chatOnly: true,
      run() { const btn = document.getElementById("chat-think"); if (btn) btn.click(); },
    },
    {
      id: "toggle-theme", label: "Toggle theme",
      run() {
        const order = ["auto", "dark", "light"];
        const active = document.querySelector<HTMLButtonElement>("#theme-toggle button.active");
        const cur = (active && active.dataset.themeChoice) || "auto";
        const next = order[(order.indexOf(cur) + 1) % order.length]!;
        setTheme(next);
      },
    },
    {
      id: "toggle-developer", label: "Toggle Developer mode",
      run() { setDeveloperMode(!isDeveloperMode()); },
    },
    {
      id: "open-memory", label: "Open Memory panel",
      run() { openMemPanel(); },
    },
    {
      id: "browse-models", label: "Browse models (Hub)",
      run() { openHubPanel(); },
    },
    {
      id: "open-shortcuts", label: "Open shortcut sheet",
      run() {
        const btn = document.getElementById("nav-shortcuts");
        if (btn) btn.click();
      },
    },
    {
      id: "export-chat", label: "Export this chat", chatOnly: true,
      async run() {
        const activeRow = document.querySelector<HTMLElement>("#chat-sessions .sess.active");
        if (!activeRow || !activeRow.dataset.path) return;
        const title = activeRow.querySelector(".stitle")?.textContent || "chat";
        await exportSession(activeRow.dataset.path, title, "md");
      },
    },
  ];
}

/** Fuzzy-ish filter: every character of `query` (in order, case-insensitive)
 *  must appear as a subsequence of the candidate string. Pure. Matches the
 *  lightweight "fuzzy-filterable" bar the task calls for — not a scored
 *  fuzzy-match algorithm, a simple subsequence test, which is what every
 *  Cmd+K palette's basic case actually needs. */
export function fuzzyMatch(query: string, candidate: string): boolean {
  const q = query.toLowerCase();
  const c = candidate.toLowerCase();
  if (!q) return true;
  let qi = 0;
  for (let ci = 0; ci < c.length && qi < q.length; ci++) {
    if (c[ci] === q[qi]) qi++;
  }
  return qi === q.length;
}

/* ────────────────────────────────────────────────────────────────────
   Row shapes for the two dynamic sections (session titles / message hits)
   ──────────────────────────────────────────────────────────────────── */

interface SessionRowRef { path: string; title: string; }
interface MessageHit { sessionPath: string; sessionTitle: string; snippet: string; }

type PaletteEntry =
  | { kind: "action"; action: PaletteAction }
  | { kind: "session"; row: SessionRowRef }
  | { kind: "message"; hit: MessageHit };

/* ────────────────────────────────────────────────────────────────────
   Panel chrome
   ──────────────────────────────────────────────────────────────────── */

let overlay: HTMLElement | null = null;
let input: HTMLInputElement | null = null;
let listEl: HTMLElement | null = null;
let trap: FocusTrap | null = null;
let selectedIndex = 0;
let entries: PaletteEntry[] = [];
let searchSeq = 0;
let debounceTimer: ReturnType<typeof setTimeout> | undefined;

const STYLE_ID = "mlxbun-palette-style";
const DEBOUNCE_MS = 200;

function injectPaletteStyles(): void {
  injectStyles(STYLE_ID, `
#palette-overlay{position:fixed;inset:0;z-index:900;display:none;
  align-items:flex-start;justify-content:center;padding-top:12vh;
  background:rgba(0,0,0,.45);backdrop-filter:blur(2px);}
#palette-overlay.open{display:flex;}
@media (prefers-reduced-motion:no-preference){
  #palette-overlay.open .palette-box{animation:palette-in .15s ease-out;}
}
@keyframes palette-in{from{opacity:0;transform:translateY(-6px) scale(.98);}to{opacity:1;transform:none;}}
.palette-box{width:min(560px,92vw);max-height:70vh;display:flex;flex-direction:column;
  background:var(--bg,#000);border:1px solid var(--hairline-strong,rgba(255,255,255,.28));
  border-radius:14px;box-shadow:0 20px 60px rgba(0,0,0,.5);overflow:hidden;}
.palette-input-row{border-bottom:1px solid var(--hairline,rgba(255,255,255,.14));padding:4px 4px;}
#palette-input{width:100%;box-sizing:border-box;background:transparent;border:0;outline:0;
  color:var(--ink,#fff);font-size:15px;padding:12px 14px;}
#palette-input::placeholder{color:var(--dimmer,#515154);}
.palette-list{overflow-y:auto;flex:1;padding:6px;}
.palette-section-hdr{font-size:11px;color:var(--dim,#86868b);text-transform:uppercase;
  letter-spacing:.04em;padding:8px 10px 4px;}
.palette-row{display:flex;align-items:center;justify-content:space-between;gap:8px;
  padding:9px 10px;border-radius:8px;cursor:pointer;color:var(--ink,#fff);font-size:13.5px;}
.palette-row:hover,.palette-row.active{background:var(--card-hover,rgba(255,255,255,.08));}
.palette-row .prow-label{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.palette-row .prow-snippet{color:var(--dim,#86868b);font-size:11.5px;overflow:hidden;
  text-overflow:ellipsis;white-space:nowrap;margin-top:1px;}
.palette-row .prow-main{min-width:0;flex:1;}
.palette-row .prow-hint{color:var(--dimmer,#515154);font-size:11px;font-family:var(--mono,monospace);
  flex:0 0 auto;}
.palette-empty{color:var(--dim,#86868b);font-size:13px;padding:16px 10px;text-align:center;}
.palette-row mark{background:rgba(255,214,10,.35);color:inherit;border-radius:2px;}
`);
}

export function isPaletteOpen(): boolean {
  return !!overlay && overlay.classList.contains("open");
}

export function closePalette(): void {
  if (!overlay) return;
  overlay.classList.remove("open");
  if (trap) trap.restore();
}

export function openPalette(): void {
  ensureBuilt();
  if (!overlay || !input || !trap) return;
  trap.capture();
  overlay.classList.add("open");
  input.value = "";
  refreshResults("");
  setTimeout(() => input && input.focus(), 20);
}

function ensureBuilt(): void {
  if (overlay) return;
  injectPaletteStyles();
  overlay = el("div", "", document.body);
  overlay.id = "palette-overlay";
  overlay.setAttribute("role", "dialog");
  overlay.setAttribute("aria-modal", "true");
  overlay.setAttribute("aria-label", "Command palette");

  const box = el("div", "palette-box", overlay);
  const inputRow = el("div", "palette-input-row", box);
  input = el("input", "", inputRow);
  input.id = "palette-input";
  input.type = "text";
  input.placeholder = "Type a command or search…";
  input.autocomplete = "off";
  input.spellcheck = false;
  listEl = el("div", "palette-list", box);
  listEl.setAttribute("role", "listbox");

  overlay.addEventListener("click", (e) => { if (e.target === overlay) closePalette(); });
  input.addEventListener("input", () => {
    if (debounceTimer) clearTimeout(debounceTimer);
    const q = input!.value;
    debounceTimer = setTimeout(() => refreshResults(q), DEBOUNCE_MS);
  });
  input.addEventListener("keydown", onKeydown);

  trap = trapFocus(overlay, isPaletteOpen);
}

function onKeydown(e: KeyboardEvent): void {
  if (e.key === "ArrowDown") { e.preventDefault(); move(1); return; }
  if (e.key === "ArrowUp") { e.preventDefault(); move(-1); return; }
  if (e.key === "Enter") { e.preventDefault(); activate(selectedIndex); return; }
  // Escape is handled by shell.ts's global closeTopOverlay sweep (this
  // module registers isOpen/close via setPaletteIsOpen/setPaletteClose in
  // ensureBuilt() above) — no bespoke Escape listener needed here.
}

function move(delta: number): void {
  if (!entries.length) return;
  selectedIndex = (selectedIndex + delta + entries.length) % entries.length;
  renderRows();
  const activeEl = listEl?.querySelector(".palette-row.active");
  if (activeEl) activeEl.scrollIntoView({ block: "nearest" });
}

function activate(index: number): void {
  const entry = entries[index];
  if (!entry) return;
  if (entry.kind === "action") { closePalette(); entry.action.run(); return; }
  if (entry.kind === "session") { closePalette(); openSessionRowByPath(entry.row.path); return; }
  if (entry.kind === "message") { closePalette(); openSessionRowByPath(entry.hit.sessionPath); return; }
}

/* ────────────────────────────────────────────────────────────────────
   Results: static actions (fuzzy-filtered) + session title matches +
   full-text message matches (debounced server round trip).
   ──────────────────────────────────────────────────────────────────── */

function matchingActions(query: string): PaletteAction[] {
  const onChat = currentRoute() === "chat";
  return staticActions()
    .filter((a) => (onChat || !a.chatOnly))
    .filter((a) => fuzzyMatch(query, a.label));
}

function matchingSessionRows(query: string): SessionRowRef[] {
  const rows = document.querySelectorAll<HTMLElement>("#chat-sessions .sess");
  const out: SessionRowRef[] = [];
  rows.forEach((row) => {
    const title = row.querySelector(".stitle")?.textContent || "New chat";
    const path = row.dataset.path;
    if (!path) return;
    if (fuzzyMatch(query, title)) out.push({ path, title });
  });
  return out.slice(0, 6);
}

async function refreshResults(query: string): Promise<void> {
  selectedIndex = 0;
  const q = query.trim();
  const actionEntries: PaletteEntry[] = matchingActions(q).map((action) => ({ kind: "action", action }));
  const sessionEntries: PaletteEntry[] = q ? matchingSessionRows(q).map((row) => ({ kind: "session", row })) : [];
  entries = [...actionEntries, ...sessionEntries];
  renderRows();

  if (!q || q.length < 2) return;
  const seq = ++searchSeq;
  const d = await api("/api/sessions/search?q=" + encodeURIComponent(q)).catch(() => ({ ok: false } as { ok: boolean }));
  if (seq !== searchSeq) return; // superseded by a newer keystroke
  if (input && input.value.trim() !== q) return;
  const body = d as { ok: boolean; results?: Array<{ sessionPath: string; sessionTitle: string; matches: Array<{ snippet: string }> }> };
  if (!body.ok || !body.results || !body.results.length) return;
  const messageEntries: PaletteEntry[] = body.results.slice(0, 6).map((r) => ({
    kind: "message",
    hit: { sessionPath: r.sessionPath, sessionTitle: r.sessionTitle, snippet: r.matches[0]?.snippet || "" },
  }));
  entries = [...actionEntries, ...sessionEntries, ...messageEntries];
  renderRows();
}

function esc(s: unknown): string {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);
}

function renderRows(): void {
  if (!listEl) return;
  if (!entries.length) {
    listEl.innerHTML = '<div class="palette-empty">No matching commands or chats.</div>';
    return;
  }
  listEl.innerHTML = "";
  let sawActionHdr = false, sawSessionHdr = false, sawMessageHdr = false;
  entries.forEach((entry, i) => {
    if (entry.kind === "action" && !sawActionHdr) { el("div", "palette-section-hdr", listEl!).textContent = "Commands"; sawActionHdr = true; }
    if (entry.kind === "session" && !sawSessionHdr) { el("div", "palette-section-hdr", listEl!).textContent = "Chats"; sawSessionHdr = true; }
    if (entry.kind === "message" && !sawMessageHdr) { el("div", "palette-section-hdr", listEl!).textContent = "In messages"; sawMessageHdr = true; }

    const row = el("div", "palette-row" + (i === selectedIndex ? " active" : ""), listEl!);
    row.setAttribute("role", "option");
    row.dataset.index = String(i);
    if (entry.kind === "action") {
      row.innerHTML =
        '<div class="prow-main"><div class="prow-label">' + esc(entry.action.label) + '</div></div>' +
        (entry.action.hint ? '<span class="prow-hint">' + esc(entry.action.hint) + '</span>' : "");
    } else if (entry.kind === "session") {
      row.innerHTML = '<div class="prow-main"><div class="prow-label">' + esc(entry.row.title) + '</div></div>';
    } else {
      row.innerHTML =
        '<div class="prow-main"><div class="prow-label">' + esc(entry.hit.sessionTitle) + '</div>' +
        '<div class="prow-snippet">' + esc(entry.hit.snippet) + '</div></div>';
    }
    row.addEventListener("click", () => activate(i));
    row.addEventListener("mousemove", () => { if (selectedIndex !== i) { selectedIndex = i; renderRows(); } });
  });
}

/** Wire the palette module: styles + registered callbacks so shell.ts's
 *  Cmd/Ctrl+K binding and Escape sweep can reach it. Call once at boot
 *  (main.ts), same lifecycle as initHubPanel()/initMemoryPanel(). Building
 *  the DOM itself is deferred to the first open (ensureBuilt(), called from
 *  openPalette()) so a browser session that never opens the palette pays
 *  zero DOM cost for it — consistent with the other overlays' lazy-init
 *  posture is NOT how they work today (they build eagerly at init()), but
 *  this module has no app.html anchor element to hang an eager build off
 *  of, so lazy-on-first-open is the natural shape here instead. */
export function initPalette(): void {
  setPaletteClose(closePalette);
  setPaletteIsOpen(isPaletteOpen);
  setPaletteOpen(openPalette);
}
