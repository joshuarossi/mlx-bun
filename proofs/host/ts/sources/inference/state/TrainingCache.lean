import host.ts.Source
namespace Host.Ts.Sources.Inference.State.TrainingCache
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/training-cache.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { createCausalMask } from "../kernels/attention/masks";
import { flashAttention, flashSupported, getTrainingAttn } from "../kernels/attention/flash";
import { gatedDeltaUpdate } from "../kernels/delta/gated";
import type { AttentionRead, Cache, GatedDeltaCache, GatedDeltaParameters, Mask, TrainingAttentionCache } from "../contracts/mlx/cache";
import { ropeBlocks } from "../layers/prefix-layout";
import { AttentionMasks, causalLease, unmaskedLease, withLease, type MaskLease } from "./attention-read";
import type { PrefixLayout } from "../contracts/mlx/trainable";
import { isRecurrentCache } from "./capabilities";

/** The kernel a training cache's reads attend with, fixed when the cache is
 *  built. `sdpa` is the stock fused SDPA, the kernel mlx-lm's tuner
 *  differentiates. `flash` is the opt-in O(L)-memory kernel
 *  (`MLX_BUN_TRAIN_ATTN=flash`): it serves a causal or masked read of a query
 *  it supports (`flashSupported`: head size, at least 32 positions) as causal
 *  attention within the cache's sliding window, and the SDPA serves the rest,
 *  the rule the training forwards applied per call before the caches owned
 *  their reads. */
export type TrainingAttention = "sdpa" | "flash";

/** The training attention the trainer selected for its run (`setTrainingAttn`,
 *  set around a run from `MLX_BUN_TRAIN_ATTN` once the graph's training
 *  declaration allows it). Read where a forward's training caches are built,
 *  never inside a read. */
export function selectedTrainingAttention(): TrainingAttention {
  return getTrainingAttn() === "flash" ? "flash" : "sdpa";
}

/** A training cache's read: pass-through views of `k` and `v` (borrowed, as
 *  every append's are) under `mask`, which the read owns. */
function trainingRead(k: MlxArray, v: MlxArray, mask: MaskLease, attention: TrainingAttention, window: number | null): AttentionRead {
  return withLease(mask, held => {
    const keys = k.slice([0, 0, 0, 0], k.shape);
    let values: MlxArray;
    try { values = v.slice([0, 0, 0, 0], v.shape); } catch (error) { keys.dispose(); throw error; }
    const { mode, arr } = held.mask;
    const flash = attention === "flash" && (mode === "causal" || mode === "array");
    return {
      attend: (q, scale) => flash && flashSupported(q)
        ? flashAttention(q, keys, values, scale, true, window ?? 0)
        : ops.sdpa(q, keys, values, scale, mode, arr),
      dispose() { keys.dispose(); values.dispose(); held.release(); },
    };
  });
}

/** The padded-batch training mask over `L` positions: [B, 1, L, L] bool, true
 *  where query i of row b may attend key j:
 *    (j <= i) AND (j < lengths[b]) [AND (i < j + window) under a sliding window]
 *  createCausalMask(L, 0, window) broadcast over the rows and masked by each
 *  row's key validity. Caller owns the result. */
export function paddedTrainingMask(B: number, L: number, lengths: readonly number[], window: number | null): MlxArray {
  const causal2d = createCausalMask(L, 0, window);
  const causal4d = ops.reshape(causal2d, [1, 1, L, L]);
  causal2d.dispose();
  const keyValidData = new Int32Array(B * L);
  for (let b = 0; b < B; b++) {
    const length = lengths[b]!;
    for (let j = 0; j < L; j++) keyValidData[b * L + j] = j < length ? 1 : 0;
  }
  const keyValidI = MlxArray.fromInt32(keyValidData, [B, 1, 1, L]);
  const zero = MlxArray.fromInt32(new Int32Array([0]), []);
  const keyValid = ops.less(zero, keyValidI);
  zero.dispose();
  keyValidI.dispose();
  const allow = ops.logicalAnd(causal4d, keyValid);
  causal4d.dispose();
  keyValid.dispose();
  return allow;
}

