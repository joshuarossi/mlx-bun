// OpenAI Responses API translation layer + response store for the
// mlx-bun server (Phase 11).
//
// Ported from: mlx-optiq optiq/responses_shim.py (MIT) —
// responses_to_openai_body / openai_to_responses_response /
// ResponsesStreamTranslator / output_items_to_input_items — and
// optiq/response_store.py (ResponseStore: TTL-bounded, byte-capped
// LRU). The streaming event chain is the oracle's exactly; Codex
// hard-requires response.output_text.delta and response.completed,
// the rest are spec-compliance events for the broader SDK ecosystem.
//
// Documented deltas vs the oracle:
//   - usage: real prompt/completion counts from our final chunk (it
//     reads usage only from choice-less chunks and counts text chunks
//     as output tokens); our prompt-cache hits populate
//     input_tokens_details.cached_tokens (oracle hardcodes 0).
//   - previous_response_id is echoed in the response when the request
//     carried one (oracle always emits null).

// ---------------------------------------------------------------------
// Response store (previous_response_id resumption)
// ---------------------------------------------------------------------

export interface StoredResponse {
  input: unknown[];
  output: unknown[];
  instructions: string | null;
}

interface StoreEntry extends StoredResponse {
  createdAt: number;
  size: number;
}

const DEFAULT_TTL_MS = 60 * 60 * 1000; // 1 hour — OpenAI's default
const DEFAULT_MAX_BYTES = 32 * 1024 * 1024;

/** Process-local TTL + byte-capped LRU (port of response_store.py).
 *  Does not survive restarts — sufficient for local serving; anything
 *  sturdier means external storage, out of scope upstream too. */
export class ResponseStore {
  #items = new Map<string, StoreEntry>(); // Map iterates in insertion order
  #bytes = 0;

  constructor(
    readonly ttlMs: number = DEFAULT_TTL_MS,
    readonly maxBytes: number = DEFAULT_MAX_BYTES,
  ) {}

  get size(): number {
    return this.#items.size;
  }

  get totalBytes(): number {
    return this.#bytes;
  }

  put(id: string, entry: StoredResponse): void {
    this.#evictExpired();
    const prev = this.#items.get(id);
    if (prev) {
      this.#bytes -= prev.size;
      this.#items.delete(id);
    }
    const size = JSON.stringify(entry.input).length + JSON.stringify(entry.output).length;
    this.#items.set(id, {
      input: [...entry.input],
      output: [...entry.output],
      instructions: entry.instructions,
      createdAt: Date.now(),
      size,
    });
    this.#bytes += size;
    this.#evictLru();
  }

  get(id: string): StoredResponse | null {
    this.#evictExpired();
    const entry = this.#items.get(id);
    if (!entry) return null;
    // move-to-end (LRU touch)
    this.#items.delete(id);
    this.#items.set(id, entry);
    return {
      input: [...entry.input],
      output: [...entry.output],
      instructions: entry.instructions,
    };
  }

  #evictExpired(): void {
    const cutoff = Date.now() - this.ttlMs;
    for (const [id, entry] of this.#items) {
      if (entry.createdAt >= cutoff) break; // oldest-first walk, like the oracle
      this.#bytes -= entry.size;
      this.#items.delete(id);
    }
  }

  #evictLru(): void {
    for (const [id, entry] of this.#items) {
      if (this.#bytes <= this.maxBytes) break;
      this.#bytes -= entry.size;
      this.#items.delete(id);
    }
  }
}

// ---------------------------------------------------------------------
// Request translation: Responses → Chat Completions
// ---------------------------------------------------------------------

