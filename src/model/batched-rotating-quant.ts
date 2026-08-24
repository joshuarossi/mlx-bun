// Batched sliding-window QUANTIZED KV — Phase 3 milestone 2 of
// docs/design/unified-engine-frontier-plan.md: the composition that lets a
// per-layer kv_config naming ROTATING layers (gemma) batch. No stack ships
// this (mlx-lm's batched path is bf16-only; optiq's mixed-KV hook is
// serial-only), so per the composition rule the oracle is the SERIAL
// RotatingQuantizedKVCache per row: each joiner's solo prefill converts with
// the serial ops (BatchScheduler.#quantizeSolo), and this class only
// re-arranges those bytes across the batch axis + runs the mlx-lm
// BatchRotatingKVCache ring mechanics (batched-rotating.ts) over
// (packed, scales, biases) triples instead of bf16 tensors.
//
// Same safety argument as batched-quant.ts: quantization packs along
// HEAD_DIM, so the token axis stays token-granular in all three tensors —
// left-pad columns are zeros, masked by buildBatchedRotatingMask (token-axis
// only; shared verbatim with the bf16 twin), never dequantized into anything
// a real row reads.
//
// Subclasses RotatingQuantizedKVCache so Attention.forward's `instanceof`
// dispatch (gemma4.ts) routes to the quantized path with the L1 model file
// untouched. PERSISTENT (like BatchedRotatingCache, unlike the ephemeral
// per-step BatchedQuantDecodeMaskCache): the scheduler passes it through
// every step; it self-tracks per-row offset/leftPad and the scalar ring
// state. N=1 decode updates only (rows solo-prefill serially, then merge).
//
// Gates: tests/unit/batched-rotating-quant.test.ts (model-free byte-identity vs
// the serial oracle per row, through ring wrap, B=1 and B=2) + the gemma
// scheduler gate in tests/parity/batched-kv-quant-parity.test.ts.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Dtype } from "../mlx/ffi";
import { RotatingQuantizedKVCache, type Mask } from "./gemma4-base";
import { buildBatchedRotatingMask } from "./batched-rotating";
import type { QuantRow } from "./batched-quant";
import { BatchedRotatingState } from "./batched-rotating-state";
import {
  mergeStorageRows,
  quantizedRowStorage,
  temporalStorageView,
} from "./batched-row-storage";

const STEP = 256; // shared with RotatingQuantizedKVCache.STEP and the bf16 twin

const disposeTriple = (t: ops.QuantizedTensor): void => {
  t.packed.dispose();
  t.scales.dispose();
  t.biases.dispose();
};
const mapTriple = (
  t: ops.QuantizedTensor, f: (a: MlxArray) => MlxArray,
): ops.QuantizedTensor => ({ packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) });

/** Batched ring over quantized triples — mlx-lm BatchRotatingKVCache
 *  mechanics (see batched-rotating.ts) with RotatingQuantizedKVCache
 *  storage. Scalar ring state (`ringIdx`/`offset` reuse the base fields);
 *  per-row `offsetArr` (absolute positions → RoPE) and `leftPad`. */
export class BatchedRotatingQuantCache extends RotatingQuantizedKVCache {
  readonly #rows: BatchedRotatingState;
  /** Per-row RoPE positions. STABLE ACROSS A STEP — refreshed only at
   *  releaseRopeArr() (the scheduler's post-dispatch hook), never inside
   *  the update: the monolith CAPTURES it pre-update and ropes Q after
   *  (an in-update dispose is a use-after-dispose there), and the
   *  GENERATED specializations RE-READ it for Q post-update (an in-update
   *  refresh hands K and Q different positions there — found the hard way
   *  2026-07-05: the twin passes the generated files' instanceof cache
   *  guards by subclassing, so an all-quant gemma batch decodes through
   *  the generated graph). Widens the base's readonly to mutable. */
  override ropeOffsetArr: MlxArray;

  private constructor(
    maxSize: number, groupSize: number, bits: number, leftPad: number[], offsets: number[],
  ) {
    super(maxSize, groupSize, bits);
    this.#rows = new BatchedRotatingState(maxSize, leftPad, offsets);
    this.ropeOffsetArr = MlxArray.fromInt32(Int32Array.from(offsets), [offsets.length]);
  }

