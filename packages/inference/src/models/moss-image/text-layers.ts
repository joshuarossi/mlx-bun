// MOSS's Qwen3.5 conditioner layers with the pinned MFLUX operation order.
// All numerical choices are fixed by construction; borrowed weights remain
// owned by the conditioner's Weights instance.
import { MlxArray } from "@mlx-bun/mlx/array";
import type { CompiledFunction } from "@mlx-bun/mlx/compile";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { gatedDeltaChunked } from "../../kernels/gated-delta-chunked";
import { causalDepthwiseConv } from "../../kernels/causal-depthwise-conv";
import { compiledSoftplus } from "../../kernels/softplus";
import type { MossLinear, MossSilu } from "./layers";

/** Explicit float32 RMS normalization, with a mean followed by rsqrt. */
export class MossFloat32RmsNorm {
  constructor(readonly eps: number) {}
  forward(x: MlxArray): MlxArray {
    using wide = x.astype(Dtype.float32);
    using squares = ops.square(wide);
    using mean = ops.meanAxis(squares, -1, true);
    using epsilon = ops.scalarLike(this.eps, mean);
    using shifted = ops.add(mean, epsilon);
    using inverse = ops.rsqrt(shifted);
    return ops.mul(wide, inverse);
  }
}

/** Qwen's q/k unit normalization in float32, without bf16 intermediate stores. */
export class MossTextL2Norm {
  forward(x: MlxArray): MlxArray {
    using wide = x.astype(Dtype.float32);
    using square = ops.mul(wide, wide);
    using sum = ops.sumAxis(square, -1, true);
    using eps = ops.scalarLike(1e-6, sum);
    using shifted = ops.add(sum, eps);
    using inverse = ops.rsqrt(shifted);
    return ops.mul(wide, inverse);
  }
}

