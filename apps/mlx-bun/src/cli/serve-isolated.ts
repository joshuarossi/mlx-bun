// The isolated serve composition, the default for `serve`: this process keeps the persistent
// CPU state (serve-state.ts), the web app, the chat module, the Responses history, the managed jobs and
// the modules that run beside them, and loads no model. Each resident model runs in its own
// worker process (worker-unit.ts; worker-entry.ts composes the model host over a Unix socket).
// This process holds their residency by memory fit with the same manager the in-process host
// uses (residency/model-residency.ts): a model that fits the budget gets its own worker beside
// the others; otherwise the least recently used unpinned, unleased model is drained, its worker
// flushes its saved state durably and exits (the worker gets the CLI's shutdown budget, never a
// kill first), and naming it again spawns a worker that resumes from that state. Requests route
// by their `model` (server/model-routes.ts) and forward over the worker's socket; a crash
// respawns that worker with its model while the app stays up. Whisper is a companion worker of
// its own, which can be pinned. Each worker's events are relayed onto this process's bus.
// Nothing here imports the engine or a native module.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AppModule } from "@mlx-bun/app-core";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { EngineUnavailableError, type WorkerRestartBudget } from "../jobs/worker-supervisor";
import { locateTaskModel, MEMORY_TASK_MODEL } from "../memory/model";
import { createManagementRoutes } from "../server/management-routes";
import { createWorkerMemoryClient } from "../server/memory-completion-client";
import { createModelRoutes } from "../server/model-routes";
import { createProxyRoutes } from "../server/proxy-routes";
import { createResponsesClient } from "../server/responses-client";
import { ServeRefused } from "../server/hub-routes";
import { startServer } from "../server/start";
import { listLocalRecords } from "../residency/local-records";
import { createResidencyHost, type ResidencyEntry, type ResidencyHost, type ResidencySource } from "../residency/model-residency";
import { createRecordIndex } from "../residency/record-index";
import { estimateRecordBytes } from "../residency/resident-estimate";
import type { RunningApp, ServeOptions } from "./serve-options";
import { createAppState, type RouteGroup } from "./serve-state";
import { spawnWorkerUnit, type WorkerUnit, type WorkerUnitContext } from "./worker-unit";

/** What the composition root supplies (`modules`: the installed modules that run in the persistent state)
 * and, internally for tests, stand-ins for the worker entry, the restart policy, and the model listing. */
export interface IsolatedServeHooks {
  modules?: readonly AppModule[];
  entry?: string;
  restarts?: Partial<WorkerRestartBudget>;
  env?: Record<string, string | undefined>;
  readyTimeoutMs?: number;
  graceMs?: number;
  notice?(line: string): void;
  log?(line: string): void;
  error?(line: string): void;
  /** Internal (tests): sees the app's event bus, where each worker's relayed events and the host's load/unload events arrive. */
  observe?(events: Pick<import("@mlx-bun/app-core").EventBus, "subscribe">): void;
  /** The local chat models the host may load, instead of the registry's. */
  records?(): readonly ModelRecord[];
  /** The Whisper checkpoints it may load, instead of the registry's. */
  companions?(): readonly ModelRecord[];
}

/** Isolated composition: the persistent state and the startup model's worker first, the listener
 * once that worker serves, so startup fails the way the in-process composition does when the model cannot load. */
