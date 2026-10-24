import { expect, test } from "bun:test";
import { createImageModelHost, stageBudgetRule } from "@mlx-bun/app-services";
import type { ImageRunOptions } from "@mlx-bun/app-services";
import { createResidencyHost, type ResidentUnit } from "../../src/residency/model-residency";

const tick = () => Bun.sleep(10);
async function until(check: () => boolean) {
  for (let i = 0; i < 200; i++) { if (check()) return; await Bun.sleep(5); }
  throw new Error("coordination did not settle");
}

function fixture() {
  const events: string[] = [];
  const runs: { finish(): void; fail(): void }[] = [];
  const primary = createResidencyHost<ResidentUnit>({ budgetBytes: 100,
    source: {
      resolve: async id => ({ id, bytes: 80, operations: ["generate"] }),
      load: async entry => {
        events.push(`load ${entry.id}`);
        return { id: entry.id, operations: ["generate"], bytes: () => 80, memory: () => ({ weightsBytes: 80, kvBytes: 0, prefixCacheBytes: 0 }),
          operationsFor: () => ({}), pause: async () => ({ dispose() {} }),
          close: async () => { events.push(`dispose ${entry.id}`); return { flushed: true }; } };
      },
    } });
  const image = createImageModelHost({
    catalog: { list: async () => [], find: async id => ({ id, directory: id, kind: "model", bytes: 80, operations: ["image"] }) },
    stages: stageBudgetRule(1000), idleUnloadSec: 60, log() {}, reserve: primary.reserve,
    exclusive: async (fn, signal) => { const lease = await primary.pauseAll(signal); try { return await fn(); } finally { lease.dispose(); } },
    backend: { async load(id) {
      events.push(`open ${id}`);
      if (id === "broken") throw new Error("bad pipeline");
      return { defaults: { width: 16, height: 16, steps: 1, guidance: 1, negativePrompt: "", uncondSkipLayers: [] }, pixelsPerLatent: 16,
        stageBytes: { conditioner: id === "large" ? 150 : 80, denoiser: 0, decoder: 0 },
        generate: (_request, options: ImageRunOptions) => new Promise((resolve, reject) => {
          events.push(`run ${id}`);
          const abort = () => reject(options.signal!.reason);
          options.signal?.addEventListener("abort", abort, { once: true });
          const cleanup = () => options.signal?.removeEventListener("abort", abort);
          runs.push({ fail() { cleanup(); reject(new Error("run failed")); }, finish() {
            cleanup(); resolve({ width: 16, height: 16, pixels: new Uint8Array(768), seed: 1, steps: 1, guidance: 1,
              timings: { encodeMs: 0, denoiseMs: 0, decodeMs: 0 } });
          } });
        }), dispose() { events.push(`dispose ${id}`); } };
    } },
  });
  return { primary, image, events, runs, async close() { await image.close(); await primary.close(); } };
}

test("concurrent 80-byte image acquisitions reserve against a 100-byte budget before publishing residency", async () => {
  const f = fixture();
  try {
    const a = f.image.acquire("a"), b = f.image.acquire("b");
    const first = await a;
    let secondReady = false;
    void b.then(() => { secondReady = true; });
    await tick();
    expect(secondReady).toBe(false);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    expect(f.image.resident().map(model => model.id)).toEqual(["a"]);
    first.release();
    const second = await b;
    expect(f.events).toContain("dispose a");
    expect(f.image.resident().map(model => model.id)).toEqual(["b"]);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    second.release();
  } finally { await f.close(); }
});

test("chat waits for an image lease then reclaims the idle image; image admission also waits for chat", async () => {
  const f = fixture();
  try {
    const image = await f.image.acquire("a");
    let ready = false;
    const chat = f.primary.acquire("chat").then(lease => { ready = true; return lease; });
    await tick();
    expect(ready).toBe(false);
    image.release();
    const chatLease = await chat;
    expect(f.events.slice(-2)).toEqual(["dispose a", "load chat"]);
    ready = false;
    const other = f.image.acquire("b").then(lease => { ready = true; return lease; });
    await tick();
    expect(ready).toBe(false);
    chatLease.release();
    const otherLease = await other;
    expect(f.events).toContain("dispose chat");
    expect(f.primary.resident()).toEqual([]);
    otherLease.release();
  } finally { await f.close(); }
});

