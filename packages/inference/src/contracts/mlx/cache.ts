import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
import type * as ops from "@mlx-bun/mlx/ops";

export type MaskMode = "" | "causal";
export interface Mask {
  mode: MaskMode | "array";
  arr: MlxArray | null;
  /** True when `arr` is exactly the bottom-right-aligned causal matrix
   *  (offset continuation, no window) — the case where mlx-lm would
   *  have handed the string "causal" instead. Only these array masks
   *  are eligible for the fused tiled SDPA: the optiq wrapper falls
   *  back to unfused on every array mask, and window/bidir masks must
   *  match that to stay scenario-bit-exact. */
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

/** Attention over a cache's positions as of one phase-named call. The cache
 * picked the kernel when it was built and builds the mask from the offsets, row
 * layout and sliding window it owns. The caller supplies only queries.
 *
 * The read owns its tensor handles. It stays valid after later appends, trims,
 * row changes or disposal of its cache. Holding it across the cache's next
 * append can make that append copy storage instead of writing in place, so
 * dispose it when the forward that made it is done. It does no attention work
 * before `attend`; disposing an unused read only releases handles. */
export interface AttentionRead {
  /** Queries `q` [B, Hq, L, Dk] (borrowed, positional encoding applied, Hq a
   * multiple of the stored Hkv) to an owned output [B, Hq, L, Dv]. `B` and `L`
   * must match the call that made this read, and the result is defined only for
   * that call's phase. Callable any number of times: layers that share a
   * donor's keys and values attend the donor's read with their own queries. */
  attend(q: MlxArray, scale: number): MlxArray;
  /** Releases the read's handles. Call exactly once. */
  dispose(): void;
}

/** A key/value cache that owns its attention read. Each method appends the new
 * keys and values for the phase it names and returns the read for that phase.
 * The caller never sees stored keys or values and never chooses a kernel. The
 * storage (bf16, affine, TurboQuant, paged, rotating, delayed quantization) is
 * not visible here: the loader composes the cache, and the cache fixes one
 * kernel per read at construction.
 *
 * Every append has these obligations:
 * - `k` [B, Hkv, L, Dk] and `v` [B, Hkv, L, Dv] are borrowed. The caller
 *   disposes them after the call returns. `k` already carries the positional
 *   encoding for the positions it occupies, which start at each row's offset.
 * - Rows follow this cache's row layout: one row for a single-sequence cache;
 *   `rowOffsets`, `leftPad` and padding prepared through `PaddedPrefillCache`
 *   for a batchable layout. Each row appends at its own offset, and the offsets
 *   have advanced by `L` when the call returns.
 * - The caller owns the returned read (see {@link AttentionRead}).
 * - The method name is the phase. A cache never infers the phase from `L`, from
 *   the query shape or from a mask. Calling a method outside its phase gives an
 *   undefined result. */
export interface AttentionCache extends Cache {
  /** Decode: one new position per row (`L` = 1). Each row's query sees that
   * row's valid stored positions up to and including the one just appended,
   * limited to the cache's sliding window. */
  appendDecode(k: MlxArray, v: MlxArray): AttentionRead;
  /** Window: `L` new positions per row, causal within the window, for prefill
   * chunks, prefill tails and speculative verify windows. Query `i` of a row
   * sees the row's earlier valid positions and window positions `0..i`, limited
   * to the cache's sliding window. Left padding and prepared prefill padding are
   * never visible. Outputs at padded query positions are unspecified and the
   * caller ignores them. To append context without attending, make this call
   * and dispose the read unused. */
  appendWindow(k: MlxArray, v: MlxArray): AttentionRead;
}

/** A cache composed for committed-token appends (token fill), where every
 * position of the span is already decided. */
export interface CommittedAttentionCache extends AttentionCache {
  /** Committed span: `L` decided positions per row, causal within the span.
   * Each query attends its own causal prefix with the arithmetic of a
   * one-position read, so the span keeps the single-position reduction order
   * the graph qualifies per KV format (`MlxTokenAppend`). This replaces the
   * `independentPositions` flag. The only caller today runs one row with up to
   * four positions. */
  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead;
}

/** A cache composed for prompts whose media tokens attend each other in both
 * directions (Gemma 4 vision prefill, the DiffusionGemma vision encoder). */
export interface BidirectionalAttentionCache extends AttentionCache {
  /** Bidirectional window: the same as `appendWindow`, except that two
   * positions both flagged in `bidirectional` see each other in either
   * direction, regardless of order or the sliding window. `bidirectional` is a
   * borrowed bool [L] that applies to every row. Defined only for the first
   * window of a sequence (offset 0). */
  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead;
}

/** A cache composed for block reads, where a block's queries attend the stored
 * context plus the block's own keys and values without storing them
 * (DiffusionGemma's canvas pass, the DFlash 2 drafter's block over its
 * projected context). */
export interface BlockAttentionCache extends AttentionCache {
  /** Block read: `k` [B, Hkv, L, Dk] and `v` [B, Hkv, L, Dv] are the block's
   * keys and values, borrowed and not appended. Offsets do not move. Every
   * query of a row sees that row's valid stored positions, limited to the
   * cache's sliding window, and all `L` block positions. The read takes queries
   * for exactly this block. */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead;
}

/** A gated DeltaNet block's heads for one recurrence call. */
export interface GatedDeltaHeads {
  /** [B, S, Hk, Dk], normalized and scaled by the block. */
  readonly q: MlxArray;
  /** [B, S, Hk, Dk], normalized and scaled by the block. */
  readonly k: MlxArray;
  /** [B, S, Hv, Dv]. */
  readonly v: MlxArray;
}

/** What a gated DeltaNet block lends its recurrent cache for one call: the
 * layer's recurrence weights and the block's glue between the convolution and
 * the recurrence. The block keeps its projections, norms and activations. The
 * cache keeps the convolution state, the recurrent state and the kernels that
 * update them. */
export interface GatedDeltaParameters {
  /** Depthwise causal convolution weight [convDim, K, 1]. */
  readonly convWeight: MlxArray;
  /** Per-value-head decay logarithm (`A_log`) [Hv]. */
  readonly aLog: MlxArray;
  /** Per-value-head timestep bias [Hv]. */
  readonly dtBias: MlxArray;
  /** The block's glue: the activation of the convolution output, the split
   * into q, k and v heads, and their norms and scaling. Pure. `convolved`
   * [B, S, convDim] is the raw convolution output (before activation) and is
   * borrowed. The cache owns and disposes the returned heads. The cache calls
   * this once per recurrence call, and again over the accepted prefix when it
   * replays a speculative round. */
  heads(convolved: MlxArray): GatedDeltaHeads;
}

/** Recurrent state for one gated DeltaNet layer. It owns its read the way
 * {@link AttentionCache} does: the block hands over its projected inputs and
 * receives the recurrence output. The cache zeroes padded positions, runs the
 * causal convolution over its stored convolution state, keeps each row's
 * convolution tail, runs the gated-delta recurrence with the kernels in
 * `kernels/delta`, replaces both states and advances its offsets. A training
 * cache runs the differentiable recurrence behind the same calls.
 *
 * Both calls have these obligations:
 * - `qkv` [B, S, convDim] is the `in_proj_qkv` output before convolution, and
 *   `a`, `b` [B, S, Hv] are the raw `in_proj_a` and `in_proj_b` outputs. The
 *   call consumes all three: the cache disposes them, or keeps them for an
 *   armed speculative round. The caller must not use or dispose them after the
 *   call.
 * - `layer` is borrowed and must stay valid until an armed speculative round
 *   resolves, because rollback replays through it.
 * - The caller owns the output [B, S, Hv, Dv]. The block applies the output
 *   gate (`z`) and the output projection itself.
 * - Inside an armed round (`specRoundBegin`), the call records the pre-call
 *   states and its inputs, so `specRoundRollback(keep)` restores and replays the
 *   accepted prefix inside the cache. At most one call per armed round.
 * - Rows follow this cache's row layout, as for {@link AttentionCache}. The
 *   method name is the phase; a cache never infers it from `S`. */
export interface GatedDeltaCache extends Cache {
  /** Decode: one new position per row (`S` = 1), with no prefill padding in
   * effect. */
  recurDecode(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray;
  /** Window: `S` positions per row, for prefill chunks and tails, speculative
   * verify windows and committed spans. Padding prepared through
   * `PaddedPrefillCache` holds: padded positions change neither state, each
   * row's convolution tail ends at its last real position, and each row's offset
   * advances by its real count. Outputs at padded positions are unspecified. */
  recurWindow(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray;
}

/** Quantized attention consumes a numerical storage port, independent of the
 * concrete layout used for row positions, retention and persistence.
 * @deprecated Hands packed keys and values to the caller, which then chooses
 * the kernel. Read through {@link AttentionCache}; an affine cache attends with
 * its own kernels. Removed in B1. */
export interface QuantizedAttentionState {
  readonly groupSize: number;
  readonly bits: number;
  updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor];
}

/** Values may stay in the codec's rotated domain until after attention.
 * @deprecated Hands rotated values to the caller, which must undo the rotation
 * after attention. Read through {@link AttentionCache}; a TurboQuant cache
 * undoes its rotation inside its read. Removed in B1. */
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

/** Storage appends once and hands every attention consumer the same view.
 * @deprecated The paged shape {@link AttentionCache} generalizes. Here the view
 * infers the phase from the query, and the caller still supplies the mask and
 * the `independentPositions` flag. Use {@link AttentionCache} and its named
 * reads. Removed in B1. */
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

/** Dense key/value reads (`updateAndFetch` returning keys and values as
 * arrays) for a graph whose attention reads them that way: plain storage
 * returns them directly, storage that decodes on read returns its dequantized
 * window. Storage that can answer declares it. A cache without it is not
 * certified for a composed dense read (it may still serve `updateAndFetch`
 * directly). */
export interface DenseKvReads {
  /** Pure: whether `row` can take its next append and still be read dense —
   * its storage reads dense now, and the maintenance that append schedules
   * (deferred during prefill) leaves it reading dense. */
  appendable(row: number): boolean;
}

/** KV precision maintenance over a list of caches (a model's layers, or the
 * rows of a delayed cache): converts eligible entries in place. */
export interface KvMaintenance {
  (cache: Cache[]): void;
  /** Limit committed work at a pending precision transition. */
  maxAppendTokens?(cache: readonly Cache[]): number;
  /** Bind state requiring row-local maintenance before shared decode. */
  prepareBatch?(cache: Cache[]): void;
  /** Bind all precision policies before a prefill cohort owns row boundaries. */
  preparePrefill?(cache: Cache[]): void;
  /** Pure: whether `cache` at `index` (its layer, or its row inside a delayed
   * cache), reading dense now, still reads dense after this maintenance next
   * runs on it — by its own conversion test and what it converts to. Absent:
   * this maintenance cannot answer, so storage it maintains is not certified
   * for dense reads. */
  keepsDenseReads?(cache: Cache, index: number): boolean;
}

export interface Cache {
  /** Dense reads, when this storage can answer for them (see DenseKvReads). */
  readonly denseKvReads?: DenseKvReads;
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
   * differ from the physical write head in a padded rotating layout.
   * @deprecated The loader composes the affine, TurboQuant or
   * delayed-quantization cache, which converts inside its own append and keeps
   * serving {@link AttentionCache}. Removed in B1. */
  readonly affineConversion?: { readonly offset: number; toQuantized(groupSize: number, bits: number): Cache };
  /** Optional representation-owned TurboQuant conversion.
   * @deprecated The same replacement as `affineConversion`. Removed in B1. */
  readonly turboConversion?: { readonly offset: number; toTurboQuantized(kBits: number, vBits: number): Cache };
  /** @deprecated Use {@link AttentionCache} (see {@link KvAttentionState}).
   * Removed in B1. */
  readonly attentionState?: KvAttentionState;
  /** Earliest prefix whose retained representation can resume generation.
   * Irreversible transitions may preserve bytes while invalidating older
   * precision boundaries. Reuse policy must not trim below this offset. */
  minimumReusableOffset?: number;
  /** @deprecated Use {@link AttentionCache} (see
   * {@link RotatedValueAttentionState}). Removed in B1. */
  readonly rotatedValueAttention?: RotatedValueAttentionState;
  /** @deprecated Use {@link AttentionCache} (see
   * {@link QuantizedAttentionState}). Removed in B1. */
  readonly quantizedAttention?: QuantizedAttentionState;
  offset: number;
  /** Stable storage identity for compatibility guards and persistence.
   *  REQUIRED: every capability predicate (isPlainKvCache, isRotating*,
   *  packages/inference/src/state/persistence.ts codecs) is a string compare on
   *  this value, so a missing
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
  /** @deprecated Hands stored keys and values to the caller. Use
   * {@link AttentionCache.appendDecode} or {@link AttentionCache.appendWindow},
   * or a named read that extends them. Recurrent caches implement
   * {@link GatedDeltaCache}. Removed in B1. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
  /** Mask for an N-token step given this cache's state.
   * @deprecated The named reads of {@link AttentionCache} and
   * {@link GatedDeltaCache} build their own masks from the offsets, row layout
   * and window the cache owns. This becomes internal to each cache in B1. */
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
 * The scheduler uses this for every storage family (plain and quantized KV,
 * sliding windows, recurrent state, and layouts such as GLM's compressed MLA/DSA
 * state) instead of teaching the scheduler their tensor layout. `mergeRows`
 * writes into an empty cache and does not consume inputs: its sources are a
 * running layout or one serial cache, then one serial cache per joining row.
 * Extracted rows are independent owned serial caches.
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
  /** Whether `row` can be published as a cache covering exactly `tokens`
   * positions. State that cannot be trimmed (recurrent) refuses a row whose own
   * count differs: an entry keyed to other tokens would corrupt every later
   * exact hit. Absent: any row can be published. */
  canPublishRow?(row: number, tokens: number): boolean;
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

/** What a compiled decode step hands a cache to assemble its closure inputs. The
 *  arrays it returns live for one step; the runner releases them afterwards. */
export interface DecodeStepInputs {
  /** `array[.., 0:length, ..]` along the sequence axis (axis 2). */
  activeView(array: MlxArray, length: number): MlxArray;
  /** The int32 `[1]` write position (shared between caches at the same position). */
  writePosition(position: number): MlxArray;
}

/** The stand-in a cache places in the traced graph for one step: attention
 *  appends to it exactly as it would to the real cache, and the arrays it appends
 *  become closure outputs (`outs`) instead of a buffer write. */
export interface DecodeTrace extends Cache {
  outs: MlxArray[];
}

/** One cache's slot in a compiled decode closure. Plain data: it captures no
 *  cache, so a closure built once serves every later step and generation. */
export interface DecodeSlot {
  /** Graph-shape signature (cache kind, quantization); offsets and capacities
   *  are array values or shapeless dimensions and stay out of it. */
  readonly key: string;
  /** The write happens in the graph (ring) or outside it after the step (concat). */
  readonly fetch: DecodeStepPlan["fetch"];
  /** Closure inputs this cache feeds, and closure outputs it returns. */
  readonly inputs: number;
  readonly outputs: number;
  /** The traced stand-in over this slot's `inputs`; `ropeOffset` is the int32 RoPE position input. */
  trace(inputs: readonly MlxArray[], ropeOffset: MlxArray): DecodeTrace;
}

/** A cache the compiled decode step can drive: it declares the slot it occupies
 *  in the closure for the coming step and applies the closure's outputs back. */
export interface CompiledDecodeCache extends Cache {
  /** Host-side bookkeeping for a 1-token step (growth, rotation), without the write. */
  prepareDecodeStep(): DecodeStepPlan;
  /** Non-mutating: the fetch `prepareDecodeStep` will choose. */
  decodePhase(): DecodeStepPlan["fetch"];
  decodeSlot(plan: DecodeStepPlan): DecodeSlot;
  /** The closure inputs of `slot`, in order. */
  decodeInputs(plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[];
  /** Apply the closure's outputs (takes ownership); returns arrays to evaluate with the step. */
  commitDecodeStep(slot: DecodeSlot, outputs: MlxArray[]): MlxArray[];
}
