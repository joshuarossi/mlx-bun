// The model-scoped half of the serve composition. startModelHost is the CLI's
// loader: runtime switches, expert offload, the model context and its startup
// adapter. startContextHost serves one loaded context: the binding, caches,
// engine, Whisper companion, model routes, chat backend, and the listener that
// serves them. Both borrow persistent services from the AppState they are
// given, and one close releases everything they created in the app's order.
import { releaseContext, requireChatTemplate, type ContextOwnership, type LoadedModelContext } from "../engine/model-host";
import type { ModelBinding } from "../engine/model-binding";
import { fit } from "@mlx-bun/inference/execution/fit";
import type { DurabilityFlushResult, DurabilitySnapshotStats } from "@mlx-bun/inference/state";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { TranscriptionService } from "../engine/transcription-service";
import type { ModelPromptBuilder } from "../server/prompt-contracts";
import { defaultWhisperModel } from "./model-selection";
import { resolveServingLimits, validatePagedServingOptions, type RunningApp, type ServeOptions } from "./serve-options";
import type { AppState, RouteGroup } from "./serve-state";

export interface ModelHostHooks {
  /** Runs inside the listener's drain step, after cache demotion stops and
   * before chat sessions and HTTP responses drain: the app stops its
   * persistent producers (jobs, downloads) here while the engine is alive. */
  beforeDrain?(): void | Promise<void>;
  /** Internal (worker mode, `cli/worker-entry.ts`): bind this Unix socket path
   * instead of the TCP `port`/`hostname`; the host then reports no port, and
   * the link it lends the state carries the socket for loopback clients. */
  unix?: string;
  /** Internal (worker mode): the worker's admin surface wraps the model routes
   * and answers ahead of them (health, lease, the drain gate). */
  routes?(model: RouteGroup): RouteGroup;
}

/** Worker mode: the listener is a Unix socket, so there is no port to report. */
export interface RunningWorkerHost {
  /** Drains the listener, releases the Whisper companion, engine, caches, and
   * an owned model, then restores process-wide settings. One drain however
   * often it is called; it resolves with the cache persistence result. */
  close(): Promise<DurabilityFlushResult>;
  /** Flush cache persistence while serving (`POST /admin/cache/flush`'s result). */
  flush(): Promise<DurabilityFlushResult>;
  /** Pending cache persistence counters, readable at any time. */
  stats(): DurabilitySnapshotStats;
}
export interface RunningModelHost extends RunningWorkerHost { port: number }

/** The serving policy one context host applies: serve's options minus the
 * loader's and the CLI process's own. */
export type ContextHostOptions = Pick<ServeOptions, "port" | "capacity" | "contextLimit" | "defaultGeneratedTokens" |
  "kvBudgetBytes" | "memoryBudgetBytes" | "whisper" | "readOnly" | "cache" | "request"> & {
  /** The interface to bind; null binds Bun's default, every interface. */
  hostname: string | null;
};

/** What the host serves besides the context. Nothing here is loaded or looked up. */
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
}

/** Internal: process-wide settings the loader applied, restored once with the
 * host's own after the model is released, on close and on startup failure. */
interface ContextHostHooks extends ModelHostHooks { restoreLoader?(): void }

/** Model composition owns resources until each explicit ownership transfer. */
export function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks?: ModelHostHooks & { unix?: undefined }): Promise<RunningModelHost>;
export function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks: ModelHostHooks & { unix: string }): Promise<RunningWorkerHost>;
export function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks?: ModelHostHooks): Promise<RunningModelHost | RunningWorkerHost>;
export async function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks: ModelHostHooks = {}): Promise<RunningModelHost | RunningWorkerHost> {
  const [{ loadContext }, { configureRuntime }] = await Promise.all([import("../engine"), import("@mlx-bun/inference/runtime/config")]);
  // Keep main's KV numerical composition while graph compilation stays a layer concern.
  const restoreRuntime = configureRuntime({ MLX_BUN_NO_FUSED_SDPA: options.cache.kvQuant === "config" ? "0" : "1",
    ...(options.forceWire ? { MLX_BUN_FORCE_WIRE: "1" } : {}),
    ...(options.allowPrivateMedia ? { MLX_BUN_ALLOW_PRIVATE_MEDIA: "1" } : {}) });
  // Offload routing and the runtime switches are restored only after the
  // engine has released the model, ahead of the context host's allocator limit.
  let restoreOffload: (() => void) | undefined;
  let restoreLoader: (() => void) | undefined = () => { try { restoreOffload?.(); } finally { restoreRuntime(); } };
  let cleanup: (() => void) | undefined;
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
    // The context host takes the model and the loader's process settings on entry, including a failed start.
    const restore = restoreLoader;
    cleanup = undefined; restoreLoader = undefined;
    return await startContextHost(state, context, options,
      { ownership: "owned", artifact: model, owner: "serve", ...(defaultAdapter ? { defaultAdapter } : {}) },
      { ...hooks, restoreLoader: restore });
  } catch (error) {
    try { cleanup?.(); }
    catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    finally { restoreLoader?.(); }
    throw error;
  }
}

