// Memory contracts — `mlx-bun fit`. Every term is deterministic:
//   weights        — safetensors byte sizes (registry)
//   KV bytes/token — config: layers × kv_heads × head_dim × bytes;
//                    sliding-window layers saturate at the window
//   prefill transient — chunk size we choose × calibrated bytes/token
//   machine        — RAM (queried) + Metal wired ceiling fraction
//
// Calibration constants come from measured runs on the reference M4 Pro
// (see PLAN.md baselines; eval DB validates predictions against peaks).

import { totalmem } from "node:os";
import type { KvQuantSpec, ModelConfig } from "./config";

/** Decode-efficiency vs theoretical bandwidth ceiling, measured on the
 *  reference machine (24.9 tok/s vs 30.3 ceiling @600 ctx). */
export const DECODE_EFFICIENCY = 0.82;
/** MoE decode efficiency vs the active-bytes ceiling. RECALIBRATED from
 *  the Phase 15 cleared-machine matrix: 26B-A4B measured 54.5 tok/s
 *  (python 55.7 — parity) vs ~71 tok/s raw ceiling → 0.76. The earlier
 *  0.42 came from a session where BOTH stacks were memory-degraded
 *  (32.3/33.0 "parity" — equally wrong, mutually consistent). */
export const MOE_DECODE_EFFICIENCY = 0.76;
/** Prefill transient bytes per chunk token (measured: ~1.1 GB @ 2048). */
export const TRANSIENT_PER_TOKEN = 0.55e6;
/** Fraction of unified RAM usable as GPU working set (Metal's
 *  recommendedMaxWorkingSetSize is ~75% on consumer SKUs). */
export const WIRED_FRACTION = 0.75;
export const DEFAULT_CHUNK = 2048;
/** KV cache element size (bf16 — the default, scheme-less cache). */
const KV_BYTES = 2;

/** KV-quant scheme for the fit math, mirroring serve's --kv-quant surface:
 *  uniform kvBits quantizes every attention layer (rotating included);
 *  kvConfig lists the quantized layers per-layer, the rest stay bf16.
 *  Omitted entirely → bf16. TurboQuant is deliberately absent: it stays
 *  billed at bf16 (conservative) until its cache layout gets a projector. */
export interface FitKvScheme {
  kvBits?: number;
  kvGroupSize?: number;
  kvConfig?: KvQuantSpec[];
}

/** Bytes per stored KV element under affine group quantization: packed
 *  uint32 words hold bits/8 per element, plus a scale and bias in the
 *  source dtype (bf16, 2 B each) per group (QuantizedKVCache layout). */
export function kvQuantBytesPerElement(bits: number, groupSize: number): number {
  return bits / 8 + 4 / groupSize;
}

export interface MachineSpec {
  name: string;
  ramBytes: number;
  bandwidthGBs: number;
}

/** Representative Apple Silicon SKUs (memory bandwidth GB/s). */
export const APPLE_SKUS: { chip: string; bandwidthGBs: number; ramOptions: number[] }[] = [
  { chip: "M1", bandwidthGBs: 68, ramOptions: [8, 16] },
  { chip: "M1 Pro", bandwidthGBs: 200, ramOptions: [16, 32] },
  { chip: "M1 Max", bandwidthGBs: 400, ramOptions: [32, 64] },
  { chip: "M1 Ultra", bandwidthGBs: 800, ramOptions: [64, 128] },
  { chip: "M2", bandwidthGBs: 100, ramOptions: [8, 16, 24] },
  { chip: "M2 Pro", bandwidthGBs: 200, ramOptions: [16, 32] },
  { chip: "M2 Max", bandwidthGBs: 400, ramOptions: [32, 64, 96] },
  { chip: "M2 Ultra", bandwidthGBs: 800, ramOptions: [64, 128, 192] },
  { chip: "M3", bandwidthGBs: 100, ramOptions: [8, 16, 24] },
  { chip: "M3 Pro", bandwidthGBs: 150, ramOptions: [18, 36] },
  { chip: "M3 Max", bandwidthGBs: 400, ramOptions: [36, 48, 64, 96, 128] },
  { chip: "M3 Ultra", bandwidthGBs: 819, ramOptions: [96, 256, 512] },
  { chip: "M4", bandwidthGBs: 120, ramOptions: [16, 24, 32] },
  { chip: "M4 Pro", bandwidthGBs: 273, ramOptions: [24, 48] },
  { chip: "M4 Max", bandwidthGBs: 546, ramOptions: [36, 48, 64, 128] },
];

