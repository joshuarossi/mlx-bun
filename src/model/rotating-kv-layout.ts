import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { cloneKvCaches } from "../kv-store";
import { type BatchableCache, type Cache, type Mask, type PaddedPrefillCache, type PrefillPadding, RotatingKVCache, RotatingQuantizedKVCache } from "./gemma4-base";
import { BatchedRotatingCache, buildBatchedRotatingMask } from "./batched-rotating";
import { BatchedRotatingQuantCache } from "./batched-rotating-quant";
import { BatchedRotatingState, type RotatingPositionSnapshot } from "./batched-rotating-state";
import { plainRowStorage, quantizedRowStorage, temporalStorageView } from "./batched-row-storage";
import type { TransitioningKvPositions, TransitionedKvLayout } from "../backends/mlx/transitioning-kv-rows";
import { captureRotatingDonorAttention } from "./rotating-kv-donor";

import { rollbackRotatingRing } from "./rotating-row-transaction";

const fields = ["packed", "scales", "biases"] as const;
type Ring = BatchedRotatingCache | BatchedRotatingQuantCache;

function combinedPosition(rings: readonly Ring[]): RotatingPositionSnapshot {
  const states = rings.map(ring => ring.positionSnapshot);
  return { ...states[0]!, offsets: states.map(state => state.offsets[0]!),
    leftPad: states.map(state => state.leftPad[0]!),
    prefillEnds: states[0]!.prefillEnds
      ? states.map(state => state.prefillEnds![0]!) : undefined };
}

/** One logical request with the group's physical ring geometry. This keeps
 * masks stable while different requests cross their precision boundary. */
export class AlignedRotatingCache implements Cache {
  minimumReusableOffset = 0;
  constructor(public inner: Ring) {}
  get offset(): number { return this.inner.validOffset(0); }
  get affineConversion(): AlignedRotatingCache | undefined { return this.inner instanceof BatchedRotatingCache ? this : undefined; }
  get quantizedAttention() { return this.inner instanceof BatchedRotatingQuantCache ? this.inner : undefined; }
  signature(): string { return this.inner.signature(); }
  captureDonorAttention() { return captureRotatingDonorAttention(this.inner); }
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.inner.updateAndFetch(k, v); }
  makeMask(tokens: number, window: number | null): Mask { return this.inner.makeMask(tokens, window); }
  isTrimmable(): boolean { return this.inner.positionSnapshot.totalOffset < this.inner.maxSize; }
  trim(count: number): void { this.inner.trim(count); }
  rollback(before: number, keep: number, preserveColumns: boolean): void {
    this.inner = rollbackRotatingRing(this.inner, [before], keep, preserveColumns);
  }
  state(): MlxArray[] { return this.inner.state(); }
  bytesPerToken(): number {
    const state = this.state(), tokens = state[0]?.shape[2] ?? 0;
    return tokens ? state.reduce((n, a) => n + a.nbytes, 0) / tokens : 0;
  }
  dispose(): void { this.inner.dispose(); }
  extract(limit?: number): Cache {
    const row = this.inner.extractRow(0, limit) ?? (this.inner instanceof BatchedRotatingQuantCache
      ? new RotatingQuantizedKVCache(this.inner.maxSize, this.inner.groupSize, this.inner.bits)
      : new RotatingKVCache(this.inner.maxSize));
    row.minimumReusableOffset = this.minimumReusableOffset;
    return row;
  }
  toQuantized(groupSize: number, bits: number): AlignedRotatingCache {
    const plain = this.inner as BatchedRotatingCache;
    const keys = ops.quantize(plain.keys!, groupSize, bits);
    let values: ops.QuantizedTensor;
    try { values = ops.quantize(plain.values!, groupSize, bits); }
    catch (error) { quantizedRowStorage.dispose(keys); throw error; }
    const next = new AlignedRotatingCache(BatchedRotatingQuantCache.adoptPhysical(keys, values, groupSize, bits, plain.positionSnapshot));
    next.minimumReusableOffset = this.minimumReusableOffset;
    this.dispose();
    return next;
  }
}

