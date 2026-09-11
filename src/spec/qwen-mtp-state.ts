import type { MlxArray } from "../mlx/array";
import { KVCache } from "../model/gemma4-base";
import { cloneAttachments } from "../backends/mlx/checkpoint-state";
import { disposeResources } from "../engine/resources";
import type { MtpRowState } from "./qwen-mtp-rows";
import type { DraftRowCheckpoint } from "./source";

/** The existing Qwen companion attachment is also the state interchange
 * between prepared requests and a group. Storage-tier policy stays outside. */
export function restoreQwenMtpState(checkpoint: DraftRowCheckpoint): MtpRowState {
  const { processedTokens: tokens, attachment } = checkpoint;
  if (attachment.schema !== "qwen-mtp-v1" || attachment.metadata.draftOffset !== tokens - 1)
    throw new Error("invalid paired Qwen MTP checkpoint alignment");
  const held = cloneAttachments([attachment])[0]!.tensors;
  let cache: KVCache | null = new KVCache();
  try {
    if (tokens > 1) { cache.restoreState(held[0]!, held[1]!, tokens - 1); held.splice(0, 2); }
    const state = { cache, hidden: held.pop()! }; cache = null; return state;
  } finally { disposeResources([...held, ...(cache ? [cache] : [])]); }
}

export function captureQwenMtpState(state: MtpRowState): DraftRowCheckpoint {
  const held: MlxArray[] = [];
  try {
    if (state.cache.offset > 0) held.push(...state.cache.temporalView());
    held.push(state.hidden.slice([0, 0, 0], [...state.hidden.shape]));
    return { processedTokens: state.cache.offset + 1,
      attachment: { schema: "qwen-mtp-v1", metadata: { draftOffset: state.cache.offset }, tensors: held.splice(0) } };
  } finally { disposeResources(held); }
}
