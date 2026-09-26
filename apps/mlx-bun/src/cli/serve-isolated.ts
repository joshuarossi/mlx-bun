// The isolated serve composition (`--isolate`): this process keeps the
// persistent CPU state (serve-state.ts), the web app, Pi chat, the Responses
// history, and the managed jobs, and proxies every model-scoped route to a
// worker process (worker-entry.ts) that composes the model host alone over a
// Unix socket. Workers are spawned through the executable captured at startup
// with a model this process resolved and the options it parsed, one per exact
// `/v1/models` id under the pool's cap (`--model-pool`, jobs/worker-pool.ts);
// each respawns within a budget after a crash while the app stays up. Nothing
// here imports the engine or a native module.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { Registry, type ModelRecord } from "@mlx-bun/hub/registry";
import { isSupportedModelRecord } from "@mlx-bun/inference/models/support";
import { createPiBackend } from "../chat/pi-backend";
import { PI_LOCAL_MODEL_ID } from "../chat/provider";
import { createWorkerPool, type WorkerPool } from "../jobs/worker-pool";
import { superviseWorker, type WorkerRestartBudget, type WorkerSupervisor } from "../jobs/worker-supervisor";
import { createManagementRoutes } from "../server/management-routes";
import { createProxyRoutes } from "../server/proxy-routes";
import { createResponsesClient } from "../server/responses-client";
import { startServer } from "../server/start";
import type { RunningApp, ServeOptions } from "./serve-options";
import { createAppState, type RouteGroup } from "./serve-state";

/** Internal (tests): stand in for the worker entry, the restart policy, and the registry. */
export interface IsolatedServeHooks {
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

interface ServedModel {
  contextWindow: number | undefined;
  vision: boolean; audio: boolean; thinking: boolean; transcription: boolean;
  genDefaults: { temperature: number | null; topP: number | null; topK: number | null };
}

/** What the direct host reads from the loaded context, over the worker's own
 * discovery surface: `/v1/models` for capabilities and generation defaults,
 * `/stats` for the enforced context window. Constant for the worker's life. */
async function describeServedModel(engine: WorkerSupervisor, modelId: string, options: ServeOptions): Promise<ServedModel> {
  const json = async (path: string) => {
    const response = await engine.fetch(`http://engine${path}`);
    if (!response.ok) { await response.body?.cancel().catch(() => {}); throw new Error(`worker answered ${response.status} on ${path}`); }
    return await response.json() as Record<string, unknown>;
  };
  const [models, stats] = await Promise.all([json("/v1/models"), json("/stats")]);
  const rows = Array.isArray(models.data) ? models.data as Record<string, unknown>[] : [];
  const served = rows.find(row => row.id === modelId) ?? rows[0] ?? {};
  const defaults = (served.gen_defaults ?? {}) as Record<string, unknown>;
  const capabilities = (served.capabilities ?? {}) as Record<string, unknown>;
  const admission = (stats.admission ?? {}) as Record<string, unknown>;
  const number = (value: unknown) => typeof value === "number" && Number.isFinite(value) ? value : undefined;
  return {
    contextWindow: number(admission.enforced_context_tokens) ?? number(served.context_window),
    vision: served.vision === true, audio: served.audio === true, thinking: served.reasoning === true,
    transcription: capabilities.transcription === true,
    genDefaults: {
      temperature: options.request.defaultTemperature ?? number(defaults.temperature) ?? null,
      topP: options.request.defaultTopP ?? number(defaults.top_p) ?? null,
      topK: options.request.defaultTopK ?? number(defaults.top_k) ?? null,
    },
  };
}

/** Main's strict pool resolver: only an exact id the worker's `/v1/models`
 * would list (a supported canonical record) names a worker; a fuzzy match or
 * a download never happens here, so drop-in clients sending `gpt-4`-style
 * names keep riding the default worker. */
function exactModel(id: string, createRegistry: () => Pick<Registry, "listCanonical" | "close">): ModelRecord | null {
  const registry = createRegistry();
  try {
    return registry.listCanonical().find(model => model.repoId === id && isSupportedModelRecord(model.modelType, model.repoId)) ?? null;
  } finally { registry.close(); }
}

/** Isolated composition: the persistent state and the default worker first,
 * the listener once that worker serves, so startup fails the way the direct
 * composition does when the model cannot load. */
export async function startIsolatedServer(model: ModelRecord, options: ServeOptions, hooks: IsolatedServeHooks = {}): Promise<RunningApp> {
  const state = await createAppState(options, options.storagePaths ?? {});
  // Sockets live in a private directory (0700) this process removes, one per worker.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  const notice = hooks.notice ?? (line => console.log(`[isolate] ${line}`));
  let pool: WorkerPool | undefined;
  const closeEngine = async () => { try { await pool?.close(); } finally { removeSocketDir(); } };
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  let cleanup: (() => Promise<void>) | undefined = closeEngine;
  try {
    const workers = createWorkerPool({
      cap: options.modelPool ?? 1, defaultModel: model, aliases: [PI_LOCAL_MODEL_ID],
      resolve: id => exactModel(id, hooks.createRegistry ?? (() => new Registry())),
      socketFor: index => join(socketDir, index === 0 ? "engine.sock" : `engine-${index}.sock`),
      supervise: (record, socketPath) => superviseWorker({
        entry: hooks.entry ?? fileURLToPath(new URL("./worker-entry.ts", import.meta.url)),
        socketPath,
        // The worker gets the resolved model and options; the flag itself is the parent's.
        launch: { socketPath, model: record, options: { ...options, isolate: false } },
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
    const served = await describeServedModel(supervisor, modelId, options);
    const responses = createResponsesClient(state.responses);
    const proxy = createProxyRoutes({ pool: workers, responses, downloads: () => state.downloads.snapshot(), modelId, startedAt: Date.now() });
    // Tool-approval settings and hub GC are CPU work over the parent's own
    // files; GC protects resident, queued/loading, and still-draining snapshots.
    const management = createManagementRoutes({ invalidateLibrary: proxy.invalidateLibrary,
      toolApprovalsFile: state.chatPaths?.toolApprovalsFile, servedModelPaths: () => workers.servedPaths() });
    const persistent = state.routes;
    // The persistent groups answer first, in the direct host's order among
    // themselves; the proxy takes every remaining path to a worker.
    const routes: RouteGroup = { handle: async request => await persistent.hub.handle(request) ?? await persistent.sessions.handle(request) ??
      await management.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.quantize.handle(request) ?? await persistent.dataset.handle(request) ?? await persistent.finetune.handle(request) ??
      await persistent.publishing.handle(request) ?? await proxy.handle(request) };
    let boundPort = options.port;
    // Pi lives here and reaches the model over loopback through the proxy, so
    // web chat survives a worker restart and reports its failures as errors.
    // Its `local` model id is the pool's alias for the default worker.
    const chat = createPiBackend({ port: () => boundPort, modelId,
      memory: state.memorySurface,
      paths: { ...state.chatPaths, sessionDir: state.sessionDir },
      ...(served.contextWindow !== undefined ? { contextWindow: served.contextWindow } : {}),
      readOnly: options.readOnly, vision: served.vision, audio: served.audio, thinking: served.thinking,
      transcription: async () => served.transcription,
      genDefaults: served.genDefaults, downloadsSnapshot: state.downloads.snapshot,
    });
    // Jobs lease every resident worker through the pool; loopback clients reach the workers through the proxy.
    detachLink = state.attach({ get port() { return boundPort; },
      acquireExecutionLease: signal => workers.acquireExecutionLease(signal),
      invalidateLibrary: proxy.invalidateLibrary });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, chat,
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
