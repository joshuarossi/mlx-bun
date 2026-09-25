// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 3). Built into src/web/app.js by scripts/build-web.ts.
//
// Model Hub panel (docs/design/web-chat-redesign.md §9 Phase 3, beat-matrix
// Axis 3 "Hub" row). Same overlay language/chrome as the Memory panel
// (mem-overlay/mem-panel/mem-head/mem-body): fixed right-side panel,
// scrimmed, focus-trapped, Escape closes, opened from the model picker
// popover's "Browse models…" action (and exported for palette use later).
//
// Three sections talking to src/hub-rest.ts's REST wrappers — no new WS
// frames:
//   - Downloaded  <- GET /api/hub/local  (size/quant/capability chips, the
//     /fit verdict as a green/yellow/red dot + predicted tok/s, a "serve"
//     action).
//   - Search Hugging Face <- debounced GET /api/hub/search (id/downloads/
//     size, a Download action -> POST /api/hub/download, then live progress
//     via polling GET /downloads while the panel stays open).
//   - A quiet offline footer note when search/local fail to reach the
//     network (never conflated with "no results").
//
// NEVER auto-downloads, NEVER auto-serves — every action is an explicit
// click. esc() every interpolation site: repo ids/model types are
// server-reported but ultimately HF-namespace strings, same hazard class
// model-picker.ts already treats as untrusted.

import { $, toast, trapFocus, setHubPanelClose, setOpenHubFromModelPicker, type FocusTrap } from "./shell";
import { api } from "./api";
import type { ApiEnvelope } from "./protocol";
import { esc } from "./markdown";

/* ────────────────────────────────────────────────────────────────────
   REST response shapes (mirrors src/hub-rest.ts's jsonOk() bodies).
   ──────────────────────────────────────────────────────────────────── */

export interface HubLocalRow {
  repo_id: string;
  model_type: string;
  size_bytes: number;
  quant_bits: number | null;
  quant_group_size: number | null;
  vision: boolean;
  supported: boolean;
  support_tier: "targeted" | "generic" | null;
  assessment: { fits: boolean; max_safe_context: number; predicted_decode_tps: number } | null;
}
type LocalResp = ApiEnvelope & { models?: HubLocalRow[] };

export interface HubSearchRow {
  id: string;
  downloads: number;
  likes: number;
  size_estimate: number | null;
}
type SearchResp = ApiEnvelope & { offline?: boolean; results?: HubSearchRow[] };

interface DownloadInfo {
  repoId: string;
  state: "active" | "done" | "error";
  currentFile: string | null;
  receivedBytes: number;
  totalBytes: number;
  bytesPerSec?: number;
  error?: string;
}
type DownloadsResp = { downloads?: DownloadInfo[] };

/* ────────────────────────────────────────────────────────────────────
   Shared formatting (local copies — hub.ts has no import from
   model-picker.ts to avoid a cross-popover coupling neither side needs).
   ──────────────────────────────────────────────────────────────────── */

function gb(n: number): string { return (n / 2 ** 30).toFixed(1) + " GB"; }

/** Same three-tier convention as model-picker.ts's fitVerdict: green (fits
 *  with headroom, >=10 tok/s), yellow (fits but slow), red (doesn't fit),
 *  null (no assessment). Kept as a local copy rather than a shared import
 *  since the two modules' row shapes differ slightly (Hub's assessment is
 *  non-optional-null but otherwise identical) — duplicating one small pure
 *  function is cheaper than adding a cross-import for four lines of logic. */
function fitVerdict(a: HubLocalRow["assessment"]): "green" | "yellow" | "red" | null {
  if (!a) return null;
  if (!a.fits) return "red";
  return a.predicted_decode_tps >= 10 ? "green" : "yellow";
}

function fitDotHtml(verdict: "green" | "yellow" | "red" | null): string {
  return verdict
    ? '<span class="hub-fit-dot ' + verdict + '" aria-hidden="true"></span>'
    : '<span class="hub-fit-dot" aria-hidden="true" style="background:var(--dimmer)"></span>';
}

/* ────────────────────────────────────────────────────────────────────
   Downloaded section
   ──────────────────────────────────────────────────────────────────── */

