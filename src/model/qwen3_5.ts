// Concrete model graph for Qwen3.5 hybrid models (e.g. Qwen3.6-27B-OptiQ-4bit).
// Port target: mlx_lm.models.qwen3_5 (+ qwen3_next Attention/MLP/RMSNormGated,
// gated_delta recurrence). The architecture is a 64-layer stack where every
// `fullAttentionInterval`-th layer is standard softmax attention and the rest
// are gated-DeltaNet linear-attention layers. Weights carry a
// `language_model.` prefix.
//
// Parity bars: bf16 KV → bit-exact vs mlx-lm; mixed-precision KV → bit-exact vs
// mlx-optiq (the 16 full-attention layers quantized per kv_config.json, via the
// shared maybeQuantizeKv path).

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  argmaxLastPosition,
  disposeTriple,
  disposing,
  KVCache,
  LoraState,
  QuantizedKVCache,
  QuantizedEmbedding,
  QuantizedLinear,
  quantizedSdpa,
  RMSNorm,
  type Cache,
  type Mask,
} from "./gemma4-base";
import { gatedDeltaUpdate, SSMCache } from "./qwen3-delta";

const PREFIX = "language_model";

/** Gated-DeltaNet linear-attention layer (mlx-lm GatedDeltaNet). */
class GatedDeltaNet {
  readonly inProjQkv: QuantizedLinear;
  readonly inProjZ: QuantizedLinear;
  readonly inProjB: QuantizedLinear;
  readonly inProjA: QuantizedLinear;
  readonly outProj: QuantizedLinear;
  readonly convWeight: MlxArray;
  readonly aLog: MlxArray;
  readonly dtBias: MlxArray;
  readonly normWeight: MlxArray;
  readonly eps: number;
  readonly numKHeads: number;
  readonly numVHeads: number;
  readonly headKDim: number;
  readonly headVDim: number;
  readonly keyDim: number;
  readonly valueDim: number;
  readonly convKernel: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.numKHeads = t.linearNumKeyHeads;
    this.numVHeads = t.linearNumValueHeads;
    this.headKDim = t.linearKeyHeadDim;
    this.headVDim = t.linearValueHeadDim;
    this.keyDim = this.headKDim * this.numKHeads;
    this.valueDim = this.headVDim * this.numVHeads;
    this.convKernel = t.linearConvKernelDim;
    this.eps = t.rmsNormEps;
    this.inProjQkv = QuantizedLinear.load(weights, `${prefix}.in_proj_qkv`, config);
    this.inProjZ = QuantizedLinear.load(weights, `${prefix}.in_proj_z`, config);
    this.inProjB = QuantizedLinear.load(weights, `${prefix}.in_proj_b`, config);
    this.inProjA = QuantizedLinear.load(weights, `${prefix}.in_proj_a`, config);
    this.outProj = QuantizedLinear.load(weights, `${prefix}.out_proj`, config);
    this.convWeight = weights.tensor(`${prefix}.conv1d.weight`);
    this.aLog = weights.tensor(`${prefix}.A_log`);
    this.dtBias = weights.tensor(`${prefix}.dt_bias`);
    this.normWeight = weights.tensor(`${prefix}.norm.weight`);
  }

  forward(x: MlxArray, cache: SSMCache): MlxArray {
    const [B, S] = x.shape as [number, number, number];
    const convDim = this.keyDim * 2 + this.valueDim;
    const nKeep = this.convKernel - 1;

    const qkv = this.inProjQkv.forward(x); // [B,S,convDim]
    let z = this.inProjZ.forward(x);
    z = disposing(z, ops.reshape(z, [B, S, this.numVHeads, this.headVDim]));
    const b = this.inProjB.forward(x); // [B,S,numVHeads]
    const a = this.inProjA.forward(x); // [B,S,numVHeads]

    // Causal depthwise conv with the conv-state prefix (B=1: no ssm mask).
    const convState =
      cache.conv ?? ops.zeros([B, nKeep, convDim], x.dtype);
    const convInput = ops.concatAxis([convState, qkv], 1); // [B,S+nKeep,convDim]
    if (!cache.conv) convState.dispose();
    qkv.dispose();
    // New conv state = last nKeep rows (contiguous, the array is sliced).
    const newConv = ops.contiguous(
      convInput.slice([0, S, 0], [B, S + nKeep, convDim]),
    );
    cache.conv?.dispose();
    cache.conv = newConv;

    const conv = ops.conv1d(convInput, this.convWeight, 1, 0, 1, convDim);
    convInput.dispose();
    const convOut = ops.silu(conv); // [B,S,convDim]
    conv.dispose();

    const [qFlat, kFlat, vFlat] = ops.split(
      convOut, [this.keyDim, 2 * this.keyDim], -1,
    ) as [MlxArray, MlxArray, MlxArray];
    convOut.dispose();
    let q = ops.reshape(qFlat, [B, S, this.numKHeads, this.headKDim]);
    qFlat.dispose();
    let k = ops.reshape(kFlat, [B, S, this.numKHeads, this.headKDim]);
    kFlat.dispose();
    const v = disposing(vFlat, ops.reshape(vFlat, [B, S, this.numVHeads, this.headVDim]));

    // inv_scale = head_k_dim ** -0.5; q *= inv_scale², k *= inv_scale.
    const invScale = Math.pow(this.headKDim, -0.5);
    q = disposing(q, ops.rmsNorm(q, null, 1e-6));
    q = disposing(q, ops.mulScalar(q, invScale * invScale));
    k = disposing(k, ops.rmsNorm(k, null, 1e-6));
    k = disposing(k, ops.mulScalar(k, invScale));

    const [out, newState] = gatedDeltaUpdate(
      q, k, v, a, b, this.aLog, this.dtBias, cache.recurrent,
    );
    q.dispose();
    k.dispose();
    v.dispose();
    a.dispose();
    b.dispose();
    cache.recurrent?.dispose();
    cache.recurrent = newState;
    cache.advance(S);

    // RMSNormGated: silu(z_f32) * rms_norm(out)_f32, cast back to out dtype.
    const gated = this.rmsNormGated(out, z);
    out.dispose();
    z.dispose();
    const merged = ops.reshape(gated, [B, S, this.valueDim]);
    gated.dispose();
    const result = this.outProj.forward(merged);
    merged.dispose();
    return result;
  }

  private rmsNormGated(hidden: MlxArray, gate: MlxArray): MlxArray {
    const xn = ops.rmsNorm(hidden, this.normWeight, this.eps); // bf16
    const gf = gate.astype(Dtype.float32);
    const sg = ops.silu(gf); // silu(z) in f32
    gf.dispose();
    const xf = xn.astype(Dtype.float32);
    xn.dispose();
    const prod = ops.mul(sg, xf);
    sg.dispose();
    xf.dispose();
    const res = prod.astype(hidden.dtype);
    prod.dispose();
    return res;
  }
}

