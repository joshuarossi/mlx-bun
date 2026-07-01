// Anthropic Messages API translation layer for the mlx-bun server.
//
// Ported from: mlx-optiq optiq/anthropic_shim.py (MIT) —
// anthropic_to_openai_body / openai_to_anthropic_response /
// AnthropicStreamTranslator. The SSE event grammar is the oracle's
// exactly: message_start → [content_block_start/delta/stop]* →
// message_delta (stop_reason + output_tokens) → message_stop.
//
// Documented upgrades over the oracle (possible because our
// chat-completions layer is natively capable where mlx-lm's gemma path
// is not — same divergence class as the Phase 4 bidirectional-mask fix):
//   - tools: Anthropic `tools`/`tool_use`/`tool_result` map onto our REAL
//     OpenAI tools surface (token-level gemma tool calling) instead of
//     the oracle's Qwen-style <tool_call> inline-text hack ("out of
//     scope for v1" upstream). Streamed tool calls emit proper
//     tool_use content blocks with input_json_delta.
//   - images: Anthropic image blocks (base64 or url source) map to our
//     image_url vision parts; the oracle emits "[image omitted]".
//   - usage: real prompt/completion token counts from the final OpenAI
//     chunk (the oracle counts text chunks); our prompt-cache hit count
//     surfaces as cache_read_input_tokens.
//   - prior-turn `thinking` blocks are dropped on re-ingest (Anthropic
//     semantics) instead of the oracle's json.dumps fallback.

import type { ChatMessage, ToolDefinition } from "./chat-template";

// ---------------------------------------------------------------------
// Request translation: Anthropic → OpenAI (our ChatRequest shape)
// ---------------------------------------------------------------------

interface AnthropicContentBlock {
  type?: string;
  text?: string;
  thinking?: string;
  id?: string;
  name?: string;
  input?: Record<string, unknown>;
  tool_use_id?: string;
  content?: unknown;
  source?: { type?: string; media_type?: string; data?: string; url?: string };
}

export interface AnthropicRequest {
  model?: string;
  system?: string | AnthropicContentBlock[];
  messages?: Array<{ role?: string; content?: string | AnthropicContentBlock[] }>;
  max_tokens?: number;
  temperature?: number;
  top_p?: number;
  top_k?: number;
  stop_sequences?: string[];
  stream?: boolean;
  /** mlx-lm sampler/penalty extensions — not part of the Anthropic protocol,
   *  accepted as pass-through extras with the same names as our /v1 chat
   *  surface. Anthropic has NO logit_bias, so none is accepted here. */
  min_p?: number;
  xtc_probability?: number;
  xtc_threshold?: number;
  repetition_penalty?: number;
  repetition_context_size?: number;
  presence_penalty?: number;
  presence_context_size?: number;
  frequency_penalty?: number;
  frequency_context_size?: number;
  tools?: Array<{
    name?: string;
    description?: string;
    input_schema?: Record<string, unknown>;
    type?: string;
  }>;
  tool_choice?: { type?: string };
}

/** Flatten text-bearing blocks (used for system and tool_result content). */
function flattenText(content: unknown): string {
  if (content == null) return "";
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return String(content);
  const parts: string[] = [];
  for (const block of content as AnthropicContentBlock[]) {
    if (typeof block !== "object" || block === null) parts.push(String(block));
    else if (block.type === "text") parts.push(block.text ?? "");
  }
  return parts.join("\n");
}

function imagePartFromBlock(block: AnthropicContentBlock): Record<string, unknown> | null {
  const src = block.source;
  if (!src) return null;
  if (src.type === "base64" && src.data)
    return {
      type: "image_url",
      image_url: { url: `data:${src.media_type ?? "image/png"};base64,${src.data}` },
    };
  if (src.type === "url" && src.url)
    return { type: "image_url", image_url: { url: src.url } };
  return null;
}

/** Translate an Anthropic /v1/messages body into the OpenAI
 *  /v1/chat/completions body our server consumes. Throws on
 *  structurally invalid input (caller maps to invalid_request_error). */
