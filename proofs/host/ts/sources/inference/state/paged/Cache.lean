import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Paged.Cache
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/paged/cache.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Paged KV storage behind the common cache and attention interfaces.
// Full-attention pools store bf16, affine (any bit width the composition
// names, per layer) or TurboQuant pages. The established
// gather + SDPA arm is the numerical control; direct Metal reads are Lab.
// Published views and SSD snapshots own immutable buffers independently of
// appends, row membership and RAM eviction.

import { disposeResources } from "../../runtime/resources";
import { pagedAttentionView } from "../../kernels/attention/paged";
import type { KvStorageScheme, PagedKvComposition } from "../../contracts/portable/composition";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { bidirMask, createCausalMask } from "../../kernels/attention/masks";
import {
  type AttentionRead, type BidirectionalAttentionCache, type BlockAttentionCache, type CommittedAttentionCache,
  type CompiledDecodeCache, type DecodeSlot, type DecodeStepInputs, type DecodeStepPlan, type DecodeTrace,
  type EncoderAttentionCache, type KvAttentionView, type KvDonorRows, type Mask,
} from "../../contracts/mlx/cache";
import { AttentionMasks, causalLease, encoderWindowMask, sdpaRead, unmaskedLease, withLease, type MaskLease } from "../attention-read";
import * as tq from "../../kernels/turboquant/ops";
import { TurboQuantCodec, type TurboQuantTensor } from "../turboquant-codec";
import { turboQuantDecodeSlot } from "../turboquant-kv";
import type { TurboQuantKernels } from "../turboquant-attention";

/** Typed pool-exhaustion error: a generation outgrew its pool. Sizing from
 *  prompt+maxTokens at construction makes this unreachable in practice;
 *  it exists so an accounting bug is a clear throw, never silent
 *  truncation or an allocator OOM (the byte-capped-not-count-capped
 *  lesson). */
export class PagedPoolExhausted extends Error {
  constructor(numBlocks: number) {
    super(`paged KV pool exhausted (${numBlocks} blocks) — capacity accounting bug`);
    this.name = "PagedPoolExhausted";
  }
}

/** Affine pages: the bit width and group size every page of a layer stores. */
export interface PagedQuantization { bits: number; groupSize: number }

/** TurboQuant pages: the codec's key and value bit widths, its decode policy,
 * and the read the layer's graph composed (`TurboQuantKernels`: dense or
 * deferred values). */
export interface PagedTurboQuant {
  readonly kBits: number;
  readonly vBits: number;
  readonly fusedDecode: boolean;
  readonly kernels: TurboQuantKernels;
}

/** Per-layer block arena, mlx-owned (ops.zeros — no host-pointer
 *  alignment/dtor hazards), every plane shaped [numBlocks, H, blockSize, width].
 *  bf16 pages: `keys` and `values`. Affine pages: packed `keys` and `values`
 *  with their scales and biases. TurboQuant pages: the codec's five codes, key
 *  indices in `keys`, key scales and zero points in `keyScales` and
 *  `keyBiases`, value indices in `values`, value scales in `valueScales`.
 *  alloc()/free() manage physical slot indices; the owning PagedKVCache
 *  writes/gathers through the pool. */

export class BlockPool {
  keyScales?: MlxArray; keyBiases?: MlxArray;
  valueScales?: MlxArray; valueBiases?: MlxArray;
  readonly headDim: number;
  readonly vHeadDim: number;
  readonly dtype: Dtype;
  readonly quantization?: PagedQuantization;
  /** TurboQuant pages' bit widths. */
  readonly turbo?: { readonly kBits: number; readonly vBits: number; readonly fusedDecode: boolean };
  readonly #codec?: TurboQuantCodec;
  keys: MlxArray;
  values: MlxArray;
  numBlocks: number;
  readonly blockSize: number;
  #free: number[];

