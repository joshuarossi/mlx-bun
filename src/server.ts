// OpenAI-compatible HTTP server: /v1/chat/completions (+ SSE streaming)
// and /v1/models. Phase 4 core — tool calling, vision, and the
// byte-capped prompt cache land on top of this.
//
// Generation is serialized through a single queue (one GPU, batch=1).

import type { Server } from "bun";
import { loadModelConfig } from "./config";
import { Weights } from "./weights";
import { Gemma4Model } from "./model/gemma4";
import { generate, type GenerateOptions } from "./generate";
import {
  ChatTemplate, type ChatMessage, type ToolDefinition,
} from "./chat-template";
import { loadTokenizer, type LoadedTokenizer } from "./tokenizer";
import { parseToolCalls, TOOL_CALL_END, TOOL_CALL_START } from "./tool-call";
import { PromptCache } from "./prompt-cache";
import { VisionTower } from "./vision/embedder";
import {
  buildVisionPrompt, extractImages, type VisionTokenIds,
} from "./vision/prompt";

export interface ServerOptions {
  /** Byte cap for the prompt (KV) cache. Default 2 GB. */
  promptCacheBytes?: number;
}

export interface ServerContext {
  model: Gemma4Model;
  tokenizer: LoadedTokenizer;
  template: ChatTemplate;
  modelId: string;
  vision: VisionTower | null;
  visionTokenIds: VisionTokenIds;
}

export async function loadContext(modelDir: string, modelId?: string): Promise<ServerContext> {
  const config = await loadModelConfig(modelDir);
  const weights = await Weights.open(modelDir);
  const model = new Gemma4Model(weights, config);
  return {
    model,
    tokenizer: await loadTokenizer(modelDir),
    template: await ChatTemplate.load(modelDir),
    modelId: modelId ?? modelDir.split("/").filter(Boolean).at(-1)!,
    vision: config.hasVisionSidecar
      ? VisionTower.load(modelDir, model.embedScale, config.text.rmsNormEps)
      : null,
    visionTokenIds: {
      imageTokenId: (config.raw.image_token_id as number) ?? 258880,
      boiTokenId: (config.raw.boi_token_id as number) ?? 255999,
      eoiTokenId: (config.raw.eoi_token_id as number) ?? 258882,
    },
  };
}

interface ChatRequest {
  messages: ChatMessage[];
  stream?: boolean;
  max_tokens?: number;
  max_completion_tokens?: number;
  temperature?: number;
  top_p?: number;
  top_k?: number;
  seed?: number;
  repetition_penalty?: number;
  tools?: ToolDefinition[];
  tool_choice?: "auto" | "none" | { type: string; function?: { name: string } };
}

interface OpenAIToolCall {
  id: string;
  type: "function";
  function: { name: string; arguments: string };
}

/** Routes generated tokens: content goes to the stream decoder, tool-call
 *  segments (token 48 … token 49) are captured and parsed. */
class ToolAwareStream {
  readonly #decoder: StreamDecoder;
  #inTool = false;
  #toolTokens: number[] = [];
  readonly toolSegments: number[][] = [];

  constructor(readonly tokenizer: LoadedTokenizer) {
    this.#decoder = new StreamDecoder(tokenizer);
  }

