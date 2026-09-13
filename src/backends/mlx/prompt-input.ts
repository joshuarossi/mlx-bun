import type { MlxArray } from "../../mlx/array";
import type { Cache } from "../../model/gemma4-base";

/** Prepared native input with an indivisible prefill. The preparation owner
 * retains its tensors; the model binding returns an owned final hidden row.
 * Decode, sampling and row retirement use the ordinary execution group. */
export interface MlxPromptInput {
  forward(ids: MlxArray, caches: Cache[], start?: number): MlxArray;
  readonly decodeState?: MlxDecodeState;
}

/** Additional model-owned forward state. Equal keys declare compatible row
 * state; the backend supplies the current row order after joins/retirement. */
export interface MlxDecodeState {
  readonly key: string;
  forward(ids: MlxArray, caches: Cache[], rows: readonly MlxDecodeState[]): MlxArray;
}

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
