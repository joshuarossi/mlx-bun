// The FLUX.2 VAE decoder MOSS-Image ships (diffusers AutoencoderKLFlux2,
// decode path only), the family's generic graph for its VAE: batch-norm
// de-normalization of the patched latents, the 2x2 unpatchify, the post-quant
// convolution and the decoder (conv_in; the mid block's resnet, attention and
// resnet; one up block per decoder channel count, each `layers_per_block + 1`
// resnets and, on all but the last, an upsampler; GroupNorm, SiLU, conv_out),
// then the pipeline's clamp to [-1, 1]. Float32 throughout, channels-last
// inside. The constructor binds one layer per checkpoint module the config
// declares; `decode` runs them in order.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { Weights } from "../../artifacts/weights";
import type { ImageLatentDecoder } from "../../contracts/mlx/image-generation";
import { MossDenseBiasedLinear } from "./layers";
import {
  Flux2Conv2d, Flux2GroupNorm, Flux2ImageClamp, Flux2LatentDenormalization, Flux2MidAttention, Flux2ResnetBlock,
  Flux2ShortcutResnetBlock, Flux2Silu, Flux2Unpatchify, Flux2Upsample, type Flux2DecoderLayer,
} from "./vae-layers";

/** `vae/config.json` fields the decode path reads. */
export interface Flux2VaeConfig {
  /** Channels of the unpatched latent (the decoder's input). */
  readonly latentChannels: number;
  /** Side of the square patch folded into the transformer's latent channels. */
  readonly patch: number;
  /** Pixels per unpatched latent position along each axis: 2 ** (decoder blocks - 1). */
  readonly downsample: number;
  readonly decoderBlockOutChannels: readonly number[];
  readonly layersPerBlock: number;
  readonly normNumGroups: number;
  readonly batchNormEps: number;
  readonly midBlockAddAttention: boolean;
  readonly usePostQuantConv: boolean;
}

/** Parse and check `vae/config.json` (diffusers defaults for absent keys). The
 * decoder is written for the FLUX.2 VAE's structure: `UpDecoderBlock2D` up
 * blocks, SiLU, three output channels, a mid-block attention and a post-quant
 * convolution; a config that departs from it is rejected rather than decoded
 * by a path nobody wrote. */
export function parseFlux2VaeConfig(raw: Record<string, unknown>): Flux2VaeConfig {
  const integer = (key: string, fallback: number, min: number) => {
    const value = raw[key] ?? fallback;
    if (typeof value !== "number" || !Number.isInteger(value) || value < min) throw new Error(`VAE config: ${key} must be an integer >= ${min}`);
    return value;
  };
  const flag = (key: string, fallback: boolean) => {
    const value = raw[key] ?? fallback;
    if (typeof value !== "boolean") throw new Error(`VAE config: ${key} must be a boolean`);
    return value;
  };
  const latentChannels = integer("latent_channels", 32, 1);
  const layersPerBlock = integer("layers_per_block", 2, 0);
  const normNumGroups = integer("norm_num_groups", 32, 1);
  const batchNormEps = raw.batch_norm_eps ?? 1e-4;
  if (typeof batchNormEps !== "number" || !Number.isFinite(batchNormEps) || batchNormEps < 0)
    throw new Error("VAE config: batch_norm_eps must be a finite number >= 0");
  const patchSize = raw.patch_size ?? [2, 2];
  if (!Array.isArray(patchSize) || patchSize.length !== 2 || patchSize[0] !== patchSize[1] ||
      typeof patchSize[0] !== "number" || !Number.isInteger(patchSize[0]) || patchSize[0] < 1)
    throw new Error("VAE config: patch_size must be a square [p, p] of positive integers");
  const channels = raw.decoder_block_out_channels ?? raw.block_out_channels ?? [128, 256, 512, 512];
  if (!Array.isArray(channels) || channels.length === 0 ||
      !channels.every(value => typeof value === "number" && Number.isInteger(value) && value > 0 && value % normNumGroups === 0))
    throw new Error(`VAE config: decoder block channels must be positive multiples of norm_num_groups ${normNumGroups}`);
  const upBlocks = raw.up_block_types ?? channels.map(() => "UpDecoderBlock2D");
  if (!Array.isArray(upBlocks) || upBlocks.length !== channels.length || !upBlocks.every(type => type === "UpDecoderBlock2D"))
    throw new Error(`VAE config: expected ${channels.length} UpDecoderBlock2D up blocks`);
  if ((raw.act_fn ?? "silu") !== "silu") throw new Error("VAE config: act_fn must be silu");
  if (integer("out_channels", 3, 1) !== 3) throw new Error("VAE config: out_channels must be 3");
  const midBlockAddAttention = flag("mid_block_add_attention", true);
  const usePostQuantConv = flag("use_post_quant_conv", true);
  if (!midBlockAddAttention || !usePostQuantConv)
    throw new Error("VAE config: the decoder is written for mid_block_add_attention and use_post_quant_conv both true");
  return {
    latentChannels, patch: patchSize[0], downsample: 2 ** (channels.length - 1), decoderBlockOutChannels: channels as number[],
    layersPerBlock, normNumGroups, batchNormEps, midBlockAddAttention, usePostQuantConv,
  };
}

/** The decoder's GroupNorm epsilon: its resnets, mid attention and `conv_norm_out` all use 1e-6. */
const NORM_EPS = 1e-6;

