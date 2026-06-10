// Gemma 4 text model — line-for-line port of mlx-lm's gemma4_text.py
// (oracle venv site-packages), covering the paths our target models
// exercise: 12B (dense), e4b (per-layer-input embeddings + KV-shared
// layers), 26B-A4B (MoE block: router + gather_qmm experts).
//
// Parity notes (see PLAN.md Phase 2 findings):
// - SDPA scale is 1.0 (Gemma4 normalizes q/k instead).
// - Full-attention layers: global_head_dim 512, 1 global KV head,
//   attention_k_eq_v (V = same projection as K, with un-scaled RMS norm);
//   ProportionalRoPE rotates only partial_rotary_factor·dims dims.
// - Python-float scalars promote weakly to the array dtype.
// - Replicate mlx python helper implementations exactly (x**3 is
//   mx.power, not x·x·x — they round differently in bf16).
//
// Masks: ports base.py create_attention_mask/create_causal_mask. Sliding
// layers use a plain (non-rotating) cache + window masks — numerically
// identical to mlx-lm's RotatingKVCache, at the cost of unbounded cache
// growth past the window (memory optimization deferred).

import type { ModelConfig } from "../config";
import { quantFor } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";

export type MaskMode = "" | "causal";
export interface Mask {
  mode: MaskMode | "array";
  arr: MlxArray | null;
}

/** Per-adapter LoRA weights for one linear (mlx-lm LoRALinear shapes:
 *  a [in_features, rank], b [rank, out_features], typically f32). */
export interface LoraWeights {
  a: MlxArray;
  b: MlxArray;
  scale: number;
  rank: number;
}

/** Active-adapter state, shared by every mounted linear of one model.
 *  A plain field, NOT a ContextVar port: our generation queue is
 *  serialized, so exactly one request's adapters are active at a time
 *  (PLAN Phase 8 decision). Set/restored by generate(). */
export class LoraState {
  active: string[] = [];
}

export class QuantizedLinear {
  /** Mounted adapters keyed by id (null until first mount — fast path). */
  adapters: Map<string, LoraWeights> | null = null;
  /** Shared per-model active state (wired by AdapterManager.mount). */
  loraState: LoraState | null = null;

  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedLinear {
    if (!weights.has(`${path}.scales`))
      throw new Error(`${path}: expected quantized linear (no .scales tensor)`);
    const spec = quantFor(config.quantization, path);
    if (!spec) throw new Error(`${path}: no quant spec`);
    return new QuantizedLinear(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  /** (in_features, out_features) from the quantized tensors (reference
   *  _infer_linear_shape: scales are [out, in/group_size]). */
  get inFeatures(): number {
    return this.scales.shape[1]! * this.spec.groupSize;
  }
  get outFeatures(): number {
    return this.scales.shape[0]!;
  }

  forward(x: MlxArray): MlxArray {
    let out = ops.quantizedMatmul(x, this.w, this.scales, this.biases, this.spec, true);
    // LoRA residual — composition is mlx-lm LoRALinear / optiq apply.py:
    //   y + (scale · ((x @ A) @ B)).astype(x.dtype)
    // (optiq mount.py omits the astype, leaking the f32 residual into the
    // bf16 stream — divergence documented in PLAN Phase 8 findings; the
    // cast form is what the adapters were trained behind.)
    const st = this.loraState;
    if (st && st.active.length > 0 && this.adapters && this.adapters.size > 0) {
      for (const id of st.active) {
        const lw = this.adapters.get(id);
        if (!lw) continue;
        const xa = ops.matmul(x, lw.a);
        const z = ops.matmul(xa, lw.b);
        xa.dispose();
        const zs = ops.mulScalar(z, lw.scale);
        z.dispose();
        const zc = zs.astype(x.dtype);
        zs.dispose();
        out = disposing(out, ops.add(out, zc));
        zc.dispose();
      }
    }
    return out;
  }
}

class RMSNorm {
  constructor(readonly weight: MlxArray | null, readonly eps: number) {}
  forward(x: MlxArray): MlxArray {
    return ops.rmsNorm(x, this.weight, this.eps);
  }
}

class QuantizedEmbedding {
  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedEmbedding {
    const spec = quantFor(config.quantization, path)!;
    return new QuantizedEmbedding(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  /** ids [1, L] (int/uint) → embeddings [1, L, hidden]. */
  encode(ids: MlxArray): MlxArray {
    const rows = ops.takeAxis(this.w, ids, 0);
    const scaleRows = ops.takeAxis(this.scales, ids, 0);
    const biasRows = this.biases ? ops.takeAxis(this.biases, ids, 0) : null;
    const out = ops.dequantize(rows, scaleRows, biasRows, this.spec);
    for (const a of [rows, scaleRows]) a.dispose();
    biasRows?.dispose();
    return out;
  }

  /** Tied output head: h [1, L, hidden] → logits [1, L, vocab]. */
  asLinear(h: MlxArray): MlxArray {
    return ops.quantizedMatmul(h, this.w, this.scales, this.biases, this.spec, true);
  }
}

/** Fetched KV handed from a donor layer to its sharers (and to the
 *  speculative drafter). Owned by forwardLayers for the pass. */
export type SharedKv =
  | { kind: "plain"; keys: MlxArray; values: MlxArray; offset: number }
  | { kind: "quant"; keys: ops.QuantizedTensor; values: ops.QuantizedTensor;
      offset: number; groupSize: number; bits: number };

export interface Cache {
  offset: number;
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
  /** Mask for an N-token step given this cache's state. */
  makeMask(N: number, windowSize: number | null): Mask;
  state(): MlxArray[];
  /** Can `trim(n)` drop the last n tokens? (Ring caches lose trimability
   *  once wrapped.) */
  isTrimmable(): boolean;
  /** Drop the last n tokens (future writes overwrite them). */
  trim(n: number): void;
  dispose(): void;
}

/** KV cache — port of mlx-lm cache.py KVCache: preallocated in steps of
 *  256 along the sequence axis, updated in place via slice_update. */
export class KVCache implements Cache {
  static readonly STEP = 256;
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const prev = this.offset;
    const L = k.shape[2]!;
    if (!this.keys || prev + L > this.keys.shape[2]!) {
      const [B, H, , D] = k.shape as [number, number, number, number];
      const vD = v.shape[3]!;
      const nSteps = Math.floor((KVCache.STEP + L - 1) / KVCache.STEP);
      const newK = ops.zeros([B, H, nSteps * KVCache.STEP, D], k.dtype);
      const newV = ops.zeros([B, H, nSteps * KVCache.STEP, vD], v.dtype);
      if (this.keys && this.values) {
        let oldK = this.keys;
        let oldV = this.values;
        if (prev % KVCache.STEP !== 0) {
          const trimK = oldK.slice([0, 0, 0, 0], [B, H, prev, D]);
          const trimV = oldV.slice([0, 0, 0, 0], [B, H, prev, vD]);
          oldK.dispose();
          oldV.dispose();
          oldK = trimK;
          oldV = trimV;
        }
        this.keys = ops.concatAxis([oldK, newK], 2);
        this.values = ops.concatAxis([oldV, newV], 2);
        for (const a of [oldK, oldV, newK, newV]) a.dispose();
      } else {
        this.keys = newK;
        this.values = newV;
      }
    }

    this.offset += L;
    const [B, H, S, D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    const k2 = ops.sliceUpdate(this.keys!, k, [0, 0, prev, 0], [B, H, this.offset, D]);
    const v2 = ops.sliceUpdate(this.values!, v, [0, 0, prev, 0], [B, H, this.offset, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = k2;
    this.values = v2;
    return [
      this.keys.slice([0, 0, 0, 0], [B, H, this.offset, D]),
      this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]),
    ];
  }

  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    if (this.offset === 0 && windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && windowSize !== null && N <= windowSize)
      return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Arrays to eval to materialize cache state (prefill chunk boundary). */
  state(): MlxArray[] {
    return this.keys && this.values ? [this.keys, this.values] : [];
  }

  isTrimmable(): boolean {
    return true;
  }

  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
  }

  /** Chronological (K, V) view sliced to offset (drafter donor read). */
  temporalView(): [MlxArray, MlxArray] {
    if (!this.keys || !this.values) throw new Error("cache is empty");
    const [B, H, , D] = this.keys.shape as [number, number, number, number];
    const vD = this.values.shape[3]!;
    return [
      this.keys.slice([0, 0, 0, 0], [B, H, this.offset, D]),
      this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]),
    ];
  }

  /** Adopt persisted state (takes ownership of the arrays). */
  restoreState(keys: MlxArray, values: MlxArray, offset: number): void {
    this.dispose();
    this.keys = keys;
    this.values = values;
    this.offset = offset;
  }

  /** Port of mlx-lm KVCache.to_quantized: quantize the whole buffer
   *  (padding included — it's overwritten before being read). */
  toQuantized(groupSize: number, bits: number): QuantizedKVCache {
    const q = new QuantizedKVCache(groupSize, bits);
    q.offset = this.offset;
    if (this.keys && this.values) {
      q.keys = ops.quantize(this.keys, groupSize, bits);
      q.values = ops.quantize(this.values, groupSize, bits);
    }
    this.dispose();
    return q;
  }

  dispose(): void {
    this.keys?.dispose();
    this.values?.dispose();
    this.keys = this.values = null;
    this.offset = 0;
  }
}

/** Quantized KV cache — port of mlx-lm QuantizedKVCache: keys/values
 *  stored as (packed u32, scales, biases) triples, quantized along
 *  head_dim. Only full-attention layers convert (mlx-lm's rotating-cache
 *  quantization is NYI upstream; sliding layers are window-capped
 *  anyway). Attention dispatches to quantizedSdpa for these. */
export class QuantizedKVCache implements Cache {
  static readonly STEP = 256;
  keys: ops.QuantizedTensor | null = null;
  values: ops.QuantizedTensor | null = null;
  offset = 0;

