// The isolated host's route group: what the parent owns, and the way a request
// reaches a model worker. Each resident model runs in its own worker process;
// the model router (model-routes.ts) picks the model a request names and leases
// its worker, and `forwardToWorker` sends the request over the worker's Unix
// socket with the body streaming through (hop-by-hop headers stripped, a client
// abort aborting the proxied fetch so the worker sees the disconnect). The
// parent answers `/engine`, `/health` and `/stats` (with the workers'
// contribution) and `/v1/responses` through the history client. The workers' private admin paths never forward.
import type { WorkerMemory } from "../jobs/worker-memory";
import { describeExit, EngineUnavailableError, type WorkerSupervisor, type WorkerSupervisorState } from "../jobs/worker-supervisor";
import type { createResponsesClient } from "./responses-client";

const HOP_BY_HOP = new Set([
  "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
  "te", "trailer", "transfer-encoding", "upgrade",
]);
/** Never forwarded to a worker: its private socket surface (which only the
 * parent itself calls; unmatched here, the listener answers 404) and the
 * parent's own synthesis route (served by its earlier group). */
const PARENT_ONLY = new Set(["/admin/lease", "/admin/drain", "/admin/memory/complete", "/admin/events", "/admin/adapters", "/v1/memory/synthesize"]);

const encoder = new TextEncoder();
/** A copy without the hop-by-hop headers and the ones `Connection` names
 * (also used by the library host, `cli/library-host.ts`). */
export const stripHopByHop = (headers: Headers) => {
  const excluded = new Set(HOP_BY_HOP);
  for (const name of (headers.get("connection") ?? "").split(",")) excluded.add(name.trim().toLowerCase());
  const out = new Headers();
  headers.forEach((value, key) => { if (!excluded.has(key.toLowerCase())) out.set(key, value); });
  return out;
};

/** The SSE error frame each protocol's own error path emits, so a client
 * parser ends the stream with an error instead of a silent truncation. */
export function unavailableFrame(pathname: string, message: string): string {
  if (pathname === "/v1/messages")
    return `event: error\ndata: ${JSON.stringify({ type: "error", error: { type: "api_error", message } })}\n\n`;
  if (pathname === "/v1/responses")
    return `event: error\ndata: ${JSON.stringify({ type: "error", code: "engine_unavailable", message, param: null })}\n\n`;
  return `data: ${JSON.stringify({ error: { message, type: "engine_unavailable" } })}\n\n`;
}

/** Pass an event stream through unchanged; when the worker dies under it,
 * end with the protocol's error frame instead of dropping the connection. */
function guardEventStream(body: ReadableStream<Uint8Array>, failure: () => string): ReadableStream<Uint8Array> {
  const reader = body.getReader();
  return new ReadableStream<Uint8Array>({
    async pull(controller) {
      let item: Awaited<ReturnType<typeof reader.read>>;
      try { item = await reader.read(); }
      catch { controller.enqueue(encoder.encode(failure())); controller.close(); return; }
      if (item.done) controller.close(); else controller.enqueue(item.value);
    },
    cancel(reason) { return reader.cancel(reason).catch(() => {}); },
  });
}

export interface WorkerEngine {
  readonly id: string;
  readonly role: "primary" | "companion";
  readonly supervisor: WorkerSupervisor;
  /** The MLX memory the worker last reported; undefined before its first report and while it is down. */
  measured?(): WorkerMemory | undefined;
}

export interface ProxyRoutesOptions {
  /** The resident workers, and the id of the model requests that name none are answered by. */
  workers(): readonly WorkerEngine[];
  current(): string;
  /** The model router: it leases the worker a request belongs to and forwards to it. */
  models: { handle(request: Request): Promise<Response | null> };
  responses: ReturnType<typeof createResponsesClient>;
  /** The model the server started with. */
  modelId: string;
  startedAt: number;
}

/** `memory` is the worker's own MLX reading (`active_bytes` and `cache_bytes` are what residency counts), null until it reports. */
export interface WorkerReport { id: string; role: "primary" | "companion"; pid: number | null; state: WorkerSupervisorState; restarts: number; socket: string;
  memory: { active_bytes: number; cache_bytes: number; peak_bytes: number } | null }

/** The current model's worker fields, then every resident worker. `state` is `none` while no worker is resident. */
export interface EngineReport {
  isolated: true;
  state: WorkerSupervisorState | "none";
  pid: number | null;
  restarts: number | null;
  socket: string | null;
  model: string;
  last_exit: { code: number | null; signal: string | null } | null;
  response_store: { entries: number; bytes: number; max_bytes: number; ttl_ms: number };
  workers: WorkerReport[];
}

