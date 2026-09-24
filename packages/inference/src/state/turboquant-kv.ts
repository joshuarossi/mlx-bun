import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache,KvDonorAttention,KvDonorRows,Mask,RotatedValueAttentionState } from "../contracts/mlx/cache";
import type { KvCodec } from "../contracts/mlx/kv-codec";
import * as tq from "../kernels/turboquant/ops";
import { createCausalMask } from "../kernels/attention/masks";
import { decodedKvDonorAttention } from "./decoded-kv-donor";
import { KVCache } from "./kv";
import { RotatingKVCache } from "./rotating-kv";
import { TurboQuantCodec,disposeTurboQuant,turboQuantFusedDecode,type TurboQuantTensor } from "./turboquant-codec";


/** TurboQuant KV cache — v1 (docs/design/turboquant.md): dequantize-
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
  minimumReusableOffset = 0;
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
  /** Experimental operation selection, captured once for this cache. */
  readonly #codec: KvCodec<TurboQuantTensor>;

  constructor(readonly kBits: number, readonly vBits: number,
    readonly fusedDecode = turboQuantFusedDecode()) {
    this.#codec = new TurboQuantCodec(kBits, vBits, fusedDecode);
  }

  captureDonorRows(): KvDonorRows {
    if (!this.#kv || this.#headDim === null) throw new Error("cache is empty");
    const [keys, values] = this.#decode(this.#kv, this.offset, this.#headDim, false);
    const B = keys.shape[0]!;
    return { keys, values, offsets: Array(B).fill(this.offset),
      starts: Array(B).fill(0), ends: Array(B).fill(this.offset) };
  }
  captureDonorAttention(): KvDonorAttention { return decodedKvDonorAttention(this.captureDonorRows()); }

  get rotatedValueAttention(): RotatedValueAttentionState { return this; }
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

  #encode(k: MlxArray, v: MlxArray): TurboQuantTensor { return this.#codec.encode(k, v); }
  #decode(t: TurboQuantTensor, upTo: number, headDim: number, deferV = false): [MlxArray, MlxArray] {
    return this.#codec.decode(t, upTo, headDim, deferV);
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
    q.minimumReusableOffset = (cache as Cache).minimumReusableOffset ?? 0;
    cache.dispose();
    return q;
  }

  dispose(): void {
    if (this.#kv) disposeTurboQuant(this.#kv);
    this.#kv = null;
    this.offset = 0;
    this.minimumReusableOffset = 0;
  }
}
