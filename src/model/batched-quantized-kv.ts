import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { cleanupFailure, disposeResources } from "../engine/resources";
import { BatchedKVCache } from "./batched-kv";
import { KVCache, QuantizedKVCache, isQuantizedKvCache,
  type BatchableCache, type Cache, type Mask, type QuantizedAttentionState, type PaddedPrefillCache, type PrefillPadding } from "./gemma4-base";

import { KvTensorRows } from "../backends/mlx/kv-tensor-rows";
import { quantizedDonorAttention } from "./kv-attention-view";

const FIELDS = ["packed", "scales", "biases"] as const;

/** Affine KV uses the same row-position storage operations for its packed
 * values, scales and biases. No dequantization or requantization is needed
 * for merge, rollback, retirement or extraction. Inputs share this codec. */
export class BatchedQuantizedKVCache implements BatchableCache, QuantizedAttentionState, PaddedPrefillCache {
  #planes = FIELDS.map(() => new BatchedKVCache());
  #minimum: number[] = [];
  get minimumReusableOffset(): number { return Math.max(0, ...this.#minimum); }
  constructor(readonly groupSize: number, readonly bits: number) {}
  restorePrefillEnds(ends: readonly number[] | undefined): void { for (const plane of this.#planes) plane.restorePrefillEnds(ends); }
  preparePrefill(padding: PrefillPadding): void {
    for (const plane of this.#planes) plane.preparePrefill(padding);
    if (!this.#minimum.length) this.#minimum = padding.lengths.map(() => 0);
  }
  finalizePrefill(): void { for (const plane of this.#planes) plane.finalizePrefill(); }
  get quantizedAttention(): QuantizedAttentionState { return this; }
  captureDonorAttention(): import("./gemma4-base").KvDonorAttention {
    const views: import("./gemma4-base").KvDonorRows[] = [];
    try {
      for (const plane of this.#planes) views.push(plane.captureDonorRows());
      const field = (name: "keys" | "values") => ({
        packed: views[0]![name], scales: views[1]![name], biases: views[2]![name],
      });
      const { offsets, starts, ends } = views[0]!;
      return quantizedDonorAttention(field("keys"), field("values"), { offsets, starts, ends }, this.groupSize, this.bits);
    } catch (error) { disposeResources(views.flatMap(view => [view.keys, view.values])); throw error; }
  }
  signature(): string { return `kv:batched-quant:${this.bits}:${this.groupSize}`; }
  get rowOffsets(): readonly number[] { return this.#planes[0]!.rowOffsets; }
  get leftPad(): readonly number[] { return this.#planes[0]!.leftPad; }
  get batchSize(): number | null { return this.#planes[0]!.batchSize; }
  get offset(): number { return this.#planes[0]!.offset; }
  get ropeOffsetArr(): MlxArray | undefined { return this.#planes[0]!.ropeOffsetArr; }
  makeEmptyBatch(): BatchedQuantizedKVCache { return new BatchedQuantizedKVCache(this.groupSize, this.bits); }
  bytesPerToken(): number { return this.#planes.reduce((n, plane) => n + plane.bytesPerToken(), 0); }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * tokens; }
  makeMask(tokens: number, window: number | null): Mask { return this.#planes[0]!.makeMask(tokens, window); }
  isTrimmable(): boolean { return true; }
  trim(count: number): void { for (const plane of this.#planes) plane.trim(count); }
  specRoundBegin(): void { for (const plane of this.#planes) plane.specRoundBegin(); }
  specRoundCommit(): void { for (const plane of this.#planes) plane.specRoundCommit(); }
  specRoundRollback(keep: number | readonly number[]): void {
    for (const plane of this.#planes) plane.specRoundRollback(keep);
  }
  updateAndFetch(): [MlxArray, MlxArray] { throw new Error("quantized attention uses updateAndFetchQuantized"); }

  updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    using inputs = new DisposableStack();
    const key = ops.quantize(k, this.groupSize, this.bits);
    for (const field of FIELDS) inputs.use(key[field]);
    const value = ops.quantize(v, this.groupSize, this.bits);
    for (const field of FIELDS) inputs.use(value[field]);
    const held: MlxArray[] = [], keys: Partial<ops.QuantizedTensor> = {}, values: Partial<ops.QuantizedTensor> = {};
    try {
      for (const [index, field] of FIELDS.entries()) {
        const [kk, vv] = this.#planes[index]!.updateAndFetch(key[field], value[field]);
        held.push(kk, vv); keys[field] = kk; values[field] = vv;
      }
      return [keys as ops.QuantizedTensor, values as ops.QuantizedTensor];
    } catch (error) { return cleanupFailure(error, () => disposeResources(held)); }
  }

  /** Borrow prepared request state. All planes stage replacements before
   * releasing the current group, preserving donor ownership on failure. */
  mergeRows(rows: readonly Cache[]): void {
    const next: BatchedKVCache[] = [];
    try {
      for (const [index, field] of FIELDS.entries()) {
        const held: KVCache[] = [], inputs: Cache[] = [];
        try {
          for (const row of rows) {
            if (row instanceof BatchedQuantizedKVCache) inputs.push(row.#planes[index]!);
            else if (isQuantizedKvCache(row)) {
              const view = new KVCache(); held.push(view);
              if (row.offset > 0) {
                const key = ops.copyOf(row.keys![field]);
                let value: MlxArray;
                try { value = ops.copyOf(row.values![field]); }
                catch (error) { key.dispose(); throw error; }
                view.restoreState(key, value, row.offset);
              }
              inputs.push(view);
            } else throw new Error(`quantized row layout cannot merge ${row.signature()}`);
          }
          const plane = new BatchedKVCache(); next.push(plane); plane.mergeRows(inputs);
        } finally { disposeResources(held); }
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    const previous = this.#planes; this.#planes = next; disposeResources(previous);
    this.#minimum = rows.flatMap(row => row instanceof BatchedQuantizedKVCache ? row.#minimum : [row.minimumReusableOffset ?? 0]);
  }

  alignRows(leftPad: readonly number[]): void {
    if (leftPad.every((pad, row) => pad === this.leftPad[row])) return;
    const aligned = new KvTensorRows();
    try {
    aligned.mergeRows([{ planes: this.#planes.flatMap(plane => plane.keys ? [plane.keys, plane.values!] : []),
      rowOffsets: this.rowOffsets, leftPad: this.leftPad }]);
    aligned.alignRows(leftPad);
    for (const plane of this.#planes) {
      plane.keys?.dispose(); plane.values?.dispose();
      plane.keys = aligned.planes.shift() ?? null; plane.values = aligned.planes.shift() ?? null;
      plane.leftPad = [...leftPad];
    }
    } finally { aligned.dispose(); }
  }
  filterRows(keep: readonly number[]): void {
    for (const plane of this.#planes) plane.filterRows(keep);
    this.#minimum = keep.map(row => this.#minimum[row]!);
  }
  state(): MlxArray[] {
    if (!this.#planes[0]!.keys) return [];
    return [...this.#planes.map(plane => plane.keys!), ...this.#planes.map(plane => plane.values!)];
  }

  /** Return the existing persisted representation, owning compact arrays. */
  extractRow(row: number): QuantizedKVCache {
    const offset = this.rowOffsets[row]!, result = new QuantizedKVCache(this.groupSize, this.bits);
    if (this.#minimum[row]) result.minimumReusableOffset = this.#minimum[row];
    if (offset === 0) return result;
    const held: KVCache[] = [];
    try {
      for (const plane of this.#planes) held.push(plane.extractRow(row));
      result.restoreState(
        { packed: held[0]!.keys!, scales: held[1]!.keys!, biases: held[2]!.keys! },
        { packed: held[0]!.values!, scales: held[1]!.values!, biases: held[2]!.values! }, offset);
      for (const cache of held) cache.keys = cache.values = null;
      return result;
    } finally { disposeResources(held); }
  }

  dispose(): void { disposeResources(this.#planes); this.#minimum = []; }
}
