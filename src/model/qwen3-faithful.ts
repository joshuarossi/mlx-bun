// FaithfulQwen3 — an EXACT op-for-op copy of mlx-lm's dense Qwen3 decode,
// wired as a SWAPPABLE qwen3 backend (factory.ts selects it behind a flag),
// so both run through the identical generate()/eval/server machinery. Purpose:
// an A/B reference — prove it dispatches exactly mlx-lm's kernels, THEN compare
// performance vs our optimized path, THEN decide what to optimize.
//
// Transcribed verbatim from the oracle (`/Users/joshrossi/Code/mlx-lm/.venv`):
//   mlx_lm/models/qwen3.py       Attention / MLP / TransformerBlock / Qwen3Model
//   mlx_lm/models/activations.py @partial(mx.compile) swiglu (used for EVERY shape)
// The ONLY deviation from our existing Qwen3Model.forwardLayers is the MLP
// activation: mlx-lm runs `swiglu(gate, up)` — a single `@mx.compile`'d closure
// (`nn.silu(gate) * x`) — whereas our Qwen3MLP.forward dispatches sigmoid + mul +
// mul as three separate kernels. Here we call `compiledSwiglu`, the exact same
// mx.compile closure the FaithfulMiniCPM5 path uses, so the fused kernel set
// matches the oracle op-for-op.
//
// Only `forwardLayers` is overridden — weight loading, `lm_head`/tied head, and
// sampling are the shared Qwen3Model + generate() path, which already match
// generate_step. No flags, no branches, no fusion beyond mlx-lm's own @mx.compile
// swiglu. Falls back to the monolith for anything outside mlx-lm's plain-qwen3
// envelope (quantized KV, training-flash, batched per-row offsets) so it never
// crashes.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { disposing, KVCache, type Cache, type Mask } from "./gemma4-base";
import { getTrainingAttn } from "./flash-attention";
import { compiledSwiglu } from "./minicpm5";
import { Qwen3Model, type Qwen3Attention, type Qwen3Layer, type Qwen3MLP } from "./qwen3";

// qwen3.py Attention.__call__ — verbatim (q/k RMSNorm over head_dim BEFORE
// transpose+RoPE, full-head RoPE, GQA sdpa).
function attention(a: Qwen3Attention, x: MlxArray, mask: Mask, cache: KVCache): MlxArray {
  const [B, L] = x.shape as [number, number, number];
  let q = a.qProj.forward(x);                                          // self.q_proj(x)
  let k = a.kProj.forward(x);                                          // self.k_proj(x)
  let v = a.vProj.forward(x);                                          // self.v_proj(x)
  // queries = self.q_norm(queries.reshape(B, L, n_heads, -1)).transpose(0,2,1,3)
  q = disposing(q, ops.reshape(q, [B, L, a.nHeads, a.headDim]));
  k = disposing(k, ops.reshape(k, [B, L, a.nKvHeads, a.headDim]));
  v = disposing(v, ops.reshape(v, [B, L, a.nKvHeads, a.headDim]));
  q = disposing(q, a.qNorm.forward(q));                               // self.q_norm(...)
  k = disposing(k, a.kNorm.forward(k));                               // self.k_norm(...)
  q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));               //   .transpose(0,2,1,3)
  k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
  v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));               // values...transpose(0,2,1,3)
  q = disposing(q, ops.rope(q, a.headDim, a.ropeBase, cache.offset, null)); // self.rope(q, offset=cache.offset)
  k = disposing(k, ops.rope(k, a.headDim, a.ropeBase, cache.offset, null)); // self.rope(k, offset=cache.offset)
  const [keys, values] = cache.updateAndFetch(k, v);                  // cache.update_and_fetch(keys, values)
  k.dispose(); v.dispose();
  let out = ops.sdpa(q, keys, values, a.scale, mask.mode, mask.arr);  // scaled_dot_product_attention
  q.dispose(); keys.dispose(); values.dispose();
  out = disposing(out, ops.transposeAxes(out, [0, 2, 1, 3]));         // output.transpose(0,2,1,3)
  out = disposing(out, ops.reshape(out, [B, L, -1]));                 //   .reshape(B, L, -1)
  const y = a.oProj.forward(out); out.dispose();                     // self.o_proj(output)
  return y;
}

// qwen3.py MLP.__call__: down_proj(swiglu(gate_proj(x), up_proj(x)))
function mlp(m: Qwen3MLP, x: MlxArray): MlxArray {
  const g = m.gate.forward(x);
  const u = m.up.forward(x);
  const s = compiledSwiglu(g, u); g.dispose(); u.dispose(); // activations.py swiglu (mx.compile, all shapes)
  const y = m.down.forward(s); s.dispose();
  return y;
}

// qwen3.py TransformerBlock.__call__
function block(layer: Qwen3Layer, x: MlxArray, mask: Mask, cache: KVCache): MlxArray {
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

export class FaithfulQwen3 extends Qwen3Model {
  /** mlx-lm's plain-qwen3 envelope: plain bf16 KV, static-offset RoPE, inference.
   *  Qwen3Model never sets a prefix plan or batched per-row offsets, so the only
   *  exits are quantized KV (QuantizedKVCache), training-flash, or a future
   *  batched-decode cache carrying ropeOffsetArr. */
  #envelopeOk(cache: Cache[]): boolean {
    if (getTrainingAttn() === "flash") return false;
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
