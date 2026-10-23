// Model-free: POST /v1/images/generations mounted the way a host mounts it
// (`createModuleRoutes`), over the real service with a fake `modelHost`:
// OpenAI's response shape with a decodable PNG, every refused field, the
// host's failures, and cancellation releasing the lease.
import { expect, test } from "bun:test";
import { decode } from "fast-png";
import type { RouteHandler } from "@mlx-bun/app-core";
import { createModuleRoutes } from "@mlx-bun/app-services";
import { manifest } from "../src/manifest";
import { createImageHandlers } from "../src/routes";
import { ImageService, NO_IMAGE_MODEL } from "../src/service";
import { DEFAULTS, FakeHostError, fakeCatalog, fakeHost, fakeOperation, MODEL_ID, OTHER_ID, pattern, ticking } from "./support";

function setup(input: Parameters<typeof fakeOperation>[0] & { defaultId?: string; acquire?: (id: string) => void } = {}) {
  const { operation, requests } = fakeOperation(input);
  const { host, events, held } = fakeHost(operation, { defaultId: "defaultId" in input ? input.defaultId : MODEL_ID, ...(input.acquire ? { acquire: input.acquire } : {}) });
  const handlers = createImageHandlers(new ImageService({ modelHost: host, catalog: fakeCatalog() }, { now: ticking() }), () => 1_700_000_000_123);
  const routes = createModuleRoutes(manifest.routes.map(spec => ({ spec, path: spec.path, handler: handlers[spec.id] as RouteHandler })));
  return { routes, requests, events, held };
}

const post = (body: unknown, init: RequestInit = {}) => new Request("http://localhost/v1/images/generations",
  { method: "POST", headers: { "content-type": "application/json" }, body: typeof body === "string" ? body : JSON.stringify(body), ...init });

test("a generation answers OpenAI's shape with a base64 PNG of the operation's pixels, and the extensions reach the operation", async () => {
  const { routes, requests, events, held } = setup();
  const response = (await routes.handle(post({ prompt: "a lighthouse", n: 1, size: "48x32", response_format: "b64_json", model: OTHER_ID,
    negative_prompt: "fog", steps: 2, guidance: 3.5, seed: 77, uncond_skip_layers: [] })))!;
  expect(response.status).toBe(200);
  const body = await response.json();
  expect(Object.keys(body)).toEqual(["created", "data", "mlx_bun"]);
  expect(body.created).toBe(1_700_000_000);
  expect(body.data).toHaveLength(1);
  expect(body.data[0].revised_prompt).toBeNull();
  const png = decode(Buffer.from(body.data[0].b64_json, "base64"));
  expect([png.width, png.height, png.channels]).toEqual([48, 32, 3]);
  expect(png.data).toEqual(pattern(48, 32, 77));
  expect(body.mlx_bun).toEqual({ model: OTHER_ID, width: 48, height: 32, seed: 77, steps: 2, guidance: 3.5,
    timings: { load_ms: 7, encode_ms: 11, denoise_ms: 22, decode_ms: 33, png_ms: 1, total_ms: expect.any(Number) } });
  expect(requests).toEqual([{ prompt: "a lighthouse", width: 48, height: 32, negativePrompt: "fog", steps: 2, guidance: 3.5, seed: 77, uncondSkipLayers: [] }]);
  expect(events).toEqual([`acquire ${OTHER_ID} need=image`, `release ${OTHER_ID}`]);
  expect(held()).toBe(0);
});

test("omitted fields take the model's defaults: no size, size auto, no model, null extensions", async () => {
  const { routes, requests } = setup();
  for (const body of [{ prompt: "x" }, { prompt: "x", size: "auto", model: null, n: null, response_format: null, seed: null }]) {
    const response = (await routes.handle(post(body)))!;
    expect(response.status).toBe(200);
    const result = await response.json();
    expect([result.mlx_bun.model, result.mlx_bun.width, result.mlx_bun.height, result.mlx_bun.steps]).toEqual([MODEL_ID, DEFAULTS.width, DEFAULTS.height, DEFAULTS.steps]);
  }
  expect(requests).toEqual([{ prompt: "x" }, { prompt: "x" }]);
});

