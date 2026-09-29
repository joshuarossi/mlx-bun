// The isolated serve composition (`--isolate`): this process keeps the
// persistent CPU state (serve-state.ts), the web app, Pi chat, the Responses
// history, and the managed jobs, and proxies every model-scoped route to one
// worker process (worker-entry.ts) that composes the model host (serve-host.ts)
// over a Unix socket. The worker is spawned through the executable captured at
// startup with a model this process resolved and the options it parsed, and
// respawns within a budget after a crash while the app stays up. The worker
// swaps models in-process by memory fit (engine/model-residency.ts); this
// process forwards a hub switch to it and never loads a model itself. Memory
// synthesis keeps its pipeline, vault and SSE here and runs each stage call on
// the worker's memory task model. Nothing here imports the engine or a native
// module.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { AppModule } from "@mlx-bun/app-core";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { createPiBackend } from "../chat/pi-backend";
import { WORKER_PROTOCOL_VERSION } from "../jobs/worker-process";
import { EngineUnavailableError, superviseWorker, type WorkerRestartBudget, type WorkerSupervisor } from "../jobs/worker-supervisor";
import { locateTaskModel, MEMORY_TASK_MODEL } from "../memory/model";
import { createManagementRoutes } from "../server/management-routes";
import { createWorkerMemoryClient } from "../server/memory-completion-client";
import { createProxyRoutes } from "../server/proxy-routes";
import { createResponsesClient } from "../server/responses-client";
import { ServeRefused } from "../server/hub-routes";
import { startServer } from "../server/start";
import { shutdownTimeoutMs, type RunningApp, type ServeOptions } from "./serve-options";
import { createAppState, type RouteGroup } from "./serve-state";

/** What the composition root supplies (`modules`: the installed modules that run in the persistent state)
 * and, internally for tests, stand-ins for the worker entry and the restart policy. */
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
}

interface ServedModel {
  contextWindow: number | undefined;
  vision: boolean; audio: boolean; thinking: boolean; transcription: boolean;
  genDefaults: { temperature: number | null; topP: number | null; topK: number | null };
}

/** What the direct host reads from the loaded context, over the worker's own
 * discovery surface: `/v1/models` for capabilities and generation defaults,
 * `/stats` for the enforced context window. Read at startup and again after
 * each switch, for the model the worker then serves. */
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

/** Isolated composition: the persistent state and the worker first, the
 * listener once that worker serves, so startup fails the way the direct
 * composition does when the model cannot load. */
