import host.ts.Source
namespace Host.Ts.Sources.Inference.State.LatentLegos
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/latent-legos.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The latent attention state (GLM-5.2's compressed MLA: the latent, the
// decoupled RoPE key and, on a sparse-attention layer, the DSA index key) under
// the composition's KV scheme and paging. `MLACache` is the f32 lego (bf16 KV's
// counterpart: the checkpoint-native state, stored as computed). The legos here
// store the same three families as the scheme names, by the rules the key/value
// legos follow:
// - `EncodedLatentCache`: affine (one bit width and group size for every
//   family) or TurboQuant (every family through the codec's key encoding at
//   the key width: the latent is what the keys are made from as well as the
//   values, so it takes the key side's precision, and the state has no
//   value-only store for the value width to name; measured on synthetic GLM
//   weights, the latent through the 3-bit value encoding instead cost a logits
//   KL of 0.0117 against 0.00007 through the 8-bit key encoding), f32 through
//   each row's first append or its first `start` positions and encoded after
//   (the bf16-first rule), read decoded;
// - `PagedLatentCache`: each row's positions in pages of `blockSize`, stored
//   as the scheme names from the first position (as K/V pages are), read
//   gathered and decoded.
// Both implement the whole latent contract (`LatentAttentionCache`): the read
// per append, the stored index keys, the row layout (`BatchableCache`), the
// speculative transaction, prefill padding, and the snapshot and SSD forms
// (`latentLegoCodecs`, the codec provider a graph composing these declares).

import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type {
  BatchableCache, Cache, LatentAttentionCache, LatentAttentionState, PrefillPadding,
} from "../contracts/mlx/cache";
import type { KvStorageScheme } from "../contracts/portable/composition";
import * as tq from "../kernels/turboquant/ops";
import { disposeResources } from "../runtime/resources";
import { positiveInteger } from "../runtime/integers";
import { transitionDue } from "./bf16-first-kv";
import { rowRollIndices } from "./batched-row-storage";
import { MLACache, type MLACacheGeometry } from "./glm52-cache";
import { legacyCacheCodecs } from "./persistence";
import type { CacheCodec, CacheCodecProvider, CacheHeaderEntry, LatentLegoKind } from "./persistence-types";

// ---------------------------------------------------------------------------
// Family encodings

/** What one family of latent state stores: affine at a width and group size,
 * or TurboQuant's key or value encoding at a width. */
export type LatentFormat =
  | { readonly kind: "affine"; readonly bits: number; readonly groupSize: number }
  | { readonly kind: "turbo"; readonly kBits: number; readonly vBits: number };

/** The latent state's three families, in stored order. */
type Family = 0 | 1 | 2;

/** One family's encoding: f32 positions [B, L, width] to owned planes
 * [B, L, w_i] (positions along axis 1, so every row operation applies to
 * each plane alike), and planes back to f32. Zero planes decode to zeros. */
interface FamilyEncoding {
  readonly planes: number;
  encode(values: MlxArray): MlxArray[];
  decode(planes: readonly MlxArray[]): MlxArray;
}

function affineEncoding(bits: number, groupSize: number, width: number): FamilyEncoding {
  if (width % groupSize !== 0)
    throw new Error(`latent state width ${width} is not a multiple of the affine group size ${groupSize}`);
  return {
    planes: 3,
    encode(values) { const q = ops.quantize(values, groupSize, bits); return [q.packed, q.scales, q.biases]; },
    decode: ([packed, scales, biases]) => ops.dequantize(packed!, scales!, biases!, { bits, groupSize, mode: "affine" }),
  };
}

/** TurboQuant's key encoding (asymmetric affine per 32 positions of the width,
 * `bits` wide), decoded in f32 (the codec decodes through bf16). */
function turboKeyEncoding(bits: number, width: number): FamilyEncoding {
  if (width % tq.TURBOQUANT_BLOCK_SIZE !== 0)
    throw new Error(`latent state width ${width} has no TurboQuant key encoding`);
  const pack = (indices: MlxArray) => {
    if (bits >= 8) return indices;
    try { return tq.packBits(indices, bits); } finally { indices.dispose(); }
  };
  const unpack = (packed: MlxArray) => bits >= 8 ? packed : tq.unpackBits(packed, bits, width);
  const wide = (decoded: MlxArray) => { try { return decoded.astype(Dtype.float32); } finally { decoded.dispose(); } };
  return {
    planes: 3,
    encode(values) { const e = tq.encodeKeys(values, bits, bits === 8); return [pack(e.indices), e.scales, e.zeros]; },
    decode([indices, scales, zeros]) {
      const codes = unpack(indices!);
      try { return wide(tq.decodeKeys(codes, scales!, zeros!)); } finally { if (codes !== indices) codes.dispose(); }
    },
  };
}

/** The encoding of a family of width `width` under `format` (every family alike). */
function familyEncoding(format: LatentFormat, width: number): FamilyEncoding {
  return format.kind === "affine" ? affineEncoding(format.bits, format.groupSize, width) : turboKeyEncoding(format.kBits, width);
}

const formatKey = (format: LatentFormat | null) => !format ? "f32"
  : format.kind === "affine" ? `affine:${format.bits}:${format.groupSize}` : `turbo:${format.kBits}:${format.vBits}`;

// ---------------------------------------------------------------------------
// Shared helpers

/** Geometry every latent lego of a layer shares (the `MLACache` geometry). */
export interface LatentGeometry {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  /** The DSA index key width, on a sparse-attention layer. */
  readonly indexHeadDim?: number;
  readonly maxTokens?: number;
}

const widthsOf = (g: LatentGeometry): number[] => [g.kvLoraRank, g.ropeHeadDim, ...(g.indexHeadDim ? [g.indexHeadDim] : [])];

function validateF32(name: string, array: MlxArray, expected: readonly number[]): void {
  if (array.dtype !== Dtype.float32) throw new Error(`${name} must be float32`);
  const shape = array.shape;
  if (shape.length !== expected.length || shape.some((dimension, index) => dimension !== expected[index]))
    throw new Error(`${name} shape ${JSON.stringify(shape)} != ${JSON.stringify(expected)}`);
}

/** Validate one append's inputs against the geometry and return [B, L]. */
function appendShape(g: LatentGeometry, latent: MlxArray, rope: MlxArray, indexKeys: MlxArray | null,
  batch: number | null): [number, number] {
  if (latent.shape.length !== 3) throw new Error(`latent state must have rank 3 (got ${latent.shape.length})`);
  const [B, L] = latent.shape as [number, number, number];
  positiveInteger(B, "latent batch size"); positiveInteger(L, "latent token count");
  validateF32("latent", latent, [B, L, g.kvLoraRank]);
  validateF32("RoPE key", rope, [B, L, g.ropeHeadDim]);
  if (g.indexHeadDim) {
    if (!indexKeys) throw new Error("this latent state stores DSA index keys");
    validateF32("DSA index keys", indexKeys, [B, L, g.indexHeadDim]);
  } else if (indexKeys) throw new Error("this latent state stores no DSA index keys");
  if (batch !== null && B !== batch) throw new Error(`latent batch size ${B} != existing ${batch}`);
  return [B, L];
}

/** Owned zeros shaped like `like` with `tokens` positions along axis 1. */
const zerosLike = (like: MlxArray, tokens: number, batch = like.shape[0]!) =>
  ops.zeros([batch, tokens, ...like.shape.slice(2)], like.dtype);

/** `array` with `tokens` zero positions before it along axis 1 (owned). */
function padLeft(array: MlxArray, tokens: number): MlxArray {
  if (tokens === 0) return ops.contiguous(array);
  using padding = zerosLike(array, tokens);
  return ops.concatAxis([padding, array], 1);
}

/** Positions [from, to) of row `row` along axis 1, as an owned copy. */
function rowSlice(array: MlxArray, row: number, from: number, to: number): MlxArray {
  using view = array.slice([row, from, 0], [row + 1, to, array.shape[2]!]);
  return ops.copyOf(view);
}

/** Per-row choice between two [B, T, W] arrays: `useFirst[b]` picks `first`. */
function pickRows(useFirst: readonly boolean[], first: MlxArray, second: MlxArray): MlxArray {
  if (useFirst.every(Boolean)) return ops.contiguous(first);
  if (!useFirst.some(Boolean)) return ops.contiguous(second);
  using flags = ops.fromInt32(useFirst.map(Number), [useFirst.length, 1, 1]);
  using mask = flags.astype(Dtype.bool);
  return ops.where(mask, first, second);
}

// ---------------------------------------------------------------------------
// Encoded latent state (f32 first)

/** Persisted or extracted state of one encoded row (owned arrays). */
interface EncodedRowState {
  /** Per family, its encoded planes [1, T, w_i]. */
  readonly planes: MlxArray[][];
  /** Per family, the f32 values [1, T, W] of a row not yet converted; null once converted. */
  readonly shadow: MlxArray[] | null;
  readonly offset: number;
  readonly minimumReusableOffset: number;
}

/**
 * The latent attention state stored as `format` names, f32 first: the lego a
 * quantized KV scheme composes for a GLM-5.2 layer.
 *
 * Every append encodes its positions. A row reads its stored state in f32
 * through the append that leaves it holding at least `start` positions (the
 * first append when `start` is 0), then converts: every later read of that row
 * decodes all its stored positions. The encoding is per position, so encoding
 * at append time stores what converting the f32 state at the start would. The
 * f32 values a row still reads (the `shadow`) are kept only while some row has
 * not converted. Conversion is irreversible: trimming or rolling a row back
 * below the start keeps it converted. A nonzero start records the converted
 * offset as the earliest reusable prefix (`minimumReusableOffset`).
 *
 * Rows: one row for a single sequence; a batch keeps its rows right-justified
 * along the sequence axis, `rowOffsets[b]` positions in row `b` starting at
 * `leftPad[b]` (`MLACache`'s layout). Reads return f32 [B, T, width] with zeros
 * in the padding.
 */
export class EncodedLatentCache implements BatchableCache, LatentAttentionCache {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  readonly indexHeadDim: number | null;
  readonly maxTokens: number;
  readonly #encodings: FamilyEncoding[];
  readonly #widths: number[];
  #planes: MlxArray[][] | null = null;
  #shadow: MlxArray[] | null = null;
  #converted: boolean[] = [];
  #minimum: number[] = [];
  #beforeRound: number[] | undefined;
  #ends: number[] | undefined;
  offset = 0;
  batchSize: number | null = null;
  rowOffsets: number[] = [];
  leftPad: number[] = [];

  constructor(readonly geometry: LatentGeometry, readonly format: LatentFormat, readonly start: number) {
    positiveInteger(geometry.kvLoraRank, "latent kvLoraRank");
    positiveInteger(geometry.ropeHeadDim, "latent ropeHeadDim");
    if (!Number.isSafeInteger(start) || start < 0) throw new Error("latent conversion start must be a non-negative integer");
    this.kvLoraRank = geometry.kvLoraRank;
    this.ropeHeadDim = geometry.ropeHeadDim;
    this.indexHeadDim = geometry.indexHeadDim ?? null;
    this.maxTokens = geometry.maxTokens ?? Number.MAX_SAFE_INTEGER;
    this.#widths = widthsOf(geometry);
    this.#encodings = this.#widths.map(width => familyEncoding(format, width));
  }

  signature(): string {
    return `kv:latent:${this.indexHeadDim ? "dsa:" : ""}${formatKey(this.format)}:${this.start}`;
  }
  get minimumReusableOffset(): number { return Math.max(0, ...this.#minimum); }
  /** A restored or cloned row's earliest reusable prefix, as persistence records it. */
  set minimumReusableOffset(value: number | undefined) {
    this.#minimum = this.#minimum.length ? this.#minimum.map(() => value ?? 0) : [value ?? 0];
  }

  /** Every array this cache holds, encoded planes then the f32 shadow. */
  #arrays(): MlxArray[] { return [...(this.#planes?.flat() ?? []), ...(this.#shadow ?? [])]; }
  /** Rebuild the plane lists from a flat array list in `#arrays` order. */
  #adopt(arrays: MlxArray[], shadow: boolean): void {
    const planes: MlxArray[][] = [];
    let at = 0;
    for (const encoding of this.#encodings) { planes.push(arrays.slice(at, at + encoding.planes)); at += encoding.planes; }
    this.#planes = planes;
    this.#shadow = shadow ? arrays.slice(at, at + this.#encodings.length) : null;
  }

  state(): MlxArray[] { return this.#arrays(); }
  bytesPerToken(): number {
    const arrays = this.#planes?.flat() ?? [];
    const tokens = arrays[0] ? arrays[0].shape[0]! * arrays[0].shape[1]! : 0;
    return tokens ? arrays.reduce((bytes, array) => bytes + array.nbytes, 0) / tokens
      : this.#widths.reduce((bytes, width) => bytes + width * 4, 0);
  }
  projectedBytes(tokens: number): number {
    return MLACache.projectedByteLength({ kvLoraRank: this.kvLoraRank, ropeHeadDim: this.ropeHeadDim,
      ...(this.indexHeadDim ? { dsa: { headDim: this.indexHeadDim } } : {}) }, 1, tokens);
  }

  /** Decode family `family`'s stored state, rows still in f32 read from the shadow. */
  #read(family: Family, converted: readonly boolean[]): MlxArray {
    const decoded = this.#encodings[family]!.decode(this.#planes![family]!);
    if (!this.#shadow) return decoded;
    try { return pickRows(converted, decoded, this.#shadow[family]!); } finally { decoded.dispose(); }
  }

  appendLatent(latent: MlxArray, rope: MlxArray, indexKeys: MlxArray | null): LatentAttentionState {
    const [B, L] = appendShape(this.geometry, latent, rope, indexKeys, this.batchSize);
    const offsets = this.rowOffsets.length ? this.rowOffsets : new Array<number>(B).fill(0);
    if (Math.max(...offsets) > this.maxTokens - L)
      throw new RangeError(`latent append would exceed maxTokens ${this.maxTokens}: ${Math.max(...offsets)} + ${L}`);
    const converted = this.#converted.length ? [...this.#converted] : new Array<boolean>(B).fill(false);
    const inputs = [latent, rope, ...(indexKeys ? [indexKeys] : [])];
    // Stage every family before publishing any (a rejected append leaves the cache unchanged).
    const planes: MlxArray[][] = [], shadow: MlxArray[] = [];
    const keepShadow = converted.some(done => !done);
    try {
      for (const [family, input] of inputs.entries()) {
        const encoded = this.#encodings[family]!.encode(input);
        planes.push(encoded.map((plane, index) => {
          const current = this.#planes?.[family]![index];
          if (!current) return plane;
          try { return ops.concatAxis([current, plane], 1); } finally { plane.dispose(); }
        }));
        if (keepShadow) {
          const current = this.#shadow?.[family] ?? (this.offset ? ops.zeros([B, this.offset, this.#widths[family]!], Dtype.float32) : null);
          shadow.push(current ? ops.concatAxis([current, input], 1) : ops.contiguous(input));
          if (current && current !== this.#shadow?.[family]) current.dispose();
        }
      }
    } catch (error) { disposeResources([...planes.flat(), ...shadow]); throw error; }
    disposeResources(this.#arrays());
    this.#planes = planes; this.#shadow = keepShadow ? shadow : null;
    this.batchSize ??= B;
    if (!this.rowOffsets.length) { this.rowOffsets = new Array<number>(B).fill(0); this.leftPad = new Array<number>(B).fill(0); }
    this.rowOffsets = this.rowOffsets.map(offset => offset + L);
    this.offset += L;
    if (!this.#minimum.length) this.#minimum = new Array<number>(B).fill(0);
    let state: LatentAttentionState;
    const read: MlxArray[] = [];
    try {
      for (let family = 0; family < inputs.length; family++) read.push(this.#read(family as Family, converted));
      state = { latent: read[0]!, rope: read[1]!, indexKeys: read[2] ?? null };
    } catch (error) { disposeResources(read); throw error; }
    this.#converted = converted.map((done, row) => done || transitionDue(this.rowOffsets[row]!, this.start));
    for (const [row, done] of this.#converted.entries())
      if (done && !converted[row] && this.start > 0) this.#minimum[row] = this.rowOffsets[row]!;
    this.#dropShadowIfConverted();
    return state;
  }

  storedIndexKeys(): MlxArray | null {
    if (!this.indexHeadDim || !this.#planes || this.offset === 0) return null;
    return this.#read(2, this.#converted);
  }

  #dropShadowIfConverted(): void {
    if (this.#shadow && this.#converted.every(Boolean)) { disposeResources(this.#shadow); this.#shadow = null; }
  }

  isTrimmable(): boolean { return true; }
  trim(n: number): void {
    const shortest = this.rowOffsets.length ? Math.min(...this.rowOffsets) : this.offset;
    if (!Number.isSafeInteger(n) || n < 0 || n > shortest)
      throw new RangeError(`cannot trim ${n} tokens from latent offset ${this.offset}`);
    if (n === 0) return;
    const next = this.offset - n;
    if (next === 0) { this.#clearStorage(); this.rowOffsets = this.rowOffsets.map(() => 0); this.leftPad = this.leftPad.map(() => 0); return; }
    const arrays = this.#arrays().map(array => rowSliceAll(array, next));
    const shadow = !!this.#shadow;
    disposeResources(this.#arrays());
    this.#adopt(arrays, shadow);
    this.offset = next;
    this.rowOffsets = this.rowOffsets.map(offset => offset - n);
  }

  #clearStorage(): void {
    disposeResources(this.#arrays());
    this.#planes = null; this.#shadow = null; this.offset = 0;
  }

  // The speculative transaction (MLACache's): keep each row's accepted prefix,
  // right-justified.
  specRoundBegin(): void { this.#beforeRound = [...this.rowOffsets]; }
  specRoundCommit(): void { this.#beforeRound = undefined; }
  specRoundRollback(keep: number | readonly number[]): void {
    const next = this.#beforeRound!.map((before, row) => before + (typeof keep === "number" ? keep : keep[row]!));
    const rejected = this.rowOffsets.map((offset, row) => offset - next[row]!);
    this.#beforeRound = undefined;
    if (rejected.every(count => count === rejected[0])) { this.trim(rejected[0]!); return; }
    const width = this.offset, pads = this.leftPad.map((pad, row) => pad + rejected[row]!);
    const removable = Math.min(...pads);
    using indices = ops.fromInt32(rejected.flatMap(count =>
      Array.from({ length: width }, (_, column) => (column - count + width) % width)), [this.batchSize!, width, 1]);
    const arrays: MlxArray[] = [];
    try {
      for (const array of this.#arrays()) {
        using shifted = ops.takeAlongAxis(array, indices, 1);
        arrays.push(shifted.slice([0, removable, 0], [this.batchSize!, width, array.shape[2]!]));
      }
    } catch (error) { disposeResources(arrays); throw error; }
    const shadow = !!this.#shadow;
    disposeResources(this.#arrays());
    this.#adopt(arrays, shadow);
    this.offset = width - removable;
    this.rowOffsets = next;
    this.leftPad = pads.map(pad => pad - removable);
  }

  // Prefill padding (MLACache's, over every plane).
  preparePrefill(padding: PrefillPadding): void {
    if (!this.rowOffsets.length) {
      this.rowOffsets = padding.lengths.map(() => 0); this.leftPad = [...this.rowOffsets];
      this.#converted = padding.lengths.map(() => false); this.#minimum = padding.lengths.map(() => 0);
      this.batchSize = padding.lengths.length;
    }
    if (padding.leftPadding) {
      this.leftPad = this.leftPad.map((pad, row) => pad + padding.leftPadding![row]!);
      this.rowOffsets = this.rowOffsets.map((offset, row) => offset - padding.leftPadding![row]!);
    }
    this.#ends = padding.rightPadding?.some(pad => pad > 0)
      ? padding.lengths.map((length, row) => this.rowOffsets[row]! + length) : undefined;
  }
  finalizePrefill(): void {
    const ends = this.#ends;
    this.#ends = undefined;
    if (!ends) return;
    const padding = ends.map((end, row) => Math.max(0, this.rowOffsets[row]! - end));
    if (!padding.some(pad => pad > 0)) return;
    const arrays: MlxArray[] = [];
    try {
      if (this.#planes) {
        using indices = rowRollIndices(this.offset, padding);
        using compressed = ops.reshape(indices, [padding.length, this.offset, 1]);
        for (const array of this.#arrays()) arrays.push(ops.takeAlongAxis(array, compressed, 1));
      }
    } catch (error) { disposeResources(arrays); throw error; }
    if (this.#planes) { const shadow = !!this.#shadow; disposeResources(this.#arrays()); this.#adopt(arrays, shadow); }
    this.rowOffsets = this.rowOffsets.map((offset, row) => offset - padding[row]!);
    this.leftPad = this.leftPad.map((pad, row) => pad + padding[row]!);
  }

  makeEmptyBatch(): EncodedLatentCache { return new EncodedLatentCache(this.geometry, this.format, this.start); }

  /** Row `row`'s state (owned copies), its padding removed. */
  rowState(row: number): EncodedRowState {
    if (this.batchSize === null) throw new Error("latent state is empty");
    const start = this.leftPad[row]!, end = this.offset, offset = this.rowOffsets[row]!;
    const planes = offset ? this.#planes!.map(family => family.map(plane => rowSlice(plane, row, start, end))) : [];
    const shadow = this.#converted[row] ? null
      : offset ? this.#shadow!.map(values => rowSlice(values, row, start, end)) : [];
    return { planes, shadow, offset, minimumReusableOffset: this.#minimum[row] ?? 0 };
  }

  /** Adopt one row's state (taking ownership): what extraction and the SSD form restore. */
  restoreRow(state: EncodedRowState): void {
    this.dispose();
    this.batchSize = 1; this.rowOffsets = [state.offset]; this.leftPad = [0];
    this.#converted = [state.shadow === null]; this.#minimum = [state.minimumReusableOffset];
    if (!state.offset) return;
    this.#planes = state.planes; this.#shadow = state.shadow;
    this.offset = state.offset;
  }

  /** Merge serial or batched rows of this geometry and format into this empty cache. */
  mergeRows(rows: readonly Cache[]): void {
    if (this.batchSize !== null || this.offset !== 0) throw new Error("latent mergeRows requires an empty destination cache");
    if (!rows.length) throw new Error("latent mergeRows requires at least one row");
    const states: EncodedRowState[] = [];
    try {
      for (const source of rows) {
        if (!(source instanceof EncodedLatentCache) || source.signature() !== this.signature())
          throw new Error(`latent mergeRows cannot merge ${source.signature()} into ${this.signature()}`);
        const count = source.batchSize ?? 1;
        for (let row = 0; row < count; row++)
          states.push(source.batchSize === null ? { planes: [], shadow: [], offset: 0, minimumReusableOffset: 0 } : source.rowState(row));
      }
      const width = Math.max(...states.map(state => state.offset));
      if (width > this.maxTokens) throw new RangeError(`latent merged width ${width} exceeds maxTokens ${this.maxTokens}`);
      const converted = states.map(state => state.shadow === null);
      if (width) {
        const prototype = states.find(state => state.offset)!;
        const family = (pick: (state: EncodedRowState) => MlxArray | undefined, columns: number, dtype: Dtype) => {
          const padded = states.map(state => {
            const array = pick(state);
            return array ? padLeft(array, width - state.offset) : ops.zeros([1, width, columns], dtype);
          });
          try { return ops.concatAxis(padded, 0); } finally { disposeResources(padded); }
        };
        const planes = prototype.planes.map((group, f) =>
          group.map((plane, i) => family(state => state.planes[f]?.[i], plane.shape[2]!, plane.dtype)));
        const shadow = converted.every(Boolean) ? null
          : this.#widths.map((w, f) => family(state => state.shadow?.[f], w, Dtype.float32));
        this.#planes = planes; this.#shadow = shadow;
      }
      this.batchSize = states.length; this.offset = width;
      this.rowOffsets = states.map(state => state.offset);
      this.leftPad = states.map(state => width - state.offset);
      this.#converted = converted;
      this.#minimum = states.map(state => state.minimumReusableOffset);
    } finally { disposeResources(states.flatMap(state => [...state.planes.flat(), ...(state.shadow ?? [])])); }
  }

  extractRow(row: number): EncodedLatentCache {
    const out = this.makeEmptyBatch();
    try { out.restoreRow(this.rowState(row)); return out; }
    catch (error) { out.dispose(); throw error; }
  }

  filterRows(keep: readonly number[]): void {
    if (this.batchSize === null) throw new Error("latent state is empty");
    if (!keep.length) throw new Error("latent filterRows cannot keep zero rows");
    const removable = Math.min(...keep.map(row => this.leftPad[row]!));
    const width = this.offset - removable;
    using indices = ops.fromInt32([...keep], [keep.length]);
    const arrays: MlxArray[] = [];
    try {
      for (const array of this.#arrays()) {
        using trimmed = array.slice([0, removable, 0], [this.batchSize, this.offset, array.shape[2]!]);
        using selected = ops.takeAxis(trimmed, indices, 0);
        arrays.push(ops.copyOf(selected));
      }
    } catch (error) { disposeResources(arrays); throw error; }
    const shadow = !!this.#shadow;
    disposeResources(this.#arrays());
    if (this.#planes) this.#adopt(arrays, shadow);
    this.batchSize = keep.length; this.offset = width;
    this.rowOffsets = keep.map(row => this.rowOffsets[row]!);
    this.leftPad = keep.map(row => this.leftPad[row]! - removable);
    this.#converted = keep.map(row => this.#converted[row] ?? false);
    this.#minimum = keep.map(row => this.#minimum[row] ?? 0);
    if (this.#ends) this.#ends = keep.map(row => this.#ends![row]!);
    this.#dropShadowIfConverted();
  }

  dispose(): void {
    disposeResources(this.#arrays());
    this.#planes = null; this.#shadow = null; this.#converted = []; this.#minimum = [];
    this.offset = 0; this.batchSize = null; this.rowOffsets = []; this.leftPad = [];
    this.#beforeRound = undefined; this.#ends = undefined;
  }
}

/** Positions [0, to) along axis 1 of every row, as an owned copy. */
function rowSliceAll(array: MlxArray, to: number): MlxArray {
  using view = array.slice([0, 0, 0], [array.shape[0]!, to, array.shape[2]!]);
  return ops.copyOf(view);
}

// ---------------------------------------------------------------------------
// Paged latent state

/** One row's pages: per stored plane a pool [numBlocks, blockSize, w], the
 * row's block table, its offset and the positions it holds as prefill padding. */
class LatentPages {
  pools: MlxArray[] = [];
  blockTable: number[] = [];
  #free: number[] = [];
  numBlocks = 0;
  offset = 0;
  constructor(readonly blockSize: number) {}

  clone(): LatentPages {
    const copy = new LatentPages(this.blockSize);
    copy.pools = this.pools.map(pool => ops.contiguous(pool));
    copy.blockTable = [...this.blockTable]; copy.#free = [...this.#free];
    copy.numBlocks = this.numBlocks; copy.offset = this.offset;
    return copy;
  }

  #grow(blocks: number): void {
    if (blocks <= this.numBlocks) return;
    this.pools = this.pools.map(pool => {
      using zeros = ops.zeros([blocks - this.numBlocks, ...pool.shape.slice(1)], pool.dtype);
      try { return ops.concatAxis([pool, zeros], 0); } finally { pool.dispose(); }
    });
    for (let i = blocks - 1; i >= this.numBlocks; i--) this.#free.push(i);
    this.numBlocks = blocks;
  }

  /** Append encoded planes [1, L, w_i] (borrowed) at the offset. */
  append(planes: readonly MlxArray[]): void {
    const L = planes[0]!.shape[1]!;
    if (!this.pools.length) {
      this.pools = planes.map(plane => ops.zeros([1, this.blockSize, plane.shape[2]!], plane.dtype));
      this.numBlocks = 1; this.#free = [0];
    }
    let written = 0;
    while (written < L) {
      const position = this.offset + written, block = Math.floor(position / this.blockSize), within = position % this.blockSize;
      while (this.blockTable.length <= block) {
        if (!this.#free.length) this.#grow(Math.max(this.numBlocks + 1, Math.ceil(this.numBlocks * 1.5)));
        this.blockTable.push(this.#free.pop()!);
      }
      const count = Math.min(this.blockSize - within, L - written), physical = this.blockTable[block]!;
      this.pools = this.pools.map((pool, index) => {
        const plane = planes[index]!;
        using piece = plane.slice([0, written, 0], [1, written + count, plane.shape[2]!]);
        try { return ops.sliceUpdate(pool, piece, [physical, within, 0], [physical + 1, within + count, plane.shape[2]!]); }
        finally { pool.dispose(); }
      });
      written += count;
    }
    this.offset += L;
  }

  /** The stored planes in order, [1, offset, w_i] each, owned. */
  gather(): MlxArray[] {
    if (!this.offset) return this.pools.map(pool => ops.zeros([1, 0, pool.shape[2]!], pool.dtype));
    using table = ops.fromInt32(this.blockTable, [this.blockTable.length]);
    return this.pools.map(pool => {
      using picked = ops.takeAxis(pool, table, 0);
      using flat = ops.reshape(picked, [1, this.blockTable.length * this.blockSize, pool.shape[2]!]);
      return ops.copyOf(flat.slice([0, 0, 0], [1, this.offset, pool.shape[2]!]));
    });
  }

  /** Drop the last `n` positions; tail blocks return to the free list. */
  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
    const need = Math.ceil(this.offset / this.blockSize);
    while (this.blockTable.length > need) this.#free.push(this.blockTable.pop()!);
  }

  /** Keep positions [from, to) (owned rewrite through the same encoding). */
  keep(from: number, to: number): void {
    const planes = this.gather();
    try {
      const kept = planes.map(plane => ops.copyOf(plane.slice([0, from, 0], [1, to, plane.shape[2]!])));
      try { this.trim(this.offset); this.append(kept); } finally { disposeResources(kept); }
    } finally { disposeResources(planes); }
  }

  /** Adopt saved pools (taking ownership) holding `offset` positions in `blockTable`'s blocks. */
  restore(pools: MlxArray[], blockTable: readonly number[], numBlocks: number, offset: number): void {
    this.dispose();
    const used = new Set(blockTable);
    this.pools = pools; this.blockTable = [...blockTable]; this.numBlocks = numBlocks; this.offset = offset;
    this.#free = Array.from({ length: numBlocks }, (_, i) => numBlocks - 1 - i).filter(i => !used.has(i));
  }

  dispose(): void { disposeResources(this.pools); this.pools = []; this.blockTable = []; this.#free = []; this.numBlocks = 0; this.offset = 0; }
}

/**
 * The latent attention state in pages of `blockSize` positions per row, stored
 * as `format` names from the first position (null: f32, the checkpoint-native
 * state, read as `MLACache` reads it). Each row owns its pages; a read gathers
 * every row's stored positions, decodes them and joins the rows right-justified
 * with zero padding, `MLACache`'s layout, so f32 pages read `MLACache`'s bits.
 * The transaction trims each row back to its accepted length (its tail pages
 * return to the row's free list); prefill padding is removed from each row's
 * pages when the prefill finalizes.
 */
export class PagedLatentCache implements BatchableCache, LatentAttentionCache {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  readonly indexHeadDim: number | null;
  readonly maxTokens: number;
  readonly #encodings: (FamilyEncoding | null)[];
  readonly #widths: number[];
  #rows: LatentPages[] = [];
  /** Per row, the leading positions it holds as left padding during a prefill. */
  #leading: number[] = [];
  #ends: number[] | undefined;
  #beforeRound: number[] | undefined;

  constructor(readonly geometry: LatentGeometry, readonly format: LatentFormat | null, readonly blockSize: number) {
    positiveInteger(blockSize, "latent page size");
    this.kvLoraRank = geometry.kvLoraRank;
    this.ropeHeadDim = geometry.ropeHeadDim;
    this.indexHeadDim = geometry.indexHeadDim ?? null;
    this.maxTokens = geometry.maxTokens ?? Number.MAX_SAFE_INTEGER;
    this.#widths = widthsOf(geometry);
    this.#encodings = this.#widths.map(width => format ? familyEncoding(format, width) : null);
  }

  signature(): string { return `kv:latent-paged:${this.indexHeadDim ? "dsa:" : ""}${formatKey(this.format)}:${this.blockSize}`; }
  get batchSize(): number | null { return this.#rows.length || null; }
  /** Each row's stored positions, prefill padding excluded. */
  get rowOffsets(): number[] { return this.#rows.map((row, index) => row.offset - (this.#leading[index] ?? 0)); }
  get offset(): number { return Math.max(0, ...this.#rows.map(row => row.offset)); }
  get leftPad(): number[] { const width = this.offset; return this.rowOffsets.map(offset => width - offset); }
  /** The pages of each row (borrowed); the SSD form. */
  get pages(): readonly LatentPages[] { return this.#rows; }

  #encode(values: readonly MlxArray[]): MlxArray[] {
    return values.flatMap((value, family) => this.#encodings[family]?.encode(value) ?? [ops.contiguous(value)]);
  }
  #decode(planes: readonly MlxArray[]): MlxArray[] {
    const out: MlxArray[] = [];
    let at = 0;
    try {
      for (const encoding of this.#encodings) {
        const count = encoding?.planes ?? 1;
        out.push(encoding ? encoding.decode(planes.slice(at, at + count)) : ops.contiguous(planes[at]!));
        at += count;
      }
      return out;
    } catch (error) { disposeResources(out); throw error; }
  }

  /** Every row's stored state decoded and joined right-justified: per family [B, T, W]. */
  #read(families: number): MlxArray[] {
    const width = this.offset;
    const perRow: MlxArray[][] = [];
    try {
      for (const row of this.#rows) {
        const planes = row.gather();
        try { perRow.push(this.#decode(planes).map(values => { try { return padLeft(values, width - row.offset); } finally { values.dispose(); } })); }
        finally { disposeResources(planes); }
      }
      return Array.from({ length: families }, (_, family) => ops.concatAxis(perRow.map(row => row[family]!), 0));
    } finally { disposeResources(perRow.flat()); }
  }

  appendLatent(latent: MlxArray, rope: MlxArray, indexKeys: MlxArray | null): LatentAttentionState {
    const [B, L] = appendShape(this.geometry, latent, rope, indexKeys, this.batchSize);
    if (this.offset > this.maxTokens - L) throw new RangeError(`latent append would exceed maxTokens ${this.maxTokens}`);
    if (!this.#rows.length) { this.#rows = Array.from({ length: B }, () => new LatentPages(this.blockSize)); this.#leading = new Array<number>(B).fill(0); }
    const inputs = [latent, rope, ...(indexKeys ? [indexKeys] : [])];
    for (const [index, row] of this.#rows.entries()) {
      const values = inputs.map(input => rowSlice(input, index, 0, L));
      try {
        const planes = this.#encode(values);
        try { row.append(planes); } finally { disposeResources(planes); }
      } finally { disposeResources(values); }
    }
    const read = this.#read(inputs.length);
    return { latent: read[0]!, rope: read[1]!, indexKeys: read[2] ?? null };
  }

  storedIndexKeys(): MlxArray | null {
    if (!this.indexHeadDim || !this.offset) return null;
    const all = this.#read(3);
    disposeResources(all.slice(0, 2));
    return all[2]!;
  }

  state(): MlxArray[] { return this.#rows.flatMap(row => row.pools); }
  bytesPerToken(): number {
    const pools = this.#rows[0]?.pools ?? [];
    return pools.length ? pools.reduce((bytes, pool) => bytes + pool.nbytes / (pool.shape[0]! * pool.shape[1]!), 0)
      : this.#widths.reduce((bytes, width) => bytes + width * 4, 0);
  }
  projectedBytes(tokens: number): number {
    return MLACache.projectedByteLength({ kvLoraRank: this.kvLoraRank, ropeHeadDim: this.ropeHeadDim,
      ...(this.indexHeadDim ? { dsa: { headDim: this.indexHeadDim } } : {}) }, 1, tokens);
  }
  isTrimmable(): boolean { return true; }
  trim(n: number): void {
    if (!Number.isSafeInteger(n) || n < 0 || n > Math.min(...this.rowOffsets, Infinity))
      throw new RangeError(`cannot trim ${n} tokens from latent pages`);
    for (const row of this.#rows) row.trim(n);
  }

  specRoundBegin(): void { this.#beforeRound = this.#rows.map(row => row.offset); }
  specRoundCommit(): void { this.#beforeRound = undefined; }
  specRoundRollback(keep: number | readonly number[]): void {
    const before = this.#beforeRound!;
    for (const [index, row] of this.#rows.entries()) row.trim(row.offset - before[index]! - (typeof keep === "number" ? keep : keep[index]!));
    this.#beforeRound = undefined;
  }

  preparePrefill(padding: PrefillPadding): void {
    if (!this.#rows.length) { this.#rows = padding.lengths.map(() => new LatentPages(this.blockSize)); this.#leading = padding.lengths.map(() => 0); }
    if (padding.leftPadding) this.#leading = this.#leading.map((lead, row) => lead + padding.leftPadding![row]!);
    this.#ends = padding.rightPadding?.some(pad => pad > 0)
      ? padding.lengths.map((length, row) => this.#rows[row]!.offset + length) : undefined;
  }
  finalizePrefill(): void {
    for (const [index, row] of this.#rows.entries()) {
      const lead = this.#leading[index] ?? 0, end = Math.min(row.offset, this.#ends?.[index] ?? row.offset);
      if (lead || end < row.offset) row.keep(lead, end);
    }
    this.#leading = this.#rows.map(() => 0); this.#ends = undefined;
  }

  makeEmptyBatch(): PagedLatentCache { return new PagedLatentCache(this.geometry, this.format, this.blockSize); }
  /** Adopt rows' pages (taking ownership): what extraction and the SSD form restore. */
  adoptRows(rows: LatentPages[]): void { this.dispose(); this.#rows = rows; this.#leading = rows.map(() => 0); }
  mergeRows(rows: readonly Cache[]): void {
    if (this.#rows.length) throw new Error("latent mergeRows requires an empty destination cache");
    const next: LatentPages[] = [];
    try {
      for (const source of rows) {
        if (!(source instanceof PagedLatentCache) || source.signature() !== this.signature())
          throw new Error(`latent pages cannot merge ${source.signature()} into ${this.signature()}`);
        if (!source.#rows.length) next.push(new LatentPages(this.blockSize));
        for (const row of source.#rows) next.push(row.clone());
      }
    } catch (error) { disposeResources(next); throw error; }
    this.adoptRows(next);
  }
  extractRow(row: number): PagedLatentCache {
    const out = this.makeEmptyBatch();
    out.adoptRows([this.#rows[row]!.clone()]);
    return out;
  }
  filterRows(keep: readonly number[]): void {
    const previous = this.#rows, retained = new Set(keep);
    this.#rows = keep.map(row => previous[row]!);
    this.#leading = keep.map(row => this.#leading[row] ?? 0);
    if (this.#ends) this.#ends = keep.map(row => this.#ends![row]!);
    disposeResources(previous.filter((_, row) => !retained.has(row)));
  }
  dispose(): void {
    disposeResources(this.#rows); this.#rows = []; this.#leading = [];
    this.#ends = undefined; this.#beforeRound = undefined;
  }
}

// ---------------------------------------------------------------------------
// Composition

/** The latent format a KV scheme names for the layer at cache index `layer`:
 * every layer of a uniform affine scheme, the listed layers of a per-layer one,
 * every layer under TurboQuant; none (f32) for bf16 and unlisted layers. */
export function latentFormatOf(kv: KvStorageScheme, layer: number): LatentFormat | null {
  switch (kv.kind) {
    case "bf16": return null;
    case "affine": return { kind: "affine", bits: kv.bits, groupSize: kv.groupSize };
    case "affine-layers": {
      const entry = kv.layers.find(item => item.layer === layer);
      return entry ? { kind: "affine", bits: entry.bits, groupSize: entry.groupSize } : null;
    }
    case "turbo": return { kind: "turbo", kBits: kv.kBits, vBits: kv.vBits };
  }
}

/** The latent attention cache a composition names for one layer: f32
 * (`MLACache`), f32-first encoded (`EncodedLatentCache`), or pages of either
 * (`PagedLatentCache`). */
export function composedLatentCache(kv: KvStorageScheme, paged: { readonly blockSize: number } | null, layer: number,
  geometry: LatentGeometry): LatentAttentionCache & BatchableCache {
  const format = latentFormatOf(kv, layer);
  if (paged) return new PagedLatentCache(geometry, format, paged.blockSize);
  const mla: MLACacheGeometry = { kvLoraRank: geometry.kvLoraRank, ropeHeadDim: geometry.ropeHeadDim,
    ...(geometry.maxTokens !== undefined ? { maxTokens: geometry.maxTokens } : {}),
    ...(geometry.indexHeadDim ? { dsa: { headDim: geometry.indexHeadDim } } : {}) };
  if (!format) return new MLACache(mla);
  return new EncodedLatentCache(geometry, format, kv.kind === "bf16" ? 0 : kv.quantizedKvStart ?? 0);
}

// ---------------------------------------------------------------------------
// The snapshot and SSD forms

const ENCODED: LatentLegoKind = "latent-encoded", PAGED: LatentLegoKind = "latent-paged";

const geometryHeader = (g: LatentGeometry) => ({
  kvLoraRank: g.kvLoraRank, ropeHeadDim: g.ropeHeadDim,
  ...(g.indexHeadDim ? { dsaHeadDim: g.indexHeadDim } : {}), ...(g.maxTokens !== undefined ? { maxTokens: g.maxTokens } : {}),
});
const geometryOf = (entry: CacheHeaderEntry): LatentGeometry => ({
  kvLoraRank: entry.kvLoraRank!, ropeHeadDim: entry.ropeHeadDim!,
  ...(entry.dsaHeadDim ? { indexHeadDim: entry.dsaHeadDim } : {}), ...(entry.maxTokens !== undefined ? { maxTokens: entry.maxTokens } : {}),
});
const formatHeader = (format: LatentFormat | null) => !format ? {}
  : format.kind === "affine" ? { bits: format.bits, groupSize: format.groupSize } : { kBits: format.kBits, vBits: format.vBits };
const formatOf = (entry: CacheHeaderEntry): LatentFormat | null =>
  entry.kBits ? { kind: "turbo", kBits: entry.kBits, vBits: entry.vBits! }
    : entry.bits ? { kind: "affine", bits: entry.bits, groupSize: entry.groupSize! } : null;

/** One serial encoded latent cache: its encoded planes, then its f32 shadow
 * while it has not converted. */
const encodedCodec: CacheCodec = {
  matches: cache => cache instanceof EncodedLatentCache,
  snapshot(cache, context) {
    const c = cache as EncodedLatentCache;
    if (c.batchSize !== 1) throw new Error(`persistence takes serial state; extract each of the ${c.batchSize} rows first`);
    const state = c.rowState(0);
    for (const array of [...state.planes.flat(), ...(state.shadow ?? [])]) context.push(array, true);
    return { kind: ENCODED, offset: state.offset, tensors: context.slots, ...geometryHeader(c.geometry), ...formatHeader(c.format),
      quantizedKvStart: c.start, latentShadow: state.shadow !== null };
  },
  clone(cache) {
    const c = cache as EncodedLatentCache;
    if (c.batchSize !== 1) throw new Error(`persistence takes serial state; extract each of the ${c.batchSize} rows first`);
    return c.extractRow(0);
  },
  load(entry, context) {
    const cache = new EncodedLatentCache(geometryOf(entry), formatOf(entry)!, entry.quantizedKvStart ?? 0);
    const arrays = entry.tensors.map(context.arr);
    const families = widthsOf(cache.geometry).length, perFamily = (arrays.length - (entry.latentShadow ? families : 0)) / families;
    const planes = Array.from({ length: families }, (_, f) => arrays.slice(f * perFamily, (f + 1) * perFamily));
    cache.restoreRow({ planes, shadow: entry.latentShadow ? arrays.slice(families * perFamily) : null,
      offset: entry.offset, minimumReusableOffset: entry.minimumReusableOffset ?? 0 });
    return cache;
  },
  headerTrimmable: () => true,
};

/** One serial paged latent cache: its pools and block table. */
const pagedCodec: CacheCodec = {
  matches: cache => cache instanceof PagedLatentCache,
  snapshot(cache, context) {
    const c = cache as PagedLatentCache;
    if (c.batchSize !== 1) throw new Error(`persistence takes serial state; extract each of the ${c.batchSize} rows first`);
    const pages = c.pages[0]!;
    for (const pool of pages.pools) context.push(pool, false);
    return { kind: PAGED, offset: pages.offset, tensors: context.slots, ...geometryHeader(c.geometry), ...formatHeader(c.format),
      latentPages: { blockSize: c.blockSize, blockTable: [...pages.blockTable], numBlocks: pages.numBlocks } };
  },
  clone(cache) {
    const c = cache as PagedLatentCache;
    if (c.batchSize !== 1) throw new Error(`persistence takes serial state; extract each of the ${c.batchSize} rows first`);
    return c.extractRow(0);
  },
  load(entry, context) {
    const layout = entry.latentPages!;
    const cache = new PagedLatentCache(geometryOf(entry), formatOf(entry), layout.blockSize);
    const pages = new LatentPages(layout.blockSize);
    pages.restore(entry.tensors.map(context.arr), layout.blockTable, layout.numBlocks, entry.offset);
    cache.adoptRows([pages]);
    return cache;
  },
  headerTrimmable: () => true,
};

/** The persistence codecs of every latent lego, by header kind. The default
 * codecs (`legacyCacheCodecs`) serve every other storage, `MLACache` included. */
export const LATENT_LEGO_CODECS: Readonly<Record<LatentLegoKind, CacheCodec>> = Object.freeze({
  [ENCODED]: encodedCodec, [PAGED]: pagedCodec,
});

/** The codec provider of a graph whose caches include latent legos: theirs, and
 * the default codecs for everything else. */
export const latentLegoCodecs: CacheCodecProvider = Object.freeze({
  id: `${legacyCacheCodecs.id}+latent-legos-v1`,
  forCache(cache: Cache): CacheCodec {
    return cache instanceof EncodedLatentCache ? encodedCodec : cache instanceof PagedLatentCache ? pagedCodec
      : legacyCacheCodecs.forCache(cache);
  },
  forHeader(entry: CacheHeaderEntry): CacheCodec {
    return entry.kind === ENCODED ? encodedCodec : entry.kind === PAGED ? pagedCodec : legacyCacheCodecs.forHeader(entry);
  },
});

"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.LatentLegos
