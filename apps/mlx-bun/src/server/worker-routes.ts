// The private admin surface an isolation worker serves on its Unix socket,
// ahead of the model routes: readiness for the parent, a connection-owned
// execution lease for managed GPU jobs, a drain that stops admission and
// waits for the work in flight, the model worker's memory task model for the
// parent's synthesis, and the two things the parent asks of the model host it
// does not own: switch the served model (`/admin/serve`) and list the snapshots
// it holds resident (`/admin/served`). It is never mounted on a TCP listener,
// where every one of these paths is unknown (404), as they are on a worker
// that lacks the capability behind one.
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { MemoryCompletionClient, MemoryCompletionRequest } from "../memory/model";

export interface WorkerRouteGroup { handle(request: Request): Promise<Response | null> }

export type WorkerState = "ready" | "draining";

export interface WorkerRoutesOptions {
  /** The `/v1/models` id the parent addresses this worker by. */
  modelId: string;
  /** The host's exclusive execution lease: it resolves once generation in
   * flight has finished, so drain waits on it and jobs hold it. A host without
   * one (the transcription-only app) has no `/admin/lease` route (404) and
   * drains on admitted requests alone. */
  acquireExecutionLease?(signal: AbortSignal): Promise<DisposableResource>;
  /** Drain waits at most this long for in-flight work; a request body may
   * lower it (`timeout_ms`). Default 120 s, the app's shutdown deadline. */
  drainTimeoutMs?: number;
  pid?: number;
  /** The model form's memory task model (Gemma-4 e4b with its chunk adapter,
   * loaded by the first call): `POST /admin/memory/complete` runs one memory
   * `complete` or `completeBatch` on it for the `--isolate` parent's synthesis,
   * under the execution lease; the call that loads it loads exactly the
   * snapshot the call carries. The composition owns it and closes it after
   * `close()` has joined the calls. Without it (or without a lease) there is
   * no such route (404). */
  memoryTaskModel?: { clientFor(signal: AbortSignal, snapshot: string): MemoryCompletionClient };
  /** Make a local model the served one (the host's `serve`): `POST /admin/serve` with `{ model }`. Rejects with a status-carrying error (`status`). Without it there is no such route (404). */
  serve?(model: string, signal: AbortSignal): Promise<{ model: string; record?: unknown }>;
  /** Snapshots of the models the host holds resident: `GET /admin/served`. Without it there is no such route (404). */
  servedPaths?(): readonly string[];
}

/** The private memory call's body: one `complete` (a single row) or one
 * `completeBatch`, and `snapshot`, the task model directory the parent
 * selected and retains on this worker, the one a loading call loads. */
export interface WorkerMemoryCall { call: "complete" | "completeBatch"; snapshot: string; requests: MemoryCompletionRequest[] }

function parseMemoryCall(value: unknown): WorkerMemoryCall {
  const body = value as { call?: unknown; snapshot?: unknown; requests?: unknown } | null;
  if (!body || typeof body !== "object" || (body.call !== "complete" && body.call !== "completeBatch"))
    throw new Error('call expects "complete" or "completeBatch"');
  if (typeof body.snapshot !== "string" || !body.snapshot) throw new Error("snapshot expects the selected task model directory");
  if (!Array.isArray(body.requests) || (body.call === "complete" && body.requests.length !== 1))
    throw new Error(body.call === "complete" ? "complete expects exactly one request" : "requests expects an array");
  const requests = body.requests.map((row: unknown, index): MemoryCompletionRequest => {
    const { stage, input, maxTokens } = (row ?? {}) as { stage?: unknown; input?: { system?: unknown; user?: unknown } | null; maxTokens?: unknown };
    if (typeof stage !== "string" || !stage || !input || typeof input !== "object" || typeof input.user !== "string" ||
      (input.system !== undefined && typeof input.system !== "string") || typeof maxTokens !== "number" || !Number.isSafeInteger(maxTokens) || maxTokens < 1)
      throw new Error(`requests[${index}] expects { stage, input: { system?, user }, maxTokens >= 1 }`);
    return { stage, input: { ...(input.system !== undefined ? { system: input.system as string } : {}), user: input.user }, maxTokens };
  });
  return { call: body.call, snapshot: body.snapshot, requests };
}

