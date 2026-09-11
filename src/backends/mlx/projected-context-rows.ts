import type { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { BatchedKVCache } from "../../model/batched-kv";
import type { Cache } from "../../model/gemma4-base";
import { MlxStateRows } from "./state-rows";
import { disposeResources } from "../../engine/resources";

export interface ProjectedContext { k: MlxArray; v: MlxArray; }
export interface ContextProjection {
  project(hidden: MlxArray, positions: number | MlxArray): ProjectedContext[];
}

/** Incremental projected context reuses ordinary full-attention row storage.
 * The projection graph owns numerics; this object owns positions and validity. */
export class MlxProjectedContextRows {
  readonly state: MlxStateRows<BatchedKVCache>;
  constructor(layers: number, readonly graph: ContextProjection) {
    this.state = new MlxStateRows(Array.from({ length: layers }, () => new BatchedKVCache()));
  }
  get positions(): readonly number[] { return this.state.caches[0]!.rowOffsets; }
  prepareAppend(rows: readonly (readonly Cache[])[]) { return this.state.prepareAppendMany(rows); }
  append(hidden: MlxArray, lengths: readonly number[]): void {
    const width = Math.max(...lengths), B = lengths.length, positions = this.positions;
    using context = hidden.slice([0, 0, 0], [B, width, hidden.shape[2]!]);
    using offsets = positions.every(position => position === positions[0]) ? null : ops.fromInt32([...positions], [B]);
    const projected = this.graph.project(context, offsets ?? positions[0]!);
    try {
      for (const [layer, cache] of this.state.caches.entries()) {
        cache.specRoundBegin();
        for (const array of cache.updateAndFetch(projected[layer]!.k, projected[layer]!.v)) array.dispose();
        if (lengths.every(length => length === width)) cache.specRoundCommit();
        else cache.specRoundRollback(lengths);
      }
    } finally { disposeResources(projected.flatMap(pair => [pair.k, pair.v])); }
  }
  materialize(): void { ops.evalAll(this.state.caches.flatMap(cache => cache.state())); }
  readAttention() {
    const views: import("../../model/gemma4-base").KvDonorRows[] = [];
    try { for (const cache of this.state.caches) views.push(cache.captureDonorRows()); }
    catch (error) { disposeResources(views.flatMap(view => [view.keys, view.values])); throw error; }
    const masks = new Map<string, MlxArray | null>();
    return {
      attend(layer: number, query: MlxArray, blockKeys: MlxArray, blockValues: MlxArray, scale = 1): MlxArray {
        const view = views[layer]!, width = view.keys.shape[2]!, block = blockKeys.shape[2]!, B = view.offsets.length;
        // Membership and coverage advance together in every context layer.
        const key = `${width}:${block}:${view.keys.dtype}`;
        if (!masks.has(key)) {
          let mask: MlxArray | null = null;
          if (view.starts.some(start => start !== 0) || view.ends.some(end => end !== width)) {
            using columns = ops.arange(0, width, 1, Dtype.int32);
            using lower = ops.fromInt32([...view.starts], [B, 1, 1, 1]);
            using upper = ops.fromInt32([...view.ends], [B, 1, 1, 1]);
            using before = ops.less(columns, lower), after = ops.greaterEqual(columns, upper);
            using invalid = ops.logicalOr(before, after);
            using floats = invalid.astype(view.keys.dtype);
            using prefix = ops.mulScalar(floats, -1e9);
            using suffix = ops.zeros([B, 1, 1, block], view.keys.dtype);
            mask = ops.concatAxis([prefix, suffix], 3);
          }
          masks.set(key, mask);
        }
        using keys = ops.concatAxis([view.keys, blockKeys], 2);
        using values = ops.concatAxis([view.values, blockValues], 2);
        const mask = masks.get(key)!;
        return ops.sdpa(query, keys, values, scale, mask ? "array" : "", mask);
      },
      dispose() { disposeResources([...views.flatMap(view => [view.keys, view.values]), ...[...masks.values()].filter(value => value !== null)]); },
    };
  }
  dispose(): void { this.state.dispose(); }
}
