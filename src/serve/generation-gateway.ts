import { AdmissionPool } from "../engine/admission";
import { acquireReservation } from "./preparation";
import { cleanupFailure, disposeResources } from "../engine/resources";
// GenerationGateway is the scheduling seam between CompletionExecutor and
// the inference runtime. It declares one mechanism per request: the preserved
// strict/dedicated serial executor, or the continuous scheduler (`--batch N`).
// The scheduler itself chooses its B=1 fast path or B=N step from its active
// row count; placement does not predict a batch size. The executor owns each
// request's semantic token sink and passes its callback plus one immutable
// placement into run(). Each request keeps its own callback, so the scheduler
// can fan tokens out to the matching response stream.
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
// Batchable gate (the rest → serial): batch>1 AND every model cache is a
// dynamic-B-capable built-in type or implements BatchableCache (mirrors mlx-lm
// server.py's all-caches-have-merge check). GLM's capability owns compressed
// MLA/DSA merge/extract/filter and byte projection; Qwen3.5's SSM cache owns
// its row state. The remaining request-shape exclusions include vision, LoRA,
// serial-only KV modes, and user-fixed seed
// (reproducibility ⇒ solo, matching mlx-lm's _is_batchable). Temperature /
// top-p / top-k DO batch (each row samples with its own seed). Full-attention
// AND sliding-window (Gemma) models both batch — the scheduler assembles each
// layer's cache by type. Prompt-cache prefix reuse works on the batch lane
// too (Phase 3.2): joiners take() at admission; never-merged lone rows put()
// back zero-copy on finish; merged rows with ≥256 prompt tokens are extracted
// and put back by BatchScheduler.#extractAndPut (see docs/design/batching.md).

import { MlxArray } from "../mlx/array";
import type { RuntimeModel } from "../model/factory";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
import {
  KVCache,
  RotatingKVCache,
  isBatchableCache,
  isPlainKvCache,
  isRotatingPlainCache,
} from "../model/gemma4-base";
import { SSMCache } from "../model/qwen3-delta";
import { UniversalDenseModel } from "../model/universal/dense";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "../generate";
import type { KvScheme } from "../kv-scheme";
import { makeStepSampler } from "../sampler";
import { MlxBatchExecutionGroup as BatchScheduler, type RowPromptCache } from "../backends/mlx/batch-group";
import { runtimeConfig } from "../runtime-config";
import { resolveExecution } from "../engine/execution-plan";
import type { ExecutionRequirements, ResolvedExecution } from "../contracts/execution";
import type { PromptResponseTrace } from "./prompt-response-trace";

