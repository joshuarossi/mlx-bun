import { expect, spyOn, test } from "bun:test";
import type { AdapterInfo } from "@mlx-bun/inference/adapters";
import { createAdapterOperation } from "../../src/engine/adapter-operation";
import type { GenerationGateway } from "../../src/engine/generation-gateway";
import type { LoadedModelContext } from "../../src/engine/model-host";

// The `adapters` operation of a loaded model over a stand-in adapter manager and gateway: what runs under the engine's lock and what does not.
const info: AdapterInfo = { id: "tuned", path: "/adapter", rank: 2, scale: 1, sizeBytes: 100, mountedLayers: 2, skippedTensors: 3, ramBytes: 80 };
function setup() {
  const calls: string[] = [], signals: (AbortSignal | undefined)[] = [];
  let mounted = true;
  const context = { adapters: {
    list: () => mounted ? [info] : [],
    async mount(id: string, path: string) { calls.push(`mount:${id}:${path}`); mounted = true; return { ...info, id, path }; },
    unmount(id: string) { calls.push(`unmount:${id}`); const count = mounted ? 2 : 0; mounted = false; return count; },
  } } as Pick<LoadedModelContext, "adapters">;
  const gateway: Pick<GenerationGateway, "runExclusive"> = { async runExclusive(work, _trace, signal) {
    calls.push("lock"); signals.push(signal); signal?.throwIfAborted();
    try { return await work(); } finally { calls.push("unlock"); }
  } };
  return { context, gateway, calls, signals };
}

test("mounting and unmounting borrow the execution lock and forward cancellation; listing reads without it and drops what the wire does not carry", async () => {
  const run = setup(), controller = new AbortController();
  const operation = createAdapterOperation(run.context, run.gateway);
  expect(await operation.list()).toEqual([{ id: "tuned", path: "/adapter", rank: 2, scale: 1, sizeBytes: 100, mountedLayers: 2, ramBytes: 80 }]);
  expect(run.calls).toEqual([]);
  expect(await operation.mount("new", "/new", controller.signal)).toEqual({ id: "new", path: "/new", rank: 2, scale: 1, sizeBytes: 100, mountedLayers: 2, ramBytes: 80 });
  expect(await operation.unmount("a b")).toBe(2);
  expect(await operation.unmount("a b")).toBe(0);
  expect(run.calls).toEqual(["lock", "mount:new:/new", "unlock", "lock", "unmount:a b", "unlock", "lock", "unmount:a b", "unlock"]);
  expect(run.signals[0]).toBe(controller.signal);
  controller.abort();
  await expect(operation.mount("late", "/late", controller.signal)).rejects.toThrow();
  expect(run.calls).not.toContain("mount:late:/late");
});

const stats = { layersMerged: 2, layersOnlyInOne: 1, totalKeysOut: 6, sources: ["/a", "/b"], scales: [1, -0.5] };

test("merge passes the sources, the output and the scales to the training library under the lock, and a failure releases it after the library's cleanup", async () => {
  const run = setup(), events: string[] = [];
  const args: unknown[][] = [];
  const operation = createAdapterOperation(run.context, run.gateway, async (...input) => { args.push(input); events.push("merge"); return stats; });
  expect(await operation.merge({ adapters: ["/a", "/b"], output: "/out", scales: [1, -0.5] })).toEqual(stats);
  expect(args).toEqual([[["/a", "/b"], "/out", [1, -0.5]]]);
  await operation.merge({ adapters: ["/a", "/b"], output: "/out" });
  expect(args[1]![2]).toBeUndefined();
  const failing = createAdapterOperation(run.context, run.gateway, async () => {
    try { events.push("merge"); throw new Error("incompatible adapters"); } finally { events.push("library cleanup"); }
  });
  run.calls.length = 0; events.length = 0;
  await expect(failing.merge({ adapters: ["/a", "/b"], output: "/out" })).rejects.toThrow("incompatible adapters");
  expect(events).toEqual(["merge", "library cleanup"]);
  expect(run.calls).toEqual(["lock", "unlock"]);
});

test("a merge whose admission was cancelled never runs, and one already running keeps its lock until cleanup settled even after the caller left", async () => {
  const controller = new AbortController();
  let entered = false, called = false;
  const waiting: Pick<GenerationGateway, "runExclusive"> = { async runExclusive(_work, _trace, signal) {
    entered = true;
    await new Promise<void>((_, reject) => signal!.addEventListener("abort", () => reject(signal!.reason), { once: true }));
    throw new Error("unreachable");
  } };
  const cancelled = createAdapterOperation(setup().context, waiting, async () => { called = true; return stats; });
  const pending = cancelled.merge({ adapters: ["/a", "/b"], output: "/out" }, controller.signal);
  while (!entered) await Bun.sleep(1);
  controller.abort();
  await expect(pending).rejects.toBeDefined(); expect(called).toBe(false);

  const events: string[] = [], gone = new AbortController();
  let finish!: () => void;
  const done = new Promise<void>(resolve => { finish = resolve; });
  const run = setup();
  const lock: Pick<GenerationGateway, "runExclusive"> = { async runExclusive(work) { events.push("lock"); try { return await work(); } finally { events.push("unlock"); } } };
  const running = createAdapterOperation(run.context, lock, async () => { events.push("merge"); await done; events.push("library cleanup"); return stats; });
  const held = running.merge({ adapters: ["/a", "/b"], output: "/out" }, gone.signal);
  while (!events.includes("merge")) await Bun.sleep(1);
  gone.abort(); expect(events).toEqual(["lock", "merge"]);
  finish(); await held;
  expect(events).toEqual(["lock", "merge", "library cleanup", "unlock"]);
});

test("merges queued behind one another run serially, each with its own output", async () => {
  const clock = spyOn(Date, "now").mockReturnValue(123456789);
  try {
    let release!: () => void, allQueued!: () => void;
    let tail = new Promise<void>(resolve => { release = resolve; });
    const queued = new Promise<void>(resolve => { allQueued = resolve; });
    let admissions = 0;
    const gateway: Pick<GenerationGateway, "runExclusive"> = { runExclusive(work) {
      const result = tail.then(work);
      tail = result.then(() => {}, () => {});
      if (++admissions === 2) allQueued();
      return result;
    } };
    const outputs: string[] = [];
    const operation = createAdapterOperation(setup().context, gateway, async (_sources, output) => { outputs.push(output); return stats; });
    const pending = ["/one", "/two"].map(output => operation.merge({ adapters: ["/a", "/b"], output }));
    await queued;
    expect(outputs).toEqual([]);
    release();
    await Promise.all(pending);
    expect(outputs).toEqual(["/one", "/two"]);
  } finally { clock.mockRestore(); }
});
