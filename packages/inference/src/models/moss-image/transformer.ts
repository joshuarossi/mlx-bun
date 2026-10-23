// The MOSS-Image DiT (`MOSSImageTransformer`), the family's generic graph: it
// binds every layer at construction (one joint block per layer the artifact
// declares; each projection dense or MLX-quantized as the artifact's
// quantization table states) and its forward arranges them: the latent and text
// embedders, the text refiner, the joint blocks over [image, text] tokens under
// one timestep modulation, and the video head. Request data (the latents, the
// conditioning, the timestep and the blocks a guidance branch skips) is the only
// thing a forward reads.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { loadModelConfig, quantFor, type ModelConfig } from "../../artifacts/config";
import { Weights } from "../../artifacts/weights";
import type { ImageDenoiser } from "../../contracts/mlx/image-generation";
import {
  MossJointAttention, MossJointBlock, MossJointFeedForward, MossLatentEmbedder, MossLatentHead, MossModulation,
  MossTextAttention, MossTextBlock, MossTextFeedForward, MossTimestepEmbedder, MossTokenSequence,
} from "./blocks";
import { MossDenseLinear, MossQuantizedLinear, MossRmsNorm, MossSitu, type MossLinear } from "./layers";
import { MossRope } from "./rope";

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

/** The reference `_RMSNorm` epsilon. */
const NORM_EPS = 1e-6;

export class MossImageTransformer implements ImageDenoiser {
  readonly latentChannels: number;
  readonly pixelsPerLatent = 16;
  readonly depth: number;
  readonly rope: MossRope;
  readonly latentEmbedder: MossLatentEmbedder;
  readonly textProjection: MossLinear;
  readonly textBlocks: readonly MossTextBlock[];
  readonly timestepEmbedder: MossTimestepEmbedder;
  readonly modulation: MossModulation;
  readonly sequence = new MossTokenSequence();
  readonly blocks: readonly MossJointBlock[];
  readonly head: MossLatentHead;

  /** Every checkpoint tensor but `rope.bands`, which the rotation derives (the
   * reference recomputes it on load too). */
  static usesTensor(name: string): boolean {
    return name !== "rope.bands";
  }

  static async open(dir: string, config: MossTransformerConfig): Promise<MossImageTransformer> {
    const modelConfig = await loadModelConfig(dir);
    const weights = await Weights.open(dir);
    try { return new MossImageTransformer(weights, modelConfig, config); }
    catch (error) { weights.dispose(); throw error; }
  }

  constructor(readonly weights: Weights, modelConfig: ModelConfig, readonly config: MossTransformerConfig) {
    this.latentChannels = config.latentChannels;
    this.depth = config.numLayers;
    const linear = (path: string): MossLinear => quantFor(modelConfig.quantization, path)
      ? MossQuantizedLinear.load(weights, path, modelConfig) : MossDenseLinear.load(weights, path);
    const norm = (path: string) => new MossRmsNorm(weights.tensor(`${path}.weight`), NORM_EPS);
    const activation = new MossSitu();
    this.rope = new MossRope(config.dim / config.numHeads, config.ropeBase);
    this.latentEmbedder = new MossLatentEmbedder(linear("video_embedder"));
    this.textProjection = linear("text_embedder.proj");
    const textBlock = (prefix: string) => new MossTextBlock(
      norm(`${prefix}.norm1`),
      new MossTextAttention(linear(`${prefix}.qkv`), linear(`${prefix}.proj`), norm(`${prefix}.q_norm`), norm(`${prefix}.k_norm`), this.rope, config.numHeads),
      norm(`${prefix}.norm2`),
      new MossTextFeedForward(linear(`${prefix}.ffn_up`), linear(`${prefix}.ffn_gate`), linear(`${prefix}.ffn_down`), activation));
    this.textBlocks = [textBlock("text_embedder.blocks.0"), textBlock("text_embedder.blocks.1")];
    this.timestepEmbedder = new MossTimestepEmbedder(linear("time_embedding.0"), linear("time_embedding.2"), config.freqDim);
    this.modulation = new MossModulation(linear("shared_block_modulation"), linear("video_head_modulation"), config.dim);
    const blocks: MossJointBlock[] = [];
    for (let i = 0; i < config.numLayers; i++) {
      const prefix = `layers.${i}`;
      blocks.push(new MossJointBlock(
        norm(`${prefix}.norm1`),
        new MossJointAttention(linear(`${prefix}.proj.q`), linear(`${prefix}.proj.k`), linear(`${prefix}.proj.v`), linear(`${prefix}.proj.o`),
          norm(`${prefix}.q_norm`), norm(`${prefix}.k_norm`), this.rope, config.numHeads),
        norm(`${prefix}.norm2`),
        new MossJointFeedForward(linear(`${prefix}.proj.ffn_up_gate`), linear(`${prefix}.proj.ffn_down`), activation)));
    }
    this.blocks = blocks;
    this.head = new MossLatentHead(norm("final_norm_video"), linear("final_linear_video"));
  }

  velocity(latents: MlxArray, timestep: number, context: MlxArray, skip: ReadonlySet<number> = new Set()): MlxArray {
    const height = latents.shape[2]!, width = latents.shape[3]!, tokens = height * width;
    const layout = this.rope.layout(height, width, context.shape[1]!);
    using time = this.timestepEmbedder.forward(timestep);
    using mod = this.modulation.forward(time);
    using image = this.latentEmbedder.forward(latents);
    let text = this.textProjection.forward(context);
    for (const block of this.textBlocks) { using previous = text; text = block.forward(previous, layout.text); }
    let x: MlxArray;
    { using refined = text; x = this.sequence.join(image, refined); }
    try {
      for (let i = 0; i < this.blocks.length; i++) {
        if (skip.has(i)) continue;
        using previous = x;
        x = this.blocks[i]!.forward(previous, layout.joint, mod.block);
      }
      using imageTokens = this.sequence.image(x, tokens);
      return this.head.forward(imageTokens, mod, height, width);
    } finally {
      x.dispose();
    }
  }

  dispose(): void {
    this.rope.dispose();
    for (const block of [...this.textBlocks, ...this.blocks]) block.dispose();
    for (const layer of [this.latentEmbedder, this.timestepEmbedder, this.modulation, this.head]) layer.dispose();
    this.textProjection.dispose();
    this.weights.dispose();
  }
}
