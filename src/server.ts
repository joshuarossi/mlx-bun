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
// Embedded web app — the unified SPA (chat / quantize / finetune /
// dataset / status). `with { type: "text" }` inlines the file in both
// `bun run` and the compiled single binary. bun-types types *.html
// imports as HTMLBundle (the html loader), but the text attribute makes
// the runtime value a string — hence the double cast.
import appHtml from "./web/app.html" with { type: "text" };
import curveDesignerHtml from "../docs/curve-designer.html" with { type: "text" };
import pkgJson from "../package.json" with { type: "json" };
import { readFileSync } from "node:fs";
const APP_PAGE = appHtml as unknown as string;
const pkgVersion = (pkgJson as { version: string }).version;
import { loadModelConfig, type KvQuantSpec } from "./config";
import { Weights } from "./weights";
import { Gemma4Model } from "./model/gemma4";
import { createModel, type RuntimeModel } from "./model/factory";
import { isMiniCPM5Config, isQwen35Config, isSupportedModelRecord } from "./model/support";
import { generate, type GenerateOptions } from "./generate";
import type { HlgConfig } from "./sampler";
import { isMonotone, CURVE_UMIN, type CurveParams } from "./curve-sampler";
const CURVE_PAGE = curveDesignerHtml as unknown as string;
import { GenerationGateway } from "./serve/generation-gateway";
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
import { makePiWsHandler, type PiWsData } from "./pi-web";

