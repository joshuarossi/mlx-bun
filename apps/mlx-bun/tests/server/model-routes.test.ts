import { expect, test } from "bun:test";
import type { ModelOperations } from "@mlx-bun/app-core";
import { createResidencyHost, type ResidencyEntry } from "../../src/engine/model-residency";
import { createModelRoutes, modelField, type RoutedUnit } from "../../src/server/model-routes";

const GB = 1000;
const post = (path: string, body: unknown, signal?: AbortSignal) => new Request(`http://app${path}`, { method: "POST",
  headers: { "content-type": "application/json" }, body: typeof body === "string" ? body : JSON.stringify(body), ...(signal ? { signal } : {}) });
const get = (path: string) => new Request(`http://app${path}`);

/** Models by id; each unit answers the wire routes with its own id and records what reached it. */
function fixture(sizes: Record<string, number>, options: { budget?: number; current?: string; failLoad?: Set<string> } = {}) {
  const received: { unit: string; path: string; body: string }[] = [];
  const units = new Map<string, FakeUnit>();
  class FakeUnit implements RoutedUnit {
    readonly operations = ["generate" as const];
    stream: ReadableStreamDefaultController<Uint8Array> | undefined;
    hold = false;
    constructor(readonly id: string) {}
    bytes() { return sizes[this.id]!; }
    memory() { return { weightsBytes: this.bytes(), kvBytes: 0, prefixCacheBytes: 0 }; }
    async pause() { return { dispose() {} }; }
    async close() { return { flushed: true }; }
    routes = { handle: async (request: Request): Promise<Response | null> => {
      const url = new URL(request.url);
      const body = request.method === "POST" ? await request.text() : "";
      received.push({ unit: this.id, path: url.pathname, body });
      if (url.pathname === "/v1/chat/completions") {
        if (this.hold) return new Response(new ReadableStream<Uint8Array>({ start: controller => { this.stream = controller; } }));
        return Response.json({ model: this.id });
      }
      if (url.pathname === "/v1/models" || url.pathname.startsWith("/v1/models/")) {
        const full = { id: this.id, object: "model", context_window: 4096 };
        const others = Object.keys(sizes).filter(id => id !== this.id).map(id => ({ id, object: "model", tier: "supported" }));
        const filter = url.pathname === "/v1/models" ? null : decodeURIComponent(url.pathname.slice("/v1/models/".length));
        const data = [full, ...others, { id: "org/whisper", object: "model", transcription: true, resident: false }];
        return Response.json({ object: "list", data: filter ? data.filter(entry => entry.id === filter) : data });
      }
      if (url.pathname === "/library") return Response.json({ models: Object.keys(sizes).map(repo_id => ({ repo_id, serving: repo_id === this.id })) });
      if (url.pathname === "/stats") return Response.json({ server: { model: this.id } });
      if (url.pathname === "/v1/adapters/load") return Response.json({ mounted: this.id });
      if (url.pathname === "/health") return Response.json({ status: "ok", from: this.id });
      return null;
    } };
    operationsFor(): Partial<ModelOperations> {
      return { generate: async request => await this.routes.handle(request) ?? Response.json({}, { status: 404 }) };
    }
  }
  let current = options.current ?? Object.keys(sizes)[0]!;
  const host = createResidencyHost<FakeUnit>({ budgetBytes: options.budget ?? 100 * GB,
    source: {
      async resolve(id): Promise<ResidencyEntry | undefined> { return id in sizes ? { id, bytes: sizes[id]!, operations: ["generate"] } : undefined; },
      async load(entry) {
        if (options.failLoad?.has(entry.id)) throw new Error(`cannot load ${entry.id}`);
        const unit = new FakeUnit(entry.id); units.set(entry.id, unit); return unit;
      },
    } });
  const routes = createModelRoutes({ host, current: () => current, serves: async id => id in sizes });
  return { host, routes, received, units, setCurrent(id: string) { current = id; } };
}

