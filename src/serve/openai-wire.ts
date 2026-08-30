// OpenAI wire formats: InferenceResult → chat.completion / text_completion
// JSON, and the SSE chunk protocols for both. Anthropic and Responses have
// their own (src/anthropic.ts, src/responses.ts); all three implement the
// same CompletionStreamProtocol so the HTTP writer (http.ts) is shared.
import type { CompletionSummary, CompletionUsage } from "./completion-executor";
import type { CompletionEvent, CompletionStreamProtocol } from "./completion-sink";
import type { InferenceResult } from "./inference-request";

export interface OpenAiResponseMeta {
  id: string;
  created: number;
  model: string;
}

/** OpenAI usage block from the executor's live/terminal usage view. */
export const openAiUsage = (usage: CompletionUsage) => ({
  prompt_tokens: usage.promptTokens,
  completion_tokens: usage.completionTokens,
  total_tokens: usage.totalTokens,
  prompt_tokens_details: { cached_tokens: usage.cachedTokens },
  ...(usage.speculation ? { speculation: usage.speculation } : {}),
});

/** Terminal usage: the wire block plus mlx-bun's `lane` (batch|serial|…). */
export const openAiSummaryUsage = (summary: CompletionSummary) => ({
  ...openAiUsage(summary.usage),
  lane: summary.lane,
});

export function chatCompletionJson(result: InferenceResult, meta: OpenAiResponseMeta) {
  return {
    ...meta, object: "chat.completion",
    choices: [{
      index: 0,
      message: {
        role: "assistant",
        content: result.content || (result.toolCalls.length ? null : ""),
        ...(result.reasoning ? { reasoning: result.reasoning } : {}),
        ...(result.toolCalls.length ? { tool_calls: result.toolCalls } : {}),
      },
      ...(result.logprobs ? { logprobs: result.logprobs } : {}),
      finish_reason: result.finishReason,
    }],
    usage: openAiSummaryUsage(result),
  };
}

export function textCompletionJson(result: InferenceResult, meta: OpenAiResponseMeta) {
  return {
    ...meta, object: "text_completion",
    choices: [{
      index: 0, text: result.content,
      ...(result.logprobs ? { logprobs: result.logprobs } : {}),
      finish_reason: result.finishReason,
    }],
    usage: openAiSummaryUsage(result),
  };
}

const sse = (obj: unknown) => `data: ${JSON.stringify(obj)}\n\n`;
const DONE = "data: [DONE]\n\n";

/** OpenAI chat SSE: a role primer chunk, one chunk per event (content /
 *  reasoning / tool_calls delta), a terminal chunk carrying finish_reason +
 *  usage, then the bare `[DONE]` sentinel strict SDK clients require. An
 *  error mid-stream is a single `{error}` frame and nothing after it. */
export function chatCompletionStream(meta: OpenAiResponseMeta): CompletionStreamProtocol {
  const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
    ...meta, object: "chat.completion.chunk",
    choices: [{ index: 0, delta, finish_reason: finish }],
  });
  let errored = false;
  return {
    start: () => [sse(chunk({ role: "assistant", content: "" }, null))],
    addEvents: (events: CompletionEvent[]) => events.map((event) =>
      event.type === "reasoning" ? sse(chunk({ reasoning: event.text }, null))
      : event.type === "content" ? sse(chunk({ content: event.text }, null))
      : sse(chunk({ tool_calls: event.calls.map((call, index) => ({ index, ...call })) }, null))),
    finish: (reason, usage) => errored ? [] : [sse({ ...chunk({}, reason), usage }), DONE],
    error: (message) => { errored = true; return [sse({ error: { message } })]; },
  };
}

/** OpenAI text-completion SSE: content deltas as `text`, then a final chunk
 *  with finish_reason + usage (mlx-lm gates usage behind
 *  stream_options.include_usage; we always attach it — an additive superset
 *  OpenAI clients ignore), then `[DONE]`. */
export function textCompletionStream(meta: OpenAiResponseMeta): CompletionStreamProtocol {
  const chunk = (text: string, finish: string | null) => ({
    ...meta, object: "text_completion",
    choices: [{ index: 0, text, finish_reason: finish }],
  });
  let errored = false;
  return {
    start: () => [],
    addEvents: (events: CompletionEvent[]) => events
      .filter((event) => event.type === "content")
      .map((event) => sse(chunk((event as { text: string }).text, null))),
    finish: (reason, usage) => errored ? [] : [sse({ ...chunk("", reason), usage }), DONE],
    error: (message) => { errored = true; return [sse({ error: { message } })]; },
  };
}
