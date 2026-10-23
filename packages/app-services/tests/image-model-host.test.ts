// The image model host's contract with a fake backend (no model, no MLX): leases,
// lazy open, idle policy, the execution lock around runs, cancellation, and the
// stage-residency policy the host hands each run.
import { expect, test } from "bun:test";
import type { CatalogEntry, CoreEvent, ImageProgress, ImageRequest, ModelCatalog, ModelHostError } from "@mlx-bun/app-core";
import { createImageModelHost, fixedStageRule, stageBudgetRule, type ImageBackend, type ImageRunOptions, type LoadedImagePipeline } from "../src";

const entry = (id: string, directory = `/models/${id}`, operations: CatalogEntry["operations"] = ["image"]): CatalogEntry =>
  ({ id, kind: "model", directory, bytes: 900, operations });
const catalog = (entries: CatalogEntry[]): ModelCatalog => ({
  list: async () => entries, resolve: async id => entries.find(item => item.id === id),
  find: async query => entries.find(item => item.id === query) ?? (() => { throw new Error(`no model matching "${query}"`); })(),
  estimate: async () => undefined, locate: async () => undefined, register: async () => { throw new Error("unused"); },
  download: async () => { throw new Error("unused"); }, pickDefault: async () => { throw new Error("unused"); }, rescan: async () => 0, startDownload() { throw new Error("unused"); }, downloads: () => [], canPublish: () => false, publish: async () => { throw new Error("unused"); },
});

const defaults = { width: 64, height: 64, steps: 4, guidance: 3, negativePrompt: "", uncondSkipLayers: [1] };
const stageBytes = { conditioner: 500, denoiser: 300, decoder: 100 };

interface Run { request: ImageRequest; options: ImageRunOptions; finish(): void; fail(error: Error): void }

/** A pipeline whose runs wait until the test finishes them (or their signal aborts), recording what the host asked of each. */
function setup(options: Partial<Parameters<typeof createImageModelHost>[0]> = {}, entries = [entry("org/image"), entry("org/chat", "/models/chat", ["generate"])]) {
  const events: string[] = [], runs: Run[] = [];
  const clock = { now: 0 }, timers: { ms: number; fn: () => void }[] = [];
  const backend: ImageBackend = { async load(dir) {
    events.push(`open ${dir}`); clock.now += 40;
    const pipeline: LoadedImagePipeline = {
      defaults, pixelsPerLatent: 16, stageBytes,
      generate(request, run) {
        events.push(`run ${request.prompt} release=${run.releaseStages}`);
        run.onProgress?.({ stage: "conditioner" });
        return new Promise((resolve, reject) => {
          const abort = () => { events.push(`aborted ${request.prompt}`); reject(run.signal!.reason); };
          run.signal?.addEventListener("abort", abort, { once: true });
          runs.push({ request, options: run, fail: error => { run.signal?.removeEventListener("abort", abort); reject(error); },
            finish: () => { run.signal?.removeEventListener("abort", abort); events.push(`done ${request.prompt}`);
              resolve({ width: 64, height: 64, pixels: new Uint8Array(64 * 64 * 3), seed: request.seed ?? 7, steps: 4, guidance: 3,
                timings: { encodeMs: 1, denoiseMs: 2, decodeMs: 3 } }); } });
        });
      },
      dispose() { events.push(`dispose ${dir}`); },
    };
    return pipeline;
  } };
  const host = createImageModelHost({ catalog: catalog(entries), backend, log() {}, now: () => clock.now, stages: stageBudgetRule(10_000),
    timers: { setTimeout: (fn, ms) => { const timer = { ms, fn }; timers.push(timer); return timer; }, clearTimeout: handle => { const at = timers.indexOf(handle as never); if (at >= 0) timers.splice(at, 1); } },
    ...options });
  /** Resolves once `count` runs have reached the pipeline. */
  const started = async (count: number) => { while (runs.length < count) await Bun.sleep(1); return runs[count - 1]!; };
  return { host, events, runs, timers, clock, started };
}

