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
import curveDesignerHtml from "./lab/curve/curve-designer.html" with { type: "text" };
// Vendored, no-CDN static assets referenced by app.html (convention: any
// self-contained JS/CSS too big to inline gets `with { type: "text" }`
// imported here and served under /assets/<name>; see src/web/vendor/README
// for how hljs.js was built). Add new vendored assets the same way.
import hljsJs from "./web/vendor/hljs.js" with { type: "text" };
import hljsCss from "./web/vendor/hljs-theme.css" with { type: "text" };
// The frontend bundle (plan §7/§9 Phase 2 module split): GENERATED from
// src/web/src/*.ts by `bun scripts/build-web.ts` — see that file's header
// and tests/using/web-build.test.ts (the freshness gate). Same
// with { type: "text" } + /assets/<name> pattern as the vendored assets
// above; app.html's <script defer src="/assets/app.js"> loads it.
import appJs from "./web/app.js" with { type: "text" };
// PWA installability (plan §9 Phase 3, beat-matrix Axis 10): a manifest +
// a single inline SVG icon (no binary PNGs — the hygiene gate forbids
// tracked binary files; some browsers won't show an SVG app icon, which is
// an accepted tradeoff, see docs/reference/server-config.md) + a shell-
// only service worker. Same with { type: "text" } + /assets/<name>-shaped
// pattern as the vendored assets above; see src/web/sw.js's header for why
// it deliberately does NOT cache API/WS traffic.
import manifestWebmanifest from "./web/manifest.webmanifest" with { type: "text" };
import iconSvg from "./web/icon.svg" with { type: "text" };
import swJs from "./web/sw.js" with { type: "text" };
import { readFileSync } from "node:fs";
const APP_PAGE = appHtml as unknown as string;
const HLJS_JS = hljsJs as unknown as string;
const HLJS_CSS = hljsCss as unknown as string;
const APP_JS = appJs as unknown as string;
const MANIFEST_WEBMANIFEST = manifestWebmanifest as unknown as string;
const ICON_SVG = iconSvg as unknown as string;
const SW_JS = swJs as unknown as string;
import { type TurboQuantScheme } from "./config";
import { Gemma4Model } from "./model/gemma4";
import { DiffusionGemmaModel } from "./model/diffusion-gemma";
import { spliceImageTokens } from "./vision/diffusion-vision";
import { Glm52Model } from "./model/glm52";
import {
  GLM52_G5_ASPIRATIONAL_DECODE_TPS,
  GLM52_G5_DIRECT_ORACLE_WARM_DECODE_TPS,
  GLM52_G5_MEASURED_AT,
  GLM52_G5_MEASURED_WARM_DECODE_TPS,
} from "./model/glm52-memory";
import { isMiniCPM5Config } from "./model/support";
import {
  generate,
  type GenerateOptions,
  type TokenLogprobs,
  withModelUsageFlush,
  withModelWiredLimit,
} from "./generate";
import { cloneKvCaches, SpillQueue } from "./kv-store";
import { resolveKvScheme } from "./kv-scheme";
import { runtimeValue } from "./runtime-config";
import { TURBOQUANT_HEAD_DIMS } from "./mlx/turboquant-tables";
import {
  compileGrammarRequest, grammarEnabled, type GrammarRequest,
} from "./grammar";
import type { HlgConfig } from "./sampler";
import { isMonotone, CURVE_UMIN, type CurveParams } from "./lab/curve/curve-sampler";
const CURVE_PAGE = curveDesignerHtml as unknown as string;
import { GenerationGateway } from "./serve/generation-gateway";
import {
  CompletionExecutor,
  CompletionRejected,
  prepareCompletion,
  type CompletionSummary,
  type PreparedCompletion,
} from "./serve/completion-executor";
import {
  createPromptResponseTrace,
  type PromptResponseTrace,
} from "./serve/prompt-response-trace";
import { handleAdminRoute } from "./serve/admin-routes";
import { handleAuxiliaryRoute } from "./serve/aux-routes";
import {
  createTimedFlowControl,
  type CompletionEvent,
  type CompletionStreamProtocol,
} from "./serve/completion-sink";
import { createDiscoveryRoutes } from "./serve/discovery-routes";
import { handleLabRoute } from "./serve/lab-routes";
import { handleModelAdminRoute } from "./serve/model-admin-routes";
import { RequestOwnership } from "./serve/request-plan";
import { handleStaticRoute } from "./serve/static-routes";
const STATIC_ROUTE_ASSETS = {
  appPage: APP_PAGE,
  appJs: APP_JS,
  hljsJs: HLJS_JS,
  hljsCss: HLJS_CSS,
  manifest: MANIFEST_WEBMANIFEST,
  iconSvg: ICON_SVG,
  serviceWorker: SW_JS,
  curvePage: CURVE_PAGE,
};
import {
  type ToolDefinition,
} from "./chat-template";
import { PromptCache, cacheBytes } from "./prompt-cache";
import { SsdCacheStore } from "./ssd-cache";
import {
  SsdDurabilityCoordinator,
  type DurabilityFlushResult,
  type DurabilitySnapshotStats,
} from "./ssd-durability";
import { configFingerprint } from "./model/fingerprint";
import {
  anthropicToChatBody, chatJsonToAnthropic, createAnthropicStreamProtocol,
  type AnthropicRequest,
} from "./anthropic";
import {
  ResponseStore, chatJsonToResponses, outputItemsToInputItems,
  responsesToChatBody, createResponsesStreamProtocol,
  type ResponsesRequest,
} from "./responses";
import { fit } from "./fit";
import { setMemoryLimit } from "./mlx/ffi";
import { Qwen3VLVisionTower } from "./vision/qwen3vl-tower";
import { buildQwen3VLVisionPrompt } from "./vision/qwen3vl-prompt";
import { Qwen35Model } from "./model/qwen3_5";
import type { MropeRequestState } from "./model/qwen3-mrope";
import {
  buildMultimodalPrompt,
  buildVisionPrompt,
  extractAudio,
  extractImages,
  extractVideos,
  type VisionTokenIds,
  type VisionEncoder,
} from "./vision/prompt";
import { ensureWav } from "./audio/transcode";
import { makePiWsHandler, type PiWsData } from "./pi-web";
import {
  detectDraftKind,
  getAudioTower,
  getVisionTower,
  loadContext,
  type DraftKind,
  type GenSamplingDefaults,
  type LoadContextOptions,
  type ServerContext,
} from "./serve/model-host";
import {
  applyGrammarDegrade,
  nextDefaultSeed,
  normalizeMessages,
  parseLogitBias,
  promptEndsInOpenThink,
  resolveHlg,
  validateLogprobsParams,
  validateReasoningEffort,
  type ChatRequest,
  type TextCompletionRequest,
} from "./serve/chat-request";
import {
  selectToolStreamMode,
  StopMatcher,
  ThinkingTagSplitter,
  ToolAwareStream,
  type ToolStreamMode,
} from "./serve/token-streams";

// The serving facade: createServer's companion loaders stay importable from
// here (public library API via src/index.ts; bench scripts; parity tests).
export {
  detectDraftKind,
  loadContext,
  type DraftKind,
  type GenSamplingDefaults,
  type LoadContextOptions,
  type ServerContext,
};

export interface ServerOptions {
  /** Byte cap for the prompt (KV) cache. Default 8 GB. */
  promptCacheBytes?: number;
  /** Aggregate KV-byte budget across concurrently-admitted batch rows
   *  (`--kv-budget`, batching-perf-path P3). Joiners whose projected KV
   *  (prompt + max_tokens, window-capped) would exceed it QUEUE until rows
   *  evict; a request over the budget alone is rejected. Unset = no
   *  aggregate cap (per-request admission via memoryBudget still applies). */
  kvBudgetBytes?: number;
  /** KV quantization override. Unset/"off" is bf16. "config" applies the
   *  model's declared mixed-precision kv_config; supported per-layer schemes
   *  compose with continuous scheduling. A number forces uniform bits
   *  (group size 64, start 0) and uses the preserved serial executor. */
  kvQuant?: "off" | "config" | number;
  /** TurboQuant scheme (docs/design/turboquant.md): a separate axis from
   *  kvQuant above, mutually exclusive with it (`--kv-quant turbo[:k<bits>v
   *  <bits>]` sets this instead of kvQuant). Solo-only in v1 — see
   *  GenerationGateway's explicit refusal. */
  turboQuant?: TurboQuantScheme;
  /** OPTIONAL paged KV cache (`--paged-kv`, docs/design/kv-cache.md):
   *  vLLM-style block-pool storage for full-attention layers,
   *  gather-to-contiguous before the stock SDPA. Default off (unset = the
   *  plain KVCache path, byte-identical). v1 scope: serial batch=1,
   *  Gemma4-family, bf16 — startup refuses `--batch N>1`, `--kv-quant`,
   *  turbo, and `--draft-model` combinations; paged requests bypass the
   *  prompt cache and run uncompiled. Gated bit-exact vs the plain path. */
  pagedKv?: { blockSize?: number };
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
  /** Listen on a UNIX DOMAIN SOCKET instead of a TCP port — the engine-
   *  child mode of the isolation architecture (docs/reference/server-config.md): the
   *  parent process reverse-proxies HTTP to this socket. Stale socket
   *  files are unlinked before bind. When set, `hostname`/port are ignored. */
  unixSocket?: string;
  /** Interface to bind (Bun.serve hostname). Unset ⇒ Bun's default
   *  (all interfaces) — embedded/library use. The CLI always passes one:
   *  "127.0.0.1" (loopback, mlx_lm.server parity) unless --host says
   *  otherwise. */
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
  /** Completion cap when the request omits max_tokens (`--max-tokens`).
   *  mlx_lm.server's flag; its default there is 512 — ours stays 65,536 so
   *  thinking traces never truncate. `--max-tokens 512` = mlx-lm behavior. */
  defaultMaxTokens?: number;
  /** Continuous-scheduler concurrency cap (`--batch N`). Default 8; the
   *  scheduler specializes active B=1 and B=N with mlx-lm parity at the same
   *  composition. `--batch 1` pins the preserved strict serial executor. */
  batch?: number;
  /** HLG tone-curve sampling default (set via --hlg-sampling on + sub-knobs).
   *  A per-request `hlg` object overrides it field-by-field. Off when unset. */
  hlg?: HlgConfig;
  /** Adapter id mounted at startup via `serve --adapter <dir>` (mlx-lm's
   *  `--adapter-path`). Used when a request sends no `adapter` field; a
   *  request's explicit `adapter` (including "none") always wins. Hot-swap
   *  via /v1/adapters is unchanged. */
  defaultAdapter?: string;
  /** SSD cold tier for the prompt/KV cache (`--ssd-cache <dir>`): prefix
   *  KV survives RAM eviction AND server restarts — the coding-agent
   *  long-context TTFT win (docs/design/kv-cache.md). Off unless
   *  a directory is given. Serial lane only (where the prompt cache lives). */
  ssdCacheDir?: string;
  /** Byte cap for the SSD tier (default 32 GiB). */
  ssdCacheMaxBytes?: number;
  /** Idle-demotion threshold in seconds (`--ssd-demote-idle`): prompt-cache
   *  entries unused this long spill to the SSD tier and free their GPU
   *  memory (Layer 0 — RAM drains between bursts, prefixes stay reachable
   *  via zero-copy restore). Default 300 when the tier is on; 0 disables. */
  ssdDemoteIdleSec?: number;
  /** Verify every tensor hash on restore (`--ssd-cache-verify`) — reads all
   *  bytes eagerly, defeating lazy fault-in; integrity paranoia only. */
  ssdCacheVerify?: boolean;
}

interface ServerLifecycle {
  flush: () => Promise<DurabilityFlushResult>;
  stats: () => DurabilitySnapshotStats;
  stopTimers: () => void;
}

export interface ServerShutdownResult {
  stopped: boolean;
  timedOut: boolean;
  durability: DurabilityFlushResult;
}

