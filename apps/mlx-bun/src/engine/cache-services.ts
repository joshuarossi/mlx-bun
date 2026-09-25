import { readFileSync } from "node:fs";
import { resolveKvScheme, type KvQuantOverride } from "@mlx-bun/inference/state/kv-scheme";
import type { TurboQuantScheme } from "@mlx-bun/inference/artifacts/config";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import type { PromptCache, TieredPromptCache, SsdCacheStore, SsdIndexEntry,
  CacheCodecProvider, ColdTier, DurabilitySnapshotStats, DurabilityFlushResult } from "@mlx-bun/inference/state";
import type { ContinuationPersistence, MlxGatewayBinding } from "@mlx-bun/inference/execution";
import type { LoadedModelContext } from "./model-host";
import type { ModelBinding } from "./model-binding";

export interface CacheServiceOptions {
  promptCacheBytes?: number;
  kvQuant?: KvQuantOverride;
  turboQuant?: TurboQuantScheme;
  quantizedKvStart?: number;
  ssdCacheDir?: string;
  ssdCacheMaxBytes?: number;
  ssdCacheVerify?: boolean;
  ssdDemoteIdleSec?: number;
  generationCheckpointTokens?: number;
  /** An explicit allocator cap also limits optional RAM cache residency. */
  allocatorLimitBytes?: number;
}

/** Construction ports let CPU tests and replacement runtimes supply their own
 * storage objects. Returned cache/state objects retain the library contracts. */
export interface CacheServiceDependencies {
  defaultStateCodecs: CacheCodecProvider;
  cloneState(caches: Cache[], codecs: CacheCodecProvider): Cache[];
  createPromptCache(...args: ConstructorParameters<typeof PromptCache>): PromptCache;
  createTieredPromptCache(...args: ConstructorParameters<typeof TieredPromptCache>): TieredPromptCache;
  createStore(options: ConstructorParameters<typeof SsdCacheStore>[0]): SsdCacheStore;
  createContinuationPersistence(...args: ConstructorParameters<typeof ContinuationPersistence>): ContinuationPersistence;
  costSizeRetention(): PromptCache["retention"];
  configFingerprint(config: LoadedModelContext["model"]["config"]): string;
  activeMemory(): number;
  maxWorkingSet(): number;
  scheduleDemotion(run: () => void, intervalMs: number): () => void;
}

async function defaultDependencies(): Promise<CacheServiceDependencies> {
  const [state, execution, artifacts, memory] = await Promise.all([
    import("@mlx-bun/inference/state"), import("@mlx-bun/inference/execution"),
    import("@mlx-bun/inference/artifacts"), import("@mlx-bun/mlx/ffi"),
  ]);
  return {
    defaultStateCodecs: state.legacyCacheCodecs, cloneState: state.cloneKvCaches,
    createPromptCache: (...args) => new state.PromptCache(...args),
    createTieredPromptCache: (...args) => new state.TieredPromptCache(...args),
    createStore: options => new state.SsdCacheStore(options),
    createContinuationPersistence: (...args) => new execution.ContinuationPersistence(...args),
    costSizeRetention: () => new state.CostSizeRetention(), configFingerprint: artifacts.configFingerprint,
    activeMemory: memory.activeMemory, maxWorkingSet: memory.maxRecommendedWorkingSetSize,
    scheduleDemotion(run, interval) { const timer = setInterval(run, interval); timer.unref(); return () => clearInterval(timer); },
  };
}

/** Compose app cache policy without loading a model or starting execution.
 * The caller borrows these services until execution has drained, then closes
 * them before disposing the model. SSD is opt-in; plain KV and 8 GB RAM retain
 * main's defaults. Native library imports are deferred until construction. */
