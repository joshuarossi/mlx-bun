// `<mlx-models-panel>`: the module's web panel as one self-contained custom element. It imports only its data protocol
// (types), its own render and style files and the web kit, draws into its own shadow root and reaches the backend
// only through `connection`, so any host (the web shell, a native webview) mounts it the same way: create the
// element, set `connection`, append it.
//
// Four sections over the module's routes: what is serving now (from `/library`); the downloaded models
// (`/api/hub/local`, with which one is served and which are loaded) and a Serve action; Hugging Face search
// (`/api/hub/search`) with Download and live progress (`/downloads`); and the adapters on disk
// (`/v1/adapters/available`, `/v1/adapters`) with Mount and Unmount. Nothing downloads, serves or mounts without an
// explicit click. The routes keep their shipped root paths, so requests go to the origin `connection.apiBase` names.
import { BASE_CSS, createApi, emitHostEvent, errorOf, HOST_EVENTS, shadowStyles, type Api, type ApiEnvelope } from "@mlx-bun/web-kit";
import type { AvailableAdapterRow, DownloadInfo, HubLocalRow, HubSearchRow, LibraryRow, MountedAdapterRow, PanelConnection } from "../protocol";
import { esc, renderAdaptersHtml, renderHubLocalHtml, renderHubSearchHtml, renderServingHtml, type Running } from "./render";
import { STYLE } from "./style";

export { esc, fitVerdict, renderAdaptersHtml, renderHubLocalHtml, renderHubSearchHtml, renderServingHtml } from "./render";
export type { Running } from "./render";

/** Fired (bubbling, composed) on the element whenever the served model or the mounted adapters changed, so the page around it can refresh what it shows. */
export const MODELS_CHANGED = HOST_EVENTS.modelsChanged;

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

const MARKUP =
  '<div class="status notice" id="status" role="status"></div>' +
  '<div class="restart notice warn" id="restart"></div>' +
  '<section class="section"><h3 class="section-title">Serving now</h3><div class="card" id="serving"><div class="serving"><span class="skeleton">Loading the served model…</span></div></div></section>' +
  '<section class="section"><h3 class="section-title">Downloaded <span class="count" id="local-count"></span></h3>' +
  '<p class="card-note" style="margin-bottom:10px">Fit is predicted for this Mac. Serving a model loads it beside the running ones when it fits; otherwise the least recently used one is unloaded with its saved state, and switching back resumes it.</p>' +
  '<div class="list skeletons" id="local"><div class="list-row"><span class="skeleton" style="width:46%"></span></div><div class="list-row"><span class="skeleton" style="width:38%"></span></div></div></section>' +
  '<section class="section"><h3 class="section-title">Find a model</h3>' +
  '<input class="input search" type="search" id="query" placeholder="Search Hugging Face for MLX models" aria-label="Search Hugging Face for MLX models" autocomplete="off">' +
  '<div id="results"><p class="card-note">Type to search Hugging Face. Downloads land in the Hugging Face cache and appear above when they finish.</p></div>' +
  '<p class="hint offline" id="offline" style="display:none">You are offline, or Hugging Face is unreachable. Search needs a network connection; downloaded models work offline.</p></section>' +
  '<section class="section"><h3 class="section-title">Adapters</h3>' +
  '<p class="card-note" style="margin-bottom:10px">Every LoRA adapter found on disk. Mounting loads it into the served model\'s memory; the chat picks which mounted adapter a turn uses.</p>' +
  '<div class="list skeletons" id="adapters"><div class="list-row"><span class="skeleton" style="width:30%"></span></div></div></section>';

class ModelsPanel extends Base {
  #connection: PanelConnection | undefined;
  #api: Api | undefined;
  #shadow: ShadowRoot;
  #inFlight = new Set<string>();
  #pollTimer: ReturnType<typeof setInterval> | undefined;
  #searchTimer: ReturnType<typeof setTimeout> | undefined;
  #lastQuery = "";

  constructor() {
    super();
    this.#shadow = this.attachShadow({ mode: "open" });
    const body = document.createElement("div");
    body.innerHTML = MARKUP;
    this.#shadow.append(shadowStyles(STYLE, BASE_CSS), body);
    this.#part("query").addEventListener("input", () => {
      clearTimeout(this.#searchTimer);
      const query = (this.#part("query") as HTMLInputElement).value.trim();
      this.#searchTimer = setTimeout(() => { void this.search(query); }, 300);
    });
  }

