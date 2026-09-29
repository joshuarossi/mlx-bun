import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { createCausalMask } from "../kernels/attention/masks";
import type { Cache, Mask } from "../contracts/mlx/cache";
import type { PrefixLayout } from "../contracts/mlx/trainable";

/** Stateless cache for the training forward. Training is always a single
 *  offset-0 full-sequence pass, so `updateAndFetch` is a pure pass-through (no
 *  buffer, no state mutation) and `makeMask` is the offset-0 causal/windowed
 *  mask — identical to KVCache at offset 0. The statelessness is REQUIRED for
 *  gradient checkpointing: mlx_checkpoint re-runs the layer closure during the
 *  backward recompute, and a stateful (appending) cache would corrupt on the
 *  second run. */
export class TrainingCache implements Cache {
  /** Training-only adapter; never admitted, merged, or persisted. */
  signature(): string { return "train:training"; }
  offset = 0;
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    // Return fresh views: the caller disposes its input k/v right after (its
    // contract with the real KVCache, which returns buffer slices). A
    // full-range slice is a cheap view node; mlx keeps the source alive
    // through it, so disposing the inputs is safe.
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(N: number, windowSize: number | null): Mask {
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
    /* owns no arrays */
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
 *  It also marks the forward as a training forward: a DeltaNet layer reading it
 *  runs its recurrence with a backward attached (`gatedDeltaUpdate`'s
 *  `differentiable`), since the
 *  inference kernel has no gradient. */
export class TrainingSSMCache implements Cache {
  /** Training-only adapter; never admitted, merged, or persisted. */
  signature(): string { return "train:training-ssm"; }
  offset = 0;
  specRound: null = null;
  get conv(): MlxArray | null { return null; }
  set conv(v: MlxArray | null) { v?.dispose(); }
  get recurrent(): MlxArray | null { return null; }
  set recurrent(v: MlxArray | null) { v?.dispose(); }
  advance(_n: number): void { /* offset pinned at 0 */ }
  rowOffset(_i: number): number { return 0; }
  updateAndFetch(): [MlxArray, MlxArray] {
    throw new Error("TrainingSSMCache: DeltaNet layers do not use the KV path");
  }
  makeMask(_N: number, _w: number | null): Mask {
    return { mode: "", arr: null }; // ssm_mask is None at B=1 (SSMCache parity)
  }
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
 *  prefix-shared forward whose `makeMask` returns the block-sparse mask (see
 *  `blockSparsePrefixMask`); a layer type with a sliding window passes it in.
 *
 *  `memo` (shared by `prefixSharedCaches`) builds the unwindowed [T,T] mask once
 *  per step instead of once per layer, segment forward and backward recompute:
 *  makeMask then hands out cheap slice VIEWS (consumers dispose their view) and
 *  the first cache disposed frees the memo. */
export class PrefixSharedCache implements Cache {
  /** Training-only adapter; never admitted, merged, or persisted. */
  signature(): string { return "train:prefix-shared"; }
  offset = 0;
  constructor(
    private readonly layout: PrefixLayout,
    private readonly memo?: { mask: MlxArray | null },
  ) {}
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(N: number, windowSize: number | null): Mask {
    const { P, Rc, Rr } = this.layout;
    if (N !== P + Rc + Rr) throw new Error(`PrefixSharedCache: N=${N} != P+Rc+Rr=${P + Rc + Rr}`);
    if (!this.memo || windowSize !== null) return { mode: "array", arr: blockSparsePrefixMask(this.layout, windowSize) };
    if (!this.memo.mask) this.memo.mask = blockSparsePrefixMask(this.layout, null);
    const m = this.memo.mask;
    return { mode: "array", arr: m.slice([0, 0], m.shape) };
  }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void { /* offset pinned at 0 */ }
  dispose(): void {
    if (this.memo?.mask) { this.memo.mask.dispose(); this.memo.mask = null; }
  }
}

/** `count` prefix-shared caches sharing one block-sparse-mask memo. */
export function prefixSharedCaches(count: number, layout: PrefixLayout): Cache[] {
  const memo: { mask: MlxArray | null } = { mask: null };
  return Array.from({ length: count }, () => new PrefixSharedCache(layout, memo));
}
