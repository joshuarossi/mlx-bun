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

/** A training pass's cache: it stores nothing and owns the positions its pass
 * reads at, the uniform positions from its offset or, for a prefix-shared
 * concat [prompt; chosen; rejected], each response restarted after the prompt. */
export interface TrainingAttentionCache extends AttentionCache {
  /** `x` [B, H, T, D] rotated at this pass's positions: `rope` rotates one
   * contiguous block of positions from a scalar offset. The caller owns `x`. */
  ropePositions(x: MlxArray, rope: (block: MlxArray, offset: number) => MlxArray): MlxArray;
}

/** A cache composed for committed-token appends (token fill), where every
 * position of the span is already decided. */
export interface CommittedAttentionCache extends AttentionCache {
  /** Committed span: `L` decided positions per row, causal within the span.
   * Each query attends its own causal prefix with the arithmetic of a
   * one-position read, so the span keeps the single-position reduction order
   * the graph qualifies per KV format (`MlxKnownSpans`, read by `appendKnown`). This replaces the
   * `independentPositions` flag. The only caller today runs one row with up to
   * four positions. */
  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead;
}

/** A cache composed for prompts whose media tokens attend each other in both
 * directions (Gemma 4 vision prefill). */
export interface BidirectionalAttentionCache extends AttentionCache {
  /** Bidirectional window: the same as `appendWindow`, except that two
   * positions both flagged in `bidirectional` see each other in either
   * direction, regardless of order or the sliding window. `bidirectional` is a
   * borrowed bool [L] that applies to every row. Defined only for the first
   * window of a sequence (offset 0). */
  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead;
}

/** A cache composed for an encoder that reads its whole prompt with no sliding
 * window, its media tokens attending each other in both directions (the
 * DiffusionGemma vision encoder, which reads every layer, sliding or full,
 * through one mask over the whole prompt). */
