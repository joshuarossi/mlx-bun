// GLM-5.2 compressed attention state.
//
// One MLACache corresponds to one decoder layer. It stores only the
// checkpoint-native compressed state:
//   - latent: [B, T, kv_lora_rank]
//   - decoupled RoPE key: [B, T, qk_rope_head_dim]
//   - optional DSA index key: [B, T, index_head_dim]
//
// Serial rows and dynamic batches use the same checkpoint-native tensors.
// Batched rows are right-justified along T; rowOffsets/leftPad preserve each
// row's logical position without reconstructing per-head K/V.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  type BatchableCache,
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
  /** Persistence discriminator; native MTP owns an independent MLA row. */
  readonly role?: "target" | "mtp";
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
  const exact = ops.copyOf(view); // TRUE copy: see 2026-08-20 contiguous-view pin class
  view.dispose();
  return exact;
}

function padLeftTokens(array: MlxArray, tokens: number): MlxArray {
  if (tokens === 0) return ops.contiguous(array);
  const shape = [...array.shape];
  shape[1] = tokens;
  const padding = ops.zeros(shape, Dtype.float32);
  const result = ops.concatAxis([padding, array], 1);
  padding.dispose();
  return result;
}

function validateRowIndex(row: number, batch: number, label: string): void {
  if (!Number.isSafeInteger(row) || row < 0 || row >= batch)
    throw new RangeError(`${label} row ${row} is outside batch ${batch}`);
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

  /** Adopt persisted compressed index-key state after validating it. */
  restoreState(data: MlxArray, offset: number): void {
    positiveInteger("DSA restored offset", offset);
    const [batch, tokens] = data.shape;
    positiveInteger("DSA restored batch size", batch!);
    if (tokens !== offset)
      throw new Error(`DSA restored token length ${tokens} != offset ${offset}`);
    validateF32("DSA restored index state", data, [batch!, offset, this.headDim]);
    this.dispose();
    this.data = data;
    this.batchSize = batch!;
    this.offset = offset;
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

export class Glm52Cache implements BatchableCache {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  readonly maxTokens: number;
  readonly dsa: DSAIndexCache | null;
  readonly role: "target" | "mtp";

  latent: MlxArray | null = null;
  rope: MlxArray | null = null;
  offset = 0;
  batchSize: number | null = null;
  rowOffsets: number[] = [];
  leftPad: number[] = [];

  constructor(geometry: MLACacheGeometry) {
    positiveInteger("MLA kvLoraRank", geometry.kvLoraRank);
    positiveInteger("MLA ropeHeadDim", geometry.ropeHeadDim);
    if (geometry.maxTokens !== undefined)
      positiveInteger("MLA maxTokens", geometry.maxTokens);
    this.kvLoraRank = geometry.kvLoraRank;
    this.ropeHeadDim = geometry.ropeHeadDim;
    this.maxTokens = geometry.maxTokens ?? Number.MAX_SAFE_INTEGER;
    this.dsa = geometry.dsa ? new DSAIndexCache(geometry.dsa) : null;
    this.role = geometry.role ?? "target";
    if (this.role === "mtp" && this.dsa)
      throw new Error("native MTP cache cannot contain target DSA state");
  }

  signature(): string {
    if (this.role === "mtp") return "kv:mla:mtp";
    return this.dsa ? "kv:mla:target:dsa" : "kv:mla:target";
  }

  bytesPerToken(): number {
    return (this.kvLoraRank + this.ropeHeadDim + (this.dsa?.headDim ?? 0)) * 4;
  }

  /** Append one equal-width row block without expanding it to per-head K/V. */
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
    const priorRowOffsets = this.rowOffsets.length
      ? this.rowOffsets
      : new Array(batch).fill(0) as number[];
    const longestRow = Math.max(...priorRowOffsets);
    if (longestRow > this.maxTokens - tokens)
      throw new RangeError(
        `MLA append would exceed maxTokens ${this.maxTokens}: ` +
        `${longestRow} + ${tokens}`,
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
    if (this.rowOffsets.length === 0) {
      this.rowOffsets = new Array(batch).fill(0) as number[];
      this.leftPad = new Array(batch).fill(0) as number[];
    }
    this.rowOffsets = this.rowOffsets.map((value) => value + tokens);
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

  /** Caller-owned view of one row with its synthetic left padding removed. */
  fetchRow(row: number): MLACompressedState {
    if (!this.latent || !this.rope || this.batchSize === null)
      throw new Error("MLA cache is empty");
    validateRowIndex(row, this.batchSize, "MLA");
    const start = this.leftPad[row]!;
    const stop = this.offset;
    return {
      latent: this.latent.slice(
        [row, start, 0],
        [row + 1, stop, this.kvLoraRank],
      ),
      rope: this.rope.slice(
        [row, start, 0],
        [row + 1, stop, this.ropeHeadDim],
      ),
      dsa: this.dsa?.data?.slice(
        [row, start, 0],
        [row + 1, stop, this.dsa.headDim],
      ) ?? null,
    };
  }

  rowOffset(row: number): number {
    if (this.batchSize === null) throw new Error("MLA cache is empty");
    validateRowIndex(row, this.batchSize, "MLA");
    return this.rowOffsets[row]!;
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

  /**
   * Adopt persisted checkpoint-native state. Arrays become cache-owned only
   * after every shape/dtype/geometry check passes.
   */
  restoreCompressedState(
    latent: MlxArray,
    rope: MlxArray,
    dsa: MlxArray | null,
    offset: number,
  ): void {
    positiveInteger("MLA restored offset", offset);
    if (offset > this.maxTokens)
      throw new RangeError(
        `MLA restored offset ${offset} exceeds maxTokens ${this.maxTokens}`,
      );
    const [batch, tokens] = latent.shape;
    positiveInteger("MLA restored batch size", batch!);
    if (tokens !== offset)
      throw new Error(`MLA restored token length ${tokens} != offset ${offset}`);
    validateF32(
      "MLA restored latent",
      latent,
      [batch!, offset, this.kvLoraRank],
    );
    validateF32(
      "MLA restored RoPE state",
      rope,
      [batch!, offset, this.ropeHeadDim],
    );
    if (this.dsa) {
      if (!dsa) throw new Error("MLA restored state requires DSA index state");
      validateF32(
        "MLA restored DSA state",
        dsa,
        [batch!, offset, this.dsa.headDim],
      );
    } else if (dsa) {
      throw new Error("MLA restored state has unexpected DSA index state");
    }

    this.dispose();
    this.latent = latent;
    this.rope = rope;
    this.batchSize = batch!;
    this.offset = offset;
    this.rowOffsets = new Array(batch!).fill(offset) as number[];
    this.leftPad = new Array(batch!).fill(0) as number[];
    if (this.dsa) this.dsa.restoreState(dsa!, offset);
  }

  isTrimmable(): boolean {
    return true;
  }

  trim(n: number): void {
    const shortestRow = this.rowOffsets.length
      ? Math.min(...this.rowOffsets)
      : this.offset;
    if (!Number.isSafeInteger(n) || n < 0 || n > shortestRow)
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
    this.rowOffsets = this.rowOffsets.map((value) => value - n);
  }

  /** Exact logical bytes of valid f32 compressed state. */
  get byteLength(): number {
    if (this.batchSize === null) return 0;
    const logicalTokens = this.rowOffsets.reduce((sum, value) => sum + value, 0);
    return safeProduct(
      "MLA cache byte length",
      [
        logicalTokens,
        this.kvLoraRank + this.ropeHeadDim + (this.dsa?.headDim ?? 0),
        4,
      ],
    );
  }

  makeEmptyBatch(): Glm52Cache {
    const CacheType = this.constructor as typeof Glm52Cache;
    return new CacheType({
      kvLoraRank: this.kvLoraRank,
      ropeHeadDim: this.ropeHeadDim,
      maxTokens: this.maxTokens,
      role: this.role,
      ...(this.dsa ? { dsa: { headDim: this.dsa.headDim } } : {}),
    });
  }

  /** Merge serial or already-batched rows into this empty cache. */
  mergeRows(rows: readonly Cache[]): void {
    if (this.batchSize !== null || this.offset !== 0)
      throw new Error("MLA mergeRows requires an empty destination cache");
    if (rows.length === 0)
      throw new Error("MLA mergeRows requires at least one row");

    const states: MLACompressedState[] = [];
    const offsets: number[] = [];
    try {
      for (const generic of rows) {
        if (!(generic instanceof Glm52Cache))
          throw new Error("MLA mergeRows requires GLM compressed caches");
        if (
          generic.kvLoraRank !== this.kvLoraRank ||
          generic.ropeHeadDim !== this.ropeHeadDim ||
          generic.maxTokens !== this.maxTokens ||
          generic.role !== this.role ||
          (generic.dsa?.headDim ?? null) !== (this.dsa?.headDim ?? null)
        ) {
          throw new Error("MLA mergeRows cache geometry does not match");
        }
        if (generic.batchSize === null || generic.offset === 0)
          throw new Error("MLA mergeRows cannot merge an empty row");
        for (let row = 0; row < generic.batchSize; row++) {
          states.push(generic.fetchRow(row));
          offsets.push(generic.rowOffset(row));
        }
      }

      const width = Math.max(...offsets);
      if (width > this.maxTokens)
        throw new RangeError(`MLA merged width ${width} exceeds maxTokens ${this.maxTokens}`);
      const mergeFamily = (
        select: (state: MLACompressedState) => MlxArray,
      ): MlxArray => {
        const padded = states.map((state, row) =>
          padLeftTokens(select(state), width - offsets[row]!)
        );
        try {
          return ops.concatAxis(padded, 0);
        } finally {
          for (const array of padded) array.dispose();
        }
      };

      const latent = mergeFamily((state) => state.latent);
      let rope: MlxArray | null = null;
      let dsa: MlxArray | null = null;
      try {
        rope = mergeFamily((state) => state.rope);
        if (this.dsa) {
          dsa = mergeFamily((state) => {
            if (!state.dsa) throw new Error("MLA mergeRows is missing DSA state");
            return state.dsa;
          });
        }
      } catch (error) {
        latent.dispose();
        rope?.dispose();
        dsa?.dispose();
        throw error;
      }

      this.latent = latent;
      this.rope = rope;
      this.batchSize = offsets.length;
      this.offset = width;
      this.rowOffsets = [...offsets];
      this.leftPad = offsets.map((value) => width - value);
      if (this.dsa) this.dsa.restoreState(dsa!, width);
    } finally {
      for (const state of states) {
        state.latent.dispose();
        state.rope.dispose();
        state.dsa?.dispose();
      }
    }
  }

  /** Copy one logical row into an independently-owned serial cache. */
  extractRow(row: number): Glm52Cache {
    if (this.batchSize === null) throw new Error("MLA cache is empty");
    validateRowIndex(row, this.batchSize, "MLA extract");
    const state = this.fetchRow(row);
    const copy = (array: MlxArray): MlxArray => ops.mulScalar(array, 1);
    const latent = copy(state.latent);
    const rope = copy(state.rope);
    const dsa = state.dsa ? copy(state.dsa) : null;
    const out = this.makeEmptyBatch();
    try {
      out.restoreCompressedState(latent, rope, dsa, this.rowOffsets[row]!);
      return out;
    } catch (error) {
      latent.dispose();
      rope.dispose();
      dsa?.dispose();
      out.dispose();
      throw error;
    } finally {
      state.latent.dispose();
      state.rope.dispose();
      state.dsa?.dispose();
    }
  }

  /** Keep selected rows and normalize removable common left padding. */
  filterRows(keep: readonly number[]): void {
    if (this.batchSize === null) throw new Error("MLA cache is empty");
    if (keep.length === 0) throw new Error("MLA filterRows cannot keep zero rows");
    const unique = new Set<number>();
    for (const row of keep) {
      validateRowIndex(row, this.batchSize, "MLA filter");
      if (unique.has(row)) throw new Error(`MLA filter row ${row} is duplicated`);
      unique.add(row);
    }
    const nextOffsets = keep.map((row) => this.rowOffsets[row]!);
    const selectedPad = keep.map((row) => this.leftPad[row]!);
    const removablePad = Math.min(...selectedPad);
    const nextWidth = this.offset - removablePad;
    const indices = ops.fromInt32([...keep], [keep.length]);
    const filterFamily = (array: MlxArray): MlxArray => {
      const selected = ops.takeAxis(array, indices, 0);
      if (removablePad === 0) return selected;
      const view = selected.slice(
        [0, removablePad, 0],
        [keep.length, this.offset, array.shape[2]!],
      );
      const exact = ops.copyOf(view); // TRUE copy: see 2026-08-20 contiguous-view pin class
      selected.dispose();
      view.dispose();
      return exact;
    };

    let latent: MlxArray | null = null;
    let rope: MlxArray | null = null;
    let dsa: MlxArray | null = null;
    try {
      latent = filterFamily(this.latent!);
      rope = filterFamily(this.rope!);
      if (this.dsa) dsa = filterFamily(this.dsa.data!);
    } catch (error) {
      latent?.dispose();
      rope?.dispose();
      dsa?.dispose();
      throw error;
    } finally {
      indices.dispose();
    }

    this.latent!.dispose();
    this.rope!.dispose();
    this.latent = latent;
    this.rope = rope;
    this.batchSize = keep.length;
    this.offset = nextWidth;
    this.rowOffsets = nextOffsets;
    this.leftPad = selectedPad.map((value) => value - removablePad);
    if (this.dsa) this.dsa.restoreState(dsa!, nextWidth);
  }

  projectedBytes(tokens: number): number {
    return Glm52Cache.projectedByteLength({
      kvLoraRank: this.kvLoraRank,
      ropeHeadDim: this.ropeHeadDim,
      ...(this.dsa ? { dsa: { headDim: this.dsa.headDim } } : {}),
    }, 1, tokens);
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
    this.rowOffsets = [];
    this.leftPad = [];
  }
}

/** Architecture-name alias retained for code that speaks in MLA terms. */
export class MLACache extends Glm52Cache {}
