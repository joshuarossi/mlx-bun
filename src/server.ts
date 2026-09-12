import { ContinuationPersistence } from "./backends/mlx/continuation-persistence";
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
import { cloneKvCaches, legacyCacheCodecs } from "./kv-store";
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

import { PromptCache } from "./prompt-cache";
import { TieredPromptCache } from "./tiered-prompt-cache";
import { SsdCacheStore } from "./ssd-cache";
import {
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
import { activeMemory, maxRecommendedWorkingSetSize, setMemoryLimit } from "./mlx/ffi";
import { makePiWsHandler, type PiWsData } from "./pi-web";
import { ChatStage } from "./serve/chat-stage";
import { TextCompletionStage } from "./serve/text-completion-stage";
import { InferenceStage } from "./serve/inference-request";
import { admit, respondJson, respondStream, type ErrorFormatter } from "./serve/http";
import {
  chatCompletionJson, chatCompletionStream, textCompletionJson, textCompletionStream,
} from "./serve/openai-wire";
import { createRequestPrep } from "./serve/request-prep";
import { GeneratedTokenHistory } from "./serve/generated-token-history";
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
   *  aggregate cap (an explicit memoryBudget also limits each request). */
  kvBudgetBytes?: number;
  /** KV quantization override. Unset/"off" is bf16. "config" applies the
   *  model's declared mixed-precision kv_config; supported per-layer schemes
   *  compose with continuous scheduling. A number forces uniform bits
   *  (group size 64, start 0) and uses the preserved serial executor. */
  kvQuant?: "off" | "config" | number;
  /** Optional absolute row offset for KV conversion; omitted preserves start-zero server policy. */
  quantizedKvStart?: number;
  /** TurboQuant scheme (docs/design/turboquant.md): a separate axis from
   *  kvQuant above, mutually exclusive with it (`--kv-quant turbo[:k<bits>v
   *  <bits>]` sets this instead of kvQuant). Solo-only in v1 — see
   *  GenerationGateway's explicit refusal. */
  turboQuant?: TurboQuantScheme;
  /** OPTIONAL paged KV cache (`--paged-kv`, docs/design/kv-cache.md):
   *  vLLM-style block-pool storage for full-attention layers,
   *  gather-to-contiguous before the stock SDPA. Default off (unset = the
   *  plain KVCache path, byte-identical). Gemma4-family, bf16, B1/B>1;
   *  startup refuses `--kv-quant`,
   *  turbo, and `--draft-model` combinations; paged requests bypass the
   *  prompt cache and run uncompiled. Gated bit-exact vs the plain path. */
  pagedKv?: { blockSize?: number };
  /** Explicit opt-in process budget. Enforces the fit estimate's context
   *  limit and sets the MLX allocator limit. Unset keeps estimates advisory. */
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
  /** Optional byte cap for the SSD tier (default unbounded). */
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

/** Resolve a completion cap against an explicitly enforced context limit.
 * Serving keeps fit estimates advisory unless the operator chooses a budget. */
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
  // unsupported explicit kv-quant) drain to the serial executor
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
    quantizedKvStart: serverOptions.quantizedKvStart,
    config: ctx.kvConfig,
  });
  const kvScheme = resolvedKvScheme.generationOptions;
  // The model execution plan qualifies the method while retaining KV policy.
  if (ctx.draft && (kvScheme.turboQuant || kvScheme.kvBits || kvScheme.kvConfig?.length))
    console.warn(
      `[spec] --draft-model with quantized KV (--kv-quant ${serverOptions.turboQuant ? "turbo" : String(serverOptions.kvQuant)}): ` +
        `requests keep the KV scheme; the model execution plan enables speculation ` +
        `only for a qualified combination. Check response usage for the active method. ` +
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
  // quietly (kv-quant: the swap would drop the scheme; speculative
  // provider composition with paged storage is not implemented).
  if (serverOptions.pagedKv) {
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
  // tokenizer hash (ids must keep meaning the same text). The model binding
  // also identifies the runtime numerics that produced the persisted state.
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
    if (typeof serving.stateCompatibility !== "string" || !serving.stateCompatibility.length)
      throw new Error("--ssd-cache requires the model binding's stateCompatibility identity");
    const schemeKey = resolvedKvScheme.cacheKey;
    const stateKey = Bun.hash(serving.stateCompatibility).toString(16);
    const tokJson = readFileSync(`${ctx.model.config.modelDir}/tokenizer.json`);
    ssdStore = new SsdCacheStore({
      codecs: stateCodecs,
      dir: serverOptions.ssdCacheDir,
      maxBytes: serverOptions.ssdCacheMaxBytes ?? Number.POSITIVE_INFINITY,
      configFingerprint: `${configFingerprint(ctx.model.config)}-${schemeKey}-${stateKey}`,
      tokenizerHash: Bun.hash(tokJson).toString(16),
      modelId: ctx.modelId,
      verify: serverOptions.ssdCacheVerify,
    });
    const recovered = ssdStore.scan();
    const capacity = Number.isFinite(ssdStore.maxBytes)
      ? `${(ssdStore.maxBytes / 2 ** 30).toFixed(0)} GiB cap`
      : "unlimited";
    console.log(
      `[ssd-cache] ${serverOptions.ssdCacheDir} — ${recovered} entr${recovered === 1 ? "y" : "ies"} recovered, ` +
      `${(ssdStore.totalBytes / 2 ** 30).toFixed(2)} GiB, ${capacity}`,
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
          return { tokens: loaded.tokens, caches: loaded.caches, attachments: loaded.attachments, retain: () => {} };
        },
        store: (tokens: number[], caches: import("./model/gemma4").Cache[], ns: string,
          attachments?: import("./backends/mlx/checkpoint-state").CheckpointAttachment[]) => {
          if (ssdStore!.hasDurablePrefix(tokens, ns)) return true;
          return ssdStore!.store(tokens, caches, ns, attachments);
        },
      }
    : null;
  const promptCache = ssdStore && coldTier
    ? new TieredPromptCache(promptCacheCap, ssdStore, coldTier, cloneState,
        runtimeValue("MLX_BUN_SSD_WRITEBEHIND") !== "0")
    : new PromptCache(promptCacheCap, null, null, cloneState);
  const spillQueue = promptCache instanceof TieredPromptCache ? promptCache.spillQueue : null;
  const durability = promptCache instanceof TieredPromptCache ? promptCache.durability : null;
  // Responses-API store for previous_response_id resumption (Phase 11):
  // TTL + byte-capped LRU, port of optiq/response_store.py. Pairs with
  // the prompt cache: a resumed conversation re-renders the same prefix,
  // so its KV prefill is already cached.
  const responseStore = new ResponseStore();

  // Memory estimates remain available in diagnostics. Only an explicit
  // operator budget or context cap constrains request planning.
  const memoryAdmission = ctx.glmMemoryPlan ?? fit(
    ctx.model.config, ctx.model.weightsBytes, 1,
    undefined, undefined, 0, serverOptions.memoryBudgetBytes,
    resolvedKvScheme.fitOptions,
  );
  const profileContext = runtimeValue("MLX_BUN_RD_CONTEXT_LIMIT");
  const profileLimit = profileContext === undefined ? null : Number(profileContext);
  if (profileLimit !== null && (!Number.isSafeInteger(profileLimit) || profileLimit < 1))
    throw new Error("MLX_BUN_RD_CONTEXT_LIMIT must be a positive integer");
  const budgetLimit = serverOptions.memoryBudgetBytes !== undefined
    ? memoryAdmission.maxSafeContext : ctx.glmMemoryPlan?.contextTokens ?? null;
  const contextLimit = profileLimit === null ? budgetLimit
    : Math.min(profileLimit, budgetLimit ?? Infinity);
  const admission = memoryAdmission;
  const allocatorLimit =
    admission.allocatorLimitBytes ?? serverOptions.memoryBudgetBytes;
  if (allocatorLimit) setMemoryLimit(allocatorLimit);

  let checkpointPersistence: ContinuationPersistence | undefined;
  const executionServices: import("./backends/mlx/serial-executor").MlxSerialServices = {
    get checkpointPersistence() { return checkpointPersistence; },
    promptCache, checkpoints: ssdStore,
    checkpointEveryTokens: serverOptions.generationCheckpointTokens,
    identity: { artifact: ctx.profile.artifact, implementation: ctx.profile.profile.execution,
      stateAbi: "legacy-cache-array-v1", codecs: stateCodecs.id },
    adapterNamespace: (adapters) => ctx.adapters.cacheNamespace(adapters),
    cloneState,
  };
  serving.gateway.configureContinuation?.(executionServices);
  const runGeneration = serving.createSerial(executionServices);

  // Cache policy owns RAM residency and SSD persistence independently of
  // request scheduling. Published state is immutable.
  const gateway = new GenerationGateway(serving.gateway, batch, runGeneration, {
    kvBudgetBytes: serverOptions.kvBudgetBytes,
    checkpoints: !!(serverOptions.generationCheckpointTokens && ssdStore),
    stateCodecs,
    kvScheme: resolvedKvScheme,
    promptCache,
    adapterNamespace: (adapters) => ctx.adapters.cacheNamespace(adapters),
  });
  const spillQueueGbRaw = Number(runtimeValue("MLX_BUN_SSD_SPILL_QUEUE_GB"));
  const spillQueueCapBytes =
    (Number.isFinite(spillQueueGbRaw) && spillQueueGbRaw >= 0 ? spillQueueGbRaw : 2) * 1024 ** 3;
  if (ssdStore && serverOptions.generationCheckpointTokens)
    checkpointPersistence = new ContinuationPersistence(ssdStore, {
      maxBytes: spillQueueCapBytes,
    });
  // Keep allocator headroom for the next forward. Only optional cache
  // snapshots are reclaimed; context, batch size and sampling stay intact.
  // Do not count MLX's reusable pool as live state or await an SSD write.
  const cacheWorkingSet = Math.min(maxRecommendedWorkingSetSize(), allocatorLimit ?? Infinity);
  const cacheOverBudget = () => Math.max(activeMemory(),
    ctx.model.weightsBytes + Math.max(promptCache.totalBytes, spillQueue?.pendingBytes ?? 0)) > cacheWorkingSet * 0.85;
  promptCache.pressure = {
    // File-backed weights may not yet appear in MLX's active allocations
    // before the first forward. Account for their known footprint as well.
    overBudget: cacheOverBudget,
  };
  const durabilityStats = (): DurabilitySnapshotStats => {
    const stats = durability?.stats ?? {
      pendingSnapshots: 0,
      pendingSpills: spillQueue?.pendingCount ?? 0,
      pendingSpillBytes: spillQueue?.pendingBytes ?? 0,
      droppedSpills: spillQueue?.droppedCount ?? 0,
      failedSpills: spillQueue?.failedCount ?? 0,
    };
    const checkpoints = checkpointPersistence?.stats;
    return { ...stats, pendingSpills: stats.pendingSpills + (checkpoints?.pendingCount ?? 0),
      pendingSpillBytes: stats.pendingSpillBytes + (checkpoints?.pendingBytes ?? 0),
      droppedSpills: stats.droppedSpills + (checkpoints?.dropped ?? 0),
      failedSpills: stats.failedSpills + (checkpoints?.failed ?? 0) };
  };
  const flushDurability = async (): Promise<DurabilityFlushResult> => {
    const started = performance.now();
    const checkpoints = await checkpointPersistence?.flush();
    const result = durability ? await durability.flush() : null;
    if (!result) await spillQueue?.drain();
    const stats = durabilityStats();
    return {
      ...stats,
      durable: (result?.durable ?? stats.pendingSpills === 0) && (checkpoints?.durable ?? true) && stats.pendingSpills === 0,
      flushedSnapshots: result?.flushedSnapshots ?? 0,
      missingSnapshots: result?.missingSnapshots ?? 0,
      elapsedMs: performance.now() - started,
    };
  };
  // Remember exact generated IDs independently of cache persistence.
  const tokenHistory = new GeneratedTokenHistory(ctx.tokenizer);
  if (ssdStore) for (const tokens of ssdStore.tokenPrefixes()) tokenHistory.remember(tokens);
  promptCache.onPut = (tokens) => {
    tokenHistory.remember(tokens);
  };

  // Cache age, not scheduler activity, decides idle demotion. The cache
  // queues any missing SSD copy and retains RAM until that copy commits.
  const demoteIdleMs = (serverOptions.ssdDemoteIdleSec ?? (ssdStore ? 300 : 0)) * 1000;
  let demoteTimer: ReturnType<typeof setInterval> | null = null;
  if (ssdStore && demoteIdleMs > 0) {
    demoteTimer = setInterval(() => {
      const n = promptCache.demoteIdle(demoteIdleMs);
      if (n > 0) console.log(`[ssd-cache] demoted ${n} idle entr${n === 1 ? "y" : "ies"} to disk`);
    }, Math.max(30_000, demoteIdleMs / 4));
    demoteTimer.unref?.();
  }

  const sessionEngine = createSessionCompletionEngine(gateway, disposeUnstartedRequest);
  const completionExecutor = new CompletionExecutor(sessionEngine);

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
  const prep = createRequestPrep({ ctx, serverOptions, kvScheme, defaultGeneratedTokens, tokenHistory });
  const { templateOptionsFor } = prep;
  const preparation = createPreparationExecutor((work, signal) => gateway.runExclusive(work, undefined, signal), batch);
  const chatStage = new ChatStage(
    ctx, prep, promptCache, contextLimit, serverOptions.defaultAdapter,
    preparation, serving.buildPrompt);
  const textStage = new TextCompletionStage(
    ctx, prep, contextLimit, defaultGeneratedTokens, serverOptions.defaultAdapter);
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
              max_bytes: Number.isFinite(ssdStore.maxBytes) ? ssdStore.maxBytes : null,
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
            enforced_context_tokens: contextLimit,
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
