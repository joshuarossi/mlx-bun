import type { GraphCapabilities } from "../portable/graph";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "./cache";
import type { TargetView } from "./draft-target";
import type { NativeMtpHead } from "./drafter";
import type { TrainableGraph } from "./trainable";
import type { MediaEncoders, MediaSidecarProbes, MlxPromptInput, PixelInput, TextEmbeddingModel, Vision } from "./media";

/** Weight and expert-residency facts the wired-limit scope reads. */
export interface MlxModelMemory {
  readonly weightsBytes: number;
  readonly expertRuntime?: {
    readonly plan: { readonly plannedBytes: number };
    flushUsage?: () => void;
    finishUsage?: () => Promise<void>;
  } | null;
}

/** Model-owned execution for committed tokens. Recheck the chunk limit after
 * each forward: native arithmetic can change at a cache-length boundary. */
export interface MlxTokenAppend {
  /** Affine formats whose committed append retains one-token arithmetic. */
  readonly affineKvBits?: readonly number[];
  readonly turboQuantFormats?: readonly { readonly kBits: number; readonly vBits: number }[];
  /** Maximum positions per row at this cohort size; omitted rows means B=1. */
  maxChunkSize(state: readonly Cache[], rows?: number): number;
  forwardHidden(ids: MlxArray, state: Cache[]): MlxArray | Promise<MlxArray>;
}

/** A graph's compiled single-token decode step: the whole forward replayed from
 * one recorded graph instead of rebuilt per token. The graph decides which
 * state layouts it can express; the caller falls back to the ordinary forward
 * for the rest. */
export interface MlxCompiledDecodeStep {
  /** Cheap and pure: whether `state`, in its current layout, can take a step. */
  accepts(state: readonly Cache[]): boolean;
  /** Consume one pending uint32 [1] token (unevaluated is fine) and advance
   * every cache one position. The returned logits [1,1,V] belong to the
   * caller; `evalWith` holds cache updates that must ride the same async
   * evaluation. A step that throws leaves `state` exactly as it was, so the
   * caller can run the same token through the ordinary graph. */
  step(token: MlxArray, state: Cache[]): { logits: MlxArray; evalWith: MlxArray[] };
}

/** method `denoising`: what the canvas denoiser drives over a graph's weights, with the prefill state
 * an array of caches. A graph that declares the method implements these; binding refuses one that does not. */
export interface MlxDenoisingOperations {
  readonly config: { readonly text: { readonly vocabSize: number } };
  readonly canvasLength: number;
  readonly embedScale: number;
  prefill(promptIds: number[]): Cache[];
  /** Image-conditioned prefill from channel-first pixels. */
  prefillVision?(promptIds: number[], pixels: MlxArray): Cache[];
  extendPrefill(tokens: MlxArray, state: Cache[]): void;
  decoderLogits(canvas: MlxArray, state: Cache[], feedback: MlxArray | null): MlxArray;
  dequantEmbedWeight(): MlxArray;
  softEmbeddings(logits: MlxArray, weight: MlxArray): MlxArray;
}

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
  /** `nativeDraft`: the checkpoint's own multi-token-prediction head, refused when its tier is not loaded. */
  nativeDraftHead?(): NativeMtpHead;

  /** What the trainer consumes: the head, segmented backward, prefix sharing,
   * gradient checkpointing, flash-attention constraint and denoising objective
   * this graph implements. Undeclared parts make the trainer refuse. */
  readonly trainable?: TrainableGraph;
  /** `compiledDecode`: the graph's compiled decode step, created on first use
   * and owned by the graph until `releaseCompiledDecode`. */
  compiledDecodeStep?(): MlxCompiledDecodeStep;
  /** Retire the compiled step before the graph unloads: its recorded graph
   * borrows the graph's weights and constants. Safe to call when none exists. */
  releaseCompiledDecode?(): void;
  /** Snapshot of the streamed expert residency, for diagnostics; null when the graph streams none. */
  expertResidency?(): Record<string, unknown> | null;
}
