import { runtimeValue } from "../runtime-config";
import { captureFullKvDonorRows } from "../backends/mlx/full-kv-row-donor";
import { decodedKvDonorAttention } from "./decoded-kv-donor";
import { appendFullKvRows } from "../backends/mlx/full-kv-row-append";
import type { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { unrotateValues } from "../mlx/turboquant-ops";
import { type Cache, type RotatedValueAttentionState, TurboQuantKVCache } from "./gemma4-base";
import { BatchedTurboQuantKVCache } from "./batched-turboquant-kv";
import { FullTransitioningKvRows } from "../backends/mlx/full-transitioning-kv-rows";

/** TurboQuant tensor access and value-domain handling over the shared
 * row-transition lifecycle. Model projections and attention remain batched. */
export class DelayedTurboQuantKVCache extends FullTransitioningKvRows<BatchedTurboQuantKVCache> implements RotatedValueAttentionState {
  #rotated: boolean[] = [];
  constructor(readonly kBits: number, readonly vBits: number, readonly start: number,
    readonly maintain: (rows: Cache[]) => void, row?: Cache,
    readonly fusedDecode = runtimeValue("MLX_BUN_TURBOQUANT_FUSED_DECODE") === "1") {
    super({ signature: `kv:delayed-turboquant:${kBits}:${vBits}:${start}`, maintain,
      converted: row => row instanceof TurboQuantKVCache,
      makeLayout: () => new BatchedTurboQuantKVCache(kBits, vBits, fusedDecode) }, row);
  }
  captureDonorRows(): import("./gemma4-base").KvDonorRows {
    return this.packed?.captureDonorRows() ?? captureFullKvDonorRows(this.rows, this.leftPad, this.offset);
  }
  captureDonorAttention(): import("./gemma4-base").KvDonorAttention {
    return decodedKvDonorAttention(this.captureDonorRows());
  }
  get rotatedValueAttention(): RotatedValueAttentionState { return this; }
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
  makeEmptyBatch(): DelayedTurboQuantKVCache { return new DelayedTurboQuantKVCache(this.kBits, this.vBits, this.start, this.maintain, undefined, this.fusedDecode); }
}
