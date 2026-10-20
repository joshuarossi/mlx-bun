// The panel's pure renderers: HTML strings from the routes' JSON. Every interpolated value passes through `esc`: repo
// ids and model types are Hugging Face namespace strings, user-controlled.
import { bytes, esc, gb, num, rate, shortName } from "@mlx-bun/web-kit";
import type { AvailableAdapterRow, FitAssessment, HubLocalRow, HubSearchRow, LibraryRow, MountedAdapterRow } from "../protocol";

export { esc };

/** Three tiers on this machine's own fit numbers: green fits with headroom (at least 10 tok/s decode), yellow fits but is slow,
 * red does not fit, null has no assessment (an unreadable config). */
export function fitVerdict(assessment: FitAssessment | null): "green" | "yellow" | "red" | null {
  if (!assessment) return null;
  if (!assessment.fits) return "red";
  return assessment.predicted_decode_tps >= 10 ? "green" : "yellow";
}

const FIT_WORDS = { green: "fits with headroom", yellow: "fits, but slowly", red: "does not fit in memory" } as const;

const fitDot = (verdict: ReturnType<typeof fitVerdict>): string => verdict
  ? `<span class="hub-fit-dot ${verdict} dot ${verdict === "green" ? "ok" : verdict === "yellow" ? "warn" : "bad"}" title="${FIT_WORDS[verdict]}" aria-label="${FIT_WORDS[verdict]}"></span>`
  : '<span class="hub-fit-dot dot" title="fit unknown" aria-label="fit unknown"></span>';

/** What the host says of a model's place in memory. */
export interface Running { serving: boolean; resident: boolean }

const quant = (model: { quant_bits: number | null }): string => model.quant_bits ? `${model.quant_bits}-bit` : "unquantized";

/** The summary at the top of the page: the served model, what is loaded beside it, and what the fit model says. */
export function renderServingHtml(library: readonly LibraryRow[], reachable = true): string {
  if (!reachable) return '<div class="notice bad"><b>The server is not answering.</b> The list below is the last one it gave.</div>';
  const served = library.find(row => row.serving);
  const beside = library.filter(row => row.resident && !row.serving);
  if (!served) {
    return '<div class="serving none"><div class="serving-name muted">No model is serving</div>' +
      '<div class="serving-meta">Serve a downloaded model below, or search Hugging Face for one.</div></div>';
  }
  const assessment = served.assessment;
  const facts = [quant(served), gb(served.size_bytes)];
  if (served.vision) facts.push("vision");
  if (assessment?.fits) facts.push(`about ${rate(assessment.predicted_decode_tps)}`, `${num(assessment.max_safe_context)} tokens of context`);
  return '<div class="serving"><div class="serving-head"><span class="tag ok"><span class="dot ok live"></span>serving</span>' +
    `<div class="serving-name mono" title="${esc(served.repo_id)}">${esc(served.repo_id)}</div></div>` +
    `<div class="serving-meta">${facts.map(esc).join(" · ")}</div>` +
    (beside.length ? `<div class="serving-beside">Also loaded: ${beside.map(row => `<span class="tag">${esc(shortName(row.repo_id))}</span>`).join(" ")}</div>` : "") +
    "</div>";
}

function localRowHtml(model: HubLocalRow, running: Running | undefined): string {
  const name = shortName(model.repo_id);
  const meta = [gb(model.size_bytes), quant(model)];
  if (model.vision) meta.push("vision");
  if (!model.supported) meta.push("unsupported model family");
  const assessment = model.assessment;
  const speed = assessment && assessment.fits ? `about ${rate(assessment.predicted_decode_tps)}`
    : assessment ? "does not fit this Mac's memory" : "fit unknown";
  const serving = running?.serving === true;
  const loaded = !serving && running?.resident === true;
  const tag = serving ? '<span class="tag ok hub-serving-tag">currently serving</span>' : loaded ? '<span class="tag hub-loaded-tag">loaded</span>' : "";
  const serve = model.supported && !serving ? `<button type="button" class="btn sm hub-serve-btn" data-repo="${esc(model.repo_id)}">Serve</button>` : "";
  return `<div class="list-row hub-row${serving ? " is-serving" : ""}">${fitDot(fitVerdict(assessment))}<div class="list-main hub-row-main">` +
    `<div class="list-name hub-row-name" title="${esc(model.repo_id)}">${esc(name)}${tag ? " " + tag : ""}</div>` +
    `<div class="list-meta hub-row-meta">${esc(meta.join(" · "))} · ${esc(speed)}</div></div>` +
    `<div class="list-actions hub-row-actions">${serve}</div></div>`;
}

