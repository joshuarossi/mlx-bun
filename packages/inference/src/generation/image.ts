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

/** One velocity prediction per denoising step. Chosen once per request
 * (`guidanceFor`); returns an owned float32 `[1, C, h, w]`. */
export interface GuidanceStep {
  velocity(latents: MlxArray, timestep: number): MlxArray;
}

/** The conditional prediction alone (guidance scale 1). */
export class ConditionalVelocity implements GuidanceStep {
  constructor(readonly denoiser: ImageDenoiser, readonly positive: MlxArray) {}
  velocity(latents: MlxArray, timestep: number): MlxArray {
    return this.denoiser.velocity(latents, timestep, this.positive);
  }
}

/** Classifier-free guidance, `uncond + scale * (cond - uncond)` in float32, the
 * unconditional branch skipping `skip` (skip-layer guidance on the negative branch). */
export class GuidedVelocity implements GuidanceStep {
  readonly #skip: ReadonlySet<number>;
  constructor(readonly denoiser: ImageDenoiser, readonly positive: MlxArray, readonly negative: MlxArray,
    readonly scale: number, skip: readonly number[]) {
    this.#skip = new Set(skip);
  }
  velocity(latents: MlxArray, timestep: number): MlxArray {
    using conditional = this.denoiser.velocity(latents, timestep, this.positive);
    using unconditional = this.denoiser.velocity(latents, timestep, this.negative, this.#skip);
    using delta = ops.sub(conditional, unconditional);
    using scaled = ops.mulScalar(delta, this.scale);
    return ops.add(unconditional, scaled);
  }
}

/** The step a request runs: guided when its conditioning holds a negative branch
 * (guidance other than 1), else the conditional prediction alone. */
export function guidanceFor(denoiser: ImageDenoiser, conditioning: ImageConditioning,
  request: Pick<ResolvedImageRequest, "guidance" | "uncondSkipLayers">): GuidanceStep {
  return conditioning.negative
    ? new GuidedVelocity(denoiser, conditioning.positive, conditioning.negative, request.guidance, request.uncondSkipLayers)
    : new ConditionalVelocity(denoiser, conditioning.positive);
}

export interface DenoiseOptions {
  readonly steps: number;
  readonly signal?: AbortSignal;
  /** Called after each completed step. */
  readonly onStep?: (done: number, total: number) => void;
}

/** Flow-matching Euler sampling from `latents` (borrowed) down the schedule's
 * noise levels: per step `x + (sigma_next - sigma) * v` in float32, `v` from the
 * request's guidance step. Each evaluated step yields to the event loop, so a
 * cancellation from a timer, a disconnect or a signal handler is seen before the
 * next one. Returns owned, evaluated latents; on cancellation or failure every
 * intermediate is freed. */
export async function denoiseLatents(
  step: GuidanceStep, schedule: FlowMatchingSchedule, latents: MlxArray, options: DenoiseOptions,
): Promise<{ latents: MlxArray; steps: number }> {
  const sigmas = schedule.sigmas(options.steps);
  const total = sigmas.length - 1;
  let x = ops.copyOf(latents);
  try {
    for (let i = 0; i < total; i++) {
      checkAborted(options.signal);
      const sigma = sigmas[i]!, next = sigmas[i + 1]!;
      using velocity = step.velocity(x, schedule.timestep(sigma));
      using dt = MlxArray.fromFloat32(new Float32Array([next - sigma]), []);
      using change = ops.mul(dt, velocity);
      const updated = ops.add(x, change);
      try { updated.eval(); } catch (error) { updated.dispose(); throw error; }
      x.dispose();
      x = updated;
      options.onStep?.(i + 1, total);
      await new Promise<void>(resolve => setImmediate(resolve));
    }
    return { latents: x, steps: total };
  } catch (error) {
    x.dispose();
    throw error;
  }
}

/** Decode latents through the decoder's bound numerical and pixel operations.
 * The returned RGB bytes are independent of both owned native arrays. */
export function decodePixels(decoder: ImageLatentDecoder, latents: MlxArray): { pixels: Uint8Array; width: number; height: number } {
  using image = decoder.decode(latents);
  using pixels = decoder.pixels(image);
  const height = pixels.shape[1]!, width = pixels.shape[2]!;
  // A pixel operation may return a strided view; raw reads require row-major storage.
  using rowMajor = ops.contiguous(pixels);
  return { pixels: new Uint8Array(rowMajor.rawBytes()), width, height };
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
    report({ stage: "conditioner" });
    checkAborted(options.signal);
    let started = performance.now();
    opened.add("conditioner");
    const conditioner = await pipeline.conditioner();
    checkAborted(options.signal);
    conditioning = encodeConditioning(conditioner, resolved);
    const encodeMs = performance.now() - started;
    finish("conditioner");

    report({ stage: "denoiser", step: 0 });
    checkAborted(options.signal);
    started = performance.now();
    opened.add("denoiser");
    const denoiser = await pipeline.denoiser();
    checkAborted(options.signal);
    const step = guidanceFor(denoiser, conditioning, resolved);
    using noise = options.latents ? ops.copyOf(options.latents)
      : initialLatents(pipeline.latentChannels, pipeline.pixelsPerLatent, resolved.width, resolved.height, resolved.seed);
    const denoised = await denoiseLatents(step, pipeline.schedule, noise, {
      steps: resolved.steps, signal: options.signal,
      onStep: (step, steps) => report({ stage: "denoiser", step, steps }),
    });
    latents = denoised.latents;
    const denoiseMs = performance.now() - started;
    conditioning.dispose();
    conditioning = null;
    finish("denoiser");

    report({ stage: "decoder" });
    checkAborted(options.signal);
    started = performance.now();
    opened.add("decoder");
    const decoder = await pipeline.decoder();
    checkAborted(options.signal);
    const { pixels, width, height } = decodePixels(decoder, latents);
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
