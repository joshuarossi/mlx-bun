// Continuous-batching scheduler for `--batch N` serving (phase S2, the engine
// loop). Owns ONE running batch and drives it forward one decode step at a
// time, admitting waiting requests and evicting finished ones between steps —
// iteration-level (continuous) scheduling, not static batching. See
// docs/design/parallel-slots.md.
//
// The numerically-hard parts are already verified primitives:
//   - the batched FORWARD (BatchedDecodeMaskCache + per-row RoPE/mask) is
//     bit-parity with mlx-lm B=N across all 4 models (tests/batched-decode-parity);
//   - the dynamic-B cache ops mergeKVRows / filterKVRows are oracle-verified
//     against mlx-lm BatchKVCache.merge/.extract/.filter (rows join/leave).
// This module is the ORCHESTRATION on top: admission, the step loop, per-row
// sampling + token accounting, and eviction. Its correctness gate
// (tests/batch-scheduler.test.ts) checks each row's greedy output equals its
// solo greedy decode — i.e. batching + the scheduler don't change any row's
// result.
//
// SCOPE (v1): full-attention models only (every layer a KVCache). Sliding-
// window (RotatingKVCache) dynamic-B batched decode is a follow-up (ring-wrap
// per-row mask), so a rotating-cache model throws here and the server routes it
// to the serial path. Greedy or any per-row `sample` closure is supported; the
// _is_batchable gate (fixed seed / vision / adapter-mismatch → serial) and KV
// budget admission live in the server wiring (step 3), not here.
//
// Bun-async, NO threads: a single detached driver loop owns the GPU for batched
// mode. Joins re-merge the whole batch (mergeKVRows on extracted advanced-offset
// rows + a fresh solo prefill); the keep-the-running-batch `extend` optimization
// is a later refinement.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { clearCache } from "../mlx/ffi";
import { KVCache } from "../model/gemma4-base";
import { BatchedDecodeMaskCache, mergeKVRows, filterKVRows } from "../model/batched-mask";
import type { RuntimeModel } from "../model/factory";

/** A token sampler for one row: (logits [1,V], step) → token array [1] on
 *  device. Greedy is `(l) => ops.argmaxAxis(l, -1)`; richer closures fold in
 *  temperature / top-p / logits processors + history (built per request from
 *  its sampler options, exactly like generate()'s sampleStep). */
export type RowSampler = (logits1V: MlxArray, step: number) => MlxArray;

export interface BatchRequest {
  promptIds: number[];
  maxTokens: number;
  eosTokenIds: number[];
  sample: RowSampler;
  /** Called per emitted (non-EOS) token, in order. Returning `false` halts this
   *  row (a decoded-text stop sequence fired) — matches generate()'s onToken
   *  contract. EOS terminates the row WITHOUT an onToken call (mlx-lm/generate
   *  never emit the EOS token to the consumer). May be async; keep it cheap —
   *  it runs inline in the step loop and a slow await stalls the whole batch. */
  onToken: (token: number) => void | boolean | Promise<void | boolean>;
}

export interface BatchStats {
  promptTokens: number;
  generatedTokens: number;
  /** Prompt tokens served from a pre-warmed cache. Always 0 in v1 (each row is
   *  solo-prefilled from scratch; prompt-cache reuse under batching is a later
   *  refinement). */
  cachedTokens: number;
  finishReason: "stop" | "length";
}

interface Row {
  req: BatchRequest;
  resolve: (s: BatchStats) => void;
  reject: (e: unknown) => void;
  current: number; // last emitted token, fed at the next step
  generated: number; // tokens emitted so far (incl. a terminating EOS)
  promptTokens: number;
}

/** Mutual-exclusion lock the scheduler holds for its whole ACTIVE period (first
 *  admit → batch empties), so a serial-path generation never touches the GPU
 *  (or shared model state like loraState) while a batch is in flight. acquire()
 *  resolves to a release fn. Omit for standalone use (e.g. the unit test). */
export interface ExclusiveLock {
  acquire(): Promise<() => void>;
}

export interface BatchSchedulerOptions {
  /** Max rows in the running batch (mlx-lm `--decode-concurrency`). */
  maxBatch: number;
  /** Held while the batch is active; the serial fallback acquires the same lock. */
  lock?: ExclusiveLock;
}

export class BatchScheduler {
  #running: Row[] = [];
  #inners: KVCache[] | null = null; // per-layer batched KV; null when empty
  #leftPad: number[] = [];
  #pending: Row[] = [];
  #looping = false;
  #wake: (() => void) | null = null;
  readonly #maxBatch: number;
  readonly #layerCount: number;
  readonly #lock: ExclusiveLock | undefined;