test("a lease opens the pipeline on first use, exposes its defaults, and the default policy releases it after the lease", async () => {
  const { host, events, started } = setup();
  const lease = await host.acquire("org/image", { need: ["image"] });
  expect(lease.loadMs).toBe(40);
  expect(lease.model).toMatchObject({ id: "org/image", role: "companion", operations: ["image"], leases: 1, pinned: false });
  const image = lease.operations.image!;
  expect(image.defaults).toEqual(defaults);
  expect(image.pixelsPerLatent).toBe(16);
  expect(Object.keys(lease.operations)).toEqual(["image"]);
  const progress: ImageProgress[] = [];
  const result = image.generate({ prompt: "a cat", seed: 3 }, { onProgress: step => progress.push(step) });
  (await started(1)).finish();
  expect(await result).toMatchObject({ width: 64, height: 64, seed: 3 });
  expect(progress).toEqual([{ stage: "conditioner" }]);
  lease.release(); lease.release();
  expect(host.resident()).toEqual([]);
  expect(host.stats("org/image")).toEqual({ resident: false, loads: 1, unloads: 1, lastLoadMs: 40, idleUnloadSec: 0 });
  expect(events).toEqual(["open /models/org/image", "run a cat release=false", "done a cat", "dispose /models/org/image"]);
});

test("a failed run and an aborted run reject; the lease still releases and the pipeline is released after it", async () => {
  const { host, events, started } = setup();
  const lease = await host.acquire("org/image");
  const failing = lease.operations.image!.generate({ prompt: "bad" });
  (await started(1)).fail(new RangeError("width must be a positive multiple of 16, got 3"));
  await expect(failing).rejects.toThrow("width must be a positive multiple of 16");
  const controller = new AbortController();
  const aborted = lease.operations.image!.generate({ prompt: "slow" }, { signal: controller.signal });
  await started(2);
  controller.abort(new Error("client went away"));
  await expect(aborted).rejects.toThrow("client went away");
  // A signal that fired before the run never reaches the pipeline.
  await expect(lease.operations.image!.generate({ prompt: "late" }, { signal: controller.signal })).rejects.toThrow("client went away");
  expect(host.resident()[0]).toMatchObject({ leases: 1 });
  lease.release();
  expect(host.resident()).toEqual([]);
  expect(events).toEqual(["open /models/org/image", "run bad release=false", "run slow release=false", "aborted slow", "dispose /models/org/image"]);
});

test("an abort while the pipeline opens rejects the acquire and leaves no lease behind", async () => {
  const controller = new AbortController();
  const { host, events } = setup({ backend: { async load(dir) {
    events.push(`open ${dir}`); controller.abort(new Error("gave up"));
    return { defaults, pixelsPerLatent: 16, stageBytes, generate: async () => { throw new Error("unused"); }, dispose() { events.push(`dispose ${dir}`); } };
  } } });
  await expect(host.acquire("org/image", { signal: controller.signal })).rejects.toThrow("gave up");
  expect(host.resident()).toEqual([]);
  expect(events).toEqual(["open /models/org/image", "dispose /models/org/image"]);
  await expect(host.acquire("org/image", { signal: controller.signal })).rejects.toThrow("gave up");
});

test("the idle policy and a per-lease keep-alive delay the release; a new lease cancels it and pinning removes it", async () => {
  const { host, timers, events } = setup({ idleUnloadSec: 5 });
  (await host.acquire("org/image")).release();
  expect(timers.map(timer => timer.ms)).toEqual([5000]);
  const warm = await host.acquire("org/image");
  expect(warm.loadMs).toBe(0); expect(timers).toEqual([]);
  warm.release();
  timers.shift()!.fn();
  expect(host.resident()).toEqual([]);
  (await host.acquire("org/image", { keepAliveSec: 30 })).release();
  expect(timers.map(timer => timer.ms)).toEqual([30_000]);
  host.pin("org/image");
  expect(timers).toEqual([]);
  expect(host.stats("org/image").idleUnloadSec).toBeNull();
  expect(host.policy.pinned).toEqual(["org/image"]);
  host.unpin("org/image");
  (await host.acquire("org/image", { keepAliveSec: 0 })).release();
  expect(host.resident()).toEqual([]);
  expect(events.filter(event => event.startsWith("open"))).toHaveLength(2);
});

