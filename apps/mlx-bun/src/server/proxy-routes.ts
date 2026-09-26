// The parent's model-scoped route group under --isolate: every request a
// worker serves is forwarded over its Unix socket with the body streaming
// through (hop-by-hop headers stripped, a client abort aborting the proxied
// fetch so the worker sees the disconnect). The five model-routed POSTs are
// buffered to read `model` and go to that id's worker through the pool; every
// other path rides the default worker, or the most recently used resident
// while the default is evicted, without loading a model. The parent answers
// only what it owns: `/engine`, `/health` and `/stats` with the worker's
// contribution and the pool's state, `/downloads` from its own transfer
// owner, `/v1/models` with residency flags, and `/v1/responses` through the
// history client. The worker's private admin paths never forward.
import { describeExit, EngineUnavailableError, type WorkerSupervisor, type WorkerSupervisorState } from "../jobs/worker-supervisor";
import type { PoolReport, WorkerPool } from "../jobs/worker-pool";
import type { createResponsesClient } from "./responses-client";

const HOP_BY_HOP = new Set([
  "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
  "te", "trailer", "transfer-encoding", "upgrade",
]);
/** Answered by the parent's listener alone (501 from the migration list, or
 * the worker's private socket surface), never forwarded. */
const PARENT_ONLY = new Set(["/admin/lease", "/admin/drain", "/v1/memory/synthesize"]);
/** Generation endpoints whose JSON body carries the routing `model` field (main's list). */
export const MODEL_ROUTED = new Set(["/v1/chat/completions", "/v1/completions", "/v1/messages", "/v1/responses", "/v1/embeddings"]);

const encoder = new TextEncoder(), decoder = new TextDecoder();
const stripHopByHop = (headers: Headers) => {
  const excluded = new Set(HOP_BY_HOP);
  for (const name of (headers.get("connection") ?? "").split(",")) excluded.add(name.trim().toLowerCase());
  const out = new Headers();
  headers.forEach((value, key) => { if (!excluded.has(key.toLowerCase())) out.set(key, value); });
  return out;
};

/** The routing key from a buffered JSON body. A body that is not a JSON
 * object with a string `model` routes to the default worker, which answers
 * a malformed body with its own 400; the bytes are forwarded unchanged. */
export function modelField(body: Uint8Array): string | undefined {
  try {
    const value = JSON.parse(decoder.decode(body)) as { model?: unknown } | null;
    return value && typeof value === "object" && typeof value.model === "string" ? value.model : undefined;
  } catch { return undefined; }
}

export interface ProxyRoutesOptions {
  pool: WorkerPool;
  responses: ReturnType<typeof createResponsesClient>;
  /** Progress rows for `GET /downloads`; the parent owns transfers. */
  downloads(): readonly unknown[];
  modelId: string;
  startedAt: number;
}

/** The default worker's fields are null while it is evicted (`state: "evicted"`). */
export interface EngineReport {
  isolated: true;
  state: WorkerSupervisorState | "evicted";
  pid: number | null;
  restarts: number | null;
  socket: string | null;
  model: string;
  last_exit: { code: number | null; signal: string | null } | null;
  response_store: { entries: number; bytes: number; max_bytes: number; ttl_ms: number };
  pool: PoolReport;
}

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

type Observe = (engine: WorkerSupervisor) => void;

