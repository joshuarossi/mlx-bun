import type { Qwen35Model } from "../models/qwen/qwen3_5";
import { mropePositionIds, type MropeRequestState } from "../layers/qwen-mrope";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../contracts/cache";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { bindEmbeddingsInput, type MlxDecodeState, type MlxPromptInput } from "./prompt-input";

class QwenMediaDecodeState implements MlxDecodeState {
  readonly key = "qwen-interleaved-mrope";
  constructor(readonly model: Qwen35Model, readonly delta: number) {}

  forward(ids: MlxArray, caches: Cache[], rows: readonly MlxDecodeState[]): MlxArray {
    const B = rows.length, L = ids.shape[1]!;
    const cache = caches[this.model.faIdx]!;
    // The cache supplies logical positions, including left padding, on device.
    // No offset readback or request-global position mutation is needed.
    const offsets = (cache as Cache & { ropeOffsetArr?: MlxArray }).ropeOffsetArr;
    using deltas = ops.fromInt32(rows.map(row => (row as QwenMediaDecodeState).delta), [B]);
    using scalar = offsets ? null : ops.fromInt32([cache.offset], []);
    using starts = ops.add(offsets ?? scalar!, deltas);
    using startRows = ops.reshape(starts, [B, 1]);
    using indices = ops.arange(0, L, 1, Dtype.int32);
    using positions = ops.add(startRows, indices);
    using axis = ops.reshape(positions, [1, B, L]);
    using grid = ops.concatAxis([axis, axis, axis], 0);
    return this.model.forwardHiddenAtPositions(ids, caches, grid);
  }
}

/** The prompt owns its grid; only its continuation delta survives into decode. */
export function bindQwenMediaInput(model: Qwen35Model, embeddings: MlxArray,
  state: MropeRequestState): MlxPromptInput {
  const input = bindEmbeddingsInput((ids, caches, start) => {
    using positions = mropePositionIds(state, start, ids.shape[1]!);
    return start > 0 ? model.forwardHiddenAtPositions(ids, caches, positions)
      : model.forwardEmbeddingsAtPositions(embeddings, caches, positions);
  });
  return { ...input, decodeState: new QwenMediaDecodeState(model, state.delta) };
}
