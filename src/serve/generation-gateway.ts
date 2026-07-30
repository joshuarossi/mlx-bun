// Generation gateway — the seam between the server's request handlers and the
// two execution lanes: the serial single-queue path (today's default) and the
// continuous-batching scheduler (`--batch N`). The handler builds an onToken
// closure (its own StopMatcher + tool router + SSE stream) and calls run();
// the gateway routes it to the right lane. Per-row SSE fan-out falls out for
// free — each request keeps its own onToken/stream and the scheduler just
// invokes the right row's onToken.
//
// The two lanes are MUTUALLY EXCLUSIVE on the GPU (and on shared model state
// like loraState, which generate() mutates per-generation assuming a serialized
// queue). One AsyncMutex enforces it: a serial run holds it for its duration;
// the scheduler holds it for its whole active period (first admit → batch
// empties). So batched requests run concurrently with EACH OTHER (the point),
// but never alongside a serial-lane generation. A non-batchable request DRAINS
// the batch: while any serial-lane request is waiting, the scheduler stops
// admitting new rows (admissionHeld), finishes the running ones, and releases
// the mutex; the serial request runs solo, then kick() resumes admission.
// (mlx-lm's drain_batch semantics — without this, sustained batchable traffic
// starves the serial lane forever.) Non-generation GPU/model-state work (the
// curve endpoints, adapter mount/unmount) goes through runExclusive() so there
// is exactly ONE mutual-exclusion domain.
//
// v1 batchable gate (the rest → serial): batch>1 AND every model cache is a
// dynamic-B-capable type (KVCache | RotatingKVCache — mirrors mlx-lm
// server.py's all-caches-have-merge check; Qwen3.5's SSMCache has no
// merge/filter/temporalView, so hybrid models route serial until the ArraysCache
// port — batching-v2-plan item h) AND bf16 KV (no kv-quant — the batched
// scheduler runs bf16; mixed-precision-KV batching is the novel-combo L2
// follow-up) AND no vision AND no LoRA adapters AND no repetition penalty
// (per-row logits processors are a later refinement) AND no user-fixed seed
// (reproducibility ⇒ solo, matching mlx-lm's _is_batchable). Temperature /
// top-p / top-k DO batch (each row samples with its own seed). Full-attention
// AND sliding-window (Gemma) models both batch — the scheduler assembles each
// layer's cache by type. Prompt-cache prefix reuse works on the batch lane
// too (Phase 3.2): joiners take() at admission; never-merged lone rows put()
// back on finish (merged rows' KV is not extracted — their entries age out).

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
import { KVCache, RotatingKVCache } from "../model/gemma4-base";
import { SSMCache } from "../model/qwen3-delta";
import { UniversalDenseModel } from "../model/universal/dense";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "../generate";
import type { KvQuantSpec, TurboQuantScheme } from "../config";
import { makeSampler, makeLogitsProcessors, toLogprobs } from "../sampler";
import { BatchScheduler, type RowPromptCache } from "./batch-scheduler";

/** Async mutex: acquire() resolves to a release fn; releases run FIFO. */
class AsyncMutex {
  #tail: Promise<void> = Promise.resolve();
  /** Holders + waiters. > 0 means somebody owns or wants the engine. */
  #pending = 0;
  get locked(): boolean {
    return this.#pending > 0;
  }
  acquire(): Promise<() => void> {
    this.#pending++;
    let release!: () => void;
    const gate = new Promise<void>((r) => { release = r; });
    const wait = this.#tail;
    this.#tail = this.#tail.then(() => gate);
    let released = false;
    return wait.then(() => () => {
      if (released) return; // idempotent: a double release must not skew #pending
      released = true;
      this.#pending--;
      release();
    });
  }
}

/** Embeddings-prefill payload for media prompts (vision and/or audio — the
 *  name predates audio). Any request carrying one routes to the serial lane
 *  (shape.hasVision) and prefills through generate()'s promptEmbeddings
 *  path, bypassing the prompt cache. */