export async function startIsolatedServer(model: ModelRecord, options: ServeOptions, hooks: IsolatedServeHooks = {}): Promise<RunningApp> {
  let engine: WorkerSupervisor | undefined;
  const requireEngine = () => { if (!engine) throw new EngineUnavailableError("starting", null); return engine; };
  // Snapshots the worker reads besides the models it serves: the memory task
  // model, selected here and kept out of hub GC from the call that carries it
  // for as long as that worker lives (a respawned worker holds none until asked).
  const retained = new Set<string>();
  let retainedFor = 0;
  const retention = () => {
    if (engine && engine.restarts !== retainedFor) { retained.clear(); retainedFor = engine.restarts; }
    return retained;
  };
  // The parent loads no model: each synthesis stage call or batch runs on the
  // worker's memory task model over its private route. That worker takes its
  // own execution lease. Each call selects the task model snapshot once, here
  // (the worker never scans the cache): the call carries it, and a call that
  // loads the task model loads exactly it.
  const state = await createAppState({ ...options, memoryCompletions: signal => createWorkerMemoryClient(async () => {
    const worker = requireEngine(), snapshot = await locateTaskModel(MEMORY_TASK_MODEL);
    retention().add(snapshot);
    return { worker, snapshot };
  }, signal) }, options.storagePaths ?? {}, hooks.modules);
  // The socket lives in a private directory (0700) this process removes.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  const notice = hooks.notice ?? (line => console.log(`[isolate] ${line}`));
  const closeEngine = async () => { try { await engine?.close(); } finally { removeSocketDir(); } };
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  let cleanup: (() => Promise<void>) | undefined = closeEngine;
  try {
    const socketPath = join(socketDir, "engine.sock");
    const supervisor = superviseWorker({
      entry: hooks.entry ?? fileURLToPath(new URL("./worker-entry.ts", import.meta.url)),
      socketPath,
      // The worker gets the resolved model and options; the flag itself is the parent's.
      launch: { version: WORKER_PROTOCOL_VERSION, socketPath, model, options: { ...options, isolate: false } },
      ...(hooks.restarts ? { restarts: hooks.restarts } : {}),
      ...(hooks.env ? { env: hooks.env } : {}),
      ...(hooks.readyTimeoutMs !== undefined ? { readyTimeoutMs: hooks.readyTimeoutMs } : {}),
      // The worker flushes every resident model's saved state when it closes, and a kill would cut that: it gets the
      // CLI's shutdown budget to drain and then to stop, as the library host's worker does.
      drainTimeoutMs: hooks.graceMs ?? shutdownTimeoutMs(), graceMs: hooks.graceMs ?? shutdownTimeoutMs(),
      notice,
      ...(hooks.log ? { log: hooks.log } : {}),
      ...(hooks.error ? { error: hooks.error } : {}),
    });
    engine = supervisor;
    await supervisor.ready;
    let modelId = supervisor.modelId ?? model.repoId;
    notice(`engine worker pid ${supervisor.pid} ready (socket ${supervisor.socketPath})`);
    let served = await describeServedModel(supervisor, modelId, options);
    const responses = createResponsesClient(state.responses);
    const proxy = createProxyRoutes({ engine: supervisor, responses, downloads: () => state.downloads.snapshot(), modelId, startedAt: Date.now() });
    // Hub GC keeps every snapshot the worker holds resident (asked of it each time, since it swaps models),
    // the last answer when it cannot be reached, and the task model's.
    let lastServed: readonly string[] = [model.path];
    const servedPaths = async () => {
      try {
        const response = await supervisor.fetch("http://engine/admin/served", { signal: AbortSignal.timeout(2_000) });
        if (response.ok) lastServed = ((await response.json()) as { paths: string[] }).paths;
        else await response.body?.cancel().catch(() => {});
      } catch { /* an unreachable worker keeps what it last held */ }
      return [...lastServed, ...retention()];
    };
    // Tool-approval settings and hub GC are CPU work over the parent's own files.
    const management = createManagementRoutes({ invalidateLibrary: proxy.invalidateLibrary,
      toolApprovalsFile: state.chatPaths?.toolApprovalsFile, servedModelPaths: servedPaths });
    const persistent = state.routes;
    // The persistent groups answer first, in the direct host's order among
    // themselves; the proxy takes every remaining path to the worker.
    const routes: RouteGroup = { handle: async request => await persistent.hub.handle(request) ?? await persistent.sessions.handle(request) ??
      await management.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.quantize.handle(request) ?? await persistent.appModules.handle(request) ?? await persistent.finetune.handle(request) ??
      await persistent.publishing.handle(request) ?? await proxy.handle(request) };
    let boundPort = options.port;
    // Pi lives here and reaches the model over loopback through the proxy, so
    // web chat survives a worker restart and reports its failures as errors.
    // Its `local` model id is whatever the worker serves as current; each chat
    // reads what that model is when it connects.
    let describedAt = supervisor.restarts;
    const chat = createPiBackend({ port: () => boundPort, modelId,
      model: async () => {
        // A respawned worker serves the model it was started with, not the one a switch chose: describe it again.
        if (supervisor.restarts !== describedAt) {
          try {
            const next = supervisor.modelId ?? model.repoId;
            served = await describeServedModel(supervisor, next, options);
            modelId = next; describedAt = supervisor.restarts;
          } catch { /* still restarting: the next connection asks again */ }
        }
        return { modelId, ...(served.contextWindow !== undefined ? { contextWindow: served.contextWindow } : {}),
          vision: served.vision, audio: served.audio, thinking: served.thinking, genDefaults: served.genDefaults };
      },
      memory: state.memorySurface,
      paths: { ...state.chatPaths, sessionDir: state.sessionDir },
      ...(served.contextWindow !== undefined ? { contextWindow: served.contextWindow } : {}),
      readOnly: options.readOnly, vision: served.vision, audio: served.audio, thinking: served.thinking,
      transcription: async () => served.transcription,
      genDefaults: served.genDefaults, downloadsSnapshot: state.downloads.snapshot,
    });
    // Jobs lease the worker; loopback clients reach it through the proxy; a hub switch is the worker's to make.
    detachLink = state.attach({ get model() { return { id: modelId, bytes: model.sizeBytes }; }, get port() { return boundPort; },
      acquireExecutionLease: signal => supervisor.acquireExecutionLease(signal),
      invalidateLibrary: proxy.invalidateLibrary,
      async serve(id, signal) {
        let response: Response;
        try {
          response = await supervisor.fetch("http://engine/admin/serve", { method: "POST", body: JSON.stringify({ model: id }),
            headers: { "content-type": "application/json" }, signal });
        } catch (error) { throw new ServeRefused(502, error instanceof Error ? error.message : String(error)); }
        const body = await response.json().catch(() => ({})) as { model?: string; error?: { message?: string } };
        if (!response.ok || typeof body.model !== "string")
          throw new ServeRefused(response.ok ? 502 : response.status, body.error?.message ?? `the worker answered ${response.status}`);
        modelId = body.model;
        served = await describeServedModel(supervisor, modelId, options).catch(() => served);
        return { model: modelId };
      } });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, chat,
      // The app stops its producers (jobs, downloads) while the worker is alive,
      // then chat and HTTP drain, then the worker is drained and stopped.
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
