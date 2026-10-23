// The FLUX.2 VAE decoder MOSS-Image ships (diffusers AutoencoderKLFlux2,
// decode path only): batch-norm de-normalization of the patched latents, the
// 2x2 unpatchify, post-quant convolution and the decoder, in float32.

import type { MlxArray } from "@mlx-bun/mlx/array";
import type { ImageLatentDecoder } from "../../contracts/mlx/image-generation";

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

/** Parse and check `vae/config.json`. */
export function parseFlux2VaeConfig(raw: Record<string, unknown>): Flux2VaeConfig {
  throw new Error(`Flux2 VAE config parsing is not implemented (${Object.keys(raw).length} keys)`);
}

export class Flux2VaeDecoder implements ImageLatentDecoder {
  /** The decode path's tensors: the decoder, the post-quant convolution and the batch-norm statistics. */
  static usesTensor(name: string): boolean {
    return name.startsWith("decoder.") || name.startsWith("post_quant_conv.") || name.startsWith("bn.");
  }

  static async open(dir: string, config: Flux2VaeConfig): Promise<Flux2VaeDecoder> {
    throw new Error(`Flux2 VAE decoding is not implemented (${dir}, ${config.latentChannels} channels)`);
  }

  decode(_latents: MlxArray): MlxArray {
    throw new Error("Flux2 VAE decoding is not implemented");
  }

  dispose(): void {}
}
