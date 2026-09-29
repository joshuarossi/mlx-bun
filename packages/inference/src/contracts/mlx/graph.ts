import type { GraphCapabilities } from "../portable/graph";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "./cache";
import type { TargetView } from "./draft-target";
import type { MediaEncoders, MediaSidecarProbes, MlxPromptInput, PixelInput, TextEmbeddingModel, Vision } from "./media";

/** The operations behind a graph's declared capabilities. A graph implements
 * the ones its `graphCapabilities` promise; composition checks the pairing once
 * when it binds (`declaredGraph`), so execution never probes for them. */
export interface MlxDeclaredGraph {
  readonly graphCapabilities: GraphCapabilities;
  /** Unscaled token embeddings, for media prompts that splice embeddings. */
  readonly embed?: TextEmbeddingModel["embed"];
  /** media `embeddings`/`embeddings+positions`: bind one request's prepared
   * embeddings into an input whose prefill is indivisible. */
  bindMediaInput?(input: Vision): MlxPromptInput;
  /** embeddings: the pooled, L2-normalized sentence vector of one sequence,
   * ids [1, L] to [1, hidden]. The caller appends the pooling token the
   * profile declares and owns the result. */
  embedPooled?(ids: MlxArray): MlxArray;
  /** media: the lazy encoders this graph loads from the checkpoint at `modelDir`. */
  mediaEncoders?(modelDir: string, probes: MediaSidecarProbes): Promise<MediaEncoders>;
  /** media `pixels`: the pixel input a denoising method consumes; null when the checkpoint has none. */
  pixelInput?(): PixelInput | null;
  /** Ports over this graph's live caches that draft sources may consume. */
  draftTarget?(caches: Cache[]): TargetView;
  /** Snapshot of the streamed expert residency, for diagnostics; null when the graph streams none. */
  expertResidency?(): Record<string, unknown> | null;
}