export async function createCacheServices(context: LoadedModelContext, binding: ModelBinding,
  options: CacheServiceOptions = {}, supplied?: CacheServiceDependencies) {
  if (options.generationCheckpointTokens !== undefined) {
    if (!Number.isInteger(options.generationCheckpointTokens) || options.generationCheckpointTokens < 1)
      throw new Error("generationCheckpointTokens must be a positive integer");
    if (!options.ssdCacheDir) throw new Error("generation checkpoints require an SSD cache directory");
  }
  const cap = options.promptCacheBytes ?? 8e9;
  if (options.ssdCacheDir && cap <= 0) throw new Error("SSD cache requires a nonzero RAM prompt cache");
  if (options.ssdCacheDir && !binding.stateCompatibility?.length)
    throw new Error("SSD cache requires the model binding's stateCompatibility identity");
  const resolvedKvScheme = resolveKvScheme({ override: options.kvQuant, turboQuant: options.turboQuant,
    quantizedKvStart: options.quantizedKvStart, config: context.kvConfig });
  const deps = supplied ?? await defaultDependencies();
  const runtime = binding.gateway.runtime;
  const stateCodecs = context.stateCodecs ?? deps.defaultStateCodecs;
  const cloneState = (caches: Cache[]) => deps.cloneState(caches, stateCodecs);
  const adapterNamespace = (adapters: string[]) => context.adapters.cacheNamespace(adapters);
  let checkpoints: SsdCacheStore | null = null;
  if (options.ssdCacheDir) {
    const tokenizer = readFileSync(`${context.model.config.modelDir}/tokenizer.json`);
    checkpoints = deps.createStore({ codecs: stateCodecs, dir: options.ssdCacheDir,
      maxBytes: options.ssdCacheMaxBytes ?? Infinity, modelId: context.modelId,
      configFingerprint: `${deps.configFingerprint(context.model.config)}-${resolvedKvScheme.cacheKey}-${Bun.hash(binding.stateCompatibility).toString(16)}`,
      tokenizerHash: Bun.hash(tokenizer).toString(16), verify: options.ssdCacheVerify,
      storage: { layout: runtime.value("MLX_BUN_SSD_LAYOUT") === "blocks" ? "blocks" : "whole",
        segmented: runtime.value("MLX_BUN_SSD_SEGMENTED") !== "0" },
    });
    checkpoints.scan();
  }
  const store = checkpoints;
  const cold: ColdTier | null = store ? {
    find: (tokens, ns) => { const hit = store.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
    findExact: (tokens, ns) => { const hit = store.findExact(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
    restoreObjectAsync: async handle => {
      const loaded = await store.restoreAsync(handle as SsdIndexEntry, { makeCache: () => [] });
      return loaded ? { ...loaded, retain() {} } : null;
    },
    restore: handle => {
      const loaded = binding.restore(store, handle as SsdIndexEntry);
      return loaded ? { ...loaded, retain() {} } : null;
    },
    ...(binding.restoreAsync && runtime.value("MLX_BUN_SSD_PREFETCH") !== "0" ? {
      restoreAsync: async (handle: unknown) => {
        const loaded = await binding.restoreAsync!(store, handle as SsdIndexEntry);
        return loaded ? { ...loaded, retain() {} } : null;
      },
    } : {}),
    store: (tokens, caches, ns, attachments) => store.hasDurablePrefix(tokens, ns) || store.store(tokens, caches, ns, attachments),
  } : null;
  const tiered = store && cold ? deps.createTieredPromptCache(cap, store, cold, cloneState,
    runtime.value("MLX_BUN_SSD_WRITEBEHIND") !== "0") : null;
  const promptCache = tiered ?? deps.createPromptCache(cap, null, null, cloneState);
  const spillQueue = tiered?.spillQueue;
  const durability = tiered?.durability;
  let stopDemotion: (() => void) | undefined;
  try {
    if (runtime.value("MLX_BUN_CACHE_RETENTION") === "cost-size") promptCache.retention = deps.costSizeRetention();
    const rawQueueGb = Number(runtime.value("MLX_BUN_SSD_SPILL_QUEUE_GB"));
    const queueBytes = (Number.isFinite(rawQueueGb) && rawQueueGb >= 0 ? rawQueueGb : 2) * 1024 ** 3;
    const checkpointPersistence = store && options.generationCheckpointTokens
      ? deps.createContinuationPersistence(store, { maxBytes: queueBytes }) : undefined;
    const continuationServices: Parameters<NonNullable<MlxGatewayBinding["configureContinuation"]>>[0] = {
      promptCache, checkpoints: store, checkpointPersistence,
      checkpointEveryTokens: options.generationCheckpointTokens,
      identity: { artifact: context.profile.artifact, implementation: context.profile.profile.execution,
        stateAbi: "legacy-cache-array-v1", codecs: stateCodecs.id },
      adapterNamespace, cloneState,
    };
    const workingSet = Math.min(deps.maxWorkingSet(), options.allocatorLimitBytes ?? Infinity);
    promptCache.pressure = { overBudget: () => Math.max(deps.activeMemory(),
      context.model.weightsBytes + Math.max(promptCache.totalBytes, spillQueue?.pendingBytes ?? 0)) > workingSet * 0.85 };
    const idleMs = (options.ssdDemoteIdleSec ?? (store ? 300 : 0)) * 1000;
    if (store && idleMs > 0) stopDemotion = deps.scheduleDemotion(() => promptCache.demoteIdle(idleMs), Math.max(30_000, idleMs / 4));
    const stats = (): DurabilitySnapshotStats => {
      const current = durability?.stats ?? { pendingSnapshots: 0, pendingSpills: spillQueue?.pendingCount ?? 0,
        pendingSpillBytes: spillQueue?.pendingBytes ?? 0, droppedSpills: spillQueue?.droppedCount ?? 0,
        failedSpills: spillQueue?.failedCount ?? 0 };
      const pending = checkpointPersistence?.stats;
      return { ...current, pendingSpills: current.pendingSpills + (pending?.pendingCount ?? 0),
        pendingSpillBytes: current.pendingSpillBytes + (pending?.pendingBytes ?? 0),
        droppedSpills: current.droppedSpills + (pending?.dropped ?? 0), failedSpills: current.failedSpills + (pending?.failed ?? 0) };
    };
    const flush = async (): Promise<DurabilityFlushResult> => {
      const started = performance.now();
      const errors: unknown[] = [];
      let checkpointResult: Awaited<ReturnType<ContinuationPersistence["flush"]>> | undefined;
      let result: DurabilityFlushResult | undefined;
      try { checkpointResult = await checkpointPersistence?.flush(); } catch (error) { errors.push(error); }
      try { result = await durability?.flush(); } catch (error) { errors.push(error); }
      // Also drain after a failed coordinator flush before releasing RAM views.
      try { await spillQueue?.drain(); } catch (error) { errors.push(error); }
      if (errors.length === 1) throw errors[0];
      if (errors.length) throw new AggregateError(errors, "cache flush failed");
      const current = stats();
      return { ...current, durable: (result?.durable ?? current.pendingSpills === 0) &&
        (checkpointResult?.durable ?? true) && current.pendingSpills === 0,
        flushedSnapshots: result?.flushedSnapshots ?? 0, missingSnapshots: result?.missingSnapshots ?? 0,
        elapsedMs: performance.now() - started };
    };
    let closing: Promise<DurabilityFlushResult> | undefined;
    return { promptCache, resolvedKvScheme, kvScheme: resolvedKvScheme.generationOptions,
      stateCodecs, checkpoints: store, continuationServices, adapterNamespace, stats, flush,
      /** Call only after all execution borrowers have drained. Clears RAM even
       * when persistence fails; durable:false is returned to the shutdown owner. */
      close(): Promise<DurabilityFlushResult> {
        return closing ??= (async () => {
          let result: DurabilityFlushResult | undefined; const errors: unknown[] = [];
          try { stopDemotion?.(); } catch (error) { errors.push(error); }
          stopDemotion = undefined;
          try { result = await flush(); } catch (error) { errors.push(error); }
          try { promptCache.clear(); } catch (error) { errors.push(error); }
          if (errors.length === 1) throw errors[0];
          if (errors.length) throw new AggregateError(errors, "cache cleanup failed");
          return result!;
        })();
      },
    };
  } catch (error) {
    const errors: unknown[] = [error];
    try { stopDemotion?.(); } catch (cleanup) { errors.push(cleanup); }
    try { promptCache.clear(); } catch (cleanup) { errors.push(cleanup); }
    if (errors.length > 1) throw new AggregateError(errors, "cache construction and cleanup failed");
    throw error;
  }
}