export function createProxyRoutes(options: ProxyRoutesOptions) {
  const { pool, responses } = options;
  const report = (): EngineReport => {
    const engine = pool.default;
    return {
      isolated: true, state: engine?.state ?? "evicted", pid: engine?.pid ?? null, restarts: engine?.restarts ?? null,
      socket: engine?.socketPath ?? null, model: engine?.modelId ?? options.modelId, last_exit: engine?.lastExit ?? null,
      response_store: responses.stats, pool: pool.report(),
    };
  };
  const summary = () => {
    const { cap, default: defaultId, resident, loading } = pool.report();
    return { cap, default: defaultId, resident: resident.map(worker => worker.id), loading };
  };
  const unavailableMessage = (error: unknown) => {
    if (error instanceof EngineUnavailableError) return `inference engine unavailable: ${error.message}${error.state === "restarting" ? " — retry shortly" : ""}`;
    return "inference engine unavailable: the engine worker stopped mid-request; respawning — retry shortly";
  };
  const unavailable = (error: unknown, target: WorkerSupervisor | undefined) => Response.json({ error: {
    message: unavailableMessage(error), type: "engine_unavailable",
    state: error instanceof EngineUnavailableError ? error.state : target?.state ?? pool.default?.state ?? "evicted",
  } }, { status: 502 });
  const streamFailure = (engine: WorkerSupervisor) => {
    const exit = engine.lastExit;
    return `inference engine unavailable: the engine worker stopped while streaming this response${exit ? ` (${describeExit(exit)})` : ""}; it is being respawned`;
  };

  /** `childFor`: the worker a request goes to. A model-routed POST is
   * buffered so its `model` field can pick the worker, then forwarded byte
   * for byte; everything else goes where inspection goes, never spawning. */
  const forward = async (request: Request, observe?: Observe): Promise<Response> => {
    request.signal.throwIfAborted();
    const { pathname } = new URL(request.url);
    let engine: WorkerSupervisor, body: BodyInit | null;
    if (request.method === "POST" && MODEL_ROUTED.has(pathname)) {
      const raw = new Uint8Array(await request.arrayBuffer());
      engine = await pool.workerFor(modelField(raw), request.signal);
      body = raw;
    } else {
      engine = pool.inspect() ?? await pool.workerFor(undefined, request.signal);
      body = request.body;
    }
    observe?.(engine);
    const upstream = await engine.fetch(request.url, {
      method: request.method, headers: stripHopByHop(request.headers), body,
      signal: request.signal, redirect: "manual", duplex: "half",
    });
    const headers = stripHopByHop(upstream.headers);
    const stream = upstream.body && (upstream.headers.get("content-type") ?? "").startsWith("text/event-stream")
      ? guardEventStream(upstream.body, () => unavailableFrame(pathname, streamFailure(engine)))
      : upstream.body;
    return new Response(stream, { status: upstream.status, statusText: upstream.statusText, headers });
  };
  const respond = async (request: Request, work: (observe: Observe) => Promise<Response>): Promise<Response> => {
    let target: WorkerSupervisor | undefined;
    try { return await work(engine => { target = engine; }); }
    catch (error) {
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return unavailable(error, target);
    }
  };

  /** The worker's listing, each row flagged with the pool's residency. */
  const models = async (request: Request, observe: Observe): Promise<Response> => {
    const upstream = await forward(request, observe);
    if (!upstream.ok || !(upstream.headers.get("content-type") ?? "").includes("json")) return upstream;
    const body = await upstream.json() as { data?: unknown };
    if (!Array.isArray(body.data)) return Response.json(body, { status: upstream.status, headers: upstream.headers });
    const residentIds = new Set(pool.residents().map(worker => worker.id)), loading = new Set(pool.report().loading);
    const data = body.data.map((row: unknown) => {
      if (!row || typeof row !== "object" || typeof (row as { id?: unknown }).id !== "string") return row;
      const id = (row as { id: string }).id;
      return { ...row, resident: residentIds.has(id), ...(loading.has(id) ? { loading: true } : {}) };
    });
    const headers = new Headers(upstream.headers);
    headers.delete("content-length");
    return Response.json({ ...body, data }, { status: upstream.status, headers });
  };

  const health = async (): Promise<Response> => {
    const engineReport = report();
    const engine = pool.default;
    let contribution: Record<string, unknown> = {};
    if (engine?.state === "ready") {
      try {
        const upstream = await engine.fetch("http://engine/health", { signal: AbortSignal.timeout(2_000) });
        const body = await upstream.json() as Record<string, unknown>;
        if (upstream.ok) contribution = { state: body.state, in_flight: body.in_flight, leases: body.leases };
        else contribution = { state: "unreachable" };
      } catch { contribution = { state: "unreachable" }; }
    }
    const { response_store: _store, isolated: _isolated, pool: _pool, ...worker } = engineReport;
    return Response.json({ status: "ok", isolated: true, engine: { ...worker, ...contribution }, pool: summary() });
  };
  const stats = async (request: Request): Promise<Response> => {
    const own = { response_store: responses.stats, engine: report() };
    const engine = pool.inspect();
    try {
      if (!engine) throw new EngineUnavailableError("closed", null, "no engine worker is resident");
      const upstream = await engine.fetch(request.url, { headers: stripHopByHop(request.headers), signal: request.signal });
      if (!upstream.ok) return new Response(upstream.body, { status: upstream.status, headers: stripHopByHop(upstream.headers) });
      const body = await upstream.json() as Record<string, unknown>;
      return Response.json({ ...body, ...own });
    } catch (error) {
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return Response.json({ server: { owner: "serve", model: options.modelId, started_at: options.startedAt }, ...own,
        unavailable: unavailableMessage(error) });
    }
  };

  return {
    report,
    forward,
    /** A finished download or job changes the library every worker lists. */
    invalidateLibrary: () => pool.invalidateLibrary(),
    async handle(request: Request): Promise<Response | null> {
      const { pathname } = new URL(request.url);
      if (PARENT_ONLY.has(pathname)) return null;
      if (pathname === "/engine") return request.method === "GET" ? Response.json(report()) : null;
      if (request.method === "GET") {
        if (pathname === "/health") return health();
        if (pathname === "/stats") return stats(request);
        if (pathname === "/downloads") return Response.json({ downloads: options.downloads() });
        if (pathname === "/v1/models" || pathname.startsWith("/v1/models/")) return respond(request, observe => models(request, observe));
      }
      if (pathname === "/v1/responses" && request.method === "POST")
        return respond(request, observe => responses.forward(request, inner => forward(inner, observe)));
      return respond(request, observe => forward(request, observe));
    },
  };
}
