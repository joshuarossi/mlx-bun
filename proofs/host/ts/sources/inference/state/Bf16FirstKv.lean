import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Bf16FirstKv
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/bf16-first-kv.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The quantized KV legos a composition's `makeCache` builds: bf16 storage
// through the first append (or the first `start` tokens), quantized storage
// after. Today's served path and mlx-lm's generate loop both run the first
// forward against unquantized keys and values and convert afterwards, even with
// `quantized_kv_start` 0; these caches keep that order inside their own
// appends. A cache quantized from token zero (`QuantizedKVCache` built empty)
// is a different composition with different first-chunk numbers.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { clearCache, Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type {
  AttentionCache, AttentionRead, BidirectionalAttentionCache, BlockAttentionCache, Cache, CommittedAttentionCache, CompiledDecodeCache, ComposedStorage,
  EncoderAttentionCache,
  DecodeSlot, DecodeStepInputs, DecodeStepPlan, Mask,
} from "../contracts/mlx/cache";
import type { KvStorageScheme } from "../contracts/portable/composition";
import { composedAffineKernels, type AffineKernels, type AffineKernelSet } from "./affine-attention";
import { AttentionMasks, decodeByPosition, sdpaRead, type DenseRead } from "./attention-read";
import { KVCache } from "./kv";
import { KV4_DECODE_BLOCK } from "../kernels/attention/kvq4-decode";
import { kv4Head256Kernels } from "./kv4-head256-cache";
import { QuantizedKVCache } from "./quantized-kv";
import { RotatingKVCache } from "./rotating-kv";
import { RotatingQuantizedKVCache } from "./rotating-quantized-kv";
import { TurboQuantKVCache } from "./turboquant-kv";
import type { TurboQuantKernels } from "./turboquant-attention";
import { turboQuantFusedDecode } from "./turboquant-codec";
import { isQuantizedKvCache, isRotatingQuantizedCache, isTurboQuantKvCache } from "./capabilities";

/** Whether bf16 storage holding `offset` positions converts under a
 * conversion start of `start` tokens: once it holds at least `start`
 * positions, and never while empty, so the first append is bf16 even when the
 * start is 0. */
export function transitionDue(offset: number, start: number): boolean {
  return offset >= start && offset !== 0;
}

/** Finish one conversion: a nonzero start records the converted `offset`
 * (read before the source was consumed) as the earliest reusable prefix, then
 * the new storage is materialized and the allocator pool released before
 * anything else converts, which bounds the live bf16 source plus quantized
 * copy to one layer. Returns `converted`. */
export function completeConversion<C extends Cache>(converted: C, offset: number, start: number): C {
  if (start > 0) converted.minimumReusableOffset = offset;
  const state = converted.state();
  try { ops.evalAll(state); }
  finally { if (converted.stateNeedsDispose) for (const array of state) array.dispose(); }
  clearCache();
  return converted;
}

/** The affine conversion of one bf16 entry: the source's own `toQuantized`
 * (which consumes the source) with `kernelSet`, the set the converted storage
 * attends with, then the shared bookkeeping. */
export function convertToAffine<C extends Cache>(
  source: { readonly offset: number; toQuantized(groupSize: number, bits: number, kernels: AffineKernelSet): C },
  groupSize: number, bits: number, start: number, kernelSet: AffineKernelSet,
): C {
  const offset = source.offset;
  return completeConversion(source.toQuantized(groupSize, bits, kernelSet), offset, start);
}

/** The TurboQuant conversion of one bf16 entry: encode the source's live
 * window (consuming the source), then the shared bookkeeping. The converted
 * cache attends with the source's TurboQuant read (`turboQuantKernels`);
 * `fusedDecode` is its decode policy. */
export function convertToTurboQuant(source: KVCache, kBits: number, vBits: number, start: number,
  fusedDecode: boolean): TurboQuantKVCache {
  const offset = source.offset;
  return completeConversion(TurboQuantKVCache.fromKVCache(source, kBits, vBits, source.turboQuantKernels, fusedDecode), offset, start);
}

