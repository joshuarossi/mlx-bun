import { expect, test } from "bun:test";
import type { LoadedModelContext } from "../../src/engine/model-host";
import { createDiscoveryRoutes, matchDiscoveryRoute } from "../../src/server/discovery-routes";

test("discovery matches only its GET surfaces and leaves other requests to composition", () => {
  for (const [path, route] of [["/library", "library"], ["/downloads", "downloads"], ["/v1", "api-index"],
    ["/health", "health"], ["/v1/models", "models"], ["/v1/models/org/model", "models"]] as const) {
    expect(matchDiscoveryRoute("GET", path)).toBe(route);
    expect(matchDiscoveryRoute("POST", path)).toBeNull();
  }
  expect(matchDiscoveryRoute("GET", "/not-discovery")).toBeNull();
});

function discovery(modelType: string, adapters: boolean, training: boolean, failScan = false) {
  let scans = 0, closes = 0;
  const context = { modelId: `test/${modelType}`, model: { config: { modelType, text: { maxPositionEmbeddings: 8192 } } },
    template: { supportsThinking: false }, genDefaults: {}, draft: null } as unknown as LoadedModelContext;
  const routes = createDiscoveryRoutes(context, { discovery: { adapters, training, dsa: !adapters, embeddings: false } },
    123000, undefined, () => ({
      async scan() { scans++; if (failScan) throw new Error("scan failed"); return 0; },
      listCanonical: () => [], close: () => { closes++; },
    }));
  const get = (path: string) => {
    const request = new Request(`http://local${path}`);
    return routes.handle(new URL(request.url), request);
  };
  return { routes, get, scans: () => scans, closes: () => closes };
}

test("model discovery preserves batch vocabulary and binding capabilities and closes its registry", async () => {
  for (const [modelType, supported] of [["qwen3", true], ["glm5", false]] as const) {
    const run = discovery(modelType, supported, supported);
    const response = (await run.get(`/v1/models/test/${modelType}`))!;
    expect(response.status).toBe(200);
    expect((await response.json()).data).toEqual([expect.objectContaining({ batch_mode: "batch", adapters: supported, training: supported,
      dsa: !supported, capabilities: expect.objectContaining({ adapters: supported, training: supported, anthropic_messages: true, responses: true }) })]);
    expect(run.scans()).toBe(1); expect(run.closes()).toBe(1);
  }
});

test("library discovery closes each registry and refreshes only when its cache is invalidated", async () => {
  const run = discovery("qwen3", true, true);
  expect(await (await run.get("/library"))!.json()).toEqual({ models: [] });
  await run.get("/library");
  expect(run.scans()).toBe(1); expect(run.closes()).toBe(1);
  run.routes.invalidateLibrary(); await run.get("/library");
  expect(run.scans()).toBe(2); expect(run.closes()).toBe(2);
});

test("discovery releases its registry when scanning fails", async () => {
  const run = discovery("qwen3", true, true, true);
  await expect(run.get("/library")).rejects.toThrow("scan failed");
  expect(run.closes()).toBe(1);
  // Cache discovery is optional for /models: the served model remains visible.
  expect((await (await run.get("/v1/models"))!.json()).data).toHaveLength(1);
  expect(run.scans()).toBe(2); expect(run.closes()).toBe(2);
});

test("downloads serves the composition's progress rows when supplied", async () => {
  const context = { modelId: "test/model", model: { config: { modelType: "llama", text: { maxPositionEmbeddings: 8192 } } },
    template: { supportsThinking: false }, genDefaults: {}, draft: null } as unknown as LoadedModelContext;
  const rows = [{ repoId: "org/tiny", state: "active" as const, currentFile: null, receivedBytes: 0, totalBytes: 0,
    filesDone: 0, filesTotal: 0, bytesPerSec: 0, startedAt: 5, finishedAt: null }];
  const routes = createDiscoveryRoutes(context, { discovery: { adapters: false, training: false, dsa: true, embeddings: false } },
    1, undefined, undefined, () => rows);
  const request = new Request("http://local/downloads");
  expect(await (await routes.handle(new URL(request.url), request))!.json()).toEqual({ downloads: rows });
});

test("a configured Whisper companion is listed beside the chat model and the API index names the audio routes", async () => {
  const context = { modelId: "test/model", model: { config: { modelType: "llama", text: { maxPositionEmbeddings: 8192 } } },
    template: { supportsThinking: false }, genDefaults: {}, draft: null } as unknown as LoadedModelContext;
  const registry = () => ({ async scan() { return 0; }, listCanonical: () => [], close() {} });
  const binding = { discovery: { adapters: false, training: false, dsa: true, embeddings: false } };
  const get = async (routes: ReturnType<typeof createDiscoveryRoutes>, path: string) => {
    const request = new Request(`http://local${path}`);
    return (await routes.handle(new URL(request.url), request))!.json();
  };
  const withWhisper = createDiscoveryRoutes(context, binding, 7000, async () => ({ id: "org/whisper", resident: true }), registry);
  const listed = await get(withWhisper, "/v1/models");
  expect(listed.data).toEqual([
    expect.objectContaining({ id: "test/model", capabilities: expect.objectContaining({ transcription: true }) }),
    { id: "org/whisper", object: "model", created: 7, owned_by: "mlx-bun", transcription: true, resident: true,
      capabilities: { transcription: true, translation: true, chat_completions: false } },
  ]);
  expect((await get(withWhisper, "/v1/models/org/whisper")).data).toHaveLength(1);
  const without = createDiscoveryRoutes(context, binding, 7000, async () => null, registry);
  const alone = await get(without, "/v1/models");
  expect(alone.data).toHaveLength(1);
  expect(alone.data[0].capabilities.transcription).toBe(false);
  const index = await get(without, "/v1");
  expect(index.endpoints).toEqual(expect.arrayContaining(["POST /v1/audio/transcriptions", "POST /v1/audio/translations"]));
});