  constructor(readonly groupSize: number, readonly bits: number) {}

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
    if (this.offset === 0 && (windowSize === null || N <= windowSize))
      return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
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

  dispose(): void {
    for (const a of this.state()) a.dispose();
    this.keys = this.values = null;
    this.offset = 0;
  }
}

/** Rotating (sliding-window) KV cache — port of mlx-lm RotatingKVCache
 *  with keep=0 (gemma4's configuration): a ring buffer of max_size
 *  entries, so decode attends over at most the window. RoPE offsets use
 *  the true position; masks use the buffer-clamped offset. */
export class RotatingKVCache implements Cache {
  static readonly STEP = 256;
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;
  #idx = 0;
  readonly maxSize: number;

  constructor(maxSize: number) {
    this.maxSize = maxSize;
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

  trim(n: number): void {
    const k = Math.min(this.offset, n);
    this.offset -= k;
    this.#idx -= k;
  }

  get ringIdx(): number {
    return this.#idx;
  }

  /** Chronological (K, V) view, valid length min(offset, maxSize)
   *  (port of optiq kv_view._read_cache_temporal). */
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

  dispose(): void {
    this.keys?.dispose();
    this.values?.dispose();
    this.keys = this.values = null;
    this.offset = 0;
    this.#idx = 0;
  }
}

const FINFO_MIN: Partial<Record<Dtype, number>> = {
  [Dtype.bfloat16]: -3.3895313892515355e38,
  [Dtype.float16]: -65504,
  [Dtype.float32]: -3.4028234663852886e38,
};

/** Port of base.py quantized_scaled_dot_product_attention (stock,
 *  non-tiled): scores and output via quantized_matmul against the
 *  quantized KV triples; GQA via a 5-d reshape. Exported for the
 *  fused-vs-unfused parity tests. */
export function quantizedSdpaUnfused(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const nRep = H / KV;
  const N = kq.packed.shape[2]!;

  let queries = ops.mulScalar(q, scale);
  const owned: MlxArray[] = [queries];

  let kT = kq;
  let vT = vq;
  if (nRep > 1) {
    const qr = ops.reshape(queries, [B, KV, nRep, L, D]);
    owned.push(qr);
    queries = qr;
    const expand = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const e = (a: MlxArray): MlxArray => {
        // expand_dims(axis=-3) like the reference — view-preserving;
        // reshape would copy the strided slice and change kernel paths
        const r = ops.expandDims(a, -3);
        owned.push(r);
        return r;
      };
      return { packed: e(t.packed), scales: e(t.scales), biases: e(t.biases) };
    };
    kT = expand(kq);
    vT = expand(vq);
  }

  let scores = ops.quantizedMatmulQT(queries, kT, true, groupSize, bits);
  owned.push(scores);

  let maskArr: MlxArray | null = null;
  let ownsMask = false;
  if (mask.mode === "causal") {
    const qIdx = ops.arange(N - L, N, 1, Dtype.int32);
    const kIdx = ops.arange(0, N, 1, Dtype.int32);
    const qCol = ops.reshape(qIdx, [L, 1]);
    const kRow = ops.reshape(kIdx, [1, N]);
    maskArr = ops.greaterEqual(qCol, kRow);
    ownsMask = true;
    for (const a of [qIdx, kIdx, qCol, kRow]) a.dispose();
  } else if (mask.mode === "array") {
    maskArr = mask.arr;
  }
  if (maskArr) {
    const ninf = ops.scalarLike(FINFO_MIN[scores.dtype] ?? -3.4e38, scores);
    const masked = ops.where(maskArr, scores, ninf);
    ninf.dispose();
    if (ownsMask) maskArr.dispose();
    owned.push(masked);
    scores = masked;
  }

