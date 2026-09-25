import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createCacheServices, type CacheServiceDependencies } from "../../src/engine/cache-services";
import { createAppEngine } from "../../src/engine";
import type { LoadedModelContext } from "../../src/engine/model-host";
import type { ModelBinding } from "../../src/engine/model-binding";
import { createRuntimeConfig } from "@mlx-bun/inference/runtime/config";

function setup(values: Record<string, string> = {}) {
  const events: string[] = [];
  const zero = { pendingSnapshots: 0, pendingSpills: 0, pendingSpillBytes: 0, droppedSpills: 0, failedSpills: 0 };
  let interval = 0, demote: (() => void) | undefined, storeOptions: unknown, cold: unknown;
  let ramCap = 0, active = 0, writeBehind: boolean | undefined;
  const cache = { totalBytes: 0, retention: { name: "lru" }, pressure: { overBudget: () => false },
    clear() { events.push("cache clear"); }, demoteIdle(ms: number) { events.push(`demote ${ms}`); return 1; } };
  const store = { scan() { events.push("scan"); }, hasDurablePrefix: () => false,
    find: () => ({ prefixLen: 2, entry: "entry" }), findExact: () => null,
    restoreAsync: async () => null, store: () => true };
  const durability = { stats: zero, async flush() { events.push("prefix flush");
    return { ...zero, durable: true, flushedSnapshots: 2, missingSnapshots: 0, elapsedMs: 1 }; } };
  const persistence = { stats: { pendingCount: 0, pendingBytes: 0, dropped: 0, failed: 0 },
    async flush() { events.push("checkpoint flush"); return { durable: true, pendingBytes: 0, failed: 0 }; } };
  const stateCodecs = { id: "replacement-state" };
  const context = { modelId: "test", model: { config: { modelDir: "/unused" }, weightsBytes: 20 },
    kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }], stateCodecs,
    profile: { artifact: "artifact", profile: { execution: "implementation" } },
    adapters: { cacheNamespace: (names: string[]) => names.join(":") }, dispose() { events.push("model dispose"); },
  } as unknown as LoadedModelContext;
  const binding = { stateCompatibility: "binding-v1", gateway: { runtime: createRuntimeConfig(values) },
    restore() { events.push("restore"); return { tokens: [1, 2], caches: [] }; },
    async restoreAsync() { events.push("restore async"); return { tokens: [1, 2], caches: [] }; },
  } as unknown as ModelBinding;
  const deps = {
    defaultStateCodecs: { id: "default" }, cloneState(caches: unknown, codecs: unknown) {
      expect(codecs).toBe(stateCodecs); events.push("clone"); return caches;
    },
    createPromptCache(cap: number) { ramCap = cap; events.push("RAM"); return cache; },
    createTieredPromptCache(cap: number, _store: unknown, tier: unknown, _clone: unknown, write: boolean) {
      ramCap = cap; cold = tier; writeBehind = write; events.push("tiered");
      return Object.assign(cache, { durability, spillQueue: { pendingBytes: 0,
        async drain() { events.push("spill drain"); } } });
    },
    createStore(options: unknown) { storeOptions = options; return store; },
    createContinuationPersistence(_store: unknown, options: { maxBytes: number }) {
      events.push(`queue ${options.maxBytes}`); return persistence;
    },
    costSizeRetention: () => ({ name: "cost-size" }), configFingerprint: () => "config",
    activeMemory: () => active, maxWorkingSet: () => 100,
    scheduleDemotion(run: () => void, ms: number) { demote = run; interval = ms; return () => events.push("timer stop"); },
  } as unknown as CacheServiceDependencies;
  return { context, binding, deps, events, cache, durability, persistence,
    setActive(n: number) { active = n; }, get cap() { return ramCap; }, get interval() { return interval; },
    get storeOptions() { return storeOptions; }, get cold() { return cold; }, get writeBehind() { return writeBehind; },
    demote() { demote?.(); } };
}

