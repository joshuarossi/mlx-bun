// Gemma 4 text model — line-for-line port of mlx-lm's gemma4_text.py
// (oracle venv site-packages), specialized to the paths our target models
// exercise: no MoE block, no per-layer-input embeddings, no KV-shared
// layers (all disabled in the 12B config; guarded with explicit errors).
//
// Parity notes (see PLAN.md Phase 2):
// - SDPA scale is 1.0 (Gemma4 normalizes q/k instead).
// - Full-attention layers: global_head_dim 512, 1 global KV head,
//   attention_k_eq_v (V = same projection as K, with un-scaled RMS norm);
//   ProportionalRoPE rotates only partial_rotary_factor·dims dims (rest
//   get freq=inf → identity).
// - Python-float scalars promote weakly to the array dtype — replicated
//   via ops.scalarLike/mulScalar.
// - Masks: for N==1 mlx-lm passes no mask; otherwise "causal" while
//   N ≤ sliding_window (longer prompts need real window masks — Phase 3).

import type { ModelConfig } from "../config";
import { quantFor } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";

class QuantizedLinear {
  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedLinear {
    if (!weights.has(`${path}.scales`))
      throw new Error(`${path}: expected quantized linear (no .scales tensor)`);
    const spec = quantFor(config.quantization, path);
    if (!spec) throw new Error(`${path}: no quant spec`);
    return new QuantizedLinear(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  forward(x: MlxArray): MlxArray {
    return ops.quantizedMatmul(x, this.w, this.scales, this.biases, this.spec, true);
  }
}

class RMSNorm {
  constructor(readonly weight: MlxArray | null, readonly eps: number) {}
  forward(x: MlxArray): MlxArray {
    return ops.rmsNorm(x, this.weight, this.eps);
  }
}

class QuantizedEmbedding {
  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedEmbedding {
    const spec = quantFor(config.quantization, path)!;
    return new QuantizedEmbedding(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  /** ids [L] → embeddings [1, L, hidden] (QuantizedEmbedding.__call__). */
  encode(ids: number[]): MlxArray {
    const idx = ops.fromInt32(ids, [ids.length]);
    const rows = ops.takeAxis(this.w, idx, 0);
    const scaleRows = ops.takeAxis(this.scales, idx, 0);
    const biasRows = this.biases ? ops.takeAxis(this.biases, idx, 0) : null;
    const deq = ops.dequantize(rows, scaleRows, biasRows, this.spec);
    const out = ops.reshape(deq, [1, ids.length, -1]);
    for (const a of [idx, rows, scaleRows, deq]) a.dispose();
    biasRows?.dispose();
    return out;
  }

  /** Tied output head: h [1, L, hidden] → logits [1, L, vocab]. */
  asLinear(h: MlxArray): MlxArray {
    return ops.quantizedMatmul(h, this.w, this.scales, this.biases, this.spec, true);
  }
}

/** Plain KV cache (concat-based; mlx-lm's step-allocated cache is
 *  numerically identical). Sliding-window eviction comes in Phase 3. */
export class KVCache {
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    if (this.keys && this.values) {
      const nk = ops.concatAxis([this.keys, k], 2);
      const nv = ops.concatAxis([this.values, v], 2);
      this.keys.dispose();
      this.values.dispose();
      k.dispose();
      v.dispose();
      this.keys = nk;
      this.values = nv;
    } else {
      this.keys = k;
      this.values = v;
    }
    this.offset = this.keys.shape[2]!;
    return [this.keys, this.values];
  }

  dispose(): void {
    this.keys?.dispose();
    this.values?.dispose();
    this.keys = this.values = null;
    this.offset = 0;
  }
}

class Attention {
  readonly isSliding: boolean;
  readonly useKEqV: boolean;
  readonly headDim: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly ropeBase: number | null;
  readonly ropeFreqs: MlxArray | null;
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear | null;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly vNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string, layerType: string) {
    const t = config.text;
    this.isSliding = layerType === "sliding_attention";
    this.headDim = this.isSliding ? t.headDim : t.globalHeadDim;
    this.nHeads = t.numAttentionHeads;
    this.useKEqV = t.attentionKEqV && !this.isSliding;
    this.nKvHeads = this.useKEqV ? t.numGlobalKeyValueHeads : t.numKeyValueHeads;

    const rp = t.ropeParameters[this.isSliding ? "sliding_attention" : "full_attention"]!;
    if (rp.ropeType === "default") {
      this.ropeBase = rp.ropeTheta;
      this.ropeFreqs = null;
    } else if (rp.ropeType === "proportional") {
      // ProportionalRoPE: rotate only partialRotaryFactor·dims dims;
      // freqs beyond that are inf (identity rotation).
      const rotated = Math.floor(this.headDim * rp.partialRotaryFactor);
      const n = this.headDim / 2;
      const freqs = new Float32Array(n).fill(Infinity);
      for (let i = 0; i < rotated / 2; i++)
        freqs[i] = Math.pow(rp.ropeTheta, (2 * i) / this.headDim);
      this.ropeBase = null;
      this.ropeFreqs = MlxArray.fromFloat32(freqs, [n]);
    } else {
      throw new Error(`unsupported rope_type ${rp.ropeType}`);
    }

    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = this.useKEqV ? null : QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
    this.vNorm = new RMSNorm(null, t.rmsNormEps);
  }

  rope(x: MlxArray, offset: number): MlxArray {
    return ops.rope(x, this.headDim, this.ropeBase, offset, this.ropeFreqs);
  }

  forward(x: MlxArray, maskMode: "" | "causal", cache: KVCache): MlxArray {
    const [B, L] = x.shape as [number, number, number];

    let q = this.qProj.forward(x);
    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    q = disposing(q, this.qNorm.forward(q));

    let k = this.kProj.forward(x);
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    let v: MlxArray;
    if (this.vProj) {
      v = this.vProj.forward(x);
      v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    } else {
      v = k; // shared projection; norms differ below
    }

    const offset = cache.offset;

    const kNormed = this.kNorm.forward(k);
    const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]);
    kNormed.dispose();
    const kRoped = this.rope(kT, offset);
    kT.dispose();

    const vNormed = this.vNorm.forward(v);
    const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);
    vNormed.dispose();
    if (v !== k) v.dispose();
    k.dispose();

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    q = disposing(q, this.rope(q, offset));