  const probs = ops.softmaxAxis(scores, -1, true);
  owned.push(probs);
  let out = ops.quantizedMatmulQT(probs, vT, false, groupSize, bits);
  if (nRep > 1) {
    const r = ops.reshape(out, [B, H, L, D]);
    out.dispose();
    out = r;
  }
  for (const a of owned) a.dispose();
  return out;
}

/** Tile size for the fused quantized-SDPA prefill path (oracle default). */
export const FUSED_N_CHUNK = 512;

/** Port of optiq fused_quant_sdpa._prefill_flashattn_n_tiled: a
 *  FlashAttention-2 loop over the KV N axis with mx.quantized_matmul as
 *  the inner kernel. Never materializes the full [..., L, N] scores
 *  matrix — the per-tile transient is bounded by FUSED_N_CHUNK, which is
 *  the whole point (stock u4 KV prefill peaks ABOVE fp16 KV at long
 *  context; see the oracle's module docstring). Op composition order
 *  mirrors the oracle exactly: parity is tier a (bit-exact) vs the python
 *  fused path; vs quantizedSdpaUnfused it is tier b by construction
 *  (online softmax ≠ one-shot precise softmax in bf16). */
export function quantizedSdpaTiled(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const nRep = H / KV;
  const N = kq.packed.shape[2]!;

  let queries = ops.mulScalar(q, scale);

  let kT = kq;
  let vT = vq;
  const expanded: MlxArray[] = [];
  if (nRep > 1) {
    const qr = ops.reshape(queries, [B, KV, nRep, L, D]);
    queries.dispose();
    queries = qr;
    const expand = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const e = (a: MlxArray): MlxArray => {
        const r = ops.expandDims(a, -3);
        expanded.push(r);
        return r;
      };
      return { packed: e(t.packed), scales: e(t.scales), biases: e(t.biases) };
    };
    kT = expand(kq);
    vT = expand(vq);
  }

  // The oracle builds a bottom-right-aligned [L, N] bool causal matrix
  // and slices columns per tile; our "array" masks (createCausalMask at
  // offset > 0) are that same matrix already materialized — both slice
  // identically below.
  let maskArr: MlxArray | null = null;
  let ownsMask = false;
  if (mask.mode === "causal") {
    const qIdx = ops.arange(N - L, N, 1, Dtype.int32);
    const kIdx = ops.arange(0, N, 1, Dtype.int32);
    const qCol = ops.reshape(qIdx, [L, 1]);
    const kRow = ops.reshape(kIdx, [1, N]);
    maskArr = ops.greaterEqual(qCol, kRow);
    ownsMask = true;
    for (const a of [qIdx, kIdx, qCol, kRow]) a.dispose();
  } else if (mask.mode === "array") {
    maskArr = mask.arr;
  }

  // Slice [..., n0:n1, :] (KV triples) / [..., n0:n1] (mask chunks).
  const sliceAxis = (a: MlxArray, axisFromEnd: 1 | 2, n0: number, n1: number): MlxArray => {
    const dims = a.shape;
    const start = dims.map(() => 0);
    const stop = [...dims];
    start[dims.length - axisFromEnd] = n0;
    stop[dims.length - axisFromEnd] = n1;
    return a.slice(start, stop);
  };

  let oAcc: MlxArray | null = null;
  let rowMax: MlxArray | null = null;
  let rowSum: MlxArray | null = null;

  for (let n0 = 0; n0 < N; n0 += FUSED_N_CHUNK) {
    const n1 = Math.min(n0 + FUSED_N_CHUNK, N);
    const kChunk: ops.QuantizedTensor = {
      packed: sliceAxis(kT.packed, 2, n0, n1),
      scales: sliceAxis(kT.scales, 2, n0, n1),
      biases: sliceAxis(kT.biases, 2, n0, n1),
    };
    const vChunk: ops.QuantizedTensor = {
      packed: sliceAxis(vT.packed, 2, n0, n1),
      scales: sliceAxis(vT.scales, 2, n0, n1),
      biases: sliceAxis(vT.biases, 2, n0, n1),
    };

    let scores = ops.quantizedMatmulQT(queries, kChunk, true, groupSize, bits);
    for (const a of [kChunk.packed, kChunk.scales, kChunk.biases]) a.dispose();

    if (maskArr) {
      const maskChunk = sliceAxis(maskArr, 1, n0, n1);
      let masked: MlxArray;
      if (maskChunk.dtype === Dtype.bool) {
        const ninf = ops.scalarLike(FINFO_MIN[scores.dtype] ?? -3.4e38, scores);
        masked = ops.where(maskChunk, scores, ninf);
        ninf.dispose();
      } else {
        masked = ops.add(scores, maskChunk);
      }
      maskChunk.dispose();
      scores.dispose();
      scores = masked;
    }

    const chunkMax = ops.maxAxis(scores, -1, true);
    if (oAcc === null) {
      rowMax = chunkMax;
      const shifted = ops.sub(scores, rowMax);
      const exps = ops.exp(shifted);
      shifted.dispose();
      rowSum = ops.sumAxis(exps, -1, true);
      oAcc = ops.quantizedMatmulQT(exps, vChunk, false, groupSize, bits);
      exps.dispose();
    } else {
      const newMax = ops.maximum(rowMax!, chunkMax);
      chunkMax.dispose();
      const maxDiff = ops.sub(rowMax!, newMax);
      const factor = ops.exp(maxDiff);
      maxDiff.dispose();
      const shifted = ops.sub(scores, newMax);
      const exps = ops.exp(shifted);
      shifted.dispose();
      // new_sum = factor * row_sum + sum(exps)  (association order kept)
      const carried = ops.mul(factor, rowSum!);
      const sumExps = ops.sumAxis(exps, -1, true);
      const newSum = ops.add(carried, sumExps);
      carried.dispose();
      sumExps.dispose();
      const deltaOut = ops.quantizedMatmulQT(exps, vChunk, false, groupSize, bits);
      exps.dispose();
      // o_acc = o_acc * factor + delta_out
      const scaledAcc = ops.mul(oAcc!, factor);
      factor.dispose();
      const nextAcc = ops.add(scaledAcc, deltaOut);
      scaledAcc.dispose();
      deltaOut.dispose();
      oAcc!.dispose();
      oAcc = nextAcc;
      rowMax!.dispose();
      rowMax = newMax;
      rowSum!.dispose();
      rowSum = newSum;
    }
    scores.dispose();
    for (const a of [vChunk.packed, vChunk.scales, vChunk.biases]) a.dispose();
  }

