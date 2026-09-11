import { expect, test } from "bun:test";
import { createHash } from "node:crypto";

const enabled = Bun.env.MLX_BUN_TEST_ROTATING_SPEC_QUANT === "1";
test.skipIf(!enabled)("quantized target row layouts preserve B1 forward logits from identical cached state", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { targetCacheLayout } = await import("../../src/backends/mlx/cache-layout");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const ops = await import("../../src/mlx/ops");
  const path = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
  const weights = await Weights.open(path), model = createModel(weights, await loadModelConfig(path));
  const bits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 4);
  const source = model.makeCache();
  try {
    const length = Number(Bun.env.MLX_BUN_TEST_QUANTIZED_PREFIX ?? 7);
    using prompt = ops.fromInt32(Array.from({length}, (_,i)=>1+i%97), [1, length]);
    using hidden = model.forwardHidden(prompt, source); hidden.eval();
    const turboQuant = Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
    const perLayer = Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1";
    if (perLayer) expect(model.config.kvQuant?.length).toBeGreaterThan(0);
    const start = Number(Bun.env.MLX_BUN_TEST_MTP_KV_START ?? 0);
    const maintain = createKvMaintenance({ ...(turboQuant ? { turboQuant }
      : perLayer ? { kvConfig: model.config.kvQuant! } : { kvBits: bits, kvGroupSize: 64 }), quantizedKvStart: start });
    maintain(source);
    const results = [];
    for (const width of [1, 8]) {
      const reference = cloneKvCaches(source);
      const prepared = cloneKvCaches(source);
      maintain.prepareBatch?.(prepared);
      const rows = prepared.map(cache => {
        const layout = targetCacheLayout(cache); layout.mergeRows([cache]); return layout;
      });
      for (const cache of prepared) cache.dispose();
      try {
        for (const [step, count] of [width, 1, 1].entries()) {
          maintain(reference);
          for (const row of rows) row.specRoundBegin();
          using ids = ops.fromInt32(Array(count).fill(100 + step), [1, count]);
          using expected = model.forwardHidden(ids, reference);
          using actual = model.forwardHidden(ids, rows);
          using refLogits = model.logitsFromHidden(expected);
          using rowLogits = model.logitsFromHidden(actual);
          using refTop = ops.argmaxAxis(refLogits, -1), rowTop = ops.argmaxAxis(rowLogits, -1);
          using x = ops.contiguous(expected), y = ops.contiguous(actual);
          const hash = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
          using refScores = ops.contiguous(refLogits), rowScores = ops.contiguous(rowLogits);
          results.push({ width, step, expectedScores: hash(refScores.rawBytesView()), actualScores: hash(rowScores.rawBytesView()), expected: hash(x.rawBytesView()), actual: hash(y.rawBytesView()),
            expectedTokens: refTop.toIntTokens(), actualTokens: rowTop.toIntTokens() });
          for (const row of rows) row.specRoundCommit();
        }
      } finally { for (const cache of [...reference, ...rows]) cache.dispose(); }
    }
    console.error(JSON.stringify(results));
    for (const result of results) {
      expect(result.actualTokens).toEqual(result.expectedTokens);
      expect(result.actual).toBe(result.expected);
      expect(result.actualScores).toBe(result.expectedScores);
    }
  } finally { for (const cache of source) cache.dispose(); weights.dispose(); }
}, 180000);
