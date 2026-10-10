// The quantized KV legos `--kv-quant N` composes: bf16 storage through the
// first append (or the first `start` tokens), quantized storage after. Today's
// served path and mlx-lm's generate loop both run the first forward against
// unquantized keys and values and convert afterwards, even with
// `quantized_kv_start` 0; these caches keep that order inside their own
// appends. A cache quantized from token zero (`QuantizedKVCache` built empty)
// is a different composition with different first-chunk numbers.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { clearCache } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionCache, AttentionRead, Cache, Mask } from "../contracts/mlx/cache";
import { unrotateValues } from "../kernels/turboquant/ops";
import { quantizedSdpa } from "../layers/quantized-attention";
import { AttentionMasks, causalLease, unmaskedLease, withLease, type MaskLease } from "./attention-read";
import { KVCache, type AffineKernelSet } from "./kv";
import { unfusedAffineKernels } from "./affine-attention";
import { QuantizedKVCache } from "./quantized-kv";
import { disposeTriple } from "./quantized-tensor";
import { RotatingKVCache, rotatingWindowMask } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";
import { TurboQuantKVCache } from "./turboquant-kv";

/** Whether bf16 storage holding `offset` positions converts under a
 * conversion start of `start` tokens: once it holds at least `start`
 * positions, and never while empty, so the first append is bf16 even when the
 * start is 0. The test `kv-maintenance` applies after each forward. */
export function transitionDue(offset: number, start: number): boolean {
  return offset >= start && offset !== 0;
}

/** Finish one conversion as `kv-maintenance` does: a nonzero start records the
 * converted `offset` (read before the source was consumed) as the earliest
 * reusable prefix, then the new storage is materialized and the allocator pool
 * released before anything else converts, which bounds the live bf16 source
 * plus quantized copy to one layer. Returns `converted`. */
export function completeConversion<C extends Cache>(converted: C, offset: number, start: number): C {
  if (start > 0) converted.minimumReusableOffset = offset;
  const state = converted.state();
  try { ops.evalAll(state); }
  finally { if (converted.stateNeedsDispose) for (const array of state) array.dispose(); }
  clearCache();
  return converted;
}

/** The affine conversion `kv-maintenance` performs on one entry: the source's
 * own `toQuantized` (which consumes the source) with the unfused kernels, then
 * the shared bookkeeping. */
export function convertToAffine<C extends Cache>(
  source: { readonly offset: number; toQuantized(groupSize: number, bits: number, kernels: AffineKernelSet): C },
  groupSize: number, bits: number, start: number,
): C {
  const offset = source.offset;
  return completeConversion(source.toQuantized(groupSize, bits, unfusedAffineKernels), offset, start);
}

/** The TurboQuant conversion `kv-maintenance` performs on one entry: encode
 * the source's live window (consuming the source), then the shared
 * bookkeeping. `fusedDecode` is the converted cache's decode policy. */
export function convertToTurboQuant(source: KVCache, kBits: number, vBits: number, start: number,
  fusedDecode: boolean): TurboQuantKVCache {
  const offset = source.offset;
  return completeConversion(TurboQuantKVCache.fromKVCache(source, kBits, vBits, fusedDecode), offset, start);
}

/** The affine read as the graphs compute it over quantized storage today: the
 * quantized append (`updateAndFetchQuantized`), then `quantizedSdpa` under the
 * mask. Takes ownership of `mask`.
 * TODO(B1b): the affine caches' own reads replace this, one call per phase. */
function affineRead(storage: QuantizedKVCache | RotatingQuantizedKVCache, k: MlxArray, v: MlxArray,
  mask: MaskLease): AttentionRead {
  return withLease(mask, held => {
    const [keys, values] = storage.updateAndFetchQuantized(k, v);
    const { groupSize, bits } = storage;
    return {
      attend: (q, scale) => quantizedSdpa(q, keys, values, scale, held.mask, groupSize, bits),
      dispose() { disposeTriple(keys); disposeTriple(values); held.release(); },
    };
  });
}

