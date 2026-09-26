// The parent's Responses conversation history under --isolate (main's
// responses-client.ts): `previous_response_id` resolves against the parent's
// store, the resolved conversation goes to the worker without one, and the
// completed record is remembered here, so history survives worker restarts.
// The worker keeps its own bounded store for the requests it answers; the
// parent never consults it.
import { ResponseStore, resolveResponsesConversation, type ResponseHistory, type ResponsesRequest } from "./responses";

const responsesError = (status: number, message: string) => Response.json({ error: {
  message, type: "invalid_request_error", param: null, code: null,
} }, { status });

export function createResponsesClient(store: ResponseHistory = new ResponseStore()) {
  return {
    get stats() { return { entries: store.size, bytes: store.totalBytes, max_bytes: store.maxBytes, ttl_ms: store.ttlMs }; },
    /** `forward` sends the rewritten request to the worker and returns its response as is. */
    async forward(request: Request, forward: (request: Request) => Promise<Response>): Promise<Response> {
      let body: ResponsesRequest;
      try { body = await request.json() as ResponsesRequest; }
      catch { return responsesError(400, "invalid JSON body"); }
      if (!body || typeof body !== "object" || Array.isArray(body)) return responsesError(400, "invalid JSON body");
      // The container is validated before the previous id resolves, as the
      // worker does: only a missing or expired previous response is a 404.
      if ((body.input != null && typeof body.input !== "string" && !Array.isArray(body.input)) ||
          (body.previous_response_id != null && typeof body.previous_response_id !== "string"))
        return responsesError(400, "input must be a string or array; previous_response_id must be a string");
      let conversation: ReturnType<typeof resolveResponsesConversation>;
      try { conversation = resolveResponsesConversation(body, store); }
      catch (error) { return responsesError(404, error instanceof Error ? error.message : String(error)); }
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
        const outputHeaders = new Headers(response.headers);
        outputHeaders.delete("content-length");
        return Response.json(restorePrevious(value), { status: response.status, headers: outputHeaders });
      }
      if (!response.body) return response;
      const decoder = new TextDecoder(), encoder = new TextEncoder();
      let pending = "";
      // Frames the worker did not shape as JSON (keep-alive comments, [DONE])
      // pass through; `response.completed` is remembered and every response
      // object gets the previous id the caller sent.
      const rewrite = (frame: string): string => frame.replace(/^data: (.+)$/m, (line, data: string) => {
        if (data === "[DONE]") return line;
        let event: Record<string, unknown>;
        try { event = JSON.parse(data) as Record<string, unknown>; } catch { return line; }
        if (event.response && typeof event.response === "object") {
          const value = event.response as Record<string, unknown>;
          if (event.type === "response.completed") remember(value);
          event.response = restorePrevious(value);
        }
        return `data: ${JSON.stringify(event)}`;
      });
      const outputHeaders = new Headers(response.headers);
      outputHeaders.delete("content-length");
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
