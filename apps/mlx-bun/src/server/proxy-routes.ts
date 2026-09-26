// The parent's model-scoped route group under --isolate: every request the
// worker serves is forwarded over its Unix socket with the body streaming
// through (hop-by-hop headers stripped, a client abort aborting the proxied
// fetch so the worker sees the disconnect). The parent answers only what it
// owns: `/engine`, `/health` and `/stats` with the worker's contribution,
// `/downloads` from its own transfer owner, and `/v1/responses` through the
// history client. The worker's private admin paths never forward.
import { describeExit, EngineUnavailableError, type WorkerSupervisor } from "../jobs/worker-supervisor";
import type { createResponsesClient } from "./responses-client";

const HOP_BY_HOP = new Set([
  "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
  "te", "trailer", "transfer-encoding", "upgrade",
]);
/** Answered by the parent's listener alone (501 from the migration list, or
 * the worker's private socket surface), never forwarded. */
const PARENT_ONLY = new Set(["/admin/lease", "/admin/drain", "/v1/memory/synthesize"]);

const encoder = new TextEncoder();
const stripHopByHop = (headers: Headers) => {
  const out = new Headers();
  headers.forEach((value, key) => { if (!HOP_BY_HOP.has(key.toLowerCase())) out.set(key, value); });
  return out;
};

export interface ProxyRoutesOptions {
  engine: WorkerSupervisor;
  responses: ReturnType<typeof createResponsesClient>;
  /** Progress rows for `GET /downloads`; the parent owns transfers. */
  downloads(): readonly unknown[];
  modelId: string;
  startedAt: number;
}

export interface EngineReport {
  isolated: true;
  state: WorkerSupervisor["state"];
  pid: number | null;
  restarts: number;
  socket: string;
  model: string;
  last_exit: { code: number | null; signal: string | null } | null;
  response_store: { entries: number; bytes: number; max_bytes: number; ttl_ms: number };
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

export function createProxyRoutes(options: ProxyRoutesOptions) {
  const { engine, responses } = options;
  const report = (): EngineReport => ({
    isolated: true, state: engine.state, pid: engine.pid, restarts: engine.restarts, socket: engine.socketPath,
    model: engine.modelId ?? options.modelId, last_exit: engine.lastExit, response_store: responses.stats,
  });
  const unavailableMessage = (error: unknown) => {
    if (error instanceof EngineUnavailableError) return `inference engine unavailable: ${error.message}${error.state === "restarting" ? " — retry shortly" : ""}`;
    return "inference engine unavailable: the engine worker stopped mid-request; respawning — retry shortly";
  };
  const unavailable = (error: unknown) => Response.json({ error: {
    message: unavailableMessage(error), type: "engine_unavailable", state: engine.state,
  } }, { status: 502 });
  const streamFailure = () => {
    const exit = engine.lastExit;
    return `inference engine unavailable: the engine worker stopped while streaming this response${exit ? ` (${describeExit(exit)})` : ""}; it is being respawned`;
  };

  const forward = async (request: Request): Promise<Response> => {
    request.signal.throwIfAborted();
    const upstream = await engine.fetch(request.url, {
      method: request.method, headers: stripHopByHop(request.headers), body: request.body,
      signal: request.signal, redirect: "manual", duplex: "half",
    });
    const headers = stripHopByHop(upstream.headers);
    const body = upstream.body && (upstream.headers.get("content-type") ?? "").startsWith("text/event-stream")
      ? guardEventStream(upstream.body, () => unavailableFrame(new URL(request.url).pathname, streamFailure()))
      : upstream.body;
    return new Response(body, { status: upstream.status, statusText: upstream.statusText, headers });
  };
  const respond = async (request: Request, work: () => Promise<Response>): Promise<Response> => {
    try { return await work(); }
    catch (error) {
      if (request.signal.aborted) return new Response(null, { status: 499 });
      return unavailable(error);
    }
  };

  const health = async (): Promise<Response> => {
    const engineReport = report();
    let contribution: Record<string, unknown> = {};
    if (engine.state === "ready") {
      try {
        const upstream = await engine.fetch("http://engine/health", { signal: AbortSignal.timeout(2_000) });
        const body = await upstream.json() as Record<string, unknown>;
        if (upstream.ok) contribution = { state: body.state, in_flight: body.in_flight, leases: body.leases };
        else contribution = { state: "unreachable" };
      } catch { contribution = { state: "unreachable" }; }
    }
    const { response_store: _store, isolated: _isolated, ...worker } = engineReport;
    return Response.json({ status: "ok", isolated: true, engine: { ...worker, ...contribution } });
  };
  const stats = async (request: Request): Promise<Response> => {
    const own = { response_store: responses.stats, engine: report() };
    try {
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
    /** A finished download or job changes the library the worker lists. */
    invalidateLibrary() {
      if (engine.state !== "ready") return;
      void engine.fetch("http://engine/library?refresh=1").then(response => response.arrayBuffer()).catch(() => {});
    },
    async handle(request: Request): Promise<Response | null> {
      const { pathname } = new URL(request.url);
      if (PARENT_ONLY.has(pathname)) return null;
      if (pathname === "/engine") return request.method === "GET" ? Response.json(report()) : null;
      if (request.method === "GET") {
        if (pathname === "/health") return health();
        if (pathname === "/stats") return stats(request);
        if (pathname === "/downloads") return Response.json({ downloads: options.downloads() });
      }
      if (pathname === "/v1/responses" && request.method === "POST")
        return respond(request, () => responses.forward(request, forward));
      return respond(request, () => forward(request));
    },
  };
}
