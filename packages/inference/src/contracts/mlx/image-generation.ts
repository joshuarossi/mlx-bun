import type { MlxArray } from "@mlx-bun/mlx/array";
import type { ImageGenerationDefaults, ImageStage } from "../portable/image-generation";

/** Prompt text to the sequence a denoiser attends to. */
export interface ImageConditioner {
  /** Owned, evaluated `[1, L, D]` activation in the encoder's dtype, `L >= 1`.
   * Evaluated so it stays valid after the conditioner is released. */
  encode(prompt: string): MlxArray;
  dispose(): void;
}

/** Predicts the flow-matching velocity of image latents at one timestep. */
export interface ImageDenoiser {
  readonly latentChannels: number;
  /** Pixels along each axis that one latent position decodes to. */
  readonly pixelsPerLatent: number;
  /** Block count; a skip set names blocks in `[0, depth)`. */
  readonly depth: number;
  /** `latents` `[1, C, h, w]` float32 and `context` (a conditioner's output) are
   * borrowed. Returns an owned, lazy float32 `[1, C, h, w]` velocity. Blocks in
   * `skip` (each in `[0, depth)`; `resolveImageRequest` checks a request's) are not run. */
  velocity(latents: MlxArray, timestep: number, context: MlxArray, skip?: ReadonlySet<number>): MlxArray;
  dispose(): void;
}

/** Image latents to pixels. */
export interface ImageLatentDecoder {
  /** `latents` `[1, C, h, w]` float32 is borrowed. Returns an owned, lazy raw
   * image for this decoder's bound `pixels` operation. The decoder owns the raw
   * image's layout and dtype; callers pass it unchanged to `pixels`. */
  decode(latents: MlxArray): MlxArray;
  /** `image`, produced by `decode`, is borrowed. Returns owned, lazy RGB uint8
   * `[1, h * p, w * p, 3]` pixels. Owns scaling, clipping and rounding policy. */
  pixels(image: MlxArray): MlxArray;
  dispose(): void;
}

/** Noise levels of a flow-matching sampler. */
export interface FlowMatchingSchedule {
  /** Descending noise levels for `steps` requested steps, ending with the
   * terminal 0; at most `steps + 1` entries. */
  sigmas(steps: number): Float32Array;
  /** The timestep value a denoiser receives at noise level `sigma`. */
  timestep(sigma: number): number;
}

/** A text-to-image family's runtime. Each stage opens on first use and stays
 * open until `release` or `dispose`; a caller holds one stage at a time by
 * releasing each after evaluating its output. A released stage reopens on the
 * next request for it. Stage handles are borrowed: callers never dispose them. */
export interface TextToImagePipeline {
  readonly defaults: ImageGenerationDefaults;
  readonly schedule: FlowMatchingSchedule;
  readonly latentChannels: number;
  readonly pixelsPerLatent: number;
  /** The denoiser's block count, known before it opens. */
  readonly depth: number;
  /** Weight bytes each stage holds while open: the bytes of the tensors it reads from its own component's safetensors
   * files, so never more than those files' size (a host that loads no native code charges a pipeline from the files). */
  readonly stageBytes: Readonly<Record<ImageStage, number>>;
  conditioner(): Promise<ImageConditioner>;
  denoiser(): Promise<ImageDenoiser>;
  decoder(): Promise<ImageLatentDecoder>;
  /** Close a stage and free its weights; a no-op for a stage that is not open. */
  release(stage: ImageStage): void;
  /** Release every stage. The pipeline is unusable afterwards. */
  dispose(): void;
}
