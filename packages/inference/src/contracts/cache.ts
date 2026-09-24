import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";


export type MaskMode = "" | "causal";
export interface Mask {
  mode: MaskMode | "array";
  arr: MlxArray | null;
  /** True when `arr` is exactly the bottom-right-aligned causal matrix
   *  (offset continuation, no window) — the case where mlx-lm would
   *  have handed the string "causal" instead. Only these array masks
   *  are eligible for the fused tiled SDPA: the optiq wrapper falls
   *  back to unfused on every array mask, and window/bidir masks must
   *  match that to stay scenario-bit-exact (Phase 9 finding). */
  causalEquivalent?: boolean;
}

/** Fetched KV handed from a donor layer to its sharers (and to the
 *  speculative drafter). Owned by forwardLayers for the pass.
 *  `offsetArr` is an owned pre-write position snapshot. Donor and sharing
 *  attention layers keep it until the fetched KV is released, even if the
 *  cache advances or replaces its borrowed row-position array. */
export type SharedKv =
  | { kind: "plain"; keys: MlxArray; values: MlxArray; offset: number;
      offsetArr?: MlxArray;
      /** TurboQuant deferred-V: `values` are still in the rotated (FWHT)
       *  domain — every consumer must un-rotate its attention OUTPUT
       *  (tq.unrotateValues) after sdpa. Attention is linear in V, so the
       *  result is the same decode, just transformed once per query row
       *  instead of once per cached token. */
      vRotated?: boolean;
      restoreValues?: (output: MlxArray) => MlxArray }
  | { kind: "quant"; keys: ops.QuantizedTensor; values: ops.QuantizedTensor;
      offset: number; groupSize: number; bits: number; offsetArr?: MlxArray }
  | { kind: "view"; attention: KvAttentionView; offset: number; offsetArr?: MlxArray };

/** Quantized attention consumes a numerical storage port, independent of the
 * concrete layout used for row positions, retention and persistence. */
export interface QuantizedAttentionState {
  readonly groupSize: number;
  readonly bits: number;
  updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor];
}

