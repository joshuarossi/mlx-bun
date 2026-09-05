// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// Recent-chats sidebar (list/search/fork/delete), the last-user-message
// sibling `< i/n >` toggle (edit-and-resend branching, plan §5.2), and the
// per-message action row (copy/regenerate/edit). Extracted from the
// original monolithic controllers.chat closure in app.html — behavior
// identical, but state that used to be closed-over local variables is now
// passed explicitly (SidebarState/SiblingState) so this module has no
// hidden coupling to chat.ts beyond what's passed in.
//
// Phase 3 additions (plan §9 Phase 3, beat-matrix Axis 10/11): full-text
// "in messages" search fallback below the title filter (GET
// /api/sessions/search, backed by src/serve/session-search.ts), an export
// action per session row (Markdown/JSON, via GET /api/sessions/export —
// path-validated server-side under sessionDir exactly like pi-web's
// isUnderSessionDir), and openSessionRowByPath(), the DOM-click bridge the
// command palette (palette.ts) uses to open a session without this module
// needing any reference back into chat.ts's WebSocket (chat.ts already
// wires each rendered `.sess` row's click to `onOpen` below — this just
// finds and clicks the right row instead of duplicating that send()).

import type { SessionListItem } from "../../contracts/pi";
import { $, el, injectStyles } from "./shell";
import { api } from "./api";

const SESSIONS_STYLE_ID = "mlxbun-sessions-style";

/** Injected once (shell.ts's injectStyles is idempotent per id): the small
 *  set of new classes this module's Phase 3 additions need
 *  (full-text-search fallback rows + the export micro-menu) that have no
 *  home in app.html's own <style> block, since this module doesn't touch
 *  that file. References the existing :root design tokens so it matches
 *  the current theme automatically. */
function injectSessionsStyles(): void {
  injectStyles(SESSIONS_STYLE_ID, `
.sess-msg-search{margin-top:6px;padding-top:6px;border-top:1px solid var(--hairline,rgba(255,255,255,.14));}
.sess-msg-search-hdr{font-size:11px;color:var(--dim,#86868b);text-transform:uppercase;
  letter-spacing:.04em;padding:4px 10px;}
.sess-msg-search-loading{color:var(--dim,#86868b);font-size:12px;padding:6px 10px;}
.sess-msg-hit{padding:7px 10px;border-radius:8px;cursor:pointer;}
.sess-msg-hit:hover{background:var(--card-hover,rgba(255,255,255,.08));}
.sess-msg-hit .stitle{font-size:12.5px;}
.sess-msg-snippet{color:var(--dim,#86868b);font-size:11px;overflow:hidden;text-overflow:ellipsis;
  white-space:nowrap;margin-top:2px;}
.sess-msg-snippet mark{background:rgba(255,214,10,.35);color:inherit;border-radius:2px;}
.sess-export-menu{position:fixed;z-index:950;background:var(--bg,#000);
  border:1px solid var(--hairline-strong,rgba(255,255,255,.28));border-radius:10px;
  box-shadow:0 12px 30px rgba(0,0,0,.4);overflow:hidden;min-width:150px;}
.sess-export-item{display:block;width:100%;box-sizing:border-box;appearance:none;background:none;
  border:0;text-align:left;color:var(--ink,#fff);font-size:12.5px;padding:9px 12px;cursor:pointer;}
.sess-export-item:hover{background:var(--card-hover,rgba(255,255,255,.08));}
`);
}

/* ────────────────────────────────────────────────────────────────────
   Sidebar (session list + search)
   ──────────────────────────────────────────────────────────────────── */

export interface SidebarCallbacks {
  onOpen(path: string): void;
  onFork(path: string): void;
  onDelete(path: string): void;
}

/** Mutable box so renderSessions/applySessSearch share the last-rendered
 *  item list without a module-level global (kept per chat-controller
 *  instance — there's only ever one, but this avoids reintroducing a
 *  bare module-level `let` for state that's really the controller's). */
export interface SidebarState {
  lastSessionItems: SessionListItem[];
}

export function newSidebarState(): SidebarState {
  return { lastSessionItems: [] };
}

function relTime(ms: number | undefined): string {
  if (!ms) return "";
  const s = (Date.now() - ms) / 1000;
  if (s < 60) return "just now";
  if (s < 3600) return Math.floor(s / 60) + "m ago";
  if (s < 86400) return Math.floor(s / 3600) + "h ago";
  if (s < 604800) return Math.floor(s / 86400) + "d ago";
  try { return new Date(ms).toLocaleDateString(); } catch { return ""; }
}

