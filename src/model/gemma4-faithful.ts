// FaithfulGemma4 — the AUDIT/SCOPED faithful variant of the gemma4 decode.
//
// The bug (shared across models): our MLP runs the geglu activation UNFUSED
// (standalone `ops.geluApprox(gate)` + `ops.mul(act, up)`), while the oracle
// COMPILES it in one line —
//   `@partial(mx.compile, shapeless=True) def geglu(gate, x): return nn.gelu_approx(gate) * x`
// (mlx_lm/models/gemma4_text.py). Unfused = a DIFFERENT dispatched kernel set +
// the per-op host tax (the MiniCPM5 swiglu twin of this measured ~5%).
//
// Oracle audit (mlx_lm/models/gemma4_text.py + switch_layers.py, oracle venv):
//   1. dense MLP.__call__ (line 114):  down_proj(geglu(gate_proj(x), up_proj(x)))
//                                        → geglu is @mx.compile'd. COMPILED.
//   2. SwitchGLU GeGLU activation (lines 149-150, activation=GeGLU()):
//                                        self.activation(x_up, x_gate) == geglu(...)
//                                        → the SAME @mx.compile'd geglu. COMPILED.
//   3. per-layer input gate (line 380): `gate = nn.gelu_approx(gate)` then
//                                        `mx.multiply(gate, per_layer_input)` —
//                                        STANDALONE, NOT the compiled geglu. Our
//                                        gemma4.ts DecoderLayer.forwardMlp already
//                                        spells this out unfused → ALREADY MATCHES.
//
// So the only kernel-set divergence on gemma4 is sites (1) and (2): our default
// path runs them UNFUSED. The fix is `compiledGeglu` (gemma4.ts, mirrors
// minicpm5.ts::compiledSwiglu) — the oracle's geglu graph, traced once/replayed.
//
// This class is the swappable A/B backend (like FaithfulMiniCPM5): it toggles the
// module-level faithful-geglu flag around the SHARED forward so BOTH the decode
// path (forwardLayers → DecoderLayer.forward → MLP.forward) AND the training path
// (runLayerRange → DecoderLayer.forward → MLP.forward) route the geglu through the
// compiled closure. Because it only flips an activation flag and delegates the
// rest to the (already line-for-line-oracle) Gemma4Model forward, it needs no
// re-transcription of attention / KV-sharing / per-layer-inputs / masks. It falls
// back to the plain-envelope-only faithful mode: outside that envelope (quantized
// KV, training-flash, compiled-trace) it delegates untouched to super.
//
// SCOPE (honest): a FULL op-for-op re-port of the whole gemma4 forward (the way
// FaithfulMiniCPM5 re-transcribes llama.py) is out of scope for one pass — gemma4
// is the most complex model (MoE, per-layer inputs, KV-sharing, vision, generated
// specializations). This variant proves + fixes the ONE activation-fusion
// kernel-set divergence, which is the bug class in the brief. See the status
// notes for what a full re-port would additionally cover.

import { MlxArray } from "../mlx/array";
import { getTrainingAttn } from "./flash-attention";
import {
  type Cache,
  Gemma4Model,
  isCompiledTrace,
  KVCache,
  type Mask,
  RotatingKVCache,
  setFaithfulGeglu,
  type SharedKv,
} from "./gemma4";

/** Forwards served by the faithful (compiled-geglu) path vs the plain fallback —
 *  asserted by the parity test so the fused path is proven to have actually run. */
export let faithfulGemma4ForwardUses = 0;

export class FaithfulGemma4 extends Gemma4Model {
  /** The oracle's plain envelope: bf16 KV (full or sliding/rotating), static
   *  RoPE offset, inference (not compiled-trace, not training-flash). Quantized
   *  KV caches, per-row batched offsets, and the compiled-decode trace run their
   *  own dispatch and are left to super untouched. */
  #envelopeOk(cache: Cache[]): boolean {
    if (isCompiledTrace() || getTrainingAttn() === "flash") return false;
    for (const c of cache) {
      // plain bf16 caches only (excludes QuantizedKVCache / RotatingQuantizedKVCache)
      if (!(c instanceof KVCache) && !(c instanceof RotatingKVCache)) return false;
      if (c.ropeOffsetArr != null) return false; // batched left-pad decode
    }
    return true;
  }

  protected override forwardLayers(
    h0: MlxArray, cache: Cache[], bidir: MlxArray | null, ids: MlxArray | null,
  ): MlxArray {
    if (!this.#envelopeOk(cache)) return super.forwardLayers(h0, cache, bidir, ids);
    faithfulGemma4ForwardUses++;
    setFaithfulGeglu(true);
    try {
      // Identical machinery to Gemma4Model.forwardLayers (attention, KV-sharing,
      // per-layer inputs, masks, the unfused per-layer gate) — only the MLP /
      // SwitchGLU geglu activation is now the compiled oracle graph.
      return super.forwardLayers(h0, cache, bidir, ids);
    } finally {
      setFaithfulGeglu(false);
    }
  }

  /** TRAINING coverage: segmented backward drives runLayerRange directly
   *  (bypassing forwardLayers). Flip the flag around it so the per-segment
   *  graph is built with the compiled geglu; autograd then differentiates the
   *  compiled-geglu node (vjp verified bit-identical to the plain composition).
   *  The graph is CONSTRUCTED here synchronously; the segment is NOT gradient-
   *  checkpointed (Gemma4Model.runLayerRange docstring), so no recompute closure
   *  re-enters MLP.forward outside this window. Non-segmented training goes
   *  through forwardHidden → forwardLayers (covered above). */
  override runLayerRange(
    h: MlxArray, aIdx: number, bIdx: number, cache: Cache[],
    masks: Map<string, Mask>, perLayer: MlxArray | null,
    donorKvIn: Map<number, SharedKv>,
  ): { h: MlxArray; donorKvOut: Map<number, SharedKv> } {
    // No envelope guard: training uses plain bf16 caches (flash is the only
    // divergent training mode and it does not touch the MLP geglu). Keep it
    // simple and always-faithful on the training range.
    setFaithfulGeglu(true);
    try {
      return super.runLayerRange(h, aIdx, bIdx, cache, masks, perLayer, donorKvIn);
    } finally {
      setFaithfulGeglu(false);
    }
  }
}