function localRowHtml(m: HubLocalRow): string {
  const verdict = fitVerdict(m.assessment);
  const name = m.repo_id.split("/").pop() || m.repo_id;
  const quant = m.quant_bits ? m.quant_bits + "-bit" : "unquantized";
  const metaBits = [gb(m.size_bytes), quant];
  if (m.vision) metaBits.push("vision");
  if (!m.supported) metaBits.push("unsupported model family");
  const tpsBit = m.assessment && m.assessment.fits
    ? m.assessment.predicted_decode_tps.toFixed(0) + " tok/s predicted"
    : m.assessment ? "doesn't fit this Mac's memory" : "fit unknown";
  const serveBtn = m.supported
    ? '<button type="button" class="hub-serve-btn" data-repo="' + esc(m.repo_id) + '">Serve</button>'
    : "";
  return (
    '<div class="hub-row">' +
      fitDotHtml(verdict) +
      '<div class="hub-row-main">' +
        '<div class="hub-row-name" title="' + esc(m.repo_id) + '">' + esc(name) + "</div>" +
        '<div class="hub-row-meta">' + esc(metaBits.join(" · ")) + " · " + esc(tpsBit) + "</div>" +
      "</div>" +
      '<div class="hub-row-actions">' + serveBtn + "</div>" +
    "</div>"
  );
}

/** Pure render, exported for esc()-discipline + empty-state tests
 *  (tests/using/web-app.test.ts, mirroring renderModelPopBodyHtml's pattern). */
export function renderHubLocalHtml(models: HubLocalRow[]): string {
  if (!models.length) {
    return '<div class="hub-empty">No models downloaded yet — search Hugging Face below to get one.</div>';
  }
  return [...models]
    .sort((a, b) => a.repo_id.localeCompare(b.repo_id))
    .map(localRowHtml)
    .join("");
}

async function loadLocal(): Promise<void> {
  const body = $("hub-local-body");
  if (!body) return;
  body.innerHTML = '<div class="hub-empty"><span class="shimmer">loading…</span></div>';
  try {
    const d = await api<LocalResp>("/api/hub/local");
    body.innerHTML = renderHubLocalHtml(d.models || []);
    wireServeButtons(body);
  } catch {
    body.innerHTML = '<div class="hub-empty">Could not reach the server.</div>';
  }
}

/* ────────────────────────────────────────────────────────────────────
   Serve action — handles BOTH the live-swap outcome (if a future server
   ever returns ok:true) and today's honest restart_required outcome,
   rendered as a copy-able command. NEVER auto-serves — this is only
   reachable from an explicit button click.
   ──────────────────────────────────────────────────────────────────── */

function wireServeButtons(container: HTMLElement): void {
  container.querySelectorAll<HTMLButtonElement>(".hub-serve-btn").forEach((btn) => {
    btn.onclick = () => serveModel(btn.dataset.repo || "", btn);
  });
}

type ServeResp = ApiEnvelope & { restart_required?: boolean; command?: string };

async function serveModel(repo: string, btn: HTMLButtonElement): Promise<void> {
  if (!repo) return;
  btn.disabled = true;
  const prevText = btn.textContent;
  btn.textContent = "Checking…";
  const d = await api<ServeResp>("/api/hub/serve", { method: "POST", body: { model: repo } })
    .catch((): ServeResp => ({ ok: false, error: "request failed" }));
  btn.disabled = false;
  btn.textContent = prevText;
  if (d.ok) {
    // Honest today-doesn't-happen branch, kept real rather than dead code:
    // if the server ever reports a completed live swap, reflect it plainly.
    toast("Now serving " + repo, "ok");
    return;
  }
  if (d.restart_required && d.command) {
    showRestartCommand(repo, d.command);
    return;
  }
  toast("Couldn't switch models: " + (d.error || "unknown error"), "err");
}

/** Renders the restart command inline in the footer strip (not a toast —
 *  it needs to stay visible long enough to copy) with an honest note:
 *  restarting takes ~seconds and sessions are preserved on disk (chat
 *  history lives in local JSON regardless of which model process serves
 *  it — restarting the model doesn't touch it). */
function showRestartCommand(repo: string, command: string): void {
  const strip = $("hub-restart-strip");
  if (!strip) return;
  strip.innerHTML =
    '<div class="hub-restart-note">Switching to <strong>' + esc(repo) + '</strong> needs a restart — ' +
    "there's no live in-process model swap on this path yet. Restarting takes about a second " +
    "and your sessions are preserved on disk, exactly as they are now.</div>" +
    '<div class="hub-cmd"><code>' + esc(command) + '</code>' +
    '<button type="button" class="hub-copy-btn" data-cmd="' + esc(command) + '">Copy</button></div>';
  strip.classList.add("show");
  const copyBtn = strip.querySelector(".hub-copy-btn") as HTMLButtonElement | null;
  if (copyBtn) {
    copyBtn.onclick = () => {
      const cmd = copyBtn.dataset.cmd || "";
      if (navigator.clipboard) {
        navigator.clipboard.writeText(cmd).then(() => {
          const prev = copyBtn.textContent; copyBtn.textContent = "Copied";
          setTimeout(() => { copyBtn.textContent = prev; }, 1200);
        }).catch(() => {});
      }
    };
  }
}

function hideRestartStrip(): void {
  const strip = $("hub-restart-strip");
  if (strip) { strip.classList.remove("show"); strip.innerHTML = ""; }
}