test("every refused field is a 400 in the JSON error envelope, and none reaches the model", async () => {
  const cases: [unknown, string][] = [
    ["{not json", "invalid JSON body"],
    [[{ prompt: "x" }], "the body must be a JSON object"],
    [{}, "prompt must be a non-empty string"],
    [{ prompt: "   " }, "prompt must be a non-empty string"],
    [{ prompt: 42 }, "prompt must be a non-empty string"],
    [{ prompt: "x", n: 2 }, "n must be 1: this server generates one image per request, got 2"],
    [{ prompt: "x", n: 0 }, "n must be 1: this server generates one image per request, got 0"],
    [{ prompt: "x", n: "1" }, 'n must be 1: this server generates one image per request, got "1"'],
    [{ prompt: "x", response_format: "url" }, 'response_format "url" is not supported: this server hosts no image URLs; use "b64_json"'],
    [{ prompt: "x", response_format: "png" }, 'response_format must be "b64_json", got "png"'],
    [{ prompt: "x", size: "big" }, 'size must be "WIDTHxHEIGHT" (for example "1024x1024") or "auto", got "big"'],
    [{ prompt: "x", size: "1024" }, 'size must be "WIDTHxHEIGHT" (for example "1024x1024") or "auto", got "1024"'],
    [{ prompt: "x", size: "-16x16" }, 'size must be "WIDTHxHEIGHT" (for example "1024x1024") or "auto", got "-16x16"'],
    [{ prompt: "x", size: 1024 }, 'size must be "WIDTHxHEIGHT" (for example "1024x1024") or "auto", got 1024'],
    [{ prompt: "x", size: "0x16" }, "width must be a positive integer, got 0"],
    [{ prompt: "x", model: 7 }, "model must be a string"],
    [{ prompt: "x", negative_prompt: ["fog"] }, "negative prompt must be a string"],
    [{ prompt: "x", steps: 0 }, "steps must be a positive integer, got 0"],
    [{ prompt: "x", steps: 2.5 }, "steps must be a positive integer, got 2.5"],
    [{ prompt: "x", steps: "20" }, "steps must be a positive integer, got 20"],
    [{ prompt: "x", guidance: -1 }, "guidance must be a finite number >= 0, got -1"],
    [{ prompt: "x", guidance: "high" }, "guidance must be a finite number >= 0, got high"],
    [{ prompt: "x", seed: -3 }, "seed must be an integer in [0, 2^53), got -3"],
    [{ prompt: "x", seed: 1.25 }, "seed must be an integer in [0, 2^53), got 1.25"],
    [{ prompt: "x", seed: 2 ** 53 }, `seed must be an integer in [0, 2^53), got ${2 ** 53}`],
    [{ prompt: "x", uncond_skip_layers: [3, -1] }, "skip layers must be a list of non-negative integers"],
    [{ prompt: "x", uncond_skip_layers: 3 }, "skip layers must be a list of non-negative integers"],
  ];
  const { routes, events } = setup();
  for (const [body, message] of cases) {
    const response = (await routes.handle(post(body)))!;
    expect({ status: response.status, body: await response.json() }).toEqual({ status: 400, body: { error: { message, type: "invalid_request_error" } } });
  }
  expect(events).toEqual([]);
});

test("a size off the latent grid is refused after the lease, which is released", async () => {
  const { routes, events, held } = setup();
  const response = (await routes.handle(post({ prompt: "x", size: "1000x1024" })))!;
  expect([response.status, (await response.json()).error.message]).toEqual([400, "width must be a multiple of 16, got 1000"]);
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
});

test("model failures: unknown 404, none downloaded 503 with the hint, the host's RangeError 400, its residency codes, anything else 500", async () => {
  const unknown = (await setup().routes.handle(post({ prompt: "x", model: "dall-e-3" })))!;
  expect([unknown.status, await unknown.json()]).toEqual([404, { error: { message: 'no local model matches "dall-e-3"', type: "model_not_found" } }]);

  const none = (await setup({ defaultId: undefined }).routes.handle(post({ prompt: "x" })))!;
  expect([none.status, await none.json()]).toEqual([503, { error: { message: NO_IMAGE_MODEL, type: "model_unavailable" } }]);

  const ranged = setup({ generate: async () => { throw new RangeError("uncondSkipLayers must name blocks in [0, 24), got 99"); } });
  const rangeResponse = (await ranged.routes.handle(post({ prompt: "x", uncond_skip_layers: [99] })))!;
  expect([rangeResponse.status, (await rangeResponse.json()).error]).toEqual([400, { message: "uncondSkipLayers must name blocks in [0, 24), got 99", type: "invalid_request_error" }]);
  expect(ranged.held()).toBe(0);

  for (const [code, status, type] of [["load-failed", 502, "model_load_failed"], ["closed", 503, "server_closing"], ["does-not-fit", 400, "invalid_request_error"]] as const) {
    const failing = setup({ acquire: () => { throw new FakeHostError(code, `host says ${code}`); } });
    const response = (await failing.routes.handle(post({ prompt: "x" })))!;
    expect([response.status, await response.json()]).toEqual([status, { error: { message: `host says ${code}`, type, code } }]);
  }

  const broken = setup({ generate: async () => { throw new Error("decoder exploded"); } });
  const brokenResponse = (await broken.routes.handle(post({ prompt: "x" })))!;
  expect([brokenResponse.status, await brokenResponse.json()]).toEqual([500, { error: { message: "decoder exploded", type: "server_error" } }]);
  expect(broken.held()).toBe(0);
});

test("a client that disconnects mid-run cancels the generation and the lease is released", async () => {
  const started = Promise.withResolvers<void>();
  let reason: unknown;
  const { routes, events, held } = setup({ generate: async (_request, options) => {
    started.resolve();
    return new Promise((_, reject) => options!.signal!.addEventListener("abort", () => { reason = options!.signal!.reason; reject(reason); }, { once: true }));
  } });
  const abort = new AbortController();
  const response = routes.handle(post({ prompt: "x" }, { signal: abort.signal }));
  await started.promise;
  expect(held()).toBe(1);
  abort.abort(new DOMException("client went away", "AbortError"));
  const answered = (await response)!;
  expect([answered.status, await answered.json()]).toEqual([499, { error: { message: "request cancelled", type: "request_cancelled", code: "request_cancelled" } }]);
  expect((reason as DOMException).message).toBe("client went away");
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
});

test("only the declared route answers; other paths fall through to the host", async () => {
  const { routes } = setup();
  expect(await routes.handle(new Request("http://localhost/v1/images/edits", { method: "POST", body: "{}" }))).toBeNull();
  expect(await routes.handle(new Request("http://localhost/v1/images/generations"))).toBeNull();
});
