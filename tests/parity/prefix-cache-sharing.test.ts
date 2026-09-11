// Native immutable-prefix and tier-transition gate. No downloads or servers.
// MLX_BUN_TEST_SHARED_PREFIX_MODEL=/path bun test tests/parity/prefix-cache-sharing.test.ts
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const artifact = Bun.env.MLX_BUN_TEST_SHARED_PREFIX_MODEL;

test.skipIf(!artifact)("RAM prefixes remain immutable across decode and SSD restart restore", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { generate } = await import("../../src/generate");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { leaseCacheState } = await import("../../src/backends/mlx/state-views");
  const { KVCache, QuantizedKVCache } = await import("../../src/model/gemma4-base");
  const { withResource } = await import("../../src/engine/resources");
  const { clearCache, activeMemory, peakMemory } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(artifact!);
  const model = createModel(weights, await loadModelConfig(artifact!));
  const tokenizer = await loadTokenizer(artifact!);
  const lengths = (Bun.env.MLX_BUN_TEST_SHARED_PREFIX_LENGTHS ?? "128,2051").split(",").map(Number);
  const corpus = tokenizer.encode("The workshop keeps brass washers, maple dowels and copper wire. ".repeat(Math.ceil(Math.max(...lengths) / 8)));
  const bits = Number(Bun.env.MLX_BUN_TEST_SHARED_PREFIX_KV_BITS ?? 0);
  const options = { ...(bits ? { kvBits: bits, quantizedKvStart: 0 } : {}),
    temperature: 0, maxTokens: Number(Bun.env.MLX_BUN_TEST_SHARED_PREFIX_OUTPUT_TOKENS ?? 16), eosTokenIds: [], prefillChunkSize: 512 };
  const digest = (caches: ReturnType<typeof model.makeCache>) => {
    const hash = createHash("sha256");
    for (const cache of caches) withResource(leaseCacheState(cache), arrays => {
      hash.update(JSON.stringify([cache.signature(), cache.offset]));
      for (const array of arrays) {
        // SSD restore reserves growth capacity. Compare the logical prefix,
        // excluding unused full-attention slots beyond the cache offset.
        const shape = array.shape;
        const live = (cache instanceof KVCache || cache instanceof QuantizedKVCache) && shape.length === 4 && shape[2]! > cache.offset
          ? array.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
        const contiguous = ops.contiguous(live ?? array);
        try { hash.update(JSON.stringify([(live ?? array).shape, array.dtype])); hash.update(contiguous.rawBytesView()); }
        finally { contiguous.dispose(); live?.dispose(); }
      }
    });
    return hash.digest("hex");
  };
  try {
    for (const length of lengths) {
      expect(corpus.length).toBeGreaterThanOrEqual(length);
      const prompt = corpus.slice(0, length), boundary = prompt.slice(0, -1);
      const dir = mkdtempSync(join(tmpdir(), "mlx-prefix-sharing-"));
      const diskOptions = { dir, maxBytes: Infinity, configFingerprint: "native-prefix-sharing", tokenizerHash: "native-prefix-sharing", modelId: artifact! };
      let disk = new SsdCacheStore(diskOptions), stores = 0, restores = 0;
      const cache = new PromptCache(8e9, null, {
        find(ids, ns) { const hit = disk.find(ids, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
        restore(handle) { restores++; const loaded = disk.restore(handle as any, model); return loaded ? { ...loaded, retain() {} } : null; },
        store(ids, state, ns, attachments) { stores++; return disk.store(ids, state, ns, attachments); },
      });
      const fresh = model.makeCache();
      try {
        const expected: number[] = [];
        const cold = generate(model, prompt, { ...options, cache: fresh, snapshotAt: boundary.length,
          onPrefillDone() { cache.put(boundary, cloneKvCaches(fresh)); } });
        for await (const token of cold) expected.push(token.token);
        for (const state of fresh.splice(0)) state.dispose();
        const donor = cache.findExact(boundary)!;
        expect(donor).not.toBeNull();
        const before = digest(donor.caches);
        for (let iteration = 0; iteration < 3; iteration++) {
          const hit = cache.take(prompt)!;
          expect(hit.tokens).toEqual(boundary);
          expect(cache.findExact(boundary)).toBe(donor);
          expect(hit.caches[0]).not.toBe(donor.caches[0]);
          try {
            const reused = generate(model, prompt, { ...options, cache: hit.caches });
            const output: number[] = [];
            for await (const token of reused) output.push(token.token);
            expect(output).toEqual(expected);
            expect(reused.stats!.cachedTokens).toBe(boundary.length);
            expect(digest(donor.caches)).toBe(before);
          } finally { for (const state of hit.caches) state.dispose(); hit.retain?.(); }
        }
        expect(stores).toBe(0);
        expect(restores).toBe(0);
        const retainedBytes = cache.totalBytes;
        expect(cache.demoteIdle(0)).toBe(1);
        expect(cache.size).toBe(0);
        disk = new SsdCacheStore(diskOptions);
        expect(disk.scan()).toBe(1);
        const restored = cache.take(prompt)!;
        try {
          expect(digest(restored.caches)).toBe(before);
          const resumed = generate(model, prompt, { ...options, cache: restored.caches });
          const output: number[] = [];
          for await (const token of resumed) output.push(token.token);
          expect(output).toEqual(expected);
          expect(resumed.stats!.cachedTokens).toBe(boundary.length);
        } finally { for (const state of restored.caches) state.dispose(); restored.retain?.(); }
        expect(restores).toBe(1);
        clearCache();
        console.log(JSON.stringify({ test: "prefix-cache-sharing", length, outputTokens: options.maxTokens, bits, retainedBytes,
          activeBytes: activeMemory(), peakBytes: peakMemory(), stores, restores }));
      } finally {
        cache.clear(); for (const state of fresh) state.dispose();
        rmSync(dir, { recursive: true, force: true }); clearCache();
      }
    }
  } finally { weights.dispose(); clearCache(); }
}, 600_000);
