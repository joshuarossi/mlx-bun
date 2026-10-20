// The status page: polls `/stats` and `/v1/models` every two seconds while shown, `/library` every fifteen, `/fit` and
// `/downloads` as it loads. Host-owned until a module takes the server's own stats; the markup is `view.ts`.
import { $, createApi, esc, gb, injectStyles, mb, num, uptime } from "@mlx-bun/web-kit";
import { STATUS_CSS, STATUS_MARKUP } from "./view";

interface DownloadRow {
  repoId: string;
  state: "active" | "done" | "error";
  totalBytes: number;
  receivedBytes: number;
  bytesPerSec?: number;
  currentFile?: string;
  filesDone: number;
  filesTotal: number;
  startedAt: number;
  error?: string;
}

interface LibraryModel {
  repo_id: string;
  size_bytes: number;
  serving?: boolean;
  supported?: boolean;
  model_type?: string;
  vision?: boolean;
  assessment?: { fits?: boolean; max_safe_context?: number; predicted_decode_tps?: number };
}

interface SkuRow { sku: string; ram_gb: number; fits: boolean; max_context: number; decode_tps: number }

interface FitResponse {
  report?: { fits?: boolean; weights_bytes?: number; kv_bytes?: number; transient_bytes?: number; total_bytes?: number; usable_bytes?: number; predicted_decode_tps?: number };
  measured_decode_tps?: number;
  typical_decode_tps?: number;
  typical_context_tokens?: number;
  context_tokens?: number;
  machine?: { ram_bytes?: number; bandwidth_gbs?: number; chip?: string };
  sku_matrix_ctx?: number;
  sku_matrix?: SkuRow[];
  plan?: { artifact_disk_bytes?: number | null; streamed_weights?: Record<string, number>; max_generation_tokens?: number | null };
}

const api = createApi("/api/app");
const tps = (value: number): string => value < 1 ? value.toFixed(2) : value.toFixed(1);
const text = (id: string, value: string) => { const node = $(id); if (node) node.textContent = value; };
const width = (id: string, fraction: number | null) => { const node = $(id); if (node) node.style.width = fraction == null ? "0%" : Math.min(100, 100 * fraction) + "%"; };