/** Chip name from sysctl ("M1 Max") + its bandwidth from APPLE_SKUS. */
export function detectChip(): { name: string | null; bandwidthGBs: number | null } {
  try {
    const proc = Bun.spawnSync(["sysctl", "-n", "machdep.cpu.brand_string"]);
    const name = proc.stdout.toString().trim().replace(/^Apple\s+/, "");
    if (!name) return { name: null, bandwidthGBs: null };
    const sku = APPLE_SKUS.find((s) => s.chip === name);
    return { name, bandwidthGBs: sku?.bandwidthGBs ?? null };
  } catch {
    return { name: null, bandwidthGBs: null };
  }
}

export function thisMachine(bandwidthGBs?: number): MachineSpec {
  // Default bandwidth: the detected chip's table entry; 273 (M4 Pro, the
  // original dev machine) only as the last resort.
  const bw = bandwidthGBs ?? detectChip().bandwidthGBs ?? 273;
  return { name: "this machine", ramBytes: totalmem(), bandwidthGBs: bw };
}

/** The default model everywhere — e4b. Fits comfortably on every supported
 *  Mac (including 24 GB), loads fast, and is a heavily-used primary model.
 *  Override with an explicit query (e.g. `mlx-bun serve 12B`). */
export const DEFAULT_REPO_ID = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";

/** Recommended first model. e4b for every machine by default: the old
 *  per-tier sizing reached 12B/26B on larger Macs and pushed 24 GB machines
 *  into memory pressure (a 26B is ~18 GB). The tiered sizing is preserved in
 *  largestRecommendedRepoId for callers that explicitly want the biggest fit. */
export function recommendedRepoId(_ramBytes = totalmem()): string {
  return DEFAULT_REPO_ID;
}

/** Largest Gemma a RAM tier can comfortably hold. NOT the default (see
 *  recommendedRepoId) — kept available for explicit "biggest model" opt-in. */
export function largestRecommendedRepoId(ramBytes = totalmem()): string {
  const gb = ramBytes / 2 ** 30;
  if (gb >= 48) return "mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit";
  if (gb >= 24) return "mlx-community/gemma-4-12B-it-OptiQ-4bit";
  return DEFAULT_REPO_ID;
}

/** Fraction of RAM an *auto-selected* model may occupy and still leave the
 *  machine usable for other apps (browser, editor, Photoshop). Deliberately
 *  stricter than WIRED_FRACTION: auto-pick must never grab a "dedicate the
 *  whole machine" model — e.g. the 26B (~17 GB) on a 24 GB Mac — those stay
 *  an explicit `--query` choice. The same model clears this budget on a
 *  big-RAM Mac, so it remains auto-eligible there (RAM-relative by design). */
export const COEXIST_FRACTION = 0.6;

export interface AutoPickCandidate {
  repoId: string;
  sizeBytes: number;
}

/**
 * Pick the model to auto-load when the user gives no query:
 *   1. the default (e4b) if downloaded and it fits at all;
 *   2. else the largest model that still leaves coexistence headroom;
 *   3. else (last resort) the largest model that fits at all — so a user
 *      whose only model is a heavy one still gets it.
 * Pure: the caller supplies the fit predicates, so this is unit-tested
 * without touching the registry or loading configs.
 */
