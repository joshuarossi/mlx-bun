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
import { CompiledFunction } from "../mlx/compile";
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

// ── Compiled activations ─────────────────────────────────────────────────────
// The oracle (mlx_lm/models/activations.py + qwen3_next.py) wraps BOTH swiglu
// activations in `@partial(mx.compile, shapeless=True)`. We match it: every
// activation site below (the MLP swiglu, the RMSNormGated `_precise_swiglu`, and
// the conv `nn.silu`) runs through a compiled closure unconditionally, so the
// dispatched kernel set matches the oracle op-for-op (= mlx-lm, bit-exact). Traced
// once (shapeless), replayed thereafter; autograd-safe (mx.compile threads VJP
// through the traced graph). `compiledSwiglu` is exported so the parity test can
// assert the closure exists and the MLP actually uses it.

/** activations.py: `@mx.compile def swiglu(gate, x): return nn.silu(gate) * x`.
 *  nn.silu(g) == g * sigmoid(g); mx.compile fuses sigmoid+mul+mul → one kernel. */
let _swigluClosure: CompiledFunction | null = null;
export function compiledSwiglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_swigluClosure) {
    _swigluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!;
      const sig = ops.sigmoid(g);
      const silu = ops.mul(g, sig); sig.dispose();
      const out = ops.mul(silu, u); silu.dispose();
      return [out];
    });
  }
  return _swigluClosure.apply([gate, up])[0]!;
}

/** qwen3_next.py `_precise_swiglu(h, gate, x)`:
 *    gate = nn.silu(gate.astype(f32)); x = x.astype(f32); (gate*x).astype(h.dtype)
 *  Used by Qwen3NextRMSNormGated. Inputs: (h=hidden for the out dtype, gate=z,
 *  x=rms_norm(hidden)). mx.compile fuses the two casts + silu + mul + cast. */
let _preciseSwigluClosure: CompiledFunction | null = null;
export function compiledPreciseSwiglu(h: MlxArray, gate: MlxArray, x: MlxArray): MlxArray {
  if (!_preciseSwigluClosure) {
    _preciseSwigluClosure = new CompiledFunction((inputs) => {
      const hh = inputs[0]!, g = inputs[1]!, xx = inputs[2]!;
      const gf = g.astype(Dtype.float32);
      const sig = ops.sigmoid(gf);
      const silu = ops.mul(gf, sig); gf.dispose(); sig.dispose();
      const xf = xx.astype(Dtype.float32);
      const prod = ops.mul(silu, xf); silu.dispose(); xf.dispose();
      const out = prod.astype(hh.dtype); prod.dispose();
      return [out];
    });
  }
  return _preciseSwigluClosure.apply([h, gate, x])[0]!;
}

/** mlx.nn.silu is `@partial(mx.compile, shapeless=True) def silu(x): x*sigmoid(x)`
 *  — a COMPILED kernel, not a standalone sigmoid+mul. Used for the conv
 *  activation `nn.silu(conv1d(...))`, matching mlx-lm's fused BV2ISigmoid…_V_. */
let _siluClosure: CompiledFunction | null = null;
export function compiledSilu(x: MlxArray): MlxArray {
  if (!_siluClosure) {
    _siluClosure = new CompiledFunction((inputs) => {
      const xx = inputs[0]!;
      const sig = ops.sigmoid(xx);
      const out = ops.mul(xx, sig); sig.dispose(); // x * sigmoid(x)
      return [out];
    });
  }
  return _siluClosure.apply([x])[0]!;
}

// NOTE: the attention output gate is `self.o_proj(output * mx.sigmoid(gate))`
// INLINE in mlx-lm (qwen3_next.py) — NOT @mx.compile. It is intentionally kept
// as a standalone sigmoid + multiply in Qwen3Attention.forward so the dispatched
// kernel set matches the reference; there is no compiled-output-gate helper.

/** Gated-DeltaNet linear-attention layer (mlx-lm GatedDeltaNet). */
export class GatedDeltaNet {
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