    const [keys, values] = cache.updateAndFetch(kRoped, vT); // cache owns

    const attn = ops.sdpa(q, keys, values, 1.0, maskMode);
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

class MLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray): MlxArray {
    const g = this.gate.forward(x);
    const u = this.up.forward(x);
    const act = ops.geluApprox(g);
    g.dispose();
    const h = ops.mul(act, u);
    act.dispose();
    u.dispose();
    const out = this.down.forward(h);
    h.dispose();
    return out;
  }
}

class DecoderLayer {
  readonly attn: Attention;
  readonly mlp: MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  readonly layerScalar: MlxArray | null;
  readonly layerType: string;

  constructor(weights: Weights, config: ModelConfig, idx: number) {
    const prefix = `language_model.model.layers.${idx}`;
    const t = config.text;
    this.layerType = t.layerTypes[idx]!;
    this.attn = new Attention(weights, config, `${prefix}.self_attn`, this.layerType);
    this.mlp = new MLP(weights, config, `${prefix}.mlp`);
    const norm = (n: string) => new RMSNorm(weights.tensor(`${prefix}.${n}.weight`), t.rmsNormEps);
    this.inputNorm = norm("input_layernorm");
    this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm");
    this.postFfNorm = norm("post_feedforward_layernorm");
    this.layerScalar = weights.has(`${prefix}.layer_scalar`)
      ? weights.tensor(`${prefix}.layer_scalar`)
      : null;
  }

