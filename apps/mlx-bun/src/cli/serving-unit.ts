// One loaded model, served: its binding, caches, engine, and the routes bound
// to them. A unit is what the model host holds resident (residency/model-residency.ts);
// closing it drains its work, flushes its saved state durably, and releases the
// context by the ownership rule. Persistent services and the listener belong to
// the host that holds units (serve-host.ts), never to a unit.
import { releaseContext, requireChatTemplate, type ContextOwnership, type LoadedModelContext } from "../engine/model-host";
import type { ModelBinding } from "../engine/model-binding";
import type { KvBudget } from "../engine/kv-budget";
import type { UnitClosed, ResidentUnit } from "../residency/model-residency";
import { servingReserveBytes } from "../residency/resident-estimate";
import { fit } from "@mlx-bun/inference/execution/fit";
import type { DurabilityFlushResult, DurabilitySnapshotStats } from "@mlx-bun/inference/state";
import type { EventBus } from "@mlx-bun/app-core";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import { createEngineTelemetry } from "../engine/telemetry";
import type { TranscriptionInfo } from "../server/discovery-routes";
import type { ModelPromptBuilder } from "../server/prompt-contracts";
import type { ResponseHistory } from "../server/responses";
import type { DownloadStatus } from "@mlx-bun/hub/download";
import { resolveServingLimits, validatePagedServingOptions, type ServeOptions } from "./serve-options";
import type { RouteGroup } from "./serve-state";

/** The serving policy one host applies to every unit: serve's options minus the loader's and the CLI process's own. */
export type ContextHostOptions = Pick<ServeOptions, "port" | "capacity" | "contextLimit" | "defaultGeneratedTokens" |
  "kvBudgetBytes" | "memoryBudgetBytes" | "modelBudgetBytes" | "whisper" | "readOnly" | "cache" | "request"> & {
  /** The interface to bind; null binds Bun's default, every interface. */
  hostname: string | null;
};

/** What a unit serves besides its context. Nothing here is loaded or looked up. */
export interface ContextHost {
  /** Who releases the context; see ContextOwnership. */
  ownership: ContextOwnership;
  /** Replacement numerics for the context; default binds the built-in model classes. */
  binding?: ModelBinding;
  /** Replacement chat prompt construction; default renders the context's
   * template. With one, a context without a template serves; the builder then
   * returns `probeStableLen: false`. */
  buildPrompt?: ModelPromptBuilder;
  /** Descriptive artifact metadata for `/fit`, `/stats`, and hub GC protection;
   * each field defaults to main's unknown value (path: the config's model directory). */
  artifact?: { path?: string; sizeBytes?: number; expertsBytes?: number };
  /** An adapter id already mounted on the context, used when a request names none. */
  defaultAdapter?: string;
  /** `/stats`' `server.owner`; default "embedded". */
  owner?: string;
  /** Milliseconds the loader took to load the model, published with its `model.load` event; absent for a context this host did not load. */
  loadMs?: number;
}

/** What chat needs to describe the model it talks to. */
export interface ServedModelFacts {
  readonly modelId: string;
  readonly contextWindow: number;
  readonly vision: boolean;
  readonly audio: boolean;
  readonly thinking: boolean;
  readonly genDefaults: { readonly temperature: number | null; readonly topP: number | null; readonly topK: number | null };
}

/** Shared by every unit of one host. */
export interface UnitShared {
  readonly responses: ResponseHistory;
  /** The `events` bus: each unit's engine publishes its request timings and samples through it. */
  readonly events: Pick<EventBus, "publish">;
  readonly downloads: () => readonly DownloadStatus[];
  readonly artifactRoot?: string;
  readonly toolApprovalsFile?: string;
  readonly transcription: () => Promise<TranscriptionInfo | null>;
  /** One saved-state budget across every unit's store. */
  readonly ssdBudget?: KvBudget;
  /** The process allocator limit the host applied; bounds each unit's optional RAM caches. */
  readonly allocatorLimitBytes?: number;
  /** Each close's durability result, for the host's own final report. */
  readonly onClosed?: (result: DurabilityFlushResult) => void;
}

