// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// The Memory panel (plan §5.5), provenance chips (§5.4.2), personalized
// hero chips + consent card (§5.1), and the sidebar entry that opens the
// panel. Everything here talks to the /api/memory/* REST wrappers
// (src/memory/rest.ts) — no new WS frames, per the task brief. esc()
// discipline on every interpolation site: article names/content/commit
// subjects/paths are all vault (i.e. user/model) data, never trusted.
//
// State model: the panel is a single overlay with two "screens" — a list
// screen (status strip + search + article/reference lists) and an article
// screen (rendered content + History toggle + links line). `view` tracks
// which is showing so Back/Escape/re-open behave predictably; there is no
// deep router here (the panel is not URL-addressable — matching the plan's
// "reachable from the sidebar, not a nav tab" framing).

import { $, el, toast, trapFocus, setMemPanelClose, type FocusTrap } from "./shell";
import { api } from "./api";
import type { ApiEnvelope } from "./protocol";
import { esc, mdToHtml, wireCanvasToggle } from "./markdown";

/* ────────────────────────────────────────────────────────────────────
   REST response shapes (mirrors src/memory/rest.ts's jsonOk() bodies —
   frontend-only types since these are HTTP JSON envelopes, not part of
   the typed WS contract in pi-web.ts). Each extends ApiEnvelope (api()'s
   generic constraint, api.ts) via intersection, per that file's own
   doc-comment convention.
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

async function getJson<T extends ApiEnvelope>(path: string): Promise<T> {
  return api<T>(path);
}

/* ────────────────────────────────────────────────────────────────────
   Cached status — the panel, the sidebar entry, the hero chips, and the
   consent card all need "is memory enabled + how many articles" without
   each firing their own /api/memory/status round trip.
   ──────────────────────────────────────────────────────────────────── */

let cachedStatus: StatusResp | null = null;

async function fetchStatus(force = false): Promise<StatusResp> {
  if (cachedStatus && !force) return cachedStatus;
  const d = await getJson<StatusResp>("/api/memory/status").catch((): StatusResp => ({ ok: false, enabled: false }));
  cachedStatus = d;
  return d;
}

/* ────────────────────────────────────────────────────────────────────
   Panel open/close + focus trap (same mechanism as the HF modal / drawer)
   ──────────────────────────────────────────────────────────────────── */

let panelTrap: FocusTrap;
type View = { kind: "list" } | { kind: "article"; name: string; historyOpen?: boolean };
let currentView: View = { kind: "list" };
let lastListScroll = 0;

export function isMemPanelOpen(): boolean {
  const ov = $("mem-overlay");
  return !!ov && ov.classList.contains("open");
}

export function closeMemPanel(): void {
  $("mem-overlay").classList.remove("open");
  $("chat-memory-entry").setAttribute("aria-expanded", "false");
  panelTrap.restore();
}

/** Opens the panel. `articleName` jumps straight to that article's view
 *  (used by provenance chips and link-chip navigation); omitted opens/keeps
 *  the list view. */
export async function openMemPanel(articleName?: string): Promise<void> {
  panelTrap.capture();
  $("mem-overlay").classList.add("open");
  $("chat-memory-entry").setAttribute("aria-expanded", "true");
  if (articleName) await showArticle(articleName);
  else await showList();
  setTimeout(() => { const s = $("mem-search") as HTMLInputElement | null; if (s) s.focus(); }, 30);
}

function setBack(show: boolean): void {
  $("mem-back").classList.toggle("show", show);
}

/* ────────────────────────────────────────────────────────────────────
   Status strip
   ──────────────────────────────────────────────────────────────────── */

function relDate(ms: number | undefined): string {
  if (!ms) return "—";
  const days = (Date.now() - ms) / 86_400_000;
  if (days < 1) return "today";
  if (days < 2) return "yesterday";
  if (days < 30) return Math.floor(days) + "d ago";
  try { return new Date(ms).toLocaleDateString(); } catch { return "—"; }
}

function renderStatusStrip(st: VaultStatusBody): void {
  const lastArticle = st.recentArticles[0];
  $("mem-status").innerHTML =
    '<span class="mem-stat"><b>' + st.articleCount + '</b> article' + (st.articleCount === 1 ? "" : "s") + "</span>" +
    '<span class="mem-stat">last touched <b>' + esc(relDate(lastArticle && lastArticle.mtimeMs)) + "</b></span>" +
    '<span class="mem-stat">' + (st.isGitRepo ? "git-tracked" : "not a git repo") + "</span>";
}

