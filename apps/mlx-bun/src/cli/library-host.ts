// `openIsolatedHost` behind the public `mlx-bun/engine` entry (engine-entry.ts),
// imported only when a host is opened: one full-app worker (the `__worker` app
// launch form, worker-entry.ts) on a private Unix socket, supervised with the
// CLI's restart budget (jobs/worker-supervisor.ts) and shutdown deadline, and
// adapted to the `EngineHost` contract main's EngineChild implemented. The
// worker runs `runServe` from `["--model", model, ...arguments]`, so the host
// forwards to the whole app: completions, discovery, jobs, sessions, memory.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { WORKER_PROTOCOL_VERSION } from "../jobs/worker-process";
import { superviseWorker, type WorkerSupervisor, type WorkerSupervisorOptions } from "../jobs/worker-supervisor";
import type { EngineHost } from "../server/client";
import { stripHopByHop } from "../server/proxy-routes";
import { shutdownTimeoutMs, validateAppLaunchArgv } from "./serve";
import type { AppWorkerLaunch } from "./worker-entry";

/** `openIsolatedHost`'s options; engine-entry.ts documents them. */
export interface IsolatedHostOptions { arguments?: readonly string[]; command?: readonly string[]; readyTimeoutMs?: number }

/** Internal (tests), never a public option: stand-ins for this module's path
 * (the compiled-consumer check), process creation, and the restart budget. */
export interface LibraryHostSeams {
  modulePath?: string;
  spawn?: WorkerSupervisorOptions["spawn"];
  restarts?: WorkerSupervisorOptions["restarts"];
}

/** Main's rule: a source or package consumer runs this package's CLI source
 * under its own Bun; a compiled consumer's executable is not the mlx-bun CLI,
 * so it must name one. */
function workerCommand(command: readonly string[] | undefined, modulePath: string): readonly string[] {
  if (!command && modulePath.includes("$bunfs"))
    throw new Error("a compiled library consumer must supply the mlx-bun executable as command");
  const resolved = command ?? [process.execPath, fileURLToPath(new URL("./main.ts", import.meta.url))];
  if (!resolved.length) throw new Error("engine command must not be empty");
  return resolved;
}

/** Refuses what the CLI would refuse before anything is spawned, starts the
 * worker, and resolves once it serves. A worker that fails before ready is
 * stopped and its socket directory removed; the rejection is its reason. */
export async function openLibraryHost(model: string, options: IsolatedHostOptions = {}, seams: LibraryHostSeams = {}): Promise<EngineHost<Request, Response>> {
  if (typeof model !== "string" || !model.trim())
    throw new Error("openIsolatedHost needs a model: an empty query selects one automatically and may download the starter model");
  const argv = ["--model", model, ...(options.arguments ?? [])];
  validateAppLaunchArgv(argv);
  const command = workerCommand(options.command, seams.modulePath ?? fileURLToPath(import.meta.url));
  // A private 0700 directory, as in the isolated server: a short path within the
  // 104-byte socket limit, removed after the worker has exited.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  const socketPath = join(socketDir, "engine.sock");
  const launch: AppWorkerLaunch = { kind: "app", version: WORKER_PROTOCOL_VERSION, socketPath, argv };
  // The worker's app closes under the CLI's deadline; the parent drains and
  // then waits that long after SIGTERM before SIGKILL.
  const budget = shutdownTimeoutMs();
  let supervisor: WorkerSupervisor;
  try {
    supervisor = superviseWorker({ command, socketPath, launch, drainTimeoutMs: budget, graceMs: budget,
      ...(options.readyTimeoutMs !== undefined ? { readyTimeoutMs: options.readyTimeoutMs } : {}),
      // The worker's own output reaches the consumer's console unprefixed, as main's inherited stdio did.
      log: line => console.log(line), error: line => console.error(line),
      ...(seams.spawn ? { spawn: seams.spawn } : {}), ...(seams.restarts ? { restarts: seams.restarts } : {}) });
  } catch (error) { removeSocketDir(); throw error; }
  const host = supervisedHost(supervisor, removeSocketDir);
  try { await supervisor.ready; }
  catch (error) { await host.close(); throw error; }
  return host;
}

/** Main's EngineChild forwarding over the supervisor: wait (abortably) for a
 * serving worker, strip hop-by-hop headers both ways, stream both bodies,
 * retry a GET or HEAD once after 250 ms, never replay anything else. */
function supervisedHost(supervisor: WorkerSupervisor, removeSocketDir: () => void): EngineHost<Request, Response> {
  let closing: Promise<void> | undefined;
  const closed = () => new Error("engine host is closed");
  // After close the supervisor's refusals ("shutting down", an aborted fetch)
  // mean the host is closed; a caller's own abort keeps its reason.
  const rethrow = (error: unknown, signal?: AbortSignal): never => { throw closing && !signal?.aborted ? closed() : error; };
  const forwardOnce = async (request: Request): Promise<Response> => {
    if (closing) throw closed();
    request.signal.throwIfAborted();
    // Startup or a respawn: nothing is sent until a worker serves.
    try { await supervisor.whenReady(request.signal); } catch (error) { rethrow(error, request.signal); }
    if (closing) throw closed();
    request.signal.throwIfAborted();
    let upstream: Response;
    try {
      upstream = await supervisor.fetch(request.url, { method: request.method, headers: stripHopByHop(request.headers),
        body: request.body, signal: request.signal, redirect: "manual", duplex: "half" });
    } catch (error) { return rethrow(error, request.signal); }
    return new Response(upstream.body, { status: upstream.status, headers: stripHopByHop(upstream.headers) });
  };
  return {
    /** Follows the current worker: pending during a respawn, rejected once the restart budget is spent or the host is closed. */
    get ready() {
      const ready = closing ? Promise.reject(closed()) : supervisor.whenReady().catch(error => rethrow(error));
      ready.catch(() => {}); // observed by whoever reads it
      return ready;
    },
    async forward(request) {
      try { return await forwardOnce(request); }
      catch (error) {
        // A bodyless request that raced a worker exit waits out the respawn once.
        if ((request.method !== "GET" && request.method !== "HEAD") || request.signal.aborted || closing) throw error;
        await new Promise(resolve => setTimeout(resolve, 250));
        return await forwardOnce(request);
      }
    },
    /** Drain, SIGTERM, SIGKILL after the grace; the socket directory goes once the worker has exited. */
    close() {
      return closing ??= (async () => { try { await supervisor.close(); } finally { removeSocketDir(); } })();
    },
  };
}
