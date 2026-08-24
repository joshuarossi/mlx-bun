// gemma4-base — the config-INDEPENDENT machinery shared by every
// architecture variant (docs/design/optimization_plan.md Phase B: pure code
// movement out of the gemma4.ts monolith; every definition here is
// verbatim from it). Cache classes, quantized-KV SDPA, masks, the
// quantized primitives + LoRA machinery, and small graph helpers live
// here; everything that branches on architecture (Attention, MLP, MoE,
// DecoderLayer, Gemma4Model) stays in gemma4.ts and becomes the
// per-model generated code in Phase C.

import type { ModelConfig } from "../config";
import { quantFor } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { expertOffloadArray } from "../expert-offload";
import * as tq from "../mlx/turboquant-ops";
import { runtimeValue } from "../runtime-config";

export type MaskMode = "" | "causal";
export interface Mask {
  mode: MaskMode | "array";
  arr: MlxArray | null;
  /** True when `arr` is exactly the bottom-right-aligned causal matrix
   *  (offset continuation, no window) — the case where mlx-lm would
   *  have handed the string "causal" instead. Only these array masks
   *  are eligible for the fused tiled SDPA: the optiq wrapper falls
   *  back to unfused on every array mask, and window/bidir masks must
   *  match that to stay scenario-bit-exact (Phase 9 finding). */
  causalEquivalent?: boolean;
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
  /** Training-only LoRA-input dropout. `rate` is the drop probability; `seed` is
   *  set per micro-step by the trainer and is CONSTANT across that step's forward
   *  and any recompute (segmented / gradient-checkpoint), so each layer's mask —
   *  keyed by (seed, the linear's dropoutId) — is reproduced exactly in the
   *  backward. `seed === null` (the default, and for inference) disables it. */
  dropoutRate = 0;
  dropoutSeed: number | null = null;
}

/** Replaceable quantized payload. Inference sees this as read-only through
 *  QuantizedLinear getters; sensitivity analysis exchanges it atomically. */
export interface QuantizedLinearState {
  w: MlxArray;
  scales: MlxArray;
  biases: MlxArray | null;
  spec: ops.QuantSpec;
}

/** Inverted LoRA-input dropout, keyed by (seed, id) so it is deterministic —
 *  the same (seed, id, shape) reproduces the mask, which is what makes the
 *  segmented / gradient-checkpoint recompute correct. kept ⇒ x/(1-p),
 *  dropped ⇒ 0 (preserves the expectation). Caller owns the result. */
export function loraInputDropout(x: MlxArray, p: number, seed: number, id: number): MlxArray {
  const key = ops.randomKey(BigInt(seed) * 100003n + BigInt(id));
  const u = ops.randomUniform(x.shape, Dtype.float32, 0, 1, key); // [shape] in [0,1)
  key.dispose();
  const pArr = ops.scalarLike(p, u);
  const keep = ops.less(pArr, u); // u > p ⇒ keep (bool [shape])
  const scaleX = ops.scalarLike(1 / (1 - p), x);
  const zeroX = ops.scalarLike(0, x);
  const mask = ops.where(keep, scaleX, zeroX); // x.dtype
  const xd = ops.mul(x, mask);
  for (const a of [u, pArr, keep, scaleX, zeroX, mask]) a.dispose();
  return xd;
}

export class QuantizedLinear {
  /** Mounted adapters keyed by id (null until first mount — fast path). */
  adapters: Map<string, LoraWeights> | null = null;
  /** Shared per-model active state (wired by AdapterManager.mount). */
  loraState: LoraState | null = null;
  /** Stable per-target index for keying training-only LoRA dropout (set by
   *  attachForTraining). Gives each adapted linear an independent dropout mask. */
  dropoutId = 0;
  private _w: MlxArray;
  private _scales: MlxArray;
  private _biases: MlxArray | null;
  private _spec: ops.QuantSpec;

  constructor(
    w: MlxArray,
    scales: MlxArray,
    biases: MlxArray | null,
    spec: ops.QuantSpec,
    /** ADDITIVE bias term (`.bias`, mlx nn.QuantizedLinear's optional bias —
     *  qwen2 qkv, starcoder2, …). Distinct from `biases`, the quantization
     *  zero-points. Applied after the matmul, before any LoRA residual,
     *  exactly like mlx's QuantizedLinear.__call__. */
    readonly bias: MlxArray | null = null,
  ) {
    this._w = w;
    this._scales = scales;
    this._biases = biases;
    this._spec = spec;
  }

  get w(): MlxArray { return this._w; }
  get scales(): MlxArray { return this._scales; }
  get biases(): MlxArray | null { return this._biases; }
  get spec(): ops.QuantSpec { return this._spec; }

