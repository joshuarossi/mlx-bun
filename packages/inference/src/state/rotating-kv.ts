import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache,DecodeStepPlan,KvDonorRows,Mask } from "../contracts/mlx/cache";
import { createCausalMask } from "../kernels/attention/masks";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";


/** Rotating (sliding-window) KV cache — port of mlx-lm RotatingKVCache
 *  with keep=0 (gemma4's configuration): a ring buffer of max_size
 *  entries, so decode attends over at most the window. RoPE offsets use
 *  the true position; masks use the buffer-clamped offset. */
export class RotatingKVCache implements Cache {
  declare minimumReusableOffset?: number;
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache). */
  readonly ropeOffsetArr?: MlxArray;
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;
  #idx = 0;
  readonly maxSize: number;

  constructor(maxSize: number) {
    this.maxSize = maxSize;
  }

  signature(): string { return "kv:rotating-plain"; }

  bytesPerToken(): number {
    const steps = this.keys?.shape[2] ?? 0;
    return steps > 0 ? (this.keys!.nbytes + this.values!.nbytes) / steps : 0;
  }

  /** v with ring contents rearranged into temporal order (keep=0). */
  #temporalOrder(v: MlxArray): MlxArray {
    const S = v.shape[2]!;
    const [B, H, , D] = v.shape as [number, number, number, number];
    if (this.#idx === S) return v.slice([0, 0, 0, 0], [B, H, S, D]);
    if (this.#idx < this.offset) {
      const tail = v.slice([0, 0, this.#idx, 0], [B, H, S, D]);
      const head = v.slice([0, 0, 0, 0], [B, H, this.#idx, D]);
      const out = ops.concatAxis([tail, head], 2);
      tail.dispose();
      head.dispose();
      return out;
    }
    return v.slice([0, 0, 0, 0], [B, H, this.#idx, D]);
  }

  #trim(trimSize: number, v: MlxArray, append: MlxArray | null): MlxArray {
    const [B, H, S, D] = v.shape as [number, number, number, number];
    let base: MlxArray;
    if (trimSize > 0) {
      base = v.slice([0, 0, trimSize, 0], [B, H, S, D]);
    } else {
      base = v.slice([0, 0, 0, 0], [B, H, S, D]);
    }
    if (!append) return base;
    const out = ops.concatAxis([base, append], 2);
    base.dispose();
    return out;
  }

  #updateConcat(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const S = k.shape[2]!;
    if (!this.keys || !this.values) {
      // own copies (full-range slice = cheap view node)
      const [B, H, , D] = k.shape as [number, number, number, number];
      const vD = v.shape[3]!;
      this.keys = k.slice([0, 0, 0, 0], [B, H, S, D]);
      this.values = v.slice([0, 0, 0, 0], [B, H, S, vD]);
    } else {
      const tk = this.#temporalOrder(this.keys);
      const tv = this.#temporalOrder(this.values);
      this.keys.dispose();
      this.values.dispose();
      this.#idx = tk.shape[2]!;
      const trimSize = this.#idx - this.maxSize + 1;
      this.keys = this.#trim(trimSize, tk, k);
      this.values = this.#trim(trimSize, tv, v);
      tk.dispose();
      tv.dispose();
    }
    this.offset += S;
    this.#idx = this.keys.shape[2]!;
    return this.#fetchAll();
  }

  #updateInPlace(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const [B, H, S, D] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    const prev = this.offset;

    if (!this.keys || (prev >= this.keys.shape[2]! && this.keys.shape[2]! < this.maxSize)) {
      const newSize = Math.min(RotatingKVCache.STEP, this.maxSize - prev);
      const newK = ops.zeros([B, H, newSize, D], k.dtype);
      const newV = ops.zeros([B, H, newSize, vD], v.dtype);
      if (this.keys && this.values) {
        const ck = ops.concatAxis([this.keys, newK], 2);
        const cv = ops.concatAxis([this.values, newV], 2);
        this.keys.dispose();
        this.values.dispose();
        newK.dispose();
        newV.dispose();
        this.keys = ck;
        this.values = cv;
      } else {
        this.keys = newK;
        this.values = newV;
      }
      this.#idx = prev;
    }

    const trimSize = this.keys!.shape[2]! - this.maxSize;
    if (trimSize > 0) {
      const tk = this.#trim(trimSize, this.keys!, null);
      const tv = this.#trim(trimSize, this.values!, null);
      this.keys!.dispose();
      this.values!.dispose();
      this.keys = tk;
      this.values = tv;
      this.#idx = this.maxSize;
    }

    if (this.#idx === this.maxSize) this.#idx = 0; // rotate (keep=0)

    const [, , SK, DK] = this.keys!.shape as [number, number, number, number];
    const k2 = ops.sliceUpdate(this.keys!, k, [0, 0, this.#idx, 0], [B, H, this.#idx + S, DK]);
    const v2 = ops.sliceUpdate(this.values!, v, [0, 0, this.#idx, 0], [B, H, this.#idx + S, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = k2;
    this.values = v2;
    this.offset += S;
    this.#idx += S;

    if (this.offset < this.maxSize) {
      const kOut = this.keys.slice([0, 0, 0, 0], [B, H, this.offset, DK]);
      const vOut = this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]);
      return [kOut, vOut];
    }
    return this.#fetchAll();
  }

  #fetchAll(): [MlxArray, MlxArray] {
    const [B, H, S, D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    return [
      this.keys!.slice([0, 0, 0, 0], [B, H, S, D]),
      this.values!.slice([0, 0, 0, 0], [B, H, S, vD]),
    ];
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return k.shape[2]! === 1 ? this.#updateInPlace(k, v) : this.#updateConcat(k, v);
  }

  makeMask(N: number, windowSize: number | null): Mask {
    const window = windowSize ?? this.maxSize;
    if (N > 1) {
      const offset = Math.min(this.maxSize - 1, this.offset);
      if (offset + N > window)
        return { mode: "array", arr: createCausalMask(N, offset, window) };
      return { mode: "causal", arr: null };
    }
    // N == 1: eviction enforces the window (window === maxSize for gemma4)
    return { mode: "", arr: null };
  }

  state(): MlxArray[] {
    return this.keys && this.values ? [this.keys, this.values] : [];
  }

  /** Port of mlx-lm RotatingKVCache.is_trimmable/trim: only valid while
   *  the ring has never wrapped (still in temporal order). */
  isTrimmable(): boolean {
    return this.offset < this.maxSize;
  }

  trim(n: number, bypass = false): void {
    const k = Math.min(this.offset, n);
    if (!bypass) {
      // mlx-lm semantics: only valid pre-wrap (guarded by isTrimmable upstream).
      this.offset -= k;
      this.#idx -= k;
      return;
    }
    // Spec-decode rollback after a >1 #updateConcat write: the buffer is in
    // temporal order with #idx === bufferLen and the newest tokens are the last
    // rows, so physically slice the last k off and keep #idx === new length.
    // (Only sound right after a concat write with k ≤ γ — DSpark's only caller.)
    this.offset -= k;
    if (k > 0 && this.keys && this.values) {
      const [B, H, S, D] = this.keys.shape as [number, number, number, number];
      const vD = this.values.shape[3]!;
      const nk = this.keys.slice([0, 0, 0, 0], [B, H, S - k, D]);
      const nv = this.values.slice([0, 0, 0, 0], [B, H, S - k, vD]);
      this.keys.dispose();
      this.values.dispose();
      this.keys = nk;
      this.values = nv;
      this.#idx = nk.shape[2]!;
    } else {
      this.#idx -= k;
    }
  }

  get ringIdx(): number {
    return this.#idx;
  }

  /** Compiled decode: host-side bookkeeping of #updateInPlace (L=1) —
   *  growth, oversize trim, rotation — without the write. */
  prepareDecodeStep(): DecodeStepPlan {
    const prev = this.offset;
    if (!this.keys || !this.values) throw new Error("compiled decode on an empty cache");
    if (prev >= this.keys.shape[2]! && this.keys.shape[2]! < this.maxSize) {
      const [B, H, , D] = this.keys.shape as [number, number, number, number];
      const vD = this.values.shape[3]!;
      const newSize = Math.min(RotatingKVCache.STEP, this.maxSize - prev);
      const newK = ops.zeros([B, H, newSize, D], this.keys.dtype);
      const newV = ops.zeros([B, H, newSize, vD], this.values.dtype);
      const ck = ops.concatAxis([this.keys, newK], 2);
      const cv = ops.concatAxis([this.values, newV], 2);
      for (const a of [this.keys, this.values, newK, newV]) a.dispose();
      this.keys = ck;
      this.values = cv;
      this.#idx = prev;
    }
    const trimSize = this.keys.shape[2]! - this.maxSize;
    if (trimSize > 0) {
      const tk = this.#trim(trimSize, this.keys, null);
      const tv = this.#trim(trimSize, this.values, null);
      this.keys.dispose();
      this.values.dispose();
      this.keys = tk;
      this.values = tv;
      this.#idx = this.maxSize;
    }
    if (this.#idx === this.maxSize) this.#idx = 0; // rotate (keep=0)
    // Pre-window-fill the attended set is the [0..offset] prefix plus the
    // new row (today's slice of the updated buffer); once writes wrap,
    // it's the whole ring in ring order, which only the in-graph
    // write-then-read-all form reproduces bit-exactly.
    const fetch = prev + 1 < this.maxSize && this.#idx === prev ? "concat" : "ring";
    return { fetch, writePos: this.#idx, activeLen: prev };
  }

  /** Compiled decode, concat fetch: the write half. Takes ownership of
   *  kNew/vNew; returns the updated buffers to async-eval. */
  writeDecodeStep(kNew: MlxArray, vNew: MlxArray): MlxArray[] {
    const [B, H, , D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    const k2 = ops.sliceUpdate(this.keys!, kNew, [0, 0, this.#idx, 0], [B, H, this.#idx + 1, D]);
    const v2 = ops.sliceUpdate(this.values!, vNew, [0, 0, this.#idx, 0], [B, H, this.#idx + 1, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    kNew.dispose();
    vNew.dispose();
    this.keys = k2;
    this.values = v2;
    this.offset += 1;
    this.#idx += 1;
    return [k2, v2];
  }

  /** Compiled decode, ring fetch: adopt the in-graph-updated buffers
   *  (closure outputs; ownership transfers here). */
  adoptDecodeStep(newKeys: MlxArray, newValues: MlxArray): MlxArray[] {
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = newKeys;
    this.values = newValues;
    this.offset += 1;
    this.#idx += 1;
    return [newKeys, newValues];
  }

  /** Chronological (K, V) view, valid length min(offset, maxSize)
   *  (port of optiq kv_view._read_cache_temporal). */
  captureDonorRows(): KvDonorRows {
    const [keys, values] = this.temporalView();
    const B = keys.shape[0]!, width = keys.shape[2]!;
    return { keys, values, offsets: Array(B).fill(this.offset),
      starts: Array(B).fill(0), ends: Array(B).fill(width) };
  }

  temporalView(): [MlxArray, MlxArray] {
    if (!this.keys || !this.values) throw new Error("cache is empty");
    const tk = this.#temporalOrder(this.keys);
    const tv = this.#temporalOrder(this.values);
    const valid = Math.min(this.offset, this.maxSize);
    const cut = (a: MlxArray): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      const s = a.slice([0, 0, 0, 0], [B, H, valid, D]);
      a.dispose();
      return s;
    };
    return [cut(tk), cut(tv)];
  }

  /** Adopt persisted state (takes ownership of the arrays). */
  restoreState(keys: MlxArray, values: MlxArray, offset: number, idx: number): void {
    this.dispose();
    this.keys = keys;
    this.values = values;
    this.offset = offset;
    this.#idx = idx;
  }

  /** Port of optiq rotating.py _replay_into_quantized: quantize the
   *  whole buffer AS-LAID-OUT (ring order, not temporal order — correct
   *  because ringIdx is preserved with it) into a
   *  RotatingQuantizedKVCache. */
  toQuantized(groupSize: number, bits: number): RotatingQuantizedKVCache {
    const q = new RotatingQuantizedKVCache(this.maxSize, groupSize, bits);
    if (this.keys && this.values) {
      q.keys = ops.quantize(this.keys, groupSize, bits);
      q.values = ops.quantize(this.values, groupSize, bits);
    }
    q.offset = this.offset;
    q.ringIdx = this.#idx;
    this.dispose();
    return q;
  }

  dispose(): void {
    this.keys?.dispose();
    this.values?.dispose();
    this.keys = this.values = null;
    this.offset = 0;
    this.#idx = 0;
  }
}
