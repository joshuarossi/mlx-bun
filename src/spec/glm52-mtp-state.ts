import type { MlxArray } from "../mlx/array";
import type { MLACache } from "../model/glm52-cache";
import { cloneAttachments } from "../backends/mlx/checkpoint-state";
import { disposeResources } from "../engine/resources";
import type { DraftRowCheckpoint } from "./source";
import type { Glm52MtpRowState } from "./glm52-mtp-rows";

export function captureGlm52MtpState(state: Glm52MtpRowState): DraftRowCheckpoint {
  const held: MlxArray[] = [];
  try {
    if (state.cache.offset) {
      const cache = state.cache.fetch(); held.push(cache.latent, cache.rope);
    }
    held.push(state.hidden.slice([0, 0, 0], [...state.hidden.shape]));
    return { processedTokens: state.processedTokens, attachment: {
      schema: "glm52-native-mtp-v1", metadata: { processedTokens: state.processedTokens, draftOffset: state.cache.offset },
      tensors: held.splice(0),
    } };
  } finally { disposeResources(held); }
}

export function restoreGlm52MtpState(checkpoint: DraftRowCheckpoint, makeCache: () => MLACache): Glm52MtpRowState {
  const { attachment, processedTokens } = checkpoint;
  if (attachment.schema !== "glm52-native-mtp-v1" || attachment.metadata.processedTokens !== processedTokens)
    throw new Error("invalid native GLM MTP checkpoint alignment");
  const held = cloneAttachments([attachment])[0]!.tensors;
  let cache: MLACache | null = makeCache();
  try {
    const offset = attachment.metadata.draftOffset as number;
    if (offset) { cache.restoreCompressedState(held[0]!, held[1]!, null, offset); held.splice(0, 2); }
    const state = { cache, hidden: held.pop()!, processedTokens }; cache = null; return state;
  } finally { disposeResources([...held, ...(cache ? [cache] : [])]); }
}
