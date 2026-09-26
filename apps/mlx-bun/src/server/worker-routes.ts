// The private admin surface an isolation worker serves on its Unix socket,
// ahead of the model routes: readiness for the parent, a connection-owned
// execution lease for managed GPU jobs, and a drain that stops admission and
// waits for the work in flight. It is never mounted on a TCP listener, where
// these paths keep answering 501 from the migration list.
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";

export interface WorkerRouteGroup { handle(request: Request): Promise<Response | null> }

export type WorkerState = "ready" | "draining";

export interface WorkerRoutesOptions {
  /** The `/v1/models` id the parent addresses this worker by. */
  modelId: string;
  /** The host's exclusive execution lease: it resolves once generation in
   * flight has finished, so drain waits on it and jobs hold it. */
  acquireExecutionLease(signal: AbortSignal): Promise<DisposableResource>;
  /** Drain waits at most this long for in-flight work; a request body may
   * lower it (`timeout_ms`). Default 120 s, the app's shutdown deadline. */
  drainTimeoutMs?: number;
  pid?: number;
}

const encoder = new TextEncoder();
const methodNotAllowed = (allow: string) => Response.json({ error: { message: `use ${allow}` } }, { status: 405, headers: { allow } });

/** The group is a wrapper so it can count the model requests it admits;
 * streaming bodies outlive `handle`, and the execution lease covers those. */
export function createWorkerRoutes(options: WorkerRoutesOptions) {
  let draining = false, inFlight = 0, closed = false;
  const idleWaiters = new Set<() => void>();
  /** Aborted by close(): every pending lease acquisition composes with it, and close joins them. */
  const shutdown = new AbortController();
  const pending = new Set<Promise<unknown>>();
  const track = <T>(work: Promise<T>): Promise<T> => {
    pending.add(work);
    work.finally(() => { pending.delete(work); }).catch(() => {});
    return work;
  };
  const held = new Set<{ release(): void; controller: ReadableStreamDefaultController<Uint8Array> }>();
  const state = (): WorkerState => draining ? "draining" : "ready";
  const health = () => Response.json({ status: "ok", state: state(), model: options.modelId,
    pid: options.pid ?? process.pid, in_flight: inFlight, leases: held.size });

  // A parent-managed GPU job holds this response open. The connection owns
  // the lease, so the parent dying cannot strand the worker's execution lock.
  const lease = async (request: Request): Promise<Response> => {
    const closing = () => Response.json({ error: { message: "worker is closing", type: "unavailable" } }, { status: 503 });
    if (closed) return closing();
    let lease: DisposableResource;
    try { lease = await track(options.acquireExecutionLease(AbortSignal.any([request.signal, shutdown.signal]))); }
    catch (error) {
      if (closed) return closing();
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return Response.json({ error: { message: `execution lease failed: ${error instanceof Error ? error.message : String(error)}`, type: "lease_failed" } }, { status: 503 });
    }
    // The acquisition may have resolved after close() ran: never publish a lease then.
    if (closed || request.signal.aborted) { lease.dispose(); return closed ? closing() : new Response(null, { status: 499 }); }
    const entry = { release: () => {}, controller: undefined as unknown as ReadableStreamDefaultController<Uint8Array> };
    let released = false;
    entry.release = () => {
      if (released) return;
      released = true;
      held.delete(entry);
      request.signal.removeEventListener("abort", entry.release);
      lease.dispose();
    };
    held.add(entry);
    request.signal.addEventListener("abort", entry.release, { once: true });
    if (request.signal.aborted) entry.release();
    return new Response(new ReadableStream<Uint8Array>({
      start(controller) { entry.controller = controller; controller.enqueue(encoder.encode("leased\n")); },
      cancel() { entry.release(); },
    }), { headers: { "content-type": "application/octet-stream" } });
  };

  // Drain: no new model request is admitted from now on (503), then wait for
  // the admitted ones to return and for generation to quiesce, within the
  // deadline. The report is honest either way; the gate stays shut.
  const drain = async (request: Request): Promise<Response> => {
    let timeoutMs = options.drainTimeoutMs ?? 120_000;
    const text = await request.text();
    if (text.trim()) {
      let body: { timeout_ms?: unknown };
      try { body = JSON.parse(text) as typeof body; } catch { return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 }); }
      if (body.timeout_ms !== undefined) {
        if (typeof body.timeout_ms !== "number" || !(body.timeout_ms >= 0)) return Response.json({ error: { message: "timeout_ms expects a number >= 0" } }, { status: 400 });
        timeoutMs = body.timeout_ms;
      }
    }
    draining = true;
    const started = Date.now();
    const signal = AbortSignal.any([request.signal, AbortSignal.timeout(timeoutMs), shutdown.signal]);
    let drained = false;
    try {
      await new Promise<void>((resolve, reject) => {
        if (inFlight === 0) return resolve();
        // A signal aborted before we listen would never fire the listener.
        if (signal.aborted) return reject(signal.reason);
        const wake = () => { idleWaiters.delete(wake); signal.removeEventListener("abort", stop); resolve(); };
        const stop = () => { idleWaiters.delete(wake); reject(signal.reason); };
        idleWaiters.add(wake);
        signal.addEventListener("abort", stop, { once: true });
      });
      (await track(options.acquireExecutionLease(signal))).dispose();
      drained = !closed;
    } catch (error) { if (!signal.aborted) throw error; }
    return Response.json({ drained, state: state(), model: options.modelId, in_flight: inFlight, leases: held.size,
      waited_ms: Date.now() - started, timed_out: !drained && !request.signal.aborted });
  };

  return {
    state,
    wrap(model: WorkerRouteGroup): WorkerRouteGroup {
      return { async handle(request) {
        const { pathname } = new URL(request.url);
        if (pathname === "/health") return request.method === "GET" ? health() : methodNotAllowed("GET");
        if (pathname === "/admin/lease") return request.method === "POST" ? lease(request) : methodNotAllowed("POST");
        if (pathname === "/admin/drain") return request.method === "POST" ? drain(request) : methodNotAllowed("POST");
        if (draining) return Response.json({ error: { message: "worker is draining; no new requests are admitted", type: "draining" } }, { status: 503 });
        inFlight++;
        try { return await model.handle(request); }
        finally { if (--inFlight === 0) for (const wake of [...idleWaiters]) wake(); }
      } };
    },
    /** Shutdown: refuse new leases, cancel pending acquisitions and join them,
     * and release every connection-held lease and end its stream, so the
     * listener's graceful stop is not waiting on a job's open connection. */
    async close(): Promise<void> {
      closed = true;
      shutdown.abort(new Error("worker admin surface closed"));
      for (const entry of [...held]) {
        entry.release();
        try { entry.controller.close(); } catch { /* already cancelled */ }
      }
      await Promise.allSettled([...pending]);
    },
  };
}