    // Armed speculative verify round (serve loop, serial lane): this forward
    // must be rewindable. Snapshot = hand the REPLACED state slots to the
    // round instead of disposing (free — arrays are immutable); record the
    // position-local kernel inputs (qkv/a/b) and install the prefix replay.
    const spec = cache.specRound;
    if (spec) {
      if (!spec.armed)
        throw new Error("GatedDeltaNet: spec round already recorded this round");
      spec.armed = false;
      spec.S = S;
      spec.replay = (c, keep) => this.#replaySpecPrefix(c, keep);
    }

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
    if (spec) spec.qkv = qkv;
    else qkv.dispose();
    // New conv state = last nKeep rows (contiguous, the array is sliced).
    const newConv = ops.contiguous(
      convInput.slice([0, S, 0], [B, S + nKeep, convDim]),
    );
    if (spec) spec.prevConv = cache.conv;
    else cache.conv?.dispose();
    cache.conv = newConv;

    const conv = ops.conv1d(convInput, this.convWeight, 1, 0, 1, convDim);
    convInput.dispose();
    const convOut = compiledSilu(conv); // nn.silu (mx.compile), matches mlx-lm
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
    if (spec) {
      spec.a = a;
      spec.b = b;
      spec.prevRecurrent = cache.recurrent;
    } else {
      a.dispose();
      b.dispose();
      cache.recurrent?.dispose();
    }
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

  /** Speculative rollback replay: with the pre-round snapshot RESTORED onto
   *  `cache`, re-advance the first `keep` window tokens from the recorded
   *  position-local inputs. Every op mirrors forward() on the same values —
   *  conv windows, silu, per-position norms, and the kernel's serial prefix
   *  are all independent of the rejected tail — so the resulting conv +
   *  recurrent state is BIT-EXACTLY what a forward over only the accepted
   *  prefix would have produced. Output projections (z / out_proj) are state-
   *  free and skipped: only the states matter here. */
  #replaySpecPrefix(cache: SSMCache, keep: number): void {
    const r = cache.specRound;
    if (!r || !r.qkv || !r.a || !r.b)
      throw new Error("GatedDeltaNet replay without recorded round inputs");
    const B = r.qkv.shape[0]!;
    const convDim = this.keyDim * 2 + this.valueDim;
    const nKeep = this.convKernel - 1;

    const qkvPfxView = r.qkv.slice([0, 0, 0], [B, keep, convDim]);
    const qkvPfx = ops.contiguous(qkvPfxView);
    qkvPfxView.dispose();
    const convState = cache.conv ?? ops.zeros([B, nKeep, convDim], qkvPfx.dtype);
    const convInput = ops.concatAxis([convState, qkvPfx], 1);
    if (!cache.conv) convState.dispose();
    qkvPfx.dispose();
    const newConv = ops.contiguous(
      convInput.slice([0, keep, 0], [B, keep + nKeep, convDim]),
    );
    cache.conv?.dispose();
    cache.conv = newConv;

    const conv = ops.conv1d(convInput, this.convWeight, 1, 0, 1, convDim);
    convInput.dispose();
    const convOut = compiledSilu(conv);
    conv.dispose();
    const [qFlat, kFlat, vFlat] = ops.split(
      convOut, [this.keyDim, 2 * this.keyDim], -1,
    ) as [MlxArray, MlxArray, MlxArray];
    convOut.dispose();
    let q = ops.reshape(qFlat, [B, keep, this.numKHeads, this.headKDim]);
    qFlat.dispose();
    let k = ops.reshape(kFlat, [B, keep, this.numKHeads, this.headKDim]);
    kFlat.dispose();
    const v = disposing(vFlat, ops.reshape(vFlat, [B, keep, this.numVHeads, this.headVDim]));
    const invScale = Math.pow(this.headKDim, -0.5);
    q = disposing(q, ops.rmsNorm(q, null, 1e-6));
    q = disposing(q, ops.mulScalar(q, invScale * invScale));
    k = disposing(k, ops.rmsNorm(k, null, 1e-6));
    k = disposing(k, ops.mulScalar(k, invScale));