/* ────────────────────────────────────────────────────────────────────
   List view: status + search + article/reference lists
   ──────────────────────────────────────────────────────────────────── */

function emptyVaultHtml(root: string): string {
  return (
    '<div class="mem-empty">' +
    "<p>No memory vault yet at <code>" + esc(root) + "</code>.</p>" +
    '<p style="margin-top:8px">Memory is a local, git-tracked wiki the assistant reads from (never writes to during chat) — nightly synthesis is what updates it.</p>' +
    '<div class="mcta"><button class="btn primary sm" id="mem-empty-init">Set up memory</button></div>' +
    "</div>"
  );
}

function articleRowHtml(name: string, excerpt?: string, icon = "📄"): string {
  const display = name.startsWith("Reference/") ? name.slice("Reference/".length) : name;
  return (
    '<div class="mem-art" data-article="' + esc(name) + '" tabindex="0" role="button">' +
    '<span class="mem-art-ico" aria-hidden="true">' + esc(icon) + "</span>" +
    '<div style="min-width:0;flex:1 1 auto">' +
    '<div class="mem-art-name">' + esc(display.replace(/_/g, " ")) + "</div>" +
    (excerpt ? '<div class="mem-art-excerpt">' + esc(excerpt) + "</div>" : "") +
    "</div></div>"
  );
}

function wireArticleRows(container: HTMLElement): void {
  container.querySelectorAll<HTMLElement>(".mem-art").forEach((row) => {
    const open = () => { const name = row.dataset.article; if (name) showArticle(name); };
    row.addEventListener("click", open);
    row.addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter") open(); });
  });
}

async function renderListBody(): Promise<void> {
  const body = $("mem-body");
  const st = await fetchStatus();
  if (!st.enabled || !st.status) {
    body.innerHTML = emptyVaultHtml(st.root || "~/.mlx-bun/wiki");
    const btn = $("mem-empty-init") as HTMLButtonElement | null;
    if (btn) btn.onclick = () => runInit(body);
    return;
  }
  renderStatusStrip(st.status);
  body.innerHTML =
    '<input type="search" id="mem-search" placeholder="Search articles…" aria-label="Search memory" autocomplete="off">' +
    '<div id="mem-list"></div>';
  await renderArticleLists("");
  const search = $("mem-search") as HTMLInputElement;
  let debounce: ReturnType<typeof setTimeout> | undefined;
  search.addEventListener("input", () => {
    clearTimeout(debounce);
    debounce = setTimeout(() => renderArticleLists(search.value.trim()), 180);
  });
}

async function renderArticleLists(query: string): Promise<void> {
  const listEl = $("mem-list");
  if (!query) {
    const d = await getJson<ListResp>("/api/memory/list").catch((): ListResp => ({ ok: false }));
    if (!d.ok) { listEl.innerHTML = '<div class="mem-list-empty">Couldn\'t load the vault contents.</div>'; return; }
    const articles = d.articles || [], reference = d.reference || [];
    listEl.innerHTML =
      '<div class="mem-sec"><div class="mem-sec-title">Articles</div>' +
      (articles.length
        ? articles.map((a) => articleRowHtml(a)).join("")
        : '<div class="mem-list-empty">No articles yet — nightly synthesis writes here after a few conversations.</div>') +
      "</div>" +
      // Reference/ docs are clearly separated (plan §5.5) — mlx-bun's own
      // docs, not personal memory.
      (reference.length
        ? '<div class="mem-sec"><div class="mem-sec-title">Reference</div>' +
          reference.map((r) => articleRowHtml(r, undefined, "📘")).join("") + "</div>"
        : "");
    wireArticleRows(listEl);
    return;
  }
  const d = await getJson<SearchResp>("/api/memory/search?q=" + encodeURIComponent(query)).catch((): SearchResp => ({ ok: false }));
  if (!d.ok || !d.summaries || !d.summaries.length) {
    listEl.innerHTML = '<div class="mem-list-empty">No matches for “' + esc(query) + '”.</div>';
    return;
  }
  const hitsByArticle = new Map<string, SearchHit>();
  for (const h of d.hits || []) if (!hitsByArticle.has(h.article)) hitsByArticle.set(h.article, h);
  listEl.innerHTML =
    '<div class="mem-sec"><div class="mem-sec-title">' + d.summaries.length + " match" + (d.summaries.length === 1 ? "" : "es") + "</div>" +
    d.summaries.map((s) => articleRowHtml(s.article, hitsByArticle.get(s.article)?.excerpt, s.article.startsWith("Reference/") ? "📘" : "📄")).join("") +
    "</div>";
  wireArticleRows(listEl);
}