/** Borrow the newest valid window from a solo cache, including a temporary
 * oversized block. No dequantization or physical-ring normalization in place. */
export function rotatingSourcePosition(row: RotatingKVCache | RotatingQuantizedKVCache): BatchedRotatingState {
  const state = new BatchedRotatingState(row.maxSize, [0], [row.offset]);
  const length = row instanceof RotatingKVCache ? row.keys?.shape[2] ?? 0 : row.keys?.packed.shape[2] ?? 0;
  state.restore({ maxSize: row.maxSize, offsets: [row.offset], leftPad: [0], totalOffset: row.offset,
    ringIndex: row.ringIdx, rotated: row.ringIdx < row.offset && row.ringIdx < length });
  return state;
}

/** Take ownership of solo rows and align them once at membership changes. */
export function alignRotatingRows(rows: Cache[]): AlignedRotatingCache[] {
  const width = Math.max(0, ...rows.map(row => Math.min(row.offset, (row as RotatingKVCache).maxSize)));
  const prototype = rows.find(row => row.state().length > 0) as RotatingKVCache | RotatingQuantizedKVCache | undefined;
  const emptyPlane = (field: "keys" | "values"): MlxArray | null => {
    if (!width || !prototype) return null;
    const tensor = prototype[field]!;
    if (tensor instanceof MlxArray) return ops.zeros([1, tensor.shape[1]!, width, tensor.shape[3]!], tensor.dtype);
    return ops.zeros([1, tensor.packed.shape[1]!, width, tensor.packed.shape[3]! * 32 / (prototype as RotatingQuantizedKVCache).bits], tensor.scales.dtype);
  };
  const result: AlignedRotatingCache[] = [];
  try {
    for (const source of rows) {
      if (!(source instanceof RotatingKVCache || source instanceof RotatingQuantizedKVCache))
        throw new Error(`rotating layout cannot adopt ${source.signature()}`);
      const length = Math.min(source.offset, source.maxSize), pad = width - length;
      const position: RotatingPositionSnapshot = { maxSize: source.maxSize, offsets: [source.offset], leftPad: [pad],
        totalOffset: width, ringIndex: width, rotated: false };
      const state = rotatingSourcePosition(source);
      const options = { from: Math.max(0, state.activeLength - length), to: state.activeLength };
      let inner: Ring;
      if (source instanceof RotatingKVCache) {
        using k = source.keys ? temporalStorageView(plainRowStorage, source.keys, state, options) : null;
        using v = source.values ? temporalStorageView(plainRowStorage, source.values, state, options) : null;
        const keys = k ? plainRowStorage.padLeft(k, pad) : emptyPlane("keys");
        let values: MlxArray | null;
        try { values = v ? plainRowStorage.padLeft(v, pad) : emptyPlane("values"); }
        catch (error) { keys?.dispose(); throw error; }
        inner = BatchedRotatingCache.adoptPhysical(keys, values, position);
      } else {
        const k = source.keys ? temporalStorageView(quantizedRowStorage, source.keys, state, options) : null;
        const v = source.values ? temporalStorageView(quantizedRowStorage, source.values, state, options) : null;
        const empty = (field: "keys" | "values") => {
          using tensor = emptyPlane(field);
          return tensor ? ops.quantize(tensor, source.groupSize, source.bits) : null;
        };
        try {
          const keys = k ? quantizedRowStorage.padLeft(k, pad) : empty("keys");
          let values: ops.QuantizedTensor | null;
          try { values = v ? quantizedRowStorage.padLeft(v, pad) : empty("values"); }
          catch (error) { if (keys) quantizedRowStorage.dispose(keys); throw error; }
          inner = BatchedRotatingQuantCache.adoptPhysical(keys, values, source.groupSize, source.bits, position);
        } finally { if (k) quantizedRowStorage.dispose(k); if (v) quantizedRowStorage.dispose(v); }
      }
      const row = new AlignedRotatingCache(inner); row.minimumReusableOffset = source.minimumReusableOffset ?? 0;
      result.push(row);
    }
  } catch (error) { for (const row of result) row.dispose(); throw error; }
  for (const row of rows) row.dispose();
  return result;
}

