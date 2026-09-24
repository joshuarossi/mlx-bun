import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../contracts/mlx/cache";
import { withResource } from "../runtime/resources";
import { leaseCacheStates } from "../state/leases";

/** Append an already accepted span without intermediate vocabulary heads.
 * Chunking changes the graph shape, so callers must qualify its numerics for
 * their model. Verification uses its separate round operation because
 * recurrent rollback records one forward per round. Append precedes emission/cancellation
 * boundaries, preserving the cache-covered prefix on a consumer break.
 */
export async function appendFillHidden(
  forward: (ids: MlxArray, cache: Cache[]) => MlxArray | Promise<MlxArray>,
  cache: Cache[],
  ids: number[],
  chunkSize: (cache: readonly Cache[]) => number,
): Promise<MlxArray> {
  const input = ops.fromInt32(ids, [1, ids.length]);
  try { return await appendHiddenRows(forward, cache, input, chunkSize); }
  finally { input.dispose(); }
}

/** Append equal-length committed token rows [B,L]. The caller owns the input;
 * the returned hidden rows belong to the caller. Model policy receives B so
 * a larger cohort cannot silently cross its qualified projection geometry. */
export async function appendHiddenRows(
  forward: (ids: MlxArray, cache: Cache[]) => MlxArray | Promise<MlxArray>,
  cache: Cache[],
  input: MlxArray,
  chunkSize: (cache: readonly Cache[], rows: number) => number,
): Promise<MlxArray> {
  const [rows, length] = input.shape as [number, number];
  const hidden: MlxArray[] = [];
  try {
    for (let start = 0; start < length;) {
      const limit = chunkSize(cache, rows);
      if (!Number.isSafeInteger(limit) || limit < 1)
        throw new Error("Model append chunk limit must be a positive integer");
      const end = Math.min(length, start + limit);
      if (start === 0 && end === length) return await forward(input, cache);
      const part = input.slice([0, start], [rows, end]);
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
  }
}
