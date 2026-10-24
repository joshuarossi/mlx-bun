// MOSS's FLUX.2 VAE layers. Spatial blocks exchange NCHW arrays as MFLUX does;
// Conv2d, GroupNorm and attention projections use NHWC internally. Weights are
// borrowed bf16 arrays owned by Flux2VaeWeights. Each layer owns only its views.
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { MossLinear, MossSilu } from "./layers";

export class Flux2LatentInput {
  /** Borrowed float32 packed NCHW latents to an owned bf16 array. */
  forward(latents: MlxArray): MlxArray { return latents.astype(Dtype.bfloat16); }
}

/** bf16 x * sqrt(running_var + eps) + running_mean, in that order. */
export class Flux2LatentDenormalization {
  readonly #scale: MlxArray;
  readonly #shift: MlxArray;

  constructor(runningMean: MlxArray, runningVar: MlxArray, eps: number) {
    const channels = runningMean.shape[0]!;
    using variance = ops.reshape(runningVar, [1, channels, 1, 1]);
    using epsilon = ops.scalarLike(eps, variance);
    using shifted = ops.add(variance, epsilon);
    const scale = ops.sqrt(shifted);
    try { this.#shift = ops.reshape(runningMean, [1, channels, 1, 1]); }
    catch (error) { scale.dispose(); throw error; }
    this.#scale = scale;
  }

  /** Borrowed bf16 [B, C, h, w] to an owned bf16 array of that shape. */
  forward(latents: MlxArray): MlxArray {
    using scaled = ops.mul(latents, this.#scale);
    return ops.add(scaled, this.#shift);
  }

  dispose(): void { this.#scale.dispose(); this.#shift.dispose(); }
}

export class Flux2Unpatchify {
  constructor(readonly patch: number) {}

  /** Packed [B, C*p*p, h, w] to plain [B, C, h*p, w*p], both NCHW. */
  forward(z: MlxArray): MlxArray {
    const [batch, patched, height, width] = z.shape as [number, number, number, number];
    const p = this.patch, channels = patched / (p * p);
    using split = ops.reshape(z, [batch, channels, p, p, height, width]);
    using ordered = ops.transposeAxes(split, [0, 1, 4, 2, 5, 3]);
    return ops.reshape(ordered, [batch, channels, height * p, width * p]);
  }
}

/** Native Conv2d plus its separate bias add. Input and output are NHWC. */
export class Flux2Conv2d {
  readonly #weight: MlxArray;
  readonly #padding: [number, number];

  constructor(weight: MlxArray, readonly bias: MlxArray) {
    const [, , kh, kw] = weight.shape as [number, number, number, number];
    if (kh !== kw || kh % 2 !== 1) throw new Error(`Flux2Conv2d: expected an odd square kernel, got ${kh}x${kw}`);
    this.#padding = [(kh - 1) / 2, (kh - 1) / 2];
    // MFLUX's checkpoint mapping transposes without forcing contiguous storage.
    this.#weight = ops.transposeAxes(weight, [0, 2, 3, 1]);
  }

  forward(x: MlxArray): MlxArray {
    using convolved = ops.conv2d(x, this.#weight, [1, 1], this.#padding);
    return ops.add(convolved, this.bias);
  }

  dispose(): void { this.#weight.dispose(); }
}

/** The decoder's conv_in/conv_out wrappers exchange NCHW arrays. */
export class Flux2SpatialConv {
  constructor(readonly conv: Pick<Flux2Conv2d, "forward" | "dispose">) {}
  forward(x: MlxArray): MlxArray {
    using nhwc = ops.transposeAxes(x, [0, 2, 3, 1]);
    using convolved = this.conv.forward(nhwc);
    return ops.transposeAxes(convolved, [0, 3, 1, 2]);
  }
  dispose(): void { this.conv.dispose(); }
}

/** Flux2VAE.decode keeps divide-by-one then add-zero before post_quant_conv.
 * Keep both operations, including their signed-zero behavior. */
export class Flux2PostQuantConv {
  constructor(readonly conv: Pick<Flux2Conv2d, "forward" | "dispose">) {}
  forward(x: MlxArray): MlxArray {
    using one = ops.scalarLike(1, x), zero = ops.scalarLike(0, x);
    using divided = ops.div(x, one);
    using shifted = ops.add(divided, zero);
    using nhwc = ops.transposeAxes(shifted, [0, 2, 3, 1]);
    using convolved = this.conv.forward(nhwc);
    return ops.transposeAxes(convolved, [0, 3, 1, 2]);
  }
  dispose(): void { this.conv.dispose(); }
}

/** MFLUX's nn.GroupNorm(pytorch_compatible=True): a flattened float32
 * fast.layer_norm per group, separate affine operations, then bf16 output. */
export class Flux2GroupNorm {
  constructor(readonly weight: MlxArray, readonly bias: MlxArray, readonly groups: number, readonly eps: number) {}

  /** Borrowed NHWC activation to an owned bf16 NHWC activation. */
  forward(x: MlxArray): MlxArray {
    const [batch, height, width, channels] = x.shape as [number, number, number, number];
    const positions = height * width, groupSize = channels / this.groups;
    using wide = x.astype(Dtype.float32);
    using split = ops.reshape(wide, [batch, positions, this.groups, groupSize]);
    using grouped = ops.transposeAxes(split, [0, 2, 1, 3]);
    using rows = ops.reshape(grouped, [batch, this.groups, positions * groupSize]);
    using normalized = ops.layerNorm(rows, null, null, this.eps);
    using groupedOut = ops.reshape(normalized, [batch, this.groups, positions, groupSize]);
    using ordered = ops.transposeAxes(groupedOut, [0, 2, 1, 3]);
    using nhwc = ops.reshape(ordered, [batch, height, width, channels]);
    using scaled = ops.mul(this.weight, nhwc);
    using shifted = ops.add(scaled, this.bias);
    return shifted.astype(Dtype.bfloat16);
  }
}

export class Flux2SpatialNorm {
  constructor(readonly norm: Pick<Flux2GroupNorm, "forward">) {}
  forward(x: MlxArray): MlxArray {
    using nhwc = ops.transposeAxes(x, [0, 2, 3, 1]);
    using normed = this.norm.forward(nhwc);
    return ops.transposeAxes(normed, [0, 3, 1, 2]);
  }
}

function residualBranch(x: MlxArray, norm1: Pick<Flux2GroupNorm, "forward">, conv1: Pick<Flux2Conv2d, "forward">,
  norm2: Pick<Flux2GroupNorm, "forward">, conv2: Pick<Flux2Conv2d, "forward">, activation: Pick<MossSilu, "forward">): MlxArray {
  using normed1 = norm1.forward(x);
  using activated1 = activation.forward(normed1);
  using hidden = conv1.forward(activated1);
  using normed2 = norm2.forward(hidden);
  using activated2 = activation.forward(normed2);
  return conv2.forward(activated2);
}

export class Flux2ResnetBlock {
  constructor(readonly norm1: Pick<Flux2GroupNorm, "forward">, readonly conv1: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly norm2: Pick<Flux2GroupNorm, "forward">, readonly conv2: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly activation: Pick<MossSilu, "forward">) {}

  /** Borrowed NCHW activation to an owned NCHW activation. */
  forward(x: MlxArray): MlxArray {
    using residual = ops.transposeAxes(x, [0, 2, 3, 1]);
    using branch = residualBranch(residual, this.norm1, this.conv1, this.norm2, this.conv2, this.activation);
    using added = ops.add(branch, residual);
    return ops.transposeAxes(added, [0, 3, 1, 2]);
  }

  dispose(): void { this.conv1.dispose(); this.conv2.dispose(); }
}

export class Flux2ShortcutResnetBlock {
  constructor(readonly norm1: Pick<Flux2GroupNorm, "forward">, readonly conv1: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly norm2: Pick<Flux2GroupNorm, "forward">, readonly conv2: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly shortcut: Pick<Flux2Conv2d, "forward" | "dispose">, readonly activation: Pick<MossSilu, "forward">) {}

  forward(x: MlxArray): MlxArray {
    using residual = ops.transposeAxes(x, [0, 2, 3, 1]);
    using branch = residualBranch(residual, this.norm1, this.conv1, this.norm2, this.conv2, this.activation);
    using skip = this.shortcut.forward(residual);
    using added = ops.add(branch, skip);
    return ops.transposeAxes(added, [0, 3, 1, 2]);
  }

  dispose(): void { this.conv1.dispose(); this.conv2.dispose(); this.shortcut.dispose(); }
}

/** One-head spatial attention. All four biased projections receive rank-four
 * NHWC inputs, exactly as MFLUX's Flux2AttentionBlock passes to nn.Linear. */
export class Flux2MidAttention {
  readonly scale: number;

  constructor(readonly norm: Pick<Flux2GroupNorm, "forward">, readonly q: MossLinear, readonly k: MossLinear,
    readonly v: MossLinear, readonly out: MossLinear, channels: number) {
    // MFLUX computes 1 / mx.sqrt(C), then the SDPA API reads a float scalar.
    // Bind that float32 sqrt/reciprocal once, rather than using a double sqrt.
    using width = MlxArray.fromInt32(new Int32Array([channels]), []);
    using root = ops.sqrt(width);
    using one = ops.scalarLike(1, root);
    using scale = ops.div(one, root);
    this.scale = scale.toFloat32()[0]!;
  }

  forward(x: MlxArray): MlxArray {
    using spatial = ops.transposeAxes(x, [0, 2, 3, 1]);
    const [batch, height, width, channels] = spatial.shape as [number, number, number, number];
    const positions = height * width, splitHead = [batch, positions, 1, channels];
    using normed = this.norm.forward(spatial);
    using q = this.q.forward(normed), k = this.k.forward(normed), v = this.v.forward(normed);
    using qs = ops.reshape(q, splitHead), ks = ops.reshape(k, splitHead), vs = ops.reshape(v, splitHead);
    using qh = ops.transposeAxes(qs, [0, 2, 1, 3]), kh = ops.transposeAxes(ks, [0, 2, 1, 3]), vh = ops.transposeAxes(vs, [0, 2, 1, 3]);
    using attended = ops.sdpa(qh, kh, vh, this.scale, "");
    using ordered = ops.transposeAxes(attended, [0, 2, 1, 3]);
    using merged = ops.reshape(ordered, [batch, height, width, channels]);
    using projected = this.out.forward(merged);
    using added = ops.add(spatial, projected);
    return ops.transposeAxes(added, [0, 3, 1, 2]);
  }

  dispose(): void { for (const linear of [this.q, this.k, this.v, this.out]) linear.dispose(); }
}

/** Scalar repeat by two along one axis: expand, broadcast, reshape. */
function repeatTwice(x: MlxArray, axis: number): MlxArray {
  const shape = x.shape, expanded = [...shape];
  expanded.splice(axis + 1, 0, 1);
  const broadcast = [...expanded];
  broadcast[axis + 1] = 2;
  const output = [...shape];
  output[axis] = output[axis]! * 2;
  using split = ops.reshape(x, expanded);
  using repeated = ops.broadcastTo(split, broadcast);
  return ops.reshape(repeated, output);
}

export class Flux2Upsample {
  constructor(readonly conv: Pick<Flux2Conv2d, "forward" | "dispose">) {}
  forward(x: MlxArray): MlxArray {
    // Match the two successive NCHW repeats before transposing for Conv2d.
    using height = repeatTwice(x, 2);
    using width = repeatTwice(height, 3);
    using nhwc = ops.transposeAxes(width, [0, 2, 3, 1]);
    using convolved = this.conv.forward(nhwc);
    return ops.transposeAxes(convolved, [0, 3, 1, 2]);
  }
  dispose(): void { this.conv.dispose(); }
}

export class Flux2ImageLayout {
  /** Borrowed raw NCHW image to an owned raw NHWC view, with no clamp/cast. */
  forward(x: MlxArray): MlxArray { return ops.transposeAxes(x, [0, 2, 3, 1]); }
}

/** MFLUX ImageUtil's bf16 normalization, followed by float32 byte scaling.
 * Each operation is eager MLX graph construction; do not compile/fuse this chain. */
export class Flux2Pixels {
  /** Borrowed raw bf16 NHWC image to owned NHWC uint8 pixels. */
  forward(image: MlxArray): MlxArray {
    using two = ops.scalarLike(2, image), half = ops.scalarLike(0.5, image);
    using zero = ops.scalarLike(0, image), one = ops.scalarLike(1, image);
    using divided = ops.div(image, two);
    using shifted = ops.add(divided, half);
    using clipped = ops.clip(shifted, zero, one);
    using wide = clipped.astype(Dtype.float32);
    using scaled = ops.mulScalar(wide, 255);
    using rounded = ops.round(scaled);
    return rounded.astype(Dtype.uint8);
  }
}

export type Flux2DecoderLayer = Flux2ResnetBlock | Flux2ShortcutResnetBlock | Flux2MidAttention | Flux2Upsample;
