import { captureFullKvDonorRows } from "./full-kv-row-donor";
import { decodedKvDonorAttention } from "./decoded-kv-donor";
import { appendFullKvRows } from "./full-kv-row-append";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { unrotateValues } from "../kernels/turboquant/ops";
import { type AttentionCache, type AttentionRead, type Cache, type RotatedValueAttentionState } from "../contracts/mlx/cache";
import { TurboQuantKVCache } from "./turboquant-kv";
import { BatchedTurboQuantKVCache } from "./batched-turboquant-kv";
import { FullTransitioningKvRows } from "./full-transitioning-kv-rows";
import { FullPrefillRow } from "./full-prefill-row";
import { KVCache } from "./kv";
import { completeConversion, convertToTurboQuant, transitionDue } from "./bf16-first-kv";

/** The TurboQuant transition of `Bf16FirstTurboQuantKVCache` over
 * full-attention rows: a bf16 row (`KVCache`, or a padded `FullPrefillRow`
 * over one) encodes its live window once it holds `start` positions. */
function settleTurboQuantRows(rows: Cache[], kBits: number, vBits: number, start: number, fusedDecode: boolean): void {
  for (let index = 0; index < rows.length; index++) {
    const row = rows[index]!;
    if (row instanceof FullPrefillRow) {
      const source = row.turboConversion;
      if (!source || !transitionDue(source.offset, start)) continue;
      const offset = source.offset;
      rows[index] = completeConversion(source.toTurboQuantized(kBits, vBits, fusedDecode), offset, start);
    } else if (row instanceof KVCache && transitionDue(row.offset, start)) {
      rows[index] = convertToTurboQuant(row, kBits, vBits, start, fusedDecode);
    }
  }
}

/** The rows of the TurboQuant bf16-first lego (`Bf16FirstTurboQuantKVCache`)
 * for continuous batching: TurboQuant tensor access and value-domain handling
 * over the shared row-transition lifecycle (when a row converts is described on
 * `TransitioningKvRows`). Model projections and attention remain batched.
 * `fusedDecode` is resolved by whoever builds the layout. The reads are the
 * graph's call today: this layout's mask before the append, the deferred-V
 * fetch and the stock fused SDPA, then the value transform the fetch captured. */
export class DelayedTurboQuantKVCache extends FullTransitioningKvRows<BatchedTurboQuantKVCache>
  implements RotatedValueAttentionState, AttentionCache {
  #rotated: boolean[] = [];
  constructor(readonly kBits: number, readonly vBits: number, readonly start: number,
    readonly fusedDecode: boolean, row?: Cache) {
    super({ signature: `kv:delayed-turboquant:${kBits}:${vBits}:${start}`, conversionOffset: start,
      settle: rows => settleTurboQuantRows(rows, kBits, vBits, start, fusedDecode),
      // The conversion leaves storage that decodes on read.
      keepsDenseReads: () => true,
      converted: row => row instanceof TurboQuantKVCache,
      makeLayout: () => new BatchedTurboQuantKVCache(kBits, vBits, fusedDecode) }, row);
  }
  captureDonorRows(): import("../contracts/mlx/cache").KvDonorRows {
    return this.packed?.captureDonorRows() ?? captureFullKvDonorRows(this.rows, this.leftPad, this.offset);
  }
  captureDonorAttention(): import("../contracts/mlx/cache").KvDonorAttention {
    return decodedKvDonorAttention(this.captureDonorRows());
  }
  get rotatedValueAttention(): RotatedValueAttentionState { return this; }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead { return this.#read(k, v); }
  appendWindow(k: MlxArray, v: MlxArray): AttentionRead { return this.#read(k, v); }
  /** The graph's read today: the mask from this layout before the append (no
   * sliding window), the deferred-V fetch and its value transform. */
  #read(k: MlxArray, v: MlxArray): AttentionRead {
    const mask = this.makeMask(k.shape[2]!, null);
    let keys: MlxArray, values: MlxArray;
    try { [keys, values] = this.updateAndFetchDeferredV(k, v); } catch (error) { mask.arr?.dispose(); throw error; }
    const restore = this.captureValueTransform();
    return {
      attend(q, scale) {
        const rotated = ops.sdpa(q, keys, values, scale, mask.mode, mask.arr);
        try { return restore(rotated); } finally { rotated.dispose(); }
      },
      dispose() { keys.dispose(); values.dispose(); mask.arr?.dispose(); },
    };
  }

  #append(k: MlxArray, v: MlxArray, deferred: boolean): [MlxArray, MlxArray] {
    this.advance();
    if (this.packed) {
      this.#rotated = Array.from({ length: this.batchSize! }, () => true);
      return deferred ? this.packed.updateAndFetchDeferredV(k, v) : this.packed.updateAndFetch(k, v);
    }
    this.#rotated = this.rows.map(row => !!row.rotatedValueAttention);
    const result = appendFullKvRows(this.rows, this.leftPad, this.offset + k.shape[2]!, k, v, deferred);
    try { this.syncPositions(true); } catch (error) { result[0].dispose(); result[1].dispose(); throw error; }
    return result;
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.#append(k, v, false); }
  updateAndFetchDeferredV(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.#append(k, v, true); }
  captureValueTransform(): (output: MlxArray) => MlxArray {
    const rotated = [...this.#rotated];
    if (rotated.every(value => value)) return unrotateValues;
    if (rotated.every(value => !value)) return output => ops.contiguous(output);
    return output => {
      using restored = unrotateValues(output);
      using flags = ops.fromInt32(rotated.map(value => Number(value)), [rotated.length, 1, 1, 1]);
      using mask = flags.astype(Dtype.bool);
      return ops.where(mask, restored, output);
    };
  }
  makeEmptyBatch(): DelayedTurboQuantKVCache { return new DelayedTurboQuantKVCache(this.kBits, this.vBits, this.start, this.fusedDecode); }
}
