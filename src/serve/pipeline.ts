// Shared contracts of the request pipeline. Each stage is one configured
// program — `run(input) → output` — and the server composes them in order,
// like a shell pipe:
//
//   new ChatRequest(body) → ChatStage.run → InferenceRequest
//                         → InferenceStage.run → InferenceResult → wire JSON/SSE
//
// A stage knows only the interface it reads and the one it writes.
import type { CompletionEvent } from "./completion-sink";
import type { CompletionUsage } from "./completion-executor";
import type { PromptResponseTrace } from "./prompt-response-trace";

/** A request a stage refuses. `status` is the HTTP status the wire adapter
 *  answers with; `body` the protocol-neutral error object (adapters reshape
 *  it: OpenAI `{error}`, Anthropic `{type:"error"}`, Responses `{error}`). */
export class RequestError extends Error {
  constructor(
    readonly status: number,
    message: string,
    readonly body: Record<string, unknown> = { message },
  ) {
    super(message);
  }
}

/** What flows back to the caller while a request is in flight: cancellation,
 *  tracing, and (for streaming surfaces) events + live usage. */
export interface RunControl {
  signal?: AbortSignal;
  trace?: PromptResponseTrace;
  onEvents?(events: readonly CompletionEvent[]): void | false | Promise<void | false>;
  onUsageProgress?(usage: Readonly<CompletionUsage>): void;
}