/** Serve one loaded context with the app's routes, chat, and listener. The
 * context is released by `input.ownership` (createAppEngine's rule), on close
 * and on a failed start alike; everything else the host created is released
 * either way. It applies no runtime switches and activates no expert offload:
 * those belong to whoever loaded the context. A context without a chat
 * template is refused unless `input.buildPrompt` builds its prompts. */
export function startContextHost(state: AppState, context: LoadedModelContext, options: ContextHostOptions, input: ContextHost,
  hooks?: ContextHostHooks & { unix?: undefined }): Promise<RunningModelHost>;
export function startContextHost(state: AppState, context: LoadedModelContext, options: ContextHostOptions, input: ContextHost,
  hooks: ContextHostHooks): Promise<RunningModelHost | RunningWorkerHost>;
export async function startContextHost(state: AppState, context: LoadedModelContext, options: ContextHostOptions, input: ContextHost,
  hooks: ContextHostHooks = {}): Promise<RunningModelHost | RunningWorkerHost> {
  // Process-wide settings (the loader's, then this host's allocator limit) are
  // restored only after the engine has released the model, on close and on
  // startup failure alike, so a later host in the same process starts from
  // the state it found. The restore runs once: a repeated close must not undo
  // a later host's settings.
  let restoreAllocator: (() => void) | undefined, restored = false;
  const restoreProcess = () => {
    if (restored) return;
    restored = true;
    try { hooks.restoreLoader?.(); } finally { restoreAllocator?.(); }
  };
  let cleanup: (() => void | Promise<unknown>) | undefined = () => releaseContext(context, input.ownership);
  // The link is returned to the state once, like the process restore.
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  try {
    const [{ modelServingBinding, createCacheServices, createAppEngine },
      { createCompletionRoutes }, { startServer }, { createPiBackend },
      { GeneratedTokenHistory }, { createStatusRoutes }, { createManagementRoutes }, { createAdapterRoutes }, { createCacheRoutes },
      { TranscriptionService }, { createAudioRoutes }, { createAdapterArtifactRoutes }] = await Promise.all([
      import("../engine"), import("../server/routes"), import("../server/start"), import("../chat/pi-backend"),
      import("../server/generated-token-history"), import("../server/status-routes"),
      import("../server/management-routes"), import("../server/adapter-routes"), import("../server/cache-routes"),
      import("../engine/transcription-service"), import("../server/audio-routes"), import("../server/adapter-artifact-routes"),
    ]);
    // The default prompt path renders the context's template; a supplied builder replaces it.
    if (!input.buildPrompt) requireChatTemplate(context);
    const binding = await modelServingBinding(context, input.binding);
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
      ...(input.buildPrompt ? { buildPrompt: input.buildPrompt } : {}),
      ...(input.defaultAdapter ? { defaultAdapter: input.defaultAdapter } : {}) });
    const audio = createAudioRoutes({ service: transcriptionService });
    const status = createStatusRoutes({ ...(input.owner ? { owner: input.owner } : {}), context, caches, gateway: engine.gateway,
      diagnostics: () => binding.diagnostics(), responseStats: completions.responseStats,
      artifact: { expertsBytes: input.artifact?.expertsBytes ?? 0, sizeBytes: input.artifact?.sizeBytes ?? null },
      capacity: options.capacity, contextLimit: limits.contextLimit, startedAt: Date.now(),
      ssdCacheDir: options.cache.ssdCacheDir, memoryBudgetBytes: options.memoryBudgetBytes });
    const cacheAdmin = createCacheRoutes(caches);
    const adapters = createAdapterRoutes(context, engine.gateway);
    // Settings share this group with hub GC, which must protect the served snapshot.
    const management = createManagementRoutes({ invalidateLibrary: completions.invalidateLibrary,
      toolApprovalsFile: state.chatPaths?.toolApprovalsFile, servedModelPath: input.artifact?.path ?? context.model.config.modelDir });
    const adapterArtifacts = createAdapterArtifactRoutes(engine.gateway, { outputRoot: state.storagePaths.artifactRoot });
    const persistent = state.routes;
    const modelRoutes = { handle: async (request: Request) => await status.handle(request) ?? await cacheAdmin.handle(request) ?? await persistent.hub.handle(request) ?? await persistent.sessions.handle(request) ?? await adapters.handle(request) ?? await management.handle(request) ?? await audio.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.quantize.handle(request) ?? await persistent.dataset.handle(request) ?? await persistent.finetune.handle(request) ?? await adapterArtifacts.handle(request) ?? await persistent.publishing.handle(request) ?? await completions.handle(request) };
    const routes = hooks.routes?.(modelRoutes) ?? modelRoutes;
    // A Unix listener has no port: the requested one stands in for Pi's TCP
    // loopback, and for the link's URL placeholder (its clients use the socket).
    let boundPort = options.port;
    const chat = createPiBackend({ port: () => boundPort, modelId: context.modelId,
      memory: state.memorySurface,
      paths: { ...state.chatPaths, sessionDir: state.sessionDir },
      contextWindow: limits.contextLimit ?? context.model.config.text.maxPositionEmbeddings,
      readOnly: options.readOnly, vision: !!(context.vision || context.loadVision),
      audio: !!(context.audio || context.loadAudio), thinking: context.template?.supportsThinking ?? false,
      transcription: async () => (await transcriptionService()) !== null,
      genDefaults: {
        temperature: options.request.defaultTemperature ?? context.genDefaults.temperature ?? null,
        topP: options.request.defaultTopP ?? context.genDefaults.topP ?? null,
        topK: options.request.defaultTopK ?? context.genDefaults.topK ?? null,
      }, downloadsSnapshot: state.downloads.snapshot,
    });
    // Jobs and loopback clients reach this host from the first served request.
    detachLink = state.attach({ get port() { return boundPort; }, ...(hooks.unix ? { unix: hooks.unix } : {}),
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
      closeEngine: closeApp }, hooks.unix ? { unix: hooks.unix } : { port: options.port, hostname: options.hostname });
    if (listener.server.port !== undefined) boundPort = listener.server.port;
    let closing: Promise<DurabilityFlushResult> | undefined;
    const close = () => closing ??= (async () => {
      try { await listener.close(); } finally { try { restoreProcess(); } finally { detach(); } }
      return durability!;
    })();
    const host = { close, flush: () => caches.flush(), stats: () => caches.stats() };
    return hooks.unix ? host : { port: boundPort, ...host };
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
 * pages them in. Every take runs one at a time inside the service. The
 * internal hooks are the model host's: a Unix socket instead of TCP, a route
 * wrapper, and a step ahead of the Whisper close (the worker app form). */
