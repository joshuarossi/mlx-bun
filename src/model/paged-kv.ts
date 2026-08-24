// Paged KV cache — vLLM-style block-pool storage behind the standard Cache
// interface (docs/design/paged-kv-cache.md). OPTIONAL and default-off
// (`--paged-kv` / GenerateOptions.pagedKv); v1 scope is serial batch=1
// decode on Gemma4-family plain full-attention layers, bf16 only.
//
// Storage: K/V live in fixed-size per-layer pool tensors
// [numBlocks, H_kv, blockSize, headDim]; a host-side block table maps the
// sequence's logical block order to physical pool slots. Writes go through
// ops.sliceUpdate into the tail block; reads gather the occupied blocks
// back into ONE contiguous [1, H, S, D] pair (ops.takeAxis over the pool's
// block axis + transpose + reshape) and hand that to the unchanged
// ops.sdpa call site — identical bytes to what a plain KVCache would have
// fetched, so the paged path is gated bit-exact, not KL-tolerated
// (tests/paged-kv-parity.test.ts). The gather IS the cost: a full K/V copy
// per step, pure bandwidth tax at batch=1 — v1 ships the abstraction for
// the batched/CoW follow-ups, not a speed win (see the design doc's
// Motivation, which says this honestly).
//
// Deliberately NOT a KVCache subclass (the TurboQuantKVCache reasoning):
// every instanceof gate in the tree — CompiledDecode.supports, the batch
// gateway's #modelCachesBatchable, generated forwards' #matches() — must
// EXCLUDE paged caches and fall back to the monolith/uncompiled path.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { createCausalMask, type Cache, type Mask } from "./gemma4-base";

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
export class BlockPool {
  keys: MlxArray;
  values: MlxArray;
  readonly numBlocks: number;
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
  }) {
    this.numBlocks = opts.numBlocks;
    this.blockSize = opts.blockSize;
    this.keys = ops.zeros(
      [opts.numBlocks, opts.numKvHeads, opts.blockSize, opts.headDim], opts.dtype);
    this.values = ops.zeros(
      [opts.numBlocks, opts.numKvHeads, opts.blockSize, opts.vHeadDim ?? opts.headDim],
      opts.dtype);
    // LIFO free list, low indices first — deterministic layout for tests.
    this.#free = Array.from({ length: opts.numBlocks }, (_, i) => opts.numBlocks - 1 - i);
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
    const k = pick(this.keys);
    const v = pick(this.values);
    idx.dispose();
    return [k, v];
  }

  dispose(): void {
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
  /** Distinct kind: paged layout is serial-only and never merges into a
   *  batch, so no capability guard should ever match it as plain. */
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
  ) {}

  get #blockSize(): number {
    return this.blockSize;
  }

  /** Blocks needed to hold `n` tokens. */
  #blocksFor(n: number): number {
    return Math.ceil(n / this.#blockSize);
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
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
        dtype: k.dtype,
      });
    // Write, splitting the incoming L along block boundaries. Blocks past
    // the current tail allocate from the free list as they're reached.
    let written = 0;
    while (written < L) {
      const pos = this.offset + written;
      const bi = Math.floor(pos / this.#blockSize);
      const within = pos % this.#blockSize;
      while (this.blockTable.length <= bi) this.blockTable.push(this.pool.alloc());
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

    // Fetch: gather occupied blocks contiguous, slice to the live prefix.
    const nb = this.#blocksFor(this.offset);
    const [gk, gv] = this.pool.gather(this.blockTable.slice(0, nb));
    const keys = gk.slice([0, 0, 0, 0], [1, H, this.offset, kD]);
    const values = gv.slice([0, 0, 0, 0], [1, H, this.offset, vD]);
    gk.dispose();
    gv.dispose();
    return [keys, values];
  }

  /** Same mask policy as KVCache.makeMask (it reads only offset). */
  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && N <= windowSize) return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Pool tensors — what a prefill-chunk boundary must materialize.
   *  NOT prompt-cache-compatible in v1 (cloneKvCaches never sees paged
   *  caches; the serve lane bypasses take/put for paged requests). */
  state(): MlxArray[] {
    return this.pool ? [this.pool.keys, this.pool.values] : [];
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