// Local esc() to avoid importing markdown.ts's whole surface just for
// escaping — identical logic.
function esc(s: unknown): string {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);
}

export function renderSessions(state: SidebarState, items: SessionListItem[] | undefined, activePath: string | undefined, cb: SidebarCallbacks): void {
  injectSessionsStyles();
  state.lastSessionItems = items || [];
  const box = $("chat-sessions");
  if (!items || !items.length) { box.innerHTML = '<div class="sessempty">No saved chats yet. Your conversations are saved locally here.</div>'; return; }
  box.innerHTML = "";
  for (const s of items) {
    const row = el("div", "sess" + (s.path === activePath ? " active" : ""), box);
    row.dataset.title = (s.title || "New chat").toLowerCase();
    row.dataset.path = s.path;
    row.innerHTML =
      '<div class="stitle">' + esc(s.title || "New chat") + '</div>' +
      '<div class="smeta"><span>' + esc(relTime(s.modified)) + '</span>' +
        (s.messageCount ? '<span>· ' + s.messageCount + ' msg' + (s.messageCount === 1 ? '' : 's') + '</span>' : '') +
        (s.forked ? '<span>· forked</span>' : '') + '</div>' +
      '<button class="sbtn sexport" title="Export this chat">⇩</button>' +
      '<button class="sbtn sfork" title="New chat from here">⑂</button>' +
      '<button class="sbtn sdel" title="Delete chat">✕</button>';
    row.addEventListener("click", () => { cb.onOpen(s.path); });
    row.querySelector(".sexport")!.addEventListener("click", (e) => { e.stopPropagation(); openExportMenu(row.querySelector(".sexport") as HTMLElement, s.path, s.title); });
    row.querySelector(".sfork")!.addEventListener("click", (e) => { e.stopPropagation(); cb.onFork(s.path); });
    row.querySelector(".sdel")!.addEventListener("click", (e) => { e.stopPropagation(); cb.onDelete(s.path); });
  }
  applySessSearch(state);
}

/** Find the rendered `.sess` row for `path` (present for every session —
 *  renderSessions draws the full list, title-search only hides rows via
 *  `.sess-hidden`) and click it, reusing chat.ts's existing onOpen wiring
 *  instead of this module needing its own WebSocket reference. Un-hides the
 *  row first so a click reaches an element that isn't `display:none`-adjacent
 *  (sess-hidden only dims/collapses via CSS, but clearing it keeps the
 *  sidebar visibly consistent with "this is the chat you're now in").
 *  Returns false (no-op) if the row isn't in the DOM yet (e.g. sessions
 *  frame hasn't arrived) — callers (palette.ts) treat that as "can't open
 *  yet", never a throw. */
export function openSessionRowByPath(path: string): boolean {
  const box = document.getElementById("chat-sessions");
  if (!box) return false;
  const row = box.querySelector<HTMLElement>('.sess[data-path="' + cssEscape(path) + '"]');
  if (!row) return false;
  row.classList.remove("sess-hidden");
  row.click();
  return true;
}

/** Minimal CSS.escape fallback (attribute-selector value escaping) — avoids
 *  depending on the global CSS.escape existing (it does in every real
 *  browser, but happy-dom's test environment is the reason this is spelled
 *  out defensively rather than assumed). */
