// Concrete model graph for Qwen3-MoE (model_type `qwen3_moe`,
// Qwen3MoeForCausalLM). A STRAIGHT op-for-op transcription of the oracle
// (`/Users/joshrossi/Code/mlx-lm/.venv/.../mlx_lm/models/qwen3_moe.py` +
// switch_layers.py SwitchGLU + activations.py swiglu). Each op below carries
// the exact oracle line it copies — no abstraction, no reorder, no
// "optimization". The ONLY intentional deviation from a naive transcription is
// that the expert swiglu is mx.compile-COMPILED (like the oracle's
// activations.py `@partial(mx.compile) def swiglu`), matching both the greedy
// token stream AND the dispatched Metal kernel set.
//
// Attention is identical to plain qwen3 (per-head q/k RMSNorm over head_dim
// before RoPE, full-head RoPE, GQA, SDPA). The MoE block is
// Qwen3MoeSparseMoeBlock: gate Linear -> precise softmax over ALL experts ->
// argpartition top-k -> take_along_axis -> renormalize (norm_topk_prob) ->
// SwitchGLU(swiglu) experts -> weighted sum. Per decoder_sparse_step /
// mlp_only_layers a layer may instead be a dense MLP (MLP class); both are
// handled faithfully. Weights are untied (separate lm_head). Config: 48 layers,
// hidden 2048, 128 experts, top-8, moe_intermediate 768, rope_theta 1e7.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { CompiledFunction } from "../mlx/compile";
import {
  argmaxLastPosition,
  disposing,
  isCompiledTrace,
  KVCache,
  LoraState,
  QuantizedEmbedding,
  QuantizedLinear,
  QuantizedSwitchLinear,
  RMSNorm,
  type Cache,
  type Mask,
} from "./gemma4-base";

// ── activations.py swiglu (mx.compile) ───────────────────────────────────────
// `@partial(mx.compile, shapeless=True) def swiglu(gate, x): return nn.silu(gate) * x`
// nn.silu(g) == g * sigmoid(g); mx.compile fuses sigmoid + mul + mul into ONE
// kernel. Traced once (shapeless), replayed thereafter. Autograd-safe (mx.compile
// threads the VJP through the traced graph). Exported so the parity test can
// assert the closure exists and the expert path actually uses it.
let _swigluClosure: CompiledFunction | null = null;
export function compiledSwiglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_swigluClosure) {
    _swigluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!;              // nn.silu(gate) * x
      const sig = ops.sigmoid(g);
      const silu = ops.mul(g, sig); sig.dispose();
      const out = ops.mul(silu, u); silu.dispose();
      return [out];
    });
  }
  return _swigluClosure.apply([gate, up])[0]!;
}

// ── qwen3_moe.py Attention (== plain qwen3) ──────────────────────────────────
class Attention {
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;                                  // self.n_heads
    this.nKvHeads = t.numKeyValueHeads;                                 // self.n_kv_heads
    this.headDim = t.headDim;                                           // head_dim
    this.scale = Math.pow(this.headDim, -0.5);                          // self.scale = head_dim**-0.5
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000000; // args.rope_theta
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config); // nn.Linear(dim, n_heads*head_dim, bias=False)
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps); // nn.RMSNorm(head_dim)
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const [B, L] = x.shape as [number, number, number];                // B, L, D = x.shape
    let q = this.qProj.forward(x);                                     // queries = self.q_proj(x)
    let k = this.kProj.forward(x);                                     // keys = self.k_proj(x)
    let v = this.vProj.forward(x);                                     // values = self.v_proj(x)
    // queries = self.q_norm(queries.reshape(B,L,n_heads,-1)).transpose(0,2,1,3)
    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    q = disposing(q, this.qNorm.forward(q));                           // self.q_norm(...)
    k = disposing(k, this.kNorm.forward(k));                           // self.k_norm(...)
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));              //   .transpose(0,2,1,3)
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));              // values.reshape(...).transpose(0,2,1,3)
    q = disposing(q, ops.rope(q, this.headDim, this.ropeBase, cache.offset, null)); // self.rope(queries, offset=cache.offset)
    k = disposing(k, ops.rope(k, this.headDim, this.ropeBase, cache.offset, null)); // self.rope(keys, offset=cache.offset)
    const [keys, values] = cache.updateAndFetch(k, v);                 // cache.update_and_fetch(keys, values)
    k.dispose(); v.dispose();
    let out = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr); // scaled_dot_product_attention(...)
    q.dispose(); keys.dispose(); values.dispose();
    out = disposing(out, ops.transposeAxes(out, [0, 2, 1, 3]));        // output.transpose(0,2,1,3)
    out = disposing(out, ops.reshape(out, [B, L, -1]));                //   .reshape(B, L, -1)
    const y = this.oProj.forward(out); out.dispose();                 // self.o_proj(output)
    return y;
  }
}

