// Continuous-batching scheduler for `--batch N` serving (phase S2, the engine
// loop). Owns ONE running batch and drives it forward one decode step at a
// time, admitting waiting requests and evicting finished ones between steps —
// iteration-level (continuous) scheduling, not static batching. See
// docs/design/parallel-slots.md and docs/design/batching-v2-plan.md.
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
// cache by type. Gate: tests/batch-scheduler.test.ts (teacher-forced, KL).
//
// Per-layer cache types: a model interleaves full-attention layers (plain
// KVCache, wrapped per step in a BatchedDecodeMaskCache) and sliding-window
// layers (a persistent BatchedRotatingCache that is itself the batched cache +
// mask). Full layers share one leftPad/offset (all rows advance together); the
// rotating caches self-track per-row leftPad/offset as the ring wraps. The
// per-row absolute position stays consistent across both (full: offset-leftPad;
// rot: offsetArr) — see docs/design/parallel-slots.md. Hybrid gated-DeltaNet
// models (Qwen3.5) add "ssm" layers: SSMCache state is plain [B,...] with no
// temporal axis and no padding (rows solo-prefill unpadded, decode feeds one
// real token per row), so merge/filter are B-axis concat/take and the cache
// passes through the step unwrapped (no mask, no per-row RoPE — full layers
// carry positions). Gate: GenerationGateway.willBatch on cache capability.
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

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { clearCache } from "../mlx/ffi";
import { KVCache, RotatingKVCache, type Cache } from "../model/gemma4-base";
import { BatchedDecodeMaskCache, mergeKVRows, filterKVRows } from "../model/batched-mask";
import { BatchedRotatingCache } from "../model/batched-rotating";
import { SSMCache } from "../model/qwen3-delta";
import type { RuntimeModel } from "../model/factory";
import type { GrammarController } from "../grammar";
import { kvBytesAt } from "../fit";

/** Decode-pipeline kill switch (read once at load, like the serial loop's
 *  MLX_BUN_COMPILED_DECODE): 1 ⇒ read each step's tokens synchronously. */
const NO_PIPELINE = process.env.MLX_BUN_BATCH_NO_PIPELINE === "1";

// NOTE — oMLX-style "adaptive burst decode" (several steps per event-loop
// yield, omlx/engine_core.py _step_burst) was ported here 2026-07-02 and
// REFUTED by measurement: on this runtime it REGRESSED cpm5 B=4 aggregate
// 345→289 tok/s, batch-lane B=1 149→121, and TTFT ~+100 ms (first-token SSE
// flush waits out the burst budget). Their win exists because each Python
// step hand-off ping-pongs the GIL with asyncio/uvicorn (~1 ms/token); Bun's
// setImmediate hop costs microseconds, so bursting here only delays socket
// flushes. Don't re-add without new evidence — the per-yield step below is
// the measured optimum (docs/design/batching-perf-path.md P4 notes).

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
  /** Grammar controller for this row (B1: per-row matchers). When set, the
   *  scheduler drives it: `accept()` after each emitted token (fires the async
   *  bitmask fill), `await ready()` before the row's next sample (the sample
   *  closure applies `applyMask`). Termination (grammar satisfied) is an
   *  additional per-row stop source. The gateway OWNS disposal (finally around
   *  submit()); the scheduler uses but never owns. Null on the degrade path. */
  grammar?: GrammarController;
}

export interface BatchStats {
  promptTokens: number;
  generatedTokens: number;
  /** Prompt tokens served from a pre-warmed cache. Always 0 in v1 (each row is
   *  solo-prefilled from scratch; prompt-cache reuse under batching is later). */
  cachedTokens: number;
  finishReason: "stop" | "length";
}

interface Row {
  req: BatchRequest;
  resolve: (s: BatchStats) => void;
  reject: (e: unknown) => void;
  current: number; // last emitted token, fed at the next step (pipeline cold)
  generated: number; // tokens emitted so far (incl. a terminating EOS)
  sampled: number; // sample() calls so far (leads `generated` by 1 in-pipeline)
  promptTokens: number;
}

/** A joiner mid-prefill: `pos` prompt tokens are already in `solo`. Advanced
 *  one chunk per loop iteration, interleaved with batch decode steps. */
interface PrefillState {
  row: Row;
  solo: Cache[];
  pos: number;
}

/** Held while the batch is active; the serial fallback acquires the same lock. */
export interface ExclusiveLock {
  acquire(): Promise<() => void>;
}

export interface BatchSchedulerOptions {
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
}

type LayerInner = KVCache | BatchedRotatingCache | SSMCache;
type Row1 = { keys: MlxArray; values: MlxArray };

