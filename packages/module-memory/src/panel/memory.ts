// The memory overlay's controller: the drawer (status, search, the article list, an article with its links and git
// history), the sidebar entry and the consent card it wires into the slots the chat hands it (`ChatSlots`), the
// personalised greeting chips, and the provenance chips the chat host draws for memory tools. It renders into the light
// DOM, reaches the module's routes (`/api/memory/*`) through the web kit's client over the connection's `apiBase`, and
// sends its notices to the connection's `ui.notify`.
import { $, createApi, el, emitHostEvent, esc, HOST_EVENTS, relativeTime, trapFocus, type Api, type ApiEnvelope, type FocusTrap } from "@mlx-bun/web-kit";
import type { PanelConnection } from "../protocol";
import { mdToHtml, wireCanvasToggle } from "./markdown";
import { ICONS } from "./template";

/** Where memory attaches in a chat's markup (the chat element's `companionSlots()`): the sidebar entry
 * (`#chat-memory-entry`) and its count (`#chat-memory-count`), the first-run consent card (`#chat-consent`) with its
 * actions (`#chat-consent-yes`, `#chat-consent-skip`), and the greeting's suggestion chips (`#chat-hello-chips`). The
 * chat owns them; memory adds its classes (`mem-entry`, `mem-entry-count`, `mem-consent`) and wiring. */
export interface ChatSlots {
  entry: HTMLButtonElement;
  count: HTMLElement;
  consent: HTMLElement;
  consentYes: HTMLButtonElement;
  consentSkip: HTMLButtonElement;
  chips: HTMLElement;
}

/* ────────────────────────────────────────────────────────────────────
   REST response shapes (the module's `routes.ts` `jsonOk()` bodies). Each extends the client's envelope.
   ──────────────────────────────────────────────────────────────────── */

interface VaultStatusBody {
  root: string;
  exists: boolean;
  articleCount: number;
  referenceCount: number;
  isGitRepo: boolean;
  recentArticles: { article: string; mtimeMs: number }[];
}
type StatusResp = ApiEnvelope & { enabled?: boolean; status?: VaultStatusBody; root?: string };
type ListResp = ApiEnvelope & { enabled?: boolean; articles?: string[]; reference?: string[] };
interface SearchSummary { article: string; occurrences: number; matched_terms?: string[]; title_matches?: number }
interface SearchHit { article: string; anchor: string | null; line: number; excerpt: string }
type SearchResp = ApiEnvelope & { summaries?: SearchSummary[]; hits?: SearchHit[] };
type ArticleResp = ApiEnvelope & {
  name?: string; path?: string; content?: string;
  infobox?: { entityKind?: string } | null; lead?: string | null;
};
type LinksResp = ApiEnvelope & { name?: string; outbound?: string[]; inbound?: string[] };
interface HistoryEntry { hash: string; date: string; subject: string }
type HistoryResp = ApiEnvelope & { name?: string; isGitRepo?: boolean; entries?: HistoryEntry[] };
type DiffResp = ApiEnvelope & { name?: string; rev?: string; diff?: string };
type InitResp = ApiEnvelope & { result?: { root: string; gitInitialized: boolean }; status?: VaultStatusBody };

/* ────────────────────────────────────────────────────────────────────
   The client over the connection's base (`/api/memory`, or an absolute URL in a native webview). Module paths
   resolve under it; `/v1/...` paths on its origin.
   ──────────────────────────────────────────────────────────────────── */

let connection: PanelConnection = { apiBase: "/api/memory", eventsUrl: "" };
let api: Api = createApi(connection.apiBase);
/** The element's connection: the client's base and the host's notifications. */
export function setConnection(next: PanelConnection): void { connection = next; api = createApi(next.apiBase); }

/** A notice through the host's `ui.notify`; a host without one shows none. */
function toast(message: string, kind: "ok" | "err"): void {
  connection.ui?.notify?.(message, kind);
}