export interface ResponsesRequest {
  model?: string;
  input?: string | Array<Record<string, unknown>>;
  instructions?: string;
  previous_response_id?: string;
  max_output_tokens?: number;
  max_tokens?: number;
  temperature?: number;
  top_p?: number;
  top_k?: number;
  stream?: boolean;
  /** mlx-lm sampler/penalty extensions + logit_bias — not part of the
   *  Responses protocol proper; accepted as pass-through extras with the
   *  same names as our /v1 chat surface. */
  min_p?: number;
  xtc_probability?: number;
  xtc_threshold?: number;
  logit_bias?: Record<string, number>;
  repetition_penalty?: number;
  repetition_context_size?: number;
  presence_penalty?: number;
  presence_context_size?: number;
  frequency_penalty?: number;
  frequency_context_size?: number;
  tools?: Array<Record<string, unknown>>;
  tool_choice?: unknown;
}

const hex = () => crypto.randomUUID().replaceAll("-", "");
const genResponseId = () => `resp_${hex().slice(0, 24)}`;
const genCallId = () => `call_${hex().slice(0, 24)}`;
const genItemId = (prefix = "msg") => `${prefix}_${hex().slice(0, 24)}`;

const STATUS_MAP: Record<string, string> = {
  stop: "completed",
  length: "incomplete",
  tool_calls: "completed",
  function_call: "completed",
};

/** Flatten a Responses content array ({type, text} parts) to text. */
function coerceText(content: unknown): string {
  if (content == null) return "";
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return String(content);
  const parts: string[] = [];
  for (const part of content) {
    if (typeof part === "string") parts.push(part);
    else if (part && typeof part === "object" && (part as any).text != null)
      parts.push(String((part as any).text));
  }
  return parts.join("");
}

/** Convert a prior response's output array into input-shaped items for
 *  previous_response_id resumption (reasoning items dropped — replaying
 *  them invites the model to repeat itself). */
export function outputItemsToInputItems(output: unknown[]): Record<string, unknown>[] {
  const items: Record<string, unknown>[] = [];
  for (const raw of output ?? []) {
    if (!raw || typeof raw !== "object") continue;
    const item = raw as Record<string, unknown>;
    if (item.type === "message") {
      items.push({
        type: "message",
        role: item.role ?? "assistant",
        content: item.content ?? [],
      });
    } else if (item.type === "function_call") {
      items.push({
        type: "function_call",
        call_id: item.call_id ?? item.id,
        name: item.name ?? "",
        arguments: item.arguments ?? "",
      });
    }
  }
  return items;
}

/** Translate a Responses body into our chat-completions body shape.
 *  System text from `instructions` AND role=system/developer input
 *  items merge into ONE leading system message (strict templates
 *  reject duplicates; Codex sends both — oracle finding). */