/** Affine storage `source` holds, re-homed into a cache of the same storage
 * class that attends with `kernels` and `masks`: the arrays move (no copy) and
 * `source` is left empty. A restored, cloned or extracted entry enters a lego
 * with the lego's own kernels. */
function rehomeAffine(source: QuantizedKVCache, kernels: AffineKernels, masks: AttentionMasks): QuantizedKVCache {
  const cache = new QuantizedKVCache(source.groupSize, source.bits, kernels, masks);
  if (source.keys && source.values) cache.restoreState(source.keys, source.values, source.offset);
  else cache.offset = source.offset;
  cache.minimumReusableOffset = source.minimumReusableOffset;
  source.keys = source.values = null;
  source.dispose();
  return cache;
}

function rehomeRotatingAffine(source: RotatingQuantizedKVCache, kernels: AffineKernels, masks: AttentionMasks): RotatingQuantizedKVCache {
  const cache = new RotatingQuantizedKVCache(source.maxSize, source.groupSize, source.bits, kernels, masks);
  if (source.keys && source.values) cache.restoreState(source.keys, source.values, source.offset, source.ringIdx);
  else { cache.offset = source.offset; cache.ringIdx = source.ringIdx; }
  cache.minimumReusableOffset = source.minimumReusableOffset;
  source.keys = source.values = null;
  source.dispose();
  return cache;
}

/** The deprecated plain fetch of a lego in bf16: the storage's fetch, then the
 * transition its append may owe. The caller owns the fetched keys and values,
 * which outlive the conversion that consumes the bf16 storage. */
function fetchThenSettle(fetched: [MlxArray, MlxArray], settle: () => void): [MlxArray, MlxArray] {
  try { settle(); }
  catch (error) { fetched[0].dispose(); fetched[1].dispose(); throw error; }
  return fetched;
}

/** The bidirectional and encoder reads are defined for a sequence's first
 * window only, which a lego always holds in bf16. */
function firstWindowOnly(read: string): never {
  throw new Error(`${read} reads a sequence's first window (offset 0); this cache already holds positions`);
}

/**
 * Affine-quantized keys and values for one full-attention layer, bf16 first:
 * the lego `--kv-quant N` (and a `kv_config.json` layer) composes.
 *
 * Numbers: today's served path and mlx-lm's (`quantized_kv_start`). Storage is
 * a `KVCache` until an append leaves it holding at least `start` positions (the
 * first append when `start` is 0). That append is read bf16 and then, before it
 * returns, the storage converts (`KVCache.toQuantized`, the reuse floor at a
 * nonzero start, materialized at once). Every later append quantizes its
 * positions and is read by the quantized storage's own reads, with
 * `kernelSet`'s kernels. Stored values below the offset therefore equal the
 * convert-after path's bit for bit, and so does every read. A
 * `QuantizedKVCache` built empty is the other composition: it quantizes the
 * first append too, so its first chunk's output differs
 * (`tests/state/bf16-first-kv.test.ts` records by how much), and it has no
 * mlx-lm oracle.
 *
 * The transition keys only on this cache's stored length and runs only inside
 * its appends (or when it adopts storage that already holds `start`
 * positions), so the caller's append boundaries are part of the numbers: a
 * caller that splits one planned prefill chunk into two appends moves the
 * conversion to the split. The rows layout the scheduler batches
 * (`DelayedQuantizedKVCache`) converts with this same code but only at each
 * row's planned chunk boundary (`TransitioningKvRows`). The transition is
 * irreversible: trimming below the start afterwards keeps the quantized
 * storage, so a verify window that crosses the start converts even if its tail
 * is later rejected.
 *
 * The row layouts, clones and saved files take the storage, never this cache
 * (`composed`): its signature is its own (`kv:bf16-first:` and the storage's),
 * and its storage is what the convert-after path saves.
 */
export class Bf16FirstQuantizedKVCache implements CommittedAttentionCache, BidirectionalAttentionCache, EncoderAttentionCache, BlockAttentionCache, CompiledDecodeCache {
  #plain: KVCache | null;
  #quantized: QuantizedKVCache | null = null;