export async function startIsolatedServer(model: ModelRecord, options: ServeOptions, hooks: IsolatedServeHooks = {}): Promise<RunningApp> {
  let residency!: ResidencyHost<WorkerUnit>;
  /** The model requests that name none are answered by, and Pi's `local`: the one the server started with, then the last switch. */
  let current = model.repoId;
  const workers = () => residency ? residency.resident().flatMap(({ id }) => { const unit = residency.peek(id); return unit ? [unit] : []; }) : [];
  const currentUnit = () => residency?.peek(current);
  // Snapshots a worker reads besides its own model: the memory task model, selected here and kept out of hub GC
  // from the call that carries it for as long as that worker lives (a respawned worker holds none until asked).
  const retained = new WeakMap<WorkerUnit, { restarts: number; paths: Set<string> }>();
  const retention = (unit: WorkerUnit) => {
    let held = retained.get(unit);
    if (!held || held.restarts !== unit.supervisor.restarts) retained.set(unit, held = { restarts: unit.supervisor.restarts, paths: new Set() });
    return held.paths;
  };
  // The parent loads no model: each synthesis stage call or batch runs on the current model's worker (its memory task
  // model, over its private route). That worker takes its own execution lease. Each call selects the task model
  // snapshot once, here (the worker never scans the cache): the call carries it, and a call that loads the task
  // model loads exactly it.
  const state = await createAppState({ ...options, memoryCompletions: signal => createWorkerMemoryClient(async () => {
    const unit = currentUnit();
    if (!unit) throw new EngineUnavailableError("starting", null);
    const snapshot = await locateTaskModel(MEMORY_TASK_MODEL);
    retention(unit).add(snapshot);
    return { worker: unit.supervisor, snapshot };
  }, signal) }, options.storagePaths ?? {}, hooks.modules);
  hooks.observe?.(state.events);
  // The sockets live in a private directory (0700) this process removes, one per worker.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  const notice = hooks.notice ?? (line => console.log(`[isolate] ${line}`));
  const closeEngine = async () => { try { await residency?.close(); } finally { removeSocketDir(); } };
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  let cleanup: (() => Promise<void>) | undefined = closeEngine;
  try {
    const { thisMachine, WIRED_FRACTION } = await import("@mlx-bun/inference/execution/fit");
    const machine = thisMachine();
    // What all resident workers may use together: a share of the memory the GPU can wire (this process cannot ask Metal, so
    // it is derived from the machine's RAM the way `/fit` does).
    const budgetBytes = options.modelBudgetBytes ?? Math.floor(machine.ramBytes * WIRED_FRACTION * 0.7);
    const context: WorkerUnitContext = { options, startup: model, socketDir, publish: event => state.events.publish(event), notice,
      ...(hooks.entry ? { entry: hooks.entry } : {}), ...(hooks.restarts ? { restarts: hooks.restarts } : {}), ...(hooks.env ? { env: hooks.env } : {}),
      ...(hooks.readyTimeoutMs !== undefined ? { readyTimeoutMs: hooks.readyTimeoutMs } : {}), ...(hooks.graceMs !== undefined ? { graceMs: hooks.graceMs } : {}),
      ...(hooks.log ? { log: hooks.log } : {}), ...(hooks.error ? { error: hooks.error } : {}) };
    const chatModels = createRecordIndex(() => hooks.records?.() ?? listLocalRecords("generate"), model);
    const companionList = () => hooks.companions?.() ?? listLocalRecords("transcribe");
    // Whisper: the checkpoint `--whisper-model` resolved to, else the first downloaded one, looked up once.
    let whisper: Promise<ModelRecord | undefined> | undefined;
    const whisperRecord = () => whisper ??= (async () => {
      const explicit = options.whisper;
      if (explicit?.modelDir && explicit.modelId) {
        const listed = (await companionList()).find(record => record.repoId === explicit.modelId);
        return listed ?? { repoId: explicit.modelId, path: explicit.modelDir, modelType: "whisper", sizeBytes: 0, expertsBytes: 0 } as unknown as ModelRecord;
      }
      return (await companionList())[0];
    })();
    const source: ResidencySource<WorkerUnit> = {
      async resolve(id) {
        const chat = await chatModels.find(id);
        // A config the fit model cannot read leaves the checkpoint's own size as the estimate.
        if (chat) return { id, bytes: await estimateRecordBytes(chat, { budgetBytes, cache: options.cache, machine }).catch(() => chat.sizeBytes), operations: ["generate"], role: "primary" };
        const companion = await whisperRecord();
        if (companion && companion.repoId === id) return { id, bytes: companion.sizeBytes, operations: ["transcribe"], role: "companion" };
        return undefined;
      },
      async load(entry) {
        const record = entry.role === "companion" ? (await whisperRecord())! : (await chatModels.find(entry.id))!;
        return spawnWorkerUnit(context, record, entry.role ?? "primary", entry.bytes);
      },
    };
    residency = createResidencyHost<WorkerUnit>({ source, budgetBytes, events: state.events,
      defaultFor: async operation => operation === "generate" ? current : operation === "transcribe" ? (await whisperRecord())?.repoId : undefined,
      log: line => notice(line) });
    // Startup fails fast, as the in-process composition does: the first model's worker serves before the listener binds.
    const first = await spawnWorkerUnit(context, model, "primary", (await source.resolve(model.repoId))?.bytes ?? model.sizeBytes);
    const entryOf = (unit: WorkerUnit): ResidencyEntry => ({ id: unit.id, bytes: unit.bytes(), role: unit.role, operations: unit.operations });
    residency.adopt(entryOf(first), first, { loadMs: first.readyMs });
    // Whisper stays resident when asked to (`--whisper-resident`); otherwise it is the first to go when memory is short.
    const companion = options.whisper?.resident ? await whisperRecord() : undefined;
    if (companion) residency.pin(companion.repoId);

    const models = createModelRoutes({ host: residency, current: () => current,
      serves: async id => !!await chatModels.find(id),
      // Audio requests belong to the Whisper worker, which loads on first use and drains a chat model when memory is short.
      companion: async pathname => (pathname.startsWith("/v1/audio/") || pathname.startsWith("/admin/transcription/")) ? (await whisperRecord())?.repoId : undefined });
    const responses = createResponsesClient(state.responses);
    const proxy = createProxyRoutes({ workers: () => workers(), current: () => current, models, responses,
      downloads: () => state.downloads.snapshot(), modelId: model.repoId, startedAt: Date.now() });
    const invalidateLibrary = () => { chatModels.invalidate(); proxy.invalidateLibrary(); };
    // Hub GC keeps the snapshot of every resident worker's model, and the task model's on the worker that read it.
    const servedPaths = () => workers().flatMap(unit => [unit.record.path, ...retention(unit)]);
    // Tool-approval settings and hub GC are CPU work over the parent's own files.
    const management = createManagementRoutes({ invalidateLibrary, servedModelPaths: servedPaths });
    const persistent = state.routes;
    // The persistent groups answer first, in the direct host's order among themselves; the proxy takes every remaining path.
    const routes: RouteGroup = { handle: async request => await persistent.hub.handle(request) ??
      await management.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.models.handle(request) ?? await persistent.appModules.handle(request) ??
      await persistent.publishing.handle(request) ?? await proxy.handle(request) };
    let boundPort = options.port;
    // The chat module lives in the state and reaches the model through the served model host (over this listener's proxy;
    // its `local` model id is whatever is current), so web chat survives a worker restart and reports its failures as errors.
    // Jobs pause every resident worker; loopback clients reach the workers through the proxy; a hub switch is this host's to make.
    detachLink = state.attach({ get model() { return { id: current, bytes: currentUnit()?.bytes() ?? model.sizeBytes }; }, get port() { return boundPort; },
      acquireExecutionLease: signal => residency.pauseAll(signal),
      invalidateLibrary,
      async serve(id, signal) {
        if (!await chatModels.find(id)) throw new ServeRefused(404, `${id} is not a local model; download it first`);
        try { (await residency.acquire(id, { signal, need: ["generate"] })).release(); }
        catch (error) { throw new ServeRefused(error instanceof Error && "code" in error && error.code === "load-failed" ? 502 : 400, error instanceof Error ? error.message : String(error)); }
        current = id;
        return { model: id };
      } });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, sockets: state.sockets,
      // The app stops its producers (jobs, downloads) while the workers are alive, then chat and HTTP drain, then every
      // worker is drained, flushes its saved state, and exits.
      beforeDrain: () => state.close(),
      closeEngine }, { port: options.port, hostname: options.hostname });
    if (listener.server.port !== undefined) boundPort = listener.server.port;
    let closing: Promise<void> | undefined;
    return { port: boundPort, downloads: state.downloads, close: () => closing ??= (async () => {
      const errors: unknown[] = [];
      try { await listener.close(); } catch (error) { errors.push(error); } finally { detach(); }
      // The listener's drain already closed the state; a repeated failure here is the same one.
      try { await state.close(); } catch (error) { errors.push(error); }
      if (errors.length) throw errors[0];
    })() };
  } catch (error) {
    const failures: unknown[] = [];
    try { await cleanup?.(); } catch (failure) { failures.push(failure); }
    finally { detach(); }
    try { await state.close(); } catch (failure) { failures.push(failure); }
    if (failures.length) throw new AggregateError([error, ...failures], "startup and cleanup failed");
    throw error;
  }
}
