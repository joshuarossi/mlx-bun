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
import type { Cache, Mask } from "./gemma4-base";

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
  /** Per-row absolute position (drives RoPE) and buffer padding. */
  offsetArr: number[];
  leftPad: number[];
  #idx = 0;
  #offset = 0; // scalar total tokens processed (mlx-lm _offset)
  #rotated = false;
  #ropeArr: MlxArray | null = null;
  #ropeForOffset = -1;
  readonly maxSize: number;

  constructor(maxSize: number, leftPad: number[]) {
    this.maxSize = maxSize;
    this.leftPad = [...leftPad];
    this.offsetArr = leftPad.map((l) => -l);
  }

  /** Current batch size — tracks filter() (which shrinks the per-row arrays). */
  get #B(): number {
    return this.leftPad.length;
  }

  /** mlx-lm uses `cache.offset` (the per-row array) for the scalar interface
   *  too; we expose the scalar total as `offset` and the per-row positions via
   *  `ropeOffsetArr` (the model's per-row RoPE path). */
  get offset(): number {
    return this.#offset;
  }

  get ropeOffsetArr(): MlxArray {
    if (this.#ropeArr && this.#ropeForOffset === this.#offset) return this.#ropeArr;
    this.#ropeArr?.dispose();
    this.#ropeArr = MlxArray.fromInt32(Int32Array.from(this.offsetArr), [this.#B]);
    this.#ropeForOffset = this.#offset;
    return this.#ropeArr;
  }

  makeMask(N: number, windowSize: number | null): Mask {
    const window = windowSize ?? this.maxSize;
    return {
      mode: "array",
      arr: buildBatchedRotatingMask(
        this.#B, N, this.leftPad, this.maxSize, window,
        this.#idx, this.#offset, this.#rotated,
      ),
    };
  }

  /** N=1 decode update — port of _update_in_place. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const [B, H, S, D] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    if (S !== 1)
      throw new Error("BatchedRotatingCache supports N=1 decode updates only (solo-prefill then merge)");
    const prev = this.#offset;

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
      this.#idx = prev;
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
      this.#idx = this.maxSize;
      this.leftPad = this.leftPad.map((x) => x - trimSize);
    }

    // Rotate when the write head reaches the end of the ring.
    if (this.#idx === this.maxSize) {
      this.#rotated = true;
      this.#idx = 0;
    }
    if (this.#rotated) this.leftPad = this.leftPad.map((x) => x - S);

    // Write the new K/V at the ring head.
    const [, , SK, DK] = this.keys!.shape as [number, number, number, number];
    const k2 = ops.sliceUpdate(this.keys!, k, [0, 0, this.#idx, 0], [B, H, this.#idx + S, DK]);
    const v2 = ops.sliceUpdate(this.values!, v, [0, 0, this.#idx, 0], [B, H, this.#idx + S, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = k2;
    this.values = v2;
    this.#offset += S;
    this.offsetArr = this.offsetArr.map((x) => x + S);
    this.#idx += S;

    // Return the populated prefix (ring not yet full) or the whole buffer.
    if (this.#offset < this.maxSize) {
      return [
        this.keys.slice([0, 0, 0, 0], [B, H, this.#offset, DK]),
        this.values.slice([0, 0, 0, 0], [B, H, this.#offset, vD]),
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
    const valid = Math.min(this.#offset, this.maxSize);
    const order = (a: MlxArray): MlxArray => {
      const [B, H, Sbuf, D] = a.shape as [number, number, number, number];
      let t: MlxArray;
      if (this.#idx === Sbuf) {
        t = a.slice([0, 0, 0, 0], [B, H, Sbuf, D]);
      } else if (this.#idx < this.#offset) {
        const tail = a.slice([0, 0, this.#idx, 0], [B, H, Sbuf, D]);
        const head = a.slice([0, 0, 0, 0], [B, H, this.#idx, D]);
        t = ops.concatAxis([tail, head], 2);
        tail.dispose();
        head.dispose();
      } else {
        t = a.slice([0, 0, 0, 0], [B, H, this.#idx, D]);
      }
      const [, , , Dd] = t.shape as [number, number, number, number];
      const cut = t.slice([0, 0, 0, 0], [B, H, valid, Dd]);
      t.dispose();
      return cut;
    };
    return [order(this.keys), order(this.values)];
  }

  /** Keep only `keep` rows along the batch axis (eviction). */
  filter(keep: number[]): void {
    if (this.keys && this.values) {
      const idxArr = MlxArray.fromInt32(Int32Array.from(keep), [keep.length]);
      const k = ops.takeAxis(this.keys, idxArr, 0);
      const v = ops.takeAxis(this.values, idxArr, 0);
      idxArr.dispose();
      this.keys.dispose();
      this.values.dispose();
      this.keys = k;
      this.values = v;
    }
    this.offsetArr = keep.map((i) => this.offsetArr[i]!);
    this.leftPad = keep.map((i) => this.leftPad[i]!);
    this.releaseRopeArr();
  }

  state(): MlxArray[] {
    return this.keys && this.values ? [this.keys, this.values] : [];
  }
  isTrimmable(): boolean {
    return this.#offset < this.maxSize;
  }
  trim(n: number): void {
    const k = Math.min(this.#offset, n);
    this.#offset -= k;
    this.#idx -= k;
    this.offsetArr = this.offsetArr.map((x) => x - k);
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
    cache.offsetArr = [...offsets];
    if (width === 0) return cache;

    const padTo = (a: MlxArray, pad: number): MlxArray => {
      if (pad === 0) return a.slice([0, 0, 0, 0], a.shape as number[]);
      const [B, H, , D] = a.shape as [number, number, number, number];
      const z = ops.zeros([B, H, pad, D], a.dtype);
      const out = ops.concatAxis([z, a], 2);
      z.dispose();
      return out;
    };
    const ks = rows.map((r, i) => padTo(r.keys, leftPad[i]!));
    const vs = rows.map((r, i) => padTo(r.values, leftPad[i]!));
    cache.keys = ops.concatAxis(ks, 0);
    cache.values = ops.concatAxis(vs, 0);
    for (const a of [...ks, ...vs]) a.dispose();
    cache.#idx = width;
    cache.#offset = width;
    return cache;
  }
}