export function chooseAutoModel<T extends AutoPickCandidate>(
  candidates: T[],
  defaultRepoId: string,
  fitsFullBudget: (c: T) => boolean,
  fitsCoexistBudget: (c: T) => boolean,
): T | undefined {
  const preferred = candidates.find((c) => c.repoId === defaultRepoId);
  if (preferred && fitsFullBudget(preferred)) return preferred;
  const bySizeDesc = [...candidates].sort((a, b) => b.sizeBytes - a.sizeBytes);
  return bySizeDesc.find(fitsCoexistBudget) ?? bySizeDesc.find(fitsFullBudget);
}

export interface FitReport {
  fits: boolean;
  contextTokens: number;
  weightsBytes: number;
  kvBytes: number;
  transientBytes: number;
  totalBytes: number;
  usableBytes: number;
  maxSafeContext: number;
  predictedDecodeTps: number;
}

interface KvGeometry {
  fullLayers: number;
  slidingLayers: number;
  linearLayers: number;
  fullBytesPerToken: number;
  slidingBytesPerToken: number;
  /** Constant recurrent-state bytes for linear-attention (DeltaNet) layers:
   *  f32 state [Hv, Dv, Dk] + bf16 conv window [K-1, 2·Hk·Dk + Hv·Dv] per
   *  layer (see qwen3-delta.ts) — context-independent, so it belongs in the
   *  fixed term, never in bytes/token. */
  linearStateBytes: number;
  window: number;
}

function kvGeometry(config: ModelConfig, scheme?: FitKvScheme): KvGeometry {
  const t = config.text;
  // Per-layer element size: kvConfig quantizes listed layers only; uniform
  // kvBits quantizes every attention layer (matches maybeQuantizeKv).
  const byLayer = scheme?.kvConfig?.length
    ? new Map(scheme.kvConfig.map((e) => [e.layerIdx, e]))
    : null;
  const uniformBytes = scheme?.kvBits
    ? kvQuantBytesPerElement(scheme.kvBits, scheme.kvGroupSize ?? 64)
    : KV_BYTES;
  const elBytes = (layer: number): number => {
    if (byLayer) {
      const e = byLayer.get(layer);
      return e ? kvQuantBytesPerElement(e.bits, e.groupSize) : KV_BYTES;
    }
    return uniformBytes;
  };
  let fullLayers = 0, slidingLayers = 0, linearLayers = 0;
  let fullBytesPerToken = 0, slidingBytesPerToken = 0;
  for (let i = 0; i < t.numHiddenLayers; i++) {
    // empty/short layerTypes means full attention (llama-like configs)
    const type = t.layerTypes[i] ?? "full_attention";
    if (type === "linear_attention") {
      linearLayers++;
    } else if (type === "sliding_attention") {
      slidingLayers++;
      slidingBytesPerToken += 2 * t.numKeyValueHeads * t.headDim * elBytes(i);
    } else {
      fullLayers++;
      fullBytesPerToken += 2 * t.numGlobalKeyValueHeads * t.globalHeadDim * elBytes(i);
    }
  }
  // Linear (DeltaNet) state is never KV-quantized (SSMCache is not a
  // KVCache) — always f32 state + model-dtype conv window.
  const convDim = 2 * t.linearNumKeyHeads * t.linearKeyHeadDim +
    t.linearNumValueHeads * t.linearValueHeadDim;
  const linearStateBytes = linearLayers === 0 ? 0 : linearLayers * (
    t.linearNumValueHeads * t.linearValueHeadDim * t.linearKeyHeadDim * 4 +
    Math.max(0, t.linearConvKernelDim - 1) * convDim * KV_BYTES
  );
  return {
    fullLayers,
    slidingLayers,
    linearLayers,
    fullBytesPerToken,
    slidingBytesPerToken,
    linearStateBytes,
    window: t.slidingWindow,
  };
}

export function kvBytesAt(config: ModelConfig, ctx: number, kvScheme?: FitKvScheme): number {
  const g = kvGeometry(config, kvScheme);
  return g.fullBytesPerToken * ctx + g.slidingBytesPerToken * Math.min(ctx, g.window) +
    g.linearStateBytes;
}