  let out = ops.div(oAcc!, rowSum!);
  oAcc!.dispose();
  rowMax!.dispose();
  rowSum!.dispose();
  if (ownsMask) maskArr!.dispose();
  for (const a of expanded) a.dispose();
  queries.dispose();
  if (nRep > 1) {
    const r = ops.reshape(out, [B, H, L, D]);
    out.dispose();
    out = r;
  }
  return out;
}

/** Gate for the tiled path — port of fused_quant_sdpa._supported plus the
 *  wrapper's mask check, with one documented deviation: the oracle wrapper
 *  falls back to unfused on ARRAY masks because mlx-lm always hands it the
 *  "causal" string in this scenario (its make_mask returns "causal" even at
 *  offset > 0 for non-windowed caches); our makeMask materializes the
 *  equivalent bool matrix for offset > 0 — the exact
 *  long-prefill-over-quantized-cache case this path exists for — so 2-d
 *  bool array masks tile too (the oracle's INNER function handles them
 *  with the same column slicing we use). */
/** Escape hatch mirroring optiq serve's --no-fused-kv: forces the stock
 *  unfused path everywhere. Also the A/B lever for
 *  scripts/bench-fused-prefill.ts. */
const FUSED_SDPA_DISABLED = process.env.MLX_BUN_NO_FUSED_SDPA === "1";

function fusedSdpaSupported(q: MlxArray, mask: Mask, groupSize: number, bits: number): boolean {
  if (FUSED_SDPA_DISABLED) return false;
  if (bits !== 4 && bits !== 8) return false;
  if (groupSize !== 32 && groupSize !== 64 && groupSize !== 128) return false;
  if (q.dtype !== Dtype.bfloat16 && q.dtype !== Dtype.float16) return false;
  if (mask.mode === "causal") return true;
  if (mask.mode === "array")
    return mask.arr !== null && mask.arr.shape.length === 2 && mask.arr.dtype === Dtype.bool;
  return false;
}

/** Quantized-cache SDPA dispatch: L > 1 (prefill/continuation) with a
 *  supported config goes through the N-tiled fused path; decode (L = 1)
 *  and unsupported configs stay on the stock unfused port. Exported for
 *  the dispatch-gate tests. */
export function quantizedSdpa(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  if (q.shape[2]! > 1 && fusedSdpaSupported(q, mask, groupSize, bits))
    return quantizedSdpaTiled(q, kq, vq, scale, mask, groupSize, bits);
  return quantizedSdpaUnfused(q, kq, vq, scale, mask, groupSize, bits);
}

/** Port of base.py create_causal_mask (bool, [N, offset+N]). */
export function createCausalMask(N: number, offset: number, windowSize: number | null): MlxArray {
  const rinds = ops.arange(0, offset + N, 1, Dtype.int32);
  const lindsFlat = offset ? ops.arange(offset, offset + N, 1, Dtype.int32) : rinds;
  const linds = ops.reshape(lindsFlat, [N, 1]);
  const rindsB = ops.reshape(rinds, [1, offset + N]);
  let mask = ops.greaterEqual(linds, rindsB);
  if (windowSize !== null) {
    const w = ops.fromInt32([windowSize], []);
    const rPlusW = ops.add(rindsB, w);
    const inWindow = ops.less(linds, rPlusW);
    const combined = ops.logicalAnd(mask, inWindow);
    for (const a of [w, rPlusW, inWindow, mask]) a.dispose();
    mask = combined;
  }
  if (lindsFlat !== rinds) lindsFlat.dispose();
  rinds.dispose();
  linds.dispose();
  rindsB.dispose();
  return mask;
}

class Attention {
  readonly isSliding: boolean;
  readonly useKEqV: boolean;
  readonly hasKv: boolean;
  readonly headDim: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly ropeBase: number | null;
  readonly ropeFreqs: MlxArray | null;
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear | null;
  readonly vProj: QuantizedLinear | null;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm | null;
  readonly vNorm: RMSNorm | null;

