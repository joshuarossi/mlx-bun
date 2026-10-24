import { expect, test } from "bun:test";
import type { CatalogEntry, ModelCatalog } from "@mlx-bun/app-core";
import { createHostServices, stageBudgetRule, type Exclusive } from "@mlx-bun/app-services";
import { createResidencyHost, type ResidentUnit } from "../../src/residency/model-residency";

const tick = () => Bun.sleep(10);
function fixture(sizes = { whisper: 80, image: 80, chat: 80 }) {
  const events: string[] = [];
  const loading = Promise.withResolvers<void>(), running = Promise.withResolvers<void>();
  const control = { fail: false, loadGate: Promise.resolve(), runGate: Promise.resolve() };
  const primary = createResidencyHost<ResidentUnit>({ budgetBytes: 100, source: {
    resolve: async id => ({ id, bytes: sizes.chat, operations: ["generate"] }),
    load: async entry => {
      events.push("load chat");
      return { id: entry.id, operations: ["generate"], bytes: () => sizes.chat,
        memory: () => ({ weightsBytes: sizes.chat, kvBytes: 0, prefixCacheBytes: 0 }), operationsFor: () => ({}),
        pause: async () => { events.push("pause chat"); return { dispose() { events.push("resume chat"); } }; },
        close: async () => { events.push("dispose chat"); return { flushed: true }; } };
    },
  } });
  const entries: CatalogEntry[] = [
    { id: "whisper", directory: "/whisper", kind: "model", bytes: sizes.whisper, operations: ["transcribe"] },
    { id: "image", directory: "/image", kind: "model", bytes: sizes.image, operations: ["image"] },
  ];
  const unused = () => { throw new Error("unused catalog operation"); };
  const catalog: ModelCatalog = { list: async () => entries, find: async id => entries.find(entry => entry.id === id)!,
    resolve: async id => entries.find(entry => entry.id === id), estimate: async () => undefined, locate: async () => undefined,
    register: unused, download: unused, pickDefault: unused, rescan: async () => 0, startDownload: unused, downloads: () => [], canPublish: () => false, publish: unused };
  const exclusive: Exclusive = async (fn, signal) => { const lease = await primary.pauseAll(signal); try { return await fn(); } finally { lease.dispose(); } };
  // Use the same shared service binding as serve-host: both companions own a
  // reservation, and Whisper's load takes the execution lease after admission.
  const services = createHostServices({ catalog, log() {}, whisper: { idleUnloadSec: 60 }, image: { idleUnloadSec: 60, stages: stageBudgetRule(1000) },
    reserve: primary.reserve, exclusive, loadExclusive: exclusive,
    backend: { async load() {
      events.push("load whisper"); loading.resolve();
      await control.loadGate;
      if (control.fail) throw new Error("weights failed");
      events.push("loaded whisper");
      return { promptTokenBudget: 1, encode: () => [], start: unused,
        transcribe: async () => { events.push("decode whisper"); return { text: "ok", segments: [], language: "en" }; },
        dispose() { events.push("dispose whisper"); } };
    } },
    imageBackend: { async load() {
      events.push("open image");
      return { stageBytes: { conditioner: sizes.image, denoiser: 0, decoder: 0 }, pixelsPerLatent: 16,
        defaults: { width: 16, height: 16, steps: 1, guidance: 1, negativePrompt: "", uncondSkipLayers: [] },
        async generate() {
          events.push("run image"); running.resolve(); await control.runGate; events.push("finished image");
          return { width: 16, height: 16, pixels: new Uint8Array(768), seed: 1, steps: 1, guidance: 1,
            timings: { encodeMs: 0, denoiseMs: 0, decodeMs: 0 } };
        }, dispose() { events.push("dispose image"); } };
    } },
  });
  return { primary, ...services, events, control, loading: loading.promise, running: running.promise,
    async close() { await services.companions.close(); services.events.close(); await primary.close(); } };
}

test("an 80-byte pending Whisper load holds back an 80-byte image under a 100-byte shared budget", async () => {
  const f = fixture(), gate = Promise.withResolvers<void>();
  f.control.loadGate = gate.promise;
  try {
    const audio = f.companions.acquire("whisper");
    await f.loading;
    expect(f.whisper.resident()).toEqual([]);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    let admitted = false;
    const image = f.companions.acquire("image").then(lease => { admitted = true; return lease; });
    await tick(); expect(admitted).toBe(false); expect(f.events).not.toContain("run image");
    gate.resolve();
    const audioLease = await audio;
    await tick(); expect(admitted).toBe(false);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    audioLease.release();
    const imageLease = await image;
    expect(f.events).toContain("dispose whisper");
    expect(f.companions.resident().map(model => model.id)).toEqual(["image"]);
    await imageLease.operations.image!.generate({ prompt: "ok" });
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    imageLease.release();
  } finally { gate.resolve(); await f.close(); }
});

