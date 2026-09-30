import { expect, test } from "bun:test";
import type { CoreEvent, ModelOperations } from "@mlx-bun/app-core";
import { createResidencyHost, ResidencyError, type ResidencyEntry, type ResidencyHost, type ResidentUnit, type UnitClosed } from "../../src/residency/model-residency";

const GB = 1000;
/** Models by id and size; a unit records what the host did to it. Nothing here loads weights. */
function fixture(sizes: Record<string, number>, options: { budget: number; pinned?: string[]; measured?: () => number; external?: () => number; failLoad?: Set<string> }) {
  const log: string[] = [];
  const events: CoreEvent[] = [];
  const units = new Map<string, FakeUnit>();
  let resident = 0, peak = 0;
  class FakeUnit implements ResidentUnit {
    readonly operations = ["generate" as const];
    resumed = false;
    paused = 0;
    closeGate: Promise<void> = Promise.resolve();
    flushed = true;
    constructor(readonly id: string, readonly size: number) {}
    bytes() { return this.size; }
    memory() { return { weightsBytes: this.size, kvBytes: 0, prefixCacheBytes: 0 }; }
    operationsFor(): Partial<ModelOperations> { return { generate: async () => new Response(this.id) }; }
    async pause() { this.paused++; log.push(`pause ${this.id}`); return { dispose: () => { this.paused--; log.push(`unpause ${this.id}`); } }; }
    async close(): Promise<UnitClosed> {
      log.push(`drain ${this.id}`);
      await this.closeGate;
      log.push(`flush ${this.id}`);
      await Promise.resolve();
      log.push(`release ${this.id}`);
      resident -= this.size;
      return { flushed: this.flushed, flushMs: 1, drainMs: 1 };
    }
  }
  const loadGate = new Map<string, Promise<void>>();
  const resumes = new Set<string>();
  const loads: string[] = [];
  const host = createResidencyHost<FakeUnit>({
    budgetBytes: options.budget, pinned: options.pinned, measured: options.measured, external: options.external,
    events: { publish: event => events.push(event) },
    source: {
      async resolve(id): Promise<ResidencyEntry | undefined> { return id in sizes ? { id, bytes: sizes[id]!, operations: ["generate"] } : undefined; },
      async load(entry) {
        loads.push(entry.id);
        await loadGate.get(entry.id);
        if (options.failLoad?.has(entry.id)) throw new Error(`cannot load ${entry.id}`);
        resident += entry.bytes; peak = Math.max(peak, resident);
        const unit = new FakeUnit(entry.id, entry.bytes);
        unit.resumed = resumes.has(entry.id);
        units.set(entry.id, unit);
        log.push(`load ${entry.id}`);
        return unit;
      },
    },
  });
  return { host, log, events, units, loads, loadGate, resumes, get peak() { return peak; }, get resident() { return resident; } };
}
const ids = (host: ResidencyHost<ResidentUnit>) => host.resident().map(model => model.id).sort();
const tick = () => new Promise<void>(resolve => setTimeout(resolve, 5));

test("models that fit the budget load beside each other and are served without a second load", async () => {
  const f = fixture({ a: 4 * GB, b: 3 * GB }, { budget: 10 * GB });
  const a = await f.host.acquire("a"); a.release();
  const b = await f.host.acquire("b"); b.release();
  expect(ids(f.host)).toEqual(["a", "b"]);
  const again = await f.host.acquire("a");
  expect(again.loadMs).toBe(0);
  expect(await (await again.operations.generate!(new Request("http://x/"))).text()).toBe("a");
  again.release();
  expect(f.loads).toEqual(["a", "b"]);
  expect(f.host.stats("a")).toMatchObject({ resident: true, loads: 1, unloads: 0 });
});