  constructor(
    weights: Weights, config: ModelConfig, prefix: string, layerType: string,
    hasKv = true,
  ) {
    const t = config.text;
    this.hasKv = hasKv;
    this.isSliding = layerType === "sliding_attention";
    this.headDim = this.isSliding ? t.headDim : t.globalHeadDim;
    this.nHeads = t.numAttentionHeads;
    this.useKEqV = t.attentionKEqV && !this.isSliding;
    this.nKvHeads = this.useKEqV ? t.numGlobalKeyValueHeads : t.numKeyValueHeads;

    const rp = t.ropeParameters[this.isSliding ? "sliding_attention" : "full_attention"]!;
    if (rp.ropeType === "default") {
      this.ropeBase = rp.ropeTheta;
      this.ropeFreqs = null;
    } else if (rp.ropeType === "proportional") {
      // Port of rope_utils.ProportionalRoPE.__init__. The rotated freqs
      // MUST be computed on-device in f32 (arange/dims, then base**x)
      // exactly like the reference — computing them host-side in f64 and
      // rounding to f32 lands 17/64 of them 1 ulp off (f64 pow ≠ f32
      // powf), a latent knife-edge that Phase 10's tiled values exposed
      // as a 1-ulp q-rope divergence at layer 11 (Phase 2 porting rule:
      // replicate the helper's IMPLEMENTATION, not its formula).
      const rotated = Math.floor(this.headDim * rp.partialRotaryFactor);
      const n = this.headDim / 2;
      const exponentsRaw = ops.arange(0, rotated, 2, Dtype.float32);
      const dims = ops.scalarLike(this.headDim, exponentsRaw);
      const exponents = ops.div(exponentsRaw, dims);
      const base = ops.scalarLike(rp.ropeTheta, exponents);
      let rotFreqs = ops.pow(base, exponents);
      if (rp.factor !== 1.0) {
        const f = ops.scalarLike(rp.factor, rotFreqs);
        rotFreqs = disposing(rotFreqs, ops.mul(f, rotFreqs));
        f.dispose();
      }
      this.ropeBase = null;
      const tailLen = n - rotated / 2;
      if (tailLen > 0) {
        const tail = MlxArray.fromFloat32(
          new Float32Array(tailLen).fill(Infinity), [tailLen],
        );
        this.ropeFreqs = ops.concatAxis([rotFreqs, tail], 0);
        tail.dispose();
      } else {
        this.ropeFreqs = rotFreqs;
      }
      for (const a of [exponentsRaw, dims, exponents, base])
        a.dispose();
      if (this.ropeFreqs !== rotFreqs) rotFreqs.dispose();
    } else {
      throw new Error(`unsupported rope_type ${rp.ropeType}`);
    }

    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = hasKv ? QuantizedLinear.load(weights, `${prefix}.k_proj`, config) : null;
    this.vProj = hasKv && !this.useKEqV
      ? QuantizedLinear.load(weights, `${prefix}.v_proj`, config) : null;
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = hasKv
      ? new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps) : null;
    this.vNorm = hasKv ? new RMSNorm(null, t.rmsNormEps) : null;
  }

  rope(x: MlxArray, offset: number): MlxArray {
    return ops.rope(x, this.headDim, this.ropeBase, offset, this.ropeFreqs);
  }

  /** Returns the attention output plus the fetched KV (for KV-shared
   *  sharer layers and the speculative drafter). The SharedKv arrays are
   *  owned by the caller (forwardLayers) and disposed after the pass. */
  forward(
    x: MlxArray, mask: Mask, cache: Cache | null, sharedIn: SharedKv | null,
  ): { out: MlxArray; shared: SharedKv } {
    const [B, L] = x.shape as [number, number, number];

    let q = this.qProj.forward(x);
    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    q = disposing(q, this.qNorm.forward(q));

    let shared: SharedKv;
    if (!this.hasKv) {
      if (!sharedIn) throw new Error("KV-shared layer received no shared KV");
      shared = sharedIn;
    } else {
      if (!cache) throw new Error("donor layer requires a cache");
      let k = this.kProj!.forward(x);
      k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
      let v: MlxArray;
      if (this.vProj) {
        v = this.vProj.forward(x);
        v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
      } else {
        v = k; // attention_k_eq_v: shared projection; norms differ below
      }

      const offset = cache.offset;

      const kNormed = this.kNorm!.forward(k);
      const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]);
      kNormed.dispose();
      const kRoped = this.rope(kT, offset);
      kT.dispose();

      const vNormed = this.vNorm!.forward(v);
      const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);
      vNormed.dispose();
      if (v !== k) v.dispose();
      k.dispose();

      if (cache instanceof QuantizedKVCache) {
        const [kq, vq] = cache.updateAndFetchQuantized(kRoped, vT);
        kRoped.dispose();
        vT.dispose();
        shared = {
          kind: "quant", keys: kq, values: vq, offset,
          groupSize: cache.groupSize, bits: cache.bits,
        };
      } else {
        const [keys, values] = cache.updateAndFetch(kRoped, vT);
        kRoped.dispose();
        vT.dispose();
        shared = { kind: "plain", keys, values, offset };
      }
    }

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    q = disposing(q, this.rope(q, shared.offset));

    let attn: MlxArray;
    if (shared.kind === "quant") {
      attn = quantizedSdpa(q, shared.keys, shared.values, 1.0, mask, shared.groupSize, shared.bits);
    } else {
      attn = ops.sdpa(q, shared.keys, shared.values, 1.0, mask.mode, mask.arr);
    }
    q.dispose();
    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.oProj.forward(merged);
    merged.dispose();
    return { out, shared };
  }
}

class MLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray): MlxArray {
    const g = this.gate.forward(x);
    const u = this.up.forward(x);
    const act = ops.geluApprox(g);
    g.dispose();
    const h = ops.mul(act, u);
    act.dispose();
    u.dispose();
    const out = this.down.forward(h);
    h.dispose();
    return out;
  }
}

// --- MoE block (26B-A4B) — port of reference Router/Experts/SwitchGLU ----
// (gemma4_text.py + switch_layers.py in the oracle venv). The checkpoint
// ships pre-stacked switch_glu tensors [experts, out, in/packed]; only the
// quantized path exists here (all our targets are OptiQ quants).

/** Port of switch_layers.QuantizedSwitchLinear (gather_qmm over stacked
 *  expert weights; rhs_indices selects the expert per row). */
class QuantizedSwitchLinear {
  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedSwitchLinear {
    if (!weights.has(`${path}.scales`))
      throw new Error(`${path}: expected quantized switch linear (no .scales tensor)`);
    const spec = quantFor(config.quantization, path);
    if (!spec) throw new Error(`${path}: no quant spec`);
    return new QuantizedSwitchLinear(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  forward(x: MlxArray, indices: MlxArray, sortedIndices: boolean): MlxArray {
    return ops.gatherQmm(x, this.w, this.scales, this.biases, indices, this.spec, sortedIndices);
  }
}

/** Port of reference Router: norm -> scale -> project -> top-k -> renormalize. */
class Router {
  readonly proj: QuantizedLinear;
  /** scale · hidden_size^-0.5, precomputed (identical ops to the per-call
   *  product in the reference: bf16 array × weak scalar). */
  readonly normWeight: MlxArray;
  readonly perExpertScale: MlxArray;
  readonly eps: number;
  readonly numExperts: number;
  readonly topK: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.proj = QuantizedLinear.load(weights, `${prefix}.proj`, config);
    const scale = weights.tensor(`${prefix}.scale`);
    this.normWeight = ops.mulScalar(scale, Math.pow(t.hiddenSize, -0.5));
    scale.dispose();
    this.perExpertScale = weights.tensor(`${prefix}.per_expert_scale`);
    this.eps = t.rmsNormEps;
    this.numExperts = t.numExperts;
    this.topK = t.topKExperts;
  }

  /** x [B, L, H] → { indices [B, L, k] (uint32), weights [B, L, k] }. */
  forward(x: MlxArray): { indices: MlxArray; weights: MlxArray } {
    const normed = ops.rmsNorm(x, this.normWeight, this.eps);
    const scores = this.proj.forward(normed);
    normed.dispose();

    const part = ops.argpartitionAxis(scores, this.numExperts - this.topK, -1);
    const [B, L] = scores.shape as [number, number, number];
    const indices = part.slice([0, 0, this.numExperts - this.topK], [B, L, this.numExperts]);
    part.dispose();

    let w = ops.takeAlongAxis(scores, indices, -1);
    scores.dispose();
    w = disposing(w, ops.softmaxAxis(w, -1, false));
    const gathered = ops.takeAxis(this.perExpertScale, indices, 0);
    w = disposing(w, ops.mul(w, gathered));
    gathered.dispose();
    return { indices, weights: w };
  }
}

/** Port of switch_layers.SwitchGLU (geglu activation), quantized path. */
class SwitchGLU {
  readonly gate: QuantizedSwitchLinear;
  readonly up: QuantizedSwitchLinear;
  readonly down: QuantizedSwitchLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedSwitchLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedSwitchLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedSwitchLinear.load(weights, `${prefix}.down_proj`, config);
  }

