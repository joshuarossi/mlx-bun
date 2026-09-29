import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";

/** Encoder/decoder geometry a speech graph reads from its checkpoint. */
export interface WhisperDims {
  nMels: number;
  nAudioCtx: number;
  nAudioState: number;
  nAudioHead: number;
  nAudioLayer: number;
  nVocab: number;
  nTextCtx: number;
  nTextState: number;
  nTextHead: number;
  nTextLayer: number;
}

/** Decoder state one decode owns (self-attention K/V and the cross K/V from the encoder output).
 * The graph that made it is the only one that reads it; the transcription loop only advances,
 * reorders and releases it. */
export interface WhisperDecoderCache {
  /** Tokens already in the self-attention cache. */
  readonly offset: number;
  /** Beam reorder: keep rows `indices` (take along the batch axis). */
  rearrange(indices: number[]): void;
  dispose(): void;
}

/** The optimized path's cache: its self-attention K/V arrays per layer, so a pipelined loop can
 * schedule their evaluation with the step outputs. */
export interface WhisperFastCache extends WhisperDecoderCache {
  readonly k: readonly MlxArray[];
  readonly v: readonly MlxArray[];
}

/** Token filters the optimized decode steps apply on device. */
export interface FastFilterConfig {
  nVocab: number;
  eot: number;
  timestampBegin: number;
  noTimestamps: number;
  /** Ids masked at every step (non-speech + task/special tokens). */
  suppressIds: number[];
  /** Ids masked at the first sampled position (blank + eot), or null. */
  blankIds: number[] | null;
  useTimestampRules: boolean;
  maxInitialTimestampIndex: number | null;
}

/** The optimized execution path of a speech graph (temperature-0 decoding, beam search). Every step
 * returns owned arrays. */
export interface WhisperFastPath {
  makeCache(): WhisperFastCache;
  /** `audioCtx` (Lab): encode only the first 2·audioCtx mel frames. */
  encode(mel: MlxArray, audioCtx?: number | null): MlxArray;
  /** Project the encoder output into every decoder layer's cross K/V. */
  crossKv(features: MlxArray, cache: WhisperFastCache): void;
  /** Multi-token prefill: fills the self-KV cache, returns logits [B, T, V]. */
  prefill(tokens: MlxArray, cache: WhisperFastCache): MlxArray;
  /** Pipelined greedy step over token and timestamp-state arrays. */
  greedyStep(
    st: { tok: MlxArray; lastTok: MlxArray; penultTok: MlxArray; lastTs: MlxArray },
    cache: WhisperFastCache, cfg: FastFilterConfig,
  ): { pre: MlxArray; next: MlxArray; lp: MlxArray; lastTs: MlxArray };
  beamStep(
    tokens: number[], cache: WhisperFastCache, cfg: FastFilterConfig, k: number,
    state: { lastTok: number[]; penultTok: number[]; lastTs: number[] },
  ): { pre: MlxArray; idx: MlxArray; vals: MlxArray };
  /** One compiled decode step: pre-filter and filtered last-position logits [B, V] f32. */
  step(
    tokens: number[], cache: WhisperFastCache, cfg: FastFilterConfig,
    state: { lastTok: number[]; penultTok: number[]; lastTs: number[]; atBegin: boolean },
  ): { pre: MlxArray; filtered: MlxArray };
}

/** What the transcription engine needs of a speech-recognition graph: the faithful encoder/decoder,
 * the optimized path, and the checkpoint facts window decoding and word timing read. The engine
 * never names the class that implements it. */
export interface WhisperGraph {
  readonly dims: WhisperDims;
  /** The checkpoint's weight dtype (mel windows are cast to it). */
  readonly dtype: Dtype;
  readonly isMultilingual: boolean;
  /** Cross-attention heads (layer, head) used for word timestamps. */
  readonly alignmentHeads: [number, number][];
  readonly fast: WhisperFastPath;
  makeCache(): WhisperDecoderCache;
  /** mel [B, 3000, n_mels] (weight dtype) → [B, 1500, D]. */
  encode(mel: MlxArray): MlxArray;
  /** tokens [B, T] int32 + audio features → logits [B, T, n_vocab] and, on request, the per-layer
   * raw cross-attention qk. Advances `cache`. */
  decode(
    tokens: MlxArray, audioFeatures: MlxArray, cache: WhisperDecoderCache,
    opts?: { wantCrossQk?: boolean },
  ): { logits: MlxArray; crossQk: (MlxArray | null)[] };
}
