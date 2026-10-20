// The recent-chats sidebar: the saved chats as rows (title, relative time, message count) with Export, New chat from
// here and Delete; the search field, which filters titles at once and, when few titles match, searches inside the
// messages (`/api/sessions/search`); and export as Markdown or JSON (`/api/sessions/export`, path-checked server-side).
// Opening a chat is a click on its row, so the host's palette opens one the same way (`openByPath`).
import { $, el, esc, listen, relativeTime, type Api, type Disposer } from "@mlx-bun/web-kit";
import type { SessionListItem } from "../protocol";
import { ICON } from "./icons";

export interface SidebarCallbacks {
  onOpen(path: string): void;
  onFork(path: string): void;
  onDelete(path: string): void;
}

export interface Sidebar {
  /** Redraws the list from a `sessions` frame. */
  render(items: readonly SessionListItem[] | undefined, activePath: string | undefined): void;
  /** Re-applies the search field to the rows (after typing, or a redraw). */
  applySearch(): void;
  /** Opens a listed chat as a click on its row does; false when the list does not hold it. */
  openByPath(path: string): boolean;
  /** Downloads a chat as Markdown or JSON. */
  exportChat(path: string, title: string, format: "md" | "json"): Promise<void>;
  /** The listed chats, for the host's palette. */
  recentChats(): { title: string; path: string }[];
}

/** Only search inside messages once the title filter has mostly given up. */
const FEW_HITS_THRESHOLD = 3;
const MESSAGE_SEARCH_DEBOUNCE_MS = 250;