/** The TurboQuant read as the graphs compute it today: the deferred-V append,
 * the stock fused SDPA under the mask, then the inverse rotation of the output.
 * Takes ownership of `mask`. */
function turboQuantRead(storage: TurboQuantKVCache, k: MlxArray, v: MlxArray, mask: MaskLease): AttentionRead {
  return withLease(mask, held => {
    const [keys, values] = storage.updateAndFetchDeferredV(k, v);
    return {
      attend(q, scale) {
        const rotated = ops.sdpa(q, keys, values, scale, held.mask.mode, held.mask.arr);
        try { return unrotateValues(rotated); } finally { rotated.dispose(); }
      },
      dispose() { keys.dispose(); values.dispose(); held.release(); },
    };
  });
}

/** Deprecated reads have no meaning for a cache that owns its read. */
function ownsItsRead(): never {
  throw new Error("this cache owns its attention read: call appendDecode or appendWindow (contracts/mlx/cache.ts AttentionCache)");
}

/**
 * Affine-quantized keys and values for one full-attention layer, bf16 first:
 * the lego `--kv-quant N` (and a `kv_config.json` layer) composes.
 *
 * Numbers: today's served path and mlx-lm's (`quantized_kv_start`). Storage is
 * a `KVCache` until an append leaves it holding at least `start` positions (the
 * first append when `start` is 0). That append is read bf16 and then, before it
 * returns, the storage converts exactly as `kv-maintenance` converts it after a
 * forward (`KVCache.toQuantized`, the reuse floor at a nonzero
 * start, materialized at once). Every later append quantizes its positions and
 * is read affine. Stored values below the offset therefore equal the
 * convert-after path's bit for bit, and so does every read. A `QuantizedKVCache`
 * built empty is the other composition: it quantizes the first append too, so
 * its first chunk's output differs (`tests/state/bf16-first-kv.test.ts` records
 * by how much), and it has no mlx-lm oracle.
 *
 * The transition keys only on this cache's stored length and runs only inside
 * its appends, so the caller's append boundaries are part of the numbers: a
 * caller that splits one planned prefill chunk into two appends moves the
 * conversion to the split, and the second append reads quantized keys where the
 * served path reads bf16 until the chunk's end. The rows layout the scheduler
 * batches today (`DelayedQuantizedKVCache`) converts with this same code but
 * only at each row's planned chunk boundary (`TransitioningKvRows`). The
 * transition is irreversible: trimming below the start afterwards keeps the
 * quantized storage, so a verify window that crosses the start converts even if
 * its tail is later rejected.
 *
 * Reads: before the transition, `KVCache`'s reads (stock fused SDPA); after it,
 * the affine read the graphs make today (`quantizedSdpa` over the quantized
 * append, no mask for decode, the causal mask for a window). `signature()`,
 * `state()` and the offsets are the current storage's, so a saved lego is the
 * storage the convert-after path saves. Persistence, cloning and the row
 * layouts dispatch on that signature and read storage fields, so they cannot
 * take this cache as it is: the composition that builds it routes it to them.
 */
export class Bf16FirstQuantizedKVCache implements AttentionCache {
  #plain: KVCache | null;
  #quantized: QuantizedKVCache | null = null;

  constructor(
    readonly groupSize: number,
    readonly bits: number,
    /** Positions held in bf16 before the conversion; 0 converts after the first append. */
    readonly start: number,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
  ) {
    this.#plain = new KVCache(masks);
  }

