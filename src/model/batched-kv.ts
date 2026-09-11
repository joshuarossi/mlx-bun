import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { materializeCopy } from "../mlx/materialize";
import { KVCache, isPlainKvCache, type BatchableCache, type Cache, type Mask, type PaddedPrefillCache, type PrefillPadding } from "./gemma4-base";
import { FullPrefillPadding } from "./full-prefill-padding";

/** Full-attention storage with independently advancing row positions.
 * Speculative rollback changes coverage, without moving the retained KV.
 * Subsequent appends overwrite each row's rejected suffix in place when MLX
 * can donate the buffer. Queue membership is outside this layout. */
export class BatchedKVCache implements BatchableCache, PaddedPrefillCache {
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  rowOffsets: number[] = [];
  leftPad: number[] = [];
  #rope: MlxArray | undefined;
  #beforeRound: number[] | undefined;
  readonly #padding = new FullPrefillPadding();

  restorePrefillEnds(ends: readonly number[] | undefined): void { this.#padding.restoreEnds(ends); }
  preparePrefill(padding: PrefillPadding): void {
    this.#padding.prepare(this, padding); this.#positionsChanged();
  }
  finalizePrefill(): void {
    const next = this.#padding.finalize(this.state(), this);
    if (!next) return;
    this.keys?.dispose(); this.values?.dispose();
    this.keys = next[0] ?? null; this.values = next[1] ?? null;
    this.#positionsChanged();
  }

  captureDonorRows(): import("./gemma4-base").KvDonorRows {
    const B = this.rowOffsets.length, width = this.offset;
    const keys = this.keys!.slice([0,0,0,0], [B,this.keys!.shape[1]!,width,this.keys!.shape[3]!]);
    let values: MlxArray;
    try { values = this.values!.slice([0,0,0,0], [B,this.values!.shape[1]!,width,this.values!.shape[3]!]); }
    catch (error) { keys.dispose(); throw error; }
    return { keys, values, offsets: [...this.rowOffsets], starts: [...this.leftPad], ends: this.#ends() };
  }

  signature(): string { return "kv:batched-positions"; }
  get batchSize(): number | null { return this.rowOffsets.length || null; }
  get offset(): number { return Math.max(0, ...this.#ends()); }
  #ends(): number[] { return this.rowOffsets.map((offset, row) => offset + this.leftPad[row]!); }
  get ropeOffsetArr(): MlxArray | undefined {
    // A common unpadded position uses the existing scalar RoPE operation.
    if (this.leftPad.every(pad => pad === 0) && this.rowOffsets.every(offset => offset === this.rowOffsets[0])) return undefined;
    return this.#rope ??= ops.fromInt32(this.rowOffsets, [this.rowOffsets.length]);
  }
  #positionsChanged(): void { this.#rope?.dispose(); this.#rope = undefined; }
  makeEmptyBatch(): BatchedKVCache { return new BatchedKVCache(); }
  bytesPerToken(): number {
    if (!this.keys || !this.values) return 0;
    return (this.keys.nbytes + this.values.nbytes) / (this.rowOffsets.length * this.keys.shape[2]!);
  }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * tokens; }
  state(): MlxArray[] { return this.keys && this.values ? [this.keys, this.values] : []; }
  isTrimmable(): boolean { return true; }
  trim(count: number): void {
    this.rowOffsets = this.rowOffsets.map(offset => offset - count);
    this.#positionsChanged();
  }
  specRoundBegin(): void { this.#beforeRound = [...this.rowOffsets]; }
  specRoundCommit(): void { this.#beforeRound = undefined; }
  specRoundRollback(keep: number | readonly number[]): void {
    this.rowOffsets = this.#beforeRound!.map((offset, row) => offset + (typeof keep === "number" ? keep : keep[row]!));
    this.#beforeRound = undefined;
    this.#positionsChanged();
  }

  makeMask(N: number, window: number | null): Mask {
    const B = this.rowOffsets.length, ends = this.#ends(), S = this.offset + N;
    if (window === null && this.leftPad.every(pad => pad === 0) && ends.every(end => end === ends[0]))
      return { mode: N === 1 ? "" : "causal", arr: null };
    using starts = ops.fromInt32(ends, [B, 1, 1, 1]);
    using relative = ops.arange(0, N, 1, Dtype.int32);
    using queries = ops.reshape(relative, [1, 1, N, 1]);
    using position = ops.add(starts, queries);
    using indices = ops.arange(0, S, 1, Dtype.int32);
    using keys = ops.reshape(indices, [1, 1, 1, S]);
    using pads = ops.fromInt32(this.leftPad, [B, 1, 1, 1]);
    using causal = ops.lessEqual(keys, position);
    using valid = ops.greaterEqual(keys, pads);
    const mask = ops.logicalAnd(causal, valid);
    if (window === null) return { mode: "array", arr: mask };
    using windowSize = ops.fromInt32([window], []);
    using limit = ops.add(keys, windowSize);
    using within = ops.less(position, limit);
    try { return { mode: "array", arr: ops.logicalAnd(mask, within) }; }
    finally { mask.dispose(); }
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const B = this.rowOffsets.length, N = k.shape[2]!, ends = this.#ends();
    const needed = Math.max(...ends) + N;
    const grow = (array: MlxArray) => {
      const [rows, heads, capacity, width] = array.shape as [number, number, number, number];
      if (capacity >= needed) return array;
      using padding = ops.zeros([rows, heads, Math.ceil(needed / 256) * 256 - capacity, width], array.dtype);
      const grown = ops.concatAxis([array, padding], 2);
      array.dispose();
      return grown;
    };
    const allocate = (input: MlxArray) => ops.zeros(
      [B, input.shape[1]!, Math.ceil(needed / 256) * 256, input.shape[3]!], input.dtype);
    this.keys = this.keys ? grow(this.keys) : allocate(k);
    this.values = this.values ? grow(this.values) : allocate(v);
    const common = ends.every(end => end === ends[0]);
    using positions = common ? null : ops.fromInt32(ends.flatMap(end =>
      Array.from({ length: N }, (_, position) => end + position)), [B, 1, N, 1]);
    const append = (array: MlxArray, values: MlxArray) => common
      ? ops.sliceUpdate(array, values, [0, 0, ends[0]!, 0], [B, array.shape[1]!, ends[0]! + N, array.shape[3]!])
      : ops.putAlongAxis(array, positions!, values, 2);
    const keys = append(this.keys, k);
    let values: MlxArray;
    try { values = append(this.values, v); }
    catch (error) { keys.dispose(); throw error; }
    this.keys.dispose(); this.values.dispose();
    this.keys = keys; this.values = values;
    this.rowOffsets = this.rowOffsets.map(offset => offset + N);
    this.#positionsChanged();
    return [keys.slice([0, 0, 0, 0], [B, keys.shape[1]!, needed, keys.shape[3]!]),
      values.slice([0, 0, 0, 0], [B, values.shape[1]!, needed, values.shape[3]!])];
  }

  mergeRows(rows: readonly Cache[]): void {
    const only = rows.length === 1 ? rows[0] : undefined;
    if (only && (only instanceof BatchedKVCache || isPlainKvCache(only))) {
      // Preserve allocated capacity when a request starts alone. Immutable
      // aliases transfer ownership without copying its prefill storage.
      const keys = only.keys ? ops.copyOf(only.keys) : null;
      let values: MlxArray | null;
      try { values = only.values ? ops.copyOf(only.values) : null; }
      catch (error) { keys?.dispose(); throw error; }
      const offsets = only instanceof BatchedKVCache ? [...only.rowOffsets] : [only.offset];
      const pads = only instanceof BatchedKVCache ? [...only.leftPad] : [0];
      this.dispose(); this.keys = keys; this.values = values;
      this.rowOffsets = offsets; this.leftPad = pads;
      return;
    }
    const chunks: Array<{ keys: MlxArray | null; values: MlxArray | null; offsets: number[]; pads: number[]; width: number }> = [];
    const held: MlxArray[] = [];
    try {
      for (const cache of rows) {
        let keys: MlxArray | null, values: MlxArray | null, offsets: number[], pads: number[];
        if (cache instanceof BatchedKVCache && cache.offset === 0) {
          keys = values = null; offsets = [...cache.rowOffsets]; pads = [...cache.leftPad];
        } else if (cache instanceof BatchedKVCache) {
          const B = cache.rowOffsets.length, width = cache.offset;
          keys = cache.keys!.slice([0, 0, 0, 0], [B, cache.keys!.shape[1]!, width, cache.keys!.shape[3]!]);
          held.push(keys);
          values = cache.values!.slice([0, 0, 0, 0], [B, cache.values!.shape[1]!, width, cache.values!.shape[3]!]);
          held.push(values);
          offsets = [...cache.rowOffsets]; pads = [...cache.leftPad];
        } else if (isPlainKvCache(cache)) {
          if (cache.offset === 0) keys = values = null;
          else { [keys, values] = cache.temporalView(); held.push(keys, values); }
          offsets = [cache.offset]; pads = [0];
        } else throw new Error(`full-attention batch cannot merge ${cache.signature()}`);
        chunks.push({ keys, values, offsets, pads, width: keys?.shape[2] ?? 0 });
      }
      const width = Math.max(0, ...chunks.map(chunk => chunk.width));
      const padded = (array: MlxArray, count: number) => {
        if (!count) return array;
        using padding = ops.zeros([array.shape[0]!, array.shape[1]!, count, array.shape[3]!], array.dtype);
        const result = ops.concatAxis([padding, array], 2); held.push(result); return result;
      };
      const merge = (field: "keys" | "values") => {
        if (!width) return null; // Geometry arrives with the first append.
        const prototype = chunks.find(chunk => chunk[field])![field]!;
        return ops.concatAxis(chunks.map(chunk => {
          const array = chunk[field];
          if (array) return padded(array, width - chunk.width);
          const empty = ops.zeros([chunk.offsets.length, prototype.shape[1]!, width, prototype.shape[3]!], prototype.dtype);
          held.push(empty); return empty;
        }), 0);
      };
      const keys = merge("keys");
      let values: MlxArray | null;
      try { values = merge("values"); }
      catch (error) { keys?.dispose(); throw error; }
      this.dispose();
      this.keys = keys; this.values = values;
      this.rowOffsets = chunks.flatMap(chunk => chunk.offsets);
      this.leftPad = chunks.flatMap(chunk => chunk.pads.map(pad => pad + width - chunk.width));
    } finally { for (const array of held) array.dispose(); }
  }

  filterRows(rows: readonly number[]): void {
    if (!rows.length) { this.dispose(); return; }
    const pads = rows.map(row => this.leftPad[row]!);
    const sharedPadding = Math.min(...pads);
    using indices = this.keys ? ops.fromInt32([...rows], [rows.length]) : null;
    const select = (array: MlxArray | null): MlxArray | null => {
      if (!array) return null;
      const selected = ops.takeAxis(array, indices!, 0);
      if (!sharedPadding) return selected;
      // mlx-lm BatchKVCache.filter removes padding common to all survivors.
      // Keeping it changes attention reduction geometry after retirement.
      try { return selected.slice([0, 0, sharedPadding, 0], [...selected.shape]); }
      finally { selected.dispose(); }
    };
    const keys = select(this.keys);
    let values: MlxArray | null;
    try { values = select(this.values); }
    catch (error) { keys?.dispose(); throw error; }
    this.keys?.dispose(); this.values?.dispose();
    this.keys = keys; this.values = values;
    this.rowOffsets = rows.map(row => this.rowOffsets[row]!);
    this.leftPad = pads.map(pad => pad - sharedPadding);
    this.#padding.filter(rows);
    this.#positionsChanged();
  }

  extractRow(row: number): KVCache {
    const start = this.leftPad[row]!, count = this.rowOffsets[row]!;
    if (count === 0) return new KVCache();
    const copy = (array: MlxArray) => {
      using view = array.slice([row, 0, start, 0], [row + 1, array.shape[1]!, start + count, array.shape[3]!]);
      return materializeCopy(view);
    };
    const keys = copy(this.keys!);
    let values: MlxArray;
    try { values = copy(this.values!); }
    catch (error) { keys.dispose(); throw error; }
    const cache = new KVCache(); cache.restoreState(keys, values, count); return cache;
  }

  dispose(): void {
    this.keys?.dispose(); this.values?.dispose(); this.#positionsChanged();
    this.keys = this.values = null;
    this.rowOffsets = []; this.leftPad = []; this.#beforeRound = undefined; this.#padding.clear();
  }
}
