// Batched sliding-window (rotating) KV cache for `--batch N` serving — the
// hard half of dynamic-B that BatchedDecodeMaskCache (full-attention) doesn't
// cover. Faithful port of mlx-lm's BatchRotatingKVCache (models/cache.py):
// a shared ring buffer whose rotation state (_idx / _offset / rotated) is
// SCALAR across the batch (all rows advance one token per step, so the write
// column is the same for every row), with PER-ROW `offset` (absolute position,
// drives RoPE) and `leftPad` (padding columns in the buffer, masked out).
//
// SCOPE: only the pieces the scheduler needs — `merge` (assemble from solo
// prefills), the N=1 decode update (`_update_in_place`), `make_mask`, `filter`,
// and temporalView (extract). The N>1 batched-PREFILL path
// (`_update_concat`/`finalize`/`_lengths`) is NOT ported: the scheduler
// solo-prefills each request (single-stream RotatingKVCache) then merges, so
// this cache only ever sees N=1 updates. Positions (offset/leftPad/_idx/_offset/
// rotated) are tracked on the HOST (small deterministic ints) so make_mask is
// built in JS like buildBatchedDecodeMask; only K/V live on device.
//
// The genuinely tricky bit is make_mask once the ring wraps: the buffer is no
// longer in temporal order, so the causal+window+padding mask is built in
// temporal coordinates then ROLLED to the ring's physical layout — see
// buildBatchedRotatingMask (a column-by-column port of mlx-lm make_mask,
// including the `roll(shift=idx+1)`). Gated model-free against mlx-lm
// (tests/batched-rotating.test.ts) + end-to-end vs a long-context Gemma oracle.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { RotatingKVCache, type Cache, type Mask } from "./gemma4-base";
import { BatchedRotatingState } from "./batched-rotating-state";
import {
  mergeStorageRows,
  plainRowStorage,
  temporalStorageView,
} from "./batched-row-storage";

const STEP = 256;

/** Port of BatchRotatingKVCache.make_mask for the DECODE case. Returns a
 *  [B,1,N,S] bool mask (S == min(maxSize-1, offsetScalar) + N) for the step
 *  ABOUT to be written: causal AND sliding-window AND per-row left-padding,
 *  rolled to the ring's physical layout once wrapped.
 *
 *  Inputs are the PRE-write scalar ring state (`idx`=_idx, `offsetScalar`=_offset,
 *  `rotated`) and per-row `leftPad`. The leftPad adjustments here are LOCAL to
 *  the mask (mlx-lm decrements left_padding both in make_mask AND in update; the
 *  update's decrement is the persistent one, applied separately by the cache). */
export function buildBatchedRotatingMask(
  B: number, N: number, leftPad: number[],
  maxSize: number, window: number, idx: number, offsetScalar: number, rotated: boolean,
): MlxArray {
  const off = Math.min(maxSize - 1, offsetScalar);
  const S = off + N;

  // Local (non-persisted) leftPad for the mask: trim + rotation shrink it.
  const trimSize = idx - maxSize + (N > 1 ? 1 : 0);
  const isRot = N === 1 && (rotated || idx >= maxSize);
  const lp = leftPad.map((x) => x - (trimSize > 0 ? trimSize : 0) - (isRot ? 1 : 0));

  // roll(shift): physical column = (temporal column + shift) mod S.
  const shift = isRot ? (idx >= maxSize ? 0 : idx) + 1 : 0;

  const data = new Int32Array(B * N * S);
  for (let b = 0; b < B; b++) {
    const pad = lp[b]!;
    for (let i = 0; i < N; i++) {
      const lind = off + i; // query temporal position
      for (let j = 0; j < S; j++) {
        // temporal key position j: causal, within window, past this row's pad.
        const allow = lind >= j && lind < j + window && j >= pad;
        if (!allow) continue;
        const col = ((j + shift) % S + S) % S;
        data[(b * N + i) * S + col] = 1;
      }
    }
  }
  const intArr = MlxArray.fromInt32(data, [B, 1, N, S]);
  const zero = MlxArray.fromInt32(new Int32Array([0]), []);
  const mask = ops.less(zero, intArr); // 0 < x → bool
  zero.dispose();
  intArr.dispose();
  return mask;
}

/** Faithful port of mlx-lm BatchRotatingKVCache (decode-only — see file header). */
export class BatchedRotatingCache implements Cache {
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  readonly #rows: BatchedRotatingState;
  #ropeArr: MlxArray | null = null;
  #ropeForOffset = -1;
  readonly maxSize: number;

