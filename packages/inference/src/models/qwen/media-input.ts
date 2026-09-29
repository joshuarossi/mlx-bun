import type { ModelConfig } from "../../artifacts/config";
import type { QuantizedEmbedding } from "../../layers/quantized-embedding";
import type { QuantizedLinear } from "../../layers/quantized-linear";
import { mropePositionIds } from "../../layers/qwen-mrope";
import { type MropeRequestState } from "../../contracts/mlx/positions";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../contracts/mlx/cache";
import type { MediaEncoders, MlxDecodeState, MlxPromptInput, VisionEncoder } from "../../contracts/mlx/media";
import type { TargetView } from "../../contracts/mlx/draft-target";
import { existsSync } from "node:fs";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { bindEmbeddingsInput } from "../media-input";

/** What the Qwen graph's media and draft ports read from it. */
export interface QwenMediaGraph {
  readonly config: ModelConfig;
  readonly embed: QuantizedEmbedding;
  readonly lmHead: QuantizedLinear | null;
  /** The full-attention layer whose cache supplies logical positions. */
  readonly faIdx: number;
  forwardHiddenAtPositions(ids: MlxArray, caches: Cache[], positions: MlxArray): MlxArray;
  forwardEmbeddingsAtPositions(embeddings: MlxArray, caches: Cache[], positions: MlxArray): MlxArray;
  logitsFromHidden(hidden: MlxArray): MlxArray;
}

class QwenMediaDecodeState implements MlxDecodeState {
  readonly key = "qwen-interleaved-mrope";
  constructor(readonly model: QwenMediaGraph, readonly delta: number) {}

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
export function bindQwenMediaInput(model: QwenMediaGraph, embeddings: MlxArray,
  state: MropeRequestState): MlxPromptInput {
  const input = bindEmbeddingsInput((ids, caches, start) => {
    using positions = mropePositionIds(state, start, ids.shape[1]!);
    return start > 0 ? model.forwardHiddenAtPositions(ids, caches, positions)
      : model.forwardEmbeddingsAtPositions(embeddings, caches, positions);
  });
  return { ...input, decodeState: new QwenMediaDecodeState(model, state.delta) };
}

/** Tower weights arrive either as the OptiQ-convention sidecar or in the main
 * shards (mlx-vlm convention); the tower loader handles both. The encoder is a
 * Qwen3VLVisionTower riding the shared lazy slot; the Qwen media route is its
 * only consumer and reads it through the structural contract it defines. */
export async function qwenMediaEncoders(model: QwenMediaGraph, modelDir: string): Promise<MediaEncoders> {
  const hasSidecar = existsSync(`${modelDir}/optiq/optiq_vision.safetensors`);
  if (!hasSidecar && model.config.raw.vision_config === undefined) return { vision: null, audio: null };
  const { Qwen3VLVisionTower } = await import("../vision/qwen3vl");
  return { vision: () => Qwen3VLVisionTower.load(modelDir) as unknown as VisionEncoder, audio: null };
}

/** Ports draft sources read from this graph: its embedding, head, and the MTP
 * geometry a checkpoint-native draft head needs. */
export function qwenDraftTarget(model: QwenMediaGraph): TargetView {
  return Object.freeze({ identity: model, recurrentMtp: Object.freeze({
    hiddenSize: model.config.text.hiddenSize, layerCount: model.config.text.numHiddenLayers,
    embed: model.embed.encode.bind(model.embed), logitsFromHidden: model.logitsFromHidden.bind(model),
    vocabularyHead: model.lmHead ? Object.freeze({ w: model.lmHead.w, scales: model.lmHead.scales,
      biases: model.lmHead.biases, spec: model.lmHead.spec, vocabSize: model.config.text.vocabSize }) : undefined,
  }) });
}