  /** x [B, L, H], indices [B, L, k] → [B, L, k, H]. */
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    // x → [B, L, 1, 1, H] (reference expand_dims(x, (-2, -3)))
    let h = ops.expandDims(x, -2);
    h = disposing(h, ops.expandDims(h, -3));

    // Sort tokens by expert when there are many rows (reference threshold).
    const doSort = indices.size >= 64;
    let idx = indices;
    let invOrder: MlxArray | null = null;
    let order: MlxArray | null = null;
    if (doSort) {
      // _gather_sort: flatten indices, argsort, gather rows by order // k
      const k = indices.shape[indices.ndim - 1]!;
      const idxFlat = ops.reshape(indices, [indices.size]);
      order = ops.argsortAxis(idxFlat, 0);
      invOrder = ops.argsortAxis(order, 0);
      const kScalar = ops.scalarLike(k, order);
      const rowIdx = ops.floorDivide(order, kScalar);
      kScalar.dispose();
      const [, , , , H] = h.shape as number[];
      const flat = ops.reshape(h, [-1, 1, H!]);
      h.dispose();
      h = ops.takeAxis(flat, rowIdx, 0);
      flat.dispose();
      rowIdx.dispose();
      idx = ops.takeAxis(idxFlat, order, 0);
      idxFlat.dispose();
    }

    const xUp = this.up.forward(h, idx, doSort);
    const xGate = this.gate.forward(h, idx, doSort);
    h.dispose();
    // GeGLU activation: gelu_approx(gate) · up (same composition as MLP)
    const act = ops.geluApprox(xGate);
    xGate.dispose();
    const mid = ops.mul(act, xUp);
    act.dispose();
    xUp.dispose();
    let y = this.down.forward(mid, idx, doSort);
    mid.dispose();
    if (idx !== indices) idx.dispose();

    if (doSort) {
      // _scatter_unsort: restore row order, unflatten to indices.shape
      y = disposing(y, ops.takeAxis(y, invOrder!, 0));
      invOrder!.dispose();
      order!.dispose();
      const [B, L, k] = indices.shape as number[];
      const H = y.shape[y.ndim - 1]!;
      y = disposing(y, ops.reshape(y, [B!, L!, k!, 1, H]));
    }

    // squeeze(-2)
    const shape = y.shape;
    shape.splice(shape.length - 2, 1);
    return disposing(y, ops.reshape(y, shape));
  }
}

/** Port of reference Experts: switch_glu then top-k weighted sum. */
class Experts {
  readonly switchGlu: SwitchGLU;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.switchGlu = new SwitchGLU(weights, config, `${prefix}.switch_glu`);
  }

  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    const w = ops.expandDims(weights, -1);
    const y = this.switchGlu.forward(x, indices);
    const wy = ops.mul(w, y);
    w.dispose();
    y.dispose();
    return disposing(wy, ops.sumAxis(wy, -2, false));
  }
}

class DecoderLayer {
  readonly attn: Attention;
  readonly mlp: MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  readonly layerScalar: MlxArray | null;
  readonly layerType: string;
  // 26B-A4B MoE block (dense MLP + routed experts in parallel branches)
  readonly router: Router | null;
  readonly experts: Experts | null;
  readonly postFfNorm1: RMSNorm | null;
  readonly postFfNorm2: RMSNorm | null;
  readonly preFfNorm2: RMSNorm | null;
  // e2b/e4b per-layer input gating
  readonly perLayerGate: QuantizedLinear | null;
  readonly perLayerProjection: QuantizedLinear | null;
  readonly postPerLayerNorm: RMSNorm | null;

  constructor(weights: Weights, config: ModelConfig, prefixBase: string, idx: number, hasKv: boolean) {
    const prefix = `${prefixBase}.layers.${idx}`;
    const t = config.text;
    this.layerType = t.layerTypes[idx]!;
    this.attn = new Attention(weights, config, `${prefix}.self_attn`, this.layerType, hasKv);
    this.mlp = new MLP(weights, config, `${prefix}.mlp`);
    const norm = (n: string) => new RMSNorm(weights.tensor(`${prefix}.${n}.weight`), t.rmsNormEps);
    this.inputNorm = norm("input_layernorm");
    this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm");
    this.postFfNorm = norm("post_feedforward_layernorm");
    this.layerScalar = weights.has(`${prefix}.layer_scalar`)
      ? weights.tensor(`${prefix}.layer_scalar`)
      : null;
    if (t.enableMoeBlock) {
      this.router = new Router(weights, config, `${prefix}.router`);
      this.experts = new Experts(weights, config, `${prefix}.experts`);
      this.postFfNorm1 = norm("post_feedforward_layernorm_1");
      this.postFfNorm2 = norm("post_feedforward_layernorm_2");
      this.preFfNorm2 = norm("pre_feedforward_layernorm_2");
    } else {
      this.router = this.experts = null;
      this.postFfNorm1 = this.postFfNorm2 = this.preFfNorm2 = null;
    }
    if (t.hiddenSizePerLayerInput > 0) {
      this.perLayerGate = QuantizedLinear.load(weights, `${prefix}.per_layer_input_gate`, config);
      this.perLayerProjection = QuantizedLinear.load(weights, `${prefix}.per_layer_projection`, config);
      this.postPerLayerNorm = norm("post_per_layer_input_norm");
    } else {
      this.perLayerGate = this.perLayerProjection = null;
      this.postPerLayerNorm = null;
    }
  }

  forward(
    x: MlxArray, mask: Mask, cache: Cache | null,
    sharedIn: SharedKv | null, perLayerInput: MlxArray | null,
  ): { h: MlxArray; shared: SharedKv } {
    let h = this.inputNorm.forward(x);
    const { out, shared } = this.attn.forward(h, mask, cache, sharedIn);
    h.dispose();
    h = out;
    h = disposing(h, this.postAttnNorm.forward(h));
    h = disposing(h, ops.add(x, h));

    const residual = h;
    let f: MlxArray;
    if (this.router && this.experts) {
      // MoE: dense MLP and routed experts as parallel branches off h
      // (reference DecoderLayer, enable_moe path)
      let h1 = this.preFfNorm.forward(h);
      h1 = disposing(h1, this.mlp.forward(h1));
      h1 = disposing(h1, this.postFfNorm1!.forward(h1));

      const { indices, weights: topKWeights } = this.router.forward(h);
      let h2 = this.preFfNorm2!.forward(h);
      h2 = disposing(h2, this.experts.forward(h2, indices, topKWeights));
      h2 = disposing(h2, this.postFfNorm2!.forward(h2));
      indices.dispose();
      topKWeights.dispose();

      f = ops.add(h1, h2);
      h1.dispose();
      h2.dispose();
    } else {
      f = this.preFfNorm.forward(h);
      f = disposing(f, this.mlp.forward(f));
    }
    f = disposing(f, this.postFfNorm.forward(f));
    h = ops.add(residual, f);
    residual.dispose();
    f.dispose();

    // per-layer input gating (reference gemma4_text DecoderLayer)
    if (this.perLayerGate && this.perLayerProjection && this.postPerLayerNorm && perLayerInput) {
      const res2 = h;
      let gate = this.perLayerGate.forward(h);
      gate = disposing(gate, ops.geluApprox(gate));
      gate = disposing(gate, ops.mul(gate, perLayerInput));
      gate = disposing(gate, this.perLayerProjection.forward(gate));
      gate = disposing(gate, this.postPerLayerNorm.forward(gate));
      h = ops.add(res2, gate);
      res2.dispose();
      gate.dispose();
    }

    if (this.layerScalar) h = disposing(h, ops.mul(h, this.layerScalar));
    return { h, shared };
  }
}

