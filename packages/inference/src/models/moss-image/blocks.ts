// The MOSS-Image DiT's layers (the snapshot's pipeline_moss_image.py), each
// doing one job in the reference's dtypes: bf16 activations, float32 RMS
// statistics, the timestep sinusoid in float64, the velocity in float32. They
// take the projections and norms their graph bound; the graph arranges them.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { MossLinear, MossRmsNorm, MossSitu } from "./layers";
import type { MossRope, MossRopeTables } from "./rope";

/** Attention over `[1, N, dim]` q/k/v (consumed): per-head RMS norms on q and k,
 * the four-axis rotation on both, SDPA at `head_dim ** -0.5`, heads merged. */
function attend(q: MlxArray, k: MlxArray, v: MlxArray, qNorm: MossRmsNorm, kNorm: MossRmsNorm,
  rope: MossRope, tables: MossRopeTables, heads: number): MlxArray {
  const [batch, length, dim] = q.shape as [number, number, number];
  const shape = [batch, length, heads, dim / heads];
  const split = (x: MlxArray) => { const out = ops.reshape(x, shape); x.dispose(); return out; };
  using qh = split(q), kh = split(k), vh = split(v);
  using qn = qNorm.forward(qh), kn = kNorm.forward(kh);
  using qr = rope.apply(qn, tables), kr = rope.apply(kn, tables);
  using qt = ops.transposeAxes(qr, [0, 2, 1, 3]), kt = ops.transposeAxes(kr, [0, 2, 1, 3]), vt = ops.transposeAxes(vh, [0, 2, 1, 3]);
  using attended = ops.sdpa(qt, kt, vt, Math.pow(dim / heads, -0.5), "");
  using merged = ops.transposeAxes(attended, [0, 2, 1, 3]);
  return ops.reshape(merged, [batch, length, dim]);
}

/** Joint-block attention: separate bias-free q, k, v projections and the output projection. */
export class MossJointAttention {
  constructor(readonly q: MossLinear, readonly k: MossLinear, readonly v: MossLinear, readonly o: MossLinear,
    readonly qNorm: MossRmsNorm, readonly kNorm: MossRmsNorm, readonly rope: MossRope, readonly heads: number) {}

  forward(y: MlxArray, tables: MossRopeTables): MlxArray {
    using attended = attend(this.q.forward(y), this.k.forward(y), this.v.forward(y), this.qNorm, this.kNorm, this.rope, tables, this.heads);
    return this.o.forward(attended);
  }

  dispose(): void { for (const linear of [this.q, this.k, this.v, this.o]) linear.dispose(); }
}

/** Text-refiner attention (`_TextBlock`): one fused qkv projection (with bias) split in thirds, and the output projection. */
export class MossRefinerAttention {
  constructor(readonly qkv: MossLinear, readonly proj: MossLinear, readonly qNorm: MossRmsNorm, readonly kNorm: MossRmsNorm,
    readonly rope: MossRope, readonly heads: number) {}

  forward(y: MlxArray, tables: MossRopeTables): MlxArray {
    using fused = this.qkv.forward(y);
    const dim = fused.shape.at(-1)! / 3;
    const [q, k, v] = ops.split(fused, [dim, 2 * dim], -1);
    using attended = attend(q!, k!, v!, this.qNorm, this.kNorm, this.rope, tables, this.heads);
    return this.proj.forward(attended);
  }

  dispose(): void { this.qkv.dispose(); this.proj.dispose(); }
}

/** Joint-block feed-forward: one up-and-gate projection (hidden first, gate second), SITU, down. */
export class MossJointFeedForward {
  constructor(readonly upGate: MossLinear, readonly down: MossLinear, readonly activation: MossSitu) {}

  forward(y: MlxArray): MlxArray {
    using upGate = this.upGate.forward(y);
    const [hidden, gate] = ops.split(upGate, [upGate.shape.at(-1)! / 2], -1);
    using activated = this.activation.forward(hidden!, gate!);
    return this.down.forward(activated);
  }

  dispose(): void { this.upGate.dispose(); this.down.dispose(); }
}