  /** Atomically install a quantized payload and return the previous one.
   *  This is the sole mutation capability used by sensitivity sweeps. */
  exchangeQuantizedState(next: QuantizedLinearState): QuantizedLinearState {
    const previous = {
      w: this._w,
      scales: this._scales,
      biases: this._biases,
      spec: this._spec,
    };
    this._w = next.w;
    this._scales = next.scales;
    this._biases = next.biases;
    this._spec = next.spec;
    return previous;
  }

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
      weights.has(`${path}.bias`) ? weights.tensor(`${path}.bias`) : null,
    );
  }

  /** (in_features, out_features) from the quantized tensors (reference
   *  _infer_linear_shape: scales are [out, in/group_size]). */
  get inFeatures(): number {
    return this._scales.shape[1]! * this._spec.groupSize;
  }
  get outFeatures(): number {
    return this._scales.shape[0]!;
  }

  forward(x: MlxArray): MlxArray {
    let out = ops.quantizedMatmul(
      x,
      this._w,
      this._scales,
      this._biases,
      this._spec,
      true,
    );
    // Additive bias (mlx QuantizedLinear: `x = x + self["bias"]`), before
    // the LoRA residual (LoRALinear calls the base linear bias-inclusive).
    if (this.bias) out = disposing(out, ops.add(out, this.bias));
    // LoRA residual — composition is mlx-lm LoRALinear / optiq apply.py:
    //   y + (scale · ((x @ A) @ B)).astype(x.dtype)
    // (optiq mount.py omits the astype, leaking the f32 residual into the
    // bf16 stream — divergence documented in PLAN Phase 8 findings; the
    // cast form is what the adapters were trained behind.)
    const st = this.loraState;
    if (st && st.active.length > 0 && this.adapters && this.adapters.size > 0) {
      // Training-only LoRA-input dropout (PEFT applies dropout to x before A;
      // the base quantized path is untouched). Keyed by (seed, dropoutId) so the
      // backward recompute reproduces the exact mask.
      let xLora = x;
      let xDrop: MlxArray | null = null;
      if (st.dropoutSeed !== null && st.dropoutRate > 0) {
        xDrop = loraInputDropout(x, st.dropoutRate, st.dropoutSeed, this.dropoutId);
        xLora = xDrop;
      }
      for (const id of st.active) {
        const lw = this.adapters.get(id);
        if (!lw) continue;
        const xa = ops.matmul(xLora, lw.a);
        const z = ops.matmul(xa, lw.b);
        xa.dispose();
        const zs = ops.mulScalar(z, lw.scale);
        z.dispose();
        const zc = zs.astype(x.dtype);
        zs.dispose();
        out = disposing(out, ops.add(out, zc));
        zc.dispose();
      }
      xDrop?.dispose();
    }
    return out;
  }
}

export class RMSNorm {
  constructor(readonly weight: MlxArray | null, readonly eps: number) {}
  forward(x: MlxArray): MlxArray {
    return ops.rmsNorm(x, this.weight, this.eps);
  }
}

export class QuantizedEmbedding {
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
 *  speculative drafter). Owned by forwardLayers for the pass.
 *  `offsetArr` is set only under compiled decode (trace adapters): the
 *  RoPE offset as an array VALUE so the compiled graph replays at any
 *  position (see src/model/compiled-decode.ts). */
export type SharedKv =
  | { kind: "plain"; keys: MlxArray; values: MlxArray; offset: number;
      offsetArr?: MlxArray;
      /** TurboQuant deferred-V: `values` are still in the rotated (FWHT)
       *  domain — every consumer must un-rotate its attention OUTPUT
       *  (tq.unrotateValues) after sdpa. Attention is linear in V, so the
       *  result is the same decode, just transformed once per query row
       *  instead of once per cached token. */
      vRotated?: boolean }
  | { kind: "quant"; keys: ops.QuantizedTensor; values: ops.QuantizedTensor;
      offset: number; groupSize: number; bits: number; offsetArr?: MlxArray };

export interface Cache {
  offset: number;
  /** Stable storage identity for compatibility guards and persistence. */
  signature?(): string;
  /** Physical cache storage consumed by one additional token for one row.
   *  Recurrent caches return 0 because their state does not grow with the
   *  sequence. Optional for stateless/training adapters that are never
   *  admitted or persisted. */
  bytesPerToken?(): number;
  /** state() returned temporary views that the caller must release. */
  readonly stateNeedsDispose?: boolean;
  /** Compiled-decode trace adapters expose the RoPE offset as an int32
   *  array input here; real caches leave it unset (static int path). */
  readonly ropeOffsetArr?: MlxArray;
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
  /** Mask for an N-token step given this cache's state. */
  makeMask(N: number, windowSize: number | null): Mask;
  state(): MlxArray[];
  /** Can `trim(n)` drop the last n tokens? (Ring caches lose trimability
   *  once wrapped.) */
  isTrimmable(): boolean;
  /** Drop the last n tokens (future writes overwrite them). `bypass` (default
   *  false → unchanged behavior) skips the isTrimmable guard for the
   *  speculative-decode rollback case (trim the last n ≤ γ tips right after a
   *  >1 concat write); rotating caches then physically shrink the buffer tail. */
  trim(n: number, bypass?: boolean): void;
  /** Speculative verify-round support for NON-trimmable recurrent caches
   *  (SSMCache — gated-DeltaNet conv + recurrent state). A cache exposing
   *  these is spec-eligible without isTrimmable(): the serve loop arms a
   *  round before the verify forward (the layer snapshots pre-round state —
   *  free, MLX arrays are immutable — and records its position-local kernel
   *  inputs), then resolves it: commit on full accept, or rollback(keep)
   *  which restores the snapshot and bit-exactly REPLAYS the first `keep`
   *  window tokens through the recurrence (identical arithmetic prefix ⇒
   *  identical state). Trimmable caches leave these unset and keep trim(). */
  specRoundBegin?(): void;
  specRoundCommit?(): void;
  specRoundRollback?(keep: number): void;
  dispose(): void;
}

