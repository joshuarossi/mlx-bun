// Serial GLM-5.2 compressed attention state.
//
// One MLACache corresponds to one decoder layer. It stores only the
// checkpoint-native compressed state:
//   - latent: [B, T, kv_lora_rank]
//   - decoupled RoPE key: [B, T, qk_rope_head_dim]
//   - optional DSA index key: [B, T, index_head_dim]
//
// G2 intentionally implements the smallest correctness surface. Dynamic-row
// merge/extract and persistence belong to G7; capacity growth and paging are
// performance concerns, not part of this class.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  createCausalMask,
  type Cache,
  type Mask,
} from "./gemma4-base";

export interface DSAIndexGeometry {
  readonly headDim: number;
}

export interface MLACacheGeometry {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  readonly dsa?: DSAIndexGeometry;
  /** Optional hard context bound from the model config. */
  readonly maxTokens?: number;
}

export interface MLACompressedState {
  /** Caller-owned view [B, T, kv_lora_rank]. */
  latent: MlxArray;
  /** Caller-owned view [B, T, qk_rope_head_dim]. */
  rope: MlxArray;
  /** Caller-owned view [B, T, index_head_dim], when enabled. */
  dsa: MlxArray | null;
}

function positiveInteger(name: string, value: number): void {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new Error(`${name} must be a positive safe integer`);
}

function safeProduct(label: string, values: readonly number[]): number {
  let product = 1;
  for (const value of values) {
    if (!Number.isSafeInteger(value) || value < 0)
      throw new Error(`${label}: invalid dimension ${String(value)}`);
    product *= value;
    if (!Number.isSafeInteger(product))
      throw new Error(`${label} exceeds the safe integer range`);
  }
  return product;
}

function validateF32(
  name: string,
  array: MlxArray,
  expected: readonly number[],
): void {
  if (array.dtype !== Dtype.float32)
    throw new Error(`${name} must be float32`);
  const shape = array.shape;
  if (
    shape.length !== expected.length ||
    shape.some((dimension, index) => dimension !== expected[index])
  ) {
    throw new Error(
      `${name} shape ${JSON.stringify(shape)} != ${JSON.stringify(expected)}`,
    );
  }
}

function appendAlongTokens(current: MlxArray | null, update: MlxArray): MlxArray {
  if (!current) return ops.contiguous(update);
  return ops.concatAxis([current, update], 1);
}

function trimToTokens(array: MlxArray, tokens: number): MlxArray {
  const start = array.shape.map(() => 0);
  const stop = [...array.shape];
  stop[1] = tokens;
  const view = array.slice(start, stop);
  const exact = ops.contiguous(view);
  view.dispose();
  return exact;
}

/** Optional DSA index-key state owned by one MLACache. */
export class DSAIndexCache {
  readonly headDim: number;
  data: MlxArray | null = null;
  offset = 0;
  batchSize: number | null = null;

  constructor(geometry: DSAIndexGeometry) {
    positiveInteger("DSA headDim", geometry.headDim);
    this.headDim = geometry.headDim;
  }

  validateAppend(value: MlxArray, batch: number, tokens: number): void {
    validateF32(
      "DSA index state",
      value,
      [batch, tokens, this.headDim],
    );
    if (this.batchSize !== null && batch !== this.batchSize)
      throw new Error(`DSA batch size ${batch} != existing ${this.batchSize}`);
  }

  append(value: MlxArray, batch: number, tokens: number): void {
    this.validateAppend(value, batch, tokens);
    const next = appendAlongTokens(this.data, value);
    this.data?.dispose();
    this.data = next;
    this.batchSize ??= batch;
    this.offset += tokens;
  }

  fetch(): MlxArray {
    if (!this.data || this.batchSize === null || this.offset === 0)
      throw new Error("DSA index cache is empty");
    return this.data.slice(
      [0, 0, 0],
      [this.batchSize, this.offset, this.headDim],
    );
  }

  get byteLength(): number {
    if (this.batchSize === null) return 0;
    return safeProduct(
      "DSA cache byte length",
      [this.batchSize, this.offset, this.headDim, 4],
    );
  }

  state(): MlxArray[] {
    return this.data ? [this.data] : [];
  }

