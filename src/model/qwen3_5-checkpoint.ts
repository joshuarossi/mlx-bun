// Qwen3.5 checkpoint-generation normalization — the load-seam port of
// mlx_lm.models.qwen3_5's `Model.sanitize` + `TextModel.sanitize`.
//
// Two checkpoint generations ship the same graph under different conventions:
//
//   pre-5.8 (mlx-lm-converted)    5.8-family (transformers 5.8.0 export)
//   ──────────────────────────    ───────────────────────────────────────
//   language_model.model.*        model.language_model.*
//   language_model.lm_head.*      lm_head.*                (top level)
//   vision_tower.*                model.visual.*
//   (no mtp tensors in-repo)      mtp.*                    (in-repo)
//   conv1d.weight [C, K, 1]       conv1d.weight [C, 1, K]  (HF layout)
//   RMSNorm gains stored as γ     RMSNorm gains stored as γ−1
//
// Our graph speaks the FIRST column (`PREFIX = "language_model"` in
// qwen3_5.ts) — which is exactly mlx-lm's post-sanitize name space — so this
// module maps the artifact onto it instead of teaching every consumer two
// namings. The rules below are a line-for-line copy of the oracle; see
// mlx_lm/models/qwen3_5.py `Model.sanitize` (naming/drop) and
// `TextModel.sanitize` (γ shift, conv layout).
//
// The γ shift is the dangerous one: a spurious +1.0 silently corrupts an old
// artifact. The oracle's discriminator is NOT the naming — it is
//   should_shift = any("mtp." in k) or any conv1d.weight with shape[-1] != 1
// evaluated over the whole (post-rename, pre-drop) weight map. Reproduced
// verbatim. Measured on the two artifacts in play (2026-09-01, M1 Max):
//   • ~/.cache/…/models--mjriii--Qwen3.8-27B/snapshots/staged — no mtp.*,
//     conv1d [10240,4,1] → no shift; layer-0 input_layernorm ≡ 1.0.
//   • /Volumes/MLX-Models/models/mjriii/Qwen3.8-27B-{tqalloc-norot,rtn4-g64}
//     — 31 mtp.* tensors, conv1d [10240,1,4] → shift; layer-0
//     input_layernorm mean −0.0334 (= γ−1), byte-identical to the raw
//     Qwen/Qwen3.8-27B 5.8 checkpoint (the quantizer copies norms verbatim).

import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Weights, WeightsView } from "../weights";

/** Header-level facts about one stored tensor (no bytes are read). */
export interface CheckpointTensor {
  readonly name: string;
  readonly shape: readonly number[];
}

export interface Qwen35Sanitized {
  /** canonical (graph) name → the name the artifact actually stores. */
  readonly names: Map<string, string>;
  /** Canonical names stored as γ−1: a +1.0 is due at load. */
  readonly normShift: Set<string>;
  /** Canonical names in HF conv layout: a moveaxis(2, 1) is due at load. */
  readonly convMoveaxis: Set<string>;
  /** True when the artifact already IS our canonical layout — no view needed
   *  and the pre-existing load path runs untouched. */
  readonly identity: boolean;
}

/** mlx-lm `TextModel.sanitize` norm_keys, verbatim and in order. */
const NORM_KEYS = [
  ".input_layernorm.weight",
  ".post_attention_layernorm.weight",
  "model.norm.weight",
  ".q_norm.weight",
  ".k_norm.weight",
] as const;

/** mlx-lm `Model.sanitize`: drop vision, fold every naming onto
 *  `language_model.…`. Returns null for a dropped tensor. */
function canonicalName(key: string): string | null {
  if (key.startsWith("vision_tower") || key.startsWith("model.visual")) return null;
  if (key.startsWith("model.language_model"))
    return "language_model.model" + key.slice("model.language_model".length);
  if (key.startsWith("language_model.")) return key;
  return "language_model." + key;
}

/**
 * Port of mlx_lm.models.qwen3_5 `Model.sanitize` ∘ `TextModel.sanitize`,
 * name/shape half. Pure: takes header facts, returns the load plan.
 */
export function sanitizeQwen35Checkpoint(
  tensors: Iterable<CheckpointTensor>,
): Qwen35Sanitized {
  // Pass 1 — rename (vision dropped), exactly as Model.sanitize.
  const renamed: { canonical: string; source: string; shape: readonly number[] }[] = [];
  let sawForeignName = false;
  for (const t of tensors) {
    const canonical = canonicalName(t.name);
    if (canonical === null) {
      sawForeignName ||= t.name.startsWith("model.visual");
      continue;
    }
    if (canonical !== t.name) sawForeignName = true;
    renamed.push({ canonical, source: t.name, shape: t.shape });
  }

  // Pass 2 — TextModel.sanitize's two flags, over the renamed map BEFORE the
  // mtp drop (the oracle computes them first, then filters).
  const hasMtpWeights = renamed.some((t) => t.canonical.includes("mtp."));
  const hasUnsanitizedConv1d = renamed.some(
    (t) => t.canonical.includes("conv1d.weight") && t.shape[t.shape.length - 1] !== 1,
  );
  const shouldShiftNormWeights = hasMtpWeights || hasUnsanitizedConv1d;

  const names = new Map<string, string>();
  const normShift = new Set<string>();
  const convMoveaxis = new Set<string>();
  for (const t of renamed) {
    if (t.canonical.includes("mtp.")) continue; // oracle drops these outright
    names.set(t.canonical, t.source);
    if (t.canonical.includes("conv1d.weight") && t.shape[t.shape.length - 1] !== 1)
      convMoveaxis.add(t.canonical);
    if (
      shouldShiftNormWeights &&
      NORM_KEYS.some((sfx) => t.canonical.endsWith(sfx)) &&
      t.shape.length === 1
    )
      normShift.add(t.canonical);
  }

  return {
    names,
    normShift,
    convMoveaxis,
    identity: !sawForeignName && !hasMtpWeights && !shouldShiftNormWeights &&
      convMoveaxis.size === 0,
  };
}

/**
 * The {@link WeightsView} for a qwen3.5 artifact, or null when the artifact is
 * already canonical (then nothing is installed and the load path is bit-for-bit
 * what it was before this seam existed).
 */
export function qwen35WeightsView(weights: Weights): WeightsView | null {
  const plan = sanitizeQwen35Checkpoint(
    weights.tensorNames.map((name) => ({ name, shape: weights.info(name).shape })),
  );
  if (plan.identity) return null;
  return {
    names: plan.names,
    fixup(canonical: string, arr: MlxArray): MlxArray | null {
      // Oracle order: moveaxis first, then the γ shift (disjoint sets — a
      // conv1d weight is 3-D and never a norm gain).
      if (plan.convMoveaxis.has(canonical)) {
        // `v.moveaxis(2, 1)` on [C, 1, K] → [C, K, 1]. Materialized: the
        // conv1d kernel consumes it every forward, and the transposed view
        // would otherwise pin the source shard buffer.
        const moved = ops.transposeAxes(arr, [0, 2, 1]);
        const out = ops.contiguous(moved);
        moved.dispose();
        return out;
      }
      if (plan.normShift.has(canonical)) {
        // `v + 1.0` — a weak python scalar, so the add happens at the gain's
        // own dtype (bf16 here); scalarLike builds the constant host-side at
        // that dtype for the same single-kernel add the reference dispatches.
        const one = ops.scalarLike(1, arr);
        const out = ops.add(arr, one);
        one.dispose();
        return out;
      }
      return null;
    },
  };
}
