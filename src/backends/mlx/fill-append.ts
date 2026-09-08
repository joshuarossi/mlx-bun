import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { Cache } from "../../model/gemma4";
import { withResource } from "../../engine/resources";
import { leaseCacheStates } from "./state-views";

/** Append an already accepted span without intermediate vocabulary heads.
 * Chunking changes the graph shape, so callers must qualify its numerics for
 * their model. A verify round must use chunkSize=0: recurrent rollback records
 * one forward per round. The complete append precedes emission/cancellation
 * boundaries, preserving the cache-covered prefix on a consumer break.
 */
export async function appendFillHidden(
  forward: (ids: MlxArray, cache: Cache[]) => MlxArray | Promise<MlxArray>,
  cache: Cache[],
  ids: number[],
  chunkSize: (cache: readonly Cache[]) => number,
): Promise<MlxArray> {
  const input = ops.fromInt32(ids, [1, ids.length]);
  const hidden: MlxArray[] = [];
  try {
    for (let start = 0; start < ids.length;) {
      const limit = chunkSize(cache);
      if (!Number.isSafeInteger(limit) || limit < 1)
        throw new Error("Model append chunk limit must be a positive integer");
      const end = Math.min(ids.length, start + limit);
      if (start === 0 && end === ids.length) return await forward(input, cache);
      const part = input.slice([0, start], [1, end]);
      try {
        const h = await forward(part, cache);
        hidden.push(h);
        // Bound transient graphs while retaining all positions for an optional
        // diagnostic trace. Normal generation projects only the last position.
        withResource(leaseCacheStates(cache), (state) => ops.evalAll([h, ...state]));
      } finally {
        part.dispose();
      }
      start = end;
    }
    return ops.concatAxis(hidden, 1);
  } finally {
    for (const h of hidden) h.dispose();
    input.dispose();
  }
}
