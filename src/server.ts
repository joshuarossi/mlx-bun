// OpenAI-compatible HTTP server: /v1/chat/completions (+ SSE streaming)
// and /v1/models. Phase 4 core — tool calling, vision, and the
// byte-capped prompt cache land on top of this.
//
// Original code; behavioral reference: mlx-lm server.py (MIT) for the
// protocol surface and stop/finish semantics. No code ported — Bun.serve
// and the generation queue are structurally different.
//
// Generation is serialized through a single queue (one GPU, batch=1).

import type { Server } from "bun";
import { loadModelConfig, type KvQuantSpec } from "./config";
import { Weights } from "./weights";
import { Gemma4Model } from "./model/gemma4";
import { generate, type GenerateOptions } from "./generate";
import {
  ChatTemplate, type ChatMessage, type ToolDefinition,
} from "./chat-template";
import { loadTokenizer, type LoadedTokenizer } from "./tokenizer";
import { parseToolCalls, TOOL_CALL_END, TOOL_CALL_START } from "./tool-call";
import { PromptCache } from "./prompt-cache";
import { AdapterManager } from "./lora";
import { fit } from "./fit";
import { setMemoryLimit } from "./mlx/ffi";
import { VisionTower } from "./vision/embedder";
import {
  buildVisionPrompt, extractImages, type VisionTokenIds,
} from "./vision/prompt";

export interface ServerOptions {
  /** Byte cap for the prompt (KV) cache. Default 2 GB. */
  promptCacheBytes?: number;
  /** KV quantization override. Default: apply ctx.kvConfig when present
   *  (mixed per-layer). "off" forces bf16; a number forces uniform bits
   *  (group size 64, start 0) ignoring the config file. */
  kvQuant?: "off" | number;
  /** Memory budget for the serving process (admission control — Phase 5).
   *  Requests whose prompt + max_tokens exceed the budget's max safe
   *  context are rejected with 400 instead of crashing the GPU: the OOM
   *  crash class is UNCATCHABLE (Phase 6 — mlx throws from a Metal
   *  completion handler ⇒ std::terminate; optiq serve died exactly this
   *  way loading the 26B). Also caps the mlx allocator
   *  (mlx_set_memory_limit) as defense in depth. Default: machine RAM ×
   *  WIRED_FRACTION, admission check only, allocator untouched. */
  memoryBudgetBytes?: number;
}

export interface ServerContext {
  model: Gemma4Model;
  tokenizer: LoadedTokenizer;
  template: ChatTemplate;
  modelId: string;
  vision: VisionTower | null;
  visionTokenIds: VisionTokenIds;
  adapters: AdapterManager;
  /** Per-layer KV quantization from the repo's kv_config.json (null if
   *  absent). Applied by default — optiq serve's headline behavior;
   *  ServerOptions.kvQuant overrides ("off" | uniform bits). */
  kvConfig: KvQuantSpec[] | null;
}