  constructor(opts: {
    numBlocks: number;
    blockSize: number;
    numKvHeads: number;
    headDim: number;
    /** V head dim when it differs from K's (attention_k_eq_v models don't
     *  reach v1's gemma4 scope, but the pool stays shape-honest). */
    vHeadDim?: number;
    dtype: Dtype;
    quantization?: PagedQuantization;
    turbo?: { readonly kBits: number; readonly vBits: number; readonly fusedDecode: boolean };
  }, source?: BlockPool) {
    this.headDim = opts.headDim; this.vHeadDim = opts.vHeadDim ?? opts.headDim;
    this.dtype = opts.dtype; this.quantization = opts.quantization;
    if (opts.turbo) {
      this.turbo = Object.freeze({ kBits: opts.turbo.kBits, vBits: opts.turbo.vBits, fusedDecode: opts.turbo.fusedDecode });
      this.#codec = new TurboQuantCodec(opts.turbo.kBits, opts.turbo.vBits, opts.turbo.fusedDecode);
    }
    this.numBlocks = opts.numBlocks;
    this.blockSize = opts.blockSize;
    const shape = (width: number) => [opts.numBlocks, opts.numKvHeads, opts.blockSize, width];
    if (source) {
      this.keys = ops.contiguous(source.keys); this.values = ops.contiguous(source.values);
      const copy = (array?: MlxArray) => array ? ops.contiguous(array) : undefined;
      this.keyScales = copy(source.keyScales); this.keyBiases = copy(source.keyBiases);
      this.valueScales = copy(source.valueScales); this.valueBiases = copy(source.valueBiases);
    } else if (this.turbo) {
      // The codec's layout (TurboQuantKVCache's): index planes bit-packed below
      // eight bits, one fp16 scale (and key zero point) per 32 positions of a head.
      const { kBits, vBits } = this.turbo, vD = this.vHeadDim, groups = (dim: number) => dim / tq.TURBOQUANT_BLOCK_SIZE;
      this.keys = ops.zeros(shape(tq.packedDim(opts.headDim, kBits)), kBits === 8 ? Dtype.int8 : Dtype.uint8);
      this.keyScales = ops.zeros(shape(groups(opts.headDim)), Dtype.float16);
      this.keyBiases = ops.zeros(shape(groups(opts.headDim)), Dtype.float16);
      this.values = ops.zeros(shape(tq.packedDim(vD, vBits)), Dtype.uint8);
      this.valueScales = ops.zeros(shape(groups(vD)), Dtype.float16);
    } else {
      this.keys = ops.zeros(shape(opts.headDim), opts.dtype);
      this.values = ops.zeros(shape(this.vHeadDim), opts.dtype);
    }
    if (!source && this.quantization) {
      const { bits, groupSize } = this.quantization;
      const k = ops.quantize(this.keys, groupSize, bits), v = ops.quantize(this.values, groupSize, bits);
      this.keys.dispose(); this.values.dispose();
      this.keys = k.packed; this.keyScales = k.scales; this.keyBiases = k.biases;
      this.values = v.packed; this.valueScales = v.scales; this.valueBiases = v.biases;
    }
    // LIFO free list, low indices first — deterministic layout for tests.
    this.#free = source ? [...source.#free] : Array.from({ length: opts.numBlocks }, (_, i) => opts.numBlocks - 1 - i);
  }

  /** Independent ownership and allocation metadata over immutable MLX buffers.
   * Functional writes detach storage while another snapshot retains it. */
  clone(): BlockPool {
    return new BlockPool({ numBlocks: this.numBlocks, blockSize: this.blockSize,
      numKvHeads: this.keys.shape[1]!, headDim: this.headDim,
      vHeadDim: this.vHeadDim, dtype: this.dtype, quantization: this.quantization, turbo: this.turbo }, this);
  }

  restoreArrays(arrays: MlxArray[], occupied: readonly number[]): void {
    disposeResources(this.arrays());
    [this.keys, this.values] = [arrays[0]!, arrays[1]!];
    [this.keyScales, this.keyBiases, this.valueScales, this.valueBiases] = arrays.slice(2);
    const used = new Set(occupied);
    this.#free = Array.from({ length: this.numBlocks }, (_, i) => this.numBlocks - 1 - i).filter(i => !used.has(i));
  }

  grow(blocks: number): void {
    if (blocks <= this.numBlocks) return;
    const grow = (array: MlxArray) => {
      using zeros = ops.zeros([blocks - this.numBlocks, ...array.shape.slice(1)], array.dtype);
      const next = ops.concatAxis([array, zeros], 0); array.dispose(); return next;
    };
    this.keys = grow(this.keys); this.values = grow(this.values);
    if (this.keyScales) this.keyScales = grow(this.keyScales);
    if (this.keyBiases) this.keyBiases = grow(this.keyBiases);
    if (this.valueScales) this.valueScales = grow(this.valueScales);
    if (this.valueBiases) this.valueBiases = grow(this.valueBiases);
    for (let i = blocks - 1; i >= this.numBlocks; i--) this.#free.push(i);
    this.numBlocks = blocks;
  }