/** The downloaded models, the served one first. `running` marks which is served and which are loaded. */
export function renderHubLocalHtml(models: readonly HubLocalRow[], running: ReadonlyMap<string, Running> = new Map()): string {
  if (!models.length) return '<div class="empty"><h3>No models downloaded yet</h3><p>Search Hugging Face below, or run <code>mlx-bun get</code> in a terminal.</p></div>';
  return [...models]
    .sort((a, b) => Number(running.get(b.repo_id)?.serving === true) - Number(running.get(a.repo_id)?.serving === true) || a.repo_id.localeCompare(b.repo_id))
    .map(model => localRowHtml(model, running.get(model.repo_id))).join("");
}

function searchRowHtml(result: HubSearchRow, downloading: boolean): string {
  const meta = [`${num(result.downloads)} downloads`];
  if (result.size_estimate != null) meta.push(`about ${gb(result.size_estimate)}`);
  const action = downloading ? '<span class="tag accent hub-dl-tag">downloading…</span>'
    : `<button type="button" class="btn sm hub-download-btn" data-repo="${esc(result.id)}">Download</button>`;
  return `<div class="list-row hub-row" data-search-repo="${esc(result.id)}"><div class="list-main hub-row-main">` +
    `<div class="list-name hub-row-name" title="${esc(result.id)}">${esc(shortName(result.id))}</div>` +
    `<div class="list-meta hub-row-meta">${esc(result.id)} · ${esc(meta.join(" · "))}</div></div>` +
    `<div class="list-actions hub-row-actions">${action}</div></div>`;
}

/** Search results. `downloading` is the set of repos with a transfer running now. */
export function renderHubSearchHtml(results: readonly HubSearchRow[], offline: boolean, downloading: ReadonlySet<string>): string {
  if (offline) return '<div class="notice warn">Hugging Face is unreachable right now. Search needs a network connection; downloaded models work offline.</div>';
  if (!results.length) return '<div class="empty"><p>No MLX models match that search.</p></div>';
  return results.map(result => searchRowHtml(result, downloading.has(result.id))).join("");
}

/** Every adapter on disk with what mounting it costs; incompatible ones (trained for another model) are grayed with the reason. */
export function renderAdaptersHtml(available: readonly AvailableAdapterRow[], mounted: ReadonlyMap<string, MountedAdapterRow>): string {
  if (!available.length) {
    return '<div class="empty"><p>No adapters found on disk. Fine-tune one under Tools, or drop an adapter directory into <code>~/.mlx-bun/adapters</code>.</p></div>';
  }
  return available.map(adapter => {
    const info = mounted.get(adapter.id);
    const meta: string[] = [];
    if (adapter.base_model) meta.push(`base <b>${esc(shortName(adapter.base_model))}</b>`);
    if (adapter.rank) meta.push(`rank <b>${esc(adapter.rank)}</b>`);
    if (info) meta.push(`disk <b>${esc(bytes(info.size_bytes))}</b>`, `RAM <b>${esc(bytes(info.ram_bytes))}</b>`);
    const why = adapter.compatible ? "" : `<div class="ad-why">${adapter.base_model ? "trained for " + esc(adapter.base_model) + ", not the served model" : "not compatible with the served model"}</div>`;
    const action = info ? `<button type="button" class="btn sm ad-unmount" data-id="${esc(adapter.id)}">Unmount</button>`
      : adapter.compatible ? `<button type="button" class="btn sm ad-mount" data-id="${esc(adapter.id)}" data-path="${esc(adapter.path)}">Mount</button>` : "";
    return `<div class="list-row ad-row${adapter.compatible ? "" : " incompatible"}" data-adapter-row="${esc(adapter.id)}"><div class="list-main ad-row-main">` +
      `<div class="list-name ad-row-head"><span class="ad-row-id" title="${esc(adapter.id)}">${esc(adapter.id)}</span>${info ? ' <span class="tag ok ad-badge mounted">mounted</span>' : ""}</div>` +
      `<div class="list-meta ad-meta">${meta.join(" · ")}</div>${why}</div><div class="list-actions hub-row-actions">${action}</div></div>`;
  }).join("");
}
