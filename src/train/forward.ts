// Training forward pass: full-sequence logits with no KV reuse.
//
// Unlike generate(), training runs the entire sequence in one pass over a
// fresh cache (B=1). The LoRA residual fires through the model's quantized
// linears when loraState.active is set (attachForTraining). The cache and
// hidden activations are disposed here; only the returned logits survive.

import { MlxArray } from "../mlx/array";
import type { RuntimeModel } from "../model/factory";

/** Run a full-sequence forward for training.
 *  @param ids int32 array [1, L].
 *  @returns logits [1, L, V] (caller owns; dispose when done). */
export function trainForward(model: RuntimeModel, ids: MlxArray): MlxArray {
  const cache = model.makeCache();
  try {
    const h = model.forwardHidden(ids, cache);
    const logits = model.logitsFromHidden(h);
    h.dispose();
    return logits;
  } finally {
    for (const c of cache) c.dispose();
  }
}