  get freeBlocks(): number {
    return this.#free.length;
  }

  alloc(): number {
    const idx = this.#free.pop();
    if (idx === undefined) throw new PagedPoolExhausted(this.numBlocks);
    return idx;
  }

  free(physIdx: number): void {
    this.#free.push(physIdx);
  }

  /** Write `k`/`v` ([1, H, l, D], l ≤ blockSize − within) into physical
   *  block `physIdx` starting at row `within`. Functional slice_update:
   *  the pool tensors are single-referenced here, so mlx donates the
   *  buffer and the write is in-place in the steady state. */
  writeBlock(physIdx: number, k: MlxArray, v: MlxArray, within: number): void {
    if (this.#codec) {
      const enc = this.#codec.encode(k, v);
      const replace = (target: MlxArray, input: MlxArray): MlxArray => {
        const result = ops.sliceUpdate(target, input, [physIdx, 0, within, 0],
          [physIdx + 1, input.shape[1]!, within + input.shape[2]!, input.shape[3]!]);
        target.dispose(); return result;
      };
      try {
        this.keys = replace(this.keys, enc.kIdx); this.keyScales = replace(this.keyScales!, enc.kScales);
        this.keyBiases = replace(this.keyBiases!, enc.kZeros);
        this.values = replace(this.values, enc.vPacked); this.valueScales = replace(this.valueScales!, enc.vScales);
      } finally { disposeResources([enc.kIdx, enc.kScales, enc.kZeros, enc.vPacked, enc.vScales]); }
      return;
    }
    if (this.quantization) {
      const { bits, groupSize } = this.quantization;
      const kq = ops.quantize(k, groupSize, bits), vq = ops.quantize(v, groupSize, bits);
      const replace = (target: MlxArray, input: MlxArray): MlxArray => {
        const result = ops.sliceUpdate(target, input, [physIdx, 0, within, 0],
          [physIdx + 1, input.shape[1]!, within + input.shape[2]!, input.shape[3]!]);
        target.dispose(); return result;
      };
      try {
        this.keys = replace(this.keys, kq.packed); this.keyScales = replace(this.keyScales!, kq.scales); this.keyBiases = replace(this.keyBiases!, kq.biases);
        this.values = replace(this.values, vq.packed); this.valueScales = replace(this.valueScales!, vq.scales); this.valueBiases = replace(this.valueBiases!, vq.biases);
      } finally { disposeResources([kq.packed, kq.scales, kq.biases, vq.packed, vq.scales, vq.biases]); }
      return;
    }
    const l = k.shape[2]!;
    const [, H, , kD] = this.keys.shape as [number, number, number, number];
    const vD = this.values.shape[3]!;
    const k2 = ops.sliceUpdate(
      this.keys, k, [physIdx, 0, within, 0], [physIdx + 1, H, within + l, kD]);
    this.keys.dispose();
    this.keys = k2;
    const v2 = ops.sliceUpdate(
      this.values, v, [physIdx, 0, within, 0], [physIdx + 1, H, within + l, vD]);
    this.values.dispose();
    this.values = v2;
  }