export function cacheSignature(cache: Cache | undefined): string {
  return cache?.signature?.() ?? "unknown";
}

export interface RowBatchCache extends Cache {
  readonly batchSize: number;
  filterRows(keep: readonly number[]): void;
  extractRow(row: number): Cache | null;
}

export function isRowBatchCache(cache: Cache): cache is RowBatchCache {
  const candidate = cache as Partial<RowBatchCache>;
  return typeof candidate.batchSize === "number" &&
    typeof candidate.filterRows === "function" &&
    typeof candidate.extractRow === "function";
}

export function isPlainKvCache(cache: Cache | undefined): cache is KVCache {
  return cacheSignature(cache) === "kv:plain";
}

export function isQuantizedKvCache(cache: Cache | undefined): cache is QuantizedKVCache {
  return cacheSignature(cache).startsWith("kv:quant:");
}

export function isRotatingPlainCache(cache: Cache | undefined): cache is RotatingKVCache {
  return cacheSignature(cache) === "kv:rotating-plain";
}

export function isRotatingQuantizedCache(
  cache: Cache | undefined,
): cache is RotatingQuantizedKVCache {
  return cacheSignature(cache).startsWith("kv:rotating-quant:");
}

/**
 * Capability contract for cache layouts that own their dynamic-row batching.
 * The scheduler uses this for non-K/V state families (for example GLM's
 * compressed MLA/DSA state) instead of teaching the scheduler their tensor
 * layout. `mergeRows` writes into an empty cache and does not consume inputs;
 * extracted rows are independent owned caches.
 */
export interface BatchableCache extends Cache {
  readonly batchSize: number | null;
  readonly rowOffsets: readonly number[];
  readonly leftPad: readonly number[];
  readonly maxTokens?: number;
  makeEmptyBatch(): BatchableCache;
  mergeRows(rows: readonly Cache[]): void;
  extractRow(row: number): Cache;
  filterRows(keep: readonly number[]): void;
  projectedBytes(tokens: number): number;
}

export function isBatchableCache(cache: Cache): cache is BatchableCache {
  const candidate = cache as Partial<BatchableCache>;
  return (
    typeof candidate.makeEmptyBatch === "function" &&
    typeof candidate.mergeRows === "function" &&
    typeof candidate.extractRow === "function" &&
    typeof candidate.filterRows === "function" &&
    typeof candidate.projectedBytes === "function" &&
    Array.isArray(candidate.rowOffsets) &&
    Array.isArray(candidate.leftPad)
  );
}

/** How one decode step interacts with a cache under compiled decode
 *  (returned by prepareDecodeStep, consumed by compiled-decode.ts):
 *  - "concat": the compiled graph fetches concat(active prefix, new kv)
 *    — same values as today's write-then-slice — and the WRITE happens
 *    outside the graph right after (writeDecodeStep), keeping the buffer
 *    single-referenced at its slice_update so mlx donates it in place.
 *  - "ring": the write happens IN-graph (slice_update_dynamic at
 *    writePos) and the fetch is the full updated buffer — the rotating
 *    steady state, where attention reads the whole ring in ring order
 *    (a concat would permute KV positions and change summation order).
 *    The updated buffers come back as closure outputs; adoptDecodeStep
 *    swaps them in. */
export interface DecodeStepPlan {
  fetch: "concat" | "ring";
  /** Write position on axis 2 (== ring index for rotating caches). */
  writePos: number;
  /** Valid prefix length for "concat" fetches (== offset). */
  activeLen: number;
}

/** KV cache — port of mlx-lm cache.py KVCache: preallocated in steps of
 *  256 along the sequence axis, updated in place via slice_update. */
