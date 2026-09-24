import { MlxArray } from "@mlx-bun/mlx/array";
import { type MlxForwardWork,type MlxPreparationWork } from "../contracts/mlx/forward-work";
import type { ExecutionContext } from "../contracts/portable/scheduling";
import { type RuntimeConfig } from "../runtime/config";
import type { PromptResponseTrace } from "../runtime/trace";
import type { GrammarController } from "../sampling/grammar";
import type { KvScheme } from "../state/kv-scheme";
import type { MlxRequestStatePolicy } from "../state/request-policy";
import type { OrdinaryContinuation } from "./continuation-types";

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

/** A method prepares and advances rows; the shared executor owns queueing. */
export interface MlxGroupPreparation {
  readonly rows: readonly Row[];
  readonly tokenWeight?: number;
  readonly canAdmit?: boolean;
  readonly supportsMixedWork?: boolean;
  admit?(row: Row): void;
  advance(work?: MlxPreparationWork): Promise<boolean>;
  dispose(): void;
}

export interface MlxGroupMethodHost {
  readonly rows: readonly Row[];
  readonly runtime: RuntimeConfig;
  readonly prefillChunkSize: number;
  readonly promptCache: RowPromptCache | undefined;
  join(row: Row): void;
  filterRows(keep: number[]): void;
  publish(row: Row, token: number, logprobs?: import("../generation/index").TokenLogprobs): Promise<void | boolean>;
  finish(row: Row, reason: "stop" | "length"): void;
}

export interface MlxGroupedMethod {
  /** Maximum target tokens in the next iteration, including candidates. */
  readonly runningTokens?: number;
  prepare(row: Row): MlxGroupPreparation;
  advance(work?: MlxForwardWork): Promise<void>;
  filterRows(keep: readonly number[], discard: boolean): void;
  dispose(): void;
}

export interface MlxGroupMethodRequest {
  /** Equal keys declare compatible method state, independent of queue size. */
  readonly key: string;
  readonly data: unknown;
  open(host: MlxGroupMethodHost): MlxGroupedMethod;
}

export type BatchRequest = BatchRequestFields & (
  | { method: MlxGroupMethodRequest; sample?: RowSampler }
  | { method?: undefined; sample: RowSampler }
);

export interface BatchRequestFields {
  /** Borrowed prepared input; its owner retains it through preparation. */
  promptInput?: import("./prompt-input").MlxPromptInput;
  cacheSessionId?: string;
  /** Optional ordinary continuation policy; owns persistence and sampler recovery. */
  continuation?: OrdinaryContinuation;
  statePolicy?: MlxRequestStatePolicy;
  context?: ExecutionContext;
  /** Resolve loaded-state identity under the execution lease, after any
   * queued adapter replacement has finished. */
  cacheNamespace?: string | (() => string);
  /** Resolved replay permission; standalone group callers retain auto mode. */
  compiledDecode?: boolean;
  promptIds: number[];
  /** Request policy overrides the execution group's captured prefill default. */
  prefillChunkSize?: number;
  maxTokens: number;
  eosTokenIds: number[];
  /** Called per emitted (non-EOS) token, in order. Returning `false` halts this
   *  row (a decoded-text stop sequence fired) — matches generate()'s onToken
   *  contract. EOS terminates the row WITHOUT an onToken call. Throwing evicts
   *  THIS row only (its submit promise rejects; siblings continue). May be
   *  async; keep it cheap — it runs inline in the step loop. */
  onToken: (token: number, logprobs?: import("../generation/index").TokenLogprobs) => void | boolean | Promise<void | boolean>;
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
  spec?: import("../generation/index").GenerateStats["spec"];
  fill?: import("../generation/index").GenerateStats["fill"];
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
export type RowPromptCache = import("../state/checkpoint").MlxPrefixCache;

export interface Row {
  spec?: import("../generation/index").GenerateStats["spec"];
  fill?: import("../generation/index").GenerateStats["fill"];
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
  closeTokenZero?: () => void;
  cacheNamespace?: string;
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

/** Held while the batch is active; the serial fallback acquires the same lock. */
export interface ExclusiveLock {
  acquire(): Promise<() => void>;
}

export interface MlxBatchExecutionGroupOptions {
  /** Scheduling work budget for extending an existing preparation cohort. */
  prefillBatchTokenLimit?: number;
  runtime?: RuntimeConfig;
  maxQueued?: number;
  stateCodecs?: import("../state/persistence-types").CacheCodecProvider;
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
  /** Model binding owns support for precision transitions. */
  kvBatchCapabilities?: { delayedAffine?: boolean };
  /** Prompt-cache hook (Phase 3.2): admission take()s the longest usable
   *  prefix into the joiner's solo caches (suffix-only prefill — the
   *  multi-turn chat TTFT path); rows that finish never-merged put() their
   *  caches back. Adapter requests never reach the batch lane, so the
   *  namespace is always "" here. Runs under the gateway mutex domain, so
   *  take/put never race the serial lane's use of the same cache. */
  promptCache?: RowPromptCache;
}