test("loaded Whisper is charged once, shares a fitting budget, and still pauses chat for loading and decode", async () => {
  const f = fixture({ whisper: 40, image: 40, chat: 20 });
  try {
    const chat = await f.primary.acquire("chat");
    const audio = await f.companions.acquire("whisper");
    expect(f.events).toEqual(["load chat", "pause chat", "load whisper", "loaded whisper", "resume chat"]);
    expect((await f.primary.plan("next")).freeBytes).toBe(40);
    const image = await f.companions.acquire("image");
    expect((await f.primary.plan("next")).freeBytes).toBe(0);
    const warm = await f.companions.acquire("whisper");
    expect(warm.loadMs).toBe(0);
    expect(f.events.filter(event => event === "load whisper")).toHaveLength(1);
    await warm.operations.transcribe!.transcribe(new Float32Array(1));
    expect(f.events.slice(-3)).toEqual(["pause chat", "decode whisper", "resume chat"]);
    warm.release(); audio.release(); image.release(); chat.release();
    expect(f.events).not.toContain("dispose whisper");
    await f.whisper.unload("whisper");
    expect((await f.primary.plan("next")).freeBytes).toBe(40);
  } finally { await f.close(); }
});

test("Whisper loading excludes an already admitted image run and a job even with no chat residents", async () => {
  const f = fixture({ whisper: 40, image: 40, chat: 20 }), gate = Promise.withResolvers<void>();
  f.control.loadGate = gate.promise;
  try {
    const image = await f.image.acquire("image");
    const audio = f.whisper.acquire("whisper");
    await f.loading;
    const run = image.operations.image!.generate({ prompt: "wait" });
    await tick(); expect(f.events).not.toContain("run image");
    let jobStarted = false;
    const job = f.primary.pauseAll().then(lease => { jobStarted = true; return lease; });
    await tick(); expect(f.events).not.toContain("run image"); expect(jobStarted).toBe(false);
    gate.resolve();
    const audioLease = await audio;
    await run; (await job).dispose();
    expect(f.events.indexOf("loaded whisper")).toBeLessThan(f.events.indexOf("run image"));
    image.release(); audioLease.release();
  } finally { gate.resolve(); await f.close(); }
});

test("an image run and a job each gate lazy Whisper loading", async () => {
  const f = fixture({ whisper: 40, image: 40, chat: 20 }), gate = Promise.withResolvers<void>();
  f.control.runGate = gate.promise;
  try {
    const image = await f.image.acquire("image");
    const run = image.operations.image!.generate({ prompt: "hold" });
    await f.running;
    const audio = f.whisper.acquire("whisper");
    await tick(); expect(f.events).not.toContain("load whisper");
    gate.resolve(); await run;
    (await audio).release();
    expect(f.events.indexOf("finished image")).toBeLessThan(f.events.indexOf("load whisper"));
    await f.whisper.unload("whisper");
    const job = await f.primary.pauseAll();
    const next = f.whisper.acquire("whisper");
    await tick(); expect(f.events.filter(event => event === "load whisper")).toHaveLength(1);
    job.dispose(); (await next).release(); image.release();
  } finally { gate.resolve(); await f.close(); }
});

test("failed Whisper loading releases its reservation and execution lease to a waiting image", async () => {
  const f = fixture(), gate = Promise.withResolvers<void>();
  f.control.loadGate = gate.promise; f.control.fail = true;
  try {
    const failed = f.whisper.acquire("whisper");
    void failed.catch(() => {});
    await f.loading;
    const image = f.image.acquire("image");
    gate.resolve(); await expect(failed).rejects.toThrow("weights failed");
    const lease = await image;
    expect(f.whisper.resident()).toEqual([]);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    await lease.operations.image!.generate({ prompt: "ok" }); lease.release();
    f.control.fail = false;
    (await f.whisper.acquire("whisper")).release();
    expect(f.events).toContain("dispose image");
  } finally { gate.resolve(); await f.close(); }
});