test("a request naming an exact local model is answered by it, loading it first; anything else is the current model's", async () => {
  const f = fixture({ a: 2 * GB, b: 2 * GB });
  (await f.host.acquire("a")).release();
  const named = await f.routes.handle(post("/v1/chat/completions", { model: "b", messages: [] }));
  expect(await named!.json()).toEqual({ model: "b" });
  expect(f.host.resident().map(model => model.id).sort()).toEqual(["a", "b"]);
  // Pi's `local`, a name another server would know, no model, and a body that is not JSON all ride the current model.
  for (const body of [{ model: "local" }, { model: "gpt-4" }, { messages: [] }, "not json", "[1]", { model: 7 }]) {
    const answered = await f.routes.handle(post("/v1/chat/completions", body));
    expect(await answered!.json()).toEqual({ model: "a" });
  }
  // The routed body reaches the model's own parser byte for byte.
  expect(f.received.filter(item => item.unit === "b").map(item => item.body)).toEqual([JSON.stringify({ model: "b", messages: [] })]);
  f.setCurrent("b");
  expect(await (await f.routes.handle(post("/v1/chat/completions", { model: "local" })))!.json()).toEqual({ model: "b" });
});

test("the model stays leased until the response body ends, is cancelled, or fails, and never longer", async () => {
  const f = fixture({ a: 2 * GB });
  (await f.host.acquire("a")).release();
  f.units.get("a")!.hold = true;
  const leases = () => f.host.resident()[0]!.leases;
  const response = (await f.routes.handle(post("/v1/chat/completions", { model: "a", stream: true })))!;
  expect(leases()).toBe(1);
  const reader = response.body!.getReader();
  const first = reader.read();
  f.units.get("a")!.stream!.enqueue(new TextEncoder().encode("data: 1\n\n"));
  expect(new TextDecoder().decode((await first).value)).toBe("data: 1\n\n");
  expect(leases()).toBe(1);
  const second = reader.read();
  f.units.get("a")!.stream!.close();
  expect((await second).done).toBe(true);
  expect(leases()).toBe(0);
  // A client that goes away releases it too.
  const cancelled = (await f.routes.handle(post("/v1/chat/completions", { model: "a", stream: true })))!;
  expect(leases()).toBe(1);
  await cancelled.body!.cancel();
  expect(leases()).toBe(0);
  // A stream that breaks releases it.
  const broken = (await f.routes.handle(post("/v1/chat/completions", { model: "a", stream: true })))!;
  const failing = broken.body!.getReader().read();
  f.units.get("a")!.stream!.error(new Error("stream broke"));
  await expect(failing).rejects.toThrow("stream broke");
  expect(leases()).toBe(0);
});

test("an evictable model is not released under a stream: a swap waits for the stream to end", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  (await f.host.acquire("a")).release();
  f.units.get("a")!.hold = true;
  const stream = (await f.routes.handle(post("/v1/chat/completions", { model: "a" })))!;
  let swapped = false;
  const other = f.routes.handle(post("/v1/chat/completions", { model: "b" })).then(response => { swapped = true; return response; });
  await new Promise(resolve => setTimeout(resolve, 10));
  expect(swapped).toBe(false);
  expect(f.host.resident().map(model => model.id)).toEqual(["a"]);
  const reading = stream.body!.getReader().read();
  f.units.get("a")!.stream!.close();
  await reading;
  expect(await (await other)!.json()).toEqual({ model: "b" });
  expect(f.host.resident().map(model => model.id)).toEqual(["b"]);
});

test("a model that cannot be leased answers with a typed error and holds nothing", async () => {
  const f = fixture({ a: 2 * GB, broken: 2 * GB }, { failLoad: new Set(["broken"]) });
  (await f.host.acquire("a")).release();
  const failed = (await f.routes.handle(post("/v1/chat/completions", { model: "broken" })))!;
  expect(failed.status).toBe(502);
  expect(await failed.json()).toMatchObject({ error: { type: "model_load_failed", code: "load-failed", message: "cannot load broken" } });
  expect(f.host.resident().map(model => model.leases)).toEqual([0]);
  await f.host.close();
  const closed = (await f.routes.handle(post("/v1/chat/completions", { model: "a" })))!;
  expect(closed.status).toBe(503);
  expect((await closed.json()).error.type).toBe("server_closing");
});