  trim(n: number): void {
    if (!Number.isSafeInteger(n) || n < 0 || n > this.offset)
      throw new RangeError(`cannot trim ${n} tokens from DSA offset ${this.offset}`);
    if (n === 0) return;
    const nextOffset = this.offset - n;
    if (nextOffset === 0) {
      this.dispose();
      return;
    }
    const next = trimToTokens(this.data!, nextOffset);
    this.data!.dispose();
    this.data = next;
    this.offset = nextOffset;
  }

  dispose(): void {
    this.data?.dispose();
    this.data = null;
    this.offset = 0;
    this.batchSize = null;
  }
}

export class Glm52Cache implements Cache {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  readonly maxTokens: number;
  readonly dsa: DSAIndexCache | null;

  latent: MlxArray | null = null;
  rope: MlxArray | null = null;
  offset = 0;
  batchSize: number | null = null;

  constructor(geometry: MLACacheGeometry) {
    positiveInteger("MLA kvLoraRank", geometry.kvLoraRank);
    positiveInteger("MLA ropeHeadDim", geometry.ropeHeadDim);
    if (geometry.maxTokens !== undefined)
      positiveInteger("MLA maxTokens", geometry.maxTokens);
    this.kvLoraRank = geometry.kvLoraRank;
    this.ropeHeadDim = geometry.ropeHeadDim;
    this.maxTokens = geometry.maxTokens ?? Number.MAX_SAFE_INTEGER;
    this.dsa = geometry.dsa ? new DSAIndexCache(geometry.dsa) : null;
  }

  /**
   * Append one serial prefill/decode block without expanding it to per-head
   * K/V. Inputs remain caller-owned.
   */
  append(latent: MlxArray, rope: MlxArray, dsa: MlxArray | null = null): void {
    const latentShape = latent.shape;
    if (latentShape.length !== 3)
      throw new Error(`MLA latent must have rank 3 (got ${latentShape.length})`);
    const [batch, tokens] = latentShape as [number, number, number];
    positiveInteger("MLA batch size", batch);
    positiveInteger("MLA token count", tokens);
    validateF32("MLA latent", latent, [batch, tokens, this.kvLoraRank]);
    validateF32("MLA RoPE state", rope, [batch, tokens, this.ropeHeadDim]);
    if (this.batchSize !== null && batch !== this.batchSize)
      throw new Error(`MLA batch size ${batch} != existing ${this.batchSize}`);
    if (this.offset > this.maxTokens - tokens)
      throw new RangeError(
        `MLA append would exceed maxTokens ${this.maxTokens}: ` +
        `${this.offset} + ${tokens}`,
      );

    if (this.dsa) {
      if (!dsa) throw new Error("MLA cache requires DSA index state");
      this.dsa.validateAppend(dsa, batch, tokens);
      if (this.dsa.offset !== this.offset)
        throw new Error(
          `DSA offset ${this.dsa.offset} != MLA offset ${this.offset}`,
        );
    } else if (dsa) {
      throw new Error("MLA cache was created without DSA index state");
    }

    // Build both MLA arrays before publishing either one. Shape and offset
    // validation above also runs before DSA mutates, so rejected appends leave
    // every state family unchanged.
    let nextLatent: MlxArray | null = null;
    let nextRope: MlxArray | null = null;
    try {
      nextLatent = appendAlongTokens(this.latent, latent);
      nextRope = appendAlongTokens(this.rope, rope);
      if (this.dsa) this.dsa.append(dsa!, batch, tokens);
    } catch (error) {
      nextLatent?.dispose();
      nextRope?.dispose();
      throw error;
    }

    this.latent?.dispose();
    this.rope?.dispose();
    this.latent = nextLatent;
    this.rope = nextRope;
    this.batchSize ??= batch;
    this.offset += tokens;
  }

  /** Append and return caller-owned chronological views. */
  appendAndFetch(
    latent: MlxArray,
    rope: MlxArray,
    dsa: MlxArray | null = null,
  ): MLACompressedState {
    this.append(latent, rope, dsa);
    return this.fetch();
  }

  /**
   * GLM attention integration seam. The returned arrays are caller-owned
   * chronological views; the cache retains its own full state.
   */
  appendCompressed(
    latent: MlxArray,
    rope: MlxArray,
    dsa: MlxArray | null = null,
  ): MLACompressedState {
    return this.appendAndFetch(latent, rope, dsa);
  }