/** The chat's slots, once a chat is attached. */
let slots: ChatSlots | null = null;

const errorText = (envelope: ApiEnvelope, fallback: string): string =>
  (typeof envelope.error === "string" && envelope.error) || (typeof envelope.message === "string" && envelope.message) || fallback;
const display = (name: string): string => (name.startsWith("Reference/") ? name.slice("Reference/".length) : name).replace(/_/g, " ");
const loadingHtml = (label: string): string =>
  '<div class="mem-loading" role="status" aria-label="' + esc(label) + '"><span class="skeleton"></span><span class="skeleton"></span><span class="skeleton"></span></div>';

/** Enter and Space activate a row that acts as a button. */
function activate(row: HTMLElement, run: () => void): void {
  row.addEventListener("click", run);
  row.addEventListener("keydown", (e) => {
    const key = (e as KeyboardEvent).key;
    if (key === "Enter" || key === " ") { e.preventDefault(); run(); }
  });
}

/* ────────────────────────────────────────────────────────────────────
   Cached status: the drawer, the sidebar entry, the greeting chips and the consent card all need "is memory set up,
   and how many articles" without each asking `status` again.
   ──────────────────────────────────────────────────────────────────── */

let cachedStatus: StatusResp | null = null;

async function fetchStatus(force = false): Promise<StatusResp> {
  if (cachedStatus && !force) return cachedStatus;
  const d = await api.get<StatusResp>("status");
  cachedStatus = d;
  return d;
}

/* ────────────────────────────────────────────────────────────────────
   Open and close, with a focus trap
   ──────────────────────────────────────────────────────────────────── */

let panelTrap: FocusTrap;

export function isMemPanelOpen(): boolean {
  const ov = $("mem-overlay");
  return !!ov && ov.classList.contains("open");
}

export function closeMemPanel(): void {
  const overlay = $("mem-overlay");
  if (!overlay.classList.contains("open")) return;
  beginView(); // a fetch still in flight renders nothing into the closed drawer and reports nothing
  overlay.classList.remove("open");
  slots?.entry.setAttribute("aria-expanded", "false");
  panelTrap.restore();
  changed();
}

/** The drawer closed, or rendered its list or an article (on opening too): the host that describes the page (the
 * chat's assistant) hears it through the kit's panel-changed event, synchronously, once the view it will describe is
 * showing, however the drawer got there. */
function changed(): void {
  emitHostEvent(HOST_EVENTS.panelChanged, undefined, $("mem-overlay"), { bubbles: true, composed: true });
}

/** A view's render belongs to the latest request: a slower earlier fetch, or one still in flight when the drawer
 *  closed, neither overwrites what the user chose since nor raises a change for a view no longer wanted. */
let viewSeq = 0;
const beginView = (): number => ++viewSeq;
const isCurrentView = (seq: number): boolean => seq === viewSeq;

/** Opens the drawer. `articleName` jumps straight to that article (the provenance chips and the link chips use it);
 *  omitted, it shows the list. The view raises the change once it is rendered, so a host's snapshot never describes
 *  the view the drawer last showed. */
export async function openMemPanel(articleName?: string): Promise<void> {
  panelTrap.capture();
  $("mem-overlay").classList.add("open");
  slots?.entry.setAttribute("aria-expanded", "true");
  if (articleName) await showArticle(articleName);
  else await showList();
  setTimeout(() => { if (isMemPanelOpen()) (document.getElementById("mem-search") ?? document.getElementById("mem-close"))?.focus(); }, 30);
}

function setBack(show: boolean): void {
  $("mem-back").classList.toggle("show", show);
  $("mem-back").closest(".mem-head")?.classList.toggle("back", show);
  $("mem-panel").classList.toggle("reading", show);
}

/* ────────────────────────────────────────────────────────────────────
   Status strip
   ──────────────────────────────────────────────────────────────────── */