export function responsesToChatBody(body: ResponsesRequest): Record<string, unknown> {
  const systemParts: string[] = [];
  const messages: Record<string, unknown>[] = [];
  if (body.instructions) systemParts.push(String(body.instructions));

  const inp = body.input;
  if (typeof inp === "string") {
    if (inp) messages.push({ role: "user", content: inp });
  } else if (Array.isArray(inp)) {
    for (const raw of inp) {
      if (!raw || typeof raw !== "object") continue;
      const item = raw as Record<string, unknown>;
      if (item.type === "function_call") {
        messages.push({
          role: "assistant",
          content: null,
          tool_calls: [{
            id: item.call_id ?? `call_${hex().slice(0, 12)}`,
            type: "function",
            function: { name: item.name, arguments: item.arguments ?? "" },
          }],
        });
        continue;
      }
      if (item.type === "function_call_output") {
        const output = item.output;
        messages.push({
          role: "tool",
          tool_call_id: item.call_id ?? "",
          content: typeof output === "string" ? output : JSON.stringify(output ?? ""),
        });
        continue;
      }
      // regular message item (explicit type or implicit by having role)
      let role = String(item.role ?? "user");
      const content = coerceText(item.content);
      if (role === "system" || role === "developer") {
        if (content) systemParts.push(content);
        continue;
      }
      if (!["user", "assistant", "tool"].includes(role)) role = "user";
      messages.push({ role, content });
    }
  }
  if (systemParts.length) messages.unshift({ role: "system", content: systemParts.join("\n\n") });

  const oai: Record<string, unknown> = { messages };
  if (body.model != null) oai.model = body.model;
  const maxTokens = body.max_output_tokens ?? body.max_tokens;
  if (maxTokens != null) oai.max_tokens = maxTokens;
  if (body.temperature != null) oai.temperature = body.temperature;
  if (body.top_p != null) oai.top_p = body.top_p;
  if (body.top_k != null) oai.top_k = body.top_k;
  if (body.stream) oai.stream = true;
  // mlx-lm sampler/penalty extensions (+ OpenAI logit_bias): straight
  // pass-through — same wire names on the chat surface.
  for (const k of [
    "min_p", "xtc_probability", "xtc_threshold", "logit_bias",
    "repetition_penalty", "repetition_context_size",
    "presence_penalty", "presence_context_size",
    "frequency_penalty", "frequency_context_size",
  ] as const) {
    if (body[k] != null) oai[k] = body[k];
  }

  // Flat Responses tool shape → nested chat shape; built-ins
  // (web_search, file_search, mcp, computer_use) dropped silently.
  const tools = (body.tools ?? [])
    .filter((t) => t && t.type === "function")
    .map((t) => {
      const fn: Record<string, unknown> = {};
      for (const k of ["name", "description", "parameters", "strict"])
        if (t[k] != null) fn[k] = t[k];
      return { type: "function", function: fn };
    });
  if (tools.length) oai.tools = tools;

  const tc = body.tool_choice;
  if (tc != null) {
    if (
      typeof tc === "object" &&
      (tc as any).type === "function" &&
      (tc as any).name &&
      !(tc as any).function
    ) {
      oai.tool_choice = { type: "function", function: { name: (tc as any).name } };
    } else {
      oai.tool_choice = tc; // "auto" / "none" / "required" pass through
    }
  }
  return oai;
}

// ---------------------------------------------------------------------
// Response translation: chat completion → Responses (non-streaming)
// ---------------------------------------------------------------------

function baseResponse(model: string, id: string): Record<string, unknown> {
  return {
    id,
    object: "response",
    created_at: Math.floor(Date.now() / 1000),
    status: "in_progress",
    error: null,
    incomplete_details: null,
    instructions: null,
    max_output_tokens: null,
    model,
    output: [] as unknown[],
    parallel_tool_calls: true,
    previous_response_id: null,
    reasoning: null,
    store: false,
    temperature: null,
    text: { format: { type: "text" } },
    tool_choice: "auto",
    tools: [],
    top_p: null,
    truncation: "disabled",
    usage: null,
    user: null,
    metadata: {},
  };
}

function usageBlock(
  inputTokens: number,
  outputTokens: number,
  cachedTokens: number,
  reasoningTokens: number,
): Record<string, unknown> {
  return {
    input_tokens: inputTokens,
    output_tokens: outputTokens,
    total_tokens: inputTokens + outputTokens,
    input_tokens_details: { cached_tokens: cachedTokens },
    output_tokens_details: { reasoning_tokens: reasoningTokens },
  };
}

/** Non-streaming: OpenAI chat.completion JSON → Responses JSON. */
export function chatJsonToResponses(
  oai: any,
  model: string,
  previousResponseId: string | null = null,
): Record<string, unknown> {
  const choice = oai?.choices?.[0] ?? {};
  const message = choice.message ?? {};
  const text: string = message.content ?? "";
  const reasoning: string = message.reasoning ?? "";
  const output: Record<string, unknown>[] = [];
  if (reasoning)
    output.push({
      id: genItemId("rs"),
      type: "reasoning",
      status: "completed",
      summary: [{ type: "summary_text", text: reasoning }],
    });
  if (text)
    output.push({
      id: genItemId("msg"),
      type: "message",
      status: "completed",
      role: "assistant",
      content: [{ type: "output_text", text, annotations: [] }],
    });
  for (const tc of message.tool_calls ?? []) {
    output.push({
      id: genItemId("fc"),
      type: "function_call",
      status: "completed",
      call_id: tc.id ?? genCallId(),
      name: tc.function?.name ?? "",
      arguments: tc.function?.arguments ?? "",
    });
  }
  const usage = oai?.usage ?? {};
  const resp = baseResponse(model, genResponseId());
  resp.status = STATUS_MAP[choice.finish_reason ?? "stop"] ?? "completed";
  resp.output = output;
  resp.previous_response_id = previousResponseId;
  resp.usage = usageBlock(
    Number(usage.prompt_tokens ?? 0),
    Number(usage.completion_tokens ?? 0),
    Number(usage.prompt_tokens_details?.cached_tokens ?? 0),
    reasoning ? Math.max(1, reasoning.split(/\s+/).length) : 0,
  );
  return resp;
}

