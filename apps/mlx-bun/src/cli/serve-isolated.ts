// The isolated serve composition (`--isolate`): this process keeps the
// persistent CPU state (serve-state.ts: the web app, the chat module, the
// Responses history, the managed jobs), and proxies every model-scoped route to a
// worker process (worker-entry.ts) that composes the model host alone over a
// Unix socket. Workers are spawned through the executable captured at startup
// with a model this process resolved and the options it parsed, one per exact
// `/v1/models` id under the pool's cap (`--model-pool`, jobs/worker-pool.ts);
// each respawns within a budget after a crash while the app stays up. Memory
// synthesis keeps its pipeline, vault and SSE here and runs each stage call on
// the default model worker's memory task model. Nothing here imports the
// engine or a native module.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { AppModule } from "@mlx-bun/app-core";
import type { ModelRecord, Registry } from "@mlx-bun/hub/registry";
import { isSupportedModelRecord } from "@mlx-bun/inference/models/support";
import { createWorkerPool, type WorkerPool } from "../jobs/worker-pool";
import { WORKER_PROTOCOL_VERSION } from "../jobs/worker-process";
import { EngineUnavailableError, superviseWorker, type WorkerRestartBudget, type WorkerSupervisor } from "../jobs/worker-supervisor";
import { locateTaskModel, MEMORY_TASK_MODEL } from "../memory/model";
import { createManagementRoutes } from "../server/management-routes";
import { createWorkerMemoryClient } from "../server/memory-completion-client";
import { createProxyRoutes } from "../server/proxy-routes";
import { createResponsesClient } from "../server/responses-client";
import { startServer } from "../server/start";
import type { RunningApp, ServeOptions } from "./serve-options";
import { createAppState, type RouteGroup } from "./serve-state";
import { openRegistry } from "../storage/paths";

/** What the composition root supplies (`modules`: the installed modules that run in the persistent state)
 * and, internally for tests, stand-ins for the worker entry, the restart policy, and the registry. */
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
  /** The registry the pool resolves exact ids through; never scans or downloads. */
  createRegistry?(): Pick<Registry, "listCanonical" | "close">;
}

/** Main's strict pool resolver: only an exact id the worker's `/v1/models`
 * would list (a supported canonical record) names a worker; a fuzzy match or
 * a download never happens here, so drop-in clients sending `gpt-4`-style
 * names keep riding the default worker. */
function exactModel(id: string, createRegistry: () => Pick<Registry, "listCanonical" | "close">): ModelRecord | null {
  const registry = createRegistry();
  try {
    return registry.listCanonical().find(model => model.repoId === id && isSupportedModelRecord(model.modelType)) ?? null;
  } finally { registry.close(); }
}

/** Isolated composition: the persistent state and the default worker first,
 * the listener once that worker serves, so startup fails the way the direct
 * composition does when the model cannot load. */
export async function startIsolatedServer(model: ModelRecord, options: ServeOptions, hooks: IsolatedServeHooks = {}): Promise<RunningApp> {
  let pool: WorkerPool | undefined;
  const requirePool = () => { if (!pool) throw new EngineUnavailableError("starting", null); return pool; };
  // The parent loads no model: each synthesis stage call or batch runs on the
  // default model worker's memory task model over its private route. That
  // worker takes its own execution lease; a pool lease here would wait on it.
  // Each call selects the task model snapshot once, here (the worker never
  // scans the cache): the call carries it, a call that loads the task model
  // loads exactly it, and it is retained on that worker before the call is
  // sent, for the worker's lifetime (the task model stays resident there),
  // through cancellations, until the worker has closed.
  const state = await createAppState({ ...options, memoryCompletions: signal => createWorkerMemoryClient(async signal => {
    const workers = requirePool(), worker = await workers.workerFor(undefined, signal);
    const snapshot = await locateTaskModel(MEMORY_TASK_MODEL);
    workers.retain(worker, [snapshot]);
    return { worker, snapshot };
  }, signal) }, options.storagePaths ?? {}, hooks.modules);
  // Sockets live in a private directory (0700) this process removes, one per worker.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  const notice = hooks.notice ?? (line => console.log(`[isolate] ${line}`));
  const closeEngine = async () => { try { await pool?.close(); } finally { removeSocketDir(); } };
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  let cleanup: (() => Promise<void>) | undefined = closeEngine;
  try {
    const workers = createWorkerPool({
      // `local` is the id clients (chat, dataset generation) send for "the served model".
      cap: options.modelPool ?? 1, defaultModel: model, aliases: ["local"],
      resolve: id => exactModel(id, hooks.createRegistry ?? (() => openRegistry())),
      socketFor: index => join(socketDir, index === 0 ? "engine.sock" : `engine-${index}.sock`),
      supervise: (record, socketPath) => superviseWorker({
        entry: hooks.entry ?? fileURLToPath(new URL("./worker-entry.ts", import.meta.url)),
        socketPath,
        // The worker gets the resolved model and options; the flag itself is the parent's.
        launch: { version: WORKER_PROTOCOL_VERSION, socketPath, model: record, options: { ...options, isolate: false } },
        ...(hooks.restarts ? { restarts: hooks.restarts } : {}),
        ...(hooks.env ? { env: hooks.env } : {}),
        ...(hooks.readyTimeoutMs !== undefined ? { readyTimeoutMs: hooks.readyTimeoutMs } : {}),
        ...(hooks.graceMs !== undefined ? { graceMs: hooks.graceMs } : {}),
        ...(hooks.notice ? { notice: hooks.notice } : {}),
        ...(hooks.log ? { log: hooks.log } : {}),
        ...(hooks.error ? { error: hooks.error } : {}),
      }),
      notice,
    });
    pool = workers;
    const supervisor = await workers.ready;
    const modelId = supervisor.modelId ?? model.repoId;
    notice(`engine worker pid ${supervisor.pid} ready (socket ${supervisor.socketPath})`);
    const responses = createResponsesClient(state.responses);
    const proxy = createProxyRoutes({ pool: workers, responses, downloads: () => state.downloads.snapshot(), modelId, startedAt: Date.now() });
    // Hub GC is CPU work over the parent's own files; it protects resident,
    // queued/loading, and still-draining snapshots, with the task model's
    // retained on the workers it reached.
    const management = createManagementRoutes({ invalidateLibrary: proxy.invalidateLibrary, servedModelPaths: () => workers.servedPaths() });
    const persistent = state.routes;
    // The persistent groups answer first, in the direct host's order among
    // themselves; the proxy takes every remaining path to a worker.
    const routes: RouteGroup = { handle: async request => await persistent.hub.handle(request) ??
      await management.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.models.handle(request) ?? await persistent.appModules.handle(request) ??
      await persistent.publishing.handle(request) ?? await proxy.handle(request) };
    // The chat module lives in the state and reaches the model through the served model host (over this listener's proxy), so
    // web chat survives a worker restart and reports its failures as errors.
    let boundPort = options.port;
    // Jobs lease every resident worker through the pool; loopback clients reach the workers through the proxy.
    detachLink = state.attach({ model: { id: modelId, bytes: model.sizeBytes }, get port() { return boundPort; },
      acquireExecutionLease: signal => workers.acquireExecutionLease(signal),
      invalidateLibrary: proxy.invalidateLibrary });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, sockets: state.sockets,
      // The app stops its producers (jobs, downloads) while the workers are alive,
      // then chat and HTTP drain, then every worker is drained and stopped.
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