/** Stateless cache for the training and scoring forward. Training is always a
 *  single offset-0 full-sequence pass, so nothing is stored and every append
 *  reads exactly the keys and values it is handed; the offset stays 0. The
 *  statelessness is REQUIRED: gradient checkpointing re-runs a layer's closure
 *  during the backward recompute, and a layer that shares another layer's keys
 *  and values reads them through that layer's cache again, so an append must
 *  leave the cache as it found it.
 *
 *  Reads: pass-through views of `k` and `v`, attended with `attention`.
 *  Without `rowLengths`: no mask for decode, the fused causal mask for a
 *  window, and the offset-0 sliding-window mask once a window is longer than
 *  `window`. With `rowLengths` (a right-padded batch whose rows hold that many
 *  real positions), both reads take the padded-batch mask
 *  (`paddedTrainingMask`) for the cache's window, so no real query sees a
 *  padded key. A layer with a sliding window gets a cache composed with it; the
 *  caches of one forward share `masks`, so its layers build each mask once. */
export class TrainingCache implements TrainingAttentionCache {
  constructor(
    /** The layer's sliding window; null for full attention. */
    readonly window: number | null = null,
    /** The per-forward masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
    /** The kernel this cache's reads attend with. */
    readonly attention: TrainingAttention = "sdpa",
    /** Real positions per row of a right-padded batch; null for unpadded rows. */
    readonly rowLengths: readonly number[] | null = null,
  ) {}
  /** Training-only adapter; never admitted, merged, or persisted. */
  signature(): string { return "train:training"; }
  offset = 0;
  /** Uniform positions from the pinned offset. */
  ropePositions(x: MlxArray, rope: (block: MlxArray, offset: number) => MlxArray): MlxArray { return rope(x, this.offset); }
  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    return trainingRead(k, v, this.rowLengths ? this.#padded(k.shape[2]!) : unmaskedLease, this.attention, this.window);
  }
  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    const L = k.shape[2]!, window = this.window;
    const mask = this.rowLengths ? this.#padded(L)
      : window === null || L <= window ? causalLease
      : this.masks.lease(`training-window:${window}`, `${L}`,
        () => ({ mode: "array", arr: createCausalMask(L, 0, window) }));
    return trainingRead(k, v, mask, this.attention, window);
  }
  #padded(L: number): MaskLease {
    const lengths = this.rowLengths!;
    return this.masks.lease(`training-padded:${this.window}`, `${L}|${lengths.join(",")}`,
      () => ({ mode: "array", arr: paddedTrainingMask(lengths.length, L, lengths, this.window) }));
  }
  /** The dense fetch and mask the softcapped read (`state/softcap-attention.ts`)
   *  attends through: pass-through views and the mask the window read takes. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(N: number, windowSize: number | null): Mask {
    if (this.rowLengths) return { mode: "array", arr: paddedTrainingMask(this.rowLengths.length, N, this.rowLengths, this.window) };
    if (N === 1) return { mode: "", arr: null };
    if (windowSize === null || N <= windowSize) return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, 0, windowSize) };
  }
  state(): MlxArray[] {
    return [];
  }
  isTrimmable(): boolean {
    return true;
  }
  trim(_n: number): void {
    /* offset is pinned at 0 */
  }
  dispose(): void {
    // Owns no arrays; drops the memo's holds on its masks.
    this.masks.clear();
  }
}

/** Stateless DeltaNet stand-in (same re-runnability contract as
 *  TrainingCache): state WRITES are discarded immediately, so a gradient-
 *  checkpoint recompute re-enters with the identical null-state conditions;
 *  reads always yield null (zeros inside the kernel) — a full-sequence
 *  forward from t=0, exactly the training/perplexity semantics. Before this
 *  existed, qwen3_5 routed its DeltaNet layers into plain TrainingCache and
 *  threw on the missing conv/recurrent/advance surface (the recorded
 *  "mlx-bun perplexity cannot score qwen3_5" gap).
 *
 *  Its `recurDecode` and `recurWindow` run the recurrence with a backward
 *  attached (`gatedDeltaUpdate`'s `differentiable`), since the inference
 *  kernel has no gradient; the DeltaNet block hands them its projections as it
 *  does to any recurrent cache. */
