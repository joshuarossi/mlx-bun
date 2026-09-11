import { captureFullKvDonorAttention } from "../backends/mlx/full-kv-row-donor";
import { appendFullKvRows } from "../backends/mlx/full-kv-row-append";
import { fullRowPadding, fullRowPhysicalLength } from "./full-prefill-row";
import { captureKvAttention } from "./kv-attention-view";
import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { FullTransitioningKvRows } from "../backends/mlx/full-transitioning-kv-rows";
import { BatchedQuantizedKVCache } from "./batched-quantized-kv";
import { QuantizedKVCache, type Cache, type Mask, type KvAttentionState, type KvAttentionView } from "./gemma4-base";

/** Affine storage keeps its native quantized-attention arithmetic while rows
 * cross the conversion boundary independently. Once all rows convert, their
 * packed planes use the existing batched attention implementation. */
export class DelayedQuantizedKVCache extends FullTransitioningKvRows<BatchedQuantizedKVCache> implements KvAttentionState {
  constructor(readonly groupSize: number, readonly bits: number, readonly start: number,
    readonly maintain: (rows: Cache[]) => void, row?: Cache) {
    super({ signature: `kv:delayed-quant:${bits}:${groupSize}:${start}`, maintain,
      converted: row => row instanceof QuantizedKVCache,
      makeLayout: () => new BatchedQuantizedKVCache(groupSize, bits) }, row);
  }
  get attentionState(): KvAttentionState { return this; }
  captureDonorAttention() {
    return this.packed?.captureDonorAttention() ?? captureFullKvDonorAttention(this.rows, this.leftPad, this.offset);
  }
  makeEmptyBatch(): DelayedQuantizedKVCache { return new DelayedQuantizedKVCache(this.groupSize, this.bits, this.start, this.maintain); }
  updateAndFetch(): [MlxArray, MlxArray] { throw new Error("mixed precision rows use their attention state"); }
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView {
    this.advance();
    if (this.packed) return captureKvAttention(this.packed, k, v);
    if (this.rows.every(row => !row.quantizedAttention)) {
      const [keys, values] = appendFullKvRows(this.rows, this.leftPad, this.offset + k.shape[2]!, k, v);
      try { this.syncPositions(true); } catch (error) { keys.dispose(); values.dispose(); throw error; }
      return { attend: (q, scale, mask) => ops.sdpa(q, keys, values, scale, mask.mode, mask.arr),
        dispose() { keys.dispose(); values.dispose(); } };
    }
    const views: KvAttentionView[] = [], pads = this.rows.map((row, index) => this.leftPad[index]! - fullRowPadding(row));
    const lengths = this.rows.map(cache => fullRowPhysicalLength(cache) + k.shape[2]!);
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
            // Capture alignment with the KV tensors, never consult live rows.
            const start = mask.arr?.shape.map(() => 0), end = mask.arr ? [...mask.arr.shape] : undefined;
            if (start && end) {
              if (end.length === 4 && end[0]! > 1) { start[0] = row; end[0] = row + 1; }
              start[start.length - 1] = pads[row]!;
              end[end.length - 1] = pads[row]! + lengths[row]!;
            }
            using arr = mask.arr ? mask.arr.slice(start!, end!) : null;
            outputs.push(view.attend(qr, scale, { mode: mask.mode, arr }));
          }
          return outputs.length === 1 ? ops.contiguous(outputs[0]!) : ops.concatAxis(outputs, 0);
        } finally { for (const output of outputs) output.dispose(); }
      },
      dispose() { for (const view of views) view.dispose(); },
    };
  }
  updateAndAttend(q: MlxArray, k: MlxArray, v: MlxArray, scale: number, mask: Mask): MlxArray {
    const view = this.appendAndFetch(k, v);
    try { return view.attend(q, scale, mask); } finally { view.dispose(); }
  }
}
