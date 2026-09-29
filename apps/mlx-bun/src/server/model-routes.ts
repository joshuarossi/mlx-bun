// Routes model-scoped requests to the model that should answer them. The five
// generation endpoints carry a `model` id in the JSON body: an exact local id
// (the ones `/v1/models` lists) leases that model from the model host, loading
// it (and draining another) when it is not resident; anything else (no id, an
// alias such as Pi's `local`, a name another server would know) is answered by
// the current model. Every other model-scoped path (`/stats`, `/fit`, cache
// administration, adapters) belongs to the current model too. The response
// body holds the lease until it ends, so a model is never released under a
// stream. `/v1/models` and `/library` list every local model with which are
// resident and which is current; `/stats` adds the host's residency.
import type { ResidencyHost, ResidentUnit } from "../engine/model-residency";
import { ResidencyError } from "../engine/model-residency";
import { errorResponse } from "./http";
import { RequestError } from "./pipeline";

/** Generation endpoints whose JSON body carries the routing `model` field. */
export const MODEL_ROUTED = new Set(["/v1/chat/completions", "/v1/completions", "/v1/messages", "/v1/responses", "/v1/embeddings"]);

const decoder = new TextDecoder();
/** The routing key from a buffered JSON body. A body that is not a JSON object with a string `model` names no model; the current model answers it and its own parser rejects a malformed body. */
export function modelField(body: Uint8Array | string): string | undefined {
  try {
    const value = JSON.parse(typeof body === "string" ? body : decoder.decode(body)) as { model?: unknown } | null;
    return value && typeof value === "object" && typeof value.model === "string" ? value.model : undefined;
  } catch { return undefined; }
}

/** A unit whose model-scoped routes this router can delegate to. */
export interface RoutedUnit extends ResidentUnit {
  readonly routes: { handle(request: Request): Promise<Response | null> };
}

export interface ModelRoutesOptions<U extends RoutedUnit> {
  host: Pick<ResidencyHost<U>, "acquire" | "peek" | "resident" | "policy">;
  /** The model that answers requests naming no local model. */
  current(): string;
  /** Whether `id` is an exact id this host can serve (the ids `/v1/models` lists), resident or not. */
  serves(id: string): Promise<boolean>;
}

/** A response that keeps its lease until the body has ended, been cancelled, or failed. */
function holding(response: Response, release: () => void): Response {
  if (!response.body) { release(); return response; }
  const reader = response.body.getReader();
  let done = false;
  const finish = () => { if (!done) { done = true; release(); } };
  const body = new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const chunk = await reader.read();
        if (chunk.done) { finish(); controller.close(); } else controller.enqueue(chunk.value);
      } catch (error) { finish(); controller.error(error); }
    },
    cancel(reason) { finish(); return reader.cancel(reason).catch(() => {}); },
  });
  return new Response(body, { status: response.status, statusText: response.statusText, headers: response.headers });
}

/** The typed answer for a model that could not be leased. */
function unavailable(error: unknown, context: string, signal: AbortSignal): Response {
  if (error instanceof ResidencyError) {
    const status = error.code === "load-failed" ? 502 : error.code === "closed" ? 503 : 400;
    const type = error.code === "load-failed" ? "model_load_failed" : error.code === "closed" ? "server_closing" : "invalid_request_error";
    return errorResponse(new RequestError(status, error.message, { message: error.message, type, code: error.code }), context, undefined, signal);
  }
  return errorResponse(error, context, undefined, signal);
}

