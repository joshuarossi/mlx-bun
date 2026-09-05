import type { ExecutionGroup } from "../../contracts/scheduling";
import { driveExecutionGroup } from "../../engine/scheduler";
import { disposeResources } from "../../engine/resources";
import type { DisposableResource } from "../../contracts/resources";
import { nextPrefillStep } from "../../inference/prefill";
import { executeMlxPrefillStep } from "./prefill";
// Continuous-batching scheduler for `--batch N` serving (phase S2, the engine
// loop). Owns ONE running batch and drives it forward one decode step at a
// time, admitting waiting requests and evicting finished ones between steps —
// iteration-level (continuous) scheduling, not static batching. See
// docs/design/batching.md and docs/design/batching.md.
//
// The numerically-hard parts are verified primitives:
//   - the batched FORWARD (per-row RoPE/mask) is bit-parity with mlx-lm B=N
//     across all 4 models (tests/batched-decode-parity);
//   - the dynamic-B FULL-attention ops mergeKVRows / filterKVRows match mlx-lm
//     BatchKVCache (tests/batched-decode-parity), and the SLIDING-window
//     BatchedRotatingCache (merge/filter/decode/make_mask incl. ring-wrap)
//     matches mlx-lm BatchRotatingKVCache (tests/batched-rotating).
// This module is the ORCHESTRATION on top: admission, the step loop, per-row
// sampling + token accounting, eviction, and assembling each layer's batched
// cache by type. Gate: tests/parity/batch-scheduler.test.ts (teacher-forced, KL).
//
// Per-layer cache types: a model interleaves full-attention layers (plain
// KVCache, wrapped per step in a BatchedDecodeMaskCache) and sliding-window
// layers (a persistent BatchedRotatingCache that is itself the batched cache +
// mask). Full layers share one leftPad/offset (all rows advance together); the
// rotating caches self-track per-row leftPad/offset as the ring wraps. The
// per-row absolute position stays consistent across both (full: offset-leftPad;
// rot: offsetArr) — see docs/design/batching.md. Hybrid gated-DeltaNet
// models (Qwen3.5) add "ssm" layers: SSMCache state is plain [B,...] with no
// temporal axis and no padding (rows solo-prefill unpadded, decode feeds one
// real token per row), so merge/filter are B-axis concat/take and the cache
// passes through the step unwrapped (no mask, no per-row RoPE — full layers
// carry positions). Gate: GenerationGateway.place on cache capability.
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
// Joins re-merge the whole batch; the keep-the-running-batch `extend`
// optimization is a later refinement (batching-v2-plan item a).

import { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import { activeMemory, cacheMemory, clearCache, Dtype, peakMemory } from "../../mlx/ffi";
import { runtimeConfig } from "../../runtime-config";
import { runtimeValue } from "../../runtime-config";
import { CompiledDecode } from "../../model/compiled-decode";
import type { Gemma4Model } from "../../model/gemma4";
import {
  KVCache, QuantizedKVCache, RotatingKVCache, RotatingQuantizedKVCache,
  cacheSignature,
  isBatchableCache,
  isPlainKvCache,
  isQuantizedKvCache,
  isRotatingPlainCache,
  isRotatingQuantizedCache,
  isRowBatchCache,
  type BatchableCache,
  type Cache,
} from "../../model/gemma4-base";
import { BatchedDecodeMaskCache, mergeKVRows, extendKVRows, extractKVRow, filterKVRows } from "../../model/batched-mask";
import {
  BatchedQuantDecodeMaskCache, extendQuantRows, extractQuantRow, filterQuantRows, mergeQuantRows,
  type QuantRow,
} from "../../model/batched-quant";
import { BatchedRotatingQuantCache } from "../../model/batched-rotating-quant";
import type { KvQuantSpec } from "../../config";
import type { KvScheme } from "../../kv-scheme";
import { BatchedRotatingCache } from "../../model/batched-rotating";
import { cloneKvCaches } from "../../kv-store";
import { SSMCache } from "../../model/qwen3-delta";
import type { RuntimeModel } from "../../model/factory";
import type { GrammarController } from "../../grammar";
import { toLogprobs } from "../../sampler";
import { acquireModelWiredLimit } from "../../generate";
import { batchRowKvBytes } from "../../serve/kv-budget";
import type { PromptResponseTrace } from "../../serve/prompt-response-trace";

/** Decode-pipeline kill switch (read once at load, like the serial loop's
 *  MLX_BUN_COMPILED_DECODE): 1 ⇒ read each step's tokens synchronously. */
const NO_PIPELINE = runtimeValue("MLX_BUN_BATCH_NO_PIPELINE") === "1";

/** Per-step phase timing (MLX_BUN_BATCH_STEP_TRACE=1, debug-only): where a
 *  decode step's wall time goes — graph BUILD+dispatch (host), the pipelined
 *  READ of the previous step's tokens (GPU wait), row EMIT (onToken/SSE), and
 *  the GAP between consecutive steps (drive-loop + everything else). Sums
 *  print via `stepTraceReport()` (the b1 profile experiment calls it). */
const STEP_TRACE = runtimeValue("MLX_BUN_BATCH_STEP_TRACE") === "1";
const STEP_T = { t0: 0, lastEnd: 0, build: 0, read: 0, emit: 0, gap: 0, n: 0 };
export function stepTraceReport(): string {
  const per = (x: number) => (STEP_T.n ? (x / STEP_T.n).toFixed(3) : "0");
  const s = `steps=${STEP_T.n} build=${per(STEP_T.build)}ms read=${per(STEP_T.read)}ms emit=${per(STEP_T.emit)}ms gap=${per(STEP_T.gap)}ms (per step)`;
  STEP_T.t0 = STEP_T.lastEnd = STEP_T.build = STEP_T.read = STEP_T.emit = STEP_T.gap = STEP_T.n = 0;
  return s;
}

// NOTE — oMLX-style "adaptive burst decode" (several steps per event-loop
// yield, omlx/engine_core.py _step_burst) was ported here 2026-07-02 and
// REFUTED by measurement: on this runtime it REGRESSED cpm5 B=4 aggregate
// 345→289 tok/s, batch-lane B=1 149→121, and TTFT ~+100 ms (first-token SSE
// flush waits out the burst budget). Their win exists because each Python
// step hand-off ping-pongs the GIL with asyncio/uvicorn (~1 ms/token); Bun's
// setImmediate hop costs microseconds, so bursting here only delays socket
// flushes. Don't re-add without new evidence — the per-yield step below is
// the measured optimum (docs/design/batching.md P4 notes).

/** A token sampler for one row: (logits [1,V], step) → token array [1] on
 *  device. Greedy is `(l) => ops.argmaxAxis(l, -1)`; richer closures fold in
 *  temperature / top-p / logits processors + history (built per request from
 *  its sampler options, exactly like generate()'s sampleStep). Called once per
 *  step 0..maxTokens-1 for this row (never beyond maxTokens). */
export type RowSampler = (logits1V: MlxArray, step: number) => MlxArray;

export interface BatchRequest {
  promptIds: number[];
  maxTokens: number;
  eosTokenIds: number[];
  sample: RowSampler;
  /** Called per emitted (non-EOS) token, in order. Returning `false` halts this
   *  row (a decoded-text stop sequence fired) — matches generate()'s onToken
   *  contract. EOS terminates the row WITHOUT an onToken call. Throwing evicts
   *  THIS row only (its submit promise rejects; siblings continue). May be
   *  async; keep it cheap — it runs inline in the step loop. */
  onToken: (token: number) => void | boolean | Promise<void | boolean>;
  /** Diagnostic-only request-local trace. */
  trace?: PromptResponseTrace;
  /** Closes the gateway's queue/admission span when this row leaves pending. */
  onAdmitted?: () => void;
  /** Client/request lifetime. An aborted pending row is removed before
   *  admission; a row in prefill or decode is evicted at the next safe
   *  scheduler boundary. */
  signal?: AbortSignal;
  /** The row's sampler is PLAIN GREEDY (temperature 0, no curve) with no
   *  logits processors and no grammar — set by the gateway when true. Lets
   *  the scheduler take the vectorized sampling fast path (ONE
   *  log-softmax+argmax over [B,V] instead of B slice/sample/concat graphs)
   *  when EVERY live row qualifies. Numerically identical per row
   *  (row-independent ops, same per-row shapes); the per-row closure path
   *  is the fallback and the MLX_BUN_BATCH_VEC_SAMPLE=0 kill switch. */
  plainGreedy?: boolean;
  /** Grammar controller for this row (B1: per-row matchers). When set, the
   *  scheduler drives it: `accept()` after each emitted token (fires the async
   *  bitmask fill), `await ready()` before the row's next sample (the sample
   *  closure applies `applyMask`). Termination (grammar satisfied) is an
   *  additional per-row stop source. The gateway OWNS disposal (finally around
   *  submit()); the scheduler uses but never owns. Null on the degrade path. */
  grammar?: GrammarController;
  /** Stable cache boundary from the server's template probe (the serial
   *  lane's options.snapshotAt): the prompt prefix the NEXT turn's render
   *  preserves. The scheduler snapshots a trim-free prompt-cache entry at
   *  min(this, promptIds.length-1) during the solo prefill — the oracle
   *  invariant (mlx-lm insert_segments) that gives wrapped-ring models a
   *  reuse path. Absent = still capped at promptIds.length-1. */
  snapshotAt?: number;
}

export interface BatchStats {
  promptTokens: number;
  generatedTokens: number;
  /** Prompt tokens served from the prompt cache (Phase 3.2): a joiner's solo
   *  prefill starts from the longest usable cached prefix, exactly like the
   *  serial lane's runGeneration take(). 0 on a cold prefill. */
  cachedTokens: number;
  finishReason: "stop" | "length";
  /** Wall-clock from admission (leaving the pending queue) to the first
   *  emitted token — the row's prefill span on the batch lane. */
  prefillMs: number;
  /** Wall-clock from the first emitted token to finish. */
  decodeMs: number;
}

/** The slice of PromptCache the scheduler drives (structural — the server's
 *  PromptCache satisfies it). take() on admission (any joiner: a restored
 *  prefix + suffix prefill is byte-safe whether the row later merges or
 *  not). put() paths: rows that finish NEVER-MERGED (adopted lone rows,
 *  Phase 3.2) hand their pristine serial caches over zero-copy; rows that
 *  finish INSIDE a multi-row batch get their KV EXTRACTED per row into
 *  fresh serial caches first (mlx-lm server.py:872 extract_cache — the
 *  cross-request reuse concurrent agents live on). */
export interface RowPromptCache {
  take(prompt: number[], ns?: string): {
    tokens: number[]; caches: Cache[]; retain?: () => void;
  } | null;
  put(tokens: number[], caches: Cache[], ns?: string, retain?: () => void): void;
}

interface Row {
  req: BatchRequest;
  resolve: (s: BatchStats) => void;
  reject: (e: unknown) => void;
  current: number; // last emitted token, fed at the next step (pipeline cold)
  generated: number; // tokens emitted so far (incl. a terminating EOS)
  sampled: number; // sample() calls so far (leads `generated` by 1 in-pipeline)
  promptTokens: number;
  /** Prompt tokens restored from the prompt cache at admission (stats). */
  cachedTokens: number;
  /** performance.now() marks for BatchStats timing (0 = not reached). */
  admittedAt: number;
  firstTokenAt: number;
  /** Generated tokens whose KV actually entered the cache (fed as a step
   *  input) — serial generate()'s `forwarded` list. promptIds+fed is the
   *  exact token coverage of the row's caches, the put() entry key.
   *  PER-ROW EXACT for every row: pushes are gated on the pending
   *  register's per-slot real/placeholder flags (#pendingReal), so a
   *  doomed slot's placeholder is never recorded — and if one ever DID
   *  feed a forward, `fedTainted` flips instead (see #step's read). */
  fed: number[];
  /** A placeholder slot value fed this row's KV (junk token in the cache):
   *  the coverage key is no longer derivable — extraction refuses.
   *  Structurally unreachable today (a doomed row always evicts at the
   *  emit that follows its placeholder, filtering the slot before the
   *  next forward; cold steps never contain doomed rows because a flush
   *  emits every in-flight token) — this flag makes `fed` provably exact
   *  instead of resting on that timing chain. */
  fedTainted: boolean;
  /** Ever merged into a multi-row batch (or poisoned by a reject): its KV
   *  is interleaved in batched buffers — a finish put() must EXTRACT the
   *  row (#extractRowCaches) rather than adopt the inners. */
  merged: boolean;
}

/** A joiner mid-prefill: `pos` prompt tokens are already in `solo`. Advanced
 *  one chunk per loop iteration, interleaved with batch decode steps. */
interface PrefillState {
  row: Row;
  solo: Cache[];
  pos: number;
  /** Release hook carried by an SSD-restored prompt-cache entry (must run
   *  only after `solo`/the adopted caches are disposed — see PromptCacheEntry). */
  retain?: () => void;
  /** Pending boundary-snapshot position: #prefillChunk splits its chunking
   *  exactly here, clones + put()s the trim-free prefix entry, then nulls
   *  it. null = no snapshot for this row (short prompt / cached past it). */
  snapAt: number | null;
  closePrefill?: () => void;
}

/** Held while the batch is active; the serial fallback acquires the same lock. */
export interface ExclusiveLock {
  acquire(): Promise<() => void>;
}

export interface MlxBatchExecutionGroupOptions {
  /** Max rows in the running batch (mlx-lm `--decode-concurrency`). */
  maxBatch: number;
  lock?: ExclusiveLock;
  /** Drain signal: while true, no NEW rows are admitted (running rows finish,
   *  the lock is released) so a waiting serial-lane request can run — mlx-lm's
   *  drain_batch. Pair with kick() when it flips back to false. */
  admissionHeld?: () => boolean;
  /** Joiner prefill chunk length (default 2048, the serial loop's constant). */
  prefillChunkSize?: number;
  /** Aggregate KV-byte budget across all running rows (batching-perf-path
   *  P3 admission, via `--kv-budget`). A joiner whose PROJECTED KV
   *  (kvBytesAt(config, prompt + maxTokens), sliding window already capped)
   *  would push the batch's projected total over this ceiling WAITS in the
   *  queue (FIFO, head-of-line — no starvation, no reorder) until rows
   *  evict. A request that can NEVER fit (over budget alone, empty batch)
   *  is rejected instead of deadlocking. Unset = unlimited (v1 behavior). */
  kvBudgetBytes?: number;
  /** Authoritative server-wide scheme. Each joiner's solo prefill converts at
   * the same chunk boundaries as the serial path, so a row's quantized bytes
   * preserve the L2 composition. Unsupported schemes fail at construction. */
  kvScheme?: KvScheme;
  /** Prompt-cache hook (Phase 3.2): admission take()s the longest usable
   *  prefix into the joiner's solo caches (suffix-only prefill — the
   *  multi-turn chat TTFT path); rows that finish never-merged put() their
   *  caches back. Adapter requests never reach the batch lane, so the
   *  namespace is always "" here. Runs under the gateway mutex domain, so
   *  take/put never race the serial lane's use of the same cache. */
  promptCache?: RowPromptCache;
}

type LayerInner =
  | KVCache
  | QuantizedKVCache
  | BatchedRotatingCache
  | BatchedRotatingQuantCache // rot layer under a kv_config scheme (milestone 2)
  | RotatingKVCache // adopted lone-row state only (see #mergeJoiner adopt)
  | RotatingQuantizedKVCache // adopted lone-row state, quantized rot layer
  | SSMCache
  | BatchableCache;
type Row1 = { keys: MlxArray; values: MlxArray };

export class MlxBatchExecutionGroup {
  readonly #runtime = runtimeConfig();
  #running: Row[] = [];
  #inners: LayerInner[] | null = null; // per-layer batched KV; null when empty
  #fullLeftPad: number[] = []; // per-row padding for FULL layers (rot self-tracks)
  #pending: Row[] = [];
  #prefill: PrefillState | null = null; // the (single) joiner mid-prefill
  /** Sampled-but-unread token array [B], aligned with #running — the decode
   *  pipeline register. Filtered/disposed alongside the batched KV. */
  #pendingToks: MlxArray | null = null;
  /** Per-slot flags for #pendingToks: true = a REAL sampled token of that
   *  row's stream; false = a doomed/terminated row's placeholder (fed-token
   *  accounting must skip it — see Row.fed/fedTainted). Filtered/cleared in
   *  lockstep with the register. */
  #pendingReal: boolean[] | null = null;
  #steps = 0; // decode-step counter (clearCache cadence)
  #looping = false;
  #closed = false;
  #driver: Promise<void> | null = null;
  #wake: (() => void) | null = null;
  readonly #maxBatch: number;
  readonly #lock: ExclusiveLock | undefined;
  readonly #admissionHeld: (() => boolean) | undefined;
  readonly #prefillChunkSize: number;
  readonly #prefillTailSplit: boolean;
  readonly #kvBudgetBytes: number | undefined;
  readonly #promptCache: RowPromptCache | undefined;
  /** Retain hook of the currently-ADOPTED row's cache entry (at most one:
   *  only a lone adopted row holds un-copied entry caches). Runs after the
   *  adopted caches are disposed, or transfers back on put(). */
  #adoptedRetain: (() => void) | null = null;
  readonly #kinds: ("full" | "rot" | "ssm" | "owned-batch")[];
  readonly #rotMaxSize: number[]; // per-layer sliding window (rot layers only)
  readonly #compressedProjectors: Array<(tokens: number) => number> | null;
  readonly #batchCacheMaxTokens: number | null;
  readonly #kvScheme: KvScheme | undefined;
  /** layerIdx → mixed-precision spec (Phase 3.1); null = bf16 batch (v1). */
  readonly #kvByLayer: Map<number, KvQuantSpec> | null;
  /** Compiled decode runner for the B=1 serial-class case (Phase 3.2) —
   *  same eligibility gate as generate.ts (gemma dense, kill switch
   *  MLX_BUN_COMPILED_DECODE); adapters never reach the batch lane. Set
   *  to null permanently on a failed step (serial disables per
   *  generation; the scheduler is one long-lived "generation"). */
  #compiled: CompiledDecode | null;

  constructor(private readonly model: RuntimeModel, opts: MlxBatchExecutionGroupOptions) {
    this.#maxBatch = Math.max(1, Math.floor(opts.maxBatch));
    this.#lock = opts.lock;
    this.#admissionHeld = opts.admissionHeld;
    this.#prefillChunkSize = Math.max(1, Math.floor(opts.prefillChunkSize ?? 2048));
    this.#prefillTailSplit = this.#runtime.flag("MLX_BUN_PREFILL_TAIL_SPLIT", true);
    this.#kvBudgetBytes = opts.kvBudgetBytes;
    this.#promptCache = opts.promptCache;
    this.#kvScheme = opts.kvScheme;
    const proto = model.makeCache(); // fresh caches hold no buffers
    if (this.#kvScheme && !this.#kvScheme.batchable(
      model.config,
      (layerIdx) =>
        isPlainKvCache(proto[layerIdx]) || isRotatingPlainCache(proto[layerIdx]),
    )) {
      for (const cache of proto) cache.dispose();
      throw new Error(`unsupported KV scheme for batch scheduler: ${this.#kvScheme.kind}`);
    }
    this.#kinds = proto.map((c) =>
      isBatchableCache(c)
        ? "owned-batch"
        : isRotatingPlainCache(c)
          ? "rot"
          : cacheSignature(c) === "ssm"
            ? "ssm"
            : "full",
    );
    this.#compressedProjectors = proto.every(isBatchableCache)
      ? proto.map((cache) => (tokens: number) => cache.projectedBytes(tokens))
      : null;
    this.#batchCacheMaxTokens = proto.every(isBatchableCache)
      ? Math.min(...proto.map((cache) => cache.maxTokens ?? Number.MAX_SAFE_INTEGER))
      : null;
    const kvConfig = this.#kvScheme?.options.kvConfig;
    this.#kvByLayer = kvConfig?.length
      ? new Map(kvConfig.map((entry) => [entry.layerIdx, entry]))
      : null;
    this.#rotMaxSize = proto.map((c) => (isRotatingPlainCache(c) ? c.maxSize : 0));
    for (const c of proto) c.dispose();
    this.#compiled =
      this.#runtime.flag("MLX_BUN_COMPILED_DECODE", true) &&
      model.config.modelType.startsWith("gemma4") &&
      !model.config.text.enableMoeBlock
        ? CompiledDecode.for(model as Gemma4Model)
        : null;
  }

  get activeRows(): number {
    return this.#running.length;
  }

  get pendingRows(): number {
    return this.#pending.length + (this.#prefill ? 1 : 0);
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
    const asyncModel = this.model as RuntimeModel & {
      forwardHiddenAsync?: (ids: MlxArray, cache: Cache[]) => Promise<MlxArray>;
    };
    return typeof asyncModel.forwardHiddenAsync === "function"
      ? await asyncModel.forwardHiddenAsync(ids, cache)
      : this.model.forwardHidden(ids, cache);
  }

  /** Projected aggregate KV of everything admitted (running + mid-prefill). */
  get projectedKvBytes(): number {
    let total = this.#running.reduce((a, r) => a + this.#rowKvBytes(r), 0);
    if (this.#prefill) total += this.#rowKvBytes(this.#prefill.row);
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

  #ensureLoop(): void {
    if (this.#wake) { this.#wake(); return; }
    if (this.#looping || this.#closed) return;
    this.#looping = true;
    this.#driver = this.#drive();
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
      get active() { return scheduler.#running.length; },
      get queued() { return scheduler.#pending.length; },
      get preparing() { return scheduler.#prefill !== null; },
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
      canBurst: () => this.#kvBudgetBytes === undefined ||
        this.projectedKvBytes + this.#rowKvBytes(this.#pending[0]!) <= this.#kvBudgetBytes,
      advancePreparation: () => this.#advancePreparation(),
      advance: () => this.#step(),
      failActive: (error) => {
        for (const row of this.#running) row.reject(error);
        this.#applyFilter([], true); // failed state never enters the prefix store
      },
      failAll: (error) => this.#failAll(error),
      reserveResidency: () => acquireModelWiredLimit(this.model),
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
      });
    } finally { this.#looping = false; }
  }

  #admitNext(): boolean {
    if (!this.#kvAdmits(this.#pending[0]!)) return false;
    const row = this.#pending.shift()!;
    let owned: { caches: Cache[]; retain?: () => void } | undefined;
    let closePrefill: (() => void) | undefined;
    try {
      row.req.onAdmitted?.();
      row.admittedAt = performance.now();
      const closeCache = row.req.trace?.begin("cache.lookup_restore", { mechanism: "continuous" });
      const hit = this.#promptCache?.take(row.req.promptIds) ?? null;
      if (hit) owned = hit;
      closeCache?.();
      if (hit) row.cachedTokens = hit.tokens.length;
      const len = row.req.promptIds.length;
      const boundary = Math.min(row.req.snapshotAt ?? len, len - 1);
      const snapAt = this.#promptCache && boundary >= 256 && boundary > (hit?.tokens.length ?? 0)
        ? boundary : null;
      closePrefill = row.req.trace?.begin("prefill.total", {
        mechanism: "continuous", promptTokens: row.promptTokens, cachedTokens: row.cachedTokens,
      });
      const closeBatchSetup = row.req.trace?.begin("prefill.batch_setup", { mechanism: "continuous" });
      owned ??= { caches: this.model.makeCache() };
      closeBatchSetup?.();
      this.#prefill = { row, solo: owned.caches, pos: hit?.tokens.length ?? 0,
        retain: owned.retain, snapAt, closePrefill };
      owned = undefined; // transfer to the preparation owner
    } catch (error) {
      let failure = error;
      try { disposeResources([...(owned?.caches ?? []), { dispose: () => owned?.retain?.() },
        { dispose: () => closePrefill?.() }]); }
      catch (cleanupError) { failure = new AggregateError([error, cleanupError], "batch admission and cleanup failed"); }
      row.reject(failure);
    }
    return true;
  }

  async #advancePreparation(): Promise<void> {
    const p = this.#prefill!;
    try {
      if (await this.#prefillChunk(p)) {
        p.closePrefill?.();
        this.#prefill = null;
      }
    } catch (error) {
      this.#prefill = null;
      let failure = error;
      try { disposeResources([...p.solo, { dispose: () => p.retain?.() }, { dispose: () => p.closePrefill?.() }]); }
      catch (cleanupError) { failure = new AggregateError([error, cleanupError], "batch prefill and cleanup failed"); }
      p.row.reject(failure);
    }
  }

  #failAll(error: unknown): void {
    const p = this.#prefill;
    const rows = new Set([...this.#running, ...this.#pending, ...(p ? [p.row] : [])]);
    const retain = this.#adoptedRetain;
    const resources = [...(p?.solo ?? []), ...(this.#inners ?? []), this.#pendingToks,
      { dispose: () => p?.retain?.() }, { dispose: () => p?.closePrefill?.() }, { dispose: () => retain?.() }]
      .filter((resource): resource is DisposableResource => resource != null);
    this.#pending = []; this.#running = []; this.#prefill = null;
    this.#inners = null; this.#pendingToks = null; this.#pendingReal = null;
    this.#fullLeftPad = []; this.#adoptedRetain = null;
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
    if (!this.#kvByLayer) return;
    const close = trace?.begin("prefill.kv_maintenance", {
      mechanism: "continuous",
    });
    try {
      for (let i = 0; i < solo.length; i++) {
        const e = this.#kvByLayer.get(i);
        const c = solo[i]!;
        if (!e || c.offset === 0) continue;
        // Milestone 2: rotating layers convert too — RotatingKVCache.
        // toQuantized → RotatingQuantizedKVCache, exactly maybeQuantizeKv's
        // dispatch (generate.ts). Converted caches don't match either class
        // (the four cache classes are siblings), so re-conversion never fires.
        if (!(isPlainKvCache(c) || isRotatingPlainCache(c))) continue;
        const q = c.toQuantized(e.groupSize, e.bits);
        solo[i] = q;
        ops.evalAll(q.state());
        clearCache();
      }
    } finally {
      close?.();
    }
  }

  /** Advance a joiner's solo prefill by one chunk. Non-final chunks forward +
   *  eval the cache and return false (the caller interleaves a decode step).
   *  The final chunk samples token 0, emits it, and — if the row survives —
   *  merges it into the running batch; returns true (admission complete). */
  async #prefillChunk(p: PrefillState): Promise<boolean> {
    p.row.req.signal?.throwIfAborted();
    const prompt = p.row.req.promptIds;
    const chunkStart = p.pos;
    const closeChunk = p.row.req.trace?.begin("prefill.chunk", {
      mechanism: "continuous",
      startToken: chunkStart,
    });
    try {
    let h: MlxArray;
    while (true) {
      p.row.req.signal?.throwIfAborted();
      const step = nextPrefillStep({ length: prompt.length, position: p.pos,
        chunkSize: this.#prefillChunkSize, tailSplit: this.#prefillTailSplit, snapshotAt: p.snapAt });
      const hidden = await executeMlxPrefillStep(
        (ids, caches) => this.#forwardHidden(ids, caches), p.solo, prompt, step,
        () => this.#quantizeSolo(p.solo, p.row.req.trace),
      );
      p.pos = step.end;
      if (hidden) { h = hidden; break; }
      if (step.snapshot) {
        try { this.#promptCache!.put(prompt.slice(0, step.end), cloneKvCaches(p.solo)); }
        catch (error) { console.warn(`batch-lane boundary snapshot skipped: ${(error as Error).message}`); }
        p.snapAt = null;
      }
      if (step.batchYield) return false;
    }
    closeChunk?.();
    p.closePrefill?.();
    p.closePrefill = undefined;
    const closeTokenZero = p.row.req.trace?.begin("token_zero.total", {
      mechanism: "continuous",
    });
    // MLX is lazy: synchronize(stream) only waits for already-submitted work;
    // it does not submit `h`'s graph. Attribution mode must evaluate the final
    // L=1 forward explicitly or its work is silently charged to the head/read.
    const forceAttribution = !!p.row.req.trace &&
      this.#runtime.value("MLX_BUN_P2R_SYNC") === "1";
    if (forceAttribution) {
      const closeForward = p.row.req.trace!.begin("token_zero.forward", {
        mechanism: "continuous",
        activeBytes: activeMemory(),
        cacheBytes: cacheMemory(),
        peakBytes: peakMemory(),
      });
      ops.evalAll([h, ...p.solo.flatMap((c) => c.state())]);
      closeForward();
    }
    const [, Lc, H] = h.shape as [number, number, number];
    const hLast = h.slice([0, Lc - 1, 0], [1, Lc, H]);
    h.dispose();
    const lg = this.model.logitsFromHidden(hLast); // [1,1,V]
    hLast.dispose();
    if (forceAttribution) {
      const closeHead = p.row.req.trace!.begin("token_zero.head", {
        mechanism: "continuous",
        activeBytes: activeMemory(),
        cacheBytes: cacheMemory(),
        peakBytes: peakMemory(),
      });
      ops.evalAll([lg]);
      closeHead();
    }
    const V = lg.shape[2]!;
    const last2 = ops.reshape(lg, [1, V]);
    lg.dispose();
    const closeSample = forceAttribution
      ? p.row.req.trace!.begin("token_zero.sample", { mechanism: "continuous" })
      : undefined;
    const tok = this.#readToken(p.row.req.sample(last2, 0));
    closeSample?.();
    closeTokenZero?.();
    last2.dispose();
    p.row.sampled = 1;
    p.row.generated = 1;
    clearCache(); // drop the prefill transients (serial's token-0 clear)

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
        this.#putOrDispose(p.solo, p.row.req.promptIds, p.retain);
        this.#finish(p.row, stop === "continue" ? "stop" : stop);
        return true;
      }
    }

    const stop = await this.#emit(p.row, tok);
    if (stop !== "continue") {
      this.#putOrDispose(p.solo, p.row.req.promptIds, p.retain);
      this.#finish(p.row, stop);
      return true;
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
    return true;
    } finally {
      closeChunk?.();
    }
  }

  /** Merge a fully-prefilled joiner with the running batch, layer by layer
   *  (re-merge; `extend` is the later refinement). Flushes the decode pipeline
   *  first so the row set is settled and the next step starts cold. */
  async #mergeJoiner(p: PrefillState): Promise<void> {
    await this.#flushPipeline();

    // ADOPT, don't copy (unified-engine plan Phase 3.2): a row joining an
    // EMPTY batch keeps its solo caches as the batch inners — a pointer
    // handoff, zero bytes moved (the old path ran the full merge machinery
    // to produce a byte-identical [1,...] copy). The copy now happens only
    // when a SECOND row joins and a genuinely new layout must exist. The
    // prize beyond the saved copy: the lone row's caches stay SERIAL-CLASS
    // (KVCache / RotatingKVCache / QuantizedKVCache), so the B=1 step is
    // literally the serial graph, and compiled decode + prompt-cache
    // take/put become possible for it. The rot branch below knows how to
    // treat an adopted RotatingKVCache as the merge's first row.
    if (!this.#inners) {
      this.#inners = p.solo as LayerInner[];
      this.#fullLeftPad = [0];
      this.#adoptedRetain = p.retain ?? null;
      this.#running.push(p.row);
      return;
    }

    const prev = this.#inners;
    const prevPad = this.#fullLeftPad;
    const B = this.#running.length;
    const newInners: LayerInner[] = [];
    let newFullPad = this.#fullLeftPad;
    for (let layer = 0; layer < this.#kinds.length; layer++) {
      if (this.#kinds[layer] === "owned-batch") {
        const solo = p.solo[layer]!;
        if (!isBatchableCache(solo))
          throw new Error(`batch-capable layer ${layer} lost its cache capability`);
        const merged = solo.makeEmptyBatch();
        const previous = prev?.[layer];
        merged.mergeRows(previous ? [previous, solo] : [solo]);
        newFullPad = [...merged.leftPad];
        newInners.push(merged);
        continue;
      }
      if (this.#kinds[layer] === "ssm") {
        // No temporal axis, no left-pad: B-axis concat of the state slots.
        // mergeRows steals the solo arrays when the batch starts cold, so the
        // unconditional p.solo dispose below stays safe either way.
        newInners.push(SSMCache.mergeRows(
          (prev?.[layer] as SSMCache | undefined) ?? null,
          p.solo[layer] as SSMCache,
        ));
        continue;
      }
      if (isQuantizedKvCache(p.solo[layer])) {
        // Phase 3.1 — quantized full layer: same merge/extend shapes as the
        // bf16 branch below, over (packed, scales, biases) triples. The solo
        // row was converted by #quantizeSolo with the serial ops, so its
        // bytes already bit-match serial `--kv-quant config`; this branch
        // only re-arranges rows along the batch axis.
        const qSolo = p.solo[layer] as QuantizedKVCache;
        const [qk, qv] = qSolo.temporalView();
        const qRow = { keys: qk, values: qv };
        const dispose3 = (t: { packed: MlxArray; scales: MlxArray; biases: MlxArray }) => {
          t.packed.dispose(); t.scales.dispose(); t.biases.dispose();
        };
        const prevQ = prev?.[layer] as QuantizedKVCache | undefined;
        if (prevQ && this.#runtime.value("MLX_BUN_BATCH_EXTEND") !== "0") {
          const [k0, v0] = prevQ.temporalView();
          const ext = extendQuantRows(k0, v0, prevPad, qRow);
          dispose3(k0); dispose3(v0);
          newFullPad = ext.leftPad;
          const c = new QuantizedKVCache(qSolo.groupSize, qSolo.bits);
          c.restoreState(ext.keys, ext.values, ext.width);
          newInners.push(c);
        } else {
          const rows: { keys: typeof qk; values: typeof qv }[] = [];
          if (prevQ) {
            const [k0, v0] = prevQ.temporalView(); // [B,H,off,*]
            const S = k0.packed.shape[2]!;
            for (let b = 0; b < B; b++) {
              const pad = prevPad[b]!;
              const cutRow = (t: typeof k0): typeof k0 => ({
                packed: t.packed.slice([b, 0, pad, 0], [b + 1, t.packed.shape[1]!, S, t.packed.shape[3]!]),
                scales: t.scales.slice([b, 0, pad, 0], [b + 1, t.scales.shape[1]!, S, t.scales.shape[3]!]),
                biases: t.biases.slice([b, 0, pad, 0], [b + 1, t.biases.shape[1]!, S, t.biases.shape[3]!]),
              });
              rows.push({ keys: cutRow(k0), values: cutRow(v0) });
            }
            dispose3(k0); dispose3(v0);
          }
          rows.push(qRow);
          const merged = mergeQuantRows(rows);
          newFullPad = merged.leftPad;
          const c = new QuantizedKVCache(qSolo.groupSize, qSolo.bits);
          c.restoreState(merged.keys, merged.values, merged.width);
          newInners.push(c);
          for (const r of rows) { dispose3(r.keys); dispose3(r.values); }
        }
        // qRow views are disposed via the rows loop above or here for extend
        if (prevQ && this.#runtime.value("MLX_BUN_BATCH_EXTEND") !== "0") { dispose3(qRow.keys); dispose3(qRow.values); }
        else if (!prevQ) { /* disposed in the rows loop */ }
        continue;
      }
      // NOTE: the quantized-rotating branch below never uses this layer's
      // bf16 temporalView — calling it before the branch leaked the pair
      // (six arrays per second-row join on quantized rotating layers,
      // introduced in 859572d; 2026-07-07 review fix). The view is taken
      // AFTER the branch, on the paths that actually consume it.
      const soloC = p.solo[layer] as KVCache | RotatingKVCache;
      if (this.#kinds[layer] === "rot" && isRotatingQuantizedCache(p.solo[layer])) {
        // Milestone 2 — QUANTIZED rotating layer: the solo row converted at
        // the serial boundaries (#quantizeSolo), so its ring bytes are the
        // serial oracle's; this branch re-arranges temporal triples across
        // the batch axis (the bf16 rot merge over triples).
        const qSolo = p.solo[layer] as RotatingQuantizedKVCache;
        const [qk, qv] = qSolo.temporalView();
        const rows: QuantRow[] = [];
        const offsets: number[] = [];
        const dispose3 = (t: QuantRow) => {
          t.keys.packed.dispose(); t.keys.scales.dispose(); t.keys.biases.dispose();
          t.values.packed.dispose(); t.values.scales.dispose(); t.values.biases.dispose();
        };
        const prevC = prev?.[layer];
        if (prevC && isRowBatchCache(prevC) && isRotatingQuantizedCache(prevC)) {
          const batched = prevC as BatchedRotatingQuantCache;
          const [k0, v0] = batched.temporalView(); // [B,H,valid,*] triples, temporal
          const valid = k0.packed.shape[2]!;
          for (let b = 0; b < B; b++) {
            const pad = Math.max(0, batched.leftPad[b]!);
            const cutRow = (t: typeof k0): typeof k0 => ({
              packed: t.packed.slice([b, 0, pad, 0], [b + 1, t.packed.shape[1]!, valid, t.packed.shape[3]!]),
              scales: t.scales.slice([b, 0, pad, 0], [b + 1, t.scales.shape[1]!, valid, t.scales.shape[3]!]),
              biases: t.biases.slice([b, 0, pad, 0], [b + 1, t.biases.shape[1]!, valid, t.biases.shape[3]!]),
            });
            rows.push({ keys: cutRow(k0), values: cutRow(v0) });
            offsets.push(batched.offsetArr[b]!);
          }
          for (const t of [k0, v0]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); }
        } else if (isRotatingQuantizedCache(prevC)) {
          // Adopted lone row (Phase 3.2 adopt): its chronological triples
          // are the merge's first row, pad 0 by definition.
          const [k0, v0] = prevC.temporalView();
          rows.push({ keys: k0, values: v0 });
          offsets.push(prevC.offset);
        }
        rows.push({ keys: qk, values: qv });
        offsets.push(qSolo.offset);
        newInners.push(BatchedRotatingQuantCache.merge(
          rows, offsets, this.#rotMaxSize[layer]!, qSolo.groupSize, qSolo.bits,
        ));
        for (const r of rows) dispose3(r);
        continue;
      }
      const [sk, sv] = soloC.temporalView();
      const newRow: Row1 = { keys: sk, values: sv };
      if (this.#kinds[layer] === "rot") {
        const rows: Row1[] = [];
        const offsets: number[] = [];
        const prevC = prev?.[layer];
        if (isRotatingPlainCache(prevC) && !isRowBatchCache(prevC)) {
          // Adopted lone row (Phase 3.2): a plain serial rotating cache —
          // its chronological view is the merge's first row, same as a
          // fresh solo (pad 0 by definition).
          const [k0, v0] = prevC.temporalView();
          rows.push({ keys: k0, values: v0 });
          offsets.push(prevC.offset);
        }
        // Route by CAPABILITY (isRowBatchCache), never by signature string,
        // inside the rot branch: the running batch's ring is a row-batch
        // cache whatever its storage kind. The 2026-08-22 agg×4 regression
        // (443f333) came from a signature-based conjunct here silently
        // dropping the running rows; since then Cache.signature() is
        // REQUIRED (BatchedRotatingCache reports "kv:rotating-plain") and
        // the quant family is dispatched by its own branch above.
        const prevRot = prevC && isRowBatchCache(prevC)
          ? prevC as unknown as BatchedRotatingCache
          : undefined;
        if (prevRot) {
          const [k0, v0] = prevRot.temporalView(); // [B,H,valid,D]
          const [, H, valid, D] = k0.shape as [number, number, number, number];
          const vD = v0.shape[3]!;
          for (let b = 0; b < B; b++) {
            const pad = Math.max(0, prevRot.leftPad[b]!);
            rows.push({
              keys: k0.slice([b, 0, pad, 0], [b + 1, H, valid, D]),
              values: v0.slice([b, 0, pad, 0], [b + 1, H, valid, vD]),
            });
            offsets.push(prevRot.offsetArr[b]!);
          }
          k0.dispose(); v0.dispose();
        }
        rows.push(newRow);
        offsets.push(soloC.offset);
        newInners.push(BatchedRotatingCache.merge(rows, offsets, this.#rotMaxSize[layer]!));
        for (const r of rows) { r.keys.dispose(); r.values.dispose(); }
      } else {
        const prevFull = prev?.[layer] as KVCache | undefined;
        if (prevFull && this.#runtime.value("MLX_BUN_BATCH_EXTEND") !== "0") {
          // extend-join (mlx-lm BatchKVCache.extend semantics, P0): append
          // the new right-justified row to the running buffer in ONE pad +
          // ONE concat — no per-row extraction. Existing pads grow, never
          // shrink (the re-merge below re-normalizes them instead; both are
          // masked, both token-exact vs their mlx-lm protocol twin).
          // MLX_BUN_BATCH_EXTEND=0 = the O(B·S) re-merge, kill switch/A-B.
          const [k0, v0] = prevFull.temporalView(); // [B,H,off,D]
          const ext = extendKVRows(k0, v0, prevPad, newRow);
          k0.dispose(); v0.dispose();
          newFullPad = ext.leftPad;
          const c = new KVCache();
          c.restoreState(ext.keys, ext.values, ext.width);
          newInners.push(c);
          newRow.keys.dispose(); newRow.values.dispose();
        } else {
          const rows: Row1[] = [];
          if (prevFull) {
            const [k0, v0] = prevFull.temporalView(); // [B,H,off,D]
            const [, H, off, D] = k0.shape as [number, number, number, number];
            const vD = v0.shape[3]!;
            for (let b = 0; b < B; b++) {
              const pad = prevPad[b]!;
              rows.push({
                keys: k0.slice([b, 0, pad, 0], [b + 1, H, off, D]),
                values: v0.slice([b, 0, pad, 0], [b + 1, H, off, vD]),
              });
            }
            k0.dispose(); v0.dispose();
          }
          rows.push(newRow);
          const merged = mergeKVRows(rows);
          newFullPad = merged.leftPad;
          const c = new KVCache();
          c.restoreState(merged.keys, merged.values, merged.width);
          newInners.push(c);
          for (const r of rows) { r.keys.dispose(); r.values.dispose(); }
        }
      }
    }
    if (prev) for (const c of prev) c.dispose();
    // An adopted row's entry-backed arrays are gone after the prev dispose;
    // run its retain now. The joiner's likewise after its solo dispose.
    this.#adoptedRetain?.();
    this.#adoptedRetain = null;
    for (const c of p.solo) c.dispose();
    p.retain?.();
    // Every row in a REAL merge has its KV interleaved in batched buffers —
    // no longer prompt-cache put() candidates.
    for (const r of this.#running) r.merged = true;
    p.row.merged = true;
    this.#inners = newInners;
    this.#fullLeftPad = newFullPad;
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
  async #step(): Promise<void> {
    if (STEP_TRACE) {
      const now = performance.now();
      if (STEP_T.lastEnd) STEP_T.gap += now - STEP_T.lastEnd;
      STEP_T.t0 = now;
    }
    const rows = this.#running;
    const B = rows.length;
    const inners = this.#inners!;

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
    if (hasLiveGrammar) return this.#stepGrammar();

    let nextToks: MlxArray | null = null;
    let nextReal: boolean[] | null = null;
    if (anyLive) {
      // Fed-token accounting (prompt-cache put): a COLD step feeds each
      // row's `current` (values known now, always a real emitted token); a
      // pipelined step feeds the pending array, whose values are pushed at
      // the read below gated on the per-slot real flags.
      if (!this.#pendingToks) for (const r of rows) r.fed.push(r.current);
      // Per-layer forward cache: rot layers use the persistent
      // BatchedRotatingCache directly; ssm layers are already [B,...] state
      // with no padding (no mask, no per-row RoPE — pass through); full
      // layers get a fresh BatchedDecodeMaskCache wrapper — UNLESS no row
      // has left padding. UNPADDED FAST PATH (unified-engine plan Phase 2,
      // the B=1 case above all): with every leftPad 0 the wrapper's two
      // jobs vanish — the padding mask (KVCache.makeMask(1) is the empty
      // mask, exactly the serial loop's) and the per-row rope positions
      // (every row sits at the shared scalar offset). The bare cache then
      // dispatches the SAME per-step graph serial builds; the wrapper
      // otherwise costs a host mask build + ~8 device nodes PER FULL LAYER
      // PER TOKEN (the Phase-0 constant ~4–6 ms/step host tax at B=1).
      const unpadded = this.#fullLeftPad.every((p) => p === 0);
      // Compiled decode at B=1 (Phase 3.2): after adopt-don't-copy, a lone
      // row's caches are SERIAL-CLASS, so the serial engine's compiled step
      // replays the same C++ graph here — closing the batch lane's last
      // B=1 host-tax gap (e4b's ~7%). Guards: gemma dense (constructor),
      // serial-class caches (supports — a merged batch's BatchedRotating
      // layers fail it), unpadded, and a uint32 pipeline register (the
      // trace signature; per-row int32 samplers take the graph path).
      // Grammar batches use #stepGrammar and stay on the graph path.
      let lg: MlxArray | null = null;
      let evalWith: MlxArray[] = [];
      if (
        this.#compiled && B === 1 && unpadded &&
        (!this.#pendingToks || this.#pendingToks.dtype === Dtype.uint32) &&
        // A filtered-to-one BATCHED rot-quant cache subclasses the serial
        // class (so supports() passes) but carries batched ring state —
        // exclude it; only truly-adopted serial caches replay compiled.
        !inners.some((c) => isRowBatchCache(c) && isRotatingQuantizedCache(c)) &&
        CompiledDecode.supports(inners as Cache[])
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
          fwd = inners.map((c) =>
            isRowBatchCache(c) || isBatchableCache(c) || unpadded
              ? c
              : isQuantizedKvCache(c)
                ? new BatchedQuantDecodeMaskCache(c, B, this.#fullLeftPad)
                : new BatchedDecodeMaskCache(c, B, this.#fullLeftPad, null),
          );
          const ids = this.#pendingToks
            ? ops.reshape(this.#pendingToks, [B, 1]) // feed the unread tokens
            : ops.fromInt32(rows.map((r) => r.current), [B, 1]); // pipeline cold
          const h = await this.#forwardHidden(ids, fwd);
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
          runtimeValue("MLX_BUN_BATCH_VEC_SAMPLE") !== "0" &&
          rows.every((r) => r.sampled >= r.req.maxTokens || r.req.plainGreedy);
        // Doomed slots hold placeholders (vec path: a real argmax value,
        // equally not part of the row's stream) — flag them so the fed
        // accounting at the read stays per-row exact.
        nextReal = rows.map((r) => r.sampled < r.req.maxTokens);
        if (vecOk) {
          const flat = ops.reshape(lg, [B, V]);
          lg.dispose();
          const lp = toLogprobs(flat);
          flat.dispose();
          nextToks = ops.argmaxAxis(lp, -1); // [B]
          lp.dispose();
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
            sampled.push(row.req.sample(rl2, row.sampled));
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
        // Free the step's RoPE arrays; do NOT dispose (full wrappers would free
        // their persistent inner; rot caches persist across steps).
        if (fwd) for (const c of fwd) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
      }
    }
    this.#steps++;
    if (this.#steps % 256 === 0) clearCache(); // serial's cadence, not per-step
    if (STEP_TRACE) STEP_T.build += performance.now() - STEP_T.t0;

    // Read + emit the PREVIOUS step's tokens while the new step computes.
    const prev = this.#pendingToks;
    const prevReal = this.#pendingReal;
    this.#pendingToks = nextToks;
    this.#pendingReal = nextReal;
    // Kill switch / A-B lever (house style, cf. MLX_BUN_COMPILED_DECODE=0):
    // MLX_BUN_BATCH_NO_PIPELINE=1 reads THIS step's tokens synchronously —
    // set from process start `prev` is always null, so the flush below IS the
    // whole phase 2. Same math either way (pipelining is scheduling).
    if (NO_PIPELINE) {
      await this.#flushPipeline();
      return;
    }
    if (prev) {
      const tRead = STEP_TRACE ? performance.now() : 0;
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
      if (STEP_TRACE) STEP_T.read += performance.now() - tRead;
      const tEmit = STEP_TRACE ? performance.now() : 0;
      await this.#emitRows(toks); // also filters #pendingToks on eviction
      if (STEP_TRACE) { STEP_T.emit += performance.now() - tEmit; STEP_T.n++; }
    }
    if (STEP_TRACE) STEP_T.lastEnd = performance.now();
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
  async #stepGrammar(): Promise<void> {
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
      // Unpadded fast path — same rule as #step (bare caches == serial graph).
      const unpadded = this.#fullLeftPad.every((p) => p === 0);
      const fwd: Cache[] = inners.map((c) =>
        isRowBatchCache(c) || isBatchableCache(c) || unpadded
          ? c
          : isQuantizedKvCache(c)
            ? new BatchedQuantDecodeMaskCache(c, B, this.#fullLeftPad)
            : new BatchedDecodeMaskCache(c, B, this.#fullLeftPad, null),
      );
      try {
        // (3) Build the forward graph (host-side; the fills overlap it).
        const ids = prev
          ? ops.reshape(prev, [B, 1]) // feed the unread tokens (device array)
          : ops.fromInt32(rows.map((r) => r.current), [B, 1]); // pipeline cold
        const h = await this.#forwardHidden(ids, fwd);
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
          sampled.push(row.req.sample(rl2, row.sampled));
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
      if (row.generated === 1) row.firstTokenAt = performance.now();
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
  async #emit(row: Row, token: number): Promise<"continue" | "stop" | "length"> {
    row.req.signal?.throwIfAborted();
    if (row.req.eosTokenIds.includes(token)) return "stop";
    const cont = await row.req.onToken(token);
    if (cont === false) return "stop";
    // Grammar termination: the matcher is satisfied (e.g. closing `}` accepted).
    // The final token has been delivered via onToken above; halt with "stop" so
    // the row finishes + evicts rather than sampling into an all--inf mask.
    if (row.req.grammar?.isTerminated) return "stop";
    if (row.generated >= row.req.maxTokens) return "length";
    row.current = token;
    return "continue";
  }

  #finish(row: Row, reason: "stop" | "length"): void {
    const now = performance.now();
    const first = row.firstTokenAt || now;
    row.resolve({
      promptTokens: row.promptTokens,
      generatedTokens: row.generated,
      cachedTokens: row.cachedTokens,
      finishReason: reason,
      prefillMs: row.admittedAt ? first - row.admittedAt : 0,
      decodeMs: row.firstTokenAt ? now - row.firstTokenAt : 0,
    });
  }

  /** Finish-time disposition of serial-class caches covering exactly
   *  `tokens`: put() into the prompt cache when the hook is present and the
   *  offset lines up (defensive — a mismatch means the accounting is wrong
   *  and the entry would corrupt future hits), else dispose. `retain` rides
   *  along per the PromptCacheEntry contract (runs after dispose). */
  #putOrDispose(caches: Cache[], tokens: number[], retain?: () => void): void {
    if (this.#promptCache) {
      const withOff = caches.find(
        (c) => typeof (c as { offset?: unknown }).offset === "number",
      ) as { offset: number } | undefined;
      if (withOff && withOff.offset === tokens.length) {
        this.#promptCache.put(tokens, caches, "", retain);
        return;
      }
    }
    for (const c of caches) c.dispose();
    retain?.();
  }

  /** Extract a finishing MERGED row's KV into fresh serial caches and put()
   *  them keyed by [promptIds + fed] — the batch-lane mirror of mlx-lm
   *  server.py:872 (extract_cache → prompt_cache.insert_cache). Gates:
   *  promptTokens >= 256 (the boundary-snapshot substantiality gate,
   *  server.ts) and an exact coverage key (!fedTainted). Refusal
   *  (#extractRowCaches null) just disposes-by-omission — the row's KV dies
   *  with the filter, exactly the pre-extraction behavior. */
  #extractAndPut(b: number, row: Row): void {
    if (!this.#promptCache || !row.merged || row.fedTainted) return;
    if (row.promptTokens < 256) return;
    const tokens = [...row.req.promptIds, ...row.fed];
    const caches = this.#extractRowCaches(b, tokens.length);
    if (!caches) return;
    // Materialize the owned copies without stalling the in-flight step (the
    // slices depend on this step's KV writes): async — the batched source
    // buffers free once the copies land, instead of being pinned by a lazy
    // graph inside an idle cache entry.
    ops.asyncEvalAll(caches.flatMap((c) => c.state()));
    this.#putOrDispose(caches, tokens);
  }

  /** Row `b` of every layer as OWNED serial-class caches, or null when a
   *  layer kind can't be extracted (then the caller drops the row's KV as
   *  before). Bit-exactness: merge/extend/filter/decode are byte-preserving
   *  per row (tests/batched-decode-parity, tests/batched-rotating,
   *  tests/batched-rotating-quant) and each extract is a pure slice+copy of
   *  those bytes (tests/batched-extract), so an extracted row's bytes ==
   *  the solo run's. */
  #extractRowCaches(b: number, expectTokens: number): Cache[] | null {
    const out: Cache[] = [];
    for (const inner of this.#inners!) {
      let c: Cache | null;
      if (isBatchableCache(inner)) c = inner.extractRow(b);
      else if (isRowBatchCache(inner) && cacheSignature(inner) === "ssm")
        // Coverage gate: recurrent state is UNTRIMMABLE, so an entry is only
        // valid when the row's own advance count equals the [promptIds+fed]
        // key EXACTLY (a mismatched entry would silently corrupt every future
        // exact-hit). Defensive — a miss here means the fed accounting broke.
        c = (inner as SSMCache).conv && (inner as SSMCache).rowOffset(b) === expectTokens
          ? inner.extractRow(b)
          : null;
      else if (isRowBatchCache(inner)) c = inner.extractRow(b);
      else if (
        isRotatingQuantizedCache(inner) || // adopted serial state never
        isRotatingPlainCache(inner) //     coexists with a merged row (defensive)
      )
        c = null;
      else if (isQuantizedKvCache(inner))
        c = inner.keys ? extractQuantRow(inner, this.#fullLeftPad[b]!, b) : null;
      else if (isPlainKvCache(inner))
        c = inner.keys ? extractKVRow(inner, this.#fullLeftPad[b]!, b) : null;
      else c = null;
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
    const inners = this.#inners!;
    if (keep.length === 0) {
      // Prompt-cache put (Phase 3.2): a lone NEVER-MERGED row's inners are
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
          inners as Cache[],
          [...solo.req.promptIds, ...solo.fed],
          this.#adoptedRetain ?? undefined,
        );
      } else {
        for (const c of inners) c.dispose();
        this.#adoptedRetain?.();
      }
      this.#adoptedRetain = null;
      this.#inners = null;
      this.#fullLeftPad = [];
      this.#running = [];
      this.#pendingToks?.dispose();
      this.#pendingToks = null;
      this.#pendingReal = null;
      return;
    }
    const out: LayerInner[] = [];
    for (const inner of inners) {
      if (isBatchableCache(inner)) {
        inner.filterRows(keep);
        out.push(inner);
      } else if (isRowBatchCache(inner)) {
        inner.filterRows(keep);
        out.push(inner);
      } else if (isRotatingQuantizedCache(inner) || isRotatingPlainCache(inner)) {
        // Adopted lone-row state exists only at B=1, where the only filter
        // is the keep=[] dispose-all handled above — unreachable.
        throw new Error("applyFilter: adopted serial rotating cache cannot be row-filtered");
      } else if (isQuantizedKvCache(inner)) {
        const [k0, v0] = inner.temporalView();
        const f = filterQuantRows(k0, v0, keep);
        for (const t of [k0, v0]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); }
        const c = new QuantizedKVCache(inner.groupSize, inner.bits);
        c.restoreState(f.keys, f.values, inner.offset);
        out.push(c);
        inner.dispose();
      } else if (isPlainKvCache(inner)) {
        const [k0, v0] = inner.temporalView();
        const f = filterKVRows(k0, v0, keep);
        k0.dispose(); v0.dispose();
        const c = new KVCache();
        c.restoreState(f.keys, f.values, inner.offset);
        out.push(c);
        inner.dispose();
      } else {
        throw new Error(`applyFilter: unsupported cache signature ${cacheSignature(inner)}`);
      }
    }
    this.#inners = out;
    this.#fullLeftPad = keep.map((i) => this.#fullLeftPad[i]!);
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
