// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// STATUS CONTROLLER — ported dashboard (poll /stats + /v1/models + /fit +
// /library + /downloads). Behavior-identical port of the original
// controllers.status IIFE in app.html.

import { $, gb, mb, num } from "./shell";
import { esc } from "./markdown";

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
  assessment?: {
    fits?: boolean;
    max_safe_context?: number;
    predicted_decode_tps?: number;
  };
}

interface SkuRow {
  sku: string;
  ram_gb: number;
  fits: boolean;
  max_context: number;
  decode_tps: number;
}

export function createStatusController() {
  let timer: ReturnType<typeof setInterval> | null = null, libTimer: ReturnType<typeof setInterval> | null = null, fitLoaded = false;
  const dlRates: Record<string, { bytes: number; t: number }> = {};
  // Library staleness (web-ui-pass-plan.md #3): /library is server-cached for
  // 30s, but the client used to fetch it exactly once per page load
  // (gated on `fitLoaded`) — a quantize job finishing, a fresh download
  // landing, or a manual drop into the HF cache never showed up without a
  // hard reload. Poll it independently on a ~15s cadence while this view is
  // visible (started in enter()/stopped in leave(), same as the main tick).

  async function tick(): Promise<void> {
    try {
      const [stats, models] = await Promise.all([
        fetch("/stats").then((r) => r.json()),
        fetch("/v1/models").then((r) => r.json()),
      ]);
      const m = models.data && models.data[0];
      $("st-model-id").textContent = (m && m.id) || "—";
      const a = stats.admission || {};
      $("st-model-meta").textContent = num(m && m.context_window) + " token window · weights " + gb(a.weights_bytes);
      $("st-safe-ctx").textContent = num(a.max_safe_context);

      $("st-weights").textContent = gb(a.weights_bytes);
      $("st-usable").textContent = gb(a.usable_bytes);
      $("st-budget").textContent = a.memory_budget_bytes ? gb(a.memory_budget_bytes) : "off";
      $("st-mem-bar").style.width = a.usable_bytes ? Math.min(100, 100 * a.weights_bytes / a.usable_bytes) + "%" : "0%";

      const pc = stats.prompt_cache || {};
      const lookups = (pc.hits || 0) + (pc.misses || 0);
      $("st-pc-hits").textContent = lookups ? Math.round(100 * pc.hits / lookups) + "%" : "no lookups";
      $("st-pc-entries").textContent = num(pc.entries);
      $("st-pc-bytes").textContent = mb(pc.bytes) + " / " + mb(pc.max_bytes);
      $("st-pc-bar").style.width = pc.max_bytes ? Math.min(100, 100 * pc.bytes / pc.max_bytes) + "%" : "0%";

      const rs = stats.response_store || {};
      $("st-rs-entries").textContent = num(rs.entries);
      $("st-rs-bytes").textContent = mb(rs.bytes) + " / " + mb(rs.max_bytes);
      $("st-rs-ttl").textContent = rs.ttl_ms ? (rs.ttl_ms / 60000) + " min" : "—";
      $("st-rs-bar").style.width = rs.max_bytes ? Math.min(100, 100 * rs.bytes / rs.max_bytes) + "%" : "0%";

      const kv = stats.kv_quant || {};
      $("st-kv-mode").innerHTML = "<code>" + esc(kv.mode || "—") + "</code>";
      const att = kv.attention;
      $("st-kv-layers").innerHTML = Object.entries(kv.layers || {})
        .map(([k, v]) => '<div class="kv"><b>' + esc(k) + ' layers</b><span class="num">' + esc(v) + "</span></div>").join("") +
        (att ? '<div class="kv"><b>attention</b><span class="num">' + esc(att.global) + " global · " + esc(att.sliding_window) + " sliding</span></div>" : "");

      await loadDownloads();
      if (!fitLoaded) { await loadFit(); await loadLibrary(); }
      if (stats.server && stats.server.started_at) {
        const up = (Date.now() - stats.server.started_at) / 1000;
        $("st-uptime").textContent = up < 90 ? Math.round(up) + "s" : up < 5400 ? Math.round(up / 60) + "m" : (up / 3600).toFixed(1) + "h";
      }
      $("st-updated").textContent = new Date().toLocaleTimeString();
    } catch {
      /* nav pill already reflects connectivity; leave last-good values on screen */
    }
  }

  async function loadDownloads(): Promise<void> {
    let downloads: DownloadRow[] | undefined;
    try { ({ downloads } = await fetch("/downloads").then((r) => r.json())); } catch { return; }
    const card = $("st-dl-card");
    if (!downloads || downloads.length === 0) { card.style.display = "none"; return; }
    card.style.display = "";
    const order = downloads.slice().sort((a, b) =>
      (a.state === "active" ? 0 : 1) - (b.state === "active" ? 0 : 1) || b.startedAt - a.startedAt);
    $("st-dl-list").innerHTML = order.map((d) => {
      const pct = d.totalBytes ? Math.min(100, 100 * d.receivedBytes / d.totalBytes) : 0;
      let detail: string, barCls = "";
      if (d.state === "active") {
        let bps = d.bytesPerSec || 0;
        if (!bps) {
          const prev = dlRates[d.repoId], now = performance.now();
          if (prev && now > prev.t) bps = (d.receivedBytes - prev.bytes) / ((now - prev.t) / 1000);
          dlRates[d.repoId] = { bytes: d.receivedBytes, t: now };
        }
        const speed = bps > 0 ? " · " + mb(bps) + "/s · ~" + Math.max(1, Math.round((d.totalBytes - d.receivedBytes) / bps / 60)) + " min left" : "";
        detail = gb(d.receivedBytes) + " / " + gb(d.totalBytes) + " · " + pct.toFixed(0) + "%" + speed +
          (d.currentFile ? " · <code>" + esc(d.currentFile) + "</code>" : "");
        barCls = "warm";
      } else if (d.state === "done") {
        detail = gb(d.totalBytes) + ' · <span style="color:var(--green);font-weight:600">complete</span>';
      } else {
        detail = '<span style="color:var(--red);font-weight:600">error</span> · ' + esc(d.error || "");
      }
      return '<div style="padding:10px 0">' +
        '<div class="kv" style="border:none"><b>' + esc(d.repoId) + "</b>" +
        '<span class="num">' + d.filesDone + "/" + d.filesTotal + " files</span></div>" +
        '<div style="font-size:13.5px;color:var(--dim)" class="num">' + detail + "</div>" +
        '<div class="meter ' + barCls + '"><i style="width:' + pct + '%"></i></div></div>';
    }).join("");
  }

  async function loadLibrary(): Promise<void> {
    let models: LibraryModel[] | undefined;
    try { ({ models } = await fetch("/library").then((r) => r.json())); } catch { return; }
    if (!models) return;
    $("st-lib-body").innerHTML = models.slice()
      .sort((a, b) => (b.serving ? 1 : 0) - (a.serving ? 1 : 0) || b.size_bytes - a.size_bytes)
      .map((m) => {
        const a = m.assessment;
        let status: string;
        if (m.serving) status = '<span style="color:var(--blue);font-weight:700">SERVING</span>';
        else if (!m.supported) status = '<span style="color:var(--dimmer)">unsupported (' + esc(m.model_type) + ")</span>";
        else if (a && a.fits) status = '<span style="color:var(--green);font-weight:600">fits</span>';
        else status = '<span style="color:var(--red);font-weight:600">too big</span>';
        // web-ui-pass-plan.md #20: max_safe_context is meaningful whenever
        // it's > 0, even when `fits` is false at the library's default 8192
        // probe context — e.g. a model that doesn't fit at 8192 tokens but
        // does fit at a smaller context still gets a real number here rather
        // than an uninformative "—". predicted_decode_tps stays gated on
        // `fits` since it's only computed for the fitting case server-side.
        const safeCtx = m.supported && a && (a.max_safe_context ?? 0) > 0 ? num(a.max_safe_context) : "—";
        return "<tr" + (m.serving ? ' class="you"' : "") + "><td>" + esc(m.repo_id) +
          (m.vision ? ' · <span style="color:var(--dim)">vision</span>' : "") +
          '</td><td class="num">' + gb(m.size_bytes) + "</td><td>" + status + "</td>" +
          '<td class="num">' + safeCtx + "</td>" +
          '<td class="num">' + (m.supported && a && a.fits ? (a.predicted_decode_tps ?? 0).toFixed(0) + " tok/s" : "—") + "</td></tr>";
      }).join("");
  }

  async function loadFit(): Promise<void> {
    interface FitResponse {
      report?: {
        fits?: boolean;
        weights_bytes?: number; kv_bytes?: number; transient_bytes?: number;
        total_bytes?: number; usable_bytes?: number; predicted_decode_tps?: number;
      };
      measured_decode_tps?: number;
      typical_decode_tps?: number;
      typical_context_tokens?: number;
      context_tokens?: number;
      machine?: { ram_bytes?: number; bandwidth_gbs?: number; chip?: string };
      sku_matrix_ctx?: number;
      sku_matrix?: SkuRow[];
    }
    let f: FitResponse;
    try { f = await fetch("/fit").then((r) => r.json()); } catch { return; }
    fitLoaded = true;
    const r = f.report || {};
    if (f.measured_decode_tps) {
      $("st-tps").textContent = f.measured_decode_tps.toFixed(1);
      $("st-tps").closest(".card")!.querySelector("h3")!.textContent = "Decode · measured";
      $("st-tps-cap").textContent = "mlx-bun benchmark on this machine · predicted " + (f.typical_decode_tps || 0).toFixed(1) + " at " + num(f.typical_context_tokens) + " ctx";
    } else if (f.typical_decode_tps) {
      $("st-tps").textContent = f.typical_decode_tps.toFixed(1);
      $("st-tps-cap").textContent = "at " + num(f.typical_context_tokens) + " context · " + (r.predicted_decode_tps || 0).toFixed(1) + " tok/s at the " + num(f.context_tokens) + " max (full-KV reads)";
    } else {
      $("st-tps").textContent = (r.predicted_decode_tps || 0).toFixed(1);
    }
    $("st-m-ram").textContent = gb(f.machine && f.machine.ram_bytes);
    $("st-m-bw").textContent = (f.machine && f.machine.bandwidth_gbs || "—") + " GB/s";
    $("st-m-fits").innerHTML = r.fits ? '<span style="color:var(--green);font-weight:700">FITS</span>' : '<span style="color:var(--red);font-weight:700">DOES NOT FIT</span>';
    $("st-fit-ctx").textContent = num(f.context_tokens);
    $("st-f-weights").textContent = gb(r.weights_bytes);
    $("st-f-kv").textContent = gb(r.kv_bytes);
    $("st-f-transient").textContent = gb(r.transient_bytes);
    $("st-f-total").textContent = gb(r.total_bytes) + " / " + gb(r.usable_bytes);
    $("st-fit-bar").style.width = r.usable_bytes ? Math.min(100, 100 * (r.total_bytes ?? 0) / r.usable_bytes) + "%" : "0%";

    $("st-sku-ctx").textContent = num(f.sku_matrix_ctx);
    const myRam = Math.round((f.machine && f.machine.ram_bytes || 0) / 2 ** 30);
    const myChip = (f.machine && f.machine.chip) || null;
    const rows = f.sku_matrix || [];
    let youIdx = rows.findIndex((row) => myChip && row.sku === myChip && row.ram_gb === myRam);
    if (youIdx < 0 && myChip) {
      let best = Infinity;
      rows.forEach((row, i) => { if (row.sku === myChip && Math.abs(row.ram_gb - myRam) < best) { best = Math.abs(row.ram_gb - myRam); youIdx = i; } });
    }
    if (youIdx < 0) youIdx = rows.findIndex((row) => row.ram_gb === myRam);
    $("st-sku-body").innerHTML = rows.map((row, i) => {
      const you = i === youIdx;
      const dimCls = row.fits ? "num" : "num fit-no";
      return "<tr" + (you ? ' class="you"' : "") + "><td>" + esc(row.sku) + (you ? " · <b>this machine</b>" : "") +
        '</td><td class="num">' + row.ram_gb + " GB</td>" +
        '<td class="' + (row.fits ? "fit-yes" : "fit-no") + '">' + (row.fits ? "fits" : "no") + "</td>" +
        '<td class="' + dimCls + '">' + (row.max_context > 0 ? num(row.max_context) : "0 — weights alone don’t fit") + "</td>" +
        '<td class="' + dimCls + '">' + (row.decode_tps > 0 ? "~" + row.decode_tps.toFixed(0) + " tok/s" : "—") + "</td></tr>";
    }).join("");
  }

  return {
    init() {
      // trigger scroll reveals once mounted
      const page = $("status-page");
      requestAnimationFrame(() => page.classList.add("lit"));
      page.classList.add("lit");
    },
    enter() {
      tick();
      timer = setInterval(tick, 2000);
      loadLibrary();
      libTimer = setInterval(loadLibrary, 15_000);
    },
    leave() {
      if (timer) clearInterval(timer); timer = null;
      if (libTimer) clearInterval(libTimer); libTimer = null;
    },
    // Exposed so a quantize job's `done` event (this same controller's own
    // quantize flow, see controllers.quantize below) can force an immediate
    // refresh instead of waiting up to 15s — the server invalidates its
    // /library cache the moment the job completes (server.ts onComplete),
    // so an immediate re-fetch is guaranteed fresh, not a race.
    refreshLibrary: loadLibrary,
  };
}