/* ────────────────────────────────────────────────────────────────────
   Search Hugging Face section — debounced, offline-aware.
   ──────────────────────────────────────────────────────────────────── */

function searchRowHtml(r: HubSearchRow, downloading: boolean): string {
  const name = r.id.split("/").pop() || r.id;
  const metaBits = [r.downloads.toLocaleString() + " downloads"];
  if (r.size_estimate != null) metaBits.push(gb(r.size_estimate));
  const action = downloading
    ? '<span class="hub-dl-tag">downloading…</span>'
    : '<button type="button" class="hub-download-btn" data-repo="' + esc(r.id) + '">Download</button>';
  return (
    '<div class="hub-row" data-search-repo="' + esc(r.id) + '">' +
      '<div class="hub-row-main">' +
        '<div class="hub-row-name" title="' + esc(r.id) + '">' + esc(name) + "</div>" +
        '<div class="hub-row-meta">' + esc(r.id) + " · " + esc(metaBits.join(" · ")) + "</div>" +
      "</div>" +
      '<div class="hub-row-actions">' + action + "</div>" +
    "</div>"
  );
}

/** Pure render, exported for tests. `downloading` is the set of repo ids
 *  with an active download right now (from GET /downloads polling). */
export function renderHubSearchHtml(results: HubSearchRow[], offline: boolean, downloading: Set<string>): string {
  if (offline) {
    return '<div class="hub-empty">Can\'t reach Hugging Face right now — search needs a network connection.</div>';
  }
  if (!results.length) {
    return '<div class="hub-empty">No matches.</div>';
  }
  return results.map((r) => searchRowHtml(r, downloading.has(r.id))).join("");
}

let searchDebounce: ReturnType<typeof setTimeout> | undefined;
let lastSearchQuery = "";
let inFlightDownloads = new Set<string>();

async function runSearch(query: string): Promise<void> {
  const body = $("hub-search-body");
  if (!body) return;
  lastSearchQuery = query;
  if (!query) { body.innerHTML = '<div class="hub-empty">Type to search Hugging Face for MLX models.</div>'; return; }
  body.innerHTML = '<div class="hub-empty"><span class="shimmer">searching…</span></div>';
  const d = await api<SearchResp>("/api/hub/search?q=" + encodeURIComponent(query))
    .catch((): SearchResp => ({ ok: false, offline: true, results: [] }));
  if (lastSearchQuery !== query) return; // a newer keystroke already superseded this response
  const offline = !!d.offline;
  body.innerHTML = renderHubSearchHtml(d.results || [], offline, inFlightDownloads);
  wireDownloadButtons(body);
  setOfflineFooter(offline);
}

function wireDownloadButtons(container: HTMLElement): void {
  container.querySelectorAll<HTMLButtonElement>(".hub-download-btn").forEach((btn) => {
    btn.onclick = () => startDownload(btn.dataset.repo || "", btn);
  });
}

type DownloadStartResp = ApiEnvelope & { repo?: string; started?: boolean };

async function startDownload(repo: string, btn: HTMLButtonElement): Promise<void> {
  if (!repo) return;
  btn.disabled = true;
  btn.textContent = "Starting…";
  const d = await api<DownloadStartResp>("/api/hub/download", { method: "POST", body: { repo } })
    .catch((): DownloadStartResp => ({ ok: false, error: "request failed" }));
  if (!d.ok) {
    btn.disabled = false;
    btn.textContent = "Download";
    toast("Couldn't start download: " + (d.error || "unknown error"), "err");
    return;
  }
  inFlightDownloads.add(repo);
  toast("Downloading " + repo, "ok");
  const row = btn.closest(".hub-row");
  const actions = row ? row.querySelector(".hub-row-actions") : null;
  if (actions) actions.innerHTML = '<span class="hub-dl-tag">downloading…</span>';
  ensureDownloadPolling();
}

/* ────────────────────────────────────────────────────────────────────
   Live download progress — reuses the existing GET /downloads endpoint
   (same source the nav download pill polls) so the Hub panel's own
   in-flight rows show real progress without a second tracker. Only polls
   while the panel is open (started on open, stopped on close).
   ──────────────────────────────────────────────────────────────────── */

let downloadPollTimer: ReturnType<typeof setInterval> | undefined;

function ensureDownloadPolling(): void {
  if (downloadPollTimer) return;
  downloadPollTimer = setInterval(pollDownloads, 1500);
}

function stopDownloadPolling(): void {
  if (downloadPollTimer) { clearInterval(downloadPollTimer); downloadPollTimer = undefined; }
}

