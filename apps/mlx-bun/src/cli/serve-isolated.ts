// The isolated serve composition (`--isolate`): this process keeps the
// persistent CPU state (serve-state.ts), the web app, Pi chat, the Responses
// history, and the managed jobs, and proxies every model-scoped route to a
// worker process (worker-entry.ts) that composes the model host alone over a
// Unix socket. The worker is spawned through the executable captured at
// startup with the model this process resolved and the options it parsed; it
// respawns within a budget after a crash while the app stays up. Nothing here
// imports the engine or a native module.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { createPiBackend } from "../chat/pi-backend";
import { superviseWorker, type WorkerRestartBudget, type WorkerSupervisor } from "../jobs/worker-supervisor";
import { createManagementRoutes } from "../server/management-routes";
import { createProxyRoutes } from "../server/proxy-routes";
import { createResponsesClient } from "../server/responses-client";
import { startServer } from "../server/start";
import type { RunningApp, ServeOptions } from "./serve-options";
import { createAppState, type RouteGroup } from "./serve-state";

/** Internal (tests): stand in for the worker entry and the restart policy. */
export interface IsolatedServeHooks {
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

/** Isolated composition: the persistent state and the worker first, the
 * listener once the worker serves, so startup fails the way the direct
 * composition does when the model cannot load. */
export async function startIsolatedServer(model: ModelRecord, options: ServeOptions, hooks: IsolatedServeHooks = {}): Promise<RunningApp> {
  const state = await createAppState(options, options.storagePaths ?? {});
  // The socket lives in a private directory (0700) this process removes.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const socketPath = join(socketDir, "engine.sock");
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  let engine: WorkerSupervisor | undefined;
  const closeEngine = async () => { try { await engine?.close(); } finally { removeSocketDir(); } };
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  let cleanup: (() => Promise<void>) | undefined = closeEngine;
  try {
    const supervisor = superviseWorker({
      entry: hooks.entry ?? fileURLToPath(new URL("./worker-entry.ts", import.meta.url)),
      socketPath,
      // The worker gets the resolved model and options; the flag itself is the parent's.
      launch: { socketPath, model, options: { ...options, isolate: false } },
      ...(hooks.restarts ? { restarts: hooks.restarts } : {}),
      ...(hooks.env ? { env: hooks.env } : {}),
      ...(hooks.readyTimeoutMs !== undefined ? { readyTimeoutMs: hooks.readyTimeoutMs } : {}),
      ...(hooks.graceMs !== undefined ? { graceMs: hooks.graceMs } : {}),
      ...(hooks.notice ? { notice: hooks.notice } : {}),
      ...(hooks.log ? { log: hooks.log } : {}),
      ...(hooks.error ? { error: hooks.error } : {}),
    });
    engine = supervisor;
    const { modelId } = await supervisor.ready;
    (hooks.notice ?? (line => console.log(`[isolate] ${line}`)))(`engine worker pid ${supervisor.pid} ready (socket ${socketPath})`);
    const served = await describeServedModel(supervisor, modelId, options);
    const responses = createResponsesClient(state.responses);
    const proxy = createProxyRoutes({ engine: supervisor, responses, downloads: () => state.downloads.snapshot(), modelId, startedAt: Date.now() });
    // Tool-approval settings and hub GC are CPU work over the parent's own
    // files; GC still protects the snapshot the worker serves.
    const management = createManagementRoutes({ invalidateLibrary: proxy.invalidateLibrary,
      toolApprovalsFile: state.chatPaths?.toolApprovalsFile, servedModelPath: model.path });
    const persistent = state.routes;
    // The persistent groups answer first, in the direct host's order among
    // themselves; the proxy takes every remaining path to the worker.
    const routes: RouteGroup = { handle: async request => await persistent.hub.handle(request) ?? await persistent.sessions.handle(request) ??
      await management.handle(request) ?? await persistent.memory.handle(request) ?? await persistent.jobs.handle(request) ??
      await persistent.quantize.handle(request) ?? await persistent.dataset.handle(request) ?? await persistent.finetune.handle(request) ??
      await persistent.publishing.handle(request) ?? await proxy.handle(request) };
    let boundPort = options.port;
    // Pi lives here and reaches the model over loopback through the proxy, so
    // web chat survives a worker restart and reports its failures as errors.
    const chat = createPiBackend({ port: () => boundPort, modelId,
      memory: state.memorySurface,
      paths: { ...state.chatPaths, sessionDir: state.sessionDir },
      ...(served.contextWindow !== undefined ? { contextWindow: served.contextWindow } : {}),
      readOnly: options.readOnly, vision: served.vision, audio: served.audio, thinking: served.thinking,
      transcription: async () => served.transcription,
      genDefaults: served.genDefaults, downloadsSnapshot: state.downloads.snapshot,
    });
    // Jobs and loopback clients reach the worker through the supervisor.
    detachLink = state.attach({ get port() { return boundPort; },
      acquireExecutionLease: signal => supervisor.acquireExecutionLease(signal),
      invalidateLibrary: proxy.invalidateLibrary });
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