export function anthropicToChatBody(body: AnthropicRequest): Record<string, unknown> {
  if (!Array.isArray(body.messages) || body.messages.length === 0)
    throw new Error("messages: at least one message is required");

  const messages: ChatMessage[] = [];
  if (body.system != null) {
    const sys = typeof body.system === "string" ? body.system : flattenText(body.system);
    if (sys) messages.push({ role: "system", content: sys });
  }

  for (const m of body.messages) {
    const role = m.role === "assistant" ? "assistant" : "user";
    if (typeof m.content === "string" || m.content == null) {
      messages.push({ role, content: m.content ?? "" });
      continue;
    }
    const textParts: string[] = [];
    const imageParts: Record<string, unknown>[] = [];
    const toolCalls: NonNullable<ChatMessage["tool_calls"]> = [];
    for (const block of m.content) {
      switch (block.type) {
        case "text":
          textParts.push(block.text ?? "");
          break;
        case "thinking":
          break; // prior-turn thinking is not re-fed (Anthropic semantics)
        case "image": {
          const part = imagePartFromBlock(block);
          if (part) imageParts.push(part);
          break;
        }
        case "tool_use":
          toolCalls.push({
            id: block.id ?? `toolu_${crypto.randomUUID().slice(0, 12)}`,
            type: "function",
            function: {
              name: block.name ?? "",
              arguments: JSON.stringify(block.input ?? {}),
            },
          });
          break;
        case "tool_result":
          // Anthropic packs tool results into the next user message;
          // OpenAI (and the gemma template) want role:"tool" messages.
          messages.push({
            role: "tool",
            tool_call_id: block.tool_use_id,
            content: flattenText(block.content),
          });
          break;
        default:
          if (block.text) textParts.push(block.text);
      }
    }
    if (role === "assistant") {
      const msg: ChatMessage = { role, content: textParts.join("\n") || null };
      if (toolCalls.length) msg.tool_calls = toolCalls;
      if (msg.content || toolCalls.length) messages.push(msg);
    } else if (imageParts.length) {
      messages.push({
        role,
        content: [
          ...textParts.filter((t) => t).map((t) => ({ type: "text", text: t })),
          ...imageParts,
        ],
      });
    } else if (textParts.length) {
      messages.push({ role, content: textParts.join("\n") });
    }
  }

  const oai: Record<string, unknown> = { messages };
  if (body.model != null) oai.model = body.model;
  if (body.max_tokens != null) oai.max_tokens = body.max_tokens;
  if (body.temperature != null) oai.temperature = body.temperature;
  if (body.top_p != null) oai.top_p = body.top_p;
  if (body.top_k != null) oai.top_k = body.top_k;
  if (body.stop_sequences?.length) oai.stop = body.stop_sequences;
  if (body.stream) oai.stream = true;
  // mlx-lm sampler/penalty extensions: straight pass-through (same wire names
  // on the chat surface). No logit_bias — it doesn't exist in this protocol.
  for (const k of [
    "min_p", "xtc_probability", "xtc_threshold",
    "repetition_penalty", "repetition_context_size",
    "presence_penalty", "presence_context_size",
    "frequency_penalty", "frequency_context_size",
  ] as const) {
    if (body[k] != null) oai[k] = body[k];
  }

  // Client tools only (entries with name + input_schema); server-tool
  // types (web_search etc.) have no local meaning and are dropped.
  const tools: ToolDefinition[] = (body.tools ?? [])
    .filter((t) => t.name && t.input_schema)
    .map((t) => ({
      type: "function" as const,
      function: {
        name: t.name!,
        description: t.description,
        parameters: t.input_schema,
      },
    }));
  if (tools.length) oai.tools = tools;
  if (body.tool_choice?.type === "none") oai.tool_choice = "none";

  return oai;
}

// ---------------------------------------------------------------------
// Response translation: OpenAI → Anthropic
// ---------------------------------------------------------------------

const STOP_REASON_MAP: Record<string, string> = {
  stop: "end_turn",
  length: "max_tokens",
  tool_calls: "tool_use",
  function_call: "tool_use",
};

const genMessageId = () => `msg_${crypto.randomUUID().replaceAll("-", "").slice(0, 24)}`;

function usageFromOpenAi(usage: any): Record<string, number> {
  const out: Record<string, number> = {
    input_tokens: Number(usage?.prompt_tokens ?? 0),
    output_tokens: Number(usage?.completion_tokens ?? 0),
  };
  const cached = usage?.prompt_tokens_details?.cached_tokens;
  if (cached) out.cache_read_input_tokens = Number(cached);
  return out;
}