function renderStatusStrip(st: VaultStatusBody): void {
  const last = st.recentArticles[0];
  $("mem-status").innerHTML =
    '<span class="tag num">' + st.articleCount + " article" + (st.articleCount === 1 ? "" : "s") + "</span>" +
    (last ? '<span class="tag">Updated ' + esc(relativeTime(last.mtimeMs)) + "</span>" : "") +
    (st.isGitRepo ? '<span class="tag ok">Git-tracked</span>' : '<span class="tag warn" title="Changes to the vault are not versioned">Not a git repository</span>');
}

/* ────────────────────────────────────────────────────────────────────
   List view: search and the article and reference lists
   ──────────────────────────────────────────────────────────────────── */

function emptyVaultHtml(root: string): string {
  return (
    '<div class="empty mem-empty">' +
    "<h3>No memory vault yet</h3>" +
    "<p>Memory is a local, git-tracked wiki at <code>" + esc(root) + "</code>. The assistant reads it during chats and never writes to it; " +
    "nightly synthesis keeps it up to date.</p>" +
    '<div id="mem-init-error"></div>' +
    '<div class="actions"><button class="btn primary" id="mem-empty-init" type="button">Set up memory</button></div>' +
    "</div>"
  );
}

function articleRowHtml(name: string, excerpt?: string): string {
  const reference = name.startsWith("Reference/");
  return (
    '<div class="list-row mem-art" data-article="' + esc(name) + '" tabindex="0" role="button">' +
    '<span class="mem-art-ico" title="' + (reference ? "Reference" : "Article") + '">' + (reference ? ICONS.reference : ICONS.article) + "</span>" +
    '<div class="list-main"><div class="list-name mem-art-name">' + esc(display(name)) + "</div>" +
    (excerpt ? '<div class="list-meta mem-art-excerpt">' + esc(excerpt) + "</div>" : "") +
    '</div><span class="mem-art-go">' + ICONS.caret() + "</span></div>"
  );
}

function sectionHtml(title: string, count: number | null, rows: string): string {
  return '<div class="mem-sec"><div class="mem-sec-title">' + esc(title) + (count !== null ? ' <span class="count">' + count + "</span>" : "") + "</div>" + rows + "</div>";
}

function wireArticleRows(container: HTMLElement): void {
  container.querySelectorAll<HTMLElement>(".mem-art").forEach((row) => {
    activate(row, () => { const name = row.dataset.article; if (name) void showArticle(name); });
  });
}

async function renderListBody(seq: number): Promise<void> {
  const body = $("mem-body");
  const st = await fetchStatus();
  if (!isCurrentView(seq)) return;
  if (!st.enabled || !st.status) {
    $("mem-status").innerHTML = "";
    body.innerHTML = emptyVaultHtml(st.root || "~/.mlx-bun/wiki");
    const btn = document.getElementById("mem-empty-init") as HTMLButtonElement | null;
    if (btn) btn.onclick = () => runInit(btn);
    return;
  }
  renderStatusStrip(st.status);
  body.innerHTML =
    '<div class="mem-search"><input class="input" type="search" id="mem-search" placeholder="Search memory" aria-label="Search memory" autocomplete="off"></div>' +
    '<div id="mem-list">' + loadingHtml("Loading the articles") + "</div>";
  await renderArticleLists("", seq);
  const search = $("mem-search") as HTMLInputElement;
  let debounce: ReturnType<typeof setTimeout> | undefined;
  search.addEventListener("input", () => {
    clearTimeout(debounce);
    debounce = setTimeout(() => renderArticleLists(search.value.trim(), seq), 180);
  });
}