// ── qwen3_moe.py MLP (dense-layer FFN) ───────────────────────────────────────
// def __call__(self, x): return self.down_proj(swiglu(self.gate_proj(x), self.up_proj(x)))
class MLP {
  readonly gateProj: QuantizedLinear;
  readonly upProj: QuantizedLinear;
  readonly downProj: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gateProj = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config); // nn.Linear(dim, hidden_dim, bias=False)
    this.upProj = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.downProj = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray): MlxArray {
    const g = this.gateProj.forward(x);                                // self.gate_proj(x)
    const u = this.upProj.forward(x);                                  // self.up_proj(x)
    const s = compiledSwiglu(g, u);                                    // swiglu(gate, x)  (mx.compile)
    g.dispose(); u.dispose();
    const y = this.downProj.forward(s); s.dispose();                  // self.down_proj(...)
    return y;
  }
}

// ── switch_layers.py SwitchGLU (swiglu activation, quantized experts) ─────────
// The three per-expert projections are the stacked switch_mlp.{gate,up,down}_proj
// tensors; the activation is the SAME @mx.compile swiglu as activations.py.
class SwitchGLU {
  readonly gateProj: QuantizedSwitchLinear;
  readonly upProj: QuantizedSwitchLinear;
  readonly downProj: QuantizedSwitchLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gateProj = QuantizedSwitchLinear.load(weights, `${prefix}.gate_proj`, config);
    this.upProj = QuantizedSwitchLinear.load(weights, `${prefix}.up_proj`, config);
    this.downProj = QuantizedSwitchLinear.load(weights, `${prefix}.down_proj`, config);
  }

  /** x [B, L, H], indices [B, L, k] → [B, L, k, H]. */
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    // x = mx.expand_dims(x, (-2, -3))  → [B, L, 1, 1, H]
    let h = ops.expandDims(x, -2);
    h = disposing(h, ops.expandDims(h, -3));

    // do_sort = indices.size >= 64
    const doSort = indices.size >= 64;
    let idx = indices;
    let invOrder: MlxArray | null = null;
    let order: MlxArray | null = null;
    if (doSort) {
      // _gather_sort(x, indices): flatten indices, argsort → order, argsort(order) →
      // inv_order, gather rows by order // M (M = k = last dim of indices).
      const M = indices.shape[indices.ndim - 1]!;                      // *_, M = indices.shape
      const idxFlat = ops.reshape(indices, [indices.size]);           // indices.flatten()
      order = ops.argsortAxis(idxFlat, 0);                            // order = mx.argsort(indices)
      invOrder = ops.argsortAxis(order, 0);                          // inv_order = mx.argsort(order)
      const mScalar = ops.scalarLike(M, order);
      const rowIdx = ops.floorDivide(order, mScalar);                // order // M
      mScalar.dispose();
      const [, , , , H] = h.shape as number[];
      const flat = ops.reshape(h, [-1, 1, H!]);                      // x.flatten(0, -3)
      h.dispose();
      h = ops.takeAxis(flat, rowIdx, 0);                             // x.flatten(0,-3)[order // M]
      flat.dispose(); rowIdx.dispose();
      idx = ops.takeAxis(idxFlat, order, 0);                         // indices[order]
      idxFlat.dispose();
    }
    // (self.training path — mx.stop_gradient(idx) — is inference-irrelevant here)
    const xUp = this.upProj.forward(h, idx, doSort);                  // x_up = self.up_proj(x, idx, sorted_indices=do_sort)
    const xGate = this.gateProj.forward(h, idx, doSort);             // x_gate = self.gate_proj(x, idx, sorted_indices=do_sort)
    h.dispose();
    // self.activation(x_up, x_gate) == SwiGLU()(x_up, x_gate) == swiglu(x_gate, x_up)
    // (SwiGLU.__call__(self, x, gate) returns swiglu(gate, x); called (x_up, x_gate)).
    const mid = compiledSwiglu(xGate, xUp);                           // swiglu(gate=x_gate, x=x_up)  (mx.compile)
    xGate.dispose(); xUp.dispose();
    let y = this.downProj.forward(mid, idx, doSort);                 // x = self.down_proj(activation, idx, sorted_indices=do_sort)
    mid.dispose();
    if (idx !== indices) idx.dispose();

    if (doSort) {
      // _scatter_unsort(x, inv_order, indices.shape): x[inv_order], unflatten to
      // indices.shape (+ the trailing [1, H] the squeeze(-2) below removes).
      y = disposing(y, ops.takeAxis(y, invOrder!, 0));               // x = x[inv_order]
      invOrder!.dispose(); order!.dispose();
      const [B, L, k] = indices.shape as number[];
      const H = y.shape[y.ndim - 1]!;
      y = disposing(y, ops.reshape(y, [B!, L!, k!, 1, H]));          // mx.unflatten(x, 0, shape)
    }
    // return x.squeeze(-2)
    const shape = y.shape;
    shape.splice(shape.length - 2, 1);
    return disposing(y, ops.reshape(y, shape));
  }
}

