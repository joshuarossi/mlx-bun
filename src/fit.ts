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
import type { ModelConfig } from "./config";

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
/** KV cache element size (bf16; quantized KV lands in Phase 6). */
const KV_BYTES = 2;

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
  { chip: "M2", bandwidthGBs: 100, ramOptions: [8, 16, 24] },
  { chip: "M2 Pro", bandwidthGBs: 200, ramOptions: [16, 32] },
  { chip: "M2 Max", bandwidthGBs: 400, ramOptions: [32, 64, 96] },
  { chip: "M3", bandwidthGBs: 100, ramOptions: [8, 16, 24] },
  { chip: "M3 Pro", bandwidthGBs: 150, ramOptions: [18, 36] },
  { chip: "M3 Max", bandwidthGBs: 400, ramOptions: [36, 48, 64, 128] },
  { chip: "M4", bandwidthGBs: 120, ramOptions: [16, 24, 32] },
  { chip: "M4 Pro", bandwidthGBs: 273, ramOptions: [24, 48, 64] },
  { chip: "M4 Max", bandwidthGBs: 546, ramOptions: [36, 64, 128] },
];

export function thisMachine(bandwidthGBs = 273): MachineSpec {
  return { name: "this machine", ramBytes: totalmem(), bandwidthGBs };
}

/** Recommended first model per device tier (PRODUCT_ROADMAP profiles).
 *  Conservative: the model must leave headroom for KV + the OS. */
export function recommendedRepoId(ramBytes = totalmem()): string {
  const gb = ramBytes / 2 ** 30;
  if (gb >= 48) return "mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit";
  if (gb >= 24) return "mlx-community/gemma-4-12B-it-OptiQ-4bit";
  return "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
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
  fullBytesPerToken: number;
  slidingBytesPerToken: number;
  window: number;
}

function kvGeometry(config: ModelConfig): KvGeometry {
  const t = config.text;
  const slidingLayers = t.layerTypes.filter((l) => l === "sliding_attention").length;
  const fullLayers = t.numHiddenLayers - slidingLayers;
  const kEqVFactor = t.attentionKEqV ? 2 : 2; // k and v stored separately either way
  return {
    fullLayers,
    slidingLayers,
    fullBytesPerToken: fullLayers * kEqVFactor * t.numGlobalKeyValueHeads * t.globalHeadDim * KV_BYTES,
    slidingBytesPerToken: slidingLayers * 2 * t.numKeyValueHeads * t.headDim * KV_BYTES,
    window: t.slidingWindow,
  };
}

export function kvBytesAt(config: ModelConfig, ctx: number): number {
  const g = kvGeometry(config);
  return g.fullBytesPerToken * ctx + g.slidingBytesPerToken * Math.min(ctx, g.window);
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
): FitReport {
  const usable = usableBytes ?? machine.ramBytes * WIRED_FRACTION;
  const transient = Math.min(chunk, ctx) * TRANSIENT_PER_TOKEN;
  const kv = kvBytesAt(config, ctx);
  const total = weightsBytes + kv + transient;

  // solve max context: weights + kv(ctx) + transient ≤ usable.
  // Below the window both KV terms are linear in ctx; above it the
  // sliding term saturates and only full-attention layers keep growing.
  const g = kvGeometry(config);
  const fixed = weightsBytes + chunk * TRANSIENT_PER_TOKEN;
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
): { sku: string; ramGB: number; fits: boolean; maxContext: number; decodeTps: number }[] {
  const rows: ReturnType<typeof skuMatrix> = [];
  for (const sku of APPLE_SKUS) {
    for (const ram of sku.ramOptions) {
      const m: MachineSpec = {
        name: `${sku.chip} ${ram}GB`,
        ramBytes: ram * 2 ** 30,
        bandwidthGBs: sku.bandwidthGBs,
      };
      const r = fit(config, weightsBytes, ctx, m, DEFAULT_CHUNK, expertsBytes);
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
