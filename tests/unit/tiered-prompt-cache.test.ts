import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { TieredPromptCache } from "../../src/tiered-prompt-cache";
import { SsdCacheStore } from "../../src/ssd-cache";
import { KVCache } from "../../src/model/gemma4-base";
import { MlxArray } from "../../src/mlx/array";
import { cloneKvCaches } from "../../src/kv-store";
import { cacheBytes, type ColdTier } from "../../src/prompt-cache";
import { disposeResources } from "../../src/engine/resources";

function state(value: number): KVCache[] {
  const cache = new KVCache();
  cache.restoreState(MlxArray.fromFloat32(new Float32Array([value, value + 1]), [1, 1, 2, 1]),
    MlxArray.fromFloat32(new Float32Array([value + 2, value + 3]), [1, 1, 2, 1]), 2);
  return [cache];
}
function fixture(maxBytes: number, writeBehind = true, delay?: Promise<void>) {
  const dir = mkdtempSync(join(tmpdir(), "tiered-cache-"));
  const options = { dir, maxBytes: 1 << 24, modelId: "tiered", configFingerprint: "tiered", tokenizerHash: "tiered", verify: true };
  const ssd = new SsdCacheStore(options);
  let failWrites = false;
  const cold: ColdTier = {
    find(tokens, ns) { const hit = ssd.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
    restore(handle) { const loaded = ssd.restore(handle as Parameters<typeof ssd.restore>[0], { makeCache: () => [new KVCache()] });
      return loaded ? { ...loaded, retain() {} } : null; },
    store: (tokens, caches, ns, attachments) => ssd.store(tokens, caches, ns, attachments),
  };
  const cache = new TieredPromptCache(maxBytes, {
    hasDurablePrefix: (tokens, ns) => ssd.hasDurablePrefix(tokens, ns),
    async storeAsync(...args) { if (delay) await delay; return failWrites ? false : ssd.storeAsync(...args); },
  }, cold, cloneKvCaches, writeBehind);
  return { cache, ssd, options, failWrites(value: boolean) { failWrites = value; },
    async close() { await cache.durability.flush(); cache.clear(); rmSync(dir, { recursive: true, force: true }); } };
}

test("persistence leaves an under-budget entry resident and reusable in RAM", async () => {
  const f = fixture(1024), caches = state(10);
  try {
    f.cache.put([1, 2], caches);
    expect((await f.cache.durability.flush()).durable).toBe(true);
    expect(f.cache.size).toBe(1);
    expect(caches[0]!.keys!.toFloat32()).toEqual(new Float32Array([10, 11]));
    expect(f.ssd.entries).toBe(1);
    const hit = f.cache.take([1, 2, 9])!;
    expect(hit.caches[0]!.offset).toBe(2);
    expect(f.ssd.stats.restores).toBe(0);
    disposeResources(hit.caches); hit.retain?.();
  } finally { await f.close(); }
});

test("LRU demotion waits for SSD, keeps the hotter entry and restores through the same cache", async () => {
  const release = Promise.withResolvers<void>();
  const first = state(10), second = state(20), f = fixture(cacheBytes(first), true, release.promise);
  try {
    f.cache.put([1, 2], first); f.cache.put([3, 4], second);
    // Make the first entry hotter while both writes are pending.
    const hot = f.cache.take([1, 2, 9])!; disposeResources(hot.caches); hot.retain?.();
    // Completed writer ownership must be released before reevaluating
    // pressure, otherwise its stale byte count can evict the hot entry too.
    f.cache.pressure = { overBudget: () => f.cache.size > 1 || f.cache.spillQueue.pendingBytes > 0 };
    f.cache.reclaim();
    expect(f.cache.size).toBe(2);
    expect(second[0]!.keys!.toFloat32()).toEqual(new Float32Array([20, 21]));
    release.resolve();
    expect((await f.cache.durability.flush()).durable).toBe(true);
    expect(f.cache.size).toBe(1);
    expect(f.cache.findExact([1, 2])).not.toBeNull();
    expect(f.cache.findExact([3, 4])).toBeNull();
    expect(f.cache.spillQueue.droppedCount).toBe(0);
    const restored = f.cache.take([3, 4, 9])!;
    expect(restored.caches[0]!.offset).toBe(2);
    expect(restored.caches[0]!.state()[0]!.toFloat32().slice(0, 2)).toEqual(new Float32Array([20, 21]));
    disposeResources(restored.caches); restored.retain?.();
    expect(f.ssd.stats.restores).toBe(1);
    const ramAgain = f.cache.take([3, 4, 10])!;
    disposeResources(ramAgain.caches); ramAgain.retain?.();
    expect(f.ssd.stats.restores).toBe(1);
    const restarted = new SsdCacheStore(f.options);
    expect(restarted.scan()).toBe(2);
  } finally { release.resolve(); await f.close(); }
});

test("with write-behind disabled, capacity eviction still persists before removing RAM", async () => {
  const first = state(30), f = fixture(cacheBytes(first), false);
  try {
    f.cache.put([1, 2], first);
    await f.cache.durability.flush();
    expect(f.ssd.entries).toBe(0);
    f.cache.put([3, 4], state(40));
    expect(f.cache.size).toBe(2);
    expect((await f.cache.durability.flush()).durable).toBe(true);
    expect(f.cache.size).toBe(1);
    expect(f.ssd.hasDurablePrefix([1, 2])).toBe(true);
    expect(f.cache.findExact([3, 4])).not.toBeNull();
  } finally { await f.close(); }
});

test("failed SSD writes retain the RAM entry and a retry completes its demotion", async () => {
  const first = state(50), f = fixture(cacheBytes(first));
  try {
    f.failWrites(true);
    f.cache.put([1, 2], first); f.cache.put([3, 4], state(60));
    expect((await f.cache.durability.flush()).durable).toBe(false);
    expect(f.cache.size).toBe(2);
    expect(first[0]!.keys!.toFloat32()).toEqual(new Float32Array([50, 51]));
    expect(f.ssd.entries).toBe(0);
    f.failWrites(false);
    expect((await f.cache.durability.flush()).durable).toBe(true);
    expect(f.cache.size).toBe(1);
    expect(f.ssd.hasDurablePrefix([1, 2])).toBe(true);
    expect(f.cache.spillQueue.droppedCount).toBe(0);
  } finally { f.failWrites(false); await f.close(); }
});