const unavailableMessage = (error: unknown) => {
  if (error instanceof EngineUnavailableError) return `inference engine unavailable: ${error.message}${error.state === "restarting" ? " — retry shortly" : ""}`;
  return "inference engine unavailable: the engine worker stopped mid-request; respawning — retry shortly";
};
/** The 502 a request gets when its worker cannot take it. */
export function workerUnavailable(error: unknown, worker: WorkerSupervisor): Response {
  return Response.json({ error: { message: unavailableMessage(error), type: "engine_unavailable",
    state: error instanceof EngineUnavailableError ? error.state : worker.state } }, { status: 502 });
}

/** The request goes to the worker as it came, its body streaming through. A worker that cannot take it, or dies under
 * it, answers with the protocol's own unavailable error; nothing is retried. */
export async function forwardToWorker(worker: WorkerSupervisor, request: Request): Promise<Response> {
  const { pathname } = new URL(request.url);
  try {
    request.signal.throwIfAborted();
    const upstream = await worker.fetch(request.url, {
      method: request.method, headers: stripHopByHop(request.headers), body: request.body,
      signal: request.signal, redirect: "manual", duplex: "half",
    });
    const headers = stripHopByHop(upstream.headers);
    const failure = () => {
      const exit = worker.lastExit;
      return `inference engine unavailable: the engine worker stopped while streaming this response${exit ? ` (${describeExit(exit)})` : ""}; it is being respawned`;
    };
    const stream = upstream.body && (upstream.headers.get("content-type") ?? "").startsWith("text/event-stream")
      ? guardEventStream(upstream.body, () => unavailableFrame(pathname, failure()))
      : upstream.body;
    return new Response(stream, { status: upstream.status, statusText: upstream.statusText, headers });
  } catch (error) {
    if (request.signal.aborted) return new Response(null, { status: 499 });
    return workerUnavailable(error, worker);
  }
}

export function createProxyRoutes(options: ProxyRoutesOptions) {
  const { responses } = options;
  const currentWorker = () => options.workers().find(worker => worker.id === options.current() && worker.role === "primary")?.supervisor;
  const report = (): EngineReport => {
    const engine = currentWorker();
    return {
      isolated: true, state: engine?.state ?? "none", pid: engine?.pid ?? null, restarts: engine?.restarts ?? null,
      socket: engine?.socketPath ?? null, model: options.current(), last_exit: engine?.lastExit ?? null, response_store: responses.stats,
      workers: options.workers().map(({ id, role, supervisor, measured }) => {
        const memory = measured?.();
        return { id, role, pid: supervisor.pid, state: supervisor.state, restarts: supervisor.restarts, socket: supervisor.socketPath,
          memory: memory ? { active_bytes: memory.activeBytes, cache_bytes: memory.cacheBytes, peak_bytes: memory.peakBytes } : null };
      }),
    };
  };
  const health = async (): Promise<Response> => {
    const engine = currentWorker();
    let contribution: Record<string, unknown> = {};
    if (engine?.state === "ready") {
      try {
        const upstream = await engine.fetch("http://engine/health", { signal: AbortSignal.timeout(2_000) });
        const body = await upstream.json() as Record<string, unknown>;
        if (upstream.ok) contribution = { state: body.state, in_flight: body.in_flight, leases: body.leases };
        else contribution = { state: "unreachable" };
      } catch { contribution = { state: "unreachable" }; }
    }
    const { response_store: _store, isolated: _isolated, workers, ...current } = report();
    return Response.json({ status: "ok", isolated: true, engine: { ...current, ...contribution }, workers });
  };
  const stats = async (request: Request): Promise<Response> => {
    const own = { response_store: responses.stats, engine: report() };
    const upstream = await options.models.handle(request).catch(() => null);
    if (upstream?.ok && (upstream.headers.get("content-type") ?? "").includes("json"))
      return Response.json({ ...(await upstream.json() as Record<string, unknown>), ...own });
    if (upstream && !upstream.ok && upstream.status !== 502) return upstream;
    // The worker's own reason (a 502 from the forward), else that no worker is resident.
    const reason = await upstream?.json().then((body: { error?: { message?: string } }) => body.error?.message).catch(() => undefined);
    if (request.signal.aborted) return new Response(null, { status: 499 });
    return Response.json({ server: { owner: "serve", model: options.current(), started_at: options.startedAt }, ...own,
      unavailable: reason ?? "inference engine unavailable: no model worker is resident" });
  };

  return {
    report,
    async handle(request: Request): Promise<Response | null> {
      const { pathname } = new URL(request.url);
      if (PARENT_ONLY.has(pathname)) return null;
      if (pathname === "/engine") return request.method === "GET" ? Response.json(report()) : null;
      if (request.method === "GET") {
        if (pathname === "/health") return health();
        if (pathname === "/stats") return stats(request);
      }
      if (pathname === "/v1/responses" && request.method === "POST")
        return responses.forward(request, async inner => await options.models.handle(inner) ?? Response.json({ error: { message: "Not found" } }, { status: 404 }));
      return options.models.handle(request);
    },
  };
}
