// Text-to-image generation over the stage contracts (`contracts/mlx/image-generation`):
// conditioning, flow-matching Euler denoising with classifier-free and
// skip-layer guidance, and decoding to RGB bytes. Each stage is a function a
// caller can run alone; `generateImage` runs them in order and releases each
// stage after its output is evaluated unless the caller keeps them open. Nothing
// here names a family: the pipeline binds the implementations.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type {
  FlowMatchingSchedule, ImageConditioner, ImageDenoiser, ImageLatentDecoder, TextToImagePipeline,
} from "../contracts/mlx/image-generation";
import type {
  GeneratedImage, ImageGenerationDefaults, ImageGenerationProgress, ImageGenerationRequest, ImageStage,
} from "../contracts/portable/image-generation";

/** A request with every default applied and every field validated. */
export interface ResolvedImageRequest {
  readonly prompt: string;
  readonly negativePrompt: string;
  readonly width: number;
  readonly height: number;
  readonly steps: number;
  readonly guidance: number;
  readonly seed: number;
  readonly uncondSkipLayers: readonly number[];
}

/** What request validation reads of a pipeline. */
export interface ImageRequestBounds {
  readonly defaults: ImageGenerationDefaults;
  readonly pixelsPerLatent: number;
  readonly depth: number;
}

const MAX_SEED = 2 ** 53 - 1;

/** Apply the pipeline's defaults and validate. Throws a RangeError naming the
 * offending field; `seed` defaults to a random one, reported in the result. */
export function resolveImageRequest(bounds: ImageRequestBounds, request: ImageGenerationRequest): ResolvedImageRequest {
  const { defaults, pixelsPerLatent, depth } = bounds;
  if (typeof request.prompt !== "string") throw new RangeError("prompt must be a string");
  const width = request.width ?? defaults.width, height = request.height ?? defaults.height;
  for (const [name, value] of [["width", width], ["height", height]] as const)
    if (!Number.isInteger(value) || value <= 0 || value % pixelsPerLatent !== 0)
      throw new RangeError(`${name} must be a positive multiple of ${pixelsPerLatent}, got ${value}`);
  const steps = request.steps ?? defaults.steps;
  if (!Number.isInteger(steps) || steps < 1) throw new RangeError(`steps must be a positive integer, got ${steps}`);
  const guidance = request.guidance ?? defaults.guidance;
  if (!Number.isFinite(guidance) || guidance < 0) throw new RangeError(`guidance must be finite and nonnegative, got ${guidance}`);
  const seed = request.seed ?? Math.floor(Math.random() * 2 ** 32);
  if (!Number.isInteger(seed) || seed < 0 || seed > MAX_SEED) throw new RangeError(`seed must be an integer in [0, 2^53), got ${seed}`);
  const uncondSkipLayers = [...(request.uncondSkipLayers ?? defaults.uncondSkipLayers)];
  for (const block of uncondSkipLayers)
    if (!Number.isInteger(block) || block < 0 || block >= depth)
      throw new RangeError(`uncondSkipLayers must name blocks in [0, ${depth}), got ${block}`);
  const negativePrompt = request.negativePrompt ?? defaults.negativePrompt;
  if (typeof negativePrompt !== "string") throw new RangeError("negativePrompt must be a string");
  return { prompt: request.prompt, negativePrompt, width, height, steps, guidance, seed, uncondSkipLayers };
}

/** Throws the signal's reason (or an AbortError) once the signal has fired. */
function checkAborted(signal: AbortSignal | undefined): void {
  if (signal?.aborted) throw signal.reason ?? new DOMException("image generation aborted", "AbortError");
}

/** The conditioning a guided denoise reads. Owned; `dispose` frees both. */
export interface ImageConditioning {
  readonly positive: MlxArray;
  /** Present when guidance needs an unconditional prediction. */
  readonly negative: MlxArray | null;
  dispose(): void;
}