export class BatchScheduler {
  #running: Row[] = [];
  #inners: LayerInner[] | null = null; // per-layer batched KV; null when empty
  #fullLeftPad: number[] = []; // per-row padding for FULL layers (rot self-tracks)
  #pending: Row[] = [];
  #prefill: PrefillState | null = null; // the (single) joiner mid-prefill
  /** Sampled-but-unread token array [B], aligned with #running — the decode
   *  pipeline register. Filtered/disposed alongside the batched KV. */
  #pendingToks: MlxArray | null = null;
  #steps = 0; // decode-step counter (clearCache cadence)
  #looping = false;
  #wake: (() => void) | null = null;
  readonly #maxBatch: number;
  readonly #lock: ExclusiveLock | undefined;
  readonly #admissionHeld: (() => boolean) | undefined;
  readonly #prefillChunkSize: number;
  readonly #kvBudgetBytes: number | undefined;
  readonly #kinds: ("full" | "rot" | "ssm")[]; // per-layer attention type
  readonly #rotMaxSize: number[]; // per-layer sliding window (rot layers only)

  constructor(private readonly model: RuntimeModel, opts: BatchSchedulerOptions) {
    this.#maxBatch = Math.max(1, Math.floor(opts.maxBatch));
    this.#lock = opts.lock;
    this.#admissionHeld = opts.admissionHeld;
    this.#prefillChunkSize = Math.max(1, Math.floor(opts.prefillChunkSize ?? 2048));
    this.#kvBudgetBytes = opts.kvBudgetBytes;
    const proto = model.makeCache(); // fresh caches hold no buffers
    this.#kinds = proto.map((c) =>
      c instanceof RotatingKVCache ? "rot" : c instanceof SSMCache ? "ssm" : "full",
    );
    this.#rotMaxSize = proto.map((c) => (c instanceof RotatingKVCache ? c.maxSize : 0));
    for (const c of proto) c.dispose();
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
    return kvBytesAt(this.model.config, row.promptTokens + row.req.maxTokens);
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
    return new Promise<BatchStats>((resolve, reject) => {
      this.#pending.push({
        req, resolve, reject,
        current: 0, generated: 0, sampled: 0, promptTokens: req.promptIds.length,
      });
      this.#ensureLoop();
    });
  }

  /** Wake the driver loop (e.g. after admissionHeld flips back to false). */
  kick(): void {
    this.#ensureLoop();
  }

  #ensureLoop(): void {
    if (this.#wake) { this.#wake(); return; }
    if (this.#looping) return;
    this.#looping = true;
    void this.#drive();
  }

  async #drive(): Promise<void> {
    let release: (() => void) | null = null;
    try {
      while (true) {
        const held = this.#admissionHeld?.() === true;
        // Work = running rows, an in-flight prefill (finish it even under
        // drain — the row is already half-admitted), or admissible pending.
        const hasWork =
          this.#running.length > 0 ||
          this.#prefill !== null ||
          (!held && this.#pending.length > 0);
        if (!hasWork) {
          if (release) { release(); release = null; } // let the serial lane in
          await new Promise<void>((r) => { this.#wake = r; });
          this.#wake = null;
          continue;
        }
        if (!release && this.#lock) release = await this.#lock.acquire();

        // Start at most one joiner prefill (drain-aware); it advances one
        // chunk per iteration, interleaved with the decode step below.
        if (!this.#prefill && !held &&
            this.#pending.length > 0 && this.#running.length < this.#maxBatch &&
            this.#kvAdmits(this.#pending[0]!))
          this.#prefill = { row: this.#pending.shift()!, solo: this.model.makeCache(), pos: 0 };

        if (this.#prefill) {
          const p = this.#prefill;
          try {
            if (await this.#prefillChunk(p)) this.#prefill = null;
          } catch (e) {
            // Prefill/admission failure is per-row: reject the joiner, keep
            // the running batch.
            this.#prefill = null;
            for (const c of p.solo) c.dispose();
            p.row.reject(e);
          }
        }

        // Burst admission: when a joiner just COMPLETED and more batchable
        // requests are queued, admit them before the next decode step (the
        // admit-all-then-step grouping the mlx-lm goldens gate). Long prompts
        // still interleave: a mid-prefill joiner leaves #prefill non-null, so
        // the loop falls through to run a decode step between chunks.
        if (this.#prefill === null && !held &&
            this.#pending.length > 0 && this.#running.length < this.#maxBatch &&
            (this.#kvBudgetBytes === undefined ||
              this.projectedKvBytes + this.#rowKvBytes(this.#pending[0]!) <= this.#kvBudgetBytes))
          continue;

        if (this.#running.length > 0) {
          try {
            await this.#step();
          } catch (e) {
            // A forward/sampling error can't be attributed to one row — drop
            // the batch. (A row's onToken error is contained in #emitRows.)
            for (const row of this.#running) row.reject(e);
            this.#applyFilter([]);
          }
        }
        await new Promise<void>((r) => setImmediate(r));
      }
    } finally {
      if (release) release();
      this.#looping = false;
    }
  }

  /** Advance a joiner's solo prefill by one chunk. Non-final chunks forward +
   *  eval the cache and return false (the caller interleaves a decode step).
   *  The final chunk samples token 0, emits it, and — if the row survives —
   *  merges it into the running batch; returns true (admission complete). */
  async #prefillChunk(p: PrefillState): Promise<boolean> {
    const prompt = p.row.req.promptIds;
    if (prompt.length - p.pos > this.#prefillChunkSize) {
      const chunk = prompt.slice(p.pos, p.pos + this.#prefillChunkSize);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const h = this.model.forwardHidden(ids, p.solo);
      ids.dispose();
      h.dispose(); // logits never computed for non-final chunks
      ops.evalAll(p.solo.flatMap((c) => c.state()));
      clearCache(); // serial prefill's per-chunk clear (generate.ts)
      p.pos += this.#prefillChunkSize;
      return false;
    }

    // Final chunk: slice the LAST hidden position BEFORE the lm_head — running
    // logitsFromHidden on the whole [1,Lp,H] hidden materializes a [1,Lp,V]
    // transient (~4.3 GB bf16 at Gemma V=262k, 8k prompt). Same reorder as the
    // serial path (generate.ts prefill).
    const chunk = prompt.slice(p.pos);
    const ids = ops.fromInt32(chunk, [1, chunk.length]);
    const h = this.model.forwardHidden(ids, p.solo);
    ids.dispose();
    const [, Lc, H] = h.shape as [number, number, number];
    const hLast = h.slice([0, Lc - 1, 0], [1, Lc, H]);
    h.dispose();
    const lg = this.model.logitsFromHidden(hLast); // [1,1,V]
    hLast.dispose();
    const V = lg.shape[2]!;
    const last2 = ops.reshape(lg, [1, V]);
    lg.dispose();
    const tok = this.#readToken(p.row.req.sample(last2, 0));
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
        for (const c of p.solo) c.dispose();
        this.#finish(p.row, stop === "continue" ? "stop" : stop);
        return true;
      }
    }

    const stop = await this.#emit(p.row, tok);
    if (stop !== "continue") {
      for (const c of p.solo) c.dispose();
      this.#finish(p.row, stop);
      return true;
    }
    await this.#mergeJoiner(p);
    return true;
  }

  /** Merge a fully-prefilled joiner with the running batch, layer by layer
   *  (re-merge; `extend` is the later refinement). Flushes the decode pipeline
   *  first so the row set is settled and the next step starts cold. */
  async #mergeJoiner(p: PrefillState): Promise<void> {
    await this.#flushPipeline();

    const prev = this.#inners;
    const prevPad = this.#fullLeftPad;
    const B = this.#running.length;
    const newInners: LayerInner[] = [];
    let newFullPad = this.#fullLeftPad;
    for (let layer = 0; layer < this.#kinds.length; layer++) {
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
      const soloC = p.solo[layer] as KVCache | RotatingKVCache;
      const [sk, sv] = soloC.temporalView();
      const newRow: Row1 = { keys: sk, values: sv };
      if (this.#kinds[layer] === "rot") {
        const rows: Row1[] = [];
        const offsets: number[] = [];
        const prevRot = prev?.[layer] as BatchedRotatingCache | undefined;
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
        const rows: Row1[] = [];
        const prevFull = prev?.[layer] as KVCache | undefined;
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
    if (prev) for (const c of prev) c.dispose();
    for (const c of p.solo) c.dispose();
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
    if (anyLive) {
      // Per-layer forward cache: rot layers use the persistent
      // BatchedRotatingCache directly; ssm layers are already [B,...] state
      // with no padding (no mask, no per-row RoPE — pass through); full
      // layers get a fresh BatchedDecodeMaskCache wrapper.
      const fwd: Cache[] = inners.map((c) =>
        c instanceof BatchedRotatingCache || c instanceof SSMCache
          ? c
          : new BatchedDecodeMaskCache(c, B, this.#fullLeftPad, null),
      );
      try {
        const ids = this.#pendingToks
          ? ops.reshape(this.#pendingToks, [B, 1]) // feed the unread tokens
          : ops.fromInt32(rows.map((r) => r.current), [B, 1]); // pipeline cold
        const h = this.model.forwardHidden(ids, fwd);
        ids.dispose();
        const lg = this.model.logitsFromHidden(h); // [B,1,V]
        h.dispose();
        const V = lg.shape[2]!;
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
        ops.asyncEvalAll([nextToks]); // dispatch; read NEXT iteration
      } finally {
        // Free the step's RoPE arrays; do NOT dispose (full wrappers would free
        // their persistent inner; rot caches persist across steps).
        for (const c of fwd) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
      }
    }
    this.#steps++;
    if (this.#steps % 256 === 0) clearCache(); // serial's cadence, not per-step

    // Read + emit the PREVIOUS step's tokens while the new step computes.
    const prev = this.#pendingToks;
    this.#pendingToks = nextToks;
    // Kill switch / A-B lever (house style, cf. MLX_BUN_COMPILED_DECODE=0):
    // MLX_BUN_BATCH_NO_PIPELINE=1 reads THIS step's tokens synchronously —
    // set from process start `prev` is always null, so the flush below IS the
    // whole phase 2. Same math either way (pipelining is scheduling).
    if (NO_PIPELINE) {
      await this.#flushPipeline();
      return;
    }
    if (prev) {
      const toks = [...prev.toFloat32()].map((x) => Math.round(x));
      prev.dispose();
      await this.#emitRows(toks); // also filters #pendingToks on eviction
    }
  }

  /** Read out the pipeline register (if any): emit its tokens and evict
   *  finished rows, leaving the pipeline cold. Called before a join merges. */
  async #flushPipeline(): Promise<void> {
    const prev = this.#pendingToks;
    if (!prev) return;
    this.#pendingToks = null;
    const toks = [...prev.toFloat32()].map((x) => Math.round(x));
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
      prev ? [...prev.toFloat32()].map((x) => Math.round(x)) : [];
    if (process.env.MLX_BUN_GRAMMAR_DEBUG === "1")
      console.log(`[sg] B=${B} prevVals=${JSON.stringify(prevVals)} current=${JSON.stringify(rows.map((r) => r.current))} sampled=${JSON.stringify(rows.map((r) => r.sampled))}`);

    // (2) accept() per live grammar row — fires that row's async bitmask fill.
    for (let b = 0; b < B && prevVals.length; b++) {
      const g = rows[b]!.req.grammar;
      if (g && !g.isTerminated) g.accept(prevVals[b]!);
    }

    let nextToks: MlxArray | null = null;
    const anyLive = rows.some((r) => r.sampled < r.req.maxTokens);
    if (anyLive) {
      const fwd: Cache[] = inners.map((c) =>
        c instanceof BatchedRotatingCache || c instanceof SSMCache
          ? c
          : new BatchedDecodeMaskCache(c, B, this.#fullLeftPad, null),
      );
      try {
        // (3) Build the forward graph (host-side; the fills overlap it).
        const ids = prev
          ? ops.reshape(prev, [B, 1]) // feed the unread tokens (device array)
          : ops.fromInt32(rows.map((r) => r.current), [B, 1]); // pipeline cold
        const h = this.model.forwardHidden(ids, fwd);
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
    for (let b = 0; b < B; b++) {
      const row = rows[b]!;
      row.generated++;
      let disp: "continue" | "stop" | "length";
      try {
        disp = await this.#emit(row, toks[b]!);
      } catch (e) {
        row.reject(e); // containment: this row only (mlx-lm `remove`)
        continue; // not kept → evicted by the filter below
      }
      if (disp === "continue") keep.push(b);
      else this.#finish(row, disp);
    }
    if (keep.length < B) this.#applyFilter(keep);
  }

  /** Account one sampled token for a row. Mirrors generate(): EOS terminates
   *  WITHOUT an onToken call; otherwise onToken(token) runs and `false` halts;
   *  reaching maxTokens ends with "length". Advances row.current on continue. */
  async #emit(row: Row, token: number): Promise<"continue" | "stop" | "length"> {
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
    row.resolve({
      promptTokens: row.promptTokens,
      generatedTokens: row.generated,
      cachedTokens: 0,
      finishReason: reason,
    });
  }

  /** Evict rows not in `keep` (sorted ascending) from the batched KV and the
   *  pipeline register. */
  #applyFilter(keep: number[]): void {
    const inners = this.#inners!;
    if (keep.length === 0) {
      for (const c of inners) c.dispose();
      this.#inners = null;
      this.#fullLeftPad = [];
      this.#running = [];
      this.#pendingToks?.dispose();
      this.#pendingToks = null;
      return;
    }
    const out: LayerInner[] = [];
    for (const inner of inners) {
      if (inner instanceof BatchedRotatingCache) {
        inner.filter(keep); // in-place (mutates + drops rows + reduces padding)
        out.push(inner);
      } else if (inner instanceof SSMCache) {
        inner.filter(keep); // in-place B-axis take on both state slots
        out.push(inner);
      } else {
        const [k0, v0] = inner.temporalView();
        const f = filterKVRows(k0, v0, keep);
        k0.dispose(); v0.dispose();
        const c = new KVCache();
        c.restoreState(f.keys, f.values, inner.offset);
        out.push(c);
        inner.dispose();
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
  }

  #readToken(t: MlxArray): number {
    const v = Math.round(t.toFloat32()[0]!);
    t.dispose();
    return v;
  }
}
