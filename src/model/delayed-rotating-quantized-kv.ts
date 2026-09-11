import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { RotatingKVCache, type Cache, type KvAttentionState, type KvAttentionView, type PaddedPrefillCache, type PrefillPadding } from "./gemma4-base";
import { SpeculativeTransitioningKvRows } from "../backends/mlx/transitioning-kv-rows";
import { AlignedRotatingCache, alignRotatingRows, RotatingAffineLayout, SpeculativeRotatingAffineLayout, RotatingKvPositions } from "./rotating-kv-layout";
import { BatchedRotatingQuantCache } from "./batched-rotating-quant";
import { captureKvAttention, combineKvDonorAttention } from "./kv-attention-view";

/** Precision changes preserve each row's physical columns. The model owns
 * queries and scale; the shared lifecycle owns membership and conversion. */
export class DelayedRotatingQuantizedKVCache extends SpeculativeTransitioningKvRows<RotatingAffineLayout> implements KvAttentionState, PaddedPrefillCache {
  constructor(readonly maxSize: number, readonly groupSize: number, readonly bits: number, readonly start: number,
    readonly maintain: (rows: Cache[]) => void, row?: Cache, readonly speculative = false) {
    super({ signature: `kv:delayed-rotating-quant:${maxSize}:${bits}:${groupSize}:${start}`, maintain,
      converted: row => row instanceof AlignedRotatingCache && row.inner instanceof BatchedRotatingQuantCache,
      makeLayout: () => speculative ? new SpeculativeRotatingAffineLayout(maxSize, groupSize, bits) : new RotatingAffineLayout(maxSize, groupSize, bits), prepareRows: alignRotatingRows,
      packRows: (layout, rows) => layout.adoptAlignedRows(rows as readonly AlignedRotatingCache[]),
      extractRow: row => (row as AlignedRotatingCache).extract(speculative ? maxSize : undefined),
      rollbackRow: (row, before, keep, preserve) => (row as AlignedRotatingCache).rollback(before, keep, preserve) }, row, new RotatingKvPositions(maxSize));
  }
  get attentionState(): KvAttentionState { return this; }
  captureDonorAttention(): import("./gemma4-base").KvDonorAttention {
    if (this.packed) return this.packed.captureDonorAttention();
    const views: import("./gemma4-base").KvDonorAttention[] = [];
    try {
      for (const row of this.rows) views.push((row as AlignedRotatingCache).captureDonorAttention());
      return combineKvDonorAttention(views);
    } catch (error) { for (const view of views) view.dispose(); throw error; }
  }
  override makeMask(tokens: number, window: number | null) {
    if (this.speculative && this.leftPad.every(pad => pad === 0) &&
        this.offset + tokens <= Math.min(this.maxSize, window ?? this.maxSize))
      return { mode: tokens === 1 ? "" as const : "causal" as const, arr: null };
    return super.makeMask(tokens, window);
  }
  preparePrefill(padding: PrefillPadding): void {
    if (!this.batchSize) {
      const rows = padding.lengths.map(() => new RotatingKVCache(this.maxSize));
      try { this.mergeRows(rows); } finally { for (const row of rows) row.dispose(); }
    }
    if (this.packed) { this.packed.preparePrefill(padding); return; }
    // Every physical row follows the same block geometry, even when only a
    // sibling has right padding. The token lengths still belong to each row.
    const rightPaddedBatch = padding.rightPadding?.some(pad => pad > 0);
    for (const [row, cache] of this.rows.entries()) (cache as AlignedRotatingCache).inner.preparePrefill({
      lengths: [padding.lengths[row]!],
      ...(padding.leftPadding ? { leftPadding: [padding.leftPadding[row]!] } : {}),
      ...(padding.rightPadding ? { rightPadding: [padding.rightPadding[row]!] } : {}),
    }, rightPaddedBatch);
    this.syncPositions(true);
  }
  finalizePrefill(): void {
    if (this.packed) { this.packed.finalizePrefill(); return; }
    for (const cache of this.rows) (cache as AlignedRotatingCache).inner.finalizePrefill();
    this.syncPositions(true);
  }
  get maxTokens(): number { return this.maxSize; }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * Math.min(tokens, this.maxSize); }
  makeEmptyBatch(): DelayedRotatingQuantizedKVCache {
    return new DelayedRotatingQuantizedKVCache(this.maxSize, this.groupSize, this.bits, this.start, this.maintain, undefined, this.speculative);
  }
  updateAndFetch(): [MlxArray, MlxArray] { throw new Error("mixed precision rows use their attention state"); }
  releaseRopeArr(): void { this.packed?.releaseRopeArr(); }
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView {
    this.advance();
    if (this.packed) return captureKvAttention(this.packed, k, v);
    const views: KvAttentionView[] = [];
    try {
      for (const [row, cache] of this.rows.entries()) {
        const slice = (a: MlxArray) => a.slice([row, 0, 0, 0], [row + 1, a.shape[1]!, a.shape[2]!, a.shape[3]!]);
        using kr = slice(k), vr = slice(v);
        views.push(captureKvAttention(cache, kr, vr));
      }
      this.syncPositions(true);
    } catch (error) { for (const view of views) view.dispose(); throw error; }
    return {
      attend(q, scale, mask) {
        const outputs: MlxArray[] = [];
        try {
          for (const [row, view] of views.entries()) {
            using qr = q.slice([row, 0, 0, 0], [row + 1, q.shape[1]!, q.shape[2]!, q.shape[3]!]);
            const start = mask.arr?.shape.map(() => 0), end = mask.arr ? [...mask.arr.shape] : undefined;
            if (start && end && end.length === 4 && end[0]! > 1) { start[0] = row; end[0] = row + 1; }
            using arr = mask.arr ? mask.arr.slice(start!, end!) : null;
            outputs.push(view.attend(qr, scale, { mode: mask.mode, arr }));
          }
          return outputs.length === 1 ? ops.contiguous(outputs[0]!) : ops.concatAxis(outputs, 0);
        } finally { for (const output of outputs) output.dispose(); }
      },
      dispose() { for (const view of views) view.dispose(); },
    };
  }
}
