// The layers of MOSS-Image's conditioner, the Qwen3.5-9B language model the
// pipeline runs once per prompt (transformers' Qwen3_5TextModel, no head, no
// cache): each does one job in the reference's dtypes and order and binds the
// kernels it owns. Projections and gains are borrowed from the component's
// `Weights`; a layer frees only what it made.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { gatedDeltaFloat32 } from "../../kernels/gated-delta-float32";
import type { MossLinear } from "./layers";

const f32 = Math.fround;

/** `x` (borrowed) through a float32 function, cast back to `x`'s dtype once:
 * how torch applies an activation to a bf16 tensor. */
function inFloat(x: MlxArray, fn: (wide: MlxArray) => MlxArray): MlxArray {
  using wide = x.astype(Dtype.float32);
  using out = fn(wide);
  return out.astype(x.dtype);
}

/** torch's CPU SiLU on float32 values (borrowed), in the form its kernel computes: `x / (1 + exp(-x))`. Returns an owned array. */
function torchSilu(x: MlxArray): MlxArray {
  using negative = ops.neg(x);
  using exponential = ops.exp(negative);
  using one = ops.scalarLike(1, exponential);
  using denominator = ops.add(one, exponential);
  return ops.div(x, denominator);
}

/** A float32 value (borrowed) rounded to `dtype` and widened back: the result of one torch operation on bf16 tensors,
 * which computes in float32 and stores in the input dtype. */
function stored(wide: MlxArray, dtype: Dtype): MlxArray {
  using rounded = wide.astype(dtype);
  return rounded.astype(Dtype.float32);
}

/** transformers' `l2norm` (`x * rsqrt((x * x).sum(-1) + 1e-6)`) on a bf16 tensor as the pinned torch runs it: each
 * operation computed in float32 and stored in the input dtype (the sum accumulated in float32, stored once), with
 * `rsqrt` a square root stored in bf16 and then its reciprocal stored in bf16. Measured against the reference's own
 * l2norm outputs: that sequence matches every element, a once-rounded rsqrt about a fifth of them. */
export class MossTextL2Norm {
  /** `x` `[..., D]` (borrowed) to an owned normalization in `x`'s dtype. */
  forward(x: MlxArray): MlxArray {
    const dtype = x.dtype;
    using wide = x.astype(Dtype.float32);
    using squaresWide = ops.square(wide);
    using squares = stored(squaresWide, dtype);
    using sumWide = ops.sumAxis(squares, -1, true);
    using sum = stored(sumWide, dtype);
    using eps = ops.scalarLike(1e-6, sum);
    using shiftedWide = ops.add(sum, eps);
    using shifted = stored(shiftedWide, dtype);
    using rootWide = ops.sqrt(shifted);
    using root = stored(rootWide, dtype);
    using one = ops.scalarLike(1, root);
    using inverseWide = ops.div(one, root);
    using inverse = stored(inverseWide, dtype);
    using unit = ops.mul(wide, inverse);
    return unit.astype(dtype);
  }
}

/** `Qwen3_5RMSNorm`: normalize in float32, scale by `1 + gamma` in float32, cast once. */
export class MossTextRmsNorm {
  readonly #scale: MlxArray;

  constructor(gamma: MlxArray, readonly eps: number) {
    using wide = gamma.astype(Dtype.float32);
    using one = ops.scalarLike(1, wide);
    this.#scale = ops.add(one, wide);
  }

