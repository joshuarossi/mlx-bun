// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - sampling stays on-device; only the chosen token id crosses to JS

import { MlxArray, gpuStream } from "./mlx/array";
import {
  activeMemory,
  clearCache,
  maxRecommendedWorkingSetSize,
  peakMemory,
  setWiredLimit,
  synchronize,
} from "./mlx/ffi";
import * as ops from "./mlx/ops";
import { CompiledDecode } from "./model/compiled-decode";
import { Gemma4Model, KVCache, RotatingKVCache, TurboQuantKVCache, type Cache } from "./model/gemma4";
import { PagedKVCache } from "./model/paged-kv";
import { DiffusionGemmaModel } from "./model/diffusion-gemma";
import { diffusionGenerate } from "./diffusion/diffusion-generate";
import type { RuntimeModel } from "./model/factory";
import type { PromptResponseTrace } from "./serve/prompt-response-trace";
import type { KvQuantSpec, TurboQuantScheme } from "./config";
import { flagOn } from "./flags";
import { runtimeValue } from "./runtime-config";
import {
  disposeStepExtras,
  makeStepSampler,
  stepExtrasArrays,
  type LogitsProcessorOptions,
  type SamplerOptions,
  type StepExtras,
} from "./sampler";
import type { GrammarController } from "./grammar";

export interface GenerateOptions extends SamplerOptions, LogitsProcessorOptions {
  maxTokens?: number;
  eosTokenIds?: number[];
  prefillChunkSize?: number;
  /** Fired once during prefill, at `snapshotAt` tokens (default: the full
   *  prompt) and BEFORE any further KV is written — the one moment the
   *  caches hold exactly that prefix (post-wrap rings can't be rewound
   *  later). The server's prompt-boundary cache snapshot hangs here. */
  onPrefillDone?: () => void;
  /** Token count at which onPrefillDone fires (the STABLE cache boundary —
   *  chat prompts end in a generation primer, e.g. 12B's thought-channel
   *  tokens, that the NEXT turn's re-render does not contain; snapshotting
   *  there would make the entry untrimmable-and-divergent). Prefill is
   *  split at this index when it falls mid-prompt. */
  snapshotAt?: number;
  /** Pre-warmed KV caches (e.g. from the prompt cache). cache[0].offset
   *  prompt tokens are treated as already prefilled; only the suffix is
   *  forwarded. Caller keeps ownership — generate() will not dispose. */
  cache?: Cache[];
  /** Vision path: pre-merged (unscaled) input embeddings [1, L, hidden]
   *  covering the whole prompt; prefilled in one shot (no chunking).
   *  Caller keeps ownership. */
  promptEmbeddings?: MlxArray;
  /** bool [L] marking image tokens (bidirectional attention among them).
   *  MUST be unset when the prompt contains any audio — audio prompts run
   *  fully causal (audio-input-plan.md §3.3 Q1). */
  imageMask?: MlxArray;
  /** bool [L] marking ALL multimodal soft tokens (image | audio) for
   *  per-layer-input id zeroing (e2b/e4b), decoupled from imageMask so
   *  audio-only prompts (no bidirectional mask) still zero their positions.
   *  When unset, zeroing falls back to imageMask (the legacy vision shape).
   *  Caller keeps ownership. */
  multimodalMask?: MlxArray;
  /** Quantize full-attention KV caches to this many bits (4 or 8).
   *  Rotating (sliding-window) caches stay bf16 — they're window-capped
   *  and upstream rotating-cache quantization is NYI. */
  kvBits?: number;
  kvGroupSize?: number;
  /** Per-layer mixed-precision KV from kv_config.json (config.kvQuant).
   *  Overrides kvBits, like optiq serve's --kv-config. layerIdx indexes
   *  the cache list (== layer index for the donor prefix); entries for
   *  rotating/sliding caches are skipped until Phase 9. */
  kvConfig?: KvQuantSpec[];
  /** Convert once a cache's offset reaches this (uniform-kvBits default
   *  5000 = mlx-lm; kvConfig default 0 = optiq serve). */
  quantizedKvStart?: number;
  /** TurboQuant scheme (docs/design/turboquant-kv.md): rotation-based KV
   *  quantization, a CLI-only runtime lever in the same class as uniform
   *  kvBits (mutually exclusive with kvBits/kvConfig — maybeQuantizeKv
   *  checks kvBits/kvConfig first, so set at most one). Full-attention
   *  KVCache layers convert via TurboQuantKVCache.fromKVCache;
   *  RotatingKVCache (sliding-window) layers stay bf16 in v1 — a one-time
   *  warning names the limitation, never a throw. */
  turboQuant?: TurboQuantScheme;
  /** OPTIONAL paged KV storage (docs/design/paged-kv-cache.md): fresh
   *  full-attention KVCache layers are replaced with PagedKVCache (block
   *  pool + gather-to-contiguous) before prefill. v1 scope: serial batch=1
   *  Gemma4-family, bf16 — mutually exclusive with kvBits/kvConfig/
   *  turboQuant/draft/compiled decode (callers refuse the combos; the
   *  cache swap itself only ever touches plain empty KVCache entries).
   *  Values are gated bit-exact vs the plain path (tests/paged-kv*). */
  pagedKv?: { blockSize?: number };
  /** Mounted LoRA adapter ids to apply (resolved/validated by
   *  AdapterManager.resolveSpec). Residuals sum in order. Set on the
   *  model's LoraState for exactly the duration of this generation —
   *  a plain field, safe because the generation queue is serialized. */
  adapters?: string[];
  /** DiffusionGemma image-text-to-text: channel-first pixel_values [1,3,H,W].
   *  When set, `promptTokens` are the spliced (<|image|>-expanded) ids and the
   *  denoising engine prefills the merged vision features. Caller keeps ownership. */
  visionPixels?: MlxArray;
  /** Capture each emitted token's log-probability (mlx_lm.server `logprobs`).
   *  The distribution matches mlx-lm generate_step exactly: full-vocab
   *  log-softmax of the logits AFTER logits processors, BEFORE the sampler's
   *  temperature/top-p/top-k/min-p/XTC (generate.py L409-422). Off by default —
   *  the hot path pays nothing when unset. */
  logprobs?: boolean;
  /** Capture the top-k (token id, logprob) pairs per emitted token from the
   *  same distribution (mlx_lm.server `top_logprobs`). 0/unset = off. */
  topLogprobs?: number;
  /** Grammar-constrained decoding (src/grammar.ts): a compiled GrammarController
   *  that masks invalid tokens to -inf each step. L2-class (oMLX oracle). When
   *  set, the decode loop takes a slightly different shape: it eager-reads the
   *  token id (acceptToken needs a JS number, which the pipelined loop defers),
   *  advances the matcher, and awaits the async mask precompute (which overlaps
   *  the GPU forward). Non-grammar requests keep the fast pipelined loop. */
  grammar?: GrammarController;
}

