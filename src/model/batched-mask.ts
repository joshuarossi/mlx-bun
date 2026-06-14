// Padding-aware attention masks for batched (B>1) serving — decode side.
//
// Companion to src/train/forward.ts's buildBatchedPadMask, which builds the
// PREFILL mask ([B,1,L,L], offset 0, right-padded — the training case, already
// parity-proven by tests/train-batch-e2e.test.ts). This module covers the
// DECODE case for batched serving: left-padded rows sharing one growing
// [B,H,S,D] KV buffer, where a step forwards N new query tokens at a nonzero
// offset. (The two builders should be consolidated when batched prefill is
// wired into the serving path — phase S1a, docs/design/parallel-slots.md.)
//
// Why left-padding for decode: with rows right-aligned in the KV buffer, every
// row's next write lands in the SAME column, so one advancing offset serves
// the whole batch. Each row's RoPE position is still per-row (handled via the
// array-offset path, ropeOffsetArr / ops.ropeDynamic — not here); the only
// thing the mask must encode is (a) causality, (b) each row's left padding,
// and (c) the sliding window, if any.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { createCausalMask, type Cache, type Mask } from "./gemma4-base";

/** Padding-aware key-validity mask for batched DECODE with left-padded rows.
 *
 *  The shared KV buffer has width S (== cache offset once this step's keys are
 *  written). Row b has `leftPad[b]` padding columns on the left, then its real
 *  keys. A step forwards N new query tokens whose absolute positions are
 *  S-N .. S-1 (N == 1 in the steady decode state; N > 1 only for a batched
 *  prefill chunk).
 *
 *  Returns [B, 1, N, S] bool, true where query i of row b may attend to key j:
 *      allow[b,0,i,j] = (j <= S-N+i)            causal (query i at abs pos S-N+i)
 *                       AND (j >= leftPad[b])    key past row b's left padding
 *                       AND (S-N+i < j+window)   within the sliding window*
 *      (*only when windowSize !== null)
 *
 *  Built from createCausalMask(N, S-N, windowSize) (the model's own [N, S] bool
 *  matrix) broadcast over B, AND-ed with a per-row [B,1,1,S] key-validity mask
 *  — exactly mirroring buildBatchedPadMask, but at a decode offset with
 *  left-padding instead of offset-0 right-padding. Caller owns the result. */
export function buildBatchedDecodeMask(
  B: number,
  N: number,
  S: number,
  leftPad: number[],
  windowSize: number | null,
): MlxArray {
  // [N, S] causal(+window): queries at abs positions S-N..S-1, keys 0..S-1.
  const causal2d = createCausalMask(N, S - N, windowSize); // [N, S] bool
  const causal4d = ops.reshape(causal2d, [1, 1, N, S]);
  causal2d.dispose();

  // Per-row key validity: keyValid[b,0,0,j] = j >= leftPad[b]. Build as int32
  // {0,1} then compare to bool, broadcasting over the query axis (i).
  const keyValidData = new Int32Array(B * S);
  for (let b = 0; b < B; b++) {
    const pad = leftPad[b]!;
    for (let j = 0; j < S; j++) keyValidData[b * S + j] = j >= pad ? 1 : 0;
  }
  const keyValidI = MlxArray.fromInt32(keyValidData, [B, 1, 1, S]);
  const zero = MlxArray.fromInt32(new Int32Array([0]), []);
  const keyValid = ops.less(zero, keyValidI); // 0 < x → bool, true where x==1
  zero.dispose();
  keyValidI.dispose();

  const allow = ops.logicalAnd(causal4d, keyValid); // [1,1,N,S] & [B,1,1,S]
  causal4d.dispose();
  keyValid.dispose();
  return allow; // [B, 1, N, S] bool
}

/** Cache wrapper for batched DECODE with left-padded rows. Delegates all KV
 *  storage to a real, shape-[B,H,S,D] cache (KVCache et al. are already
 *  B-generic), but overrides two things the stock single-sequence path gets
 *  wrong for a padded batch:
 *
 *   - `makeMask` returns the per-row left-padding decode mask
 *     (buildBatchedDecodeMask) instead of the stock mask, which is EMPTY at
 *     N==1 and would let every row attend to its own (garbage) left padding.
 *   - `ropeOffsetArr` exposes each row's REAL position (= pre-write offset −
 *     leftPad[b]) as an int32 [B] array, so RoPE is applied per-row via the
 *     array-offset path (mlx fast_rope_dynamic — verified to rotate each row
 *     by its own offset). The scalar offset would mis-position every padded
 *     row by its pad amount.
 *
 *  `leftPad` is fixed for the batch's lifetime (set when the left-padded decode
 *  buffer is assembled from per-row prefills). The position array is recomputed
 *  only when the inner offset advances (once per decode step), so the two reads
 *  within a step (K before updateAndFetch, Q after — see Attention.forward)
 *  return the SAME array; the attention graph holds it until eval, so it must
 *  not be freed mid-step. */
export class BatchedDecodeMaskCache implements Cache {
  #ropeArr: MlxArray | null = null;
  #ropeForOffset = -1;

  constructor(
    private readonly inner: Cache,
    private readonly B: number,
    private readonly leftPad: number[],
    private readonly window: number | null,
  ) {}

  get offset(): number {
    return this.inner.offset;
  }

  get ropeOffsetArr(): MlxArray {
    const off = this.inner.offset;
    if (this.#ropeArr && this.#ropeForOffset === off) return this.#ropeArr;
    this.#ropeArr?.dispose(); // prior step's array; its graph is already evaluated
    const data = new Int32Array(this.B);
    for (let b = 0; b < this.B; b++) data[b] = off - this.leftPad[b]!;
    this.#ropeArr = MlxArray.fromInt32(data, [this.B]);
    this.#ropeForOffset = off;
    return this.#ropeArr;
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return this.inner.updateAndFetch(k, v);
  }

  makeMask(N: number, _windowSize: number | null): Mask {
    // forwardLayers calls makeMask BEFORE this step's updateAndFetch, so the
    // KV the attention then fetches spans inner.offset + N keys. Build a fresh
    // mask each step and hand the model ownership — forwardLayers disposes
    // mask.arr after building the layer graph (mlx refcounts it into the sdpa
    // nodes, so post-build dispose is safe), so no view bookkeeping is needed.
    const S = this.inner.offset + N;
    return { mode: "array", arr: buildBatchedDecodeMask(this.B, N, S, this.leftPad, this.window) };
  }

  state(): MlxArray[] {
    return this.inner.state();
  }
  isTrimmable(): boolean {
    return this.inner.isTrimmable();
  }
  trim(n: number): void {
    this.inner.trim(n);
  }
  dispose(): void {
    this.inner.dispose();
    this.#ropeArr?.dispose();
    this.#ropeArr = null;
  }
}