  get connection(): PanelConnection | undefined { return this.#connection; }
  set connection(value: PanelConnection | undefined) {
    this.#connection = value;
    this.#api = value ? createApi(value.apiBase) : undefined;
    if (this.isConnected && value) void this.refresh();
  }

  connectedCallback() { if (this.#connection) void this.refresh(); }
  disconnectedCallback() { this.#stopPolling(); clearTimeout(this.#searchTimer); }

  #part(id: string): HTMLElement { return this.#shadow.getElementById(id)!; }
  get #client(): Api { return this.#api ?? createApi("/api/models"); }

  #say(text: string, kind: "" | "ok" | "err" = "") {
    const status = this.#part("status");
    status.textContent = text;
    status.className = "status notice" + (kind === "ok" ? " ok" : kind === "err" ? " bad" : "");
  }
  #changed() { emitHostEvent(HOST_EVENTS.modelsChanged, undefined, this, { bubbles: true, composed: true }); }

  /** Reloads the downloaded models and the adapters. */
  async refresh(): Promise<void> {
    this.#part("restart").className = "restart notice warn";
    await Promise.all([this.#loadLocal(), this.#loadAdapters()]);
    if (this.#inFlight.size) this.#startPolling();
  }

  async #loadLocal() {
    const target = this.#part("local");
    const [local, library] = await Promise.all([
      this.#client.get<ApiEnvelope & { models?: HubLocalRow[] }>("/api/hub/local"),
      this.#client.get<ApiEnvelope & { models?: LibraryRow[] }>("/library"),
    ]);
    if (local.ok === false) {
      target.className = "";
      target.innerHTML = `<div class="notice bad"><b>Could not load the downloaded models.</b> ${esc(errorOf(local))}<span class="actions"><button type="button" class="btn sm retry">Retry</button></span></div>`;
      target.querySelector<HTMLButtonElement>(".retry")!.onclick = () => { void this.refresh(); };
      this.#part("serving").innerHTML = renderServingHtml([], false);
      return;
    }
    const rows = library.models ?? [];
    const running = new Map<string, Running>(rows.map(row => [row.repo_id, { serving: row.serving, resident: row.resident }]));
    const models = local.models ?? [];
    this.#part("serving").innerHTML = renderServingHtml(rows);
    this.#part("local-count").textContent = models.length ? String(models.length) : "";
    target.className = models.length ? "list" : "";
    target.innerHTML = renderHubLocalHtml(models, running);
    target.querySelectorAll<HTMLButtonElement>(".hub-serve-btn").forEach(button => { button.onclick = () => { void this.#serve(button.dataset.repo ?? "", button); }; });
  }

  async #serve(repo: string, button: HTMLButtonElement) {
    if (!repo) return;
    button.disabled = true;
    const label = button.textContent;
    button.textContent = "Loading…";
    const answer = await this.#client.post<ApiEnvelope & { restart_required?: boolean; command?: string }>("/api/hub/serve", { model: repo });
    button.disabled = false;
    button.textContent = label;
    if (answer.ok) {
      this.#part("restart").className = "restart notice warn";
      this.#say("Now serving " + repo, "ok");
      this.#changed();
      await this.#loadLocal();
      await this.#loadAdapters();
      return;
    }
    if (answer.restart_required && answer.command) { this.#showRestart(repo, answer.command); return; }
    this.#say("Couldn't switch models: " + errorOf(answer, "unknown error"), "err");
  }

  /** A host that serves one model cannot swap: the restart command stays visible long enough to copy. */
  #showRestart(repo: string, command: string) {
    const strip = this.#part("restart");
    strip.innerHTML = `<p>Switching to <b>${esc(repo)}</b> needs a restart: this server holds one model and cannot swap. Restarting takes about a second, and your chats stay on disk as they are.</p>` +
      `<div class="hub-cmd"><code>${esc(command)}</code><button type="button" class="btn sm hub-copy-btn" data-cmd="${esc(command)}">Copy</button></div>`;
    strip.className = "restart notice warn show";
    const copy = strip.querySelector<HTMLButtonElement>(".hub-copy-btn")!;
    copy.onclick = () => {
      void navigator.clipboard?.writeText(command).then(() => { copy.textContent = "Copied"; setTimeout(() => { copy.textContent = "Copy"; }, 1200); }).catch(() => {});
    };
  }

  /** Searches Hugging Face for MLX models; a newer query supersedes an older answer. */
  async search(query: string): Promise<void> {
    const results = this.#part("results");
    this.#lastQuery = query;
    if (!query) {
      results.innerHTML = '<p class="card-note">Type to search Hugging Face. Downloads land in the Hugging Face cache and appear above when they finish.</p>';
      this.#part("offline").style.display = "none";
      return;
    }
    results.innerHTML = '<p class="card-note"><span class="skeleton">Searching Hugging Face…</span></p>';
    const answer = await this.#client.get<ApiEnvelope & { offline?: boolean; results?: HubSearchRow[] }>("/api/hub/search?q=" + encodeURIComponent(query));
    if (this.#lastQuery !== query) return;
    const offline = answer.ok === false || !!answer.offline;
    results.className = !offline && (answer.results ?? []).length ? "list" : "";
    results.innerHTML = renderHubSearchHtml(answer.results ?? [], offline, this.#inFlight);
    results.querySelectorAll<HTMLButtonElement>(".hub-download-btn").forEach(button => { button.onclick = () => { void this.#download(button.dataset.repo ?? "", button); }; });
    this.#part("offline").style.display = offline ? "" : "none";
  }

  async #download(repo: string, button: HTMLButtonElement) {
    if (!repo) return;
    button.disabled = true;
    button.textContent = "Starting…";
    const answer = await this.#client.post<ApiEnvelope>("/api/hub/download", { repo });
    if (!answer.ok) {
      button.disabled = false;
      button.textContent = "Download";
      this.#say("Couldn't start the download: " + errorOf(answer, "unknown error"), "err");
      return;
    }
    this.#inFlight.add(repo);
    this.#say("Downloading " + repo, "ok");
    const actions = button.closest(".hub-row")?.querySelector(".hub-row-actions");
    if (actions) actions.innerHTML = '<span class="tag accent hub-dl-tag">downloading…</span>';
    this.#startPolling();
  }

  #startPolling() { this.#pollTimer ??= setInterval(() => { void this.pollDownloads(); }, 1500); }
  #stopPolling() { if (this.#pollTimer) clearInterval(this.#pollTimer); this.#pollTimer = undefined; }

  /** One step over the transfers' rows: progress on each search row, and the tag a finished or failed one settles on. */
  async pollDownloads(): Promise<void> {
    const answer = await this.#client.get<ApiEnvelope & { downloads?: DownloadInfo[] }>("/downloads");
    if (answer.ok === false) return;
    const downloads = answer.downloads ?? [];
    let active = false;
    for (const download of downloads) {
      if (download.state === "active") { active = true; this.#inFlight.add(download.repoId); }
      const actions = [...this.#shadow.querySelectorAll<HTMLElement>(".hub-row[data-search-repo]")].find(row => row.dataset.searchRepo === download.repoId)?.querySelector(".hub-row-actions");
      if (!actions) continue;
      if (download.state === "active") {
        // No total yet means the listing and disk preflight are still running.
        actions.innerHTML = `<span class="tag accent hub-dl-tag">${download.totalBytes ? Math.floor((download.receivedBytes / download.totalBytes) * 100) + "%" : "preparing…"}</span>`;
      } else if (download.state === "done") {
        const finished = this.#inFlight.delete(download.repoId);
        actions.innerHTML = '<span class="tag ok hub-dl-tag done">done — reload to serve</span>';
        if (finished) void this.#loadLocal();
      } else {
        this.#inFlight.delete(download.repoId);
        actions.innerHTML = `<span class="tag bad hub-dl-tag error">${esc(download.error || "download failed")}</span>`;
      }
    }
    // A transfer that finished and dropped out of the tracker's rolling window still needs its stale tag cleared.
    for (const repo of [...this.#inFlight]) if (!downloads.some(item => item.repoId === repo && item.state === "active")) this.#inFlight.delete(repo);
    if (!active) this.#stopPolling();
  }

  async #loadAdapters() {
    const target = this.#part("adapters");
    const [available, mounted] = await Promise.all([
      this.#client.get<ApiEnvelope & { adapters?: AvailableAdapterRow[] }>("/v1/adapters/available"),
      this.#client.get<ApiEnvelope & { adapters?: MountedAdapterRow[] }>("/v1/adapters"),
    ]);
    if (available.ok === false || mounted.ok === false || available.error || mounted.error) {
      target.className = "";
      target.innerHTML = `<div class="notice bad">${esc(errorOf(available.ok === false || available.error ? available : mounted))}</div>`;
      return;
    }
    const rows = available.adapters ?? [];
    target.className = rows.length ? "list" : "";
    target.innerHTML = renderAdaptersHtml(rows, new Map((mounted.adapters ?? []).map(adapter => [adapter.id, adapter])));
    target.querySelectorAll<HTMLButtonElement>(".ad-mount").forEach(button => { button.onclick = () => { void this.#mount(button); }; });
    target.querySelectorAll<HTMLButtonElement>(".ad-unmount").forEach(button => { button.onclick = () => { void this.#unmount(button); }; });
  }

  async #mount(button: HTMLButtonElement) {
    const { id, path } = button.dataset as { id: string; path: string };
    button.disabled = true;
    button.textContent = "Mounting…";
    const answer = await this.#client.post<ApiEnvelope>("/v1/adapters", { id, path });
    if (answer.error || answer.ok === false) { this.#say("adapter: " + errorOf(answer, "mount failed"), "err"); button.disabled = false; button.textContent = "Mount"; return; }
    this.#say("Mounted " + id, "ok");
    this.#changed();
    await this.#loadAdapters();
  }

  async #unmount(button: HTMLButtonElement) {
    const id = button.dataset.id!;
    button.disabled = true;
    const answer = await this.#client.del<ApiEnvelope>("/v1/adapters/" + encodeURIComponent(id));
    if (answer.error || answer.ok === false) { this.#say("adapter: " + errorOf(answer, "unmount failed"), "err"); button.disabled = false; return; }
    this.#say("Unmounted " + id, "ok");
    this.#changed();
    await this.#loadAdapters();
  }
}

if (typeof customElements !== "undefined" && !customElements.get("mlx-models-panel")) customElements.define("mlx-models-panel", ModelsPanel);
export type { ModelsPanel };