test("cancelling Whisper admission drops the waiter without loading or leaking a charge", async () => {
  const f = fixture(), controller = new AbortController();
  try {
    const image = await f.image.acquire("image");
    const audio = f.whisper.acquire("whisper", { signal: controller.signal });
    await tick(); expect(f.events).not.toContain("load whisper");
    controller.abort(new Error("cancelled admission"));
    await expect(audio).rejects.toThrow("cancelled admission");
    await tick(); image.release(); await f.image.unload("image");
    expect((await f.primary.plan("chat")).freeBytes).toBe(100);
    (await f.whisper.acquire("whisper")).release();
  } finally { await f.close(); }
});

test("cancelling an in-flight Whisper load keeps its charge until the backend returns and the weights are disposed", async () => {
  const f = fixture(), controller = new AbortController(), gate = Promise.withResolvers<void>();
  f.control.loadGate = gate.promise;
  try {
    const audio = f.whisper.acquire("whisper", { signal: controller.signal });
    await f.loading;
    controller.abort(new Error("cancelled load"));
    await expect(audio).rejects.toThrow("cancelled load");
    let admitted = false;
    const image = f.image.acquire("image").then(lease => { admitted = true; return lease; });
    await tick(); expect(admitted).toBe(false);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    gate.resolve();
    const lease = await image;
    expect(f.events).toContain("dispose whisper"); expect(f.whisper.resident()).toEqual([]);
    expect(f.whisper.stats("whisper").loads).toBe(0);
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
    lease.release();
  } finally { gate.resolve(); await f.close(); }
});

test("one aborted caller leaves a shared Whisper load and a preload alive", async () => {
  for (const preload of [false, true]) {
    const f = fixture(), gate = Promise.withResolvers<void>(), controller = new AbortController();
    f.control.loadGate = gate.promise;
    try {
      const audio = f.whisper.acquire("whisper", { signal: controller.signal });
      await f.loading;
      const other = preload ? f.whisper.preload("whisper") : f.whisper.acquire("whisper");
      await tick(); controller.abort(new Error("one caller left"));
      await expect(audio).rejects.toThrow("one caller left");
      gate.resolve(); const lease = await other;
      expect(f.events.filter(event => event === "load whisper")).toHaveLength(1);
      expect(f.whisper.stats("whisper").resident).toBe(true);
      expect((await f.primary.plan("chat")).freeBytes).toBe(20);
      lease?.release();
    } finally { gate.resolve(); await f.close(); }
  }
});

test("closing Whisper cancels blocked admission and releases a preload's reservation", async () => {
  const f = fixture();
  try {
    const image = await f.image.acquire("image");
    const audio = f.whisper.preload("whisper");
    await tick();
    const rejected = audio.catch(error => error);
    await f.whisper.close(); expect(await rejected).toMatchObject({ code: "closed" });
    expect(f.events).not.toContain("load whisper");
    image.release(); await f.image.unload("image");
    expect((await f.primary.plan("chat")).freeBytes).toBe(100);
  } finally { await f.close(); }
  const loaded = fixture();
  try {
    await loaded.whisper.preload("whisper");
    expect((await loaded.primary.plan("chat")).freeBytes).toBe(20);
    await loaded.whisper.close();
    expect((await loaded.primary.plan("chat")).freeBytes).toBe(100);
    expect(loaded.events.filter(event => event === "dispose whisper")).toHaveLength(1);
  } finally { await loaded.close(); }
});

test("Whisper can be oversized alone but pinning a companion never admits another over budget", async () => {
  const f = fixture({ whisper: 150, image: 80, chat: 80 });
  try {
    (await f.primary.acquire("chat")).release();
    const audio = await f.whisper.acquire("whisper");
    expect(f.primary.resident()).toEqual([]);
    expect((await f.primary.plan("chat")).freeBytes).toBe(0);
    f.whisper.pin("whisper"); audio.release();
    await expect(f.image.acquire("image")).rejects.toThrow("pinned residents or companions");
    await expect(f.primary.acquire("chat")).rejects.toMatchObject({ code: "no-evictable-model" });
    f.whisper.unpin("whisper");
    const image = await f.image.acquire("image");
    expect(f.events).toContain("dispose whisper");
    f.image.pin("image"); image.release();
    await expect(f.whisper.acquire("whisper")).rejects.toThrow("pinned residents or companions");
    expect((await f.primary.plan("chat")).freeBytes).toBe(20);
  } finally { await f.close(); }
});