/** Encode the prompt and, for a guidance scale other than 1, the negative
 * prompt. The outputs are evaluated, so they outlive the conditioner. */
export function encodeConditioning(conditioner: ImageConditioner, request: Pick<ResolvedImageRequest, "prompt" | "negativePrompt" | "guidance">): ImageConditioning {
  const positive = conditioner.encode(request.prompt);
  let negative: MlxArray | null = null;
  try {
    if (request.guidance !== 1) negative = conditioner.encode(request.negativePrompt);
  } catch (error) {
    positive.dispose();
    throw error;
  }
  return { positive, negative, dispose() { positive.dispose(); negative?.dispose(); } };
}

/** Seeded float32 noise `[1, channels, height / p, width / p]`. Owned. */
export function initialLatents(channels: number, pixelsPerLatent: number, width: number, height: number, seed: number): MlxArray {
  using key = ops.randomKey(BigInt(seed));
  return ops.randomNormal([1, channels, height / pixelsPerLatent, width / pixelsPerLatent], Dtype.float32, 0, 1, key);
}

export interface DenoiseOptions {
  readonly steps: number;
  readonly guidance: number;
  readonly uncondSkipLayers: readonly number[];
  readonly signal?: AbortSignal;
  /** Called after each completed step. */
  readonly onStep?: (done: number, total: number) => void;
}

/** Flow-matching Euler sampling from `latents` (borrowed) down the schedule's
 * noise levels: per step the conditional velocity, combined with the
 * unconditional one as `uncond + guidance * (cond - uncond)` when guidance is
 * not 1 (the unconditional branch skips `uncondSkipLayers`), then
 * `x + (sigma_next - sigma) * v`, all in float32. Returns owned, evaluated
 * latents; on cancellation or failure every intermediate is freed. */
export function denoiseLatents(
  denoiser: ImageDenoiser, schedule: FlowMatchingSchedule, latents: MlxArray,
  conditioning: Pick<ImageConditioning, "positive" | "negative">, options: DenoiseOptions,
): { latents: MlxArray; steps: number } {
  const guided = options.guidance !== 1;
  if (guided && !conditioning.negative) throw new Error("guided denoising needs the negative conditioning");
  const sigmas = schedule.sigmas(options.steps);
  const total = sigmas.length - 1;
  const skip = new Set(options.uncondSkipLayers);
  let x = ops.copyOf(latents);
  try {
    for (let step = 0; step < total; step++) {
      checkAborted(options.signal);
      const sigma = sigmas[step]!, next = sigmas[step + 1]!;
      const timestep = schedule.timestep(sigma);
      let prediction = denoiser.velocity(x, timestep, conditioning.positive);
      if (guided) {
        using uncond = denoiser.velocity(x, timestep, conditioning.negative!, skip);
        using delta = ops.sub(prediction, uncond);
        prediction.dispose();
        using scaled = ops.mulScalar(delta, options.guidance);
        prediction = ops.add(uncond, scaled);
      }
      using velocity = prediction;
      using dt = MlxArray.fromFloat32(new Float32Array([next - sigma]), []);
      using change = ops.mul(dt, velocity);
      const updated = ops.add(x, change);
      updated.eval();
      x.dispose();
      x = updated;
      options.onStep?.(step + 1, total);
    }
    return { latents: x, steps: total };
  } catch (error) {
    x.dispose();
    throw error;
  }
}

/** Decode latents (borrowed) to RGB bytes with the reference postprocess:
 * `round(clip(image / 2 + 0.5, 0, 1) * 255)`. */
