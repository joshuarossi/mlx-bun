import type { MlxArray } from "../../mlx/array";
import type { Cache } from "../../model/gemma4-base";

/** Prepared native input with an indivisible prefill. The preparation owner
 * retains its tensors; the model binding returns an owned final hidden row.
 * Decode, sampling and row retirement use the ordinary execution group. */
export interface MlxPromptInput {
  forward(ids: MlxArray, caches: Cache[]): MlxArray;
}

/** Preserve the ordinary generator's projection geometry for a prepared
 * embedding sequence: process the whole prompt, then project only its tip. */
export function bindEmbeddingsInput(
  forward: (ids: MlxArray, caches: Cache[]) => MlxArray,
): MlxPromptInput {
  return { forward(ids, caches) {
    using hidden = forward(ids, caches);
    const [batch, length, width] = hidden.shape;
    return hidden.slice([0, length! - 1, 0], [batch!, length!, width!]);
  } };
}
