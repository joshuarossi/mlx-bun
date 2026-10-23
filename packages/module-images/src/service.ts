// Text-to-image over a model the host leases: request validation, model
// resolution, the `image` lease and PNG encoding. The route and the verb are
// adapters over `ImageService.generate`; neither loads weights nor decides
// residency, which are the host's `modelHost` policy.
//
// A generation holds its lease from acquire until the operation settles,
// whatever the outcome (success, failure, cancellation), and releases it
// before the PNG is encoded.

import type { CoreServices, GeneratedImage, ImageProgress, ImageRequest } from "@mlx-bun/app-core";
import { encodePng } from "./png";

export type ImageServices = Pick<CoreServices, "modelHost" | "catalog">;

export const NO_IMAGE_MODEL =
  "no image model is available; download a text-to-image model with mlx-bun get <org/repo>, or name a local one";

/** A request the service refused before or instead of generating, with the HTTP status and error type the route answers. */
export class ImageRequestError extends Error {
  constructor(message: string, readonly status: number, readonly type = "invalid_request_error") {
    super(message);
    this.name = "ImageRequestError";
  }
}

const invalid = (message: string) => new ImageRequestError(message, 400);

/** Everything about a request that holds for any model: types, positivity, the seed range. Throws an `ImageRequestError` (400). */
export function validateImageRequest(request: ImageRequest): void {
  if (typeof request.prompt !== "string" || !request.prompt.trim()) throw invalid("prompt must be a non-empty string");
  if (request.negativePrompt !== undefined && typeof request.negativePrompt !== "string") throw invalid("negative prompt must be a string");
  for (const name of ["width", "height", "steps"] as const) {
    const value = request[name];
    if (value !== undefined && !(Number.isSafeInteger(value) && value > 0)) throw invalid(`${name} must be a positive integer, got ${String(value)}`);
  }
  const { guidance, seed, uncondSkipLayers } = request;
  if (guidance !== undefined && !(typeof guidance === "number" && Number.isFinite(guidance) && guidance >= 0))
    throw invalid(`guidance must be a finite number >= 0, got ${String(guidance)}`);
  if (seed !== undefined && !(Number.isSafeInteger(seed) && seed >= 0)) throw invalid(`seed must be an integer in [0, 2^53), got ${String(seed)}`);
  if (uncondSkipLayers !== undefined && !(Array.isArray(uncondSkipLayers) && uncondSkipLayers.every(block => Number.isSafeInteger(block) && block >= 0)))
    throw invalid("skip layers must be a list of non-negative integers");
}

/** One generation: the model (a directory or cached query; undefined = the host's default for `image`) and the request. */
export interface ImageGeneration {
  readonly model?: string;
  readonly request: ImageRequest;
  /** Cancels the wait for the model and the run; the lease is released either way. */
  readonly signal?: AbortSignal;
  readonly onProgress?: (progress: ImageProgress) => void;
}

export interface ImageOutcome {
  readonly modelId: string;
  readonly image: GeneratedImage;
  /** The image as a PNG file's bytes. */
  readonly png: Uint8Array;
  /** Milliseconds: `load_ms` is non-zero exactly when this generation waited for the model to load. */
  readonly timings: { readonly load_ms: number; readonly encode_ms: number; readonly denoise_ms: number; readonly decode_ms: number; readonly png_ms: number; readonly total_ms: number };
}

export interface ImageServiceOptions {
  /** The owner's lifetime (the module's): when it aborts, generations in flight are cancelled and new ones refused. */
  readonly signal?: AbortSignal;
  /** Monotonic milliseconds for the reported timings. */
  readonly now?: () => number;
}

const isRangeError = (error: unknown): error is Error => error instanceof RangeError || (error as Error | undefined)?.name === "RangeError";

export class ImageService {
  readonly #services: ImageServices;
  readonly #lifetime: AbortSignal | undefined;
  readonly #now: () => number;
  /** Generations still running; `close()` joins them, so their leases are back before the host releases the models. */
  readonly #inflight = new Set<Promise<unknown>>();

  constructor(services: ImageServices, options: ImageServiceOptions = {}) {
    this.#services = services;
    this.#lifetime = options.signal;
    this.#now = options.now ?? (() => performance.now());
  }

  /** The catalog id for a directory or cached query, else the host's default for `image`. */
  async resolveModel(query?: string): Promise<string> {
    if (query !== undefined) {
      try { return (await this.#services.catalog.find(query)).id; }
      catch (error) { throw new ImageRequestError((error as Error)?.message ?? String(error), 404, "model_not_found"); }
    }
    const id = await this.#services.modelHost.defaultFor("image");
    if (!id) throw new ImageRequestError(NO_IMAGE_MODEL, 503, "model_unavailable");
    return id;
  }

  /** Validate, resolve the model, lease it for `image`, generate, release, and encode the PNG. */
  generate(input: ImageGeneration): Promise<ImageOutcome> {
    const work = this.#generate(input);
    this.#inflight.add(work);
    work.finally(() => { this.#inflight.delete(work); }).catch(() => {});
    return work;
  }

  async #generate(input: ImageGeneration): Promise<ImageOutcome> {
    validateImageRequest(input.request);
    const signals = [input.signal, this.#lifetime].filter(signal => signal !== undefined);
    try { return await this.#run(input, signals.length ? AbortSignal.any(signals) : undefined); }
    catch (error) {
      // Stopping the owner cancels the run; the caller hears that the service stopped, not its own cancellation.
      if (this.#lifetime?.aborted && !input.signal?.aborted) throw new ImageRequestError("the image service has stopped", 503, "server_closing");
      throw error;
    }
  }

  async #run(input: ImageGeneration, signal: AbortSignal | undefined): Promise<ImageOutcome> {
    const { request } = input;
    signal?.throwIfAborted();
    const started = this.#now();
    const modelId = await this.resolveModel(input.model);
    signal?.throwIfAborted();
    const lease = await this.#services.modelHost.acquire(modelId, { need: ["image"], ...(signal ? { signal } : {}) });
    let image: GeneratedImage;
    try {
      const operation = lease.operations.image;
      if (!operation) throw new Error(`${modelId} did not provide the image operation`);
      for (const name of ["width", "height"] as const) {
        const value = request[name];
        if (value !== undefined && value % operation.pixelsPerLatent !== 0)
          throw invalid(`${name} must be a multiple of ${operation.pixelsPerLatent}, got ${value}`);
      }
      image = await operation.generate(request, { ...(signal ? { signal } : {}), ...(input.onProgress ? { onProgress: input.onProgress } : {}) });
    } catch (error) {
      // The host refuses what only the model knows (a skip-layer block past its depth) with a RangeError.
      if (!signal?.aborted && isRangeError(error)) throw invalid(error.message);
      throw error;
    } finally { lease.release(); }
    const encoding = this.#now();
    const png = encodePng(image);
    const finished = this.#now();
    return { modelId, image, png, timings: { load_ms: lease.loadMs, encode_ms: image.timings.encodeMs, denoise_ms: image.timings.denoiseMs,
      decode_ms: image.timings.decodeMs, png_ms: finished - encoding, total_ms: finished - started } };
  }

  /** Join the generations in flight; the lifetime signal has cancelled them, so each releases its lease as it settles. */
  async close(): Promise<void> {
    await Promise.allSettled([...this.#inflight]);
  }
}