// ── qwen3_moe.py Qwen3MoeSparseMoeBlock ──────────────────────────────────────
class Qwen3MoeSparseMoeBlock {
  readonly gate: QuantizedLinear;
  readonly switchMlp: SwitchGLU;
  readonly numExperts: number;
  readonly topK: number;
  readonly normTopkProb: boolean;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.numExperts = t.numExperts;                                   // self.num_experts
    this.topK = t.topKExperts;                                        // self.top_k
    this.normTopkProb = t.normTopkProb;                              // self.norm_topk_prob
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate`, config); // nn.Linear(dim, num_experts, bias=False)
    this.switchMlp = new SwitchGLU(weights, config, `${prefix}.switch_mlp`); // SwitchGLU(dim, moe_inter, num_experts)
  }

  forward(x: MlxArray): MlxArray {
    let gates = this.gate.forward(x);                                 // gates = self.gate(x)
    gates = disposing(gates, ops.softmaxAxis(gates, -1, true));      // gates = mx.softmax(gates, axis=-1, precise=True)

    const k = this.topK;
    const [B, L] = gates.shape as [number, number, number];
    // inds = mx.argpartition(gates, kth=-k, axis=-1)[..., -k:]
    const part = ops.argpartitionAxis(gates, this.numExperts - k, -1); // argpartition(..., kth=-k)
    let inds: MlxArray;
    if (isCompiledTrace()) {
      const start = ops.fromInt32([this.numExperts - k], [1]);
      inds = ops.sliceDynamic(part, start, [2], [B, L, k]);
      start.dispose();
    } else {
      inds = part.slice([0, 0, this.numExperts - k], [B, L, this.numExperts]); // [..., -k:]
    }
    part.dispose();

    let scores = ops.takeAlongAxis(gates, inds, -1);                 // scores = mx.take_along_axis(gates, inds, axis=-1)
    gates.dispose();
    if (this.normTopkProb) {
      const denom = ops.sumAxis(scores, -1, true);                  // mx.sum(scores, axis=-1, keepdims=True)
      scores = disposing(scores, ops.div(scores, denom));           // scores /= ...
      denom.dispose();
    }

    const y = this.switchMlp.forward(x, inds);                       // y = self.switch_mlp(x, inds)
    inds.dispose();
    // y = (y * scores[..., None]).sum(axis=-2)
    const sExp = ops.expandDims(scores, -1);                        // scores[..., None]
    scores.dispose();
    const wy = ops.mul(y, sExp);                                    // y * scores[..., None]
    y.dispose(); sExp.dispose();
    return disposing(wy, ops.sumAxis(wy, -2, false));               // .sum(axis=-2)
  }
}

// ── qwen3_moe.py Qwen3MoeDecoderLayer ────────────────────────────────────────
class Qwen3MoeDecoderLayer {
  readonly selfAttn: Attention;
  readonly mlp: Qwen3MoeSparseMoeBlock | MLP;
  readonly inputLayernorm: RMSNorm;
  readonly postAttentionLayernorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string, layerIdx: number) {
    const t = config.text;
    this.selfAttn = new Attention(weights, config, `${prefix}.self_attn`);
    this.inputLayernorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), t.rmsNormEps);
    this.postAttentionLayernorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), t.rmsNormEps);
    // if (layer_idx not in mlp_only_layers) and (num_experts > 0 and
    //     (layer_idx + 1) % decoder_sparse_step == 0): Qwen3MoeSparseMoeBlock else MLP
    const isMoe =
      !t.mlpOnlyLayers.includes(layerIdx) &&
      t.numExperts > 0 &&
      (layerIdx + 1) % t.decoderSparseStep === 0;
    this.mlp = isMoe
      ? new Qwen3MoeSparseMoeBlock(weights, config, `${prefix}.mlp`)
      : new MLP(weights, config, `${prefix}.mlp`);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const xn = this.inputLayernorm.forward(x);                       // self.input_layernorm(x)
    const r1 = this.selfAttn.forward(xn, mask, cache);              // r = self.self_attn(..., mask, cache)
    xn.dispose();
    const h = ops.add(x, r1); r1.dispose();                        // h = x + r
    const hn = this.postAttentionLayernorm.forward(h);             // self.post_attention_layernorm(h)
    const r2 = this.mlp.forward(hn); hn.dispose();                 // r = self.mlp(...)
    const out = ops.add(h, r2); h.dispose(); r2.dispose();        // out = h + r
    return out;
  }
}

// ── qwen3_moe.py Qwen3MoeModel + Model ───────────────────────────────────────
export class Qwen3MoeModel {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3MoeDecoderLayer[];
  readonly finalNorm: RMSNorm;
  /** Untied lm_head (tie_word_embeddings=false for this family). */
  readonly lmHead: QuantizedLinear | null;

  constructor(weights: Weights, config: ModelConfig) {
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.embed_tokens", config); // nn.Embedding
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3MoeDecoderLayer(weights, config, `model.layers.${i}`, i),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.norm.weight"), config.text.rmsNormEps); // self.norm
    this.lmHead = config.text.tieWordEmbeddings
      ? null
      : QuantizedLinear.load(weights, "lm_head", config);           // self.lm_head
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `model.layers.${i}`;
      out.set(`${p}.self_attn.q_proj`, l.selfAttn.qProj);
      out.set(`${p}.self_attn.k_proj`, l.selfAttn.kProj);
      out.set(`${p}.self_attn.v_proj`, l.selfAttn.vProj);
      out.set(`${p}.self_attn.o_proj`, l.selfAttn.oProj);
      if (l.mlp instanceof MLP) {
        out.set(`${p}.mlp.gate_proj`, l.mlp.gateProj);
        out.set(`${p}.mlp.up_proj`, l.mlp.upProj);
        out.set(`${p}.mlp.down_proj`, l.mlp.downProj);
      }
      // MoE switch_mlp / gate are QuantizedSwitchLinear (stacked experts) — not
      // LoRA targets under our per-linear adapter machinery.
    }
    return out;
  }

  makeCache(): Cache[] {
    return this.layers.map(() => new KVCache());
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const h = this.embed.encode(ids);                               // self.embed_tokens(inputs)
    return this.forwardLayers(h, cache);
  }

  forwardEmbeddings(_embeds: MlxArray, _cache: Cache[], _bidir: MlxArray | null): MlxArray {
    throw new Error("qwen3_moe input-embedding path is not supported");
  }

  protected forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    const L = h0.shape[1]!;
    const mask = cache[0]!.makeMask(L, null);                       // create_attention_mask(h, cache[0])
    let cur = h0;
    for (let i = 0; i < this.layers.length; i++) {                  // for layer, c in zip(self.layers, cache)
      const next = this.layers[i]!.forward(cur, mask, cache[i]!);   // h = layer(h, mask, c)
      cur.dispose();
      cur = next;
    }
    mask.arr?.dispose();
    return disposing(cur, this.finalNorm.forward(cur));            // return self.norm(h)
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.lmHead ? this.lmHead.forward(h) : this.embed.asLinear(h); // self.lm_head(out)
  }

  forward(tokens: number[] | MlxArray, cache: Cache[]): MlxArray {
    const ids = Array.isArray(tokens)
      ? ops.fromInt32(tokens, [1, tokens.length])
      : tokens;
    const h = this.forwardHidden(ids, cache);
    if (Array.isArray(tokens)) ids.dispose();
    const logits = this.logitsFromHidden(h);
    h.dispose();
    return logits;
  }

  generate(promptTokens: number[], maxTokens: number, eosIds: number[] = []): number[] {
    const cache = this.makeCache();
    const out: number[] = [];
    try {
      let tokens = promptTokens;
      for (let step = 0; step < maxTokens; step++) {
        const logits = this.forward(tokens, cache);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        if (eosIds.includes(next)) break;
        out.push(next);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
    return out;
  }
}