export interface ServingUnit extends ResidentUnit {
  readonly context: LoadedModelContext;
  readonly artifactPath: string;
  readonly facts: ServedModelFacts;
  /** Everything model-scoped: status, cache administration, adapters, adapter artifacts, and the wire routes. */
  readonly routes: RouteGroup;
  invalidateLibrary(): void;
  /** Stop background work (idle demotion) ahead of a drain. */
  stopBackground(): void;
  flush(): Promise<DurabilityFlushResult>;
  stats(): DurabilitySnapshotStats;
  /** The engine's execution gateway, for callers that run work under its lock. */
  readonly gateway: { acquireExecutionLease(signal?: AbortSignal): Promise<DisposableResource>; runExclusive<T>(fn: () => Promise<T>, trace?: undefined, signal?: AbortSignal): Promise<T> };
}

/** The context is released by `input.ownership` on close and on a failed
 * start alike; everything else the unit created is released either way. A
 * context without a chat template is refused unless `input.buildPrompt`
 * builds its prompts. */
export async function createServingUnit(context: LoadedModelContext, options: ContextHostOptions, input: ContextHost,
  shared: UnitShared): Promise<ServingUnit> {
  let cleanup: (() => void | Promise<unknown>) | undefined = () => releaseContext(context, input.ownership);
  try {
    const [{ modelServingBinding, createCacheServices, createAppEngine },
      { createCompletionRoutes }, { GeneratedTokenHistory }, { createStatusRoutes }, { createAdapterRoutes }, { createCacheRoutes },
      { createAdapterArtifactRoutes }] = await Promise.all([
      import("../engine"), import("../server/routes"), import("../server/generated-token-history"), import("../server/status-routes"),
      import("../server/adapter-routes"), import("../server/cache-routes"), import("../server/adapter-artifact-routes"),
    ]);
    // The default prompt path renders the context's template; a supplied builder replaces it.
    if (!input.buildPrompt) requireChatTemplate(context);
    const binding = await modelServingBinding(context, input.binding);
    const caches = await createCacheServices(context, binding, { ...options.cache,
      ...(shared.allocatorLimitBytes ? { allocatorLimitBytes: shared.allocatorLimitBytes } : {}),
      ...(shared.ssdBudget ? { ssdBudget: shared.ssdBudget } : {}) });
    // The persistence result of the final flush is the close's evidence.
    let durability: DurabilityFlushResult | undefined;
    const closeCaches = async () => {
      const result = durability = await caches.close();
      if (!result.durable) console.warn(`[server] cache flush incomplete: ${result.pendingSnapshots} snapshots, ${result.pendingSpills} spills, ${result.failedSpills} failed`);
    };
    cleanup = async () => { try { await closeCaches(); } finally { releaseContext(context, input.ownership); } };
    validatePagedServingOptions(options.request.pagedKv, caches.kvScheme, !!context.draft);
    binding.gateway.configureContinuation?.(caches.continuationServices);
    // createAppEngine takes ownership even when its constructor rejects.
    cleanup = undefined;
    const engine = await createAppEngine(context, { capacity: options.capacity, binding, ownership: input.ownership,
      gateway: { kvBudgetBytes: options.kvBudgetBytes,
        checkpoints: !!(options.cache.generationCheckpointTokens && caches.checkpoints),
        stateCodecs: caches.stateCodecs, kvScheme: caches.resolvedKvScheme,
        promptCache: caches.promptCache, adapterNamespace: caches.adapterNamespace },
      beforeModelDispose: closeCaches,
    });
    cleanup = () => engine.close();
    // The engine's events (request timings, batch and cache samples) come from one adapter around the completion engine.
    const telemetry = createEngineTelemetry({ events: shared.events, model: context.modelId, capacity: options.capacity,
      weightsBytes: context.model.weightsBytes, gateway: engine.gateway, promptCache: caches.promptCache });
    engine.completion = telemetry.observe(engine.completion);
    telemetry.sample();
    const tokenHistory = new GeneratedTokenHistory(context.tokenizer);
    if (caches.checkpoints) for (const tokens of caches.checkpoints.tokenPrefixes()) tokenHistory.remember(tokens);
    caches.promptCache.onPut = tokens => tokenHistory.remember(tokens);
    const admission = context.memoryPlan ?? fit(context.model.config, context.model.weightsBytes, 1,
      undefined, undefined, 0, options.memoryBudgetBytes, caches.resolvedKvScheme.fitOptions);
    const limits = resolveServingLimits(options, context.memoryPlan, admission);
    const completions = createCompletionRoutes(engine, { ...options.request, promptCache: caches.promptCache,
      kvScheme: caches.kvScheme, ...limits, tokenHistory, responseHistory: shared.responses, downloads: shared.downloads,
      transcription: shared.transcription,
      ...(input.buildPrompt ? { buildPrompt: input.buildPrompt } : {}),
      ...(input.defaultAdapter ? { defaultAdapter: input.defaultAdapter } : {}) });
    const status = createStatusRoutes({ ...(input.owner ? { owner: input.owner } : {}), context, caches, gateway: engine.gateway,
      diagnostics: () => binding.diagnostics(), responseStats: completions.responseStats,
      artifact: { expertsBytes: input.artifact?.expertsBytes ?? 0, sizeBytes: input.artifact?.sizeBytes ?? null },
      capacity: options.capacity, contextLimit: limits.contextLimit, startedAt: Date.now(),
      ssdCacheDir: options.cache.ssdCacheDir, memoryBudgetBytes: options.memoryBudgetBytes });
    const cacheAdmin = createCacheRoutes(caches);
    const adapters = createAdapterRoutes(context, engine.gateway);
    const adapterArtifacts = createAdapterArtifactRoutes(engine.gateway, { outputRoot: shared.artifactRoot });
    const routes: RouteGroup = { handle: async request => await status.handle(request) ?? await cacheAdmin.handle(request) ??
      await adapters.handle(request) ?? await adapterArtifacts.handle(request) ?? await completions.handle(request) };
    const artifactPath = input.artifact?.path ?? context.model.config.modelDir;
    // Weights plus the KV and working set of a typical context, plus the RAM prefix cache it holds now.
    const reserve = context.memoryPlan ? 0 : servingReserveBytes(context.model.config, context.model.weightsBytes,
      { expertsBytes: input.artifact?.expertsBytes, kvScheme: caches.resolvedKvScheme.fitOptions });
    const facts: ServedModelFacts = { modelId: context.modelId,
      contextWindow: limits.contextLimit ?? context.model.config.text.maxPositionEmbeddings,
      vision: !!(context.vision || context.loadVision), audio: !!(context.audio || context.loadAudio),
      thinking: context.template?.supportsThinking ?? false,
      genDefaults: {
        temperature: options.request.defaultTemperature ?? context.genDefaults.temperature ?? null,
        topP: options.request.defaultTopP ?? context.genDefaults.topP ?? null,
        topK: options.request.defaultTopK ?? context.genDefaults.topK ?? null,
      } };
    let closing: Promise<UnitClosed> | undefined;
    const unit: ServingUnit = {
      id: context.modelId, context, artifactPath, facts, routes, gateway: engine.gateway,
      // Saved state was found for this model: a request can resume from it.
      resumed: (caches.checkpoints?.entries ?? 0) > 0,
      operations: ["generate", ...(binding.discovery.embeddings ? ["embed" as const] : [])],
      bytes: () => context.memoryPlan ? context.memoryPlan.totalBytes : context.model.weightsBytes + reserve + caches.promptCache.totalBytes,
      memory: () => ({ weightsBytes: context.model.weightsBytes, kvBytes: engine.gateway.kvBytes.projected, prefixCacheBytes: caches.promptCache.totalBytes }),
      operationsFor: () => ({
        generate: async request => await completions.handle(request) ?? Response.json({ error: { message: "Not found" } }, { status: 404 }),
      }),
      pause: signal => engine.gateway.acquireExecutionLease(signal),
      invalidateLibrary: () => completions.invalidateLibrary(),
      stopBackground: () => { telemetry.stop(); caches.stopIdleDemotion(); },
      flush: () => caches.flush(),
      stats: () => caches.stats(),
      // Closes the engine (admission stops, work in flight drains), then flushes and clears the caches, then releases the context.
      close: () => closing ??= (async () => {
        const started = performance.now();
        telemetry.stop();
        await engine.close();
        return { flushed: durability?.durable ?? true, drainMs: performance.now() - started - (durability?.elapsedMs ?? 0),
          ...(durability ? { flushMs: durability.elapsedMs } : {}) };
      })().finally(() => { if (durability) shared.onClosed?.(durability); }),
    };
    return unit;
  } catch (error) {
    try { await cleanup?.(); }
    catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    throw error;
  }
}