  constructor(maxSize: number, leftPad: number[]) {
    this.maxSize = maxSize;
    this.#rows = new BatchedRotatingState(maxSize, leftPad);
  }

  /** Same signature as the serial RotatingKVCache — the scheduler's merge
   *  guards recognize a batched ring as "rotating-plain + RowBatchCache"
   *  (batch-scheduler #mergeJoiner prevRot branch); without this the next
   *  join sees "unknown", skips the prevRot rows, and replaces the batch's
   *  sliding-layer KV with a one-row cache (B≥3 collapse). Guard order
   *  everywhere is isRowBatchCache FIRST, so the shared string never
   *  misroutes a batched cache into a serial-only path. */
  signature(): string { return "kv:rotating-plain"; }

  get offsetArr(): number[] { return this.#rows.offsets; }
  get leftPad(): number[] { return this.#rows.leftPad; }
  get batchSize(): number { return this.#rows.batchSize; }

  /** Current batch size — tracks filter() (which shrinks the per-row arrays). */
  get #B(): number {
    return this.#rows.batchSize;
  }

  /** mlx-lm uses `cache.offset` (the per-row array) for the scalar interface
   *  too; we expose the scalar total as `offset` and the per-row positions via
   *  `ropeOffsetArr` (the model's per-row RoPE path). */
  get offset(): number {
    return this.#rows.totalOffset;
  }

  get ropeOffsetArr(): MlxArray {
    if (this.#ropeArr && this.#ropeForOffset === this.offset) return this.#ropeArr;
    this.#ropeArr?.dispose();
    this.#ropeArr = MlxArray.fromInt32(Int32Array.from(this.offsetArr), [this.#B]);
    this.#ropeForOffset = this.offset;
    return this.#ropeArr;
  }

  makeMask(N: number, windowSize: number | null): Mask {
    const window = windowSize ?? this.maxSize;
    return {
      mode: "array",
      arr: buildBatchedRotatingMask(
        this.#B, N, this.leftPad, this.maxSize, window,
        this.#rows.ringIndex, this.offset, this.#rows.rotated,
      ),
    };
  }

  /** N=1 decode update — port of _update_in_place. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const [B, H, S, D] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    if (S !== 1)
      throw new Error("BatchedRotatingCache supports N=1 decode updates only (solo-prefill then merge)");
    const prev = this.offset;

    // Grow the buffer (in STEP chunks) until it reaches maxSize.
    if (!this.keys || (prev >= this.keys.shape[2]! && this.keys.shape[2]! < this.maxSize)) {
      const newSize = Math.min(STEP, this.maxSize - prev);
      const newK = ops.zeros([B, H, newSize, D], k.dtype);
      const newV = ops.zeros([B, H, newSize, vD], v.dtype);
      if (this.keys && this.values) {
        const ck = ops.concatAxis([this.keys, newK], 2);
        const cv = ops.concatAxis([this.values, newV], 2);
        for (const a of [this.keys, this.values, newK, newV]) a.dispose();
        this.keys = ck;
        this.values = cv;
      } else {
        this.keys = newK;
        this.values = newV;
      }
      this.#rows.markGrown(prev);
    }

    // Trim any overshoot past maxSize (decrements left padding persistently).
    const trimSize = this.keys!.shape[2]! - this.maxSize;
    if (trimSize > 0) {
      const tk = this.keys!.slice([0, 0, trimSize, 0], this.keys!.shape as number[]);
      const tv = this.values!.slice([0, 0, trimSize, 0], this.values!.shape as number[]);
      this.keys!.dispose();
      this.values!.dispose();
      this.keys = tk;
      this.values = tv;
      this.#rows.trimOvershoot(trimSize);
    }

    // Rotate when the write head reaches the end of the ring.
    const writeIndex = this.#rows.beginWrite(S);

    // Write the new K/V at the ring head.
    const [, , SK, DK] = this.keys!.shape as [number, number, number, number];
    const k2 = ops.sliceUpdate(this.keys!, k, [0, 0, writeIndex, 0], [B, H, writeIndex + S, DK]);
    const v2 = ops.sliceUpdate(this.values!, v, [0, 0, writeIndex, 0], [B, H, writeIndex + S, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = k2;
    this.values = v2;
    this.#rows.commitWrite(S);

    // Return the populated prefix (ring not yet full) or the whole buffer.
    if (this.offset < this.maxSize) {
      return [
        this.keys.slice([0, 0, 0, 0], [B, H, this.offset, DK]),
        this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]),
      ];
    }
    return [
      this.keys.slice([0, 0, 0, 0], [B, H, SK, DK]),
      this.values.slice([0, 0, 0, 0], [B, H, SK, vD]),
    ];
  }

  /** Free the per-step RoPE array without disposing KV (wrapper-rebuild path). */
  releaseRopeArr(): void {
    this.#ropeArr?.dispose();
    this.#ropeArr = null;
    this.#ropeForOffset = -1;
  }

  /** Ring contents in temporal order, cut to the valid length (extract). */
  temporalView(): [MlxArray, MlxArray] {
    if (!this.keys || !this.values) throw new Error("cache is empty");
    return [
      temporalStorageView(plainRowStorage, this.keys, this.#rows),
      temporalStorageView(plainRowStorage, this.values, this.#rows),
    ];
  }

  /** mlx-lm `BatchRotatingKVCache.extract` (models/cache.py:1417): row `i`
   *  as a fresh SERIAL RotatingKVCache — de-rolled to temporal order (the
   *  oracle's roll(-_idx) when rotated), left padding stripped
   *  (`max(0, left_padding[idx])` — post-wrap pads go negative), OWNED
   *  contiguous copies. `offset` = the row's absolute position (may exceed
   *  the buffer: wrapped rings have evicted tokens); ring idx = the new
   *  buffer length — temporal order ⇔ write head at the end, exactly the
   *  oracle's `cache._idx = cache.keys.shape[2]`. Bit-exact vs a solo run:
   *  merge/decode/filter keep each row's ring bytes identical to the serial
   *  cache's (tests/batched-rotating) and this is a pure slice+copy. */
  extractRow(i: number): RotatingKVCache | null {
    if (!this.keys || !this.values) return null;
    const pad = Math.max(0, this.leftPad[i]!);
    const c = new RotatingKVCache(this.maxSize);
    const k = temporalStorageView(plainRowStorage, this.keys, this.#rows, {
      row: i, from: pad, copy: true,
    });
    const v = temporalStorageView(plainRowStorage, this.values, this.#rows, {
      row: i, from: pad, copy: true,
    });
    c.restoreState(k, v, this.offsetArr[i]!, k.shape[2]!);
    return c;
  }

  /** Keep only `keep` rows along the batch axis (eviction). */
  filter(keep: number[]): void {
    if (this.keys && this.values) {
      const k = plainRowStorage.takeRows(this.keys, keep);
      const v = plainRowStorage.takeRows(this.values, keep);
      this.keys.dispose();
      this.values.dispose();
      this.keys = k;
      this.values = v;
    }
    this.#rows.filter(keep);
    this.releaseRopeArr();
  }

  filterRows(keep: readonly number[]): void { this.filter([...keep]); }

  state(): MlxArray[] {
    return this.keys && this.values ? [this.keys, this.values] : [];
  }
  isTrimmable(): boolean {
    return this.#rows.trimmable;
  }
  trim(n: number): void {
    this.#rows.trim(n);
  }
  dispose(): void {
    this.keys?.dispose();
    this.values?.dispose();
    this.keys = this.values = null;
    this.#ropeArr?.dispose();
    this.#ropeArr = null;
  }

  /** Assemble a batch from per-row temporal KV slices (port of merge). Each row
   *  is its solo cache's temporalView ([1,H,Li,D], Li ≤ maxSize, temporal
   *  order) and `offsets[i]` its absolute position. Left-pads to the longest
   *  row; the result is in temporal order (rotated=false, idx=offset=width). */
  static merge(
    rows: { keys: MlxArray; values: MlxArray }[], offsets: number[], maxSize: number,
  ): BatchedRotatingCache {
    const lens = rows.map((r) => r.keys.shape[2]!);
    const width = Math.max(...lens, 0);
    const leftPad = lens.map((l) => width - l);
    const cache = new BatchedRotatingCache(maxSize, leftPad);
    cache.#rows.restoreMerged(width, offsets);
    if (width === 0) return cache;

    cache.keys = mergeStorageRows(plainRowStorage, rows.map((row) => row.keys), leftPad);
    cache.values = mergeStorageRows(plainRowStorage, rows.map((row) => row.values), leftPad);
    return cache;
  }
}