export interface EncoderAttentionCache extends AttentionCache {
  /** Encoder window: the first window of a sequence (offset 0), `L` new
   * positions per row, stored as `appendWindow` stores them. Query `i` sees
   * window positions `0..i`, and two positions both flagged in `bidirectional`
   * see each other in either direction. The cache's sliding window does not
   * limit this read: every query sees the whole window, whatever its length.
   * (`appendBidirectional` is the read the sliding window does limit.)
   * `bidirectional` is a borrowed bool [L] that applies to every row. */
  appendEncoderWindow(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead;
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

/** Pure decode operation bound by a layer. `qkv` is [B, 1, convDim], `a` and
 * `b` are [B, 1, Hv], `conv` is [B, K-1, convDim] and `recurrent` is null or
 * [B, Hv, Dv, Dk] float32. All inputs are borrowed; every result is owned by
 * the cache. `out` and `v` are [B, 1, Hv, Dv], `k` is [B, 1, Hk, Dk], and
 * both returned states retain their input layouts. `k` and `v` retain this
 * position's exact inputs for speculative rollback. */
export type GatedDeltaDecode = (qkv: MlxArray, a: MlxArray, b: MlxArray,
  conv: MlxArray, recurrent: MlxArray | null) => {
    out: MlxArray; conv: MlxArray; recurrent: MlxArray; k: MlxArray; v: MlxArray;
  };

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
  /** An explicitly bound fused decode read. Omission preserves the ordinary
   * convolution/heads/recurrence. Window reads always use `heads`. */
  readonly decode?: GatedDeltaDecode;
  /** The block's glue: the activation of the convolution output, the split
   * into q, k and v heads, and their norms and scaling. Pure. `convolved`
   * [B, S, convDim] is the raw convolution output (before activation) and is
   * borrowed. The cache owns and disposes the returned heads. The cache calls
   * this once per ordinary read; a bound `decode` supplies its own heads.
   * A speculative round keeps k and v for the rows a rollback retains. */
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

/** The compressed state of one latent attention layer after an append, as
 * caller-owned views of every stored position in order (float32). The caller
 * disposes all three. Rows follow the cache's row layout: right-justified, row
 * `b`'s positions starting at `leftPad[b]`. */
export interface LatentAttentionState {
  /** [B, T, kvLoraRank]: the normalized compressed content state. */
  readonly latent: MlxArray;
  /** [B, T, ropeHeadDim]: the decoupled RoPE key, already rotated. */
  readonly rope: MlxArray;
  /** [B, T, indexHeadDim]: the sparse-attention (DSA) index keys, on a cache
   * composed to store them; null otherwise. */
  readonly indexKeys: MlxArray | null;
}

/** State for one multi-head latent attention layer (GLM-5.2's MLA): it stores
 * the checkpoint-native compressed state per position (the latent and the
 * decoupled RoPE key, and on a sparse-attention layer the DSA index key), never
 * per-head keys and values. The attention block projects its queries and that
 * state, appends the state here and reads back everything stored, from which
 * it reconstructs or absorbs keys and values itself (the same split as
 * {@link GatedDeltaCache}: the block keeps its projections, the cache keeps the
 * state and its row layout). A layer composed with DSA appends an index key
 * with every position and reads the index keys stored before its append to
 * select positions.
 *
 * Rows: one row for a single sequence; a batch keeps its rows right-justified
 * along the sequence axis, `rowOffsets[b]` positions in row `b` starting at
 * `leftPad[b]`. Inputs to an append are borrowed and float32. */
export interface LatentAttentionCache extends Cache {
  readonly kvLoraRank: number;
  readonly ropeHeadDim: number;
  /** Rows in the layout, or null before the first append. */
  readonly batchSize: number | null;
  readonly rowOffsets: readonly number[];
  readonly leftPad: readonly number[];
  /** The index keys stored so far, [B, offset, indexHeadDim], owned by the
   * caller; null when none are stored (a cache without DSA, or an empty one). */
  storedIndexKeys(): MlxArray | null;
  /** Appends `L` positions per row (`latent` [B, L, kvLoraRank], `rope`
   * [B, L, ropeHeadDim], and `indexKeys` [B, L, indexHeadDim] exactly when the
   * cache stores them), advancing every row by `L`, and returns the state as of
   * this append. A rejected append leaves the cache unchanged. */
  appendLatent(latent: MlxArray, rope: MlxArray, indexKeys: MlxArray | null): LatentAttentionState;
}

/** A captured numerical view supports multiple queries without appending KV
 * again. It owns its tensor handles independently of later cache membership or
 * precision changes. Query/mask inputs are borrowed; outputs are owned. */
export interface KvAttentionView {
  /** Qualified committed spans retain the single-position reduction order. */
  attend(q: MlxArray, scale: number, mask: Mask, independentPositions?: boolean): MlxArray;
  dispose(): void;
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

/** The row-layout half of a composition's KV scheme, over one request's layer
 * caches: where its serial caches (the graph's composed legos) join row
 * layouts. The legos convert themselves inside their own appends; nothing here
 * converts a serial cache. */
export interface KvMaintenance {
  /** Limit committed work at a pending precision transition. */
  maxAppendTokens?(cache: readonly Cache[]): number;
  /** Bind state requiring row-local maintenance before shared decode. */
  prepareBatch?(cache: Cache[]): void;
  /** Bind all precision policies before a prefill cohort owns row boundaries. */
  preparePrefill?(cache: Cache[]): void;
}

/** The storage a composed cache holds and converts (the bf16-first KV legos a
 * graph's `makeCache` builds for its composition's KV scheme). The row
 * layouts, clones and saved files take the storage, never the lego; whoever
 * hands storage back to serial use composes it with `over`. */
export interface ComposedStorage {
  /** The storage held now, borrowed: bf16 before the transition, quantized or
   * encoded after. */
  storage(): Cache;
  /** This lego's composition over `storage`, which the result owns: storage
   * that already holds the conversion start converts before this returns, and
   * quantized storage reads with this lego's kernels. */
  over(storage: Cache): Cache;
  /** Hands the storage held now to the caller and leaves this lego empty. */
  release(): Cache;
}

export interface Cache {
  /** Present on a cache that composes the storage it holds (see ComposedStorage). */
  readonly composed?: ComposedStorage;
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
  /** Earliest prefix whose retained representation can resume generation.
   * Irreversible transitions may preserve bytes while invalidating older
   * precision boundaries. Reuse policy must not trim below this offset. */
  minimumReusableOffset?: number;
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

/**
 * Verification rows: the row layout a speculative method keeps its target rows
 * in, holding the speculative transaction. Every storage a cache lego holds
 * names one (state's `targetCacheLayout`), so any lego serves speculation.
 *
 * The method arms a round before the verify window (`specRoundBegin`), appends
 * the window, then resolves it: `specRoundCommit` keeps every row's window;
 * `specRoundRollback(keep)` keeps the first `keep` positions of each row's
 * window (one count for every row, or one per row). After either, every row is
 * exactly as if only its kept positions had been appended: the same offsets and
 * stored positions, the same reads from then on.
 */
export interface SpeculativeRowLayout extends BatchableCache {
  makeEmptyBatch(): SpeculativeRowLayout;
  specRoundBegin(): void;
  specRoundCommit(): void;
  specRoundRollback(keep: number | readonly number[]): void;
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
  /** Registers `array`, which the cache computed for this step's inputs (a
   *  prefix it decodes outside the recorded graph), for release after the step;
   *  returns it. Takes ownership. */
  own(array: MlxArray): MlxArray;
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