function cssEscape(s: string): string {
  if (typeof CSS !== "undefined" && CSS.escape) return CSS.escape(s);
  return s.replace(/["\\]/g, "\\$&");
}

/** Client-side substring filter over session titles (no server round
 *  trip). Re-applied after every re-render since #chat-sessions is
 *  rebuilt wholesale on each `sessions` frame. When the title filter yields
 *  few/no hits, debounced-fetches a full-text "in messages" fallback
 *  section (plan §5.7/§9 Phase 3, beat-matrix Axis 10/11's full-text BEAT)
 *  below the title-filtered rows. */
export function applySessSearch(state: SidebarState): void {
  const input = $("chat-sess-search") as HTMLInputElement | null;
  const q = input ? input.value.trim().toLowerCase() : "";
  const rows = $("chat-sessions").querySelectorAll<HTMLElement>(".sess");
  let visibleCount = 0;
  rows.forEach((row) => {
    const match = !q || (row.dataset.title || "").includes(q);
    row.classList.toggle("sess-hidden", !match);
    if (match) visibleCount++;
  });
  let empty = $("chat-sessions").querySelector(".sess-search-empty");
  if (q && !visibleCount && state.lastSessionItems.length) {
    if (!empty) { empty = el("div", "sessempty sess-search-empty", $("chat-sessions")); }
    empty.textContent = "No chats match “" + q + "”.";
  } else if (empty) {
    empty.remove();
  }
  scheduleMessageSearch(state, q, visibleCount);
}

/* ────────────────────────────────────────────────────────────────────
   Full-text "in messages" fallback (beat-matrix Axis 10/11): when the
   title filter yields few/no hits, debounce a GET /api/sessions/search
   and render title+snippet rows below the sidebar's own list. Clicking a
   row opens that session via the existing sidebar click flow (the row is
   already rendered by renderSessions above — a full-text hit is always
   for a session that's IN the sidebar, since the sidebar lists every
   session on disk, just some hidden by the title filter).
   ──────────────────────────────────────────────────────────────────── */

const MESSAGE_SEARCH_DEBOUNCE_MS = 250;
/** Only bother with the server round trip once the title filter has mostly
 *  given up — a query that already matches plenty of titles doesn't need a
 *  second, slower full-text pass under it. */
const FEW_HITS_THRESHOLD = 3;

let messageSearchTimer: ReturnType<typeof setTimeout> | undefined;
let messageSearchSeq = 0;

function scheduleMessageSearch(state: SidebarState, q: string, titleHits: number): void {
  if (messageSearchTimer) clearTimeout(messageSearchTimer);
  const section = document.getElementById("chat-sessions")?.querySelector(".sess-msg-search");
  if (!q || q.length < 2 || titleHits > FEW_HITS_THRESHOLD) {
    if (section) section.remove();
    return;
  }
  const seq = ++messageSearchSeq;
  messageSearchTimer = setTimeout(() => runMessageSearch(state, q, seq), MESSAGE_SEARCH_DEBOUNCE_MS);
}

async function runMessageSearch(state: SidebarState, q: string, seq: number): Promise<void> {
  const box = $("chat-sessions");
  let section = box.querySelector(".sess-msg-search") as HTMLElement | null;
  if (!section) section = el("div", "sess-msg-search", box);
  section.innerHTML = '<div class="sess-msg-search-hdr">In messages</div><div class="sess-msg-search-loading">Searching…</div>';

  const d = await api("/api/sessions/search?q=" + encodeURIComponent(q)).catch(() => ({ ok: false } as { ok: boolean }));
  if (seq !== messageSearchSeq) return; // superseded by a newer keystroke
  // The input may have been cleared/changed while the request was in flight.
  const input = $("chat-sess-search") as HTMLInputElement | null;
  if (!input || input.value.trim().toLowerCase() !== q) return;

  const body = d as { ok: boolean; results?: Array<{ sessionPath: string; sessionTitle: string; matches: Array<{ snippet: string; ranges: Array<[number, number]>; role: string }> }> };
  if (!body.ok || !body.results || !body.results.length) {
    section.innerHTML = '<div class="sess-msg-search-hdr">In messages</div><div class="sessempty">No message matches for “' + esc(q) + '”.</div>';
    return;
  }
  section.innerHTML = '<div class="sess-msg-search-hdr">In messages</div>';
  for (const r of body.results) {
    const item = el("div", "sess-msg-hit", section);
    item.dataset.path = r.sessionPath;
    const first = r.matches[0];
    item.innerHTML =
      '<div class="stitle">' + esc(r.sessionTitle) + '</div>' +
      (first ? '<div class="sess-msg-snippet">' + highlightSnippetHtml(first.snippet, first.ranges) + '</div>' : "");
    item.addEventListener("click", () => { openSessionRowByPath(r.sessionPath); });
  }
}

/** Escape a plain-text snippet then re-insert `<mark>` around the reported
 *  [start,end) ranges — same escape-then-restore discipline markdown.ts
 *  uses for code spans, applied here to search highlighting instead. Ranges
 *  are assumed non-overlapping and sorted (buildSnippet in
 *  src/serve/session-search.ts only ever emits one range per snippet
 *  today, but this loop handles more without change). */
export function highlightSnippetHtml(snippet: string, ranges: Array<[number, number]>): string {
  if (!ranges.length) return esc(snippet);
  let out = "";
  let cursor = 0;
  for (const [start, end] of ranges) {
    if (start < cursor || end <= start || end > snippet.length) continue;
    out += esc(snippet.slice(cursor, start));
    out += "<mark>" + esc(snippet.slice(start, end)) + "</mark>";
    cursor = end;
  }
  out += esc(snippet.slice(cursor));
  return out;
}

/* ────────────────────────────────────────────────────────────────────
   Message actions (copy / regenerate / edit) + sibling toggle
   ──────────────────────────────────────────────────────────────────── */

export interface SiblingInfo {
  entryId: string | null;
  index: number;
  count: number;
  siblingIds: string[];
}

export function newSiblingInfo(): SiblingInfo {
  return { entryId: null, index: 0, count: 0, siblingIds: [] };
}

export interface MsgActionOpts {
  regenerate?: boolean;
  edit?: boolean;
}

/** Append a hover/focus action row to a message element. `text` is the
 *  RAW SOURCE (markdown for assistant, plain for user) — never innerHTML —
 *  so Copy puts back exactly what the model said / the user typed.
 *  `onRegenerate`/`onEdit` are the click handlers (owned by chat.ts, which
 *  knows about the WS connection and turnActive state this module doesn't). */
export function addMsgActions(
  m: HTMLElement,
  text: string,
  opts: MsgActionOpts,
  handlers: { onRegenerate?: () => void; onEdit?: (m: HTMLElement) => void },
): HTMLElement {
  const row = el("div", "msg-actions", m);
  const copyBtn = el("button", "maction", row);
  copyBtn.type = "button"; copyBtn.textContent = "Copy";
  copyBtn.addEventListener("click", () => {
    if (!navigator.clipboard) return;
    navigator.clipboard.writeText(text || "").then(() => {
      copyBtn.textContent = "Copied"; setTimeout(() => { copyBtn.textContent = "Copy"; }, 1200);
    }).catch(() => {});
  });
  if (opts.regenerate) {
    const btn = el("button", "maction", row);
    btn.type = "button"; btn.textContent = "Regenerate";
    btn.title = "Re-run this reply (keeps the old one on disk as a branch)";
    btn.addEventListener("click", () => { handlers.onRegenerate && handlers.onRegenerate(); });
  }
  if (opts.edit) {
    const btn = el("button", "maction", row);
    btn.type = "button"; btn.textContent = "Edit";
    btn.title = "Edit and resend — keeps the original as a numbered branch";
    btn.addEventListener("click", () => { handlers.onEdit && handlers.onEdit(m); });
  }
  return row;
}

/** Render (or clear) the `< i/n >` sibling toggle above the last user
 *  message. Rebuilt whenever a `siblings` frame arrives or the thread is
 *  rebuilt. Hidden entirely when count <= 1 (the common no-edits case). */
export function renderSiblingToggle(
  lastUserMsgEl: HTMLElement | null,
  lastUserEntryId: string | null,
  siblingInfo: SiblingInfo,
  onSwitch: (delta: number) => void,
): void {
  if (!lastUserMsgEl) return;
  let box = lastUserMsgEl.querySelector(".sib-toggle") as HTMLElement | null;
  if (siblingInfo.count <= 1 || siblingInfo.entryId !== lastUserEntryId) {
    if (box) box.remove();
    return;
  }
  if (!box) {
    box = el("div", "sib-toggle", null);
    lastUserMsgEl.insertBefore(box, lastUserMsgEl.firstChild);
  }
  const { index, count } = siblingInfo;
  box.innerHTML =
    '<button class="sib-prev" type="button" ' + (index <= 1 ? "disabled" : "") + '>&lt;</button>' +
    '<span>' + index + '/' + count + '</span>' +
    '<button class="sib-next" type="button" ' + (index >= count ? "disabled" : "") + '>&gt;</button>';
  box.querySelector(".sib-prev")!.addEventListener("click", () => onSwitch(-1));
  box.querySelector(".sib-next")!.addEventListener("click", () => onSwitch(1));
}

/** Resolve the sibling target id for a +-1 direction move from siblingInfo,
 *  or null if there's no such neighbor (caller should no-op). Pure — split
 *  out from the button wiring above so it's independently testable. */
export function switchSiblingTarget(siblingInfo: SiblingInfo, delta: number): string | null {
  const ids = siblingInfo.siblingIds || [];
  return ids[siblingInfo.index - 1 + delta] ?? null;
}

/* ────────────────────────────────────────────────────────────────────
   Export (plan §5.7/§9 Phase 3, beat-matrix Axis 10 "Chat export" +
   Axis 11 "Conversation export/import"): Markdown or raw JSON, built from
   GET /api/sessions/export?path= (server-validated under sessionDir) — used
   uniformly for the open session and any other session in the sidebar,
   so this module needs no reference into chat.ts's in-memory thread state.
   ──────────────────────────────────────────────────────────────────── */

/** Slugify a session title into a filesystem-safe download filename stem
 *  (lowercase, spaces/punctuation -> hyphens, collapsed, trimmed, capped —
 *  same shape as a typical static-site slug). Pure — independently
 *  testable and reused by palette.ts's export action. */
export function slugTitle(title: string): string {
  const slug = (title || "chat")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return (slug || "chat").slice(0, 60);
}

interface ExportEntry {
  type?: string;
  message?: { role?: string; content?: unknown };
}

function entryContentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content
      .filter((p): p is { type: string; text: string } =>
        !!p && (p as { type?: string }).type === "text" && typeof (p as { text?: unknown }).text === "string")
      .map((p) => p.text)
      .join(" ");
  }
  return "";
}