const serverLifecycles = new WeakMap<Server<unknown>, ServerLifecycle>();

function emptyDurabilityResult(): DurabilityFlushResult {
  return {
    durable: true,
    flushedSnapshots: 0,
    missingSnapshots: 0,
    pendingSnapshots: 0,
    pendingSpills: 0,
    pendingSpillBytes: 0,
    droppedSpills: 0,
    failedSpills: 0,
    elapsedMs: 0,
  };
}

/** Flush prompt-cache snapshots without stopping the HTTP server. */
export function flushServerCacheDurability(
  server: Server<unknown>,
): Promise<DurabilityFlushResult> {
  return serverLifecycles.get(server)?.flush() ?? Promise.resolve(emptyDurabilityResult());
}

/** Stop admission, flush cache durability, then finish the Bun server. */
export async function shutdownServer(
  server: Server<unknown>, timeoutMs = 120_000,
): Promise<ServerShutdownResult> {
  const lifecycle = serverLifecycles.get(server);
  lifecycle?.stopTimers();
  const stopped = Promise.resolve(server.stop(false));
  const work = (async (): Promise<ServerShutdownResult> => {
    await stopped;
    const durability = lifecycle ? await lifecycle.flush() : emptyDurabilityResult();
    return { stopped: true, timedOut: false, durability };
  })();
  let timeoutHandle: ReturnType<typeof setTimeout> | null = null;
  const timeout = new Promise<ServerShutdownResult>((resolve) => {
    timeoutHandle = setTimeout(() => {
      const stats = lifecycle?.stats();
      resolve({
        stopped: false,
        timedOut: true,
        durability: {
          ...emptyDurabilityResult(),
          durable: false,
          ...(stats ?? {}),
          elapsedMs: timeoutMs,
        },
      });
    }, timeoutMs);
    timeoutHandle.unref?.();
  });
  try {
    return await Promise.race([work, timeout]);
  } finally {
    if (timeoutHandle) clearTimeout(timeoutHandle);
  }
}


export interface ContextAdmissionDecision {
  /** Effective completion ceiling after admission. */
  maxTokens: number;
  /** True when admission reduced the client's upper bound to fit. */
  clamped: boolean;
}

/** Resolve a request's completion upper bound against the admitted context.
 *
 * `max_tokens` is a ceiling, not a promise that every token will be emitted:
 * when a prompt fits but a broad client-wide `max_tokens` would push the
 * reservation past the safe context, the bound is CLAMPED to the remaining
 * room instead of rejecting an otherwise valid request (the pre-v0.0.13
 * behavior 400'd a prompt with thousands of tokens of generation room over a
 * 17-token overshoot). This never weakens the OOM guard — generation stops at
 * the clamped ceiling, inside the admitted context. Only a prompt that leaves
 * no generation slot at all is rejected. */