/** Async mutex: acquire() resolves to a release fn; releases run FIFO. */
class AsyncMutex {
  #tail: Promise<void> = Promise.resolve();
  /** Holders + waiters. > 0 means somebody owns or wants the engine. */
  #pending = 0;
  get locked(): boolean {
    return this.#pending > 0;
  }
  acquire(signal?: AbortSignal): Promise<() => void> {
    if (signal?.aborted) return Promise.reject(signal.reason);
    this.#pending++;
    let release!: () => void;
    const gate = new Promise<void>((r) => { release = r; });
    const wait = this.#tail;
    this.#tail = this.#tail.then(() => gate);
    let released = false;
    const unlock = () => {
      if (released) return; // idempotent: a double release must not skew #pending
      released = true;
      this.#pending--;
      release();
    };
    return new Promise((resolve, reject) => {
      let settled = false;
      const abort = () => {
        if (settled) return;
        settled = true;
        signal?.removeEventListener("abort", abort);
        // Release this waiter's gate, not its predecessor's. Later acquirers
        // still wait for the active holder, preserving mutual exclusion.
        unlock();
        reject(signal!.reason);
      };
      signal?.addEventListener("abort", abort, { once: true });
      wait.then(() => {
        if (settled) return;
        settled = true;
        signal?.removeEventListener("abort", abort);
        resolve(unlock);
      });
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
   *  run fully causal (docs/design/generic-model-support.md §3.3 Q1). */
  imageMask?: MlxArray;
  /** bool [L] union multimodal soft-token mask (image | audio) for
   *  per-layer-input id zeroing. Absent on the legacy vision-only shape,
   *  where zeroing falls back to imageMask. */
  multimodalMask?: MlxArray;
  /** Qwen3.5/3.8 vision: the request's mRoPE positions + decode delta,
   *  installed on the model for exactly this serial run (server-side). */
  mrope?: import("../model/qwen3-mrope").MropeRequestState;
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
  trace?: PromptResponseTrace,
  execution?: ResolvedExecution,
) => Promise<GenerateStats>;

/** What the batchable decision needs from a request (cheap to compute). */
export interface RequestShape extends ExecutionRequirements {}

export type GenerationMechanism = "serial" | "continuous";

/** One immutable scheduling declaration for one exact request shape.
 *  `continuous` means scheduler admission, not that another row is present. */
export interface GenerationPlacement {
  readonly shape: RequestShape;
  readonly mechanism: GenerationMechanism;
  readonly execution?: ResolvedExecution;
}

function disposeUnstartedRequest(options: GenerateOptions, vision?: Vision): void {
  disposeResources([options.grammar, vision?.embeddings, vision?.imageMask,
    vision?.multimodalMask, options.visionPixels].filter((resource) => resource != null));
}

export class GenerationGateway {
  #closed = false;
  readonly #runtime = runtimeConfig();
  readonly #requests: AdmissionPool;
  readonly #mutex = new AsyncMutex();
  readonly #batch: number;
  #scheduler: BatchScheduler | null = null;
  #rowsSubmitted = 0;
  /** Serial-lane requests waiting for / holding the mutex. While > 0 the
   *  scheduler pauses admission (drain) so they can't be starved. */
  #serialWaiters = 0;
  /** Lazy, memoized: can this model's caches do the dynamic-B ops? */
  #cacheBatchable: boolean | null = null;
  /** Lazy, memoized: can the configured KV scheme convert every named cache? */
  #kvSchemeBatchable: boolean | null = null;
  constructor(
    private readonly model: RuntimeModel,
    batch: number,
    private readonly serialRun: SerialRun,
    private readonly opts: {
      kvBudgetBytes?: number;
      checkpoints?: boolean;
      stateCodecs?: import("../kv-store").CacheCodecProvider;
      /** The server-wide KV scheme (server.ts kvScheme) — threaded to the
       *  scheduler at construction when batchable (Phase 3.1). turboQuant is
       *  never threaded to the scheduler (always solo-only — see placement);
       *  it's here only so the gateway can see it's active. */
      kvScheme?: KvScheme;
      /** The server's prompt cache (Phase 3.2): batch-lane joiners take()
       *  the longest usable prefix at admission; never-merged rows put()
       *  back on finish. Safe to share with the serial lane — both use it
       *  only inside this gateway's mutual-exclusion domain. */
      promptCache?: RowPromptCache;
    } = {},
  ) {
    this.#batch = Math.max(1, Math.floor(batch));
    this.#requests = new AdmissionPool(this.#batch);
  }

  /** True if `--batch N` (N>1) is on (batchability is then per-request). */
  get batchingEnabled(): boolean {
    return this.batchMode === "batch";
  }

  /** Truthful configured/model-capability mode for stats and discovery. */
  get batchMode(): "off" | "serial" | "batch" {
    if (this.#batch <= 1) return "off";
    return this.#modelCachesBatchable() ? "batch" : "serial";
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
    return this.#requests.active > 0 || this.#requests.queued > 0 ||
      this.#mutex.locked || this.activeRows > 0 || this.pendingRows > 0;
  }

  async close(): Promise<void> {
    this.#closed = true;
    this.#requests.close();
    await this.#scheduler?.close();
    await this.onIdle();
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
      // tests/parity/batched-decode-parity.test.ts "Llama 3B Tier-0"). The
      // maskArray archs (gemma2-family: forwardLayers builds a pad-blind
      // causal mask) and sliding-window universal archs remain UNVALIDATED
      // cells → serial, per the per-model-cell discipline.
      if (this.model instanceof UniversalDenseModel) {
        const a = this.model.args;
        this.#cacheBatchable =
          !a.maskArray && !a.layerTypes?.includes("sliding_attention");
        return this.#cacheBatchable;
      }
      const ssmOk = this.#runtime.value("MLX_BUN_BATCH_SSM") !== "0";
      const proto = this.model.makeCache(); // fresh caches hold no buffers
      this.#cacheBatchable = proto.every(
        (c) =>
          c instanceof KVCache ||
          c instanceof RotatingKVCache ||
          isBatchableCache(c) ||
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
      if (scheme?.kind !== "affine-config") {
        this.#kvSchemeBatchable = false;
      } else {
        const proto = this.model.makeCache();
        try {
          this.#kvSchemeBatchable = scheme.batchable(
            this.model.config,
            (layerIdx) =>
              isPlainKvCache(proto[layerIdx]) || isRotatingPlainCache(proto[layerIdx]),
          );
        } finally {
          for (const cache of proto) cache.dispose();
        }
      }
    }
    return this.#kvSchemeBatchable;
  }

  place(shape: RequestShape, options: GenerateOptions = {}): GenerationPlacement {
    const frozenShape = Object.freeze(shape);
    const execution = resolveExecution(frozenShape, {
      method: this.model instanceof DiffusionGemmaModel ? "denoising" : "autoregressive",
      continuous: this.batchingEnabled,
      quantizedBatch: shape.kvQuant && this.#kvBatchable(),
      grammarBatch: this.#runtime.value("MLX_BUN_GRAMMAR_BATCH") !== "0",
      checkpoints: this.opts.checkpoints === true,
    }, { pagedKv: !!options.pagedKv, fill: !!options.fill });
    return Object.freeze({ shape: frozenShape, mechanism: execution.mechanism, execution });
  }

  /** Run `fn` with exclusive ownership of the GPU + shared model state (the
   *  serial lane's lock). THE single mutual-exclusion domain: the serial
   *  generation path, the curve /generate + /signal endpoints, and adapter
   *  mount/unmount all come through here, so nothing runs concurrently with
   *  batched decode steps (or with each other). Registers as a serial waiter
   *  so the scheduler drains (stops admitting) until `fn` has run. */
  /** Shared by inference, preparation and managed GPU subprocesses. */
  async acquireExecutionLease(
    signal?: AbortSignal,
    trace?: PromptResponseTrace,
  ): Promise<import("../contracts/resources").DisposableResource> {
    if (this.#closed) throw new Error("generation gateway is closed");
    this.#serialWaiters++;
    const closeAdmission = trace?.begin("engine.admission_wait", { mechanism: "serial" });
    const resume = () => {
      this.#serialWaiters--;
      if (this.#serialWaiters === 0) this.#scheduler?.kick();
    };
    try {
      const release = await this.#mutex.acquire(signal);
      let released = false;
      return { dispose: () => {
        if (released) return;
        released = true;
        release(); resume();
      } };
    } catch (error) { resume(); throw error; }
    finally { closeAdmission?.(); }
  }

  async runExclusive<T>(
    fn: () => Promise<T>,
    trace?: PromptResponseTrace,
    signal?: AbortSignal,
  ): Promise<T> {
    const lease = await this.acquireExecutionLease(signal, trace);
    try { return await fn(); } finally { lease.dispose(); }
  }

  /** Run one generation on the appropriate lane. onToken is invoked per emitted
   *  token (its `false` halts); resolves with stats when the generation ends. */
  async run(
    promptIds: number[],
    options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken,
    vision: Vision | undefined,
    shape: RequestShape,
    placement: GenerationPlacement,
    signal?: AbortSignal,
    trace?: PromptResponseTrace,
  ): Promise<GenerateStats> {
    let reservation;
    try { reservation = await acquireReservation(this.#requests, signal); }
    catch (error) { cleanupFailure(error, () => disposeUnstartedRequest(options, vision)); }
    try { return await this.#run(promptIds, options, onToken, vision, shape, placement, signal, trace); }
    finally { reservation.dispose(); }
  }

  async #run(
    promptIds: number[],
    options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken,
    vision: Vision | undefined,
    shape: RequestShape,
    placement: GenerationPlacement,
    signal?: AbortSignal,
    trace?: PromptResponseTrace,
  ): Promise<GenerateStats> {
    const disposeUnstarted = () => disposeUnstartedRequest(options, vision);
    if (placement.shape !== shape) {
      disposeUnstarted();
      throw new Error("generation placement does not belong to this request shape");
    }
    try {
      signal?.throwIfAborted();
    } catch (e) {
      // The gateway is the first component that accepts ownership of a
      // compiled controller. An already-aborted request reaches neither lane.
      disposeUnstarted();
      throw e;
    }
    if (placement.mechanism === "serial") {
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
      let started = false;
      return this.runExclusive(async () => {
        signal?.throwIfAborted();
        started = true;
        const stats = await this.serialRun(
          promptIds, signal ? { ...options, signal } : options, hoppingOnToken, vision, trace, placement.execution,
        );
        signal?.throwIfAborted();
        return stats;
      }, trace, signal)
        // Covers a serial waiter aborted before serialRun takes ownership.
        // generate() also disposes defensively; the operation is idempotent.
        .finally(() => {
          if (started) options.grammar?.dispose();
          else disposeUnstarted();
        });
    }

    // The scheduler owns grammar ready/accept sequencing. StepSampler owns the
    // shared processors -> mask -> logprobs -> sample -> history contract.
    const stepSampler = makeStepSampler(options, {
      tokenRepresentation: "device",
      grammarWait: "external",
      historyUpdate: "after-sample",
      initialHistory: promptIds,
    });
    const sample = (logits1V: MlxArray, step: number): MlxArray =>
      stepSampler.sample(logits1V, step).token;

    let st;
    this.#rowsSubmitted++;
    const closeAdmission = trace?.begin("engine.admission_wait", {
      mechanism: "continuous",
    });
    try {
      st = await this.#ensureScheduler().submit({
        promptIds,
        maxTokens: options.maxTokens ?? 512,
        eosTokenIds: options.eosTokenIds ?? this.model.config.eosTokenIds,
        sample,
        plainGreedy: stepSampler.isPlainGreedy,
        onToken,
        onAdmitted: closeAdmission,
        trace,
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
      closeAdmission?.();
      stepSampler.dispose();
      // The scheduler never owns per-row grammar state.
      options.grammar?.dispose();
    }

    return {
      promptTokens: st.promptTokens,
      cachedTokens: st.cachedTokens,
      generatedTokens: st.generatedTokens,
      prefillMs: st.prefillMs,
      decodeMs: st.decodeMs,
      prefillTps: st.prefillMs > 0 ? ((st.promptTokens - st.cachedTokens) / st.prefillMs) * 1000 : 0,
      decodeTps: st.decodeMs > 0 && st.generatedTokens > 1 ? ((st.generatedTokens - 1) / st.decodeMs) * 1000 : 0,
      cacheTokens: [],
    };
  }

  #ensureScheduler(): BatchScheduler {
    if (!this.#scheduler)
      this.#scheduler = new BatchScheduler(this.model, {
        maxBatch: this.#batch,
        stateCodecs: this.opts.stateCodecs,
        kvBudgetBytes: this.opts.kvBudgetBytes,
        // Phase 3.1: the batchable kvConfig composition is applied by the
        // scheduler (solo rows convert at serial chunk boundaries, then
        // merge as quantized triples). Only threaded when the scheme
        // passed #kvBatchable — otherwise those requests never reach here.
        kvScheme: this.#kvBatchable() ? this.opts.kvScheme : undefined,
        promptCache: this.opts.promptCache,
        lock: { acquire: () => this.#mutex.acquire() },
        // Drain: pause admission while any serial-lane request waits; the
        // runExclusive finally-block kick()s the loop back awake.
        admissionHeld: () => this.#serialWaiters > 0,
      });
    return this.#scheduler;
  }
}
