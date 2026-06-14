// Per-layer LoRA rank resolution — port of optiq/lora/sensitivity_rank.py.
//
// Produces a Map<modulePath, rank> over the model's loraTargets() filtered by
// target-module suffixes and a layer window. The three strategies:
//   constant — every target gets the base rank.
//   by_bits  — rank * (bits / 4), clamped to >= MIN_RANK. For a uniformly
//              4-bit model (MiniCPM5-1B-OptiQ-4bit) this is identical to
//              constant unless an optiq_metadata.json per-layer bits map is
//              supplied.
//   by_kl    — rank * clip(kl / median_kl, 0.5, 2.0); falls back to by_bits
//              when no KL map is present.

import type { RuntimeModel } from "../model/factory";

export type RankScaling = "constant" | "by_bits" | "by_kl";

const MIN_RANK = 2; // mlx LoRA requires rank >= 2.

/** All 7 trainable linears per transformer block (Unsloth target set). */
export const DEFAULT_TARGET_MODULES = [
  "q_proj", "k_proj", "v_proj", "o_proj",
  "gate_proj", "up_proj", "down_proj",
] as const;

export interface ResolveRanksOptions {
  rank: number;
  rankScaling: RankScaling;
  /** Suffixes (e.g. "q_proj"); a module is adapted iff its path ends with one. */
  targetModules?: readonly string[];
  /** -1 = all layers; else only the last N transformer blocks. */
  numLayers?: number;
  /** Optional per-layer bits map (optiq_metadata.json). */
  bitsMap?: Record<string, number>;
  /** Optional per-layer KL map. */
  klMap?: Record<string, number>;
}

/** Resolve a rank per adapted module path. */
export function resolveRanks(model: RuntimeModel, opts: ResolveRanksOptions): Map<string, number> {
  const targetModules = opts.targetModules ?? DEFAULT_TARGET_MODULES;
  const numLayers = opts.numLayers ?? -1;
  const allPaths = [...model.loraTargets().keys()];

  // Total transformer-block count, for the last-N window.
  const totalLayers = countLayers(allPaths);
  const minLayer = numLayers < 0 ? 0 : Math.max(0, totalLayers - numLayers);

  const out = new Map<string, number>();
  for (const path of allPaths) {
    if (!endsWithAny(path, targetModules)) continue;
    const layer = layerIndex(path);
    if (layer >= 0 && layer < minLayer) continue;
    out.set(path, rankForLayer(path, opts));
  }
  return out;
}

function rankForLayer(path: string, opts: ResolveRanksOptions): number {
  const base = opts.rank;
  if (opts.rankScaling === "constant") return Math.max(MIN_RANK, base);

  if (opts.rankScaling === "by_bits") {
    const bits = opts.bitsMap?.[path];
    if (bits === undefined) return Math.max(MIN_RANK, base);
    return Math.max(MIN_RANK, Math.ceil(base * (bits / 4.0)));
  }

  if (opts.rankScaling === "by_kl") {
    const kl = opts.klMap?.[path];
    if (kl === undefined || !opts.klMap) {
      // fall back to by_bits
      return rankForLayer(path, { ...opts, rankScaling: "by_bits" });
    }
    const vals = Object.values(opts.klMap).sort((a, b) => a - b);
    const median = vals.length ? vals[Math.floor(vals.length / 2)]! : 1.0;
    const factor = Math.max(0.5, Math.min(2.0, median ? kl / median : 1.0));
    return Math.max(MIN_RANK, Math.ceil(base * factor));
  }

  throw new Error(`unknown rank_scaling: ${opts.rankScaling}`);
}

/** Extract the transformer-block index from a module path like
 *  `model.layers.7.self_attn.q_proj` → 7; -1 if not found. */
function layerIndex(path: string): number {
  const m = path.match(/\.layers\.(\d+)\./);
  return m ? Number(m[1]) : -1;
}

function countLayers(paths: string[]): number {
  let max = -1;
  for (const p of paths) {
    const i = layerIndex(p);
    if (i > max) max = i;
  }
  return max + 1;
}

function endsWithAny(path: string, suffixes: readonly string[]): boolean {
  return suffixes.some((s) => path.endsWith(s));
}
