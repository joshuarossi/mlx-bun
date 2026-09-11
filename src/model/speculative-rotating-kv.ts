import { rotatingSourcePosition } from "./rotating-kv-layout";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { type BatchableCache, type Cache, type Mask, type PrefillPadding, RotatingKVCache } from "./gemma4-base";
import { BatchedRotatingCache } from "./batched-rotating";
import { rollbackRotatingRing } from "./rotating-row-transaction";
import { BatchedRotatingState } from "./batched-rotating-state";
import { plainRowStorage, temporalStorageView } from "./batched-row-storage";
import { disposeResources } from "../engine/resources";

/** Ring transactions retain accepted KV columns, including rounds that cross
 * the window boundary. The verify block already retains the complete history
 * needed by its earliest query; no target recomputation or scheduler policy. */
export class SpeculativeRotatingKVCache implements BatchableCache {
  #inner: BatchedRotatingCache;
  #before?: number[];
  constructor(readonly maxSize: number) { this.#inner = new BatchedRotatingCache(maxSize, []); }
  signature(): string { return "kv:rotating-plain"; }
  get offset(): number { return this.#inner.offset; }
  get rowOffsets(): readonly number[] { return this.#inner.offsetArr; }
  get leftPad(): readonly number[] { return this.#inner.leftPad; }
  get batchSize(): number { return this.#inner.batchSize; }
  get ropeOffsetArr(): MlxArray { return this.#inner.ropeOffsetArr; }
  makeEmptyBatch(): SpeculativeRotatingKVCache { return new SpeculativeRotatingKVCache(this.maxSize); }
  makeMask(tokens: number, window: number | null): Mask { return this.#inner.makeMask(tokens, window); }
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.#inner.updateAndFetch(k, v); }
  preparePrefill(padding: PrefillPadding): void { this.#inner.preparePrefill(padding); }
  finalizePrefill(): void { this.#inner.finalizePrefill(); }
  state(): MlxArray[] { return this.#inner.state(); }
  isTrimmable(): boolean { return this.#inner.isTrimmable(); }
  trim(count: number): void { this.#inner.trim(count); }
  bytesPerToken(): number {
    const state = this.state();
    return state.length ? state.reduce((n, a) => n + a.nbytes, 0) / (this.batchSize * state[0]!.shape[2]!) : 0;
  }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * Math.min(tokens, this.maxSize); }
  extractRow(row: number): Cache {
    const result = new RotatingKVCache(this.maxSize);
    if (!this.rowOffsets[row] || !this.#inner.keys || !this.#inner.values) return result;
    const position = new BatchedRotatingState(this.maxSize, []); position.restore(this.#inner.positionSnapshot);
    const range = { row, from: Math.max(0, position.leftPad[row]!, position.activeLength - this.maxSize),
      to: position.activeLength, copy: true };
    const keys = temporalStorageView(plainRowStorage, this.#inner.keys, position, range);
    let values: MlxArray;
    try { values = temporalStorageView(plainRowStorage, this.#inner.values, position, range); }
    catch (error) { keys.dispose(); throw error; }
    result.restoreState(keys, values, this.rowOffsets[row]!, keys.shape[2]!); return result;
  }
  captureDonorRows(): import("./gemma4-base").KvDonorRows {
    const position = new BatchedRotatingState(this.maxSize, []); position.restore(this.#inner.positionSnapshot);
    const from = Math.max(0, position.activeLength - this.maxSize);
    const range = { from, to: position.activeLength };
    const keys = temporalStorageView(plainRowStorage, this.#inner.keys!, position, range); let values: MlxArray;
    try { values = temporalStorageView(plainRowStorage, this.#inner.values!, position, range); }
    catch (error) { keys.dispose(); throw error; }
    return { keys, values, offsets: [...this.rowOffsets], starts: this.leftPad.map(pad => Math.max(0, pad - from)),
      ends: this.rowOffsets.map(() => position.activeLength - from) };
  }

  filterRows(keep: readonly number[]): void { this.#inner.filterRows(keep); }
  mergeRows(sources: readonly Cache[]): void {
    const only = sources.length === 1 ? sources[0] : undefined;
    if (only instanceof SpeculativeRotatingKVCache) {
      const keys = only.#inner.keys ? ops.copyOf(only.#inner.keys) : null;
      let values: MlxArray | null;
      try { values = only.#inner.values ? ops.copyOf(only.#inner.values) : null; }
      catch (error) { keys?.dispose(); throw error; }
      const next = BatchedRotatingCache.adoptPhysical(keys, values, only.#inner.positionSnapshot);
      this.#inner.dispose(); this.#inner = next; return;
    }
    const held: Cache[] = [], planes: { keys: MlxArray; values: MlxArray }[] = [], offsets: number[] = [];
    try {
      const rows = sources.flatMap(source => source instanceof SpeculativeRotatingKVCache
        ? Array.from({ length: source.batchSize }, (_, row) => { const cache = source.extractRow(row); held.push(cache); return cache; })
        : [source]) as RotatingKVCache[];
      const prototype = rows.find(row => row.keys !== null);
      if (!prototype) {
        this.#inner.dispose(); this.#inner = new BatchedRotatingCache(this.maxSize, rows.map(() => 0)); return;
      }
      for (const cache of rows) {
        const state = rotatingSourcePosition(cache);
        const range = { from: Math.max(0, state.activeLength - this.maxSize), to: state.activeLength };
        const plane = (field: "keys" | "values") => cache[field]
          ? temporalStorageView(plainRowStorage, cache[field]!, state, range)
          : ops.zeros([1, prototype[field]!.shape[1]!, 0, prototype[field]!.shape[3]!], prototype[field]!.dtype);
        const keys = plane("keys"); let values: MlxArray;
        try { values = plane("values"); } catch (error) { keys.dispose(); throw error; }
        planes.push({ keys, values }); offsets.push(cache.offset);
      }
      const next = BatchedRotatingCache.merge(planes, offsets, this.maxSize);
      this.#inner.dispose(); this.#inner = next;
    } finally { disposeResources([...held, ...planes.flatMap(row => [row.keys, row.values])]); }
  }
  specRoundBegin(): void { this.#before = [...this.rowOffsets]; }
  specRoundCommit(): void { this.#before = undefined; }
  specRoundRollback(keep: number | readonly number[]): void {
    this.#inner = rollbackRotatingRing(this.#inner, this.#before!, keep);
    this.#before = undefined;
  }
  dispose(): void { this.#before = undefined; this.#inner.dispose(); }
}