  get offsetArr(): number[] { return this.#rows.offsets; }
  get leftPad(): number[] { return this.#rows.leftPad; }
  get batchSize(): number { return this.#rows.batchSize; }

  get #B(): number {
    return this.#rows.batchSize;
  }

  #seqLen2(): number {
    return this.keys ? this.keys.packed.shape[2]! : 0;
  }

  /** Scheduler hook, called on every fwd cache AFTER the step's graph is
   *  built — the ONE safe point to swap the rope array for the advanced
   *  positions (the step's graph holds its own reference; no JS reads the
   *  old handle after this). */
  releaseRopeArr(): void {
    this.ropeOffsetArr.dispose();
    this.ropeOffsetArr = MlxArray.fromInt32(Int32Array.from(this.offsetArr), [this.#B]);
  }

  #allocTriple(B: number, H: number, T: number, dim: number, dtype: Dtype): ops.QuantizedTensor {
    const elPerInt = 32 / this.bits;
    return {
      packed: ops.zeros([B, H, T, dim / elPerInt], Dtype.uint32),
      scales: ops.zeros([B, H, T, dim / this.groupSize], dtype),
      biases: ops.zeros([B, H, T, dim / this.groupSize], dtype),
    };
  }

  override makeMask(N: number, windowSize: number | null): Mask {
    const window = windowSize ?? this.maxSize;
    return {
      mode: "array",
      arr: buildBatchedRotatingMask(
        this.#B, N, this.leftPad, this.maxSize, window,
        this.#rows.ringIndex, this.#rows.totalOffset, this.#rows.rotated,
      ),
    };
  }

  /** N=1 decode update — the bf16 twin's updateAndFetch (mlx-lm
   *  _update_in_place) over triples, with quantize-on-write from the
   *  serial oracle. */
  override updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const [B, H, S, D] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    if (S !== 1)
      throw new Error("BatchedRotatingQuantCache supports N=1 decode updates only (solo-prefill then merge)");
    const prev = this.#rows.totalOffset;

    // Grow the buffer (in STEP chunks) until it reaches maxSize.
    if (!this.keys || (prev >= this.#seqLen2() && this.#seqLen2() < this.maxSize)) {
      const newSize = Math.min(STEP, this.maxSize - prev);
      const newK = this.#allocTriple(B, H, newSize, D, k.dtype);
      const newV = this.#allocTriple(B, H, newSize, vD, v.dtype);
      if (this.keys && this.values) {
        const grow = (old: ops.QuantizedTensor, add: ops.QuantizedTensor): ops.QuantizedTensor => {
          const cat = (a: MlxArray, b: MlxArray): MlxArray => {
            const out = ops.concatAxis([a, b], 2);
            a.dispose();
            b.dispose();
            return out;
          };
          return {
            packed: cat(old.packed, add.packed),
            scales: cat(old.scales, add.scales),
            biases: cat(old.biases, add.biases),
          };
        };
        this.keys = grow(this.keys, newK);
        this.values = grow(this.values, newV);
      } else {
        this.keys = newK;
        this.values = newV;
      }
      this.#rows.markGrown(prev);
      this.ringIdx = this.#rows.ringIndex;
    }

    // Trim any overshoot past maxSize (decrements left padding persistently).
    const trimSize = this.#seqLen2() - this.maxSize;
    if (trimSize > 0) {
      const cutFrom = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
        mapTriple(t, (a) => {
          const [b2, h2, s2, d2] = a.shape as [number, number, number, number];
          const s = a.slice([0, 0, trimSize, 0], [b2, h2, s2, d2]);
          a.dispose();
          return s;
        });
      this.keys = cutFrom(this.keys!);
      this.values = cutFrom(this.values!);
      this.#rows.trimOvershoot(trimSize);
      this.ringIdx = this.#rows.ringIndex;
    }

    // Rotate when the write head reaches the end of the ring.
    this.ringIdx = this.#rows.beginWrite(S);

    // Quantize + write the new K/V at the ring head (six sliceUpdates).
    const kq = ops.quantize(k, this.groupSize, this.bits);
    const vq = ops.quantize(v, this.groupSize, this.bits);
    const writeAt = (dst: ops.QuantizedTensor, src: ops.QuantizedTensor): ops.QuantizedTensor =>
      ({
        packed: this.#assign2(dst.packed, src.packed, S),
        scales: this.#assign2(dst.scales, src.scales, S),
        biases: this.#assign2(dst.biases, src.biases, S),
      });
    this.keys = writeAt(this.keys!, kq);
    this.values = writeAt(this.values!, vq);
    disposeTriple(kq);
    disposeTriple(vq);

    this.#rows.commitWrite(S);
    this.offset = this.#rows.totalOffset;
    this.ringIdx = this.#rows.ringIndex;

    // Return the populated prefix (ring not yet full) or the whole buffer.
    const upTo = this.offset < this.maxSize ? this.offset : this.#seqLen2();
    const cut = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
      mapTriple(t, (a) => {
        const [b2, h2, , d2] = a.shape as [number, number, number, number];
        return a.slice([0, 0, 0, 0], [b2, h2, upTo, d2]);
      });
    return [cut(this.keys!), cut(this.values!)];
  }

  #assign2(dst: MlxArray, src: MlxArray, S: number): MlxArray {
    const [B, H, , D] = dst.shape as [number, number, number, number];
    const out = ops.sliceUpdate(dst, src, [0, 0, this.ringIdx, 0], [B, H, this.ringIdx + S, D]);
    dst.dispose();
    return out;
  }

  /** Ring contents in temporal order, cut to the valid length (extract) —
   *  overrides the base to use the BATCHED ring state. */
  override temporalView(): [ops.QuantizedTensor, ops.QuantizedTensor] {
    if (!this.keys || !this.values) throw new Error("cache is empty");
    return [
      temporalStorageView(quantizedRowStorage, this.keys, this.#rows),
      temporalStorageView(quantizedRowStorage, this.values, this.#rows),
    ];
  }

  /** Quantized twin of BatchedRotatingCache.extractRow (mlx-lm
   *  BatchRotatingKVCache.extract, models/cache.py:1417, over triples):
   *  row `i` as a fresh SERIAL RotatingQuantizedKVCache — de-rolled to
   *  temporal order, left padding stripped, OWNED contiguous copies;
   *  offset = the row's absolute position, ringIdx = the new buffer length
   *  (the oracle's `cache._idx = cache.keys.shape[2]`). Token-axis slicing
   *  is byte-safe (packing along HEAD_DIM — file header); per-row byte
   *  identity vs the serial oracle is the class invariant
   *  (tests/batched-rotating-quant), extraction is a pure slice+copy. */
  extractRow(i: number): RotatingQuantizedKVCache | null {
    if (!this.keys || !this.values) return null;
    const pad = Math.max(0, this.leftPad[i]!);
    const c = new RotatingQuantizedKVCache(this.maxSize, this.groupSize, this.bits);
    const k = temporalStorageView(quantizedRowStorage, this.keys, this.#rows, {
      row: i, from: pad, copy: true,
    });
    const v = temporalStorageView(quantizedRowStorage, this.values, this.#rows, {
      row: i, from: pad, copy: true,
    });
    c.restoreState(k, v, this.offsetArr[i]!, k.packed.shape[2]!);
    return c;
  }

  /** Keep only `keep` rows along the batch axis (eviction), in place. */
  filter(keep: number[]): void {
    if (this.keys && this.values) {
      const k = quantizedRowStorage.takeRows(this.keys, keep);
      const v = quantizedRowStorage.takeRows(this.values, keep);
      disposeTriple(this.keys);
      disposeTriple(this.values);
      this.keys = k;
      this.values = v;
    }
    this.#rows.filter(keep);
    this.releaseRopeArr(); // safe here: filter runs between steps
  }

  filterRows(keep: readonly number[]): void { this.filter([...keep]); }

  override isTrimmable(): boolean {
    return false; // batched rows never re-enter the prompt cache directly
  }

  override dispose(): void {
    super.dispose();
    this.releaseRopeArr();
    this.ropeOffsetArr?.dispose();
  }

  /** Assemble a batch from per-row temporal quantized slices (the bf16
   *  twin's merge over triples). Each row is a solo/adopted/batched cache's
   *  temporalView ([1,H,Li,*], Li ≤ maxSize, temporal order) and
   *  `offsets[i]` its absolute position. Result is in temporal order
   *  (rotated=false, ringIdx=offset=width). */
  static merge(
    rows: QuantRow[], offsets: number[], maxSize: number, groupSize: number, bits: number,
  ): BatchedRotatingQuantCache {
    const lens = rows.map((r) => r.keys.packed.shape[2]!);
    const width = Math.max(...lens, 0);
    const leftPad = lens.map((l) => width - l);
    const cache = new BatchedRotatingQuantCache(maxSize, groupSize, bits, leftPad, offsets);
    cache.#rows.restoreMerged(width, offsets);
    cache.offset = cache.#rows.totalOffset;
    cache.ringIdx = cache.#rows.ringIndex;
    if (width === 0) return cache;

    cache.keys = mergeStorageRows(quantizedRowStorage, rows.map((row) => row.keys), leftPad);
    cache.values = mergeStorageRows(quantizedRowStorage, rows.map((row) => row.values), leftPad);
    return cache;
  }
}