async function pollDownloads(): Promise<void> {
  let downloads: DownloadInfo[] = [];
  try {
    const r = await fetch("/downloads");
    const d = (await r.json()) as DownloadsResp;
    downloads = d.downloads || [];
  } catch { return; }

  let anyActive = false;
  for (const dl of downloads) {
    if (dl.state === "active") { anyActive = true; inFlightDownloads.add(dl.repoId); }
    const row = document.querySelector<HTMLElement>('.hub-row[data-search-repo="' + cssEscape(dl.repoId) + '"]');
    if (!row) continue;
    const actions = row.querySelector(".hub-row-actions");
    if (!actions) continue;
    if (dl.state === "active") {
      const pct = dl.totalBytes ? Math.floor((dl.receivedBytes / dl.totalBytes) * 100) : 0;
      actions.innerHTML = '<span class="hub-dl-tag">' + pct + "%</span>";
    } else if (dl.state === "done") {
      inFlightDownloads.delete(dl.repoId);
      actions.innerHTML = '<span class="hub-dl-tag done">done — reload to serve</span>';
    } else if (dl.state === "error") {
      inFlightDownloads.delete(dl.repoId);
      actions.innerHTML = '<span class="hub-dl-tag error">' + esc(dl.error || "download failed") + "</span>";
    }
  }
  // A download that finished/errored and dropped out of the tracker's
  // rolling window entirely still needs its stale "downloading…" tag
  // cleared — treat "not present anymore" the same as "not active".
  for (const repo of [...inFlightDownloads]) {
    if (!downloads.some((d) => d.repoId === repo && d.state === "active")) inFlightDownloads.delete(repo);
  }
  if (!anyActive) stopDownloadPolling();
}

/** Minimal CSS.escape polyfill-free helper for attribute-selector lookups —
 *  repo ids are `org/name` (slash + alnum/hyphen/underscore/dot), so a full
 *  CSS.escape isn't needed; this only guards the one character (`"`) that
 *  would break the quoted attribute selector above. HF repo ids can't
 *  contain quotes, but this stays defensive rather than assuming it. */
function cssEscape(s: string): string {
  return s.replace(/"/g, '\\"');
}

/* ────────────────────────────────────────────────────────────────────
   Panel chrome: open/close, focus trap, section wiring.
   ──────────────────────────────────────────────────────────────────── */

let panelTrap: FocusTrap;

export function isHubPanelOpen(): boolean {
  const ov = $("hub-overlay");
  return !!ov && ov.classList.contains("open");
}

export function closeHubPanel(): void {
  $("hub-overlay").classList.remove("open");
  stopDownloadPolling();
  panelTrap.restore();
}

export async function openHubPanel(): Promise<void> {
  panelTrap.capture();
  $("hub-overlay").classList.add("open");
  hideRestartStrip();
  const search = $("hub-search-input") as HTMLInputElement | null;
  if (search) search.value = "";
  const searchBody = $("hub-search-body");
  if (searchBody) searchBody.innerHTML = '<div class="hub-empty">Type to search Hugging Face for MLX models.</div>';
  setOfflineFooter(false);
  await loadLocal();
  if (inFlightDownloads.size) ensureDownloadPolling();
  setTimeout(() => { const el2 = $("hub-search-input") as HTMLInputElement | null; if (el2) el2.focus(); }, 30);
}

function setOfflineFooter(offline: boolean): void {
  const note = $("hub-offline-note");
  if (!note) return;
  note.style.display = offline ? "" : "none";
}

/** Wires the panel chrome + registers the open-from-model-picker callback.
 *  Call once at chat controller init, same lifecycle as initMemoryPanel().
 *  The model picker's "Browse models…" button is re-rendered via innerHTML
 *  on every popover open (model-picker.ts's refreshModelPop()), so it can't
 *  hold a handler bound once here — model-picker.ts calls
 *  openHubFromModelPicker() (shell.ts's registered-callback pattern)
 *  instead of a direct element lookup. */
export function initHubPanel(): void {
  panelTrap = trapFocus($("hub-overlay"), isHubPanelOpen);
  setHubPanelClose(closeHubPanel); // registers with shell.ts's global Escape sweep
  setOpenHubFromModelPicker(() => { openHubPanel(); });

  const closeBtn = $("hub-close") as HTMLButtonElement | null;
  if (closeBtn) closeBtn.onclick = closeHubPanel;
  const overlay = $("hub-overlay");
  if (overlay) overlay.addEventListener("click", (e) => { if (e.target === overlay) closeHubPanel(); });

  const search = $("hub-search-input") as HTMLInputElement | null;
  if (search) {
    search.addEventListener("input", () => {
      clearTimeout(searchDebounce);
      const q = search.value.trim();
      searchDebounce = setTimeout(() => runSearch(q), 300);
    });
  }
}

// Exposed for tests that need to reset module-level state between cases.
export function _resetHubStateForTests(): void {
  inFlightDownloads = new Set();
  stopDownloadPolling();
}