export function shouldUseGrammarJump(
  options: Pick<GenerateOptions, "grammar" | "logprobs" | "topLogprobs">,
): boolean {
  return options.grammar !== undefined &&
    flagOn("MLX_BUN_GRAMMAR_JUMP", false) &&
    !options.logprobs &&
    !(options.topLogprobs && options.topLogprobs > 0);
}

/** Per-token logprob info (only present when GenerateOptions requested it). */
export interface TokenLogprobs {
  /** logprob of the emitted token (requires options.logprobs). */
  logprob?: number;
  /** top-k (id, logprob) pairs, sorted by logprob descending (requires
   *  options.topLogprobs > 0). mlx-lm leaves argpartition order unspecified;
   *  sorting is the deterministic reading of the same set. */
  top?: { id: number; logprob: number }[];
}

/** Materialize every cache's state at a prefill chunk boundary. Unlike
 *  KVCache/QuantizedKVCache/RotatingKVCache, TurboQuantKVCache.state()
 *  allocates FRESH trimmed slice views on every call (required by its
 *  snapshotCache/cloneKvCaches callers in kv-store.ts, which already
 *  dispose them) rather than returning its own live-owned arrays — so
 *  this chokepoint must dispose that cache kind's state() output itself,
 *  or the views leak (unreferenced past this call, only reclaimed by the
 *  FinalizationRegistry backstop on GC of the tiny JS wrapper). */
export function evalCacheState(cache: Cache[]): void {
  const turboState = cache.flatMap((c) => (c instanceof TurboQuantKVCache ? c.state() : []));
  try {
    const liveState = cache.flatMap((c) => (c instanceof TurboQuantKVCache ? [] : c.state()));
    ops.evalAll([...turboState, ...liveState]);
  } finally {
    // Disposed even when evalAll throws (Metal OOM / deferred graph error) —
    // the whole reason this chokepoint exists is that these views are owned.
    for (const a of turboState) a.dispose();
  }
}

/** Port of mlx-lm maybe_quantize_kv_cache + BOTH halves of optiq serve's
 *  per-layer patched variant (incl. patch_rotating_to_quantized: rotating
 *  caches convert too — Phase 9):
 *  - per-layer bits/group_size selection (kvConfig overrides kvBits,
 *    matching optiq's --kv-config precedence; shipped kv_config.json
 *    files cover EVERY cache-owning layer, sliding ones included —
 *    verified 12B 48/48, 26B 30/30, e4b 24/24 distinct caches — so
 *    rotating quantization engages straight from the config; uniform
 *    kvBits — like optiq --kv-bits — reaches them too), and
 *  - STREAMING conversion (optiq streaming_kv_quant / serve.py
 *    patched_maybe_quantize): eval each layer's quantized triples and
 *    clear the buffer pool before building the next layer's conversion.
 *    Lazily batching every layer's toQuantized into one eval pins ALL
 *    layers' bf16 K/V as graph inputs alongside ALL quantized outputs —
 *    the exact transient optiq's fix kills (16.35 → 7.60 GB at 32k on a
 *    24 GB Mac). Numerics untouched: same quantize math, only the eval
 *    ordering is forced (tests/kv-quant.test.ts, tests/rotating-kvq.test.ts). */
export function maybeQuantizeKv(cache: Cache[], options: GenerateOptions): void {
  const { kvBits, kvConfig, turboQuant } = options;
  if (turboQuant) {
    maybeTurboQuantizeKv(cache, turboQuant, options.quantizedKvStart ?? 0);
    return;
  }
  if (!kvBits && !kvConfig?.length) return;
  const start = options.quantizedKvStart ?? (kvConfig?.length ? 0 : 5000);
  const byLayer = kvConfig?.length
    ? new Map(kvConfig.map((e) => [e.layerIdx, e]))
    : null;
  for (let i = 0; i < cache.length; i++) {
    const c = cache[i]!;
    if (!(c instanceof KVCache || c instanceof RotatingKVCache) || c.offset < start) continue;
    // OptiQ's mixed-KV hook skips empty caches: the first prompt prefill
    // runs bf16, then the populated cache is quantized before decode.
    // Converting empty caches at start=0 makes prefill itself quantized
    // and diverges from the oracle path.
    if (c.offset === 0) continue;
    if (byLayer) {
      const e = byLayer.get(i);
      if (!e) continue;
      cache[i] = c.toQuantized(e.groupSize, e.bits);
    } else {
      cache[i] = c.toQuantized(options.kvGroupSize ?? 64, kvBits!);
    }
    // Streaming half: materialize THIS layer's conversion now so its bf16
    // source (already released by toQuantized) frees before the next layer
    // converts — the transient stays ~one layer, not the whole cache.
    ops.evalAll(cache[i]!.state());
    clearCache();
  }
}