export function createModelRoutes<U extends RoutedUnit>(options: ModelRoutesOptions<U>) {
  const { host } = options;
  /** The unit that answers model-scoped requests that name no model, without loading anything. */
  const active = (): U | undefined => {
    const current = host.peek(options.current());
    if (current) return current;
    const latest = host.resident().filter(model => model.state === "ready").sort((a, b) => b.lastUsedAt - a.lastUsedAt)[0];
    return latest ? host.peek(latest.id) : undefined;
  };
  const listing = async (request: Request, path: string): Promise<Response | null> => {
    const unit = active();
    return unit ? await unit.routes.handle(new Request(new URL(path, request.url), { headers: request.headers, signal: request.signal })) : null;
  };
  const residentIds = () => new Set(host.resident().filter(model => model.state === "ready").map(model => model.id));

  /** Lease `id`, run `serve` on its unit, and hold the lease until the response has been delivered. */
  async function leased(id: string, request: Request, serve: (unit: U, lease: { release(): void }) => Promise<Response | null>): Promise<Response | null> {
    const path = new URL(request.url).pathname;
    let lease;
    try { lease = await host.acquire(id, { signal: request.signal }); }
    catch (error) { return unavailable(error, path, request.signal); }
    try {
      const response = await serve(lease.unit, lease);
      return response ? holding(response, () => lease.release()) : (lease.release(), null);
    } catch (error) { lease.release(); return errorResponse(error, path, undefined, request.signal); }
  }

  return {
    async handle(request: Request): Promise<Response | null> {
      const url = new URL(request.url);
      const { pathname } = url;
      if (request.method === "POST" && MODEL_ROUTED.has(pathname)) {
        // The body is read once here and handed on as bytes; the model's own parser answers a malformed one.
        const body = await request.text();
        const named = modelField(body);
        const id = named !== undefined && await options.serves(named) ? named : options.current();
        return leased(id, request, unit => unit.operationsFor().generate!(new Request(request.url, {
          method: request.method, headers: request.headers, body, signal: request.signal })));
      }
      const listsModels = pathname === "/v1/models" || pathname.startsWith("/v1/models/");
      if (request.method === "GET" && listsModels) {
        // `/v1/models/{id}` lists that one model; `/v1/models` lists them all.
        const filter = decodeURIComponent(pathname.slice("/v1/models/".length)) || null;
        const own = filter === null ? undefined : options.host.peek(filter);
        if (own) return own.routes.handle(request);
        const base = await listing(request, "/v1/models");
        if (!base) return null;
        const list = await base.json() as { object: string; data: Record<string, unknown>[] };
        const resident = residentIds(), current = options.current();
        // Every resident model answers for itself; the rest are listed as the registry knows them.
        const full = await Promise.all([...resident].map(async id => {
          const unit = host.peek(id);
          const entry = unit ? await unit.routes.handle(new Request(new URL(`/v1/models/${encodeURIComponent(id)}`, request.url))) : null;
          return [id, entry ? ((await entry.json()) as { data?: Record<string, unknown>[] }).data?.[0] : undefined] as const;
        }));
        const bySelf = new Map(full.flatMap(([id, entry]) => entry ? [[id, entry] as const] : []));
        const data = list.data.map(entry => {
          const id = entry.id as string, row = bySelf.get(id) ?? entry;
          return entry.transcription === true ? row : { ...row, resident: resident.has(id), current: id === current };
        });
        return Response.json({ ...list, data: filter === null ? data : data.filter(entry => entry.id === filter) });
      }
      if (request.method === "GET" && pathname === "/library") {
        const base = await listing(request, `/library${url.search}`);
        if (!base) return null;
        const { models } = await base.json() as { models: Record<string, unknown>[] };
        const resident = residentIds(), current = options.current();
        return Response.json({ models: models.map(row => ({ ...row, serving: row.repo_id === current, resident: resident.has(row.repo_id as string) })) });
      }
      if (request.method === "GET" && pathname === "/stats") {
        const unit = active();
        const base = unit ? await unit.routes.handle(request) : null;
        if (!base) return null;
        const stats = await base.json() as Record<string, unknown>;
        const models = host.resident();
        return Response.json({ ...stats, models: { current: options.current(), budget_bytes: host.policy.budgetBytes,
          resident_bytes: models.reduce((sum, model) => sum + model.bytes, 0),
          resident: models.map(model => ({ id: model.id, state: model.state, bytes: model.bytes, pinned: model.pinned, leases: model.leases,
            last_used_at: model.lastUsedAt })) } });
      }
      if (request.method === "GET" && pathname === "/health")
        return await active()?.routes.handle(request) ?? Response.json({ status: "ok" });
      // Everything else model-scoped is the current model's, when one is resident: a read answers as it is, and
      // a change (mounting an adapter, flushing a cache) holds the model resident until it is done.
      const unit = active();
      if (!unit) return null;
      if (["GET", "HEAD"].includes(request.method)) return unit.routes.handle(request);
      return leased(unit.id, request, served => served.routes.handle(request));
    },
  };
}
