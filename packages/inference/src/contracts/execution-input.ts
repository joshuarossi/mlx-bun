import type { MlxArray } from '@mlx-bun/mlx/array';
import type { GenerateOptions, GenerateStats } from '../generation/types';
import type { ResolvedExecution } from './execution';
import type { PromptResponseTrace } from '../execution/trace';
import type { OnToken } from './token-delivery';
export type { OnToken } from './token-delivery';


/** Prepared embeddings for vision/audio prompts. Qualified models consume
 * this through shared preparation and decode; other bindings retain serial
 * execution. Token-only prefix caching remains disabled for media. */
export type Vision = {
  /** Producer identity includes all media and preceding rendered tokens. */
  prefixIdentity?: string;
  embeddings: MlxArray;
  /** bool [L] image-token mask for the bidirectional attention overlay.
   *  Absent when the prompt carries ANY audio — audio(-containing) prompts
   *  run fully causal (docs/design/generic-model-support.md §3.3 Q1). */
  imageMask?: MlxArray;
  /** bool [L] union multimodal soft-token mask (image | audio) for
   *  per-layer-input id zeroing. Absent on the legacy vision-only shape,
   *  where zeroing falls back to imageMask. */
  multimodalMask?: MlxArray;
  /** Qwen3.5/3.8 vision: the request's mRoPE positions + decode delta,
   *  owned by shared forward input, or scoped to the explicit serial run. */
  mrope?: import("../layers/qwen-mrope").MropeRequestState;
};

/** The serial lane — exactly today's runGeneration (prompt-cache reuse + the
 *  generate() pipeline). The gateway calls it under the mutex. */
export type SerialRun = (
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  vision?: Vision,
  trace?: PromptResponseTrace,
  execution?: ResolvedExecution,
) => Promise<GenerateStats>;
