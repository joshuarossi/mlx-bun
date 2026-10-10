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

/** A verify forward's hidden-layer capture. The graph calls it once per
 * decoder layer, in layer order, with that layer's residual output, then once
 * with index `layerCount` (the decoder's layer count) and the post-final-norm
 * output, all before the forward returns. `hidden` [sequences, tokens per
 * sequence, hidden-width] is borrowed and possibly unevaluated: it is valid
 * only during the call. The callback copies the layers it keeps (for example
 * with `ops.contiguous`) and owns and disposes those copies. */
export type MlxLayerCapture = (layer: number, hidden: MlxArray) => void;

/** A prefill or decode forward. `ids` is integer token ids [sequences, tokens
 * per sequence]. The caller owns `ids` and may dispose them once the call
 * returns (or its promise settles); the result does not depend on the caller's
 * handle. The graph borrows `state` and appends every position of `ids` to
 * each layer's cache (keys and values, or recurrent state), advancing each
 * sequence by its token count; it never rolls back. The returned post-final-norm
 * hidden [sequences, tokens per sequence, hidden-width] is owned by the caller,
 * who disposes it, and may be unevaluated, as may the appended cache state.
 * A forward that throws may leave a partial append, which the caller discards
 * or rolls back. */
export type MlxPhaseForward = (ids: MlxArray, state: Cache[]) => MlxArray | Promise<MlxArray>;

/** A speculative verify forward: `MlxPhaseForward`'s ownership and append, and
 * `capture` receives the hidden layers the drafter taps. `capture` is null when
 * the composition's drafter reads none; only a graph that declares
 * `hiddenLayerTaps` receives a non-null capture. */
export type MlxVerifyForward = (ids: MlxArray, state: Cache[], capture: MlxLayerCapture | null) =>
  MlxArray | Promise<MlxArray>;

/** One operation per width class, where a forward's rows are its sequences
 * times its tokens per sequence. The caller picks the entry by the rows it is
 * loading and hands an entry only rows of its class; an entry never inspects
 * its input to learn its class. A graph with one forward supplies the same
 * operation in every entry; a specialized graph supplies the operation it built
 * for each class. */
export interface MlxWidthTable<Operation> {
  /** Exactly one row. */
  readonly one: Operation;
  /** Two to four rows. */
  readonly twoToFour: Operation;
  /** Five to eight rows. */
  readonly fiveToEight: Operation;
  /** Nine or more rows. */
  readonly wider: Operation;
}

/** The autoregressive phases, each named by the caller. The graph runs the
 * operation it was asked for and never derives the phase or the width class
 * from its input. Each operation follows `MlxPhaseForward`'s ownership. */
export interface MlxTokenPhases {
  /** One whole chunk of a prompt: tokens per sequence equal the composition's
   * prefill chunk size; rows are sequences times that size. Token ids only: a
   * prompt with prepared media enters through the `MlxPromptInput` that
   * `bindMediaInput` returns (for `embeddings+positions`, the graph's
   * `forwardEmbeddingsAtPositions`). */
  prefillChunk(ids: MlxArray, state: Cache[]): MlxArray | Promise<MlxArray>;
  /** The positions left at the end of a prompt after its whole chunks, fewer
   * than the chunk size per sequence; rows are sequences times those tokens.
   * The same semantics as `prefillChunk`, named apart because a composition
   * may run it on different hardware. */
  prefillTail(ids: MlxArray, state: Cache[]): MlxArray | Promise<MlxArray>;
  /** One new token per sequence: `ids` [sequences, 1], so rows are sequences. */
  readonly decode: MlxWidthTable<MlxPhaseForward>;
  /** A speculative window: each sequence's last accepted token and its drafted
   * tokens, right-padded by the caller to the round's depth, `ids`
   * [sequences, depth + 1], so rows are sequences times (depth + 1). The graph
   * appends all depth + 1 positions; dropping the rejected suffix is the
   * caller's speculative transaction, begun before this call. */
  readonly verify: MlxWidthTable<MlxVerifyForward>;
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
  /** Measured cost of a verify forward by its row count, relative to one
   *  single-row decode step (rows 1 = 1). Declared only by a graph measured on
   *  the hardware it serves; speculative depth scheduling reads it. */
  readonly verifyRoundCosts?: ReadonlyMap<number, number>;
}
