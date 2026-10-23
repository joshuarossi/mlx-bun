// Test seams for the images module: a catalog, a `modelHost` that records every
// lease, and an `image` operation that paints a deterministic pattern. No
// weights, no native code: the module sees only the app-core contracts.
import type {
  CatalogEntry, GeneratedImage, ImageDefaults, ImageOperation, ImageProgress, ImageRequest, ModelCatalog, ModelHost, ModelHostError, ResidencyFailure,
} from "@mlx-bun/app-core";

export const MODEL_ID = "org/image", MODEL_DIR = "/models/image", OTHER_ID = "org/other-image";

export const DEFAULTS: ImageDefaults = { width: 64, height: 32, steps: 3, guidance: 4.5, negativePrompt: "", uncondSkipLayers: [7, 8] };
export const PIXELS_PER_LATENT = 16;

/** A catalog that knows the given ids (id to directory) and finds them by id or directory. */
export function fakeCatalog(models: Record<string, string> = { [MODEL_ID]: MODEL_DIR, [OTHER_ID]: "/models/other" }): ModelCatalog {
  const entry = (id: string): CatalogEntry => ({ id, kind: "model", directory: models[id]!, bytes: 0, operations: ["image"] });
  const unused = () => { throw new Error("unused"); };
  return {
    list: async () => Object.keys(models).map(entry),
    resolve: async id => id in models ? entry(id) : undefined,
    async find(query) {
      const id = Object.keys(models).find(key => key === query || models[key] === query);
      if (!id) throw new Error(`no local model matches "${query}"`);
      return entry(id);
    },
    estimate: async () => ({ residentBytes: 0 }),
    locate: async () => undefined,
    register: async () => unused(), download: async () => unused(), pickDefault: async () => unused(),
    canPublish: () => false, rescan: async () => 0, startDownload: unused, downloads: () => [], publish: async () => unused(),
  };
}

/** The pattern the fake paints: red = x, green = y, blue = the seed's low byte. */
export function pattern(width: number, height: number, seed: number): Uint8Array {
  const pixels = new Uint8Array(width * height * 3);
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) pixels.set([x % 256, y % 256, seed % 256], (y * width + x) * 3);
  return pixels;
}

type Generate = ImageOperation["generate"];

/** An `image` operation over the defaults above; `generate` replaces the painting run (it receives the default as `paint`). */
export function fakeOperation(input: { generate?: (request: ImageRequest, options: Parameters<Generate>[1], paint: Generate) => Promise<GeneratedImage> } = {}) {
  const requests: ImageRequest[] = [];
  const paint: Generate = async (request, options = {}) => {
    const progress = (value: ImageProgress) => options.onProgress?.(value);
    const width = request.width ?? DEFAULTS.width, height = request.height ?? DEFAULTS.height, steps = request.steps ?? DEFAULTS.steps;
    const seed = request.seed ?? 1234;
    progress({ stage: "conditioner" });
    for (let step = 1; step <= steps; step++) { options.signal?.throwIfAborted(); progress({ stage: "denoiser", step, steps }); }
    progress({ stage: "decoder" });
    return { width, height, pixels: pattern(width, height, seed), seed, steps, guidance: request.guidance ?? DEFAULTS.guidance,
      timings: { encodeMs: 11, denoiseMs: 22, decodeMs: 33 } };
  };
  const operation: ImageOperation = {
    defaults: DEFAULTS,
    pixelsPerLatent: PIXELS_PER_LATENT,
    async generate(request, options) {
      requests.push(request);
      return input.generate ? input.generate(request, options, paint) : paint(request, options);
    },
  };
  return { operation, requests };
}

export class FakeHostError extends Error implements ModelHostError {
  constructor(readonly code: ResidencyFailure, message: string) { super(message); }
}

/** A `modelHost` that hands out leases over `operation`, records acquires and releases, and answers `defaultFor("image")` with `defaultId`. */
export function fakeHost(operation: ImageOperation | undefined, input: { defaultId?: string; acquire?: (id: string) => void } = {}) {
  const events: string[] = [];
  let held = 0;
  const unused = () => { throw new Error("unused"); };
  const host: ModelHost = {
    policy: { budgetBytes: 0, pinned: [], idleUnloadSec: 0 },
    async acquire(id, options = {}) {
      options.signal?.throwIfAborted();
      events.push(`acquire ${id} need=${(options.need ?? []).join(",")}`);
      input.acquire?.(id);
      held++;
      let released = false;
      return {
        model: { id, role: "companion", state: "ready", operations: ["image"], bytes: 0, pinned: false, leases: held, lastUsedAt: 0 },
        loadMs: 7,
        operations: operation ? { image: operation } : {},
        release() {
          if (released) throw new Error("released twice");
          released = true; held--; events.push(`release ${id}`);
        },
      };
    },
    defaultFor: async operationName => operationName === "image" ? input.defaultId : undefined,
    plan: async () => unused(), serve: async () => unused(), unload: async () => unused(), pin: unused, unpin: unused,
    resident: () => [], stats: () => unused(),
  };
  return { host, events, held: () => held };
}

/** A clock that advances one millisecond per read. */
export function ticking(): () => number {
  let now = 0;
  return () => now++;
}
