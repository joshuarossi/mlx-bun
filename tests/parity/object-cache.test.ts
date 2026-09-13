import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

describe.skipIf(process.env.MLX_BUN_TEST_OBJECT_CACHE !== "1")("shared tensor-object RAM/SSD cache", () => {
  test("evicts only after queued persistence and restores exact native bytes after restart", async () => {
    const { SsdCacheStore } = await import("../../src/ssd-cache");
    const { TieredPromptCache } = await import("../../src/tiered-prompt-cache");
    const { MlxArray } = await import("../../src/mlx/array");
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-object-cache-"));
    const options = { dir, maxBytes: 2 ** 20, modelId: "object-test", configFingerprint: "test-v1", tokenizerHash: "test", verify: true };
    const store = new SsdCacheStore(options);
    const cold = (storage: InstanceType<typeof SsdCacheStore>) => ({
      find: () => null, restore: () => null,
      findExact: (tokens: number[], ns: string) => {
        const hit = storage.findExact(tokens, ns);
        return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null;
      },
      restoreObjectAsync: async (entry: unknown) => {
        const loaded = await storage.restoreAsync(entry as any, { makeCache: () => [] });
        return loaded ? { ...loaded, retain: () => {} } : null;
      },
      store: (tokens: number[], caches: any[], ns: string, attachments?: any[]) => storage.store(tokens, caches, ns, attachments),
    });
    const cache = new TieredPromptCache(16, store, cold(store));
    try {
      const data = MlxArray.fromFloat32(new Float32Array([1, -0, 3.25, -9, 5, 6, 7, 8]), [2, 4]);
      const expected = Buffer.from(data.rawBytes()).toString("hex");
      cache.objects!.put("encoder:image-a", [{ schema: "features-v1", metadata: { grid: "1,2,2" }, tensors: [data] }]);
      expect(cache.totalBytes).toBe(32);
      const held = await cache.objects!.take("encoder:image-a");
      const flush = await cache.durability.flush();
      expect(flush.durable).toBe(true);
      expect(cache.totalBytes).toBe(0);
      expect(store.entries).toBe(1);
      expect(Buffer.from(held!.value[0]!.tensors[0]!.rawBytes()).toString("hex")).toBe(expected);
      held!.dispose(); cache.clear();
      const restarted = new SsdCacheStore(options);
      expect(restarted.scan()).toBe(1);
      const restoredCache = new TieredPromptCache(128, restarted, cold(restarted));
      try {
        const restored = await restoredCache.objects!.take("encoder:image-a");
        expect(restored!.value[0]!.metadata.grid).toBe("1,2,2");
        expect(Buffer.from(restored!.value[0]!.tensors[0]!.rawBytes()).toString("hex")).toBe(expected);
        expect(restoredCache.totalBytes).toBe(32);
        expect(await restoredCache.objects!.take("encoder:image-b")).toBeNull();
        restored!.dispose();
        expect((await restoredCache.durability.flush()).durable).toBe(true);
      } finally { restoredCache.clear(); }
    } finally { cache.clear(); rmSync(dir, { recursive: true, force: true }); }
  }, 30_000);
});