test("runs go through the execution lock one at a time, and a run that waits for it can be cancelled without taking it", async () => {
  let held = 0, maxHeld = 0;
  const queue: (() => void)[] = [];
  let busy = false;
  const exclusive = async <T>(fn: () => Promise<T>, signal?: AbortSignal): Promise<T> => {
    while (busy) {
      await new Promise<void>((resolve, reject) => {
        queue.push(resolve);
        signal?.addEventListener("abort", () => { queue.splice(queue.indexOf(resolve), 1); reject(signal.reason); }, { once: true });
      });
    }
    busy = true; held++; maxHeld = Math.max(maxHeld, held);
    try { return await fn(); } finally { held--; busy = false; queue.shift()?.(); }
  };
  const { host, events, runs, started } = setup({ exclusive });
  const lease = await host.acquire("org/image");
  const first = lease.operations.image!.generate({ prompt: "one" });
  const second = lease.operations.image!.generate({ prompt: "two" });
  const controller = new AbortController();
  const third = lease.operations.image!.generate({ prompt: "three" }, { signal: controller.signal });
  await started(1);
  await Bun.sleep(5);
  expect(runs).toHaveLength(1);
  controller.abort(new Error("cancelled while queued"));
  await expect(third).rejects.toThrow("cancelled while queued");
  runs[0]!.finish();
  await first;
  (await started(2)).finish();
  await second;
  expect(maxHeld).toBe(1);
  expect(events.filter(event => event.startsWith("run") || event.startsWith("done"))).toEqual(["run one release=false", "done one", "run two release=false", "done two"]);
  lease.release();
});

test("runs on one pipeline never overlap without an execution lock either; a run that gives up while queued does not let the next one in early", async () => {
  const { host, events, runs, started } = setup();
  const one = await host.acquire("org/image"), two = await host.acquire("org/image");
  const first = one.operations.image!.generate({ prompt: "first" });
  const controller = new AbortController();
  const second = two.operations.image!.generate({ prompt: "second" }, { signal: controller.signal });
  const third = one.operations.image!.generate({ prompt: "third" });
  await started(1);
  controller.abort(new Error("second gave up"));
  await expect(second).rejects.toThrow("second gave up");
  await Bun.sleep(5);
  expect(runs).toHaveLength(1);
  runs[0]!.finish();
  await first;
  (await started(2)).finish();
  await third;
  expect(events.filter(event => event.startsWith("run") || event.startsWith("done"))).toEqual(["run first release=false", "done first", "run third release=false", "done third"]);
  one.release(); two.release();
  expect(host.resident()).toEqual([]);
});

test("stages that fit the budget stay open between runs; stages that exceed it are released one by one, and residency counts a run's peak", async () => {
  // 900 bytes of stages within a 10 000 byte budget: kept open; the host reports all of them.
  const fits = setup({ idleUnloadSec: 60 });
  const kept = await fits.host.acquire("org/image");
  const keptRun = kept.operations.image!.generate({ prompt: "fits" });
  (await fits.started(1)).finish();
  await keptRun;
  expect(fits.runs[0]!.options.releaseStages).toBe(false);
  expect(fits.host.resident()[0]!.bytes).toBe(900);
  kept.release();
  // A budget below the 900 bytes: each run releases every stage after its output; at most the largest stage is held.
  const admitted: number[] = [];
  const tight = setup({ stages: stageBudgetRule(899), admit: async bytes => { admitted.push(bytes); } });
  const lease = await tight.host.acquire("org/image");
  const run = lease.operations.image!.generate({ prompt: "tight" });
  (await tight.started(1)).finish();
  await run;
  expect(tight.runs[0]!.options.releaseStages).toBe(true);
  expect(tight.host.resident()[0]!.bytes).toBe(500);
  expect(admitted).toEqual([500]);
  lease.release();
  // At the budget exactly the stages still fit.
  const exact = setup({ stages: stageBudgetRule(900) });
  const exactLease = await exact.host.acquire("org/image");
  const exactRun = exactLease.operations.image!.generate({ prompt: "exact" });
  (await exact.started(1)).finish();
  await exactRun;
  expect(exact.runs[0]!.options.releaseStages).toBe(false);
  exactLease.release();
  // A decision made elsewhere is applied as made, whatever the stages weigh: the host reports what a run holds under it.
  for (const release of [true, false]) {
    const fixed = setup({ stages: fixedStageRule(release), idleUnloadSec: 60 });
    const fixedLease = await fixed.host.acquire("org/image");
    const fixedRun = fixedLease.operations.image!.generate({ prompt: "fixed" });
    (await fixed.started(1)).finish();
    await fixedRun;
    expect([fixed.runs[0]!.options.releaseStages, fixed.host.resident()[0]!.bytes]).toEqual([release, release ? 500 : 900]);
    fixedLease.release();
  }
});