/** Values may stay in the codec's rotated domain until after attention. */
export interface RotatedValueAttentionState {
  /** Capture a fetched value domain independently of later row changes. */
  captureValueTransform?(): (output: MlxArray) => MlxArray;
  updateAndFetchDeferredV(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
}

/** A captured numerical view supports multiple queries without appending KV
 * again. It owns its tensor handles independently of later cache membership or
 * precision changes. Query/mask inputs are borrowed; outputs are owned. */
export interface KvAttentionView {
  /** Qualified committed spans retain the single-position reduction order. */
  attend(q: MlxArray, scale: number, mask: Mask, independentPositions?: boolean): MlxArray;
  dispose(): void;
}

/** Storage appends once and hands every attention consumer the same view. */
export interface KvAttentionState {
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView;
}

/** Owned read-only planes with validity separate from physical padding. */
export interface KvDonorRows {
  readonly keys: MlxArray;
  readonly values: MlxArray;
  readonly offsets: readonly number[];
  readonly starts: readonly number[];
  readonly ends: readonly number[];
}

/** Captured Q-only attention hides plain or encoded donor storage. */
export interface KvDonorAttention extends KvAttentionView {
  readonly width: number;
  readonly dtype: Dtype;
  readonly offsets: readonly number[];
  readonly starts: readonly number[];
  readonly ends: readonly number[];
}

export interface Cache {
  /** Maximum committed positions before this state changes precision. */
  maxAppendTokens?(): number;
  captureDonorRows?(): KvDonorRows;
  captureDonorAttention?(): KvDonorAttention;
  /** A preparation method commits each request's own precision boundary.
   * Splitting a forward for a sibling must not move that boundary. */
  readonly prefillMaintenance?: {
    beginPrefill(): void;
    commitPrefill(rows: readonly number[]): void;
    endPrefill(): void;
  };
  /** Optional representation-owned affine conversion. Logical position can
   * differ from the physical write head in a padded rotating layout. */
  readonly affineConversion?: { readonly offset: number; toQuantized(groupSize: number, bits: number): Cache };
  readonly turboConversion?: { readonly offset: number; toTurboQuantized(kBits: number, vBits: number): Cache };
  readonly attentionState?: KvAttentionState;
  /** Earliest prefix whose retained representation can resume generation.
   * Irreversible transitions may preserve bytes while invalidating older
   * precision boundaries. Reuse policy must not trim below this offset. */
  minimumReusableOffset?: number;
  readonly rotatedValueAttention?: RotatedValueAttentionState;
  readonly quantizedAttention?: QuantizedAttentionState;
  offset: number;
  /** Stable storage identity for compatibility guards and persistence.
   *  REQUIRED: every capability predicate (isPlainKvCache, isRotating*,
   *  kv-store codecs) is a string compare on this value, so a missing
   *  override used to fail OPEN into wrong routing (PRs #42/#43:
   *  BatchedRotatingCache shipped without one and batched joins dropped
   *  running rows). Wrappers report their own kind plus the inner kind. */
  signature(): string;
  /** Physical cache storage consumed by one additional token for one row.
   *  Recurrent caches return 0 because their state does not grow with the
   *  sequence. Optional for stateless/training adapters that are never
   *  admitted or persisted. */
  bytesPerToken?(): number;
  /** state() returned temporary views that the caller must release. */
  readonly stateNeedsDispose?: boolean;
  /** Compiled-decode trace adapters expose the RoPE offset as an int32
   *  array input here; real caches leave it unset (static int path). */
  readonly ropeOffsetArr?: MlxArray;
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
  /** Mask for an N-token step given this cache's state. */
  makeMask(N: number, windowSize: number | null): Mask;
  state(): MlxArray[];
  /** Can `trim(n)` drop the last n tokens? (Ring caches lose trimability
   *  once wrapped.) */
  isTrimmable(): boolean;
  /** Drop the last n tokens (future writes overwrite them). `bypass` (default
   *  false → unchanged behavior) skips the isTrimmable guard for the
   *  speculative-decode rollback case (trim the last n ≤ γ tips right after a
   *  >1 concat write); rotating caches then physically shrink the buffer tail. */
  trim(n: number, bypass?: boolean): void;
  /** Speculative verify-round support for NON-trimmable recurrent caches
   *  (SSMCache — gated-DeltaNet conv + recurrent state). A cache exposing
   *  these is spec-eligible without isTrimmable(): the serve loop arms a
   *  round before the verify forward (the layer snapshots pre-round state —
   *  free, MLX arrays are immutable — and records its position-local kernel
   *  inputs), then resolves it: commit on full accept, or rollback(keep)
   *  which restores the snapshot and bit-exactly REPLAYS the first `keep`
   *  window tokens through the recurrence (identical arithmetic prefix ⇒
   *  identical state). Trimmable caches leave these unset and keep trim(). */
  specRoundBegin?(): void;
  specRoundCommit?(): void;
  specRoundRollback?(keep: number): void;
  dispose(): void;
}

export interface RowBatchCache extends Cache {
  readonly batchSize: number;
  filterRows(keep: readonly number[]): void;
  extractRow(row: number): Cache | null;
}

/**
 * Capability contract for cache layouts that own their dynamic-row batching.
 * The scheduler uses this for non-K/V state families (for example GLM's
 * compressed MLA/DSA state) instead of teaching the scheduler their tensor
 * layout. `mergeRows` writes into an empty cache and does not consume inputs;
 * extracted rows are independent owned caches.
 */
export interface BatchableCache extends Cache {
  readonly batchSize: number | null;
  readonly rowOffsets: readonly number[];
  readonly leftPad: readonly number[];
  readonly maxTokens?: number;
  makeEmptyBatch(): BatchableCache;
  mergeRows(rows: readonly Cache[]): void;
  extractRow(row: number): Cache;
  filterRows(keep: readonly number[]): void;
  projectedBytes(tokens: number): number;
}

/** Padding is interpreted by cache geometry, independently of scheduling.
 * Left padding initializes an empty group; lengths count input columns before
 * trailing padding. Finalize before ordinary decode or publishing checkpoints. */
export interface PrefillPadding {
  readonly leftPadding?: readonly number[];
  readonly lengths: readonly number[];
  readonly rightPadding?: readonly number[];
}
export interface PaddedPrefillCache extends Cache {
  preparePrefill(padding: PrefillPadding): void;
  finalizePrefill(): void;
}

/** How one decode step interacts with a cache under compiled decode
 *  (returned by prepareDecodeStep, consumed by compiled-decode.ts):
 *  - "concat": the compiled graph fetches concat(active prefix, new kv)
 *    — same values as today's write-then-slice — and the WRITE happens
 *    outside the graph right after (writeDecodeStep), keeping the buffer
 *    single-referenced at its slice_update so mlx donates it in place.
 *  - "ring": the write happens IN-graph (slice_update_dynamic at
 *    writePos) and the fetch is the full updated buffer — the rotating
 *    steady state, where attention reads the whole ring in ring order
 *    (a concat would permute KV positions and change summation order).
 *    The updated buffers come back as closure outputs; adoptDecodeStep
 *    swaps them in. */
export interface DecodeStepPlan {
  fetch: "concat" | "ring";
  /** Write position on axis 2 (== ring index for rotating caches). */
  writePos: number;
  /** Valid prefix length for "concat" fetches (== offset). */
  activeLen: number;
}