  forward(x: MlxArray, maskMode: "" | "causal", cache: KVCache): MlxArray {
    let h = this.inputNorm.forward(x);
    h = disposing(h, this.attn.forward(h, maskMode, cache));
    h = disposing(h, this.postAttnNorm.forward(h));
    h = disposing(h, ops.add(x, h));

    const residual = h;
    let f = this.preFfNorm.forward(h);
    f = disposing(f, this.mlp.forward(f));
    f = disposing(f, this.postFfNorm.forward(f));
    h = ops.add(residual, f);
    residual.dispose();
    f.dispose();

    if (this.layerScalar) h = disposing(h, ops.mul(h, this.layerScalar));
    return h;
  }
}

/** Dispose `old` and return `next` — for h = disposing(h, op(h)) chains. */
function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}

export class Gemma4Model {
  readonly config: ModelConfig;
  readonly embed: QuantizedEmbedding;
  readonly layers: DecoderLayer[];
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;

  constructor(weights: Weights, config: ModelConfig) {
    const t = config.text;
    if (t.hiddenSize === 0 || !config.text.tieWordEmbeddings)
      throw new Error("only tied-embedding text configs are supported");
    if ((config.raw.text_config as any)?.enable_moe_block)
      throw new Error("MoE block not supported yet (Phase 6)");
    if ((config.raw.text_config as any)?.hidden_size_per_layer_input)
      throw new Error("per-layer-input models not supported yet");
    if ((config.raw.text_config as any)?.num_kv_shared_layers)
      throw new Error("KV-shared layers not supported yet");

    this.config = config;
    this.embed = QuantizedEmbedding.load(weights, "language_model.model.embed_tokens", config);
    this.layers = Array.from(
      { length: t.numHiddenLayers },
      (_, i) => new DecoderLayer(weights, config, i),
    );
    this.finalNorm = new RMSNorm(
      weights.tensor("language_model.model.norm.weight"),
      t.rmsNormEps,
    );
    this.embedScale = Math.sqrt(t.hiddenSize);
  }

  makeCache(): KVCache[] {
    return this.layers.map(() => new KVCache());
  }

  /** tokens → logits [1, L, vocab] (caller disposes). */
  forward(tokens: number[], cache: KVCache[]): MlxArray {
    const maskMode: "" | "causal" = tokens.length === 1 ? "" : "causal";

    let h = this.embed.encode(tokens);
    h = disposing(h, ops.mulScalar(h, this.embedScale));

    for (let i = 0; i < this.layers.length; i++)
      h = disposing(h, this.layers[i]!.forward(h, maskMode, cache[i]!));

    h = disposing(h, this.finalNorm.forward(h));

    let logits = this.embed.asLinear(h);
    h.dispose();

    const softcap = this.config.text.finalLogitSoftcapping;
    if (softcap !== null) {
      const capped = logitSoftcap(logits, softcap);
      logits.dispose();
      logits = capped;
    }
    return logits;
  }

  /** Greedy generation; returns generated token ids (not incl. prompt). */
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

/** tanh(x / cap) * cap with weak-scalar semantics. */
function logitSoftcap(logits: MlxArray, cap: number): MlxArray {
  const capArr = ops.scalarLike(cap, logits);
  const scaled = ops.div(logits, capArr);
  const t = ops.tanh(scaled);
  scaled.dispose();
  const out = ops.mul(t, capArr);
  t.dispose();
  capArr.dispose();
  return out;
}

/** argmax over vocab at the last sequence position of [1, L, V]. */
export function argmaxLastPosition(logits: MlxArray): number {
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]);
  const am = ops.argmaxAxis(last, -1);
  const id = ops.itemUint32(am);
  last.dispose();
  am.dispose();
  return id;
}

/** Last-position logits as f32 (for the parity harness). */
export function lastPositionLogits(logits: MlxArray): Float32Array {
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]);
  const f32 = last.toFloat32();
  last.dispose();
  return f32;
}
