import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache,DecodeStepPlan,KvDonorAttention,Mask,QuantizedAttentionState } from "../contracts/mlx/cache";
import { createCausalMask } from "../kernels/attention/masks";
import { quantizedSdpa } from "../layers/quantized-attention";
import { disposeTriple,mapTriple } from "./quantized-tensor";


/** Quantized rotating (sliding-window) KV cache — port of optiq
 *  runtime/kv/rotating.py RotatingQuantizedKVCache with keep=0
 *  (gemma4's configuration): RotatingKVCache's ring mechanics over
 *  (packed, scales, biases) triples, storage convention identical to
 *  QuantizedKVCache. Returns ACTIVE QUANTIZED SLICES — the oracle's
 *  module docstring claims dequantize-on-read, but its code does not
 *  (Phase 9 finding; port follows the code). optiq's producer-registry
 *  + SDPA patches are unnecessary here: our SharedKv carries
 *  groupSize/bits through the donor→sharer plumbing explicitly. */
export class RotatingQuantizedKVCache implements Cache {
  get quantizedAttention(): QuantizedAttentionState { return this; }
  declare minimumReusableOffset?: number;
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache). */
  readonly ropeOffsetArr?: MlxArray;
  keys: ops.QuantizedTensor | null = null;
  values: ops.QuantizedTensor | null = null;
  offset = 0;
  /** Ring write index (oracle `_idx`); public so toQuantized replay
   *  and persistence can carry it. */
  ringIdx = 0;
  readonly maxSize: number;

  constructor(maxSize: number, readonly groupSize: number, readonly bits: number) {
    this.maxSize = maxSize;
  }

  signature(): string { return `kv:rotating-quant:${this.bits}:${this.groupSize}`; }

  bytesPerToken(): number {
    const steps = this.keys?.packed.shape[2] ?? 0;
    if (steps === 0 || !this.keys || !this.values) return 0;
    const tensors = [
      this.keys.packed, this.keys.scales, this.keys.biases,
      this.values.packed, this.values.scales, this.values.biases,
    ];
    return tensors.reduce((bytes, array) => bytes + array.nbytes, 0) / steps;
  }

  updateAndFetch(): [MlxArray, MlxArray] {
    throw new Error("RotatingQuantizedKVCache: use updateAndFetchQuantized");
  }

  #seqLen(): number {
    return this.keys ? this.keys.packed.shape[2]! : 0;
  }

  /** Empty (packed, scales, biases) triple of T tokens (oracle _alloc_pair). */
  #allocPair(B: number, H: number, T: number, dim: number, dtype: Dtype): ops.QuantizedTensor {
    const elPerInt = 32 / this.bits;
    return {
      packed: ops.zeros([B, H, T, dim / elPerInt], Dtype.uint32),
      scales: ops.zeros([B, H, T, dim / this.groupSize], dtype),
      biases: ops.zeros([B, H, T, dim / this.groupSize], dtype),
    };
  }

  /** Ring contents rearranged into temporal order, per component (keep=0). */
  #temporalOrder(t: ops.QuantizedTensor): ops.QuantizedTensor {
    const S = t.packed.shape[2]!;
    const cut = (a: MlxArray, from: number, to: number): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      return a.slice([0, 0, from, 0], [B, H, to, D]);
    };
    if (this.ringIdx === S) return mapTriple(t, (a) => cut(a, 0, S));
    if (this.ringIdx < this.offset) {
      return mapTriple(t, (a) => {
        const tail = cut(a, this.ringIdx, S);
        const head = cut(a, 0, this.ringIdx);
        const out = ops.concatAxis([tail, head], 2);
        tail.dispose();
        head.dispose();
        return out;
      });
    }
    return mapTriple(t, (a) => cut(a, 0, this.ringIdx));
  }

  #trim(trimSize: number, t: ops.QuantizedTensor, append: ops.QuantizedTensor | null): ops.QuantizedTensor {
    const part = (a: MlxArray, ap: MlxArray | null): MlxArray => {
      const [B, H, S, D] = a.shape as [number, number, number, number];
      const base = a.slice([0, 0, trimSize > 0 ? trimSize : 0, 0], [B, H, S, D]);
      if (!ap) return base;
      const out = ops.concatAxis([base, ap], 2);
      base.dispose();
      return out;
    };
    return {
      packed: part(t.packed, append?.packed ?? null),
      scales: part(t.scales, append?.scales ?? null),
      biases: part(t.biases, append?.biases ?? null),
    };
  }

  #updateConcat(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const S = k.shape[2]!;
    const kq = ops.quantize(k, this.groupSize, this.bits);
    const vq = ops.quantize(v, this.groupSize, this.bits);
    if (!this.keys || !this.values) {
      this.keys = kq;
      this.values = vq;
    } else {
      const tk = this.#temporalOrder(this.keys);
      const tv = this.#temporalOrder(this.values);
      disposeTriple(this.keys);
      disposeTriple(this.values);
      this.ringIdx = tk.packed.shape[2]!;
      const trimSize = this.ringIdx - this.maxSize + 1;
      this.keys = this.#trim(trimSize, tk, kq);
      this.values = this.#trim(trimSize, tv, vq);
      for (const t of [tk, tv, kq, vq]) disposeTriple(t);
    }
    this.offset += S;
    this.ringIdx = this.#seqLen();
    return this.#activeSlices();
  }

  #updateInPlace(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const [B, H, S, D] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    const prev = this.offset;

    if (!this.keys || (prev >= this.#seqLen() && this.#seqLen() < this.maxSize)) {
      const newSize = Math.min(RotatingQuantizedKVCache.STEP, this.maxSize - prev);
      const newK = this.#allocPair(B, H, newSize, D, k.dtype);
      const newV = this.#allocPair(B, H, newSize, vD, v.dtype);
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

    const trimSize = this.#seqLen() - this.maxSize;
    if (trimSize > 0) {
      const tk = this.#trim(trimSize, this.keys!, null);
      const tv = this.#trim(trimSize, this.values!, null);
      disposeTriple(this.keys!);
      disposeTriple(this.values!);
      this.keys = tk;
      this.values = tv;
      this.ringIdx = this.maxSize;
    }

    if (this.ringIdx === this.maxSize) this.ringIdx = 0; // rotate (keep=0)

    const kq = ops.quantize(k, this.groupSize, this.bits);
    const vq = ops.quantize(v, this.groupSize, this.bits);
    const writeAt = (dst: ops.QuantizedTensor, src: ops.QuantizedTensor): ops.QuantizedTensor => ({
      packed: this.#assign(dst.packed, src.packed, S),
      scales: this.#assign(dst.scales, src.scales, S),
      biases: this.#assign(dst.biases, src.biases, S),
    });
    this.keys = writeAt(this.keys!, kq);
    this.values = writeAt(this.values!, vq);
    disposeTriple(kq);
    disposeTriple(vq);

    this.offset += S;
    this.ringIdx += S;
    return this.#activeSlices();
  }

  #assign(dst: MlxArray, src: MlxArray, S: number): MlxArray {
    const [B, H, , D] = dst.shape as [number, number, number, number];
    const out = ops.sliceUpdate(dst, src, [0, 0, this.ringIdx, 0], [B, H, this.ringIdx + S, D]);
    dst.dispose();
    return out;
  }

  /** Active window as quantized triples (oracle _active_slices; fresh
   *  view handles so callers own what they dispose). */
  #activeSlices(): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const upTo = this.offset < this.maxSize ? this.offset : this.#seqLen();
    const cut = (a: MlxArray): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      return a.slice([0, 0, 0, 0], [B, H, upTo, D]);
    };
    return [mapTriple(this.keys!, cut), mapTriple(this.values!, cut)];
  }

  /** Quantize incoming k/v and write into the ring; returns active
   *  quantized triples (S=1 in place, S>1 via temporal-order + concat). */
  updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    return k.shape[2]! === 1 ? this.#updateInPlace(k, v) : this.#updateConcat(k, v);
  }

  /** Same mask formula as RotatingKVCache (inherited in the oracle). */
  makeMask(N: number, windowSize: number | null): Mask {
    const window = windowSize ?? this.maxSize;
    if (N > 1) {
      const offset = Math.min(this.maxSize - 1, this.offset);
      if (offset + N > window)
        return { mode: "array", arr: createCausalMask(N, offset, window) };
      return { mode: "causal", arr: null };
    }
    return { mode: "", arr: null };
  }

  state(): MlxArray[] {
    if (!this.keys || !this.values) return [];
    return [
      this.keys.packed, this.keys.scales, this.keys.biases,
      this.values.packed, this.values.scales, this.values.biases,
    ];
  }

  /** Ring rule (inherited semantics): trimmable only before wrap. */
  isTrimmable(): boolean {
    return this.offset < this.maxSize;
  }

  trim(n: number, bypass = false): void {
    const k = Math.min(this.offset, n);
    if (!bypass) {
      this.offset -= k;
      this.ringIdx -= k;
      return;
    }
    // Spec-decode rollback after a >1 concat write — physically slice the last k
    // off each (packed, scales, biases) component and keep ringIdx === seqLen.
    this.offset -= k;
    if (k > 0 && this.keys && this.values) {
      const S = this.#seqLen();
      const cut = (a: MlxArray): MlxArray => {
        const [B, H, , D] = a.shape as [number, number, number, number];
        return a.slice([0, 0, 0, 0], [B, H, S - k, D]);
      };
      const nk = mapTriple(this.keys, cut);
      const nv = mapTriple(this.values, cut);
      disposeTriple(this.keys);
      disposeTriple(this.values);
      this.keys = nk;
      this.values = nv;
      this.ringIdx = this.#seqLen();
    } else {
      this.ringIdx -= k;
    }
  }

  /** Adopt persisted state (takes ownership of the triples' arrays) —
   *  ring order as-laid-out, ringIdx carried with it (kv-store persistence). */
  restoreState(keys: ops.QuantizedTensor, values: ops.QuantizedTensor, offset: number, idx: number): void {
    this.dispose();
    this.keys = keys;
    this.values = values;
    this.offset = offset;
    this.ringIdx = idx;
  }

  /** Chronological (K, V) triples cut to the valid window — the quantized
   *  twin of RotatingKVCache.temporalView (batched merge reads, Phase 3
   *  milestone 2). Caller owns the returned views. */
  captureDonorAttention(): KvDonorAttention {
    const [keys, values] = this.temporalView();
    const B = keys.packed.shape[0]!, width = keys.packed.shape[2]!;
    return { width, dtype: keys.scales.dtype, offsets: Array(B).fill(this.offset),
      starts: Array(B).fill(0), ends: Array(B).fill(width),
      attend: (q, scale, mask) => quantizedSdpa(q, keys, values, scale, mask, this.groupSize, this.bits),
      dispose() { disposeTriple(keys); disposeTriple(values); },
    };
  }

  temporalView(): [ops.QuantizedTensor, ops.QuantizedTensor] {
    if (!this.keys || !this.values) throw new Error("cache is empty");
    const valid = Math.min(this.offset, this.maxSize);
    const cutValid = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
      mapTriple(t, (a) => {
        const [B, H, , D] = a.shape as [number, number, number, number];
        return a.slice([0, 0, 0, 0], [B, H, valid, D]);
      });
    const tk = this.#temporalOrder(this.keys);
    const tv = this.#temporalOrder(this.values);
    const out: [ops.QuantizedTensor, ops.QuantizedTensor] = [cutValid(tk), cutValid(tv)];
    disposeTriple(tk);
    disposeTriple(tv);
    return out;
  }

  /** Oracle: to_quantized on an already-quantized rotating cache is
   *  idempotent. */
  toQuantized(): RotatingQuantizedKVCache {
    return this;
  }

  /** Compiled decode: host-side bookkeeping of #updateInPlace (L=1) —
   *  growth, oversize trim, rotation — without quantize/write. */
  prepareDecodeStep(): DecodeStepPlan {
    const prev = this.offset;
    if (!this.keys || !this.values) throw new Error("compiled decode on an empty cache");
    if (prev >= this.#seqLen() && this.#seqLen() < this.maxSize) {
      const [B, H, , pD] = this.keys.packed.shape as [number, number, number, number];
      const elPerInt = 32 / this.bits;
      const kD = pD * elPerInt;
      const vD = this.values.packed.shape[3]! * elPerInt;
      const dtype = this.keys.scales.dtype;
      const newSize = Math.min(RotatingQuantizedKVCache.STEP, this.maxSize - prev);
      const newK = this.#allocPair(B, H, newSize, kD, dtype);
      const newV = this.#allocPair(B, H, newSize, vD, dtype);
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
      this.ringIdx = prev;
    }
    const trimSize = this.#seqLen() - this.maxSize;
    if (trimSize > 0) {
      const tk = this.#trim(trimSize, this.keys, null);
      const tv = this.#trim(trimSize, this.values, null);
      disposeTriple(this.keys);
      disposeTriple(this.values);
      this.keys = tk;
      this.values = tv;
      this.ringIdx = this.maxSize;
    }
    if (this.ringIdx === this.maxSize) this.ringIdx = 0; // rotate (keep=0)
    const fetch = prev + 1 < this.maxSize && this.ringIdx === prev ? "concat" : "ring";
    return { fetch, writePos: this.ringIdx, activeLen: prev };
  }

  /** Compiled decode, concat fetch: six sliceUpdates of the in-graph-
   *  quantized step row. Takes ownership; returns updated buffers. */
  writeDecodeStep(rows: MlxArray[]): MlxArray[] {
    const w = (d: MlxArray, srcRow: MlxArray): MlxArray => {
      const [b, h, , dd] = d.shape as [number, number, number, number];
      const u = ops.sliceUpdate(d, srcRow, [0, 0, this.ringIdx, 0], [b, h, this.ringIdx + 1, dd]);
      d.dispose();
      srcRow.dispose();
      return u;
    };
    this.keys = {
      packed: w(this.keys!.packed, rows[0]!),
      scales: w(this.keys!.scales, rows[1]!),
      biases: w(this.keys!.biases, rows[2]!),
    };
    this.values = {
      packed: w(this.values!.packed, rows[3]!),
      scales: w(this.values!.scales, rows[4]!),
      biases: w(this.values!.biases, rows[5]!),
    };
    this.offset += 1;
    this.ringIdx += 1;
    return this.state();
  }

  /** Compiled decode, ring fetch: adopt the six in-graph-updated buffers
   *  (closure outputs, in state() order; ownership transfers here). */
  adoptDecodeStep(bufs: MlxArray[]): MlxArray[] {
    disposeTriple(this.keys!);
    disposeTriple(this.values!);
    this.keys = { packed: bufs[0]!, scales: bufs[1]!, biases: bufs[2]! };
    this.values = { packed: bufs[3]!, scales: bufs[4]!, biases: bufs[5]! };
    this.offset += 1;
    this.ringIdx += 1;
    return bufs;
  }

  dispose(): void {
    if (this.keys) disposeTriple(this.keys);
    if (this.values) disposeTriple(this.values);
    this.keys = this.values = null;
    this.offset = 0;
    this.ringIdx = 0;
  }
}
