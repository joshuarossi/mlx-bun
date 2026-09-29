// The worker half of runtime isolation, reached only through the parent's
// spawn helper (jobs/worker-process.ts): the launch record arrives as the
// first stdin line, the ready line leaves on stdout, and the end of stdin
// means the parent is gone. No flag selects it. Two launch forms, both
// carrying the app's package version (a record with another one exits 2):
// - model (`--isolate`): only the model-scoped host (serve-host.ts) over the
//   parent's Unix socket, with the persistent services stubbed because the
//   parent owns them, plus the memory task model the parent's synthesis calls
//   through the admin surface (only the default worker is ever asked);
// - app: the whole app, composed by `runServe` from serve arguments exactly as
//   the CLI composes it, listening on the parent's socket instead of TCP.
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { createEventHub, createModuleSockets } from "@mlx-bun/app-services/portable";
import { decodeLaunch, formatWorkerMessage, WORKER_PROTOCOL_VERSION } from "../jobs/worker-process";
import { ResponseStore } from "../server/responses";
import { createWorkerRoutes } from "../server/worker-routes";
import type { CommandArgs } from "./args";
// The app form's composition loads only when a launch asks for it.
import type { ServeDependencies, ServedApp, SignalPort, startModelServer, startTranscriptionServer } from "./serve";
import { startModelHost } from "./serve-host";
import type { ServeOptions } from "./serve-options";
import type { AppState, ModelHostLink, RouteGroup } from "./serve-state";

/** The model form: the socket to bind, the model record the parent selected,
 * and the serve options with every query already resolved to a directory
 * (draft, Whisper). The parent's port and hostname are ignored. */
export interface ModelWorkerLaunch { kind?: "model"; version: string; socketPath: string; model: ModelRecord; options: ServeOptions }
/** The app form: serve arguments as the CLI takes them (`["--model", model, ...]`),
 * validated by `validateAppLaunchArgv` and composed by `runServe` on the socket. */
export interface AppWorkerLaunch { kind: "app"; version: string; socketPath: string; argv: string[] }
export type WorkerLaunch = ModelWorkerLaunch | AppWorkerLaunch;

export function parseWorkerLaunch(text: string): WorkerLaunch {
  let value: unknown;
  try { value = decodeLaunch(text); } catch (error) { throw new Error(`worker launch is not JSON: ${error instanceof Error ? error.message : String(error)}`); }
  const record = value as Record<string, unknown> | null;
  if (!record || typeof record !== "object" || Array.isArray(record)) throw new Error("worker launch must be an object");
  if (typeof record.socketPath !== "string" || !record.socketPath.trim()) throw new Error("worker launch needs socketPath");
  if (record.version !== WORKER_PROTOCOL_VERSION)
    throw new Error(`worker protocol version mismatch: the launch record is ${typeof record.version === "string" ? record.version : "unversioned"}, this worker is ${WORKER_PROTOCOL_VERSION}`);
  const socketPath = record.socketPath, version = WORKER_PROTOCOL_VERSION;
  if (record.kind === "app") {
    if (!Array.isArray(record.argv) || !record.argv.every(item => typeof item === "string"))
      throw new Error("worker launch needs argv, the serve arguments");
    return { kind: "app", version, socketPath, argv: record.argv as string[] };
  }
  if (record.kind !== undefined && record.kind !== "model") throw new Error(`worker launch kind ${JSON.stringify(record.kind)} is unknown`);
  const model = record.model as Partial<ModelRecord> | undefined;
  if (!model || typeof model !== "object" || typeof model.repoId !== "string" || typeof model.path !== "string")
    throw new Error("worker launch needs model.repoId and model.path");
  const options = record.options as Partial<ServeOptions> | undefined;
  if (!options || typeof options !== "object" || !options.cache || !options.request || typeof options.capacity !== "number")
    throw new Error("worker launch needs resolved serve options");
  return { ...(record.kind === "model" ? { kind: "model" as const } : {}), version, socketPath, model: model as ModelRecord, options: options as ServeOptions };
}

/** The persistent half a worker does not own: nothing served, no producers,
 * and the host's link kept where the admin routes can reach it. */
