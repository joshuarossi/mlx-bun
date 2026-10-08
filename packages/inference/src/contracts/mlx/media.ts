import type { MlxArray } from '@mlx-bun/mlx/array';
import type { Cache } from './cache';

/** Prepared embeddings for vision/audio prompts. Qualified models consume
 * this through shared preparation and decode; other bindings retain serial
 * execution. Token-only prefix caching remains disabled for media. */
export type Vision = {
  /** Producer identity includes all media and preceding rendered tokens. */
  prefixIdentity?: string;
  embeddings: MlxArray;
  /** bool [L] image-token mask for the bidirectional attention overlay.
   *  Absent when the prompt carries ANY audio — audio(-containing) prompts
   *  run fully causal (`02d723a:docs/design/generic-model-support.md` §6.6). */
  imageMask?: MlxArray;
  /** bool [L] union multimodal soft-token mask (image | audio) for
   *  per-layer-input id zeroing. Absent on the legacy vision-only shape,
   *  where zeroing falls back to imageMask. */
  multimodalMask?: MlxArray;
  /** Qwen3.5/3.8 vision: the request's mRoPE positions + decode delta,
   *  owned by shared forward input, or scoped to the explicit serial run. */
  mrope?: import("./positions").MropeRequestState;
};

/** Returns unscaled text embeddings; the caller owns the returned tensor. */
export interface TextEmbeddingModel {
  readonly embed: { encode(ids: MlxArray): MlxArray };
}
export interface AudioEncoder {
  readonly cacheIdentity?: string;
  readonly embedScale: number;
  features(mel: Float32Array, frames: number, preDivide?: boolean): MlxArray;
}

/** Prepared native input with an indivisible prefill. The preparation owner
 * retains its tensors; the graph's binding returns an owned final hidden row.
 * Decode, sampling and row retirement use the ordinary execution group. */
export interface MlxPromptInput {
  forward(ids: MlxArray, caches: Cache[], start?: number): MlxArray;
  readonly decodeState?: MlxDecodeState;
}

/** Additional graph-owned forward state. Equal keys declare compatible row
 * state; the backend supplies the current row order after joins/retirement. */
export interface MlxDecodeState {
  readonly key: string;
  forward(ids: MlxArray, caches: Cache[], rows: readonly MlxDecodeState[]): MlxArray;
}

/** Common contract for image encoders: preprocess image bytes into an
 * encoder-specific representation, then turn it into language-space soft
 * tokens [1, softTokens, hidden] (pre-divided by embed_scale). Encoders own
 * their preprocessing. */
export interface VisionEncoder<P extends { softTokens: number } = { softTokens: number }> {
  readonly cacheIdentity?: string;
  preprocess(bytes: Uint8Array): Promise<P>;
  features(pre: P): MlxArray;
  dispose?(): void;
}

/** Raw image pixels that a denoising method takes as its own prefill input. */
export interface PixelInput {
  /** Pixels are owned by the caller once returned. */
  preprocess(bytes: Uint8Array): Promise<{ pixels: MlxArray; softTokens: number }>;
  /** Insert `softTokens` image placeholders (one image) into rendered prompt ids. */
  spliceTokens(rawIds: number[], softTokens: number, tokenIds: { image: number; boi: number; eoi: number }): number[];
}

/** Lazy image/audio encoders loaded from a checkpoint's sidecars; null where
 * the checkpoint ships none. Loading is deferred until a request needs it. */
export interface MediaEncoders {
  vision: (() => VisionEncoder) | null;
  audio: (() => AudioEncoder & { dispose?(): void }) | null;
}

/** Facts about a checkpoint's files that only the caller's storage can answer. */
export interface MediaSidecarProbes {
  /** Whether the sidecar at `path` ships the audio encoder's tensors (header-only read). */
  shipsAudioTower(path: string): boolean;
}