/** Paged-KV conversion (docs/design/paged-kv-cache.md): swap each FRESH
 *  plain full-attention KVCache for a PagedKVCache sized to hold
 *  `capacityTokens` (prompt + maxTokens — known exactly at generate()
 *  setup, so pool exhaustion is unreachable absent an accounting bug).
 *  Same in-place-mutation shape as maybeQuantizeKv, but runs ONCE before
 *  prefill: paging changes storage layout, not arithmetic, so there is no
 *  "convert when populated" trigger. Sliding-window (RotatingKVCache)
 *  layers keep today's scheme — mixed paged-full + rotating-sliding is
 *  the supported v1 shape. Pre-warmed caches (offset > 0) skip conversion
 *  entirely: the serve lane bypasses prompt-cache reuse for paged
 *  requests, so this only guards library callers. */
export function maybePageKv(
  cache: Cache[], options: GenerateOptions, capacityTokens: number,
): void {
  if (!options.pagedKv) return;
  if (cache.some((c) => c.offset > 0)) return;
  const blockSize = options.pagedKv.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE;
  for (let i = 0; i < cache.length; i++) {
    if (cache[i] instanceof KVCache) {
      cache[i]!.dispose(); // fresh (offset 0) — nothing stored yet
      cache[i] = new PagedKVCache(capacityTokens, blockSize);
    }
  }
}

/** Emitted once per process: RotatingKVCache (sliding-window) layers are a
 *  documented v1 non-goal (docs/design/turboquant-kv.md) — they stay bf16
 *  rather than throwing, so mixed full-attention/sliding-window models (e.g.
 *  Gemma) still serve correctly under --kv-quant turbo. */
let warnedTurboRotating = false;

/** TurboQuant conversion chokepoint (mirrors the uniform/config branch
 *  above): only plain full-attention KVCache instances convert, via
 *  TurboQuantKVCache.fromKVCache — RotatingKVCache stays bf16 (warn once,
 *  never throw). Same offset===0 skip-empty-cache rule as the affine path. */
function maybeTurboQuantizeKv(cache: Cache[], scheme: TurboQuantScheme, start: number): void {
  for (let i = 0; i < cache.length; i++) {
    const c = cache[i]!;
    if (c instanceof RotatingKVCache) {
      if (!warnedTurboRotating) {
        warnedTurboRotating = true;
        console.warn(
          "[turbo-quant] sliding-window (RotatingKVCache) layers stay bf16 in v1 " +
          "(full-attention only) — docs/design/turboquant-kv.md.",
        );
      }
      continue;
    }
    if (!(c instanceof KVCache) || c.offset < start || c.offset === 0) continue;
    const tq = TurboQuantKVCache.fromKVCache(c, scheme.kBits, scheme.vBits);
    cache[i] = tq;
    // state() allocates fresh trimmed slice views for this cache kind
    // (see evalCacheState) — dispose after materializing (throw included),
    // or they leak.
    const state = tq.state();
    try {
      ops.evalAll(state);
    } finally {
      for (const a of state) a.dispose();
    }
    clearCache();
  }
}

export interface GenerateStats {
  promptTokens: number;
  /** Prompt tokens skipped via a pre-warmed cache. */
  cachedTokens: number;
  generatedTokens: number;
  prefillTps: number;
  decodeTps: number;
  prefillMs: number;
  decodeMs: number;
  /** Exact token sequence whose KV now lives in the cache (prompt + every
   *  decoded token that was forwarded, including a trailing EOS the
   *  pipeline forwarded before reading it). For PromptCache.put(). */
  cacheTokens: number[];
  /** Speculative-decoding telemetry (serve --draft-model path only).
   *  draftedByPos/acceptedByPos: per-draft-position round counts (index =
   *  position within a round's block) — the Phase-1c per-position
   *  acceptance signal. */
  spec?: {
    drafted: number; accepted: number; targetCalls: number;
    draftedByPos?: number[]; acceptedByPos?: number[];
    rejected?: number; rounds?: number; acceptanceLengths?: number[];
    tokensPerForward?: number; forwardsSaved?: number;
  };
}

export interface GenerateDiagnostics {
  trace?: PromptResponseTrace;
  mechanism?: "serial" | "continuous";
}

export interface GeneratedToken {
  token: number;
  index: number;
  /** Present only when GenerateOptions.logprobs / topLogprobs requested it. */
  logprobs?: TokenLogprobs;
}

export class Generation implements AsyncIterable<GeneratedToken> {
  stats: GenerateStats | null = null;
  readonly #iter: AsyncGenerator<GeneratedToken, GenerateStats>;

  constructor(iter: AsyncGenerator<GeneratedToken, GenerateStats>) {
    this.#iter = iter;
  }

  async *[Symbol.asyncIterator](): AsyncGenerator<GeneratedToken> {
    try {
      while (true) {
        const r = await this.#iter.next();
        if (r.done) {
          this.stats = r.value;
          return;
        }
        yield r.value;
      }
    } finally {
      // Consumer broke early (e.g. a decoded-text stop sequence fired):
      // drive the inner generator's shutdown so its finallys run (array
      // disposal, wired/adapter scopes) and capture the stats its
      // early-return path still reports.
      if (this.stats === null) {
        const r = await this.#iter.return(undefined as unknown as GenerateStats);
        if (r.done && r.value) this.stats = r.value;
      }
    }
  }
}

// Scoped wired limit, raised only for near-ceiling models. mlx-lm's
// wired_limit context wires unconditionally per generation; we deviate
// with a measured justification (PLAN Phase 6 verification findings):
// - 26B-A4B (16.4 GB = 92% of the 17.8 GiB working set) NEEDS wiring —
//   8.6 tok/s without, 32.3 with (Metal evicts weight buffers per token).
// - 12B/e4b (≤47%) hit reference parity WITHOUT wiring, and wiring in a
//   multi-model process (the test suite) pins memory the OTHER resident
//   models need — async GPU exec OOM, which is uncatchable (the mlx
//   completion-handler throw terminates the process).
// Scope semantics match the reference: set → generate → synchronize →
// restore; nothing stays pinned between generations. Re-entrant: only
// the outermost wiring scope touches the limit.
// macOS 26.6 reports a 24.96 GiB recommended set on this 24 GB machine.
// The old 0.75 fraction therefore stopped wiring the 13-16 GiB Qwen/GLM
// models even though they page heavily without an explicit wired limit.
// Keep smaller 8-9 GiB models unwired while covering the large-model class.
const WIRE_THRESHOLD = 0.5;
let wiredScopeDepth = 0;
let wiredOldLimit = 0;

