import { expect, test } from "bun:test";
import type { HttpMethod, RouteHandler, RouteSpec } from "@mlx-bun/app-core";
import { createCompanionInfoRoutes, createModuleRoutes } from "../src";

const route = (method: HttpMethod, path: string, handler: RouteHandler) =>
  ({ spec: { id: path, method, path, summary: "", response: "json" } satisfies RouteSpec, path, handler });
const request = (method: string, path: string) => new Request(`http://localhost${path}`, { method });

test("module routes match by method and exact path shape, with :name matching one non-empty segment; the rest falls through", async () => {
  const routes = createModuleRoutes([
    route("POST", "/v1/x", () => new Response("post")), route("GET", "/v1/x", () => new Response("get")),
    route("DELETE", "/v1/x/:id", req => new Response(`delete ${new URL(req.url).pathname}`)), route("POST", "/v1/x/:id/go", () => new Response("go")),
  ]);
  const text = async (method: string, path: string) => (await routes.handle(request(method, path)))?.text() ?? null;
  expect(await text("POST", "/v1/x")).toBe("post");
  expect(await text("GET", "/v1/x")).toBe("get");
  expect(await text("DELETE", "/v1/x/a%2Fb")).toBe("delete /v1/x/a%2Fb");
  expect(await text("POST", "/v1/x/7/go")).toBe("go");
  for (const [method, path] of [["PUT", "/v1/x"], ["POST", "/v1/x/"], ["DELETE", "/v1/x/"], ["POST", "/v1/x/7"], ["POST", "/v1/x/7/go/more"], ["GET", "/v1/y"], ["GET", "/"]] as const)
    expect(await text(method, path)).toBeNull();
  expect(await createModuleRoutes([]).handle(request("POST", "/v1/x"))).toBeNull();
});

test("the transcription-only discovery routes describe the checkpoint alone", async () => {
  let resident = false;
  const routes = createCompanionInfoRoutes({ modelId: "org/whisper", name: "mlx-bun", version: "1.2.3", startedAt: 5_000,
    endpoints: ["POST /v1/audio/transcriptions", "GET /health"],
    models: { stats: () => ({ resident, loads: 1, unloads: 1, lastLoadMs: 250, idleUnloadSec: 0 }) },
    counters: () => ({ requests: 3, sessions: 2 }) });
  const get = (path: string) => routes.handle(new Request(`http://localhost${path}`));
  expect(await (await get("/health"))!.json()).toEqual({ status: "ok", transcription: { resident: false, loads: 1, unloads: 1, requests: 3, last_load_ms: 250, idle_unload_sec: 0, sessions: 2 } });
  expect(await (await get("/stats"))!.json()).toMatchObject({ model: "org/whisper", transcription: { requests: 3 }, uptime_s: expect.any(Number) });
  expect(await (await get("/v1"))!.json()).toEqual({ name: "mlx-bun", version: "1.2.3", model: "org/whisper", mode: "transcription", endpoints: ["POST /v1/audio/transcriptions", "GET /health"] });
  resident = true;
  expect(await (await get("/v1/models"))!.json()).toEqual({ object: "list", data: [{ id: "org/whisper", object: "model", created: 5, owned_by: "mlx-bun", transcription: true, resident: true,
    capabilities: { transcription: true, translation: true, chat_completions: false } }] });
  expect((await (await get("/v1/models/org/whisper"))!.json()).data).toHaveLength(1);
  expect((await (await get("/v1/models/other"))!.json()).data).toEqual([]);
  expect(await get("/v1/chat/completions")).toBeNull();
  expect(await routes.handle(new Request("http://localhost/health", { method: "POST" }))).toBeNull();
  // Before the module reports anything the counters read zero.
  const idle = createCompanionInfoRoutes({ modelId: "m", name: "n", version: "v", endpoints: [], models: { stats: () => ({ resident: false, loads: 0, unloads: 0, lastLoadMs: 0, idleUnloadSec: null }) }, counters: () => undefined });
  expect(await (await idle.handle(new Request("http://localhost/health")))!.json()).toMatchObject({ transcription: { requests: 0, sessions: 0, idle_unload_sec: null } });
});
