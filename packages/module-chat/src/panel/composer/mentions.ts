// The `#` picker: typing `#` opens one list over the attached files and the memory vault's articles
// (`/api/memory/search`), so attaching context and recalling a memory are the same gesture. Choosing a file pulses
// its chip (it is already attached, so the typed span is just removed); choosing an article inserts `[[Article]]`,
// the wikilink the memory tools resolve. Without a vault the picker lists files only. While it is open it owns the
// arrow keys, Enter, Tab and Escape in the message box.
import { esc, type Api, type ApiEnvelope } from "@mlx-bun/web-kit";
import { ICON } from "../icons";
import type { Attachment, ComposerState } from "./state";

export interface MentionQuery {
  /** Where the `#` sits in the message box's value. */
  hashIndex: number;
  /** The text typed after `#` up to the caret (a space ends the span). */
  query: string;
}

/** Does the caret sit inside an open `#mention` span? A `#` preceded by a word character ("C#", "issue#12") is not
 * one, and whitespace between the `#` and the caret closes it. */
export function detectMentionQuery(text: string, caret: number): MentionQuery | null {
  if (caret < 0 || caret > text.length) return null;
  let i = caret - 1;
  while (i >= 0) {
    const ch = text[i]!;
    if (ch === "#") {
      const before = i > 0 ? text[i - 1]! : "";
      if (/[A-Za-z0-9_]/.test(before)) return null;
      return { hashIndex: i, query: text.slice(i + 1, caret) };
    }
    if (/\s/.test(ch)) return null;
    i--;
  }
  return null;
}

export type MentionItem =
  | { kind: "file"; id: number; name: string }
  | { kind: "article"; name: string; excerpt?: string };

const MAX_MENTION_FILE_RESULTS = 6;
const MAX_MENTION_ARTICLE_RESULTS = 8;

/** Attached files whose names contain the query (case-insensitive; an empty query lists them all). */
export function filterFileMentions(attachments: Attachment[], query: string): MentionItem[] {
  const q = query.trim().toLowerCase();
  const matches = attachments.filter((a) => !q || a.name.toLowerCase().includes(q));
  return matches.slice(0, MAX_MENTION_FILE_RESULTS).map((a) => ({ kind: "file", id: a.id, name: a.name }));
}

/** Files first (already-attached context is the cheapest hit), then articles, each capped on its own. */
export function buildMentionItems(fileMatches: MentionItem[], articleNames: string[]): MentionItem[] {
  const articles: MentionItem[] = articleNames.slice(0, MAX_MENTION_ARTICLE_RESULTS).map((name) => ({ kind: "article", name }));
  return [...fileMatches, ...articles];
}

/** Replaces the open `#query` span: nothing for a file, `[[Name]] ` for an article. Returns the text and the caret. */
export function applyMention(text: string, q: MentionQuery, item: MentionItem, caret: number): { text: string; caret: number } {
  const insertion = item.kind === "article" ? "[[" + item.name + "]] " : "";
  const before = text.slice(0, q.hashIndex);
  const after = text.slice(caret);
  return { text: before + insertion + after, caret: before.length + insertion.length };
}

/** The picker's rows for an item list and the selected index. File and article names are user data: escaped. */
export function renderMentionListHtml(items: MentionItem[], selected: number, memoryEnabled: boolean): string {
  if (!items.length) {
    return '<div class="mention-empty">' + (memoryEnabled ? "No matching files or memory articles." : "No matching attached files.") + "</div>";
  }
  let filesHtml = "", articlesHtml = "";
  items.forEach((item, i) => {
    const active = i === selected ? " active" : "";
    const label = item.kind === "file" ? esc(item.name) : esc(item.name.replace(/_/g, " "));
    const row = '<div class="mention-row' + active + '" data-idx="' + i + '" role="option" aria-selected="' + (i === selected) + '">' +
      '<span class="mention-ico" aria-hidden="true">' + (item.kind === "file" ? ICON.file : ICON.memory) + "</span>" +
      '<span class="mention-label">' + label + "</span>" +
      '<span class="mention-tag">' + (item.kind === "file" ? "attached" : "memory") + "</span></div>";
    if (item.kind === "file") filesHtml += row; else articlesHtml += row;
  });
  const sections: string[] = [];
  if (filesHtml) sections.push('<div class="mention-sec-title">Attached files</div>' + filesHtml);
  if (articlesHtml) sections.push('<div class="mention-sec-title">Memory</div>' + articlesHtml);
  return sections.join("");
}

