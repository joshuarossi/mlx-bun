import { SsmPrefillPadding } from "./ssm-prefill-padding";
import type { PaddedPrefillCache, PrefillPadding } from "./gemma4-base";
import * as ops from "../mlx/ops";
import type { MlxArray } from "../mlx/array";
import type { BatchableCache, Cache } from "./gemma4-base";
import { SSMCache } from "./qwen3-delta";

/** Recurrent storage behind the same row-layout port as attention KV.
 * Inputs to merge are borrowed; request membership is owned by the caller. */
export class BatchedSSMCache extends SSMCache implements BatchableCache, PaddedPrefillCache {
  constructor() { super(); this.offsets = []; }
  preparePrefill(padding: PrefillPadding): void {
    if (!this.offsets!.length) this.offsets = padding.lengths.map(() => 0);
    const padded = padding.leftPadding?.some(n => n > 0) || padding.rightPadding?.some(n => n > 0);
    this.prefillPadding = padded ? new SsmPrefillPadding(padding) : null;
  }
  finalizePrefill(): void { this.prefillPadding = null; }
  get rowOffsets(): readonly number[] { return this.offsets!; }
  get leftPad(): readonly number[] { return this.rowOffsets.map(() => 0); }
  makeEmptyBatch(): BatchedSSMCache { return new BatchedSSMCache(); }
  projectedBytes(_tokens: number): number {
    return this.batchSize ? this.state().reduce((bytes, array) => bytes + array.nbytes, 0) / this.batchSize : 0;
  }

  mergeRows(rows: readonly Cache[]): void {
    if (!rows.length) { this.dispose(); return; }
    const sources = rows as readonly SSMCache[];
    const offsets = sources.flatMap(source => source.offsets ?? [source.offset]);
    const merge = (field: "conv" | "recurrent"): MlxArray | null => {
      const prototype = sources.find(source => source[field])?.[field];
      if (!prototype) return null;
      if (sources.length === 1) return ops.copyOf(prototype);
      const empty: MlxArray[] = [];
      try {
        return ops.concatAxis(sources.map(source => {
          if (source[field]) return source[field]!;
          const zeros = ops.zeros([source.offsets?.length ?? 1, ...prototype.shape.slice(1)], prototype.dtype);
          empty.push(zeros); return zeros;
        }), 0);
      } finally { for (const array of empty) array.dispose(); }
    };
    const conv = merge("conv");
    let recurrent;
    try { recurrent = merge("recurrent"); }
    catch (error) { conv?.dispose(); throw error; }
    this.dispose();
    this.conv = conv; this.recurrent = recurrent;
    this.offsets = offsets; this.offset = Math.max(0, ...offsets);
  }

  override dispose(): void { super.dispose(); this.offset = 0; this.offsets = []; }
}
