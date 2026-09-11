import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { Cache } from "../../model/gemma4-base";
import { fullRowPadding } from "../../model/full-prefill-row";
import { disposeResources } from "../../engine/resources";

/** Assemble full-attention tensors at the model's B while storage retains
 * per-row formats and positions. Returned arrays own their captured state. */
export function appendFullKvRows(rows: readonly Cache[], leftPad: readonly number[], width: number,
  k: MlxArray, v: MlxArray, deferredValues = false): [MlxArray, MlxArray] {
  const parts: [MlxArray, MlxArray][] = [], padded: MlxArray[] = [];
  try {
    for (const [index, row] of rows.entries()) {
      using kr = k.slice([index, 0, 0, 0], [index + 1, k.shape[1]!, k.shape[2]!, k.shape[3]!]);
      using vr = v.slice([index, 0, 0, 0], [index + 1, v.shape[1]!, v.shape[2]!, v.shape[3]!]);
      parts.push(deferredValues && row.rotatedValueAttention
        ? row.rotatedValueAttention.updateAndFetchDeferredV(kr, vr) : row.updateAndFetch(kr, vr));
    }
    const combine = (field: 0 | 1) => {
      const views = parts.map((part, row) => {
        const a = part[field], before = leftPad[row]! - fullRowPadding(rows[row]!), after = width - before - a.shape[2]!;
        if (!before && !after) return a;
        using prefix = ops.zeros([1, a.shape[1]!, before, a.shape[3]!], a.dtype);
        using suffix = ops.zeros([1, a.shape[1]!, after, a.shape[3]!], a.dtype);
        const result = ops.concatAxis([prefix, a, suffix], 2); padded.push(result); return result;
      });
      return views.length === 1 ? ops.contiguous(views[0]!) : ops.concatAxis(views, 0);
    };
    const keys = combine(0);
    try { return [keys, combine(1)]; } catch (error) { keys.dispose(); throw error; }
  } finally { disposeResources([...parts.flat(), ...padded]); }
}
