// Model-free: model resolution, validation before the lease, the lease's
// lifetime on every outcome, the host's RangeError, PNG output and stopping,
// over a fake `modelHost` and catalog.
import { expect, test } from "bun:test";
import { decode } from "fast-png";
import { ImageRequestError, ImageService, NO_IMAGE_MODEL, validateImageRequest } from "../src/service";
import { DEFAULTS, fakeCatalog, fakeHost, fakeOperation, MODEL_DIR, MODEL_ID, OTHER_ID, pattern, ticking } from "./support";

function setup(input: Parameters<typeof fakeOperation>[0] & { defaultId?: string } = {}) {
  const { operation, requests } = fakeOperation(input);
  const { host, events, held } = fakeHost(operation, { defaultId: "defaultId" in input ? input.defaultId : MODEL_ID });
  const service = new ImageService({ modelHost: host, catalog: fakeCatalog() }, { now: ticking() });
  return { service, requests, events, held };
}

test("no model named: the host's default for image is leased for image, released, and the PNG is the operation's pixels", async () => {
  const { service, requests, events, held } = setup();
  const outcome = await service.generate({ request: { prompt: "a red fox", seed: 9 } });
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
  expect(requests).toEqual([{ prompt: "a red fox", seed: 9 }]);
  expect(outcome.modelId).toBe(MODEL_ID);
  const png = decode(outcome.png);
  expect([png.width, png.height, png.channels, png.depth]).toEqual([DEFAULTS.width, DEFAULTS.height, 3, 8]);
  expect(png.data).toEqual(pattern(DEFAULTS.width, DEFAULTS.height, 9));
  expect(outcome.timings).toMatchObject({ load_ms: 7, encode_ms: 11, denoise_ms: 22, decode_ms: 33, png_ms: 1 });
  expect(outcome.timings.total_ms).toBeGreaterThan(outcome.timings.png_ms);
});

test("a named model resolves through the catalog, by id or directory", async () => {
  const { service, events } = setup();
  await service.generate({ model: OTHER_ID, request: { prompt: "x" } });
  await service.generate({ model: MODEL_DIR, request: { prompt: "x" } });
  expect(events.filter(event => event.startsWith("acquire"))).toEqual([`acquire ${OTHER_ID} need=image`, `acquire ${MODEL_ID} need=image`]);
  expect(await service.resolveModel(OTHER_ID)).toBe(OTHER_ID);
});

test("with no image model, generation fails with the download hint and never acquires", async () => {
  const { service, events } = setup({ defaultId: undefined });
  const failure = await service.generate({ request: { prompt: "x" } }).catch(error => error);
  expect(failure).toBeInstanceOf(ImageRequestError);
  expect(failure.message).toBe(NO_IMAGE_MODEL);
  expect(failure.message).toContain("mlx-bun get");
  expect([failure.status, failure.type]).toEqual([503, "model_unavailable"]);
  expect(events).toEqual([]);
});

test("an unknown model is a 404 with the catalog's message, before any lease", async () => {
  const { service, events } = setup();
  const failure = await service.generate({ model: "nope", request: { prompt: "x" } }).catch(error => error);
  expect([failure.status, failure.type, failure.message]).toEqual([404, "model_not_found", 'no local model matches "nope"']);
  expect(events).toEqual([]);
});

test("every model-independent field is validated before the lease", async () => {
  const cases: [Record<string, unknown>, string][] = [
    [{ prompt: "" }, "prompt must be a non-empty string"],
    [{ prompt: "  \n" }, "prompt must be a non-empty string"],
    [{ prompt: 5 }, "prompt must be a non-empty string"],
    [{ prompt: "x", negativePrompt: 3 }, "negative prompt must be a string"],
    [{ prompt: "x", width: 0 }, "width must be a positive integer, got 0"],
    [{ prompt: "x", height: 15.5 }, "height must be a positive integer, got 15.5"],
    [{ prompt: "x", width: "64" }, "width must be a positive integer, got 64"],
    [{ prompt: "x", steps: 0 }, "steps must be a positive integer, got 0"],
    [{ prompt: "x", guidance: -0.5 }, "guidance must be a finite number >= 0, got -0.5"],
    [{ prompt: "x", guidance: Number.NaN }, "guidance must be a finite number >= 0, got NaN"],
    [{ prompt: "x", seed: -1 }, "seed must be an integer in [0, 2^53), got -1"],
    [{ prompt: "x", seed: 2 ** 53 }, `seed must be an integer in [0, 2^53), got ${2 ** 53}`],
    [{ prompt: "x", seed: 0.5 }, "seed must be an integer in [0, 2^53), got 0.5"],
    [{ prompt: "x", uncondSkipLayers: [1, -1] }, "skip layers must be a list of non-negative integers"],
    [{ prompt: "x", uncondSkipLayers: "1" }, "skip layers must be a list of non-negative integers"],
  ];
  const { service, events } = setup();
  for (const [request, message] of cases) {
    const failure = await service.generate({ request: request as never }).catch(error => error);
    expect([failure.status, failure.message]).toEqual([400, message]);
  }
  expect(events).toEqual([]);
  // The edges that are allowed.
  expect(() => validateImageRequest({ prompt: "x", seed: 0, guidance: 0, uncondSkipLayers: [] })).not.toThrow();
  expect(() => validateImageRequest({ prompt: "x", seed: 2 ** 53 - 1 })).not.toThrow();
});