/** Render a session's raw JSONL entries (as returned by GET
 *  /api/sessions/export) into plain Markdown: one `### User`/`### Assistant`
 *  heading per turn plus its text. Pure — takes the already-parsed entry
 *  array, not a fetch, so it's testable without a network stub and reusable
 *  for both "export the open session" and "export any sidebar session"
 *  (both go through the same server endpoint in this module, see
 *  exportSession below). */
export function sessionEntriesToMarkdown(entries: unknown[], title: string): string {
  const lines: string[] = ["# " + (title || "Chat"), ""];
  for (const raw of entries) {
    const e = raw as ExportEntry;
    if (e.type !== "message" || !e.message) continue;
    const role = e.message.role;
    if (role !== "user" && role !== "assistant") continue;
    const text = entryContentText(e.message.content);
    if (!text) continue;
    lines.push("### " + (role === "user" ? "User" : "Assistant"), "", text, "");
  }
  return lines.join("\n");
}

function downloadBlob(filename: string, content: string, mime: string): void {
  const blob = new Blob([content], { type: mime });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url; a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

/** Fetch a session's raw entries + title and trigger a browser download in
 *  the requested format. Always goes through GET /api/sessions/export
 *  (works uniformly whether or not this is the currently-open session —
 *  SessionManager flushes each turn to disk as it happens, so the file is
 *  never meaningfully stale relative to what's on screen). */
export async function exportSession(path: string, title: string, format: "md" | "json"): Promise<void> {
  const d = await api("/api/sessions/export?path=" + encodeURIComponent(path))
    .catch(() => ({ ok: false } as { ok: boolean }));
  const body = d as { ok: boolean; entries?: unknown[] };
  if (!body.ok || !body.entries) return;
  const stem = slugTitle(title);
  if (format === "json") {
    downloadBlob(stem + ".json", JSON.stringify(body.entries, null, 2), "application/json");
  } else {
    downloadBlob(stem + ".md", sessionEntriesToMarkdown(body.entries, title), "text/markdown");
  }
}

let exportMenuEl: HTMLElement | null = null;

function closeExportMenu(): void {
  if (exportMenuEl) { exportMenuEl.remove(); exportMenuEl = null; }
}

/** Tiny two-item popover (Markdown / JSON) anchored under the export
 *  button. Not a FocusTrap-managed overlay (it's a two-button micro-menu,
 *  not a modal) — a document-level click-outside listener closes it, and
 *  Escape closes it via the same listener path since Escape isn't
 *  special-cased elsewhere for this menu. */
function openExportMenu(anchor: HTMLElement, path: string, title: string): void {
  closeExportMenu();
  const menu = el("div", "sess-export-menu", document.body);
  const rect = anchor.getBoundingClientRect();
  menu.style.position = "fixed";
  menu.style.top = (rect.bottom + 4) + "px";
  menu.style.left = Math.max(4, rect.right - 140) + "px";
  menu.innerHTML =
    '<button class="sess-export-item" data-fmt="md">Export as Markdown</button>' +
    '<button class="sess-export-item" data-fmt="json">Export as JSON</button>';
  menu.querySelectorAll<HTMLButtonElement>(".sess-export-item").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      exportSession(path, title, (btn.dataset.fmt as "md" | "json"));
      closeExportMenu();
    });
  });
  exportMenuEl = menu;
  setTimeout(() => {
    document.addEventListener("click", closeExportMenu, { once: true });
    document.addEventListener("keydown", onExportMenuKeydown);
  }, 0);
}

function onExportMenuKeydown(e: KeyboardEvent): void {
  if (e.key === "Escape") { closeExportMenu(); document.removeEventListener("keydown", onExportMenuKeydown); }
}
