import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { RotatingKVCache } from "./rotating-kv";
import { type AttentionCache, type AttentionRead, type Cache, type KvAttentionState, type KvAttentionView, type PaddedPrefillCache, type PrefillPadding } from "../contracts/mlx/cache";
import { SpeculativeTransitioningKvRows } from "./transitioning-kv-rows";
import { AlignedRotatingCache, alignRotatingRows, RotatingAffineLayout, SpeculativeRotatingAffineLayout, RotatingKvPositions } from "./rotating-kv-layout";
import { BatchedRotatingQuantCache } from "./batched-rotating-quant";
import { captureKvAttention, combineKvDonorAttention } from "./kv-attention-view";
import { convertToAffine, transitionDue } from "./bf16-first-kv";
import { unfusedAffineKernels } from "./affine-attention";

/** The affine transition of `Bf16FirstRotatingQuantizedKVCache` over aligned
 * ring rows: a plain ring converts its physical columns with its own
 * `toQuantized` once it holds `start` positions. */
function settleAffineRings(rows: Cache[], groupSize: number, bits: number, start: number): void {
  for (let index = 0; index < rows.length; index++) {
    const source = (rows[index] as AlignedRotatingCache).affineConversion;
    if (source && transitionDue(source.offset, start)) rows[index] = convertToAffine(source, groupSize, bits, start);
  }
}

/** The rows of the rotating affine bf16-first lego
 * (`Bf16FirstRotatingQuantizedKVCache`) for continuous batching. Precision
 * changes preserve each row's physical columns. The model owns queries and
 * scale; the shared lifecycle owns membership and the transition (when a row
 * converts is described on `TransitioningKvRows`). A `start` of `Infinity`
 * never converts: the prefill cohort's layout for plain rings. The reads are
 * the graph's call today: this layout's mask before the append, under the
 * ring's window, then its attention view. */
export class DelayedRotatingQuantizedKVCache extends SpeculativeTransitioningKvRows<RotatingAffineLayout>
  implements KvAttentionState, PaddedPrefillCache, AttentionCache {
  constructor(readonly maxSize: number, readonly groupSize: number, readonly bits: number, readonly start: number,
    row?: Cache, readonly speculative = false) {
    super({ signature: `kv:delayed-rotating-quant:${maxSize}:${bits}:${groupSize}:${start}`, conversionOffset: start,
      settle: rows => settleAffineRings(rows, groupSize, bits, start),
      keepsDenseReads: row => {
        const source = (row as AlignedRotatingCache).affineConversion;
        return !source || !transitionDue(source.offset, start);
      },
      converted: row => row instanceof AlignedRotatingCache && row.inner instanceof BatchedRotatingQuantCache,
      // The delayed lego is not composed yet (B1): unfused, the uniform `--kv-quant N` composition.
      makeLayout: () => { const kernels = unfusedAffineKernels(bits, groupSize, Dtype.bfloat16);
        return speculative ? new SpeculativeRotatingAffineLayout(maxSize, groupSize, bits, kernels) : new RotatingAffineLayout(maxSize, groupSize, bits, kernels); },
      prepareRows: alignRotatingRows,
      packRows: (layout, rows) => layout.adoptAlignedRows(rows as readonly AlignedRotatingCache[]),
      extractRow: row => (row as AlignedRotatingCache).extract(speculative ? maxSize : undefined),
      rollbackRow: (row, before, keep, preserve) => (row as AlignedRotatingCache).rollback(before, keep, preserve) }, row, new RotatingKvPositions(maxSize));
  }
  get attentionState(): KvAttentionState { return this; }
  captureDonorAttention(): import("../contracts/mlx/cache").KvDonorAttention {
    if (this.packed) return this.packed.captureDonorAttention();
    const views: import("../contracts/mlx/cache").KvDonorAttention[] = [];
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

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead { return this.#read(k, v); }
  appendWindow(k: MlxArray, v: MlxArray): AttentionRead { return this.#read(k, v); }
  /** The graph's read today: the mask from this layout before the append, with
   * the ring's window, then the attention view the append returns. */
  #read(k: MlxArray, v: MlxArray): AttentionRead {
    const mask = this.makeMask(k.shape[2]!, this.maxSize);
    let view: KvAttentionView;
    try { view = this.appendAndFetch(k, v); } catch (error) { mask.arr?.dispose(); throw error; }
    return { attend: (q, scale) => view.attend(q, scale, mask), dispose() { view.dispose(); mask.arr?.dispose(); } };
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
    return new DelayedRotatingQuantizedKVCache(this.maxSize, this.groupSize, this.bits, this.start, undefined, this.speculative);
  }
  /** Plain keys and values while every row is still plain: each row's own
   * ring answers (one row keeps its physical columns and phase; several share
   * one aligned geometry) and rows join along the batch; the caller owns them.
   * Once a row is converted, or the transition this append runs converts one, reading
   * plain is an error raised before any row appends. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    this.advancePlain();
    const rows = this.rows as AlignedRotatingCache[];
    if (rows.length === 1) {
      const [keys, values] = rows[0]!.updateAndFetch(k, v);
      try { this.syncPositions(true); } catch (error) { keys.dispose(); values.dispose(); throw error; }
      return [keys, values];
    }
    const parts: MlxArray[][] = [];
    try {
      for (const [row, cache] of rows.entries()) {
        const slice = (a: MlxArray) => a.slice([row, 0, 0, 0], [row + 1, a.shape[1]!, a.shape[2]!, a.shape[3]!]);
        using kr = slice(k), vr = slice(v);
        parts.push(cache.updateAndFetch(kr, vr));
      }
      this.syncPositions(true);
      const keys = ops.concatAxis(parts.map(part => part[0]!), 0);
      try { return [keys, ops.concatAxis(parts.map(part => part[1]!), 0)]; } catch (error) { keys.dispose(); throw error; }
    } finally { for (const array of parts.flat()) array.dispose(); }
  }
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
