import { detectChip, fit, skuMatrix, thisMachine, type MachineSpec } from "@mlx-bun/hub/fit";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { createCacheServices } from "../engine/cache-services";
import type { GenerationGateway } from "../engine/generation-gateway";
import type { LoadedModelContext } from "../engine/model-host";
import type { ModelBinding } from "../engine/model-binding";

type CacheServices = Awaited<ReturnType<typeof createCacheServices>>;
type PromptCounters = Pick<CacheServices["promptCache"], "size" | "totalBytes" | "maxBytes" |
  "hits" | "misses" | "sessionHits" | "sessionMisses" | "prefixScans" |
  "objectHits" | "objectMisses" | "objectRestores" | "demotions">;
type DiskCounters = Pick<NonNullable<CacheServices["checkpoints"]>, "entries" | "totalBytes" |
  "maxBytes" | "longestDurablePrefixTokens"> & {
    stats: Pick<NonNullable<CacheServices["checkpoints"]>["stats"], "restores" | "spills" | "restoreMsLast">;
  };

/** Read-only HTTP views borrow counters and metadata. They neither open model
 * storage nor acquire execution leases, and fit estimates never set admission. */
export function createStatusRoutes(input: {
  context: Pick<LoadedModelContext, "modelId" | "glmMemoryPlan"> & {
    model: Pick<LoadedModelContext["model"], "config" | "weightsBytes">;
  };
  caches: Pick<CacheServices, "stats"> & {
    resolvedKvScheme: Pick<CacheServices["resolvedKvScheme"], "fitOptions" | "describe">;
    promptCache: PromptCounters; checkpoints: DiskCounters | null;
  };
  gateway: Pick<GenerationGateway, "activeRows" | "pendingRows" | "submittedRows" | "kvBytes">;
  diagnostics: ModelBinding["diagnostics"];
  responseStats(): { entries: number; bytes: number; max_bytes: number; ttl_ms: number };
  artifact: Pick<ModelRecord, "expertsBytes" | "sizeBytes">;
  capacity: number;
  contextLimit: number | null;
  startedAt: number;
  owner?: string;
  ssdCacheDir?: string;
  /** Main's explicit `--memory-budget`: the usable envelope for the estimates below. */
  memoryBudgetBytes?: number;
  /** Composition/test inputs; omitted values use the hub's machine detection. */
  machine?: MachineSpec;
  chip?: string | null;
}) {
  const { context: ctx, caches, gateway } = input;
  const machine = input.machine ?? thisMachine();
  const chip = input.chip === undefined ? detectChip().name : input.chip;
  const plan = ctx.glmMemoryPlan;
  const admission = plan ?? fit(ctx.model.config, ctx.model.weightsBytes, 1,
    machine, undefined, 0, input.memoryBudgetBytes, caches.resolvedKvScheme.fitOptions);

  return { async handle(request: Request): Promise<Response | null> {
    if (request.method !== "GET") return null;
    const path = new URL(request.url).pathname;
    if (path === "/stats") {
      const pc = caches.promptCache, disk = caches.checkpoints;
      const pending = caches.stats();
      return Response.json({
        server: { owner: input.owner ?? "embedded", model: ctx.modelId, started_at: input.startedAt },
        prompt_cache: { entries: pc.size, bytes: pc.totalBytes, max_bytes: pc.maxBytes,
          hits: pc.hits, misses: pc.misses, session_hits: pc.sessionHits, session_misses: pc.sessionMisses,
          prefix_scans: pc.prefixScans, object_hits: pc.objectHits, object_misses: pc.objectMisses, object_restores: pc.objectRestores },
        ...(disk ? { ssd_cache: { dir: input.ssdCacheDir, entries: disk.entries, bytes: disk.totalBytes,
          max_bytes: Number.isFinite(disk.maxBytes) ? disk.maxBytes : null,
          restores: disk.stats.restores, spills: disk.stats.spills, restore_ms_last: Math.round(disk.stats.restoreMsLast),
          demotions: pc.demotions, pending_snapshots: pending.pendingSnapshots, pending_spills: pending.pendingSpills,
          pending_spill_bytes: pending.pendingSpillBytes, dropped_spills: pending.droppedSpills, failed_spills: pending.failedSpills,
          longest_durable_prefix_tokens: disk.longestDurablePrefixTokens } } : {}),
        response_store: input.responseStats(),
        kv_quant: caches.resolvedKvScheme.describe(ctx.model.config),
        admission: { max_safe_context: admission.maxSafeContext, enforced_context_tokens: input.contextLimit,
          memory_budget_bytes: plan?.processLimitBytes ?? input.memoryBudgetBytes ?? null, usable_bytes: admission.usableBytes, weights_bytes: ctx.model.weightsBytes },
        ...input.diagnostics(),
        batch: { configured: input.capacity, mode: "batch", batched: true,
          active_rows: gateway.activeRows, pending_rows: gateway.pendingRows, submitted_rows: gateway.submittedRows,
          kv_bytes: gateway.kvBytes.projected, kv_budget_bytes: gateway.kvBytes.budget },
      });
    }
    if (path !== "/fit") return null;
    const machineWire = { chip, ram_bytes: machine.ramBytes, bandwidth_gbs: machine.bandwidthGBs };
    if (plan) {
      const li = plan.lineItems, kvBytes = li.targetKvBytes + li.mtpKvBytes;
      return Response.json({ machine: machineWire, context_tokens: plan.contextTokens,
        typical_context_tokens: plan.contextTokens, typical_decode_tps: null,
        measured_decode_tps: null, measured_at: null,
        report: { fits: true, weights_bytes: li.residentWeightsBytes, kv_bytes: kvBytes,
          transient_bytes: plan.plannedProcessBytes - li.residentWeightsBytes - li.mainExpertSlabBytes - li.mtpExpertSlabBytes - kvBytes,
          total_bytes: plan.plannedProcessBytes, usable_bytes: plan.processLimitBytes,
          max_safe_context: plan.contextTokens, predicted_decode_tps: null },
        glm52: { artifact_disk_bytes: input.artifact.sizeBytes,
          main_expert_slab_bytes: li.mainExpertSlabBytes, mtp_expert_slab_bytes: li.mtpExpertSlabBytes,
          max_generation_tokens: plan.maxGenerationTokens,
          direct_oracle_warm_decode_tps: null, aspirational_decode_tps: null },
        sku_matrix_ctx: plan.contextTokens,
        sku_matrix: [{ sku: chip, ram_gb: Math.round(machine.ramBytes / 2 ** 30), fits: true,
          max_context: plan.contextTokens, decode_tps: null }],
      });
    }
    const report = fit(ctx.model.config, ctx.model.weightsBytes, admission.maxSafeContext,
      machine, undefined, input.artifact.expertsBytes, input.memoryBudgetBytes, caches.resolvedKvScheme.fitOptions);
    const typicalContext = Math.min(8192, admission.maxSafeContext);
    return Response.json({ machine: machineWire, context_tokens: admission.maxSafeContext,
      typical_context_tokens: typicalContext,
      typical_decode_tps: fit(ctx.model.config, ctx.model.weightsBytes, typicalContext,
        machine, undefined, input.artifact.expertsBytes, input.memoryBudgetBytes, caches.resolvedKvScheme.fitOptions).predictedDecodeTps,
      // The old EvalDB and machine-specific historical GLM measurements are not
      // live evidence for this server. Preserve the fields without inventing data.
      measured_decode_tps: null, measured_at: null,
      report: { fits: report.fits, weights_bytes: report.weightsBytes, kv_bytes: report.kvBytes,
        transient_bytes: report.transientBytes, total_bytes: report.totalBytes,
        usable_bytes: report.usableBytes, max_safe_context: report.maxSafeContext, predicted_decode_tps: report.predictedDecodeTps },
      sku_matrix_ctx: 32768,
      sku_matrix: skuMatrix(ctx.model.config, ctx.model.weightsBytes, 32768, input.artifact.expertsBytes)
        .map(r => ({ sku: r.sku, ram_gb: r.ramGB, fits: r.fits, max_context: r.maxContext, decode_tps: r.decodeTps })),
    });
  } };
}
