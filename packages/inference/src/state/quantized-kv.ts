import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache,DecodeStepPlan,KvDonorAttention,Mask,QuantizedAttentionState } from "../contracts/mlx/cache";
import { createCausalMask } from "../kernels/attention/masks";
import { quantizedSdpa } from "../layers/quantized-attention";
import { disposeTriple } from "./quantized-tensor";


/** Quantized KV cache — port of mlx-lm QuantizedKVCache: keys/values
 *  stored as (packed u32, scales, biases) triples, quantized along
 *  head_dim. Only full-attention layers convert (mlx-lm's rotating-cache
 *  quantization is NYI upstream; sliding layers are window-capped
 *  anyway). Attention dispatches to quantizedSdpa for these. */
export class QuantizedKVCache implements Cache {
  minimumReusableOffset?: number;
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache). */
  readonly ropeOffsetArr?: MlxArray;
  keys: ops.QuantizedTensor | null = null;
  values: ops.QuantizedTensor | null = null;
  offset = 0;

  constructor(readonly groupSize: number, readonly bits: number) {}

  get quantizedAttention(): QuantizedAttentionState { return this; }

  signature(): string { return `kv:quant:${this.bits}:${this.groupSize}`; }

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
    throw new Error("QuantizedKVCache: use updateAndFetchQuantized");
  }

  #grow(triple: ops.QuantizedTensor | null, lastDims: number[], B: number, H: number, steps: number, dtype: Dtype): ops.QuantizedTensor {
    const mk = (dim: number, dt: Dtype) => ops.zeros([B, H, steps, dim], dt);
    if (!triple)
      return { packed: mk(lastDims[0]!, Dtype.uint32), scales: mk(lastDims[1]!, dtype), biases: mk(lastDims[2]!, dtype) };
    const ext = (a: MlxArray, dim: number, dt: Dtype): MlxArray => {
      const z = mk(dim, dt);
      const out = ops.concatAxis([a, z], 2);
      a.dispose();
      z.dispose();
      return out;
    };
    return {
      packed: ext(triple.packed, lastDims[0]!, Dtype.uint32),
      scales: ext(triple.scales, lastDims[1]!, dtype),
      biases: ext(triple.biases, lastDims[2]!, dtype),
    };
  }

  /** Quantize incoming k/v and append; returns quantized views to offset. */
  updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const [B, H, L, kD] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    const prev = this.offset;
    const elPerInt = 32 / this.bits;

    if (!this.keys || prev + L > this.keys.packed.shape[2]!) {
      const newSteps = Math.floor((QuantizedKVCache.STEP + L - 1) / QuantizedKVCache.STEP) * QuantizedKVCache.STEP;
      if (this.keys && prev % QuantizedKVCache.STEP !== 0) {
        const trimTo = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
          const cut = (a: MlxArray): MlxArray => {
            const [b, h, , d] = a.shape as [number, number, number, number];
            const s = a.slice([0, 0, 0, 0], [b, h, prev, d]);
            a.dispose();
            return s;
          };
          return { packed: cut(t.packed), scales: cut(t.scales), biases: cut(t.biases) };
        };
        this.keys = trimTo(this.keys);
        this.values = trimTo(this.values!);
      }
      const dtype = k.dtype;
      this.keys = this.#grow(this.keys, [kD / elPerInt, kD / this.groupSize, kD / this.groupSize], B, H, newSteps, dtype);
      this.values = this.#grow(this.values, [vD / elPerInt, vD / this.groupSize, vD / this.groupSize], B, H, newSteps, dtype);
    }

    this.offset += L;
    const kq = ops.quantize(k, this.groupSize, this.bits);
    const vq = ops.quantize(v, this.groupSize, this.bits);

    const writeAll = (dst: ops.QuantizedTensor, src: ops.QuantizedTensor): ops.QuantizedTensor => {
      const w = (d: MlxArray, s: MlxArray): MlxArray => {
        const [b, h, , dd] = d.shape as [number, number, number, number];
        const u = ops.sliceUpdate(d, s, [0, 0, prev, 0], [b, h, this.offset, dd]);
        d.dispose();
        s.dispose();
        return u;
      };
      return {
        packed: w(dst.packed, src.packed),
        scales: w(dst.scales, src.scales),
        biases: w(dst.biases, src.biases),
      };
    };
    this.keys = writeAll(this.keys!, kq);
    this.values = writeAll(this.values!, vq);

    const fetch = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const f = (a: MlxArray): MlxArray => {
        const [b, h, , d] = a.shape as [number, number, number, number];
        return a.slice([0, 0, 0, 0], [b, h, this.offset, d]);
      };
      return { packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) };
    };
    return [fetch(this.keys), fetch(this.values)];
  }

  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    // Same rule as KVCache.makeMask (mlx-lm cache.py:114-125): windowless
    // multi-token chunks are the string "causal" at any offset. The old
    // causalEquivalent escape hatch existed precisely because this case
    // used to ship an array; only windowed continuations materialize now.
    if (windowSize === null || (this.offset === 0 && N <= windowSize))
      return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Compiled decode: growth half of updateAndFetchQuantized (L=1),
   *  without quantize/write (those live in the compiled graph / after). */
  prepareDecodeStep(): DecodeStepPlan {
    const prev = this.offset;
    if (!this.keys || !this.values) throw new Error("compiled decode on an empty cache");
    if (prev + 1 > this.keys.packed.shape[2]!) {
      if (prev % QuantizedKVCache.STEP !== 0) {
        const trimTo = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
          const cut = (a: MlxArray): MlxArray => {
            const [b, h, , d] = a.shape as [number, number, number, number];
            const s = a.slice([0, 0, 0, 0], [b, h, prev, d]);
            a.dispose();
            return s;
          };
          return { packed: cut(t.packed), scales: cut(t.scales), biases: cut(t.biases) };
        };
        this.keys = trimTo(this.keys);
        this.values = trimTo(this.values);
      }
      const [B, H] = this.keys.packed.shape as [number, number, number, number];
      const elPerInt = 32 / this.bits;
      const kD = this.keys.packed.shape[3]! * elPerInt;
      const vD = this.values.packed.shape[3]! * elPerInt;
      const dtype = this.keys.scales.dtype;
      this.keys = this.#grow(this.keys, [kD / elPerInt, kD / this.groupSize, kD / this.groupSize], B, H, QuantizedKVCache.STEP, dtype);
      this.values = this.#grow(this.values, [vD / elPerInt, vD / this.groupSize, vD / this.groupSize], B, H, QuantizedKVCache.STEP, dtype);
    }
    return { fetch: "concat", writePos: prev, activeLen: prev };
  }

  /** Compiled decode: the write half — six sliceUpdates of the already-
   *  quantized step row (quantize ran in-graph). Takes ownership of the
   *  rows; returns the updated buffers to async-eval with the step. */
  writeDecodeStep(rows: MlxArray[]): MlxArray[] {
    const prev = this.offset;
    const w = (d: MlxArray, srcRow: MlxArray): MlxArray => {
      const [b, h, , dd] = d.shape as [number, number, number, number];
      const u = ops.sliceUpdate(d, srcRow, [0, 0, prev, 0], [b, h, prev + 1, dd]);
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
    this.offset = prev + 1;
    return this.state();
  }

  state(): MlxArray[] {
    if (!this.keys || !this.values) return [];
    return [
      this.keys.packed, this.keys.scales, this.keys.biases,
      this.values.packed, this.values.scales, this.values.biases,
    ];
  }

  isTrimmable(): boolean {
    return true;
  }

  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
  }

  /** Adopt persisted state (takes ownership of the triples' arrays) —
   *  the quantized twin of KVCache.restoreState (kv-store persistence). */
  restoreState(keys: ops.QuantizedTensor, values: ops.QuantizedTensor, offset: number): void {
    this.dispose();
    this.keys = keys;
    this.values = values;
    this.offset = offset;
  }

  /** Chronological (K, V) triples sliced to offset — the quantized twin of
   *  KVCache.temporalView (batched merge/extend/filter reads). Caller owns
   *  the returned views. */
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
    const cut = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const f = (a: MlxArray): MlxArray => {
        const [b, h, , d] = a.shape as [number, number, number, number];
        return a.slice([0, 0, 0, 0], [b, h, this.offset, d]);
      };
      return { packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) };
    };
    return [cut(this.keys), cut(this.values)];
  }

  dispose(): void {
    for (const a of this.state()) a.dispose();
    this.keys = this.values = null;
    this.offset = 0;
  }
}