export function decodePixels(decoder: ImageLatentDecoder, latents: MlxArray): { pixels: Uint8Array; width: number; height: number } {
  using image = decoder.decode(latents);
  const [, height, width, channels] = image.shape as [number, number, number, number];
  if (channels !== 3) throw new Error(`a latent decoder must return RGB, got ${channels} channels`);
  using half = ops.mulScalar(image, 0.5);
  using offset = ops.scalarLike(0.5, half);
  using shifted = ops.add(half, offset);
  using zero = ops.scalarLike(0, shifted), one = ops.scalarLike(1, shifted);
  using clipped = ops.clip(shifted, zero, one);
  using scaled = ops.mulScalar(clipped, 255);
  using rounded = ops.round(scaled);
  using bytes = rounded.astype(Dtype.uint8);
  return { pixels: new Uint8Array(bytes.rawBytes()), width, height };
}

export interface ImageGenerationOptions {
  /** Release each stage once its output is evaluated, so one stage holds
   * memory at a time. False keeps every stage open for the next request.
   * Default true. */
  readonly releaseStages?: boolean;
  readonly signal?: AbortSignal;
  readonly onProgress?: (progress: ImageGenerationProgress) => void;
  /** Initial latents `[1, C, h, w]` float32 in place of seeded noise (borrowed),
   * for comparisons against another backend's noise. */
  readonly latents?: MlxArray;
}

/** Run a request through the pipeline's three stages. Validation happens
 * before any stage opens. On failure or cancellation the stages this call
 * opened are released (when `releaseStages`) and every tensor it made is freed. */
export async function generateImage(
  pipeline: TextToImagePipeline, request: ImageGenerationRequest, options: ImageGenerationOptions = {},
): Promise<GeneratedImage> {
  const resolved = resolveImageRequest(pipeline, request);
  const release = options.releaseStages ?? true;
  const opened = new Set<ImageStage>();
  const finish = (stage: ImageStage) => { if (release) { pipeline.release(stage); opened.delete(stage); } };
  const report = options.onProgress ?? (() => {});
  if (options.latents) {
    const expected = [1, pipeline.latentChannels, resolved.height / pipeline.pixelsPerLatent, resolved.width / pipeline.pixelsPerLatent];
    if (options.latents.shape.join() !== expected.join())
      throw new RangeError(`latents must have shape [${expected.join(", ")}], got [${options.latents.shape.join(", ")}]`);
  }
  let conditioning: ImageConditioning | null = null;
  let latents: MlxArray | null = null;
  try {
    checkAborted(options.signal);
    report({ stage: "conditioner" });
    let started = performance.now();
    opened.add("conditioner");
    conditioning = encodeConditioning(await pipeline.conditioner(), resolved);
    const encodeMs = performance.now() - started;
    finish("conditioner");

    checkAborted(options.signal);
    report({ stage: "denoiser", step: 0 });
    started = performance.now();
    opened.add("denoiser");
    const denoiser = await pipeline.denoiser();
    using noise = options.latents ? ops.copyOf(options.latents)
      : initialLatents(pipeline.latentChannels, pipeline.pixelsPerLatent, resolved.width, resolved.height, resolved.seed);
    const denoised = denoiseLatents(denoiser, pipeline.schedule, noise, conditioning, {
      steps: resolved.steps, guidance: resolved.guidance, uncondSkipLayers: resolved.uncondSkipLayers, signal: options.signal,
      onStep: (step, steps) => report({ stage: "denoiser", step, steps }),
    });
    latents = denoised.latents;
    const denoiseMs = performance.now() - started;
    conditioning.dispose();
    conditioning = null;
    finish("denoiser");

    checkAborted(options.signal);
    report({ stage: "decoder" });
    started = performance.now();
    opened.add("decoder");
    const { pixels, width, height } = decodePixels(await pipeline.decoder(), latents);
    const decodeMs = performance.now() - started;
    finish("decoder");
    return {
      width, height, pixels, seed: resolved.seed, steps: denoised.steps, guidance: resolved.guidance,
      timings: { encodeMs, denoiseMs, decodeMs },
    };
  } finally {
    conditioning?.dispose();
    latents?.dispose();
    for (const stage of opened) finish(stage);
  }
}
