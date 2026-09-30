// `<mlx-models-panel>`: the module's web panel as one self-contained custom element. It imports only its data protocol
// (types) and its own render and style files, draws into its own shadow root and reaches the backend only through
// `connection`, so any host (the web shell, a native webview) mounts it the same way: create the element, set
// `connection`, append it.
//
// Three sections over the module's routes: the downloaded models (`/api/hub/local`, with which one is served and which are
// loaded from `/library`) and a Serve action; Hugging Face search (`/api/hub/search`) with Download and live progress
// (`/downloads`); and the adapters on disk (`/v1/adapters/available`, `/v1/adapters`) with Mount and Unmount. Nothing
// downloads, serves or mounts without an explicit click. The routes keep their shipped root paths, so requests go to the
// origin `connection.apiBase` names (an absolute URL in a native webview, this page's own origin when it is relative).
import type { AvailableAdapterRow, DownloadInfo, HubLocalRow, HubSearchRow, LibraryRow, MountedAdapterRow, PanelConnection } from "../protocol";
import { esc, renderAdaptersHtml, renderHubLocalHtml, renderHubSearchHtml, type Running } from "./render";
import { STYLE } from "./style";

export { esc, fitVerdict, renderAdaptersHtml, renderHubLocalHtml, renderHubSearchHtml } from "./render";
export type { Running } from "./render";

/** Fired (bubbling, composed) on the element whenever the served model or the mounted adapters changed, so the page around it can refresh what it shows. */
export const MODELS_CHANGED = "mlx-models-changed";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

type Envelope = { ok?: boolean; error?: string | { message?: string }; [key: string]: unknown };

class ModelsPanel extends Base {
  #connection: PanelConnection | undefined;
  #shadow: ShadowRoot;
  #inFlight = new Set<string>();
  #pollTimer: ReturnType<typeof setInterval> | undefined;
  #searchTimer: ReturnType<typeof setTimeout> | undefined;
  #lastQuery = "";

  constructor() {
    super();
    this.#shadow = this.attachShadow({ mode: "open" });
    const style = document.createElement("style");
    style.textContent = STYLE;
    const body = document.createElement("div");
    body.innerHTML =
      '<div class="status" id="status" role="status"></div>' +
      '<div class="restart" id="restart"></div>' +
      '<section><h3>Downloaded</h3><p class="note">Fit is predicted for this Mac, not a generic guess. Serving a model loads it beside the running ones when it fits; ' +
      'otherwise the least recently used one is unloaded with its saved state, and switching back resumes it.</p><div id="local"></div></section>' +
      '<section><h3>Search Hugging Face</h3><input type="search" id="query" placeholder="Search MLX models…" aria-label="Search Hugging Face for MLX models" autocomplete="off">' +
      '<div id="results"><div class="hub-empty">Type to search Hugging Face for MLX models.</div></div>' +
      '<p class="offline" id="offline" style="display:none">You\'re offline (or Hugging Face is unreachable) — search needs a network connection, but your downloaded models still work fully offline.</p></section>' +
      '<section><h3>Adapters</h3><p class="note">Every adapter found on disk. Mounting loads it into the served model\'s memory; the chat picks which mounted adapter a turn uses.</p><div id="adapters"></div></section>';
    this.#shadow.append(style, body);
    this.#part("query").addEventListener("input", () => {
      clearTimeout(this.#searchTimer);
      const query = (this.#part("query") as HTMLInputElement).value.trim();
      this.#searchTimer = setTimeout(() => { void this.search(query); }, 300);
    });
  }

