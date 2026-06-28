// Concrete model graph for plain Qwen3 (Qwen3ForCausalLM).
// Port target: mlx_lm.models.qwen3. A standard dense decoder — GQA softmax
// attention with per-head q/k RMSNorm (applied over head_dim BEFORE RoPE),
// full-head RoPE (theta 1e6), SwiGLU MLP, RMSNorm, tied embeddings.
//
// Primary use here is as a TEXT-EMBEDDING backbone (mlx-community Qwen3-Embedding-*):
// `embedPooled` returns the last-token hidden, L2-normalized — the pooling
// Qwen3-Embedding was trained with (an <|endoftext|> token is appended by the
// caller; its hidden is the sentence vector). The full causal-LM surface
// (forward/generate via the tied head) is wired too so it conforms to RuntimeModel.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import {
  argmaxLastPosition,
  disposing,
  KVCache,
  LoraState,
  QuantizedEmbedding,
  QuantizedLinear,
  RMSNorm,
  type Cache,
  type Mask,
} from "./gemma4-base";

class Qwen3Attention {
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
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 1000000;
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    let q = this.qProj.forward(x);
    let k = this.kProj.forward(x);
    let v = this.vProj.forward(x);

    // Reshape to heads, then q/k RMSNorm over head_dim BEFORE transpose+RoPE
    // (mlx-lm qwen3 reference order).
    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    q = disposing(q, this.qNorm.forward(q));
    k = disposing(k, this.kNorm.forward(k));

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    q = disposing(q, ops.rope(q, this.headDim, this.ropeBase, cache.offset, null));
    k = disposing(k, ops.rope(k, this.headDim, this.ropeBase, cache.offset, null));

    const [keys, values] = cache.updateAndFetch(k, v);
    k.dispose();
    v.dispose();
    const attn = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
    keys.dispose();
    values.dispose();
    q.dispose();

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.oProj.forward(merged);
    merged.dispose();
    return out;
  }
}

class Qwen3MLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray): MlxArray {
    const gate = this.gate.forward(x);
    const up = this.up.forward(x);
    const sig = ops.sigmoid(gate);
    const silu = ops.mul(gate, sig);
    gate.dispose();
    sig.dispose();
    const hidden = ops.mul(silu, up);
    silu.dispose();
    up.dispose();
    const out = this.down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

class Qwen3Layer {
  readonly attn: Qwen3Attention;
  readonly mlp: Qwen3MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.attn = new Qwen3Attention(weights, config, `${prefix}.self_attn`);
    this.mlp = new Qwen3MLP(weights, config, `${prefix}.mlp`);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const xn = this.inputNorm.forward(x);
    const a = this.attn.forward(xn, mask, cache);
    xn.dispose();
    const h = ops.add(x, a);
    a.dispose();
    const hn = this.postAttnNorm.forward(h);
    const m = this.mlp.forward(hn);
    hn.dispose();
    const out = ops.add(h, m);
    h.dispose();
    m.dispose();
    return out;
  }
}

export class Qwen3Model {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3Layer[];
  readonly finalNorm: RMSNorm;
  /** Separate lm_head when NOT tied; otherwise the tied embedding's asLinear. */
  readonly lmHead: QuantizedLinear | null;

  constructor(weights: Weights, config: ModelConfig) {
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.embed_tokens", config);
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3Layer(weights, config, `model.layers.${i}`),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.norm.weight"), config.text.rmsNormEps);
    this.lmHead = config.text.tieWordEmbeddings
      ? null
      : QuantizedLinear.load(weights, "lm_head", config);
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `model.layers.${i}`;
      out.set(`${p}.self_attn.q_proj`, l.attn.qProj);
      out.set(`${p}.self_attn.k_proj`, l.attn.kProj);
      out.set(`${p}.self_attn.v_proj`, l.attn.vProj);
      out.set(`${p}.self_attn.o_proj`, l.attn.oProj);
      out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
      out.set(`${p}.mlp.up_proj`, l.mlp.up);
      out.set(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  makeCache(): Cache[] {
    return this.layers.map(() => new KVCache());
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const h = this.embed.encode(ids);
    return this.forwardLayers(h, cache);
  }

  forwardEmbeddings(_embeds: MlxArray, _cache: Cache[], _bidir: MlxArray | null): MlxArray {
    throw new Error("qwen3 input-embedding path is not supported");
  }

  protected forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    const L = h0.shape[1]!;
    const mask = cache[0]!.makeMask(L, null);
    let cur = h0;
    for (let i = 0; i < this.layers.length; i++) {
      const next = this.layers[i]!.forward(cur, mask, cache[i]!);
      cur.dispose();
      cur = next;
    }
    mask.arr?.dispose();
    return disposing(cur, this.finalNorm.forward(cur));
  }

  /** Last-token pooled, L2-normalized sentence embedding for one sequence.
   *  ids [1, L] → vector [1, hidden]. The caller appends the EOS/eod token
   *  (Qwen3-Embedding's pooling token) to `ids`. */
  embedPooled(ids: MlxArray): MlxArray {
    const cache = this.makeCache();
    try {
      const h = this.forwardHidden(ids, cache); // [1, L, hidden]
      const [B, L, H] = h.shape as [number, number, number];
      const last = h.slice([0, L - 1, 0], [B, L, H]); // [1, 1, hidden]
      h.dispose();
      const vec = disposing(last, ops.reshape(last, [B, H])); // [1, hidden]
      // L2 normalize: x / max(||x||_2, eps)
      const sq = ops.square(vec);
      const ss = disposing(sq, ops.sumAxis(sq, -1, true));
      const norm = disposing(ss, ops.sqrt(ss));
      const out = ops.div(vec, norm);
      vec.dispose();
      norm.dispose();
      return out;
    } finally {
      for (const c of cache) c.dispose();
    }
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.lmHead ? this.lmHead.forward(h) : this.embed.asLinear(h);
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
