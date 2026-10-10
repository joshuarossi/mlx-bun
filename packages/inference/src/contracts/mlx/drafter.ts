// Drafter models as the draft sources see them. A drafter is a model: it is built
// and loaded in `models/` (`models/drafters.ts`), and the sources in
// `generation/speculative/` consume only these ports, never a concrete drafter.

import type { MlxArray } from "@mlx-bun/mlx/array";
import type { AssistantDonors } from "./attention";
import type { Cache } from "./cache";
import type { DraftProjection } from "./draft-projection";
import type { ResidualBasis } from "./draft-target";

/** One drafted step of a KV-borrowing assistant: owned token ids and the post-projected hidden. */
export interface DrafterRowsStep { tokens: MlxArray; nextHidden: MlxArray }

/** The optiq KV-borrowing assistant: no cache of its own, it reads the target's donor attention. */
export interface AssistantDrafterModel {
  forwardRows(lastTokenEmb: MlxArray, targetHidden: MlxArray, donors: AssistantDonors,
    position: number | MlxArray): DrafterRowsStep;
  dispose(): void;
}

/** What a projected-context drafter (DSpark, DeepSpec) attends over the target's tapped hidden states. */
export interface ContextKV {
  k: MlxArray; // [1, nKvHeads, ctxLen, headDim]
  v: MlxArray; // [1, nKvHeads, ctxLen, headDim]
}

/** Confidence-scheduled draft-length pruning and logits collection of one DSpark block. */
export interface DsparkDraftOptions {
  thresholds?: number[];
  minConf?: number;
  /** Concatenate the per-position draft logits into the result; default true. */
  collectLogits?: boolean;
  collectConfidence?: boolean;
}

/** Storage owns context validity; the DSpark graph supplies only Q and the block's K/V. */
export interface DsparkContextAttention {
  attend(layer: number, query: MlxArray, keys: MlxArray, values: MlxArray, scale: number): MlxArray;
}

/** Our trained DSpark module: block drafting over the target's multi-layer hidden context. */
export interface DsparkDrafterModel {
  readonly cfg: {
    readonly gamma: number;
    readonly nLayers: number;
    readonly tapLayers: number[];
    readonly sts?: { readonly thresholds: number[] };
  };
  projectContextRows(hidden: MlxArray): { k: MlxArray; v: MlxArray }[];
  forwardInfer(model: DraftProjection, hCtx: MlxArray, anchor: number, gamma: number,
    opts?: DsparkDraftOptions): { tokens: number[] };
  forwardRows(model: DraftProjection, hCtx: MlxArray | null, anchors: readonly number[], gamma: number,
    opts?: DsparkDraftOptions, context?: DsparkContextAttention): { tokens: number[][] };
  dispose(): void;
}

/** Storage owns context validity; the DeepSpec graph supplies only Q and new block KV. */
export interface DeepspecContextAttention {
  attend(layer: number, query: MlxArray, blockKeys: MlxArray, blockValues: MlxArray): MlxArray;
}

export interface DeepspecDraftRows {
  tokens: number[][];
  conf: number[][];
  baseLogits?: MlxArray;
}

export interface DeepspecDraftBlock {
  /** Sequentially sampled draft tokens, length 0..gamma (0 iff confidence truncation fires first). */
  tokens: number[];
  /** Per-position sigmoid confidence, aligned with `tokens`. */
  conf: number[];
  /** Base logits of the full block [1, gamma, vocab]; the caller disposes. */
  baseLogits: MlxArray;
}

/** DeepSeek's released DSpark drafter (DeepSpec): a block forward over cached, already projected context K/V. */
export interface DeepspecDrafterModel {
  readonly cfg: { readonly num_target_layers: number; readonly num_hidden_layers: number };
  /** The target layers whose hiddens the drafter conditions on. */
  readonly tapLayers: number[];
  /** The trained block width. */
  readonly gamma: number;
  readonly hidden: number;
  projectContext(targetHiddens: MlxArray): MlxArray;
  projectContextKV(contextHidden: MlxArray, positions: number[]): ContextKV[];
  projectContextKVRows(contextHidden: MlxArray, position: number | MlxArray): ContextKV[];
  draftBlock(ctxKV: ContextKV[], anchorTok: number, anchorPos: number): DeepspecDraftBlock;
  draftRows(context: DeepspecContextAttention, anchors: readonly number[], position: number | MlxArray,
    collectLogits?: boolean): DeepspecDraftRows;
  dispose(): void;
}

/** The recurrent multi-token-prediction block split from a Qwen release: token embeddings paired
 * with hiddens in, the module output (post final norm) out; the cache supplies positions and storage. */
export interface RecurrentMtpModule {
  forward(tokenEmbeds: MlxArray, hiddens: MlxArray, cache: Cache): MlxArray;
}

/** The checkpoint-native multi-token-prediction row of a graph that declares `nativeDraft`, over
 * compressed (MLA) attention state. The graph owns the numerics and the head's weights; the draft
 * source owns sampling and state retention. */
export interface NativeMtpHead {
  readonly hiddenSize: number;
  /** Geometry of the compressed cache the head appends to. */
  readonly cache: { readonly kvLoraRank: number; readonly ropeHeadDim: number; readonly maxTokens: number };
  forward(ids: MlxArray, hidden: MlxArray, cache: Cache): Promise<MlxArray>;
  /** Logits [B, positions, V] of the head's output. */
  project(hidden: MlxArray): MlxArray;
}

/** DFlash 2's projected-context attention: block keys follow the context rows. */
export interface Dflash2ContextAttention {
  attend(layer: number, query: MlxArray, blockKeys: MlxArray, blockValues: MlxArray, scale?: number): MlxArray;
}

/** The DFlash 2 block drafter: target taps → projected context K/V; one greedy block per anchor.
 *  It loads in the basis it was trained on and learns the target's when a draft group binds. */
export interface Dflash2DrafterModel {
  readonly cfg: { readonly layers: number; readonly numTargetLayers: number };
  readonly tapLayers: number[];
  /** Draft tokens per block (block size minus the anchor). */
  readonly gamma: number;
  /** Apply the target's declared residual basis (null: the trained basis) before any projection.
   *  The first call applies it; every later call must pass the same declaration. */
  bindResidualBasis(basis: ResidualBasis | null): void;
  projectContext(taps: MlxArray): MlxArray;
  projectContextKVRows(context: MlxArray, position: number | MlxArray): { k: MlxArray; v: MlxArray }[];
  draftRows(context: Dflash2ContextAttention, projection: DraftProjection, anchors: readonly number[],
    position: number | MlxArray, depth: number): number[][];
  /** The same proposals left on the device: [B, steps] row-major. */
  draftRowsDevice(context: Dflash2ContextAttention, projection: DraftProjection, anchors: readonly number[],
    position: number | MlxArray, depth: number): MlxArray;
  dispose(): void;
}