async function renderArticleLists(query: string, seq: number): Promise<void> {
  const listEl = $("mem-list");
  if (!query) {
    const d = await api.get<ListResp>("list");
    if (!isCurrentView(seq)) return;
    if (!d.ok) {
      listEl.innerHTML = '<div class="notice bad" role="alert"><span><b>Could not load the vault.</b> ' + esc(errorText(d, "The server did not say why.")) +
        '</span><span class="actions"><button class="btn sm" type="button" id="mem-list-retry">Retry</button></span></div>';
      ($("mem-list-retry") as HTMLButtonElement).onclick = () => { void renderArticleLists("", seq); };
      return;
    }
    const articles = d.articles || [], reference = d.reference || [];
    listEl.innerHTML =
      sectionHtml("Articles", articles.length || null, articles.length
        ? '<div class="list">' + articles.map((a) => articleRowHtml(a)).join("") + "</div>"
        : '<p class="mem-note">No articles yet. Nightly synthesis writes them after a few conversations.</p>') +
      // Reference/ docs are mlx-bun's own documentation, not personal memory, so they get their own section.
      (reference.length ? sectionHtml("Reference", reference.length, '<div class="list">' + reference.map((r) => articleRowHtml(r)).join("") + "</div>") : "");
    wireArticleRows(listEl);
    return;
  }
  const d = await api.get<SearchResp>("search?q=" + encodeURIComponent(query));
  if (!isCurrentView(seq)) return;
  if (!d.ok) {
    listEl.innerHTML = '<p class="mem-note bad" role="alert">Search failed: ' + esc(errorText(d, "the server did not say why")) + ". Try again in a moment.</p>";
    return;
  }
  if (!d.summaries || !d.summaries.length) {
    listEl.innerHTML = '<p class="mem-note">No matches for “' + esc(query) + "”. Try fewer or different words.</p>";
    return;
  }
  const hitsByArticle = new Map<string, SearchHit>();
  for (const h of d.hits || []) if (!hitsByArticle.has(h.article)) hitsByArticle.set(h.article, h);
  listEl.innerHTML = sectionHtml(d.summaries.length === 1 ? "1 match" : d.summaries.length + " matches", null,
    '<div class="list">' + d.summaries.map((s) => articleRowHtml(s.article, hitsByArticle.get(s.article)?.excerpt)).join("") + "</div>");
  wireArticleRows(listEl);
}

async function runInit(button: HTMLButtonElement): Promise<void> {
  button.disabled = true;
  button.textContent = "Setting up…";
  const d = await api.post<InitResp>("init");
  if (!d.ok) {
    button.disabled = false;
    button.textContent = "Try again";
    const slot = document.getElementById("mem-init-error");
    if (slot) slot.innerHTML = '<div class="notice bad" role="alert"><span><b>Could not set up memory.</b> ' + esc(errorText(d, "The server did not say why.")) + "</span></div>";
    cachedStatus = null;
    return;
  }
  toast("Memory vault created", "ok");
  cachedStatus = null;
  await refreshSidebarEntry();
  await showList();
}

async function showList(): Promise<void> {
  const seq = beginView();
  setBack(false);
  $("mem-title").textContent = "Memory";
  $("mem-body").scrollTop = 0;
  try { await renderListBody(seq); } finally { if (isCurrentView(seq)) changed(); }
}

/* ────────────────────────────────────────────────────────────────────
   Article view: the rendered page, its links, and its history
   ──────────────────────────────────────────────────────────────────── */

function linksLineHtml(outbound: string[], inbound: string[]): string {
  if (!outbound.length && !inbound.length) return "";
  const row = (label: string, names: string[]) => names.length
    ? '<div class="mem-links-row"><span class="lbl">' + label + "</span>" +
      names.map((n) => '<button class="tag mem-link-chip" type="button" data-article="' + esc(n) + '">' + esc(display(n)) + "</button>").join("") +
      "</div>"
    : "";
  return '<div class="mem-links">' + row("Links to", outbound) + row("Linked from", inbound) + "</div>";
}

function wireLinkChips(container: HTMLElement): void {
  container.querySelectorAll<HTMLButtonElement>(".mem-link-chip").forEach((btn) => {
    btn.addEventListener("click", () => { const name = btn.dataset.article; if (name) void showArticle(name); });
  });
}

