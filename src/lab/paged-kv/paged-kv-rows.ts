import type { BatchableCache, Cache, Mask } from "../../model/gemma4-base";
import { buildBatchedDecodeMask, mergeKVRows } from "../../model/batched-mask";
import { MlxArray } from "../../mlx/array";
import { disposeResources } from "../../engine/resources";
import { PagedKVCache, poolBlocksFor } from "./paged-kv";

/** Block storage owns row membership; attention consumes the same gathered
 * K/V representation as the existing paged cache. No scheduler policy here. */
export class PagedKvRows implements BatchableCache {
  #rows: PagedKVCache[] = [];
  #rope?: MlxArray;
  #ropeOffset = -1;

  constructor(readonly capacityTokens: number, readonly blockSize: number) {}
  signature(): string { return "kv:paged-rows"; }
  get batchSize(): number { return this.#rows.length; }
  get offset(): number { return Math.max(0, ...this.#rows.map(row => row.offset)); }
  get rowOffsets(): number[] { return this.#rows.map(row => row.offset); }
  get leftPad(): number[] { const width = this.offset; return this.#rows.map(row => width - row.offset); }
  get ropeOffsetArr(): MlxArray | undefined {
    if (this.#rows.length < 2) return undefined;
    if (!this.#rope || this.#ropeOffset !== this.offset) {
      this.releaseRopeArr();
      this.#rope = MlxArray.fromInt32(Int32Array.from(this.rowOffsets), [this.batchSize]);
      this.#ropeOffset = this.offset;
    }
    return this.#rope;
  }
  releaseRopeArr(): void { this.#rope?.dispose(); this.#rope = undefined; this.#ropeOffset = -1; }
  makeEmptyBatch(): PagedKvRows { return new PagedKvRows(this.capacityTokens, this.blockSize); }

  mergeRows(rows: readonly Cache[]): void {
    const next: PagedKVCache[] = [];
    try {
      for (const source of rows) {
        if (source instanceof PagedKvRows) {
          for (const row of source.#rows) next.push(row.clone());
        } else if (source instanceof PagedKVCache) next.push(source.clone());
        else throw new Error(`Paged rows cannot merge ${source.signature()}`);
      }
    } catch (error) { disposeResources(next); throw error; }
    const previous = this.#rows; this.#rows = next;
    this.releaseRopeArr(); disposeResources(previous);
  }
  extractRow(row: number): PagedKVCache { return this.#rows[row]!.clone(); }
  filterRows(keep: readonly number[]): void {
    const previous = this.#rows;
    this.#rows = keep.map(row => previous[row]!);
    const retained = new Set(keep);
    this.releaseRopeArr();
    disposeResources(previous.filter((_, row) => !retained.has(row)));
  }

  updateAndFetch(keys: MlxArray, values: MlxArray): [MlxArray, MlxArray] {
    if (this.#rows.length === 1) return this.#rows[0]!.updateAndFetch(keys, values);
    const fetched: Array<{ keys: MlxArray; values: MlxArray }> = [];
    try {
      for (const [row, storage] of this.#rows.entries()) {
        using k = keys.slice([row, 0, 0, 0], [row + 1, ...keys.shape.slice(1)]);
        using v = values.slice([row, 0, 0, 0], [row + 1, ...values.shape.slice(1)]);
        const [nextK, nextV] = storage.updateAndFetch(k, v);
        fetched.push({ keys: nextK, values: nextV });
      }
      const result = mergeKVRows(fetched);
      return [result.keys, result.values];
    } finally { disposeResources(fetched.flatMap(row => [row.keys, row.values])); }
  }
  makeMask(tokens: number, window: number | null): Mask {
    if (this.#rows.length === 1) return this.#rows[0]!.makeMask(tokens, window);
    return { mode: "array", arr: buildBatchedDecodeMask(this.batchSize, tokens,
      this.offset + tokens, this.leftPad, window) };
  }
  state(): MlxArray[] { return this.#rows.flatMap(row => row.state()); }
  isTrimmable(): boolean { return true; }
  trim(tokens: number): void { for (const row of this.#rows) row.trim(tokens); this.releaseRopeArr(); }
  projectedBytes(tokens: number): number {
    const pool = this.#rows.find(row => row.pool)?.pool;
    if (!pool) return 0;
    const bytesPerBlock = (pool.keys.nbytes + pool.values.nbytes) / pool.numBlocks;
    return poolBlocksFor(tokens, this.blockSize) * bytesPerBlock;
  }
  dispose(): void { const rows = this.#rows; this.#rows = []; this.releaseRopeArr(); disposeResources(rows); }
}