  /** `storage`: bf16 or affine storage of this layer to adopt (restored,
   * cloned or extracted elsewhere); affine storage is re-homed to this lego's
   * kernels, bf16 storage that already holds `start` positions converts now. */
  constructor(
    readonly groupSize: number,
    readonly bits: number,
    /** Positions held in bf16 before the conversion; 0 converts after the first append. */
    readonly start: number,
    /** The affine kernel set the converted storage attends with, named by the
     * composition (`composedAffineKernels`, or the KV4 set). */
    readonly kernelSet: AffineKernelSet,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
    storage?: Cache,
  ) {
    if (!storage) { this.#plain = new KVCache(masks); return; }
    if (isQuantizedKvCache(storage)) {
      const source = storage as QuantizedKVCache;
      this.#plain = null;
      this.#quantized = rehomeAffine(source, this.#kernelsFor(source), masks);
      return;
    }
    this.#plain = storage as KVCache;
    this.#convertIfDue();
  }

  #kernelsFor(source: QuantizedKVCache): AffineKernels {
    return this.kernelSet(this.bits, this.groupSize, source.keys?.scales.dtype ?? Dtype.bfloat16);
  }

  get #storage(): KVCache | QuantizedKVCache { return this.#quantized ?? this.#plain!; }
  get offset(): number { return this.#storage.offset; }
  get minimumReusableOffset(): number | undefined { return (this.#storage as Cache).minimumReusableOffset; }
  set minimumReusableOffset(value: number | undefined) { (this.#storage as Cache).minimumReusableOffset = value; }
  /** The donor reads of the storage held now: a drafter borrowing this layer's
   * keys and values reads them as the storage hands them out. */
  get captureDonorRows() { const storage = this.#storage as Cache; return storage.captureDonorRows?.bind(storage); }
  get captureDonorAttention() { const storage = this.#storage as Cache; return storage.captureDonorAttention?.bind(storage); }

  /** The storage the row layouts, clones and saved files take (see the class). */
  readonly composed: ComposedStorage = {
    storage: () => this.#storage,
    over: (storage: Cache) => new Bf16FirstQuantizedKVCache(this.groupSize, this.bits, this.start, this.kernelSet, this.masks, storage),
    release: () => { const storage = this.#storage; this.#plain = new KVCache(this.masks); this.#quantized = null; return storage; },
  };

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return this.#quantized.appendDecode(k, v);
    return this.#settle(this.#plain!.appendDecode(k, v));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return this.#quantized.appendWindow(k, v);
    return this.#settle(this.#plain!.appendWindow(k, v));
  }

  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return this.#quantized.appendCommitted(k, v);
    return this.#settle(this.#plain!.appendCommitted(k, v));
  }

  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    if (this.#quantized) return firstWindowOnly("appendBidirectional");
    return this.#settle(this.#plain!.appendBidirectional(k, v, bidirectional));
  }

  /** The encoder window, a first window: bf16 storage's read, then the
   * transition its append owes. */
  appendEncoderWindow(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    if (this.#quantized) return firstWindowOnly("appendEncoderWindow");
    return this.#settle(this.#plain!.appendEncoderWindow(k, v, bidirectional));
  }

  /** The block read of the storage held now (it appends nothing, so nothing
   * converts). */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead { return this.#storage.readBlock(k, v); }

  /** Positions an append may add before the transition: up to the start. */
  maxAppendTokens(): number {
    return this.#plain && this.#plain.offset < this.start ? this.start - this.#plain.offset : Infinity;
  }

  // The compiled decode step drives the storage held now; a committed step
  // owes the transition an append owes.
  prepareDecodeStep(): DecodeStepPlan { return this.#storage.prepareDecodeStep(); }
  decodePhase(): DecodeStepPlan["fetch"] { return this.#storage.decodePhase(); }
  decodeSlot(plan: DecodeStepPlan): DecodeSlot { return this.#storage.decodeSlot(plan); }
  decodeInputs(plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[] { return this.#storage.decodeInputs(plan, step); }
  commitDecodeStep(slot: DecodeSlot, outputs: MlxArray[]): MlxArray[] {
    const evalWith = this.#storage.commitDecodeStep(slot, outputs);
    if (!this.#plain || !transitionDue(this.#plain.offset, this.start)) return evalWith;
    // The conversion consumes the arrays the step wrote and evaluates the
    // converted storage before it returns: nothing is left to evaluate here.
    this.#convertIfDue();
    return [];
  }

  /** After a bf16 append: convert once the stored length reaches the start.
   * The read already holds the bf16 keys and values it attends. */
  #settle(read: AttentionRead): AttentionRead {
    try { this.#convertIfDue(); }
    catch (error) { read.dispose(); throw error; }
    return read;
  }

  #convertIfDue(): void {
    const plain = this.#plain!;
    if (!transitionDue(plain.offset, this.start)) return;
    this.#quantized = convertToAffine(plain, this.groupSize, this.bits, this.start, this.kernelSet);
    this.#plain = null;
  }

  signature(): string { return `kv:bf16-first:${this.#storage.signature()}`; }
  state(): MlxArray[] { return this.#storage.state(); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  isTrimmable(): boolean { return this.#storage.isTrimmable(); }
  trim(n: number): void { this.#storage.trim(n); }
  /** @deprecated The reads build their own masks. */
  makeMask(N: number, windowSize: number | null): Mask { return this.#storage.makeMask(N, windowSize); }
  /** @deprecated Read through `appendDecode` or `appendWindow`. The dense
   * fetch of the storage (the softcapped read's): bf16 storage fetches and then
   * converts as an append does; affine storage fetches its window dequantized. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    if (this.#quantized) return this.#quantized.updateAndFetch(k, v);
    return fetchThenSettle(this.#plain!.updateAndFetch(k, v), () => this.#convertIfDue());
  }

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
 * converts (`RotatingKVCache.toQuantized`: the ring as laid out, its write
 * index carried) into a `RotatingQuantizedKVCache`, whose own reads serve every
 * later append. Every written ring position equals the convert-after path's
 * bit for bit.
 */
export class Bf16FirstRotatingQuantizedKVCache implements CommittedAttentionCache, BidirectionalAttentionCache, EncoderAttentionCache, BlockAttentionCache, CompiledDecodeCache {
  #plain: RotatingKVCache | null;
  #quantized: RotatingQuantizedKVCache | null = null;

  constructor(
    /** The sliding window: the ring's capacity and the window every read applies. */
    readonly maxSize: number,
    readonly groupSize: number,
    readonly bits: number,
    /** Positions held in bf16 before the conversion; 0 converts after the first append. */
    readonly start: number,
    /** The affine kernel set the converted storage attends with, named by the
     * composition (`composedAffineKernels`). */
    readonly kernelSet: AffineKernelSet,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
    storage?: Cache,
  ) {
    if (!storage) { this.#plain = new RotatingKVCache(maxSize, masks); return; }
    if (isRotatingQuantizedCache(storage)) {
      const source = storage as RotatingQuantizedKVCache;
      this.#plain = null;
      this.#quantized = rehomeRotatingAffine(source,
        this.kernelSet(this.bits, this.groupSize, source.keys?.scales.dtype ?? Dtype.bfloat16), masks);
      return;
    }
    this.#plain = storage as RotatingKVCache;
    this.#convertIfDue();
  }

  get #storage(): RotatingKVCache | RotatingQuantizedKVCache { return this.#quantized ?? this.#plain!; }
  get offset(): number { return this.#storage.offset; }
  get minimumReusableOffset(): number | undefined { return (this.#storage as Cache).minimumReusableOffset; }
  set minimumReusableOffset(value: number | undefined) { (this.#storage as Cache).minimumReusableOffset = value; }
  /** The donor reads of the storage held now: a drafter borrowing this layer's
   * keys and values reads them as the storage hands them out. */
  get captureDonorRows() { const storage = this.#storage as Cache; return storage.captureDonorRows?.bind(storage); }
  get captureDonorAttention() { const storage = this.#storage as Cache; return storage.captureDonorAttention?.bind(storage); }

  /** The storage the row layouts, clones and saved files take. */
  readonly composed: ComposedStorage = {
    storage: () => this.#storage,
    over: (storage: Cache) => new Bf16FirstRotatingQuantizedKVCache(this.maxSize, this.groupSize, this.bits, this.start,
      this.kernelSet, this.masks, storage),
    release: () => { const storage = this.#storage; this.#plain = new RotatingKVCache(this.maxSize, this.masks); this.#quantized = null; return storage; },
  };

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return this.#quantized.appendDecode(k, v);
    return this.#settle(this.#plain!.appendDecode(k, v));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#quantized) return this.#quantized.appendWindow(k, v);
    return this.#settle(this.#plain!.appendWindow(k, v));
  }

  /** A committed span, one decode per position through this lego
   * (`decodeByPosition`), so the transition falls where `L` decodes put it. */
  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead {
    return decodeByPosition(this, k, v);
  }

  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    if (this.#quantized) return firstWindowOnly("appendBidirectional");
    return this.#settle(this.#plain!.appendBidirectional(k, v, bidirectional));
  }

  /** The encoder window, a first window: bf16 storage's read, then the
   * transition its append owes. */
  appendEncoderWindow(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    if (this.#quantized) return firstWindowOnly("appendEncoderWindow");
    return this.#settle(this.#plain!.appendEncoderWindow(k, v, bidirectional));
  }

  /** The block read of the storage held now (it appends nothing, so nothing
   * converts). */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead { return this.#storage.readBlock(k, v); }

  maxAppendTokens(): number {
    return this.#plain && this.#plain.offset < this.start ? this.start - this.#plain.offset : Infinity;
  }

  // The compiled decode step drives the ring held now; a committed step owes
  // the transition an append owes.
  prepareDecodeStep(): DecodeStepPlan { return this.#storage.prepareDecodeStep(); }
  decodePhase(): DecodeStepPlan["fetch"] { return this.#storage.decodePhase(); }
  decodeSlot(plan: DecodeStepPlan): DecodeSlot { return this.#storage.decodeSlot(plan); }
  decodeInputs(plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[] { return this.#storage.decodeInputs(plan, step); }
  commitDecodeStep(slot: DecodeSlot, outputs: MlxArray[]): MlxArray[] {
    const evalWith = this.#storage.commitDecodeStep(slot, outputs);
    if (!this.#plain || !transitionDue(this.#plain.offset, this.start)) return evalWith;
    // The conversion consumes the arrays the step wrote and evaluates the
    // converted storage before it returns: nothing is left to evaluate here.
    this.#convertIfDue();
    return [];
  }

  #settle(read: AttentionRead): AttentionRead {
    try { this.#convertIfDue(); }
    catch (error) { read.dispose(); throw error; }
    return read;
  }

  #convertIfDue(): void {
    const plain = this.#plain!;
    if (!transitionDue(plain.offset, this.start)) return;
    this.#quantized = convertToAffine(plain, this.groupSize, this.bits, this.start, this.kernelSet);
    this.#plain = null;
  }

  signature(): string { return `kv:bf16-first:${this.#storage.signature()}`; }
  state(): MlxArray[] { return this.#storage.state(); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  isTrimmable(): boolean { return this.#storage.isTrimmable(); }
  trim(n: number, bypass?: boolean): void { this.#storage.trim(n, bypass); }
  /** @deprecated The reads build their own masks. */
  makeMask(N: number, windowSize: number | null): Mask { return this.#storage.makeMask(N, windowSize); }
  /** @deprecated Read through `appendDecode` or `appendWindow`. The dense
   * fetch of the storage (the softcapped read's): a bf16 ring fetches and then
   * converts as an append does; an affine ring fetches its ring dequantized. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    if (this.#quantized) return this.#quantized.updateAndFetch(k, v);
    return fetchThenSettle(this.#plain!.updateAndFetch(k, v), () => this.#convertIfDue());
  }

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
 * That append is read bf16 and then, before it returns, the storage converts
 * (`TurboQuantKVCache.fromKVCache` over the live window, the reuse floor at a
 * nonzero start, materialized at once). Every later append encodes its
 * positions and is read through the codec. Stored values below the offset
 * equal the convert-after path's bit for bit. The transition has the
 * obligations described on {@link Bf16FirstQuantizedKVCache}.
 *
 * Reads: before the transition, `KVCache`'s reads; after it, the encoded
 * storage's reads, which attend with `turboQuantKernels` (no mask for decode,
 * the causal mask for a window): decoded values and the stock fused SDPA for
 * Qwen 3.5's graph, or the deferred-V fetch, the stock fused SDPA and the
 * inverse rotation of the output for Gemma 4's and MiniCPM5's. `fusedDecode` is
 * resolved by whoever builds the cache; nothing here reads the runtime
 * configuration.
 */
export class Bf16FirstTurboQuantKVCache implements CommittedAttentionCache, BidirectionalAttentionCache, EncoderAttentionCache, BlockAttentionCache, CompiledDecodeCache {
  #plain: KVCache | null;
  #encoded: TurboQuantKVCache | null = null;

  constructor(
    readonly kBits: number,
    readonly vBits: number,
    /** Positions held in bf16 before the conversion; 0 converts after the first append. */
    readonly start: number,
    /** The codec's decode policy for the converted storage. */
    readonly fusedDecode: boolean,
    /** How the converted storage attends, named by the graph the cache serves
     * (`denseTurboQuantKernels` for Qwen 3.5, `deferredTurboQuantKernels` for
     * Gemma 4 and MiniCPM5). */
    readonly turboQuantKernels: TurboQuantKernels,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
    storage?: Cache,
  ) {
    if (!storage) { this.#plain = new KVCache(masks, turboQuantKernels); return; }
    if (isTurboQuantKvCache(storage)) { this.#plain = null; this.#encoded = storage as TurboQuantKVCache; return; }
    this.#plain = storage as KVCache;
    this.#convertIfDue();
  }

  get #storage(): KVCache | TurboQuantKVCache { return this.#encoded ?? this.#plain!; }
  get offset(): number { return this.#storage.offset; }
  get minimumReusableOffset(): number | undefined { return (this.#storage as Cache).minimumReusableOffset; }
  set minimumReusableOffset(value: number | undefined) { (this.#storage as Cache).minimumReusableOffset = value; }
  /** The donor reads of the storage held now: a drafter borrowing this layer's
   * keys and values reads them as the storage hands them out. */
  get captureDonorRows() { const storage = this.#storage as Cache; return storage.captureDonorRows?.bind(storage); }
  get captureDonorAttention() { const storage = this.#storage as Cache; return storage.captureDonorAttention?.bind(storage); }
  /** `state()` returns fresh views once the storage is encoded. */
  get stateNeedsDispose(): boolean { return this.#encoded !== null; }

  /** The storage the row layouts, clones and saved files take. */
  readonly composed: ComposedStorage = {
    storage: () => this.#storage,
    over: (storage: Cache) => new Bf16FirstTurboQuantKVCache(this.kBits, this.vBits, this.start, this.fusedDecode,
      this.turboQuantKernels, this.masks, storage),
    release: () => { const storage = this.#storage; this.#plain = new KVCache(this.masks, this.turboQuantKernels); this.#encoded = null; return storage; },
  };

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#encoded) return this.#encoded.appendDecode(k, v);
    return this.#settle(this.#plain!.appendDecode(k, v));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#encoded) return this.#encoded.appendWindow(k, v);
    return this.#settle(this.#plain!.appendWindow(k, v));
  }

  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead {
    if (this.#encoded) return this.#encoded.appendCommitted(k, v);
    return this.#settle(this.#plain!.appendCommitted(k, v));
  }

  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    if (this.#encoded) return firstWindowOnly("appendBidirectional");
    return this.#settle(this.#plain!.appendBidirectional(k, v, bidirectional));
  }

  /** The encoder window, a first window: bf16 storage's read, then the
   * transition its append owes. */
  appendEncoderWindow(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    if (this.#encoded) return firstWindowOnly("appendEncoderWindow");
    return this.#settle(this.#plain!.appendEncoderWindow(k, v, bidirectional));
  }

  /** The block read of the storage held now (it appends nothing, so nothing
   * converts). */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead { return this.#storage.readBlock(k, v); }

  maxAppendTokens(): number {
    return this.#plain && this.#plain.offset < this.start ? this.start - this.#plain.offset : Infinity;
  }

  // The compiled decode step drives the storage held now; a committed step
  // owes the transition an append owes.
  prepareDecodeStep(): DecodeStepPlan { return this.#storage.prepareDecodeStep(); }
  decodePhase(): DecodeStepPlan["fetch"] { return this.#storage.decodePhase(); }
  decodeSlot(plan: DecodeStepPlan): DecodeSlot { return this.#storage.decodeSlot(plan); }
  decodeInputs(plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[] { return this.#storage.decodeInputs(plan, step); }
  commitDecodeStep(slot: DecodeSlot, outputs: MlxArray[]): MlxArray[] {
    const evalWith = this.#storage.commitDecodeStep(slot, outputs);
    if (!this.#plain || !transitionDue(this.#plain.offset, this.start)) return evalWith;
    // The conversion consumes the arrays the step wrote and evaluates the
    // converted storage before it returns: nothing is left to evaluate here.
    this.#convertIfDue();
    return [];
  }

  #settle(read: AttentionRead): AttentionRead {
    try { this.#convertIfDue(); }
    catch (error) { read.dispose(); throw error; }
    return read;
  }

  #convertIfDue(): void {
    const plain = this.#plain!;
    if (!transitionDue(plain.offset, this.start)) return;
    this.#encoded = convertToTurboQuant(plain, this.kBits, this.vBits, this.start, this.fusedDecode);
    this.#plain = null;
  }

  signature(): string { return `kv:bf16-first:${this.#storage.signature()}`; }
  state(): MlxArray[] { return this.#storage.state(); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  isTrimmable(): boolean { return this.#storage.isTrimmable(); }
  trim(n: number): void { this.#storage.trim(n); }
  /** @deprecated The reads build their own masks. */
  makeMask(N: number, windowSize: number | null): Mask { return this.#storage.makeMask(N, windowSize); }
  /** @deprecated Read through `appendDecode` or `appendWindow`. The plain
   * fetch of the storage (the softcapped read's): bf16 storage fetches and then
   * encodes as an append does; encoded storage decodes its window. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    if (this.#encoded) return this.#encoded.updateAndFetch(k, v);
    return fetchThenSettle(this.#plain!.updateAndFetch(k, v), () => this.#convertIfDue());
  }

  /** Releases the storage and returns to the constructed state: empty bf16. */
  dispose(): void {
    this.#encoded?.dispose();
    this.#plain?.dispose();
    this.#encoded = null;
    this.#plain = new KVCache(this.masks, this.turboQuantKernels);
    this.masks.clear();
  }
}

/** The KV4 kernel set over the composition's affine set `plain`: the 4-bit
 * group-64 head-dim-256 reads (`kv4Head256Kernels`, the decode kernel at
 * `decodeBlock` tokens per threadgroup) for one sequence, and `plain`'s kernels
 * for a row layout holding more. */
export function kv4Head256KernelSet(plain: AffineKernelSet, decodeBlock: number): AffineKernelSet {
  return (bits, groupSize, dtype) => kv4Head256Kernels(plain(bits, groupSize, dtype), decodeBlock);
}

/**
 * The 4-bit group-64 full-attention lego of the Qwen3.8-27B Trellis M4 Pro and
 * M1 Max compositions, bf16 first: {@link Bf16FirstQuantizedKVCache} whose
 * quantized storage reads with `Kv4Head256Cache`'s kernels, the decode kernel at
 * the composition's `decodeBlock`. The first append is bf16, as
 * the old graph's conversion after the first forward kept it; every later
 * decode reads with the fused one-row KV4 kernel and every window with the
 * folded-GQA kernel, the cores the old graph injected for one sequence. Its
 * storage carries the KV4 set into the row layouts it joins, which read with
 * the KV4 kernels while they hold one unpadded row and with `plain`'s affine
 * kernels when they hold more (`AffineKernels.multiRow`), as the old graph read
 * several sequences through the generic path.
 */
export class Bf16FirstKv4Head256Cache extends Bf16FirstQuantizedKVCache {
  /** `plain`: the composition's affine kernel set (`composedAffineKernels`); `decodeBlock`: the decode kernel's
   *  tokens per threadgroup its device's table names (the M4 Pro's by default). */
  constructor(start: number, readonly plain: AffineKernelSet, masks = new AttentionMasks(),
    readonly decodeBlock = KV4_DECODE_BLOCK, storage?: Cache) {
    super(64, 4, start, kv4Head256KernelSet(plain, decodeBlock), masks, storage);
  }
}

/** One-time notice that TurboQuant leaves sliding-window layers bf16. */
let warnedTurboRotating = false;

/** The cache a composition's KV scheme names for one full-attention layer
 * (cache index `layer`) of a graph whose TurboQuant read is
 * `turboQuantKernels` and whose bf16 window read is `windowRead` (the stock
 * fused SDPA unless it names another): plain bf16 for `bf16` and for a layer a
 * per-layer scheme does not list, the bf16-first affine lego for affine schemes
 * (the scheme's read kernels, `composedAffineKernels`), the bf16-first
 * TurboQuant lego for `turbo`. Every cache of one `makeCache` call shares
 * `masks`. */
export function composedFullAttentionCache(kv: KvStorageScheme, layer: number, masks: AttentionMasks,
  turboQuantKernels: TurboQuantKernels, windowRead: DenseRead = sdpaRead): AttentionCache {
  const start = kv.kind === "bf16" ? 0 : kv.quantizedKvStart ?? 0;
  switch (kv.kind) {
    case "bf16": return new KVCache(masks, turboQuantKernels, windowRead);
    case "affine": return new Bf16FirstQuantizedKVCache(kv.groupSize, kv.bits, start, composedAffineKernels(kv.kernels), masks);
    case "affine-layers": {
      const entry = kv.layers.find(item => item.layer === layer);
      return entry ? new Bf16FirstQuantizedKVCache(entry.groupSize, entry.bits, start, composedAffineKernels(kv.kernels), masks)
        : new KVCache(masks, turboQuantKernels, windowRead);
    }
    case "turbo": return new Bf16FirstTurboQuantKVCache(kv.kBits, kv.vBits, start, turboQuantFusedDecode(), turboQuantKernels, masks);
  }
}

/** The cache a composition's KV scheme names for one sliding-window layer of
 * `maxSize` (cache index `layer`): plain for `bf16`, for a layer a per-layer
 * scheme does not list and for `turbo` (TurboQuant encodes full-attention
 * layers only), the bf16-first rotating affine lego otherwise. */
export function composedSlidingAttentionCache(kv: KvStorageScheme, layer: number, maxSize: number,
  masks: AttentionMasks): AttentionCache {
  const start = kv.kind === "bf16" ? 0 : kv.quantizedKvStart ?? 0;
  switch (kv.kind) {
    case "bf16": return new RotatingKVCache(maxSize, masks);
    case "affine": return new Bf16FirstRotatingQuantizedKVCache(maxSize, kv.groupSize, kv.bits, start, composedAffineKernels(kv.kernels), masks);
    case "affine-layers": {
      const entry = kv.layers.find(item => item.layer === layer);
      return entry ? new Bf16FirstRotatingQuantizedKVCache(maxSize, entry.groupSize, entry.bits, start, composedAffineKernels(kv.kernels), masks)
        : new RotatingKVCache(maxSize, masks);
    }
    case "turbo":
      if (!warnedTurboRotating) {
        warnedTurboRotating = true;
        console.warn("[turbo-quant] sliding-window (RotatingKVCache) layers stay bf16 in v1 (full-attention only).");
      }
      return new RotatingKVCache(maxSize, masks);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Bf16FirstKv