export function createWorkerState(options: ServeOptions, link: { current?: ModelHostLink }): AppState {
  const none: RouteGroup = { handle: async () => null };
  const events = createEventHub();
  return {
    web: () => null,
    downloads: { active: [], snapshot: () => [], start() { throw new Error("a worker owns no downloads"); }, async close() {} },
    // A worker publishes its own engine's events for the modules it hosts; it runs no jobs.
    events,
    responses: new ResponseStore(),
    // Chat and its memory tools are the parent's: the worker never opens a vault, so the paths are placeholders.
    memoryPaths: options.memoryPaths ?? { vault: "", skills: "" },
    storagePaths: options.storagePaths ?? {},
    sockets: createModuleSockets([]),
    routes: { hub: none, memory: none, jobs: none, models: none, appModules: none, finetune: none, publishing: none },
    attach(supplied) {
      link.current = supplied;
      return () => { if (link.current === supplied) link.current = undefined; };
    },
    async close() { events.close(); },
  };
}

/** What the app form composes with; `runServe`'s own defaults otherwise. */
export interface AppWorkerDependencies {
  resolve: ServeDependencies["resolve"];
  start: typeof startModelServer;
  startTranscription: typeof startTranscriptionServer;
  log(message: string): void;
}

export interface WorkerEntryPorts {
  /** The launch record is the first line; the stream's end means the parent left. */
  stdin: ReadableStream<Uint8Array>;
  write(line: string): void;
  signals: SignalPort;
  /** Internal (tests): stand-ins for the app form's selection, compositions,
   * and log; a stand-in composition still receives the socket hooks. */
  app?: Partial<AppWorkerDependencies>;
}

const defaults: WorkerEntryPorts = { stdin: Bun.stdin.stream(), write: line => { process.stdout.write(line + "\n"); }, signals: process };