test("a model that does not fit evicts the least recently used one: drain, flush, release, then load, never above the budget", async () => {
  const f = fixture({ a: 4 * GB, b: 4 * GB, c: 5 * GB }, { budget: 10 * GB });
  for (const id of ["a", "b"]) (await f.host.acquire(id)).release();
  // Touching a again makes b the least recently used.
  (await f.host.acquire("a")).release();
  const c = await f.host.acquire("c"); c.release();
  expect(ids(f.host)).toEqual(["a", "c"]);
  expect(f.log.slice(-4)).toEqual(["drain b", "flush b", "release b", "load c"]);
  expect(f.peak).toBeLessThanOrEqual(10 * GB);
  expect(f.host.stats("b")).toMatchObject({ resident: false, loads: 1, unloads: 1 });
  const unload = f.events.find(event => event.type === "model.unload");
  expect(unload).toMatchObject({ type: "model.unload", model: "b", reason: "evicted", flushed: true });
  expect(f.events.filter(event => event.type === "model.load" && event.phase === "finished").map(event => (event as { model: string }).model)).toEqual(["a", "b", "c"]);
});

test("loads announce whether saved state was found, adoption announces the loader's time, and a failed load carries its reason", async () => {
  const f = fixture({ a: 4 * GB, b: 4 * GB, c: 4 * GB }, { budget: 6 * GB, failLoad: new Set(["c"]) });
  f.resumes.add("b");
  (await f.host.acquire("a")).release();
  (await f.host.acquire("b")).release();
  await f.host.acquire("c").catch(() => undefined);
  const loads = f.events.filter(event => event.type === "model.load");
  expect(loads.map(event => `${(event as { model: string }).model} ${(event as { phase: string }).phase}${(event as { resumed?: boolean }).resumed ? " resumed" : ""}${(event as { error?: string }).error ? ` ${(event as { error?: string }).error}` : ""}`))
    .toEqual(["a started", "a finished", "b started", "b finished resumed", "c started", "c failed cannot load c"]);
  expect(loads.filter(event => (event as { phase: string }).phase === "finished").every(event => typeof (event as { ms?: number }).ms === "number")).toBe(true);
});

test("a model the loader already loaded is announced as resident with the time it took, and may be pinned", async () => {
  const f = fixture({ a: 4 * GB }, { budget: 10 * GB });
  const unit = { id: "a", operations: ["generate" as const], resumed: true, bytes: () => 4 * GB, memory: () => ({ weightsBytes: 4 * GB, kvBytes: 0, prefixCacheBytes: 0 }),
    operationsFor: () => ({}), pause: async () => ({ dispose() {} }), close: async () => ({ flushed: true }) };
  f.host.adopt({ id: "a", bytes: 4 * GB, operations: ["generate"] }, unit as never, { pin: true, loadMs: 321 });
  expect(f.events).toEqual([expect.objectContaining({ type: "model.load", model: "a", phase: "finished", ms: 321, weightsBytes: 4 * GB, resumed: true })]);
  expect(f.host.resident().map(model => [model.id, model.pinned])).toEqual([["a", true]]);
  expect(() => f.host.adopt({ id: "a", bytes: 4 * GB, operations: ["generate"] }, unit as never)).toThrow("already resident");
});

test("acquiring an evicted model reloads it, and it is not lent out while it drains", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  (await f.host.acquire("a")).release();
  const gate = Promise.withResolvers<void>();
  (await f.host.acquire("b")).release();
  f.units.get("b")!.closeGate = gate.promise;
  // a is evicted for b; a is asked for while b's eviction is still draining, so it waits its turn.
  const back = f.host.acquire("a");
  await tick();
  expect(f.log).toContain("drain b");
  expect(f.log).not.toContain("release b");
  gate.resolve();
  const lease = await back;
  expect(f.loads).toEqual(["a", "b", "a"]);
  expect(f.peak).toBeLessThanOrEqual(10 * GB);
  expect(f.host.stats("a")).toMatchObject({ loads: 2, unloads: 1 });
  lease.release();
});

test("a leased model is never evicted: the newcomer waits for the lease, then swaps, and never thrashes", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  const busy = await f.host.acquire("a");
  let done = false;
  const wanted = f.host.acquire("b").then(lease => { done = true; return lease; });
  await tick();
  expect(done).toBe(false);
  expect(f.log).toEqual(["load a"]);
  expect(ids(f.host)).toEqual(["a"]);
  busy.release();
  const lease = await wanted;
  expect(ids(f.host)).toEqual(["b"]);
  expect(f.log.slice(-4)).toEqual(["drain a", "flush a", "release a", "load b"]);
  lease.release();
});

