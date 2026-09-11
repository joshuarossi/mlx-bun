import { captureKvDonorAttention, combineKvDonorAttention } from "../../model/kv-attention-view";
import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { Cache, KvDonorRows } from "../../model/gemma4-base";
import { fullRowInner, fullRowPadding } from "../../model/full-prefill-row";
import { disposeResources } from "../../engine/resources";

/** Read full-attention rows in their existing physical columns. Valid token
 * coverage excludes prefill padding; no append, conversion or compaction. */
export function captureFullKvDonorRows(rows: readonly Cache[], leftPad: readonly number[], width: number): KvDonorRows {
  const parts: KvDonorRows[] = [], padded: MlxArray[] = [];
  try {
    for (const row of rows) parts.push(fullRowInner(row).captureDonorRows!());
    const combine = (field: "keys" | "values") => {
      const views = parts.map((part, index) => {
        const a = part[field], before = leftPad[index]! - fullRowPadding(rows[index]!), after = width - before - a.shape[2]!;
        if (!before && !after) return a;
        using prefix = ops.zeros([1, a.shape[1]!, before, a.shape[3]!], a.dtype);
        using suffix = ops.zeros([1, a.shape[1]!, after, a.shape[3]!], a.dtype);
        const result = ops.concatAxis([prefix, a, suffix], 2); padded.push(result); return result;
      });
      return views.length === 1 ? ops.contiguous(views[0]!) : ops.concatAxis(views, 0);
    };
    const offsets = rows.map(row => row.offset), starts = [...leftPad];
    const keys = combine("keys");
    try { return { keys, values: combine("values"), offsets, starts, ends: offsets.map((offset, row) => starts[row]! + offset) }; }
    catch (error) { keys.dispose(); throw error; }
  } finally { disposeResources([...parts.flatMap(part => [part.keys, part.values]), ...padded]); }
}


/** Capture full rows in global columns while each encoded view retains its
 * own physical width and numerical attention operation. */
export function captureFullKvDonorAttention(rows: readonly Cache[], leftPad: readonly number[], width: number): import("../../model/gemma4-base").KvDonorAttention {
  const captured: import("../../model/gemma4-base").KvDonorAttention[] = [];
  try {
    for (const [index, row] of rows.entries()) {
      const view = captureKvDonorAttention(fullRowInner(row));
      const pad = leftPad[index]! - fullRowPadding(row);
      captured.push({ width, dtype: view.dtype, offsets: [row.offset],
        starts: [leftPad[index]!], ends: [leftPad[index]! + row.offset],
        attend(q, scale, mask) {
          if (!mask.arr) return view.attend(q, scale, mask);
          const from = mask.arr.shape.map(() => 0), to = [...mask.arr.shape];
          from[from.length - 1] = pad; to[to.length - 1] = pad + view.width;
          using arr = mask.arr.slice(from, to);
          return view.attend(q, scale, { mode: mask.mode, arr });
        },
        dispose: () => view.dispose(),
      });
    }
    return combineKvDonorAttention(captured);
  } catch (error) { disposeResources(captured); throw error; }
}
