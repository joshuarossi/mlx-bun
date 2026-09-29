// The model-scoped half of the serve composition. startModelHost is the CLI's
// loader: runtime switches, expert offload, the model context and its startup
// adapter. startContextHost serves one or more models from the model host
// (engine/model-residency.ts): each loaded model is a serving unit (binding,
// caches, engine, routes: serving-unit.ts), the Whisper companion, the model
// router (server/model-routes.ts), the chat backend, and the listener that
// serves them. Both borrow persistent services from the AppState they are
// given, and one close releases everything they created in the app's order.
import { totalmem } from "node:os";
import { requireChatTemplate, releaseContext, type LoadedModelContext } from "../engine/model-host";
import { createKvBudget, type KvBudget } from "../engine/kv-budget";
import { createResidencyHost, type ResidencyEntry, type ResidencyHost, type ResidencySource } from "../engine/model-residency";
import { servingReserveBytes } from "../engine/resident-estimate";
import type { DurabilityFlushResult, DurabilitySnapshotStats } from "@mlx-bun/inference/state";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import pkgJson from "../../package.json" with { type: "json" };
import { loadInstalledModules } from "./module-host";
import { type RunningApp, type ServeOptions } from "./serve-options";
import type { AppState, RouteGroup } from "./serve-state";
import { createServingUnit, type ContextHost, type ContextHostOptions, type ServedModelFacts, type ServingUnit, type UnitShared } from "./serving-unit";
import { ServeRefused } from "../server/hub-routes";
import { openRegistry } from "../storage/paths";

export type { ContextHost, ContextHostOptions } from "./serving-unit";
export { resolveServingLimits, validatePagedServingOptions } from "./serve-options";

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
  /** Drains the listener, releases the Whisper companion and every resident
   * model (draining, flushing its saved state, releasing it), and restores
   * process-wide settings. One drain however often it is called; it resolves
   * with the cache persistence result of the models resident at close. */
  close(): Promise<DurabilityFlushResult>;
  /** Flush cache persistence of every resident model while serving (`POST /admin/cache/flush`'s result). */
  flush(): Promise<DurabilityFlushResult>;
  /** Pending cache persistence counters, readable at any time. */
  stats(): DurabilitySnapshotStats;
}
export interface RunningModelHost extends RunningWorkerHost { port: number }

/** The other local models a host may load beside (or instead of) its first, by exact id. */
export interface ModelSource {
  /** The local models this host can serve, as the registry knows them; never scans or downloads. */
  records(): readonly ModelRecord[] | Promise<readonly ModelRecord[]>;
  /** Load one model for serving; the host takes ownership of the context. */
  load(record: ModelRecord): Promise<{ context: LoadedModelContext; defaultAdapter?: string; loadMs: number }>;
  /** The model the host starts with, when it is not one `records` lists (a path given to `--model`). */
  startup?: ModelRecord;
}

/** Fraction of the GPU's recommended working set all resident models may use together by default. */
const DEFAULT_BUDGET_FRACTION = 0.7;

/** Internal: process-wide settings the loader applied, restored once with the
 * host's own after the model is released, on close and on startup failure. */
interface ContextHostHooks extends ModelHostHooks { restoreLoader?(): void }

const idle = (): DurabilitySnapshotStats => ({ pendingSnapshots: 0, pendingSpills: 0, pendingSpillBytes: 0, droppedSpills: 0, failedSpills: 0 });
function mergeStats(all: readonly DurabilitySnapshotStats[]): DurabilitySnapshotStats {
  return all.reduce((sum, item) => ({ pendingSnapshots: sum.pendingSnapshots + item.pendingSnapshots, pendingSpills: sum.pendingSpills + item.pendingSpills,
    pendingSpillBytes: sum.pendingSpillBytes + item.pendingSpillBytes, droppedSpills: sum.droppedSpills + item.droppedSpills,
    failedSpills: sum.failedSpills + item.failedSpills }), idle());
}
function mergeDurability(all: readonly DurabilityFlushResult[]): DurabilityFlushResult {
  return { ...mergeStats(all), durable: all.every(item => item.durable), flushedSnapshots: all.reduce((n, item) => n + item.flushedSnapshots, 0),
    missingSnapshots: all.reduce((n, item) => n + item.missingSnapshots, 0), elapsedMs: all.reduce((n, item) => Math.max(n, item.elapsedMs), 0) };
}