  /** Gather `blockTable`'s blocks in logical order into one contiguous
   *  [1, H, nb·blockSize, D] pair (the fetch copy). Caller owns both. */
  gather(blockTable: number[]): [MlxArray, MlxArray] {
    if (this.#codec) throw new Error("TurboQuant pages gather through decode (gatherDecoded)");
    const idx = MlxArray.fromInt32(Int32Array.from(blockTable), [blockTable.length]);
    const pick = (pool: MlxArray): MlxArray => pickBlocks(pool, idx);
    const read = (data: MlxArray, scales?: MlxArray, biases?: MlxArray) => {
      const packed = pick(data);
      if (!this.quantization) return packed;
      using owned = packed; using s = pick(scales!), b = pick(biases!);
      return ops.dequantize(owned, s, b, { ...this.quantization, mode: "affine" });
    };
    const k = read(this.keys, this.keyScales, this.keyBiases);
    const v = read(this.values, this.valueScales, this.valueBiases);
    idx.dispose();
    return [k, v];
  }

  /** TurboQuant pages: write encoded positions (taking ownership) into
   *  block `physIdx` from row `within`. */
  writeCodes(physIdx: number, codes: TurboQuantTensor, within: number): void {
    const replace = (target: MlxArray, input: MlxArray): MlxArray => {
      const result = ops.sliceUpdate(target, input, [physIdx, 0, within, 0],
        [physIdx + 1, input.shape[1]!, within + input.shape[2]!, input.shape[3]!]);
      target.dispose(); return result;
    };
    try {
      this.keys = replace(this.keys, codes.kIdx); this.keyScales = replace(this.keyScales!, codes.kScales);
      this.keyBiases = replace(this.keyBiases!, codes.kZeros);
      this.values = replace(this.values, codes.vPacked); this.valueScales = replace(this.valueScales!, codes.vScales);
    } finally { disposeResources([codes.kIdx, codes.kScales, codes.kZeros, codes.vPacked, codes.vScales]); }
  }

  /** TurboQuant pages: the first `length` positions of `blockTable`'s blocks,
   *  decoded by the codec with values in their own domain or left rotated
   *  (`TurboQuantKVCache`'s decode, per position). Caller owns both. */
  gatherDecoded(blockTable: number[], length: number, rotated: boolean): [MlxArray, MlxArray] {
    if (!this.#codec) throw new Error("only TurboQuant pages decode");
    using idx = MlxArray.fromInt32(Int32Array.from(blockTable), [blockTable.length]);
    const codes: TurboQuantTensor = {
      kIdx: pickBlocks(this.keys, idx), kScales: pickBlocks(this.keyScales!, idx), kZeros: pickBlocks(this.keyBiases!, idx),
      vPacked: pickBlocks(this.values, idx), vScales: pickBlocks(this.valueScales!, idx),
    };
    try { return this.#codec.decode(codes, length, this.headDim, rotated); }
    finally { disposeResources([codes.kIdx, codes.kScales, codes.kZeros, codes.vPacked, codes.vScales]); }
  }

  arrays(): MlxArray[] {
    return [this.keys, this.values, this.keyScales, this.keyBiases, this.valueScales, this.valueBiases].filter((a): a is MlxArray => !!a);
  }
  dispose(): void {
    disposeResources([this.keyScales, this.keyBiases, this.valueScales, this.valueBiases].filter((a): a is MlxArray => !!a));
    this.keys.dispose();
    this.values.dispose();
    this.#free = [];
  }
}

/** One plane's blocks `idx` in logical order, [1, H, blocks·blockSize, width]
 *  (the fetch copy). Caller owns it. */
function pickBlocks(pool: MlxArray, idx: MlxArray): MlxArray {
  const took = ops.takeAxis(pool, idx, 0); // [nb, H, bs, D]
  const [nb, H, bs, D] = took.shape as [number, number, number, number];
  const t = ops.transposeAxes(took, [1, 0, 2, 3]); // [H, nb, bs, D] (view)
  took.dispose();
  const out = ops.reshape(t, [1, H, nb * bs, D]); // materializes seq order
  t.dispose();
  return out;
}

/** Whether the direct paged kernel reads this page format: bf16 pages, and
 *  affine pages whose codes never straddle a 32-bit word. TurboQuant pages and
 *  other widths read gathered. */
function directReadable(quantization: PagedQuantization | undefined, turbo: PagedTurboQuant | undefined): boolean {
  return !turbo && (!quantization || 32 % quantization.bits === 0);
}

/** Whether the paged lego the composition's paging `paged` and KV scheme `kv`
 *  name has a compiled decode form: gathered pages do (a concat slot), and so
 *  do direct pages the kernel does not read (TurboQuant, affine widths that
 *  straddle a 32-bit word), which read gathered. Direct pages the kernel reads
 *  have none: the kernel's partitions follow the context length, which a
 *  shapeless recorded graph cannot hold, and the lego reads one way, so a
 *  composition with them decodes eagerly (`resolveComposition`). Per-layer
 *  affine schemes leave their unlisted layers bf16, which the kernel reads. */
export function pagedDecodeCompiles(paged: PagedKvComposition, kv: KvStorageScheme): boolean {
  if (!paged.direct) return true;
  return kv.kind === "turbo" || (kv.kind === "affine" && !directReadable({ bits: kv.bits, groupSize: kv.groupSize }, undefined));
}

/** Cache implementation over a BlockPool. Same values as a plain KVCache
 *  at every step (parity-gated); only the physical arrangement differs.
 *  The pool allocates lazily on the first write (KVCache's lazy-alloc
 *  shape): head count / head dims / dtype come from the first k/v pair,
 *  so the wiring (maybePageKv) needs no per-model shape plumbing.
 *
 *  Reads: each owns an immutable view of the blocks as of its append
 *  (`pagedAttentionView`). Decode attends its one query, and a window its
 *  queries under the causal mask, with the read `direct` (the composition's
 *  `pagedKv.direct`) fixes at construction: the direct Metal read from the
 *  blocks for at most eight queries, or the gathered blocks through the stock
 *  fused SDPA (decode with no mask, a window with the causal mask). A window of
 *  more than eight queries gathers under either.
 *
 *  The other reads are `KVCache`'s over the gathered blocks, so bf16 pages read
 *  bit for bit as the bf16 lego they replace: a committed span is the window
 *  read (as `KVCache` qualifies it); the bidirectional and encoder windows
 *  append, gather and attend under `KVCache`'s masks; a block read attends the
 *  gathered positions and the block's own keys with no mask; the donor rows are
 *  the gathered positions. Affine pages gather dequantized.
 *
 *  TurboQuant pages read as `TurboQuantKVCache` reads its storage: the
 *  window decoded per position by the codec, in the domain the layer's kernel
 *  set reads (`PagedTurboQuant.kernels`), attended by that set (no mask for
 *  decode, the causal mask for a window); the other reads take the window
 *  decoded to the values' own domain. The direct read takes bf16 pages and
 *  affine widths that divide 32 bits; other pages read gathered whatever the
 *  composition says.
 *
 *  Compiled decode, gathered pages: a concat slot. The stored positions are
 *  gathered (and dequantized) outside the recorded graph, as the decode read
 *  gathers them; in it the new position is stored as the pages store it
 *  (quantized and dequantized again on affine pages) and joined to them, and
 *  the fused SDPA reads the joined window with no mask, the gathered decode
 *  read. The row leaves the graph as it was appended; the write after the step
 *  appends it to the pages. Direct pages have no compiled form
 *  (`pagedDecodeCompiles`): their read is a custom kernel whose partitions
 *  follow the context length, which a shapeless recorded graph cannot hold, so
 *  their composition decodes eagerly and this cache refuses a compiled slot. */
export class PagedKVCache implements CommittedAttentionCache, BidirectionalAttentionCache, EncoderAttentionCache, BlockAttentionCache, CompiledDecodeCache {
  /** Distinct storage kind; the row adapter preserves its block pools. */
  signature(): string { return "kv:paged"; }
  /** Matches KVCache.STEP: v1's growth granularity is a permutation of
   *  today's 256-token step into fixed reusable slots, not a new tuning
   *  axis (--paged-kv-block-size overrides for experiments). */
  static readonly DEFAULT_BLOCK_SIZE = 256;
  /** Set only by compiled-decode trace adapters (see Cache); a real cache
   *  leaves it unset. */
  readonly ropeOffsetArr?: MlxArray;
  offset = 0;
  /** Logical block order → physical pool slot. */
  blockTable: number[] = [];
  pool: BlockPool | null = null;

  /** The direct Metal read, where the page format takes it (see the class). */
  readonly direct: boolean;

  constructor(
    /** Tokens this cache must be able to hold (prompt + maxTokens). */
    readonly capacityTokens: number,
    readonly blockSize: number,
    direct = false,
    /** Affine pages; absent with `turbo` absent: bf16 pages. */
    readonly quantization?: PagedQuantization,
    /** The masks the bidirectional and encoder reads lease. */
    readonly masks = new AttentionMasks(),
    /** TurboQuant pages. */
    readonly turbo?: PagedTurboQuant,
  ) {
    if (quantization && turbo) throw new Error("pages store one format: affine or TurboQuant");
    this.direct = direct && directReadable(quantization, turbo);
  }

  clone(): PagedKVCache {
    const copy = new PagedKVCache(this.capacityTokens, this.blockSize, this.direct, this.quantization, this.masks, this.turbo);
    copy.offset = this.offset;
    copy.blockTable = [...this.blockTable];
    copy.pool = this.pool?.clone() ?? null;
    return copy;
  }

  get #blockSize(): number {
    return this.blockSize;
  }

  /** Blocks needed to hold `n` tokens. */
  #blocksFor(n: number): number {
    return Math.ceil(n / this.#blockSize);
  }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    this.append(k, v);
    if (this.turbo) return this.#turboRead(unmaskedLease);
    return pagedRead(pagedAttentionView(this.pool!, [...this.blockTable], this.offset, this.direct), { mode: "", arr: null });
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    this.append(k, v);
    if (this.turbo) return this.#turboRead(causalLease);
    return pagedRead(pagedAttentionView(this.pool!, [...this.blockTable], this.offset, this.direct), { mode: "causal", arr: null });
  }

  /** TurboQuant pages: the layer's kernel set over the window it decodes. */
  #turboRead(mask: MaskLease): AttentionRead {
    const table = [...this.blockTable], length = this.offset, pool = this.pool!;
    return this.turbo!.kernels.read({
      decoded: () => pool.gatherDecoded(table, length, false),
      rotated: () => {
        const [keys, values] = pool.gatherDecoded(table, length, true);
        return { keys, values, restore: tq.unrotateValues };
      },
    }, mask);
  }