const cssEscape = (value: string): string => typeof CSS !== "undefined" && CSS.escape ? CSS.escape(value) : value.replace(/["\\]/g, "\\$&");

/** A plain-text snippet, escaped, with `<mark>` around the reported `[start, end)` ranges (sorted, non-overlapping). */
export function highlightSnippetHtml(snippet: string, ranges: Array<[number, number]>): string {
  if (!ranges.length) return esc(snippet);
  let out = "", cursor = 0;
  for (const [start, end] of ranges) {
    if (start < cursor || end <= start || end > snippet.length) continue;
    out += esc(snippet.slice(cursor, start)) + "<mark>" + esc(snippet.slice(start, end)) + "</mark>";
    cursor = end;
  }
  return out + esc(snippet.slice(cursor));
}

/** A filesystem-safe download name from a chat title. */
export function slugTitle(title: string): string {
  const slug = (title || "chat").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
  return (slug || "chat").slice(0, 60);
}

interface ExportEntry { type?: string; message?: { role?: string; content?: unknown } }

function entryContentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content
    .filter((p): p is { type: string; text: string } => !!p && (p as { type?: string }).type === "text" && typeof (p as { text?: unknown }).text === "string")
    .map((p) => p.text).join(" ");
}

/** A saved chat's raw entries as Markdown: one `### User` or `### Assistant` heading per message. */
export function sessionEntriesToMarkdown(entries: unknown[], title: string): string {
  const lines: string[] = ["# " + (title || "Chat"), ""];
  for (const raw of entries) {
    const entry = raw as ExportEntry;
    if (entry.type !== "message" || !entry.message) continue;
    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") continue;
    const text = entryContentText(entry.message.content);
    if (text) lines.push("### " + (role === "user" ? "User" : "Assistant"), "", text, "");
  }
  return lines.join("\n");
}

function downloadBlob(filename: string, content: string, mime: string): void {
  const url = URL.createObjectURL(new Blob([content], { type: mime }));
  const link = el("a", "", document.body);
  link.href = url; link.download = filename;
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

const rowHtml = (s: SessionListItem): string =>
  '<button type="button" class="sopen">' +
    '<span class="stitle">' + esc(s.title || "New chat") + "</span>" +
    '<span class="smeta"><span>' + esc(s.modified ? relativeTime(s.modified) : "") + "</span>" +
      (s.messageCount ? "<span>" + s.messageCount + " message" + (s.messageCount === 1 ? "" : "s") + "</span>" : "") +
      (s.forked ? "<span>branched</span>" : "") + "</span></button>" +
  '<span class="sacts">' +
    '<button type="button" class="sbtn sexport btn icon sm quiet" title="Export this chat" aria-label="Export this chat">' + ICON.download + "</button>" +
    '<button type="button" class="sbtn sfork btn icon sm quiet" title="New chat from here" aria-label="New chat from here">' + ICON.branch + "</button>" +
    '<button type="button" class="sbtn sdel btn icon sm quiet" title="Delete this chat" aria-label="Delete this chat">' + ICON.trash + "</button></span>";

export function createSidebar(api: Api, callbacks: SidebarCallbacks, disposer: Disposer): Sidebar {
  let items: readonly SessionListItem[] = [];
  let searchTimer: ReturnType<typeof setTimeout> | undefined;
  let searchSeq = 0;
  let exportMenu: HTMLElement | null = null;
  let stopMenuListeners: (() => void) | null = null;
  disposer.add(() => { clearTimeout(searchTimer); closeExportMenu(); });

  const list = () => $("chat-sessions");
  const query = () => (($("chat-sess-search") as HTMLInputElement | null)?.value || "").trim().toLowerCase();

  function closeExportMenu(): void {
    exportMenu?.remove();
    exportMenu = null;
    stopMenuListeners?.();
    stopMenuListeners = null;
  }

  /** A two-item menu under the export button; a click elsewhere or Escape closes it. */
  function openExportMenu(anchor: HTMLElement, path: string, title: string): void {
    closeExportMenu();
    const menu = el("div", "sess-export-menu", document.body);
    menu.setAttribute("role", "menu");
    const rect = anchor.getBoundingClientRect();
    menu.style.top = (rect.bottom + 4) + "px";
    menu.style.left = Math.max(8, rect.right - 180) + "px";
    menu.innerHTML = '<button type="button" role="menuitem" class="sess-export-item" data-fmt="md">Export as Markdown</button>' +
      '<button type="button" role="menuitem" class="sess-export-item" data-fmt="json">Export as JSON</button>';
    menu.querySelectorAll<HTMLButtonElement>(".sess-export-item").forEach((button) => {
      button.addEventListener("click", (event) => {
        event.stopPropagation();
        void exportChat(path, title, button.dataset.fmt as "md" | "json");
        closeExportMenu();
      });
    });
    exportMenu = menu;
    menu.querySelector<HTMLButtonElement>(".sess-export-item")?.focus();
    // Registered after this click finishes bubbling, so the click that opened the menu does not close it.
    setTimeout(() => {
      if (exportMenu !== menu) return;
      const stopClick = listen(document, "click", closeExportMenu);
      const stopKey = listen(document, "keydown", (event) => { if ((event as KeyboardEvent).key === "Escape") { closeExportMenu(); anchor.focus(); } });
      stopMenuListeners = () => { stopClick(); stopKey(); };
    }, 0);
  }

  async function exportChat(path: string, title: string, format: "md" | "json"): Promise<void> {
    const answer = await api.get<{ entries?: unknown[] }>("/api/sessions/export?path=" + encodeURIComponent(path));
    if (!answer.ok || !answer.entries) return;
    const stem = slugTitle(title);
    if (format === "json") downloadBlob(stem + ".json", JSON.stringify(answer.entries, null, 2), "application/json");
    else downloadBlob(stem + ".md", sessionEntriesToMarkdown(answer.entries, title), "text/markdown");
  }

  function openByPath(path: string): boolean {
    const row = list()?.querySelector<HTMLElement>('.sess[data-path="' + cssEscape(path) + '"]');
    if (!row) return false;
    row.classList.remove("sess-hidden");
    row.click();
    return true;
  }

  async function runMessageSearch(q: string, seq: number): Promise<void> {
    const box = list();
    let section = box.querySelector<HTMLElement>(".sess-msg-search");
    if (!section) section = el("div", "sess-msg-search", box);
    section.innerHTML = '<div class="sess-msg-search-hdr">In messages</div><div class="sess-msg-search-loading"><span class="skeleton">Searching…</span></div>';
    type Hit = { sessionPath: string; sessionTitle: string; matches: Array<{ snippet: string; ranges: Array<[number, number]>; role: string }> };
    const answer = await api.get<{ results?: Hit[] }>("/api/sessions/search?q=" + encodeURIComponent(q));
    if (seq !== searchSeq || query() !== q) return; // superseded, or the field changed while it was in flight
    if (!answer.ok || !answer.results?.length) {
      section.innerHTML = '<div class="sess-msg-search-hdr">In messages</div><div class="sessempty">' +
        (answer.ok ? "No messages mention “" + esc(q) + "”." : "Could not search the messages. Try again in a moment.") + "</div>";
      return;
    }
    section.innerHTML = '<div class="sess-msg-search-hdr">In messages</div>';
    for (const hit of answer.results) {
      const item = el("button", "sess-msg-hit", section);
      item.type = "button";
      item.dataset.path = hit.sessionPath;
      const first = hit.matches[0];
      item.innerHTML = '<span class="stitle">' + esc(hit.sessionTitle) + "</span>" +
        (first ? '<span class="sess-msg-snippet">' + highlightSnippetHtml(first.snippet, first.ranges) + "</span>" : "");
      item.addEventListener("click", () => { openByPath(hit.sessionPath); });
    }
  }

  function scheduleMessageSearch(q: string, titleHits: number): void {
    clearTimeout(searchTimer);
    if (!q || q.length < 2 || titleHits > FEW_HITS_THRESHOLD) { list()?.querySelector(".sess-msg-search")?.remove(); return; }
    const seq = ++searchSeq;
    searchTimer = setTimeout(() => { void runMessageSearch(q, seq); }, MESSAGE_SEARCH_DEBOUNCE_MS);
  }

  function applySearch(): void {
    const q = query();
    const box = list();
    let visible = 0;
    box.querySelectorAll<HTMLElement>(".sess").forEach((row) => {
      const match = !q || (row.dataset.title || "").includes(q);
      row.classList.toggle("sess-hidden", !match);
      if (match) visible++;
    });
    let empty = box.querySelector(".sess-search-empty");
    if (q && !visible && items.length) {
      empty ??= el("div", "sessempty sess-search-empty", box);
      empty.textContent = "No chat titles match “" + q + "”.";
    } else empty?.remove();
    scheduleMessageSearch(q, visible);
  }

  function render(next: readonly SessionListItem[] | undefined, activePath: string | undefined): void {
    items = next || [];
    const box = list();
    if (!items.length) { box.innerHTML = '<div class="sessempty">No saved chats yet. Each conversation is saved on this Mac and listed here.</div>'; return; }
    box.innerHTML = "";
    for (const s of items) {
      const row = el("div", "sess" + (s.path === activePath ? " active" : ""), box);
      row.dataset.title = (s.title || "New chat").toLowerCase();
      row.dataset.path = s.path;
      row.innerHTML = rowHtml(s);
      if (s.path === activePath) row.querySelector(".sopen")!.setAttribute("aria-current", "true");
      row.addEventListener("click", () => callbacks.onOpen(s.path));
      const exportButton = row.querySelector<HTMLElement>(".sexport")!;
      exportButton.addEventListener("click", (event) => { event.stopPropagation(); openExportMenu(exportButton, s.path, s.title); });
      row.querySelector(".sfork")!.addEventListener("click", (event) => { event.stopPropagation(); callbacks.onFork(s.path); });
      row.querySelector(".sdel")!.addEventListener("click", (event) => { event.stopPropagation(); callbacks.onDelete(s.path); });
    }
    applySearch();
  }

  function recentChats(): { title: string; path: string }[] {
    return [...(list()?.querySelectorAll<HTMLElement>(".sess") ?? [])].flatMap((row) =>
      row.dataset.path ? [{ title: row.querySelector(".stitle")?.textContent || "New chat", path: row.dataset.path }] : []);
  }

  return { render, applySearch, openByPath, exportChat, recentChats };
}
