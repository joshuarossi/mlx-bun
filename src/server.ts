import { modelServingBinding } from "./backends/mlx/model-serving";
import type { ServingContext } from "./serve/model-host";
export { generationCheckpointKey } from "./serve/checkpoint-identity";
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
import { STATIC_ROUTE_ASSETS } from "./web-assets";
import { readFileSync } from "node:fs";
import { type TurboQuantScheme } from "./config";
import {
  GLM52_G5_ASPIRATIONAL_DECODE_TPS,
  GLM52_G5_DIRECT_ORACLE_WARM_DECODE_TPS,
  GLM52_G5_MEASURED_AT,
  GLM52_G5_MEASURED_WARM_DECODE_TPS,
} from "./model/glm52-memory";
import {
  type GenerateOptions,
} from "./generate";
import { createPreparationExecutor } from "./serve/preparation";
import { cloneKvCaches, legacyCacheCodecs, SpillQueue } from "./kv-store";
import type { Cache } from "./model/gemma4";
import { resolveKvScheme } from "./kv-scheme";
import { runtimeValue } from "./runtime-config";
import { TURBOQUANT_HEAD_DIMS } from "./mlx/turboquant-tables";
import type { HlgConfig } from "./sampler";
import { isMonotone, CURVE_UMIN, type CurveParams } from "./lab/curve/curve-sampler";
import { GenerationGateway, disposeUnstartedRequest } from "./serve/generation-gateway";
import { createSessionCompletionEngine } from "./serve/session-completion-engine";
import {
  CompletionExecutor,
} from "./serve/completion-executor";
import {
  createPromptResponseTrace,
  type PromptResponseTrace,
} from "./serve/prompt-response-trace";
import { handleAdminRoute } from "./serve/admin-routes";
import { handleAuxiliaryRoute } from "./serve/aux-routes";
import { createDiscoveryRoutes } from "./serve/discovery-routes";
import { handleLabRoute } from "./serve/lab-routes";
import { handleModelAdminRoute } from "./serve/model-admin-routes";
import { handleStaticRoute } from "./serve/static-routes";

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
  ResponseStore, chatJsonToResponses, resolveResponsesConversation,
  responsesToChatBody, createResponsesStreamProtocol,
  type ResponsesRequest,
} from "./responses";
import { fit } from "./fit";
import { setMemoryLimit } from "./mlx/ffi";
import { makePiWsHandler, type PiWsData } from "./pi-web";
import { ChatStage } from "./serve/chat-stage";
import { TextCompletionStage } from "./serve/text-completion-stage";
import { InferenceStage } from "./serve/inference-request";
import { admit, respondJson, respondStream, type ErrorFormatter } from "./serve/http";
import {
  chatCompletionJson, chatCompletionStream, textCompletionJson, textCompletionStream,
} from "./serve/openai-wire";
import { createRequestPrep } from "./serve/request-prep";
import {
  detectDraftKind,
  loadContext,
  type DraftKind,
  type GenSamplingDefaults,
  type LoadContextOptions,
  type ServerContext,
} from "./serve/model-host";
import {
  ChatRequest,
  TextCompletionRequest,
  type ChatRequestParams,
  type TextCompletionParams,
} from "./serve/chat-request";

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
  /** Periodically persist an in-flight serial generation every N emitted
   *  tokens. An identical request after restart replays the saved assistant
   *  prefix and continues from the already-sampled next token. Requires the
   *  SSD cache and --batch 1. */
  generationCheckpointTokens?: number;
}