export function fit(
  config: ModelConfig,
  weightsBytes: number,
  ctx: number,
  machine: MachineSpec = thisMachine(),
  chunk: number = DEFAULT_CHUNK,
  /** Bytes of `.experts.` tensors (registry). MoE decode reads only
   *  top_k/num_experts of them per token; residency still needs all. */
  expertsBytes = 0,
  /** Explicit memory budget in bytes (admission control). When set it
   *  replaces the machine-derived usable ceiling (ram × WIRED_FRACTION)
   *  outright — the budget IS the usable envelope. */
  usableBytes?: number,
  /** Active KV-quant scheme; a quantized cache holds more context in the
   *  same budget, so the solved ceiling (and admission) must bill it. */
  kvScheme?: FitKvScheme,
): FitReport {
  const usable = usableBytes ?? machine.ramBytes * WIRED_FRACTION;
  const transient = Math.min(chunk, ctx) * TRANSIENT_PER_TOKEN;
  const kv = kvBytesAt(config, ctx, kvScheme);
  const total = weightsBytes + kv + transient;

  // solve max context: weights + kv(ctx) + transient ≤ usable.
  // Below the window both KV terms are linear in ctx; above it the
  // sliding term saturates and only full-attention layers keep growing.
  const g = kvGeometry(config, kvScheme);
  const fixed = weightsBytes + chunk * TRANSIENT_PER_TOKEN + g.linearStateBytes;
  let maxCtx = 0;
  if (usable > fixed) {
    const budget = usable - fixed;
    const linear = Math.floor(budget / (g.fullBytesPerToken + g.slidingBytesPerToken));
    maxCtx = linear <= g.window
      ? linear
      : Math.floor((budget - g.slidingBytesPerToken * g.window) / g.fullBytesPerToken);
    maxCtx = Math.min(maxCtx, config.text.maxPositionEmbeddings);
  }

  // decode reads all weights + the KV cache once per token — except MoE
  // expert weights, where only top_k of num_experts are touched per token
  const t = config.text;
  const isMoe = t.enableMoeBlock && t.numExperts > 0;
  const expertsSkipped = isMoe
    ? expertsBytes * (1 - t.topKExperts / t.numExperts)
    : 0;
  const bytesPerToken = weightsBytes - expertsSkipped + kv;
  const predictedDecodeTps =
    ((machine.bandwidthGBs * 1e9) / bytesPerToken) *
    (isMoe ? MOE_DECODE_EFFICIENCY : DECODE_EFFICIENCY);

  return {
    fits: total <= usable,
    contextTokens: ctx,
    weightsBytes,
    kvBytes: kv,
    transientBytes: transient,
    totalBytes: total,
    usableBytes: usable,
    maxSafeContext: maxCtx,
    predictedDecodeTps,
  };
}

/** The SKU matrix: which Apple Silicon configs run this model at `ctx`. */
export function skuMatrix(
  config: ModelConfig, weightsBytes: number, ctx: number, expertsBytes = 0,
  kvScheme?: FitKvScheme,
): { sku: string; ramGB: number; fits: boolean; maxContext: number; decodeTps: number }[] {
  const rows: ReturnType<typeof skuMatrix> = [];
  for (const sku of APPLE_SKUS) {
    for (const ram of sku.ramOptions) {
      const m: MachineSpec = {
        name: `${sku.chip} ${ram}GB`,
        ramBytes: ram * 2 ** 30,
        bandwidthGBs: sku.bandwidthGBs,
      };
      const r = fit(config, weightsBytes, ctx, m, DEFAULT_CHUNK, expertsBytes, undefined, kvScheme);
      rows.push({
        sku: sku.chip,
        ramGB: ram,
        fits: r.fits,
        maxContext: r.maxSafeContext,
        decodeTps: r.predictedDecodeTps,
      });
    }
  }
  return rows;
}