async function showArticle(name: string): Promise<void> {
  const seq = beginView();
  setBack(true);
  $("mem-title").textContent = display(name);
  const body = $("mem-body");
  body.innerHTML = loadingHtml("Loading the article");
  body.scrollTop = 0;
  try { await renderArticle(name, body, seq); } finally { if (isCurrentView(seq)) changed(); }
}

async function renderArticle(name: string, body: HTMLElement, seq: number): Promise<void> {
  const [artRes, linksRes] = await Promise.all([
    api.get<ArticleResp>("article?name=" + encodeURIComponent(name)),
    api.get<LinksResp>("links?name=" + encodeURIComponent(name)),
  ]);
  if (!isCurrentView(seq)) return;
  if (!artRes.ok || artRes.content == null) {
    body.innerHTML = '<div class="notice bad" role="alert"><span><b>Could not open “' + esc(display(name)) + "”.</b> " +
      esc(errorText(artRes, "It may have been renamed or removed.")) + "</span></div>";
    return;
  }

  body.innerHTML =
    '<div class="seg mem-tabs" role="group" aria-label="Article view">' +
    '<button class="on" id="mem-tab-view" type="button" aria-pressed="true">Article</button>' +
    '<button id="mem-tab-history" type="button" aria-pressed="false">History</button>' +
    "</div>" +
    '<div id="mem-art-view">' +
    // data-ui-chrome="content": a vault article is synthesized from past conversations, not app-authored UI, and can
    // hold arbitrary links, so the assistant's UI snapshot leaves it out (as it does the chat thread).
    '<div class="mem-article-render" data-ui-chrome="content">' + mdToHtml(artRes.content) + "</div>" +
    linksLineHtml(linksRes.outbound || [], linksRes.inbound || []) +
    "</div>" +
    '<div id="mem-art-history" style="display:none"></div>';

  wireLinkChips(body);
  ($("mem-tab-view") as HTMLButtonElement).onclick = () => switchArticleTab("view");
  ($("mem-tab-history") as HTMLButtonElement).onclick = () => switchArticleTab("history", name);
}

async function switchArticleTab(tab: "view" | "history", name?: string): Promise<void> {
  for (const [id, on] of [["mem-tab-view", tab === "view"], ["mem-tab-history", tab === "history"]] as const) {
    $(id).classList.toggle("on", on);
    $(id).setAttribute("aria-pressed", String(on));
  }
  $("mem-art-view").style.display = tab === "view" ? "" : "none";
  $("mem-art-history").style.display = tab === "history" ? "" : "none";
  if (tab === "history" && name) await renderHistoryPane(name);
}