/** Non-streaming: OpenAI chat.completion JSON → Anthropic message JSON. */
export function chatJsonToAnthropic(oai: any, model: string): Record<string, unknown> {
  const choice = oai?.choices?.[0] ?? {};
  const message = choice.message ?? {};
  const content: Record<string, unknown>[] = [];
  if (message.reasoning)
    content.push({ type: "thinking", thinking: message.reasoning, signature: "" });
  if (message.content) content.push({ type: "text", text: message.content });
  let finish: string | null = choice.finish_reason ?? null;
  for (const tc of message.tool_calls ?? []) {
    let input: unknown;
    try {
      input = JSON.parse(tc.function?.arguments ?? "{}");
    } catch {
      input = { _raw: tc.function?.arguments ?? "" };
    }
    content.push({
      type: "tool_use",
      id: tc.id ?? `toolu_${crypto.randomUUID().slice(0, 12)}`,
      name: tc.function?.name,
      input,
    });
    finish = "tool_calls";
  }
  return {
    id: genMessageId(),
    type: "message",
    role: "assistant",
    content,
    model,
    stop_reason: STOP_REASON_MAP[finish ?? "stop"] ?? "end_turn",
    stop_sequence: null,
    usage: usageFromOpenAi(oai?.usage),
  };
}

// ---------------------------------------------------------------------
// Streaming: OpenAI chunk events → Anthropic SSE event frames
// ---------------------------------------------------------------------