async function runInit(body: HTMLElement): Promise<void> {
  body.innerHTML = '<div class="mem-empty"><p><span class="shimmer">setting up your local memory vault…</span></p></div>';
  const d = await api<InitResp>("/api/memory/init", { method: "POST" }).catch((): InitResp => ({ ok: false, error: "request failed" }));
  if (!d.ok) {
    toast("Couldn't set up memory: " + (d.error || "unknown error"), "err");
    cachedStatus = null;
    await renderListBody();
    return;
  }
  toast("Memory vault created", "ok");
  cachedStatus = null;
  await refreshSidebarEntry();
  await showList();
}

async function showList(): Promise<void> {
  currentView = { kind: "list" };
  setBack(false);
  $("mem-title").textContent = "Memory";
  $("mem-body").scrollTop = 0;
  await renderListBody();
}

/* ────────────────────────────────────────────────────────────────────
   Article view: rendered content + links line + History toggle
   ──────────────────────────────────────────────────────────────────── */

function linksLineHtml(outbound: string[], inbound: string[]): string {
  if (!outbound.length && !inbound.length) return "";
  const row = (label: string, names: string[]) => names.length
    ? '<div class="mem-links-row"><span class="lbl">' + label + "</span>" +
      names.map((n) => '<button class="mem-link-chip" type="button" data-article="' + esc(n) + '">' + esc(n.replace(/_/g, " ")) + "</button>").join("") +
      "</div>"
    : "";
  return '<div class="mem-links">' + row("links to", outbound) + row("linked from", inbound) + "</div>";
}

function wireLinkChips(container: HTMLElement): void {
  container.querySelectorAll<HTMLButtonElement>(".mem-link-chip").forEach((btn) => {
    btn.addEventListener("click", () => { const name = btn.dataset.article; if (name) showArticle(name); });
  });
}

async function showArticle(name: string): Promise<void> {
  currentView = { kind: "article", name };
  setBack(true);
  const display = name.startsWith("Reference/") ? name.slice("Reference/".length) : name;
  $("mem-title").textContent = display.replace(/_/g, " ");
  const body = $("mem-body");
  body.innerHTML = '<p class="mem-list-empty"><span class="shimmer">loading article…</span></p>';
  body.scrollTop = 0;

  const [artRes, linksRes] = await Promise.all([
    getJson<ArticleResp>("/api/memory/article?name=" + encodeURIComponent(name)).catch((): ArticleResp => ({ ok: false })),
    getJson<LinksResp>("/api/memory/links?name=" + encodeURIComponent(name)).catch((): LinksResp => ({ ok: false })),
  ]);
  if (!artRes.ok || artRes.content == null) {
    body.innerHTML = '<div class="mem-list-empty">Couldn\'t load “' + esc(display) + '”.</div>';
    return;
  }

  body.innerHTML =
    '<div class="mem-art-head">' +
    '<div class="mem-art-tabs">' +
    '<button class="mem-art-tab active" id="mem-tab-view" type="button">Article</button>' +
    '<button class="mem-art-tab" id="mem-tab-history" type="button">History</button>' +
    "</div></div>" +
    '<div id="mem-art-view">' +
    // data-ui-chrome="content": rendered vault-article markdown (synthesized
    // from past conversations, not app-authored UI) can contain arbitrary
    // links — excluded from captureUiSnapshot for the same reason chat-thread
    // is (see assistant.ts's isAgentChrome doc comment: that snapshot is
    // re-served to the model verbatim as trusted UI state).
    '<div class="mem-article-render" data-ui-chrome="content">' + mdToHtml(artRes.content) + "</div>" +
    linksLineHtml((linksRes.outbound || []), (linksRes.inbound || [])) +
    "</div>" +
    '<div id="mem-art-history" style="display:none"></div>';

  wireLinkChips(body);
  ($("mem-tab-view") as HTMLButtonElement).onclick = () => switchArticleTab("view");
  ($("mem-tab-history") as HTMLButtonElement).onclick = () => switchArticleTab("history", name);
}