  get #storage(): KVCache | QuantizedKVCache { return this.#quantized ?? this.#plain!; }
  get offset(): number { return this.#storage.offset; }
  get minimumReusableOffset(): number | undefined { return this.#quantized?.minimumReusableOffset; }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return affineRead(this.#quantized, k, v, unmaskedLease);
    return this.#settle(this.#plain!.appendDecode(k, v));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return affineRead(this.#quantized, k, v, causalLease);
    return this.#settle(this.#plain!.appendWindow(k, v));
  }

  /** After a bf16 append: convert once the stored length reaches the start.
   * The read already holds the bf16 keys and values it attends. */
  #settle(read: AttentionRead): AttentionRead {
    const plain = this.#plain!;
    if (!transitionDue(plain.offset, this.start)) return read;
    try { this.#quantized = convertToAffine(plain, this.groupSize, this.bits, this.start); }
    catch (error) { read.dispose(); throw error; }
    this.#plain = null;
    return read;
  }

  signature(): string { return this.#storage.signature(); }
  state(): MlxArray[] { return this.#storage.state(); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  isTrimmable(): boolean { return this.#storage.isTrimmable(); }
  trim(n: number): void { this.#storage.trim(n); }
  /** @deprecated The reads build their own masks. */
  makeMask(N: number, windowSize: number | null): Mask { return this.#storage.makeMask(N, windowSize); }
  /** @deprecated Read through `appendDecode` or `appendWindow`. */
  updateAndFetch(): [MlxArray, MlxArray] { return ownsItsRead(); }

  /** Releases the storage and returns to the constructed state: empty bf16. */
  dispose(): void {
    this.#quantized?.dispose();
    this.#plain?.dispose();
    this.#quantized = null;
    this.#plain = new KVCache(this.masks);
    this.masks.clear();
  }
}

/**
 * Affine-quantized keys and values for one sliding-window layer, bf16 first:
 * the rotating counterpart of {@link Bf16FirstQuantizedKVCache}, with the same
 * numbers, transition and obligations. Storage is a `RotatingKVCache` of
 * `maxSize` until an append leaves it holding at least `start` positions, then
 * converts as `kv-maintenance` does (`RotatingKVCache.toQuantized`: the ring as
 * laid out, its write index carried) into a `RotatingQuantizedKVCache`. Every
 * written ring position equals the convert-after path's bit for bit.
 *
 * Reads: before the transition, `RotatingKVCache`'s reads (decode writes in
 * place, a window concatenates); after it, the affine read the graphs make
 * today: decode with no mask, a window under the sliding causal mask built
 * before its append. Until B1b, the quantized append is the deprecated one,
 * which writes a one-position window in place (as the graphs do today) where
 * the bf16 window read concatenates.
 */
export class Bf16FirstRotatingQuantizedKVCache implements AttentionCache {
  #plain: RotatingKVCache | null;
  #quantized: RotatingQuantizedKVCache | null = null;

  constructor(
    /** The sliding window: the ring's capacity and the window every read applies. */
    readonly maxSize: number,
    readonly groupSize: number,
    readonly bits: number,
    /** Positions held in bf16 before the conversion; 0 converts after the first append. */
    readonly start: number,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
  ) {
    this.#plain = new RotatingKVCache(maxSize, masks);
  }

  get #storage(): RotatingKVCache | RotatingQuantizedKVCache { return this.#quantized ?? this.#plain!; }
  get offset(): number { return this.#storage.offset; }
  get minimumReusableOffset(): number | undefined { return this.#storage.minimumReusableOffset; }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return affineRead(this.#quantized, k, v, unmaskedLease);
    return this.#settle(this.#plain!.appendDecode(k, v));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    const quantized = this.#quantized;
    if (quantized) return affineRead(quantized, k, v, rotatingWindowMask(this.masks, this.maxSize, quantized.offset, k.shape[2]!));
    return this.#settle(this.#plain!.appendWindow(k, v));
  }

  #settle(read: AttentionRead): AttentionRead {
    const plain = this.#plain!;
    if (!transitionDue(plain.offset, this.start)) return read;
    try { this.#quantized = convertToAffine(plain, this.groupSize, this.bits, this.start); }
    catch (error) { read.dispose(); throw error; }
    this.#plain = null;
    return read;
  }

  signature(): string { return this.#storage.signature(); }
  state(): MlxArray[] { return this.#storage.state(); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  isTrimmable(): boolean { return this.#storage.isTrimmable(); }
  trim(n: number, bypass?: boolean): void { this.#storage.trim(n, bypass); }
  /** @deprecated The reads build their own masks. */
  makeMask(N: number, windowSize: number | null): Mask { return this.#storage.makeMask(N, windowSize); }
  /** @deprecated Read through `appendDecode` or `appendWindow`. */
  updateAndFetch(): [MlxArray, MlxArray] { return ownsItsRead(); }

  /** Releases the storage and returns to the constructed state: empty bf16. */
  dispose(): void {
    this.#quantized?.dispose();
    this.#plain?.dispose();
    this.#quantized = null;
    this.#plain = new RotatingKVCache(this.maxSize, this.masks);
    this.masks.clear();
  }
}

/**
 * TurboQuant-encoded keys and values for one full-attention layer, bf16 first:
 * the lego `--kv-quant turbo` composes (sliding-window layers keep a plain
 * `RotatingKVCache`).
 *
 * Numbers: today's served path. Storage is a `KVCache` until an append leaves
 * it holding at least `start` positions (the first append when `start` is 0).
 * That append is read bf16 and then, before it returns, the storage converts as
 * `kv-maintenance` converts it (`TurboQuantKVCache.fromKVCache` over the live
 * window, the reuse floor at a nonzero start, materialized at once). Every later
 * append encodes its positions and is read through the codec. Stored values
 * below the offset equal the convert-after path's bit for bit. The transition
 * has the obligations described on {@link Bf16FirstQuantizedKVCache}.
 *
 * Reads: before the transition, `KVCache`'s reads; after it, the read the
 * graphs make today: the deferred-V fetch, the stock fused SDPA (no mask for
 * decode, the causal mask for a window), then the inverse rotation of the
 * output. `fusedDecode` is resolved by whoever builds the cache; nothing here
 * reads the runtime configuration.
 */
export class Bf16FirstTurboQuantKVCache implements AttentionCache {
  #plain: KVCache | null;
  #encoded: TurboQuantKVCache | null = null;

  constructor(
    readonly kBits: number,
    readonly vBits: number,
    /** Positions held in bf16 before the conversion; 0 converts after the first append. */
    readonly start: number,
    /** The codec's decode policy for the converted storage. */
    readonly fusedDecode: boolean,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
  ) {
    this.#plain = new KVCache(masks);
  }

  get #storage(): KVCache | TurboQuantKVCache { return this.#encoded ?? this.#plain!; }
  get offset(): number { return this.#storage.offset; }
  get minimumReusableOffset(): number | undefined { return this.#encoded?.minimumReusableOffset; }
  /** `state()` returns fresh views once the storage is encoded. */
  get stateNeedsDispose(): boolean { return this.#encoded !== null; }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#encoded) return turboQuantRead(this.#encoded, k, v, unmaskedLease);
    return this.#settle(this.#plain!.appendDecode(k, v));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#encoded) return turboQuantRead(this.#encoded, k, v, causalLease);
    return this.#settle(this.#plain!.appendWindow(k, v));
  }

  #settle(read: AttentionRead): AttentionRead {
    const plain = this.#plain!;
    if (!transitionDue(plain.offset, this.start)) return read;
    try { this.#encoded = convertToTurboQuant(plain, this.kBits, this.vBits, this.start, this.fusedDecode); }
    catch (error) { read.dispose(); throw error; }
    this.#plain = null;
    return read;
  }

  signature(): string { return this.#storage.signature(); }
  state(): MlxArray[] { return this.#storage.state(); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  isTrimmable(): boolean { return this.#storage.isTrimmable(); }
  trim(n: number): void { this.#storage.trim(n); }
  /** @deprecated The reads build their own masks. */
  makeMask(N: number, windowSize: number | null): Mask { return this.#storage.makeMask(N, windowSize); }
  /** @deprecated Read through `appendDecode` or `appendWindow`. */
  updateAndFetch(): [MlxArray, MlxArray] { return ownsItsRead(); }

  /** Releases the storage and returns to the constructed state: empty bf16. */
  dispose(): void {
    this.#encoded?.dispose();
    this.#plain?.dispose();
    this.#encoded = null;
    this.#plain = new KVCache(this.masks);
    this.masks.clear();
  }
}