const encoder = new TextEncoder();
const describe = (error: unknown) => error instanceof Error ? error.message : String(error);
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
  const closing = () => Response.json({ error: { message: "worker is closing", type: "unavailable" } }, { status: 503 });

  // A parent-managed GPU job holds this response open. The connection owns
  // the lease, so the parent dying cannot strand the worker's execution lock.
  const lease = async (request: Request): Promise<Response> => {
    const acquire = options.acquireExecutionLease!;
    if (closed) return closing();
    let lease: DisposableResource;
    try { lease = await track(acquire(AbortSignal.any([request.signal, shutdown.signal]))); }
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

  // The parent's synthesis sends one memory stage call or batch; the ordered
  // raw outputs answer it (`{ outputs }`). The execution lease is taken before
  // the task model's lazy load (of the call's snapshot) and released only
  // after every row has joined, so memory work never overlaps generation or a
  // managed job's lease. The parent disconnecting (a cancelled run, its
  // shutdown) or close() aborts the rows; close() joins them.
  const memory = async (request: Request): Promise<Response> => {
    const task = options.memoryTaskModel!, acquire = options.acquireExecutionLease!;
    if (closed) return closing();
    let body: WorkerMemoryCall;
    try { body = parseMemoryCall(await request.json()); }
    catch (error) {
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return Response.json({ error: { message: `invalid memory call: ${describe(error)}`, type: "invalid_request_error" } }, { status: 400 });
    }
    const signal = AbortSignal.any([request.signal, shutdown.signal]);
    try {
      const outputs = await track((async () => {
        const exclusive = await acquire(signal);
        try {
          signal.throwIfAborted();
          const client = task.clientFor(signal, body.snapshot);
          return body.call === "complete" ? [await client.complete(body.requests[0]!)] : await client.completeBatch(body.requests);
        } finally { exclusive.dispose(); }
      })());
      return Response.json({ outputs });
    } catch (error) {
      if (closed) return closing();
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return Response.json({ error: { message: describe(error), type: "memory_failed" } }, { status: 500 });
    }
  };

  // The parent asks the host it does not own to switch the served model. The
  // host answers with what it now serves, or with the reason it could not
  // (an id that is not local, a model that failed to load).
  const serve = async (request: Request): Promise<Response> => {
    let model: unknown;
    try { model = ((await request.json()) as { model?: unknown } | null)?.model; }
    catch { return request.signal.aborted ? new Response(null, { status: 499 }) : Response.json({ error: { message: "invalid JSON body" } }, { status: 400 }); }
    if (typeof model !== "string" || !model.trim()) return Response.json({ error: { message: 'missing "model"', type: "invalid_request_error" } }, { status: 400 });
    if (closed) return closing();
    try { return Response.json(await track(options.serve!(model.trim(), AbortSignal.any([request.signal, shutdown.signal])))); }
    catch (error) {
      if (closed) return closing();
      if (request.signal.aborted) return new Response(null, { status: 499 });
      const status = typeof (error as { status?: unknown })?.status === "number" ? (error as { status: number }).status : 500;
      return Response.json({ error: { message: describe(error), type: "serve_failed" } }, { status });
    }
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
      if (options.acquireExecutionLease) (await track(options.acquireExecutionLease(signal))).dispose();
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
        if (pathname === "/admin/lease" && options.acquireExecutionLease) return request.method === "POST" ? lease(request) : methodNotAllowed("POST");
        if (pathname === "/admin/drain") return request.method === "POST" ? drain(request) : methodNotAllowed("POST");
        if (pathname === "/admin/served" && options.servedPaths) return request.method === "GET" ? Response.json({ paths: options.servedPaths() }) : methodNotAllowed("GET");
        if (draining) return Response.json({ error: { message: "worker is draining; no new requests are admitted", type: "draining" } }, { status: 503 });
        inFlight++;
        try {
          // Memory calls are admitted and drained like model requests.
          if (pathname === "/admin/memory/complete" && options.memoryTaskModel && options.acquireExecutionLease) return request.method === "POST" ? await memory(request) : methodNotAllowed("POST");
          if (pathname === "/admin/serve" && options.serve) return request.method === "POST" ? await serve(request) : methodNotAllowed("POST");
          return await model.handle(request);
        } finally { if (--inFlight === 0) for (const wake of [...idleWaiters]) wake(); }
      } };
    },
    /** Shutdown: refuse new leases and memory calls, cancel pending
     * acquisitions and memory calls and join them (every row settled), and
     * release every connection-held lease and end its stream, so the
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