async function switchArticleTab(tab: "view" | "history", name?: string): Promise<void> {
  $("mem-tab-view").classList.toggle("active", tab === "view");
  $("mem-tab-history").classList.toggle("active", tab === "history");
  $("mem-art-view").style.display = tab === "view" ? "" : "none";
  $("mem-art-history").style.display = tab === "history" ? "" : "none";
  if (tab === "history" && name) await renderHistoryPane(name);
}

async function renderHistoryPane(name: string): Promise<void> {
  const pane = $("mem-art-history");
  if (pane.dataset.loaded === name) return; // cheap: don't re-fetch on every tab click
  pane.innerHTML = '<p class="mem-list-empty"><span class="shimmer">loading history…</span></p>';
  const d = await getJson<HistoryResp>("/api/memory/history?name=" + encodeURIComponent(name)).catch((): HistoryResp => ({ ok: false }));
  if (!d.ok || !d.entries) {
    pane.innerHTML = '<div class="mem-list-empty">No history available (not a git-tracked vault, or nothing committed yet).</div>';
    return;
  }
  if (!d.entries.length) {
    pane.innerHTML = '<div class="mem-list-empty">No commits touch this article yet.</div>';
    return;
  }
  pane.dataset.loaded = name;
  pane.innerHTML =
    d.entries.map((e) =>
      '<div class="mem-hist-entry" data-hash="' + esc(e.hash) + '" tabindex="0" role="button">' +
      '<span class="mem-hist-subject">' + esc(e.subject || "(no subject)") + "</span>" +
      '<span class="mem-hist-date">' + esc(e.date) + "</span>" +
      '<span class="mem-hist-hash">' + esc(e.hash.slice(0, 7)) + "</span>" +
      "</div>",
    ).join("") + '<div class="mem-diff" id="mem-diff-body" style="display:none"></div>';
  pane.querySelectorAll<HTMLElement>(".mem-hist-entry").forEach((row) => {
    const open = async () => {
      pane.querySelectorAll(".mem-hist-entry").forEach((r) => r.classList.remove("active"));
      row.classList.add("active");
      const hash = row.dataset.hash!;
      const diffEl = $("mem-diff-body");
      diffEl.style.display = "";
      diffEl.textContent = "loading diff…";
      const dr = await getJson<DiffResp>(
        "/api/memory/diff?name=" + encodeURIComponent(name) + "&rev=" + encodeURIComponent(hash),
      ).catch((): DiffResp => ({ ok: false }));
      diffEl.innerHTML = dr.ok && dr.diff ? diffToHtml(dr.diff) : '<span class="diffctx">Couldn\'t load this diff.</span>';
    };
    row.addEventListener("click", open);
    row.addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter") open(); });
  });
}

/** Render a `git show` unified diff as an added/removed-lines block, matching
 *  the existing code-panel visual language (.diffadd/.diffdel, same classes
 *  the approval card's edit-diff view uses). Line-oriented and escaped —
 *  never trusts diff content as markup. */
function diffToHtml(diff: string): string {
  return diff
    .split("\n")
    .map((line) => {
      if (line.startsWith("+++") || line.startsWith("---")) return '<span class="diffctx">' + esc(line) + "</span>";
      if (line.startsWith("@@")) return '<span class="diffhunk">' + esc(line) + "</span>";
      if (line.startsWith("+")) return '<span class="diffadd">' + esc(line) + "</span>";
      if (line.startsWith("-")) return '<span class="diffdel">' + esc(line) + "</span>";
      return '<span class="diffctx">' + esc(line) + "</span>";
    })
    .join("\n");
}

/* ────────────────────────────────────────────────────────────────────
   Sidebar entry (article count, quiet — not a nav tab)
   ──────────────────────────────────────────────────────────────────── */

export async function refreshSidebarEntry(): Promise<void> {
  const st = await fetchStatus(true);
  const entry = $("chat-memory-entry");
  if (!st.ok || !st.enabled || !st.status) {
    // No vault yet: keep the entry reachable (opening it shows the
    // "set up memory" empty state) but the count reads as an invite, not
    // a stat, so it never looks like a broken zero.
    entry.style.display = "";
    $("chat-memory-count").textContent = "set up";
    return;
  }
  entry.style.display = "";
  $("chat-memory-count").textContent = String(st.status.articleCount);
}

