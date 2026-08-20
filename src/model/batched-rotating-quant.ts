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
// Gates: tests/batched-rotating-quant.test.ts (model-free byte-identity vs
// the serial oracle per row, through ring wrap, B=1 and B=2) + the gemma
// scheduler gate in tests/batched-kv-quant-parity.test.ts.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Dtype } from "../mlx/ffi";
import { RotatingQuantizedKVCache, type Mask } from "./gemma4-base";
import { buildBatchedRotatingMask } from "./batched-rotating";
import type { QuantRow } from "./batched-quant";

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
  offsetArr: number[];
  leftPad: number[];
  #rotated = false;
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
    this.leftPad = [...leftPad];
    this.offsetArr = [...offsets];
    this.ropeOffsetArr = MlxArray.fromInt32(Int32Array.from(offsets), [offsets.length]);
  }

  get #B(): number {
    return this.leftPad.length;
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
        this.ringIdx, this.offset, this.#rotated,
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
    const prev = this.offset;

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
      this.ringIdx = prev;
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
      this.ringIdx = this.maxSize;
      this.leftPad = this.leftPad.map((x) => x - trimSize);
    }

    // Rotate when the write head reaches the end of the ring.
    if (this.ringIdx === this.maxSize) {
      this.#rotated = true;
      this.ringIdx = 0;
    }
    if (this.#rotated) this.leftPad = this.leftPad.map((x) => x - S);

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

    this.offset += S;
    this.offsetArr = this.offsetArr.map((x) => x + S);
    this.ringIdx += S;

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
    const valid = Math.min(this.offset, this.maxSize);
    const order = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
      mapTriple(t, (a) => {
        const [B, H, Sbuf, D] = a.shape as [number, number, number, number];
        let tt: MlxArray;
        if (this.ringIdx === Sbuf) {
          tt = a.slice([0, 0, 0, 0], [B, H, Sbuf, D]);
        } else if (this.ringIdx < this.offset) {
          const tail = a.slice([0, 0, this.ringIdx, 0], [B, H, Sbuf, D]);
          const head = a.slice([0, 0, 0, 0], [B, H, this.ringIdx, D]);
          tt = ops.concatAxis([tail, head], 2);
          tail.dispose();
          head.dispose();
        } else {
          tt = a.slice([0, 0, 0, 0], [B, H, this.ringIdx, D]);
        }
        const cut = tt.slice([0, 0, 0, 0], [B, H, valid, D]);
        tt.dispose();
        return cut;
      });
    return [order(this.keys), order(this.values)];
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
    const valid = Math.min(this.offset, this.maxSize);
    const cut = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
      mapTriple(t, (a) => {
        const [, H, Sbuf, D] = a.shape as [number, number, number, number];
        const row = a.slice([i, 0, 0, 0], [i + 1, H, Sbuf, D]);
        let tt: MlxArray;
        if (this.ringIdx === Sbuf) {
          tt = row;
        } else if (this.ringIdx < this.offset) {
          const tail = row.slice([0, 0, this.ringIdx, 0], [1, H, Sbuf, D]);
          const head = row.slice([0, 0, 0, 0], [1, H, this.ringIdx, D]);
          tt = ops.concatAxis([tail, head], 2);
          tail.dispose();
          head.dispose();
          row.dispose();
        } else {
          tt = row.slice([0, 0, 0, 0], [1, H, this.ringIdx, D]);
          row.dispose();
        }
        const cutV = tt.slice([0, 0, pad, 0], [1, H, valid, D]);
        tt.dispose();
        const own = ops.copyOf(cutV); // TRUE copy: see 2026-08-20 contiguous-view pin class
        cutV.dispose();
        return own;
      });
    const c = new RotatingQuantizedKVCache(this.maxSize, this.groupSize, this.bits);
    const k = cut(this.keys);
    const v = cut(this.values);
    c.restoreState(k, v, this.offsetArr[i]!, k.packed.shape[2]!);
    return c;
  }

  /** Keep only `keep` rows along the batch axis (eviction), in place. */
  filter(keep: number[]): void {
    if (this.keys && this.values) {
      const idxArr = MlxArray.fromInt32(Int32Array.from(keep), [keep.length]);
      const take = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
        mapTriple(t, (a) => ops.takeAxis(a, idxArr, 0));
      const k = take(this.keys);
      const v = take(this.values);
      idxArr.dispose();
      disposeTriple(this.keys);
      disposeTriple(this.values);
      this.keys = k;
      this.values = v;
    }
    this.offsetArr = keep.map((i) => this.offsetArr[i]!);
    this.leftPad = keep.map((i) => this.leftPad[i]!);
    this.releaseRopeArr(); // safe here: filter runs between steps
  }

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
    if (width === 0) return cache;

    const padTo = (a: MlxArray, pad: number): MlxArray => {
      if (pad === 0) return a.slice([0, 0, 0, 0], a.shape as number[]);
      const [B, H, , D] = a.shape as [number, number, number, number];
      const z = ops.zeros([B, H, pad, D], a.dtype);
      const out = ops.concatAxis([z, a], 2);
      z.dispose();
      return out;
    };
    const padded = rows.map((r, i) => ({
      keys: mapTriple(r.keys, (a) => padTo(a, leftPad[i]!)),
      values: mapTriple(r.values, (a) => padTo(a, leftPad[i]!)),
    }));
    const cat = (pick: (r: QuantRow) => ops.QuantizedTensor): ops.QuantizedTensor => ({
      packed: ops.concatAxis(padded.map((r) => pick(r).packed), 0),
      scales: ops.concatAxis(padded.map((r) => pick(r).scales), 0),
      biases: ops.concatAxis(padded.map((r) => pick(r).biases), 0),
    });
    cache.keys = cat((r) => r.keys);
    cache.values = cat((r) => r.values);
    for (const r of padded) { disposeTriple(r.keys); disposeTriple(r.values); }
    cache.ringIdx = width;
    cache.offset = width;
    return cache;
  }
}
