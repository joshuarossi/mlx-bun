// The private admin surface an isolation worker serves on its Unix socket,
// ahead of the model routes: readiness for the parent, a connection-owned
// execution lease for managed GPU jobs, a drain that stops admission and
// waits for the work in flight, the model worker's memory task model for the
// parent's synthesis, the worker's event stream (`/admin/events`), and its model's
// adapter operation (`/admin/adapters`). It is
// never mounted on a TCP listener, where every one of these paths is unknown
// (404), as they are on a worker that lacks the capability behind one.
import type { AdapterOperation, EventBus } from "@mlx-bun/app-core";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { MemoryCompletionClient, MemoryCompletionRequest } from "@mlx-bun/module-memory/model";

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
   * `complete` or `completeBatch` on it for the isolated parent's synthesis,
   * under the execution lease; the call that loads it loads exactly the
   * snapshot the call carries. The composition owns it and closes it after
   * `close()` has joined the calls. Without it (or without a lease) there is
   * no such route (404). */
  memoryTaskModel?: { clientFor(signal: AbortSignal, snapshot: string): MemoryCompletionClient };
  /** The worker's own events (its engine's request timings and samples, its model's memory): `GET /admin/events` streams them
   * as JSON lines for the parent, which publishes them on its bus. Without it there is no such route (404). */
  events?: Pick<EventBus, "subscribe">;
  /** The worker's model's `adapters` operation (list, mount, unmount, merge under the engine's lock), which the parent's models module
   * reaches through `POST /admin/adapters`, admitted and drained like model work. Without it there is no such route (404). */
  adapters?: AdapterOperation;
}

/** The body of one private adapter call: `op` names the operation and the rest is its arguments. */
export type WorkerAdapterCall =
  | { op: "list" }
  | { op: "mount"; id: string; path: string }
  | { op: "unmount"; id: string }
  | { op: "merge"; adapters: [string, string]; output: string; scales?: number[] };

function parseAdapterCall(value: unknown): WorkerAdapterCall {
  const body = value as Record<string, unknown> | null;
  if (!body || typeof body !== "object" || Array.isArray(body)) throw new Error("expected a JSON object");
  const text = (field: unknown, name: string) => { if (typeof field !== "string" || !field) throw new Error(`${name} expects a non-empty string`); return field; };
  switch (body.op) {
    case "list": return { op: "list" };
    case "mount": return { op: "mount", id: text(body.id, "id"), path: text(body.path, "path") };
    case "unmount": return { op: "unmount", id: text(body.id, "id") };
    case "merge": {
      const { adapters, scales } = body;
      if (!Array.isArray(adapters) || adapters.length !== 2) throw new Error("adapters expects two directories");
      if (scales !== undefined && (!Array.isArray(scales) || !scales.every(item => typeof item === "number" && Number.isFinite(item)))) throw new Error("scales expects finite numbers");
      return { op: "merge", adapters: [text(adapters[0], "adapters[0]"), text(adapters[1], "adapters[1]")], output: text(body.output, "output"), ...(scales ? { scales: scales as number[] } : {}) };
    }
    default: throw new Error('op expects "list", "mount", "unmount" or "merge"');
  }
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

  // One private adapter call for the parent's models module: it runs on the model this worker holds, under its engine lock.
  const adapters = async (request: Request): Promise<Response> => {
    const operation = options.adapters!;
    let call: WorkerAdapterCall;
    try { call = parseAdapterCall(await request.json()); }
    catch (error) {
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return Response.json({ error: { message: `invalid adapter call: ${describe(error)}`, type: "invalid_request_error" } }, { status: 400 });
    }
    try {
      switch (call.op) {
        case "list": return Response.json({ adapters: await operation.list(request.signal) });
        case "mount": return Response.json({ adapter: await operation.mount(call.id, call.path, request.signal) });
        case "unmount": return Response.json({ removed: await operation.unmount(call.id, request.signal) });
        case "merge": return Response.json({ stats: await operation.merge({ adapters: call.adapters, output: call.output, ...(call.scales ? { scales: call.scales } : {}) }, request.signal) });
      }
    } catch (error) {
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return Response.json({ error: { message: describe(error), type: "adapter_failed" } }, { status: 400 });
    }
  };

  // The parent subscribes to what this worker's engine publishes. Each connection is one subscription, released when
  // the parent leaves or the surface closes; a held connection is not model work, so drain does not wait for it.
  const streams = new Set<() => void>();
  const events = (request: Request): Response => {
    let unsubscribe = () => {}, stop = () => {};
    const stream = new ReadableStream<Uint8Array>({
      start(controller) {
        unsubscribe = options.events!.subscribe("*", event => { try { controller.enqueue(encoder.encode(JSON.stringify(event) + "\n")); } catch { stop(); } });
        stop = () => { streams.delete(stop); unsubscribe(); try { controller.close(); } catch { /* already ended */ } };
        streams.add(stop);
        request.signal.addEventListener("abort", stop, { once: true });
        controller.enqueue(encoder.encode("\n"));
      },
      cancel() { stop(); },
    });
    return new Response(stream, { headers: { "content-type": "application/x-ndjson" } });
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
        if (pathname === "/admin/events" && options.events) return request.method === "GET" ? events(request) : methodNotAllowed("GET");
        if (draining) return Response.json({ error: { message: "worker is draining; no new requests are admitted", type: "draining" } }, { status: 503 });
        inFlight++;
        try {
          // Memory and adapter calls are admitted and drained like model requests.
          if (pathname === "/admin/memory/complete" && options.memoryTaskModel && options.acquireExecutionLease) return request.method === "POST" ? await memory(request) : methodNotAllowed("POST");
          if (pathname === "/admin/adapters" && options.adapters) return request.method === "POST" ? await adapters(request) : methodNotAllowed("POST");
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
      for (const end of [...streams]) end();
      for (const entry of [...held]) {
        entry.release();
        try { entry.controller.close(); } catch { /* already cancelled */ }
      }
      await Promise.allSettled([...pending]);
    },
  };
}
