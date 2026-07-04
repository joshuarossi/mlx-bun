// FaithfulQwen35 — an EXACT op-for-op copy of mlx-lm's Qwen3.5 decode, wired as
// a SWAPPABLE qwen3_5 backend (a flag in factory.ts selects this instead of the
// stock `Qwen35Model`), so both run through the identical
// generate()/eval/server machinery. Purpose: an A/B reference — prove it
// dispatches exactly the oracle's kernels (in particular the COMPILED swiglu),
// then compare performance vs our default path.
//
// Transcribed from the oracle (`/Users/joshrossi/Code/mlx-lm/.venv`):
//   mlx_lm/models/qwen3_5.py       DecoderLayer / GatedDeltaNet / Qwen3_5TextModel
//   mlx_lm/models/qwen3_next.py    Qwen3NextAttention / Qwen3NextMLP / RMSNormGated
//   mlx_lm/models/activations.py   @partial(mx.compile) swiglu  (Qwen3NextMLP)
//                                  @partial(mx.compile) _precise_swiglu (RMSNormGated)
//
// The ONLY behavioural difference vs `Qwen35Model` is the activation KERNEL: the
// stock path runs the two swiglu activations UNFUSED (standalone ops.silu/
// sigmoid + ops.mul), the oracle wraps BOTH in `@mx.compile`. Every other op —
// projections, q/k norm, partial RoPE, the depthwise conv + its standalone
// `nn.silu` (NOT compiled in the oracle), the gated-delta recurrence, the
// output gate `output * sigmoid(gate)` (NOT compiled in the oracle), attention
// SDPA — is left exactly as `Qwen35Model` already runs it: we REUSE the same
// layer objects and their `forward`, only flipping `useCompiledActivation` on
// the MLP + linear-attn so the two swiglu sites use the compiled closures.
//
// Falls back to the stock monolith for anything outside the oracle's plain
// bf16-KV / static-offset envelope (quantized KV = the mlx-optiq L2 mode;
// batched per-row RoPE offsets), so it never crashes.
//
// TRAINING: `Qwen35Model` has no `runLayerRange`; training-time forward reaches
// the model through `forwardHidden -> forwardLayers` (src/train/forward.ts::
// trainForward calls model.forwardHidden). Because we override `forwardLayers`
// here, a training forward on the faithful backend runs THIS block — plain
// KVCache/SSMCache, no offArr → inside the envelope — so the compiled swiglu is
// on the training path too. The compiled closures are autograd-safe (mx.compile
// threads the VJP through the traced graph; verified maxDiff==0 vs the plain
// composition in the scratchpad grad harness), so no separate training override
// is needed.

import { MlxArray } from "../mlx/array";
import { disposing, QuantizedKVCache, type Cache } from "./gemma4-base";
import { Qwen35Model } from "./qwen3_5";

/** Forwards served by the faithful (compiled-activation) path vs the monolith
 *  fallback — asserted by the parity test so the exact-copy path is proven to
 *  have actually run. */
export let faithfulForwardUses = 0;

export class FaithfulQwen35 extends Qwen35Model {
  /** mlx-lm's plain-qwen3.5 envelope: plain bf16 KV on the full-attention
   *  layers, static scalar RoPE offset, single-sequence (no batched left-pad).
   *  Quantized KV is the mlx-optiq L2 mode, not this plain-bf16 oracle; a
   *  batched decode carries per-row RoPE offsets — both fall back. */
  #envelopeOk(cache: Cache[]): boolean {
    for (const c of cache) {
      if (c instanceof QuantizedKVCache) return false; // mlx-optiq quant-KV mode
      // Batched left-pad decode exposes each row's real position as an array.
      if ((c as { ropeOffsetArr?: MlxArray }).ropeOffsetArr != null) return false;
      // Full-attention layers must be plain bf16 KVCache; linear layers are
      // SSMCache (no KV, no quant/offset knobs) — leave those alone.
    }
    return true;
  }

  protected override forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    if (!this.#envelopeOk(cache)) return super.forwardLayers(h0, cache);
    faithfulForwardUses++;
    // Flip the two swiglu sites to the oracle's compiled kernels for the
    // duration of this forward, then restore — so the base model and the
    // fallback path stay byte-identical to the stock (unfused) behaviour.
    for (const l of this.layers) {
      l.mlp.useCompiledActivation = true;
      if (l.linearAttn) l.linearAttn.useCompiledActivation = true;
    }
    try {
      const L = h0.shape[1]!;
      // Same mask/loop structure as Qwen35Model.forwardLayers: one full-attention
      // mask shared by all full layers (same offset); linear layers see no ssm
      // mask at B=1. Only the activation kernel differs.
      const faMask = cache[this.faIdx]!.makeMask(L, null);
      let h = h0;
      for (let i = 0; i < this.layers.length; i++) {
        const next = this.layers[i]!.forward(h, faMask, cache[i]!);
        h.dispose();
        h = next;
      }
      faMask.arr?.dispose();
      return disposing(h, this.finalNorm.forward(h));
    } finally {
      for (const l of this.layers) {
        l.mlp.useCompiledActivation = false;
        if (l.linearAttn) l.linearAttn.useCompiledActivation = false;
      }
    }
  }
}
