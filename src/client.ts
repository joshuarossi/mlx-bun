import type { CompletionClient } from "./contracts/completion";
import type { EngineHost } from "./contracts/host";

export interface CompletionCall {
  readonly body: Readonly<Record<string, unknown>>;
  readonly route?: "chat/completions" | "completions";
  readonly signal?: AbortSignal;
}

export interface CompletionResponse {
  choices: Array<{ text?: string; message?: { content?: string | null; [key: string]: unknown }; [key: string]: unknown }>;
  usage?: Record<string, unknown>;
  [key: string]: unknown;
}

/** A borrowed transport. Direct services, HTTP and isolated workers receive
 * the same request and return the same result; POSTs are never retried here. */
export function createCompletionClient(options: {
  baseUrl: string;
  headers?: Readonly<Record<string, string>>;
  host?: Pick<EngineHost<Request, Response>, "forward">;
}): CompletionClient<CompletionCall, CompletionResponse> {
  const baseUrl = options.baseUrl.replace(/\/$/, "");
  const headers = { ...options.headers, "content-type": "application/json" };
  const send = options.host ? options.host.forward.bind(options.host) : fetch;
  return {
    async complete({ body, route = "chat/completions", signal }) {
      signal?.throwIfAborted();
      const response = await send(new Request(`${baseUrl}/${route}`, {
        method: "POST", headers, body: JSON.stringify({ ...body, stream: false }), signal,
      }));
      if (!response.ok) {
        const detail = await response.text();
        throw new Error(`completion failed (${response.status}): ${detail}`);
      }
      const result = await response.json() as CompletionResponse;
      if (!Array.isArray(result.choices)) throw new Error("completion response has no choices");
      return result;
    },
  };
}

/** Adapts an in-process request handler. Closing waits for active handlers;
 * a handler owns any response stream it returns. */
export function createDirectHost(
  handler: (request: Request) => Promise<Response>, shutdown: () => Promise<void> = async () => {},
): EngineHost<Request, Response> {
  let closed = false;
  let closing: Promise<void> | undefined;
  const active = new Set<Promise<Response>>();
  return {
    ready: Promise.resolve(),
    forward(request) {
      if (closed) return Promise.reject(new Error("engine host is closed"));
      if (request.signal.aborted) return Promise.reject(request.signal.reason);
      const work = Promise.resolve().then(() => handler(request));
      active.add(work);
      void work.then(() => active.delete(work), () => active.delete(work));
      return work;
    },
    close() {
      closed = true;
      return closing ??= (async () => { await Promise.allSettled(active); await shutdown(); })();
    },
  };
}