export async function loadContext(
  modelDir: string, modelId?: string,
  opts: { memoryBudgetBytes?: number } = {},
): Promise<ServerContext> {
  const config = await loadModelConfig(modelDir);
  const weights = await Weights.open(modelDir);
  // memoryBudget enforcement at load (Phase 5): Weights.open only mmaps
  // (no GPU allocation yet), so a model whose weights can never serve
  // within the budget is refused HERE — before any unified-memory
  // commitment — with an actionable error instead of a Metal OOM later.
  if (opts.memoryBudgetBytes) {
    const weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    const report = fit(config, weightsBytes, 1, undefined, undefined, 0, opts.memoryBudgetBytes);
    if (report.maxSafeContext < 1)
      throw new Error(
        `model does not fit the memory budget: weights ${(weightsBytes / 1e9).toFixed(2)} GB ` +
        `+ prefill transient leave no room for any context within ` +
        `${(opts.memoryBudgetBytes / 1e9).toFixed(2)} GB`,
      );
  }
  const model = new Gemma4Model(weights, config);
  return {
    model,
    adapters: new AdapterManager(model),
    kvConfig: config.kvQuant,
    tokenizer: await loadTokenizer(modelDir),
    template: await ChatTemplate.load(modelDir),
    modelId: modelId ?? modelDir.split("/").filter(Boolean).at(-1)!,
    // A sidecar that fails to load is a capability gap, not a fatal
    // error: e4b/26B ship SigLIP-format sidecars (Phase 12); only the
    // 12B's encoder-free format loads today. Serve text-only.
    vision: config.hasVisionSidecar
      ? (() => {
          try {
            return VisionTower.load(modelDir, model.embedScale, config.text.rmsNormEps);
          } catch (e) {
            console.warn(
              `vision sidecar not loadable (${(e as Error).message}) — ` +
              `serving text-only (SigLIP sidecars land in Phase 12)`,
            );
            return null;
          }
        })()
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
  /** Mounted LoRA adapter selection: "id", "a+b" (stacked), or "none". */
  adapter?: string;
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
    onToken: (token: number) => void | Promise<void>,
    vision?: { embeddings: import("./mlx/array").MlxArray; imageMask: import("./mlx/array").MlxArray },
  ) => {
    // Cache entries are adapter-specific: KV computed under one adapter
    // must never seed another's (or the base's) prefill.
    const cacheNs = options.adapters?.join("+") ?? "";
    const entry = vision ? null : promptCache.take(promptIds, cacheNs);
    const caches = entry?.caches ?? ctx.model.makeCache();
    try {
      const gen = generate(ctx.model, promptIds, {
        ...options,
        cache: caches,
        ...(vision ? { promptEmbeddings: vision.embeddings, imageMask: vision.imageMask } : {}),
      });
      for await (const t of gen) await onToken(t.token);
      const s = gen.stats!;
      if (vision) {
        for (const c of caches) c.dispose();
      } else {
        promptCache.put(s.cacheTokens, caches, cacheNs);
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

  // Admission ceiling, resolved once (Phase 5 memoryBudget enforcement).
  // fit() solves max safe context from weights + KV growth + prefill
  // transient; the KV term assumes bf16 (a kv-quant scheme stretches the
  // real ceiling, never shrinks it — admission stays conservative).
  const admission = fit(
    ctx.model.config, ctx.model.weightsBytes, 1,
    undefined, undefined, 0, serverOptions.memoryBudgetBytes,
  );
  if (admission.maxSafeContext < 1)
    throw new Error(
      `memory budget ${(admission.usableBytes / 1e9).toFixed(2)} GB cannot serve ` +
      `${ctx.modelId} (weights ${(ctx.model.weightsBytes / 1e9).toFixed(2)} GB): ` +
      `no context fits — raise the budget or pick a smaller model`,
    );
  if (serverOptions.memoryBudgetBytes) setMemoryLimit(serverOptions.memoryBudgetBytes);

  // KV-quant scheme, resolved once: kv_config.json by default (optiq
  // serve's headline behavior), overridable to uniform bits or off.
  const kvScheme: Pick<GenerateOptions, "kvBits" | "kvConfig" | "quantizedKvStart"> =
    serverOptions.kvQuant === "off" ? {}
    : typeof serverOptions.kvQuant === "number"
      ? { kvBits: serverOptions.kvQuant, quantizedKvStart: 0 }
    : ctx.kvConfig?.length ? { kvConfig: ctx.kvConfig } : {};

  const toOptions = (req: ChatRequest): GenerateOptions => ({
    maxTokens: req.max_completion_tokens ?? req.max_tokens ?? 1024,
    temperature: req.temperature ?? 0.7,
    topP: req.top_p ?? 0,
    topK: req.top_k ?? 0,
    seed: req.seed ?? (Date.now() & 0xffffffff),
    repetitionPenalty: req.repetition_penalty,
    ...kvScheme,
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
        // Active KV scheme: which donor layers quantize and at what bits.
        // Sliding/rotating layers stay bf16 until Phase 9.
        const layerTypes = ctx.model.config.text.layerTypes;
        const kvLayers: Record<string, number> = {};
        let kvMode = "bf16";
        if (kvScheme.kvBits) {
          kvMode = `uniform-kv${kvScheme.kvBits}`;
          for (let i = 0; i < layerTypes.length; i++)
            if (layerTypes[i] === "full_attention")
              kvLayers[`kv${kvScheme.kvBits}`] = (kvLayers[`kv${kvScheme.kvBits}`] ?? 0) + 1;
        } else if (kvScheme.kvConfig) {
          kvMode = "mixed (kv_config.json)";
          for (const e of kvScheme.kvConfig)
            if (layerTypes[e.layerIdx] === "full_attention")
              kvLayers[`kv${e.bits}`] = (kvLayers[`kv${e.bits}`] ?? 0) + 1;
        }
        const bf16Layers = layerTypes.length - Object.values(kvLayers).reduce((a, b) => a + b, 0);
        return Response.json({
          prompt_cache: {
            entries: promptCache.size,
            bytes: promptCache.totalBytes,
            max_bytes: promptCache.maxBytes,
            hits: promptCache.hits,
            misses: promptCache.misses,
          },
          kv_quant: {
            mode: kvMode,
            layers: { ...kvLayers, bf16: bf16Layers },
          },
          admission: {
            max_safe_context: admission.maxSafeContext,
            memory_budget_bytes: serverOptions.memoryBudgetBytes ?? null,
            usable_bytes: admission.usableBytes,
            weights_bytes: ctx.model.weightsBytes,
          },
        });
      }

      if (url.pathname === "/v1/models" && request.method === "GET") {
        return Response.json({
          object: "list",
          data: [{ id: ctx.modelId, object: "model", created: 0, owned_by: "mlx-bun" }],
        });
      }

      // Adapter admin (port of optiq registry semantics): list / mount /
      // unmount. Mount and unmount go through the generation queue so
      // they never race an in-flight forward pass.
      if (url.pathname === "/v1/adapters" && request.method === "GET") {
        return Response.json({
          adapters: ctx.adapters.list().map((a) => ({
            id: a.id, path: a.path, rank: a.rank, scale: a.scale,
            size_bytes: a.sizeBytes, mounted_layers: a.mountedLayers,
          })),
        });
      }
      if (url.pathname === "/v1/adapters" && request.method === "POST") {
        let body: { id?: string; path?: string };
        try {
          body = (await request.json()) as typeof body;
        } catch {
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        if (!body.id || !body.path)
          return Response.json({ error: { message: "id and path required" } }, { status: 400 });
        try {
          const info = await enqueue(() => ctx.adapters.mount(body.id!, body.path!));
          return Response.json({
            id: info.id, mounted_layers: info.mountedLayers,
            rank: info.rank, scale: info.scale,
          });
        } catch (e) {
          return Response.json({ error: { message: (e as Error).message } }, { status: 400 });
        }
      }
      if (url.pathname.startsWith("/v1/adapters/") && request.method === "DELETE") {
        const id = decodeURIComponent(url.pathname.slice("/v1/adapters/".length));
        const removed = await enqueue(async () => ctx.adapters.unmount(id));
        return removed > 0
          ? Response.json({ id, removed_layers: removed })
          : Response.json({ error: { message: `adapter ${id} not mounted` } }, { status: 404 });
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
            const vp = await buildVisionPrompt(
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
        // Admission: reject what cannot finish within the memory budget
        // (the GPU OOM it would otherwise hit is uncatchable and kills
        // the process — Phase 6 finding).
        const requiredCtx = promptIds.length + (options.maxTokens ?? 1024);
        if (requiredCtx > admission.maxSafeContext) {
          vision?.embeddings.dispose();
          vision?.imageMask.dispose();
          return Response.json(
            {
              error: {
                message:
                  `request needs ${requiredCtx} tokens of context ` +
                  `(prompt ${promptIds.length} + max_tokens ${options.maxTokens}) but the ` +
                  `memory budget caps safe context at ${admission.maxSafeContext} — ` +
                  `shorten the prompt or lower max_tokens`,
                type: "memory_admission",
                code: "context_over_budget",
              },
            },
            { status: 400 },
          );
        }
        try {
          const adapterIds = ctx.adapters.resolveSpec(body.adapter);
          if (adapterIds.length) options.adapters = adapterIds;
        } catch (e) {
          return Response.json({ error: { message: (e as Error).message } }, { status: 400 });
        }

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
                  // The decode loop is an unbroken microtask chain (FFI +
                  // generator resumes) — without a macrotask hop, Bun never
                  // services the socket and the whole SSE response flushes
                  // in one burst at the end (found by the Phase 15 harness:
                  // "687k tok/s decode"). Hopping EVERY token cost ~23%
                  // decode; rate-limited to ≥25 ms intervals the flush stays
                  // smooth for any client and the hop hides behind the
                  // already-dispatched next GPU step.
                  let lastFlush = performance.now();
                  const s = await runGeneration(promptIds, options, (token) => {
                    const text = router.push(token);
                    if (text) {
                      send(chunk({ content: text }, null));
                      const now = performance.now();
                      if (now - lastFlush >= 25) {
                        lastFlush = now;
                        return new Promise<void>((r) => setImmediate(r));
                      }
                    }
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