interface ServerLifecycle {
  stopJobs: () => Promise<void>;
  close: () => Promise<void>;
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
    await lifecycle?.stopJobs();
    await stopped;
    const durability = lifecycle ? await lifecycle.flush() : emptyDurabilityResult();
    await lifecycle?.close();
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
  ctx: ServingContext, port = 0, serverOptions: ServerOptions = {},
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
  const serving = modelServingBinding(ctx);
  ctx = { ...ctx, serving };
  const batch = Math.max(1, Math.floor(serverOptions.batch ?? 8));
  if (serverOptions.generationCheckpointTokens !== undefined) {
    if (!Number.isInteger(serverOptions.generationCheckpointTokens) ||
        serverOptions.generationCheckpointTokens < 1)
      throw new Error("--generation-checkpoint expects a positive integer token interval");
    if (!serverOptions.ssdCacheDir)
      throw new Error("--generation-checkpoint requires --ssd-cache <dir>");
    if (batch !== 1)
      throw new Error("--generation-checkpoint requires --batch 1 (in-flight resume is serial-only)");
  }
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
  const stateCodecs = ctx.stateCodecs ?? legacyCacheCodecs;
  const cloneState = (caches: Cache[]) => cloneKvCaches(caches, stateCodecs);
  let ssdStore: SsdCacheStore | null = null;
  if (serverOptions.ssdCacheDir) {
    if (promptCacheCap <= 0)
      throw new Error("--ssd-cache requires the RAM prompt cache (--prompt-cache 0 disables it)");
    const schemeKey = resolvedKvScheme.cacheKey;
    const tokJson = readFileSync(`${ctx.model.config.modelDir}/tokenizer.json`);
    ssdStore = new SsdCacheStore({
      codecs: stateCodecs,
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
          const loaded = serving.restore(ssdStore!, handle as import("./ssd-cache").SsdIndexEntry);
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
    cloneState,
  );
  // Responses-API store for previous_response_id resumption (Phase 11):
  // TTL + byte-capped LRU, port of optiq/response_store.py. Pairs with
  // the prompt cache: a resumed conversation re-renders the same prefix,
  // so its KV prefill is already cached.
  const responseStore = new ResponseStore();

  const runGeneration = serving.createSerial({
    promptCache, checkpoints: ssdStore,
    checkpointEveryTokens: serverOptions.generationCheckpointTokens,
    identity: { artifact: ctx.profile.artifact, implementation: ctx.profile.profile.execution,
      stateAbi: "legacy-cache-array-v1", codecs: stateCodecs.id },
    adapterNamespace: (adapters) => ctx.adapters.cacheNamespace(adapters),
    cloneState,
  });

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
  const gateway = new GenerationGateway(serving.gateway, batch, runGeneration, {
    kvBudgetBytes: serverOptions.kvBudgetBytes,
    checkpoints: !!(serverOptions.generationCheckpointTokens && ssdStore),
    stateCodecs,
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
        cloneState,
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

  const sessionEngine = createSessionCompletionEngine(gateway, disposeUnstartedRequest);
  const completionExecutor = new CompletionExecutor(sessionEngine);

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

  // Per-request preparation (options/template/prompt-ids/grammar/router)
  // and the chat core, each built once with their collaborators injected.
  // The request pipeline, composed once:
  //   new ChatRequest(body) → chatStage.run → InferenceRequest
  //   → inferenceStage.admit → inferenceStage.run → InferenceResult → wire
  // (/v1/completions substitutes textStage; Anthropic and Responses reuse
  // chatStage with their own wire formats.)
  const prep = createRequestPrep({ ctx, serverOptions, kvScheme, defaultGeneratedTokens });
  const { templateOptionsFor } = prep;
  const preparation = createPreparationExecutor((work, signal) => gateway.runExclusive(work, undefined, signal), batch);
  const chatStage = new ChatStage(
    ctx, prep, promptCache, admission.maxSafeContext, serverOptions.defaultAdapter,
    preparation, serving.buildPrompt);
  const textStage = new TextCompletionStage(
    ctx, prep, admission.maxSafeContext, defaultGeneratedTokens, serverOptions.defaultAdapter);
  const inferenceStage = new InferenceStage(completionExecutor);
  const openAiMeta = (id: string) => ({ id, created: Math.floor(Date.now() / 1000), model: ctx.modelId });
  /** Parse the JSON body under the request's trace; a bad body is a 400. */
  const parseBody = async <T,>(request: Request, trace: PromptResponseTrace | undefined): Promise<T | Response> => {
    const closeBodyParse = trace?.begin("request.body_parse");
    try {
      return (await request.json()) as T;
    } catch {
      trace?.finish("error", { stage: "body_parse" });
      return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
    } finally {
      closeBodyParse?.();
    }
  };



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
          ...serving.diagnostics(),
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

      // A parent-managed GPU job holds this response open. The connection owns
      // the native lease, so parent death cannot strand the worker lock.
      if (serverOptions.unixSocket && url.pathname === "/admin/lease" && request.method === "POST") {
        await flushDurability();
        const lease = await gateway.acquireExecutionLease(request.signal);
        let released = false;
        const release = () => {
          if (released) return;
          released = true;
          request.signal.removeEventListener("abort", release);
          lease.dispose();
        };
        request.signal.addEventListener("abort", release, { once: true });
        if (request.signal.aborted) release();
        return new Response(new ReadableStream({
          start(controller) { controller.enqueue(new TextEncoder().encode("leased\n")); },
          cancel() { release(); },
        }), { headers: { "content-type": "application/octet-stream" } });
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
        let sids = ctx.tokenizer.encode(ctx.template.render([{ role: "user", content: typeof sbody.prompt === "string" ? sbody.prompt : "" }], templateOptionsFor({} as ChatRequestParams, null)));
        if (sids[0] === sids[1] && sids[0] === ctx.tokenizer.bosTokenId) sids = sids.slice(1);
        try {
          const NB = 80;
          // gateway.runExclusive: this raw forward must not run concurrently
          // with batched decode steps or a serial generation (GPU + shared
          // model state are single-owner — D3, one lock).
          const result = await gateway.runExclusive(() => serving.signal(sids, NB, CURVE_UMIN));
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
        let ids = ctx.tokenizer.encode(ctx.template.render([{ role: "user", content: prompt }], templateOptionsFor({} as ChatRequestParams, null)));
        if (ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId) ids = ids.slice(1);
        const samples: { text: string; junk: boolean }[] = [];
        try {
          for (let i = 0; i < n; i++) {
            const toks: number[] = [];
            const genOpts: GenerateOptions = useCurve
              ? { curve, seed: baseSeed + i, maxTokens, ...kvScheme }
              : { temperature: recipe.temperature, topP: recipe.topP, topK: recipe.topK, seed: baseSeed + i, maxTokens, ...kvScheme };
            // The same plan and execution lease cover the Lab comparison endpoint.
            const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
              hasLogitsExtras: false, wantsLogprobs: false, userSeed: true,
              kvQuant: !!(genOpts.kvBits || genOpts.kvConfig?.length), turboQuant: !!genOpts.turboQuant,
              hasGrammar: false, hasDraft: !!ctx.draft };
            const placement = gateway.place(shape, genOpts);
            await gateway.run(ids, genOpts, (t) => { toks.push(t); }, undefined,
              shape, placement, request.signal);
            const text = ctx.tokenizer.decode(toks, true).trim();
            samples.push({ text, junk: curveJunk(text) });
          }
        } catch (e) {
          return Response.json({ error: `generation failed: ${(e as Error).message}` }, { status: 500, headers: CURVE_CORS });
        }
        return Response.json({ mode: useCurve ? "curve" : "default", recipe: useCurve ? undefined : recipe, n, seed: baseSeed, samples }, { headers: CURVE_CORS });
      }

      if (url.pathname === "/v1/chat/completions" && request.method === "POST") {
        const id = `chatcmpl-${crypto.randomUUID()}`;
        const trace = createPromptResponseTrace({
          traceId: request.headers.get("x-mlx-bun-trace-id") ?? id,
          requestId: id,
          route: url.pathname,
        });
        const body = await parseBody<ChatRequestParams>(request, trace);
        if (body instanceof Response) return body;
        const meta = openAiMeta(id);
        const a = await admit(
          inferenceStage, () => chatStage.run(new ChatRequest(body), id, request.signal), trace, "chat request");
        if ("response" in a) return a.response;
        return body.stream
          ? respondStream(inferenceStage, a.admitted, chatCompletionStream(meta), request.signal, trace)
          : respondJson(inferenceStage, a.admitted, (r) => chatCompletionJson(r, meta), request.signal, trace);
      }

      // Raw text completion (mlx_lm.server's /v1/completions): no chat
      // template — TextCompletionStage tokenizes the prompt string directly.
      if (url.pathname === "/v1/completions" && request.method === "POST") {
        const id = `cmpl-${crypto.randomUUID()}`;
        const trace = createPromptResponseTrace({
          traceId: request.headers.get("x-mlx-bun-trace-id") ?? id,
          requestId: id,
          route: url.pathname,
        });
        const body = await parseBody<TextCompletionParams>(request, trace);
        if (body instanceof Response) return body;
        const meta = openAiMeta(id);
        const a = await admit(
          inferenceStage, () => textStage.run(new TextCompletionRequest(body), id), trace, "text completion");
        if ("response" in a) return a.response;
        return body.stream
          ? respondStream(inferenceStage, a.admitted, textCompletionStream(meta), request.signal, trace)
          : respondJson(inferenceStage, a.admitted, (r) => textCompletionJson(r, meta), request.signal, trace);
      }

      // Anthropic Messages API (Phase 11) — on by default, mirroring
      // optiq serve (--anthropic defaults True; the drop-in claim
      // depends on it). Oracle: optiq/anthropic_shim.py, ported in
      // src/anthropic.ts. Point Claude Code at this port via
      // ANTHROPIC_BASE_URL for a fully local backend.
      if (url.pathname === "/v1/messages" && request.method === "POST") {
        const anthropicError: ErrorFormatter = (status, message) =>
          Response.json(
            { type: "error", error: { type: status >= 500 ? "api_error" : "invalid_request_error", message } },
            { status },
          );
        let anthropicBody: AnthropicRequest;
        try {
          anthropicBody = (await request.json()) as AnthropicRequest;
        } catch {
          return anthropicError(400, "invalid JSON body", {});
        }
        let chatBody: ChatRequestParams;
        try {
          chatBody = anthropicToChatBody(anthropicBody) as unknown as ChatRequestParams;
        } catch (e) {
          return anthropicError(400, (e as Error).message, {});
        }
        const id = `chatcmpl-${crypto.randomUUID()}`;
        const a = await admit(
          inferenceStage, () => chatStage.run(new ChatRequest(chatBody), id, request.signal), undefined,
          "anthropic request", anthropicError);
        if ("response" in a) return a.response;
        if (anthropicBody.stream)
          return respondStream(
            inferenceStage, a.admitted, createAnthropicStreamProtocol(ctx.modelId), request.signal);
        return respondJson(
          inferenceStage, a.admitted,
          (r) => chatJsonToAnthropic(chatCompletionJson(r, openAiMeta(id)), ctx.modelId),
          request.signal, undefined, anthropicError);
      }

      // OpenAI Responses API (Phase 11) — Codex/Cursor/Continue speak
      // this now. Oracle: optiq/responses_shim.py + responses_server.py,
      // ported in src/responses.ts. previous_response_id resumes a prior
      // conversation from the in-process store (TTL + byte-capped LRU).
      if (url.pathname === "/v1/responses" && request.method === "POST") {
        const responsesError: ErrorFormatter = (status, message) =>
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
          return responsesError(400, "invalid JSON body", {});
        }

        let conversation: ReturnType<typeof resolveResponsesConversation>;
        try { conversation = resolveResponsesConversation(responsesBody, responseStore); }
        catch (error) { return responsesError(404, (error as Error).message, {}); }
        responsesBody = conversation.body;
        const prevId = conversation.previousId;
        const capturedInput = conversation.input;
        const capturedInstructions = conversation.instructions;
        const storeHere = !(serverOptions.unixSocket && request.headers.get("x-mlx-bun-response-owner") === "parent");
        const remember = (id: string, output: unknown[]) => {
          if (storeHere) responseStore.put(id, { input: capturedInput, output, instructions: capturedInstructions });
        };

        let chatBody: ChatRequestParams;
        try {
          chatBody = responsesToChatBody(responsesBody) as unknown as ChatRequestParams;
        } catch (e) {
          return responsesError(400, (e as Error).message, {});
        }
        const id = `chatcmpl-${crypto.randomUUID()}`;
        const a = await admit(
          inferenceStage, () => chatStage.run(new ChatRequest(chatBody), id, request.signal), undefined,
          "responses request", responsesError);
        if ("response" in a) return a.response;
        if (responsesBody.stream)
          return respondStream(
            inferenceStage, a.admitted,
            createResponsesStreamProtocol(
              ctx.modelId,
              prevId,
              (final) =>
                remember(final.id as string, final.output as unknown[]),
            ),
            request.signal);
        return respondJson(
          inferenceStage, a.admitted,
          (r) => {
            const responses = chatJsonToResponses(chatCompletionJson(r, openAiMeta(id)), ctx.modelId, prevId);
            remember(responses.id as string, responses.output as unknown[]);
            return responses;
          },
          request.signal, undefined, responsesError);
      }

      const labResponse = await handleLabRoute(url, request, {
        ensureJobs,
        acquireGpu: (signal) => gateway.acquireExecutionLease(signal),
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
    stopJobs: async () => {
      if (jobStore) {
        const jobs = await import("./jobs");
        await Promise.all([jobs.closeSubprocessJobs(jobStore), jobs.closeInProcessJobs(jobStore)]);
      }
    },
    close: async () => { preparation.close(); await sessionEngine.close(); await gateway.close(); },
    flush: flushDurability,
    stats: durabilityStats,
    stopTimers: () => {
      if (demoteTimer) clearInterval(demoteTimer);
      demoteTimer = null;
    },
  });
  return serverRef;
}
