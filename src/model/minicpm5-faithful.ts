// FaithfulMiniCPM5 — an EXACT op-for-op copy of mlx-lm's MiniCPM5 decode,
// wired as a SWAPPABLE cpm5 backend: `MLX_BUN_CPM5_FAITHFUL=1` (factory.ts)
// selects this instead of the optimized `MiniCPM5Model`, so both run through
// the identical generate()/eval/server machinery. Purpose: an A/B reference —
// prove it dispatches exactly mlx-lm's kernels, THEN compare performance vs our
// optimized path, THEN decide what to optimize.
//
// Transcribed verbatim from the oracle (`/Users/joshrossi/Code/mlx-lm/.venv`):
//   mlx_lm/models/llama.py       Attention / MLP / TransformerBlock / LlamaModel
//   mlx_lm/models/activations.py @partial(mx.compile) swiglu (used for EVERY shape)
// Only `forwardLayers` is overridden — weight loading, `lm_head`, and sampling
// (the per-token `logits - logsumexp`, in generate.ts::sampleStep) are the shared
// MiniCPM5Model + generate() path, which already match `generate_step`. No flags,
// no branches, no fusion beyond mlx-lm's own `@mx.compile` swiglu. Falls back to
// the monolith for anything outside mlx-lm's plain-llama envelope (quantized KV,
// training-flash, prefix-shared RoPE, batched per-row offsets) so it never crashes.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { disposing, KVCache, type Cache, type Mask } from "./gemma4-base";
import { getTrainingAttn } from "./flash-attention";
import {
  compiledSwiglu,
  type LlamaAttention,
  type LlamaLayer,
  type LlamaMLP,
  MiniCPM5Model,
  miniCpmPrefixPlanActive,
} from "./minicpm5";

// llama.py Attention.__call__ — verbatim
function attention(a: LlamaAttention, x: MlxArray, mask: Mask, cache: KVCache): MlxArray {
  const [B, L] = x.shape as [number, number, number];
  let q = a.qProj.forward(x);                                          // self.q_proj(x)
  let k = a.kProj.forward(x);                                          // self.k_proj(x)
  let v = a.vProj.forward(x);                                          // self.v_proj(x)
  q = disposing(q, ops.reshape(q, [B, L, a.nHeads, a.headDim]));       // .reshape(B,L,n_heads,-1)
  q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));                //   .transpose(0,2,1,3)
  k = disposing(k, ops.reshape(k, [B, L, a.nKvHeads, a.headDim]));
  k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
  v = disposing(v, ops.reshape(v, [B, L, a.nKvHeads, a.headDim]));
  v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));
  q = disposing(q, ops.rope(q, a.headDim, a.ropeBase, cache.offset, null)); // self.rope(q, offset=cache.offset)
  k = disposing(k, ops.rope(k, a.headDim, a.ropeBase, cache.offset, null)); // self.rope(k, offset=cache.offset)
  const [keys, values] = cache.updateAndFetch(k, v);                  // cache.update_and_fetch(k, v)
  k.dispose(); v.dispose();
  let out = ops.sdpa(q, keys, values, a.scale, mask.mode, mask.arr);  // scaled_dot_product_attention
  q.dispose(); keys.dispose(); values.dispose();
  out = disposing(out, ops.transposeAxes(out, [0, 2, 1, 3]));         // output.transpose(0,2,1,3)
  out = disposing(out, ops.reshape(out, [B, L, -1]));                 //   .reshape(B, L, -1)
  const y = a.oProj.forward(out); out.dispose();                     // self.o_proj(output)
  return y;
}

// llama.py MLP.__call__: down_proj(swiglu(gate_proj(x), up_proj(x)))
function mlp(m: LlamaMLP, x: MlxArray): MlxArray {
  const g = m.gate.forward(x);
  const u = m.up.forward(x);
  const s = compiledSwiglu(g, u); g.dispose(); u.dispose(); // activations.py swiglu (mx.compile, all shapes)
  const y = m.down.forward(s); s.dispose();
  return y;
}

// llama.py TransformerBlock.__call__
function block(layer: LlamaLayer, x: MlxArray, mask: Mask, cache: KVCache): MlxArray {
  const xn = layer.inputNorm.forward(x);              // self.input_layernorm(x)
  const r1 = attention(layer.attn, xn, mask, cache); xn.dispose();
  const h = ops.add(x, r1); r1.dispose();             // h = x + r
  const hn = layer.postAttnNorm.forward(h);           // self.post_attention_layernorm(h)
  const r2 = mlp(layer.mlp, hn); hn.dispose();
  const out = ops.add(h, r2); h.dispose(); r2.dispose(); // out = h + r
  return out;
}

/** Forwards served by the faithful path (vs monolith fallback) — asserted by the
 *  parity test so the exact-copy path is proven to have actually run. */
export let faithfulForwardUses = 0;

export class FaithfulMiniCPM5 extends MiniCPM5Model {
  /** mlx-lm's plain-llama envelope: plain bf16 KV, static-offset RoPE, inference. */
  #envelopeOk(cache: Cache[]): boolean {
    if (miniCpmPrefixPlanActive() || getTrainingAttn() === "flash") return false;
    for (const c of cache) {
      if (!(c instanceof KVCache)) return false; // excludes QuantizedKVCache
      if (c.ropeOffsetArr != null) return false; // batched left-pad decode
    }
    return true;
  }

  protected override forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    if (!this.#envelopeOk(cache)) return super.forwardLayers(h0, cache);
    faithfulForwardUses++;
    const L = h0.shape[1]!;
    const mask = cache[0]!.makeMask(L, null); // create_attention_mask
    let h = h0;
    for (let i = 0; i < this.layers.length; i++) {
      const nh = block(this.layers[i]!, h, mask, cache[i] as KVCache);
      h.dispose(); // forwardLayers owns h0 and every interior
      h = nh;
    }
    mask.arr?.dispose();
    return disposing(h, this.finalNorm.forward(h)); // self.norm(h)
  }
}