/* ────────────────────────────────────────────────────────────────────
   Provenance chips (plan §5.4.2) — rendered by chat.ts in place of the
   generic wrench tool card for any memory_ or reference_ tool call.
   ──────────────────────────────────────────────────────────────────── */

// Kept in sync with MEMORY_TOOL_NAMES/REFERENCE_TOOL_NAMES (src/memory/tools.ts)
// by a literal list rather than an import: this module must stay
// server-code-free (bundler-enforced, see chat.ts's header comment), so it
// can't import a value from src/memory/tools.ts even though the identifiers
// are the same. tests/using/web-app.test.ts cross-checks this list against the
// real export so drift is caught at test time instead of silently.
export const MEMORY_CHIP_TOOL_NAMES = [
  "memory_resolve", "memory_category", "memory_read", "memory_section",
  "memory_links", "memory_infobox", "memory_list", "memory_status", "memory_search",
  "reference_search", "reference_read", "reference_list",
] as const;

export function isMemoryToolName(tool: string): boolean {
  return (MEMORY_CHIP_TOOL_NAMES as readonly string[]).includes(tool);
}

/** Best-effort article name out of a memory tool call's args (every memory_*
 *  tool takes some form of `article`/`name`/`category`/`query`) — used only
 *  for the chip's label and as the target for "open in Memory panel"; never
 *  trusted for anything security-sensitive. */
function articleNameFromArgs(tool: string, args: unknown): string | null {
  if (!args || typeof args !== "object") return null;
  const a = args as Record<string, unknown>;
  const cand = a.article ?? a.name ?? a.category ?? a.query;
  return typeof cand === "string" && cand.trim() ? cand.trim() : null;
}

function chipVerb(tool: string): string {
  if (tool === "memory_search" || tool === "reference_search") return "searched";
  if (tool === "memory_links") return "traced links from";
  if (tool === "memory_list" || tool === "memory_status" || tool === "reference_list") return "checked";
  return "read";
}

/** Builds the collapsed citation-chip DOM node for a memory/reference tool
 *  call, appended into the assistant bubble in place of the generic .tool
 *  wrench card (chat.ts dispatches on isMemoryToolName() before falling
 *  back to its own toolCard()). Returns handles chat.ts needs to update the
 *  chip as tool_update/tool_end frames arrive, mirroring ToolCardState's
 *  shape closely enough that the call sites read the same way. */
export interface MemChipHandle {
  wrap: HTMLElement;
  setResult(result: unknown): void;
}

