// The server's identity as the page shows it, always on: which model answers requests, whether the server answers at
// all, and a background download. Polled lightly from `/v1/models` and `/downloads`; rendered into the status strip
// in the navigation rail and its compact twin in the top bar. Other parts of the page read `activeModelId` or
// listen for `mlx-model-changed` (the served model switched: the chat reconnects to read the new model's
// capabilities) and `mlx-server-status` (every poll's summary, for a panel that wants to describe the download).
import { createApi, emitHostEvent, HOST_EVENTS, onHostEvent, percent, shortName, type ServerStatusDetail } from "@mlx-bun/web-kit";

export interface DownloadInfo {
  state: string;
  repoId: string;
  totalBytes?: number;
  receivedBytes?: number;
}

export type ServerStatus = ServerStatusDetail;

export let activeModelId: string | null = null;
let lastOnline: boolean | null = null;
const api = createApi("/api/app");
const byId = (id: string) => document.getElementById(id);

function renderModel(model: string | null, online: boolean): void {
  for (const id of ["nav-model", "topbar-model"]) {
    const button = byId(id);
    if (!button) continue;
    const text = model ? (id === "topbar-model" ? shortName(model) : model) : online ? "No model loaded" : "Server unreachable";
    button.textContent = text;
    button.classList.toggle("none", !model);
    button.title = model ? `${model}. Opens the Models page.` : online ? "Pick a model on the Models page." : "The server is not answering.";
  }
}

function renderConnection(online: boolean): void {
  const host = location.host || "localhost";
  for (const id of ["nav-conn", "topbar-conn"]) {
    const line = byId(id);
    if (!line) continue;
    line.className = "status-line" + (online ? "" : " bad");
    const dot = line.querySelector(".dot");
    if (dot) dot.className = "dot " + (online ? "ok live" : "bad");
    const text = line.querySelector("span:last-of-type");
    if (text) text.textContent = online ? `Online at ${host}` : "Server unreachable, retrying";
  }
}

/** The status strip's download line: a model arriving in the background while another one serves. */
export function renderDownload(downloads: readonly DownloadInfo[]): ServerStatus["download"] {
  const incoming = downloads.find((item) => item.state === "active" && item.repoId !== activeModelId);
  const line = byId("nav-download");
  const summary = incoming ? { repoId: incoming.repoId, percent: incoming.totalBytes ? Math.floor(100 * (incoming.receivedBytes || 0) / incoming.totalBytes) : 0 } : null;
  if (!line) return summary;
  if (!summary) { line.style.display = "none"; return null; }
  line.style.display = "";
  const text = byId("nav-download-text");
  if (text) text.textContent = `Downloading ${shortName(summary.repoId)} (${percent(summary.percent / 100)})`;
  const bar = byId("nav-download-bar");
  if (bar) bar.style.width = `${summary.percent}%`;
  return summary;
}

export async function pollIdentity(): Promise<void> {
  const [models, downloads] = await Promise.all([
    api.get<{ data?: { id: string; current?: boolean }[] }>("/v1/models"),
    api.get<{ downloads?: DownloadInfo[] }>("/downloads"),
  ]);
  const online = models.ok !== false && Array.isArray(models.data);
  if (!online) {
    renderModel(activeModelId, false);
    renderConnection(false);
    lastOnline = false;
    emitHostEvent(HOST_EVENTS.serverStatus, { model: activeModelId, online: false, download: null });
    return;
  }
  // The server marks the current model; a server that predates residency lists the served one first.
  const listed = models.data ?? [];
  const served = listed.find((item) => item.current) || listed[0];
  const next = served ? served.id : null;
  const switched = activeModelId !== null && next !== null && next !== activeModelId;
  activeModelId = next;
  renderModel(next, true);
  renderConnection(true);
  const download = renderDownload(downloads.downloads ?? []);
  if (switched) emitHostEvent(HOST_EVENTS.modelChanged, next);
  if (lastOnline === false) emitHostEvent(HOST_EVENTS.serverRecovered);
  lastOnline = true;
  emitHostEvent(HOST_EVENTS.serverStatus, { model: next, online: true, download });
}

/** The strip's model label opens the Models page; a switch or an adapter change made there re-reads the served
 * model's identity at once instead of at the next poll. */
export function initServerStatus(): void {
  for (const id of ["nav-model", "topbar-model"]) {
    const button = byId(id);
    if (button) button.onclick = () => { location.hash = "#/models"; };
  }
  onHostEvent(HOST_EVENTS.modelsChanged, () => { void pollIdentity(); }, document);
  void pollIdentity();
  setInterval(() => { void pollIdentity(); }, 4000);
}