export class TrainingSSMCache implements GatedDeltaCache {
  /** Training-only adapter; never admitted, merged, or persisted. */
  signature(): string { return "train:training-ssm"; }
  offset = 0;
  specRound: null = null;
  recurDecode(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray {
    return this.#recur(qkv, a, b, layer);
  }
  recurWindow(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray {
    return this.#recur(qkv, a, b, layer);
  }
  /** The training recurrence: a zero conv state, the
   *  causal convolution, the block's glue, and the differentiable recurrence
   *  from a zero recurrent state. Nothing is stored, so the new recurrent
   *  state is disposed at once and no conv tail is kept. */
  #recur(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray {
    const [B, , D] = qkv.shape as [number, number, number];
    const convState = ops.zeros([B, layer.convWeight.shape[1]! - 1, D], qkv.dtype);
    const input = ops.concatAxis([convState, qkv], 1);
    convState.dispose();
    qkv.dispose();
    const conv = ops.conv1d(input, layer.convWeight, 1, 0, 1, D);
    input.dispose();
    const { q, k, v } = layer.heads(conv);
    conv.dispose();
    const [out, state] = gatedDeltaUpdate(q, k, v, a, b, layer.aLog, layer.dtBias, null, null, true);
    for (const array of [q, k, v, a, b, state]) array.dispose();
    return out;
  }
  advance(_n: number): void { /* offset pinned at 0 */ }
  rowOffset(_i: number): number { return 0; }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void { /* stateless */ }
  dispose(): void { /* owns no arrays */ }
}

/** Block-sparse attention mask [T,T] (bool, true = attend) for the prefix-shared
 *  concat [prompt(P); chosen(Rc); rejected(Rr)]: physical causal AND NOT
 *  (rejected row -> chosen col). Chosen rows already can't see rejected cols
 *  (rejected come later), so the only extra cut is rejected->chosen. With a
 *  sliding `window`, one more AND on LOGICAL positions (`logpos[row] -
 *  logpos[col] < window`, `logpos[i] = i` for prompt+chosen and `i - Rc` for the
 *  rejected block, reset to P): a rejected token at physical P+Rc+k has logical
 *  position P+k, so its window to the prompt tail differs from its physical
 *  distance by Rc. Caller owns the result. */
export function blockSparsePrefixMask(layout: PrefixLayout, window: number | null): MlxArray {
  const { P, Rc, Rr } = layout;
  const T = P + Rc + Rr;
  const causal = createCausalMask(T, 0, null); // [T,T] physical causal (a window is applied separately, on logical positions)
  const idxFlat = ops.arange(0, T, 1, Dtype.int32);
  const row = ops.reshape(idxFlat, [T, 1]);
  const col = ops.reshape(idxFlat, [1, T]);
  const pp = ops.fromInt32([P], []);
  const pRc = ops.fromInt32([P + Rc], []);
  // notForbid = NOT(rejRow AND chosenCol) = (i < P+Rc) OR (j < P) OR (j >= P+Rc)
  const notRejRow = ops.less(row, pRc);
  const colLtP = ops.less(col, pp);
  const colGePRc = ops.greaterEqual(col, pRc);
  const notChosenCol = ops.logicalOr(colLtP, colGePRc);
  const notForbid = ops.logicalOr(notRejRow, notChosenCol);
  let allow = ops.logicalAnd(causal, notForbid); // [T,T] bool

  if (window !== null) {
    const logposArr = new Int32Array(T);
    for (let i = 0; i < T; i++) logposArr[i] = i < P + Rc ? i : i - Rc;
    const logpos = MlxArray.fromInt32(logposArr, [T]);
    const lrow = ops.reshape(logpos, [T, 1]);
    const lcol = ops.reshape(logpos, [1, T]);
    const dist = ops.sub(lrow, lcol); // logpos[row] - logpos[col] (>=0 wherever causal allows)
    const w = ops.fromInt32([window], []);
    const slidingOK = ops.less(dist, w); // attend only within `window` logical positions
    const next = ops.logicalAnd(allow, slidingOK);
    allow.dispose();
    allow = next;
    for (const a of [logpos, lrow, lcol, dist, w, slidingOK]) a.dispose();
  }

  for (const a of [causal, idxFlat, row, col, pp, pRc, notRejRow, colLtP, colGePRc, notChosenCol, notForbid]) a.dispose();
  return allow;
}

/** Stateless pass-through cache (offset 0, like TrainingCache) for the
 *  prefix-shared forward over the concat [prompt(P); chosen(Rc); rejected(Rr)]:
 *  its window read takes exactly the concat's T positions under the
 *  block-sparse mask (`blockSparsePrefixMask`) for the cache's sliding window,
 *  attended with `attention`. The caches of one pass share `masks`, so each
 *  window's mask is built once per pass, across its layers, segments and
 *  backward recomputes. A decode read is not defined over a concat; it reads as
 *  the window does and refuses anything but the whole concat. */
export class PrefixSharedCache implements TrainingAttentionCache {
  /** Training-only adapter; never admitted, merged, or persisted. */
  signature(): string { return "train:prefix-shared"; }
  offset = 0;
  constructor(
    private readonly layout: PrefixLayout,
    /** The layer's sliding window, on logical positions; null for full attention. */
    readonly window: number | null = null,
    /** The per-pass masks of the model this cache belongs to. */
    readonly masks = new AttentionMasks(),
    /** The kernel this cache's reads attend with. */
    readonly attention: TrainingAttention = "sdpa",
  ) {}
  /** The concat's block positions: the prompt from 0, each response restarted at P. */
  ropePositions(x: MlxArray, rope: (block: MlxArray, offset: number) => MlxArray): MlxArray {
    return ropeBlocks(x, this.layout, rope);
  }
  appendDecode(k: MlxArray, v: MlxArray): AttentionRead { return this.appendWindow(k, v); }
  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    const { P, Rc, Rr } = this.layout, N = k.shape[2]!;
    if (N !== P + Rc + Rr) throw new Error(`PrefixSharedCache: N=${N} != P+Rc+Rr=${P + Rc + Rr}`);
    const mask = this.masks.lease(`prefix-shared:${this.window}`, `${P},${Rc},${Rr}`,
      () => ({ mode: "array", arr: blockSparsePrefixMask(this.layout, this.window) }));
    return trainingRead(k, v, mask, this.attention, this.window);
  }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void { /* offset pinned at 0 */ }
  dispose(): void { this.masks.clear(); }
}

/** Prefix-shared caches for one pass, one per entry of `windows` (each layer's
 *  sliding window, or null), sharing one set of masks and attending with
 *  `attention`. */
export function prefixSharedCaches(layout: PrefixLayout, windows: readonly (number | null)[],
  attention: TrainingAttention = "sdpa"): Cache[] {
  const masks = new AttentionMasks();
  return windows.map(window => new PrefixSharedCache(layout, window, masks, attention));
}

/** The stateless stand-in a training or scoring forward runs in place of one
 * of the graph's fresh caches: recurrent state takes `TrainingSSMCache` (fixed
 * size and causal, so right padding never reaches a real position and needs no
 * mask); an attention cache takes `attention(window)`, the caller's stand-in
 * over that cache's sliding window (its ring size; null for full attention). */
export function trainingStandIn(cache: Cache, attention: (window: number | null) => Cache): Cache {
  if (isRecurrentCache(cache)) return new TrainingSSMCache();
  const maxSize = (cache as { maxSize?: number }).maxSize;
  return attention(typeof maxSize === "number" ? maxSize : null);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.TrainingCache