// ---------------------------------------------------------------------
// Streaming: OpenAI chunks → Responses SSE events
// ---------------------------------------------------------------------

const sse = (event: string, data: unknown): string =>
  `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;

interface ToolItem {
  id: string;
  callId: string;
  name: string;
  arguments: string;
  outputIndex: number | null;
}

/** Incremental translator (oracle class of the same name). Feed chunks
 *  one at a time; frames flush per upstream chunk. finalResponse()
 *  returns the response.completed payload for the store. */
export class ResponsesStreamTranslator {
  readonly respId = genResponseId();
  readonly #base: Record<string, unknown>;
  #headersSent = false;
  #textItemId = genItemId("msg");
  #textStarted = false;
  #textAccum: string[] = [];
  #reasoningItemId = genItemId("rs");
  #reasoningStarted = false;
  #reasoningClosed = false;
  #reasoningOutputIndex: number | null = null;
  #reasoningAccum: string[] = [];
  #toolItems = new Map<number, ToolItem>();
  #toolOrder: number[] = [];
  #finishReason: string | null = null;
  #inputTokens = 0;
  #outputTokens = 0;
  #cachedTokens = 0;
  #outputIndex = 0;

  constructor(readonly model: string, previousResponseId: string | null = null) {
    this.#base = baseResponse(model, this.respId);
    this.#base.previous_response_id = previousResponseId;
  }

  #headers(out: string[]): void {
    if (this.#headersSent) return;
    this.#headersSent = true;
    out.push(
      sse("response.created", { type: "response.created", response: this.#base }),
      sse("response.in_progress", { type: "response.in_progress", response: this.#base }),
    );
  }

  #closeReasoning(out: string[]): void {
    if (!this.#reasoningStarted || this.#reasoningClosed) return;
    this.#reasoningClosed = true;
    const full = this.#reasoningAccum.join("");
    out.push(
      sse("response.reasoning_summary_text.done", {
        type: "response.reasoning_summary_text.done",
        item_id: this.#reasoningItemId,
        output_index: this.#reasoningOutputIndex,
        summary_index: 0,
        text: full,
      }),
      sse("response.output_item.done", {
        type: "response.output_item.done",
        output_index: this.#reasoningOutputIndex,
        item: {
          id: this.#reasoningItemId,
          type: "reasoning",
          status: "completed",
          summary: [{ type: "summary_text", text: full }],
        },
      }),
    );
  }

  #closeTextItem(out: string[]): void {
    const text = this.#textAccum.join("");
    out.push(
      sse("response.output_text.done", {
        type: "response.output_text.done",
        item_id: this.#textItemId,
        output_index: this.#outputIndex,
        content_index: 0,
        text,
      }),
      sse("response.content_part.done", {
        type: "response.content_part.done",
        item_id: this.#textItemId,
        output_index: this.#outputIndex,
        content_index: 0,
        part: { type: "output_text", text, annotations: [] },
      }),
      sse("response.output_item.done", {
        type: "response.output_item.done",
        output_index: this.#outputIndex,
        item: {
          id: this.#textItemId,
          type: "message",
          status: "completed",
          role: "assistant",
          content: [{ type: "output_text", text, annotations: [] }],
        },
      }),
    );
    this.#outputIndex++;
    this.#textStarted = false;
  }

  addChunk(chunk: any): string[] {
    const out: string[] = [];
    this.#headers(out);

    if (chunk?.usage) {
      this.#inputTokens = Number(chunk.usage.prompt_tokens ?? this.#inputTokens);
      this.#outputTokens = Number(chunk.usage.completion_tokens ?? this.#outputTokens);
      this.#cachedTokens = Number(
        chunk.usage.prompt_tokens_details?.cached_tokens ?? this.#cachedTokens,
      );
    }
    const choice = chunk?.choices?.[0];
    if (!choice) return out;
    const delta = choice.delta ?? {};
    if (choice.finish_reason) this.#finishReason = choice.finish_reason;

    const reasoning = delta.reasoning;
    if (reasoning) {
      if (!this.#reasoningStarted) {
        this.#reasoningStarted = true;
        this.#reasoningOutputIndex = this.#outputIndex++;
        out.push(
          sse("response.output_item.added", {
            type: "response.output_item.added",
            output_index: this.#reasoningOutputIndex,
            item: {
              id: this.#reasoningItemId,
              type: "reasoning",
              status: "in_progress",
              summary: [],
            },
          }),
        );
      }
      this.#reasoningAccum.push(reasoning);
      out.push(
        sse("response.reasoning_summary_text.delta", {
          type: "response.reasoning_summary_text.delta",
          item_id: this.#reasoningItemId,
          output_index: this.#reasoningOutputIndex,
          summary_index: 0,
          delta: reasoning,
        }),
      );
    }

    const text = delta.content;
    if (text) {
      this.#closeReasoning(out);
      if (!this.#textStarted) {
        this.#textStarted = true;
        out.push(
          sse("response.output_item.added", {
            type: "response.output_item.added",
            output_index: this.#outputIndex,
            item: {
              id: this.#textItemId,
              type: "message",
              status: "in_progress",
              role: "assistant",
              content: [],
            },
          }),
          sse("response.content_part.added", {
            type: "response.content_part.added",
            item_id: this.#textItemId,
            output_index: this.#outputIndex,
            content_index: 0,
            part: { type: "output_text", text: "", annotations: [] },
          }),
        );
      }
      this.#textAccum.push(text);
      out.push(
        sse("response.output_text.delta", {
          type: "response.output_text.delta",
          item_id: this.#textItemId,
          output_index: this.#outputIndex,
          content_index: 0,
          delta: text,
        }),
      );
    }

    for (const tcDelta of delta.tool_calls ?? []) {
      const idx = tcDelta.index ?? 0;
      let entry = this.#toolItems.get(idx);
      if (!entry) {
        entry = {
          id: genItemId("fc"),
          callId: tcDelta.id ?? genCallId(),
          name: "",
          arguments: "",
          outputIndex: null,
        };
        this.#toolItems.set(idx, entry);
        this.#toolOrder.push(idx);
      }
      const fn = tcDelta.function ?? {};
      if (fn.name) entry.name += fn.name;
      const argsDelta = fn.arguments ?? "";
      if (argsDelta) entry.arguments += argsDelta;

      if (entry.outputIndex === null) {
        if (this.#textStarted) this.#closeTextItem(out);
        entry.outputIndex = this.#outputIndex++;
        out.push(
          sse("response.output_item.added", {
            type: "response.output_item.added",
            output_index: entry.outputIndex,
            item: {
              id: entry.id,
              type: "function_call",
              status: "in_progress",
              call_id: entry.callId,
              name: entry.name,
              arguments: "",
            },
          }),
        );
      }
      if (argsDelta) {
        out.push(
          sse("response.function_call_arguments.delta", {
            type: "response.function_call_arguments.delta",
            item_id: entry.id,
            output_index: entry.outputIndex,
            delta: argsDelta,
          }),
        );
      }
    }
    return out;
  }

  #finalOutput(): Record<string, unknown>[] {
    const out: Record<string, unknown>[] = [];
    if (this.#reasoningStarted)
      out.push({
        id: this.#reasoningItemId,
        type: "reasoning",
        status: "completed",
        summary: [{ type: "summary_text", text: this.#reasoningAccum.join("") }],
      });
    if (this.#textAccum.length)
      out.push({
        id: this.#textItemId,
        type: "message",
        status: "completed",
        role: "assistant",
        content: [{
          type: "output_text",
          text: this.#textAccum.join(""),
          annotations: [],
        }],
      });
    for (const idx of this.#toolOrder) {
      const entry = this.#toolItems.get(idx)!;
      out.push({
        id: entry.id,
        type: "function_call",
        status: "completed",
        call_id: entry.callId,
        name: entry.name,
        arguments: entry.arguments,
      });
    }
    return out;
  }

  /** The response.completed payload (also what the store captures). */
  finalResponse(): Record<string, unknown> {
    return {
      ...this.#base,
      status: STATUS_MAP[this.#finishReason ?? "stop"] ?? "completed",
      output: this.#finalOutput(),
      usage: usageBlock(
        this.#inputTokens,
        this.#outputTokens,
        this.#cachedTokens,
        this.#reasoningStarted
          ? Math.max(1, this.#reasoningAccum.join("").split(/\s+/).length)
          : 0,
      ),
    };
  }

  finalize(): string[] {
    const out: string[] = [];
    this.#headers(out); // empty generation still gets created/in_progress
    if (this.#textStarted) this.#closeTextItem(out);
    this.#closeReasoning(out);
    for (const idx of this.#toolOrder) {
      const entry = this.#toolItems.get(idx)!;
      out.push(
        sse("response.function_call_arguments.done", {
          type: "response.function_call_arguments.done",
          item_id: entry.id,
          output_index: entry.outputIndex,
          arguments: entry.arguments,
        }),
        sse("response.output_item.done", {
          type: "response.output_item.done",
          output_index: entry.outputIndex,
          item: {
            id: entry.id,
            type: "function_call",
            status: "completed",
            call_id: entry.callId,
            name: entry.name,
            arguments: entry.arguments,
          },
        }),
      );
    }
    out.push(
      sse("response.completed", {
        type: "response.completed",
        response: this.finalResponse(),
      }),
    );
    return out;
  }
}

/** Wrap our OpenAI SSE byte stream as a Responses SSE byte stream.
 *  onComplete fires after response.completed with the final payload so
 *  the route can store it for previous_response_id resumption. */
export function translateOpenAiSseToResponses(
  upstream: ReadableStream<Uint8Array>,
  model: string,
  previousResponseId: string | null,
  onComplete: (final: Record<string, unknown>) => void,
): ReadableStream<Uint8Array> {
  const translator = new ResponsesStreamTranslator(model, previousResponseId);
  const enc = new TextEncoder();
  const dec = new TextDecoder();
  let buf = "";
  let finalized = false;
  return new ReadableStream<Uint8Array>({
    async start(controller) {
      const emit = (frames: string[]) => {
        for (const f of frames) controller.enqueue(enc.encode(f));
      };
      const finish = () => {
        if (finalized) return;
        finalized = true;
        emit(translator.finalize());
        onComplete(translator.finalResponse());
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
              finish();
              continue;
            }
            const parsed = JSON.parse(data);
            if (parsed?.error) {
              emit([
                sse("error", {
                  type: "error",
                  code: "server_error",
                  message: parsed.error.message ?? "generation failed",
                  param: null,
                }),
              ]);
              continue;
            }
            emit(translator.addChunk(parsed));
          }
        }
        finish();
      } catch (e) {
        emit([
          sse("error", {
            type: "error",
            code: "server_error",
            message: (e as Error).message,
            param: null,
          }),
        ]);
      } finally {
        reader.releaseLock();
        controller.close();
      }
    },
  });
}