async function renderHistoryPane(name: string): Promise<void> {
  const pane = $("mem-art-history");
  if (pane.dataset.loaded === name) return; // loaded once per article view
  pane.innerHTML = loadingHtml("Loading the history");
  const d = await api.get<HistoryResp>("history?name=" + encodeURIComponent(name));
  if (!d.ok || !d.entries) {
    pane.innerHTML = '<p class="mem-note">No history available: the vault is not a git repository, or nothing has been committed yet.</p>';
    return;
  }
  if (!d.entries.length) {
    pane.innerHTML = '<p class="mem-note">No commits touch this article yet.</p>';
    return;
  }
  pane.dataset.loaded = name;
  pane.innerHTML =
    '<div class="list mem-hist">' +
    d.entries.map((e) =>
      '<div class="list-row mem-hist-entry" data-hash="' + esc(e.hash) + '" tabindex="0" role="button">' +
      '<span class="mem-hist-ico">' + ICONS.commit + "</span>" +
      '<div class="list-main"><div class="list-name mem-hist-subject">' + esc(e.subject || "(no subject)") + "</div>" +
      '<div class="list-meta"><span class="mem-hist-date num">' + esc(e.date) + '</span> · <span class="mem-hist-hash">' + esc(e.hash.slice(0, 7)) + "</span></div></div>" +
      "</div>",
    ).join("") + "</div>" +
    '<div class="mem-diff" id="mem-diff-body" style="display:none" aria-live="polite"></div>';
  pane.querySelectorAll<HTMLElement>(".mem-hist-entry").forEach((row) => {
    activate(row, async () => {
      pane.querySelectorAll(".mem-hist-entry").forEach((r) => { r.classList.remove("selected"); r.removeAttribute("aria-current"); });
      row.classList.add("selected");
      row.setAttribute("aria-current", "true");
      const hash = row.dataset.hash!;
      const diffEl = $("mem-diff-body");
      diffEl.style.display = "";
      diffEl.innerHTML = '<span class="diffctx">Loading the diff…</span>';
      const dr = await api.get<DiffResp>("diff?name=" + encodeURIComponent(name) + "&rev=" + encodeURIComponent(hash));
      diffEl.innerHTML = dr.ok && dr.diff ? diffToHtml(dr.diff) : '<span class="diffctx">Could not load this diff: ' + esc(errorText(dr, "the server did not say why")) + ".</span>";
    });
  });
}

/** A `git show` unified diff as added and removed lines. Line-oriented and escaped: diff content is never markup. */
function diffToHtml(diff: string): string {
  return diff
    .replace(/\n$/, "")
    .split("\n")
    .map((line) => {
      if (line.startsWith("+++") || line.startsWith("---")) return '<span class="diffctx">' + esc(line) + "</span>";
      if (line.startsWith("@@")) return '<span class="diffhunk">' + esc(line) + "</span>";
      if (line.startsWith("+")) return '<span class="diffadd">' + esc(line) + "</span>";
      if (line.startsWith("-")) return '<span class="diffdel">' + esc(line) + "</span>";
      return '<span class="diffctx">' + (esc(line) || " ") + "</span>";
    })
    .join("");
}

/* ────────────────────────────────────────────────────────────────────
   Sidebar entry: a quiet row with the article count, not a navigation tab
   ──────────────────────────────────────────────────────────────────── */

export async function refreshSidebarEntry(): Promise<void> {
  const st = await fetchStatus(true);
  if (!slots) return;
  const { entry, count } = slots;
  entry.style.display = "";
  // No vault yet: the entry stays reachable (opening it offers to set memory up) and its count reads as an invitation,
  // so it never looks like a broken zero.
  const ready = st.ok && st.enabled && st.status;
  count.textContent = ready ? String(st.status!.articleCount) : "Set up";
  entry.title = ready ? `Memory: ${st.status!.articleCount} article${st.status!.articleCount === 1 ? "" : "s"}` : "Set up memory";
}

/* ────────────────────────────────────────────────────────────────────
   Provenance chips: what the chat host draws in place of its generic tool card for a memory_ or reference_ tool.
   ──────────────────────────────────────────────────────────────────── */

// Kept in sync with MEMORY_TOOL_NAMES/REFERENCE_TOOL_NAMES (the module's tools.ts) as a literal list, since panel code
// imports only panel files; apps/mlx-bun/tests/web/browser.test.ts cross-checks it against the real export.
export const MEMORY_CHIP_TOOL_NAMES = [
  "memory_resolve", "memory_category", "memory_read", "memory_section",
  "memory_links", "memory_infobox", "memory_list", "memory_status", "memory_search",
  "reference_search", "reference_read", "reference_list",
] as const;

export function isMemoryToolName(tool: string): boolean {
  return (MEMORY_CHIP_TOOL_NAMES as readonly string[]).includes(tool);
}

/** Best-effort article name from a memory tool call's arguments (`article`, `name`, `category` or `query`): only the
 *  chip's label and the "Open in Memory" target, never trusted for anything else. */
