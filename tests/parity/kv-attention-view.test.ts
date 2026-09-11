import { test, expect, spyOn } from "bun:test";
import { createHash } from "node:crypto";

const artifact = Bun.env.MLX_BUN_TEST_ATTENTION_VIEW_MODEL;
test.skipIf(!artifact)("captured attention views preserve full model state and repeated Gemma consumers", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { KVCache, QuantizedKVCache } = await import("../../src/model/gemma4-base");
  const { Gemma4Model } = await import("../../src/model/gemma4");
  const { DelayedQuantizedKVCache } = await import("../../src/model/delayed-quantized-kv");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { withResource, disposeResources } = await import("../../src/engine/resources");
  const { clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(artifact!), model = createModel(weights, await loadModelConfig(artifact!));
  const bits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 4);
  const prototype = model.makeCache();
  const kvConfig = prototype.flatMap((cache, layerIdx) => cache instanceof KVCache ? [{ layerIdx, bits, groupSize: 64 }] : []);
  disposeResources(prototype);
  const maintain = createKvMaintenance({ kvConfig, quantizedKvStart: 5 });
  const digest = (a: import("../../src/mlx/array").MlxArray) => {
    using view = ops.contiguous(a); return createHash("sha256").update(view.rawBytesView()).digest("hex");
  };
  const stateDigest = (caches: readonly import("../../src/model/gemma4-base").Cache[]) =>
    caches.flatMap(cache => withResource(leaseCacheStates([cache]), arrays => arrays.map(array => {
      if (cache instanceof KVCache || cache instanceof QuantizedKVCache) {
        // Extracted checkpoints compact the active prefix; allocator capacity
        // beyond offset is not model state and may contain unused values.
        using active = array.slice([0, 0, 0, 0], [array.shape[0]!, array.shape[1]!, cache.offset, array.shape[3]!]);
        return digest(active);
      }
      return digest(array);
    })));
  let appends = 0, reads = 0;
  const append = DelayedQuantizedKVCache.prototype.appendAndFetch;
  const observer = spyOn(DelayedQuantizedKVCache.prototype, "appendAndFetch").mockImplementation(function (this: InstanceType<typeof DelayedQuantizedKVCache>, k, v) {
    appends++; const view = append.call(this, k, v), attend = view.attend;
    view.attend = (q, scale, mask) => { reads++; return attend(q, scale, mask); };
    return view;
  });
  try {
    expect(kvConfig.length).toBeGreaterThan(0);
    for (const length of [3, 7]) {
      const seed = model.makeCache(); let actual: import("../../src/model/gemma4-base").Cache[] = [], expected: import("../../src/model/gemma4-base").Cache[] = [];
      try {
        using ids = ops.fromInt32(Array.from({ length }, (_, i) => i + 1), [1, length]);
        using hidden = model.forwardHidden(ids, seed); digest(hidden); maintain(seed);
        actual = cloneKvCaches(seed); expected = cloneKvCaches(seed); maintain.prepareBatch!(actual);
        for (const token of [71, 72, 73, 74]) {
          for (const cache of actual) if (cache instanceof DelayedQuantizedKVCache) cache.specRoundBegin();
          using input = ops.fromInt32([token], [1, 1]);
          using got = model.forwardHidden(input, actual), wanted = model.forwardHidden(input, expected);
          expect(digest(got)).toBe(digest(wanted));
          using gotLogits = model.logitsFromHidden(got), wantedLogits = model.logitsFromHidden(wanted);
          expect(digest(gotLogits)).toBe(digest(wantedLogits));
          for (const cache of actual) if (cache instanceof DelayedQuantizedKVCache) cache.specRoundCommit();
          maintain(expected);
          const extracted = actual.map(cache => cache instanceof DelayedQuantizedKVCache ? cache.extractRow(0) : cloneKvCaches([cache])[0]!);
          try {
            expect(extracted.map(c => [c.offset, c.minimumReusableOffset ?? 0]))
              .toEqual(expected.map(c => [c.offset, c.minimumReusableOffset ?? 0]));
            expect(stateDigest(extracted)).toEqual(stateDigest(expected));
          } finally { disposeResources(extracted); }
        }
      } finally { disposeResources([...actual, ...expected, ...seed]); clearCache(); }
    }
    expect(appends).toBeGreaterThan(0);
    if (model instanceof Gemma4Model && model.config.text.numHiddenLayers > prototype.length) expect(reads).toBeGreaterThan(appends);
    else expect(reads).toBeGreaterThanOrEqual(appends);
    console.error(JSON.stringify({ artifact, bits, appends, reads }));
  } finally { observer.mockRestore(); weights.dispose(); clearCache(); }
}, 300_000);
