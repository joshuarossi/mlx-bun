// The layers of the FLUX.2 VAE decoder MOSS-Image ships (diffusers
// AutoencoderKLFlux2, decode path only). Each does one job in float32 on
// channels-last activations (`[1, H, W, C]`, MLX's convolution layout); the
// decoder graph (`vae.ts`) arranges them. Weights are borrowed from the
// component's `Weights` (which frees them); a layer frees only what it made.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { MossLinear } from "./layers";

/** The pipeline's de-normalization of the transformer's patched latents through
 * the VAE's `bn` running statistics: `x * sqrt(running_var + eps) + running_mean`
 * per channel, the scale computed once in float32 as the reference does. Owns
 * its `[1, C, 1, 1]` scale and shift. */
export class Flux2LatentDenormalization {
  readonly #scale: MlxArray;
  readonly #shift: MlxArray;

  constructor(runningMean: MlxArray, runningVar: MlxArray, eps: number) {
    const channels = runningMean.shape[0]!;
    using epsilon = ops.scalarLike(eps, runningVar);
    using shifted = ops.add(runningVar, epsilon);
    using deviation = ops.sqrt(shifted);
    this.#scale = ops.reshape(deviation, [1, channels, 1, 1]);
    this.#shift = ops.reshape(runningMean, [1, channels, 1, 1]);
  }