type WiredModelMemory = {
  readonly weightsBytes: number;
  readonly expertRuntime?: {
    readonly plan: { readonly plannedBytes: number };
    flushUsage?: () => void;
    finishUsage?: () => Promise<void>;
  } | null;
};

/** Bytes whose MLX graph must stay resident while a model executes. */
export function wiredWorkingSetBytes(model: WiredModelMemory): number {
  const planned = model.expertRuntime?.plan.plannedBytes;
  return typeof planned === "number" && Number.isFinite(planned) && planned > 0
    ? Math.max(model.weightsBytes, planned)
    : model.weightsBytes;
}

export function modelNeedsWiredLimit(
  model: WiredModelMemory,
  recommendedBytes = maxRecommendedWorkingSetSize(),
  force = runtimeValue("MLX_BUN_FORCE_WIRE") === "1",
): boolean {
  return force ||
    wiredWorkingSetBytes(model) > WIRE_THRESHOLD * recommendedBytes;
}

function enterWiredScope(): void {
  if (wiredScopeDepth++ === 0)
    wiredOldLimit = setWiredLimit(maxRecommendedWorkingSetSize());
}
function exitWiredScope(): void {
  if (--wiredScopeDepth === 0) {
    synchronize(gpuStream);
    setWiredLimit(wiredOldLimit);
  }
}

/** Hold the process wired limit while one model owns GPU execution. */
export function acquireModelWiredLimit(model: WiredModelMemory): () => void {
  if (!modelNeedsWiredLimit(model)) return () => {};
  enterWiredScope();
  let released = false;
  return () => {
    if (released) return;
    released = true;
    exitWiredScope();
  };
}

export function generate(
  model: RuntimeModel,
  promptTokens: number[],
  options: GenerateOptions = {},
  diagnostics: GenerateDiagnostics = {},
): Generation {
  // DiffusionGemma is non-autoregressive: route to the denoising engine instead
  // of the AR decode loop. Same Generation/GenerateStats contract so the CLI and
  // server stream it through the existing token machinery.
  let inner =
    model instanceof DiffusionGemmaModel
      ? generateDiffusionInner(model, promptTokens, options)
      : generateInner(model, promptTokens, options, diagnostics);
  if (options.adapters?.length) inner = adapterScoped(model, options.adapters, inner);
  const memoryModel: WiredModelMemory = model;
  if (memoryModel.expertRuntime?.flushUsage)
    inner = usageScoped(memoryModel, inner);
  const wire = modelNeedsWiredLimit(model);
  return new Generation(wire ? wiredScoped(inner) : inner);
}

/** Non-autoregressive diffusion generation, adapted to the AR Generation
 *  contract. Runs the denoising engine (its own prefill + canvas loop) and
 *  streams the emitted tokens. v1: greedy (temperature 0, confidence-threshold
 *  sampler — the OptiQ default); per-block intra-stream + temperature>0
 *  (categorical) are follow-ups. */
async function* generateDiffusionInner(
  model: DiffusionGemmaModel,
  promptTokens: number[],
  options: GenerateOptions,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  const t0 = performance.now();
  const maxTokens = options.maxTokens ?? 256;
  // A fresh random canvas seed per request unless the caller pins one.
  const seed =
    options.seed !== undefined
      ? BigInt(options.seed)
      : BigInt(Math.floor(Math.random() * 0x7fffffff));
  // The shipped checkpoint's tokenizer stops on {1, 106}; union any caller eos.
  const eos = [...new Set([1, 106, ...(options.eosTokenIds ?? [])])];
  const result = diffusionGenerate(model, promptTokens, {
    maxTokens,
    sampler: "confidence-threshold",
    temperature: 0,
    eosTokenIds: eos,
    seed,
    visionPixels: options.visionPixels,
  });
  const decodeMs = performance.now() - t0;
  let index = 0;
  for (const token of result.tokens) yield { token, index: index++ };
  return {
    promptTokens: promptTokens.length,
    cachedTokens: 0,
    generatedTokens: result.tokens.length,
    prefillTps: 0,
    decodeTps: result.tokens.length / Math.max(decodeMs / 1000, 1e-9),
    prefillMs: 0,
    decodeMs,
    cacheTokens: [],
  };
}

/** Hold the model's active-adapter list for exactly this generation. */
async function* adapterScoped(
  model: RuntimeModel,
  adapters: string[],
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  model.loraState.active = adapters;
  try {
    return yield* inner;
  } finally {
    model.loraState.active = [];
  }
}

/** Wrap the generator so the wired limit is held exactly while it runs
 *  (incl. early break/return/throw — finally fires on .return()). */
async function* wiredScoped(
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  enterWiredScope();
  try {
    return yield* inner;
  } finally {
    exitWiredScope();
  }
}

/** Publish the streamed model's route ledger on every generator exit path. */
async function* usageScoped(
  model: WiredModelMemory,
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  try {
    return yield* inner;
  } finally {
    if (model.expertRuntime?.finishUsage)
      await model.expertRuntime.finishUsage();
    else
      model.expertRuntime?.flushUsage?.();
  }
}

/** Apply generate()'s scoped wiring policy to non-generator execution paths. */
export async function withModelWiredLimit<T>(
  model: WiredModelMemory,
  run: () => Promise<T>,
): Promise<T> {
  const release = acquireModelWiredLimit(model);
  try {
    return await run();
  } finally {
    release();
  }
}