  constructor(private readonly model: RuntimeModel, opts: BatchSchedulerOptions) {
    this.#maxBatch = Math.max(1, Math.floor(opts.maxBatch));
    this.#lock = opts.lock;
    this.#layerCount = model.makeCache().length; // fresh caches hold no buffers
  }

  /** Number of rows currently decoding (for /stats). */
  get activeRows(): number {
    return this.#running.length;
  }

  /** Submit a request; resolves when its row finishes (EOS, stop, or length). */
  submit(req: BatchRequest): Promise<BatchStats> {
    return new Promise<BatchStats>((resolve, reject) => {
      this.#pending.push({
        req, resolve, reject,
        current: 0, generated: 0, promptTokens: req.promptIds.length,
      });
      this.#ensureLoop();
    });
  }

  #ensureLoop(): void {
    if (this.#wake) { this.#wake(); return; } // loop idle — wake it
    if (this.#looping) return;
    this.#looping = true;
    void this.#drive();
  }

  async #drive(): Promise<void> {
    // Held for the whole active period (acquired when work appears, released
    // when the batch empties), so the serial fallback can't run concurrently.
    let release: (() => void) | null = null;
    try {
      while (true) {
        if (!release && this.#lock && (this.#pending.length > 0 || this.#running.length > 0))
          release = await this.#lock.acquire();

        // Admit waiting requests into free slots (solo prefill + merge).
        while (this.#pending.length > 0 && this.#running.length < this.#maxBatch) {
          const row = this.#pending.shift()!;
          try {
            await this.#admit(row);
          } catch (e) {
            row.reject(e);
          }
        }
        if (this.#running.length === 0) {
          if (this.#pending.length > 0) continue; // a row finished on admit; loop
          // Idle: release the lock and suspend until the next submit wakes us.
          if (release) { release(); release = null; }
          await new Promise<void>((r) => { this.#wake = r; });
          this.#wake = null;
          continue;
        }
        try {
          await this.#step();
        } catch (e) {
          // A batched forward error is batch-wide and unrecoverable for these
          // rows — fail them all and clear the batch so the loop goes idle.
          for (const row of this.#running) row.reject(e);
          this.#applyFilter([]);
        }
        // Yield to the event loop so each row's SSE socket flushes between
        // steps (the batched analogue of generate()'s per-token macrotask hop).
        await new Promise<void>((r) => setImmediate(r));
      }
    } finally {
      if (release) release();
      this.#looping = false;
    }
  }

  /** A row's full KV as a [1,H,len,D] row pair (offset == valid length). */
  #soloRow(c: KVCache): { keys: MlxArray; values: MlxArray } {
    const [keys, values] = c.temporalView();
    return { keys, values };
  }

  /** Rebuild the per-layer batched inners from per-layer row lists via mergeKVRows. */
  #rebuild(getRows: (layer: number) => { keys: MlxArray; values: MlxArray }[]): {
    inners: KVCache[]; leftPad: number[];
  } {
    const L = this.#layerCount;
    const inners: KVCache[] = [];
    let leftPad: number[] = [];
    for (let layer = 0; layer < L; layer++) {
      const rows = getRows(layer);
      const merged = mergeKVRows(rows);
      for (const r of rows) { r.keys.dispose(); r.values.dispose(); }
      const c = new KVCache();
      c.restoreState(merged.keys, merged.values, merged.width);
      inners.push(c);
      leftPad = merged.leftPad;
    }
    return { inners, leftPad };
  }

  /** Solo-prefill a joining request, emit its first token, and (if it survives)
   *  merge it into the running batch. */
  async #admit(row: Row): Promise<void> {
    const solo = this.model.makeCache();
    if (solo.some((c) => !(c instanceof KVCache)))
      throw new Error(
        "batched serving (v1) supports full-attention models only; this model uses " +
        "a sliding-window cache (RotatingKVCache) — route to the serial path",
      );
    const soloK = solo as KVCache[];
    const ids = ops.fromInt32(row.req.promptIds, [1, row.req.promptIds.length]);
    const h = this.model.forwardHidden(ids, soloK);
    ids.dispose();
    const lg = this.model.logitsFromHidden(h);
    h.dispose();
    const [, Lp, V] = lg.shape as [number, number, number];
    const last = lg.slice([0, Lp - 1, 0], [1, Lp, V]);
    lg.dispose();
    const last2 = ops.reshape(last, [1, V]);
    last.dispose();
    const tok = this.#readToken(row.req.sample(last2, 0));
    last2.dispose();
    row.generated = 1;
    clearCache();

    const stop = await this.#emit(row, tok); // EOS/onToken=false/length → finishes the row
    if (stop !== "continue") {
      for (const c of soloK) c.dispose();
      this.#finish(row, stop);
      return;
    }

    // Merge the freshly-prefilled row into the running batch.
    if (this.#running.length === 0) {
      this.#inners = soloK; // B=1 batch: solo caches ARE the batch (leftPad 0)
      this.#leftPad = [0];
      this.#running = [row];
      return;
    }
    const prev = this.#inners!;
    const prevLeftPad = this.#leftPad;
    const off = prev[0]!.offset;
    const built = this.#rebuild((layer) => {
      const [k0, v0] = prev[layer]!.temporalView(); // [B,H,off,D]
      const [, H, , D] = k0.shape as [number, number, number, number];
      const vD = v0.shape[3]!;
      const rows: { keys: MlxArray; values: MlxArray }[] = [];
      for (let b = 0; b < this.#running.length; b++) {
        const pad = prevLeftPad[b]!;
        rows.push({
          keys: k0.slice([b, 0, pad, 0], [b + 1, H, off, D]),
          values: v0.slice([b, 0, pad, 0], [b + 1, H, off, vD]),
        });
      }
      k0.dispose(); v0.dispose();
      rows.push(this.#soloRow(soloK[layer]!));
      return rows;
    });
    for (const c of prev) c.dispose();
    for (const c of soloK) c.dispose();
    this.#inners = built.inners;
    this.#leftPad = built.leftPad;
    this.#running.push(row);
  }

  /** One batched decode step: forward all rows, sample per row, emit, evict. */
  async #step(): Promise<void> {
    const rows = this.#running;
    const B = rows.length;
    const inners = this.#inners!;
    const wrappers = inners.map(
      (c) => new BatchedDecodeMaskCache(c, B, this.#leftPad, null),
    );
    let toks: number[];
    try {
      const ids = ops.fromInt32(rows.map((r) => r.current), [B, 1]);
      const h = this.model.forwardHidden(ids, wrappers);
      ids.dispose();
      const lg = this.model.logitsFromHidden(h); // [B,1,V]
      h.dispose();
      const V = lg.shape[2]!;
      const sampled: MlxArray[] = [];
      for (let b = 0; b < B; b++) {
        const rl = lg.slice([b, 0, 0], [b + 1, 1, V]);
        const rl2 = ops.reshape(rl, [1, V]);
        rl.dispose();
        sampled.push(rows[b]!.req.sample(rl2, rows[b]!.generated));
        rl2.dispose();
      }
      lg.dispose();
      const tokArr = ops.concatAxis(sampled, 0); // [B]
      for (const t of sampled) t.dispose();
      toks = [...tokArr.toFloat32()].map((x) => Math.round(x));
      tokArr.dispose();
    } finally {
      for (const w of wrappers) w.releaseRopeArr();
    }
    clearCache();

    // Emit per row; collect survivors. (Sequential awaits: onToken callbacks
    // are cheap microtasks; the GPU step above is the cost.)
    const keep: number[] = [];
    for (let b = 0; b < B; b++) {
      const row = rows[b]!;
      row.generated++;
      const disp = await this.#emit(row, toks[b]!);
      if (disp === "continue") keep.push(b);
      else this.#finish(row, disp);
    }
    if (keep.length < B) this.#applyFilter(keep);
  }

  /** Account one sampled token for a row. Returns "continue" if the row stays
   *  alive, else the finish reason. Mirrors generate(): EOS terminates WITHOUT
   *  an onToken call; otherwise onToken(token) runs and `false` halts; reaching
   *  maxTokens ends with "length". Advances row.current on continue. */
  async #emit(row: Row, token: number): Promise<"continue" | "stop" | "length"> {
    if (row.req.eosTokenIds.includes(token)) return "stop";
    const cont = await row.req.onToken(token);
    if (cont === false) return "stop";
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

  /** Evict rows not in `keep` (sorted ascending) from the batched KV. */
  #applyFilter(keep: number[]): void {
    const inners = this.#inners!;
    if (keep.length === 0) {
      for (const c of inners) c.dispose();
      this.#inners = null;
      this.#leftPad = [];
      this.#running = [];
      return;
    }
    const off = inners[0]!.offset;
    const out: KVCache[] = [];
    for (let layer = 0; layer < inners.length; layer++) {
      const [k0, v0] = inners[layer]!.temporalView();
      const f = filterKVRows(k0, v0, keep);
      k0.dispose(); v0.dispose();
      const c = new KVCache();
      c.restoreState(f.keys, f.values, off);
      out.push(c);
    }
    for (const c of inners) c.dispose();
    this.#inners = out;
    this.#leftPad = keep.map((i) => this.#leftPad[i]!);
    this.#running = keep.map((i) => this.#running[i]!);
  }

  #readToken(t: MlxArray): number {
    const v = Math.round(t.toFloat32()[0]!);
    t.dispose();
    return v;
  }
}