/** Runs until the parent signals or leaves; the exit code is the process's. */
export async function runWorkerEntry(ports: WorkerEntryPorts = defaults): Promise<number> {
  const reader = ports.stdin.getReader(), decoder = new TextDecoder();
  let buffered = "";
  const readLine = async (): Promise<string | null> => {
    for (;;) {
      const newline = buffered.indexOf("\n");
      if (newline !== -1) { const line = buffered.slice(0, newline); buffered = buffered.slice(newline + 1); return line; }
      const { done, value } = await reader.read();
      if (done) { const rest = buffered; buffered = ""; return rest.trim() ? rest : null; }
      buffered += decoder.decode(value, { stream: true });
    }
  };
  let launch: WorkerLaunch, args: CommandArgs | undefined;
  try {
    const first = await readLine();
    if (first === null) throw new Error("worker launch: stdin ended before the launch record");
    launch = parseWorkerLaunch(first);
    // The app form's arguments fail here like the CLI's, before anything composes.
    if (launch.kind === "app") args = (await import("./serve")).validateAppLaunchArgv(launch.argv);
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    return 2;
  }
  const parentLeft = () => (async () => { while ((await readLine()) !== null) { /* nothing else is expected on stdin */ } })().catch(() => {});
  if (launch.kind === "app") return runAppWorker(launch, args!, ports, parentLeft());
  const link: { current?: ModelHostLink } = {};
  // Main's memory task model, loaded by the first call and kept until this
  // worker stops: the admin surface runs each call under the host's execution
  // lease, and shutdown joins those calls, then closes the task model, both
  // ahead of the host's engine.
  const memory = (await import("./memory-engine")).createInProcessMemoryClient();
  const admin = createWorkerRoutes({ modelId: launch.model.repoId, pid: process.pid,
    acquireExecutionLease(signal) {
      if (!link.current) return Promise.reject(new Error("no model host is attached"));
      return link.current.acquireExecutionLease(signal);
    }, memoryTaskModel: memory });
  let host: Awaited<ReturnType<typeof startModelHost>>;
  try {
    host = await startModelHost(createWorkerState(launch.options, link), launch.model, launch.options,
      { unix: launch.socketPath, routes: model => admin.wrap(model),
        beforeDrain: async () => { try { await admin.close(); } finally { await memory.close(); } } });
  } catch (error) {
    // Nothing was served, so the task model never loaded; closing only refuses later calls.
    await memory.close();
    console.error(`worker startup failed: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
  ports.write(formatWorkerMessage({ type: "ready", socketPath: launch.socketPath, modelId: launch.model.repoId, pid: process.pid, version: WORKER_PROTOCOL_VERSION }));
  // Stay up until the parent signals or its pipe ends. One close; a later
  // signal waits on it, and the parent's grace period bounds the wait.
  return new Promise<number>(resolve => {
    let closing = false;
    const stop = () => {
      if (closing) return;
      closing = true;
      ports.signals.removeListener("SIGTERM", stop); ports.signals.removeListener("SIGINT", stop);
      host.close().then(() => resolve(0), error => { console.error(error instanceof Error ? error.message : String(error)); resolve(1); });
    };
    ports.signals.on("SIGTERM", stop); ports.signals.on("SIGINT", stop);
    void parentLeft().finally(stop);
  });
}

/** The app form's signal port: the process's SIGTERM and SIGINT, plus the
 * parent leaving (the end of stdin) delivered as SIGTERM, so runServe's
 * startup abort and its shutdown handlers see all three. */
function parentSignals(base: SignalPort) {
  const listeners = { SIGINT: new Set<() => void>(), SIGTERM: new Set<() => void>() };
  let stopped = false;
  const emit = (signal: "SIGINT" | "SIGTERM") => { stopped = true; for (const listener of [...listeners[signal]]) listener(); };
  const onInt = () => emit("SIGINT"), onTerm = () => emit("SIGTERM");
  base.on("SIGINT", onInt); base.on("SIGTERM", onTerm);
  return {
    get stopped() { return stopped; },
    on(signal: "SIGINT" | "SIGTERM", listener: () => void) { listeners[signal].add(listener); },
    removeListener(signal: "SIGINT" | "SIGTERM", listener: () => void) { listeners[signal].delete(listener); },
    leave: () => emit("SIGTERM"),
    dispose() { base.removeListener("SIGINT", onInt); base.removeListener("SIGTERM", onTerm); },
  };
}

/** The app form: `runServe` composes the whole app from the launch's serve
 * arguments, handing the compositions the socket hooks (the Unix socket, the
 * admin surface ahead of the routes, the admin close ahead of the producers).
 * A stop before ready aborts startup through runServe's startup signal, and
 * nothing is announced; after ready, runServe's shutdown handlers close the
 * app once under the CLI's deadline, and their exit code is the worker's. */
async function runAppWorker(launch: AppWorkerLaunch, args: CommandArgs, ports: WorkerEntryPorts, parentLeft: Promise<void>): Promise<number> {
  const { runServe, startModelServer, startTranscriptionServer, StartupCancelledError } = await import("./serve");
  const signals = parentSignals(ports.signals);
  void parentLeft.finally(signals.leave);
  const exit = Promise.withResolvers<number>();
  const supplied = ports.app ?? {};
  const start = supplied.start ?? startModelServer, startTranscription = supplied.startTranscription ?? startTranscriptionServer;
  const link: { current?: ModelHostLink } = {};
  let modelId: string | undefined;
  // One admin surface for the model the app serves; the transcription-only app has no execution lease.
  const socket = (model: ModelRecord, lease: boolean) => {
    modelId = model.repoId;
    const admin = createWorkerRoutes({ modelId: model.repoId, pid: process.pid, ...(lease ? {
      acquireExecutionLease(signal: AbortSignal) {
        if (!link.current) return Promise.reject(new Error("no model host is attached"));
        return link.current.acquireExecutionLease(signal);
      } } : {}) });
    return { unix: launch.socketPath, routes: (routes: RouteGroup) => admin.wrap(routes), beforeDrain: () => admin.close() };
  };
  try {
    let app: ServedApp;
    try {
      app = await runServe(args, {
        ...(supplied.resolve ? { resolve: supplied.resolve } : {}), ...(supplied.log ? { log: supplied.log } : {}),
        start: (model, options) => start(model, options, { ...socket(model, true), link }),
        startTranscription: (model, options) => startTranscription(model, options, socket(model, false)),
        interactive: false, open() {}, signals, exit: code => exit.resolve(code),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      // Only runServe's own cancellation (a stop before any app existed) is clean.
      // A load failure, or a failed close of an app a stop interrupted, fails the worker with its error.
      if (error instanceof StartupCancelledError) { console.error(`worker startup cancelled: ${message}`); return 0; }
      console.error(`worker startup failed: ${message}`);
      return 1;
    }
    // A stop during the load closed the app inside runServe, successfully; nothing was announced.
    if (app.aborted) return 0;
    // A stop after startup reached the shutdown handlers, which are closing the app: no ready line.
    if (!signals.stopped) {
      try { ports.write(formatWorkerMessage({ type: "ready", socketPath: launch.socketPath, modelId: modelId!, pid: process.pid, version: WORKER_PROTOCOL_VERSION })); }
      catch (error) {
        console.error(`worker ready line failed: ${error instanceof Error ? error.message : String(error)}`);
        try { await app.close(); } catch (failure) { console.error(failure instanceof Error ? failure.message : String(failure)); }
        return 1;
      }
    }
    return await exit.promise;
  } finally { signals.dispose(); }
}

// The process owner exits after the host has released the model; native
// handles the runtime still holds must not keep a stopped worker alive.
if (import.meta.main) process.exit(await runWorkerEntry());