const sse = (event: string, data: unknown): string =>
  `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;

/** Incremental translator (oracle class of the same name). Feed OpenAI
 *  chunk objects one at a time; each call returns the Anthropic SSE
 *  frames to flush BEFORE the next upstream token arrives (first-token
 *  latency on a laptop blows SDK timeouts otherwise — oracle finding). */
export class AnthropicStreamTranslator {
  readonly msgId = genMessageId();
  #headersSent = false;
  #thinkingStarted = false;
  #thinkingClosed = false;
  #textStarted = false;
  #textIndex = 0;
  #nextIndex = 0;
  #stopReason = "end_turn";
  #countedTokens = 0;
  #usage: Record<string, number> | null = null;

  constructor(readonly model: string) {}

  #headers(out: string[]): void {
    if (this.#headersSent) return;
    this.#headersSent = true;
    out.push(
      sse("message_start", {
        type: "message_start",
        message: {
          id: this.msgId, type: "message", role: "assistant",
          model: this.model, content: [],
          stop_reason: null, stop_sequence: null,
          usage: { input_tokens: 0, output_tokens: 0 },
        },
      }),
    );
  }

  #closeThinking(out: string[]): void {
    out.push(
      sse("content_block_delta", {
        type: "content_block_delta",
        index: 0,
        // unsigned local reasoning: empty signature (spec allows it)
        delta: { type: "signature_delta", signature: "" },
      }),
      sse("content_block_stop", { type: "content_block_stop", index: 0 }),
    );
    this.#thinkingClosed = true;
  }

  #closeText(out: string[]): void {
    out.push(sse("content_block_stop", { type: "content_block_stop", index: this.#textIndex }));
    this.#textStarted = false;
  }

  addChunk(chunk: any): string[] {
    const out: string[] = [];
    this.#headers(out);
    const choice = chunk?.choices?.[0] ?? {};
    const delta = choice.delta ?? {};
    const fin = choice.finish_reason;

    const reasoning = delta.reasoning;
    if (reasoning) {
      if (!this.#thinkingStarted) {
        this.#thinkingStarted = true;
        this.#nextIndex = 1;
        out.push(
          sse("content_block_start", {
            type: "content_block_start",
            index: 0,
            content_block: { type: "thinking", thinking: "" },
          }),
        );
      }
      out.push(
        sse("content_block_delta", {
          type: "content_block_delta",
          index: 0,
          delta: { type: "thinking_delta", thinking: reasoning },
        }),
      );
    }

    const text = delta.content;
    if (text) {
      if (this.#thinkingStarted && !this.#thinkingClosed) this.#closeThinking(out);
      if (!this.#textStarted) {
        this.#textStarted = true;
        this.#textIndex = this.#nextIndex++;
        out.push(
          sse("content_block_start", {
            type: "content_block_start",
            index: this.#textIndex,
            content_block: { type: "text", text: "" },
          }),
        );
      }
      out.push(
        sse("content_block_delta", {
          type: "content_block_delta",
          index: this.#textIndex,
          delta: { type: "text_delta", text },
        }),
      );
      this.#countedTokens++;
    }

    // Our server emits structured tool calls in one delta chunk; each
    // becomes a complete tool_use block (start → input_json_delta → stop).
    for (const tc of delta.tool_calls ?? []) {
      if (this.#thinkingStarted && !this.#thinkingClosed) this.#closeThinking(out);
      if (this.#textStarted) this.#closeText(out);
      const idx = this.#nextIndex++;
      out.push(
        sse("content_block_start", {
          type: "content_block_start",
          index: idx,
          content_block: {
            type: "tool_use",
            id: tc.id ?? `toolu_${crypto.randomUUID().slice(0, 12)}`,
            name: tc.function?.name ?? "",
            input: {},
          },
        }),
        sse("content_block_delta", {
          type: "content_block_delta",
          index: idx,
          delta: { type: "input_json_delta", partial_json: tc.function?.arguments ?? "{}" },
        }),
        sse("content_block_stop", { type: "content_block_stop", index: idx }),
      );
      this.#stopReason = "tool_use";
    }

    if (fin) {
      if (this.#stopReason !== "tool_use")
        this.#stopReason = STOP_REASON_MAP[fin] ?? "end_turn";
      if (chunk.usage) this.#usage = usageFromOpenAi(chunk.usage);
    }
    return out;
  }

  finalize(): string[] {
    const out: string[] = [];
    this.#headers(out);
    if (this.#thinkingStarted && !this.#thinkingClosed) this.#closeThinking(out);
    if (this.#textStarted) this.#closeText(out);
    else if (!this.#thinkingStarted && this.#nextIndex === 0) {
      // empty generation: emit one empty text block (oracle behavior)
      out.push(
        sse("content_block_start", {
          type: "content_block_start",
          index: 0,
          content_block: { type: "text", text: "" },
        }),
        sse("content_block_stop", { type: "content_block_stop", index: 0 }),
      );
    }
    out.push(
      sse("message_delta", {
        type: "message_delta",
        delta: { stop_reason: this.#stopReason, stop_sequence: null },
        // real usage from the final OpenAI chunk when present; the
        // oracle's chunk count is the fallback
        usage: this.#usage ?? { output_tokens: this.#countedTokens },
      }),
      sse("message_stop", { type: "message_stop" }),
    );
    return out;
  }
}

/** Wrap our OpenAI SSE byte stream as an Anthropic SSE byte stream.
 *  Frames translate as they arrive (per-chunk flush preserved — the
 *  upstream already rate-limits socket flushes). */
export function translateOpenAiSse(
  upstream: ReadableStream<Uint8Array>,
  model: string,
): ReadableStream<Uint8Array> {
  const translator = new AnthropicStreamTranslator(model);
  const enc = new TextEncoder();
  const dec = new TextDecoder();
  let buf = "";
  let finalized = false;
  return new ReadableStream<Uint8Array>({
    async start(controller) {
      const emit = (frames: string[]) => {
        for (const f of frames) controller.enqueue(enc.encode(f));
      };
      const reader = upstream.getReader();
      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          buf += dec.decode(value, { stream: true });
          let sep: number;
          while ((sep = buf.indexOf("\n\n")) !== -1) {
            const frame = buf.slice(0, sep);
            buf = buf.slice(sep + 2);
            const data = frame
              .split("\n")
              .find((l) => l.startsWith("data: "))
              ?.slice(6);
            if (data == null) continue;
            if (data === "[DONE]" || data === '"[DONE]"') {
              if (!finalized) {
                finalized = true;
                emit(translator.finalize());
              }
              continue;
            }
            const parsed = JSON.parse(data);
            if (parsed?.error) {
              emit([
                sse("error", {
                  type: "error",
                  error: { type: "api_error", message: parsed.error.message ?? "generation failed" },
                }),
              ]);
              continue;
            }
            emit(translator.addChunk(parsed));
          }
        }
        if (!finalized) emit(translator.finalize());
      } catch (e) {
        emit([
          sse("error", {
            type: "error",
            error: { type: "api_error", message: (e as Error).message },
          }),
        ]);
      } finally {
        reader.releaseLock();
        controller.close();
      }
    },
  });
}
