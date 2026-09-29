import { type MlxForwardWork,type MlxPreparationWork } from "../contracts/mlx/forward-work";
import type { DisposableResource } from "../contracts/portable/resources";
import type { ExecutionGroup } from "../contracts/portable/scheduling";
import { cleanupFailure,disposeResources,withResource } from "../runtime/resources";
import type { MlxRequestStatePolicy } from "../state/request-policy";
import { AdmissionRejected } from "./admission";
import { runMixedTokenIteration } from "./mixed-iteration";
import { MlxPrefillCohort,type PrefillState } from "./prefill-cohort";
import { driveExecutionGroup } from "./scheduler";
// Continuous-batching scheduler for `--batch N` serving (the engine loop).
// Owns ONE running batch and drives it forward one decode step at a
// time, admitting waiting requests and evicting finished ones between steps —
// iteration-level (continuous) scheduling, not static batching. See
// `02d723a:docs/design/batching.md`.
//
// The numerically-hard parts are verified primitives, owned by state/:
//   - the batched FORWARD (per-row RoPE/mask) is bit-parity with mlx-lm B=N
//     across all 4 models (`02d723a:tests/parity/batched-decode-parity.test.ts`);
//   - the dynamic-B FULL-attention ops mergeKVRows / filterKVRows match mlx-lm
//     BatchKVCache (same test), and the SLIDING-window
//     BatchedRotatingCache (merge/filter/decode/make_mask incl. ring-wrap)
//     matches mlx-lm BatchRotatingKVCache (`02d723a:tests/unit/batched-rotating.test.ts`).
// This module is the ORCHESTRATION on top: admission, the step loop, per-row
// sampling + token accounting, eviction. It never names a storage family:
// each layer's state joins, filters and extracts through the layer's own row
// layout (state/layout `ownedCacheLayout`, the BatchableCache port), which
// also supplies the mask and per-row RoPE positions its rows need. Those
// layouts are padded full-attention rows, per-row-position sliding rings (plain
// and quantized), recurrent state (no temporal axis, no padding), and the
// layouts that own their tensors (paged, delayed affine, TurboQuant, GLM).
// Gate: GenerationGateway.place on cache capability.
//
// Engine mechanics (the serial decode loop's hygiene, transplanted —
// batching-v2-plan step 3):
//   - PIPELINED decode: each step builds the NEXT step's graph from the
//     still-unread sampled-token array (asyncEval), then reads the PREVIOUS
//     step's tokens while the new step computes — mlx-lm GenerationBatch._step.
//     The pipeline is flushed (read + emit) before a join merges, so admission
//     never has to reconcile an in-flight token array with a new row.
//   - clearCache every 256 steps (serial's cadence; mlx-lm batched uses 512),
//     not every step — per-step clears trashed the buffer pool each token.
//   - CHUNKED, INTERLEAVED admission: a joiner prefills prefillChunkSize
//     tokens per loop iteration with one batch decode step run in between, so
//     running rows stall at most one chunk per joiner (mlx-lm interleaves the
//     same way), and the prefill transient stays bounded.
//   - Failure containment: one row's onToken throwing evicts THAT row (its
//     promise rejects); siblings keep decoding (mlx-lm `remove` semantics). A
//     forward/sampling error still drops the whole batch (can't be attributed
//     to a row).
//
// Bun-async, NO threads: a single detached driver loop owns the GPU for batched
// mode (an ExclusiveLock keeps the serial fallback off the GPU concurrently).
// When `admissionHeld` reports a waiting serial-lane request, the loop stops
// admitting, finishes the running rows, and releases the lock so the serial
// request runs (mlx-lm's drain_batch) — resumed via kick().
// Joins keep the running batch: a full-attention layout appends the new row in
// one pad + concat; rotating layers re-merge. MLX_BUN_BATCH_EXTEND=0 forces the
// full-attention re-merge.

import { MlxArray } from "@mlx-bun/mlx/array";
import { activeMemory,cacheMemory,clearCache,Dtype,peakMemory } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { type Cache } from "../contracts/mlx/cache";
import type { PrefillPolicy } from "../contracts/portable/prefill";
import type { MlxCompiledDecodeStep } from "../contracts/mlx/graph";
import { resolveMlxPrefillPolicy } from "../generation/bindings/prefill-policy";
import { acquireModelWiredLimit } from "../generation/index";
import { compiledDecodeStepOf } from "../models/capabilities";
import type { MlxTokenGraph } from "../models/graph";
import { runtimeConfig,withRuntimeConfig,type RuntimeConfig } from "../runtime/config";
import type { PromptResponseTrace } from "../runtime/trace";
import { independentGreedySampling } from "../sampling/index";
import { isBatchableCache,isPlainKvCache,isRotatingPlainCache } from "../state/capabilities";
import { createKvMaintenance,type KvMaintenance } from "../state/kv-maintenance";
import type { KvScheme } from "../state/kv-scheme";
import { ownedCacheLayout } from "../state/layout";
import { leaseCacheStates } from "../state/leases";
import { cloneSingleRowState } from "../state/views";
import { CancellationSource,GenerationCancelled } from "./cancellation";
import { batchRowKvBytes } from "./kv-budget";
import { ExecutionTasks } from "./tasks";

/** Decode-pipeline kill switch (read once at load, like the serial loop's
 *  MLX_BUN_COMPILED_DECODE): 1 ⇒ read each step's tokens synchronously. */

/** Per-step phase timing (MLX_BUN_BATCH_STEP_TRACE=1, debug-only): where a
 *  decode step's wall time goes — graph BUILD+dispatch (host), the pipelined
 *  READ of the previous step's tokens (GPU wait), row EMIT (onToken/SSE), and
 *  the GAP between consecutive steps (drive-loop + everything else). Sums
 *  print via `stepTraceReport()` (the b1 profile experiment calls it). */
const STEP_T = { t0: 0, lastEnd: 0, build: 0, read: 0, emit: 0, gap: 0, n: 0 };
export function stepTraceReport(): string {
  const per = (x: number) => (STEP_T.n ? (x / STEP_T.n).toFixed(3) : "0");
  const s = `steps=${STEP_T.n} build=${per(STEP_T.build)}ms read=${per(STEP_T.read)}ms emit=${per(STEP_T.emit)}ms gap=${per(STEP_T.gap)}ms (per step)`;
  STEP_T.t0 = STEP_T.lastEnd = STEP_T.build = STEP_T.read = STEP_T.emit = STEP_T.gap = STEP_T.n = 0;
  return s;
}

let nextMixedWorkId = 0;