export type Vision = {
  embeddings: MlxArray;
  /** bool [L] image-token mask for the bidirectional attention overlay.
   *  Absent when the prompt carries ANY audio — audio(-containing) prompts
   *  run fully causal (audio-input-plan.md §3.3 Q1). */
  imageMask?: MlxArray;
  /** bool [L] union multimodal soft-token mask (image | audio) for
   *  per-layer-input id zeroing. Absent on the legacy vision-only shape,
   *  where zeroing falls back to imageMask. */
  multimodalMask?: MlxArray;
};

/** Per-token sink: returning `false` halts this generation (stop sequence).
 *  `logprobs` is only populated on the serial lane when the request asked for
 *  logprobs capture (GenerateOptions.logprobs / topLogprobs). */
export type OnToken = (
  token: number,
  logprobs?: TokenLogprobs,
) => void | boolean | Promise<void | boolean>;

/** The serial lane — exactly today's runGeneration (prompt-cache reuse + the
 *  generate() pipeline). The gateway calls it under the mutex. */
export type SerialRun = (
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  vision?: Vision,
) => Promise<GenerateStats>;

/** What the batchable decision needs from a request (cheap to compute). */
export interface RequestShape {
  hasVision: boolean;
  hasAdapters: boolean;
  hasRepetitionPenalty: boolean;
  /** The user explicitly set `seed` (reproducibility) — not the random default. */
  userSeed: boolean;
  /** KV quantization is active (kvConfig/kvBits) — batched is bf16-only in v1. */
  kvQuant: boolean;
  /** TurboQuant is active (docs/design/turboquant-kv.md). Solo-only in v1:
   *  TurboQuantKVCache is a novel Cache implementation (not a KVCache/
   *  RotatingKVCache subclass), so #modelCachesBatchable() already excludes
   *  it automatically once a request's cache is converted — this flag is the
   *  BELT on top of that automatic BRACES, an explicit refusal at the
   *  request-shape level so a turbo request never reaches the scheduler even
   *  before any cache conversion has happened. Both layers exist on purpose. */
  turboQuant: boolean;
  /** Any of the mlx-lm sampler/processor extensions is active: min_p, XTC,
   *  logit_bias, presence/frequency penalty. INFORMATIONAL ONLY: since the
   *  batched lane grew per-row samplers/logits processors these all batch —
   *  willBatch() deliberately does not gate on this field (see its
   *  repetitionPenalty note). Kept so /stats and lane tracing can show what
   *  a request carries. */
  hasLogitsExtras: boolean;
  /** A grammar controller compiled for this request (response_format /
   *  guided_*). Degrade-path requests (compile failed → prompt injection)
   *  have NO controller and stay batchable — the injection already happened
   *  at the prompt level. B0 routes grammar to serial; B1 makes it batchable
   *  (per-row matchers), with MLX_BUN_GRAMMAR_BATCH=0 forcing the B0 serial
   *  fallback as the A/B + kill switch. */
  hasGrammar: boolean;
  /** The request asked for logprobs/top_logprobs capture. Batch-lane logprobs
   *  are deferred (the scheduler's per-row sampler doesn't capture or read
   *  back logprob arrays yet), so these route to the serial lane like the
   *  other mlx-lm request extensions above. */
  wantsLogprobs: boolean;
  /** A draft model is configured (serve --draft-model). Server-level and
   *  upstream-parity: mlx_lm.server sets is_batchable = (draft is None), so
   *  every request routes serial while a draft is mounted — speculation is a
   *  B=1 latency optimization, batching a throughput one; they are different
   *  modes by design (grammar-spec-batching-integration.md). */
  hasDraft: boolean;
}

export class GenerationGateway {
  readonly #mutex = new AsyncMutex();
  readonly #batch: number;
  #scheduler: BatchScheduler | null = null;
  #rowsSubmitted = 0;
  /** Serial-lane requests waiting for / holding the mutex. While > 0 the
   *  scheduler pauses admission (drain) so they can't be starved. */
  #serialWaiters = 0;
  /** Lazy, memoized: can this model's caches do the dynamic-B ops? */
  #cacheBatchable: boolean | null = null;
  /** Lazy, memoized: can the server's kv scheme run under batching?
   *  (Phase 3.1: kvConfig whose every configured layerIdx is a plain
   *  full-attention KVCache — uniform kvBits and rotating-layer configs
   *  stay serial. The scheme is a server-lifetime constant, so one memo.) */
  #kvSchemeBatchable: boolean | null = null;

