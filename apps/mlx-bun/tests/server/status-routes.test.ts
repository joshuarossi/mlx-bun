import { expect, test } from "bun:test";
import { fit, skuMatrix } from "@mlx-bun/hub/fit";
import { KvScheme } from "@mlx-bun/inference/state/kv-scheme";
import type { ModelConfig } from "@mlx-bun/inference/artifacts/config";
import { createStatusRoutes } from "../../src/server/status-routes";
import { pendingRoute } from "../../src/server/start";

type Input = Parameters<typeof createStatusRoutes>[0];
function fixture(): Input {
  const config = { text: { numHiddenLayers: 2, numAttentionHeads: 8, numKeyValueHeads: 2,
    headDim: 64, globalHeadDim: 64, numGlobalKeyValueHeads: 2, attentionKEqV: false,
    layerTypes: ["full_attention", "sliding_attention"], slidingWindow: 1024,
    maxPositionEmbeddings: 32768, enableMoeBlock: true, numExperts: 8, topKExperts: 2 } } as ModelConfig;
  return {
    context: { modelId: "test/model", model: { config, weightsBytes: 2e9 } },
    caches: { resolvedKvScheme: new KvScheme("bf16", {}), checkpoints: null,
      promptCache: { size: 3, totalBytes: 40, maxBytes: 80, hits: 2, misses: 1,
        sessionHits: 7, sessionMisses: 8, prefixScans: 9, objectHits: 10, objectMisses: 11, objectRestores: 12, demotions: 13 },
      stats: () => ({ pendingSnapshots: 2, pendingSpills: 3, pendingSpillBytes: 4, droppedSpills: 5, failedSpills: 6 }) },
    gateway: { activeRows: 1, pendingRows: 2, submittedRows: 3, kvBytes: { projected: 100, budget: 200 } },
    diagnostics: () => ({ custom_model: { active: true } }),
    responseStats: () => ({ entries: 2, bytes: 300, max_bytes: 400, ttl_ms: 60000 }),
    artifact: { expertsBytes: 1e9, sizeBytes: 2.5e9 }, capacity: 1, contextLimit: null, startedAt: 123,
    machine: { name: "test", ramBytes: 16 * 2 ** 30, bandwidthGBs: 200 }, chip: "test-chip",
  };
}
const get = async (routes: ReturnType<typeof createStatusRoutes>, path: string) =>
  (await routes.handle(new Request(`http://local${path}`)))!.json();

test("stats preserves the wire counters and observes changes without execution or resource ownership", async () => {
  const input = fixture(), routes = createStatusRoutes(input);
  const body = await get(routes, "/stats");
  expect(body.server).toEqual({ owner: "embedded", model: "test/model", started_at: 123 });
  expect(body.prompt_cache).toEqual({ entries: 3, bytes: 40, max_bytes: 80, hits: 2, misses: 1,
    session_hits: 7, session_misses: 8, prefix_scans: 9, object_hits: 10, object_misses: 11, object_restores: 12 });
  expect(body.response_store).toEqual({ entries: 2, bytes: 300, max_bytes: 400, ttl_ms: 60000 });
  expect(body.kv_quant).toEqual(input.caches.resolvedKvScheme.describe(input.context.model.config));
  expect(body.custom_model).toEqual({ active: true }); expect(body.ssd_cache).toBeUndefined();
  expect(body.batch).toEqual({ configured: 1, mode: "batch", batched: true,
    active_rows: 1, pending_rows: 2, submitted_rows: 3, kv_bytes: 100, kv_budget_bytes: 200 });
  input.caches.promptCache.hits = 15;
  input.responseStats = () => ({ entries: 8, bytes: 500, max_bytes: 600, ttl_ms: 70000 });
  const next = await get(routes, "/stats");
  expect(next.prompt_cache.hits).toBe(15); expect(next.response_store.entries).toBe(8);
  expect(next.admission.enforced_context_tokens).toBeNull();
  expect(next.admission.memory_budget_bytes).toBeNull();
});

test("SSD stats expose live store and combined persistence counters with unlimited cap encoded as null", async () => {
  const input = fixture(); input.ssdCacheDir = "/injected/cache";
  input.caches.checkpoints = { entries: 7, totalBytes: 8, maxBytes: Infinity,
    stats: { restores: 9, spills: 10, restoreMsLast: 10.7 }, longestDurablePrefixTokens: 11 } as NonNullable<Input["caches"]["checkpoints"]>;
  const body = await get(createStatusRoutes(input), "/stats");
  expect(body.ssd_cache).toEqual({ dir: "/injected/cache", entries: 7, bytes: 8, max_bytes: null,
    restores: 9, spills: 10, restore_ms_last: 11, demotions: 13, pending_snapshots: 2,
    pending_spills: 3, pending_spill_bytes: 4, dropped_spills: 5, failed_spills: 6, longest_durable_prefix_tokens: 11 });
});

