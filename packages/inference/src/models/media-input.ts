import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../contracts/mlx/cache";
import type { MlxPromptInput } from "../contracts/mlx/media";

/** Preserve the ordinary generator's projection geometry for a prepared
 * embedding sequence: process the whole prompt, then project only its tip. */
export function bindEmbeddingsInput(
  forward: (ids: MlxArray, caches: Cache[], start: number) => MlxArray,
): MlxPromptInput {
  return { forward(ids, caches, start = 0) {
    using hidden = forward(ids, caches, start);
    const [batch, length, width] = hidden.shape;
    return hidden.slice([0, length! - 1, 0], [batch!, length!, width!]);
  } };
}
