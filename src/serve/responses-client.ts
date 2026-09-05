import { ResponseStore, resolveResponsesConversation, type ResponseHistory, type ResponsesRequest } from "../responses";

/** Application-owned conversation history over a data-only HTTP host. Workers
 * translate/run the request; the parent stores only completed response records. */
export function createResponsesClient(store: ResponseHistory = new ResponseStore()) {
  return {
    get stats() { return { entries: store.size, bytes: store.totalBytes, max_bytes: store.maxBytes, ttl_ms: store.ttlMs }; },
    async forward(request: Request, forward: (request: Request) => Promise<Response>): Promise<Response> {
      const error = (status: number, message: string) => Response.json({ error: {
        message, type: "invalid_request_error", param: null, code: null,
      } }, { status });
      let body: ResponsesRequest;
      try { body = await request.json() as ResponsesRequest; }
      catch { return error(400, "invalid JSON body"); }
      if (!body || typeof body !== "object" || Array.isArray(body)) return error(400, "invalid JSON body");
      let conversation: ReturnType<typeof resolveResponsesConversation>;
      try { conversation = resolveResponsesConversation(body, store); }
      catch (e) { return error(404, (e as Error).message); }
      const headers = new Headers(request.headers);
      headers.delete("content-length");
      headers.set("x-mlx-bun-response-owner", "parent");
      const response = await forward(new Request(request.url, {
        method: "POST", headers, signal: request.signal,
        body: JSON.stringify({ ...conversation.body, previous_response_id: undefined }),
      }));
      if (!response.ok) return response;
      const remember = (value: Record<string, unknown>) => {
        if (typeof value.id === "string" && Array.isArray(value.output))
          store.put(value.id, { input: conversation.input, output: value.output, instructions: conversation.instructions });
      };
      const restorePrevious = (value: Record<string, unknown>) => ({ ...value, previous_response_id: conversation.previousId });
      if (!body.stream) {
        const value = await response.json() as Record<string, unknown>;
        remember(value);
        const headers = new Headers(response.headers); headers.delete("content-length");
        return Response.json(restorePrevious(value), { status: response.status, headers });
      }
      if (!response.body) return response;
      const decoder = new TextDecoder(), encoder = new TextEncoder();
      let pending = "";
      const rewrite = (frame: string): string => frame.replace(/^data: (.+)$/m, (line, data: string) => {
        if (data === "[DONE]") return line;
        const event = JSON.parse(data) as Record<string, unknown>;
        if (event.response && typeof event.response === "object") {
          const value = event.response as Record<string, unknown>;
          if (event.type === "response.completed") remember(value);
          event.response = restorePrevious(value);
        }
        return `data: ${JSON.stringify(event)}`;
      });
      const outputHeaders = new Headers(response.headers); outputHeaders.delete("content-length");
      return new Response(response.body.pipeThrough(new TransformStream<Uint8Array, Uint8Array>({
        transform(chunk, controller) {
          pending += decoder.decode(chunk, { stream: true });
          let split: number;
          while ((split = pending.indexOf("\n\n")) !== -1) {
            const frame = pending.slice(0, split);
            pending = pending.slice(split + 2);
            controller.enqueue(encoder.encode(`${rewrite(frame)}\n\n`));
          }
        },
        flush(controller) {
          pending += decoder.decode();
          if (pending) controller.enqueue(encoder.encode(rewrite(pending)));
        },
      })), { status: response.status, headers: outputHeaders });
    },
  };
}
