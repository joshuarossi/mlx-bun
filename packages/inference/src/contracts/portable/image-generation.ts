/** A text-to-image request. Unset fields take the pipeline's declared
 * defaults (`ImageGenerationDefaults`). `width` and `height` must be positive
 * multiples of the pipeline's pixels per latent position. */
export interface ImageGenerationRequest {
  readonly prompt: string;
  readonly negativePrompt?: string;
  readonly width?: number;
  readonly height?: number;
  /** Sampling steps requested of the schedule; a schedule may merge equal noise levels. */
  readonly steps?: number;
  /** Classifier-free guidance scale; 1 runs the conditional prediction alone. */
  readonly guidance?: number;
  /** Seeds the initial noise. Equal seeds give equal noise on this backend only. */
  readonly seed?: number;
  /** Blocks the unconditional prediction skips (skip-layer guidance on the
   * negative branch); empty disables it. */
  readonly uncondSkipLayers?: readonly number[];
}

/** The sampling settings a text-to-image family publishes. */
export interface ImageGenerationDefaults {
  readonly width: number;
  readonly height: number;
  readonly steps: number;
  readonly guidance: number;
  readonly negativePrompt: string;
  readonly uncondSkipLayers: readonly number[];
}

/** Decoded pixels: RGB, row-major, three bytes per pixel. */
export interface GeneratedImage {
  readonly width: number;
  readonly height: number;
  readonly pixels: Uint8Array;
  readonly seed: number;
  /** Denoising steps actually run. */
  readonly steps: number;
  readonly guidance: number;
  readonly timings: { readonly encodeMs: number; readonly denoiseMs: number; readonly decodeMs: number };
}

/** The pipeline stages, in the order a request runs them. */
export type ImageStage = "conditioner" | "denoiser" | "decoder";

/** Reported as a request moves through its stages; `step` counts completed denoising steps. */
export interface ImageGenerationProgress {
  readonly stage: ImageStage;
  readonly step?: number;
  readonly steps?: number;
}