export function memoryToolChip(parent: HTMLElement, tool: string, args: unknown): MemChipHandle {
  const articleName = articleNameFromArgs(tool, args);
  const wrap = el("div", "memchip", parent);
  const label = articleName
    ? "<b>" + chipVerb(tool) + "</b> " + esc(articleName.replace(/_/g, " "))
    : "<b>" + chipVerb(tool) + "</b> memory";
  wrap.innerHTML =
    '<div class="mchead"><span class="mcicon" aria-hidden="true">◆</span>' +
    '<span class="mclabel">' + label + "</span>" +
    '<span class="mccaret">›</span></div>' +
    '<div class="mcbody"><pre class="mcresult"></pre>' +
    (articleName ? '<button class="mcopen" type="button">Open in Memory</button>' : "") +
    "</div>";
  wrap.querySelector(".mchead")!.addEventListener("click", () => wrap.classList.toggle("open"));
  const openBtn = wrap.querySelector(".mcopen") as HTMLButtonElement | null;
  if (openBtn && articleName) openBtn.onclick = (e) => { e.stopPropagation(); openMemPanel(articleName); };
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
   Personalized hero chips (plan §5.1) — replaces the 4 static chips with
   one drawn from a real article + one adapter offer when either backend
   signal is available; falls back to the existing static chips otherwise
   (never fewer chips than today, never a broken/empty row).
   ──────────────────────────────────────────────────────────────────── */

interface AdapterAvailable { id: string; compatible?: boolean }

/** Swaps in up to 2 personalized chips ahead of the static ones, using the
 *  SAME .chip class + data-q click contract chat.ts already wires up (see
 *  chat.ts's `#chat-hello .chip` listener) — so no new click-handling path
 *  is needed for these chips to actually send a message. */
export async function personalizeHeroChips(): Promise<void> {
  const container = $("chat-hello-chips");
  if (!container) return;
  const extra: string[] = [];

  const st = await fetchStatus();
  if (st.ok && st.enabled && st.status && st.status.recentArticles.length) {
    const name = st.status.recentArticles[0]!.article;
    const display = name.replace(/_/g, " ");
    extra.push(
      '<button class="chip" data-q="' + esc("What do you remember about " + display + "?") + '">Ask about ' + esc(display) + "</button>",
    );
  }

  try {
    const d = await getJson<{ adapters?: AdapterAvailable[] }>("/v1/adapters/available");
    const compatible = (d.adapters || []).find((a) => a.compatible !== false);
    if (compatible) {
      extra.push(
        '<button class="chip" data-q="' + esc("Can you try answering with the " + compatible.id + " adapter?") + '">Try the ' + esc(compatible.id) + " adapter</button>",
      );
    }
  } catch { /* adapters are optional personalization — no adapter list is not an error */ }

  if (!extra.length) return; // keep the existing static chips exactly as they are
  // No per-chip click wiring needed: chat.ts's init() binds ONE delegated
  // listener on #chat-hello-chips (not per-.chip), so newly-inserted nodes
  // work for free regardless of init() vs. this async call's ordering.
  container.insertAdjacentHTML("afterbegin", extra.join(""));
}

/* ────────────────────────────────────────────────────────────────────
   Consent card (plan §5.1) — first run only, never auto-creates the vault.
   ──────────────────────────────────────────────────────────────────── */

const CONSENT_DISMISSED_KEY = "mlxbun.memoryConsentDismissed";

function isConsentDismissed(): boolean {
  return localStorage.getItem(CONSENT_DISMISSED_KEY) === "1";
}
function dismissConsent(): void {
  localStorage.setItem(CONSENT_DISMISSED_KEY, "1");
  $("chat-consent").classList.remove("show");
}

/** Shows the consent card iff there's no vault yet and it's never been
 *  dismissed. Called once after the first status fetch (chat.ts's init,
 *  alongside personalizeHeroChips) — never polled/re-shown mid-session. */
export async function maybeShowConsentCard(): Promise<void> {
  const card = $("chat-consent");
  if (!card) return;
  if (isConsentDismissed()) return;
  const st = await fetchStatus();
  if (st.ok && st.enabled) return; // vault already exists — nothing to consent to
  card.classList.add("show");
}

function wireConsentCard(): void {
  const skip = $("chat-consent-skip") as HTMLButtonElement | null;
  const yes = $("chat-consent-yes") as HTMLButtonElement | null;
  if (skip) skip.onclick = dismissConsent;
  if (yes) yes.onclick = async () => {
    yes.disabled = true;
    const d = await api<InitResp>("/api/memory/init", { method: "POST" }).catch((): InitResp => ({ ok: false, error: "request failed" }));
    yes.disabled = false;
    if (!d.ok) { toast("Couldn't set up memory: " + (d.error || "unknown error"), "err"); return; }
    dismissConsent();
    cachedStatus = null;
    toast("Memory vault created", "ok");
    await refreshSidebarEntry();
    await openMemPanel();
  };
}

/* ────────────────────────────────────────────────────────────────────
   Init — wires the sidebar entry, panel chrome (close/back/focus-trap/
   Escape), and the consent card. Call once at chat controller init.
   ──────────────────────────────────────────────────────────────────── */

export function initMemoryPanel(): void {
  panelTrap = trapFocus($("mem-overlay"), isMemPanelOpen);
  setMemPanelClose(closeMemPanel); // registers with shell.ts's global Escape sweep
  const entry = $("chat-memory-entry") as HTMLButtonElement;
  entry.onclick = () => openMemPanel();
  ($("mem-close") as HTMLButtonElement).onclick = closeMemPanel;
  ($("mem-back") as HTMLButtonElement).onclick = () => showList();
  $("mem-overlay").addEventListener("click", (e) => { if (e.target === $("mem-overlay")) closeMemPanel(); });
  // Canvas v1 (plan §9 Phase 3): same Preview|Source toggle as the chat
  // thread, shared via markdown.ts — mem-body is the stable ancestor whose
  // innerHTML gets replaced per article, same delegation pattern as chat.ts.
  wireCanvasToggle($("mem-body"));
  wireConsentCard();
  refreshSidebarEntry();
  personalizeHeroChips();
  maybeShowConsentCard();
}