/** Model composition owns resources until each explicit ownership transfer. */
export function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks?: ModelHostHooks & { unix?: undefined }): Promise<RunningModelHost>;
export function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks: ModelHostHooks & { unix: string }): Promise<RunningWorkerHost>;
export function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks?: ModelHostHooks): Promise<RunningModelHost | RunningWorkerHost>;
export async function startModelHost(state: AppState, model: ModelRecord, options: ServeOptions, hooks: ModelHostHooks = {}): Promise<RunningModelHost | RunningWorkerHost> {
  const [{ loadContext }, { configureRuntime }] = await Promise.all([import("../engine"), import("@mlx-bun/inference/runtime/config")]);
  // Keep main's KV numerical composition while graph compilation stays a layer concern.
  const restoreRuntime = configureRuntime({ MLX_BUN_NO_FUSED_SDPA: (options.fusedSdpa ?? options.cache.kvQuant === "config") ? "0" : "1",
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
    /** One model, loaded for serving. `--draft-*` and `--adapter` belong to the model named at startup; the others load plain. */
    const loadServed = async (record: ModelRecord): Promise<{ context: LoadedModelContext; defaultAdapter?: string; loadMs: number }> => {
      const startup = record.repoId === model.repoId;
      const draft = startup ? options.draft ?? {} : {};
      const loadStarted = performance.now();
      const context = await loadContext(record.path, record.repoId, {
        ...(options.memoryBudgetBytes !== undefined ? { memoryBudgetBytes: options.memoryBudgetBytes } : {}),
        // Resource plan inputs for runtimes that plan memory up front; other models ignore this block.
        runtime: { batchSize: options.capacity, maxGenerationTokens: options.defaultGeneratedTokens ?? 128,
          ...(options.memoryBudgetBytes !== undefined ? { memoryBudgetBytes: options.memoryBudgetBytes } : {}),
          ...(options.contextTokens !== undefined ? { contextTokens: options.contextTokens } : {}),
          ...(options.mtp !== undefined ? { nativeDraft: options.mtp } : {}) },
        // Main's gate: a draft model, or the model-free ngram kind, or mtp alone
        // (the host resolves the bundled <model>/mtp/ companion).
        ...(draft.modelDir || draft.kind === "ngram" || draft.kind === "mtp" ? {
          ...(draft.modelDir ? { draftModelDir: draft.modelDir } : {}),
          ...(draft.numTokens !== undefined ? { numDraftTokens: draft.numTokens } : {}),
          ...(draft.kind ? { draftKind: draft.kind } : {}),
          ...(draft.ngramMax !== undefined ? { ngramMax: draft.ngramMax } : {}),
          ...(draft.ngramMin !== undefined ? { ngramMin: draft.ngramMin } : {}) } : {}),
      });
      try {
        if (draft.modelDir) console.log(`[serve] draft: ${draft.modelDir.split("/").filter(Boolean).at(-1)}`);
        else if (draft.kind === "ngram") console.log("[serve] draft: ngram (prompt lookup)");
        requireChatTemplate(context);
        // Main: a startup adapter mounts before any request and becomes the default
        // for requests without an adapter field (an explicit adapter, including
        // "none", still wins); a bad adapter fails startup and releases the model.
        if (startup && options.adapterDir) {
          const directory = options.adapterDir.replace(/\/+$/, "");
          try {
            const info = await context.adapters.mount(directory.split("/").pop()!, directory);
            console.log(`[serve] adapter ${info.id} mounted (${info.mountedLayers} layers) · default for requests (select others via \`adapter\`)`);
            return { context, defaultAdapter: info.id, loadMs: performance.now() - loadStarted };
          } catch (error) {
            throw new Error(`adapter mount failed: ${error instanceof Error ? error.message : String(error)}`);
          }
        }
        return { context, loadMs: performance.now() - loadStarted };
      } catch (error) {
        try { context.dispose(); } catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
        throw error;
      }
    };
    const first = await loadServed(model);
    cleanup = () => first.context.dispose();
    // The context host takes the model and the loader's process settings on entry, including a failed start.
    const restore = restoreLoader;
    cleanup = undefined; restoreLoader = undefined;
    // Expert offload routes the process's loads through one file: that model is all this process serves.
    const models: ModelSource | undefined = options.expertOffload ? undefined : { startup: model, load: loadServed, records: localRecords };
    return await startContextHost(state, first.context, options,
      { ownership: "owned", artifact: model, owner: "serve", loadMs: first.loadMs, ...(first.defaultAdapter ? { defaultAdapter: first.defaultAdapter } : {}),
        ...(models ? { models } : {}) },
      { ...hooks, restoreLoader: restore });
  } catch (error) {
    try { cleanup?.(); }
    catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    finally { restoreLoader?.(); }
    throw error;
  }
}

/** The models `/v1/models` may list and the host may load: supported generation checkpoints the registry knows. */
async function localRecords(): Promise<readonly ModelRecord[]> {
  const { declaredOperations } = await import("@mlx-bun/app-services");
  const registry = openRegistry();
  try {
    // A fresh machine's index is empty until its first scan.
    if (registry.list().length === 0) await registry.scan();
    return registry.listCanonical().filter(record => declaredOperations(record.modelType).includes("generate"));
  } finally { registry.close(); }
}

/** Serve one or more models with the app's routes, chat, and listener. The
 * first context is resident from the start; it is released by
 * `input.ownership`, on close and on a failed start alike. Without
 * `input.models` it is the only model and is never evicted; with it, any other
 * local model loads when a request names it and fits the memory budget (the
 * least recently used unpinned, unleased model is drained, its saved state
 * flushed, and released first), and the first can be evicted and reloaded like
 * the rest. Everything else the host created is released either way. It
 * applies no runtime switches and activates no expert offload: those belong to
 * whoever loaded the context. A context without a chat template is refused
 * unless `input.buildPrompt` builds its prompts. */
export function startContextHost(state: AppState, context: LoadedModelContext, options: ContextHostOptions, input: ContextHost & { models?: ModelSource },
  hooks?: ContextHostHooks & { unix?: undefined }): Promise<RunningModelHost>;
export function startContextHost(state: AppState, context: LoadedModelContext, options: ContextHostOptions, input: ContextHost & { models?: ModelSource },
  hooks: ContextHostHooks): Promise<RunningModelHost | RunningWorkerHost>;
export async function startContextHost(state: AppState, context: LoadedModelContext, options: ContextHostOptions, input: ContextHost & { models?: ModelSource },
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
    const [{ startServer }, { createPiBackend }, { createManagementRoutes }, { createModelRoutes },
      { createHostServices, createModuleRoutes, declaredOperations }] = await Promise.all([
      import("../server/start"), import("../chat/pi-backend"), import("../server/management-routes"), import("../server/model-routes"),
      import("@mlx-bun/app-services"),
    ]);
    // Main: the plan's allocator limit, else the explicit budget, caps the
    // allocator for the whole process and bounds optional cache residency.
    const allocatorLimitBytes = context.memoryPlan?.allocatorLimitBytes ?? options.memoryBudgetBytes;
    if (allocatorLimitBytes) {
      const { setMemoryLimit } = await import("@mlx-bun/mlx/ffi");
      const previous = setMemoryLimit(allocatorLimitBytes);
      restoreAllocator = () => { setMemoryLimit(previous); };
    }
    // One saved-state budget over every model's store in this process.
    const ssdBudget: KvBudget | undefined = options.cache.ssdCacheDir
      ? createKvBudget(options.cache.ssdCacheDir, options.cache.ssdCacheMaxBytes ?? Infinity) : undefined;
    let residency!: ResidencyHost<ServingUnit>;
    // Each closing model's saved-state result; the ones at host close are the close's evidence.
    const finalResults: DurabilityFlushResult[] = [];
    let closingHost = false;
    // Main's speech-to-text companion, served by the transcription module: an
    // explicit --whisper-model, else the first downloaded Whisper checkpoint,
    // resolved once on the first audio request (a later download needs a
    // restart, as in main). The weights load per take and release per the
    // --whisper-* policy; every decode runs with every resident model paused so
    // it never overlaps generation, and a load first makes room in the budget.
    const moduleHost = createHostServices({ whisper: options.whisper, events: state.events,
      exclusive: async (fn, signal) => { const pause = await residency.pauseAll(signal); try { return await fn(); } finally { pause.dispose(); } },
      admit: bytes => residency.makeRoom(bytes) });
    const whisperInfo = async () => {
      const id = await moduleHost.whisper.defaultFor("transcribe");
      return id === undefined ? null : { id, resident: moduleHost.whisper.stats(id).resident };
    };
    const shared: UnitShared = { responses: state.responses, events: state.events, downloads: state.downloads.snapshot, transcription: whisperInfo,
      ...(state.storagePaths.artifactRoot ? { artifactRoot: state.storagePaths.artifactRoot } : {}),
      ...(ssdBudget ? { ssdBudget } : {}), ...(allocatorLimitBytes ? { allocatorLimitBytes } : {}),
      onClosed: result => { if (closingHost) finalResults.push(result); } };
    // The unit takes the context and releases it (by ownership) on close and on its own failed start.
    cleanup = undefined;
    const first = await createServingUnit(context, options, input, shared);
    cleanup = () => first.close({ flush: true });
    const facts = new Map<string, ServedModelFacts>([[first.id, first.facts]]);
    const rememberFacts = (unit: ServingUnit) => { facts.set(unit.id, unit.facts); return unit; };
    // The other local models, as the registry knows them: refreshed after a download or job, and at most every few seconds on a miss.
    let index: { at: number; byId: Map<string, ModelRecord> } | undefined;
    const known = async (id: string): Promise<ModelRecord | undefined> => {
      if (!input.models) return undefined;
      if (id === first.id && input.models.startup) return input.models.startup;
      for (const fresh of [false, true]) {
        if (!index || fresh && Date.now() - index.at > 5_000) {
          index = { at: Date.now(), byId: new Map((await input.models.records()).map(record => [record.repoId, record])) };
        }
        const record = index.byId.get(id);
        if (record) return record;
      }
      return undefined;
    };
    const machine = input.models ? (await import("@mlx-bun/inference/execution/fit")).thisMachine() : undefined;
    const memory = input.models ? await import("@mlx-bun/mlx/ffi") : undefined;
    // Every resident model together may use this much: by default a share of what the GPU can wire.
    const budgetBytes = !input.models ? Infinity
      : options.modelBudgetBytes ?? Math.floor((memory!.maxRecommendedWorkingSetSize() || totalmem() * 0.75) * DEFAULT_BUDGET_FRACTION);
    /** What loading `record` would take: its weights and a typical context's KV and working set; a runtime that plans its own memory is served alone. */
    const estimate = async (record: ModelRecord): Promise<number> => {
      const [{ loadModelConfig }, { resolveModelProfile }, { plansMemory }, { resolveKvScheme }] = await Promise.all([
        import("@mlx-bun/inference/artifacts/config"), import("@mlx-bun/inference/models/profile"), import("@mlx-bun/inference/models"),
        import("@mlx-bun/inference/state/kv-scheme")]);
      const config = await loadModelConfig(record.path);
      if (plansMemory(resolveModelProfile(config))) return budgetBytes;
      const kvScheme = resolveKvScheme({ override: options.cache.kvQuant, turboQuant: options.cache.turboQuant,
        quantizedKvStart: options.cache.quantizedKvStart, config: config.kvQuant }).fitOptions;
      return record.sizeBytes + servingReserveBytes(config, record.sizeBytes, { expertsBytes: record.expertsBytes, kvScheme, ...(machine ? { machine } : {}) });
    };
    const entryOf = (unit: ServingUnit): ResidencyEntry => ({ id: unit.id, bytes: unit.bytes(), operations: unit.operations });
    const source: ResidencySource<ServingUnit> = {
      async resolve(id) {
        const record = await known(id);
        if (!record) return undefined;
        return { id: record.repoId, bytes: await estimate(record), operations: declaredOperations(record.modelType) };
      },
      async load(entry) {
        const record = (await known(entry.id))!;
        const loaded = await input.models!.load(record);
        // A planned runtime's own allocator limit applies while it is resident.
        const limit = loaded.context.memoryPlan?.allocatorLimitBytes;
        const previous = limit ? (await import("@mlx-bun/mlx/ffi")).setMemoryLimit(limit) : undefined;
        const unit = await createServingUnit(loaded.context, options,
          { ownership: "owned", artifact: record, ...(input.owner ? { owner: input.owner } : {}), ...(loaded.defaultAdapter ? { defaultAdapter: loaded.defaultAdapter } : {}) },
          { ...shared, ...(limit ? { allocatorLimitBytes: limit } : {}) });
        if (previous === undefined) return rememberFacts(unit);
        const close = unit.close.bind(unit);
        return rememberFacts(Object.assign(unit, { close: async (options: { readonly flush: boolean }) => {
          try { return await close(options); } finally { (await import("@mlx-bun/mlx/ffi")).setMemoryLimit(previous); }
        } }));
      },
    };
    let current = first.id;
    residency = createResidencyHost<ServingUnit>({ source, budgetBytes, events: state.events,
      ...(memory ? { measured: () => memory.activeMemory() } : {}),
      external: () => moduleHost.whisper.resident().reduce((sum, model) => sum + model.bytes, 0),
      defaultFor: async operation => operation === "generate" ? current : undefined,
      log: line => console.log(line) });
    // A context the caller supplied cannot be reloaded, so it is never evicted.
    residency.adopt(entryOf(first), first, { pin: !input.models, ...(input.loadMs !== undefined ? { loadMs: input.loadMs } : {}) });
    let modules: Awaited<ReturnType<typeof loadInstalledModules>> | undefined;
    // The modules stop first (admission stops, takes in flight are joined), then the models release.
    const closeModules = async () => {
      const errors: unknown[] = [];
      try { await modules?.stop(); } catch (error) { errors.push(error); }
      try { await moduleHost.whisper.close(); } catch (error) { errors.push(error); }
      if (errors.length) throw new AggregateError(errors, "module cleanup failed");
    };
    const closeApp = async () => {
      const errors: unknown[] = [];
      // A request admitted before shutdown may lease the companion while
      // responses drain. Close again here; each owner joins/releases only once.
      try { await closeModules(); } catch (error) { errors.push(error); }
      closingHost = true;
      try { await residency.close(); } catch (error) { errors.push(error); }
      if (errors.length) throw new AggregateError(errors, "application cleanup failed");
    };
    cleanup = closeApp;
    modules = await loadInstalledModules(moduleHost);
    const models = createModelRoutes({ host: residency, current: () => current, serves: async id => id === first.id || !!await known(id) });
    const moduleRoutes = createModuleRoutes(modules.routes);
    const residentUnits = () => residency.resident().flatMap(model => { const unit = residency.peek(model.id); return unit ? [unit] : []; });
    const invalidateLibrary = () => { index = undefined; for (const unit of residentUnits()) unit.invalidateLibrary(); };
    // Settings share this group with hub GC, which must protect every resident snapshot.
    const management = createManagementRoutes({ invalidateLibrary,
      toolApprovalsFile: state.chatPaths?.toolApprovalsFile, servedModelPaths: () => residentUnits().map(unit => unit.artifactPath) });
    const persistent = state.routes;
    const modelRoutes = { handle: async (request: Request) => await models.handle(request) ?? await persistent.hub.handle(request) ?? await persistent.sessions.handle(request) ?? await management.handle(request) ?? await moduleRoutes.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.quantize.handle(request) ?? await persistent.appModules.handle(request) ?? await persistent.finetune.handle(request) ?? await persistent.publishing.handle(request) };
    const routes = hooks.routes?.(modelRoutes) ?? modelRoutes;
    // A Unix listener has no port: the requested one stands in for Pi's TCP
    // loopback, and for the link's URL placeholder (its clients use the socket).
    let boundPort = options.port;
    // Chat describes the current model when a session connects; its `local` model id is whatever the host serves then.
    const chat = createPiBackend({ port: () => boundPort, modelId: first.id, model: () => facts.get(current) ?? first.facts,
      memory: state.memorySurface,
      paths: { ...state.chatPaths, sessionDir: state.sessionDir },
      readOnly: options.readOnly,
      transcription: async () => (await moduleHost.whisper.defaultFor("transcribe")) !== undefined,
      downloadsSnapshot: state.downloads.snapshot,
    });
    // Jobs and loopback clients reach this host from the first served request. A job pauses every resident model.
    // Modules leasing the served model reach it as the current one: the id and weights follow a switch.
    detachLink = state.attach({ get model() { return { id: current, bytes: (residency.peek(current) ?? first).context.model.weightsBytes }; },
      get port() { return boundPort; }, ...(hooks.unix ? { unix: hooks.unix } : {}),
      acquireExecutionLease: signal => residency.pauseAll(signal),
      invalidateLibrary,
      ...(input.models ? { async serve(id: string, signal: AbortSignal) {
        if (id !== first.id && !await known(id)) throw new ServeRefused(404, `${id} is not a local model; download it first`);
        try { (await residency.acquire(id, { signal, need: ["generate"] })).release(); }
        catch (error) { throw new ServeRefused(error instanceof Error && "code" in error && error.code === "load-failed" ? 502 : 400, error instanceof Error ? error.message : String(error)); }
        current = id;
        return { model: id };
      } } : {}) });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, chat,
      beforeDrain: async () => {
        const errors: unknown[] = [];
        try { for (const unit of residentUnits()) unit.stopBackground(); } catch (error) { errors.push(error); }
        // Whisper closes with the persistent owners before drain: admission stops,
        // in-flight takes are joined, weights release ahead of the chat models.
        for (const result of await Promise.allSettled([hooks.beforeDrain?.(), closeModules()]))
          if (result.status === "rejected") errors.push(result.reason);
        if (errors.length === 1) throw errors[0];
        if (errors.length) throw new AggregateError(errors, "background shutdown failed");
      },
      closeEngine: closeApp }, hooks.unix ? { unix: hooks.unix } : { port: options.port, hostname: options.hostname });
    if (listener.server.port !== undefined) boundPort = listener.server.port;
    let closing: Promise<DurabilityFlushResult> | undefined;
    const close = () => closing ??= (async () => {
      try { await listener.close(); } finally { try { restoreProcess(); } finally { detach(); } }
      return mergeDurability(finalResults);
    })();
    const host = { close, flush: async () => mergeDurability(await Promise.all(residentUnits().map(unit => unit.flush()))),
      stats: () => mergeStats(residentUnits().map(unit => unit.stats())) };
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
  const [{ createCompanionInfoRoutes, createHostServices, createModuleRoutes }, { startServer }] = await Promise.all([
    import("@mlx-bun/app-services"), import("../server/start"),
  ]);
  const whisper = options.whisper ?? {};
  const moduleHost = createHostServices({ whisper: { ...whisper, modelDir: model.path, modelId: model.repoId } });
  let modules: Awaited<ReturnType<typeof loadInstalledModules>> | undefined;
  // The modules stop first (takes in flight are joined), then the weights release.
  const close = async () => {
    const errors: unknown[] = [];
    try { await modules?.stop(); } catch (error) { errors.push(error); }
    try { await moduleHost.whisper.close(); } catch (error) { errors.push(error); }
    moduleHost.events.close();
    if (errors.length) throw new AggregateError(errors, "transcription cleanup failed");
  };
  let cleanup: (() => Promise<void>) | undefined = close;
  try {
    modules = await loadInstalledModules(moduleHost);
    if (whisper.preload) await moduleHost.whisper.preload(model.repoId);
    const audio = createModuleRoutes(modules.routes);
    const loaded = modules;
    const info = createCompanionInfoRoutes({ modelId: model.repoId, models: moduleHost.whisper, counters: () => loaded.status("transcription"),
      name: "mlx-bun", version: pkgJson.version, startedAt: Date.now(),
      endpoints: [...modules.routes.map(route => `${route.spec.method} ${route.path}`), "GET /v1/models", "GET /health", "GET /stats"] });
    // startServer owns the cleanup on entry, including a bind failure.
    cleanup = undefined;
    const routes: RouteGroup = { handle: async request => await audio.handle(request) ?? await info.handle(request) };
    const listener = await startServer({
      routes: hooks.routes?.(routes) ?? routes,
      web: () => null,
      // No chat model: a WebSocket session fails to start and its transport closes.
      chat: () => ({ async start() { throw new Error("transcription-only server has no chat model"); }, async handle() {}, dispose() {} }),
      // Whisper closes before drain: admission stops, in-flight takes are joined, weights release.
      beforeDrain: async () => { try { await hooks.beforeDrain?.(); } finally { await close(); } },
      closeEngine: async () => {},
    }, hooks.unix ? { unix: hooks.unix } : { port: options.port, hostname: options.hostname });
    return { ...(hooks.unix ? {} : { port: listener.server.port! }), close: listener.close,
      downloads: { active: [], start() { throw new Error("transcription-only server owns no downloads"); } } };
  } catch (error) { await cleanup?.(); throw error; }
}
