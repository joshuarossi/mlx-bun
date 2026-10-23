// The MOSS-Image DiT (`MOSSImageTransformer`): the family's generic graph. It
// binds one joint block per layer the artifact declares at construction; a
// forward embeds the latents and the conditioning, refines the text, runs the
// blocks over [image, text] tokens with one shared modulation, and projects the
// image tokens back to latent velocity. Dtypes follow the reference: bf16
// weights and activations, the timestep sinusoid in float64, the output in
// float32.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { loadModelConfig, type ModelConfig } from "../../artifacts/config";
import { WeightAudit, tensorUsed } from "../../artifacts/weight-audit";
import { Weights } from "../../artifacts/weights";
import type { ImageDenoiser } from "../../contracts/mlx/image-generation";
import { axialRopeTables, sliceAxialRope, type AxialRopeTables } from "../../layers/axial-rope";
import { loadLinear, type AnyLinear } from "../../layers/loading";
import { RMSNorm } from "../../layers/normalization";
import { CompiledSitu } from "../../layers/situ";
import { MossJointBlock, MossTextBlock, disposeLinear, type BlockModulation, type BlockWeights } from "./blocks";

/** `transformer/config.json`. */
export interface MossTransformerConfig {
  readonly dim: number;
  readonly ffnDim: number;
  readonly numHeads: number;
  readonly numLayers: number;
  readonly textDim: number;
  readonly freqDim: number;
  readonly latentChannels: number;
  readonly ropeBase: number;
}

/** Parse and check the transformer config as the reference constructor does. */
export function parseMossTransformerConfig(raw: Record<string, unknown>): MossTransformerConfig {
  const read = (key: string, fallback: number) => {
    const value = raw[key] ?? fallback;
    if (typeof value !== "number" || !Number.isFinite(value)) throw new Error(`transformer config: ${key} must be a number`);
    return value;
  };
  const config = {
    dim: read("dim", 3072), ffnDim: read("ffn_dim", 8192), numHeads: read("num_heads", 24), numLayers: read("num_layers", 42),
    textDim: read("text_dim", 4096), freqDim: read("freq_dim", 256), latentChannels: read("latent_channels", 128),
    ropeBase: read("rope_base", 10000),
  };
  if (config.dim % config.numHeads || (config.dim / config.numHeads) % 8 || config.freqDim % 2)
    throw new Error("transformer config: need dim divisible by num_heads, head_dim divisible by 8 and an even freq_dim");
  return config;
}

/** The four coordinate axes of a position: (reserved, text index, row, column). */
const AXES = 4;

/** Per-axis RoPE frequencies `1 / base ** (k / bands)` in float32, as the
 * reference builds them on the CPU (equal to the stored `rope.bands`). */
function ropeBands(headDim: number, base: number): Float32Array {
  const bands = headDim / (2 * AXES);
  return Float32Array.from({ length: bands }, (_, k) => Math.fround(1 / Math.fround(Math.pow(base, Math.fround(k / bands)))));
}

/** The reference's coordinates: image positions `(0, textLength, row - (h-1)/2,
 * col - (w-1)/2)` in raster order, then text positions `(0, i, 0, 0)`. */
function ropeCoordinates(height: number, width: number, textLength: number): Float32Array {
  const out = new Float32Array((height * width + textLength) * AXES);
  const rowCenter = (height - 1) / 2, colCenter = (width - 1) / 2;
  let at = 0;
  for (let row = 0; row < height; row++)
    for (let col = 0; col < width; col++) {
      out[at + 1] = textLength; out[at + 2] = row - rowCenter; out[at + 3] = col - colCenter;
      at += AXES;
    }
  for (let i = 0; i < textLength; i++) { out[at + 1] = i; at += AXES; }
  return out;
}

/** The timestep sinusoid: `cat(cos(t * f), sin(t * f))` with `f_k = 10000 ** (-k / half)`
 * in float64, cast to float32 (the reference's training computation). */