async function withTokenizer(run: (directory: string) => Promise<void>) {
  const directory = mkdtempSync(join(tmpdir(), "mlx-app-cache-"));
  try { writeFileSync(join(directory, "tokenizer.json"), "{}"); await run(directory); }
  finally { rmSync(directory, { recursive: true, force: true }); }
}

test("default cache is 8 GB RAM, plain KV, and no SSD even when model quantization config exists", async () => {
  const f = setup(); const cache = await createCacheServices(f.context, f.binding, {}, f.deps);
  expect(f.cap).toBe(8e9); expect(cache.resolvedKvScheme.kind).toBe("bf16");
  expect(cache.checkpoints).toBeNull(); expect(f.storeOptions).toBeUndefined(); expect(f.interval).toBe(0);
  expect(cache.adapterNamespace(["a", "b"])).toBe("a:b");
  expect(cache.continuationServices.identity).toEqual({ artifact: "artifact", implementation: "implementation",
    stateAbi: "legacy-cache-array-v1", codecs: "replacement-state" });
  cache.continuationServices.cloneState([]); expect(f.events).toContain("clone");
  expect(f.cache.pressure.overBudget()).toBe(false); f.setActive(86); expect(f.cache.pressure.overBudget()).toBe(true);
  expect((await cache.flush()).durable).toBe(true);
  await cache.close(); await cache.close(); expect(f.events.filter(e => e === "cache clear")).toHaveLength(1);
});

test("explicit RAM disabling and KV overrides retain their meaning", async () => {
  const f = setup(); const cache = await createCacheServices(f.context, f.binding, { promptCacheBytes: 0, kvQuant: 4 }, f.deps);
  expect(f.cap).toBe(0); expect(cache.kvScheme.kvBits).toBe(4); await cache.close();
  const second = await createCacheServices(f.context, f.binding, { kvQuant: "config" }, f.deps);
  expect(second.kvScheme.kvConfig).toEqual(f.context.kvConfig!); await second.close();
});

test("SSD defaults bind identity, codecs, restoration, checkpoints, idle demotion, and flush before release", async () => {
  await withTokenizer(async directory => {
    const f = setup({ MLX_BUN_CACHE_RETENTION: "cost-size" }); f.context.model.config.modelDir = directory;
    const cache = await createCacheServices(f.context, f.binding, { ssdCacheDir: directory, generationCheckpointTokens: 32 }, f.deps);
    expect(f.storeOptions).toMatchObject({ dir: directory, maxBytes: Infinity, codecs: f.context.stateCodecs,
      configFingerprint: `config-${cache.resolvedKvScheme.cacheKey}-${Bun.hash("binding-v1").toString(16)}`,
      tokenizerHash: Bun.hash(Buffer.from("{}")).toString(16), storage: { layout: "whole", segmented: true } });
    expect(f.events).toContain(`queue ${2 * 1024 ** 3}`); expect(f.writeBehind).toBe(true);
    expect(f.cache.retention.name).toBe("cost-size"); expect(f.interval).toBe(75_000);
    f.demote(); expect(f.events).toContain("demote 300000");
    const cold = f.cold as { find(tokens: number[], ns: string): unknown; restore(handle: unknown): unknown; restoreAsync(handle: unknown): Promise<unknown> };
    expect(cold.find([1, 2], "")).toEqual({ prefixLen: 2, handle: "entry" }); cold.restore("entry"); await cold.restoreAsync("entry");
    expect(f.events).toContain("restore"); expect(f.events).toContain("restore async");
    const result = await cache.close(); expect(result.durable).toBe(true); expect(result.flushedSnapshots).toBe(2);
    expect(f.events.slice(-5)).toEqual(["timer stop", "checkpoint flush", "prefix flush", "spill drain", "cache clear"]);
  });
});