  get connection(): PanelConnection | undefined { return this.#connection; }
  set connection(value: PanelConnection | undefined) {
    this.#connection = value;
    if (this.isConnected && value) void this.refresh();
  }

  connectedCallback() { if (this.#connection) void this.refresh(); }
  disconnectedCallback() { this.#stopPolling(); clearTimeout(this.#searchTimer); }

  #part(id: string): HTMLElement { return this.#shadow.getElementById(id)!; }

  /** Where a route lives: at its shipped root path on the origin the connection names (relative to this page when the base is). */
  #url(path: string): string {
    let origin = "";
    try { origin = new URL(this.#connection!.apiBase).origin; } catch { /* a relative base: this page's own origin */ }
    return origin + path;
  }

  async #call<T extends Envelope>(path: string, init?: RequestInit): Promise<T> {
    const response = await fetch(this.#url(path), init);
    const text = await response.text();
    let body: Envelope;
    try { body = text ? JSON.parse(text) : {}; } catch { body = { ok: false, error: text.slice(0, 400) || `HTTP ${response.status}` }; }
    if (body.error && typeof body.error === "object") body.error = body.error.message ?? JSON.stringify(body.error).slice(0, 400);
    if (!response.ok && body.ok === undefined) body = { ...body, ok: false, error: (body.error as string) || `HTTP ${response.status}` };
    return body as T;
  }
  #post<T extends Envelope>(path: string, body: unknown) { return this.#call<T>(path, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) }); }

  #say(text: string, kind: "" | "ok" | "err" = "") {
    const status = this.#part("status");
    status.textContent = text;
    status.className = "status" + (kind ? " " + kind : "");
  }
  #changed() { this.dispatchEvent(new CustomEvent(MODELS_CHANGED, { bubbles: true, composed: true })); }

  /** Reloads the downloaded models and the adapters. */
  async refresh(): Promise<void> {
    this.#part("restart").className = "restart";
    await Promise.all([this.#loadLocal(), this.#loadAdapters()]);
    if (this.#inFlight.size) this.#startPolling();
  }

  async #loadLocal() {
    const target = this.#part("local");
    target.innerHTML = '<div class="hub-empty">loading…</div>';
    try {
      const [local, library] = await Promise.all([this.#call<Envelope & { models?: HubLocalRow[] }>("/api/hub/local"), this.#call<Envelope & { models?: LibraryRow[] }>("/library").catch(() => ({} as Envelope & { models?: LibraryRow[] }))]);
      const running = new Map<string, Running>((library.models ?? []).map(row => [row.repo_id, { serving: row.serving, resident: row.resident }]));
      target.innerHTML = renderHubLocalHtml(local.models ?? [], running);
      target.querySelectorAll<HTMLButtonElement>(".hub-serve-btn").forEach(button => { button.onclick = () => { void this.#serve(button.dataset.repo ?? "", button); }; });
    } catch { target.innerHTML = '<div class="hub-empty">Could not reach the server.</div>'; }
  }

  async #serve(repo: string, button: HTMLButtonElement) {
    if (!repo) return;
    button.disabled = true;
    const label = button.textContent;
    button.textContent = "Loading…";
    const answer = await this.#post<Envelope & { restart_required?: boolean; command?: string }>("/api/hub/serve", { model: repo }).catch((): Envelope & { restart_required?: boolean; command?: string } => ({ ok: false, error: "request failed" }));
    button.disabled = false;
    button.textContent = label;
    if (answer.ok) {
      this.#part("restart").className = "restart";
      this.#say("Now serving " + repo, "ok");
      this.#changed();
      await this.#loadLocal();
      await this.#loadAdapters();
      return;
    }
    if (answer.restart_required && answer.command) { this.#showRestart(repo, answer.command); return; }
    this.#say("Couldn't switch models: " + ((answer.error as string) || "unknown error"), "err");
  }

  /** A host that serves one model cannot swap: the restart command stays visible long enough to copy. */
  #showRestart(repo: string, command: string) {
    const strip = this.#part("restart");
    strip.innerHTML = `<p>Switching to <strong>${esc(repo)}</strong> needs a restart — this server holds one model and cannot swap. Restarting takes about a second and your sessions are preserved on disk, exactly as they are now.</p>` +
      `<div class="hub-cmd"><code>${esc(command)}</code><button type="button" class="hub-copy-btn" data-cmd="${esc(command)}">Copy</button></div>`;
    strip.className = "restart show";
    const copy = strip.querySelector<HTMLButtonElement>(".hub-copy-btn")!;
    copy.onclick = () => {
      void navigator.clipboard?.writeText(command).then(() => { copy.textContent = "Copied"; setTimeout(() => { copy.textContent = "Copy"; }, 1200); }).catch(() => {});
    };
  }

  /** Searches Hugging Face for MLX models; a newer query supersedes an older answer. */
  async search(query: string): Promise<void> {
    const results = this.#part("results");
    this.#lastQuery = query;
    if (!query) { results.innerHTML = '<div class="hub-empty">Type to search Hugging Face for MLX models.</div>'; return; }
    results.innerHTML = '<div class="hub-empty">searching…</div>';
    const answer = await this.#call<Envelope & { offline?: boolean; results?: HubSearchRow[] }>("/api/hub/search?q=" + encodeURIComponent(query))
      .catch((): Envelope & { offline?: boolean; results?: HubSearchRow[] } => ({ ok: false, offline: true, results: [] }));
    if (this.#lastQuery !== query) return;
    const offline = !!answer.offline;
    results.innerHTML = renderHubSearchHtml(answer.results ?? [], offline, this.#inFlight);
    results.querySelectorAll<HTMLButtonElement>(".hub-download-btn").forEach(button => { button.onclick = () => { void this.#download(button.dataset.repo ?? "", button); }; });
    this.#part("offline").style.display = offline ? "" : "none";
  }

  async #download(repo: string, button: HTMLButtonElement) {
    if (!repo) return;
    button.disabled = true;
    button.textContent = "Starting…";
    const answer = await this.#post<Envelope>("/api/hub/download", { repo }).catch((): Envelope => ({ ok: false, error: "request failed" }));
    if (!answer.ok) {
      button.disabled = false;
      button.textContent = "Download";
      this.#say("Couldn't start download: " + ((answer.error as string) || "unknown error"), "err");
      return;
    }
    this.#inFlight.add(repo);
    this.#say("Downloading " + repo, "ok");
    const actions = button.closest(".hub-row")?.querySelector(".hub-row-actions");
    if (actions) actions.innerHTML = '<span class="hub-dl-tag">downloading…</span>';
    this.#startPolling();
  }

  #startPolling() { this.#pollTimer ??= setInterval(() => { void this.pollDownloads(); }, 1500); }
  #stopPolling() { if (this.#pollTimer) clearInterval(this.#pollTimer); this.#pollTimer = undefined; }

  /** One step over the transfers' rows: progress on each search row, and the tag a finished or failed one settles on. */
  async pollDownloads(): Promise<void> {
    let downloads: DownloadInfo[] = [];
    try { downloads = ((await (await fetch(this.#url("/downloads"))).json()) as { downloads?: DownloadInfo[] }).downloads ?? []; } catch { return; }
    let active = false;
    for (const download of downloads) {
      if (download.state === "active") { active = true; this.#inFlight.add(download.repoId); }
      const actions = [...this.#shadow.querySelectorAll<HTMLElement>(".hub-row[data-search-repo]")].find(row => row.dataset.searchRepo === download.repoId)?.querySelector(".hub-row-actions");
      if (!actions) continue;
      if (download.state === "active") {
        // No total yet means the listing and disk preflight are still running.
        actions.innerHTML = `<span class="hub-dl-tag">${download.totalBytes ? Math.floor((download.receivedBytes / download.totalBytes) * 100) + "%" : "preparing…"}</span>`;
      } else if (download.state === "done") {
        const finished = this.#inFlight.delete(download.repoId);
        actions.innerHTML = '<span class="hub-dl-tag done">done — reload to serve</span>';
        if (finished) void this.#loadLocal();
      } else {
        this.#inFlight.delete(download.repoId);
        actions.innerHTML = `<span class="hub-dl-tag error">${esc(download.error || "download failed")}</span>`;
      }
    }
    // A transfer that finished and dropped out of the tracker's rolling window still needs its stale tag cleared.
    for (const repo of [...this.#inFlight]) if (!downloads.some(item => item.repoId === repo && item.state === "active")) this.#inFlight.delete(repo);
    if (!active) this.#stopPolling();
  }

  async #loadAdapters() {
    const target = this.#part("adapters");
    try {
      const [available, mounted] = await Promise.all([this.#call<Envelope & { adapters?: AvailableAdapterRow[] }>("/v1/adapters/available"), this.#call<Envelope & { adapters?: MountedAdapterRow[] }>("/v1/adapters")]);
      if (available.error || mounted.error) { target.innerHTML = `<div class="hub-empty">${esc(String(available.error ?? mounted.error))}</div>`; return; }
      target.innerHTML = renderAdaptersHtml(available.adapters ?? [], new Map((mounted.adapters ?? []).map(adapter => [adapter.id, adapter])));
      target.querySelectorAll<HTMLButtonElement>(".ad-mount").forEach(button => { button.onclick = () => { void this.#mount(button); }; });
      target.querySelectorAll<HTMLButtonElement>(".ad-unmount").forEach(button => { button.onclick = () => { void this.#unmount(button); }; });
    } catch { target.innerHTML = '<div class="hub-empty">Could not reach the server.</div>'; }
  }

  async #mount(button: HTMLButtonElement) {
    const { id, path } = button.dataset as { id: string; path: string };
    button.disabled = true;
    button.textContent = "Mounting…";
    const answer = await this.#post<Envelope>("/v1/adapters", { id, path }).catch((): Envelope => ({ ok: false, error: "request failed" }));
    if (answer.error || answer.ok === false) { this.#say("adapter: " + String(answer.error ?? "mount failed"), "err"); button.disabled = false; button.textContent = "Mount"; return; }
    this.#say("Mounted " + id, "ok");
    this.#changed();
    await this.#loadAdapters();
  }

  async #unmount(button: HTMLButtonElement) {
    const id = button.dataset.id!;
    button.disabled = true;
    const answer = await this.#call<Envelope>("/v1/adapters/" + encodeURIComponent(id), { method: "DELETE" }).catch((): Envelope => ({ ok: false, error: "request failed" }));
    if (answer.error || answer.ok === false) { this.#say("adapter: " + String(answer.error ?? "unmount failed"), "err"); button.disabled = false; return; }
    this.#say("Unmounted " + id, "ok");
    this.#changed();
    await this.#loadAdapters();
  }
}

if (typeof customElements !== "undefined" && !customElements.get("mlx-models-panel")) customElements.define("mlx-models-panel", ModelsPanel);
export type { ModelsPanel };
