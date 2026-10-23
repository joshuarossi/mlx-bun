// The layers of MOSS-Image's conditioner, the Qwen3.5-9B language model the
// pipeline runs once per prompt (transformers' Qwen3_5TextModel, no head, no
// cache): each does one job in the reference's dtypes and binds the kernels it
// needs. Projections and gains are borrowed from the component's `Weights`;
// a layer frees only what it made.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { gatedDeltaUpdate } from "../../kernels/delta/gated";
import { gatedRmsNorm } from "../../kernels/gated-rms-norm";
import type { MossLinear } from "./layers";

const f32 = Math.fround;

/** `x` (borrowed) through a float32 function, cast back to `x`'s dtype once:
 * how torch applies an activation to a bf16 tensor. */
function inFloat(x: MlxArray, fn: (wide: MlxArray) => MlxArray): MlxArray {
  using wide = x.astype(Dtype.float32);
  using out = fn(wide);
  return out.astype(x.dtype);
}

/** transformers' `l2norm` (`x * rsqrt(sum(x^2) + 1e-6)`) in float32, times `scale`, cast back once. */
function l2Normalized(x: MlxArray, scale: number): MlxArray {
  return inFloat(x, wide => {
    using squares = ops.square(wide);
    using sum = ops.sumAxis(squares, -1, true);
    using eps = ops.scalarLike(1e-6, sum);
    using shifted = ops.add(sum, eps);
    using inv = ops.rsqrt(shifted);
    using unit = ops.mul(wide, inv);
    return ops.mulScalar(unit, scale);
  });
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

/** `Qwen3_5RMSNormGated`: the gain in the input dtype, then `silu(gate)` in float32 (the gated RMS norm kernel). */
export class MossTextGatedNorm {
  constructor(readonly weight: MlxArray, readonly eps: number) {}

  /** `x` and `gate` equal-shaped and row-contiguous (borrowed). */
  forward(x: MlxArray, gate: MlxArray): MlxArray {
    return gatedRmsNorm(x, gate, this.weight, this.eps);
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

/** `Qwen3_5GatedDeltaNet` over a whole prompt from a zero state: the qkv, z, b
 * and a projections, the causal depthwise convolution with SiLU, l2-normalized q
 * (scaled by `keyDim ** -0.5`) and k, the gated delta recurrence kernel, the
 * gated norm with z, and the output projection. */
export class MossTextDeltaMixer {
  readonly #conv: MlxArray;

  /** `convWeight` is the checkpoint's `[C, 1, K]`; the layer keeps its own `[C, K, 1]` copy. */
  constructor(readonly qkv: MossLinear, readonly z: MossLinear, readonly b: MossLinear, readonly a: MossLinear, readonly out: MossLinear,
    convWeight: MlxArray, readonly aLog: MlxArray, readonly dtBias: MlxArray, readonly norm: MossTextGatedNorm, readonly shape: MossDeltaShape) {
    using moved = ops.transposeAxes(convWeight, [0, 2, 1]);
    this.#conv = ops.contiguous(moved);
  }

  forward(x: MlxArray): MlxArray {
    const { keyHeads, valueHeads, keyDim, valueDim } = this.shape, length = x.shape[1]!;
    const channels = this.#conv.shape[0]!, kernel = this.#conv.shape[1]!;
    using mixed = this.qkv.forward(x);
    using padded = ops.pad(mixed, [[0, 0], [kernel - 1, 0], [0, 0]]);
    using convolved = ops.conv1d(padded, this.#conv, 1, 0, 1, channels);
    using activated = inFloat(convolved, wide => ops.silu(wide));
    const [qFlat, kFlat, vFlat] = ops.split(activated, [keyHeads * keyDim, 2 * keyHeads * keyDim], -1);
    using qs = qFlat!, ks = kFlat!, vs = vFlat!;
    using qHeads = ops.reshape(qs, [1, length, keyHeads, keyDim]), kHeads = ops.reshape(ks, [1, length, keyHeads, keyDim]);
    using q = l2Normalized(qHeads, Math.pow(keyDim, -0.5)), k = l2Normalized(kHeads, 1);
    using v = ops.reshape(vs, [1, length, valueHeads, valueDim]);
    using bProj = this.b.forward(x), aProj = this.a.forward(x);
    const [recurred, state] = gatedDeltaUpdate(q, k, v, aProj, bProj, this.aLog, this.dtBias, null);
    state!.dispose();
    using y = recurred!;
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
    using activated = inFloat(g, wide => ops.silu(wide));
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