export interface ServerOptions {
  /** Byte cap for the prompt (KV) cache. Default 2 GB. */
  promptCacheBytes?: number;
  /** KV quantization override. When unset: apply ctx.kvConfig (mixed
   *  per-layer) for serial serving, but bf16 under `--batch N` (the batched
   *  engine is bf16-only — a mode switch, see `batch` below). "config" forces
   *  the model's kv_config even under batching (those requests then route to
   *  the serial path); "off" forces bf16; a number forces uniform bits
   *  (group size 64, start 0) ignoring the config file. */
  kvQuant?: "off" | "config" | number;
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
  /** Max concurrent requests batched through the mlx-lm-parity engine
   *  (`--batch N`). Default 1 = today's serialized single-queue path. >1 opts
   *  the WHOLE server into the batched engine (continuous batching, B floats
   *  1..N, bit-parity with mlx-lm B=N) — a mode switch, not a load-dependent
   *  fallback. See docs/design/parallel-slots.md. NOTE: the batched executor
   *  is mid-build; until it lands, >1 warns and runs serially. */
  batch?: number;
  /** HLG tone-curve sampling default (set via --hlg-sampling on + sub-knobs).
   *  A per-request `hlg` object overrides it field-by-field. Off when unset. */
  hlg?: HlgConfig;
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
  const tokenizer = await loadTokenizer(modelDir);
  // Generation must stop on the tokenizer's eos_token — the chat turn
  // terminator (e.g. Qwen <|im_end|> = 248046). Some configs (Qwen3.5-4B)
  // declare a different eos_token_id in config.json than the chat format
  // emits, so without this a turn never ends and generation runs away,
  // hallucinating both sides of the dialogue until max_tokens. mlx-lm stops on
  // the tokenizer eos; union it in. No-op when already present (Gemma, 27B).
  if (tokenizer.eosTokenId != null && !config.eosTokenIds.includes(tokenizer.eosTokenId))
    config.eosTokenIds = [...config.eosTokenIds, tokenizer.eosTokenId];
  return {
    model,
    adapters: new AdapterManager(model),
    kvConfig: config.kvQuant,
    genDefaults: await loadGenSamplingDefaults(modelDir),
    tokenizer,
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
  /** OpenAI reasoning control. For models with a switchable <think> channel
   *  (Qwen3.5/MiniCPM5) it gates enable_thinking: "none" → off, any level → on.
   *  This is what Pi sends when the provider advertises reasoning. */
  reasoning_effort?: "none" | "minimal" | "low" | "medium" | "high";
  /** Mounted LoRA adapter selection: "id", "a+b" (stacked), or "none". */
  adapter?: string;
  /** HLG tone-curve sampling override (per request). Snake_case wire fields,
   *  merged over the server's --hlg-sampling config. docs/design/hlg-sampling.md. */
  hlg?: {
    enabled?: boolean;
    width?: number;
    shoulder?: number;
    toe?: number;
    pivot_offset?: number;
  };
}

/** Per-field default HLG knobs when enabling without specifying them. */
const HLG_DEFAULTS = { width: 4, shoulder: 4, toe: 6, pivotOffset: 6 } as const;

/** Resolve the effective HLG config: a per-request `hlg` object overrides the
 *  server's --hlg-sampling default field-by-field. Returns undefined (HLG off)
 *  unless enabled by the request or the server. */
function resolveHlg(
  reqHlg: ChatRequest["hlg"],
  serverHlg: HlgConfig | undefined,
): HlgConfig | undefined {
  const enabled = reqHlg?.enabled ?? serverHlg?.enabled ?? false;
  if (!enabled) return undefined;
  const base = serverHlg ?? HLG_DEFAULTS;
  return {
    enabled: true,
    width: reqHlg?.width ?? base.width,
    shoulder: reqHlg?.shoulder ?? base.shoulder,
    toe: reqHlg?.toe ?? base.toe,
    pivotOffset: reqHlg?.pivot_offset ?? base.pivotOffset,
    pivot: "top",
  };
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

/** Split Qwen-style inline <think>...</think> markup into OpenAI reasoning
 *  deltas/content. This keeps raw tags out of normal chat text while giving
 *  pi (TUI + web) proper thinking_delta events. It is streaming-safe: partial
 *  tag prefixes are held until disambiguated. */
class ThinkingTagSplitter {
  #pending = "";
  #inThinking = false;
  reasoning = "";
  content = "";

  constructor(private readonly enabled: boolean) {}

  #safePrefixUntilTag(tag: string): string {
    const i = this.#pending.indexOf(tag);
    if (i !== -1) return this.#pending.slice(0, i);
    let hold = 0;
    for (let k = Math.min(tag.length - 1, this.#pending.length); k > 0; k--) {
      if (this.#pending.endsWith(tag.slice(0, k))) { hold = k; break; }
    }
    return this.#pending.slice(0, this.#pending.length - hold);
  }

  push(text: string): { content: string; reasoning: string } {
    if (!this.enabled) {
      this.content += text;
      return { content: text, reasoning: "" };
    }
    this.#pending += text;
    let content = "";
    let reasoning = "";
    while (this.#pending) {
      const tag = this.#inThinking ? "</think>" : "<think>";
      const i = this.#pending.indexOf(tag);
      const emit = i === -1 ? this.#safePrefixUntilTag(tag) : this.#pending.slice(0, i);
      if (!emit && i === -1) break;
      if (emit) {
        if (this.#inThinking) reasoning += emit;
        else content += emit;
        this.#pending = this.#pending.slice(emit.length);
      }
      if (i !== -1 && this.#pending.startsWith(tag)) {
        this.#pending = this.#pending.slice(tag.length);
        this.#inThinking = !this.#inThinking;
        continue;
      }
      if (i === -1) break;
    }
    this.content += content;
    this.reasoning += reasoning;
    return { content, reasoning };
  }

  flush(): { content: string; reasoning: string } {
    if (!this.enabled) return { content: "", reasoning: "" };
    const out = this.#inThinking
      ? { content: "", reasoning: this.#pending }
      : { content: this.#pending, reasoning: "" };
    this.#pending = "";
    this.content += out.content;
    this.reasoning += out.reasoning;
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

// v2 curve designer: CORS-open so a file:// editor can call a localhost engine.
const CURVE_CORS: Record<string, string> = {
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-allow-headers": "content-type",
};
/** coherence flag: non-Latin-letter ratio / replacement char / reserved token. */
function curveJunk(s: string): boolean {
  const L = s.match(/\p{L}/gu) ?? [];
  const nonLatin = L.length ? L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length : 0;
  return nonLatin >= 0.02 || /�/.test(s) || /<unused\d+>/.test(s);
}

export function createServer(
  ctx: ServerContext, port = 0, serverOptions: ServerOptions = {},
): Server<unknown> {
  // --batch N (mode switch): N===1 is the serialized path below; N>1 routes
  // batchable requests through the continuous-batching scheduler (the
  // GenerationGateway picks the lane). Both full-attention (CPM) and
  // sliding-window (Gemma) models batch — the scheduler assembles each layer's
  // cache by attention type. Non-batchable requests (vision / adapters /
  // repetition penalty / user seed / explicit kv-quant) drain to the serial
  // lane (see GenerationGateway.willBatch).
  const batch = Math.max(1, Math.floor(serverOptions.batch ?? 1));

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

  // The lane picker: routes each request to the serial path (runGeneration,
  // above) or the continuous-batching scheduler, keeping the two off the GPU
  // (and shared loraState) at the same time. See src/serve/generation-gateway.ts.
  const gateway = new GenerationGateway(ctx.model, batch, runGeneration);

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

  // Captured so the WebSocket handler can resolve the bound (possibly
  // ephemeral) port lazily for the loopback pi provider.
  let serverRef!: Server<unknown>;

  // Lab job system (quantize / finetune / dataset), lazily opened so a
  // plain serve with no Lab activity pays nothing. markZombies() recovers
  // rows orphaned by a crashed prior process. The dataset runner is
  // in-process (pure JS + loopback /v1); quantize and finetune run as
  // GPU-leased subprocesses via src/jobs/job-entry.ts.
  let jobStore: import("./jobs").JobStore | null = null;
  const ensureJobs = async () => {
    if (!jobStore) {
      const jobs = await import("./jobs");
      const store = new jobs.JobStore();
      store.markZombies();
      try { (await import("./dataset")).registerDatasetRunner(); } catch {}
      jobStore = store;
    }
    return jobStore;
  };

  // KV-quant scheme, resolved once: kv_config.json by default (optiq
  // serve's headline behavior), overridable to uniform bits or off.
  // KV quant scheme. The serial default is the model's mixed-precision config
  // (optiq parity). But `--batch N` is a bf16 continuous-batching MODE (= mlx-lm
  // B=N parity), so when KV quant is left UNSET under `--batch N` it defaults to
  // bf16 — the batch path engages out of the box. An EXPLICIT --kv-quant
  // (config / bits) is still honored, but those requests then route to the
  // serial path (batched quantized KV is the L2 follow-up); warned below.
  const configScheme = ctx.kvConfig?.length ? { kvConfig: ctx.kvConfig } : {};
  const kvScheme: Pick<GenerateOptions, "kvBits" | "kvConfig" | "quantizedKvStart"> =
    serverOptions.kvQuant === "off" ? {}
    : serverOptions.kvQuant === "config" ? configScheme
    : typeof serverOptions.kvQuant === "number"
      ? { kvBits: serverOptions.kvQuant, quantizedKvStart: 0 }
    : batch > 1 ? {} // unset + batching → bf16 mode (Option B)
    : configScheme; // unset + serial → optiq-parity mixed-precision default
  if (batch > 1 && (kvScheme.kvConfig?.length || kvScheme.kvBits))
    console.warn(
      `[batch] --batch ${batch} with explicit --kv-quant: batched serving (v1) is ` +
        `bf16-only, so kv-quant requests route to the serial path (no batching for them). ` +
        `Omit --kv-quant to batch in bf16. (docs/design/parallel-slots.md)`,
    );

  const toOptions = (req: ChatRequest): GenerateOptions & { stopSequences: string[] } => ({
    maxTokens: req.max_completion_tokens ?? req.max_tokens ?? 1024,
    temperature: req.temperature ?? serverOptions.defaultTemperature ?? ctx.genDefaults.temperature ?? 0.7,
    topP: req.top_p ?? serverOptions.defaultTopP ?? ctx.genDefaults.topP ?? 0,
    topK: req.top_k ?? serverOptions.defaultTopK ?? ctx.genDefaults.topK ?? 0,
    seed: req.seed ?? (Date.now() & 0xffffffff),
    repetitionPenalty: req.repetition_penalty ?? ctx.genDefaults.repetitionPenalty,
    hlg: resolveHlg(req.hlg, serverOptions.hlg),
    // generate() yields token ids; stop sequences match on decoded text
    // (they can span token boundaries), so the StopMatcher sits at the
    // decode layer below and halts the loop via onToken → false.
    stopSequences: (typeof req.stop === "string" ? [req.stop] : req.stop ?? [])
      .filter((s) => typeof s === "string" && s.length > 0),
    ...kvScheme,
  });

  const templateOptionsFor = (req: ChatRequest, tools: ToolDefinition[] | null) => {
    // Precedence: explicit per-request chat_template_kwargs wins; else the
    // standard reasoning_effort (the OpenAI field Pi sends — "none" → no
    // thinking, any level → thinking on); else the server-wide --thinking
    // default; else the model's own default (false for MiniCPM5, otherwise
    // leave the template's default). The Anthropic/Responses shims map their
    // reasoning fields onto reasoning_effort before reaching here.
    const explicit = req.chat_template_kwargs?.enable_thinking;
    const effort = req.reasoning_effort;
    return {
      tools,
      enableThinking: typeof explicit === "boolean"
        ? explicit
        : effort !== undefined
          ? effort !== "none"
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
    // MiniCPM5 and Qwen3.5 emit tool calls as DECODED TEXT (Qwen:
    // <tool_call><function=name><parameter=…>; both handled by
    // parseGeneratedToolCalls), not Gemma's token sentinels — so they take the
    // buffered-text path. Gemma keeps the token-level sentinel path.
    if (isMiniCPM5Config(ctx.model.config) || isQwen35Config(ctx.model.config))
      return tools?.length ? "buffered-text" : "plain";
    return "gemma-sentinel";
  };

  const toolRouter = (tools: ToolDefinition[] | null): ToolAwareStream =>
    new ToolAwareStream(ctx.tokenizer, toolStreamMode(tools), tools);

  serverRef = Bun.serve({
    port,
    ...(serverOptions.hostname ? { hostname: serverOptions.hostname } : {}),
    idleTimeout: 0,
    // Web chat rides pi's AgentSession events over a WebSocket; the embedded
    // pi provider points back at THIS server's own loopback /v1 (port
    // resolved lazily — it may be ephemeral until serve() binds).
    websocket: makePiWsHandler({
      port: () => serverRef.port ?? port,
      contextWindow: ctx.model.config.text.maxPositionEmbeddings,
      vision: !!ctx.vision,
      thinking: ctx.template.supportsThinking,
    }),
    async fetch(request, server) {
      const url = new URL(request.url);

      if (url.pathname === "/ws/chat") {
        if (server.upgrade(request, { data: { sessionId: crypto.randomUUID() } as PiWsData }))
          return undefined;
        return new Response("expected websocket", { status: 426 });
      }

      // The unified SPA is served at "/"; legacy deep links redirect into
      // the hash router so old bookmarks still land on the right section.
      if (url.pathname === "/" && request.method === "GET") {
        return new Response(APP_PAGE, {
          headers: { "content-type": "text/html; charset=utf-8" },
        });
      }
      // v2 HLG Curve Designer — served same-origin so /generate + /signal need no CORS.
      // Read fresh from disk in dev (edits show on reload, no restart); fall back to the
      // embedded copy when running as the compiled single binary.
      if (url.pathname === "/curves" && request.method === "GET") {
        let html = CURVE_PAGE;
        try { html = readFileSync(new URL("../docs/curve-designer.html", import.meta.url), "utf8"); } catch { /* binary: use embedded */ }
        return new Response(html, { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" } });
      }
      if (url.pathname === "/curve-terrain" && request.method === "GET") {
        try {
          const html = readFileSync(new URL("../docs/investigations/curve-terrain.html", import.meta.url), "utf8");
          return new Response(html, { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" } });
        } catch {
          return new Response("curve terrain artifact not found; run scripts/curve-terrain.ts first", { status: 404 });
        }
      }
      if (request.method === "GET" &&
          ["/status", "/chat", "/quantize", "/finetune", "/dataset"].includes(url.pathname)) {
        return Response.redirect(`/#${url.pathname}`, 302);
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
          // --batch: configured cap, whether batching is live for this model,
          // and rows currently decoding in the batch.
          batch: {
            configured: batch,
            batched: gateway.batchingEnabled,
            active_rows: gateway.activeRows,
          },
        });
      }

      if (url.pathname === "/v1/models" && request.method === "GET") {
        return Response.json({
          object: "list",
          data: [{
            id: ctx.modelId, object: "model", created: 0, owned_by: "mlx-bun",
            context_window: ctx.model.config.text.maxPositionEmbeddings,
            // Capability flags for clients (CLI/external pi) that build a
            // provider from discovery — `reasoning` gates the thinking toggle.
            reasoning: ctx.template.supportsThinking,
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

      // ---- Curve Designer: POST /signal {prompt} → next-token histogram over the curve's x-axis ----
      // One prefill forward; bins the real log-prob distribution so the editor can draw the
      // signal under the curve (you shape where the tokens actually are).
      if (url.pathname === "/signal" && request.method === "OPTIONS")
        return new Response(null, { headers: CURVE_CORS });
      if (url.pathname === "/signal" && request.method === "POST") {
        let sbody: { prompt?: string };
        try { sbody = (await request.json()) as typeof sbody; }
        catch { return Response.json({ error: "invalid JSON" }, { status: 400, headers: CURVE_CORS }); }
        let sids = ctx.tokenizer.encode(ctx.template.render([{ role: "user", content: typeof sbody.prompt === "string" ? sbody.prompt : "" }], templateOptionsFor({} as ChatRequest, null)));
        if (sids[0] === sids[1] && sids[0] === ctx.tokenizer.bosTokenId) sids = sids.slice(1);
        try {
          const NB = 80;
          const result = await enqueue(async () => {
            const cache = ctx.model.makeCache();
            try {
              const logits = ctx.model.forward(sids, cache); // [1, L, V]
              const [, Ln, V] = logits.shape as [number, number, number];
              const last = logits.slice([0, Ln - 1, 0], [1, Ln, V]);
              const f = last.toFloat32(); logits.dispose(); last.dispose();
              let mx = -Infinity; for (const v of f) if (v > mx) mx = v;
              let Z = 0; for (const v of f) Z += Math.exp(v - mx); const lse = mx + Math.log(Z);
              const bins = new Array<number>(NB).fill(0);
              for (const v of f) { const t = Math.max(0, Math.min(1, (v - lse - CURVE_UMIN) / (-CURVE_UMIN))); const bi = Math.min(NB - 1, Math.floor(t * NB)); bins[bi] = (bins[bi] ?? 0) + 1; }
              return { bins, vocab: V };
            } finally { for (const c of cache) c.dispose(); }
          });
          return Response.json(result, { headers: CURVE_CORS });
        } catch (e) {
          return Response.json({ error: `signal failed: ${(e as Error).message}` }, { status: 500, headers: CURVE_CORS });
        }
      }

      // ---- v2 HLG Curve Designer: POST /generate {prompt, curve, n, max_tokens, seed} ----
      // The drawn log-prob transfer curve REPLACES temperature+softmax entirely
      // (src/curve-sampler.ts). The browser editor calls this; same curve object the
      // tool's "Copy values" emits is the one the sampler consumes — one contract.
      if (url.pathname === "/generate" && request.method === "OPTIONS")
        return new Response(null, { headers: CURVE_CORS });
      if (url.pathname === "/generate" && request.method === "POST") {
        let body: { prompt?: string; curve?: CurveParams; n?: number; max_tokens?: number; seed?: number; default?: boolean };
        try { body = (await request.json()) as typeof body; }
        catch { return Response.json({ error: "invalid JSON" }, { status: 400, headers: CURVE_CORS }); }
        const curve = body.curve;
        // Identity / no shaped curve → fall back to the model's DEFAULT chat recipe
        // (temp + top-p + top-k) — the honest "what you'd get chatting" baseline, which
        // a smooth curve can't replicate (top-p/top-k are hard truncations).
        const useCurve = body.default !== true && Array.isArray(curve?.points) && curve.points.length >= 2;
        if (useCurve && !isMonotone(curve!))
          return Response.json({ error: "curve is not monotone — all segment slopes must be ≥ 0" }, { status: 400, headers: CURVE_CORS });
        const recipe = {
          temperature: serverOptions.defaultTemperature ?? ctx.genDefaults.temperature ?? 0.7,
          topP: serverOptions.defaultTopP ?? ctx.genDefaults.topP ?? 0,
          topK: serverOptions.defaultTopK ?? ctx.genDefaults.topK ?? 0,
        };
        const prompt = typeof body.prompt === "string" ? body.prompt : "";
        const n = Math.max(1, Math.min(8, Math.floor(Number(body.n) || 3)));
        const maxTokens = Math.max(1, Math.min(256, Math.floor(Number(body.max_tokens) || 80)));
        const baseSeed = Number.isFinite(body.seed) ? Number(body.seed) >>> 0 : (Date.now() & 0xffffffff);
        let ids = ctx.tokenizer.encode(ctx.template.render([{ role: "user", content: prompt }], templateOptionsFor({} as ChatRequest, null)));
        if (ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId) ids = ids.slice(1);
        const samples: { text: string; junk: boolean }[] = [];
        try {
          for (let i = 0; i < n; i++) {
            const toks: number[] = [];
            const genOpts: GenerateOptions = useCurve
              ? { curve, seed: baseSeed + i, maxTokens, ...kvScheme }
              : { temperature: recipe.temperature, topP: recipe.topP, topK: recipe.topK, seed: baseSeed + i, maxTokens, ...kvScheme };
            await enqueue(() => runGeneration(ids, genOpts, (t) => { toks.push(t); }));
            const text = ctx.tokenizer.decode(toks, true).trim();
            samples.push({ text, junk: curveJunk(text) });
          }
        } catch (e) {
          return Response.json({ error: `generation failed: ${(e as Error).message}` }, { status: 500, headers: CURVE_CORS });
        }
        return Response.json({ mode: useCurve ? "curve" : "default", recipe: useCurve ? undefined : recipe, n, seed: baseSeed, samples }, { headers: CURVE_CORS });
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

        // What lane this request takes (vision / adapters / repetition penalty /
        // a user-fixed seed → serial; everything else batches when --batch N).
        const shape = {
          hasVision: !!vision,
          hasAdapters: !!options.adapters?.length,
          hasRepetitionPenalty: !!options.repetitionPenalty,
          userSeed: body.seed !== undefined,
          kvQuant: !!(options.kvConfig?.length || options.kvBits),
        };
        const batched = gateway.willBatch(shape);

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
                // The gateway owns lane selection + GPU exclusivity; this body
                // runs per-request (concurrently in batched mode, each writing
                // its own SSE stream — the per-row fan-out).
                send(chunk({ role: "assistant", content: "" }, null));
                const router = toolRouter(tools);
                const stopper = new StopMatcher(options.stopSequences);
                const thinking = new ThinkingTagSplitter(ctx.template.supportsThinking);
                // Serial decode is an unbroken microtask chain (FFI + generator
                // resumes) — without a macrotask hop, Bun never services the
                // socket and the whole SSE response flushes in one burst at the
                // end (Phase 15: "687k tok/s decode"). Hopping EVERY token cost
                // ~23% decode; rate-limited to ≥25 ms keeps the flush smooth and
                // hides behind the next GPU step. Batched mode doesn't need it —
                // the scheduler yields to the event loop between steps.
                let lastFlush = performance.now();
                const s = await gateway.run(promptIds, options, (token) => {
                  const text = stopper.push(router.push(token));
                  const parts = thinking.push(text);
                  if (parts.reasoning) send(chunk({ reasoning: parts.reasoning }, null));
                  if (parts.content) send(chunk({ content: parts.content }, null));
                  if (stopper.stopped) return false; // halt generation
                  if (!batched && (parts.content || parts.reasoning)) {
                    const now = performance.now();
                    if (now - lastFlush >= 25) {
                      lastFlush = now;
                      return new Promise<void>((r) => setImmediate(r));
                    }
                  }
                }, vision, shape);
                // a stop match discards everything from the match on,
                // including text still held by the decoders
                let tail = "";
                if (!stopper.stopped) {
                  tail = stopper.push(router.flush());
                  if (!stopper.stopped) tail += stopper.flush();
                }
                if (tail) {
                  const parts = thinking.push(tail);
                  if (parts.reasoning) send(chunk({ reasoning: parts.reasoning }, null));
                  if (parts.content) send(chunk({ content: parts.content }, null));
                }
                {
                  const parts = thinking.flush();
                  if (parts.reasoning) send(chunk({ reasoning: parts.reasoning }, null));
                  if (parts.content) send(chunk({ content: parts.content }, null));
                }
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
          {
            const router = toolRouter(tools);
            const stopper = new StopMatcher(options.stopSequences);
            const thinking = new ThinkingTagSplitter(ctx.template.supportsThinking);
            let content = "";
            let reasoning = "";
            const s = await gateway.run(promptIds, options, (token) => {
              const parts = thinking.push(stopper.push(router.push(token)));
              content += parts.content;
              reasoning += parts.reasoning;
              if (stopper.stopped) return false; // halt generation
            }, vision, shape);
            if (!stopper.stopped) {
              let tail = stopper.push(router.flush());
              if (!stopper.stopped) tail += stopper.flush();
              const parts = thinking.push(tail);
              content += parts.content;
              reasoning += parts.reasoning;
            }
            {
              const parts = thinking.flush();
              content += parts.content;
              reasoning += parts.reasoning;
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
                  ...(reasoning ? { reasoning } : {}),
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
          }
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

      // --- Lab API: dataset builder + quantize + finetune + jobs -------
      if (url.pathname === "/api/dataset/templates" && request.method === "GET") {
        const { TEMPLATES } = await import("./dataset");
        return Response.json({ templates: TEMPLATES });
      }
      if (url.pathname === "/api/dataset/submit" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as {
          template_id?: string; inputs?: Record<string, unknown>; model_name?: string;
        };
        const { getTemplate } = await import("./dataset");
        if (!body.template_id || !getTemplate(body.template_id))
          return Response.json({ ok: false, error: `unknown template ${body.template_id}` }, { status: 400 });
        const store = await ensureJobs();
        const { submitInProcess } = await import("./jobs");
        const { homedir } = await import("node:os");
        const safe = body.template_id.replace(/[^a-z0-9_-]/gi, "");
        const outDir = `${homedir()}/.cache/mlx-bun/datasets/dataset-${safe}-${Date.now()}`;
        const { jobId } = submitInProcess(store, "dataset", {
          template_id: body.template_id, inputs: body.inputs ?? {},
          output_dir: outDir, api_url: `http://127.0.0.1:${server.port}`,
          model_name: body.model_name ?? "local",
        }, outDir);
        return Response.json({ ok: true, job_id: jobId, output_dir: outDir });
      }

      if (url.pathname === "/api/quantize/inspect" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as { model_id?: string };
        const { inspectModel } = await import("./quantize");
        return Response.json(await inspectModel(body.model_id ?? ""));
      }
      if (url.pathname === "/api/quantize/submit" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as {
          model_id?: string; bits?: number; group_size?: number;
          target_bpw?: number; candidate_bits?: number[]; reference?: string;
          calibration_mix?: string; n_calibration?: number;
        };
        if (!body.model_id)
          return Response.json({ ok: false, error: "model_id required" }, { status: 400 });
        const store = await ensureJobs();
        const { submitSubprocess } = await import("./jobs");
        const { homedir } = await import("node:os");
        const bits = body.bits ?? 4, gs = body.group_size ?? 64;
        const base = body.model_id.split("/").filter(Boolean).at(-1)!.replace(/[^a-z0-9_.-]/gi, "");
        // Mixed-precision (sensitivity+knapsack) names the dir by target bpw.
        const suffix = body.target_bpw ? `mixed-${body.target_bpw}bpw` : `${bits}bit`;
        const outDir = `${homedir()}/.cache/mlx-bun/quants/${base}-OptiQ-${suffix}`;
        const { jobId } = submitSubprocess(store, "quantize", {
          model_id: body.model_id, out_dir: outDir, bits, group_size: gs,
          // forwarded to the mixed-precision path when target_bpw is set
          target_bpw: body.target_bpw, candidate_bits: body.candidate_bits,
          reference: body.reference, calibration_mix: body.calibration_mix,
          n_calibration: body.n_calibration,
        }, outDir);
        return Response.json({ ok: true, job_id: jobId, output_dir: outDir });
      }

      if (url.pathname === "/api/finetune/inspect-dataset" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as { path?: string };
        const { inspectDataset } = await import("./train");
        return Response.json(await inspectDataset(body.path ?? ""));
      }
      if (url.pathname === "/api/finetune/submit" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as Record<string, unknown>;
        if (!body.model_dir || !body.data_dir)
          return Response.json({ ok: false, error: "model_dir and data_dir required" }, { status: 400 });
        const store = await ensureJobs();
        const { submitSubprocess } = await import("./jobs");
        const { homedir } = await import("node:os");
        const adapterPath = (body.adapter_path as string) ||
          `${homedir()}/.cache/mlx-bun/adapters/adapter-${Date.now()}`;
        const { jobId } = submitSubprocess(store, "finetune",
          { ...body, adapter_path: adapterPath }, adapterPath);
        return Response.json({ ok: true, job_id: jobId, adapter_path: adapterPath });
      }
      if (url.pathname === "/api/finetune/merge" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as {
          adapter_a?: string; adapter_b?: string; scales?: number[];
        };
        if (!body.adapter_a || !body.adapter_b)
          return Response.json({ ok: false, error: "adapter_a and adapter_b required" }, { status: 400 });
        try {
          const { mergeAdapters } = await import("./train");
          const { homedir } = await import("node:os");
          const mergedPath = `${homedir()}/.cache/mlx-bun/adapters/merged-${Date.now()}`;
          const stats = await mergeAdapters([body.adapter_a, body.adapter_b], mergedPath, body.scales);
          return Response.json({ ok: true, merged_path: mergedPath, stats });
        } catch (e) {
          return Response.json({ ok: false, error: (e as Error).message }, { status: 400 });
        }
      }
      if (url.pathname === "/api/finetune/export" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as {
          base_model?: string; adapter_path?: string; method?: string;
        };
        if (!body.base_model || !body.adapter_path)
          return Response.json({ ok: false, error: "base_model and adapter_path required" }, { status: 400 });
        try {
          const { exportAdapter } = await import("./train");
          const { homedir } = await import("node:os");
          const exportPath = `${homedir()}/.cache/mlx-bun/exports/export-${Date.now()}`;
          const manifest = await exportAdapter(exportPath, body.base_model, body.adapter_path, body.method);
          return Response.json({ ok: true, export_path: exportPath, manifest });
        } catch (e) {
          return Response.json({ ok: false, error: (e as Error).message }, { status: 400 });
        }
      }

      // --- HF token settings + push-to-hub (model & dataset repos) ------
      if (url.pathname === "/api/settings/hf-token" && request.method === "GET") {
        const { hasHfToken } = await import("./hf-push");
        return Response.json({ ok: true, hasToken: hasHfToken() });
      }
      if (url.pathname === "/api/settings/hf-token" && request.method === "POST") {
        const body = (await request.json().catch(() => ({}))) as { token?: string };
        if (!body.token) return Response.json({ ok: false, error: "token required" }, { status: 400 });
        const { saveHfToken } = await import("./hf-push");
        saveHfToken(body.token);
        return Response.json({ ok: true });
      }
      {
        const m = url.pathname.match(/^\/api\/(quantize|finetune|dataset)\/push$/);
        if (m && request.method === "POST") {
          const kind = m[1]!;
          const body = (await request.json().catch(() => ({}))) as {
            job_id?: string; repo_id?: string; private?: boolean; source_path?: string;
          };
          if (!body.repo_id) return Response.json({ ok: false, error: "repo_id required" }, { status: 400 });
          const { getHfToken, uploadFolder } = await import("./hf-push");
          const token = getHfToken();
          if (!token)
            return Response.json({ ok: false, error: "no HF token saved — add one in Settings → Hugging Face" }, { status: 400 });
          const store = await ensureJobs();
          let dir = body.source_path;
          if (!dir && body.job_id) dir = store.get(body.job_id)?.output_path ?? undefined;
          if (!dir) return Response.json({ ok: false, error: "no source dir (pass job_id or source_path)" }, { status: 400 });
          try {
            const r = await uploadFolder(dir, body.repo_id, {
              repoType: kind === "dataset" ? "dataset" : "model",
              private: !!body.private, token,
            });
            return Response.json({ ok: true, url: r.url });
          } catch (e) {
            return Response.json({ ok: false, error: (e as Error).message }, { status: 400 });
          }
        }
      }

      if (url.pathname === "/api/jobs" && request.method === "GET") {
        const store = await ensureJobs();
        const limit = Number(url.searchParams.get("limit") ?? "50");
        const kind = url.searchParams.get("kind") ?? undefined;
        return Response.json({ ok: true, jobs: store.recent(limit, kind) });
      }
      {
        const m = url.pathname.match(/^\/api\/jobs\/([^/]+?)(\/stream)?$/);
        if (m && request.method === "GET") {
          const store = await ensureJobs();
          if (m[2]) {
            const { streamJobResponse } = await import("./jobs");
            return streamJobResponse(store, m[1]!);
          }
          const job = store.get(m[1]!);
          if (!job) return Response.json({ ok: false, error: "job not found" }, { status: 404 });
          return Response.json({ ok: true, job });
        }
      }

      return Response.json({ error: { message: "not found" } }, { status: 404 });
    },
  });
  return serverRef;
}
