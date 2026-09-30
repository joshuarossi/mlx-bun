// The loopback the Pi SDK talks to. Pi's OpenAI client reaches its model over HTTP and takes no
// transport of ours, so the module answers on a private loopback listener, and every request goes
// through the `modelHost` service: a lease on the current model, its `generate` operation, and a
// release when the response body ends. A model switch is followed because each request asks the
// host for the current model; the request's own `model` field (Pi's `local`) is the host's to route.
// The listener is created on the first chat connection, takes only Pi's per-run bearer token, and
// closes with the module.
import type { ModelHost, ModelLease } from "@mlx-bun/app-core";

export interface ModelBridge {
  readonly port: number;
  /** What Pi sends as its API key; any other bearer is refused. */
  readonly token: string;
  close(): Promise<void>;
}

/** The path the model host receives; a host's `generate` ignores the origin. */
const WIRE = "http://model.local/v1/chat/completions";

const failure = (status: number, message: string, type: string) => Response.json({ error: { message, type } }, { status });

/** A response that holds its lease until the body has ended, been cancelled or failed. */
function holding(response: Response, lease: ModelLease): Response {
  if (!response.body) { lease.release(); return response; }
  const reader = response.body.getReader();
  let done = false;
  const finish = () => { if (!done) { done = true; lease.release(); } };
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

/** Forwards one chat completion to the current model. */
export async function generateThroughHost(models: Pick<ModelHost, "acquire" | "defaultFor">, request: Request): Promise<Response> {
  let lease: ModelLease;
  try {
    const id = await models.defaultFor("generate");
    if (id === undefined) return failure(503, "no model is served", "model_unavailable");
    lease = await models.acquire(id, { need: ["generate"], signal: request.signal });
  } catch (error) {
    const code = (error as { code?: string }).code;
    return failure(code === "closed" ? 503 : code === "load-failed" ? 502 : 400, error instanceof Error ? error.message : String(error), "model_unavailable");
  }
  try {
    const generate = lease.operations.generate;
    if (!generate) { lease.release(); return failure(400, `model ${lease.model.id} cannot generate`, "model_unavailable"); }
    const headers = new Headers(request.headers);
    headers.delete("authorization");
    return holding(await generate(new Request(WIRE, { method: "POST", headers, body: await request.arrayBuffer(), signal: request.signal })), lease);
  } catch (error) {
    lease.release();
    if (request.signal.aborted) return new Response(null, { status: 499 });
    return failure(502, error instanceof Error ? error.message : String(error), "model_unavailable");
  }
}

export function startModelBridge(models: Pick<ModelHost, "acquire" | "defaultFor">, token: string = crypto.randomUUID()): ModelBridge {
  const server = Bun.serve({
    hostname: "127.0.0.1", port: 0, idleTimeout: 0,
    async fetch(request) {
      const { pathname } = new URL(request.url);
      if (request.headers.get("authorization") !== `Bearer ${token}`) return failure(401, "unauthorized", "invalid_api_key");
      if (request.method !== "POST" || pathname !== "/v1/chat/completions") return failure(404, "not found", "not_found");
      return generateThroughHost(models, request);
    },
  });
  return { port: server.port!, token, close: async () => { await server.stop(true); } };
}