  constructor(
    private readonly model: RuntimeModel,
    batch: number,
    private readonly serialRun: SerialRun,
    private readonly opts: {
      kvBudgetBytes?: number;
      /** The server-wide KV scheme (server.ts kvScheme) — threaded to the
       *  scheduler at construction when batchable (Phase 3.1). turboQuant is
       *  never threaded to the scheduler (always solo-only — see willBatch);
       *  it's here only so the gateway can see it's active. */
      kvScheme?: { kvBits?: number; kvConfig?: KvQuantSpec[]; turboQuant?: TurboQuantScheme };
      /** The server's prompt cache (Phase 3.2): batch-lane joiners take()
       *  the longest usable prefix at admission; never-merged rows put()
       *  back on finish. Safe to share with the serial lane — both use it
       *  only inside this gateway's mutual-exclusion domain. */
      promptCache?: RowPromptCache;
    } = {},
  ) {
    this.#batch = Math.max(1, Math.floor(batch));
  }

  /** True if `--batch N` (N>1) is on (batchability is then per-request). */
  get batchingEnabled(): boolean {
    return this.#batch > 1;
  }

  /** Rows currently decoding in the batch (0 if no scheduler / idle). */
  get activeRows(): number {
    return this.#scheduler?.activeRows ?? 0;
  }

  /** Queued + mid-prefill rows waiting behind the batch (0 when idle). */
  get pendingRows(): number {
    return this.#scheduler?.pendingRows ?? 0;
  }

  /** True while ANY engine work is active or queued, on EITHER lane: the
   *  mutex is held/awaited (a serial generation, the batch scheduler's whole
   *  active period, curve endpoints, adapter mounts) or batch rows are
   *  running/pending. activeRows/pendingRows alone MISS the serial lane —
   *  a serial generation holds the mutex but shows zero rows. */
  get busy(): boolean {
    return this.#mutex.locked || this.activeRows > 0 || this.pendingRows > 0;
  }

  /** Resolves once the engine is idle (poll-based, ~`pollMs` granularity —
   *  cheap vs the multi-hundred-ms flushes it paces; resolves without a
   *  timer when already idle). The SSD write-behind gates each per-tensor
   *  flush step on this so durability work never steals blocking
   *  GPU-sync + writeSync slices from an active decode (the 2026-07-07
   *  decode@ctx contamination — see server.ts's write-behind block). */
  async onIdle(pollMs = 20): Promise<void> {
    while (this.busy) await new Promise<void>((r) => setTimeout(r, pollMs));
  }

  /** Cumulative rows routed to the batch lane since server start. The serial
   *  lane never advances this — /stats' race-free lane-routing observable
   *  (active/pending are instantaneous and read 0 once a request finishes). */
  get submittedRows(): number {
    return this.#rowsSubmitted;
  }

  /** Projected aggregate KV bytes of admitted rows / the --kv-budget cap. */
  get kvBytes(): { projected: number; budget: number | null } {
    return {
      projected: this.#scheduler?.projectedKvBytes ?? 0,
      budget: this.#scheduler?.kvBudgetBytes ?? this.opts.kvBudgetBytes ?? null,
    };
  }