test("a waiting request stops waiting when its signal aborts, and leaves nothing behind", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  const busy = await f.host.acquire("a");
  const controller = new AbortController();
  const wanted = f.host.acquire("b", { signal: controller.signal });
  await tick();
  controller.abort(new Error("client left"));
  await expect(wanted).rejects.toThrow("client left");
  expect(f.loads).toEqual(["a"]);
  busy.release();
  expect(f.host.resident().map(model => model.leases)).toEqual([0]);
});

test("pinned models are never evicted, and a plan lists the victims least recently used first", async () => {
  const f = fixture({ a: 3 * GB, b: 3 * GB, c: 3 * GB, d: 4 * GB }, { budget: 10 * GB, pinned: ["a"] });
  for (const id of ["a", "b", "c"]) (await f.host.acquire(id)).release();
  const plan = await f.host.plan("d");
  expect(plan).toEqual({ fits: true, requiredBytes: 4 * GB, freeBytes: 1 * GB, evict: ["b"] });
  (await f.host.acquire("d")).release();
  expect(ids(f.host)).toEqual(["a", "c", "d"]);
  expect(f.host.resident().find(model => model.id === "a")!.pinned).toBe(true);
  expect(f.host.policy.pinned).toEqual(["a"]);
  // Unpinned, it is an ordinary candidate again.
  f.host.unpin("a");
  const next = await f.host.plan("b");
  expect(next.evict).toEqual(["a"]);
});

test("a model bigger than the whole budget is still served alone, after everything unpinned is released", async () => {
  const f = fixture({ small: 2 * GB, huge: 30 * GB }, { budget: 10 * GB });
  (await f.host.acquire("small")).release();
  (await f.host.acquire("huge")).release();
  expect(ids(f.host)).toEqual(["huge"]);
});

test("measured memory floors the estimates, so a model whose estimate looks free still evicts when the process is full", async () => {
  let held = 0;
  const f = fixture({ a: 2 * GB, b: 4 * GB }, { budget: 10 * GB, measured: () => held });
  (await f.host.acquire("a")).release();
  held = 8 * GB;
  (await f.host.acquire("b")).release();
  expect(ids(f.host)).toEqual(["b"]);
});

test("residents the host does not manage (a Whisper companion) count against the budget", async () => {
  let companion = 0;
  const f = fixture({ a: 5 * GB, b: 4 * GB }, { budget: 10 * GB, external: () => companion });
  (await f.host.acquire("a")).release();
  companion = 3 * GB;
  (await f.host.acquire("b")).release();
  expect(ids(f.host)).toEqual(["b"]);
});

test("makeRoom drains least recently used models until the bytes fit, and waits while they are all leased", async () => {
  const f = fixture({ a: 4 * GB, b: 4 * GB }, { budget: 10 * GB });
  (await f.host.acquire("a")).release();
  const held = await f.host.acquire("b");
  let done = false;
  const room = f.host.makeRoom(4 * GB).then(() => { done = true; });
  await tick();
  // a is idle and enough: it is released, b (leased) is untouched.
  await room;
  expect(done).toBe(true);
  expect(ids(f.host)).toEqual(["b"]);
  held.release();
});

test("concurrent requests for one model share one load and each hold a lease", async () => {
  const f = fixture({ a: 2 * GB }, { budget: 10 * GB });
  const gate = Promise.withResolvers<void>();
  f.loadGate.set("a", gate.promise);
  const first = f.host.acquire("a"), second = f.host.acquire("a");
  await tick();
  gate.resolve();
  const [one, two] = await Promise.all([first, second]);
  expect(f.loads).toEqual(["a"]);
  expect(f.host.resident()[0]!.leases).toBe(2);
  one.release(); two.release();
  one.release();
  expect(f.host.resident()[0]!.leases).toBe(0);
});

