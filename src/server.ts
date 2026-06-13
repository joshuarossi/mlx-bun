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
// Embedded status page (Phase 16): `with { type: "text" }` inlines the
// file in both `bun run` and the compiled single binary. bun-types
// types *.html imports as HTMLBundle (the html loader), but the text
// attribute makes the runtime value a string — hence the double cast.
import statusPageHtml from "./status-page.html" with { type: "text" };
import chatPageHtml from "./chat-page.html" with { type: "text" };
import pkgJson from "../package.json" with { type: "json" };
const STATUS_PAGE = statusPageHtml as unknown as string;
const CHAT_PAGE = chatPageHtml as unknown as string;
const pkgVersion = (pkgJson as { version: string }).version;
import { loadModelConfig, type KvQuantSpec } from "./config";
import { Weights } from "./weights";
import { Gemma4Model } from "./model/gemma4";
import { createModel, type RuntimeModel } from "./model/factory";
import { isMiniCPM5Config, isSupportedModelRecord } from "./model/support";
import { generate, type GenerateOptions } from "./generate";
import {
  ChatTemplate, type ChatMessage, type ToolDefinition,
} from "./chat-template";
import { loadTokenizer, type LoadedTokenizer } from "./tokenizer";
import {
  parseGeneratedToolCalls, parseToolCalls, TOOL_CALL_END, TOOL_CALL_START,
} from "./tool-call";
import { PromptCache } from "./prompt-cache";
import {
  anthropicToChatBody, chatJsonToAnthropic, translateOpenAiSse,
  type AnthropicRequest,
} from "./anthropic";
import {
  ResponseStore, chatJsonToResponses, outputItemsToInputItems,
  responsesToChatBody, translateOpenAiSseToResponses,
  type ResponsesRequest,
} from "./responses";
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
  /** Who owns this server's lifetime: "serve" (persistent, mlx-bun
   *  serve) or "pi-session" (dies with the pi session that started
   *  it). Exposed at /stats.server so other mlx-bun processes can
   *  warn before attaching to a server that may vanish. */
  owner?: "serve" | "pi-session" | "embedded";
  /** Interface to bind (Bun.serve hostname). Default: Bun's default
   *  (all interfaces); pass "127.0.0.1" for loopback-only. */
  hostname?: string;
  /** Server-wide default for the chat template's `enable_thinking`
   *  variable (MiniCPM5/CPM and other hybrid-reasoning models). A
   *  request's `chat_template_kwargs.enable_thinking` overrides it per
   *  call; undefined ⇒ fall back to the model's own default (false for
   *  MiniCPM5). Set via `--thinking true|false`. */
  defaultThinking?: boolean;
  /** Server-wide sampling defaults (set via --temperature/--top-p/--top-k).
   *  Precedence: an explicit per-request field wins, then these, then the
   *  model's generation_config.json, then the built-in fallback. Lets the
   *  browser chat (which sends no sampling fields) be steered from the CLI. */
  defaultTemperature?: number;
  defaultTopP?: number;
  defaultTopK?: number;
}

export interface ServerContext {
  model: RuntimeModel;
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
  /** Model-author recommended sampling from generation_config.json —
   *  optiq serve injects these as server defaults (gen_config.py);
   *  explicit request fields always win. */
  genDefaults: GenSamplingDefaults;
}

export interface GenSamplingDefaults {
  temperature?: number;
  topP?: number;
  topK?: number;
  repetitionPenalty?: number;
}

