import { captureFullKvDonorAttention } from "./full-kv-row-donor";
import { appendFullKvRows } from "./full-kv-row-append";
import { FullPrefillRow, fullRowPadding, fullRowPhysicalLength } from "./full-prefill-row";
import { captureKvAttention } from "./kv-attention-view";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { FullTransitioningKvRows } from "./full-transitioning-kv-rows";
import { BatchedQuantizedKVCache } from "./batched-quantized-kv";
import { KVCache } from "./kv";
import { QuantizedKVCache } from "./quantized-kv";
import { convertToAffine, transitionDue } from "./bf16-first-kv";
import { unfusedAffineKernels } from "./affine-attention";
import { type AttentionCache, type AttentionRead, type Cache, type Mask, type KvAttentionState, type KvAttentionView } from "../contracts/mlx/cache";

/** The bf16 source of a full-attention row: a `KVCache`, or a padded
 * `FullPrefillRow` over one. Converted rows have none. */
function affineSource(row: Cache): KVCache | FullPrefillRow | undefined {
  return row instanceof FullPrefillRow ? row.affineConversion : row instanceof KVCache ? row : undefined;
}

/** The affine transition of `Bf16FirstQuantizedKVCache` over full-attention
 * rows: each row converts with its own `toQuantized` once it holds `start`
 * positions. */
function settleAffineRows(rows: Cache[], groupSize: number, bits: number, start: number): void {
  for (let index = 0; index < rows.length; index++) {
    const source = affineSource(rows[index]!);
    if (source && transitionDue(source.offset, start)) rows[index] = convertToAffine<Cache>(source, groupSize, bits, start);
  }
}

/** The rows of the affine bf16-first lego (`Bf16FirstQuantizedKVCache`) for
 * continuous batching. Each row is bf16 until it holds `start` positions and
 * converts by the same transition; rows cross independently, a converted row
 * keeps its native quantized-attention arithmetic, and once all rows convert,
 * their packed planes use the existing batched attention implementation. When
 * a row converts is described on `TransitioningKvRows`. The reads are the
 * graph's call today: this layout's mask before the append, then its attention
 * view. */
export class DelayedQuantizedKVCache extends FullTransitioningKvRows<BatchedQuantizedKVCache> implements KvAttentionState, AttentionCache {
  constructor(readonly groupSize: number, readonly bits: number, readonly start: number, row?: Cache) {
    super({ signature: `kv:delayed-quant:${bits}:${groupSize}:${start}`, conversionOffset: start,
      settle: rows => settleAffineRows(rows, groupSize, bits, start),
      keepsDenseReads: row => { const source = affineSource(row); return !source || !transitionDue(source.offset, start); },
      converted: row => row instanceof QuantizedKVCache,
      // The delayed lego is not composed yet (B1): unfused, the uniform `--kv-quant N` composition.
      makeLayout: () => new BatchedQuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)) }, row);
  }
  get attentionState(): KvAttentionState { return this; }
  captureDonorAttention() {
    return this.packed?.captureDonorAttention() ?? captureFullKvDonorAttention(this.rows, this.leftPad, this.offset);
  }
  makeEmptyBatch(): DelayedQuantizedKVCache { return new DelayedQuantizedKVCache(this.groupSize, this.bits, this.start); }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead { return this.#read(k, v); }
  appendWindow(k: MlxArray, v: MlxArray): AttentionRead { return this.#read(k, v); }
  /** The graph's read today: the mask from this layout before the append (no
   * sliding window), then the attention view the append returns. */
  #read(k: MlxArray, v: MlxArray): AttentionRead {
    const mask = this.makeMask(k.shape[2]!, null);
    let view: KvAttentionView;
    try { view = this.appendAndFetch(k, v); } catch (error) { mask.arr?.dispose(); throw error; }
    return { attend: (q, scale) => view.attend(q, scale, mask), dispose() { view.dispose(); mask.arr?.dispose(); } };
  }
  /** Plain keys and values at the model's B while every row is still plain,
   * assembled as the plain attention view does; the caller owns them. Once a
   * row is converted, or the transition this append runs converts one, reading plain
   * is an error raised before any row appends. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    this.advancePlain();
    return this.#appendPlain(k, v);
  }
  #appendPlain(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const [keys, values] = appendFullKvRows(this.rows, this.leftPad, this.offset + k.shape[2]!, k, v);
    try { this.syncPositions(true); } catch (error) { keys.dispose(); values.dispose(); throw error; }
    return [keys, values];
  }
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView {
    this.advance();
    if (this.packed) return captureKvAttention(this.packed, k, v);
    if (this.rows.every(row => !row.quantizedAttention)) {
      const [keys, values] = this.#appendPlain(k, v);
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
      attend(q, scale, mask, independentPositions) {
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
            outputs.push(view.attend(qr, scale, { mode: mask.mode, arr }, independentPositions));
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
