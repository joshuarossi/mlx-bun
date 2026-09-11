import type { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import type { Cache, KvDonorAttention } from "../../model/gemma4-base";
import { captureKvDonorAttention } from "../../model/kv-attention-view";
import type { AssistantAttention } from "../../spec/drafter";
import { disposeResources } from "../../engine/resources";

/** Bind captured cache validity to Q-only attention. Encoded layouts can
 * supply this same numerical port without changing the draft graph. */
export function readAssistantDonors(sliding: Cache, full: Cache) {
  const views: KvDonorAttention[] = [], masks: MlxArray[] = [];
  const dispose = () => disposeResources([...masks, ...views]);
  try {
    for (const cache of [sliding, full]) views.push(captureKvDonorAttention(cache));
    const bind = (view: KvDonorAttention): AssistantAttention => {
      // All draft steps borrow the same target snapshot. Build each validity
      // mask once, then reuse it across matching layers and the entire chain.
      const byWindow = new Map<number | null, MlxArray | null>();
      return { attend(query, scale, window) {
        if (!byWindow.has(window)) {
          const width = view.width, B = view.offsets.length;
          const starts = view.starts.map((start, row) => Math.max(start,
            window === null ? start : view.ends[row]! - window));
          let mask: MlxArray | null = null;
          if (starts.some(start => start !== 0) || view.ends.some(end => end !== width)) {
            using columns = ops.arange(0, width, 1, Dtype.int32);
            using lower = ops.fromInt32(starts, [B, 1, 1, 1]);
            using upper = ops.fromInt32([...view.ends], [B, 1, 1, 1]);
            using before = ops.less(columns, lower);
            using after = ops.greaterEqual(columns, upper);
            using invalid = ops.logicalOr(before, after);
            using floats = invalid.astype(view.dtype);
            mask = ops.mulScalar(floats, -1e9);
            masks.push(mask);
          }
          byWindow.set(window, mask);
        }
        const mask = byWindow.get(window)!;
        return view.attend(query, scale, { mode: mask ? "array" : "", arr: mask });
      } };
    };
    return { positions: views[0]!.offsets.map(offset => offset - 1),
      sliding: bind(views[0]!), full: bind(views[1]!), dispose };
  } catch (error) { dispose(); throw error; }
}