  /** The window read: `KVCache`'s committed read, over the same positions. */
  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead {
    return this.appendWindow(k, v);
  }

  /** `KVCache`'s vision prefill read: the causal mask OR'd with the image
   * block overlay, over the gathered first window. */
  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    const L = k.shape[2]!;
    const mask = this.masks.lease("bidirectional:none", `${L}`, () => bidirMask(L, null, bidirectional), bidirectional);
    return withLease(mask, held => {
      const [keys, values] = this.appendAndGather(k, v);
      return sdpaRead(keys, values, held);
    });
  }

  /** `KVCache`'s encoder read: the encoder window's mask over the gathered
   * first window. */
  appendEncoderWindow(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    return withLease(encoderWindowMask(this.masks, k.shape[2]!, bidirectional), mask => {
      const [keys, values] = this.appendAndGather(k, v);
      return sdpaRead(keys, values, mask);
    });
  }

  /** `KVCache`'s block read: the gathered positions in order, then the block's
   * keys and values, with no mask. Nothing is appended. */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead {
    const [storedK, storedV] = this.#gathered();
    let keys: MlxArray, values: MlxArray;
    try {
      keys = ops.concatAxis([storedK, k], 2);
      try { values = ops.concatAxis([storedV, v], 2); }
      catch (error) { keys.dispose(); throw error; }
    } finally { storedK.dispose(); storedV.dispose(); }
    return sdpaRead(keys, values, unmaskedLease);
  }

  /** The gathered positions, as `KVCache` hands its donor rows out. */
  captureDonorRows(): KvDonorRows {
    const [keys, values] = this.#gathered();
    return { keys, values, offsets: [this.offset], starts: [0], ends: [this.offset] };
  }

  get attentionState(): this | undefined { return this.direct || this.quantization ? this : undefined; }
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView {
    this.append(k, v);
    return pagedAttentionView(this.pool!, [...this.blockTable], this.offset, this.direct);
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.appendAndGather(k, v); }

  /** Append, then the keys and values gathered from the blocks up to the new
   * offset (dequantized for affine pages), each [1, H, offset, D]; the caller
   * owns both. What the joined window read of `PagedKvRows` attends. */
  appendAndGather(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    this.append(k, v);
    return this.#gathered();
  }

  /** The keys and values gathered from the blocks up to the offset
   * (dequantized for affine pages), each [1, H, offset, D]; the caller owns
   * both. */
  #gathered(): [MlxArray, MlxArray] {
    if (!this.pool) throw new Error("paged cache is empty");
    if (this.turbo) return this.pool.gatherDecoded(this.blockTable, this.offset, false);
    const H = this.pool.keys.shape[1]!, kD = this.pool.headDim, vD = this.pool.vHeadDim;
    const [gk, gv] = this.pool.gather(this.blockTable);
    const keys = gk.slice([0, 0, 0, 0], [1, H, this.offset, kD]);
    const values = gv.slice([0, 0, 0, 0], [1, H, this.offset, vD]);
    gk.dispose(); gv.dispose();
    return [keys, values];
  }

  append(k: MlxArray, v: MlxArray): void {
    const L = k.shape[2]!;
    const [, H, , kD] = k.shape as [number, number, number, number];
    const vD = v.shape[3]!;
    if (!this.pool)
      this.pool = new BlockPool({
        numBlocks: poolBlocksFor(this.capacityTokens, this.blockSize),
        blockSize: this.blockSize,
        numKvHeads: H,
        headDim: kD,
        vHeadDim: vD,
        dtype: k.dtype, quantization: this.quantization,
        ...(this.turbo ? { turbo: { kBits: this.turbo.kBits, vBits: this.turbo.vBits, fusedDecode: this.turbo.fusedDecode } } : {}),
      });
    // Write, splitting the incoming L along block boundaries. Blocks past
    // the current tail allocate from the free list as they're reached.
    let written = 0;
    while (written < L) {
      const pos = this.offset + written;
      const bi = Math.floor(pos / this.#blockSize);
      const within = pos % this.#blockSize;
      while (this.blockTable.length <= bi) {
        if (!this.pool.freeBlocks) this.pool.grow(Math.max(this.pool.numBlocks + 1, Math.ceil(this.pool.numBlocks * 1.5)));
        this.blockTable.push(this.pool.alloc());
      }
      const l = Math.min(this.#blockSize - within, L - written);
      // Full-range pieces skip the slice (fresh-view slice would be a
      // gratuitous op); partial pieces slice the [written, written+l) rows.
      if (l === L && written === 0) {
        this.pool.writeBlock(this.blockTable[bi]!, k, v, within);
      } else {
        const kp = k.slice([0, 0, written, 0], [1, H, written + l, kD]);
        const vp = v.slice([0, 0, written, 0], [1, H, written + l, vD]);
        this.pool.writeBlock(this.blockTable[bi]!, kp, vp, within);
        kp.dispose();
        vp.dispose();
      }
      written += l;
    }
    this.offset += L;

  }

  /** Compiled decode: nothing to prepare on the host; the pages grow when the
   *  step's row is appended. */
  prepareDecodeStep(): DecodeStepPlan {
    if (!this.pool) throw new Error("compiled decode on an empty cache");
    return { fetch: "concat", writePos: this.offset, activeLen: this.offset };
  }

  decodePhase(): DecodeStepPlan["fetch"] { return "concat"; }

  /** TurboQuant pages take TurboQuant storage's slot (the codes leave the
   *  graph); bf16 and affine pages the paged one (the row leaves it). */
  decodeSlot(_plan: DecodeStepPlan): DecodeSlot {
    if (this.direct) throw new Error("direct pages have no compiled decode form; their composition decodes eagerly (pagedDecodeCompiles)");
    return this.turbo ? turboQuantDecodeSlot(this.offset, this.turbo.kBits, this.turbo.vBits, this.turbo.kernels)
      : pagedDecodeSlot(this.offset, this.quantization);
  }

  /** The stored positions gathered (dequantized on affine pages, decoded in the
   *  kernel set's domain on TurboQuant pages), owned by the step. */
  decodeInputs(_plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[] {
    const [keys, values] = this.turbo
      ? this.pool!.gatherDecoded(this.blockTable, this.offset, this.turbo.kernels.fetch === "rotated") : this.#gathered();
    return [step.own(keys), step.own(values)];
  }

  /** The write half (taking ownership of `outputs`): bf16 and affine pages
   *  append the step's row as an ordinary append does; TurboQuant pages store
   *  the step's codes, packed as the codec packs them. Returns the pages to
   *  evaluate with the step. */
  commitDecodeStep(_slot: DecodeSlot, outputs: MlxArray[]): MlxArray[] {
    if (this.turbo) {
      const [kCodes, kScales, kZeros, vCodes, vScales] = outputs as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
      const kIdx = this.turbo.kBits < 8 ? tq.packBits(kCodes, this.turbo.kBits) : kCodes;
      if (kIdx !== kCodes) kCodes.dispose();
      const vPacked = this.turbo.vBits < 8 ? tq.packBits(vCodes, this.turbo.vBits) : vCodes;
      if (vPacked !== vCodes) vCodes.dispose();
      this.#store({ kIdx, kScales, kZeros, vPacked, vScales });
      return this.pool!.arrays();
    }
    const [k, v] = outputs as [MlxArray, MlxArray];
    try { this.append(k, v); } finally { k.dispose(); v.dispose(); }
    return this.pool!.arrays();
  }

  /** One position's TurboQuant codes (taking ownership), stored at the offset. */
  #store(codes: TurboQuantTensor): void {
    const pool = this.pool!, bi = Math.floor(this.offset / this.blockSize), within = this.offset % this.blockSize;
    while (this.blockTable.length <= bi) {
      if (!pool.freeBlocks) pool.grow(Math.max(pool.numBlocks + 1, Math.ceil(pool.numBlocks * 1.5)));
      this.blockTable.push(pool.alloc());
    }
    pool.writeCodes(this.blockTable[bi]!, codes, within);
    this.offset += 1;
  }

  /** Same mask policy as KVCache.makeMask (it reads only offset). */
  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && N <= windowSize) return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Owned planes materialized at prefill and immutable publication boundaries. */
  state(): MlxArray[] {
    return this.pool ? this.pool.arrays() : [];
  }

  isTrimmable(): boolean {
    return true;
  }

  /** Rewind the last n tokens and return now-unoccupied tail blocks to
   *  the free list. Stale bytes past offset are never read (fetch slices
   *  to offset; writes cover exact ranges) — the KVCache padding
   *  invariant, block-shaped. */
  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
    const need = this.#blocksFor(this.offset);
    while (this.blockTable.length > need) this.pool!.free(this.blockTable.pop()!);
  }

  dispose(): void {
    // The cache owns its pool in v1 (one sequence per pool).
    this.pool?.dispose();
    this.pool = null;
    this.blockTable = [];
    this.offset = 0;
    this.masks.clear();
  }
}