export function timestepEmbedding(timestep: number, freqDim: number): Float32Array {
  const half = freqDim / 2, out = new Float32Array(freqDim);
  for (let k = 0; k < half; k++) {
    const phase = timestep * Math.pow(10000, -k / half);
    out[k] = Math.cos(phase);
    out[half + k] = Math.sin(phase);
  }
  return out;
}

export class MossImageTransformer implements ImageDenoiser {
  readonly latentChannels: number;
  readonly pixelsPerLatent = 16;
  readonly depth: number;
  readonly videoEmbedder: AnyLinear;
  readonly textProjection: AnyLinear;
  readonly textBlocks: readonly MossTextBlock[];
  readonly timeIn: AnyLinear;
  readonly timeOut: AnyLinear;
  readonly blockModulation: AnyLinear;
  readonly headModulation: AnyLinear;
  readonly blocks: readonly MossJointBlock[];
  readonly finalNorm: RMSNorm;
  readonly finalLinear: AnyLinear;
  readonly #bands: Float32Array;
  readonly #ropes = new Map<string, AxialRopeTables>();

  /** Every checkpoint tensor but `rope.bands`, which the graph derives (and the
   * reference recomputes on load). */
  static usesTensor(name: string): boolean {
    return name !== "rope.bands";
  }

  /** Open the component directory's weights (bf16 or MLX-quantized linears). */
  static async open(dir: string, config: MossTransformerConfig): Promise<MossImageTransformer> {
    const modelConfig = await loadModelConfig(dir);
    const weights = await Weights.open(dir);
    try { return new MossImageTransformer(weights, modelConfig, config); }
    catch (error) { weights.dispose(); throw error; }
  }

  constructor(readonly weights: Weights, modelConfig: ModelConfig, readonly config: MossTransformerConfig) {
    this.latentChannels = config.latentChannels;
    this.depth = config.numLayers;
    const audit = new WeightAudit();
    const source: BlockWeights = { weights, config: modelConfig, audit };
    const linear = (path: string) => loadLinear(weights, path, modelConfig, audit);
    const activation = new CompiledSitu();
    this.videoEmbedder = linear("video_embedder");
    this.textProjection = linear("text_embedder.proj");
    this.textBlocks = [0, 1].map(i => new MossTextBlock(source, `text_embedder.blocks.${i}`, config.numHeads, activation));
    this.timeIn = linear("time_embedding.0");
    this.timeOut = linear("time_embedding.2");
    this.blockModulation = linear("shared_block_modulation");
    this.headModulation = linear("video_head_modulation");
    const blocks: MossJointBlock[] = [];
    for (let i = 0; i < config.numLayers; i++) blocks.push(new MossJointBlock(source, `layers.${i}`, config.numHeads, activation));
    this.blocks = blocks;
    this.finalNorm = new RMSNorm(tensorUsed(weights, audit, "final_norm_video.weight"), 1e-6);
    this.finalLinear = linear("final_linear_video");
    audit.finish(weights, [/^rope\.bands$/]);
    this.#bands = ropeBands(config.dim / config.numHeads, config.ropeBase);
  }

  #rope(height: number, width: number, textLength: number): AxialRopeTables {
    const key = `${height}x${width}+${textLength}`;
    let tables = this.#ropes.get(key);
    if (!tables) {
      tables = axialRopeTables(ropeCoordinates(height, width, textLength), AXES, this.#bands, Dtype.bfloat16);
      this.#ropes.set(key, tables);
    }
    return tables;
  }