export class MlxBatchExecutionGroup {
  readonly #tasks = new ExecutionTasks();
  readonly #runtime: RuntimeConfig;
  readonly #noPipeline: boolean;
  readonly #stepTrace: boolean;
  readonly #stateCodecs: import("../state/persistence-types").CacheCodecProvider | undefined;
  readonly #maxQueued: number;
  #running: Row[] = [];
  /** Per-layer state of the running rows; null when empty. A lone row that
   *  never merged keeps the serial caches its prefill built; every merge
   *  replaces them with each layer's own row layout (state/layout). */
  #inners: Cache[] | null = null;
  #pending: Row[] = [];
  #prefill: MlxGroupPreparation | null = null; // the (single) joiner mid-prefill
  #preparationPublishedOutput = false;
  /** Sampled-but-unread token array [B], aligned with #running — the decode
   *  pipeline register. Filtered/disposed alongside the batched KV. */
  #pendingToks: MlxArray | null = null;
  /** Per-slot flags for #pendingToks: true = a REAL sampled token of that
   *  row's stream; false = a doomed/terminated row's placeholder (fed-token
   *  accounting must skip it — see Row.fed/fedTainted). Filtered/cleared in
   *  lockstep with the register. */
  #pendingReal: boolean[] | null = null;
  #method: MlxGroupedMethod | undefined;
  #methodKey: string | undefined;
  #decodeStateKey: string | undefined;
  #steps = 0; // decode-step counter (clearCache cadence)
  #cacheMaintenanceSteps = 0;
  #looping = false;
  #closed = false;
  #driver: Promise<void> | null = null;
  #wake: (() => void) | null = null;
  readonly #maxBatch: number;
  readonly #lock: ExclusiveLock | undefined;
  readonly #admissionHeld: (() => boolean) | undefined;
  readonly #prefillChunkSize: number;
  readonly #prefillPolicy: PrefillPolicy;
  readonly #prefillBatchTokenLimit: number;
  readonly #prefillTailSplit: boolean;
  readonly #kvBudgetBytes: number | undefined;
  readonly #defaultPromptCache: RowPromptCache | undefined;
  #statePolicy?: MlxRequestStatePolicy;
  get #promptCache(): RowPromptCache | undefined {
    return this.#statePolicy ? this.#statePolicy.promptCache : this.#defaultPromptCache;
  }
  /** Retain hook of the currently-ADOPTED row's cache entry (at most one:
   *  only a lone adopted row holds un-copied entry caches). Runs after the
   *  adopted caches are disposed, or transfers back on put(). */
  #adoptedRetain: (() => void) | null = null;
  #contextKey: string | undefined;
  #releaseContext: (() => void) | undefined;
  /** Attention layers a plain-KV graph reads plain, bound once; null otherwise. */
  readonly #denseKvLayers: readonly number[] | null;
  readonly #compressedProjectors: Array<(tokens: number) => number> | null;
  readonly #batchCacheMaxTokens: number | null;
  readonly #kvScheme: KvScheme | undefined;
  readonly #maintainKv: KvMaintenance | null;
  /** The graph's declared compiled decode step, for the B=1 case whose state
   *  layout it accepts (kill switch MLX_BUN_COMPILED_DECODE; adapter requests
   *  disable replay in their plan). Set to null permanently on a failed step
   *  (a direct generation disables per generation; the scheduler is one
   *  long-lived "generation"). */
  #compiled: MlxCompiledDecodeStep | null;

  constructor(private readonly model: MlxTokenGraph, opts: MlxBatchExecutionGroupOptions) {
    this.#runtime = opts.runtime ?? runtimeConfig();
    this.#noPipeline = this.#runtime.value("MLX_BUN_BATCH_NO_PIPELINE") === "1";
    this.#stepTrace = this.#runtime.value("MLX_BUN_BATCH_STEP_TRACE") === "1";
    this.#maxQueued = opts.maxQueued ?? 64;
    if (!Number.isSafeInteger(this.#maxQueued) || this.#maxQueued < 1) throw new Error("invalid batch queue limit");
    this.#stateCodecs = opts.stateCodecs;
    this.#maxBatch = Math.max(1, Math.floor(opts.maxBatch));
    this.#lock = opts.lock;
    this.#admissionHeld = opts.admissionHeld;
    this.#prefillPolicy = resolveMlxPrefillPolicy(model, this.#runtime, opts.prefillChunkSize);
    this.#prefillChunkSize = this.#prefillPolicy.chunkSize(0);
    this.#prefillBatchTokenLimit = opts.prefillBatchTokenLimit ?? 2048;
    this.#prefillTailSplit = this.#runtime.flag("MLX_BUN_PREFILL_TAIL_SPLIT", true);
    this.#kvBudgetBytes = opts.kvBudgetBytes;
    this.#defaultPromptCache = opts.promptCache;
    this.#kvScheme = opts.kvScheme;
    const proto = withRuntimeConfig(this.#runtime, () => model.makeCache()); // fresh caches hold no buffers
    if (this.#kvScheme && !this.#kvScheme.batchable(
      model.config,
      (layerIdx) =>
        isPlainKvCache(proto[layerIdx]) || isRotatingPlainCache(proto[layerIdx]),
      proto.length, opts.kvBatchCapabilities,
    )) {
      for (const cache of proto) cache.dispose();
      throw new Error(`unsupported KV scheme for batch scheduler: ${this.#kvScheme.kind}`);
    }
    // The graph's declared dense-read layers, bound once: a row whose next
    // append is not certified plain-readable there is rejected before any
    // shared append, after its pending output publishes.
    let denseKvLayers: readonly number[];
    try { denseKvLayers = bindRequiredDenseKvLayers(model.requiredDenseKvLayers, proto); }
    catch (error) { for (const cache of proto) cache.dispose(); throw error; }
    this.#denseKvLayers = denseKvLayers.length ? denseKvLayers : null;
    this.#compressedProjectors = proto.every(isBatchableCache)
      ? proto.map((cache) => (tokens: number) => cache.projectedBytes(tokens))
      : null;
    this.#batchCacheMaxTokens = proto.every(isBatchableCache)
      ? Math.min(...proto.map((cache) => cache.maxTokens ?? Infinity))
      : null;
    this.#maintainKv = this.#kvScheme?.quantized
      ? createKvMaintenance(this.#kvScheme.options)
      : null;
    for (const c of proto) c.dispose();
    this.#compiled = this.#runtime.flag("MLX_BUN_COMPILED_DECODE", true)
      ? withRuntimeConfig(this.#runtime, () => compiledDecodeStepOf(model))
      : null;
  }

  get activeRows(): number {
    return this.#running.length;
  }

  get pendingRows(): number {
    return this.#pending.length + (this.#prefill?.rows.length ?? 0);
  }

  /** Projected KV bytes of one row at its worst case (full prompt + full
   *  completion; the sliding-window term is window-capped by kvBytesAt). */
  #rowKvBytes(row: Row): number {
    return this.#compressedProjectors
      ? this.#compressedProjectors.reduce(
          (sum, project) => sum + project(row.promptTokens + row.req.maxTokens),
          0,
        )
      : batchRowKvBytes(
          this.model.config,
          row.promptTokens,
          row.req.maxTokens,
          this.#kvScheme,
        );
  }

  async #forwardHidden(ids: MlxArray, cache: Cache[]): Promise<MlxArray> {
    return typeof this.model.forwardHiddenAsync === "function"
      ? await this.model.forwardHiddenAsync(ids, cache)
      : this.model.forwardHidden(ids, cache);
  }

  /** Projected aggregate KV of everything admitted (running + mid-prefill). */
  get projectedKvBytes(): number {
    let total = this.#running.reduce((a, r) => a + this.#rowKvBytes(r), 0);
    if (this.#prefill) for (const row of this.#prefill.rows) total += this.#rowKvBytes(row);
    return total;
  }

  get kvBudgetBytes(): number | undefined {
    return this.#kvBudgetBytes;
  }

  /** KV-budget admission for the queue head. True = admit now. A candidate
   *  that cannot fit even alone is rejected here (never deadlocks the
   *  queue); one that fits alone but not alongside the current batch waits. */
  #kvAdmits(candidate: Row): boolean {
    const requestedTokens = candidate.promptTokens + candidate.req.maxTokens;
    if (
      this.#batchCacheMaxTokens !== null &&
      requestedTokens > this.#batchCacheMaxTokens
    ) {
      this.#pending.shift();
      candidate.reject(new RangeError(
        `context limit: prompt ${candidate.promptTokens} + max_tokens ` +
        `${candidate.req.maxTokens} exceeds ${this.#batchCacheMaxTokens}`,
      ));
      return false;
    }
    if (this.#kvBudgetBytes === undefined) return true;
    const need = this.#rowKvBytes(candidate);
    if (need > this.#kvBudgetBytes && this.#running.length === 0 && !this.#prefill) {
      this.#pending.shift();
      candidate.reject(
        new Error(
          `kv budget: request needs ~${(need / 1e9).toFixed(2)} GB KV ` +
            `(prompt ${candidate.promptTokens} + max_tokens ${candidate.req.maxTokens}), ` +
            `over --kv-budget ${(this.#kvBudgetBytes / 1e9).toFixed(2)} GB — ` +
            `lower max_tokens or raise the budget`,
        ),
      );
      return false;
    }
    return this.projectedKvBytes + need <= this.#kvBudgetBytes;
  }

  /** Submit a request; resolves when its row finishes (EOS, stop, or length). */
  submit(req: BatchRequest): Promise<BatchStats> {
    if (this.#closed) return Promise.reject(new Error("scheduler closed"));
    if (req.signal?.aborted) return Promise.reject(req.signal.reason);
    if (this.#pending.length >= this.#maxQueued) return Promise.reject(new AdmissionRejected());
    req = { ...req, prefillChunkSize: req.prefillChunkSize ?? this.#prefillPolicy.chunkSize(req.promptIds.length) };
    return new Promise<BatchStats>((resolve, reject) => {
      let abortListener: (() => void) | null = null;
      const cleanup = () => {
        if (abortListener) req.signal?.removeEventListener("abort", abortListener);
        abortListener = null;
      };
      this.#pending.push({
        req,
        resolve: (stats) => { cleanup(); resolve(stats); },
        reject: (error) => { cleanup(); reject(error); },
        current: 0, generated: 0, sampled: 0, promptTokens: req.promptIds.length,
        admittedAt: 0, firstTokenAt: 0,
        cachedTokens: 0, fed: [], fedTainted: false, merged: false,
      });
      if (req.signal) {
        abortListener = () => this.kick();
        req.signal.addEventListener("abort", abortListener, { once: true });
      }
      this.#ensureLoop();
    });
  }

  /** Wake the driver loop (e.g. after admissionHeld flips back to false). */
  kick(): void {
    this.#ensureLoop();
  }

  /** Read-only native preparation borrows a boundary of the live execution
   * group. Model mutation still requires the gateway's exclusive drain. */
  runPreparation<T>(work: () => Promise<T>, signal?: AbortSignal): Promise<T> {
    if (this.#closed) return Promise.reject(new Error("scheduler closed"));
    if (signal?.aborted) return Promise.reject(signal.reason);
    const cancellation = signal ? new CancellationSource() : undefined;
    const abort = () => cancellation?.cancel("requested");
    signal?.addEventListener("abort", abort, { once: true });
    const result = this.#tasks.enqueue(work, cancellation).catch(error => {
      throw error instanceof GenerationCancelled && signal?.aborted ? signal.reason : error;
    }).finally(() => signal?.removeEventListener("abort", abort));
    this.#ensureLoop();
    return result;
  }

  #ensureLoop(): void {
    if (this.#wake) { this.#wake(); return; }
    if (this.#looping || this.#closed) return;
    this.#looping = true;
    this.#driver = withRuntimeConfig(this.#runtime, () => this.#drive());
    void this.#driver.catch((error) => console.error(`batch scheduler cleanup failed: ${error}`));
  }

  /** Stop at the next safe work boundary and release all queued/active runs. */
  async close(): Promise<void> {
    this.#closed = true;
    this.#wake?.();
    await this.#driver;
  }

  async #drive(): Promise<void> {
    const scheduler = this;
    const group: ExecutionGroup = {
      get pendingTasks() { return scheduler.#tasks.pending; },
      advanceTask: () => this.#tasks.advance(),
      get active() { return scheduler.#running.length; },
      get queued() { return scheduler.#pending.length; },
      get preparing() { return scheduler.#prefill !== null; },
      get preparingRows() { return scheduler.#prefill?.rows.length ?? 0; },
      get canPrepareMore() { return scheduler.#prefill?.canAdmit === true; },
      get preparingTokens() { return scheduler.#prefill?.tokenWeight ?? 0; },
      // Cache restoration belongs to preparation. A queued request's prompt
      // length is an upper bound until its cache owner resolves the prefix.
      get nextPreparationTokens() { return scheduler.#pending[0]?.promptTokens ?? 0; },
      get maxPreparationTokens() { return scheduler.#prefillBatchTokenLimit; },
      get preparationPublishedOutput() { return scheduler.#preparationPublishedOutput; },
      get maxActive() { return scheduler.#maxBatch; },
      get admissionHeld() { return scheduler.#admissionHeld?.() === true; },
      get closed() { return scheduler.#closed; },
      pruneCancelled() {
        for (let i = scheduler.#pending.length - 1; i >= 0; i--) {
          const row = scheduler.#pending[i]!;
          if (!row.req.signal?.aborted) continue;
          scheduler.#pending.splice(i, 1);
          row.reject(row.req.signal.reason);
        }
      },
      admitNext: () => this.#admitNext(),
      canBurst: () => this.#contextCompatible(this.#pending[0]!) &&
        (this.#kvBudgetBytes === undefined ||
          this.projectedKvBytes + this.#rowKvBytes(this.#pending[0]!) <= this.#kvBudgetBytes),
      get mixedPreparation() {
        return scheduler.#decodeStateKey === undefined && scheduler.#prefill?.supportsMixedWork !== false && scheduler.#runtime.flag("MLX_BUN_MIXED_PREFILL", false) &&
          (!scheduler.#method || scheduler.#method.runningTokens !== undefined) &&
          typeof scheduler.model.forwardHiddenMixed === "function"
          ? { runningTokens: scheduler.#method?.runningTokens ?? scheduler.#running.length,
            minimumPreparationTokens: scheduler.#prefill?.rows.length ?? 0 }
          : undefined;
      },
      get maxIterationTokens() { return scheduler.#runtime.number("MLX_BUN_MIXED_TOKEN_BUDGET", 256); },
      advanceMixed: async tokenBudget => {
        this.#promptCache?.reclaim?.();
        const advanced = await runMixedTokenIteration({
          prepare: forward => this.#advancePreparation({ forward,
            maxTokens: tokenBudget - (this.#method?.runningTokens ?? this.#running.length) }),
          decode: forward => this.#method ? this.#method.advance(forward) : this.#step(forward),
          forward: async (ids, cache, options) => options?.captureLayer
            ? this.model.forwardHiddenMixed!([{ ids, cache, ...options }])[0]!
            : this.#forwardHidden(ids, cache),
          mixed: groups => {
            const workId = `mixed:${++nextMixedWorkId}`;
            const tokens = groups.map(group => group.ids.shape[0]! * group.ids.shape[1]!);
            const closes = [...this.#running, ...(this.#prefill?.rows ?? [])].map(row =>
              row.req.trace?.begin("engine.mixed_forward", { workId,
                decodeTokens: tokens[0]!, prefillTokens: tokens[1]!, packedTokens: tokens[0]! + tokens[1]! }));
            try { return this.model.forwardHiddenMixed!(groups); }
            finally { for (const close of closes) close?.(); }
          },
        });
        if (!advanced && this.#running.length) {
          if (this.#method) await this.#method.advance(); else await this.#step();
        }
      },
      advancePreparation: () => {
        this.#promptCache?.reclaim?.();
        return this.#advancePreparation();
      },
      advance: () => {
        if (this.#cacheMaintenanceSteps++ % 256 === 0) this.#promptCache?.reclaim?.();
        return this.#method ? this.#method.advance() : this.#step();
      },
      failActive: (error) => {
        for (const row of this.#running) row.reject(error);
        this.#applyFilter([], true); // failed state never enters the prefix store
      },
      failAll: (error) => this.#failAll(error),
      reserveResidency: () => {
        const release = acquireModelWiredLimit(this.model);
        return () => disposeResources([
          { dispose: () => this.#leaveContext() }, { dispose: release },
        ]);
      },
      ...(this.#lock ? { acquireExecution: () => this.#lock!.acquire() } : {}),
      waitForWork: async () => {
        await new Promise<void>((resolve) => { this.#wake = resolve; });
        this.#wake = null;
      },
    };
    try {
      await driveExecutionGroup(group, {
        now: () => performance.now(),
        yield: () => new Promise<void>((resolve) => setImmediate(resolve)),
      }, this.#runtime.flag("MLX_BUN_EARLY_FIRST_TOKEN", true));
    } finally { this.#looping = false; }
  }

  #contextCompatible(row: Row): boolean {
    return (!this.#running.length && !this.#prefill) || ((row.req.context?.key ?? "") === this.#contextKey && row.req.method?.key === this.#methodKey && row.req.statePolicy?.key === this.#statePolicy?.key && row.req.promptInput?.decodeState?.key === this.#decodeStateKey);
  }

  #leaveContext(): void {
    const release = this.#releaseContext;
    this.#releaseContext = undefined;
    this.#contextKey = undefined;
    release?.();
  }

  #admitNext(): boolean {
    if (!this.#contextCompatible(this.#pending[0]!) || !this.#kvAdmits(this.#pending[0]!)) return false;
    const row = this.#pending.shift()!;
    try {
      this.#statePolicy = row.req.statePolicy;
      this.#decodeStateKey = row.req.promptInput?.decodeState?.key;
      row.cacheNamespace = typeof row.req.cacheNamespace === "function"
        ? row.req.cacheNamespace() : row.req.cacheNamespace;
      const key = row.req.context?.key ?? "";
      if (key !== this.#contextKey) {
        this.#leaveContext();
        this.#releaseContext = row.req.context?.enter();
        this.#contextKey = key;
      }
      row.req.onAdmitted?.();
      row.admittedAt = performance.now();
      if (row.req.method?.key !== this.#methodKey) {
        this.#method?.dispose(); this.#method = undefined; this.#methodKey = undefined;
        if (row.req.method) {
          const executor = this;
          this.#method = row.req.method.open({
            get rows() { return executor.#running; }, runtime: this.#runtime,
            prefillChunkSize: this.#prefillChunkSize, promptCache: this.#promptCache,
            join: row => { this.#running.push(row); },
            filterRows: keep => this.#applyFilter(keep),
            publish: async (row, token, logprobs) => {
              row.req.signal?.throwIfAborted();
              this.#firstOutput(row);
              return row.req.onToken(token, logprobs);
            },
            finish: (row, reason) => this.#finish(row, reason),
          });
          this.#methodKey = row.req.method.key;
        }
      }
      if (this.#prefill) {
        this.#prefill.admit!(row);
      } else if (this.#method) {
        this.#prefill = this.#method.prepare(row);
      } else {
        const preparation = new MlxPrefillCohort({
          model: this.model, chunkSize: this.#prefillChunkSize, tailSplit: this.#prefillTailSplit,
          promptCache: this.#promptCache, stateCodecs: this.#stateCodecs, maintain: this.#maintainKv ?? undefined,
          ...(this.#denseKvLayers ? { denseKvReads: this.#denseKvLayers } : {}),
          forward: (ids, caches) => this.#forwardHidden(ids, caches),
          project: (hidden, caches, completed) => this.#projectPrefill(hidden, caches, completed),
          complete: (state, logits) => this.#completePrefill(state, logits),
          resume: state => this.#completePrefill(state, null),
          reject: (failed, error) => this.#rejectPreparingRows([failed], error),
        });
        preparation.admit(row); this.#prefill = preparation;
      }
    } catch (error) { row.reject(error); }
    return true;
  }

  #rejectPreparingRows(rows: readonly Row[], error: unknown): void {
    const retiring = new Set(rows);
    const keep = this.#running.flatMap((row, index) => retiring.has(row) ? [] : [index]);
    if (keep.length !== this.#running.length) this.#applyFilter(keep, true);
    for (const row of rows) row.reject(error);
  }

  async #advancePreparation(work?: MlxPreparationWork): Promise<void> {
    const p = this.#prefill!, rows = p.rows;
    this.#preparationPublishedOutput = false;
    try {
      if (await p.advance(work)) this.#prefill = null;
    } catch (error) {
      this.#prefill = null;
      let failure = error;
      try { p.dispose(); }
      catch (cleanupError) { failure = new AggregateError([error, cleanupError], "batch prefill and cleanup failed"); }
      try { this.#rejectPreparingRows(rows, failure); }
      catch (cleanupError) {
        failure = new AggregateError([failure, cleanupError], "batch admission retirement failed");
        for (const row of rows) row.reject(failure);
        this.#failAll(failure);
      }
    }
  }

  #failAll(error: unknown): void {
    this.#tasks.rejectAll(error);
    const p = this.#prefill;
    const rows = new Set([...this.#running, ...this.#pending, ...(p?.rows ?? [])]);
    const retain = this.#adoptedRetain;
    const resources = [p, this.#method, ...(this.#inners ?? []), this.#pendingToks,
      { dispose: () => retain?.() }]
      .filter((resource): resource is DisposableResource => resource != null);
    this.#pending = []; this.#running = []; this.#prefill = null;
    this.#method = undefined; this.#methodKey = undefined;
    this.#inners = null; this.#pendingToks = null; this.#pendingReal = null;
    this.#adoptedRetain = null;
    for (const row of rows) row.reject(error);
    disposeResources(resources);
  }

  /** Per-layer mixed-precision conversion of a joiner's SOLO caches — the
   *  scheduler-side mirror of the serial maybeQuantizeKv (generate.ts): same
   *  per-layer map, same skip rules (empty cache, already quantized), same
   *  streaming discipline (evalAll the converted layer's state so the bf16
   *  source frees before the next layer converts). Called at every prefill
   *  chunk boundary AND once before merge, exactly where the serial loop
   *  calls maybeQuantizeKv — that placement is what makes a row's quantized
   *  bytes bit-exact vs serial `--kv-quant config`. Gateway placement and the
   *  constructor both guarantee every named cache can convert. */
  #quantizeSolo(solo: Cache[], trace?: PromptResponseTrace): void {
    if (!this.#maintainKv) return;
    const close = trace?.begin("prefill.kv_maintenance", {
      mechanism: "continuous",
    });
    try {
      this.#maintainKv(solo);
    } finally {
      close?.();
    }
  }

  /** The target owns projection geometry; samplers receive individual rows. */
  #projectPrefill(hidden: MlxArray, caches: Cache[], completed: readonly PrefillState[]): MlxArray {
    for (const p of completed) {
      p.closePrefill?.(); p.closePrefill = undefined;
      p.row.closeTokenZero = p.row.req.trace?.begin("token_zero.total", { mechanism: "continuous" });
    }
    const attributed = this.#runtime.value("MLX_BUN_P2R_SYNC") === "1"
      ? completed.flatMap(p => p.row.req.trace ? [p.row.req.trace] : []) : [];
    const begin = (phase: "token_zero.forward" | "token_zero.head") => attributed.map(trace => trace.begin(phase, {
      mechanism: "continuous", activeBytes: activeMemory(), cacheBytes: cacheMemory(), peakBytes: peakMemory(),
    }));
    if (attributed.length) {
      const closes = begin("token_zero.forward");
      try { withResource(leaseCacheStates(caches), state => ops.evalAll([hidden, ...state])); }
      finally { for (const close of closes) close(); }
    }
    // Project before selecting rows: M4 quantized projection can use different
    // arithmetic at M=1. Tail-split preparation reaches this with N=1.
    const logits = this.model.logitsFromHidden(hidden);
    try {
      if (attributed.length) {
        const closes = begin("token_zero.head");
        try { ops.evalAll([logits]); } finally { for (const close of closes) close(); }
      }
      return logits;
    } catch (error) { logits.dispose(); throw error; }
  }

  /** Sample borrowed logits from the shared target projection. */
  async #completePrefill(p: PrefillState, logits: MlxArray | null): Promise<void> {
    if (p.continuation) {
      const saved = p.continuation, row = p.row;
      row.req.continuation!.resumeSampling(saved);
      const interval = row.req.continuation!.interval;
      this.#checkpointAt.set(row, (Math.floor(saved.generatedTokens / interval) + 1) * interval);
      row.firstTokenAt = performance.now();
      row.closeTokenZero?.(); row.closeTokenZero = undefined;
      this.#preparationPublishedOutput = true;
      for (const token of saved.cacheTokens.slice(row.req.promptIds.length)) {
        row.req.signal?.throwIfAborted();
        if (await row.req.onToken(token) === false)
          throw new Error("saved generation prefix triggered a terminal stop while replaying");
      }
      row.fed = saved.cacheTokens.slice(row.req.promptIds.length);
      row.generated = saved.generatedTokens + 1;
      row.sampled = saved.generatedTokens + 1;
      row.cachedTokens = Math.min(saved.cacheTokens.length, row.promptTokens);
      const stop = await this.#emit(row, saved.pendingToken);
      if (stop !== "continue") {
        this.#putOrDispose(p.solo, saved.cacheTokens, p.retain, row.cacheNamespace, row.req.cacheSessionId);
        p.solo = [];
        this.#finish(row, stop);
        return;
      }
      await this.#mergeJoiner(p);
      return;
    }
    if (!logits) throw new Error("ordinary prefill completed without logits");
    const forceAttribution = !!p.row.req.trace && this.#runtime.value("MLX_BUN_P2R_SYNC") === "1";
    const V = logits.shape[2]!;
    const last2 = ops.reshape(logits, [1, V]);
    const closeSample = forceAttribution
      ? p.row.req.trace!.begin("token_zero.sample", { mechanism: "continuous" })
      : undefined;
    let sampled: MlxArray;
    try { sampled = p.row.req.sample!(last2, 0); } finally { last2.dispose(); }
    // The first admission can seed the existing device-token register. Its
    // first decode forward then overlaps token-zero readback, just like every
    // later pipeline step. Grammar and explicit eager-output modes retain
    // their read-before-advance order.
    if (!this.#inners && !p.row.req.grammar && !this.#noPipeline &&
        !this.#runtime.flag("MLX_BUN_EARLY_FIRST_TOKEN", true) && !forceAttribution) {
      let owned: MlxArray | null = sampled;
      try {
        ops.asyncEvalAll([sampled]);
        p.row.sampled = 1;
        this.#quantizeSolo(p.solo, p.row.req.trace);
        await this.#mergeJoiner(p);
        this.#pendingToks = sampled;
        this.#pendingReal = [true];
        owned = null;
        return;
      } finally { owned?.dispose(); }
    }
    const tok = this.#readToken(sampled);
    closeSample?.();
    p.row.sampled = 1;
    p.row.generated = 1;

    // Grammar (B1): the mask0 was applied inside the sample closure (the
    // controller is primed at compile). After reading token 0, advance the
    // matcher — fires the async fill for the NEXT step, overlapping the merge
    // below. If the grammar is already satisfied at token 0 (a 1-token grammar,
    // e.g. guided_choice landing on a single-token option), emit + finish("stop")
    // WITHOUT merging into the batch — the row never joins #running.
    if (p.row.req.grammar) {
      p.row.req.grammar.accept(tok);
      if (p.row.req.grammar.isTerminated) {
        const stop = await this.#emit(p.row, tok);
        // Token 0 was sampled but never fed — the caches cover exactly the
        // prompt, a clean prompt-only entry (put-or-dispose).
        this.#putOrDispose(p.solo, p.row.req.promptIds, p.retain, p.row.cacheNamespace, p.row.req.cacheSessionId);
        this.#finish(p.row, stop === "continue" ? "stop" : stop);
        return;
      }
    }

    const stop = await this.#emit(p.row, tok);
    if (stop !== "continue") {
      this.#putOrDispose(p.solo, p.row.req.promptIds, p.retain, p.row.cacheNamespace, p.row.req.cacheSessionId);
      this.#finish(p.row, stop);
      return;
    }
    // Default tail-split path: the caches were already converted at the head
    // boundary above (oracle composition: prefill ids[:-1] → convert → L=1
    // step-0), so this call is an idempotent no-op (converted caches match
    // neither serial class). It is LOAD-BEARING only under
    // MLX_BUN_PREFILL_TAIL_SPLIT=0 — the old serial order: token 0 sampled
    // from the unconverted final-chunk logits, THEN the caches convert
    // (before decode step 1 == before the merge).
    this.#quantizeSolo(p.solo, p.row.req.trace);
    await this.#mergeJoiner(p);
    return;
  }

  /** Merge a fully-prefilled joiner with the running batch, layer by layer,
   *  each layer's own row layout doing the work (state/layout). Flushes the
   *  decode pipeline first so the row set is settled and the next step starts
   *  cold. */
  async #mergeJoiner(p: PrefillState): Promise<void> {
    await this.#flushPipeline();
    this.#maintainKv?.prepareBatch?.(p.solo);

    // ADOPT, don't copy: a row joining an EMPTY batch keeps its solo caches as
    // the batch inners — a pointer handoff, zero bytes moved. The copy happens
    // only when a SECOND row joins and a genuinely new layout must exist. The
    // prize beyond the saved copy: the lone row's caches stay the graph's own
    // serial caches, so the B=1 step is literally the direct graph, and compiled
    // decode and prompt-cache take/put become possible for it. Each layout's
    // mergeRows takes such an adopted row as its first row.
    if (!this.#inners) {
      this.#inners = p.solo; p.solo = [];
      this.#adoptedRetain = p.retain ?? null; p.retain = undefined;
      this.#running.push(p.row);
      return;
    }

    const prev = this.#inners;
    const merged: Cache[] = [];
    try {
      for (let layer = 0; layer < p.solo.length; layer++) {
        const solo = p.solo[layer]!;
        const layout = ownedCacheLayout(solo);
        if (!layout) throw new Error(`cache layer ${layer} (${solo.signature()}) has no batch layout`);
        merged.push(layout);
        layout.mergeRows([prev[layer]!, solo]);
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(merged)); }
    for (const c of prev) c.dispose();
    // An adopted row's entry-backed arrays are gone after the prev dispose;
    // run its retain now. The joiner's likewise after its solo dispose.
    this.#adoptedRetain?.();
    this.#adoptedRetain = null;
    const completed = p.solo; p.solo = [];
    const release = p.retain; p.retain = undefined;
    disposeResources([...completed, { dispose: () => release?.() }]);
    // Every row in a REAL merge has its KV interleaved in batched buffers —
    // no longer prompt-cache put() candidates.
    for (const r of this.#running) r.merged = true;
    p.row.merged = true;
    this.#inners = merged;
    this.#running.push(p.row);
  }

  /** One PIPELINED batched decode step (mlx-lm GenerationBatch._step):
   *  1. forward all rows from the UNREAD pending token array (or, pipeline
   *     cold, from the rows' last emitted tokens), sample each live row's next
   *     token on its [1,V] slice, asyncEval the new [B] token array;
   *  2. THEN sync-read the previous step's tokens (overlapping the readback
   *     with this step's compute), emit them, and evict finished rows.
   *  Rows that finish get one extra harmless KV write from the already-built
   *  step; filter drops the row (mlx-lm behaves identically). Length-finished
   *  rows are known in advance and are NOT sampled (placeholder slot). */
  async #step(forward?: MlxForwardWork): Promise<void> {
    if (this.#denseKvLayers && await this.#rejectUnreadable()) return;
    if (this.#stepTrace) {
      const now = performance.now();
      if (STEP_T.lastEnd) STEP_T.gap += now - STEP_T.lastEnd;
      STEP_T.t0 = now;
    }
    const rows = this.#running;
    const B = rows.length;
    const inners = this.#inners!;
    const decodeState = rows[0]?.req.promptInput?.decodeState;
    if (decodeState) {
      const states = rows.map(row => row.req.promptInput!.decodeState!);
      forward = async (ids, caches) => decodeState.forward(ids, caches, states);
    }

    // A row is live if it still needs tokens sampled; a row whose pending
    // unread token is its last (sampled == maxTokens) only awaits emission.
    const anyLive = rows.some((r) => r.sampled < r.req.maxTokens);
    // Grammar (B1): if any row has a LIVE grammar controller (not terminated,
    // still sampling), take the read-before-build shape — the matcher's
    // acceptToken needs the token id as a JS number, so the previous step's
    // [B] token array is read back NOW (before building the next graph),
    // accept()ed per row (firing async fills that overlap the forward), then
    // ready() is awaited before this step's sample. This is the serial loop's
    // grammar resolution transplanted to the batch. Batches with NO live
    // grammar row keep the pipelined path byte-identical (zero cost when
    // unused). The trade: while a grammar row is live the batch runs
    // effectively NO_PIPELINE (readback no longer overlaps GPU compute) —
    // bounded by the readback (~0.1 ms) + fills (0.004–0.19 ms/row, overlapped
    // with the graph build). Serial grammar pays the identical trade today.
    const hasLiveGrammar = anyLive && rows.some(
      (r) => r.req.grammar && !r.req.grammar.isTerminated,
    );
    if (hasLiveGrammar) return this.#stepGrammar(forward);

    let nextToks: MlxArray | null = null;
    let nextReal: boolean[] | null = null;
    if (anyLive) {
      // Fed-token accounting (prompt-cache put): a COLD step feeds each
      // row's `current` (values known now, always a real emitted token); a
      // pipelined step feeds the pending array, whose values are pushed at
      // the read below gated on the per-slot real flags.
      if (!this.#pendingToks) for (const r of rows) r.fed.push(r.current);
      // Each layer's state is its own row layout (state/layout), which supplies
      // the mask and per-row RoPE positions its rows need — and none when no
      // row is padded: with every leftPad 0 a layout is exactly the serial cache
      // (the empty N=1 mask, the shared scalar offset), so the B=1 case above
      // all dispatches the SAME per-step graph a direct generation builds,
      // without a host mask build + ~8 device nodes PER FULL LAYER PER TOKEN
      // (the constant ~4–6 ms/step host tax at B=1).
      // Compiled decode at B=1: after adopt-don't-copy, a lone row's caches
      // are the caches the graph itself made, so a graph that declares a
      // compiled step replays its recorded graph here — closing the batch
      // lane's last B=1 host-tax gap (e4b's ~7%). Guards: a declared step
      // (constructor), state the step accepts (a merged batch's layouts do
      // not), and a uint32 pipeline register (the trace signature;
      // per-row int32 samplers take the graph path).
      // Grammar batches use #stepGrammar and stay on the graph path.
      let lg: MlxArray | null = null;
      let evalWith: MlxArray[] = [];
      if (
        !forward && this.#compiled && B === 1 && this.#running[0]!.req.compiledDecode !== false &&
        (!this.#pendingToks || this.#pendingToks.dtype === Dtype.uint32) &&
        this.#compiled.accepts(inners as Cache[])
      ) {
        let cur = this.#pendingToks;
        let owned = false;
        if (!cur) {
          const i = ops.fromInt32([rows[0]!.current], [1]);
          cur = i.astype(Dtype.uint32);
          i.dispose();
          owned = true;
        }
        try {
          const r = this.#compiled.step(cur, inners as Cache[]);
          lg = r.logits; // [1,1,V]
          evalWith = r.evalWith;
        } catch (e) {
          // A failed step is transactional (see generate.ts) — safe to
          // re-forward the same token on the graph path below.
          this.#compiled = null;
          console.warn(`batch lane: compiled decode disabled: ${e}`);
        } finally {
          if (owned) cur.dispose();
        }
      }
      let fwd: Cache[] | null = null;
      try {
        if (!lg) {
          fwd = inners;
          const ids = this.#pendingToks
            ? ops.reshape(this.#pendingToks, [B, 1]) // feed the unread tokens
            : ops.fromInt32(rows.map((r) => r.current), [B, 1]); // pipeline cold
          const h = await (forward ? forward(ids, fwd) : this.#forwardHidden(ids, fwd));
          ids.dispose();
          lg = this.model.logitsFromHidden(h); // [B,1,V]
          h.dispose();
        }
        const V = lg.shape[2]!;
        // Vectorized homogeneous sampling (batching-perf-path P0): when every
        // LIVE row is plain greedy, one log-softmax+argmax over [B,V] replaces
        // B slice/sample/concat graphs. Per-row identical math (row-independent
        // ops, same per-row shapes — argmax over log-softmax mirrors the
        // closure's toLogprobs→argmax exactly, tie behavior included). Doomed
        // rows get a real argmax instead of the placeholder 0 — equally
        // harmless (the slot is filtered before it is ever emitted; its only
        // use is one KV write on the row's own, about-to-evict row).
        const vecOk =
          this.#runtime.value("MLX_BUN_BATCH_VEC_SAMPLE") !== "0" &&
          rows.every((r) => r.sampled >= r.req.maxTokens || r.req.plainGreedy);
        // Doomed slots hold placeholders (vec path: a real argmax value,
        // equally not part of the row's stream) — flag them so the fed
        // accounting at the read stays per-row exact.
        nextReal = rows.map((r) => r.sampled < r.req.maxTokens);
        if (vecOk) {
          const flat = ops.reshape(lg, [B, V]);
          lg.dispose();
          try { nextToks = independentGreedySampling.sample(flat); }
          finally { flat.dispose(); }
          for (const row of rows) if (row.sampled < row.req.maxTokens) row.sampled++;
        } else {
          const sampled: MlxArray[] = [];
          for (let b = 0; b < B; b++) {
            const row = rows[b]!;
            if (row.sampled >= row.req.maxTokens) {
              // Length-doomed row: evicted right after the emission below ever
              // uses this slot as input — placeholder keeps the [B] alignment.
              sampled.push(ops.fromInt32([0], [1]));
              continue;
            }
            const rl = lg.slice([b, 0, 0], [b + 1, 1, V]);
            const rl2 = ops.reshape(rl, [1, V]);
            rl.dispose();
            sampled.push(row.req.sample!(rl2, row.sampled));
            row.sampled++;
            rl2.dispose();
          }
          lg.dispose();
          nextToks = ops.concatAxis(sampled, 0); // [B]
          for (const t of sampled) t.dispose();
        }
        // dispatch; read NEXT iteration. evalWith: the compiled step's
        // cache-update nodes must ride the same async_eval (generate.ts).
        ops.asyncEvalAll([nextToks, ...evalWith]);
      } finally {
        // Free the step's RoPE arrays; the layouts persist across steps.
        if (fwd) for (const c of fwd) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
      }
    }
    this.#steps++;
    if (this.#steps % 256 === 0) clearCache(); // serial's cadence, not per-step
    if (this.#stepTrace) STEP_T.build += performance.now() - STEP_T.t0;

    // Read + emit the PREVIOUS step's tokens while the new step computes.
    const prev = this.#pendingToks;
    const prevReal = this.#pendingReal;
    this.#pendingToks = nextToks;
    this.#pendingReal = nextReal;
    // Kill switch / A-B lever (house style, cf. MLX_BUN_COMPILED_DECODE=0):
    // MLX_BUN_BATCH_NO_PIPELINE=1 reads THIS step's tokens synchronously —
    // set from process start `prev` is always null, so the flush below IS the
    // whole phase 2. Same math either way (pipelining is scheduling).
    if (this.#noPipeline) {
      if (this.#running.some(row => row.req.continuation)) this.#captureContinuations();
      await this.#flushPipeline();
      return;
    }
    if (prev) {
      const tRead = this.#stepTrace ? performance.now() : 0;
      const toks = prev.toIntTokens();
      prev.dispose();
      // These values were the step's forward input (fed) iff a forward ran.
      // Placeholder slots are excluded from `fed` — and taint their row if
      // they ever fed (see Row.fedTainted; structurally unreachable today).
      if (anyLive)
        for (let b = 0; b < B; b++) {
          if (!prevReal || prevReal[b]) rows[b]!.fed.push(toks[b]!);
          else rows[b]!.fedTainted = true;
        }
      if (this.#stepTrace) STEP_T.read += performance.now() - tRead;
      const tEmit = this.#stepTrace ? performance.now() : 0;
      await this.#emitRows(toks); // also filters #pendingToks on eviction
      if (this.#stepTrace) { STEP_T.emit += performance.now() - tEmit; STEP_T.n++; }
    }
    if (this.#running.some(row => row.req.continuation)) this.#captureContinuations();
    if (this.#stepTrace) STEP_T.lastEnd = performance.now();
  }

  readonly #checkpointAt = new WeakMap<Row, number>();
  /** Cache extraction belongs to this existing ordinary numerical driver;
   * the optional request port owns checkpoint eligibility and persistence. */
  #captureContinuations(): void {
    if (!this.#pendingToks || !this.#running.some(row => row.req.continuation)) return;
    let pending: number[] | undefined;
    const failed = new Set<number>();
    for (let index = 0; index < this.#running.length; index++) {
      const row = this.#running[index]!, policy = row.req.continuation;
      if (!policy || row.fedTainted || row.fed.length !== row.generated ||
          row.generated < (this.#checkpointAt.get(row) ?? policy.interval) ||
          this.#pendingReal?.[index] === false) continue;
      pending ??= this.#pendingToks.toIntTokens();
      const tokens = [...row.req.promptIds, ...row.fed];
      const caches = this.#running.length === 1 && !row.merged
        ? cloneSingleRowState(this.#inners! as Cache[], this.#stateCodecs)
        : this.#extractRowCaches(index, tokens.length);
      if (!caches) continue;
      try {
        policy.captureOwned({ caches, cacheTokens: tokens, generatedTokens: row.generated,
          pendingToken: pending[index]! });
        this.#checkpointAt.set(row, (Math.floor(row.generated / policy.interval) + 1) * policy.interval);
      } catch (error) { row.reject(error); failed.add(index); }
    }
    if (failed.size) this.#applyFilter(this.#running.flatMap((_, index) => failed.has(index) ? [] : [index]), true);
  }

  /** A graph reading plain KV: when a row's next append is not certified
   * plain-readable, publish every pending token first (a row may finish on
   * it), then reject the rows still not certified before any shared append.
   * True when the batch changed; the next step then starts cold. */
  async #rejectUnreadable(): Promise<boolean> {
    const layers = this.#denseKvLayers!;
    if (!this.#inners || !unreadableRows(this.#inners as Cache[], layers, this.#running.length).length) return false;
    await this.#flushPipeline();
    const unreadable = this.#inners ? unreadableRows(this.#inners as Cache[], layers, this.#running.length) : [];
    if (!unreadable.length) return true;
    const retiring = unreadable.map(row => this.#running[row]!);
    this.#applyFilter(this.#running.flatMap((_, row) => unreadable.includes(row) ? [] : [row]), true);
    // A consumer that cancelled while its last token published keeps its own reason.
    for (const row of retiring) row.reject(row.req.signal?.aborted ? row.req.signal.reason : new DenseKvReadError());
    return true;
  }

  /** Read out the pipeline register (if any): emit its tokens and evict
   *  finished rows, leaving the pipeline cold. Called before a join merges. */
  async #flushPipeline(): Promise<void> {
    const prev = this.#pendingToks;
    if (!prev) return;
    this.#pendingToks = null;
    this.#pendingReal = null; // flushed values never fed — nothing to account
    const toks = prev.toIntTokens();
    prev.dispose();
    // Grammar rows: the flushed tokens are EMITTED below, so their matchers
    // must advance here — #stepGrammar's accept only covers tokens it reads
    // from a live pending array, and after this flush it cold-starts (no
    // accept). Skipping this left the matcher one token behind its stream on
    // every mid-decode join → one-step-stale masks → invalid output (found
    // by the feature-matrix conformance gate, 2026-07-03; the fill fired
    // here is awaited by the next #stepGrammar's ready()).
    for (let b = 0; b < this.#running.length && b < toks.length; b++) {
      const g = this.#running[b]!.req.grammar;
      if (g && !g.isTerminated) g.accept(toks[b]!);
    }
    await this.#emitRows(toks);
  }

  /** The read-before-build decode step for batches with ≥1 live grammar row
   *  (B1). Mirrors the serial loop's grammar resolution: read the previous
   *  step's [B] tokens NOW (acceptToken needs JS numbers), accept() per row
   *  (fires async fills), build the forward graph (fills overlap), await
   *  ready(), sample per live row (the closure applies applyMask), then emit
   *  the values read in step 1 — no second readback. Terminated grammar rows
   *  keep their [B] slot through the forward (placeholder, not sampled) and
   *  finish("stop") in #emitRows. On a cold start (first step after prefill)
   *  there is no pending array to read; the prefill already accepted token 0
   *  and fired the fill, so we just await ready() + sample. */
  async #stepGrammar(forward?: MlxForwardWork): Promise<void> {
    const rows = this.#running;
    const B = rows.length;
    const inners = this.#inners!;

    // (1) Read the pending [B] token array (host copy for accept). The device
    //     array is kept for the forward input below; disposed after sampling.
    //     Cold start: pendingToks null → prevVals empty (prefill handled tok0).
    const prev = this.#pendingToks;
    const prevVals: number[] =
      prev ? prev.toIntTokens() : [];
    if (this.#runtime.value("MLX_BUN_GRAMMAR_DEBUG") === "1")
      console.log(`[sg] B=${B} prevVals=${JSON.stringify(prevVals)} current=${JSON.stringify(rows.map((r) => r.current))} sampled=${JSON.stringify(rows.map((r) => r.sampled))}`);

    // (2) accept() per live grammar row — fires that row's async bitmask fill.
    for (let b = 0; b < B && prevVals.length; b++) {
      const g = rows[b]!.req.grammar;
      if (g && !g.isTerminated) g.accept(prevVals[b]!);
    }

    let nextToks: MlxArray | null = null;
    let nextReal: boolean[] | null = null;
    const anyLive = rows.some((r) => r.sampled < r.req.maxTokens);
    if (anyLive) {
      // Fed-token accounting (prompt-cache put) — mirror of #step's read:
      // real slots push, a placeholder that fed taints its row.
      const prevReal = this.#pendingReal;
      if (prev)
        for (let b = 0; b < B; b++) {
          if (!prevReal || prevReal[b]) rows[b]!.fed.push(prevVals[b]!);
          else rows[b]!.fedTainted = true;
        }
      else for (const r of rows) r.fed.push(r.current);
      const fwd: Cache[] = inners;
      try {
        // (3) Build the forward graph (host-side; the fills overlap it).
        const ids = prev
          ? ops.reshape(prev, [B, 1]) // feed the unread tokens (device array)
          : ops.fromInt32(rows.map((r) => r.current), [B, 1]); // pipeline cold
        const h = await (forward ? forward(ids, fwd) : this.#forwardHidden(ids, fwd));
        ids.dispose();
        const lg = this.model.logitsFromHidden(h); // [B,1,V]
        h.dispose();
        const V = lg.shape[2]!;

        // (4) await ready() on every live grammar row — the fills fired in (2)
        //     overlapped the graph build above. Usually already resolved.
        const liveGrammar = rows.filter(
          (r) => r.req.grammar && !r.req.grammar.isTerminated,
        );
        if (liveGrammar.length)
          await Promise.all(liveGrammar.map((r) => r.req.grammar!.ready()));

        // (5) Sample per live row (the closure applies applyMask after the
        //     logits processors). Terminated grammar rows + length-doomed rows
        //     take a placeholder (one harmless KV write, then evicted).
        const sampled: MlxArray[] = [];
        nextReal = rows.map(
          (r) => r.sampled < r.req.maxTokens && !r.req.grammar?.isTerminated,
        );
        for (let b = 0; b < B; b++) {
          const row = rows[b]!;
          if (
            row.sampled >= row.req.maxTokens ||
            row.req.grammar?.isTerminated
          ) {
            sampled.push(ops.fromInt32([0], [1]));
            continue;
          }
          const rl = lg.slice([b, 0, 0], [b + 1, 1, V]);
          const rl2 = ops.reshape(rl, [1, V]);
          rl.dispose();
          sampled.push(row.req.sample!(rl2, row.sampled));
          row.sampled++;
          rl2.dispose();
        }
        lg.dispose();
        nextToks = ops.concatAxis(sampled, 0); // [B]
        for (const t of sampled) t.dispose();
        ops.asyncEvalAll([nextToks]);
      } finally {
        for (const c of fwd)
          (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
      }
    }
    this.#steps++;
    if (this.#steps % 256 === 0) clearCache();

    // The device array `prev` has now fed the forward + been read for accept;
    // dispose it and install the new pending array. On cold start prev is null.
    prev?.dispose();
    this.#pendingToks = nextToks;
    this.#pendingReal = nextReal;

    // (6) Emit the values read in (1) — no second readback. Terminated grammar
    //     rows finish("stop") via #emit's isTerminated check; the filter evicts.
    //     Cold start: prevVals empty (prefill emitted tok0) → nothing to emit.
    if (prevVals.length) await this.#emitRows(prevVals);
    if (this.#running.some(row => row.req.continuation)) this.#captureContinuations();
  }

  /** Emit one read-back token per running row; evict finished rows. A row's
   *  onToken throwing rejects THAT row and evicts it — siblings continue. */
  async #emitRows(toks: number[]): Promise<void> {
    const rows = this.#running;
    const B = rows.length;
    const keep: number[] = [];
    const done: { b: number; row: Row }[] = []; // clean finishes (stop/length)
    for (let b = 0; b < B; b++) {
      const row = rows[b]!;
      row.generated++;
      let disp: "continue" | "stop" | "length";
      try {
        disp = await this.#emit(row, toks[b]!);
      } catch (e) {
        row.reject(e); // containment: this row only (mlx-lm `remove`)
        row.merged = true; // poison: a rejected row is never put() back
        row.fedTainted = true;
        continue; // not kept → evicted by the filter below
      }
      if (disp === "continue") keep.push(b);
      else {
        done.push({ b, row });
        this.#finish(row, disp);
      }
    }
    if (keep.length < B) {
      // Per-row prompt-cache extraction (mlx-lm server.py:864-880 →
      // BatchGenerator.extract_cache): a MERGED row's KV lives interleaved
      // in the batched inners, so it is pulled out into fresh serial caches
      // BEFORE filter() mutates them. Never-merged lone rows skip this —
      // #applyFilter's keep=[] path put()s their adopted caches zero-copy.
      // Rejected rows aren't in `done`; the whole-batch error path calls
      // #applyFilter(dropOnly) directly and never reaches here.
      for (const { b, row } of done) this.#extractAndPut(b, row);
      this.#applyFilter(keep);
    }
  }

  /** Account one sampled token for a row. Mirrors generate(): EOS terminates
   *  WITHOUT an onToken call; otherwise onToken(token) runs and `false` halts;
   *  reaching maxTokens ends with "length". Advances row.current on continue. */
  async #emit(row: Row, token: number, logprobs?: import("../generation/index").TokenLogprobs): Promise<"continue" | "stop" | "length"> {
    row.req.signal?.throwIfAborted();
    this.#firstOutput(row);
    if (row.generated === 1) clearCache();
    if (row.req.eosTokenIds.includes(token)) return "stop";
    const cont = await row.req.onToken(token, logprobs);
    if (cont === false) return "stop";
    // Grammar termination: the matcher is satisfied (e.g. closing `}` accepted).
    // The final token has been delivered via onToken above; halt with "stop" so
    // the row finishes + evicts rather than sampling into an all--inf mask.
    if (row.req.grammar?.isTerminated) return "stop";
    if (row.generated >= row.req.maxTokens) return "length";
    row.current = token;
    return "continue";
  }

  #firstOutput(row: Row): void {
    if (row.generated === 1) {
      if (this.#prefill?.rows.includes(row)) this.#preparationPublishedOutput = true;
      row.firstTokenAt = performance.now();
      row.closeTokenZero?.();
      row.closeTokenZero = undefined;
    }
  }

  #finish(row: Row, reason: "stop" | "length"): void {
    row.req.continuation?.complete();
    const span = row.decodeSpan;
    const now = span?.end ?? performance.now();
    const first = span?.start ?? (row.firstTokenAt || now);
    row.resolve({
      ...(row.spec ? { spec: row.spec } : {}),
      ...(row.fill ? { fill: row.fill } : {}),
      promptTokens: row.promptTokens,
      generatedTokens: row.generated,
      cachedTokens: row.cachedTokens,
      finishReason: reason,
      prefillMs: row.admittedAt ? first - row.admittedAt : 0,
      decodeMs: span || row.firstTokenAt ? now - first : 0,
    });
  }

  /** Finish-time disposition of serial-class caches covering exactly
   *  `tokens`: put() into the prompt cache when the hook is present and the
   *  offset lines up (defensive — a mismatch means the accounting is wrong
   *  and the entry would corrupt future hits), else dispose. `retain` rides
   *  along per the PromptCacheEntry contract (runs after dispose). */
  #putOrDispose(caches: Cache[], tokens: number[], retain?: () => void, namespace = "", sessionId?: string): void {
    if (this.#promptCache) {
      // A never-merged row can still own a row layout. Persistence receives
      // its existing serial representation, just like merged-row retirement.
      const extracted: Cache[] = [], replaced: Cache[] = [];
      let persistent: Cache[];
      try {
        persistent = caches.map(cache => {
          if (!isBatchableCache(cache) || cache.batchSize !== 1) return cache;
          const row = cache.extractRow(0);
          extracted.push(row); replaced.push(cache);
          return row;
        });
      } catch (error) { disposeResources(extracted); throw error; }
      try { disposeResources(replaced); }
      catch (error) { disposeResources(extracted); throw error; }
      caches = persistent;
      const withOff = caches.find(
        (c) => typeof (c as { offset?: unknown }).offset === "number",
      ) as { offset: number } | undefined;
      if (withOff && withOff.offset === tokens.length) {
        this.#promptCache.put(tokens, caches, namespace, retain, undefined, sessionId);
        return;
      }
    }
    for (const c of caches) c.dispose();
    retain?.();
  }

  /** Extract a finishing MERGED row's KV into fresh serial caches and put()
   *  them keyed by [promptIds + fed] — the batch-lane mirror of mlx-lm
   *  server.py:872 (extract_cache → prompt_cache.insert_cache). Gates:
   *  promptTokens >= 256 or an explicit cache session, plus an exact
   *  coverage key (!fedTainted). Refusal
   *  (#extractRowCaches null) just disposes-by-omission — the row's KV dies
   *  with the filter, exactly the pre-extraction behavior. */
  #extractAndPut(b: number, row: Row): void {
    if (!this.#promptCache || !row.merged || row.fedTainted) return;
    if (row.promptTokens < 256 && !row.req.cacheSessionId) return;
    const tokens = [...row.req.promptIds, ...row.fed];
    const caches = this.#extractRowCaches(b, tokens.length);
    if (!caches) return;
    // Materialize the owned copies without stalling the in-flight step (the
    // slices depend on this step's KV writes): async — the batched source
    // buffers free once the copies land, instead of being pinned by a lazy
    // graph inside an idle cache entry.
    withResource(leaseCacheStates(caches), state => ops.asyncEvalAll([...state]));
    this.#putOrDispose(caches, tokens, undefined, row.cacheNamespace, row.req.cacheSessionId);
  }

  /** Row `b` of every layer as OWNED serial-class caches, or null when a
   *  layer cannot publish the row (then the caller drops the row's KV as
   *  before). Bit-exactness: merge/extend/filter/decode are byte-preserving
   *  per row (`02d723a:tests/parity/batched-decode-parity.test.ts`,
   *  `02d723a:tests/unit/batched-rotating.test.ts`,
   *  packages/inference/tests/state/batched-rotating-quant.test.ts) and each
   *  extract is a pure slice+copy of those bytes
   *  (`02d723a:tests/unit/batched-extract.test.ts`), so an extracted row's bytes ==
   *  the solo run's. A layer that cannot be trimmed (recurrent state) refuses a
   *  row whose own count is not the key's `expectTokens` exactly, defensively:
   *  a mismatched entry would silently corrupt every future exact hit. */
  #extractRowCaches(b: number, expectTokens: number): Cache[] | null {
    const out: Cache[] = [];
    for (const inner of this.#inners!) {
      // Adopted serial state never coexists with a merged row (defensive).
      const c = isBatchableCache(inner) && (inner.canPublishRow?.(b, expectTokens) ?? true) ? inner.extractRow(b) : null;
      if (!c) {
        for (const d of out) d.dispose();
        return null;
      }
      out.push(c);
    }
    return out;
  }

  /** Evict rows not in `keep` (sorted ascending) from the batched KV and the
   *  pipeline register. */
  #applyFilter(keep: number[], dropOnly = false): void {
    if (this.#method) {
      this.#method.filterRows(keep, dropOnly);
      this.#running = keep.map(row => this.#running[row]!);
      return;
    }
    const inners = this.#inners!;
    if (keep.length === 0) {
      // Prompt-cache put: a lone NEVER-MERGED row's inners are
      // its adopted serial-class caches, covering exactly prompt+fed — hand
      // them back to the cache instead of disposing. dropOnly (the batch-
      // drop error path) and poisoned rows dispose as before; MERGED rows'
      // KV was already extracted per row in #emitRows (owned copies), so
      // disposing the batched inners here is safe either way.
      const solo =
        !dropOnly && this.#running.length === 1 && !this.#running[0]!.merged
          ? this.#running[0]!
          : null;
      if (solo) {
        this.#putOrDispose(
          inners,
          [...solo.req.promptIds, ...solo.fed],
          this.#adoptedRetain ?? undefined,
          solo.cacheNamespace, solo.req.cacheSessionId,
        );
      } else {
        for (const c of inners) c.dispose();
        this.#adoptedRetain?.();
      }
      this.#adoptedRetain = null;
      this.#inners = null;
      this.#running = [];
      this.#pendingToks?.dispose();
      this.#pendingToks = null;
      this.#pendingReal = null;
      return;
    }
    // Each layout evicts the rows and whatever padding the survivors share
    // (mlx-lm BatchKVCache.filter); each row's absolute RoPE position stays
    // unchanged.
    for (const inner of inners) {
      // Adopted lone-row state exists only at B=1, where the only filter is the
      // keep=[] dispose-all handled above — unreachable.
      if (!isBatchableCache(inner))
        throw new Error(`applyFilter: adopted ${inner.signature()} state cannot be row-filtered`);
      inner.filterRows(keep);
    }
    this.#running = keep.map((i) => this.#running[i]!);
    if (this.#pendingToks) {
      const idx = ops.fromInt32(keep, [keep.length]);
      const next = ops.takeAxis(this.#pendingToks, idx, 0);
      idx.dispose();
      this.#pendingToks.dispose();
      this.#pendingToks = next;
    }
    if (this.#pendingReal) this.#pendingReal = keep.map((i) => this.#pendingReal![i]!);
  }

  #readToken(t: MlxArray): number {
    const v = t.toIntTokens()[0]!;
    t.dispose();
    return v;
  }
}

import { BatchRequest,BatchStats,ExclusiveLock,MlxBatchExecutionGroupOptions,MlxGroupedMethod,MlxGroupPreparation,Row,RowPromptCache } from "./batch-types";
import { DenseKvReadError, bindRequiredDenseKvLayers, unreadableRows } from "../state/dense-kv-reads";
export { type BatchRequest,type BatchRequestFields,type BatchStats,type ExclusiveLock,type MlxBatchExecutionGroupOptions,type MlxGroupedMethod,type MlxGroupMethodHost,type MlxGroupMethodRequest,type MlxGroupPreparation,type Row,type RowPromptCache,type RowSampler } from "./batch-types";