/** A read over one block view under a fixed string mask. Takes ownership of
 * `view`. */
function pagedRead(view: KvAttentionView, mask: Mask): AttentionRead {
  return { attend: (q, scale) => view.attend(q, scale, mask), dispose: () => view.dispose() };
}

/** Size a pool for one request: capacity tokens rounded up to whole
 *  blocks. Exported for the wiring in generate.ts (maybePageKv). */
export function poolBlocksFor(capacityTokens: number, blockSize: number): number {
  return Math.max(1, Math.ceil(capacityTokens / blockSize));
}

/** A paged cache inside a compiled decode trace: the new position joins the
 *  gathered prefix as the pages store it (affine pages: quantized, then
 *  dequantized as the gather dequantizes them), read with no mask by the fused
 *  SDPA; the row as appended is the closure output. */
class TracedPagedKVCache implements DecodeTrace {
  outs: MlxArray[] = [];
  constructor(
    readonly offset: number,
    readonly quantization: PagedQuantization | undefined,
    readonly prefixKeys: MlxArray,
    readonly prefixValues: MlxArray,
    readonly ropeOffsetArr: MlxArray,
  ) {}

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    // same-shape reshape: owned aliases that survive the caller's dispose of k and v
    this.outs = [ops.reshape(k, k.shape), ops.reshape(v, v.shape)];
    const stored = (row: MlxArray): MlxArray => {
      if (!this.quantization) return ops.reshape(row, row.shape);
      const { bits, groupSize } = this.quantization;
      const q = ops.quantize(row, groupSize, bits);
      try { return ops.dequantize(q.packed, q.scales, q.biases, { bits, groupSize, mode: "affine" }); }
      finally { q.packed.dispose(); q.scales.dispose(); q.biases.dispose(); }
    };
    const join = (prefix: MlxArray, row: MlxArray): MlxArray => {
      using held = stored(row);
      return ops.concatAxis([prefix, held], 2);
    };
    const keys = join(this.prefixKeys, k);
    let values: MlxArray;
    try { values = join(this.prefixValues, v); } catch (error) { keys.dispose(); throw error; }
    return sdpaRead(keys, values, unmaskedLease);
  }

  signature(): string { return "kv:paged-trace"; }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return false; }
  trim(): void { throw new Error("a compiled decode trace is not trimmed"); }
  dispose(): void {}
}

/** The concat slot of a paged cache at `offset` whose pages store `quantization` (bf16 when absent). */
export function pagedDecodeSlot(offset: number, quantization: PagedQuantization | undefined): DecodeSlot {
  return {
    key: quantization ? `paged-cat:${quantization.bits}:${quantization.groupSize}` : "paged-cat:bf16", fetch: "concat", inputs: 2, outputs: 2,
    trace: (inputs, ropeOffset) => new TracedPagedKVCache(offset, quantization, inputs[0]!, inputs[1]!, ropeOffset),
  };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Paged.Cache