/** Dispose `old` and return `next` — for h = disposing(h, op(h)) chains. */
function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}

export class Gemma4Model {
  readonly config: ModelConfig;
  /** Total weight-shard bytes (for the conditional wired-limit scope). */
  readonly weightsBytes: number;
  /** Weight-name prefix ("language_model.model" or "model"). */
  readonly prefixBase: string;
  /** Active LoRA adapters for the current generation (see LoraState). */
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: DecoderLayer[];
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;
  readonly windowSize: number;
  /** Donor count: layers [0, numDonors) own caches; the rest share. */
  readonly numDonors: number;
  /** layer idx → donor layer idx whose fetched KV it consumes (self for donors). */
  readonly previousKvs: number[];
  /** layer idx → cache index (donors only; -1 for sharers). */
  readonly cacheIndex: number[];
  // e2b/e4b per-layer input machinery
  readonly perLayerEmbed: QuantizedEmbedding | null;
  readonly perLayerModelProjection: QuantizedLinear | null;
  readonly perLayerProjectionNorm: RMSNorm | null;
  readonly perLayerWidth: number;

  constructor(weights: Weights, config: ModelConfig) {
    const t = config.text;
    if (t.hiddenSize === 0 || !config.text.tieWordEmbeddings)
      throw new Error("only tied-embedding text configs are supported");

    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    // gemma4_unified prefixes weights with language_model.; gemma4_text doesn't
    const prefixBase = weights.has("language_model.model.embed_tokens.weight")
      ? "language_model.model" : "model";
    this.prefixBase = prefixBase;
    this.embed = QuantizedEmbedding.load(weights, `${prefixBase}.embed_tokens`, config);

    this.numDonors = t.numHiddenLayers - t.numKvSharedLayers;
    this.layers = Array.from(
      { length: t.numHiddenLayers },
      (_, i) => new DecoderLayer(weights, config, prefixBase, i, i < this.numDonors),
    );
    // previous_kvs (reference Gemma4TextModel): sharer j uses the LAST
    // donor of its own layer type
    this.previousKvs = this.layers.map((_, i) => i);
    if (t.numKvSharedLayers > 0) {
      const lastByType: Record<string, number> = {};
      for (let i = 0; i < this.numDonors; i++)
        lastByType[this.layers[i]!.layerType] = i;
      for (let j = this.numDonors; j < this.layers.length; j++) {
        const donor = lastByType[this.layers[j]!.layerType];
        if (donor === undefined)
          throw new Error(`no donor layer of type ${this.layers[j]!.layerType}`);
        this.previousKvs[j] = donor;
      }
    }
    this.cacheIndex = this.layers.map((_, i) => (i < this.numDonors ? i : -1));

    this.finalNorm = new RMSNorm(
      weights.tensor(`${prefixBase}.norm.weight`),
      t.rmsNormEps,
    );
    this.embedScale = Math.sqrt(t.hiddenSize);
    this.windowSize = t.slidingWindow;

    if (t.hiddenSizePerLayerInput > 0) {
      this.perLayerEmbed = QuantizedEmbedding.load(weights, `${prefixBase}.embed_tokens_per_layer`, config);
      this.perLayerModelProjection = QuantizedLinear.load(weights, `${prefixBase}.per_layer_model_projection`, config);
      this.perLayerProjectionNorm = new RMSNorm(
        weights.tensor(`${prefixBase}.per_layer_projection_norm.weight`), t.rmsNormEps,
      );
      this.perLayerWidth = t.hiddenSizePerLayerInput;
    } else {
      this.perLayerEmbed = this.perLayerModelProjection = null;
      this.perLayerProjectionNorm = null;
      this.perLayerWidth = 0;
    }
  }