  /** The shared block modulation and the head's shift and `1 + scale`, from the timestep. */
  #modulation(timestep: number): { block: BlockModulation; headShift: MlxArray; headScale: MlxArray } & Disposable {
    const dim = this.config.dim;
    using sinusoid = MlxArray.fromFloat32(timestepEmbedding(timestep, this.config.freqDim), [1, this.config.freqDim]);
    using embedded = sinusoid.astype(Dtype.bfloat16);
    using hidden = this.timeIn.forward(embedded);
    // nn.SiLU on bf16 computes in float and rounds once.
    using wide = hidden.astype(Dtype.float32);
    using activated = ops.silu(wide);
    using narrow = activated.astype(Dtype.bfloat16);
    using time = this.timeOut.forward(narrow);
    using block = this.blockModulation.forward(time);
    using head = this.headModulation.forward(time);
    const part = (source: MlxArray, index: number) => source.slice([0, index * dim], [1, (index + 1) * dim]);
    const shaped = (x: MlxArray) => { const out = ops.reshape(x, [1, 1, dim]); x.dispose(); return out; };
    const plusOne = (x: MlxArray) => { using one = ops.scalarLike(1, x); const out = ops.add(one, x); x.dispose(); return out; };
    const parts = [0, 1, 2, 3, 4, 5].map(i => shaped(part(block, i)));
    const mod: BlockModulation = {
      shiftA: parts[0]!, scaleA: plusOne(parts[1]!), gateA: parts[2]!,
      shiftF: parts[3]!, scaleF: plusOne(parts[4]!), gateF: parts[5]!,
    };
    const headShift = shaped(part(head, 0)), headScale = plusOne(shaped(part(head, 1)));
    const owned = [mod.shiftA, mod.scaleA, mod.gateA, mod.shiftF, mod.scaleF, mod.gateF, headShift, headScale];
    return { block: mod, headShift, headScale, [Symbol.dispose]() { for (const array of owned) array.dispose(); } };
  }

  velocity(latents: MlxArray, timestep: number, context: MlxArray, skip: ReadonlySet<number> = new Set()): MlxArray {
    for (const block of skip)
      if (!Number.isInteger(block) || block < 0 || block >= this.depth)
        throw new RangeError(`skip names block ${block}; the denoiser has blocks [0, ${this.depth})`);
    const [batch, channels, height, width] = latents.shape as [number, number, number, number];
    if (batch !== 1 || channels !== this.latentChannels)
      throw new RangeError(`latents must be [1, ${this.latentChannels}, h, w], got [${latents.shape.join(", ")}]`);
    if (context.ndim !== 3 || context.shape[0] !== 1 || context.shape[1]! < 1)
      throw new RangeError(`context must be [1, L >= 1, ${this.config.textDim}], got [${context.shape.join(", ")}]`);
    const tokens = height * width, textLength = context.shape[1]!;
    const rope = this.#rope(height, width, textLength);
    using textRope = sliceAxialRope(rope, tokens, tokens + textLength);
    using mod = this.#modulation(timestep);

    using flat = ops.reshape(latents, [1, channels, tokens]);
    using rows = ops.transposeAxes(flat, [0, 2, 1]);
    using narrowRows = rows.astype(Dtype.bfloat16);
    using packed = ops.contiguous(narrowRows);
    using video = this.videoEmbedder.forward(packed);

    let text = this.textProjection.forward(context);
    for (const block of this.textBlocks) { const next = block.forward(text, textRope); text.dispose(); text = next; }
    let x = ops.concatAxis([video, text], 1);
    text.dispose();
    try {
      for (let i = 0; i < this.blocks.length; i++) {
        if (skip.has(i)) continue;
        const next = this.blocks[i]!.forward(x, rope, mod.block);
        x.dispose();
        x = next;
      }
      using image = x.slice([0, 0, 0], [1, tokens, this.config.dim]);
      using normed = this.finalNorm.forward(image);
      using scaled = ops.mul(normed, mod.headScale);
      using shifted = ops.add(scaled, mod.headShift);
      using projected = this.finalLinear.forward(shifted);
      using channelsFirst = ops.transposeAxes(projected, [0, 2, 1]);
      using shaped = ops.reshape(channelsFirst, [1, channels, height, width]);
      return shaped.astype(Dtype.float32);
    } finally {
      x.dispose();
    }
  }

  dispose(): void {
    for (const tables of this.#ropes.values()) tables.dispose();
    this.#ropes.clear();
    for (const block of [...this.textBlocks, ...this.blocks]) block.dispose();
    for (const linear of [this.videoEmbedder, this.textProjection, this.timeIn, this.timeOut, this.blockModulation,
      this.headModulation, this.finalLinear]) disposeLinear(linear);
    this.weights.dispose();
  }
}
