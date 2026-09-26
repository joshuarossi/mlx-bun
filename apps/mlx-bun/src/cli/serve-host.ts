// The model-scoped half of the serve composition: the native binding, load
// context, caches, engine, Whisper companion, model routes, chat backend, and
// the listener that serves them. It borrows persistent services from the
// AppState it is given and returns one close that releases everything it
// created in the app's order.
import { requireChatTemplate } from "../engine/model-host";
import { fit } from "@mlx-bun/hub/fit";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { TranscriptionService } from "../engine/transcription-service";
import { defaultWhisperModel } from "./model-selection";
import { resolveServingLimits, validatePagedServingOptions, type RunningApp, type ServeOptions } from "./serve-options";
import type { AppState } from "./serve-state";

export interface ModelHostHooks {
  /** Runs inside the listener's drain step, after cache demotion stops and
   * before chat sessions and HTTP responses drain: the app stops its
   * persistent producers (jobs, downloads) here while the engine is alive. */
  beforeDrain?(): void | Promise<void>;
}

export interface RunningModelHost {
  port: number;
  /** Drains the listener, releases the Whisper companion, engine, caches, and
   * model, then restores process-wide settings. Repeated calls are no-ops. */
  close(): Promise<void>;
}

/** Model composition owns resources until each explicit ownership transfer. */
export async function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks: ModelHostHooks = {}): Promise<RunningModelHost> {
  const [{ loadContext, modelServingBinding, createCacheServices, createAppEngine },
    { createCompletionRoutes }, { startServer }, { createPiBackend },
    { configureRuntime }, { GeneratedTokenHistory }, { createStatusRoutes }, { createManagementRoutes }, { createAdapterRoutes }, { createCacheRoutes },
    { TranscriptionService }, { createAudioRoutes }, { createAdapterArtifactRoutes }] = await Promise.all([
    import("../engine"), import("../server/routes"), import("../server/start"), import("../chat/pi-backend"),
    import("@mlx-bun/inference/runtime/config"), import("../server/generated-token-history"), import("../server/status-routes"),
    import("../server/management-routes"), import("../server/adapter-routes"), import("../server/cache-routes"),
    import("../engine/transcription-service"), import("../server/audio-routes"), import("../server/adapter-artifact-routes"),
  ]);
  // Keep main's KV numerical composition while graph compilation stays a layer concern.
  const restoreRuntime = configureRuntime({ MLX_BUN_NO_FUSED_SDPA: options.cache.kvQuant === "config" ? "0" : "1",
    ...(options.forceWire ? { MLX_BUN_FORCE_WIRE: "1" } : {}),
    ...(options.allowPrivateMedia ? { MLX_BUN_ALLOW_PRIVATE_MEDIA: "1" } : {}) });
  // Process-wide settings this host applies (offload routing, allocator limit,
  // runtime switches) are restored only after its engine has released the
  // model, on close and on startup failure alike, so a later host in the same
  // process starts from the state it found. Offload restore never unmaps.
  // The restore runs once: a repeated close must not undo a later host's settings.
  let restoreOffload: (() => void) | undefined, restoreAllocator: (() => void) | undefined, restored = false;
  const restoreProcess = () => {
    if (restored) return;
    restored = true;
    try { restoreOffload?.(); } finally { try { restoreAllocator?.(); } finally { restoreRuntime(); } }
  };
  let cleanup: (() => void | Promise<unknown>) | undefined;
  // The link is returned to the state once, like the process restore.
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  try {
    if (options.expertOffload) {
      // Main: dense models log and continue; MoE experts route through the
      // page-aligned file built on first use, activated before construction.
      if (model.expertsBytes === 0) console.warn("--expert-offload ignored: this model has no experts (dense)");
      else {
        const { ensureOffloadFile, activateExpertOffload } = await import("@mlx-bun/inference/artifacts");
        restoreOffload = activateExpertOffload(await ensureOffloadFile(model.path, message => console.log(`[serve] expert offload: ${message}`)));
      }
    }
    const draft = options.draft ?? {};
    const context = await loadContext(model.path, model.repoId, {
      ...(options.memoryBudgetBytes !== undefined ? { memoryBudgetBytes: options.memoryBudgetBytes } : {}),
      // Main's GLM resource plan inputs; other families ignore this block.
      glm: { batchSize: options.capacity, maxGenerationTokens: options.defaultGeneratedTokens ?? 128,
        ...(options.memoryBudgetBytes !== undefined ? { memoryBudgetBytes: options.memoryBudgetBytes } : {}),
        ...(options.contextTokens !== undefined ? { contextTokens: options.contextTokens } : {}),
        ...(options.mtp !== undefined ? { enableMtp: options.mtp } : {}) },
      // Main's gate: a draft model, or the model-free ngram kind, or mtp alone
      // (the host resolves the bundled <model>/mtp/ companion).
      ...(draft.modelDir || draft.kind === "ngram" || draft.kind === "mtp" ? {
        ...(draft.modelDir ? { draftModelDir: draft.modelDir } : {}),
        ...(draft.numTokens !== undefined ? { numDraftTokens: draft.numTokens } : {}),
        ...(draft.kind ? { draftKind: draft.kind } : {}),
        ...(draft.ngramMax !== undefined ? { ngramMax: draft.ngramMax } : {}),
        ...(draft.ngramMin !== undefined ? { ngramMin: draft.ngramMin } : {}) } : {}),
    });
    if (draft.modelDir) console.log(`[serve] draft: ${draft.modelDir.split("/").filter(Boolean).at(-1)}`);
    else if (draft.kind === "ngram") console.log("[serve] draft: ngram (prompt lookup)");
    cleanup = () => context.dispose();
    requireChatTemplate(context);
    // Main: a startup adapter mounts before any request and becomes the default
    // for requests without an adapter field (an explicit adapter, including
    // "none", still wins); a bad adapter fails startup and releases the model.
    let defaultAdapter: string | undefined;
    if (options.adapterDir) {
      const directory = options.adapterDir.replace(/\/+$/, "");
      try {
        const info = await context.adapters.mount(directory.split("/").pop()!, directory);
        defaultAdapter = info.id;
        console.log(`[serve] adapter ${info.id} mounted (${info.mountedLayers} layers) · default for requests (select others via \`adapter\`)`);
      } catch (error) {
        throw new Error(`adapter mount failed: ${error instanceof Error ? error.message : String(error)}`);
      }
    }
    const binding = await modelServingBinding(context);
    // Main: the plan's allocator reserve, else the explicit budget, caps the
    // allocator for the whole process and bounds optional cache residency.
    const allocatorLimitBytes = context.glmMemoryPlan?.lineItems?.allocatorReserveBytes ?? options.memoryBudgetBytes;
    if (allocatorLimitBytes) {
      const { setMemoryLimit } = await import("@mlx-bun/mlx/ffi");
      const previous = setMemoryLimit(allocatorLimitBytes);
      restoreAllocator = () => { setMemoryLimit(previous); };
    }
    const caches = await createCacheServices(context, binding, { ...options.cache,
      ...(allocatorLimitBytes ? { allocatorLimitBytes } : {}) });
    const closeCaches = async () => {
      const result = await caches.close();
      if (!result.durable) console.warn(`[server] cache flush incomplete: ${result.pendingSnapshots} snapshots, ${result.pendingSpills} spills, ${result.failedSpills} failed`);
    };
    cleanup = async () => { try { await closeCaches(); } finally { context.dispose(); } };
    validatePagedServingOptions(options.request.pagedKv, caches.kvScheme, !!context.draft);
    binding.gateway.configureContinuation?.(caches.continuationServices);
    // createAppEngine takes ownership even when its constructor rejects.
    cleanup = undefined;
    const engine = await createAppEngine(context, { capacity: options.capacity, binding,
      gateway: { kvBudgetBytes: options.kvBudgetBytes,
        checkpoints: !!(options.cache.generationCheckpointTokens && caches.checkpoints),
        stateCodecs: caches.stateCodecs, kvScheme: caches.resolvedKvScheme,
        promptCache: caches.promptCache, adapterNamespace: caches.adapterNamespace },
      beforeModelDispose: closeCaches,
    });
    cleanup = () => engine.close();
    const tokenHistory = new GeneratedTokenHistory(context.tokenizer);
    if (caches.checkpoints) for (const tokens of caches.checkpoints.tokenPrefixes()) tokenHistory.remember(tokens);
    caches.promptCache.onPut = tokens => tokenHistory.remember(tokens);
    const admission = context.glmMemoryPlan ?? fit(context.model.config, context.model.weightsBytes, 1,
      undefined, undefined, 0, options.memoryBudgetBytes, caches.resolvedKvScheme.fitOptions);
    const limits = resolveServingLimits(options, context.glmMemoryPlan, admission);
    // Main's speech-to-text companion: an explicit --whisper-model, else the
    // first downloaded Whisper checkpoint, resolved once on the first audio
    // request (a later download needs a restart, as in main). The weights load
    // per take and release per the --whisper-* policy; every take runs under
    // the gateway's exclusive lock so it never overlaps chat generation.
    let transcription: Promise<TranscriptionService | null> | undefined;
    const transcriptionService = () => transcription ??= (async () => {
      const whisper = options.whisper ?? {};
      const record = whisper.modelDir ? { path: whisper.modelDir, repoId: whisper.modelId ?? whisper.modelDir } : await defaultWhisperModel();
      if (!record) return null;
      return new TranscriptionService({ modelDir: record.path, modelId: record.repoId,
        idleUnloadSec: whisper.idleUnloadSec, resident: whisper.resident,
        exclusive: (fn, signal) => engine.gateway.runExclusive(fn, undefined, signal) });
    })();
    const closeApp = async () => {
      const errors: unknown[] = [];
      // A request admitted before shutdown may initialize the lazy companion while
      // responses drain. Close again here; the service joins/releases only once.
      try { await (await transcription)?.close(); } catch (error) { errors.push(error); }
      try { await engine.close(); } catch (error) { errors.push(error); }
      if (errors.length) throw new AggregateError(errors, "application cleanup failed");
    };
    cleanup = closeApp;
    const completions = createCompletionRoutes(engine, { ...options.request, promptCache: caches.promptCache,
      kvScheme: caches.kvScheme, ...limits, tokenHistory, responseHistory: state.responses, downloads: state.downloads.snapshot,
      transcription: async () => { const service = await transcriptionService(); return service ? { id: service.modelId, resident: service.resident } : null; },
      ...(defaultAdapter ? { defaultAdapter } : {}) });
    const audio = createAudioRoutes({ service: transcriptionService });
    const status = createStatusRoutes({ owner: "serve", context, caches, gateway: engine.gateway,
      diagnostics: () => binding.diagnostics(), responseStats: completions.responseStats, artifact: model,
      capacity: options.capacity, contextLimit: limits.contextLimit, startedAt: Date.now(),
      ssdCacheDir: options.cache.ssdCacheDir, memoryBudgetBytes: options.memoryBudgetBytes });
    const cacheAdmin = createCacheRoutes(caches);
    const adapters = createAdapterRoutes(context, engine.gateway);
    // Settings share this group with hub GC, which must protect the served snapshot.
    const management = createManagementRoutes({ invalidateLibrary: completions.invalidateLibrary,
      toolApprovalsFile: state.chatPaths?.toolApprovalsFile, servedModelPath: model.path });
    const adapterArtifacts = createAdapterArtifactRoutes(engine.gateway, { outputRoot: state.storagePaths.artifactRoot });
    const persistent = state.routes;
    const routes = { handle: async (request: Request) => await status.handle(request) ?? await cacheAdmin.handle(request) ?? await persistent.hub.handle(request) ?? await persistent.sessions.handle(request) ?? await adapters.handle(request) ?? await management.handle(request) ?? await audio.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.quantize.handle(request) ?? await persistent.dataset.handle(request) ?? await persistent.finetune.handle(request) ?? await adapterArtifacts.handle(request) ?? await persistent.publishing.handle(request) ?? await completions.handle(request) };
    let boundPort = options.port;
    const chat = createPiBackend({ port: () => boundPort, modelId: context.modelId,
      memory: state.memorySurface,
      paths: { ...state.chatPaths, sessionDir: state.sessionDir },
      contextWindow: limits.contextLimit ?? context.model.config.text.maxPositionEmbeddings,
      readOnly: options.readOnly, vision: !!(context.vision || context.loadVision),
      audio: !!(context.audio || context.loadAudio), thinking: context.template.supportsThinking,
      transcription: async () => (await transcriptionService()) !== null,
      genDefaults: {
        temperature: options.request.defaultTemperature ?? context.genDefaults.temperature ?? null,
        topP: options.request.defaultTopP ?? context.genDefaults.topP ?? null,
        topK: options.request.defaultTopK ?? context.genDefaults.topK ?? null,
      }, downloadsSnapshot: state.downloads.snapshot,
    });
    // Jobs and loopback clients reach this host from the first served request.
    detachLink = state.attach({ get port() { return boundPort; },
      acquireExecutionLease: signal => engine.gateway.acquireExecutionLease(signal),
      invalidateLibrary: completions.invalidateLibrary });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, chat,
      beforeDrain: async () => {
        const errors: unknown[] = [];
        try { caches.stopIdleDemotion(); } catch (error) { errors.push(error); }
        // Whisper closes with the persistent owners before drain: admission stops,
        // in-flight takes are joined, weights release ahead of the chat model.
        for (const result of await Promise.allSettled([hooks.beforeDrain?.(), (async () => { await (await transcription)?.close(); })()]))
          if (result.status === "rejected") errors.push(result.reason);
        if (errors.length === 1) throw errors[0];
        if (errors.length) throw new AggregateError(errors, "background shutdown failed");
      },
      closeEngine: closeApp }, {
      port: options.port, hostname: options.hostname,
    });
    boundPort = listener.server.port!;
    return { port: boundPort, async close() {
      try { await listener.close(); } finally { try { restoreProcess(); } finally { detach(); } }
    } };
  } catch (error) {
    try { await cleanup?.(); }
    catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    finally { try { restoreProcess(); } finally { detach(); } }
    throw error;
  }
}

