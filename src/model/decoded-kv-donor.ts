import * as ops from "../mlx/ops";
import type { KvDonorAttention, KvDonorRows } from "./gemma4-base";

/** Takes ownership of decoded donor planes. Assistant attention uses decoded
 * values, preserving its SDPA arithmetic rather than moving inverse rotation. */
export function decodedKvDonorAttention(view: KvDonorRows): KvDonorAttention {
  const { keys, values, offsets, starts, ends } = view;
  return { width: keys.shape[2]!, dtype: keys.dtype, offsets, starts, ends,
    attend: (q, scale, mask) => ops.sdpa(q, keys, values, scale, mask.mode, mask.arr),
    dispose() { keys.dispose(); values.dispose(); },
  };
}