type MentionSearch = ApiEnvelope & { summaries?: { article: string }[]; enabled?: boolean };

/** Wires the picker to the message box: opens on `#`, filters attachments at once and searches the vault after a short
 * pause, keyboard and pointer selection, and focus back in the box at the right caret on every path. */
export function initMentionPicker(state: ComposerState, box: HTMLTextAreaElement, api: Api, opts: { onFileSelected(attachment: Attachment): void }): void {
  const pop = document.getElementById("chat-mention-pop");
  if (!pop) return;
  let items: MentionItem[] = [];
  let selected = 0;
  let activeQuery: MentionQuery | null = null;
  let memoryEnabled = true; // optimistic; a failed search yields no article rows
  let debounce: ReturnType<typeof setTimeout> | undefined;
  let searchSeq = 0;

  function render(): void {
    pop!.innerHTML = renderMentionListHtml(items, selected, memoryEnabled);
    pop!.querySelectorAll<HTMLElement>(".mention-row").forEach((row) => {
      row.addEventListener("mousedown", (event) => { event.preventDefault(); const idx = Number(row.dataset.idx); if (Number.isFinite(idx)) select(idx); });
    });
  }

  function close(): void {
    pop!.classList.remove("open");
    activeQuery = null;
    items = [];
    selected = 0;
  }

  function select(idx: number): void {
    const item = items[idx];
    if (!item || !activeQuery) { close(); return; }
    if (item.kind === "file") {
      const attachment = state.attachments.find((a) => a.id === item.id);
      const before = box.value.slice(0, activeQuery.hashIndex);
      const after = box.value.slice(box.selectionStart ?? box.value.length);
      box.value = before + after;
      box.selectionStart = box.selectionEnd = before.length;
      if (attachment) opts.onFileSelected(attachment);
    } else {
      const result = applyMention(box.value, activeQuery, item, box.selectionStart ?? box.value.length);
      box.value = result.text;
      box.selectionStart = box.selectionEnd = result.caret;
    }
    close();
    box.focus();
    box.dispatchEvent(new Event("input")); // the box resizes and every input-driven view follows
  }

  async function runSearch(query: string): Promise<void> {
    const seq = ++searchSeq;
    if (!query.trim()) { updateItems([]); return; }
    const answer = await api.get<MentionSearch>("/api/memory/search?q=" + encodeURIComponent(query));
    if (seq !== searchSeq) return; // a newer keystroke superseded this answer
    // `enabled: false` is the explicit "no vault yet": only that turns the picker files-only for this session.
    if (answer.enabled === false) { memoryEnabled = false; updateItems([]); return; }
    updateItems(answer.ok === false ? [] : (answer.summaries || []).map((s) => s.article));
  }

  function updateItems(articleNames: string[]): void {
    if (!activeQuery) return;
    items = buildMentionItems(filterFileMentions(state.attachments, activeQuery.query), articleNames);
    selected = 0;
    render();
  }

  function search(q: MentionQuery, articles: string[]): void {
    activeQuery = q;
    items = buildMentionItems(filterFileMentions(state.attachments, q.query), articles);
    selected = 0;
    render();
    clearTimeout(debounce);
    debounce = setTimeout(() => { void runSearch(q.query); }, 180);
  }

  box.addEventListener("input", () => {
    const q = detectMentionQuery(box.value, box.selectionStart ?? box.value.length);
    if (!q) { close(); return; }
    if (!activeQuery || activeQuery.hashIndex !== q.hashIndex) {
      pop.classList.add("open");
      search(q, []);
      return;
    }
    search(q, items.flatMap((item) => item.kind === "article" ? [item.name] : []));
  });

  box.addEventListener("keydown", (event) => {
    if (!pop.classList.contains("open") || !items.length) return;
    if (event.key === "ArrowDown") { event.preventDefault(); selected = Math.min(selected + 1, items.length - 1); render(); }
    else if (event.key === "ArrowUp") { event.preventDefault(); selected = Math.max(selected - 1, 0); render(); }
    else if (event.key === "Enter" || event.key === "Tab") { event.preventDefault(); select(selected); }
    else if (event.key === "Escape") { event.preventDefault(); close(); }
  });

  // A click on a row lands through its mousedown before this blur closes the list.
  box.addEventListener("blur", () => { setTimeout(() => { if (document.activeElement !== box) close(); }, 120); });
}
