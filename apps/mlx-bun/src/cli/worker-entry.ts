// The worker half of runtime isolation: a process that composes only the
// model-scoped host (serve-host.ts) over a Unix socket the parent supplies,
// with the persistent services stubbed because the parent owns them. It is
// reached only through the parent's spawn helper (jobs/worker-process.ts):
// the launch record arrives as the first stdin line, the ready line leaves on
// stdout, and the end of stdin means the parent is gone. No flag selects it.
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { defaultSessionDir } from "../chat/session-files";
import { decodeLaunch, formatWorkerMessage } from "../jobs/worker-process";
import { ResponseStore } from "../server/responses";
import { createWorkerRoutes } from "../server/worker-routes";
import type { SignalPort } from "./serve";
import { startModelHost } from "./serve-host";
import type { ServeOptions } from "./serve-options";
import type { AppState, ModelHostLink, RouteGroup } from "./serve-state";

/** What the parent resolved for this worker: the socket to bind, the model
 * record it selected, and the serve options with every query already resolved
 * to a directory (draft, Whisper). The parent's port and hostname are ignored. */
export interface WorkerLaunch { socketPath: string; model: ModelRecord; options: ServeOptions }

export function parseWorkerLaunch(text: string): WorkerLaunch {
  let value: unknown;
  try { value = decodeLaunch(text); } catch (error) { throw new Error(`worker launch is not JSON: ${error instanceof Error ? error.message : String(error)}`); }
  const record = value as Partial<WorkerLaunch> | null;
  if (!record || typeof record !== "object" || Array.isArray(record)) throw new Error("worker launch must be an object");
  if (typeof record.socketPath !== "string" || !record.socketPath.trim()) throw new Error("worker launch needs socketPath");
  const model = record.model as Partial<ModelRecord> | undefined;
  if (!model || typeof model !== "object" || typeof model.repoId !== "string" || typeof model.path !== "string")
    throw new Error("worker launch needs model.repoId and model.path");
  const options = record.options as Partial<ServeOptions> | undefined;
  if (!options || typeof options !== "object" || !options.cache || !options.request || typeof options.capacity !== "number")
    throw new Error("worker launch needs resolved serve options");
  return { socketPath: record.socketPath, model: model as ModelRecord, options: options as ServeOptions };
}

/** The persistent half a worker does not own: nothing served, no producers,
 * and the host's link kept where the admin routes can reach it. */
export function createWorkerState(options: ServeOptions, link: { current?: ModelHostLink }): AppState {
  const none: RouteGroup = { handle: async () => null };
  return {
    web: () => null,
    downloads: { active: [], snapshot: () => [], start() { throw new Error("a worker owns no downloads"); }, async close() {} },
    responses: new ResponseStore(),
    // Pi's memory is the parent's: the worker never opens a vault, so the paths are placeholders.
    memoryPaths: options.memoryPaths ?? { vault: "", skills: "" },
    chatPaths: options.chatPaths, sessionDir: options.chatPaths?.sessionDir ?? defaultSessionDir(),
    storagePaths: options.storagePaths ?? {},
    memorySurface: async () => undefined,
    routes: { hub: none, sessions: none, memory: none, jobs: none, quantize: none, dataset: none, finetune: none, publishing: none },
    attach(supplied) {
      link.current = supplied;
      return () => { if (link.current === supplied) link.current = undefined; };
    },
    async close() {},
  };
}

export interface WorkerEntryPorts {
  /** The launch record is the first line; the stream's end means the parent left. */
  stdin: ReadableStream<Uint8Array>;
  write(line: string): void;
  signals: SignalPort;
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
  let launch: WorkerLaunch;
  try {
    const first = await readLine();
    if (first === null) throw new Error("worker launch: stdin ended before the launch record");
    launch = parseWorkerLaunch(first);
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    return 2;
  }
  const link: { current?: ModelHostLink } = {};
  const admin = createWorkerRoutes({ modelId: launch.model.repoId, pid: process.pid,
    acquireExecutionLease(signal) {
      if (!link.current) return Promise.reject(new Error("no model host is attached"));
      return link.current.acquireExecutionLease(signal);
    } });
  let host: Awaited<ReturnType<typeof startModelHost>>;
  try {
    host = await startModelHost(createWorkerState(launch.options, link), launch.model, launch.options,
      { unix: launch.socketPath, routes: model => admin.wrap(model), beforeDrain: () => admin.close() });
  } catch (error) {
    console.error(`worker startup failed: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
  ports.write(formatWorkerMessage({ type: "ready", socketPath: launch.socketPath, modelId: launch.model.repoId, pid: process.pid }));
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
    void (async () => { while ((await readLine()) !== null) { /* nothing else is expected on stdin */ } })()
      .catch(() => {}).finally(stop);
  });
}

// The process owner exits after the host has released the model; native
// handles the runtime still holds must not keep a stopped worker alive.
if (import.meta.main) process.exit(await runWorkerEntry());