export class KVCache implements Cache {
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache). */
  readonly ropeOffsetArr?: MlxArray;
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;

  signature(): string { return "kv:plain"; }

  bytesPerToken(): number {
    const steps = this.keys?.shape[2] ?? 0;
    return steps > 0 ? (this.keys!.nbytes + this.values!.nbytes) / steps : 0;
  }

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
    // Windowless multi-token chunks get the STRING "causal" at ANY offset —
    // mlx-lm cache.py:114-125 create_attention_mask does exactly this, and
    // mx.fast SDPA aligns the string bottom-right, i.e. the same values as
    // our materialized matrix. Shipping the array instead (the old
    // offset>0 branch) forced a materialize-and-add mask path: a bool
    // [N, offset+N] built PER CHUNK and read by every full-attention layer
    // — the e4b 16k prefill gap vs mlx-lm (2026-07-06b, hd=512 layers
    // where the fallback dispatch can't block-skip an array mask).
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && N <= windowSize) return { mode: "causal", arr: null };
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

  /** Compiled decode: host-side bookkeeping for a 1-token step — the
   *  growth/trim half of updateAndFetch (L=1), without the write. */
  prepareDecodeStep(): DecodeStepPlan {
    const prev = this.offset;
    if (!this.keys || !this.values) throw new Error("compiled decode on an empty cache");
    if (prev + 1 > this.keys.shape[2]!) {
      const [B, H, , D] = this.keys.shape as [number, number, number, number];
      const vD = this.values.shape[3]!;
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
      const newK = ops.zeros([B, H, KVCache.STEP, D], oldK.dtype);
      const newV = ops.zeros([B, H, KVCache.STEP, vD], oldV.dtype);
      this.keys = ops.concatAxis([oldK, newK], 2);
      this.values = ops.concatAxis([oldV, newV], 2);
      for (const a of [oldK, oldV, newK, newV]) a.dispose();
    }
    return { fetch: "concat", writePos: prev, activeLen: prev };
  }

  /** Compiled decode: the write half (same sliceUpdate as updateAndFetch).
   *  Takes ownership of kNew/vNew; returns the arrays to async-eval with
   *  the step (the updated buffers). */
  writeDecodeStep(kNew: MlxArray, vNew: MlxArray): MlxArray[] {
    const prev = this.offset;
    const [B, H, , D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    const k2 = ops.sliceUpdate(this.keys!, kNew, [0, 0, prev, 0], [B, H, prev + 1, D]);
    const v2 = ops.sliceUpdate(this.values!, vNew, [0, 0, prev, 0], [B, H, prev + 1, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    kNew.dispose();
    vNew.dispose();
    this.keys = k2;
    this.values = v2;
    this.offset = prev + 1;
    return [k2, v2];
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
  /** Set only by compiled-decode trace adapters (see Cache). */
  readonly ropeOffsetArr?: MlxArray;
  keys: ops.QuantizedTensor | null = null;
  values: ops.QuantizedTensor | null = null;
  offset = 0;

  constructor(readonly groupSize: number, readonly bits: number) {}

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

/** Rotating (sliding-window) KV cache — port of mlx-lm RotatingKVCache
 *  with keep=0 (gemma4's configuration): a ring buffer of max_size
 *  entries, so decode attends over at most the window. RoPE offsets use
 *  the true position; masks use the buffer-clamped offset. */
export class RotatingKVCache implements Cache {
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

export const mapTriple = (
  t: ops.QuantizedTensor, f: (a: MlxArray) => MlxArray,
): ops.QuantizedTensor => ({ packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) });

export const disposeTriple = (t: ops.QuantizedTensor): void => {
  t.packed.dispose();
  t.scales.dispose();
  t.biases.dispose();
};

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

/** One TurboQuant-encoded (K, V) storage tuple — the 5 arrays kv-store.ts
 *  and toQuantized/fromKVCache pass around. Not `ops.QuantizedTensor`
 *  (mlx's affine int4/int8 scheme): this is the rotation + Lloyd-Max
 *  layout (docs/design/turboquant-kv.md), asymmetric-affine for keys,
 *  FWHT+Lloyd-Max for values. Field order is the kv-store.ts tensor-slot
 *  contract — do not reorder without updating snapshotCache/loadKvCache. */
export interface TurboQuantTensor {
  kIdx: MlxArray;
  kScales: MlxArray;
  kZeros: MlxArray;
  vPacked: MlxArray;
  vScales: MlxArray;
}

export const disposeTurboQuant = (t: TurboQuantTensor): void => {
  t.kIdx.dispose();
  t.kScales.dispose();
  t.kZeros.dispose();
  t.vPacked.dispose();
  t.vScales.dispose();
};

/** TurboQuant KV cache — v1 (docs/design/turboquant-kv.md): dequantize-
 *  on-fetch. Deliberately does NOT subclass KVCache/RotatingKVCache (or
 *  QuantizedKVCache) — a novel class fails every generated-file
 *  `#matches()` guard and every batching `instanceof` allow-list, so it
 *  gets solo-only routing and monolith fallback for free, the same way
 *  QuantizedKVCache does today. Only full-attention (non-rotating)
 *  layers use this in v1; sliding-window layers stay bf16.
 *
 *  Storage: 5 arrays per the vllm-metal reference's `turbo_quant_encode`
 *  tuple — kIdx (int8 unpacked at kBits=8, else bit-packed uint8),
 *  kScales/kZeros (fp16, one pair per 32-group), vPacked (bit-packed
 *  uint8, no-op at vBits=8), vScales (fp16, one per 32-group).
 *  updateAndFetch quantizes ONLY the newly appended tokens (unlike
 *  QuantizedKVCache's whole-buffer-toQuantized conversion path — the
 *  streaming append is the whole point of a live cache) and returns the
 *  DEQUANTIZED bf16 active window so ops.sdpa runs unmodified — v1 pays
 *  a full-window dequant every step; the deferred-InvFWHT trick is a
 *  documented non-goal until the quality gate passes. */
export class TurboQuantKVCache implements Cache {
  readonly stateNeedsDispose = true;
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache) — TurboQuant
   *  is not a compiled-decode participant in v1 (novel class, monolith
   *  fallback only), so this is always unset; captured once per step by
   *  construction, never refreshed mid-step (batched-rotating-quant.ts:55-63). */
  readonly ropeOffsetArr?: MlxArray;
  #kv: TurboQuantTensor | null = null;
  offset = 0;
  /** Validated lazily on first update, once head_dim is known. */
  #headDim: number | null = null;

  constructor(readonly kBits: number, readonly vBits: number) {}

  signature(): string { return `kv:turboquant:${this.kBits}:${this.vBits}`; }

  bytesPerToken(): number {
    const steps = this.#seqLen();
    if (steps === 0 || !this.#kv) return 0;
    return [
      this.#kv.kIdx, this.#kv.kScales, this.#kv.kZeros,
      this.#kv.vPacked, this.#kv.vScales,
    ].reduce((bytes, array) => bytes + array.nbytes, 0) / steps;
  }

  get headDim(): number | null {
    return this.#headDim;
  }

  #validateHeadDim(dim: number): void {
    if (this.#headDim !== null) return;
    const supported = [64, 128, 256, 512];
    if (dim % 32 !== 0 || !supported.includes(dim)) {
      throw new Error(
        `TurboQuantKVCache: head_dim ${dim} must be divisible by 32 and in {${supported.join(",")}}`,
      );
    }
    this.#headDim = dim;
  }

  #packedKDim(dim: number): number {
    return tq.packedDim(dim, this.kBits);
  }
  #packedVDim(dim: number): number {
    return tq.packedDim(dim, this.vBits);
  }
  #nGroups(dim: number): number {
    return dim / tq.TURBOQUANT_BLOCK_SIZE;
  }

  #alloc(B: number, H: number, T: number, dim: number): TurboQuantTensor {
    const kIdxDtype = this.kBits === 8 ? Dtype.int8 : Dtype.uint8;
    return {
      kIdx: ops.zeros([B, H, T, this.#packedKDim(dim)], kIdxDtype),
      kScales: ops.zeros([B, H, T, this.#nGroups(dim)], Dtype.float16),
      kZeros: ops.zeros([B, H, T, this.#nGroups(dim)], Dtype.float16),
      vPacked: ops.zeros([B, H, T, this.#packedVDim(dim)], Dtype.uint8),
      vScales: ops.zeros([B, H, T, this.#nGroups(dim)], Dtype.float16),
    };
  }

  #seqLen(): number {
    return this.#kv ? this.#kv.kIdx.shape[2]! : 0;
  }

  /** Encode k/v [B,H,L,D] into a fresh TurboQuantTensor (packed at rest). */
  #encode(k: MlxArray, v: MlxArray): TurboQuantTensor {
    const signed = this.kBits === 8;
    const kEnc = tq.encodeKeys(k, this.kBits, signed);
    const kIdxPacked = this.kBits < 8 ? tq.packBits(kEnc.indices, this.kBits) : kEnc.indices;
    if (kIdxPacked !== kEnc.indices) kEnc.indices.dispose();
    const vEnc = tq.encodeValues(v, this.vBits);
    const vIdxPacked = this.vBits < 8 ? tq.packBits(vEnc.indices, this.vBits) : vEnc.indices;
    if (vIdxPacked !== vEnc.indices) vEnc.indices.dispose();
    return {
      kIdx: kIdxPacked, kScales: kEnc.scales, kZeros: kEnc.zeros,
      vPacked: vIdxPacked, vScales: vEnc.scales,
    };
  }

  /** Decode a TurboQuantTensor's active [B,H,upTo,*] window back to
   *  bf16 [B,H,upTo,headDim] (k, v). Caller owns the returned arrays.
   *  deferV leaves V in the rotated domain (decodeValuesRotated) — the
   *  caller un-rotates its attention output instead (tq.unrotateValues). */
  #decode(t: TurboQuantTensor, upTo: number, headDim: number, deferV = false): [MlxArray, MlxArray] {
    const cut = (a: MlxArray): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      return a.slice([0, 0, 0, 0], [B, H, upTo, D]);
    };
    const kIdxCut = cut(t.kIdx);
    const kIdxUnpacked = this.kBits < 8 ? tq.unpackBits(kIdxCut, this.kBits, headDim) : kIdxCut;
    if (kIdxUnpacked !== kIdxCut) kIdxCut.dispose();
    const kScalesCut = cut(t.kScales);
    const kZerosCut = cut(t.kZeros);
    const k = tq.decodeKeys(kIdxUnpacked, kScalesCut, kZerosCut);
    for (const a of [kIdxUnpacked, kScalesCut, kZerosCut]) a.dispose();

    const vPackedCut = cut(t.vPacked);
    const vIdxUnpacked = this.vBits < 8 ? tq.unpackBits(vPackedCut, this.vBits, headDim) : vPackedCut;
    if (vIdxUnpacked !== vPackedCut) vPackedCut.dispose();
    const vScalesCut = cut(t.vScales);
    const v = deferV
      ? tq.decodeValuesRotated(vIdxUnpacked, vScalesCut, this.vBits)
      : tq.decodeValues(vIdxUnpacked, vScalesCut, this.vBits);
    for (const a of [vIdxUnpacked, vScalesCut]) a.dispose();

    return [k, v];
  }

  /** Quantize the newly-appended k/v, append into growable packed
   *  storage (256-step growth, mirroring KVCache), advance offset, then
   *  dequantize the WHOLE active window (v1 semantics) so the standard
   *  ops.sdpa path runs unmodified. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const D = this.#append(k, v);
    return this.#decode(this.#kv!, this.offset, D);
  }

  /** Deferred-inverse-FWHT read path: same append, but the returned V
   *  window stays in the ROTATED domain. The caller MUST un-rotate its
   *  attention output with tq.unrotateValues (see SharedKv.vRotated) —
   *  same decode by linearity, O(q·d log d) per step instead of
   *  O(T·d log d). Opt-in per attention site; sites that don't know about
   *  rotation keep calling updateAndFetch and stay correct. */
  updateAndFetchDeferredV(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const D = this.#append(k, v);
    return this.#decode(this.#kv!, this.offset, D, true);
  }

  /** Shared append: grow storage, encode the new tokens, slice-write them
   *  at the previous offset, advance offset. Returns head_dim. */
  #append(k: MlxArray, v: MlxArray): number {
    const [B, H, L, D] = k.shape as [number, number, number, number];
    this.#validateHeadDim(D);
    const prev = this.offset;

    if (!this.#kv || prev + L > this.#seqLen()) {
      const nSteps = Math.floor((TurboQuantKVCache.STEP + L - 1) / TurboQuantKVCache.STEP);
      const newSteps = nSteps * TurboQuantKVCache.STEP;
      if (this.#kv && prev % TurboQuantKVCache.STEP !== 0) {
        const trimTo = (t: TurboQuantTensor): TurboQuantTensor => {
          const cut = (a: MlxArray): MlxArray => {
            const [b, h, , d] = a.shape as [number, number, number, number];
            const s = a.slice([0, 0, 0, 0], [b, h, prev, d]);
            a.dispose();
            return s;
          };
          return { kIdx: cut(t.kIdx), kScales: cut(t.kScales), kZeros: cut(t.kZeros),
            vPacked: cut(t.vPacked), vScales: cut(t.vScales) };
        };
        this.#kv = trimTo(this.#kv);
      }
      const grown = this.#alloc(B, H, newSteps, D);
      if (this.#kv) {
        const cat = (a: MlxArray, b: MlxArray): MlxArray => {
          const out = ops.concatAxis([a, b], 2);
          a.dispose();
          b.dispose();
          return out;
        };
        this.#kv = {
          kIdx: cat(this.#kv.kIdx, grown.kIdx),
          kScales: cat(this.#kv.kScales, grown.kScales),
          kZeros: cat(this.#kv.kZeros, grown.kZeros),
          vPacked: cat(this.#kv.vPacked, grown.vPacked),
          vScales: cat(this.#kv.vScales, grown.vScales),
        };
      } else {
        this.#kv = grown;
      }
    }

    this.offset += L;
    const enc = this.#encode(k, v);
    const write = (dst: MlxArray, src: MlxArray): MlxArray => {
      const [b, h, , d] = dst.shape as [number, number, number, number];
      const u = ops.sliceUpdate(dst, src, [0, 0, prev, 0], [b, h, this.offset, d]);
      dst.dispose();
      src.dispose();
      return u;
    };
    this.#kv = {
      kIdx: write(this.#kv!.kIdx, enc.kIdx),
      kScales: write(this.#kv!.kScales, enc.kScales),
      kZeros: write(this.#kv!.kZeros, enc.kZeros),
      vPacked: write(this.#kv!.vPacked, enc.vPacked),
      vScales: write(this.#kv!.vScales, enc.vScales),
    };

    return D;
  }

  /** Same rule as KVCache/QuantizedKVCache.makeMask (mlx-lm cache.py:114-125):
   *  windowless multi-token chunks are the string "causal" at any offset —
   *  TurboQuant v1 is full-attention-only, never windowed. */
  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && N <= windowSize) return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Trimmed-to-offset arrays in documented order: kIdx, kScales, kZeros,
   *  vPacked, vScales (kv-store.ts tensor-slot ordering for kind
   *  "turboquant"). Empty cache → []. */
  state(): MlxArray[] {
    if (!this.#kv) return [];
    const cut = (a: MlxArray): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      return a.slice([0, 0, 0, 0], [B, H, this.offset, D]);
    };
    return [cut(this.#kv.kIdx), cut(this.#kv.kScales), cut(this.#kv.kZeros),
      cut(this.#kv.vPacked), cut(this.#kv.vScales)];
  }

  isTrimmable(): boolean {
    return true;
  }

  /** Drop the last n tokens (byte-safe: groups run along head_dim, so a
   *  token-axis slice never splits a group). Same front/back convention
   *  as KVCache.trim: offset shrinks, storage is overwritten on next write. */
  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
  }

  /** Adopt persisted/converted state (takes ownership of the arrays). */
  restoreState(t: TurboQuantTensor, offset: number, headDim: number): void {
    this.dispose();
    this.#kv = t;
    this.offset = offset;
    this.#headDim = headDim;
  }

  /** Convert an existing bf16 KVCache/RotatingKVCache's live window in one
   *  shot: quantize the whole [.., :offset, :] region, preserve offset,
   *  dispose the source's arrays. Mirrors KVCache.toQuantized/
   *  RotatingKVCache.toQuantized's contract (source cache is consumed). */
  static fromKVCache(cache: KVCache | RotatingKVCache, kBits: number, vBits: number): TurboQuantKVCache {
    const q = new TurboQuantKVCache(kBits, vBits);
    const [k, v] = cache.keys && cache.values ? cache.temporalView() : [null, null];
    if (k && v) {
      const D = k.shape[3]!;
      q.#validateHeadDim(D);
      const enc = q.#encode(k, v);
      k.dispose();
      v.dispose();
      q.#kv = enc;
      q.#headDim = D;
    }
    q.offset = cache.offset;
    cache.dispose();
    return q;
  }

  dispose(): void {
    if (this.#kv) disposeTurboQuant(this.#kv);
    this.#kv = null;
    this.offset = 0;
  }
}

export const FINFO_MIN: Partial<Record<Dtype, number>> = {
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

  // scale is 1.0 for Gemma4 (q/k are RMS-normed) — skip the identity multiply.
  let queries = q;
  const owned: MlxArray[] = [];
  if (scale !== 1.0) { queries = ops.mulScalar(q, scale); owned.push(queries); }

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
    // Batched padding masks are [B,1,L,S] (buildBatchedDecodeMask). When GQA
    // reshaped the scores to 5-D [B,KV,nRep,L,S], trailing-dim broadcasting
    // would misalign the mask's B with KV — insert the unit axis explicitly:
    // [B,1,1,L,S] broadcasts correctly over (KV, nRep).
    if (maskArr && maskArr.ndim === 4 && nRep > 1) {
      maskArr = ops.expandDims(maskArr, 1);
      ownsMask = true;
    }
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

  // scale is 1.0 for Gemma4 (q/k are RMS-normed) — skip the identity multiply.
  let queries = q;
  let ownsQueries = false;
  if (scale !== 1.0) { queries = ops.mulScalar(q, scale); ownsQueries = true; }

  let kT = kq;
  let vT = vq;
  const expanded: MlxArray[] = [];
  if (nRep > 1) {
    const qr = ops.reshape(queries, [B, KV, nRep, L, D]);
    if (ownsQueries) queries.dispose();
    queries = qr;
    ownsQueries = true;
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
  // Under a compiled-decode trace, subrange Slice swaps to DynamicSlice
  // (identical values; shapeless compile rejects Slice — same pattern as
  // the per-layer-input and MoE top-k slices).
  const sliceAxis = (a: MlxArray, axisFromEnd: 1 | 2, n0: number, n1: number): MlxArray => {
    const dims = a.shape;
    const axis = dims.length - axisFromEnd;
    if (isCompiledTrace()) {
      const start = ops.fromInt32([n0], [1]);
      const size = [...dims];
      size[axis] = n1 - n0;
      const out = ops.sliceDynamic(a, start, [axis], size);
      start.dispose();
      return out;
    }
    const start = dims.map(() => 0);
    const stop = [...dims];
    start[axis] = n0;
    stop[axis] = n1;
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
  if (ownsQueries) queries.dispose();
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
 *  "causal" string for windowless continuations (its make_mask returns
 *  "causal" even at offset > 0); our makeMask materializes the equivalent
 *  bool matrix — so masks flagged causalEquivalent tile too (the oracle's
 *  INNER function handles them with the same column slicing we use).
 *  Window/bidir array masks do NOT tile, matching the reference's
 *  scenario-level dispatch exactly (Phase 9: sliding-layer quantized
 *  prefill is unfused in optiq too). */
function fusedSdpaSupported(q: MlxArray, mask: Mask, groupSize: number, bits: number): boolean {
  // Escape hatch mirroring optiq serve's --no-fused-kv: forces the
  // stock unfused path everywhere. Also the A/B lever for
  // scripts/bench-levers.ts fused-prefill. Read per call (cheap next to the
  // FFI work) so tests and paired A/B harnesses can flip it in-process.
  if (runtimeValue("MLX_BUN_NO_FUSED_SDPA") === "1") return false;
  if (bits !== 4 && bits !== 8) return false;
  if (groupSize !== 32 && groupSize !== 64 && groupSize !== 128) return false;
  if (q.dtype !== Dtype.bfloat16 && q.dtype !== Dtype.float16) return false;
  if (mask.mode === "causal" || mask.mode === "") return true; // "" = oracle's mask=None
  if (mask.mode === "array")
    return mask.causalEquivalent === true && mask.arr !== null &&
      mask.arr.shape.length === 2 && mask.arr.dtype === Dtype.bool;
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
  const tile = q.shape[2]! > 1;
  if (tile && fusedSdpaSupported(q, mask, groupSize, bits)) {
    // The N-tiled loop CANNOT be traced: its tile count and slice extents
    // bake at trace-time N, so under shapeless replay a growing (concat-
    // phase) quantized cache's newest rows are silently never attended.
    // This throw is the backstop for any compiled caller — it lands in the
    // trace's transactional fallback instead of producing silently wrong
    // attention.
    if (isCompiledTrace())
      throw new Error(
        "quantizedSdpaTiled inside a compiled trace: the tile loop bakes trace-time N " +
          "(growing KV rows would be silently dropped) — run this generation uncompiled",
      );
    return quantizedSdpaTiled(q, kq, vq, scale, mask, groupSize, bits);
  }
  return quantizedSdpaUnfused(q, kq, vq, scale, mask, groupSize, bits);
}

/** The runtime-only half of fusedSdpaSupported (env flag, dtype, mask
 *  kind) — generated models (Phase D) bake the (bits, group_size) half
 *  as a compile-time constant and call this for the rest. The combined
 *  predicate is exactly fusedSdpaSupported. */
export function fusedSdpaRuntimeOk(q: MlxArray, mask: Mask): boolean {
  if (runtimeValue("MLX_BUN_NO_FUSED_SDPA") === "1") return false;
  if (q.dtype !== Dtype.bfloat16 && q.dtype !== Dtype.float16) return false;
  if (mask.mode === "causal" || mask.mode === "") return true;
  if (mask.mode === "array")
    return mask.causalEquivalent === true && mask.arr !== null &&
      mask.arr.shape.length === 2 && mask.arr.dtype === Dtype.bool;
  return false;
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
/** Port of switch_layers.QuantizedSwitchLinear (gather_qmm over stacked
 *  expert weights; rhs_indices selects the expert per row). */
export class QuantizedSwitchLinear {
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
    // Expert WEIGHT (the ~94% of expert bytes) comes from the page-aligned
    // offload mmap when --expert-offload is active (else resident); scales/
    // biases stay resident (small). Same bytes either way → bit-exact.
    const wName = `${path}.weight`;
    return new QuantizedSwitchLinear(
      expertOffloadArray(wName) ?? weights.tensor(wName),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  forward(x: MlxArray, indices: MlxArray, sortedIndices: boolean): MlxArray {
    return ops.gatherQmm(x, this.w, this.scales, this.biases, indices, this.spec, sortedIndices);
  }
}
/** Dispose `old` and return `next` — for h = disposing(h, op(h)) chains. */
export function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}

// Compiled-decode trace mode (set by compiled-decode.ts around its trace,
// which runs synchronously on the serialized generation queue — same
// safety argument as LoraState). Inside a shapeless-compiled graph, mlx's
// Slice primitive cannot re-infer output shapes, so the two subrange
// slices on the decode path (per-layer-input split, MoE top-k) swap to
// DynamicSlice — identical values, shapeless-safe — ONLY while tracing.
// The uncompiled path keeps the exact oracle op sequence.
let compiledTrace = false;
export function setCompiledTrace(v: boolean): void {
  compiledTrace = v;
}
export function isCompiledTrace(): boolean {
  return compiledTrace;
}
/** Causal(+window) mask OR'd with image×image bidirectional attention. */
export function bidirMask(L: number, windowSize: number | null, bidir: MlxArray): Mask {
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
export function logitSoftcap(logits: MlxArray, cap: number): MlxArray {
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
