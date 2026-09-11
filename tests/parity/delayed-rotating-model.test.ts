import { test, expect } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const artifact = Bun.env.MLX_BUN_TEST_DELAYED_ROTATING_MODEL;
test.skipIf(!artifact)("delayed rotating affine conversion preserves Gemma hidden/logits, shared reads and active state", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { KVCache, QuantizedKVCache, RotatingKVCache, RotatingQuantizedKVCache, isBatchableCache } = await import("../../src/model/gemma4-base");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { cloneKvCaches, saveKvCache, loadKvCache } = await import("../../src/kv-store");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { withResource, disposeResources } = await import("../../src/engine/resources");
  const { clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const config = await loadModelConfig(artifact!), weights = await Weights.open(artifact!), model = createModel(weights, config);
  const bits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 4);
  const perLayer = Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1";
  if (perLayer) expect(config.kvQuant?.length).toBeGreaterThan(0);
  const maintain = createKvMaintenance(perLayer
    ? { kvConfig: config.kvQuant!, quantizedKvStart: 5 }
    : { kvBits: bits, kvGroupSize: 64, quantizedKvStart: 5 });
  const digest = (a: import("../../src/mlx/array").MlxArray) => {
    using view = ops.contiguous(a); return createHash("sha256").update(view.rawBytesView()).digest("hex");
  };
  const stateDigest = (cache: import("../../src/model/gemma4-base").Cache) => {
    if (cache instanceof RotatingKVCache) {
      const arrays = cache.temporalView();
      try { return arrays.map(digest); } finally { disposeResources(arrays); }
    }
    if (cache instanceof RotatingQuantizedKVCache) {
      const pair = cache.temporalView(), arrays = pair.flatMap(t => [t.packed, t.scales, t.biases]);
      try { return arrays.map(digest); } finally { disposeResources(arrays); }
    }
    return withResource(leaseCacheStates([cache]), arrays => arrays.map(array => {
      if (cache instanceof KVCache || cache instanceof QuantizedKVCache) {
        using active = array.slice([0, 0, 0, 0], [array.shape[0]!, array.shape[1]!, cache.offset, array.shape[3]!]);
        return digest(active);
      }
      return digest(array);
    }));
  };
  try {
    for (const length of [3, 7, config.text.slidingWindow + 2]) {
      const seed = model.makeCache(); let actual: import("../../src/model/gemma4-base").Cache[] = [], expected: import("../../src/model/gemma4-base").Cache[] = [];
      try {
        using ids = ops.fromInt32(Array.from({ length }, (_, i) => 1 + i % 500), [1, length]);
        using hidden = model.forwardHidden(ids, seed); digest(hidden);
        actual = cloneKvCaches(seed); expected = cloneKvCaches(seed); maintain.prepareBatch!(actual);
        expect(actual.some(cache => cache.signature().startsWith("kv:delayed-rotating"))).toBe(true);
        for (const token of [71, 72, 73, 74]) {
          // Ordinary decode converts committed input history before the step.
          maintain(expected);
          using input = ops.fromInt32([token], [1, 1]);
          using got = model.forwardHidden(input, actual), wanted = model.forwardHidden(input, expected);
          expect(digest(got), `hidden length ${length} token ${token}`).toBe(digest(wanted));
          using gotLogits = model.logitsFromHidden(got), wantedLogits = model.logitsFromHidden(wanted);
          expect(digest(gotLogits), `logits length ${length} token ${token}`).toBe(digest(wantedLogits));
          const extracted = actual.map(cache => isBatchableCache(cache) ? cache.extractRow(0) : cloneKvCaches([cache])[0]!);
          try {
            expect(extracted.map(c => [c.offset, c.minimumReusableOffset ?? 0])).toEqual(expected.map(c => [c.offset, c.minimumReusableOffset ?? 0]));
            expect(extracted.map(stateDigest), `state length ${length} token ${token}`).toEqual(expected.map(stateDigest));
          } finally { disposeResources(extracted); }
          for (const cache of actual) (cache as { releaseRopeArr?: () => void }).releaseRopeArr?.();
        }
        const checkpoint = actual.map(cache => isBatchableCache(cache) ? cache.extractRow(0) : cloneKvCaches([cache])[0]!);
        const directory = mkdtempSync(join(tmpdir(), "mlx-bun-delayed-rotating-"));
        let restored: import("../../src/model/gemma4-base").Cache[] = [];
        let ram: import("../../src/model/gemma4-base").Cache[] = [];
        try {
          const path = join(directory, "checkpoint.kv");
          const tokens = [...Array.from({ length }, (_, i) => 1 + i % 500), 71, 72, 73, 74];
          saveKvCache(path, tokens, checkpoint);
          const loaded = loadKvCache(path, model, { verify: true }); restored = loaded.caches;
          expect(loaded.tokens).toEqual(tokens);
          expect(restored.map(stateDigest)).toEqual(checkpoint.map(stateDigest));
          expect(restored.map(c => c.minimumReusableOffset ?? 0)).toEqual(checkpoint.map(c => c.minimumReusableOffset ?? 0));
          ram = cloneKvCaches(checkpoint);
          maintain.prepareBatch!(restored); maintain.prepareBatch!(ram);
          using input = ops.fromInt32([75], [1, 1]);
          using fromSsd = model.forwardHidden(input, restored), fromRam = model.forwardHidden(input, ram);
          expect(digest(fromSsd)).toBe(digest(fromRam));
          using ssdLogits = model.logitsFromHidden(fromSsd), ramLogits = model.logitsFromHidden(fromRam);
          expect(digest(ssdLogits)).toBe(digest(ramLogits));
        } finally { disposeResources([...checkpoint, ...restored, ...ram]); rmSync(directory, { recursive: true, force: true }); }
      } finally { disposeResources([...actual, ...expected, ...seed]); clearCache(); }
    }
  } finally { weights.dispose(); clearCache(); }
}, 300_000);