  /** Cache-capability gate (mirrors mlx-lm server.py's all-caches-have-merge
   *  check): the scheduler's dynamic-B ops (temporalView/merge/filter) exist
   *  on KVCache, RotatingKVCache, and SSMCache (hybrid gated-DeltaNet models
   *  — Qwen3.5 — batch via SSMCache.mergeRows/filter; MLX_BUN_BATCH_SSM=0 is
   *  the kill switch back to serial routing). */
  #modelCachesBatchable(): boolean {
    if (this.#cacheBatchable === null) {
      // Tier-0 universal models: batchable for PLAIN full-attention archs
      // only. The 2026-07-03 uneven-row bug (scalar-offset RoPE decoded
      // padded rows at wrong positions) is fixed via
      // UniversalRope.applyDynamic + ropeOffsetArr and GATED token-exact vs
      // mlx-lm B=2 on Llama-3.2-3B (static + dynamic join/leave,
      // tests/batched-decode-parity.test.ts "Llama 3B Tier-0"). The
      // maskArray archs (gemma2-family: forwardLayers builds a pad-blind
      // causal mask) and sliding-window universal archs remain UNVALIDATED
      // cells → serial, per the per-model-cell discipline.
      if (this.model instanceof UniversalDenseModel) {
        const a = this.model.args;
        this.#cacheBatchable =
          !a.maskArray && !a.layerTypes?.includes("sliding_attention");
        return this.#cacheBatchable;
      }
      const ssmOk = process.env.MLX_BUN_BATCH_SSM !== "0";
      const proto = this.model.makeCache(); // fresh caches hold no buffers
      this.#cacheBatchable = proto.every(
        (c) =>
          c instanceof KVCache ||
          c instanceof RotatingKVCache ||
          (ssmOk && c instanceof SSMCache),
      );
      for (const c of proto) c.dispose();
    }
    return this.#cacheBatchable;
  }

  /** Phase 3.1 + milestone 2: the server's kv scheme batches iff it is a
   *  per-layer kvConfig (the L2 mixed scheme) whose every configured layer
   *  is a full-attention KVCache (BatchedQuantDecodeMaskCache + quantized
   *  merge/extend/filter) or a rotating RotatingKVCache
   *  (BatchedRotatingQuantCache — milestone 2, gemma's kv_config). Uniform
   *  kvBits (quantizedKvStart threshold semantics via the serial no-byLayer
   *  path) and configs naming SSM layers stay serial. */
  #kvBatchable(): boolean {
    if (this.#kvSchemeBatchable === null) {
      const scheme = this.opts.kvScheme;
      if (!scheme || (!scheme.kvBits && !scheme.kvConfig?.length)) {
        // Only consulted when shape.kvQuant is SET: a kv-quant request with
        // no scheme threaded to the gateway cannot be applied by the
        // scheduler — batching it would SILENTLY DROP the quantization (the
        // exact composition bug optiq serve ships). Route serial.
        this.#kvSchemeBatchable = false;
      } else if (scheme.kvBits || !scheme.kvConfig?.length) {
        this.#kvSchemeBatchable = false; // uniform bits: serial
      } else {
        const proto = this.model.makeCache();
        this.#kvSchemeBatchable = scheme.kvConfig.every(
          (e) => proto[e.layerIdx] instanceof KVCache ||
                 proto[e.layerIdx] instanceof RotatingKVCache,
        );
        for (const c of proto) c.dispose();
      }
    }
    return this.#kvSchemeBatchable;
  }

  /** Decide whether a request joins the batch or runs serially. */
  willBatch(shape: RequestShape): boolean {
    // DiffusionGemma is non-autoregressive — the batch scheduler assumes the AR
    // KV-cache decode path, so it always runs serially through generate().
    if (this.model instanceof DiffusionGemmaModel) return false;
    if (!this.batchingEnabled) return false;
    if (!this.#modelCachesBatchable()) return false;
    // repetitionPenalty / logits extras (min_p, XTC, logit_bias,
    // presence/frequency penalties) batch: the per-row sampler folds in the
    // same makeSampler/makeLogitsProcessors closures the serial lane runs,
    // over a per-row device-side token history. (Load-bearing beyond opt-in
    // knobs: some models — Qwen3.5 — ship a default repetition penalty in
    // generation_config.json, which used to route EVERY request serial.)
    return (
      !shape.hasVision &&
      !shape.hasAdapters &&
      !shape.wantsLogprobs &&
      !shape.userSeed &&
      // Phase 3.1: a kv-quant request batches when the server's scheme is
      // the batchable kvConfig composition (the scheduler applies it);
      // otherwise it routes serial exactly as before.
      !(shape.kvQuant && !this.#kvBatchable()) &&
      // TurboQuant: solo-only in v1, unconditionally — never partially
      // batchable like kvConfig. The automatic instanceof exclusion in
      // #modelCachesBatchable() already covers this once a cache converts;
      // this is the explicit belt-and-braces refusal at request-shape time
      // (mirrors the kvQuant pattern above — both layers exist on purpose).
      !shape.turboQuant &&
      !shape.hasDraft &&
      // Grammar: B1 makes it batchable (per-row matchers) unless the kill
      // switch forces serial. MLX_BUN_GRAMMAR_BATCH=0 = B0 behavior (serial),
      // the A/B + kill lever for the new code, house style.
      !(shape.hasGrammar && process.env.MLX_BUN_GRAMMAR_BATCH === "0")
    );
  }

  /** Run `fn` with exclusive ownership of the GPU + shared model state (the
   *  serial lane's lock). THE single mutual-exclusion domain: the serial
   *  generation path, the curve /generate + /signal endpoints, and adapter
   *  mount/unmount all come through here, so nothing runs concurrently with
   *  batched decode steps (or with each other). Registers as a serial waiter
   *  so the scheduler drains (stops admitting) until `fn` has run. */
  async runExclusive<T>(fn: () => Promise<T>): Promise<T> {
    this.#serialWaiters++;
    try {
      const release = await this.#mutex.acquire();
      try {
        return await fn();
      } finally {
        release();
      }
    } finally {
      this.#serialWaiters--;
      if (this.#serialWaiters === 0) this.#scheduler?.kick(); // resume admission
    }
  }

  /** Run one generation on the appropriate lane. onToken is invoked per emitted
   *  token (its `false` halts); resolves with stats when the generation ends. */
  async run(
    promptIds: number[],
    options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken,
    vision: Vision | undefined,
    shape: RequestShape,
    signal?: AbortSignal,
  ): Promise<GenerateStats> {
    try {
      signal?.throwIfAborted();
    } catch (e) {
      // The gateway is the first component that accepts ownership of a
      // compiled controller. An already-aborted request reaches neither lane.
      options.grammar?.dispose();
      throw e;
    }
    if (!this.willBatch(shape)) {
      // Serial decode is an unbroken microtask chain (FFI + generator
      // resumes): without a periodic macrotask hop the event loop starves for
      // the WHOLE generation — /stats, /health, and new-connection accepts
      // stall until the request finishes (measured 2.5 s on a 512-token cpm5
      // run). Rate-limited to ≥25 ms — the SSE flush hop's budget, ~0.1% of
      // decode — and applied HERE so every serial caller (streaming or not,
      // all four API surfaces) is covered. The batch lane needs nothing: its
      // drive loop yields per step (measured /stats ~8 ms mid-generation).
      let lastHop = performance.now();
      const hop = (): Promise<void> => new Promise<void>((r) => setImmediate(r));
      const hoppingOnToken: OnToken = (token, lp) => {
        if (signal?.aborted) return false;
        const r = onToken(token, lp);
        if (r === false) return false;
        if (performance.now() - lastHop < 25) return r;
        lastHop = performance.now();
        if (r instanceof Promise)
          return r.then((v) =>
            v === false || signal?.aborted ? false : hop().then(() => signal?.aborted ? false : v),
          );
        return hop().then(() => signal?.aborted ? false : r);
      };
      return this.runExclusive(async () => {
        signal?.throwIfAborted();
        const stats = await this.serialRun(promptIds, options, hoppingOnToken, vision);
        signal?.throwIfAborted();
        return stats;
      })
        // Covers a serial waiter aborted before serialRun takes ownership.
        // generate() also disposes defensively; the operation is idempotent.
        .finally(() => options.grammar?.dispose());
    }

    // Per-row sampler, mirroring generate()'s sampleStep: logits processors
    // (logit_bias / repetition / presence / frequency penalties — the same
    // device-side closures the serial lane runs) fold in over a per-row token
    // history seeded with the prompt, then the sampler. Greedy (temperature 0)
    // is argmax; temp>0 uses this request's own seed → independent per-row RNG.
    const sampler = makeSampler(options);
    const processors = makeLogitsProcessors(options);
    // Device-side history (prompt + generated), maintained only when a
    // processor needs it — generate()'s pushHistory, one per row. The sample
    // closure is called once per sampled token in order, so extending it
    // inside the closure keeps history exact.
    let history: MlxArray | null = null;
    if (processors.length > 0) history = ops.fromInt32(promptIds, [promptIds.length]);
    const sample = (logits1V: MlxArray, step: number): MlxArray => {
      let cur = logits1V; // caller-owned; only intermediates are disposed here
      for (const p of processors) {
        const next = p(history, cur);
        if (cur !== logits1V) cur.dispose();
        cur = next;
      }
      // Grammar mask (B1): after the standard processors, before the sampler —
      // same "grammar has the final say" ordering as serial sampleStep.
      // Precondition: the scheduler has awaited ready() before invoking this
      // closure (the mask for this step is materialized). applyMask is sync.
      if (options.grammar) {
        const masked = options.grammar.applyMask(cur);
        if (cur !== logits1V) cur.dispose();
        cur = masked;
      }
      const lp = toLogprobs(cur);
      if (cur !== logits1V) cur.dispose();
      const tok = sampler(lp, step);
      lp.dispose();
      if (history) {
        const t1 = ops.reshape(tok, [1]);
        const prev = history;
        history = ops.concatAxis([prev, t1], 0);
        prev.dispose();
        t1.dispose();
      }
      return tok;
    };

    let st;
    this.#rowsSubmitted++;
    try {
      st = await this.#ensureScheduler().submit({
        promptIds,
        maxTokens: options.maxTokens ?? 512,
        eosTokenIds: options.eosTokenIds ?? this.model.config.eosTokenIds,
        sample,
        // Vectorized-sampling eligibility: mirrors makeSampler's greedy branch
        // (temperature 0, no curve override) with nothing per-row in the way
        // (no processors, no grammar mask).
        plainGreedy:
          (options.temperature ?? 0) === 0 &&
          !options.curve &&
          processors.length === 0 &&
          !options.grammar,
        onToken,
        ...(signal ? { signal } : {}),
        // B1: pass the per-row grammar controller through. The scheduler drives
        // accept/ready/terminate; this gateway OWNS disposal (finally below)
        // across resolve, reject, eviction, and the whole-batch-drop error path.
        ...(options.grammar ? { grammar: options.grammar } : {}),
        // Stable cache boundary → the scheduler's trim-free prompt-prefix
        // snapshot (same invariant as the serial lane's snapshotAt).
        ...(options.snapshotAt !== undefined ? { snapshotAt: options.snapshotAt } : {}),
      });
    } finally {
      history?.dispose();
      history = null;
      // The scheduler never owns per-row grammar state.
      options.grammar?.dispose();
    }

    return {
      promptTokens: st.promptTokens,
      cachedTokens: st.cachedTokens,
      generatedTokens: st.generatedTokens,
      prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0,
      cacheTokens: [],
    };
  }

  #ensureScheduler(): BatchScheduler {
    if (!this.#scheduler)
      this.#scheduler = new BatchScheduler(this.model, {
        maxBatch: this.#batch,
        kvBudgetBytes: this.opts.kvBudgetBytes,
        // Phase 3.1: the batchable kvConfig composition is applied by the
        // scheduler (solo rows convert at serial chunk boundaries, then
        // merge as quantized triples). Only threaded when the scheme
        // passed #kvBatchable — otherwise those requests never reach here.
        kvConfig: this.#kvBatchable() ? this.opts.kvScheme?.kvConfig : undefined,
        promptCache: this.opts.promptCache,
        lock: { acquire: () => this.#mutex.acquire() },
        // Drain: pause admission while any serial-lane request waits; the
        // runExclusive finally-block kick()s the loop back awake.
        admissionHeld: () => this.#serialWaiters > 0,
      });
    return this.#scheduler;
  }
}