/** Normalize and apply Qwen's stored (1 + gamma) gain in float32, then cast once. */
export class MossTextRmsNorm {
  readonly #scale: MlxArray;
  constructor(gamma: MlxArray, readonly normalization: Pick<MossFloat32RmsNorm, "forward">) {
    using wide = gamma.astype(Dtype.float32);
    using one = ops.scalarLike(1, wide);
    this.#scale = ops.add(one, wide);
  }
  forward(x: MlxArray): MlxArray {
    using normalized = this.normalization.forward(x);
    using scaled = ops.mul(normalized, this.#scale);
    return scaled.astype(x.dtype);
  }
  dispose(): void { this.#scale.dispose(); }
}

/** Normalize in float32, round to the input dtype, multiply the stored gain,
 * then multiply float32 SiLU(gate) and cast back to the input dtype. */
export class MossTextGatedNorm {
  constructor(readonly weight: MlxArray, readonly normalization: Pick<MossFloat32RmsNorm, "forward">,
    readonly activation: Pick<MossSilu, "forward">) {}
  forward(x: MlxArray, gate: MlxArray): MlxArray {
    using normalizedWide = this.normalization.forward(x);
    using normalized = normalizedWide.astype(x.dtype);
    using weighted = ops.mul(this.weight, normalized);
    using gateWide = gate.astype(Dtype.float32);
    using activated = this.activation.forward(gateWide);
    using gated = ops.mul(weighted, activated);
    return gated.astype(x.dtype);
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

/** Native partial RoPE on borrowed [B,H,L,D] arrays. */
export class MossTextRope {
  constructor(readonly rotaryDims: number, readonly base: number) {}
  apply(x: MlxArray): MlxArray { return ops.rope(x, this.rotaryDims, this.base, 0, null); }
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
    readonly qNorm: Pick<MossTextRmsNorm, "forward" | "dispose">, readonly kNorm: Pick<MossTextRmsNorm, "forward" | "dispose">,
    readonly rope: Pick<MossTextRope, "apply">, readonly shape: MossTextAttentionShape) {}

  forward(x: MlxArray): MlxArray {
    const { heads, kvHeads, headDim } = this.shape, length = x.shape[1]!;
    using packed = this.q.forward(x);
    using perHead = ops.reshape(packed, [1, length, heads, 2 * headDim]);
    const [query, gate] = ops.split(perHead, [headDim], -1);
    using q = query!, g = gate!;
    using keyFlat = this.k.forward(x), valueFlat = this.v.forward(x);
    using key = ops.reshape(keyFlat, [1, length, kvHeads, headDim]), value = ops.reshape(valueFlat, [1, length, kvHeads, headDim]);
    using qn = this.qNorm.forward(q), kn = this.kNorm.forward(key);
    using qt = ops.transposeAxes(qn, [0, 2, 1, 3]), kt = ops.transposeAxes(kn, [0, 2, 1, 3]), vt = ops.transposeAxes(value, [0, 2, 1, 3]);
    using qr = this.rope.apply(qt), kr = this.rope.apply(kt);
    using attended = ops.sdpa(qr, kr, vt, headDim ** -0.5, "causal");
    using merged = ops.transposeAxes(attended, [0, 2, 1, 3]);
    using flat = ops.reshape(merged, [1, length, heads * headDim]);
    using gateFlat = ops.reshape(g, [1, length, heads * headDim]);
    using sig = ops.sigmoid(gateFlat);
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

/** -exp(A_log) * compiled softplus(a + dt_bias), entirely float32. */
export class MossTextLogDecay {
  readonly #softplus: CompiledFunction;
  constructor(readonly aLog: MlxArray, readonly dtBias: MlxArray) { this.#softplus = compiledSoftplus(); }
  softplus(x: MlxArray): MlxArray { return this.#softplus.apply([x])[0]!; }
  forward(a: MlxArray): MlxArray {
    using aLog = this.aLog.astype(Dtype.float32), dtBias = this.dtBias.astype(Dtype.float32), aWide = a.astype(Dtype.float32);
    using rate = ops.exp(aLog);
    using negRate = ops.neg(rate);
    using x = ops.add(aWide, dtBias);
    using softplus = this.softplus(x);
    return ops.mul(negRate, softplus);
  }
  dispose(): void { this.#softplus.dispose(); }
}

/** Repeat each key head consecutively, including the identity repeat. */
function repeatHeads(x: MlxArray, heads: number): MlxArray {
  const [batch, length, sourceHeads, width] = x.shape as [number, number, number, number];
  if (heads % sourceHeads) throw new RangeError("value head count must be a multiple of key head count");
  using expanded = ops.reshape(x, [batch, length, sourceHeads, 1, width]);
  using repeated = ops.broadcastTo(expanded, [batch, length, sourceHeads, heads / sourceHeads, width]);
  return ops.reshape(repeated, [batch, length, heads, width]);
}

/** Normalize repeated q/k heads in float32, keep beta and log-decay in
 * float32, run the chunked rule from zero state, then cast to v's dtype. */
export class MossTextDeltaRecurrence {
  constructor(readonly logDecay: Pick<MossTextLogDecay, "forward" | "dispose">,
    readonly normalization: Pick<MossTextL2Norm, "forward">) {}
  forward(q: MlxArray, k: MlxArray, v: MlxArray, a: MlxArray, b: MlxArray): MlxArray {
    using qRepeated = repeatHeads(q, v.shape[2]!), kRepeated = repeatHeads(k, v.shape[2]!);
    using qNormal = this.normalization.forward(qRepeated), kNormal = this.normalization.forward(kRepeated);
    using vWide = v.astype(Dtype.float32), bWide = b.astype(Dtype.float32);
    using beta = ops.sigmoid(bWide);
    using g = this.logDecay.forward(a);
    using output = gatedDeltaChunked(qNormal, kNormal, vWide, g, beta);
    return output.astype(v.dtype);
  }
  dispose(): void { this.logDecay.dispose(); }
}

/** The ordered causal-convolution kernel's sole owning layer. Weight borrowed. */
export class MossTextCausalConv {
  constructor(readonly weight: MlxArray) {}
  forward(x: MlxArray): MlxArray { return causalDepthwiseConv(x, this.weight); }
}

/** `Qwen3_5GatedDeltaNet` over a whole prompt from a zero state: the qkv, z, b
 * and a projections, the causal depthwise convolution with SiLU, the gated delta
 * rule (`MossTextDeltaRecurrence`), the gated norm with z, and the output
 * projection. */
export class MossTextDeltaMixer {
  constructor(readonly qkv: MossLinear, readonly z: MossLinear, readonly b: MossLinear, readonly a: MossLinear, readonly out: MossLinear,
    readonly conv: Pick<MossTextCausalConv, "forward">, readonly recurrence: Pick<MossTextDeltaRecurrence, "forward" | "dispose">,
    readonly norm: Pick<MossTextGatedNorm, "forward">, readonly shape: MossDeltaShape, readonly activation: Pick<MossSilu, "forward">) {}

  forward(x: MlxArray): MlxArray {
    const { keyHeads, valueHeads, keyDim, valueDim } = this.shape, length = x.shape[1]!;
    using mixed = this.qkv.forward(x);
    using convolved = this.conv.forward(mixed);
    using activated = this.activation.forward(convolved);
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
    this.recurrence.dispose();
  }
}

/** Qwen MLP: down(compiled SiLU(gate(x)) * up(x)), preserving the activation dtype. */
export class MossTextMlp {
  constructor(readonly gate: MossLinear, readonly up: MossLinear, readonly down: MossLinear, readonly activation: Pick<MossSilu, "forward">) {}

  forward(x: MlxArray): MlxArray {
    using g = this.gate.forward(x);
    using activated = this.activation.forward(g);
    using u = this.up.forward(x);
    using hidden = ops.mul(activated, u);
    return this.down.forward(hidden);
  }

  dispose(): void { for (const linear of [this.gate, this.up, this.down]) linear.dispose(); }
}

/** A linear-attention decoder layer: pre-norm Gated DeltaNet and MLP, each residual. */
export class MossTextDeltaLayer {
  constructor(readonly inputNorm: Pick<MossTextRmsNorm, "forward" | "dispose">, readonly mixer: Pick<MossTextDeltaMixer, "forward" | "dispose">,
    readonly postNorm: Pick<MossTextRmsNorm, "forward" | "dispose">, readonly mlp: Pick<MossTextMlp, "forward" | "dispose">) {}

  forward(x: MlxArray): MlxArray {
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
  constructor(readonly inputNorm: Pick<MossTextRmsNorm, "forward" | "dispose">, readonly attention: Pick<MossTextAttention, "forward" | "dispose">,
    readonly postNorm: Pick<MossTextRmsNorm, "forward" | "dispose">, readonly mlp: Pick<MossTextMlp, "forward" | "dispose">) {}

  forward(x: MlxArray): MlxArray {
    using normed = this.inputNorm.forward(x);
    using attended = this.attention.forward(normed);
    using h = ops.add(x, attended);
    using normed2 = this.postNorm.forward(h);
    using fed = this.mlp.forward(normed2);
    return ops.add(h, fed);
  }

  dispose(): void { this.inputNorm.dispose(); this.attention.dispose(); this.postNorm.dispose(); this.mlp.dispose(); }
}