test("fit reuses hub estimates at maximum and typical context with the served artifact's expert bytes", async () => {
  const input = fixture(), routes = createStatusRoutes(input), { config, weightsBytes } = input.context.model;
  const admission = fit(config, weightsBytes, 1, input.machine);
  const report = fit(config, weightsBytes, admission.maxSafeContext, input.machine, undefined, input.artifact.expertsBytes);
  const body = await get(routes, "/fit");
  expect(body.machine).toEqual({ chip: "test-chip", ram_bytes: input.machine!.ramBytes, bandwidth_gbs: 200 });
  expect(body.context_tokens).toBe(admission.maxSafeContext);
  expect(body.typical_context_tokens).toBe(8192);
  expect(body.typical_decode_tps).toBe(fit(config, weightsBytes, 8192, input.machine, undefined, input.artifact.expertsBytes).predictedDecodeTps);
  expect(body.report).toEqual({ fits: report.fits, weights_bytes: report.weightsBytes, kv_bytes: report.kvBytes,
    transient_bytes: report.transientBytes, total_bytes: report.totalBytes, usable_bytes: report.usableBytes,
    max_safe_context: report.maxSafeContext, predicted_decode_tps: report.predictedDecodeTps });
  expect(body.measured_decode_tps).toBeNull(); expect(body.measured_at).toBeNull();
  expect(body.sku_matrix_ctx).toBe(32768);
  expect(body.sku_matrix).toEqual(skuMatrix(config, weightsBytes, 32768, input.artifact.expertsBytes)
    .map(r => ({ sku: r.sku, ram_gb: r.ramGB, fits: r.fits, max_context: r.maxContext, decode_tps: r.decodeTps })));
});

test("a negative fit estimate stays advisory and never invents an enforced context cap", async () => {
  const input = fixture(); input.context.model.weightsBytes = 100e9;
  const routes = createStatusRoutes(input);
  expect((await get(routes, "/fit")).report.fits).toBe(false);
  expect((await get(routes, "/stats")).admission.enforced_context_tokens).toBeNull();
  expect(input.contextLimit).toBeNull();
});

test("GLM status preserves plan accounting and identifies unavailable historical throughput as null", async () => {
  const input = fixture(); input.contextLimit = 1024;
  input.context.glmMemoryPlan = { contextTokens: 4096, maxSafeContext: 4096, maxGenerationTokens: 128,
    processLimitBytes: 10000, usableBytes: 10000, plannedProcessBytes: 9000,
    lineItems: { residentWeightsBytes: 1000, mainExpertSlabBytes: 2000, mtpExpertSlabBytes: 500,
      targetKvBytes: 100, mtpKvBytes: 50 } } as NonNullable<Input["context"]["glmMemoryPlan"]>;
  const routes = createStatusRoutes(input), body = await get(routes, "/fit");
  expect(body.report).toEqual({ fits: true, weights_bytes: 1000, kv_bytes: 150, transient_bytes: 5350,
    total_bytes: 9000, usable_bytes: 10000, max_safe_context: 4096, predicted_decode_tps: null });
  expect(body.context_tokens).toBe(4096); expect(body.typical_context_tokens).toBe(4096);
  expect(body.measured_decode_tps).toBeNull(); expect(body.measured_at).toBeNull(); expect(body.typical_decode_tps).toBeNull();
  expect(body.glm52).toEqual({ artifact_disk_bytes: 2.5e9, main_expert_slab_bytes: 2000,
    mtp_expert_slab_bytes: 500, max_generation_tokens: 128, direct_oracle_warm_decode_tps: null, aspirational_decode_tps: null });
  expect(body.sku_matrix).toEqual([{ sku: "test-chip", ram_gb: 16, fits: true, max_context: 4096, decode_tps: null }]);
  expect((await get(routes, "/stats")).admission).toEqual({ max_safe_context: 4096, enforced_context_tokens: 1024,
    memory_budget_bytes: 10000, usable_bytes: 10000, weights_bytes: 2e9 });
});

test("status owns only GET stats and fit, with their migration placeholders removed", async () => {
  const routes = createStatusRoutes(fixture());
  for (const path of ["/stats", "/fit"]) {
    expect(pendingRoute(path)).toBe(false);
    expect(await routes.handle(new Request(`http://local${path}`, { method: "POST" }))).toBeNull();
  }
  expect(await routes.handle(new Request("http://local/other"))).toBeNull();
});
