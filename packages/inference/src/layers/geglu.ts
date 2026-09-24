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
import { runtimeFlag } from "../runtime/config";

/** Verbatim port of mlx_lm/models/gemma4_text.py:
 *    `@partial(mx.compile, shapeless=True) def geglu(gate, x): return nn.gelu_approx(gate) * x`
 *  The oracle @mx.compile's this and uses it for EVERY MLP shape (dense MLP
 *  __call__ line 114, and the SwitchGLU GeGLU activation line 149-150). Our
 *  default MLP runs the SAME math UNFUSED (standalone ops.geluApprox + ops.mul),
 *  a different dispatched kernel set + the per-op host tax the MiniCPM5 swiglu
 *  fix measured at ~5%. This closure fuses geluApprox's ~9 element-wise ops + the
 *  final mul into one traced-once/replayed graph, matching the oracle's kernel
 *  set. `geluApprox` is composed op-for-op from the same primitives as the
 *  oracle's nn.gelu_approx (0.5·x·(1+tanh(√(2/π)(x+0.044715·x³)))), so the
 *  compiled graph is the oracle's geglu graph. Autograd-safe (verified: the vjp
 *  through this closure is bit-identical to the plain composition). */
/** True when gemma's geglu activation runs through the compiled closure (matching
 *  the oracle's @mx.compile geglu) instead of the spelled-out ops.geluApprox+ops.mul.
 *  DEFAULT ON: compiled geglu is bit-exact to mlx-lm's @mx.compile geglu (same
 *  libmlx graph → same kernel) AND dispatches one fused kernel set instead of the
 *  ~9-op path. `MLX_BUN_COMPILED_GEGLU=0` (--compiled-activations off) selects the
 *  uncompiled composition — same L1 parity, slower (the A/B opt-out). */
export function compiledGegluActive(): boolean {
  return runtimeFlag("MLX_BUN_COMPILED_GEGLU", true);
}

let _gegluClosure: CompiledFunction | null = null;
export function compiledGeglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_gegluClosure) {
    _gegluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!; // nn.gelu_approx(gate) * x
      const act = ops.geluApprox(g);
      const out = ops.mul(act, u); act.dispose();
      return [out];
    });
  }
  return _gegluClosure.apply([gate, up])[0]!;
}