  /** Caller-owned chronological views of all valid compressed state. */
  fetch(): MLACompressedState {
    if (
      !this.latent ||
      !this.rope ||
      this.batchSize === null ||
      this.offset === 0
    ) {
      throw new Error("MLA cache is empty");
    }
    return {
      latent: this.latent.slice(
        [0, 0, 0],
        [this.batchSize, this.offset, this.kvLoraRank],
      ),
      rope: this.rope.slice(
        [0, 0, 0],
        [this.batchSize, this.offset, this.ropeHeadDim],
      ),
      dsa: this.dsa?.fetch() ?? null,
    };
  }

  /**
   * Compatibility with the generic Cache interface. GLM layers with DSA use
   * appendAndFetch so all three state families advance atomically.
   */
  updateAndFetch(latent: MlxArray, rope: MlxArray): [MlxArray, MlxArray] {
    if (this.dsa)
      throw new Error("DSA-enabled MLACache requires appendAndFetch");
    const state = this.appendAndFetch(latent, rope);
    return [state.latent, state.rope];
  }

  makeMask(tokens: number, windowSize: number | null): Mask {
    positiveInteger("MLA mask token count", tokens);
    if (
      windowSize !== null &&
      (!Number.isSafeInteger(windowSize) || windowSize <= 0)
    ) {
      throw new Error("MLA attention window must be a positive integer");
    }
    if (tokens === 1) return { mode: "", arr: null };
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && tokens <= windowSize)
      return { mode: "causal", arr: null };
    return {
      mode: "array",
      arr: createCausalMask(tokens, this.offset, windowSize),
    };
  }

  /** Live cache arrays to materialize at a prefill boundary. */
  state(): MlxArray[] {
    if (!this.latent || !this.rope) return [];
    return [this.latent, this.rope, ...(this.dsa?.state() ?? [])];
  }

  isTrimmable(): boolean {
    return true;
  }

  trim(n: number): void {
    if (!Number.isSafeInteger(n) || n < 0 || n > this.offset)
      throw new RangeError(`cannot trim ${n} tokens from MLA offset ${this.offset}`);
    if (n === 0) return;
    const nextOffset = this.offset - n;
    if (nextOffset === 0) {
      this.dispose();
      return;
    }

    const nextLatent = trimToTokens(this.latent!, nextOffset);
    const nextRope = trimToTokens(this.rope!, nextOffset);
    this.dsa?.trim(n);
    this.latent!.dispose();
    this.rope!.dispose();
    this.latent = nextLatent;
    this.rope = nextRope;
    this.offset = nextOffset;
  }

  /** Exact logical bytes of valid f32 compressed state. */
  get byteLength(): number {
    if (this.batchSize === null) return 0;
    const mla = safeProduct(
      "MLA cache byte length",
      [
        this.batchSize,
        this.offset,
        this.kvLoraRank + this.ropeHeadDim,
        4,
      ],
    );
    return mla + (this.dsa?.byteLength ?? 0);
  }

  static projectedByteLength(
    geometry: MLACacheGeometry,
    batchSize: number,
    tokens: number,
  ): number {
    positiveInteger("MLA projected batch size", batchSize);
    if (!Number.isSafeInteger(tokens) || tokens < 0)
      throw new Error("MLA projected token count must be a non-negative safe integer");
    positiveInteger("MLA projected kvLoraRank", geometry.kvLoraRank);
    positiveInteger("MLA projected ropeHeadDim", geometry.ropeHeadDim);
    const dsaWidth = geometry.dsa?.headDim ?? 0;
    return safeProduct(
      "MLA projected byte length",
      [
        batchSize,
        tokens,
        geometry.kvLoraRank + geometry.ropeHeadDim + dsaWidth,
        4,
      ],
    );
  }

  dispose(): void {
    this.latent?.dispose();
    this.rope?.dispose();
    this.dsa?.dispose();
    this.latent = null;
    this.rope = null;
    this.offset = 0;
    this.batchSize = null;
  }
}

/** Architecture-name alias retained for code that speaks in MLA terms. */
export class MLACache extends Glm52Cache {}