  /** LoRA-mountable linears, keyed by weight-file module path: optiq
   *  mount.py's 7 target suffixes PLUS the e2b/e4b per-layer-input
   *  projections — mlx-lm's trainer targets those on e4b and optiq's
   *  mount silently drops their trained weights (deviation documented in
   *  PLAN Phase 8 findings; we apply every adapter weight we can map).
   *  Expert pools stay non-targets (LoRASwitchLinear is future work). */
  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `${this.prefixBase}.layers.${i}`;
      const add = (suffix: string, lin: QuantizedLinear | null) => {
        if (lin) out.set(`${p}.${suffix}`, lin);
      };
      add("self_attn.q_proj", l.attn.qProj);
      add("self_attn.k_proj", l.attn.kProj);
      add("self_attn.v_proj", l.attn.vProj);
      add("self_attn.o_proj", l.attn.oProj);
      add("mlp.gate_proj", l.mlp.gate);
      add("mlp.up_proj", l.mlp.up);
      add("mlp.down_proj", l.mlp.down);
      add("per_layer_input_gate", l.perLayerGate);
      add("per_layer_projection", l.perLayerProjection);
    }
    return out;
  }

  /** Caches for donor layers only (sharers consume donors' fetched KV). */
  makeCache(): Cache[] {
    return this.layers.slice(0, this.numDonors).map((l) =>
      l.layerType === "sliding_attention"
        ? new RotatingKVCache(this.windowSize)
        : new KVCache(),
    );
  }

  /** ids [1, L] → final-norm hidden states [1, L, hidden]. */
  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    let h = this.embed.encode(ids);
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    return this.forwardLayers(h, cache, null, ids);
  }

  /** Per-layer inputs (reference _get_per_layer_inputs +
   *  _project_per_layer_inputs): [1, L, nLayers, perLayerWidth]. */
  private computePerLayerInputs(ids: MlxArray, hScaled: MlxArray): MlxArray {
    const t = this.config.text;
    const L = ids.shape[1]!;
    let pli = this.perLayerEmbed!.encode(ids); // [1, L, nLayers*width]
    pli = disposing(pli, ops.mulScalar(pli, Math.sqrt(this.perLayerWidth)));
    pli = disposing(pli, ops.reshape(pli, [1, L, t.numHiddenLayers, this.perLayerWidth]));

    let proj = this.perLayerModelProjection!.forward(hScaled);
    proj = disposing(proj, ops.mulScalar(proj, 1 / Math.sqrt(t.hiddenSize)));
    proj = disposing(proj, ops.reshape(proj, [1, L, t.numHiddenLayers, this.perLayerWidth]));
    proj = disposing(proj, this.perLayerProjectionNorm!.forward(proj));

    let combined = ops.add(proj, pli);
    proj.dispose();
    pli.dispose();
    combined = disposing(combined, ops.mulScalar(combined, Math.SQRT1_2));
    return combined;
  }

  /** Pre-merged (unscaled) input embeddings → hidden states. Used by the
   *  vision path; `bidir` (bool [L]) marks image tokens, which attend
   *  bidirectionally among themselves (use_bidirectional_attention:
   *  "vision" — text stays causal). */
  forwardEmbeddings(embeds: MlxArray, cache: Cache[], bidir: MlxArray | null): MlxArray {
    if (this.perLayerWidth > 0)
      throw new Error("vision + per-layer-input models not supported yet");
    const h = ops.mulScalar(embeds, this.embedScale);
    return this.forwardLayers(h, cache, bidir, null);
  }

  /** Consumes h. */
  private forwardLayers(
    h0: MlxArray, cache: Cache[], bidir: MlxArray | null, ids: MlxArray | null,
  ): MlxArray {
    const L = h0.shape[1]!;
    let h = h0;

    // one mask per layer type, computed from the first cache of that type
    const masks = new Map<string, Mask>();
    for (let i = 0; i < this.numDonors; i++) {
      const type = this.layers[i]!.layerType;
      if (!masks.has(type)) {
        const window = type === "sliding_attention" ? this.windowSize : null;
        if (bidir && L > 1) {
          const c = cache[i]!;
          if (c.offset !== 0)
            throw new Error("bidirectional image masks require offset-0 prefill");
          masks.set(type, bidirMask(L, window, bidir));
        } else {
          masks.set(type, cache[i]!.makeMask(L, window));
        }
      }
    }

    // per-layer inputs (e2b/e4b)
    let perLayer: MlxArray | null = null;
    if (this.perLayerWidth > 0) {
      if (!ids) throw new Error("per-layer-input models require token ids");
      perLayer = this.computePerLayerInputs(ids, h);
    }

    const intermediates: (SharedKv | null)[] = Array(this.layers.length).fill(null);
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const ci = this.cacheIndex[i]!;
      const sharedIn = ci === -1 ? (intermediates[this.previousKvs[i]!] ?? null) : null;
      let pls: MlxArray | null = null;
      if (perLayer) {
        const t = this.config.text;
        pls = perLayer.slice([0, 0, i, 0], [1, L, i + 1, this.perLayerWidth]);
        const r = ops.reshape(pls, [1, L, this.perLayerWidth]);
        pls.dispose();
        pls = r;
      }
      const { h: next, shared } = layer.forward(
        h, masks.get(layer.layerType)!, ci === -1 ? null : cache[ci]!, sharedIn, pls,
      );
      pls?.dispose();
      h.dispose();
      h = next;
      intermediates[i] = shared;
    }
    perLayer?.dispose();
    // dispose donor-fetched KV (each donor's shared entry exactly once)
    for (let i = 0; i < this.numDonors; i++) {
      const s = intermediates[i];
      if (!s) continue;
      if (s.kind === "plain") {
        s.keys.dispose();
        s.values.dispose();
      } else {
        for (const t of [s.keys, s.values])
          for (const a of [t.packed, t.scales, t.biases]) a.dispose();
      }
    }
    for (const m of masks.values()) m.arr?.dispose();

    return disposing(h, this.finalNorm.forward(h));
  }

  /** hidden [1, L, hidden] → softcapped logits [1, L, vocab]. */
  logitsFromHidden(h: MlxArray): MlxArray {
    let logits = this.embed.asLinear(h);
    const softcap = this.config.text.finalLogitSoftcapping;
    if (softcap !== null) logits = disposing(logits, logitSoftcap(logits, softcap));
    return logits;
  }

  /** tokens → logits [1, L, vocab] (compat path used by parity tests). */
  forward(tokens: number[] | MlxArray, cache: Cache[]): MlxArray {
    const ids = Array.isArray(tokens)
      ? ops.fromInt32(tokens, [1, tokens.length])
      : tokens;
    const h = this.forwardHidden(ids, cache);
    if (Array.isArray(tokens)) ids.dispose();
    const logits = this.logitsFromHidden(h);
    h.dispose();
    return logits;
  }

  /** Greedy generation (parity harness); returns generated token ids. */
  generate(promptTokens: number[], maxTokens: number, eosIds: number[] = []): number[] {
    const cache = this.makeCache();
    const out: number[] = [];
    try {
      let tokens = promptTokens;
      for (let step = 0; step < maxTokens; step++) {
        const logits = this.forward(tokens, cache);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        if (eosIds.includes(next)) break;
        out.push(next);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
    return out;
  }
}

/** Causal(+window) mask OR'd with image×image bidirectional attention. */
function bidirMask(L: number, windowSize: number | null, bidir: MlxArray): Mask {
  const causal = createCausalMask(L, 0, windowSize);
  const col = ops.reshape(bidir, [L, 1]);
  const row = ops.reshape(bidir, [1, L]);
  const outer = ops.logicalAnd(col, row);
  col.dispose();
  row.dispose();
  const allow = ops.logicalOr(causal, outer);
  causal.dispose();
  outer.dispose();
  return { mode: "array", arr: allow };
}

/** tanh(x / cap) * cap with weak-scalar semantics. */
function logitSoftcap(logits: MlxArray, cap: number): MlxArray {
  const capArr = ops.scalarLike(cap, logits);
  const scaled = ops.div(logits, capArr);
  const t = ops.tanh(scaled);
  scaled.dispose();
  const out = ops.mul(t, capArr);
  t.dispose();
  capArr.dispose();
  return out;
}

/** argmax over vocab at the last sequence position of [1, L, V]. */
export function argmaxLastPosition(logits: MlxArray): number {
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]);
  const am = ops.argmaxAxis(last, -1);
  const id = ops.itemUint32(am);
  last.dispose();
  am.dispose();
  return id;
}

/** Last-position logits as f32 (for the parity harness). */
export function lastPositionLogits(logits: MlxArray): Float32Array {
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]);
  const f32 = last.toFloat32();
  last.dispose();
  return f32;
}