test("a size off the model's latent grid is refused once leased, and the lease is released", async () => {
  const { service, events, held, requests } = setup();
  const failure = await service.generate({ request: { prompt: "x", width: 1000, height: 64 } }).catch(error => error);
  expect([failure.status, failure.message]).toEqual([400, "width must be a multiple of 16, got 1000"]);
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
  expect(requests).toEqual([]);
});

test("the host's RangeError becomes a 400; any other failure passes through; the lease is released either way", async () => {
  let failure: Error = new RangeError("uncondSkipLayers must name blocks in [0, 24), got 99");
  const { service, events, held } = setup({ generate: async () => { throw failure; } });
  const ranged = await service.generate({ request: { prompt: "x", uncondSkipLayers: [99] } }).catch(error => error);
  expect(ranged).toBeInstanceOf(ImageRequestError);
  expect([ranged.status, ranged.message]).toEqual([400, "uncondSkipLayers must name blocks in [0, 24), got 99"]);
  failure = new Error("decoder exploded");
  await expect(service.generate({ request: { prompt: "x" } })).rejects.toThrow("decoder exploded");
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`, `acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
});

test("a model without the image operation is refused and released", async () => {
  const { host, events, held } = fakeHost(undefined, { defaultId: MODEL_ID });
  const service = new ImageService({ modelHost: host, catalog: fakeCatalog() });
  await expect(service.generate({ request: { prompt: "x" } })).rejects.toThrow(`${MODEL_ID} did not provide the image operation`);
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
});

test("progress reaches the caller; a cancelled run rejects with the caller's reason and releases the lease", async () => {
  const started = Promise.withResolvers<void>();
  const { service, held, events } = setup({ generate: async (request, options, paint) => {
    started.resolve();
    await new Promise((_, reject) => options!.signal!.addEventListener("abort", () => reject(options!.signal!.reason), { once: true }));
    return paint(request, options);
  } });
  const abort = new AbortController();
  const run = service.generate({ request: { prompt: "x" }, signal: abort.signal });
  await started.promise;
  expect(held()).toBe(1);
  abort.abort(new Error("caller cancelled"));
  await expect(run).rejects.toThrow("caller cancelled");
  expect(held()).toBe(0);
  expect(events.at(-1)).toBe(`release ${MODEL_ID}`);

  const seen: string[] = [];
  const plain = setup();
  await plain.service.generate({ request: { prompt: "x", steps: 2 }, onProgress: progress => seen.push(`${progress.stage}${progress.step ? ` ${progress.step}/${progress.steps}` : ""}`) });
  expect(seen).toEqual(["conditioner", "denoiser 1/2", "denoiser 2/2", "decoder"]);
});

test("stopping the owner cancels the run in flight as a 503, refuses new runs, and close joins after the release", async () => {
  const started = Promise.withResolvers<void>();
  const { operation } = fakeOperation({ generate: async (_request, options) => {
    started.resolve();
    return new Promise((_, reject) => options!.signal!.addEventListener("abort", () => reject(options!.signal!.reason), { once: true }));
  } });
  const { host, held } = fakeHost(operation, { defaultId: MODEL_ID });
  const lifetime = new AbortController();
  const service = new ImageService({ modelHost: host, catalog: fakeCatalog() }, { signal: lifetime.signal });
  const run = service.generate({ request: { prompt: "x" } }).catch(error => error);
  await started.promise;
  lifetime.abort();
  await service.close();
  expect(held()).toBe(0);
  const failure = await run;
  expect([failure.status, failure.type]).toEqual([503, "server_closing"]);
  const late = await service.generate({ request: { prompt: "x" } }).catch(error => error);
  expect([late.status, late.type]).toEqual([503, "server_closing"]);
  expect(held()).toBe(0);
});