test("a failed load rejects with load-failed, leaks no lease, and the model can be tried again", async () => {
  const failing = new Set(["a"]);
  const f = fixture({ a: 2 * GB }, { budget: 10 * GB, failLoad: failing });
  const error = await f.host.acquire("a").catch(e => e);
  expect(error).toBeInstanceOf(ResidencyError);
  expect(error.code).toBe("load-failed");
  expect(f.events.filter(event => event.type === "model.load").map(event => (event as { phase: string }).phase)).toEqual(["started", "failed"]);
  failing.delete("a");
  (await f.host.acquire("a")).release();
  expect(ids(f.host)).toEqual(["a"]);
});

test("unknown ids and missing operations are refused before anything loads", async () => {
  const f = fixture({ a: 2 * GB }, { budget: 10 * GB });
  await expect(f.host.acquire("nope")).rejects.toMatchObject({ code: "does-not-fit" });
  await expect(f.host.acquire("a", { need: ["embed"] })).rejects.toMatchObject({ code: "does-not-fit" });
  expect(f.loads).toEqual([]);
});

test("unload refuses a leased model unless forced, and a stopped unit reports what it saved", async () => {
  const f = fixture({ a: 2 * GB }, { budget: 10 * GB });
  const lease = await f.host.acquire("a");
  await expect(f.host.unload("a")).rejects.toMatchObject({ code: "in-use" });
  await f.host.unload("a", { force: true });
  expect(ids(f.host)).toEqual([]);
  lease.release();
  await f.host.unload("a");
  await f.host.unload("never-loaded");
});

test("pausing stops every resident execution and holds back new loads until it is disposed", async () => {
  const f = fixture({ a: 2 * GB, b: 2 * GB }, { budget: 10 * GB });
  (await f.host.acquire("a")).release();
  const pause = await f.host.pauseAll();
  expect(f.units.get("a")!.paused).toBe(1);
  let loaded = false;
  const wanted = f.host.acquire("b").then(lease => { loaded = true; return lease; });
  await tick();
  expect(loaded).toBe(false);
  // A resident model is still served (its requests wait at its own execution lock).
  (await f.host.acquire("a")).release();
  pause.dispose(); pause.dispose();
  expect(f.units.get("a")!.paused).toBe(0);
  (await wanted).release();
  expect(ids(f.host)).toEqual(["a", "b"]);
});

test("pausing waits for a model that is draining instead of pausing it, so a job never leases a closing engine", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  (await f.host.acquire("a")).release();
  const gate = Promise.withResolvers<void>();
  f.units.get("a")!.closeGate = gate.promise;
  const swap = f.host.acquire("b");
  await tick();
  expect(f.log).toContain("drain a");
  let paused = false;
  const pause = f.host.pauseAll().then(resource => { paused = true; return resource; });
  await tick();
  expect(paused).toBe(false);
  gate.resolve();
  // Once a has gone, nothing is left to pause, and the swap's load stays held back until the pause is disposed.
  const resource = await pause;
  expect(f.units.get("a")!.paused).toBe(0);
  expect(f.loads).toEqual(["a"]);
  resource.dispose();
  (await swap).release();
  expect(f.loads).toEqual(["a", "b"]);
});

test("close drains every resident model including pinned ones, waits for a load in flight, and then refuses work", async () => {
  const f = fixture({ a: 2 * GB, b: 2 * GB }, { budget: 10 * GB, pinned: ["a"] });
  (await f.host.acquire("a")).release();
  const gate = Promise.withResolvers<void>();
  f.loadGate.set("b", gate.promise);
  const loading = f.host.acquire("b").catch(error => error);
  await tick();
  const closing = f.host.close();
  gate.resolve();
  const results = await closing;
  expect(await loading).toMatchObject({ code: "closed" });
  expect(f.resident).toBe(0);
  expect(results.every(result => result.flushed)).toBe(true);
  expect(await f.host.close()).toBe(results);
  await expect(f.host.acquire("a")).rejects.toMatchObject({ code: "closed" });
});

test("a unit that could not make its state durable is still released, and says so", async () => {
  const f = fixture({ a: 6 * GB, b: 6 * GB }, { budget: 10 * GB });
  (await f.host.acquire("a")).release();
  f.units.get("a")!.flushed = false;
  (await f.host.acquire("b")).release();
  expect(f.events.find(event => event.type === "model.unload")).toMatchObject({ model: "a", flushed: false });
  expect(ids(f.host)).toEqual(["b"]);
});