  /** Returns the content text delta for this token ("" while capturing). */
  push(token: number): string {
    if (this.#inTool) {
      if (token === TOOL_CALL_END) {
        this.#inTool = false;
        this.toolSegments.push(this.#toolTokens);
        this.#toolTokens = [];
      } else {
        this.#toolTokens.push(token);
      }
      return "";
    }
    if (token === TOOL_CALL_START) {
      this.#inTool = true;
      return "";
    }
    return this.#decoder.push(token);
  }

  flush(): string {
    if (this.#inTool && this.#toolTokens.length) {
      // truncated mid-tool-call (hit max_tokens); surface what we have
      this.toolSegments.push(this.#toolTokens);
      this.#toolTokens = [];
    }
    return this.#decoder.flush();
  }

  toolCalls(): OpenAIToolCall[] {
    const out: OpenAIToolCall[] = [];
    for (const seg of this.toolSegments) {
      const text = this.tokenizer.decode(seg, false); // keep <|"|> markers
      for (const c of parseToolCalls(text)) {
        out.push({
          id: `call_${crypto.randomUUID().slice(0, 8)}`,
          type: "function",
          function: { name: c.name, arguments: JSON.stringify(c.arguments) },
        });
      }
    }
    return out;
  }
}

/** OpenAI sends assistant tool_call arguments as JSON strings; the
 *  template renders the object form natively — normalize before render. */
function normalizeMessages(messages: ChatMessage[]): ChatMessage[] {
  return messages.map((m) => {
    if (!m.tool_calls) return m;
    return {
      ...m,
      tool_calls: m.tool_calls.map((tc) => ({
        ...tc,
        function: {
          ...tc.function,
          arguments:
            typeof tc.function.arguments === "string"
              ? (JSON.parse(tc.function.arguments) as Record<string, unknown>)
              : tc.function.arguments,
        },
      })),
    };
  });
}

/** Incremental detokenizer: emits the longest stable decoded prefix. */
class StreamDecoder {
  #ids: number[] = [];
  #emitted = "";

  constructor(readonly tokenizer: LoadedTokenizer) {}

  push(token: number): string {
    this.#ids.push(token);
    const full = this.tokenizer.decode(this.#ids, true);
    // hold back a trailing replacement char (partial multi-byte sequence)
    const stable = full.endsWith("�") ? full.slice(0, -1) : full;
    if (!stable.startsWith(this.#emitted)) {
      // decoder revised earlier text (rare); re-emit from scratch
      const out = stable;
      this.#emitted = stable;
      return out;
    }
    const delta = stable.slice(this.#emitted.length);
    this.#emitted = stable;
    return delta;
  }

  flush(): string {
    const full = this.tokenizer.decode(this.#ids, true);
    const delta = full.slice(this.#emitted.length);
    this.#emitted = full;
    return delta;
  }
}

export function createServer(
  ctx: ServerContext, port = 0, serverOptions: ServerOptions = {},
): Server<unknown> {
  let queue: Promise<unknown> = Promise.resolve();
  const enqueue = <T>(fn: () => Promise<T>): Promise<T> => {
    const run = queue.then(fn, fn);
    queue = run.catch(() => {});
    return run;
  };

  const promptCache = new PromptCache(serverOptions.promptCacheBytes ?? 2e9);

  /** Run one generation with prompt-cache reuse. Must be called inside
   *  the queue. Vision requests bypass the prompt cache: image tokens are
   *  identical placeholder ids, so prefix matching across different
   *  images would false-hit. */
  const runGeneration = async (
    promptIds: number[],
    options: GenerateOptions,
    onToken: (token: number) => void,
    vision?: { embeddings: import("./mlx/array").MlxArray; imageMask: import("./mlx/array").MlxArray },
  ) => {
    const entry = vision ? null : promptCache.take(promptIds);
    const caches = entry?.caches ?? ctx.model.makeCache();
    try {
      const gen = generate(ctx.model, promptIds, {
        ...options,
        cache: caches,
        ...(vision ? { promptEmbeddings: vision.embeddings, imageMask: vision.imageMask } : {}),
      });
      for await (const t of gen) onToken(t.token);
      const s = gen.stats!;
      if (vision) {
        for (const c of caches) c.dispose();
      } else {
        promptCache.put(s.cacheTokens, caches);
      }
      return s;
    } catch (e) {
      for (const c of caches) c.dispose();
      throw e;
    } finally {
      vision?.embeddings.dispose();
      vision?.imageMask.dispose();
    }
  };

  const toOptions = (req: ChatRequest): GenerateOptions => ({
    maxTokens: req.max_completion_tokens ?? req.max_tokens ?? 1024,
    temperature: req.temperature ?? 0.7,
    topP: req.top_p ?? 0,
    topK: req.top_k ?? 0,
    seed: req.seed ?? (Date.now() & 0xffffffff),
    repetitionPenalty: req.repetition_penalty,
  });

  const promptIdsFor = (messages: ChatMessage[], tools: ToolDefinition[] | null): number[] => {
    const rendered = ctx.template.render(normalizeMessages(messages), { tools });
    const ids = ctx.tokenizer.encode(rendered);
    // template includes <bos>; tokenizer post-processor also prepends one
    return ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId ? ids.slice(1) : ids;
  };

  return Bun.serve({
    port,
    idleTimeout: 0,
    async fetch(request) {
      const url = new URL(request.url);

      if (url.pathname === "/stats" && request.method === "GET") {
        return Response.json({
          prompt_cache: {
            entries: promptCache.size,
            bytes: promptCache.totalBytes,
            max_bytes: promptCache.maxBytes,
            hits: promptCache.hits,
            misses: promptCache.misses,
          },
        });
      }

      if (url.pathname === "/v1/models" && request.method === "GET") {
        return Response.json({
          object: "list",
          data: [{ id: ctx.modelId, object: "model", created: 0, owned_by: "mlx-bun" }],
        });
      }

      if (url.pathname === "/v1/chat/completions" && request.method === "POST") {
        let body: ChatRequest;
        try {
          body = (await request.json()) as ChatRequest;
        } catch {
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        if (!Array.isArray(body.messages) || body.messages.length === 0)
          return Response.json({ error: { message: "messages required" } }, { status: 400 });

        const id = `chatcmpl-${crypto.randomUUID()}`;
        const created = Math.floor(Date.now() / 1000);
        const tools =
          body.tool_choice === "none" ? null : (body.tools?.length ? body.tools : null);
        const hasImages = body.messages.some(
          (m) => Array.isArray(m.content) &&
            m.content.some((p: any) => p.type === "image_url" || p.type === "image"),
        );
        let promptIds: number[];
        let vision: Parameters<typeof runGeneration>[3];
        try {
          if (hasImages) {
            if (!ctx.vision)
              return Response.json(
                { error: { message: "model has no vision sidecar" } }, { status: 400 },
              );
            const { messages, images } = await extractImages(normalizeMessages(body.messages));
            const vp = buildVisionPrompt(
              ctx.model, ctx.vision, ctx.tokenizer, ctx.template,
              messages, images, ctx.visionTokenIds, tools,
            );
            promptIds = vp.ids;
            vision = { embeddings: vp.embeddings, imageMask: vp.imageMask };
          } else {
            promptIds = promptIdsFor(body.messages, tools);
          }
        } catch (e) {
          return Response.json(
            { error: { message: `prompt build failed: ${(e as Error).message}` } },
            { status: 400 },
          );
        }
        const options = toOptions(body);

        if (body.stream) {
          const stream = new ReadableStream<Uint8Array>({
            async start(controller) {
              const enc = new TextEncoder();
              const send = (obj: unknown) =>
                controller.enqueue(enc.encode(`data: ${JSON.stringify(obj)}\n\n`));
              const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
                id, object: "chat.completion.chunk", created, model: ctx.modelId,
                choices: [{ index: 0, delta, finish_reason: finish }],
              });
              try {
                await enqueue(async () => {
                  send(chunk({ role: "assistant", content: "" }, null));
                  const router = new ToolAwareStream(ctx.tokenizer);
                  const s = await runGeneration(promptIds, options, (token) => {
                    const text = router.push(token);
                    if (text) send(chunk({ content: text }, null));
                  }, vision);
                  const tail = router.flush();
                  if (tail) send(chunk({ content: tail }, null));
                  const toolCalls = router.toolCalls();
                  if (toolCalls.length) {
                    send(chunk({
                      tool_calls: toolCalls.map((tc, i) => ({ index: i, ...tc })),
                    }, null));
                  }
                  const finish = toolCalls.length
                    ? "tool_calls"
                    : s.generatedTokens >= (options.maxTokens ?? 1024) ? "length" : "stop";
                  send({
                    ...chunk({}, finish),
                    usage: {
                      prompt_tokens: s.promptTokens,
                      completion_tokens: s.generatedTokens,
                      total_tokens: s.promptTokens + s.generatedTokens,
                      prompt_tokens_details: { cached_tokens: s.cachedTokens },
                    },
                  });
                  send("[DONE]");
                });
              } catch (e) {
                send({ error: { message: (e as Error).message } });
              } finally {
                controller.close();
              }
            },
          });
          return new Response(stream, {
            headers: {
              "content-type": "text/event-stream",
              "cache-control": "no-cache",
              connection: "keep-alive",
            },
          });
        }

        try {
          return await enqueue(async () => {
            const router = new ToolAwareStream(ctx.tokenizer);
            let content = "";
            const s = await runGeneration(promptIds, options, (token) => {
              content += router.push(token);
            }, vision);
            content += router.flush();
            const toolCalls = router.toolCalls();
            const finish = toolCalls.length
              ? "tool_calls"
              : s.generatedTokens >= (options.maxTokens ?? 1024) ? "length" : "stop";
            return Response.json({
              id, object: "chat.completion", created, model: ctx.modelId,
              choices: [{
                index: 0,
                message: {
                  role: "assistant",
                  content: content || (toolCalls.length ? null : ""),
                  ...(toolCalls.length ? { tool_calls: toolCalls } : {}),
                },
                finish_reason: finish,
              }],
              usage: {
                prompt_tokens: s.promptTokens,
                completion_tokens: s.generatedTokens,
                total_tokens: s.promptTokens + s.generatedTokens,
                prompt_tokens_details: { cached_tokens: s.cachedTokens },
              },
            });
          });
        } catch (e) {
          return Response.json({ error: { message: (e as Error).message } }, { status: 500 });
        }
      }

      return Response.json({ error: { message: "not found" } }, { status: 404 });
    },
  });
}