function articleNameFromArgs(args: unknown): string | null {
  if (!args || typeof args !== "object") return null;
  const a = args as Record<string, unknown>;
  const cand = a.article ?? a.name ?? a.category ?? a.query;
  return typeof cand === "string" && cand.trim() ? cand.trim() : null;
}

function chipVerb(tool: string): string {
  if (tool === "memory_search" || tool === "reference_search") return "Searched";
  if (tool === "memory_links") return "Traced links from";
  if (tool === "memory_list" || tool === "memory_status" || tool === "reference_list") return "Checked";
  return "Read";
}

/** The handle the chat keeps for a chip while the tool's frames arrive; it toggles `.fail` on the wrap itself. */
export interface MemChipHandle {
  wrap: HTMLElement;
  setResult(result: unknown): void;
}

/** Draws the collapsed chip for a memory or reference tool call into `parent` (the assistant's bubble). */
export function memoryToolChip(parent: HTMLElement, tool: string, args: unknown): MemChipHandle {
  const articleName = articleNameFromArgs(args);
  const wrap = el("div", "memchip", parent);
  const label = "<b>" + chipVerb(tool) + "</b> " + (articleName ? esc(articleName.replace(/_/g, " ")) : "memory");
  wrap.innerHTML =
    '<button class="mchead" type="button" aria-expanded="false">' + ICONS.memory("mcicon") +
    '<span class="mclabel">' + label + "</span>" + ICONS.caret("mccaret") + "</button>" +
    '<div class="mcbody"><pre class="mcresult"></pre>' +
    (articleName ? '<button class="btn sm mcopen" type="button">Open in Memory</button>' : "") +
    "</div>";
  const head = wrap.querySelector(".mchead") as HTMLButtonElement;
  head.addEventListener("click", () => head.setAttribute("aria-expanded", String(wrap.classList.toggle("open"))));
  const openBtn = wrap.querySelector(".mcopen") as HTMLButtonElement | null;
  if (openBtn && articleName) openBtn.onclick = (e) => { e.stopPropagation(); void openMemPanel(articleName); };
  const resultEl = wrap.querySelector(".mcresult") as HTMLElement;
  return {
    wrap,
    setResult(result: unknown) {
      const text = result != null ? (typeof result === "string" ? result : JSON.stringify(result, null, 2)) : "";
      resultEl.textContent = String(text).slice(-4000);
    },
  };
}

/* ────────────────────────────────────────────────────────────────────
   Personalised greeting chips: up to two drawn from a real article and a compatible adapter, ahead of the chat's
   static ones, which stay when neither signal is available.
   ──────────────────────────────────────────────────────────────────── */

interface AdapterAvailable { id: string; compatible?: boolean }

/** Inserts the chips with the chat's own `.chip[data-q]` contract: the chat delegates one click listener on its chips
 *  slot, so inserted chips send their question with no wiring here. */
export async function personalizeHeroChips(): Promise<void> {
  const container = slots?.chips;
  if (!container) return;
  const extra: string[] = [];

  const st = await fetchStatus();
  if (st.ok && st.enabled && st.status && st.status.recentArticles.length) {
    const name = display(st.status.recentArticles[0]!.article);
    extra.push('<button class="chip" data-q="' + esc("What do you remember about " + name + "?") + '">Ask about ' + esc(name) + "</button>");
  }

  // Adapters are optional personalisation: no adapter list is not an error.
  const d = await api.get<{ adapters?: AdapterAvailable[] }>("/v1/adapters/available");
  const compatible = (d.adapters || []).find((a) => a.compatible !== false);
  if (compatible) {
    extra.push('<button class="chip" data-q="' + esc("Can you try answering with the " + compatible.id + " adapter?") + '">Try the ' + esc(compatible.id) + " adapter</button>");
  }

  if (!extra.length) return; // keep the static chips exactly as they are
  container.insertAdjacentHTML("afterbegin", extra.join(""));
}