export async function startTranscriptionHost(model: ModelRecord, options: ServeOptions,
  hooks: Pick<ModelHostHooks, "unix" | "routes" | "beforeDrain"> = {}): Promise<RunningApp> {
  const [{ TranscriptionService }, { createAudioRoutes }, { createTranscriptionServerRoutes }, { startServer }] = await Promise.all([
    import("../engine/transcription-service"), import("../server/audio-routes"), import("../server/transcription-server"), import("../server/start"),
  ]);
  const whisper = options.whisper ?? {};
  const service = new TranscriptionService({ modelDir: model.path, modelId: model.repoId,
    idleUnloadSec: whisper.idleUnloadSec, resident: whisper.resident });
  let cleanup: (() => Promise<void>) | undefined = async () => { await service.close(); };
  try {
    if (whisper.preload) await service.ensureLoaded();
    const audio = createAudioRoutes({ service: async () => service });
    const info = createTranscriptionServerRoutes(service, { startedAt: Date.now() });
    // startServer owns service cleanup on entry, including a bind failure.
    cleanup = undefined;
    const routes: RouteGroup = { handle: async request => await audio.handle(request) ?? await info.handle(request) };
    const listener = await startServer({
      routes: hooks.routes?.(routes) ?? routes,
      web: () => null,
      // No chat model: a WebSocket session fails to start and its transport closes.
      chat: () => ({ async start() { throw new Error("transcription-only server has no chat model"); }, async handle() {}, dispose() {} }),
      // Whisper closes before drain: admission stops, in-flight takes are joined, weights release.
      beforeDrain: async () => { try { await hooks.beforeDrain?.(); } finally { await service.close(); } },
      closeEngine: async () => {},
    }, hooks.unix ? { unix: hooks.unix } : { port: options.port, hostname: options.hostname });
    return { ...(hooks.unix ? {} : { port: listener.server.port! }), close: listener.close,
      downloads: { active: [], start() { throw new Error("transcription-only server owns no downloads"); } } };
  } catch (error) { await cleanup?.(); throw error; }
}