/** Text-refiner feed-forward: separate up and gate projections (with biases), SITU, down. */
export class MossRefinerFeedForward {
  constructor(readonly up: MossLinear, readonly gate: MossLinear, readonly down: MossLinear, readonly activation: MossSitu) {}

  forward(y: MlxArray): MlxArray {
    using activated = this.activation.forward(this.up.forward(y), this.gate.forward(y));
    return this.down.forward(activated);
  }

  dispose(): void { for (const linear of [this.up, this.gate, this.down]) linear.dispose(); }
}

/** The modulation one timestep gives every joint block: shift, `1 + scale` and
 * gate for attention and for the feed-forward, each `[1, 1, dim]` bf16. */
export interface MossBlockModulation {
  readonly shiftA: MlxArray; readonly scaleA: MlxArray; readonly gateA: MlxArray;
  readonly shiftF: MlxArray; readonly scaleF: MlxArray; readonly gateF: MlxArray;
}

/** A joint image+text block (`_Block`): modulated attention and feed-forward, gated residuals. */
export class MossJointBlock {
  constructor(readonly norm1: MossRmsNorm, readonly attention: MossJointAttention,
    readonly norm2: MossRmsNorm, readonly feedForward: MossJointFeedForward) {}

  /** `x` `[1, N, dim]` (borrowed) to an owned `[1, N, dim]`. */
  forward(x: MlxArray, tables: MossRopeTables, mod: MossBlockModulation): MlxArray {
    using normed = this.norm1.forward(x);
    using scaled = ops.mul(normed, mod.scaleA);
    using y = ops.add(scaled, mod.shiftA);
    using attended = this.attention.forward(y, tables);
    using gatedA = ops.mul(attended, mod.gateA);
    using h = ops.add(x, gatedA);
    using normed2 = this.norm2.forward(h);
    using scaled2 = ops.mul(normed2, mod.scaleF);
    using y2 = ops.add(scaled2, mod.shiftF);
    using fed = this.feedForward.forward(y2);
    using gatedF = ops.mul(fed, mod.gateF);
    return ops.add(h, gatedF);
  }

  dispose(): void { this.attention.dispose(); this.feedForward.dispose(); }
}

/** A text-refiner block (`_TextBlock`): unmodulated pre-norm attention and feed-forward. */
export class MossRefinerBlock {
  constructor(readonly norm1: MossRmsNorm, readonly attention: MossRefinerAttention,
    readonly norm2: MossRmsNorm, readonly feedForward: MossRefinerFeedForward) {}

  /** `x` `[1, L, dim]` (borrowed) to an owned `[1, L, dim]`. */
  forward(x: MlxArray, tables: MossRopeTables): MlxArray {
    using normed = this.norm1.forward(x);
    using attended = this.attention.forward(normed, tables);
    using h = ops.add(x, attended);
    using normed2 = this.norm2.forward(h);
    using fed = this.feedForward.forward(normed2);
    return ops.add(h, fed);
  }

  dispose(): void { this.attention.dispose(); this.feedForward.dispose(); }
}

/** The timestep sinusoid: `cat(cos(t * f), sin(t * f))`, `f_k = 10000 ** (-k / half)`,
 * in float64, cast to float32 (the reference's training computation). */
export function timestepSinusoid(timestep: number, freqDim: number): Float32Array {
  const half = freqDim / 2, out = new Float32Array(freqDim);
  for (let k = 0; k < half; k++) {
    const phase = timestep * Math.pow(10000, -k / half);
    out[k] = Math.cos(phase);
    out[half + k] = Math.sin(phase);
  }
  return out;
}

/** `time_embedding`: the sinusoid (bf16) through a projection, SiLU and a second projection. */
export class MossTimestepEmbedder {
  constructor(readonly inProj: MossLinear, readonly outProj: MossLinear, readonly freqDim: number) {}

  /** The timestep's `[1, dim]` bf16 embedding. Owned. */
  forward(timestep: number): MlxArray {
    using sinusoid = MlxArray.fromFloat32(timestepSinusoid(timestep, this.freqDim), [1, this.freqDim]);
    using narrow = sinusoid.astype(Dtype.bfloat16);
    using hidden = this.inProj.forward(narrow);
    // nn.SiLU on bf16 computes in float and rounds once.
    using wide = hidden.astype(Dtype.float32);
    using activated = ops.silu(wide);
    using rounded = activated.astype(Dtype.bfloat16);
    return this.outProj.forward(rounded);
  }