/** Apply generate()'s usage safe-point to direct/non-generator paths. */
export async function withModelUsageFlush<T>(
  model: WiredModelMemory,
  run: () => Promise<T>,
): Promise<T> {
  try {
    return await run();
  } finally {
    if (model.expertRuntime?.finishUsage)
      await model.expertRuntime.finishUsage();
    else
      model.expertRuntime?.flushUsage?.();
  }
}

/** Forward through either the ordinary synchronous model surface or a
 * streamed-expert model whose layer execution must cross async I/O. Keeping
 * this choice inside the shared generator preserves the complete generation
 * contract (sampling, grammar, logprobs, prompt cache, and cancellation) for
 * both execution styles. */
async function forwardHiddenForGeneration(
  model: RuntimeModel,
  ids: MlxArray,
  cache: Cache[],
): Promise<MlxArray> {
  const asyncModel = model as RuntimeModel & {
    forwardHiddenAsync?: (ids: MlxArray, cache: Cache[]) => Promise<MlxArray>;
  };
  return typeof asyncModel.forwardHiddenAsync === "function"
    ? await asyncModel.forwardHiddenAsync(ids, cache)
    : model.forwardHidden(ids, cache);
}

async function* generateInner(
  model: RuntimeModel,
  promptTokens: number[],
  options: GenerateOptions,
  diagnostics: GenerateDiagnostics,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  const {
    maxTokens = 512,
    eosTokenIds = model.config.eosTokenIds,
    prefillChunkSize = 2048,
  } = options;

  // logprobs capture (mlx_lm.server semantics — see GenerateOptions.logprobs).
  // Everything below is gated: when neither flag is set, no extra ops, evals,
  // or readbacks happen on the hot path.
  const captureSelLp = options.logprobs === true;
  const captureTopK =
    options.topLogprobs && options.topLogprobs > 0 ? options.topLogprobs : 0;
  const stepSampler = makeStepSampler(options, {
    tokenRepresentation: "device",
    grammarWait: "external",
    historyUpdate: "manual",
    captureSelectedLogprob: captureSelLp,
    captureTopLogprobs: captureTopK,
  });
  const needsTokenHistory = stepSampler.needsHistory;

  const closePrefill = diagnostics.trace?.begin("prefill.total", {
    mechanism: diagnostics.mechanism ?? "serial",
    promptTokens: promptTokens.length,
    cachedTokens: options.cache?.[0]?.offset ?? 0,
  });
  const closeBatchSetup = diagnostics.trace?.begin("prefill.batch_setup", {
    mechanism: diagnostics.mechanism ?? "serial",
  });
  const ownsCache = !options.cache;
  const cache = options.cache ?? model.makeCache();
  const cachedTokens = cache[0]!.offset;
  if (cachedTokens >= promptTokens.length)
    throw new Error(
      `pre-warmed cache (${cachedTokens} tokens) must be a strict prefix of the prompt (${promptTokens.length})`,
    );
  // Paged KV (default off): swap fresh full-attention caches for paged
  // storage BEFORE prefill. Capacity is exact — the deepest write lands at
  // prompt + maxTokens − 1 (step maxTokens−1's forward), so this bound
  // makes pool exhaustion an accounting-bug tripwire, not a request limit.
  maybePageKv(cache, options, promptTokens.length + maxTokens);
  closeBatchSetup?.();
  /** Device-side logprob capture for one step, computed from the SAME lp the
   *  sampler saw (post-processors, pre-truncation) — read back lazily with the
   *  token so decode pipelining is preserved. */
  /** Read extras back to JS (forces eval — they were async-dispatched with the
   *  token) without appending casts behind the next decode step. */
  const readExtras = (e: StepExtras | null): TokenLogprobs | undefined => {
    if (!e) return undefined;
    const out: TokenLogprobs = {};
    if (e.sel) out.logprob = e.sel.toFloat32Host()[0]!;
    if (e.topIdx && e.topVals) {
      const ids = e.topIdx.toIntTokens();
      const vals = e.topVals.toFloat32Host();
      out.top = Array.from(ids, (id, i) => ({ id, logprob: vals[i]! })).sort(
        (a, b) => b.logprob - a.logprob,
      );
    }
    disposeStepExtras(e);
    return out;
  };

  // logits [1,1,V] → sampled token array [1] (+ optional logprob capture,
  // all on-device)
  const sampleStep = (
    logits3d: MlxArray,
    step: number,
  ): { tok: MlxArray; extras: StepExtras | null } => {
    const result = stepSampler.sample(logits3d, step);
    return { tok: result.token, extras: result.extras };
  };

  const pushHistory = (tok: MlxArray): void => stepSampler.commitDevice(tok);

  // Decode-loop state lives at function scope so the finally can still
  // report stats and dispose in-flight arrays when the consumer
  // terminates the generator early (break on a stop sequence — the
  // forced .return() resumes at the yield and runs the finally).
  let prefillMs = 0;
  let tDecode = 0;
  let decodeMs = 0;
  let generated = 0;
  const forwarded: number[] = [];
  let pending: MlxArray | null = null;
  let nextPending: MlxArray | null = null;
  let pendingExtras: StepExtras | null = null;
  let nextExtras: StepExtras | null = null;
  let finished = false;
  let threw = false;
  let closeTokenZero: (() => void) | undefined;
  const makeStats = (): GenerateStats => ({
    promptTokens: promptTokens.length,
    cachedTokens,
    generatedTokens: generated,
    prefillMs,
    decodeMs,
    prefillTps: ((promptTokens.length - cachedTokens) / prefillMs) * 1000,
    decodeTps: (generated / decodeMs) * 1000,
    cacheTokens: [...promptTokens, ...forwarded],
  });

  try {
    // ---- prefill ----
    const closeInitialKv = diagnostics.trace?.begin("prefill.kv_maintenance", {
      mechanism: diagnostics.mechanism ?? "serial",
      boundary: "initial",
    });
    maybeQuantizeKv(cache, options);
    closeInitialKv?.();
    const tPrefill = performance.now();
    let h0: MlxArray;
    if (options.promptEmbeddings) {
      if (cachedTokens !== 0)
        throw new Error("promptEmbeddings cannot be combined with a pre-warmed cache");
      if (needsTokenHistory)
        stepSampler.seedHistory(promptTokens);
      // e2b/e4b need the spliced token ids to build per-layer inputs
      // (multimodal soft-token positions zeroed inside forwardEmbeddings).
      const embedIds = ops.fromInt32(promptTokens, [1, promptTokens.length]);
      h0 = model.forwardEmbeddings(
        options.promptEmbeddings, cache, options.imageMask ?? null, embedIds,
        options.multimodalMask ?? null,
      );
      embedIds.dispose();
    } else {
      let pos = cachedTokens;
      // Stable-boundary snapshot: prefill up to snapshotAt first (plain
      // chunks, no logits), fire the hook while the caches hold exactly
      // that prefix, then continue with the remainder below. Splitting here
      // changes chunk shapes only for requests that opted in — the same
      // numerics class as a prompt-cache-hit continuation prefill.
      const snapAt = options.onPrefillDone && options.snapshotAt !== undefined
        ? Math.min(Math.max(options.snapshotAt, cachedTokens), promptTokens.length)
        : promptTokens.length;
      if (snapAt > pos && snapAt < promptTokens.length) {
        while (pos < snapAt) {
          const chunk = promptTokens.slice(pos, Math.min(pos + prefillChunkSize, snapAt));
          const closeChunk = diagnostics.trace?.begin("prefill.chunk", {
            mechanism: diagnostics.mechanism ?? "serial",
            startToken: pos,
            tokens: chunk.length,
          });
          const ids = ops.fromInt32(chunk, [1, chunk.length]);
          const h = await forwardHiddenForGeneration(model, ids, cache);
          ids.dispose();
          h.dispose();
          evalCacheState(cache);
          maybeQuantizeKv(cache, options);
          clearCache();
          closeChunk?.();
          pos += chunk.length;
          // Macrotask yield between chunks (runtime-isolation.md Phase 1):
          // each chunk is a synchronous multi-hundred-ms FFI eval; without
          // this the event loop serves no I/O for the WHOLE prefill.
          await new Promise<void>((r) => setImmediate(r));
        }
        options.onPrefillDone?.();
      }
      // Oracle prefill convention (mlx-lm 0.31.3 generate_step,
      // generate.py:430-453): drain the prompt only to len-1 — chunks of
      // min(prefillChunkSize, remaining-1) — then compute step-0 logits from
      // a SEPARATE L=1 forward of the LAST prompt token (its server's
      // batched engine shares the convention: insert_segments' forced final
      // 1-token segment + GenerationBatch._step, generate.py:1645/1327).
      // Forwarding the last token as the tail of an L=n GEMM instead is
      // ulp-different in bf16 (qmm-vs-qmv + L-dependent SDPA dispatch) in
      // BOTH the step-0 logits and that token's stored KV — near-tie greedy
      // streams flip (2026-07-07 12B completion-probe ✗: first token flip at
      // step 24). MLX_BUN_PREFILL_TAIL_SPLIT=0 restores the old
      // full-final-chunk convention (A/B lever + kill switch).
      const tailSplit = flagOn("MLX_BUN_PREFILL_TAIL_SPLIT", true);
      const drainGate = tailSplit ? 1 : prefillChunkSize;
      while (promptTokens.length - pos > drainGate) {
        const n = tailSplit
          ? Math.min(prefillChunkSize, promptTokens.length - pos - 1)
          : prefillChunkSize;
        const chunk = promptTokens.slice(pos, pos + n);
        const closeChunk = diagnostics.trace?.begin("prefill.chunk", {
          mechanism: diagnostics.mechanism ?? "serial",
          startToken: pos,
          tokens: chunk.length,
        });
        const ids = ops.fromInt32(chunk, [1, chunk.length]);
        const h = await forwardHiddenForGeneration(model, ids, cache);
        ids.dispose();
        h.dispose(); // logits never computed for non-final chunks
        evalCacheState(cache);
        maybeQuantizeKv(cache, options);
        // mlx-lm _prefill clears the allocator cache after every chunk;
        // without this, prefill transients pile up in the buffer cache
        // and the first decode step pays a one-shot reclaim stall that
        // scales with prompt length (~800 ms after an 8k prefill —
        // measured, scripts/decode-split.ts; the context-scaling decode
        // gap's main term).
        clearCache();
        closeChunk?.();
        pos += n;
        if (runtimeValue("MLX_BUN_PREFILL_MEM_LOG") === "1")
          console.error(`[prefill-mem] ${pos} active ${(activeMemory() / 2 ** 30).toFixed(2)} peak ${(peakMemory() / 2 ** 30).toFixed(2)}`);
        // Macrotask yield between chunks (runtime-isolation.md Phase 1).
        await new Promise<void>((r) => setImmediate(r));
      }
      if (needsTokenHistory) {
        stepSampler.seedHistory(promptTokens);
      }
      // Under tailSplit this is exactly [promptTokens[len-1]] — the L=1
      // step-0 forward (uncompiled L=1 is bit-exact with compiled decode,
      // tests/compiled-decode.test.ts). The last prompt token's KV enters
      // the cache HERE, so downstream bookkeeping (forwarded[], cacheTokens,
      // PromptCache.put alignment) is unchanged: after step 0 the caches
      // cover exactly the prompt, as before.
      const lastChunk = promptTokens.slice(pos);
      const closeChunk = diagnostics.trace?.begin("prefill.chunk", {
        mechanism: diagnostics.mechanism ?? "serial",
        startToken: pos,
        tokens: lastChunk.length,
        final: true,
      });
      const ids0 = ops.fromInt32(lastChunk, [1, lastChunk.length]);
      h0 = await forwardHiddenForGeneration(model, ids0, cache);
      ids0.dispose();
      closeChunk?.();
    }
    if (options.snapshotAt === undefined || options.snapshotAt >= promptTokens.length)
      options.onPrefillDone?.();
    // The trace's prefill span is the uncached model-forward portion only.
    // Token-0 lm-head, sampling, and readback are a separate additive stage.
    if (diagnostics.trace && runtimeValue("MLX_BUN_P2R_SYNC") === "1")
      synchronize(gpuStream);
    closePrefill?.();
    closeTokenZero = diagnostics.trace?.begin("token_zero.total", {
      mechanism: diagnostics.mechanism ?? "serial",
    });
    const [, L0, H] = h0.shape as [number, number, number];
    const hLast = h0.slice([0, L0 - 1, 0], [1, L0, H]);
    h0.dispose();
    const logits0 = model.logitsFromHidden(hLast);
    hLast.dispose();
    const s0 = sampleStep(logits0, 0); // token array [1] (+ optional extras)
    pending = s0.tok;
    pendingExtras = s0.extras;
    logits0.dispose();
    // mirror mlx-lm generate_step: async-dispatch the first token's
    // compute; the prefill clock keeps running until the token ARRIVES
    // (first itemUint32 below). mlx-lm stops its prompt clock at the
    // first yielded token, which bills the prefill→decode boundary
    // (allocator reclaim of prefill transients + first-step dispatch)
    // to prompt_time, not decode — replicated so cross-stack decode
    // tok/s measure the same quantity. The boundary cost is real and
    // scales with prompt length; it belongs to "having prefilled".
    ops.asyncEvalAll([pending, ...stepExtrasArrays(pendingExtras)]);

    // ---- decode (pipelined) ----
    // Compiled decode (docs/design/optimization_plan.md Phase A): replay the per-step
    // graph in C++ instead of rebuilding it through bun:ffi every token.
    // Bit-exact with the uncompiled path (tests/compiled-decode.test.ts);
    // MLX_BUN_COMPILED_DECODE=0 is the kill switch / A-B lever. LoRA
    // generations stay uncompiled (adapter weights would bake into the
    // trace as constants). Any unsupported cache state falls back for
    // the rest of the generation.
    // MoE models stay uncompiled: GatherQMM lacks output_shapes in mlx
    // 0.6.0, and shapeless replay re-infers the whole tape whenever the
    // growing attention windows change shape (= every step). Remove this
    // when upstream implements GatherQMM::output_shapes.
    let compiled =
      flagOn("MLX_BUN_COMPILED_DECODE", true) &&
      !options.adapters?.length &&
      // Paged caches can't compile (data-dependent block-list length —
      // the shapeless-replay hazard; CompiledDecode.supports() also
      // excludes them per step, this just skips the setup).
      !options.pagedKv &&
      model.config.modelType.startsWith("gemma4") &&
      !model.config.text.enableMoeBlock
        ? CompiledDecode.for(model as Gemma4Model)
        : null;
    let stop = false;
    /** Token id read eagerly at the top of the loop for grammar (reused for
     *  the yield, avoiding a second readback). -1 when grammar is off — the
     *  pipelined path keeps its deferred itemUint32 below. */
    let grammarTok = -1;
    // Jump-forward decoding (opt-in, MLX_BUN_GRAMMAR_JUMP=1; serial lane
    // only — the batch lane's #stepGrammar doesn't jump yet): when the
    // grammar forces a unique continuation, emit its retokenized ids without
    // per-token forwards — ONE multi-token forward carries them into the KV
    // (see GrammarController.jumpForward for the contract + the fidelity
    // note on why this is opt-in). Excluded when logprobs are requested
    // (jumped tokens are never sampled, so they'd have no logprobs rows).
    const grammarJump = shouldUseGrammarJump(options);
    while (!stop) {
      const cur = pending!;
      const curExtras = pendingExtras;
      pendingExtras = null;
      // Grammar advance (src/grammar.ts): acceptToken needs the token id as a
      // JS number, which the pipelined loop defers (it operates on device
      // arrays). So grammar requests eager-read cur here, advance the matcher,
      // and await the async mask precompute — which overlaps the GPU forward
      // dispatched just below. This trades the readback/forward overlap for
      // correctness (the mask for step n+1 must reflect token n). Non-grammar
      // requests keep the fast pipelined loop untouched.
      //
      // F1 fix (batched-lane plan): always eager-read `grammarTok` when
      // grammar is on, even at the max_tokens boundary — the emitted token
      // reuses it unconditionally. The OLD code gated the READ on
      // generated+1 < maxTokens but emitted grammarTok regardless, so the LAST
      // iteration skipped the refresh and emitted a stale/garbage token (the
      // previous step's token, or -1 when max_tokens=1) → truncated JSON ended
      // on a corrupted token + cacheTokens recorded the wrong id. Now only
      // accept()/ready() (which prepare the NEXT step's mask) are gated.
      /** Forced ids to emit after cur this iteration (jump-forward), else null. */
      let jumpEmit: number[] | null = null;
      if (options.grammar) {
        grammarTok = ops.itemUint32(cur);
        if (generated + 1 < maxTokens) {
          options.grammar.accept(grammarTok);
          await options.grammar.ready();
          if (grammarJump && !options.grammar.isTerminated) {
            jumpEmit = options.grammar.jumpForward(maxTokens - (generated + 1));
            // jumpForward advanced the matcher and fired the post-jump mask
            // fill; it must be ready before this iteration's sampleStep.
            if (jumpEmit) await options.grammar.ready();
          }
        }
      }
      // build step n+1's graph from the *unread* pending token
      nextPending = null;
      nextExtras = null;
      // When the grammar has terminated (a complete valid JSON/schema
      // accepted), there are no valid tokens left — skip building the next
      // step so the sampler never sees an all--inf distribution.
      if (jumpEmit) {
        // JUMP iteration: one [1, 1+m] forward carries cur AND the forced ids
        // into the KV (they are all committed content — jumpForward's
        // contract); the next sampled token, if the budget and grammar allow
        // one, comes from its last position. Compiled decode resumes on the
        // following iteration (supports() re-checks the grown caches).
        maybeQuantizeKv(cache, options);
        pushHistory(cur);
        stepSampler.commitNumbers(jumpEmit);
        const chunk = [grammarTok, ...jumpEmit];
        const ids = ops.fromInt32(chunk, [1, chunk.length]);
        const h = await forwardHiddenForGeneration(model, ids, cache);
        ids.dispose();
        // Every chunk token's KV is in the cache regardless of what follows.
        forwarded.push(...chunk);
        const willGen = generated + 1 + jumpEmit.length;
        if (willGen < maxTokens && !options.grammar!.isTerminated) {
          const [, Lj, Hj] = h.shape as [number, number, number];
          const hLast = h.slice([0, Lj - 1, 0], [1, Lj, Hj]);
          h.dispose();
          const logits = model.logitsFromHidden(hLast);
          hLast.dispose();
          const sn = sampleStep(logits, willGen);
          nextPending = sn.tok;
          nextExtras = sn.extras;
          logits.dispose();
          ops.asyncEvalAll([nextPending, ...stepExtrasArrays(nextExtras)]);
        } else {
          h.dispose(); // burst ends the generation (max_tokens or grammar done)
        }
      } else if (generated + 1 < maxTokens && !options.grammar?.isTerminated) {
        maybeQuantizeKv(cache, options);
        pushHistory(cur);
        let logits: MlxArray | null = null;
        let evalWith: MlxArray[] = [];
        if (compiled && CompiledDecode.supports(cache)) {
          try {
            const r = compiled.step(cur, cache);
            logits = r.logits;
            evalWith = r.evalWith;
          } catch (e) {
            // Safe to re-forward the SAME token below: a failed step is
            // transactional — segmented mode stages ring adopts and rolls
            // back committed js-layer writes on throw (see #stepSegmented),
            // and buffer growth done by a partial prepare is benign for the
            // uncompiled path (updateAndFetch re-checks capacity).
            compiled = null;
            console.warn(`compiled decode disabled for this generation: ${e}`);
          }
        }
        if (!logits) {
          const ids = ops.reshape(cur, [1, 1]);
          const h = await forwardHiddenForGeneration(model, ids, cache);
          ids.dispose();
          logits = model.logitsFromHidden(h);
          h.dispose();
        }
        const sn = sampleStep(logits, generated + 1);
        nextPending = sn.tok;
        nextExtras = sn.extras;
        logits.dispose();
        ops.asyncEvalAll([nextPending, ...stepExtrasArrays(nextExtras), ...evalWith]);
      }

      // sync-read step n's token while n+1 computes
      // sync-read step n's token while n+1 computes (grammar already read it
      // eagerly above — reuse to avoid a second GPU sync)
      const token = options.grammar ? grammarTok : ops.itemUint32(cur);
      if (generated === 0) {
        // first token arrived: prompt clock stops, decode clock starts
        // (mlx-lm stream_generate's n==0 clock swap; the first token is
        // "free" on the decode clock there too)
        prefillMs = performance.now() - tPrefill;
        closeTokenZero?.();
        closeTokenZero = undefined;
        tDecode = performance.now();
      }
      cur.dispose();
      pending = null;
      generated++;
      // if a next-step graph was built, this token's KV entered the cache
      // (jump iterations pushed the whole chunk already)
      if (nextPending !== null && !jumpEmit) forwarded.push(token);

      if (eosTokenIds.includes(token)) {
        disposeStepExtras(curExtras);
        nextPending?.dispose();
        nextPending = null;
        disposeStepExtras(nextExtras);
        nextExtras = null;
        stop = true;
      } else {
        // readExtras before the yield: if the consumer breaks at this yield,
        // the extras are already read and disposed.
        const logprobs = readExtras(curExtras);
        yield { token, index: generated - 1, ...(logprobs ? { logprobs } : {}) };
        // mlx-lm generate_step: clear_cache after token 0 (drops the
        // remaining prefill transients) and every 256 tokens after
        if ((generated - 1) % 256 === 0) clearCache();
        // Jump-forward burst: the forced ids follow cur, one yield each (the
        // consumer's stop-sequence matcher and detokenizer see the same
        // one-at-a-time stream shape as always). Their KV is already in the
        // cache (the chunk forward above); a consumer break mid-burst is
        // safe — `forwarded` already reflects the cache exactly.
        if (jumpEmit) {
          for (const jt of jumpEmit) {
            generated++;
            yield { token: jt, index: generated - 1 };
            if ((generated - 1) % 256 === 0) clearCache();
          }
        }
        if (nextPending === null) {
          stop = true;
        } else {
          pending = nextPending;
          nextPending = null;
          pendingExtras = nextExtras;
          nextExtras = null;
        }
      }
    }
    decodeMs = performance.now() - tDecode;
    finished = true;
    return makeStats();
  } catch (e) {
    threw = true;
    throw e;
  } finally {
    if (!finished) {
      pending?.dispose();
      nextPending?.dispose();
      disposeStepExtras(pendingExtras);
      disposeStepExtras(nextExtras);
    }
    if (ownsCache) for (const c of cache) c.dispose();
    // The grammar controller owns native WASM state (GrammarMatcher +
    // TokenizerInfo cache) — dispose on every exit path (normal, early break,
    // throw). TokenizerInfo itself is process-cached (vocab-structural), so
    // only the per-request matcher/compiled are freed here.
    options.grammar?.dispose();
    stepSampler.dispose();
    if (!finished && !threw) {
      // forced early return (consumer break at a yield): still report
      // stats — `forwarded` only lists tokens whose KV actually entered
      // the cache, so cacheTokens stays exact for PromptCache.put().
      decodeMs = performance.now() - tDecode;
      return makeStats();
    }
  }
}