export function createStatusController() {
  let timer: ReturnType<typeof setInterval> | null = null, libTimer: ReturnType<typeof setInterval> | null = null, fitLoaded = false;
  const dlRates: Record<string, { bytes: number; t: number }> = {};

  async function tick(): Promise<void> {
    const [stats, models] = await Promise.all([api.get<Record<string, any>>("/stats"), api.get<{ data?: { id: string; context_window?: number; current?: boolean }[] }>("/v1/models")]);
    if (stats.ok === false || models.ok === false) return; // the status strip already says the server is unreachable; keep the last good values
    const listed = models.data || [];
    const served = listed.find((item) => item.current) || listed[0];
    text("st-model-id", served?.id || "No model loaded");
    const admission = stats.admission || {};
    text("st-model-meta", served ? `${num(served.context_window)} token window, ${gb(admission.weights_bytes, 2)} of weights` : "Serve a model from the Models page.");
    text("st-safe-ctx", num(admission.max_safe_context));
    text("st-weights", gb(admission.weights_bytes, 2));
    text("st-usable", gb(admission.usable_bytes, 2));
    text("st-budget", admission.memory_budget_bytes ? gb(admission.memory_budget_bytes, 2) : "off");
    width("st-mem-bar", admission.usable_bytes ? admission.weights_bytes / admission.usable_bytes : null);

    const cache = stats.prompt_cache || {};
    const lookups = (cache.hits || 0) + (cache.misses || 0);
    text("st-pc-hits", lookups ? Math.round(100 * cache.hits / lookups) + "%" : "no lookups yet");
    text("st-pc-entries", num(cache.entries));
    text("st-pc-bytes", `${mb(cache.bytes)} of ${mb(cache.max_bytes)}`);
    width("st-pc-bar", cache.max_bytes ? cache.bytes / cache.max_bytes : null);

    const store = stats.response_store || {};
    text("st-rs-entries", num(store.entries));
    text("st-rs-bytes", `${mb(store.bytes)} of ${mb(store.max_bytes)}`);
    text("st-rs-ttl", store.ttl_ms ? (store.ttl_ms / 60000) + " min" : "—");
    width("st-rs-bar", store.max_bytes ? store.bytes / store.max_bytes : null);

    const kv = stats.kv_quant || {};
    $("st-kv-mode").innerHTML = "<code>" + esc(kv.mode || "—") + "</code>";
    const attention = kv.attention;
    $("st-kv-layers").innerHTML = Object.entries(kv.layers || {})
      .map(([key, value]) => '<div class="kv"><b>' + esc(key) + ' layers</b><span>' + esc(value) + "</span></div>").join("") +
      (attention ? '<div class="kv"><b>attention</b><span>' + esc(attention.global) + " global, " + esc(attention.sliding_window) + " sliding</span></div>" : "");

    const runtime = stats.runtime;
    const expert = runtime && runtime.expert_runtime;
    $("st-expert-card").style.display = runtime ? "" : "none";
    if (runtime) {
      const hitRate = (d: { hits?: number; misses?: number } | null | undefined): string => {
        const total = (d?.hits || 0) + (d?.misses || 0);
        return total ? (100 * (d?.hits || 0) / total).toFixed(1) + "%" : "—";
      };
      const turn = expert && expert.last_turn;
      text("st-expert-main-hit", hitRate(turn?.main?.demand));
      text("st-expert-main-read", turn?.main?.demand ? gb(turn.main.demand.readBytes, 2) : "—");
      text("st-expert-mtp-hit", hitRate(turn?.mtp?.demand));
      text("st-expert-mtp-read", turn?.mtp?.demand ? gb(turn.mtp.demand.readBytes, 2) : "—");
      const main = expert?.main_residency, mtp = expert?.mtp_residency;
      text("st-expert-residency", main
        ? "resident slots: main " + num(main.resident + main.pinned) + " of " + num(main.resident + main.pinned + main.working) +
          (mtp ? ", MTP " + num(mtp.resident + mtp.pinned) + " of " + num(mtp.resident + mtp.pinned + mtp.working) : "")
        : "expert runtime telemetry unavailable");
    }

    await loadDownloads();
    if (!fitLoaded) { await loadFit(); await loadLibrary(); }
    if (stats.server && stats.server.started_at) text("st-uptime", uptime((Date.now() - stats.server.started_at) / 1000));
    text("st-updated", new Date().toLocaleTimeString());
  }

  async function loadDownloads(): Promise<void> {
    const answer = await api.get<{ downloads?: DownloadRow[] }>("/downloads");
    if (answer.ok === false) return;
    const downloads = answer.downloads;
    const card = $("st-dl-card");
    if (!downloads || downloads.length === 0) { card.style.display = "none"; return; }
    card.style.display = "";
    const order = downloads.slice().sort((a, b) => (a.state === "active" ? 0 : 1) - (b.state === "active" ? 0 : 1) || b.startedAt - a.startedAt);
    $("st-dl-list").innerHTML = order.map((d) => {
      const fraction = d.totalBytes ? Math.min(1, d.receivedBytes / d.totalBytes) : 0;
      let detail: string, meterClass = "";
      if (d.state === "active") {
        let bps = d.bytesPerSec || 0;
        if (!bps) {
          const prev = dlRates[d.repoId], now = performance.now();
          if (prev && now > prev.t) bps = (d.receivedBytes - prev.bytes) / ((now - prev.t) / 1000);
          dlRates[d.repoId] = { bytes: d.receivedBytes, t: now };
        }
        const speed = bps > 0 ? `, ${mb(bps)}/s, about ${Math.max(1, Math.round((d.totalBytes - d.receivedBytes) / bps / 60))} min left` : "";
        detail = `${gb(d.receivedBytes, 2)} of ${gb(d.totalBytes, 2)} (${Math.round(fraction * 100)}%)${speed}` + (d.currentFile ? ", <code>" + esc(d.currentFile) + "</code>" : "");
        meterClass = "accent";
      } else if (d.state === "done") {
        detail = gb(d.totalBytes, 2) + ', <span class="tag ok">complete</span>';
        meterClass = "ok";
      } else {
        detail = '<span class="tag bad">failed</span> ' + esc(d.error || "");
        meterClass = "bad";
      }
      return '<div class="dl-row">' +
        '<div class="kv" style="border:0;padding:0"><b style="color:var(--ink)">' + esc(d.repoId) + "</b>" +
        '<span class="muted">' + d.filesDone + " of " + d.filesTotal + " files</span></div>" +
        '<div class="muted num" style="font-size:var(--text-sm)">' + detail + "</div>" +
        '<div class="meter ' + meterClass + '"><i style="width:' + (fraction * 100) + '%"></i></div></div>';
    }).join("");
  }

  async function loadLibrary(): Promise<void> {
    const answer = await api.get<{ models?: LibraryModel[] }>("/library");
    if (answer.ok === false || !answer.models) return;
    const models = answer.models;
    if (!models.length) { $("st-lib-body").innerHTML = '<tr><td colspan="5" class="muted">Nothing is downloaded yet.</td></tr>'; return; }
    $("st-lib-body").innerHTML = models.slice()
      .sort((a, b) => (b.serving ? 1 : 0) - (a.serving ? 1 : 0) || b.size_bytes - a.size_bytes)
      .map((m) => {
        const a = m.assessment;
        let status: string;
        if (m.serving) status = '<span class="tag ok">serving</span>';
        else if (!m.supported) status = '<span class="tag">unsupported (' + esc(m.model_type) + ")</span>";
        else if (a && a.fits) status = '<span class="tag ok">fits</span>';
        else status = '<span class="tag bad">too big</span>';
        // max_safe_context is meaningful whenever it is above zero, even when `fits` is false at the library's default probe context.
        const safeCtx = m.supported && a && (a.max_safe_context ?? 0) > 0 ? num(a.max_safe_context) : "—";
        return "<tr" + (m.serving ? ' class="you"' : "") + "><td>" + esc(m.repo_id) +
          (m.vision ? ' <span class="tag">vision</span>' : "") +
          '</td><td class="num">' + gb(m.size_bytes, 2) + "</td><td>" + status + "</td>" +
          '<td class="num">' + safeCtx + "</td>" +
          '<td class="num">' + (m.supported && a && a.fits ? (a.predicted_decode_tps ?? 0).toFixed(0) + " tok/s" : "—") + "</td></tr>";
      }).join("");
  }

  async function loadFit(): Promise<void> {
    const f = await api.get<FitResponse>("/fit");
    if (f.ok === false) return;
    fitLoaded = true;
    const r = f.report || {};
    if (f.measured_decode_tps) {
      text("st-tps", tps(f.measured_decode_tps));
      text("st-tps-cap", "measured on this machine; predicted " + tps(f.typical_decode_tps || 0) + " at " + num(f.typical_context_tokens) + " tokens of context");
    } else if (f.typical_decode_tps) {
      text("st-tps", f.typical_decode_tps.toFixed(1));
      text("st-tps-cap", "predicted at " + num(f.typical_context_tokens) + " tokens of context; " + (r.predicted_decode_tps || 0).toFixed(1) + " tok/s at the " + num(f.context_tokens) + " maximum");
    } else {
      text("st-tps", r.predicted_decode_tps == null ? "—" : r.predicted_decode_tps.toFixed(1));
    }
    text("st-m-ram", gb(f.machine && f.machine.ram_bytes, 0));
    text("st-m-bw", (f.machine && f.machine.bandwidth_gbs || "—") + " GB/s");
    $("st-m-fits").innerHTML = r.fits == null ? "—" : r.fits ? '<span class="tag ok">fits</span>' : '<span class="tag bad">does not fit</span>';
    text("st-fit-ctx", num(f.context_tokens));
    document.querySelectorAll<HTMLElement>("[data-plan-fit]").forEach((row) => { row.style.display = f.plan ? "" : "none"; });
    text("st-f-weights-label", f.plan ? "resident weights" : "weights");
    text("st-f-transient-label", f.plan ? "other reserves" : "transient");
    text("st-f-artifact", f.plan?.artifact_disk_bytes ? gb(f.plan.artifact_disk_bytes, 2) : "registry unavailable");
    $("st-f-streamed").innerHTML = Object.entries(f.plan?.streamed_weights || {})
      .map(([label, value]) => '<div class="kv"><b>' + esc(label) + "</b><span>" + gb(value, 2) + "</span></div>").join("");
    text("st-f-weights", gb(r.weights_bytes, 2));
    text("st-f-kv", gb(r.kv_bytes, 2));
    text("st-f-transient", gb(r.transient_bytes, 2));
    text("st-f-total", gb(r.total_bytes, 2) + " of " + gb(r.usable_bytes, 2));
    width("st-fit-bar", r.usable_bytes ? (r.total_bytes ?? 0) / r.usable_bytes : null);

    text("st-sku-ctx", num(f.sku_matrix_ctx));
    const myRam = Math.round((f.machine && f.machine.ram_bytes || 0) / 2 ** 30);
    const myChip = (f.machine && f.machine.chip) || null;
    const rows = f.sku_matrix || [];
    let youIdx = rows.findIndex((row) => myChip && row.sku === myChip && row.ram_gb === myRam);
    if (youIdx < 0 && myChip) {
      let best = Infinity;
      rows.forEach((row, i) => { if (row.sku === myChip && Math.abs(row.ram_gb - myRam) < best) { best = Math.abs(row.ram_gb - myRam); youIdx = i; } });
    }
    if (youIdx < 0) youIdx = rows.findIndex((row) => row.ram_gb === myRam);
    $("st-sku-body").innerHTML = rows.length ? rows.map((row, i) => {
      const you = i === youIdx;
      const dim = row.fits ? "num" : "num fit-no";
      return "<tr" + (you ? ' class="you"' : "") + "><td>" + esc(row.sku) + (you ? ' <span class="tag accent">this machine</span>' : "") +
        '</td><td class="num">' + row.ram_gb + " GB</td>" +
        '<td class="' + (row.fits ? "fit-yes" : "fit-no") + '">' + (row.fits ? "fits" : "no") + "</td>" +
        '<td class="' + dim + '">' + (row.max_context > 0 ? num(row.max_context) : "0, the weights alone do not fit") + "</td>" +
        '<td class="' + dim + '">' + (row.decode_tps > 0 ? "about " + tps(row.decode_tps) + " tok/s" : "—") + "</td></tr>";
    }).join("") : '<tr><td colspan="5" class="muted">No fit table for this model.</td></tr>';
  }

  return {
    init() {
      injectStyles("mlxbun-status-style", STATUS_CSS);
      $("s-status").innerHTML = STATUS_MARKUP;
    },
    enter() {
      void tick();
      timer = setInterval(() => { void tick(); }, 2000);
      void loadLibrary();
      libTimer = setInterval(() => { void loadLibrary(); }, 15_000);
    },
    leave() {
      if (timer) clearInterval(timer); timer = null;
      if (libTimer) clearInterval(libTimer); libTimer = null;
    },
    // A quantize job's done event refreshes the library at once instead of waiting up to 15 s: the server invalidates
    // its /library cache the moment the job completes, so an immediate re-fetch is fresh, not a race.
    refreshLibrary: () => { void loadLibrary(); },
  };
}