  dispose(): void { this.inProj.dispose(); this.outProj.dispose(); }
}

/** What one timestep's modulation layer produces. Owned; disposing frees every part. */
export interface MossTimestepModulation extends Disposable {
  readonly block: MossBlockModulation;
  readonly headShift: MlxArray;
  readonly headScale: MlxArray;
}

/** `shared_block_modulation` (six parts) and `video_head_modulation` (two) from the timestep embedding. */
export class MossModulation {
  constructor(readonly block: MossLinear, readonly head: MossLinear, readonly dim: number) {}

  forward(time: MlxArray): MossTimestepModulation {
    const dim = this.dim;
    using block = this.block.forward(time);
    using head = this.head.forward(time);
    const part = (source: MlxArray, index: number) => {
      using slice = source.slice([0, index * dim], [1, (index + 1) * dim]);
      return ops.reshape(slice, [1, 1, dim]);
    };
    const plusOne = (x: MlxArray) => { using one = ops.scalarLike(1, x); using held = x; return ops.add(one, held); };
    const parts = [0, 1, 2, 3, 4, 5].map(i => part(block, i));
    const modulation: MossBlockModulation = {
      shiftA: parts[0]!, scaleA: plusOne(parts[1]!), gateA: parts[2]!,
      shiftF: parts[3]!, scaleF: plusOne(parts[4]!), gateF: parts[5]!,
    };
    const headShift = part(head, 0), headScale = plusOne(part(head, 1));
    const owned = [...Object.values(modulation), headShift, headScale];
    return { block: modulation, headShift, headScale, [Symbol.dispose]() { for (const array of owned) array.dispose(); } };
  }

  dispose(): void { this.block.dispose(); this.head.dispose(); }
}

/** `video_embedder`: latents `[1, C, h, w]` float32 to `[1, h * w, dim]` bf16 tokens in raster order. */
export class MossLatentEmbedder {
  constructor(readonly proj: MossLinear) {}

  forward(latents: MlxArray): MlxArray {
    const [, channels, height, width] = latents.shape as [number, number, number, number];
    using flat = ops.reshape(latents, [1, channels, height * width]);
    using rows = ops.transposeAxes(flat, [0, 2, 1]);
    using narrow = rows.astype(Dtype.bfloat16);
    using packed = ops.contiguous(narrow);
    return this.proj.forward(packed);
  }

  dispose(): void { this.proj.dispose(); }
}

/** Joins image and text tokens into one sequence and takes the image tokens back out. */
export class MossTokenSequence {
  /** `[1, N, dim]` and `[1, L, dim]` (borrowed) to an owned `[1, N + L, dim]`. */
  join(image: MlxArray, text: MlxArray): MlxArray {
    return ops.concatAxis([image, text], 1);
  }

  /** The first `tokens` rows of `x` (borrowed). Owned. */
  image(x: MlxArray, tokens: number): MlxArray {
    return x.slice([0, 0, 0], [1, tokens, x.shape[2]!]);
  }
}

/** The video head: final norm, the head modulation, the final projection, and
 * the tokens back to `[1, C, h, w]` float32. */
export class MossLatentHead {
  constructor(readonly norm: MossRmsNorm, readonly proj: MossLinear) {}

  forward(tokens: MlxArray, mod: MossTimestepModulation, height: number, width: number): MlxArray {
    using normed = this.norm.forward(tokens);
    using scaled = ops.mul(normed, mod.headScale);
    using shifted = ops.add(scaled, mod.headShift);
    using projected = this.proj.forward(shifted);
    const channels = projected.shape[2]!;
    using channelsFirst = ops.transposeAxes(projected, [0, 2, 1]);
    using shaped = ops.reshape(channelsFirst, [1, channels, height, width]);
    return shaped.astype(Dtype.float32);
  }

  dispose(): void { this.proj.dispose(); }
}
