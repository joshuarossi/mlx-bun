// Paged KV storage behind the common cache and attention interfaces.
// Full-attention pools support bf16 and affine KV4/KV8. The established
// gather + SDPA arm is the numerical control; direct Metal reads are Lab.
// Published views and SSD snapshots own immutable buffers independently of
// appends, row membership and RAM eviction.

import { disposeResources } from "../../engine/resources";
import { pagedAttentionView } from "./paged-attention";
import { runtimeFlag } from "../../runtime-config";
import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { createCausalMask, type Cache, type Mask, type KvAttentionView } from "../../model/gemma4-base";

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

/** Per-layer block arena. One K and one V pool tensor, mlx-owned
 *  (ops.zeros — no host-pointer alignment/dtor hazards), shaped
 *  [numBlocks, H, blockSize, D]. alloc()/free() manage physical slot
 *  indices; the owning PagedKVCache writes/gathers through the pool. */
export interface PagedQuantization { bits: 4 | 8; groupSize: number }

export class BlockPool {
  keyScales?: MlxArray; keyBiases?: MlxArray;
  valueScales?: MlxArray; valueBiases?: MlxArray;
  readonly headDim: number;
  readonly vHeadDim: number;
  readonly dtype: Dtype;
  readonly quantization?: PagedQuantization;
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
  }, source?: BlockPool) {
    this.headDim = opts.headDim; this.vHeadDim = opts.vHeadDim ?? opts.headDim;
    this.dtype = opts.dtype; this.quantization = opts.quantization;
    this.numBlocks = opts.numBlocks;
    this.blockSize = opts.blockSize;
    this.keys = source ? ops.contiguous(source.keys) : ops.zeros(
      [opts.numBlocks, opts.numKvHeads, opts.blockSize, opts.headDim], opts.dtype);
    this.values = source ? ops.contiguous(source.values) : ops.zeros(
      [opts.numBlocks, opts.numKvHeads, opts.blockSize, opts.vHeadDim ?? opts.headDim],
      opts.dtype);
    if (source?.quantization) {
      this.keyScales = ops.contiguous(source.keyScales!); this.keyBiases = ops.contiguous(source.keyBiases!);
      this.valueScales = ops.contiguous(source.valueScales!); this.valueBiases = ops.contiguous(source.valueBiases!);
    } else if (this.quantization) {
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
      vHeadDim: this.vHeadDim, dtype: this.dtype, quantization: this.quantization }, this);
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
    if (this.quantization) {
      this.keyScales = grow(this.keyScales!); this.keyBiases = grow(this.keyBiases!);
      this.valueScales = grow(this.valueScales!); this.valueBiases = grow(this.valueBiases!);
    }
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
    const idx = MlxArray.fromInt32(Int32Array.from(blockTable), [blockTable.length]);
    const pick = (pool: MlxArray): MlxArray => {
      const took = ops.takeAxis(pool, idx, 0); // [nb, H, bs, D]
      const [nb, H, bs, D] = took.shape as [number, number, number, number];
      const t = ops.transposeAxes(took, [1, 0, 2, 3]); // [H, nb, bs, D] (view)
      took.dispose();
      const out = ops.reshape(t, [1, H, nb * bs, D]); // materializes seq order
      t.dispose();
      return out;
    };
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

/** Cache implementation over a BlockPool. Same values as a plain KVCache
 *  at every step (parity-gated); only the physical arrangement differs.
 *  The pool allocates lazily on the first write (KVCache's lazy-alloc
 *  shape): head count / head dims / dtype come from the first k/v pair,
 *  so the wiring (maybePageKv) needs no per-model shape plumbing. */
export class PagedKVCache implements Cache {
  /** Distinct storage kind; the row adapter preserves its block pools. */
  signature(): string { return "kv:paged"; }
  /** Matches KVCache.STEP: v1's growth granularity is a permutation of
   *  today's 256-token step into fixed reusable slots, not a new tuning
   *  axis (--paged-kv-block-size overrides for experiments). */
  static readonly DEFAULT_BLOCK_SIZE = 256;
  /** Compiled-decode trace adapters never wrap paged caches (see Cache);
   *  always unset here. */
  readonly ropeOffsetArr?: MlxArray;
  offset = 0;
  /** Logical block order → physical pool slot. */
  blockTable: number[] = [];
  pool: BlockPool | null = null;

  constructor(
    /** Tokens this cache must be able to hold (prompt + maxTokens). */
    readonly capacityTokens: number,
    readonly blockSize: number,
    readonly direct = runtimeFlag("MLX_BUN_PAGED_ATTN", false),
    readonly quantization?: PagedQuantization,
  ) {}

  clone(): PagedKVCache {
    const copy = new PagedKVCache(this.capacityTokens, this.blockSize, this.direct, this.quantization);
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

  get attentionState(): this | undefined { return this.direct || this.quantization ? this : undefined; }
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView {
    this.append(k, v);
    return pagedAttentionView(this.pool!, [...this.blockTable], this.offset, this.direct);
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    this.append(k, v);
    const H = this.pool!.keys.shape[1]!, kD = this.pool!.headDim, vD = this.pool!.vHeadDim;
    const [gk, gv] = this.pool!.gather(this.blockTable);
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
  }
}

/** Size a pool for one request: capacity tokens rounded up to whole
 *  blocks. Exported for the wiring in generate.ts (maybePageKv). */
export function poolBlocksFor(capacityTokens: number, blockSize: number): number {
  return Math.max(1, Math.ceil(capacityTokens / blockSize));
}
