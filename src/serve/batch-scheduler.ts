// Continuous-batching scheduler for `--batch N` serving (phase S2, the engine
// loop). Owns ONE running batch and drives it forward one decode step at a
// time, admitting waiting requests and evicting finished ones between steps —
// iteration-level (continuous) scheduling, not static batching. See
// docs/design/parallel-slots.md.
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
// rot: offsetArr) — see docs/design/parallel-slots.md.
//
// Bun-async, NO threads: a single detached driver loop owns the GPU for batched
// mode (an ExclusiveLock keeps the serial fallback off the GPU concurrently).
// Joins re-merge the whole batch; the keep-the-running-batch `extend`
// optimization is a later refinement.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { clearCache } from "../mlx/ffi";
import { KVCache, RotatingKVCache, type Cache } from "../model/gemma4-base";
import { BatchedDecodeMaskCache, mergeKVRows, filterKVRows } from "../model/batched-mask";
import { BatchedRotatingCache } from "../model/batched-rotating";
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
   *  contract. EOS terminates the row WITHOUT an onToken call. May be async;
   *  keep it cheap — it runs inline in the step loop. */
  onToken: (token: number) => void | boolean | Promise<void | boolean>;
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
  current: number; // last emitted token, fed at the next step
  generated: number; // tokens emitted so far (incl. a terminating EOS)
  promptTokens: number;
}

/** Held while the batch is active; the serial fallback acquires the same lock. */
export interface ExclusiveLock {
  acquire(): Promise<() => void>;
}

export interface BatchSchedulerOptions {
  /** Max rows in the running batch (mlx-lm `--decode-concurrency`). */
  maxBatch: number;
  lock?: ExclusiveLock;
}

type LayerInner = KVCache | BatchedRotatingCache;
type Row1 = { keys: MlxArray; values: MlxArray };

export class BatchScheduler {
  #running: Row[] = [];
  #inners: LayerInner[] | null = null; // per-layer batched KV; null when empty
  #fullLeftPad: number[] = []; // per-row padding for FULL layers (rot self-tracks)
  #pending: Row[] = [];
  #looping = false;
  #wake: (() => void) | null = null;
  readonly #maxBatch: number;
  readonly #lock: ExclusiveLock | undefined;
  readonly #kinds: ("full" | "rot")[]; // per-layer attention type
  readonly #rotMaxSize: number[]; // per-layer sliding window (rot layers only)

  constructor(private readonly model: RuntimeModel, opts: BatchSchedulerOptions) {
    this.#maxBatch = Math.max(1, Math.floor(opts.maxBatch));
    this.#lock = opts.lock;
    const proto = model.makeCache(); // fresh caches hold no buffers
    this.#kinds = proto.map((c) => (c instanceof RotatingKVCache ? "rot" : "full"));
    this.#rotMaxSize = proto.map((c) => (c instanceof RotatingKVCache ? c.maxSize : 0));
  }

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
    if (this.#wake) { this.#wake(); return; }
    if (this.#looping) return;
    this.#looping = true;
    void this.#drive();
  }

  async #drive(): Promise<void> {
    let release: (() => void) | null = null;
    try {
      while (true) {
        if (!release && this.#lock && (this.#pending.length > 0 || this.#running.length > 0))
          release = await this.#lock.acquire();

        while (this.#pending.length > 0 && this.#running.length < this.#maxBatch) {
          const row = this.#pending.shift()!;
          try {
            await this.#admit(row);
          } catch (e) {
            row.reject(e);
          }
        }
        if (this.#running.length === 0) {
          if (this.#pending.length > 0) continue;
          if (release) { release(); release = null; }
          await new Promise<void>((r) => { this.#wake = r; });
          this.#wake = null;
          continue;
        }
        try {
          await this.#step();
        } catch (e) {
          for (const row of this.#running) row.reject(e);
          this.#applyFilter([]);
        }
        await new Promise<void>((r) => setImmediate(r));
      }
    } finally {
      if (release) release();
      this.#looping = false;
    }
  }

  /** Solo-prefill a joining request, emit its first token, and (if it survives)
   *  re-merge it with the running batch (per-layer, by attention type). */
  async #admit(row: Row): Promise<void> {
    const solo = this.model.makeCache();
    const ids = ops.fromInt32(row.req.promptIds, [1, row.req.promptIds.length]);
    const h = this.model.forwardHidden(ids, solo);
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

    const stop = await this.#emit(row, tok);
    if (stop !== "continue") {
      for (const c of solo) c.dispose();
      this.#finish(row, stop);
      return;
    }

    // Re-merge the running batch + the new row, layer by layer.
    const prev = this.#inners;
    const prevPad = this.#fullLeftPad;
    const B = this.#running.length;
    const newInners: LayerInner[] = [];
    let newFullPad = this.#fullLeftPad;
    for (let layer = 0; layer < this.#kinds.length; layer++) {
      const soloC = solo[layer] as KVCache | RotatingKVCache;
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
    for (const c of solo) c.dispose();
    this.#inners = newInners;
    this.#fullLeftPad = newFullPad;
    this.#running.push(row);
  }

  /** One batched decode step: forward all rows, sample per row, emit, evict. */
  async #step(): Promise<void> {
    const rows = this.#running;
    const B = rows.length;
    const inners = this.#inners!;
    // Per-layer forward cache: rot layers use the persistent BatchedRotatingCache
    // directly; full layers get a fresh BatchedDecodeMaskCache wrapper.
    const fwd: Cache[] = inners.map((c) =>
      c instanceof BatchedRotatingCache ? c : new BatchedDecodeMaskCache(c, B, this.#fullLeftPad, null),
    );
    let toks: number[];
    try {
      const ids = ops.fromInt32(rows.map((r) => r.current), [B, 1]);
      const h = this.model.forwardHidden(ids, fwd);
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
      // Free the step's RoPE arrays; do NOT dispose (full wrappers would free
      // their persistent inner; rot caches persist across steps).
      for (const c of fwd) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
    }
    clearCache();

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

  /** Account one sampled token for a row. Mirrors generate(): EOS terminates
   *  WITHOUT an onToken call; otherwise onToken(token) runs and `false` halts;
   *  reaching maxTokens ends with "length". Advances row.current on continue. */
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
      this.#fullLeftPad = [];
      this.#running = [];
      return;
    }
    const out: LayerInner[] = [];
    for (const inner of inners) {
      if (inner instanceof BatchedRotatingCache) {
        inner.filter(keep); // in-place (mutates + drops rows + reduces padding)
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
  }

  #readToken(t: MlxArray): number {
    const v = Math.round(t.toFloat32()[0]!);
    t.dispose();
    return v;
  }
}
