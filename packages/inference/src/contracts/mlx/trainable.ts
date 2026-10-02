import type { MlxArray } from "@mlx-bun/mlx/array";
import type * as ops from "@mlx-bun/mlx/ops";
import type { SharedKv } from "./cache";

/** The quantized LM head and final-logit softcap the fused linear-CE heads
 *  read. The head is not a LoRA target, so the base weights are authoritative. */
export interface HeadQuant {
  w: MlxArray; scales: MlxArray; biases: MlxArray | null;
  spec: ops.QuantSpec; softcap: number | null;
}

/** Layout of a prefix-shared concat [prompt(P); chosen(Rc); rejected(Rr)]. */
export interface PrefixLayout { P: number; Rc: number; Rr: number }

/** A LoRA leaf pair as the trainer holds it (`LoraWeights`). */
export interface LoraLeaves { a: MlxArray; b: MlxArray; scale: number; rank: number }

/** One sequence streamed through the layer stack in segments. Borrows the ids
 *  it began with; owns its caches, masks and per-layer inputs until `dispose`. */
export interface SegmentedPass {
  /** The input embeddings [1, T, hidden] (the first segment boundary). The
   *  caller owns and disposes it. */
  readonly input: MlxArray;
  /** Layers `[lo, hi)` over `h`, returning the residual stream after layer
   *  hi-1 (no final norm) and the fetched K/V of the reused donors in the range.
   *  `h` is never disposed; `donorKvIn` holds earlier segments' donor K/V
   *  (caller-owned). The caller owns and disposes what comes back. */
  runRange(h: MlxArray, lo: number, hi: number, donorKvIn: Map<number, SharedKv>):
    { h: MlxArray; donorKvOut: Map<number, SharedKv> };
  /** Release the pass's caches and masks and clear any prefix layout it set. */
  dispose(): void;
}

/** Backward that streams a sequence layer-segment by layer-segment. The driver
 *  owns the autograd (per-segment vjps over detached boundaries); the graph
 *  owns how a range of its layers runs and what crosses segment boundaries. */
export interface SegmentedTraining {
  readonly layerCount: number;
  /** K/V a layer reuses from an earlier layer of the same forward.
   *  `donorOf[i]` is the layer whose fetched K/V layer `i` consumes, or null
   *  when `i` attends its own; `reusedDonors` are the layers others consume,
   *  whose K/V must cross segment boundaries. Both are empty/null for a graph
   *  without KV sharing. */
  readonly sharedKv: { readonly reusedDonors: ReadonlySet<number>; readonly donorOf: readonly (number | null)[] };
  /** The final norm applied to the last boundary before the LM head. */
  finalNorm(h: MlxArray): MlxArray;
  /** Begin one pass over `ids` [1, T]. With a `prefix` layout the pass ropes and
   *  masks the prefix-shared concat (only for a graph that also declares
   *  `prefixShared`); the layout stays active until the pass is disposed. */
  begin(ids: MlxArray, prefix?: PrefixLayout): SegmentedPass;
}

/** One forward over a prefix-shared concat instead of two [prompt; response]
 *  forwards: block-sparse mask plus block-wise rope, bit-exact with the pair. */
export interface PrefixSharedTraining {
  /** Post-final-norm hidden [1, T, hidden] of the concat `ids` under `layout`.
   *  Borrows `ids`; the caller owns the result. */
  forwardHidden(ids: MlxArray, layout: PrefixLayout): MlxArray;
}

/** A gradient-checkpointed run of one training loop. */
export interface GradCheckpointRun {
  /** Free the checkpoints the last backward held (after its grads are eval'd). */
  releaseStep(): void;
  /** Forward-only evaluation: switch checkpointing off / back on. */
  suspend(): void;
  resume(): void;
  /** Switch checkpointing off and free everything it holds. */
  end(): void;
}

/** Recompute layer activations in the backward pass (numerically identical to
 *  off: a memory-for-compute trade). */
export interface GradCheckpointTraining {
  /** Enable for the adapter's targets; `splitMlp` also checkpoints each layer's
   *  attention and MLP sub-blocks separately. */
  enable(targets: readonly { modulePath: string; lw: LoraLeaves }[], splitMlp: boolean): GradCheckpointRun;
}

/** Whether the hand-rolled flash kernel may serve the training attention
 *  (`MLX_BUN_TRAIN_ATTN=flash`). A refusal states why. */
export type FlashTrainingAttention = { readonly supported: true } | { readonly supported: false; readonly reason: string };

/** The denoising objective of a `method: "denoising"` graph. */
export interface DenoisingTraining {
  readonly vocabSize: number;
  /** LoRA module path of each decoder layer (`<path>.self_attn.q_proj`, ...). */
  readonly layerModulePaths: readonly string[];
  /** Logits [1, L, vocab] (float32) of denoising `canvas` [1, L] given the prompt. */
  canvasLogits(promptIds: number[], canvas: MlxArray): MlxArray;
}

/** What the trainer consumes from a graph. A graph declares only the parts it
 *  implements; the trainer names the missing declaration when it needs one. */
export interface TrainableGraph {
  /** The quantized LM head for fused/flash linear-CE heads. */
  lmHead?(): HeadQuant;
  readonly flashAttention?: FlashTrainingAttention;
  readonly segmented?: SegmentedTraining;
  readonly prefixShared?: PrefixSharedTraining;
  readonly gradCheckpoint?: GradCheckpointTraining;
  readonly denoising?: DenoisingTraining;
}
