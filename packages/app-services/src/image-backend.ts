// The native side of the image model host: opening a text-to-image pipeline
// and running a request through the library's public surfaces. Every native
// module loads on first use, so composing a host touches no MLX code. Requests,
// progress and results cross as the app-core shapes; no MLX type leaves this
// file. An `ImageBackend` is also the seam tests replace with a fake.
import type { GeneratedImage, ImageDefaults, ImageProgress, ImageRequest } from "@mlx-bun/app-core";
import type { GeneratedImage as LibraryImage, ImageGenerationRequest } from "@mlx-bun/inference/contracts/portable";

/** One run's options. `releaseStages` is the host's residency decision: free each stage once its output is evaluated
 * (one stage resident at a time), or keep every stage open for the next run. */
export interface ImageRunOptions {
  readonly releaseStages: boolean;
  readonly signal?: AbortSignal;
  readonly onProgress?: (progress: ImageProgress) => void;
}

/** An opened text-to-image pipeline. Opening reads configs only; each stage loads its weights on first use. */
export interface LoadedImagePipeline {
  readonly defaults: ImageDefaults;
  readonly pixelsPerLatent: number;
  /** Weight bytes each stage holds while it is open. */
  readonly stageBytes: Readonly<Record<ImageProgress["stage"], number>>;
  /** Rejects with a RangeError naming a field the pipeline cannot take, and with the signal's reason once it aborts;
   * either way the stages this run opened are released when `releaseStages`. */
  generate(request: ImageRequest, options: ImageRunOptions): Promise<GeneratedImage>;
  /** Release every stage and hand cached buffers back to the OS. */
  dispose(): void;
}

export interface ImageBackend {
  load(modelDir: string): Promise<LoadedImagePipeline>;
}

/** The library's request for a portable one: the same fields, copied so nothing the caller holds is shared. */
function libraryRequest(request: ImageRequest): ImageGenerationRequest {
  return {
    prompt: request.prompt,
    ...(request.negativePrompt !== undefined ? { negativePrompt: request.negativePrompt } : {}),
    ...(request.width !== undefined ? { width: request.width } : {}),
    ...(request.height !== undefined ? { height: request.height } : {}),
    ...(request.steps !== undefined ? { steps: request.steps } : {}),
    ...(request.guidance !== undefined ? { guidance: request.guidance } : {}),
    ...(request.seed !== undefined ? { seed: request.seed } : {}),
    ...(request.uncondSkipLayers !== undefined ? { uncondSkipLayers: [...request.uncondSkipLayers] } : {}),
  };
}

/** The app-core result for the library's. */
function generatedImage(image: LibraryImage): GeneratedImage {
  return { width: image.width, height: image.height, pixels: image.pixels, seed: image.seed, steps: image.steps, guidance: image.guidance,
    timings: { encodeMs: image.timings.encodeMs, denoiseMs: image.timings.denoiseMs, decodeMs: image.timings.decodeMs } };
}

/** Real weights: the snapshot's pipeline, run by the library's generation. */
export const nativeImageBackend: ImageBackend = {
  async load(modelDir) {
    const [{ openImagePipeline }, { generateImage }, { clearCache }] = await Promise.all([
      import("@mlx-bun/inference/models"), import("@mlx-bun/inference/generation"), import("@mlx-bun/mlx/ffi"),
    ]);
    const { pipeline } = await openImagePipeline(modelDir);
    const defaults = pipeline.defaults;
    // A stage frees its weights a microtask after its release; the buffers MLX's allocator kept go back to the OS after that.
    const returnBuffers = () => { void Promise.resolve().then(() => clearCache()); };
    return {
      defaults: { width: defaults.width, height: defaults.height, steps: defaults.steps, guidance: defaults.guidance,
        negativePrompt: defaults.negativePrompt, uncondSkipLayers: [...defaults.uncondSkipLayers] },
      pixelsPerLatent: pipeline.pixelsPerLatent,
      stageBytes: { ...pipeline.stageBytes },
      async generate(request, options) {
        try {
          return generatedImage(await generateImage(pipeline, libraryRequest(request), {
            releaseStages: options.releaseStages,
            ...(options.signal ? { signal: options.signal } : {}),
            ...(options.onProgress ? { onProgress: progress => options.onProgress!({ stage: progress.stage,
              ...(progress.step !== undefined ? { step: progress.step } : {}), ...(progress.steps !== undefined ? { steps: progress.steps } : {}) }) } : {}),
          }));
        } finally {
          if (options.releaseStages) returnBuffers();
        }
      },
      dispose() {
        pipeline.dispose();
        returnBuffers();
      },
    };
  },
};