/** Full (softmax) attention with output gate + q/k norm + partial RoPE. */
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
  readonly ropeDims: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeDims = Math.trunc(this.headDim * t.partialRotaryFactor);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const [B, L] = x.shape as [number, number, number];

    // q_proj emits 2× head_dim per head → split into queries + gate.
    const qp = this.qProj.forward(x);
    const qpr = disposing(qp, ops.reshape(qp, [B, L, this.nHeads, this.headDim * 2]));
    const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1) as [MlxArray, MlxArray];
    qpr.dispose();
    const gate = disposing(gateHeads, ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim]));

    let k = this.kProj.forward(x);
    let v = this.vProj.forward(x);

    // q/k norm over head_dim BEFORE transpose (reference order).
    let q = this.qNorm.forward(qHeads);
    qHeads.dispose();
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    k = disposing(k, this.kNorm.forward(k));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    q = disposing(q, ops.rope(q, this.ropeDims, this.ropeBase, cache.offset, null));
    k = disposing(k, ops.rope(k, this.ropeDims, this.ropeBase, cache.offset, null));

    let attn: MlxArray;
    if (cache instanceof QuantizedKVCache) {
      const [keys, values] = cache.updateAndFetchQuantized(k, v);
      k.dispose();
      v.dispose();
      attn = quantizedSdpa(q, keys, values, this.scale, mask, cache.groupSize, cache.bits);
      disposeTriple(keys);
      disposeTriple(values);
    } else {
      const [keys, values] = cache.updateAndFetch(k, v);
      k.dispose();
      v.dispose();
      attn = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
      keys.dispose();
      values.dispose();
    }
    q.dispose();

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    let merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    // Output gate: o_proj(output * sigmoid(gate)).
    const sg = ops.sigmoid(gate);
    gate.dispose();
    merged = disposing(merged, ops.mul(merged, sg));
    sg.dispose();
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
    const g = this.gate.forward(x);
    const u = this.up.forward(x);
    const silu = ops.silu(g);
    g.dispose();
    const hidden = ops.mul(silu, u);
    silu.dispose();
    u.dispose();
    const out = this.down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