test("optional SSD policy overrides do not alter pressure or checkpoint accounting", async () => {
  await withTokenizer(async directory => {
    const f = setup({ MLX_BUN_SSD_LAYOUT: "blocks", MLX_BUN_SSD_SEGMENTED: "0", MLX_BUN_SSD_PREFETCH: "0",
      MLX_BUN_SSD_WRITEBEHIND: "0", MLX_BUN_SSD_SPILL_QUEUE_GB: "0.5" }); f.context.model.config.modelDir = directory;
    const cache = await createCacheServices(f.context, f.binding, { ssdCacheDir: directory, ssdDemoteIdleSec: 0,
      allocatorLimitBytes: 50, generationCheckpointTokens: 4, ssdCacheMaxBytes: 1000, ssdCacheVerify: true }, f.deps);
    expect(f.storeOptions).toMatchObject({ maxBytes: 1000, verify: true, storage: { layout: "blocks", segmented: false } });
    expect(f.events).toContain(`queue ${0.5 * 1024 ** 3}`); expect(f.interval).toBe(0);
    expect(f.writeBehind).toBe(false); expect(f.cold).not.toHaveProperty("restoreAsync");
    f.cache.totalBytes = 23; expect(f.cache.pressure.overBudget()).toBe(true);
    f.persistence.stats.pendingCount = 2; f.persistence.stats.pendingBytes = 80;
    expect(cache.stats()).toMatchObject({ pendingSpills: 2, pendingSpillBytes: 80 });
    expect((await cache.close()).durable).toBe(false);
  });
});

test("invalid checkpoint and SSD configurations fail before factories allocate cache state", async () => {
  const f = setup();
  for (const options of [{ generationCheckpointTokens: 0 }, { generationCheckpointTokens: 1 },
    { ssdCacheDir: "unused", promptCacheBytes: 0 }])
    await expect(createCacheServices(f.context, f.binding, options, f.deps)).rejects.toThrow();
  await expect(createCacheServices(f.context, { ...f.binding, stateCompatibility: "" }, { ssdCacheDir: "unused" }, f.deps)).rejects.toThrow("identity");
  expect(f.events).toEqual([]);
});

test("shutdown attempts every persistence release and model disposal when checkpoint flushing fails", async () => {
  await withTokenizer(async directory => {
    const f = setup(); f.context.model.config.modelDir = directory;
    const failure = new Error("checkpoint disk failure"); f.persistence.flush = async () => { f.events.push("checkpoint failure"); throw failure; };
    const cache = await createCacheServices(f.context, f.binding, { ssdCacheDir: directory, generationCheckpointTokens: 1 }, f.deps);
    const engine = await createAppEngine(f.context, { capacity: 1, binding: f.binding,
      beforeModelDispose: async () => { await cache.close(); } });
    await expect(engine.close()).rejects.toBe(failure); await expect(engine.close()).rejects.toBe(failure);
    expect(f.events.slice(-6)).toEqual(["timer stop", "checkpoint failure", "prefix flush", "spill drain", "cache clear", "model dispose"]);
  });
});

test("engine construction failure preserves the original error and attempts hook and model cleanup once", async () => {
  const f = setup(); const hookFailure = new Error("hook failure");
  try {
    await createAppEngine(f.context, { capacity: 0, binding: f.binding,
      beforeModelDispose() { f.events.push("cache close"); throw hookFailure; } });
    throw new Error("expected failure");
  } catch (error) {
    expect(error).toBeInstanceOf(AggregateError);
    const errors = (error as AggregateError).errors;
    expect(errors[0].message).toContain("positive integer"); expect(errors[1]).toBe(hookFailure);
  }
  expect(f.events).toEqual(["cache close", "model dispose"]);
});


test("stopping idle demotion before request drain preserves caches until final close", async () => {
  await withTokenizer(async directory => {
    const f = setup(); f.context.model.config.modelDir = directory;
    const cache = await createCacheServices(f.context, f.binding, { ssdCacheDir: directory }, f.deps);
    cache.stopIdleDemotion(); cache.stopIdleDemotion();
    expect(f.events.filter(event => event === "timer stop")).toHaveLength(1);
    expect(f.events).not.toContain("cache clear");
    expect(f.events).not.toContain("prefix flush");
    await cache.close();
    expect(f.events.filter(event => event === "timer stop")).toHaveLength(1);
    expect(f.events).toContain("prefix flush"); expect(f.events).toContain("cache clear");
  });
});
