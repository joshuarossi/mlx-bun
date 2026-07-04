// FaithfulUniversalDense — the swiglu/fused_swiglu activation as mlx-lm's
// exact `@mx.compile` kernel, wired as a swappable universal-dense backend
// (MLX_BUN_UNIVERSAL_FAITHFUL=1, factory.ts). Purpose: an A/B reference that
// dispatches EXACTLY mlx-lm's kernel set (one fused sigmoid·mul·mul instead of
// our three standalone ops), so we can prove kernel-set identity and measure.
//
// The bug this fixes (dense.ts UniversalMLP.forward): the swiglu path ran the
// UNCOMPILED composition `sigmoid(gate) → mul → mul`, three separate dispatches,
// where every swiglu oracle compiles it:
//   mlx_lm/models/activations.py  @partial(mx.compile, shapeless=True)
//                                 def swiglu(gate, x): return nn.silu(gate) * x
//   mlx_lm/models/llama.py (+qwen2, minicpm, phi3 gate_up split): MLP calls it.
// gemma/gemma2/starcoder2 (geglu / geglu_approx / gelu_mlp) do NOT @mx.compile
// their nn.gelu composition, so those kinds are already faithful and untouched.
//
// Only the activation changes — every other op (attention, norms, per-arch
// block wiring, masks, softcap) is UniversalDenseModel's already-op-for-op
// forward, reused verbatim via super.forwardLayers. We inject the compiled
// swiglu by flipping each MLP's `swigluFn` for the duration of a forward.
//
// This override is the SINGLE forward for both decode AND training: universal
// -dense has no separate runLayerRange — src/train/forward.ts drives training
// through model.forwardHidden → forwardLayers (this method). The compiled
// swiglu is autograd-safe (grad bit-identical to the plain composition; see
// scratchpad/dense_faithful_grad_test.ts), so training gets the fused kernel
// too. TrainingCache is inside the envelope for exactly this reason.
//
// Falls back to the uncompiled composition (super's default swigluFn=null) for
// anything outside mlx-lm's plain envelope — quantized KV, batched per-row RoPE
// offsets — so it never changes dispatch where other fused paths interact.

import { MlxArray } from "../../mlx/array";
import { QuantizedKVCache, type Cache } from "../gemma4-base";
import { compiledSwiglu } from "../minicpm5";
import { UniversalDenseModel } from "./dense";

/** Forwards served by the faithful (compiled-swiglu) path vs the uncompiled
 *  fallback — asserted by the parity test so the exact-copy path is proven
 *  to have actually run. */
export let faithfulForwardUses = 0;

export class FaithfulUniversalDense extends UniversalDenseModel {
  /** mlx-lm's plain envelope: plain (non-quantized) KV, static-offset RoPE.
   *  Training (TrainingCache) and sliding-window (RotatingKVCache) qualify —
   *  they run the same plain-envelope MLP; quant-KV and batched left-pad
   *  decode (ropeOffsetArr) do not. */
  #envelopeOk(cache: Cache[]): boolean {
    for (const c of cache) {
      if (c instanceof QuantizedKVCache) return false; // quant-KV: outside plain envelope
      if ((c as { ropeOffsetArr?: MlxArray }).ropeOffsetArr != null) return false; // batched left-pad decode
    }
    return true;
  }

  protected override forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    if (!this.#envelopeOk(cache)) return super.forwardLayers(h0, cache);
    faithfulForwardUses++;
    // Inject the @mx.compile swiglu into every swiglu/fused_swiglu MLP for
    // this forward; UniversalMLP.forward ignores it for geglu/gelu kinds.
    for (const layer of this.layers) layer.mlp.swigluFn = compiledSwiglu;
    try {
      return super.forwardLayers(h0, cache); // the op-for-op per-arch forward, verbatim
    } finally {
      for (const layer of this.layers) layer.mlp.swigluFn = null;
    }
  }
}