/** Transcription-only composition (main's `serve <whisper checkpoint>`): the
 * audio routes plus `/v1`, `/v1/models`, `/health`, and `/stats` over the Whisper
 * checkpoint alone; no chat model, prompt cache, jobs, or web app. `--preload`
 * loads the weights before the listener binds; otherwise the first request
 * pages them in. Every take runs one at a time inside the service. */
export async function startTranscriptionHost(model: ModelRecord, options: ServeOptions): Promise<RunningApp> {
  const [{ TranscriptionService }, { createAudioRoutes }, { createTranscriptionServerRoutes }, { startServer }] = await Promise.all([
    import("../engine/transcription-service"), import("../server/audio-routes"), import("../server/transcription-server"), import("../server/start"),
  ]);
  const whisper = options.whisper ?? {};
  const service = new TranscriptionService({ modelDir: model.path, modelId: model.repoId,
    idleUnloadSec: whisper.idleUnloadSec, resident: whisper.resident });
  let cleanup: (() => void) | undefined = () => service.close();
  try {
    if (whisper.preload) await service.ensureLoaded();
    const audio = createAudioRoutes({ service: async () => service });
    const info = createTranscriptionServerRoutes(service, { startedAt: Date.now() });
    // startServer owns service cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({
      routes: { handle: async request => await audio.handle(request) ?? await info.handle(request) },
      web: () => null,
      // No chat model: a WebSocket session fails to start and its transport closes.
      chat: () => ({ async start() { throw new Error("transcription-only server has no chat model"); }, async handle() {}, dispose() {} }),
      // Whisper closes before drain: admission stops, in-flight takes are joined, weights release.
      beforeDrain: () => service.close(),
      closeEngine: async () => {},
    }, { port: options.port, hostname: options.hostname });
    return { port: listener.server.port!, close: listener.close,
      downloads: { active: [], start() { throw new Error("transcription-only server owns no downloads"); } } };
  } catch (error) { cleanup?.(); throw error; }
}
