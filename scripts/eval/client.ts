// One non-streaming OpenAI-compatible request at a time, with the sampling
// fields every evaluation request carries. Token usage and wall time are
// accumulated per task for the result's timings.
import type { EvalRequest, EvalResponse, Send } from "./tasks";

/** Greedy decoding without logits processors on every request. No seed is
 * sent: greedy argmax does not consume one, and main's runner had none. */
export const REQUEST_DEFAULTS = { stream: false, temperature: 0, repetition_penalty: 0 } as const;
/** A request that has not finished in ten minutes has failed. */
export const REQUEST_TIMEOUT_MS = 600_000;

export interface RequestStats { requests: number; requestMs: number; promptTokens: number; completionTokens: number }
export const emptyStats = (): RequestStats => ({ requests: 0, requestMs: 0, promptTokens: 0, completionTokens: 0 });

type Json = Record<string, unknown>;
const record = (value: unknown): Json | null => value && typeof value === "object" && !Array.isArray(value) ? value as Json : null;
const count = (value: unknown) => Number.isSafeInteger(value) && (value as number) >= 0 ? value as number : null;

/** First position's top logprobs: mlx-bun's `content[0].top_logprobs` list, or
 * OpenAI's legacy `top_logprobs[0]` token → logprob map. */
function topLogprobs(logprobs: unknown): EvalResponse["topLogprobs"] {
  const lp = record(logprobs);
  if (!lp) return null;
  const first = Array.isArray(lp.content) ? record(lp.content[0]) : null;
  if (first && Array.isArray(first.top_logprobs))
    return first.top_logprobs.flatMap(entry => {
      const e = record(entry);
      return e && typeof e.token === "string" && typeof e.logprob === "number" ? [{ token: e.token, logprob: e.logprob }] : [];
    });
  const legacy = Array.isArray(lp.top_logprobs) ? record(lp.top_logprobs[0]) : null;
  if (legacy) return Object.entries(legacy).flatMap(([token, logprob]) => typeof logprob === "number" ? [{ token, logprob }] : []);
  return null;
}

export function parseResponse(route: EvalRequest["route"], json: unknown): EvalResponse {
  const body = record(json), choice = Array.isArray(body?.choices) ? record(body!.choices[0]) : null;
  if (!choice) throw new Error(`invalid response without choices: ${JSON.stringify(json).slice(0, 300)}`);
  const usage = record(body!.usage);
  const base = { finishReason: typeof choice.finish_reason === "string" ? choice.finish_reason : null,
    promptTokens: count(usage?.prompt_tokens), completionTokens: count(usage?.completion_tokens), topLogprobs: topLogprobs(choice.logprobs) };
  if (route === "completions") {
    if (typeof choice.text !== "string") throw new Error(`invalid completion without text: ${JSON.stringify(choice).slice(0, 300)}`);
    return { text: choice.text, reasoning: null, toolCalls: [], ...base };
  }
  const message = record(choice.message);
  if (!message || (message.content !== null && message.content !== undefined && typeof message.content !== "string"))
    throw new Error(`invalid chat message: ${JSON.stringify(choice).slice(0, 300)}`);
  const reasoning = message.reasoning ?? message.reasoning_content;
  const toolCalls = (Array.isArray(message.tool_calls) ? message.tool_calls : []).flatMap(call => {
    const fn = record(record(call)?.function);
    if (!fn || typeof fn.name !== "string") return [];
    return [{ name: fn.name, arguments: typeof fn.arguments === "string" ? fn.arguments : JSON.stringify(fn.arguments ?? {}) }];
  });
  return { text: (message.content as string | null | undefined) ?? "", reasoning: typeof reasoning === "string" && reasoning ? reasoning : null,
    toolCalls, ...base };
}

/** Requests to `${base}/v1/<route>`, naming the served model by its path. */
export function createSend(base: string, model: string, stats: () => RequestStats, timeoutMs = REQUEST_TIMEOUT_MS): Send {
  return async (request, signal) => {
    const budget = AbortSignal.timeout(timeoutMs);
    const t0 = performance.now();
    const current = stats();
    current.requests++;
    try {
      const res = await fetch(`${base}/v1/${request.route}`, {
        method: "POST", signal: signal ? AbortSignal.any([budget, signal]) : budget,
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ model, ...REQUEST_DEFAULTS, ...request.body }),
      });
      const text = await res.text();
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${text.slice(0, 300)}`);
      let json: unknown;
      try { json = JSON.parse(text); } catch { throw new Error(`invalid JSON response: ${text.slice(0, 300)}`); }
      const parsed = parseResponse(request.route, json);
      current.promptTokens += parsed.promptTokens ?? 0;
      current.completionTokens += parsed.completionTokens ?? 0;
      return parsed;
    } finally { current.requestMs += performance.now() - t0; }
  };
}
