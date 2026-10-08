import { expect, test } from "bun:test";
import type { ModelHostError } from "@mlx-bun/app-core";
import { createServedModelHost } from "../src/cli/served-model-host";
import type { ServedHostLink } from "../src/cli/served-model-host";
import { createResidencyHost, type ResidentUnit } from "../src/residency/model-residency";
import { createWhisperModelHost } from "@mlx-bun/app-services";

const link = (extra: Partial<ServedHostLink> = {}): ServedHostLink => ({ model: { id: "org/model", bytes: 123 }, port: 4321,
  ...extra });
const code = async (work: Promise<unknown>) => { try { await work; } catch (error) { return (error as ModelHostError).code; } return undefined; };

test("with no serving host attached there is no default model and acquiring is refused", async () => {
  let attached: ServedHostLink | undefined;
  const host = createServedModelHost({ link: () => attached, fetch: async () => new Response() });
  expect(await host.defaultFor("generate")).toBeUndefined();
  expect(host.resident()).toEqual([]);
  expect(await code(host.acquire("org/model"))).toBe("closed");
  attached = link();
  expect(await host.defaultFor("generate")).toBe("org/model");
  expect(await host.defaultFor("transcribe")).toBeUndefined();
  expect(host.policy).toEqual({ budgetBytes: 123, pinned: ["org/model"], idleUnloadSec: 0 });
  attached = undefined;
  expect(await code(host.acquire("org/model"))).toBe("closed");
});

test("a lease admits only the served model and its declared operation, and counts until released", async () => {
  const host = createServedModelHost({ link: () => link(), fetch: async () => new Response() });
  expect(await code(host.acquire("other"))).toBe("does-not-fit");
  expect(await code(host.acquire("org/model", { need: ["embed"] }))).toBe("does-not-fit");
  const lease = await host.acquire("org/model", { need: ["generate"] });
  expect(lease.model).toMatchObject({ id: "org/model", role: "primary", state: "ready", operations: ["generate"], bytes: 123, pinned: true, leases: 1 });
  expect(Object.keys(lease.operations)).toEqual(["generate"]);
  expect(host.resident()[0]!.leases).toBe(1);
  lease.release(); lease.release();
  expect(host.resident()[0]!.leases).toBe(0);
  expect(await code(host.unload("org/model"))).toBe("in-use");
  expect(host.stats("org/model")).toMatchObject({ resident: true, unloads: 0, idleUnloadSec: null });
  expect(await host.plan("org/model")).toMatchObject({ fits: true, evict: [] });
});

test("generate sends the wire request to the host's own listener, keeping method, path, query, headers, body and signal", async () => {
  const sent: { request: Request; link: ServedHostLink }[] = [];
  const attached = link({ unix: "/tmp/host.sock" });
  const host = createServedModelHost({ link: () => attached, fetch: async (request, to) => { sent.push({ request, link: to }); return Response.json({ ok: true }); } });
  const lease = await host.acquire("org/model");
  const abort = new AbortController();
  const response = await lease.operations.generate!(new Request("http://model.local/v1/chat/completions?x=1", { method: "POST",
    headers: { "content-type": "application/json", authorization: "Bearer t" }, body: '{"a":1}', signal: abort.signal }));
  expect(await response.json()).toEqual({ ok: true });
  const { request, link: to } = sent[0]!;
  expect(request.url).toBe("http://127.0.0.1:4321/v1/chat/completions?x=1");
  expect(request.method).toBe("POST");
  expect(request.headers.get("authorization")).toBe("Bearer t");
  expect(await request.text()).toBe('{"a":1}');
  expect(to.unix).toBe("/tmp/host.sock");
  abort.abort(new Error("stop"));
  expect(request.signal.aborted).toBe(true);
});

test("switching goes to the host's own switch with the caller's signal; a host that serves one model says it cannot switch", async () => {
  const seen: { model: string; signal: AbortSignal }[] = [];
  const switching = createServedModelHost({ link: () => link({ async serve(model, signal) { seen.push({ model, signal }); } }), fetch: async () => new Response() });
  const abort = new AbortController();
  await switching.serve("org/other", { signal: abort.signal });
  await switching.serve("org/third");
  expect(seen.map(entry => entry.model)).toEqual(["org/other", "org/third"]);
  expect(seen[0]!.signal).toBe(abort.signal);
  expect(seen[1]!.signal.aborted).toBe(false);
  const single = createServedModelHost({ link: () => link(), fetch: async () => new Response() });
  expect(await code(single.serve("org/other"))).toBe("not-switchable");
  const detached = createServedModelHost({ link: () => undefined, fetch: async () => new Response() });
  expect(await code(detached.serve("org/other"))).toBe("closed");
});

test("the host reports every resident model the serving host lends, else the served one; a lease carries the served model's adapter operation when the host has one", async () => {
  const held = [{ id: "org/model", role: "primary" as const, state: "ready" as const, operations: ["generate" as const], bytes: 1, pinned: false, leases: 0, lastUsedAt: 0, uses: ["/snap"] },
    { id: "org/other", role: "primary" as const, state: "ready" as const, operations: ["generate" as const], bytes: 2, pinned: false, leases: 0, lastUsedAt: 0 }];
  const adapters = { list: async () => [], mount: async () => { throw new Error("unused"); }, unmount: async () => 0, merge: async () => ({}) };
  const rich = createServedModelHost({ link: () => link({ resident: () => held, adapters }), fetch: async () => new Response() });
  expect(rich.resident().map(model => model.id)).toEqual(["org/model", "org/other"]);
  expect(Object.keys((await rich.acquire("org/model")).operations).sort()).toEqual(["adapters", "generate"]);
  expect((await rich.acquire("org/model")).operations.adapters).toBe(adapters);
  const plain = createServedModelHost({ link: () => link(), fetch: async () => new Response() });
  expect(plain.resident().map(model => model.id)).toEqual(["org/model"]);
  expect(Object.keys((await plain.acquire("org/model")).operations)).toEqual(["generate"]);
});