test("a single oversized pipeline is allowed alone, and a cancelled admission or failed open leaves no charge", async () => {
  const f = fixture();
  try {
    const large = await f.image.acquire("large");
    expect((await f.primary.plan("chat")).freeBytes).toBe(0);
    const controller = new AbortController();
    const pending = f.image.acquire("a", { signal: controller.signal });
    await tick();
    controller.abort(new Error("cancelled admission"));
    await expect(pending).rejects.toThrow("cancelled admission");
    await until(() => f.events.includes("dispose a"));
    large.release();
    await f.image.unload("large");
    expect((await f.primary.plan("chat")).freeBytes).toBe(100);
    await expect(f.image.acquire("broken")).rejects.toThrow("bad pipeline");
    expect((await f.primary.plan("chat")).freeBytes).toBe(100);
    (await f.primary.acquire("chat")).release();
  } finally { await f.close(); }
});

test("pinning an image prevents overcommit; unpinning makes it reclaimable", async () => {
  const f = fixture();
  try {
    const image = await f.image.acquire("a");
    f.image.pin("a"); image.release();
    await expect(f.image.acquire("b")).rejects.toThrow("pinned residents or companions");
    await expect(f.primary.acquire("chat")).rejects.toMatchObject({ code: "no-evictable-model" });
    f.image.unpin("a");
    (await f.image.acquire("b")).release();
    expect(f.image.resident().map(model => model.id)).toEqual(["b"]);
  } finally { await f.close(); }
});

test("image admission cannot use the oversized-model allowance to overcommit beside a pinned chat model", async () => {
  const f = fixture();
  try {
    const chat = await f.primary.acquire("chat");
    f.primary.pin("chat"); chat.release();
    await expect(f.image.acquire("a")).rejects.toThrow("pinned residents or companions");
    expect(f.primary.resident().map(model => model.id)).toEqual(["chat"]);
    expect(f.image.resident()).toEqual([]);
    expect((await f.primary.plan("other")).freeBytes).toBe(20);
    f.primary.unpin("chat");
    (await f.image.acquire("a")).release();
  } finally { await f.close(); }
});

test("a running image excludes a job after evicting the last chat resident; a job also gates the next image", async () => {
  const f = fixture();
  try {
    (await f.primary.acquire("chat")).release();
    const image = await f.image.acquire("a");
    expect(f.primary.resident()).toEqual([]);
    const run = image.operations.image!.generate({ prompt: "hold" });
    await until(() => f.runs.length === 1);
    let jobReady = false;
    const job = f.primary.pauseAll().then(lease => { jobReady = true; return lease; });
    await tick();
    expect(jobReady).toBe(false);
    f.runs[0]!.finish(); await run;
    const jobLease = await job;
    const next = image.operations.image!.generate({ prompt: "next" });
    await tick();
    expect(f.runs).toHaveLength(1);
    jobLease.dispose();
    await until(() => f.runs.length === 2);
    f.runs[1]!.finish(); await next;
    image.release();
  } finally { await f.close(); }
});

test("image abort, failure and a cancelled exclusive waiter all return execution to the next owner", async () => {
  const f = fixture();
  try {
    const image = await f.image.acquire("a");
    const controller = new AbortController();
    const run = image.operations.image!.generate({ prompt: "hold" }, { signal: controller.signal });
    await until(() => f.runs.length === 1);
    const cancelled = new AbortController();
    const skipped = f.primary.pauseAll(cancelled.signal);
    cancelled.abort(new Error("job cancelled"));
    await expect(skipped).rejects.toThrow("job cancelled");
    let entered = false;
    const job = f.primary.pauseAll().then(lease => { entered = true; return lease; });
    await tick(); expect(entered).toBe(false);
    controller.abort(new Error("run cancelled"));
    await expect(run).rejects.toThrow("run cancelled");
    (await job).dispose();
    const failure = image.operations.image!.generate({ prompt: "fail" });
    await until(() => f.runs.length === 2);
    f.runs[1]!.fail(); await expect(failure).rejects.toThrow("run failed");
    (await f.primary.pauseAll()).dispose();
    image.release();
  } finally { await f.close(); }
});

test("an exclusive lease keeps its selected unit runnable, rolls back a failed pause, and gates new loads", async () => {
  const f = fixture();
  try {
    const own = await f.primary.acquire("chosen");
    let paused = 0;
    own.unit.pause = async () => { paused++; throw new Error("cannot pause"); };
    const execution = await f.primary.pauseAll(undefined, "chosen");
    expect(paused).toBe(0);
    let loaded = false;
    const next = f.primary.acquire("next").then(lease => { loaded = true; return lease; });
    own.release();
    await tick(); expect(loaded).toBe(false);
    execution.dispose();
    (await next).release();
    f.primary.peek("next")!.pause = async () => { throw new Error("cannot pause"); };
    await expect(f.primary.pauseAll()).rejects.toThrow("cannot pause");
    await f.primary.unload("next");
    (await f.primary.pauseAll()).dispose();
  } finally { await f.close(); }
});
