import { expect, test } from "bun:test";
import type { AdapterInfo } from "@mlx-bun/inference/adapters";
import type { LoadedModelContext } from "../../src/engine/model-host";
import type { GenerationGateway } from "../../src/engine/generation-gateway";
import { createAdapterRoutes } from "../../src/server/adapter-routes";

function setup() {
  const calls: string[] = [], signals: (AbortSignal | undefined)[] = [];
  const info: AdapterInfo = { id: "tuned", path: "/adapter", rank: 2, scale: 1, sizeBytes: 100, mountedLayers: 2, skippedTensors: 0, ramBytes: 80 };
  let mounted = true;
  const adapters = {
    list: () => mounted ? [info] : [],
    async mount(id: string, path: string) { calls.push(`mount:${id}:${path}`); mounted = true; return { ...info, id, path }; },
    unmount(id: string) { calls.push(`unmount:${id}`); const count = mounted ? 2 : 0; mounted = false; return count; },
  } as LoadedModelContext["adapters"];
  const gateway: Pick<GenerationGateway, "runExclusive"> = { async runExclusive(work, _key, signal) {
    calls.push("lock"); signals.push(signal); signal?.throwIfAborted();
    try { return await work(); } finally { calls.push("unlock"); }
  } };
  const routes = createAdapterRoutes({ modelId: "org/Model", adapters }, gateway, async () => [
    { ...info, baseModel: "different/MODEL" }, { ...info, id: "other", baseModel: "org/Other" },
    { ...info, id: "unknown", baseModel: null },
  ]);
  const request = (method: string, path = "/v1/adapters", body?: unknown, signal?: AbortSignal) => routes.handle(new Request(`http://local${path}`, {
    method, ...(body !== undefined ? { body: JSON.stringify(body) } : {}), signal,
  }));
  return { request, calls, signals };
}

test("adapter inventory preserves wire metadata and model compatibility without mutating the engine", async () => {
  const run = setup();
  expect(await (await run.request("GET"))!.json()).toEqual({ adapters: [{ id: "tuned", path: "/adapter", rank: 2, scale: 1, size_bytes: 100, mounted_layers: 2, ram_bytes: 80 }] });
  const available = await (await run.request("GET", "/v1/adapters/available"))!.json();
  expect(available.adapters.map((a: { mounted: boolean; compatible: boolean }) => [a.mounted, a.compatible])).toEqual([[true, true], [false, false], [false, true]]);
  expect(run.calls).toEqual([]);
  expect(await run.request("GET", "/unrelated")).toBeNull();
});

test("adapter mutation borrows the execution lock and forwards request cancellation", async () => {
  const run = setup(), controller = new AbortController();
  const mounted = await run.request("POST", undefined, { id: "new", path: "/new" }, controller.signal);
  expect(await mounted!.json()).toEqual({ id: "new", mounted_layers: 2, rank: 2, scale: 1, ram_bytes: 80 });
  expect(run.calls).toEqual(["lock", "mount:new:/new", "unlock"]);
  expect(run.signals[0]?.aborted).toBe(false);
  expect(await (await run.request("DELETE", "/v1/adapters/a%20b"))!.json()).toEqual({ id: "a b", removed_layers: 2 });
  expect((await run.request("DELETE", "/v1/adapters/a%20b"))!.status).toBe(404);
  const calls = run.calls.length;
  controller.abort();
  expect((await run.request("POST", undefined, { id: "new", path: "/new" }, controller.signal))!.status).toBe(499);
  expect(run.calls).toHaveLength(calls);
});

test("malformed adapter requests fail before acquiring a lock or allocating tensors", async () => {
  const run = setup();
  for (const body of [null, [], {}, { id: 2, path: "/a" }, { id: "a", path: false }, { id: " ", path: "/a" }])
    expect((await run.request("POST", undefined, body))!.status).toBe(400);
  expect((await run.request("DELETE", "/v1/adapters/%GG"))!.status).toBe(400);
  expect(run.calls).toEqual([]);
});