  /** `latents` `[1, C, h, w]` float32 channels-first (borrowed) to an owned `[1, C, h, w]`. */
  forward(latents: MlxArray): MlxArray {
    using scaled = ops.mul(latents, this.#scale);
    return ops.add(scaled, this.#shift);
  }

  dispose(): void { this.#scale.dispose(); this.#shift.dispose(); }
}

/** The pipeline's unpatchify, to channels-last: channel `c * p * p + i * p + j` of
 * a `[1, C * p * p, h, w]` latent is pixel `(y * p + i, x * p + j)` of channel `c`
 * (the reference's `reshape(b, c, p, p, h, w).permute(0, 1, 4, 2, 5, 3)`). */
export class Flux2Unpatchify {
  constructor(readonly patch: number) {}

  /** `z` `[1, C * p * p, h, w]` (borrowed) to an owned `[1, h * p, w * p, C]`. */
  forward(z: MlxArray): MlxArray {
    const [batch, patched, height, width] = z.shape as [number, number, number, number];
    const p = this.patch, channels = patched / (p * p);
    using split = ops.reshape(z, [batch, channels, p, p, height, width]);
    using ordered = ops.transposeAxes(split, [0, 4, 2, 5, 3, 1]);
    return ops.reshape(ordered, [batch, height * p, width * p, channels]);
  }
}

/** `nn.Conv2d` at stride 1 with a bias and zero padding `(k - 1) / 2` (an odd
 * square kernel keeps the spatial size). The PyTorch weight `[C_out, C_in, k, k]`
 * (borrowed) is converted once into an owned contiguous `[C_out, k, k, C_in]`. */
export class Flux2Conv2d {
  readonly #weight: MlxArray;
  readonly #padding: [number, number];

  constructor(weight: MlxArray, readonly bias: MlxArray) {
    const [, , kh, kw] = weight.shape as [number, number, number, number];
    if (kh !== kw || kh % 2 !== 1) throw new Error(`Flux2Conv2d: expected an odd square kernel, got ${kh}x${kw}`);
    using channelsLast = ops.transposeAxes(weight, [0, 2, 3, 1]);
    this.#weight = ops.contiguous(channelsLast);
    this.#padding = [(kh - 1) / 2, (kh - 1) / 2];
  }

  /** `x` `[1, H, W, C_in]` (borrowed) to an owned `[1, H, W, C_out]`. */
  forward(x: MlxArray): MlxArray {
    using convolved = ops.conv2d(x, this.#weight, [1, 1], this.#padding);
    return ops.add(convolved, this.bias);
  }

  dispose(): void { this.#weight.dispose(); }
}

/** `nn.GroupNorm` with an affine weight and bias on channels-last float32 input:
 * channels split into `groups` contiguous runs; each group's mean and biased
 * variance over its channels and every position, in float32 (variance from the
 * centered values), then `(x - mean) / sqrt(var + eps) * weight + bias`. */
export class Flux2GroupNorm {
  constructor(readonly weight: MlxArray, readonly bias: MlxArray, readonly groups: number, readonly eps: number) {}

  /** `x` `[1, H, W, C]` (borrowed) to an owned `[1, H, W, C]`. */
  forward(x: MlxArray): MlxArray {
    const [batch, height, width, channels] = x.shape as [number, number, number, number];
    using grouped = ops.reshape(x, [batch, height * width, this.groups, channels / this.groups]);
    using channelMean = ops.meanAxis(grouped, 1, true);
    using mean = ops.meanAxis(channelMean, 3, true);
    using centered = ops.sub(grouped, mean);
    using squared = ops.square(centered);
    using channelVariance = ops.meanAxis(squared, 1, true);
    using variance = ops.meanAxis(channelVariance, 3, true);
    using epsilon = ops.scalarLike(this.eps, variance);
    using shifted = ops.add(variance, epsilon);
    using inverse = ops.rsqrt(shifted);
    using normalized = ops.mul(centered, inverse);
    using flat = ops.reshape(normalized, [batch, height, width, channels]);
    using scaled = ops.mul(flat, this.weight);
    return ops.add(scaled, this.bias);
  }
}

/** SiLU, `x * sigmoid(x)`. */
export class Flux2Silu {
  /** `x` (borrowed) to an owned result. */
  forward(x: MlxArray): MlxArray {
    return ops.silu(x);
  }
}

/** A residual block's convolution branch: GroupNorm, SiLU, conv1, GroupNorm, SiLU, conv2. */
function residualBranch(x: MlxArray, norm1: Pick<Flux2GroupNorm, "forward">, conv1: Pick<Flux2Conv2d, "forward">,
  norm2: Pick<Flux2GroupNorm, "forward">, conv2: Pick<Flux2Conv2d, "forward">, activation: Pick<Flux2Silu, "forward">): MlxArray {
  using normed1 = norm1.forward(x);
  using activated1 = activation.forward(normed1);
  using hidden = conv1.forward(activated1);
  using normed2 = norm2.forward(hidden);
  using activated2 = activation.forward(normed2);
  return conv2.forward(activated2);
}

/** `ResnetBlock2D` with equal input and output channels: the branch added to the
 * input (no time embedding, dropout off, output scale 1). */
export class Flux2ResnetBlock {
  constructor(readonly norm1: Pick<Flux2GroupNorm, "forward">, readonly conv1: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly norm2: Pick<Flux2GroupNorm, "forward">, readonly conv2: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly activation: Pick<Flux2Silu, "forward">) {}

  /** `x` `[1, H, W, C]` (borrowed) to an owned `[1, H, W, C]`. */
  forward(x: MlxArray): MlxArray {
    using branch = residualBranch(x, this.norm1, this.conv1, this.norm2, this.conv2, this.activation);
    return ops.add(x, branch);
  }

  dispose(): void { this.conv1.dispose(); this.conv2.dispose(); }
}

/** `ResnetBlock2D` that changes the channel count: the branch added to the
 * input's 1x1 `conv_shortcut` (no time embedding, dropout off, output scale 1). */
export class Flux2ShortcutResnetBlock {
  constructor(readonly norm1: Pick<Flux2GroupNorm, "forward">, readonly conv1: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly norm2: Pick<Flux2GroupNorm, "forward">, readonly conv2: Pick<Flux2Conv2d, "forward" | "dispose">,
    readonly shortcut: Pick<Flux2Conv2d, "forward" | "dispose">, readonly activation: Pick<Flux2Silu, "forward">) {}

  /** `x` `[1, H, W, C_in]` (borrowed) to an owned `[1, H, W, C_out]`. */
  forward(x: MlxArray): MlxArray {
    using branch = residualBranch(x, this.norm1, this.conv1, this.norm2, this.conv2, this.activation);
    using skip = this.shortcut.forward(x);
    return ops.add(skip, branch);
  }

  dispose(): void { this.conv1.dispose(); this.conv2.dispose(); this.shortcut.dispose(); }
}

/** The mid block's `Attention` (`AttnProcessor2_0`): GroupNorm, biased q/k/v
 * projections, one head spanning all `C` channels over the `H * W` positions at
 * scale `1 / sqrt(C)`, the biased output projection, the input added back
 * (rescale 1). */
export class Flux2MidAttention {
  constructor(readonly norm: Pick<Flux2GroupNorm, "forward">, readonly q: MossLinear, readonly k: MossLinear,
    readonly v: MossLinear, readonly out: MossLinear) {}

  /** `x` `[1, H, W, C]` (borrowed) to an owned `[1, H, W, C]`. */
  forward(x: MlxArray): MlxArray {
    const [batch, height, width, channels] = x.shape as [number, number, number, number];
    const positions = height * width, oneHead = [batch, 1, positions, channels];
    using normed = this.norm.forward(x);
    using tokens = ops.reshape(normed, [batch, positions, channels]);
    using q = this.q.forward(tokens), k = this.k.forward(tokens), v = this.v.forward(tokens);
    using qh = ops.reshape(q, oneHead), kh = ops.reshape(k, oneHead), vh = ops.reshape(v, oneHead);
    using attended = ops.sdpa(qh, kh, vh, 1 / Math.sqrt(channels), "");
    using merged = ops.reshape(attended, [batch, positions, channels]);
    using projected = this.out.forward(merged);
    using spatial = ops.reshape(projected, [batch, height, width, channels]);
    return ops.add(spatial, x);
  }

  dispose(): void { for (const linear of [this.q, this.k, this.v, this.out]) linear.dispose(); }
}

/** `Upsample2D` with a convolution: nearest-neighbour doubling of both spatial
 * axes, then the 3x3 convolution. */
export class Flux2Upsample {
  constructor(readonly conv: Pick<Flux2Conv2d, "forward" | "dispose">) {}

  /** `x` `[1, H, W, C]` (borrowed) to an owned `[1, 2H, 2W, C_out]`. */
  forward(x: MlxArray): MlxArray {
    const [batch, height, width, channels] = x.shape as [number, number, number, number];
    using expanded = ops.reshape(x, [batch, height, 1, width, 1, channels]);
    using repeated = ops.broadcastTo(expanded, [batch, height, 2, width, 2, channels]);
    using doubled = ops.reshape(repeated, [batch, 2 * height, 2 * width, channels]);
    return this.conv.forward(doubled);
  }

  dispose(): void { this.conv.dispose(); }
}

/** The pipeline's `clamp(-1, 1)` of the decoded image. Owns its two bounds. */
export class Flux2ImageClamp {
  readonly #low = MlxArray.fromFloat32(new Float32Array([-1]), []);
  readonly #high = MlxArray.fromFloat32(new Float32Array([1]), []);

  /** `image` float32 (borrowed) to an owned copy clamped to `[-1, 1]`. */
  forward(image: MlxArray): MlxArray {
    return ops.clip(image, this.#low, this.#high);
  }

  dispose(): void { this.#low.dispose(); this.#high.dispose(); }
}

/** A layer of the decoder's mid and up blocks: `[1, H, W, C]` (borrowed) to an owned activation. */
export type Flux2DecoderLayer = Flux2ResnetBlock | Flux2ShortcutResnetBlock | Flux2MidAttention | Flux2Upsample;