test("a lease on a host whose residency evicts holds the model through the host's hold: a competing acquire waits for the long lease, then swaps", async () => {
  // Two 6-unit models in a 10-unit budget: only one is resident at a time.
  const closed: string[] = [];
  const unit = (id: string): ResidentUnit => ({ id, operations: ["generate"], bytes: () => 6, memory: () => ({ weightsBytes: 6, kvBytes: 0, prefixCacheBytes: 0 }),
    operationsFor: () => ({}), pause: async () => ({ dispose() {} }), close: async () => { closed.push(id); return { flushed: true }; } });
  const residency = createResidencyHost({ budgetBytes: 10, source: {
    resolve: async id => ({ id, bytes: 6, operations: ["generate"] }), load: async entry => unit(entry.id) } });
  (await residency.acquire("org/model")).release();
  const host = createServedModelHost({ link: () => link({ hold: (id, signal) => residency.acquire(id, { need: ["generate"], ...(signal ? { signal } : {}) }) }),
    fetch: async () => new Response() });
  // A job's lease on the served model is a long lease: while it is held another model that needs the room waits.
  const lease = await host.acquire("org/model", { need: ["generate"] });
  expect(residency.resident().find(model => model.id === "org/model")!.leases).toBe(1);
  let acquired = false;
  const competing = residency.acquire("org/other").then(held => { acquired = true; return held; });
  await Bun.sleep(30);
  expect([acquired, closed]).toEqual([false, []]);
  lease.release(); lease.release();
  (await competing).release();
  expect(closed).toEqual(["org/model"]);
  expect(residency.resident().map(model => model.id)).toEqual(["org/other"]);
  // A host with no hold (it never evicts) leases as before.
  const plain = createServedModelHost({ link: () => link(), fetch: async () => new Response() });
  (await plain.acquire("org/model")).release();
});

test("a lease that cannot be held (the model does not fit or the host is closing) is refused, and holds nothing", async () => {
  const host = createServedModelHost({ link: () => link({ hold: async () => { throw Object.assign(new Error("closed"), { code: "closed" }); } }), fetch: async () => new Response() });
  expect(await code(host.acquire("org/model"))).toBe("closed");
  expect(host.resident()[0]!.leases).toBe(0);
});

test("one service leases generation and companion transcription while the companion keeps its lifecycle and execution lock", async () => {
  const seen: string[] = [];
  let decoding = 0;
  const companions = createWhisperModelHost({
    catalog: { list: async () => [{ id: "org/audio", kind: "model", directory: "/audio", bytes: 100, operations: ["transcribe"] }],
      find: async () => { throw new Error("not found"); } },
    log() {},
    exclusive: async work => { decoding++; try { return await work(); } finally { decoding--; } },
    backend: { async load() {
      seen.push("load");
      return { promptTokenBudget: 7, encode: text => [text.length],
        async transcribe() { expect(decoding).toBe(1); return { text: "hello", segments: [], language: "en" }; },
        start() { return { segments: [], feedSilent() {}, async feed() {}, async finish() { return { text: "", segments: [], language: "en" }; } }; },
        dispose() { seen.push("dispose"); } };
    } },
  });
  let attached: ServedHostLink | undefined = link({ companions, hold: async () => { seen.push("hold generation"); return { release() { seen.push("release generation"); } }; } });
  const host = createServedModelHost({ link: () => attached, fetch: async () => new Response("generated") });
  try {
    expect(await host.defaultFor("generate")).toBe("org/model");
    expect(await host.defaultFor("transcribe")).toBe("org/audio");
    const generation = await host.acquire("org/model", { need: ["generate"] });
    const audio = await host.acquire("org/audio", { need: ["transcribe"], role: "companion", keepAliveSec: 0 });
    expect(audio.operations.transcribe!.encode("hint")).toEqual([4]);
    expect(await audio.operations.transcribe!.transcribe(new Float32Array(4))).toMatchObject({ text: "hello" });
    expect(await (await generation.operations.generate!(new Request("http://local/v1/completions"))).text()).toBe("generated");
    expect(host.resident().map(model => model.id)).toEqual(["org/model", "org/audio"]);
    expect(host.stats("org/audio").resident).toBe(true);
    await expect(host.unload("org/audio")).rejects.toMatchObject({ code: "in-use" });
    audio.release(); audio.release();
    expect(host.stats("org/audio")).toMatchObject({ resident: false, loads: 1, unloads: 1 });
    generation.release();
    expect(seen).toEqual(["hold generation", "load", "dispose", "release generation"]);
    // Pinning and explicit unload still belong to the companion host.
    host.pin("org/audio");
    (await host.acquire("org/audio", { need: ["transcribe"] })).release();
    expect(host.policy.pinned).toContain("org/audio");
    expect(host.stats("org/audio").resident).toBe(true);
    host.unpin("org/audio");
    await host.unload("org/audio");
    expect(host.stats("org/audio").resident).toBe(false);
    expect((await host.plan("org/audio")).requiredBytes).toBe(100);
    attached = undefined;
    expect(await host.defaultFor("transcribe")).toBeUndefined();
    expect(host.resident()).toEqual([]);
    await expect(host.acquire("org/audio", { need: ["transcribe"] })).rejects.toMatchObject({ code: "closed" });
  } finally { await companions.close(); }
});