    const aPfxView = r.a.slice([0, 0, 0], [B, keep, this.numVHeads]);
    const aPfx = ops.contiguous(aPfxView);
    aPfxView.dispose();
    const bPfxView = r.b.slice([0, 0, 0], [B, keep, this.numVHeads]);
    const bPfx = ops.contiguous(bPfxView);
    bPfxView.dispose();

    const [y, newState] = gatedDeltaUpdate(
      q, k, v, aPfx, bPfx, this.aLog, this.dtBias, cache.recurrent,
    );
    q.dispose();
    k.dispose();
    v.dispose();
    aPfx.dispose();
    bPfx.dispose();
    y.dispose(); // only the state advance matters on the rollback path
    cache.recurrent?.dispose();
    cache.recurrent = newState;
    cache.advance(keep);
  }

  private rmsNormGated(hidden: MlxArray, gate: MlxArray): MlxArray {
    const xn = ops.rmsNorm(hidden, this.normWeight, this.eps); // bf16
    // Oracle: _precise_swiglu(hidden, gate, xn) — ALWAYS one @mx.compile kernel
    // (matches mlx-lm; no unfused silu+mul+cast).
    const res = compiledPreciseSwiglu(hidden, gate, xn);
    xn.dispose();
    return res;
  }
}

/** Full (softmax) attention with output gate + q/k norm + partial RoPE. */
export class Qwen3Attention {
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

    // Batched decode: the scheduler's mask wrapper exposes each row's REAL
    // position as ropeOffsetArr (rows have different prompt lengths); the
    // dynamic-offset kernel is the same fast::rope, bit-exact vs the static
    // form (tests/compile.test.ts). Serial lane: scalar offset, unchanged.
    const offArr = (cache as { ropeOffsetArr?: MlxArray }).ropeOffsetArr;
    q = disposing(q, offArr
      ? ops.ropeDynamic(q, this.ropeDims, this.ropeBase, offArr, null)
      : ops.rope(q, this.ropeDims, this.ropeBase, cache.offset, null));
    k = disposing(k, offArr
      ? ops.ropeDynamic(k, this.ropeDims, this.ropeBase, offArr, null)
      : ops.rope(k, this.ropeDims, this.ropeBase, cache.offset, null));

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
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    // qwen3_next.py:158  return self.o_proj(output * mx.sigmoid(gate))
    // INLINE, not @mx.compile — copy the exact ops.
    const sig = ops.sigmoid(gate);
    gate.dispose();
    const gated = ops.mul(merged, sig);
    merged.dispose();
    sig.dispose();
    const out = this.oProj.forward(gated);
    gated.dispose();
    return out;
  }
}

export class Qwen3MLP {
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
    // Oracle: down_proj(swiglu(gate_proj(x), up_proj(x))) — swiglu ALWAYS compiled
    // (mlx-lm's @mx.compile swiglu; no unfused silu+mul, matches its kernel set).
    const hidden = compiledSwiglu(g, u);
    g.dispose();
    u.dispose();
    const out = this.down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

export class Qwen3Layer {
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

  /** Layer-output tap (same contract as Gemma4Model.hiddenTap): the serve
   *  loop's forwardMaybeTap sets it around prefill/verify forwards so
   *  KV-borrowing draft sources (native Qwen MTP) can read PRE-final-norm
   *  hiddens — layer 63's output stream, what mlx-vlm captures with
   *  skip_final_norm=True. No-op (and graph-identical) when null. */
  hiddenTap: { layers: Set<number>; pos?: number; captured: Map<number, MlxArray> } | null = null;

  /** Store layer `i`'s residual stream ([1,L,H]) if the tap requests it.
   *  Copies so the loop's h.dispose() can't free the capture. */
  protected captureLayer(i: number, h: MlxArray): void {
    const tap = this.hiddenTap;
    if (!tap || !tap.layers.has(i)) return;
    const H = h.shape[2]!;
    const src = tap.pos !== undefined ? h.slice([0, tap.pos, 0], [1, tap.pos + 1, H]) : h;
    const copy = ops.contiguous(src);
    if (src !== h) src.dispose();
    tap.captured.set(i, copy);
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
      this.captureLayer(i, h); // native-MTP pre-final-norm tap (no-op unless set)
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