/** Position state has no codec or attention arithmetic. */
export class RotatingKvPositions implements TransitioningKvPositions {
  #state: BatchedRotatingState;
  #rope?: MlxArray;
  constructor(maxSize: number) { this.#state = new BatchedRotatingState(maxSize, []); }
  get rowOffsets(): readonly number[] { return this.#state.offsets; }
  get leftPad(): readonly number[] { return this.#state.leftPad; }
  get offset(): number { return this.#state.totalOffset; }
  get batchSize(): number | null { return this.#state.batchSize || null; }
  get ropeOffsetArr(): MlxArray | undefined {
    if (!this.batchSize) return undefined;
    return this.#rope ??= ops.fromInt32([...this.rowOffsets], [this.batchSize]);
  }
  sync(rows: readonly Cache[]): void {
    this.#rope?.dispose(); this.#rope = undefined;
    if (!rows.length) { this.#state = new BatchedRotatingState(this.#state.maxSize, []); return; }
    this.#state.restore(combinedPosition(rows.map(row => (row as AlignedRotatingCache).inner)));
  }
  filterRows(keep: readonly number[]): void { this.#state.filter(keep); this.#rope?.dispose(); this.#rope = undefined; }
  makeMask(tokens: number, window: number | null): Mask {
    return { mode: "array", arr: buildBatchedRotatingMask(this.#state.batchSize, tokens, this.#state.leftPad,
      this.#state.maxSize, window ?? this.#state.maxSize, this.#state.ringIndex, this.#state.totalOffset, this.#state.rotated,
      tokens > 1 || this.#state.hasPendingPadding) };
  }
  dispose(): void { this.#rope?.dispose(); this.#rope = undefined; this.#state = new BatchedRotatingState(this.#state.maxSize, []); }
}

/** Once all rows use affine storage, concatenate their already-aligned planes
 * without changing ring columns or rebuilding any attention mask. */
export class RotatingAffineLayout implements TransitionedKvLayout, PaddedPrefillCache {
  #inner?: BatchedRotatingQuantCache;
  #before?: number[];
  #minimum: number[] = [];
  constructor(readonly maxSize: number, readonly groupSize: number, readonly bits: number) {}
  get minimumReusableOffset(): number { return Math.max(0, ...this.#minimum); }
  get quantizedAttention() { return this.#inner; }
  captureDonorAttention(): import("./gemma4-base").KvDonorAttention {
    return captureRotatingDonorAttention(this.#inner!);
  }
  get rowOffsets(): readonly number[] { return this.#inner?.offsetArr ?? []; }
  get leftPad(): readonly number[] { return this.#inner?.leftPad ?? []; }
  get offset(): number { return this.#inner?.offset ?? 0; }
  get batchSize(): number | null { return this.#inner?.batchSize || null; }
  get ropeOffsetArr(): MlxArray | undefined { return this.#inner?.ropeOffsetArr; }
  get maxTokens(): number { return this.maxSize; }
  signature(): string { return `kv:rotating-affine:${this.maxSize}:${this.groupSize}:${this.bits}`; }
  makeEmptyBatch(): RotatingAffineLayout { return new RotatingAffineLayout(this.maxSize, this.groupSize, this.bits); }
  makeMask(tokens: number, window: number | null): Mask { return this.#inner!.makeMask(tokens, window); }
  preparePrefill(padding: PrefillPadding): void { this.#inner!.preparePrefill(padding); }
  finalizePrefill(): void { this.#inner!.finalizePrefill(); }
  bytesPerToken(): number {
    const tokens = this.#inner?.keys?.packed.shape[2] ?? 0;
    return tokens ? this.state().reduce((n, a) => n + a.nbytes, 0) / (tokens * this.#inner!.batchSize) : 0;
  }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * Math.min(tokens, this.maxSize); }
  isTrimmable(): boolean { return this.#inner!.positionSnapshot.totalOffset < this.maxSize; }
  trim(count: number): void { this.#inner!.trim(count); }
  specRoundBegin(): void { this.#before = [...this.rowOffsets]; }
  specRoundCommit(): void { this.#before = undefined; }
  specRoundRollback(keep: number | readonly number[]): void {
    this.#inner = rollbackRotatingRing(this.#inner!, this.#before!, keep);
    this.#before = undefined;
  }
  updateAndFetch(): [MlxArray, MlxArray] { return this.#inner!.updateAndFetch(); }
  releaseRopeArr(): void { this.#inner?.releaseRopeArr(); }
  mergeRows(rows: readonly Cache[]): void {
    const owned: Cache[] = [];
    try {
      for (const row of rows) {
        if (row instanceof RotatingAffineLayout) {
          for (let i = 0; i < (row.batchSize ?? 0); i++) owned.push(row.extractRow(i));
        } else if (row instanceof AlignedRotatingCache) owned.push(row.extract());
        else owned.push(...cloneKvCaches([row]));
      }
      if (!owned.length) { this.dispose(); return; }
      const aligned = alignRotatingRows(owned); owned.length = 0;
      try { this.adoptAlignedRows(aligned); } finally { for (const row of aligned) row.dispose(); }
    } finally { for (const row of owned) row.dispose(); }
  }
  adoptAlignedRows(rows: readonly AlignedRotatingCache[]): void {
    const rings = rows.map(row => (row as AlignedRotatingCache).inner as BatchedRotatingQuantCache);
    const position = combinedPosition(rings);
    if (rings.every(row => !row.keys)) {
      const empty = BatchedRotatingQuantCache.adoptPhysical(null, null, this.groupSize, this.bits,
        position);
      this.#inner?.dispose(); this.#inner = empty; this.#minimum = rows.map(row => row.minimumReusableOffset ?? 0);
      return;
    }
    const merge = (field: "keys" | "values") => {
      const planes: MlxArray[] = [];
      try {
        for (const part of fields) planes.push(ops.concatAxis(rings.map(row => row[field]![part]), 0));
        return { packed: planes[0]!, scales: planes[1]!, biases: planes[2]! };
      } catch (error) { for (const plane of planes) plane.dispose(); throw error; }
    };
    const keys = merge("keys"); let values: ops.QuantizedTensor;
    try { values = merge("values"); } catch (error) { quantizedRowStorage.dispose(keys); throw error; }
    const inner = BatchedRotatingQuantCache.adoptPhysical(keys, values, this.groupSize, this.bits,
      position);
    this.#inner?.dispose(); this.#inner = inner; this.#minimum = rows.map(row => row.minimumReusableOffset ?? 0);
  }
  filterRows(keep: readonly number[]): void { this.#inner!.filterRows(keep); this.#minimum = keep.map(row => this.#minimum[row]!); }
  extractRow(row: number): Cache {
    return this.extract(row);
  }
  protected extract(row: number, limit?: number): Cache {
    const result = this.#inner!.extractRow(row, limit) ?? new RotatingQuantizedKVCache(this.maxSize, this.groupSize, this.bits);
    result.minimumReusableOffset = this.#minimum[row] ?? 0; return result;
  }
  state(): MlxArray[] { return this.#inner?.state() ?? []; }
  dispose(): void { this.#inner?.dispose(); this.#inner = undefined; this.#minimum = []; this.#before = undefined; }
}

/** A committed speculative checkpoint contains only the newest valid window. */
export class SpeculativeRotatingAffineLayout extends RotatingAffineLayout {
  #ropeForOffset = -1;
  override get ropeOffsetArr(): MlxArray | undefined {
    if (this.#ropeForOffset !== this.offset) {
      this.releaseRopeArr(); this.#ropeForOffset = this.offset;
    }
    return super.ropeOffsetArr;
  }
  override makeEmptyBatch(): SpeculativeRotatingAffineLayout {
    return new SpeculativeRotatingAffineLayout(this.maxSize, this.groupSize, this.bits);
  }
  override makeMask(tokens: number, window: number | null): Mask {
    if (this.leftPad.every(pad => pad === 0) &&
        this.offset + tokens <= Math.min(this.maxSize, window ?? this.maxSize))
      return { mode: tokens === 1 ? "" : "causal", arr: null };
    return super.makeMask(tokens, window);
  }
  override extractRow(row: number): Cache { return this.extract(row, this.maxSize); }
}
