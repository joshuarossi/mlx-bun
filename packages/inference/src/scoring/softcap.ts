// Gemma 4 text model — line-for-line port of mlx-lm's gemma4_text.py
// (oracle venv site-packages), covering the paths our target models
// exercise: 12B (dense), e4b (per-layer-input embeddings + KV-shared
// layers), 26B-A4B (MoE block: router + gather_qmm experts).
//
// Parity notes (see PLAN.md Phase 2 findings):
// - SDPA scale is 1.0 (Gemma4 normalizes q/k instead).
// - Full-attention layers: global_head_dim 512, 1 global KV head,
//   attention_k_eq_v (V = same projection as K, with un-scaled RMS norm);
//   ProportionalRoPE rotates only partial_rotary_factor·dims dims.
// - Python-float scalars promote weakly to the array dtype.
// - Replicate mlx python helper implementations exactly (x**3 is
//   mx.power, not x·x·x — they round differently in bf16).
//
// Masks: ports base.py create_attention_mask/create_causal_mask. Sliding
// layers use a plain (non-rotating) cache + window masks — numerically
// identical to mlx-lm's RotatingKVCache, at the cost of unbounded cache
// growth past the window (memory optimization deferred).

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

// The shared, config-independent machinery lives in gemma4-base.ts
// (Phase B extraction); this file keeps the architecture-specific
// assembly that Phase C generates per model. Re-export the base so
// existing importers keep one entry point.

import { CompiledFunction } from "@mlx-bun/mlx/compile";

/** gemma4_text.py `@partial(mx.compile) def logit_softcap(softcap, x):
 *    return mx.tanh(x / softcap) * softcap`
 *  The oracle fuses divide+tanh+multiply into ONE kernel; our default
 *  `logitSoftcap` runs them UNFUSED (standalone div + tanh + mul → a separate
 *  `vn_Tanh` + `vsn_Divide`). Keyed by cap so the softcap is baked as a graph
 *  constant (matching the oracle's weak-scalar → the `…Divide…Tanh…Multiply…_VC_`
 *  kernel). The default (matches mlx-lm's dispatched kernel set). */
const _softcapClosures = new Map<number, CompiledFunction>();
export function compiledLogitSoftcap(x: MlxArray, cap: number): MlxArray {
  let fn = _softcapClosures.get(cap);
  if (!fn) {
    fn = new CompiledFunction((inputs) => {
      const xx = inputs[0]!;                    // tanh(x / softcap) * softcap
      const capArr = ops.scalarLike(cap, xx);
      const scaled = ops.div(xx, capArr);
      const t = ops.tanh(scaled); scaled.dispose();
      const out = ops.mul(t, capArr); t.dispose(); capArr.dispose();
      return [out];
    });
    _softcapClosures.set(cap, fn);
  }
  return fn.apply([x])[0]!;
}
