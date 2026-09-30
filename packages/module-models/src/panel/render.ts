// The panel's pure renderers: HTML strings from the routes' JSON. Every interpolated value passes through `esc`: repo ids and
// model types are Hugging Face namespace strings, user-controlled.
import type { AvailableAdapterRow, FitAssessment, HubLocalRow, HubSearchRow, MountedAdapterRow } from "../protocol";

export function esc(value: unknown): string {
  return String(value ?? "").replace(/[&<>"]/g, char => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[char]!);
}

const gb = (bytes: number): string => (bytes / 2 ** 30).toFixed(1) + " GB";
const size = (bytes: number | null | undefined): string => bytes == null ? "—" : bytes >= 2 ** 20 ? (bytes / 2 ** 20).toFixed(1) + " MB" : bytes >= 2 ** 10 ? (bytes / 2 ** 10).toFixed(1) + " KB" : bytes + " B";

/** Three tiers on this machine's own fit numbers: green fits with headroom (at least 10 tok/s decode), yellow fits but is slow,
 * red does not fit, null has no assessment (an unreadable config). */
export function fitVerdict(assessment: FitAssessment | null): "green" | "yellow" | "red" | null {
  if (!assessment) return null;
  if (!assessment.fits) return "red";
  return assessment.predicted_decode_tps >= 10 ? "green" : "yellow";
}

const fitDot = (verdict: ReturnType<typeof fitVerdict>): string => verdict
  ? `<span class="hub-fit-dot ${verdict}" aria-hidden="true"></span>`
  : '<span class="hub-fit-dot" aria-hidden="true" style="background:var(--dimmer)"></span>';

/** What the host says of a model's place in memory. */
export interface Running { serving: boolean; resident: boolean }

function localRowHtml(model: HubLocalRow, running: Running | undefined): string {
  const name = model.repo_id.split("/").pop() || model.repo_id;
  const meta = [gb(model.size_bytes), model.quant_bits ? model.quant_bits + "-bit" : "unquantized"];
  if (model.vision) meta.push("vision");
  if (!model.supported) meta.push("unsupported model family");
  const assessment = model.assessment;
  const speed = assessment && assessment.fits ? assessment.predicted_decode_tps.toFixed(0) + " tok/s predicted"
    : assessment ? "doesn't fit this Mac's memory" : "fit unknown";
  const serving = running?.serving === true;
  const tag = serving ? '<div class="hub-serving-tag">● currently serving</div>' : running?.resident ? '<div class="hub-serving-tag">○ loaded</div>' : "";
  const serve = model.supported && !serving ? `<button type="button" class="hub-serve-btn" data-repo="${esc(model.repo_id)}">Serve</button>` : "";
  return `<div class="hub-row${serving ? " serving" : ""}">${fitDot(fitVerdict(assessment))}<div class="hub-row-main">` +
    `<div class="hub-row-name" title="${esc(model.repo_id)}">${esc(name)}</div>` +
    `<div class="hub-row-meta">${esc(meta.join(" · "))} · ${esc(speed)}</div>${tag}</div>` +
    `<div class="hub-row-actions">${serve}</div></div>`;
}

/** The downloaded models, the served one first. `running` marks which is served and which are loaded. */
export function renderHubLocalHtml(models: readonly HubLocalRow[], running: ReadonlyMap<string, Running> = new Map()): string {
  if (!models.length) return '<div class="hub-empty">No models downloaded yet — search Hugging Face below to get one.</div>';
  return [...models]
    .sort((a, b) => Number(running.get(b.repo_id)?.serving === true) - Number(running.get(a.repo_id)?.serving === true) || a.repo_id.localeCompare(b.repo_id))
    .map(model => localRowHtml(model, running.get(model.repo_id))).join("");
}

function searchRowHtml(result: HubSearchRow, downloading: boolean): string {
  const name = result.id.split("/").pop() || result.id;
  const meta = [result.downloads.toLocaleString() + " downloads"];
  if (result.size_estimate != null) meta.push(gb(result.size_estimate));
  const action = downloading ? '<span class="hub-dl-tag">downloading…</span>'
    : `<button type="button" class="hub-download-btn" data-repo="${esc(result.id)}">Download</button>`;
  return `<div class="hub-row" data-search-repo="${esc(result.id)}"><div class="hub-row-main">` +
    `<div class="hub-row-name" title="${esc(result.id)}">${esc(name)}</div>` +
    `<div class="hub-row-meta">${esc(result.id)} · ${esc(meta.join(" · "))}</div></div>` +
    `<div class="hub-row-actions">${action}</div></div>`;
}

/** Search results. `downloading` is the set of repos with a transfer running now. */
export function renderHubSearchHtml(results: readonly HubSearchRow[], offline: boolean, downloading: ReadonlySet<string>): string {
  if (offline) return '<div class="hub-empty">Can\'t reach Hugging Face right now — search needs a network connection.</div>';
  if (!results.length) return '<div class="hub-empty">No matches.</div>';
  return results.map(result => searchRowHtml(result, downloading.has(result.id))).join("");
}

/** Every adapter on disk with what mounting it costs; incompatible ones (trained for another model) are grayed with the reason. */
export function renderAdaptersHtml(available: readonly AvailableAdapterRow[], mounted: ReadonlyMap<string, MountedAdapterRow>): string {
  if (!available.length) {
    return '<div class="hub-empty">No adapters found on disk yet. Fine-tune one in the Developer tab, or drop an adapter directory into <code>~/.mlx-bun/adapters</code>.</div>';
  }
  return available.map(adapter => {
    const info = mounted.get(adapter.id);
    const meta: string[] = [];
    if (adapter.base_model) meta.push(`base <b>${esc(adapter.base_model.split("/").pop())}</b>`);
    if (adapter.rank) meta.push(`rank <b>${esc(adapter.rank)}</b>`);
    if (info) meta.push(`disk <b>${esc(size(info.size_bytes))}</b>`, `RAM <b>${esc(size(info.ram_bytes))}</b>`);
    const why = adapter.compatible ? "" : `<div class="ad-why">${adapter.base_model ? "trained for " + esc(adapter.base_model) + ", not the served model" : "not compatible with the served model"}</div>`;
    const action = info ? `<button type="button" class="ad-unmount" data-id="${esc(adapter.id)}">Unmount</button>`
      : adapter.compatible ? `<button type="button" class="ad-mount" data-id="${esc(adapter.id)}" data-path="${esc(adapter.path)}">Mount</button>` : "";
    return `<div class="ad-row${adapter.compatible ? "" : " incompatible"}" data-adapter-row="${esc(adapter.id)}"><div class="ad-row-main">` +
      `<div class="ad-row-head"><span class="ad-row-id" title="${esc(adapter.id)}">${esc(adapter.id)}</span>${info ? '<span class="ad-badge mounted">mounted</span>' : ""}</div>` +
      `<div class="ad-meta">${meta.join(" · ")}</div>${why}</div><div class="hub-row-actions">${action}</div></div>`;
  }).join("");
}