export class Flux2VaeDecoder implements ImageLatentDecoder {
  readonly denormalize: Flux2LatentDenormalization;
  readonly unpatchify: Flux2Unpatchify;
  readonly postQuantConv: Flux2Conv2d;
  readonly convIn: Flux2Conv2d;
  /** Resnet, attention, resnet. */
  readonly midBlock: readonly Flux2DecoderLayer[];
  /** Per up block, in execution order: its resnets, then its upsampler (all but the last block). */
  readonly upBlocks: readonly (readonly Flux2DecoderLayer[])[];
  readonly normOut: Flux2GroupNorm;
  readonly activation = new Flux2Silu();
  readonly convOut: Flux2Conv2d;
  readonly clamp = new Flux2ImageClamp();

  /** The decode path's tensors: the decoder, the post-quant convolution and the batch-norm statistics. */
  static usesTensor(name: string): boolean {
    return name.startsWith("decoder.") || name.startsWith("post_quant_conv.") || name.startsWith("bn.");
  }

  static async open(dir: string, config: Flux2VaeConfig): Promise<Flux2VaeDecoder> {
    const weights = await Weights.open(dir);
    try { return new Flux2VaeDecoder(weights, config); }
    catch (error) { weights.dispose(); throw error; }
  }

  constructor(readonly weights: Weights, readonly config: Flux2VaeConfig) {
    // Every layer bound so far that holds arrays of its own (the clamp first: a field holding two), so a binding that fails
    // partway frees what the ones before it hold.
    const built: { dispose(): void }[] = [this.clamp];
    const own = <T extends { dispose(): void }>(layer: T): T => { built.push(layer); return layer; };
    const conv = (path: string) => own(new Flux2Conv2d(weights.tensor(`${path}.weight`), weights.tensor(`${path}.bias`)));
    const norm = (path: string) => new Flux2GroupNorm(weights.tensor(`${path}.weight`), weights.tensor(`${path}.bias`), config.normNumGroups, NORM_EPS);
    const linear = (path: string) => own(new MossDenseBiasedLinear(weights.tensor(`${path}.weight`), weights.tensor(`${path}.bias`)));
    const resnet = (path: string, inChannels: number, outChannels: number): Flux2DecoderLayer => inChannels === outChannels
      ? new Flux2ResnetBlock(norm(`${path}.norm1`), conv(`${path}.conv1`), norm(`${path}.norm2`), conv(`${path}.conv2`), this.activation)
      : new Flux2ShortcutResnetBlock(norm(`${path}.norm1`), conv(`${path}.conv1`), norm(`${path}.norm2`), conv(`${path}.conv2`),
        conv(`${path}.conv_shortcut`), this.activation);
    try {
      this.denormalize = own(new Flux2LatentDenormalization(weights.tensor("bn.running_mean"), weights.tensor("bn.running_var"), config.batchNormEps));
      this.unpatchify = new Flux2Unpatchify(config.patch);
      this.postQuantConv = conv("post_quant_conv");
      const channels = [...config.decoderBlockOutChannels].reverse();
      const top = channels[0]!;
      this.convIn = conv("decoder.conv_in");
      const attention = "decoder.mid_block.attentions.0";
      this.midBlock = [
        resnet("decoder.mid_block.resnets.0", top, top),
        new Flux2MidAttention(norm(`${attention}.group_norm`), linear(`${attention}.to_q`), linear(`${attention}.to_k`),
          linear(`${attention}.to_v`), linear(`${attention}.to_out.0`)),
        resnet("decoder.mid_block.resnets.1", top, top),
      ];
      const upBlocks: Flux2DecoderLayer[][] = [];
      let inChannels = top;
      for (let i = 0; i < channels.length; i++) {
        const prefix = `decoder.up_blocks.${i}`, outChannels = channels[i]!;
        const block: Flux2DecoderLayer[] = [];
        for (let j = 0; j <= config.layersPerBlock; j++) block.push(resnet(`${prefix}.resnets.${j}`, j === 0 ? inChannels : outChannels, outChannels));
        if (i < channels.length - 1) block.push(new Flux2Upsample(conv(`${prefix}.upsamplers.0.conv`)));
        upBlocks.push(block);
        inChannels = outChannels;
      }
      this.upBlocks = upBlocks;
      this.normOut = norm("decoder.conv_norm_out");
      this.convOut = conv("decoder.conv_out");
    } catch (error) {
      for (const layer of built.reverse()) layer.dispose();
      throw error;
    }
  }

  decode(latents: MlxArray): MlxArray {
    using denormalized = this.denormalize.forward(latents);
    using unpatched = this.unpatchify.forward(denormalized);
    using quantized = this.postQuantConv.forward(unpatched);
    let x = this.convIn.forward(quantized);
    try {
      for (const layer of this.midBlock) { using previous = x; x = layer.forward(previous); }
      for (const block of this.upBlocks)
        for (const layer of block) { using previous = x; x = layer.forward(previous); }
      using normed = this.normOut.forward(x);
      using activated = this.activation.forward(normed);
      using image = this.convOut.forward(activated);
      return this.clamp.forward(image);
    } finally {
      x.dispose();
    }
  }

  dispose(): void {
    this.denormalize.dispose();
    for (const layer of [...this.midBlock, ...this.upBlocks.flat()]) layer.dispose();
    for (const conv of [this.postQuantConv, this.convIn, this.convOut]) conv.dispose();
    this.clamp.dispose();
    this.weights.dispose();
  }
}
