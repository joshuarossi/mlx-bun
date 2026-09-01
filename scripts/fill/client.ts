// SSE chat client for the fill A/B harness (K3d). One request per replayed
// turn, streamed, timed, with `usage.fill` read off the terminal chunk.
//
// Streaming is not decoration: `ttftMs` and `toolCallMs` (time until the first
// tool-call delta) are the latency numbers an agent loop actually feels, and
// they only exist if the harness reads the stream as it arrives.
import type { FillUsage } from "./metrics";
import type { ToolSchema, WireMessage } from "./session-replay";

export interface Arm {
  label: string;
  url: string;
  headers?: Record<string, string>;
}

export interface ChatBody {
  model?: string;
  messages: WireMessage[];
  tools?: ToolSchema[];
  max_tokens?: number;
  temperature?: number;
}

export interface StreamedTurn {
  wallMs: number;
  ttftMs: number | null;
  toolCallMs: number | null;
  promptTokens: number;
  completionTokens: number;
  fill: FillUsage | null;
  text: string;
  toolCalls: { name: string; arguments: Record<string, unknown> }[];
  finishReason: string | null;
  error?: string;
}

type FetchLike = (url: string, init: RequestInit) => Promise<Response>;

interface StreamDelta {
  content?: string;
  tool_calls?: {
    index?: number;
    id?: string;
    function?: { name?: string; arguments?: string };
  }[];
}

/** POST one chat completion and consume its SSE stream. Never throws for a
 *  protocol/HTTP problem — the failure is recorded on the turn so one bad
 *  turn cannot abandon a whole A/B run. */
export async function streamChat(
  arm: Arm, body: ChatBody, fetchImpl: FetchLike = fetch,
): Promise<StreamedTurn> {
  const started = performance.now();
  const out: StreamedTurn = {
    wallMs: 0, ttftMs: null, toolCallMs: null,
    promptTokens: 0, completionTokens: 0, fill: null,
    text: "", toolCalls: [], finishReason: null,
  };
  const calls = new Map<number, { name: string; args: string }>();
  try {
    const res = await fetchImpl(`${arm.url.replace(/\/$/, "")}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json", ...(arm.headers ?? {}) },
      body: JSON.stringify({ ...body, stream: true }),
    });
    if (!res.ok || !res.body) {
      out.error = `HTTP ${res.status}: ${(await res.text()).slice(0, 200)}`;
      out.wallMs = performance.now() - started;
      return out;
    }
    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      if (out.ttftMs === null) out.ttftMs = performance.now() - started;
      buffer += decoder.decode(value, { stream: true });
      let nl: number;
      while ((nl = buffer.indexOf("\n")) !== -1) {
        const line = buffer.slice(0, nl).trim();
        buffer = buffer.slice(nl + 1);
        if (!line.startsWith("data:")) continue;
        const payload = line.slice(5).trim();
        if (payload === "[DONE]") continue;
        let frame: Record<string, unknown>;
        try { frame = JSON.parse(payload); } catch { continue; }
        if (frame.error) {
          out.error = String((frame.error as { message?: string }).message ?? frame.error);
          continue;
        }
        const choice = (frame.choices as { delta?: StreamDelta; finish_reason?: string }[])?.[0];
        const delta = choice?.delta;
        if (delta?.content) out.text += delta.content;
        if (delta?.tool_calls?.length) {
          if (out.toolCallMs === null) out.toolCallMs = performance.now() - started;
          for (const c of delta.tool_calls) {
            const idx = c.index ?? 0;
            const cur = calls.get(idx) ?? { name: "", args: "" };
            if (c.function?.name) cur.name = c.function.name;
            if (c.function?.arguments) cur.args += c.function.arguments;
            calls.set(idx, cur);
          }
        }
        if (choice?.finish_reason) out.finishReason = choice.finish_reason;
        const usage = frame.usage as Record<string, unknown> | undefined;
        if (usage) {
          out.promptTokens = Number(usage.prompt_tokens ?? 0);
          out.completionTokens = Number(usage.completion_tokens ?? 0);
          out.fill = (usage.fill as FillUsage | undefined) ?? null;
        }
      }
    }
  } catch (e) {
    out.error = (e as Error).message;
  }
  out.wallMs = performance.now() - started;
  out.toolCalls = [...calls.entries()]
    .sort(([a], [b]) => a - b)
    .map(([, c]) => {
      let args: Record<string, unknown> = {};
      try { args = c.args ? JSON.parse(c.args) : {}; } catch { /* keep {} */ }
      return { name: c.name, arguments: args };
    });
  return out;
}