export function admitRequestContext(
  promptTokens: number,
  requestedMaxTokens: number,
  maxSafeContext: number,
): ContextAdmissionDecision | null {
  const available = maxSafeContext - promptTokens;
  if (available < 1) return null;
  if (requestedMaxTokens <= available)
    return { maxTokens: requestedMaxTokens, clamped: false };
  return { maxTokens: available, clamped: true };
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
  // --batch N is a concurrency cap: N===1 pins the strict serial executor;
  // N>1 admits supported execution compositions to the continuous scheduler.
  // The scheduler chooses its B=1 fast path or B=N step from active rows.
  // Both full-attention (CPM) and
  // sliding-window (Gemma) models batch — the scheduler assembles each layer's
  // cache by attention type. Non-batchable requests (vision / adapters /
  // user seed / unsupported explicit kv-quant) drain to the serial executor
  // (see GenerationGateway.place). No inference setting is rewritten.
  // DEFAULT 8 (flipped 2026-07-05, Josh's call, after GATE-B1-SPEED): a
  // lone request through the batch lane IS the serial engine (adopted
  // serial-class caches, compiled decode, prompt cache + SSD restore;
  // 0.992-0.996 paired decode ratios, byte-identical output), so the cap
  // only changes behavior when concurrent requests actually arrive — the
  // agentic sub-agent workload. --batch 1 pins strict serial for
  // arrival-independent numerics. 8 = optiq's Mac-safe concurrency.
  const batch = Math.max(1, Math.floor(serverOptions.batch ?? 8));
  const defaultGeneratedTokens =
    serverOptions.defaultMaxTokens ?? ctx.glmMemoryPlan?.maxGenerationTokens;

  // KV-quant scheme, resolved once. UNSET now means bf16 (flipped
  // 2026-07-05 with the naked-=-L1 default): quantized KV measured 5–20%
  // SLOWER decode than bf16 at ≤16k on every model — on mlx-lm too (its
  // kv8 oracle trails its own bf16) — so it pays only in memory headroom
  // and must be an explicit opt-in (--kv-quant config|4|8, or --l2
  // whose presets pass it explicitly). The CLI always passes kvQuant now;
  // this fallback is the library-user default and matches the CLI's.
  // Mutually exclusive by contract (GenerateOptions.turboQuant doc): a
  // programmatic caller setting both gets turboQuant — say so, like the
  // other risky-combination warnings below.
  if (serverOptions.turboQuant && serverOptions.kvQuant && serverOptions.kvQuant !== "off")
    console.warn(
      `[kv-quant] both turboQuant and --kv-quant ${serverOptions.kvQuant} are set; ` +
        `turboQuant wins (they are mutually exclusive).`,
    );
  const resolvedKvScheme = resolveKvScheme({
    override: serverOptions.kvQuant,
    turboQuant: serverOptions.turboQuant,
    config: ctx.kvConfig,
  });
  const kvScheme = resolvedKvScheme.generationOptions;
  // Phase 3.1: kvConfig whose layers are all full-attention BATCHES (the
  // scheduler applies the mixed scheme per row); uniform kvBits and configs
  // touching rotating layers still route those requests serial. The warning
  // only fires for the still-serial compositions.
  if (batch > 1 && kvScheme.kvBits)
    console.warn(
      `[batch] --batch ${batch} with uniform --kv-quant ${kvScheme.kvBits}: uniform ` +
        `quantized KV is serial-only (it touches rotating layers) — those requests ` +
        `won't batch. Use --kv-quant config for batched mixed-precision KV, or omit ` +
        `--kv-quant to batch in bf16. (docs/design/unified-engine-frontier-plan.md)`,
    );
  // TurboQuant is solo-only in v1 (novel cache class, not batchable by
  // construction — see GenerationGateway placement's cache-capability gate).
  if (batch > 1 && kvScheme.turboQuant)
    console.warn(
      `[batch] --batch ${batch} with --kv-quant turbo: TurboQuant is serial-only in v1 ` +
        `— those requests won't batch. Omit --kv-quant to batch in bf16. ` +
        `(docs/design/turboquant.md)`,
    );
  // Quantized KV (any axis) excludes the spec lane: drafted requests fall to
  // the normal serial path WITH the KV scheme applied rather than losing it
  // silently (mirrors the affine kvBits/kvConfig exclusion; the spec loop is
  // bf16-KV-only in v1).
  if (ctx.draft && (kvScheme.turboQuant || kvScheme.kvBits || kvScheme.kvConfig?.length))
    console.warn(
      `[spec] --draft-model with quantized KV (--kv-quant ${serverOptions.turboQuant ? "turbo" : String(serverOptions.kvQuant)}): ` +
        `the speculative lane is bf16-KV-only in v1 — requests keep the KV scheme and ` +
        `decode serially WITHOUT speculation. Omit --kv-quant to speculate. ` +
        `(docs/design/speculative-decoding.md Phase 4)`,
    );
  // TurboQuant head-dim fail-fast (2026-07-07 review): the cache class only
  // supports {64,128,256,512} (sign-vector + Lloyd-Max table coverage) and
  // used to validate LAZILY on the first append — an unsupported model
  // (e.g. a 72/80/96 head dim) accepted --kv-quant turbo at startup and
  // then 500'd EVERY request from inside prefill. The config knows the
  // full-attention head dim (the only kind that converts; sliding layers
  // stay bf16) — refuse at createServer instead.
  if (kvScheme.turboQuant) {
    const dim = ctx.model.config.text.globalHeadDim;
    if (!(TURBOQUANT_HEAD_DIMS as readonly number[]).includes(dim))
      throw new Error(
        `--kv-quant turbo: this model's full-attention head_dim is ${dim}; ` +
          `TurboQuant supports {${TURBOQUANT_HEAD_DIMS.join(",")}} ` +
          `(docs/design/turboquant.md) — use --kv-quant config|4|8 or omit it`,
      );
  }
  // Paged KV v1 (docs/design/kv-cache.md): explicit refusals, not
  // silent downgrades — the incompatible combos would otherwise degrade
  // quietly (batch: paged caches can't merge; kv-quant: the swap would
  // drop the scheme, the exact composition bug the kvQuant gate above
  // exists to prevent; draft: the spec lane assumes serial-class caches).
  if (serverOptions.pagedKv) {
    if (batch > 1)
      throw new Error(
        `--paged-kv is serial-only in v1 — add --batch 1 (got --batch ${batch}). ` +
          `Batched paging is the follow-up PR (docs/design/kv-cache.md).`,
      );
    if (kvScheme.kvBits || kvScheme.kvConfig?.length || kvScheme.turboQuant)
      throw new Error(
        `--paged-kv is bf16-only in v1 — omit --kv-quant (quantized paged ` +
          `blocks are a documented follow-up, docs/design/kv-cache.md).`,
      );
    if (ctx.draft)
      throw new Error(
        `--paged-kv cannot combine with --draft-model in v1 ` +
          `(docs/design/kv-cache.md non-goals).`,
      );
    if (!ctx.model.config.modelType.startsWith("gemma4"))
      throw new Error(
        `--paged-kv v1 supports Gemma4-family models only ` +
          `(this model: ${ctx.model.config.modelType}) — docs/design/kv-cache.md.`,
      );
    const bs = serverOptions.pagedKv.blockSize;
    if (bs !== undefined && (!Number.isInteger(bs) || bs <= 0))
      throw new Error(`--paged-kv-block-size must be a positive integer (got ${bs})`);
    if (serverOptions.ssdCacheDir)
      console.warn(
        "[paged-kv] --ssd-cache has no effect: paged requests bypass the prompt " +
          "cache (v1 non-goal), so nothing reaches the SSD tier.",
      );
  }

  // SSD cold tier (docs/design/kv-cache.md): prefix KV survives RAM
  // eviction and restarts. Compatibility key = configFingerprint (graph
  // shape) + the EFFECTIVE kv scheme (flags pick bf16 vs config vs uniform
  // on the same model — restored caches must match what serving produces) +
  // tokenizer hash (ids must keep meaning the same text).
  // RAM prompt-cache cap: 8 GB default (Josh's call, 2026-07-06). The old
  // flat 2e9 was an anti-OOM reflex sized for a 1B model in 24 GB — a
  // single full-context 12B entry is ~0.6 GB, so it silently shrank to
  // "three entries" on big models. 8 GB holds a dozen 12B contexts; idle
  // entries still demote to SSD and LRU eviction bounds pressure.
  // --prompt-cache <GB> overrides; 0 disables.
  const promptCacheCap = serverOptions.promptCacheBytes ?? 8e9;
  let ssdStore: SsdCacheStore | null = null;
  if (serverOptions.ssdCacheDir) {
    if (promptCacheCap <= 0)
      throw new Error("--ssd-cache requires the RAM prompt cache (--prompt-cache 0 disables it)");
    const schemeKey = resolvedKvScheme.cacheKey;
    const tokJson = readFileSync(`${ctx.model.config.modelDir}/tokenizer.json`);
    ssdStore = new SsdCacheStore({
      dir: serverOptions.ssdCacheDir,
      maxBytes: serverOptions.ssdCacheMaxBytes ?? 32 * 2 ** 30,
      configFingerprint: `${configFingerprint(ctx.model.config)}-${schemeKey}`,
      tokenizerHash: Bun.hash(tokJson).toString(16),
      modelId: ctx.modelId,
      verify: serverOptions.ssdCacheVerify,
    });
    const recovered = ssdStore.scan();
    console.log(
      `[ssd-cache] ${serverOptions.ssdCacheDir} — ${recovered} entr${recovered === 1 ? "y" : "ies"} recovered, ` +
      `${(ssdStore.totalBytes / 2 ** 30).toFixed(2)} GiB of ${(ssdStore.maxBytes / 2 ** 30).toFixed(0)} GiB cap`,
    );
  }

  // Layer 0 (unified-engine plan): the cold tier is bound INTO the prompt
  // cache — take() itself tiers over it, so the batch scheduler and every
  // other consumer get SSD restores through the same API; eviction AND
  // idle demotion spill into it.
  const coldTier = ssdStore
    ? {
        find: (prompt: number[], ns: string) => {
          const h = ssdStore!.find(prompt, ns);
          return h ? { prefixLen: h.prefixLen, handle: h.entry } : null;
        },
        restore: (handle: unknown) => {
          const loaded = ssdStore!.restore(handle as import("./ssd-cache").SsdIndexEntry, ctx.model);
          if (!loaded) return null;
          // Restore is a STREAMED COPY (2026-07-07 A7-restore): the caches
          // own their bytes and no mapping outlives loadKvCache — nothing
          // to pin, nothing to unmap. retain stays in the entry contract
          // as a no-op so callers' dispose ordering is unchanged.
          return { tokens: loaded.tokens, caches: loaded.caches, retain: () => {} };
        },
        store: (tokens: number[], caches: import("./model/gemma4").Cache[], ns: string) => {
          ssdStore!.store(tokens, caches, ns);
        },
      }
    : null;
  const promptCache = new PromptCache(
    promptCacheCap,
    // RAM eviction AND idle demotion spill to the cold tier NON-BLOCKING
    // (2026-07-06, same contract as the write-behind snapshot below): the
    // cache hands us OWNED zero-copy clones + copied tokens (made under
    // the generation lock — microseconds; entries are immutable so the
    // clones stay consistent), and the flush goes through the BOUNDED
    // SpillQueue -> storeAsync (idle-gated per tensor, see below) ->
    // clone disposal on every settle/drop path (that dispose is what
    // actually frees the demoted GPU memory; the queue's byte cap keeps
    // starved-gate retention bounded — 2026-07-07 review fix). spillQueue
    // is declared with the snapshot scheduler below; safe to close over
    // here because spills only fire at put()/demoteIdle time, long after
    // init.
    ssdStore
      ? {
          spillOwned: (entry) =>
            spillQueue!.enqueue({ tokens: entry.tokens, caches: entry.caches, ns: entry.ns }),
        }
      : null,
    coldTier,
  );
  // Responses-API store for previous_response_id resumption (Phase 11):
  // TTL + byte-capped LRU, port of optiq/response_store.py. Pairs with
  // the prompt cache: a resumed conversation re-renders the same prefix,
  // so its KV prefill is already cached.
  const responseStore = new ResponseStore();

  /** Run one generation with prompt-cache reuse. Must be called under the
   *  gateway's exclusive lock — the gateway invokes it on the serial lane;
   *  the curve /generate endpoint wraps it in gateway.runExclusive. (The old
   *  `enqueue` promise queue is gone; the gateway's AsyncMutex is THE lock.)
   *  onToken returning `false` halts generation early (stop
   *  sequence fired); the cache snapshot stays valid and is still kept.
   *  Media (vision/audio embeddings-prefill) requests bypass the prompt
   *  cache: soft tokens are identical placeholder ids, so prefix matching
   *  across different images/clips would false-hit. */
  const runGeneration = async (
    promptIds: number[],
    options: GenerateOptions,
    onToken: (token: number, logprobs?: TokenLogprobs) => void | boolean | Promise<void | boolean>,
    vision?: {
      embeddings: import("./mlx/array").MlxArray;
      imageMask?: import("./mlx/array").MlxArray;
      multimodalMask?: import("./mlx/array").MlxArray;
      mrope?: MropeRequestState;
    },
    trace?: PromptResponseTrace,
  ) => {
    // Qwen vision: install the request's mRoPE state for every forward of
    // this serial run (prefill AND decode use the 3D interleaved positions +
    // delta). Scoped inside the try below — under the serial mutex — so
    // queued text requests never see it and a throw between here and the
    // try (makeCache under memory pressure, spec-path early return) can't
    // leave a DEAD request's positions installed for the next generation
    // (2026-08-18 review).
    // Speculative decoding (serve --draft-model): spec-ELIGIBLE requests
    // decode through the verify loop; the rest fall through to the normal
    // serial path (never wrong results, just no speedup — logged once per
    // combination class would be noise, so silent). Eligibility v1:
    // text-only, base weights, no logprobs capture, bf16 KV — ALL quantized
    // KV axes excluded (affine kvBits/kvConfig AND turboQuant; the spec loop
    // builds fresh bf16 caches and never calls maybeQuantizeKv, so routing a
    // turbo request here would silently drop the operator's KV scheme —
    // 2026-07-07 review). Grammar COMPOSES (Phase C constrained verify walk
    // — see the serve-loop.ts header). Prompt-cache reuse is bypassed on
    // the spec path v1.
    if (
      ctx.draft &&
      !vision &&
      !options.adapters?.length &&
      !options.logprobs &&
      !options.kvBits &&
      !options.kvConfig &&
      !options.turboQuant &&
      // Belt: --paged-kv + --draft-model is refused at createServer; this
      // keeps the spec lane paged-free even for programmatic callers.
      !options.pagedKv
    ) {
      const { specServeRun } = await import("./spec/serve-loop");
      return withModelWiredLimit(
        ctx.model,
        () => withModelUsageFlush(
          ctx.model,
          () => specServeRun(
            ctx.model, ctx.draft!.provider, ctx.draft!.numDraftTokens,
            promptIds, options, onToken,
          ),
        ),
      );
    }
    // Cache entries are adapter-specific: KV computed under one adapter
    // must never seed another's (or the base's) prefill.
    const cacheNs = options.adapters?.join("+") ?? "";
    // Paged-KV request scope (docs/design/kv-cache.md): media
    // prompts (bidir overlay) and LoRA-adapter requests are v1 non-goals —
    // they run the PLAIN cache path even under --paged-kv (scope the flag
    // per request, never 400). Effective value computed ONCE so the
    // prompt-cache bypass below and the generate() options can't disagree.
    const pagedKv = vision || options.adapters?.length ? undefined : options.pagedKv;
    // Paged requests bypass the prompt cache entirely (v1 non-goal:
    // PagedKVCache has no cloneKvCaches/restore path — the vision
    // precedent). Fresh caches per request, disposed on completion.
    const skipPromptCache = Boolean(vision || pagedKv);
    // Both tiers in one call (Layer 0): take() prefers a strictly-longer
    // SSD prefix, restores it zero-copy, and trims — see PromptCache.take.
    const closeCacheLookup = trace?.begin("cache.lookup_restore", {
      mechanism: "serial",
      bypassed: skipPromptCache,
    });
    const entry = skipPromptCache ? null : promptCache.take(promptIds, cacheNs);
    closeCacheLookup?.();
    const caches = entry?.caches ?? ctx.model.makeCache();
    // Prompt-boundary snapshot (the multi-turn agent fix, 2026-07-04): the
    // prompt+gen entry put() below is UNTRIMMABLE at context > sliding
    // window (wrapped rings) and under quantized KV (mid-group), so any
    // decode→encode roundtrip drift in the reply the client sends back
    // turns the next turn into a total miss (measured: 12B turn-2 TTFT
    // 8.9 s instead of ~0.2 s). A prompt-ONLY entry is always an exact
    // prefix of the next turn's rendering regardless of reply drift.
    // Zero-copy (cloneKvCaches = slice views); only for substantial cold
    // prefills, where the re-prefill it saves is worth an extra entry.
    // The oracle invariant (mlx-lm insert_segments): a trim-free STRICT
    // prefix of the prompt exists for EVERY substantial request — cap the
    // boundary at len-1 so even a stableLen == len prompt (e4b: the
    // template tail survives the probe render) snapshots prompt[:-1]. An
    // exact repeat then matches with trimNeeded == 0, bypassing
    // isTrimmable() entirely — the only reuse path a wrapped ring has.
    const boundary = Math.min(options.snapshotAt ?? promptIds.length, promptIds.length - 1);
    // Re-snapshot on EVERY substantial request whose stable boundary extends
    // past the cached prefix; the clone is zero-copy views, so re-putting
    // is ~free.
    const snapshotBoundary =
      !skipPromptCache && boundary >= 256 && boundary > (entry?.tokens.length ?? 0);
    try {
      if (vision?.mrope && ctx.model instanceof Qwen35Model)
        ctx.model.mrope = vision.mrope;
      const gen = generate(ctx.model, promptIds, {
        ...options,
        pagedKv, // request-scoped (undefined strips the server-wide flag)
        cache: caches,
        ...(snapshotBoundary
          ? {
              // snapshotAt MUST travel with the hook: generate() splits the
              // prefill at exactly this many tokens and fires the hook while
              // the caches hold exactly that prefix — putting boundary
              // tokens against caches at any other offset is silent KV
              // corruption.
              snapshotAt: boundary,
              onPrefillDone: () => {
                try {
                  promptCache.put(promptIds.slice(0, boundary), cloneKvCaches(caches), cacheNs);
                } catch (e) {
                  console.warn(`prompt-boundary snapshot skipped: ${(e as Error).message}`);
                }
              },
            }
          : {}),
        ...(vision
          ? {
              promptEmbeddings: vision.embeddings,
              ...(vision.imageMask ? { imageMask: vision.imageMask } : {}),
              ...(vision.multimodalMask ? { multimodalMask: vision.multimodalMask } : {}),
            }
          : {}),
      }, { trace, mechanism: "serial" });
      for await (const t of gen) {
        if ((await onToken(t.token, t.logprobs)) === false) break;
      }
      const s = gen.stats!; // set on completion AND on early break
      if (skipPromptCache) {
        // Vision and paged-KV requests own their caches for exactly one
        // generation (paged: v1 non-goal — no PromptCache integration).
        for (const c of caches) c.dispose();
      } else {
        // put() fires onPut → the debounced write-behind SSD snapshot
        // (wired below), covering the batch lane's puts too.
        promptCache.put(s.cacheTokens, caches, cacheNs, entry?.retain);
      }
      return s;
    } catch (e) {
      for (const c of caches) c.dispose();
      entry?.retain?.();
      // A throw BEFORE generate()/the gateway took ownership (promptCache
      // take / makeCache) would leak the grammar's WASM matcher; dispose()
      // is idempotent, so this is safe when the throw came from inside run
      // (whose finally already disposed it).
      options.grammar?.dispose();
      throw e;
    } finally {
      if (ctx.model instanceof Qwen35Model) ctx.model.mrope = null;
      vision?.embeddings.dispose();
      vision?.imageMask?.dispose();
      vision?.multimodalMask?.dispose();
      options.visionPixels?.dispose();
    }
  };

  // Write-behind persistence (restart survival — the oMLX boundary-snapshot
  // idea at whole-entry granularity, spill-on-evict alone can't survive a
  // clean exit): after a request completes, snapshot its still-RAM-resident
  // entry to SSD off the request path. Debounced + coalesced per namespace —
  // an agent hammering one conversation persists the settled state once
  // things go quiet, not every turn. Runs under the gateway lock (byte
  // extraction must not race a generation mutating the entry); if the entry
  // was evicted (already spilled) or extended (a newer schedule pending)
  // meanwhile, findExact misses and nothing is written.
  // Keyed by namespace and exact tokens: a sub-second final [prompt+gen] put
  // must not cancel the pending boundary snapshot, and unrelated prompts of
  // equal length must not cancel each other. Exact reschedules still
  // coalesce; stale keys self-clean when findExact misses.
  //
  // NON-BLOCKING (2026-07-06, the write-behind persistence contract): the
  // gateway lock is held only for a zero-copy SNAPSHOT (findExact +
  // cloneKvCaches — microseconds; entries are immutable so the clones are
  // consistent forever). The flush itself runs OFF the lock via
  // storeAsync, and writes chain serially so two multi-hundred-MB flushes
  // never overlap.
  //
  // IDLE-GATED (2026-07-07, the decode@ctx fix): "off the lock" was not
  // enough — every per-tensor flush step is a blocking GPU sync on the
  // SAME stream decode uses (ops.contiguous enqueues a kernel, rawBytesView
  // evals) plus a synchronous multi-MB writeSync, and the setImmediate
  // pacing interleaved those slices exactly between decode tokens. A ~16k
  // entry's flush overlapping the bench's ctx repeats depressed decode@ctx
  // ~9% on e4b (mlx-lm runs no equivalent background work). Now every step
  // — including the first — awaits gateway.onIdle() (ssdFlushGate), so the
  // flush only progresses while NOTHING is generating and pauses when a
  // request arrives mid-flush. Tradeoffs, accepted: durability waits for a
  // quiet moment (single-user serving quiesces constantly; sustained
  // hammering defers the flush AND the spill clones' GPU-memory release —
  // bounded by the chain), and one in-flight tensor step (~10-15 MB) can
  // still land ahead of a just-arrived request. MLX_BUN_SSD_WRITEBEHIND=0
  // disables write-behind snapshots entirely — the paired-A/B lever + kill
  // switch (restart survival then degrades to spill-on-evict only).
  const writeBehindOn = runtimeValue("MLX_BUN_SSD_WRITEBEHIND") !== "0";
  const ssdFlushGate = (): Promise<void> => gateway.onIdle();
  // Bounded write-behind queue (2026-07-07 review fix — see SpillQueue in
  // kv-store.ts): pending clones pin their entries' GPU buffers while the
  // idle gate starves under sustained traffic, so QUEUED bytes are capped —
  // over cap the oldest queued spill drops (clone disposed immediately, a
  // future cache miss, never a wrong result) instead of accumulating past
  // the prompt-cache cap. Default 2 GB (a quarter of the 8 GB RAM-cache
  // default); MLX_BUN_SSD_SPILL_QUEUE_GB overrides. The durability
  // coordinator retains a dirty record until the queue confirms the atomic
  // store. Explicit flush and graceful shutdown can therefore retry a drop.
  // `|| 2` would coerce an explicit "0" back to 2 GB — parse so 0 works
  // (cap 0 = keep only the newest + in-flight clone pinned; the soft cap
  // never drops the item just enqueued).
  // The gateway exists before the spill queue because the SSD writer uses
  // its idle boundary to avoid competing with generation.
  const gateway = new GenerationGateway(ctx.model, batch, runGeneration, {
    kvBudgetBytes: serverOptions.kvBudgetBytes,
    kvScheme: resolvedKvScheme,
    promptCache,
  });
  const spillQueueGbRaw = Number(runtimeValue("MLX_BUN_SSD_SPILL_QUEUE_GB"));
  const spillQueueCapBytes =
    (Number.isFinite(spillQueueGbRaw) && spillQueueGbRaw >= 0 ? spillQueueGbRaw : 2) * 1024 ** 3;
  const spillQueue = ssdStore
    ? new SpillQueue(
        spillQueueCapBytes,
        cacheBytes,
        (item) => ssdStore!.storeAsync(item.tokens, item.caches, item.ns, ssdFlushGate),
        (caches) => { for (const c of caches) c.dispose(); },
      )
    : null;
  const durability = ssdStore && spillQueue && writeBehindOn
    ? new SsdDurabilityCoordinator(
        gateway,
        promptCache,
        spillQueue,
        cloneKvCaches,
        (tokens, ns) => ssdStore.hasDurablePrefix(tokens, ns),
      )
    : null;
  const durabilityStats = (): DurabilitySnapshotStats =>
    durability?.stats ?? {
      pendingSnapshots: 0,
      pendingSpills: spillQueue?.pendingCount ?? 0,
      pendingSpillBytes: spillQueue?.pendingBytes ?? 0,
      droppedSpills: spillQueue?.droppedCount ?? 0,
      failedSpills: spillQueue?.failedCount ?? 0,
    };
  const flushDurability = async (): Promise<DurabilityFlushResult> => {
    if (durability) return durability.flush();
    const started = performance.now();
    await spillQueue?.drain();
    const stats = durabilityStats();
    return {
      ...stats,
      durable: stats.pendingSpills === 0,
      flushedSnapshots: 0,
      missingSnapshots: 0,
      elapsedMs: performance.now() - started,
    };
  };
  // Every put() — serial lane AND batch scheduler — schedules the snapshot
  // (Layer 0: batch-lane entries survive restarts too, not just evictions).
  promptCache.onPut = durability ? (tokens, ns) => durability.schedule(tokens, ns) : null;

  // Idle demotion (Layer 0): entries unused for --ssd-demote-idle seconds
  // spill to SSD and free their GPU memory — the RAM tier drains between
  // bursts while every prefix stays reachable (take() restores via
  // zero-copy mmap). The exclusive section below covers only the sweep's
  // zero-copy clone + dispose (spillOwned above); the SSD write itself
  // runs off-lock on ssdWriteChain. Swept only when the engine is TRULY idle: the
  // runExclusive below registers as a serial waiter, which would DRAIN a
  // running batch, so the activity check guards it (a momentary exclusive
  // grab of an idle engine is free). 0 disables.
  const demoteIdleMs = (serverOptions.ssdDemoteIdleSec ?? (ssdStore ? 300 : 0)) * 1000;
  let demoteTimer: ReturnType<typeof setInterval> | null = null;
  if (ssdStore && demoteIdleMs > 0) {
    demoteTimer = setInterval(() => {
      if (gateway.activeRows > 0 || gateway.pendingRows > 0) return;
      void gateway.runExclusive(async () => {
        const n = promptCache.demoteIdle(demoteIdleMs);
        if (n > 0) console.log(`[ssd-cache] demoted ${n} idle entr${n === 1 ? "y" : "ies"} to disk`);
      }).catch(() => {});
    }, Math.max(30_000, demoteIdleMs / 4));
    demoteTimer.unref?.();
  }

  const completionExecutor = new CompletionExecutor(gateway);
  const completionProtocolUsage = (usage: CompletionSummary["usage"]) => ({
    prompt_tokens: usage.promptTokens,
    completion_tokens: usage.completionTokens,
    total_tokens: usage.totalTokens,
    prompt_tokens_details: { cached_tokens: usage.cachedTokens },
    ...(usage.speculation ? { speculation: usage.speculation } : {}),
  });
  const completionUsage = (summary: CompletionSummary) => ({
    ...completionProtocolUsage(summary.usage),
    lane: summary.lane,
  });

  // Admission ceiling, resolved once (Phase 5 memoryBudget enforcement).
  // fit() solves max safe context from weights + KV growth + prefill
  // transient. The active kv-quant scheme (uniform kvBits / per-layer
  // kvConfig) is billed at its true bytes/element so a quantized cache
  // advertises and admits the larger window it actually enables; only
  // TurboQuant still bills bf16 (conservative — no projector for its
  // layout yet, and it is solo-only in v1).
  const admission = ctx.glmMemoryPlan ?? fit(
    ctx.model.config, ctx.model.weightsBytes, 1,
    undefined, undefined, 0, serverOptions.memoryBudgetBytes,
    resolvedKvScheme.fitOptions,
  );
  // A zero ceiling is a warning, never a startup refusal: killing the
  // server here can only parrot the per-request admission message (which
  // still fires, with this same ceiling) or be a false positive from the
  // fit model itself — it can never save anything the request gate
  // doesn't. Serve until physically incapable.
  if (admission.maxSafeContext < 1)
    console.warn(
      `[admission] memory budget ${(admission.usableBytes / 1e9).toFixed(2)} GB leaves no ` +
      `safe context for ${ctx.modelId} (weights ${(ctx.model.weightsBytes / 1e9).toFixed(2)} GB) ` +
      `— serving anyway; generation requests will be refused until the budget is raised`,
    );
  const allocatorLimit =
    admission.allocatorLimitBytes ?? serverOptions.memoryBudgetBytes;
  if (allocatorLimit) setMemoryLimit(allocatorLimit);

  // /library response cache (30 s) — registry + config reads only.
  const startedAt = Date.now();
  const discoveryRoutes = createDiscoveryRoutes(ctx, gateway, startedAt);

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

  // (kvScheme is resolved earlier, above the prompt-cache construction —
  // the SSD tier's compatibility fingerprint folds the effective scheme in.)

  // XTC never removes EOS or the newline token: mlx_lm.server passes
  // [tokenizer.eos_token_id, tokenizer.encode("\n")] as xtc_special_tokens.
  // We pass the flat equivalent — ALL configured EOS ids plus the bare newline
  // id(s), encoded WITHOUT special tokens (mlx-lm's encode("\n") can drag a
  // BOS along on some tokenizers; protecting BOS from XTC is a no-op, so the
  // flat/no-BOS form is behaviorally identical and cleaner).
  const xtcSpecialTokens = [
    ...ctx.model.config.eosTokenIds,
    ...ctx.tokenizer.encode("\n", false),
  ];

  // Effective enable_thinking for a request, with the same precedence the chat
  // template uses (extracted so sampling and template rendering can't disagree):
  // explicit chat_template_kwargs.enable_thinking → reasoning_effort ("none" =
  // off) → server --thinking default → model default (MiniCPM5 → off). undefined
  // means "not a switchable-thinking model / leave the template default".
  const resolveEnableThinking = (req: ChatRequest): boolean | undefined => {
    const explicit = req.chat_template_kwargs?.enable_thinking;
    if (typeof explicit === "boolean") return explicit;
    const effort = req.reasoning_effort;
    if (effort !== undefined) return effort !== "none";
    if (serverOptions.defaultThinking !== undefined) return serverOptions.defaultThinking;
    return isMiniCPM5Config(ctx.model.config) ? false : undefined;
  };

  const toOptions = (req: ChatRequest): GenerateOptions & { stopSequences: string[] } => {
    // Sampling follows the thinking state — which the web UI's thinking button
    // drives via enable_thinking. Model authors publish a SINGLE
    // generation_config temperature (the think-mode value) but recommend a
    // cooler one for direct, no-think replies (MiniCPM5 card: 0.9 think / 0.7
    // no-think, top_p 0.95 for both). So with no explicit temperature set, a
    // no-think turn runs at most NO_THINK_TEMPERATURE while a think turn keeps
    // the model's hotter configured default. An explicit request/CLI
    // temperature always wins. top_p is unchanged by mode.
    const NO_THINK_TEMPERATURE = 0.7;
    const genTemp = ctx.genDefaults.temperature ?? 0.7;
    const defaultTemp = resolveEnableThinking(req) === false
      ? Math.min(genTemp, NO_THINK_TEMPERATURE)
      : genTemp;
    return {
      // A thinking turn emits <think>…</think> AND the answer, so a tight cap
      // truncates the visible reply. Default very generously (the model's
      // context is far larger); only an explicit max_tokens narrows it. The
      // model still stops at its eos_token well before this in normal replies.
      maxTokens: req.max_completion_tokens ?? req.max_tokens ??
        defaultGeneratedTokens ?? 65_536,
      temperature: req.temperature ?? serverOptions.defaultTemperature ?? defaultTemp,
      topP: req.top_p ?? serverOptions.defaultTopP ?? ctx.genDefaults.topP ?? 0,
      topK: req.top_k ?? serverOptions.defaultTopK ?? ctx.genDefaults.topK ?? 0,
      seed: req.seed ?? nextDefaultSeed(),
      repetitionPenalty: req.repetition_penalty ?? ctx.genDefaults.repetitionPenalty,
      // mlx_lm.server sampling extensions (defaults mirror server.py: min_p /
      // xtc off, context windows 20). parseLogitBias throws on non-numeric
      // input — callers surface it as a 400 (mlx-lm's coercion error).
      minP: req.min_p ?? 0,
      xtcProbability: req.xtc_probability ?? 0,
      xtcThreshold: req.xtc_threshold ?? 0,
      ...(req.xtc_probability ? { xtcSpecialTokens } : {}),
      logitBias: parseLogitBias(req.logit_bias),
      repetitionContextSize: req.repetition_context_size ?? 20,
      presencePenalty: req.presence_penalty ?? 0,
      presenceContextSize: req.presence_context_size ?? 20,
      frequencyPenalty: req.frequency_penalty ?? 0,
      frequencyContextSize: req.frequency_context_size ?? 20,
      hlg: resolveHlg(req.hlg, serverOptions.hlg),
      // generate() yields token ids; stop sequences match on decoded text
      // (they can span token boundaries), so the StopMatcher sits at the
      // decode layer below and halts the loop via onToken → false.
      stopSequences: (typeof req.stop === "string" ? [req.stop] : req.stop ?? [])
        .filter((s) => typeof s === "string" && s.length > 0),
      ...kvScheme,
      // Paged KV is a server-wide mode like the kv scheme above (v1:
      // serial bf16 gemma4 — the createServer refusals hold the invariants).
      ...(serverOptions.pagedKv ? { pagedKv: serverOptions.pagedKv } : {}),
    };
  };

  /** Compile a grammar controller from the request's structured-output fields
   *  (response_format / guided_* / structured_outputs). Returns null when no
   *  constraint is requested OR when compile failed (degrade path). On degrade,
   *  `degradeHint` carries a human description for the system-prompt injection
   *  + Warning header (oMLX parity — never 500). Honors MLX_BUN_GRAMMAR=0. */
  const compileGrammarForRequest = async (
    req: ChatRequest,
  ): Promise<{ controller: import("./grammar").GrammarController | null; degradeHint: string | null }> => {
    if (!grammarEnabled()) {
      return {
        controller: null,
        degradeHint: "grammar compilation disabled by MLX_BUN_GRAMMAR=0",
      };
    }
    const r = await compileGrammarRequest(
      req as GrammarRequest,
      ctx.tokenizer,
      ctx.model.config.text.vocabSize,
    );
    if (!r) return { controller: null, degradeHint: null };
    return { controller: r.controller, degradeHint: r.degradeHint };
  };

  // Map OpenAI reasoning_effort levels onto the Qwen3.8 template's supported
  // set (xhigh|medium|low — the template raises on anything else). "none"
  // means thinking off (handled by resolveEnableThinking), so no depth is
  // passed. Only consumed for templates with readsReasoningEffort.
  const qwenReasoningEffort = (
    effort: ChatRequest["reasoning_effort"],
  ): "xhigh" | "medium" | "low" | undefined => {
    switch (effort) {
      case "minimal":
      case "low":
        return "low";
      case "medium":
        return "medium";
      case "high":
      case "xhigh":
        return "xhigh";
      default:
        return undefined; // "none" / unset → template default (xhigh)
    }
  };

  const templateOptionsFor = (req: ChatRequest, tools: ToolDefinition[] | null) => {
    // enableThinking resolution (and its precedence) lives in
    // resolveEnableThinking so template rendering and sampling stay in sync.
    return {
      tools,
      enableThinking: resolveEnableThinking(req),
      reasoningEffort: qwenReasoningEffort(req.reasoning_effort),
      preserveThinking: req.chat_template_kwargs?.preserve_thinking,
    };
  };

  const promptIdsFor = (
    req: ChatRequest,
    tools: ToolDefinition[] | null,
  ): { ids: number[]; startInThinking: boolean } => {
    const opts = templateOptionsFor(req, tools);
    const rendered = ctx.template.render(normalizeMessages(req.messages), opts);
    const ids = ctx.tokenizer.encode(rendered);
    // template includes <bos>; tokenizer post-processor also prepends one
    const trimmed = ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId ? ids.slice(1) : ids;
    return { ids: trimmed, startInThinking: promptEndsInOpenThink(rendered) };
  };

  /** STABLE cache boundary: the prompt's tail is a generation primer (e.g.
   *  12B's `<|channel>thought` tokens) that the NEXT turn's re-render does
   *  not contain — a cache entry ending there can never prefix-match again
   *  once the rings wrap. Probe by rendering this conversation as if a
   *  reply existed; the common prefix is what every future turn preserves.
   *  The probe is EXPENSIVE (a second full render + encode — ~150 ms at
   *  16k with our tokenizer; 30-50% of the 12B ctx-repeat TTFT,
   *  2026-07-06b), but the PRIMER LENGTH it measures is constant per
   *  template mode: the divergence sits after a special-token turn
   *  delimiter, and special tokens break BPE merges, so message content
   *  can't shift it. So the full probe runs ONCE per mode and later
   *  requests pay a subtraction. (A wrong boundary is a QUALITY knob, not
   *  a correctness one — any prefix ≤ len-1 is a valid snapshot point.) */
  const primerLenByMode = new Map<string, number>();
  const stableLenFor = (
    req: ChatRequest,
    tools: ToolDefinition[] | null,
    trimmed: number[],
  ): number => {
    const opts = templateOptionsFor(req, tools);
    const mode = `${opts.enableThinking}|${!!tools?.length}|${opts.reasoningEffort ?? ""}|${opts.preserveThinking ?? ""}`;
    const primer = primerLenByMode.get(mode);
    if (primer !== undefined) return Math.max(0, trimmed.length - primer);
    let stableLen = trimmed.length;
    try {
      const probe = ctx.tokenizer.encode(
        ctx.template.render(
          [...normalizeMessages(req.messages), { role: "assistant", content: "x" }],
          opts,
        ),
      );
      const probeTrimmed =
        probe[0] === probe[1] && probe[0] === ctx.tokenizer.bosTokenId ? probe.slice(1) : probe;
      let i = 0;
      const n = Math.min(trimmed.length, probeTrimmed.length);
      while (i < n && trimmed[i] === probeTrimmed[i]) i++;
      stableLen = i;
      // Memoize the mode's primer length (sanity-capped: a "primer" longer
      // than 64 tokens means the probe diverged for content reasons —
      // don't generalize that).
      const p = trimmed.length - stableLen;
      if (p >= 0 && p <= 64) primerLenByMode.set(mode, p);
    } catch { /* probe is best-effort; full boundary is the fallback */ }
    return stableLen;
  };

  const toolStreamMode = (tools: ToolDefinition[] | null): ToolStreamMode =>
    // Gemma-4 keeps the token-level sentinel path; every other family
    // (MiniCPM5, Qwen3/3.5, Tier-0 generics) emits tool calls as DECODED TEXT
    // — see selectToolStreamMode for why sentinel ids must stay family-gated.
    selectToolStreamMode(ctx.model.config.modelType, !!tools?.length);

  const toolRouter = (tools: ToolDefinition[] | null): ToolAwareStream =>
    new ToolAwareStream(ctx.tokenizer, toolStreamMode(tools), tools);

  if (serverOptions.unixSocket) {
    try { require("node:fs").unlinkSync(serverOptions.unixSocket); } catch {}
  }
  // Bun's types make unix/port mutually exclusive variants that a spread
  // union can't prove — runtime accepts either; cast once at the call.
  serverRef = Bun.serve({
    ...(serverOptions.unixSocket
      ? ({ unix: serverOptions.unixSocket } as unknown as Record<string, never>)
      : {
          port,
          ...(serverOptions.hostname ? { hostname: serverOptions.hostname } : {}),
        }),
    idleTimeout: 0,
    // Web chat rides pi's AgentSession events over a WebSocket; the embedded
    // pi provider points back at THIS server's own loopback /v1 (port
    // resolved lazily — it may be ephemeral until serve() binds).
    websocket: makePiWsHandler({
      port: () => serverRef.port ?? port,
      modelId: ctx.modelId,
      contextWindow: ctx.model.config.text.maxPositionEmbeddings,
      // capability flags — true if a tower is loaded or loadable (lazy)
      vision: !!(ctx.vision || ctx.loadVision),
      audio: !!(ctx.audio || ctx.loadAudio),
      thinking: ctx.template.supportsThinking,
      // Model-author sampling defaults (generation_config.json, server-CLI
      // overrides applied) for the sampling popover's per-model recommended
      // values (web-ui-pass-plan.md #14 groundwork) — same resolution
      // /v1/models' gen_defaults uses, so the two surfaces agree. The
      // think-mode-vs-not distinction lives in toOptions (per-request); this
      // is the single "model's own defaults" snapshot sent once at ready.
      genDefaults: {
        temperature: serverOptions.defaultTemperature ?? ctx.genDefaults.temperature ?? null,
        topP: serverOptions.defaultTopP ?? ctx.genDefaults.topP ?? null,
        topK: serverOptions.defaultTopK ?? ctx.genDefaults.topK ?? null,
      },
    }),
    async fetch(request, server) {
      const url = new URL(request.url);

      if (url.pathname === "/admin/cache/flush" && request.method === "POST") {
        const result = await flushDurability();
        return Response.json(
          {
            ...result,
            entries: ssdStore?.entries ?? 0,
            longest_durable_prefix_tokens:
              ssdStore?.longestDurablePrefixTokens ?? 0,
          },
          { status: result.durable ? 200 : 503 },
        );
      }

      if (url.pathname === "/ws/chat") {
        if (server.upgrade(request, { data: { sessionId: crypto.randomUUID() } as PiWsData }))
          return undefined;
        return new Response("expected websocket", { status: 426 });
      }

      const auxiliaryResponse = await handleAuxiliaryRoute(url, request);
      if (auxiliaryResponse) return auxiliaryResponse;

      const staticResponse = handleStaticRoute(url, request, STATIC_ROUTE_ASSETS);
      if (staticResponse) return staticResponse;

      const discoveryResponse = await discoveryRoutes.handle(url, request);
      if (discoveryResponse) return discoveryResponse;

      const modelAdminResponse = await handleModelAdminRoute(url, request, ctx, gateway);
      if (modelAdminResponse) return modelAdminResponse;

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
        let artifactDiskBytes: number | null = null;
        let measured: { decodeTps: number; ts: number } | null = null;
        try {
          const { Registry } = await import("./registry");
          const rec = new Registry().list().find((r) => r.repoId === ctx.modelId);
          if (rec) {
            expertsBytes = rec.expertsBytes;
            artifactDiskBytes = rec.sizeBytes;
            const { EvalDB } = await import("./evaldb");
            measured = new EvalDB().latestFor(rec.path);
          }
        } catch {}
        if (ctx.glmMemoryPlan) {
          const plan = ctx.glmMemoryPlan;
          const li = plan.lineItems;
          const kvBytes = li.targetKvBytes + li.mtpKvBytes;
          const transientBytes = plan.plannedProcessBytes -
            li.residentWeightsBytes - li.mainExpertSlabBytes -
            li.mtpExpertSlabBytes - kvBytes;
          return Response.json({
            machine: {
              chip: chip.name,
              ram_bytes: machine.ramBytes,
              bandwidth_gbs: machine.bandwidthGBs,
            },
            context_tokens: plan.contextTokens,
            typical_context_tokens: plan.contextTokens,
            typical_decode_tps: GLM52_G5_MEASURED_WARM_DECODE_TPS,
            measured_decode_tps: GLM52_G5_MEASURED_WARM_DECODE_TPS,
            measured_at: GLM52_G5_MEASURED_AT,
            report: {
              fits: true,
              weights_bytes: li.residentWeightsBytes,
              kv_bytes: kvBytes,
              transient_bytes: transientBytes,
              total_bytes: plan.plannedProcessBytes,
              usable_bytes: plan.processLimitBytes,
              max_safe_context: plan.contextTokens,
              predicted_decode_tps: null,
            },
            glm52: {
              artifact_disk_bytes: artifactDiskBytes,
              main_expert_slab_bytes: li.mainExpertSlabBytes,
              mtp_expert_slab_bytes: li.mtpExpertSlabBytes,
              max_generation_tokens: plan.maxGenerationTokens,
              direct_oracle_warm_decode_tps:
                GLM52_G5_DIRECT_ORACLE_WARM_DECODE_TPS,
              aspirational_decode_tps: GLM52_G5_ASPIRATIONAL_DECODE_TPS,
            },
            sku_matrix_ctx: plan.contextTokens,
            sku_matrix: [{
              sku: chip.name,
              ram_gb: Math.round(machine.ramBytes / 2 ** 30),
              fits: true,
              max_context: plan.contextTokens,
              decode_tps: GLM52_G5_MEASURED_WARM_DECODE_TPS,
            }],
          });
        }
        const report = fit(
          ctx.model.config, ctx.model.weightsBytes, admission.maxSafeContext,
          machine, undefined, expertsBytes, serverOptions.memoryBudgetBytes,
          resolvedKvScheme.fitOptions,
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
            resolvedKvScheme.fitOptions,
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

      if (url.pathname === "/stats" && request.method === "GET") {
        // Active KV scheme across ALL layers. Since Phase 9 rotating
        // (sliding-window) caches quantize too, so every layer the
        // scheme names counts — the old display filtered to
        // full_attention and silently undercounted (e.g. 26B showed
        // 5/30 quantized when its kv_config.json covers all 30).
        const layerTypes = ctx.model.config.text.layerTypes;
        const kvLayers: Record<string, number> = {};
        let kvMode = "bf16";
        if (kvScheme.turboQuant) {
          // v1: full-attention layers only (sliding-window stays bf16 —
          // docs/design/turboquant.md non-goal).
          const fullAttn = layerTypes.filter((l) => l !== "sliding_attention").length;
          kvMode = `turbo k${kvScheme.turboQuant.kBits}v${kvScheme.turboQuant.vBits}`;
          kvLayers[`turbo-k${kvScheme.turboQuant.kBits}v${kvScheme.turboQuant.vBits}`] = fullAttn;
        } else if (kvScheme.kvBits) {
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
          ...(ssdStore ? {
            ssd_cache: {
              dir: serverOptions.ssdCacheDir,
              entries: ssdStore.entries,
              bytes: ssdStore.totalBytes,
              max_bytes: ssdStore.maxBytes,
              restores: ssdStore.stats.restores,
              spills: ssdStore.stats.spills,
              restore_ms_last: Math.round(ssdStore.stats.restoreMsLast),
              demotions: promptCache.demotions,
              pending_snapshots: durability?.stats.pendingSnapshots ?? 0,
              pending_spills: spillQueue?.pendingCount ?? 0,
              pending_spill_bytes: spillQueue?.pendingBytes ?? 0,
              dropped_spills: spillQueue?.droppedCount ?? 0,
              failed_spills: spillQueue?.failedCount ?? 0,
              longest_durable_prefix_tokens: ssdStore.longestDurablePrefixTokens,
            },
          } : {}),
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
            memory_budget_bytes:
              ctx.glmMemoryPlan?.processLimitBytes ??
              serverOptions.memoryBudgetBytes ?? null,
            usable_bytes: admission.usableBytes,
            weights_bytes: ctx.model.weightsBytes,
          },
          ...(ctx.glmMemoryPlan ? {
            glm52: {
              preset: ctx.glmMemoryPlan.preset,
              planned_process_bytes: ctx.glmMemoryPlan.plannedProcessBytes,
              process_limit_bytes: ctx.glmMemoryPlan.processLimitBytes,
              context_tokens: ctx.glmMemoryPlan.contextTokens,
              max_generation_tokens: ctx.glmMemoryPlan.maxGenerationTokens,
              batch_size: ctx.glmMemoryPlan.batchSize,
              dsa: ctx.model instanceof Glm52Model && ctx.model.capabilities.dsa,
              mtp: ctx.draft?.provider.id === "glm52-native-mtp",
              mtp_draft_tokens: ctx.glmMemoryPlan.mtpDraftTokens,
              resident_weight_bytes: ctx.glmMemoryPlan.lineItems.residentWeightsBytes,
              main_expert_slab_bytes: ctx.glmMemoryPlan.lineItems.mainExpertSlabBytes,
              mtp_expert_slab_bytes: ctx.glmMemoryPlan.lineItems.mtpExpertSlabBytes,
              expert_runtime: ctx.model instanceof Glm52Model &&
                  ctx.model.expertRuntime
                ? {
                    main_residency:
                      ctx.model.expertRuntime.manager.snapshot(),
                    mtp_residency:
                      ctx.model.expertRuntime.mtp?.manager.snapshot() ?? null,
                    last_turn: ctx.model.expertRuntime.lastTelemetry,
                    last_repin: ctx.model.expertRuntime.lastRepin,
                  }
                : null,
            },
          } : {}),
          // --batch: configured cap, whether batching is live for this model,
          // and rows currently decoding in the batch.
          batch: {
            configured: batch,
            mode: gateway.batchMode,
            batched: gateway.batchingEnabled,
            active_rows: gateway.activeRows,
            pending_rows: gateway.pendingRows,
            submitted_rows: gateway.submittedRows,
            kv_bytes: gateway.kvBytes.projected,
            kv_budget_bytes: gateway.kvBytes.budget,
          },
        });
      }

      // Engine-mode admin (unix-socket children only — never exposed on
      // TCP): drain = quiesce the gateway + demote the whole prompt cache
      // to the SSD tier. The pool calls this before evicting a model
      // child, so its state survives the eviction losslessly.
      if (
        serverOptions.unixSocket &&
        url.pathname === "/admin/drain" &&
        request.method === "POST"
      ) {
        await gateway.runExclusive(async () => {
          promptCache.demoteIdle(0);
        });
        return Response.json({ drained: true, demotions: promptCache.demotions });
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
          // gateway.runExclusive: this raw forward must not run concurrently
          // with batched decode steps or a serial generation (GPU + shared
          // model state are single-owner — D3, one lock).
          const result = await gateway.runExclusive(async () => {
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
      // (src/lab/curve/curve-sampler.ts). The browser editor calls this; same curve object the
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
            // runExclusive: runGeneration touches the GPU + prompt cache, so
            // it needs the gateway lock (this endpoint bypasses gateway.run).
            await gateway.runExclusive(() => runGeneration(ids, genOpts, (t) => { toks.push(t); }));
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
      const handleChat = async (
        body: ChatRequest,
        signal: AbortSignal,
        streamProtocol?: CompletionStreamProtocol,
        requestId?: string,
        trace?: PromptResponseTrace,
      ): Promise<Response> => {
        if (!Array.isArray(body.messages) || body.messages.length === 0)
          return Response.json({ error: { message: "messages required" } }, { status: 400 });
        // mlx-lm validates logprobs params up front (ValueError → 400)
        const lpParamError = validateLogprobsParams(body);
        if (lpParamError)
          return Response.json({ error: { message: lpParamError } }, { status: 400 });
        // Covers /v1/messages and /v1/responses too — both funnel through
        // this handler after translation.
        const effortError = validateReasoningEffort(body);
        if (effortError)
          return Response.json({ error: { message: effortError } }, { status: 400 });

        const id = requestId ?? `chatcmpl-${crypto.randomUUID()}`;
        const closePromptPrepare = trace?.begin("request.prompt_prepare");
        const created = Math.floor(Date.now() / 1000);
        const tools =
          body.tool_choice === "none" ? null : (body.tools?.length ? body.tools : null);
        const hasImages = body.messages.some(
          (m) => Array.isArray(m.content) &&
            m.content.some((p: any) => p.type === "image_url" || p.type === "image"),
        );
        // Same shapes extractAudio accepts: OpenAI-canonical input_audio plus
        // optiq's audio / audio_url aliases (docs/design/generic-model-support.md §3.2).
        const hasAudio = body.messages.some(
          (m) => Array.isArray(m.content) &&
            m.content.some(
              (p: any) => p.type === "input_audio" || p.type === "audio" || p.type === "audio_url",
            ),
        );
        // Video content parts (video_url / video with base64 data) —
        // Qwen3.5-family only (decoded to sampled frames via the
        // AVFoundation sidecar, vision/video-frames.ts).
        const hasVideos = body.messages.some(
          (m) => Array.isArray(m.content) &&
            m.content.some((p: any) => p.type === "video_url" || p.type === "video"),
        );
        let promptIds: number[];
        let stableLen: number | null = null;
        // Whether the prompt primed an open <think> (Qwen3.5/MiniCPM5 thinking
        // on) so the model's output starts mid-reasoning — seeds the splitter.
        // Vision is Gemma4-only (no switchable thinking channel), so it's false.
        let startInThinking = false;
        let vision: Parameters<typeof runGeneration>[3];
        let diffusionPixels: import("./mlx/array").MlxArray | null = null;
        const ownership = new RequestOwnership();
        // Grammar-constrained decoding (src/grammar.ts). Compile BEFORE prompt
        // rendering: on the degrade path (compile failed but a constraint was
        // requested) inject a system message instructing valid JSON so the
        // model still best-efforts schema-conformant output (oMLX parity —
        // _compile_grammar_for_request returning None + build_json_system_prompt).
        let grammarCtrl: import("./grammar").GrammarController | null = null;
        let grammarWarning: string | null = null;
        const grammarReq =
          body.response_format != null || !!body.guided_grammar ||
          !!body.guided_regex || !!body.guided_choice?.length ||
          body.structured_outputs != null;
        if (grammarReq) {
          const g = await compileGrammarForRequest(body);
          grammarCtrl = ownership.own(g.controller);
          if (!g.controller && g.degradeHint) {
            const degraded = applyGrammarDegrade(body, g.degradeHint);
            grammarWarning = degraded.warning;
            body = degraded.body;
          }
        }
        const rejectBeforeRun = (response: Response): Response => {
          ownership.dispose();
          return response;
        };
        try {
          // Video is Qwen3.5-family only and never composes with audio —
          // one early guard so no downstream branch can silently drop a
          // video part (the gemma/diffusion builders don't know the type).
          if (hasVideos && (hasAudio || !(ctx.model instanceof Qwen35Model))) {
            return rejectBeforeRun(Response.json(
              { error: { message: hasAudio
                  ? "video and audio content parts cannot be combined"
                  : `model ${ctx.modelId} does not accept video input — video ` +
                    `content parts need a Qwen3.5-family model (e.g. Qwen3.8-27B)` } },
              { status: 400 },
            ));
          }
          if (hasAudio) {
            // Audio (and MIXED image+audio) input — A4 of
            // docs/design/generic-model-support.md. One buildMultimodalPrompt call
            // splices both media kinds in document order. A request WITH
            // audio on a model whose tower is unavailable is an explicit 400
            // — never a silent text-only degrade (that leniency is only for
            // requests without the media, getVisionTower's contract).
            const audioTower = getAudioTower(ctx);
            if (!audioTower || !ctx.audioTokenIds) {
              return rejectBeforeRun(Response.json(
                {
                  error: {
                    message:
                      `model ${ctx.modelId} has no audio tower — audio input needs ` +
                      `a model whose config.json carries audio_config and whose ` +
                      `sidecar ships the audio tensors (e.g. gemma-4 e4b OptiQ)`,
                  },
                },
                { status: 400 },
              ));
            }
            let visionSide:
              | { tower: VisionEncoder; tokenIds: VisionTokenIds }
              | undefined;
            if (hasImages) {
              const tower = getVisionTower(ctx);
              if (!tower) {
                return rejectBeforeRun(Response.json(
                  { error: { message: "model has no vision sidecar" } }, { status: 400 },
                ));
              }
              visionSide = { tower, tokenIds: ctx.visionTokenIds };
            }
            const { messages: withAudioParts, images } =
              await extractImages(normalizeMessages(body.messages));
            const { messages, audio } = await extractAudio(withAudioParts);
            // Non-WAV containers (mp3/m4a/flac/ogg/aiff/…) transcode to
            // 16 kHz WAV via CoreAudio; RIFF bytes pass through untouched.
            // Failures throw into the prompt-build 400 below.
            const wavs = await Promise.all(audio.map(ensureWav));
            // The towers are only ever non-null for Gemma4 (loader gates).
            const mp = await buildMultimodalPrompt(
              ctx.model as Gemma4Model,
              {
                ...(visionSide ? { vision: visionSide } : {}),
                audio: { tower: audioTower, tokenIds: ctx.audioTokenIds },
              },
              ctx.tokenizer, ctx.template, messages, images, wavs, tools,
            );
            promptIds = mp.ids;
            // bidirMask is null whenever audio is present (§3.3 Q1: mixed
            // prompts run fully causal); the union mask does the per-layer
            // id zeroing either way.
            vision = {
              embeddings: mp.embeddings,
              ...(mp.bidirMask ? { imageMask: mp.bidirMask } : {}),
              multimodalMask: mp.multimodalMask,
            };
          } else if (hasImages && ctx.model instanceof DiffusionGemmaModel) {
            // DiffusionGemma image-text-to-text: its OWN dedicated SigLIP tower +
            // encoder vision merge feed the denoising engine (NOT the AR
            // forwardEmbeddings path). v1 supports a single image.
            const dm = ctx.model;
            if (!dm.visionTower) {
              return rejectBeforeRun(Response.json(
                { error: { message: "this checkpoint has no vision tower" } }, { status: 400 },
              ));
            }
            const { messages, images } = await extractImages(normalizeMessages(body.messages));
            if (images.length !== 1) {
              return rejectBeforeRun(Response.json(
                { error: { message: "DiffusionGemma image input supports exactly one image" } },
                { status: 400 },
              ));
            }
            const rendered = ctx.template.render(messages, { tools, addGenerationPrompt: true });
            const rawIds = ctx.tokenizer.encode(rendered, /* addSpecialTokens */ false);
            const { pixels, softTokens } = await dm.visionTower.preprocess(images[0]!);
            diffusionPixels = ownership.own(pixels);
            promptIds = spliceImageTokens(rawIds, [softTokens], {
              image: ctx.visionTokenIds.imageTokenId,
              boi: ctx.visionTokenIds.boiTokenId,
              eoi: ctx.visionTokenIds.eoiTokenId,
            });
          } else if ((hasImages || hasVideos) && ctx.model instanceof Qwen35Model) {
            // Qwen3.8 vision + video: the tower is a Qwen3VLVisionTower
            // riding the shared lazy slot (makeVisionLoader's qwen branch);
            // image/video spans splice into input embeddings and the request
            // carries mRoPE positions + delta (PLAN 14v/14w). Videos decode
            // to sampled frames via the AVFoundation sidecar.
            const tower = getVisionTower(ctx) as unknown as Qwen3VLVisionTower | null;
            if (!tower) {
              return rejectBeforeRun(Response.json(
                { error: { message: "model has no vision sidecar" } }, { status: 400 },
              ));
            }
            const { messages: withVideos, images } =
              await extractImages(normalizeMessages(body.messages));
            const { messages, videos } = await extractVideos(withVideos);
            const vp = await buildQwen3VLVisionPrompt(
              ctx.model, tower, ctx.tokenizer, ctx.template, messages, images,
              {
                imageTokenId: (ctx.model.config.raw.image_token_id as number) ?? 248056,
                videoTokenId: (ctx.model.config.raw.video_token_id as number) ?? 248057,
                visionStartId: (ctx.model.config.raw.vision_start_token_id as number) ?? 248053,
                visionEndId: (ctx.model.config.raw.vision_end_token_id as number) ?? 248054,
              },
              templateOptionsFor(body, tools),
              videos,
            );
            promptIds = vp.ids;
            vision = { embeddings: vp.embeddings, mrope: vp.mrope };
          } else if (hasImages) {
            // Loads (and caches) the tower on first image request — text-only
            // sessions never pay for it.
            const tower = getVisionTower(ctx);
            if (!tower) {
              return rejectBeforeRun(Response.json(
                { error: { message: "model has no vision sidecar" } }, { status: 400 },
              ));
            }
            const { messages, images } = await extractImages(normalizeMessages(body.messages));
            // The tower is only ever non-null for Gemma4 (sidecar gate in
            // makeVisionLoader), so the model narrow is safe here.
            const vp = await buildVisionPrompt(
              ctx.model as Gemma4Model, tower, ctx.tokenizer, ctx.template,
              messages, images, ctx.visionTokenIds, tools,
            );
            promptIds = vp.ids;
            vision = { embeddings: vp.embeddings, imageMask: vp.imageMask };
          } else {
            const built = promptIdsFor(body, tools);
            promptIds = built.ids;
            startInThinking = built.startInThinking;
            stableLen = -1; // marker: chat path, probe lazily below
          }
        } catch (e) {
          return rejectBeforeRun(Response.json(
            { error: { message: `prompt build failed: ${(e as Error).message}` } },
            { status: 400 },
          ));
        }
        ownership.own(vision?.embeddings);
        ownership.own(vision?.imageMask);
        ownership.own(vision?.multimodalMask);
        ownership.own(diffusionPixels);
        let options: ReturnType<typeof toOptions>;
        try {
          options = toOptions(body);
          // Stable cache boundary for the prompt-boundary snapshot (chat
          // prompts end in a generation primer the next turn won't contain).
          // The probe costs a second full render+encode (~150 ms at 16k), so
          // run it ONLY when a snapshot can actually be taken: the cache
          // must not already hold the strict prefix (warm repeats peek at
          // len-1 → skip; the snapshot gate needs boundary > cached prefix).
          if (stableLen !== null) {
            const cachePeek = promptCache.peekPrefixLen(
              promptIds, options.adapters?.join("+") ?? "");
            if (cachePeek < promptIds.length - 1)
              options.snapshotAt = stableLenFor(body, tools, promptIds);
          }
        } catch (e) {
          // bad logit_bias (non-numeric keys/values) — mlx-lm's coercion error
          return rejectBeforeRun(
            Response.json({ error: { message: (e as Error).message } }, { status: 400 }),
          );
        }
        if (diffusionPixels) options.visionPixels = diffusionPixels;
        // Attach the compiled grammar controller (null when no constraint /
        // degrade — generate() runs the unmasked fast pipelined loop).
        if (grammarCtrl) options.grammar = grammarCtrl;
        const requestedMaxTokens = options.maxTokens ?? 1024;
        let adapterIds: string[];
        try {
          // A request's explicit `adapter` (incl. "none") wins over the
          // startup default from `serve --adapter <dir>`.
          adapterIds = ctx.adapters.resolveSpec(body.adapter ?? serverOptions.defaultAdapter);
        } catch (e) {
          return rejectBeforeRun(
            Response.json({ error: { message: (e as Error).message } }, { status: 400 }),
          );
        }

        const wantLogprobs = body.logprobs === true;
        const topLogprobs =
          typeof body.top_logprobs === "number" && body.top_logprobs > 0
            ? body.top_logprobs : 0;
        let prepared: PreparedCompletion;
        try {
          prepared = prepareCompletion({
            requestId: id,
            plan: {
              promptIds,
              options,
              requestedMaxTokens,
              maxSafeContext: admission.maxSafeContext,
              stream: body.stream === true,
              wantLogprobs,
              topLogprobs,
              adapterIds,
              hasVision: !!vision,
              userSeed: body.seed !== undefined,
              hasGrammar: !!grammarCtrl,
              hasDraft: !!ctx.draft,
              ownership,
            },
            vision,
            pipeline: {
              router: toolRouter(tools),
              stopper: new StopMatcher(options.stopSequences),
              thinking: new ThinkingTagSplitter(
                ctx.template.thinkingFormat === "think-tag",
                startInThinking,
              ),
              collectToolCalls: true,
            },
            ...(body.stream
              ? {
                  createFlowControl: ({ mechanism }) =>
                    createTimedFlowControl(mechanism === "serial"),
                }
              : {}),
            onPlacement: ({ mechanism, shape }) => {
              if (runtimeValue("MLX_BUN_LANE_DEBUG") === "1")
                console.error(
                  `[scheduling] mechanism=${mechanism} shape=${JSON.stringify(shape)} ` +
                    `t=${Date.now() % 100000}`,
                );
            },
            idToToken: (tokenId) => ctx.tokenizer.idToToken(tokenId),
          });
        } catch (error) {
          closePromptPrepare?.();
          trace?.finish("error", { stage: "prepare_completion" });
          if (!(error instanceof CompletionRejected)) throw error;
          return Response.json({ error: error.error }, { status: error.status });
        }
        closePromptPrepare?.();

        if (body.stream) {
          const streamAbort = new AbortController();
          const generationSignal = AbortSignal.any([signal, streamAbort.signal]);
          let cancelled = false;
          const stream = new ReadableStream<Uint8Array>({
            start(controller) {
              const enc = new TextEncoder();
              const send = (obj: unknown) => {
                if (!generationSignal.aborted)
                  controller.enqueue(enc.encode(`data: ${JSON.stringify(obj)}\n\n`));
              };
              const emitFrames = (frames: string[]) => {
                if (generationSignal.aborted) return;
                for (const frame of frames) controller.enqueue(enc.encode(frame));
              };
              let latestUsage: Readonly<CompletionSummary["usage"]> | null = null;
              let wroteFirstEvent = false;
              let traceOutcome: "success" | "error" | "abort" = "success";
              const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
                id, object: "chat.completion.chunk", created, model: ctx.modelId,
                choices: [{ index: 0, delta, finish_reason: finish }],
              });
              void (async () => {
                try {
                // The gateway owns lane selection + GPU exclusivity; this body
                // runs per-request (concurrently in batched mode, each writing
                // its own SSE stream — the per-row fan-out).
                if (streamProtocol) emitFrames(streamProtocol.start());
                else send(chunk({ role: "assistant", content: "" }, null));
                const sendEvents = (events: readonly CompletionEvent[]) => {
                  if (events.length && !wroteFirstEvent) {
                    wroteFirstEvent = true;
                    trace?.mark("response.first_write");
                  }
                  if (streamProtocol) {
                    emitFrames(streamProtocol.addEvents([...events]));
                    return;
                  }
                  for (const event of events) {
                    if (event.type === "reasoning") {
                      send(chunk({ reasoning: event.text }, null));
                    } else if (event.type === "content") {
                      send(chunk({ content: event.text }, null));
                    } else {
                      send(chunk({
                        tool_calls: event.calls.map((call, index) => ({ index, ...call })),
                      }, null));
                    }
                  }
                };
                const summary = await completionExecutor.execute(prepared, {
                  signal: generationSignal,
                  trace,
                  onEvents: sendEvents,
                  ...(streamProtocol
                    ? { onUsageProgress: (usage) => { latestUsage = usage; } }
                    : {}),
                });
                const usage = completionUsage(summary);
                if (streamProtocol) {
                  emitFrames(streamProtocol.finish(summary.finishReason, usage));
                } else {
                  send({ ...chunk({}, summary.finishReason), usage });
                  // bare sentinel per the OpenAI spec — strict SDK clients
                  // require the unquoted terminator.
                  controller.enqueue(enc.encode("data: [DONE]\n\n"));
                }
                trace?.mark("response.final_write");
                } catch (e) {
                  traceOutcome = generationSignal.aborted ? "abort" : "error";
                  if (!generationSignal.aborted) {
                    const message = (e as Error).message;
                    if (streamProtocol) {
                      emitFrames([
                        ...streamProtocol.error(message),
                        ...streamProtocol.finish(
                          "stop",
                          latestUsage ? completionProtocolUsage(latestUsage) : {},
                        ),
                      ]);
                    } else {
                      send({ error: { message } });
                    }
                  }
                } finally {
                  trace?.finish(traceOutcome);
                  if (!cancelled) {
                    if (generationSignal.aborted) controller.error(generationSignal.reason);
                    else controller.close();
                  }
                }
              })();
            },
            cancel(reason) {
              cancelled = true;
              streamAbort.abort(reason);
            },
          });
          return new Response(stream, {
            headers: {
              "content-type": "text/event-stream",
              "cache-control": "no-cache",
              connection: "keep-alive",
              ...(grammarWarning ? { Warning: grammarWarning } : {}),
            },
          });
        }

        try {
          {
            const summary = await completionExecutor.execute(prepared, { signal, trace });
            trace?.mark("response.final_write");
            const response = Response.json({
              id, object: "chat.completion", created, model: ctx.modelId,
              choices: [{
                index: 0,
                message: {
                  role: "assistant",
                  content: summary.content || (summary.toolCalls.length ? null : ""),
                  ...(summary.reasoning ? { reasoning: summary.reasoning } : {}),
                  ...(summary.toolCalls.length ? { tool_calls: summary.toolCalls } : {}),
                },
                ...(summary.logprobs ? { logprobs: summary.logprobs } : {}),
                finish_reason: summary.finishReason,
              }],
              usage: completionUsage(summary),
            }, grammarWarning ? { headers: { Warning: grammarWarning } } : undefined);
            trace?.finish("success");
            return response;
          }
        } catch (e) {
          trace?.finish(signal.aborted ? "abort" : "error");
          // A 500 with no server-side trace is undebuggable in the field —
          // always log the stack (the JSON body keeps only the message).
          console.error(`[serve] 500 on chat request:\n${(e as Error).stack ?? e}`);
          return Response.json({ error: { message: (e as Error).message } }, { status: 500 });
        }
      };

      if (url.pathname === "/v1/chat/completions" && request.method === "POST") {
        const id = `chatcmpl-${crypto.randomUUID()}`;
        const trace = createPromptResponseTrace({
          traceId: request.headers.get("x-mlx-bun-trace-id") ?? id,
          requestId: id,
          route: url.pathname,
        });
        const closeBodyParse = trace?.begin("request.body_parse");
        let body: ChatRequest;
        try {
          body = (await request.json()) as ChatRequest;
        } catch {
          closeBodyParse?.();
          trace?.finish("error", { stage: "body_parse" });
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        closeBodyParse?.();
        return handleChat(body, request.signal, undefined, id, trace);
      }

      // Raw text completion (mlx_lm.server's /v1/completions, request_type
      // "text"): NO chat template — the prompt string is tokenized directly
      // (tokenizer.encode with the tokenizer's own special-token handling,
      // exactly mlx-lm's `tokenizer.encode(request.prompt)`). Rides the same
      // GenerationGateway + admission + adapter path as chat; no tool router
      // or thinking splitter (raw text in, raw text out).
      if (url.pathname === "/v1/completions" && request.method === "POST") {
        const id = `cmpl-${crypto.randomUUID()}`;
        const trace = createPromptResponseTrace({
          traceId: request.headers.get("x-mlx-bun-trace-id") ?? id,
          requestId: id,
          route: url.pathname,
        });
        const closeBodyParse = trace?.begin("request.body_parse");
        let body: TextCompletionRequest;
        try {
          body = (await request.json()) as TextCompletionRequest;
        } catch {
          closeBodyParse?.();
          trace?.finish("error", { stage: "body_parse" });
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        closeBodyParse?.();
        const closePromptPrepare = trace?.begin("request.prompt_prepare");
        if (typeof body.prompt !== "string" || body.prompt.length === 0)
          return Response.json(
            {
              error: {
                message: "prompt (a non-empty string) is required " +
                  "(token-array prompts are not accepted, matching mlx_lm.server)",
              },
            },
            { status: 400 },
          );
        // mlx-lm validates logprobs params up front (ValueError → 400)
        const lpParamError = validateLogprobsParams(body);
        if (lpParamError)
          return Response.json({ error: { message: lpParamError } }, { status: 400 });
        const created = Math.floor(Date.now() / 1000);
        const promptIds = ctx.tokenizer.encode(body.prompt);
        const ownership = new RequestOwnership();
        let options: ReturnType<typeof toOptions>;
        try {
          options = toOptions(body as unknown as ChatRequest);
        } catch (e) {
          // bad logit_bias (non-numeric keys/values) — mlx-lm's coercion error
          return Response.json({ error: { message: (e as Error).message } }, { status: 400 });
        }
        // Grammar-constrained decoding on raw completions too (response_format /
        // guided_* / structured_outputs). The degrade path for /v1/completions
        // has no chat template to inject a system message into, so a degrade
        // only emits the Warning header (no prompt injection) — documented gap
        // vs the chat lane, which mirrors oMLX's text-completions behavior.
        let textGrammarWarning: string | null = null;
        const textGrammarReq =
          body.response_format != null || !!body.guided_grammar ||
          !!body.guided_regex || !!body.guided_choice?.length ||
          body.structured_outputs != null;
        if (textGrammarReq) {
          const g = await compileGrammarForRequest(body as unknown as ChatRequest);
          if (g.controller) options.grammar = ownership.own(g.controller);
          else if (g.degradeHint)
            textGrammarWarning =
              `grammar not enforced: ${g.degradeHint} - no prompt injection on /v1/completions`;
        }
        // mlx_lm.server's default max_tokens is 512 (its --max-tokens CLI
        // default). The chat lane's very generous default is wrong for raw
        // completion: with no template an EOS may never come.
        const requestedMaxTokens = body.max_completion_tokens ?? body.max_tokens ??
          defaultGeneratedTokens ?? 512;
        let adapterIds: string[];
        try {
          adapterIds = ctx.adapters.resolveSpec(body.adapter ?? serverOptions.defaultAdapter);
        } catch (e) {
          ownership.dispose();
          return Response.json({ error: { message: (e as Error).message } }, { status: 400 });
        }
        const wantLogprobs = body.logprobs === true;
        const topLogprobs =
          typeof body.top_logprobs === "number" && body.top_logprobs > 0
            ? body.top_logprobs : 0;
        let prepared: PreparedCompletion;
        try {
          prepared = prepareCompletion({
            requestId: id,
            plan: {
              promptIds,
              options,
              requestedMaxTokens,
              maxSafeContext: admission.maxSafeContext,
              stream: body.stream === true,
              wantLogprobs,
              topLogprobs,
              adapterIds,
              hasVision: false,
              userSeed: body.seed !== undefined,
              hasGrammar: !!options.grammar,
              hasDraft: !!ctx.draft,
              ownership,
            },
            pipeline: {
              router: new ToolAwareStream(ctx.tokenizer, "plain", null),
              stopper: new StopMatcher(options.stopSequences),
              thinking: new ThinkingTagSplitter(false),
              collectToolCalls: false,
            },
            ...(body.stream
              ? { createFlowControl: () => createTimedFlowControl(true) }
              : {}),
            idToToken: (tokenId) => ctx.tokenizer.idToToken(tokenId),
          });
        } catch (error) {
          closePromptPrepare?.();
          trace?.finish("error", { stage: "prepare_completion" });
          if (!(error instanceof CompletionRejected)) throw error;
          return Response.json({ error: error.error }, { status: error.status });
        }
        closePromptPrepare?.();

        if (body.stream) {
          const streamAbort = new AbortController();
          const generationSignal = AbortSignal.any([request.signal, streamAbort.signal]);
          let cancelled = false;
          const stream = new ReadableStream<Uint8Array>({
            start(controller) {
              const enc = new TextEncoder();
              const send = (obj: unknown) => {
                if (!generationSignal.aborted)
                  controller.enqueue(enc.encode(`data: ${JSON.stringify(obj)}\n\n`));
              };
              const chunk = (text: string, finish: string | null) => ({
                id, object: "text_completion", created, model: ctx.modelId,
                choices: [{ index: 0, text, finish_reason: finish }],
              });
              let wroteFirstEvent = false;
              let traceOutcome: "success" | "error" | "abort" = "success";
              void (async () => {
                try {
                const sendEvents = (events: readonly CompletionEvent[]) => {
                  if (events.length && !wroteFirstEvent) {
                    wroteFirstEvent = true;
                    trace?.mark("response.first_write");
                  }
                  for (const event of events) {
                    if (event.type === "content") send(chunk(event.text, null));
                  }
                };
                const summary = await completionExecutor.execute(prepared, {
                  signal: generationSignal,
                  trace,
                  onEvents: sendEvents,
                });
                // final chunk: finish_reason + usage (mlx-lm gates usage behind
                // stream_options.include_usage; we always attach it, matching
                // our chat lane — an additive superset OpenAI clients ignore)
                send({
                  ...chunk("", summary.finishReason),
                  usage: completionUsage(summary),
                });
                  controller.enqueue(enc.encode("data: [DONE]\n\n"));
                trace?.mark("response.final_write");
                } catch (e) {
                  traceOutcome = generationSignal.aborted ? "abort" : "error";
                  if (!generationSignal.aborted)
                    send({ error: { message: (e as Error).message } });
                } finally {
                  trace?.finish(traceOutcome);
                  if (!cancelled) {
                    if (generationSignal.aborted) controller.error(generationSignal.reason);
                    else controller.close();
                  }
                }
              })();
            },
            cancel(reason) {
              cancelled = true;
              streamAbort.abort(reason);
            },
          });
          return new Response(stream, {
            headers: {
              "content-type": "text/event-stream",
              "cache-control": "no-cache",
              connection: "keep-alive",
              ...(textGrammarWarning ? { Warning: textGrammarWarning } : {}),
            },
          });
        }

        try {
          const summary = await completionExecutor.execute(prepared, {
            signal: request.signal,
            trace,
          });
          trace?.mark("response.final_write");
          const response = Response.json({
            id, object: "text_completion", created, model: ctx.modelId,
            choices: [{
              index: 0, text: summary.content,
              ...(summary.logprobs ? { logprobs: summary.logprobs } : {}),
              finish_reason: summary.finishReason,
            }],
            usage: completionUsage(summary),
          }, textGrammarWarning ? { headers: { Warning: textGrammarWarning } } : undefined);
          trace?.finish("success");
          return response;
        } catch (e) {
          trace?.finish(request.signal.aborted ? "abort" : "error");
          return Response.json({ error: { message: (e as Error).message } }, { status: 500 });
        }
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
        const resp = await handleChat(
          chatBody,
          request.signal,
          anthropicBody.stream
            ? createAnthropicStreamProtocol(ctx.modelId)
            : undefined,
        );
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
          return resp;
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
        const resp = await handleChat(
          chatBody,
          request.signal,
          responsesBody.stream
            ? createResponsesStreamProtocol(
                ctx.modelId,
                prevId,
                (final) =>
                  responseStore.put(final.id as string, {
                    input: capturedInput,
                    output: final.output as unknown[],
                    instructions: capturedInstructions,
                  }),
              )
            : undefined,
        );
        if (!resp.ok) {
          const err = (await resp.json().catch(() => null)) as
            | { error?: { message?: string } }
            | null;
          return responsesError(resp.status, err?.error?.message ?? "request failed");
        }
        if (responsesBody.stream) {
          return resp;
        }
        const responses = chatJsonToResponses(await resp.json(), ctx.modelId, prevId);
        responseStore.put(responses.id as string, {
          input: capturedInput,
          output: responses.output as unknown[],
          instructions: capturedInstructions,
        });
        return Response.json(responses);
      }

      const labResponse = await handleLabRoute(url, request, {
        ensureJobs,
        serverPort: () => server.port,
        invalidateLibrary: () => discoveryRoutes.invalidateLibrary(),
      });
      if (labResponse) return labResponse;

      const adminResponse = await handleAdminRoute(url, request, {
        ensureJobs,
        invalidateLibrary: () => discoveryRoutes.invalidateLibrary(),
      });
      if (adminResponse) return adminResponse;

      return Response.json({ error: { message: "not found" } }, { status: 404 });
    },
  });
  serverLifecycles.set(serverRef, {
    flush: flushDurability,
    stats: durabilityStats,
    stopTimers: () => {
      if (demoteTimer) clearInterval(demoteTimer);
      demoteTimer = null;
    },
  });
  return serverRef;
}