/* ────────────────────────────────────────────────────────────────────
   Consent card: first run only; it never creates the vault on its own.
   ──────────────────────────────────────────────────────────────────── */

const CONSENT_DISMISSED_KEY = "mlxbun.memoryConsentDismissed";

function isConsentDismissed(): boolean {
  try { return localStorage.getItem(CONSENT_DISMISSED_KEY) === "1"; } catch { return false; }
}
function dismissConsent(): void {
  try { localStorage.setItem(CONSENT_DISMISSED_KEY, "1"); } catch { /* storage is unavailable: the card just hides */ }
  slots?.consent.classList.remove("show");
}

/** Shows the consent card when there is no vault yet and it was never dismissed. Called once when the chat attaches. */
export async function maybeShowConsentCard(): Promise<void> {
  const card = slots?.consent;
  if (!card) return;
  if (isConsentDismissed()) return;
  const st = await fetchStatus();
  if (st.ok && st.enabled) return; // a vault exists: nothing to consent to
  card.classList.add("show");
}

function wireConsentCard({ consentSkip: skip, consentYes: yes }: ChatSlots): void {
  skip.onclick = dismissConsent;
  yes.onclick = async () => {
    yes.disabled = true;
    const d = await api.post<InitResp>("init");
    yes.disabled = false;
    if (!d.ok) { toast("Could not set up memory: " + errorText(d, "the server did not say why") + ". Try again, or run mlx-bun memory init in a terminal.", "err"); return; }
    dismissConsent();
    cachedStatus = null;
    toast("Memory vault created", "ok");
    await refreshSidebarEntry();
    await openMemPanel();
  };
}

/* ────────────────────────────────────────────────────────────────────
   Init: the drawer's chrome (close, back, the focus trap, a click on the scrim) once per overlay; `attachChat` wires
   the chat's slots once its markup exists.
   ──────────────────────────────────────────────────────────────────── */

let initializedOverlay: HTMLElement | undefined;

export function initMemoryPanel(): void {
  const overlay = $("mem-overlay");
  if (initializedOverlay === overlay) return;
  initializedOverlay = overlay;
  cachedStatus = null;
  panelTrap = trapFocus(overlay, isMemPanelOpen);
  if (slots) slots.entry.onclick = () => openMemPanel();
  ($("mem-close") as HTMLButtonElement).onclick = closeMemPanel;
  ($("mem-back") as HTMLButtonElement).onclick = () => showList();
  overlay.addEventListener("click", (e) => { if (e.target === overlay) closeMemPanel(); });
  const body = $("mem-body");
  // The article's code blocks: Preview and Source for HTML and SVG fences, and Copy, delegated on the stable body.
  wireCanvasToggle(body);
  body.addEventListener("click", (e) => {
    const btn = (e.target as HTMLElement).closest?.(".cbcopy") as HTMLElement | null;
    const code = btn?.closest(".codeblock")?.querySelector("code");
    if (!btn || !code || !navigator.clipboard) return;
    navigator.clipboard.writeText(code.textContent || "").then(() => {
      btn.textContent = "Copied";
      setTimeout(() => { btn.textContent = "Copy"; }, 1200);
    }).catch(() => {});
  });
}

/** Takes the chat's slots: memory's classes on the elements it styles, the entry and the consent card wired, and the
 *  entry's count, the consent card and the personalised chips filled from the vault's status. */
export function attachChat(chat: ChatSlots): void {
  slots = chat;
  chat.entry.classList.add("mem-entry");
  chat.count.classList.add("mem-entry-count");
  chat.consent.classList.add("mem-consent");
  chat.entry.setAttribute("aria-controls", "mem-overlay"); // the drawer the entry opens is memory's
  chat.entry.onclick = () => openMemPanel();
  wireConsentCard(chat);
  void refreshSidebarEntry();
  void personalizeHeroChips();
  void maybeShowConsentCard();
}