class Qwen3Layer {
  readonly isLinear: boolean;
  readonly linearAttn: GatedDeltaNet | null = null;
  readonly selfAttn: Qwen3Attention | null = null;
  readonly mlp: Qwen3MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, layerIdx: number) {
    const prefix = `${PREFIX}.model.layers.${layerIdx}`;
    this.isLinear = (layerIdx + 1) % config.text.fullAttentionInterval !== 0;
    if (this.isLinear)
      this.linearAttn = new GatedDeltaNet(weights, config, `${prefix}.linear_attn`);
    else this.selfAttn = new Qwen3Attention(weights, config, `${prefix}.self_attn`);
    this.mlp = new Qwen3MLP(weights, config, `${prefix}.mlp`);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  forward(x: MlxArray, faMask: Mask, cache: Cache): MlxArray {
    const xn = this.inputNorm.forward(x);
    const r = this.isLinear
      ? this.linearAttn!.forward(xn, cache as SSMCache)
      : this.selfAttn!.forward(xn, faMask, cache);
    xn.dispose();
    const h = ops.add(x, r);
    r.dispose();
    const hn = this.postAttnNorm.forward(h);
    const m = this.mlp.forward(hn);
    hn.dispose();
    const out = ops.add(h, m);
    h.dispose();
    m.dispose();
    return out;
  }
}

export class Qwen35Model {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  /** Base path for LoRA target keys (weights carry the language_model prefix). */
  readonly prefixBase = "language_model.model";
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3Layer[];
  readonly finalNorm: RMSNorm;
  /** null when tied: the output head reuses embed_tokens (embed.asLinear). */
  readonly lmHead: QuantizedLinear | null;
  readonly tied: boolean;
  readonly faIdx: number;

  constructor(weights: Weights, config: ModelConfig) {
    this.config = config;
    this.tied = config.text.tieWordEmbeddings;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, `${PREFIX}.model.embed_tokens`, config);
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3Layer(weights, config, i),
    );
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.model.norm.weight`), config.text.rmsNormEps);
    // Tied models (e.g. Qwen3.5-4B) ship no lm_head; the reference uses
    // embed_tokens.as_linear (mlx-lm qwen3_5 TextModel.__call__).
    this.lmHead = this.tied ? null : QuantizedLinear.load(weights, `${PREFIX}.lm_head`, config);
    this.faIdx = config.text.fullAttentionInterval - 1;
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `${PREFIX}.model.layers.${i}`;
      if (l.selfAttn) {
        out.set(`${p}.self_attn.q_proj`, l.selfAttn.qProj);
        out.set(`${p}.self_attn.k_proj`, l.selfAttn.kProj);
        out.set(`${p}.self_attn.v_proj`, l.selfAttn.vProj);
        out.set(`${p}.self_attn.o_proj`, l.selfAttn.oProj);
      } else if (l.linearAttn) {
        out.set(`${p}.linear_attn.in_proj_qkv`, l.linearAttn.inProjQkv);
        out.set(`${p}.linear_attn.in_proj_z`, l.linearAttn.inProjZ);
        out.set(`${p}.linear_attn.in_proj_b`, l.linearAttn.inProjB);
        out.set(`${p}.linear_attn.in_proj_a`, l.linearAttn.inProjA);
        out.set(`${p}.linear_attn.out_proj`, l.linearAttn.outProj);
      }
      out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
      out.set(`${p}.mlp.up_proj`, l.mlp.up);
      out.set(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  makeCache(): Cache[] {
    return this.layers.map((l) => (l.isLinear ? new SSMCache() : new KVCache()));
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const h = this.embed.encode(ids);
    return this.forwardLayers(h, cache);
  }

  forwardEmbeddings(_embeds: MlxArray, _cache: Cache[], _bidir: MlxArray | null): MlxArray {
    throw new Error("qwen3_5 vision/input-embedding path is not supported");
  }

  protected forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    const L = h0.shape[1]!;
    // One full-attention mask shared by all full layers (same offset); linear
    // layers see no ssm mask at B=1.
    const faMask = cache[this.faIdx]!.makeMask(L, null);
    let h = h0;
    for (let i = 0; i < this.layers.length; i++) {
      const next = this.layers[i]!.forward(h, faMask, cache[i]!);
      h.dispose();
      h = next;
    }
    faMask.arr?.dispose();
    return disposing(h, this.finalNorm.forward(h));
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.tied ? this.embed.asLinear(h) : this.lmHead!.forward(h);
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