test("a client that leaves while its model is loading gets the cancellation answer, not a leaked lease", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  const busy = await f.host.acquire("a");
  const controller = new AbortController();
  const answered = f.routes.handle(post("/v1/chat/completions", { model: "b" }, controller.signal));
  await new Promise(resolve => setTimeout(resolve, 10));
  controller.abort();
  expect((await answered)!.status).toBe(499);
  busy.release();
  expect(f.host.resident().map(model => model.leases)).toEqual([0]);
});

test("/v1/models lists every local model: resident ones as they describe themselves, the rest as the registry knows them, with residency and the current model", async () => {
  const f = fixture({ a: 2 * GB, b: 2 * GB, c: 2 * GB });
  (await f.host.acquire("a")).release(); (await f.host.acquire("b")).release();
  f.setCurrent("b");
  const list = await (await f.routes.handle(get("/v1/models")))!.json();
  expect(list.data).toEqual([
    { id: "b", object: "model", context_window: 4096, resident: true, current: true },
    { id: "a", object: "model", context_window: 4096, resident: true, current: false },
    { id: "c", object: "model", tier: "supported", resident: false, current: false },
    { id: "org/whisper", object: "model", transcription: true, resident: false },
  ]);
  const one = await (await f.routes.handle(get("/v1/models/a")))!.json();
  expect(one.data.map((entry: { id: string }) => entry.id)).toEqual(["a"]);
  const bare = await (await f.routes.handle(get("/v1/models/c")))!.json();
  expect(bare.data).toEqual([{ id: "c", object: "model", tier: "supported", resident: false, current: false }]);
});

test("/library marks the current model as serving and which are resident, and /stats reports the host's residency", async () => {
  const f = fixture({ a: 2 * GB, b: 3 * GB }, { budget: 20 * GB });
  (await f.host.acquire("a")).release(); (await f.host.acquire("b")).release();
  f.setCurrent("b");
  const library = await (await f.routes.handle(get("/library")))!.json();
  expect(library.models).toEqual([{ repo_id: "a", serving: false, resident: true }, { repo_id: "b", serving: true, resident: true }]);
  const stats = await (await f.routes.handle(get("/stats")))!.json();
  expect(stats.server).toEqual({ model: "b" });
  expect(stats.models).toMatchObject({ current: "b", budget_bytes: 20 * GB, resident_bytes: 5 * GB });
  expect(stats.models.resident.map((model: { id: string }) => model.id).sort()).toEqual(["a", "b"]);
});

test("everything else model-scoped belongs to the current model; a change holds it resident, and an unmatched path falls through", async () => {
  const f = fixture({ a: 2 * GB, b: 2 * GB });
  (await f.host.acquire("a")).release(); (await f.host.acquire("b")).release();
  f.setCurrent("a");
  expect(await (await f.routes.handle(post("/v1/adapters/load", {})))!.json()).toEqual({ mounted: "a" });
  expect(f.host.resident().map(model => model.leases)).toEqual([0, 0]);
  // Not the models' path: the request goes on to the app's other groups, and nothing is left leased.
  expect(await f.routes.handle(post("/api/jobs", {}))).toBeNull();
  expect(await f.routes.handle(get("/api/jobs"))).toBeNull();
  expect(f.host.resident().map(model => model.leases)).toEqual([0, 0]);
  expect(await (await f.routes.handle(get("/health")))!.json()).toEqual({ status: "ok", from: "a" });
});

test("with no model resident, reads fall through and health still answers", async () => {
  const f = fixture({ a: 2 * GB });
  expect(await f.routes.handle(get("/stats"))).toBeNull();
  expect(await f.routes.handle(get("/v1/models"))).toBeNull();
  expect(await (await f.routes.handle(get("/health")))!.json()).toEqual({ status: "ok" });
});

test("the routing field is the JSON body's string `model` and nothing else", () => {
  expect(modelField('{"model":"org/x","n":1}')).toBe("org/x");
  expect(modelField(new TextEncoder().encode('{"model":"y"}'))).toBe("y");
  for (const body of ["", "null", "[]", '{"model":1}', '{"other":"x"}', "{bad"]) expect(modelField(body)).toBeUndefined();
});