  forward(x: MlxArray): MlxArray {
    return inFloat(x, wide => ops.rmsNorm(wide, this.#scale, this.eps));
  }

  dispose(): void { this.#scale.dispose(); }
}

/** `Qwen3_5RMSNormGated` on bf16 values with the checkpoint's bf16 weight, as the pinned torch runs it: normalize in
 * float32 (rsqrt as a square root, then its reciprocal) and store in the input dtype, multiply by the weight (bf16 by bf16,
 * stored again), then multiply by `silu(gate)` in float32 (`x / (1 + exp(-x))`) and store once. The variance's float32 sum
 * follows MLX's reduction order, not torch's, so a value at a bf16 rounding boundary can land one step apart; the
 * reference comparison counts those. */
export class MossTextGatedNorm {
  constructor(readonly weight: MlxArray, readonly eps: number) {}

  /** `x` and `gate` equal-shaped `[..., D]` (borrowed). */
  forward(x: MlxArray, gate: MlxArray): MlxArray {
    const dtype = x.dtype;
    using wide = x.astype(Dtype.float32);
    using squares = ops.square(wide);
    using variance = ops.meanAxis(squares, -1, true);
    using eps = ops.scalarLike(this.eps, variance);
    using shifted = ops.add(variance, eps);
    // torch's float32 rsqrt: a square root, then its reciprocal.
    using root = ops.sqrt(shifted);
    using one = ops.scalarLike(1, root);
    using inverse = ops.div(one, root);
    using normalizedWide = ops.mul(wide, inverse);
    using normalized = stored(normalizedWide, dtype);
    using weight = this.weight.astype(Dtype.float32);
    using weightedWide = ops.mul(weight, normalized);
    using weighted = stored(weightedWide, dtype);
    using gateWide = gate.astype(Dtype.float32);
    using activated = torchSilu(gateWide);
    using gated = ops.mul(weighted, activated);
    return gated.astype(dtype);
  }
}

/** The token embedding table: `ids` `[1, L]` to `[1, L, hidden]`. */
export class MossTextEmbedding {
  constructor(readonly table: MlxArray) {}
  forward(ids: MlxArray): MlxArray { return ops.takeAxis(this.table, ids, 0); }
}

/** An MLX affine-quantized embedding table (packed rows, scales and biases): the looked-up rows dequantized. */
export class MossQuantizedTextEmbedding {
  constructor(readonly table: MlxArray, readonly scales: MlxArray, readonly biases: MlxArray, readonly spec: ops.QuantSpec) {}
  forward(ids: MlxArray): MlxArray {
    using rows = ops.takeAxis(this.table, ids, 0), scaleRows = ops.takeAxis(this.scales, ids, 0), biasRows = ops.takeAxis(this.biases, ids, 0);
    return ops.dequantize(rows, scaleRows, biasRows, this.spec);
  }
}

/** cos/sin `[1, L, 1, rotaryDims]` bf16. Owned. */
export interface MossTextRopeTables extends Disposable {
  readonly cos: MlxArray;
  readonly sin: MlxArray;
}

/** `Qwen3_5TextRotaryEmbedding` for a text-only prompt (the three position
 * streams are equal, so interleaved mRoPE is plain RoPE) and its partial
 * rotate-half application to the first `rotaryDims` of each head. */
export class MossTextRope {
  readonly #invFreq: Float32Array;

  constructor(readonly rotaryDims: number, base: number) {
    this.#invFreq = Float32Array.from({ length: rotaryDims / 2 }, (_, k) => f32(1 / f32(Math.pow(base, f32((2 * k) / rotaryDims)))));
  }

  /** Positions `0 .. length - 1`: `freqs = position * inv_freq` in float32, `cat(freqs, freqs)`, cos/sin cast to bf16. */
  tables(length: number): MossTextRopeTables {
    const dims = this.rotaryDims, half = dims / 2;
    const cos = new Float32Array(length * dims), sin = new Float32Array(length * dims);
    for (let position = 0; position < length; position++)
      for (let k = 0; k < half; k++) {
        const angle = f32(position * this.#invFreq[k]!), c = Math.cos(angle), s = Math.sin(angle);
        cos[position * dims + k] = c; cos[position * dims + half + k] = c;
        sin[position * dims + k] = s; sin[position * dims + half + k] = s;
      }
    const table = (values: Float32Array) => { using wide = MlxArray.fromFloat32(values, [1, length, 1, dims]); return wide.astype(Dtype.bfloat16); };
    const c = table(cos), s = table(sin);
    return { cos: c, sin: s, [Symbol.dispose]() { c.dispose(); s.dispose(); } };
  }

  /** `x` `[1, L, H, D]` (borrowed): the first `rotaryDims` rotated, the rest passed through. Owned result. */
  apply(x: MlxArray, tables: MossTextRopeTables): MlxArray {
    const [b, l, h, d] = x.shape as [number, number, number, number], dims = this.rotaryDims, half = dims / 2;
    using rot = x.slice([0, 0, 0, 0], [b, l, h, dims]);
    using pass = x.slice([0, 0, 0, dims], [b, l, h, d]);
    using first = rot.slice([0, 0, 0, 0], [b, l, h, half]);
    using second = rot.slice([0, 0, 0, half], [b, l, h, dims]);
    using negated = ops.neg(second);
    using rotated = ops.concatAxis([negated, first], -1);
    using direct = ops.mul(rot, tables.cos);
    using turned = ops.mul(rotated, tables.sin);
    using embedded = ops.add(direct, turned);
    return ops.concatAxis([embedded, pass], -1);
  }
}

export interface MossTextAttentionShape {
  readonly heads: number;
  readonly kvHeads: number;
  readonly headDim: number;
}

/** `Qwen3_5Attention` over a whole prompt: q (packed with its gate per head),
 * k and v projections, per-head norms, partial RoPE, causal grouped-query SDPA,
 * the sigmoid output gate and the output projection. */
export class MossTextAttention {
  constructor(readonly q: MossLinear, readonly k: MossLinear, readonly v: MossLinear, readonly o: MossLinear,
    readonly qNorm: MossTextRmsNorm, readonly kNorm: MossTextRmsNorm, readonly rope: MossTextRope, readonly shape: MossTextAttentionShape) {}

  forward(x: MlxArray, tables: MossTextRopeTables): MlxArray {
    const { heads, kvHeads, headDim } = this.shape, length = x.shape[1]!;
    using packed = this.q.forward(x);
    using perHead = ops.reshape(packed, [1, length, heads, 2 * headDim]);
    const [query, gate] = ops.split(perHead, [headDim], -1);
    using q = query!, g = gate!;
    using keyFlat = this.k.forward(x), valueFlat = this.v.forward(x);
    using key = ops.reshape(keyFlat, [1, length, kvHeads, headDim]), value = ops.reshape(valueFlat, [1, length, kvHeads, headDim]);
    using qn = this.qNorm.forward(q), kn = this.kNorm.forward(key);
    using qr = this.rope.apply(qn, tables), kr = this.rope.apply(kn, tables);
    using qt = ops.transposeAxes(qr, [0, 2, 1, 3]), kt = ops.transposeAxes(kr, [0, 2, 1, 3]), vt = ops.transposeAxes(value, [0, 2, 1, 3]);
    using attended = ops.sdpa(qt, kt, vt, Math.pow(headDim, -0.5), "causal");
    using merged = ops.transposeAxes(attended, [0, 2, 1, 3]);
    using flat = ops.reshape(merged, [1, length, heads * headDim]);
    using gateFlat = ops.reshape(g, [1, length, heads * headDim]);
    using sig = inFloat(gateFlat, wide => ops.sigmoid(wide));
    using gated = ops.mul(flat, sig);
    return this.o.forward(gated);
  }

  dispose(): void { for (const linear of [this.q, this.k, this.v, this.o]) linear.dispose(); this.qNorm.dispose(); this.kNorm.dispose(); }
}

export interface MossDeltaShape {
  readonly keyHeads: number;
  readonly valueHeads: number;
  readonly keyDim: number;
  readonly valueDim: number;
}

/** The step log-decay `g = -exp(A_log) * softplus(a + dt_bias)` in float32, as `Qwen3_5GatedDeltaNet` computes it from
 * bf16 `a`, `A_log` and `dt_bias`. */
export class MossTextLogDecay {
  /** `aLog` and `dtBias` `[Hv]` (borrowed). */
  constructor(readonly aLog: MlxArray, readonly dtBias: MlxArray) {}

  /** torch's `softplus` on float32 `x` (borrowed): `x` above its threshold of 20; below it torch computes
   * `log1p(exp(x))` and this computes `logaddexp(x, 0)` (MLX binds no log1p here): not the same operations, so the two
   * can differ in float32 rounding, which the reference comparison measures. Returns an owned float32 array. */
  softplus(x: MlxArray): MlxArray {
    using zero = ops.scalarLike(0, x), threshold = ops.scalarLike(20, x);
    using smooth = ops.logaddexp(x, zero);
    using above = ops.greater(x, threshold);
    return ops.where(above, x, smooth);
  }

  /** `a` `[1, L, Hv]` (borrowed) to the owned float32 log-decay `[1, L, Hv]`. */
  forward(a: MlxArray): MlxArray {
    using aLog = this.aLog.astype(Dtype.float32), dtBias = this.dtBias.astype(Dtype.float32), aWide = a.astype(Dtype.float32);
    using rate = ops.exp(aLog);
    using negRate = ops.neg(rate);
    using x = ops.add(aWide, dtBias);
    using softplus = this.softplus(x);
    return ops.mul(negRate, softplus);
  }
}

/** The gated delta rule as transformers' `torch_chunk_gated_delta_rule` runs it on a whole prompt from a zero state, in its
 * dtypes and operation order up to the recurrence: q and k l2-normalized in bf16 (`MossTextL2Norm`); q, k, v and beta
 * (`sigmoid(b)` stored in bf16) widened to float32; q scaled by `keyDim ** -0.5` in float32; the float32 log-decay
 * (`MossTextLogDecay`); the result stored in the input dtype once. The recurrence differs in order: the reference solves
 * it in 64-token chunks (cumulative log-decays, `exp` of their differences, a triangular solve), while
 * `kernels/gated-delta-float32` steps token by token with each step's `exp(g)`. Both are float32, algebraically equal,
 * and differ in rounding; the reference comparison measures by how much. */
export class MossTextDeltaRecurrence {
  readonly #norm = new MossTextL2Norm();
  /** torch's `1 / (Dk ** 0.5)`, applied to float32 values. */
  readonly #scale: number;

  /** `keyDim` a multiple of 32 (the kernel's lanes). */
  constructor(readonly logDecay: MossTextLogDecay, keyDim: number) {
    if (keyDim % 32 !== 0) throw new RangeError(`delta recurrence: key head size ${keyDim} is not a multiple of 32`);
    this.#scale = f32(1 / Math.sqrt(keyDim));
  }

  /** `q`, `k` `[1, L, Hk, Dk]` and `v` `[1, L, Hv, Dv]` from the convolution, `a` and `b` `[1, L, Hv]` from their
   * projections, all in the input dtype (borrowed); returns the owned outputs `[1, L, Hv, Dv]` in that dtype. */
  forward(q: MlxArray, k: MlxArray, v: MlxArray, a: MlxArray, b: MlxArray): MlxArray {
    using qNormal = this.#norm.forward(q), kNormal = this.#norm.forward(k);
    using qWide = qNormal.astype(Dtype.float32), kWide = kNormal.astype(Dtype.float32), vWide = v.astype(Dtype.float32);
    using qScaled = ops.mulScalar(qWide, this.#scale);
    using beta = inFloat(b, wide => ops.sigmoid(wide));
    using betaWide = beta.astype(Dtype.float32);
    using g = this.logDecay.forward(a);
    using decay = ops.exp(g);
    using y = gatedDeltaFloat32(qScaled, kWide, vWide, decay, betaWide);
    return y.astype(v.dtype);
  }
}

/** `Qwen3_5GatedDeltaNet` over a whole prompt from a zero state: the qkv, z, b
 * and a projections, the causal depthwise convolution with SiLU, the gated delta
 * rule (`MossTextDeltaRecurrence`), the gated norm with z, and the output
 * projection. */
export class MossTextDeltaMixer {
  readonly #conv: MlxArray;

  /** `convWeight` is the checkpoint's `[C, 1, K]`; the layer keeps its own `[C, K, 1]` copy. */
  constructor(readonly qkv: MossLinear, readonly z: MossLinear, readonly b: MossLinear, readonly a: MossLinear, readonly out: MossLinear,
    convWeight: MlxArray, readonly recurrence: MossTextDeltaRecurrence, readonly norm: MossTextGatedNorm, readonly shape: MossDeltaShape) {
    using moved = ops.transposeAxes(convWeight, [0, 2, 1]);
    this.#conv = ops.contiguous(moved);
  }

  forward(x: MlxArray): MlxArray {
    const { keyHeads, valueHeads, keyDim, valueDim } = this.shape, length = x.shape[1]!;
    const channels = this.#conv.shape[0]!, kernel = this.#conv.shape[1]!;
    using mixed = this.qkv.forward(x);
    using padded = ops.pad(mixed, [[0, 0], [kernel - 1, 0], [0, 0]]);
    using convolved = ops.conv1d(padded, this.#conv, 1, 0, 1, channels);
    using activated = inFloat(convolved, torchSilu);
    const [qFlat, kFlat, vFlat] = ops.split(activated, [keyHeads * keyDim, 2 * keyHeads * keyDim], -1);
    using qs = qFlat!, ks = kFlat!, vs = vFlat!;
    using qHeads = ops.reshape(qs, [1, length, keyHeads, keyDim]), kHeads = ops.reshape(ks, [1, length, keyHeads, keyDim]);
    using v = ops.reshape(vs, [1, length, valueHeads, valueDim]);
    using bProj = this.b.forward(x), aProj = this.a.forward(x);
    using y = this.recurrence.forward(qHeads, kHeads, v, aProj, bProj);
    using zFlat = this.z.forward(x);
    using zHeads = ops.reshape(zFlat, [1, length, valueHeads, valueDim]);
    using gated = this.norm.forward(y, zHeads);
    using merged = ops.reshape(gated, [1, length, valueHeads * valueDim]);
    return this.out.forward(merged);
  }

  dispose(): void {
    for (const linear of [this.qkv, this.z, this.b, this.a, this.out]) linear.dispose();
    this.#conv.dispose();
  }
}

/** `Qwen3_5MLP`: `down(silu(gate(x)) * up(x))`, SiLU applied as torch applies it to bf16. */
export class MossTextMlp {
  constructor(readonly gate: MossLinear, readonly up: MossLinear, readonly down: MossLinear) {}

  forward(x: MlxArray): MlxArray {
    using g = this.gate.forward(x);
    using activated = inFloat(g, torchSilu);
    using u = this.up.forward(x);
    using hidden = ops.mul(activated, u);
    return this.down.forward(hidden);
  }

  dispose(): void { for (const linear of [this.gate, this.up, this.down]) linear.dispose(); }
}

/** A linear-attention decoder layer: pre-norm Gated DeltaNet and MLP, each residual. */
export class MossTextDeltaLayer {
  constructor(readonly inputNorm: MossTextRmsNorm, readonly mixer: MossTextDeltaMixer,
    readonly postNorm: MossTextRmsNorm, readonly mlp: MossTextMlp) {}

  /** `_tables` is the attention layers' input; a linear-attention layer reads no positions. */
  forward(x: MlxArray, _tables: MossTextRopeTables): MlxArray {
    using normed = this.inputNorm.forward(x);
    using mixed = this.mixer.forward(normed);
    using h = ops.add(x, mixed);
    using normed2 = this.postNorm.forward(h);
    using fed = this.mlp.forward(normed2);
    return ops.add(h, fed);
  }

  dispose(): void { this.inputNorm.dispose(); this.mixer.dispose(); this.postNorm.dispose(); this.mlp.dispose(); }
}

/** A full-attention decoder layer: pre-norm gated attention and MLP, each residual. */
export class MossTextAttentionLayer {
  constructor(readonly inputNorm: MossTextRmsNorm, readonly attention: MossTextAttention,
    readonly postNorm: MossTextRmsNorm, readonly mlp: MossTextMlp) {}

  forward(x: MlxArray, tables: MossTextRopeTables): MlxArray {
    using normed = this.inputNorm.forward(x);
    using attended = this.attention.forward(normed, tables);
    using h = ops.add(x, attended);
    using normed2 = this.postNorm.forward(h);
    using fed = this.mlp.forward(normed2);
    return ops.add(h, fed);
  }

  dispose(): void { this.inputNorm.dispose(); this.attention.dispose(); this.postNorm.dispose(); this.mlp.dispose(); }
}