test("acquire rejects a model that does not declare image and an id the catalog lacks; a configured model needs no catalog", async () => {
  const { host } = setup();
  await expect(host.acquire("org/chat")).rejects.toMatchObject({ code: "does-not-fit" } satisfies Partial<ModelHostError>);
  await expect(host.acquire("missing")).rejects.toThrow('no model matching "missing"');
  await expect(host.acquire("org/image", { need: ["generate"] })).rejects.toMatchObject({ code: "does-not-fit" });
  // The same holds once the model has a slot: an operation it does not declare is refused on every acquisition.
  (await host.acquire("org/image", { need: ["image"] })).release();
  await expect(host.acquire("org/image", { need: ["generate"] })).rejects.toMatchObject({ code: "does-not-fit", message: "org/image does not declare the generate operation" });
  const configured = setup({ configured: { id: "mine", directory: "/elsewhere" } }, []);
  (await configured.host.acquire("mine")).release();
  expect(configured.events[0]).toBe("open /elsewhere");
  expect(await configured.host.defaultFor("image")).toBe("mine");
});

test("the default is the configured snapshot, else the first that declares image, resolved once; other operations have none", async () => {
  const { host } = setup({}, [entry("org/whisper", "/w", ["transcribe"]), entry("org/first"), entry("org/second")]);
  expect(await host.defaultFor("image")).toBe("org/first");
  expect(await host.defaultFor("transcribe")).toBeUndefined();
  expect(await host.defaultFor("generate")).toBeUndefined();
  const none = setup({}, [entry("org/chat", "/c", ["generate"])]);
  expect(await none.host.defaultFor("image")).toBeUndefined();
  await expect(none.host.preload()).rejects.toMatchObject({ code: "does-not-fit" });
});

test("an open failure surfaces as load-failed with the library's message; a refused admission disposes the opened pipeline", async () => {
  const failing = setup({ backend: { load: async () => { throw new Error("transformer latent_channels 3 != VAE latent_channels 4"); } } });
  await expect(failing.host.acquire("org/image")).rejects.toMatchObject({ code: "load-failed", message: "transformer latent_channels 3 != VAE latent_channels 4" });
  expect(failing.host.resident()).toEqual([]);
  const refused = setup({ stages: stageBudgetRule(1), admit: async () => { throw new Error("no room"); } });
  await expect(refused.host.acquire("org/image")).rejects.toMatchObject({ code: "load-failed", message: "no room" });
  expect(refused.events).toEqual(["open /models/org/image", "dispose /models/org/image"]);
});

test("loads and unloads are published, preload opens without leasing, and close releases without counting an unload", async () => {
  const published: CoreEvent[] = [];
  const { host, events } = setup({ events: { publish: event => { published.push(event as CoreEvent); } } });
  await host.preload();
  expect(host.resident().map(model => model.id)).toEqual(["org/image"]);
  expect(published.map(event => event.type === "model.load" ? `load ${event.phase}` : event.type)).toEqual(["load started", "load finished", "model.memory"]);
  await host.unload("org/image");
  expect(published.at(-1)).toMatchObject({ type: "model.unload", model: "org/image", reason: "requested" });
  await host.preload("org/image");
  await host.close(); await host.close();
  expect(host.stats("org/image")).toMatchObject({ loads: 2, unloads: 1, resident: false });
  expect(events).toEqual(["open /models/org/image", "dispose /models/org/image", "open /models/org/image", "dispose /models/org/image"]);
  await expect(host.acquire("org/image")).rejects.toMatchObject({ code: "closed" });
  expect((await setup().host.plan("org/image")).requiredBytes).toBe(900);
});