async function loadGenSamplingDefaults(modelDir: string): Promise<GenSamplingDefaults> {
  const file = Bun.file(`${modelDir}/generation_config.json`);
  if (!(await file.exists())) return {};
  try {
    const raw = (await file.json()) as Record<string, unknown>;
    const num = (v: unknown) => (typeof v === "number" ? v : undefined);
    return {
      temperature: num(raw.temperature),
      topP: num(raw.top_p),
      topK: num(raw.top_k),
      repetitionPenalty: num(raw.repetition_penalty),
    };
  } catch {
    return {};
  }
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
  // generated-specialization dispatch by config fingerprint (Phase C);
  // unmatched configs run the monolith — slow, never broken
  const model = createModel(weights, config);
  return {
    model,
    adapters: new AdapterManager(model),
    kvConfig: config.kvQuant,
    genDefaults: await loadGenSamplingDefaults(modelDir),
    tokenizer: await loadTokenizer(modelDir),
    template: await ChatTemplate.load(modelDir),
    modelId: modelId ?? modelDir.split("/").filter(Boolean).at(-1)!,
    // A sidecar that fails to load is a capability gap, not a fatal
    // error: e4b/26B ship SigLIP-format sidecars (Phase 12); only the
    // 12B's encoder-free format loads today. Serve text-only.
    // Vision sidecars are a Gemma4 feature; MiniCPM5 never ships one.
    vision: config.hasVisionSidecar && model instanceof Gemma4Model
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
  /** OpenAI stop sequences: plain string or array (spec allows up to 4).
   *  Matched on DECODED text, not token ids — see StopMatcher. */
  stop?: string | string[];
  tools?: ToolDefinition[];
  tool_choice?: "auto" | "none" | { type: string; function?: { name: string } };
  /** Forwarded to HF chat templates, matching optiq serve. MiniCPM5 uses
   *  enable_thinking to select direct answers vs the <think> channel. */
  chat_template_kwargs?: {
    enable_thinking?: boolean;
    [key: string]: unknown;
  };
  /** Mounted LoRA adapter selection: "id", "a+b" (stacked), or "none". */
  adapter?: string;
}

interface OpenAIToolCall {
  id: string;
  type: "function";
  function: { name: string; arguments: string };
}

type ToolStreamMode = "gemma-sentinel" | "plain" | "buffered-text";

/** Routes generated tokens. Gemma uses family-specific sentinel token ids;
 *  MiniCPM5 and other text-template models use decoded-text parsing so
 *  ordinary tokenizer ids like "<" are never swallowed globally. */
class ToolAwareStream {
  readonly #decoder: StreamDecoder;
  #inTool = false;
  #toolTokens: number[] = [];
  #text = "";
  /** Chars of #text already returned as content. */
  #sent = 0;
  /** Index where tool markup starts; content emission stops there. */
  #frozen = -1;
  #textToolCalls: OpenAIToolCall[] | null = null;
  #textToolParseFailed = false;
  readonly toolSegments: number[][] = [];

  /** Decoded-text markers that open tool markup (oracle: the streaming
   *  parser buffers from `<tool_call`/`<function` on, never the whole
   *  response — content before a tool call still streams live). */
  static readonly TOOL_MARKERS = ["<tool_call>", "<function"];

  constructor(
    readonly tokenizer: LoadedTokenizer,
    readonly mode: ToolStreamMode,
    readonly tools: ToolDefinition[] | null,
  ) {
    this.#decoder = new StreamDecoder(tokenizer, mode !== "buffered-text");
  }

  /** Emit the longest #text prefix that cannot be (the start of) tool
   *  markup; hold back ambiguous tails until disambiguated. */
  #textDelta(): string {
    if (this.#frozen >= 0) return "";
    let markerAt = -1;
    for (const mk of ToolAwareStream.TOOL_MARKERS) {
      const i = this.#text.indexOf(mk, this.#sent);
      if (i !== -1 && (markerAt === -1 || i < markerAt)) markerAt = i;
    }
    if (markerAt !== -1) {
      this.#frozen = markerAt;
      const out = this.#text.slice(this.#sent, markerAt);
      this.#sent = markerAt;
      return out;
    }
    let hold = 0;
    for (const mk of ToolAwareStream.TOOL_MARKERS) {
      const max = Math.min(mk.length - 1, this.#text.length - this.#sent);
      for (let k = max; k > hold; k--) {
        if (this.#text.endsWith(mk.slice(0, k))) { hold = k; break; }
      }
    }
    const limit = this.#text.length - hold;
    if (limit <= this.#sent) return "";
    const out = this.#text.slice(this.#sent, limit);
    this.#sent = limit;
    return out;
  }

  /** Returns the content text delta for this token ("" while capturing). */
  push(token: number): string {
    if (this.mode !== "gemma-sentinel") {
      this.#text += this.#decoder.push(token);
      if (this.mode === "plain") {
        const out = this.#text.slice(this.#sent);
        this.#sent = this.#text.length;
        return out;
      }
      return this.#textDelta();
    }
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
    if (this.mode !== "gemma-sentinel") {
      this.#text += this.#decoder.flush();
      if (this.mode === "buffered-text") {
        const calls = this.toolCalls();
        if (calls.length && !this.#textToolParseFailed && this.#frozen >= 0) {
          // markup parsed into tool_calls — emit any prose still held
          // before it; the markup itself never reaches content
          const out = this.#text.slice(this.#sent, this.#frozen);
          this.#sent = this.#text.length;
          return out;
        }
        // no tool call (or parse fallback): release everything withheld
        const out = this.#text.slice(this.#sent);
        this.#sent = this.#text.length;
        return out;
      }
      const out = this.#text.slice(this.#sent);
      this.#sent = this.#text.length;
      return out;
    }
    if (this.#inTool && this.#toolTokens.length) {
      // truncated mid-tool-call (hit max_tokens); surface what we have
      this.toolSegments.push(this.#toolTokens);
      this.#toolTokens = [];
    }
    return this.#decoder.flush();
  }

  toolCalls(): OpenAIToolCall[] {
    if (this.mode !== "gemma-sentinel") {
      if (this.#textToolCalls) return this.#textToolCalls;
      try {
        this.#textToolCalls = parseGeneratedToolCalls(this.#text, this.tools ?? []).map((c) => ({
          id: `call_${crypto.randomUUID().slice(0, 8)}`,
          type: "function",
          function: { name: c.name, arguments: JSON.stringify(c.arguments) },
        }));
      } catch {
        this.#textToolParseFailed = true;
        this.#textToolCalls = [];
      }
      return this.#textToolCalls;
    }
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

/** Decoded-text stop-sequence matcher with streaming hold-back. Matching
 *  on text (not token ids) catches sequences that span token boundaries
 *  or tokenize differently in context; current mlx-lm uses token-id
 *  state machines and misses those. Text that could be the start of a
 *  stop sequence is withheld until disambiguated, so SSE clients never
 *  see any part of the stop sequence itself. */
export class StopMatcher {
  #pending = "";
  stopped = false;

  constructor(readonly sequences: string[]) {}

  /** Feed a text delta; returns the prefix that is now safe to emit.
   *  After a match fires (`stopped`), text before the match is returned
   *  and everything from the match on is discarded. */
  push(text: string): string {
    if (this.stopped) return "";
    if (this.sequences.length === 0) return text;
    this.#pending += text;
    // earliest full match wins
    let cut = -1;
    for (const seq of this.sequences) {
      const i = this.#pending.indexOf(seq);
      if (i !== -1 && (cut === -1 || i < cut)) cut = i;
    }
    if (cut !== -1) {
      this.stopped = true;
      const out = this.#pending.slice(0, cut);
      this.#pending = "";
      return out;
    }
    // hold back the longest tail that is a proper prefix of any sequence
    let hold = 0;
    for (const seq of this.sequences) {
      const max = Math.min(seq.length - 1, this.#pending.length);
      for (let k = max; k > hold; k--) {
        if (this.#pending.endsWith(seq.slice(0, k))) {
          hold = k;
          break;
        }
      }
    }
    if (hold === 0) {
      const out = this.#pending;
      this.#pending = "";
      return out;
    }
    const out = this.#pending.slice(0, -hold);
    this.#pending = this.#pending.slice(-hold);
    return out;
  }

  /** Generation ended without a match — release any held-back text. */
  flush(): string {
    const out = this.#pending;
    this.#pending = "";
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

  constructor(
    readonly tokenizer: LoadedTokenizer,
    readonly skipSpecialTokens = true,
  ) {}

  push(token: number): string {
    this.#ids.push(token);
    const full = this.tokenizer.decode(this.#ids, this.skipSpecialTokens);
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
    const full = this.tokenizer.decode(this.#ids, this.skipSpecialTokens);
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
  // Responses-API store for previous_response_id resumption (Phase 11):
  // TTL + byte-capped LRU, port of optiq/response_store.py. Pairs with
  // the prompt cache: a resumed conversation re-renders the same prefix,
  // so its KV prefill is already cached.
  const responseStore = new ResponseStore();

  /** Run one generation with prompt-cache reuse. Must be called inside
   *  the queue. onToken returning `false` halts generation early (stop
   *  sequence fired); the cache snapshot stays valid and is still kept.
   *  Vision requests bypass the prompt cache: image tokens are
   *  identical placeholder ids, so prefix matching across different
   *  images would false-hit. */
  const runGeneration = async (
    promptIds: number[],
    options: GenerateOptions,
    onToken: (token: number) => void | boolean | Promise<void | boolean>,
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
      for await (const t of gen) {
        if ((await onToken(t.token)) === false) break;
      }
      const s = gen.stats!; // set on completion AND on early break
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

  // /library response cache (30 s) — registry + config reads only.
  let libraryCache: { at: number; rows: unknown[] } | null = null;
  const startedAt = Date.now();

  // KV-quant scheme, resolved once: kv_config.json by default (optiq
  // serve's headline behavior), overridable to uniform bits or off.
  const kvScheme: Pick<GenerateOptions, "kvBits" | "kvConfig" | "quantizedKvStart"> =
    serverOptions.kvQuant === "off" ? {}
    : typeof serverOptions.kvQuant === "number"
      ? { kvBits: serverOptions.kvQuant, quantizedKvStart: 0 }
    : ctx.kvConfig?.length ? { kvConfig: ctx.kvConfig } : {};

  const toOptions = (req: ChatRequest): GenerateOptions & { stopSequences: string[] } => ({
    maxTokens: req.max_completion_tokens ?? req.max_tokens ?? 1024,
    temperature: req.temperature ?? serverOptions.defaultTemperature ?? ctx.genDefaults.temperature ?? 0.7,
    topP: req.top_p ?? serverOptions.defaultTopP ?? ctx.genDefaults.topP ?? 0,
    topK: req.top_k ?? serverOptions.defaultTopK ?? ctx.genDefaults.topK ?? 0,
    seed: req.seed ?? (Date.now() & 0xffffffff),
    repetitionPenalty: req.repetition_penalty ?? ctx.genDefaults.repetitionPenalty,
    // generate() yields token ids; stop sequences match on decoded text
    // (they can span token boundaries), so the StopMatcher sits at the
    // decode layer below and halts the loop via onToken → false.
    stopSequences: (typeof req.stop === "string" ? [req.stop] : req.stop ?? [])
      .filter((s) => typeof s === "string" && s.length > 0),
    ...kvScheme,
  });

  const templateOptionsFor = (req: ChatRequest, tools: ToolDefinition[] | null) => {
    // Precedence: per-request chat_template_kwargs wins; else the
    // server-wide --thinking default; else the model's own default
    // (false for MiniCPM5, otherwise leave the template's default).
    const requested = req.chat_template_kwargs?.enable_thinking;
    return {
      tools,
      enableThinking: typeof requested === "boolean"
        ? requested
        : serverOptions.defaultThinking !== undefined
          ? serverOptions.defaultThinking
          : isMiniCPM5Config(ctx.model.config) ? false : undefined,
    };
  };

  const promptIdsFor = (req: ChatRequest, tools: ToolDefinition[] | null): number[] => {
    const rendered = ctx.template.render(normalizeMessages(req.messages), templateOptionsFor(req, tools));
    const ids = ctx.tokenizer.encode(rendered);
    // template includes <bos>; tokenizer post-processor also prepends one
    return ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId ? ids.slice(1) : ids;
  };

  const toolStreamMode = (tools: ToolDefinition[] | null): ToolStreamMode => {
    if (isMiniCPM5Config(ctx.model.config)) return tools?.length ? "buffered-text" : "plain";
    return "gemma-sentinel";
  };

  const toolRouter = (tools: ToolDefinition[] | null): ToolAwareStream =>
    new ToolAwareStream(ctx.tokenizer, toolStreamMode(tools), tools);

  return Bun.serve({
    port,
    ...(serverOptions.hostname ? { hostname: serverOptions.hostname } : {}),
    idleTimeout: 0,
    async fetch(request) {
      const url = new URL(request.url);

      if ((url.pathname === "/" || url.pathname === "/status") && request.method === "GET") {
        return new Response(STATUS_PAGE, {
          headers: { "content-type": "text/html; charset=utf-8" },
        });
      }

      if (url.pathname === "/chat" && request.method === "GET") {
        return new Response(CHAT_PAGE, {
          headers: { "content-type": "text/html; charset=utf-8" },
        });
      }

      if (url.pathname === "/library" && request.method === "GET") {
        // Everything on disk, each with a fit assessment for THIS machine
        // (30 s cache — registry scan + config reads, no tensor bytes).
        if (!libraryCache || Date.now() - libraryCache.at > 30_000) {
          const { Registry } = await import("./registry");
          const { loadModelConfig } = await import("./config");
          const reg = new Registry();
          if (reg.list().length === 0) await reg.scan();
          const rows = [];
          for (const m of reg.list()) {
            const supported = isSupportedModelRecord(m.modelType, m.repoId);
            let assessment = null;
            try {
              const config = await loadModelConfig(m.path);
              const r = fit(config, m.sizeBytes, 8192, undefined, undefined, m.expertsBytes);
              assessment = {
                fits: r.fits,
                max_safe_context: r.maxSafeContext,
                predicted_decode_tps: r.predictedDecodeTps,
              };
            } catch {}
            rows.push({
              repo_id: m.repoId, model_type: m.modelType,
              size_bytes: m.sizeBytes, quant_bits: m.quantBits,
              vision: m.hasVisionSidecar, supported,
              serving: m.repoId === ctx.modelId,
              assessment,
            });
          }
          libraryCache = { at: Date.now(), rows };
        }
        return Response.json({ models: libraryCache.rows });
      }

      if (url.pathname === "/downloads" && request.method === "GET") {
        const { downloadsSnapshot } = await import("./download");
        return Response.json({ downloads: downloadsSnapshot() });
      }

      if (url.pathname === "/fit" && request.method === "GET") {
        // Fit assessment for the status page: this-machine report at the
        // admission ceiling + the Apple SKU matrix at a fixed 32k.
        // expertsBytes comes from the registry so MoE models predict on
        // active bytes — same numbers as `mlx-bun fit` and the serve
        // banner (the three surfaces used to disagree). When the eval DB
        // has a real measurement for this snapshot, it rides along:
        // measured beats predicted.
        const { skuMatrix, thisMachine, detectChip } = await import("./fit");
        const machine = thisMachine();
        const chip = detectChip();
        let expertsBytes = 0;
        let measured: { decodeTps: number; ts: number } | null = null;
        try {
          const { Registry } = await import("./registry");
          const rec = new Registry().list().find((r) => r.repoId === ctx.modelId);
          if (rec) {
            expertsBytes = rec.expertsBytes;
            const { EvalDB } = await import("./evaldb");
            measured = new EvalDB().latestFor(rec.path);
          }
        } catch {}
        const report = fit(
          ctx.model.config, ctx.model.weightsBytes, admission.maxSafeContext,
          machine, undefined, expertsBytes, serverOptions.memoryBudgetBytes,
        );
        return Response.json({
          machine: { chip: chip.name, ram_bytes: machine.ramBytes, bandwidth_gbs: machine.bandwidthGBs },
          context_tokens: admission.maxSafeContext,
          // Headline number: prediction at a TYPICAL context (8k) — the
          // max-context report below is the bandwidth worst case (every
          // decode step re-reads the full KV), not the everyday speed.
          typical_context_tokens: Math.min(8192, admission.maxSafeContext),
          typical_decode_tps: fit(
            ctx.model.config, ctx.model.weightsBytes,
            Math.min(8192, admission.maxSafeContext),
            machine, undefined, expertsBytes, serverOptions.memoryBudgetBytes,
          ).predictedDecodeTps,
          measured_decode_tps: measured?.decodeTps ?? null,
          measured_at: measured?.ts ?? null,
          report: {
            fits: report.fits,
            weights_bytes: report.weightsBytes,
            kv_bytes: report.kvBytes,
            transient_bytes: report.transientBytes,
            total_bytes: report.totalBytes,
            usable_bytes: report.usableBytes,
            max_safe_context: report.maxSafeContext,
            predicted_decode_tps: report.predictedDecodeTps,
          },
          sku_matrix_ctx: 32768,
          sku_matrix: skuMatrix(ctx.model.config, ctx.model.weightsBytes, 32768, expertsBytes).map((r) => ({
            sku: r.sku, ram_gb: r.ramGB, fits: r.fits,
            max_context: r.maxContext, decode_tps: r.decodeTps,
          })),
        });
      }

      if (url.pathname === "/v1" && request.method === "GET") {
        return Response.json({
          name: "mlx-bun", version: pkgVersion, model: ctx.modelId,
          endpoints: [
            "POST /v1/chat/completions", "POST /v1/messages", "POST /v1/responses",
            "GET /v1/models", "GET/POST/DELETE /v1/adapters",
            "GET /stats", "GET /fit", "GET /library", "GET /downloads",
          ],
        });
      }

      if (url.pathname === "/stats" && request.method === "GET") {
        // Active KV scheme across ALL layers. Since Phase 9 rotating
        // (sliding-window) caches quantize too, so every layer the
        // scheme names counts — the old display filtered to
        // full_attention and silently undercounted (e.g. 26B showed
        // 5/30 quantized when its kv_config.json covers all 30).
        const layerTypes = ctx.model.config.text.layerTypes;
        const kvLayers: Record<string, number> = {};
        let kvMode = "bf16";
        if (kvScheme.kvBits) {
          kvMode = `uniform-kv${kvScheme.kvBits}`;
          kvLayers[`kv${kvScheme.kvBits}`] = layerTypes.length;
        } else if (kvScheme.kvConfig) {
          kvMode = "mixed (kv_config.json)";
          for (const e of kvScheme.kvConfig)
            kvLayers[`kv${e.bits}`] = (kvLayers[`kv${e.bits}`] ?? 0) + 1;
        }
        const bf16Layers = layerTypes.length - Object.values(kvLayers).reduce((a, b) => a + b, 0);
        const slidingLayers = layerTypes.filter((l) => l === "sliding_attention").length;
        return Response.json({
          server: {
            owner: serverOptions.owner ?? "embedded",
            model: ctx.modelId,
            started_at: startedAt,
          },
          prompt_cache: {
            entries: promptCache.size,
            bytes: promptCache.totalBytes,
            max_bytes: promptCache.maxBytes,
            hits: promptCache.hits,
            misses: promptCache.misses,
          },
          response_store: {
            entries: responseStore.size,
            bytes: responseStore.totalBytes,
            max_bytes: responseStore.maxBytes,
            ttl_ms: responseStore.ttlMs,
          },
          kv_quant: {
            mode: kvMode,
            layers: { ...kvLayers, ...(bf16Layers > 0 ? { bf16: bf16Layers } : {}) },
            attention: {
              global: layerTypes.length - slidingLayers,
              sliding_window: slidingLayers,
            },
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
          data: [{
            id: ctx.modelId, object: "model", created: 0, owned_by: "mlx-bun",
            context_window: ctx.model.config.text.maxPositionEmbeddings,
          }],
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

      // The chat-completions core, shared by both protocol surfaces:
      // /v1/chat/completions calls it directly; /v1/messages (Anthropic)
      // translates its body into this shape and the Response back —
      // generation, tools, vision, stop sequences, prompt cache, and
      // admission control all live here exactly once.
      const handleChat = async (body: ChatRequest): Promise<Response> => {
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
            // ctx.vision is only ever non-null for Gemma4 (sidecar gate
            // in loadContext), so the narrow is safe here.
            const vp = await buildVisionPrompt(
              ctx.model as Gemma4Model, ctx.vision, ctx.tokenizer, ctx.template,
              messages, images, ctx.visionTokenIds, tools,
            );
            promptIds = vp.ids;
            vision = { embeddings: vp.embeddings, imageMask: vp.imageMask };
          } else {
            promptIds = promptIdsFor(body, tools);
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
                  const router = toolRouter(tools);
                  const stopper = new StopMatcher(options.stopSequences);
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
                    const text = stopper.push(router.push(token));
                    if (text) send(chunk({ content: text }, null));
                    if (stopper.stopped) return false; // halt generation
                    if (text) {
                      const now = performance.now();
                      if (now - lastFlush >= 25) {
                        lastFlush = now;
                        return new Promise<void>((r) => setImmediate(r));
                      }
                    }
                  }, vision);
                  // a stop match discards everything from the match on,
                  // including text still held by the decoders
                  let tail = "";
                  if (!stopper.stopped) {
                    tail = stopper.push(router.flush());
                    if (!stopper.stopped) tail += stopper.flush();
                  }
                  if (tail) send(chunk({ content: tail }, null));
                  const toolCalls = router.toolCalls();
                  if (toolCalls.length) {
                    send(chunk({
                      tool_calls: toolCalls.map((tc, i) => ({ index: i, ...tc })),
                    }, null));
                  }
                  const finish = toolCalls.length
                    ? "tool_calls"
                    : stopper.stopped ? "stop"
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
                  // bare sentinel per the OpenAI spec — JSON.stringify would
                  // quote it and strict SDK clients never see the terminator
                  controller.enqueue(enc.encode("data: [DONE]\n\n"));
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
            const router = toolRouter(tools);
            const stopper = new StopMatcher(options.stopSequences);
            let content = "";
            const s = await runGeneration(promptIds, options, (token) => {
              content += stopper.push(router.push(token));
              if (stopper.stopped) return false; // halt generation
            }, vision);
            if (!stopper.stopped) {
              content += stopper.push(router.flush());
              if (!stopper.stopped) content += stopper.flush();
            }
            const toolCalls = router.toolCalls();
            const finish = toolCalls.length
              ? "tool_calls"
              : stopper.stopped ? "stop"
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
      };

      if (url.pathname === "/v1/chat/completions" && request.method === "POST") {
        let body: ChatRequest;
        try {
          body = (await request.json()) as ChatRequest;
        } catch {
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        return handleChat(body);
      }

      // Anthropic Messages API (Phase 11) — on by default, mirroring
      // optiq serve (--anthropic defaults True; the drop-in claim
      // depends on it). Oracle: optiq/anthropic_shim.py, ported in
      // src/anthropic.ts. Point Claude Code at this port via
      // ANTHROPIC_BASE_URL for a fully local backend.
      if (url.pathname === "/v1/messages" && request.method === "POST") {
        const anthropicError = (status: number, type: string, message: string) =>
          Response.json({ type: "error", error: { type, message } }, { status });
        let anthropicBody: AnthropicRequest;
        try {
          anthropicBody = (await request.json()) as AnthropicRequest;
        } catch {
          return anthropicError(400, "invalid_request_error", "invalid JSON body");
        }
        let chatBody: ChatRequest;
        try {
          chatBody = anthropicToChatBody(anthropicBody) as unknown as ChatRequest;
        } catch (e) {
          return anthropicError(400, "invalid_request_error", (e as Error).message);
        }
        const resp = await handleChat(chatBody);
        if (!resp.ok) {
          const err = (await resp.json().catch(() => null)) as
            | { error?: { message?: string } }
            | null;
          return anthropicError(
            resp.status,
            resp.status >= 500 ? "api_error" : "invalid_request_error",
            err?.error?.message ?? "request failed",
          );
        }
        if (anthropicBody.stream) {
          return new Response(translateOpenAiSse(resp.body!, ctx.modelId), {
            headers: {
              "content-type": "text/event-stream",
              "cache-control": "no-cache",
              connection: "keep-alive",
            },
          });
        }
        return Response.json(chatJsonToAnthropic(await resp.json(), ctx.modelId));
      }

      // OpenAI Responses API (Phase 11) — Codex/Cursor/Continue speak
      // this now. Oracle: optiq/responses_shim.py + responses_server.py,
      // ported in src/responses.ts. previous_response_id resumes a prior
      // conversation from the in-process store (TTL + byte-capped LRU).
      if (url.pathname === "/v1/responses" && request.method === "POST") {
        const responsesError = (status: number, message: string) =>
          Response.json(
            {
              error: {
                message,
                type: status >= 500 ? "server_error" : "invalid_request_error",
                param: null, code: null,
              },
            },
            { status },
          );
        let responsesBody: ResponsesRequest;
        try {
          responsesBody = (await request.json()) as ResponsesRequest;
        } catch {
          return responsesError(400, "invalid JSON body");
        }

        // previous_response_id: prepend the prior conversation's input
        // + output (as input items); carry instructions forward only if
        // the new request omits them (oracle semantics).
        const prevId = responsesBody.previous_response_id ?? null;
        if (prevId) {
          const prior = responseStore.get(prevId);
          if (!prior)
            return responsesError(404, `previous_response_id '${prevId}' not found or expired`);
          const prepended = [...prior.input, ...outputItemsToInputItems(prior.output)];
          const newInput =
            typeof responsesBody.input === "string"
              ? responsesBody.input
                ? [{ type: "message", role: "user", content: responsesBody.input }]
                : []
              : responsesBody.input ?? [];
          responsesBody = {
            ...responsesBody,
            input: [...prepended, ...newInput] as Array<Record<string, unknown>>,
            instructions: responsesBody.instructions ?? prior.instructions ?? undefined,
          };
        }
        // Remember the effective input so a later follow-up that chains
        // off THIS response sees the full history.
        const capturedInput: unknown[] =
          typeof responsesBody.input === "string"
            ? [{ type: "message", role: "user", content: responsesBody.input }]
            : [...(responsesBody.input ?? [])];
        const capturedInstructions = responsesBody.instructions ?? null;

        let chatBody: ChatRequest;
        try {
          chatBody = responsesToChatBody(responsesBody) as unknown as ChatRequest;
        } catch (e) {
          return responsesError(400, (e as Error).message);
        }
        const resp = await handleChat(chatBody);
        if (!resp.ok) {
          const err = (await resp.json().catch(() => null)) as
            | { error?: { message?: string } }
            | null;
          return responsesError(resp.status, err?.error?.message ?? "request failed");
        }
        if (responsesBody.stream) {
          const body = translateOpenAiSseToResponses(
            resp.body!, ctx.modelId, prevId,
            (final) =>
              responseStore.put(final.id as string, {
                input: capturedInput,
                output: final.output as unknown[],
                instructions: capturedInstructions,
              }),
          );
          return new Response(body, {
            headers: {
              "content-type": "text/event-stream",
              "cache-control": "no-cache",
              connection: "keep-alive",
            },
          });
        }
        const responses = chatJsonToResponses(await resp.json(), ctx.modelId, prevId);
        responseStore.put(responses.id as string, {
          input: capturedInput,
          output: responses.output as unknown[],
          instructions: capturedInstructions,
        });
        return Response.json(responses);
      }

      return Response.json({ error: { message: "not found" } }, { status: 404 });
    },
  });
}
