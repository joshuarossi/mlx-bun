// Sampling — port of mlx-lm's sample_utils.make_sampler /
// make_logits_processors (temperature, top-p, top-k, min-p, XTC,
// repetition/presence/frequency penalties, logit bias).
// All filtering happens on-device; only the chosen token id crosses to JS.
// Seeded: each step derives a fresh key from (seed, step) so runs are
// reproducible without sharing global RNG state. (mlx-lm draws XTC's
// uniform and the categorical from one global stream; we split the
// per-step key into (xtc, categorical) subkeys instead — deterministic,
// and the XTC-off path is unchanged.)

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

function negInfLike(a: MlxArray): MlxArray {
  return ops.scalarLike(-Infinity, a);
}

/** apply_top_p: keep the smallest set of tokens whose cumulative
 *  probability exceeds top_p; others → -inf. */
export function applyTopP(lp: MlxArray, topP: number): MlxArray {
  const probs = ops.exp(lp);
  const sortedIdx = ops.argsortAxis(lp, -1);
  const sortedProbs = ops.takeAlongAxis(probs, sortedIdx, -1);
  const cum = ops.cumsum(sortedProbs, -1);
  // scatter arange back through sortedIdx to invert the permutation
  const V = lp.shape[lp.shape.length - 1]!;
  const zerosIdx = ops.zeros(sortedIdx.shape, sortedIdx.dtype);
  const ar = ops.arange(0, V, 1, sortedIdx.dtype);
  const arB = ops.reshape(ar, sortedIdx.shape);
  const inverse = ops.putAlongAxis(zerosIdx, sortedIdx, arB, -1);
  const cumOrig = ops.takeAlongAxis(cum, inverse, -1);
  const threshold = ops.scalarLike(1 - topP, cumOrig);
  const keep = ops.less(threshold, cumOrig); // cum > 1 - topP
  const ninf = negInfLike(lp);
  const out = ops.where(keep, lp, ninf);
  for (const a of [probs, sortedIdx, sortedProbs, cum, zerosIdx, ar, arB, inverse, cumOrig, threshold, keep, ninf])
    a.dispose();
  return out;
}

/** apply_top_k: all but the k highest logprobs → -inf. */
export function applyTopK(lp: MlxArray, topK: number): MlxArray {
  const V = lp.shape[lp.shape.length - 1]!;
  const negLp = ops.neg(lp);
  const part = ops.argpartitionAxis(negLp, topK - 1, -1);
  const maskIdx = part.slice([0, topK], [1, V]);
  const ninf = negInfLike(lp);
  const out = ops.putAlongAxis(lp, maskIdx, ninf, -1);
  for (const a of [negLp, part, maskIdx, ninf]) a.dispose();
  return out;
}

/** apply_min_p: mask tokens whose probability is below minP · p(top token).
 *  Faithful to the reference (mlx-lm 0.31.3 sample_utils.apply_min_p): the
 *  threshold is computed in log space directly against the max logprob —
 *  `scaled_min_p = max(lp) + log(minP)` — no full sort; min_tokens_to_keep
 *  survivors are recovered with an argpartition on the top tail. */
export function applyMinP(lp: MlxArray, minP: number, minTokensToKeep = 1): MlxArray {
  if (!(minP >= 0 && minP <= 1))
    throw new Error(`minP has to be a float in the [0, 1] interval, but is ${minP}`);
  if (!Number.isInteger(minTokensToKeep) || minTokensToKeep < 1)
    throw new Error(`minTokensToKeep has to be a positive integer, but is ${minTokensToKeep}`);

  const owned: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => { owned.push(a); return a; };

  // Mask tokens that have a probability less than max(p) * min_p
  const top = k(ops.maxAxis(lp, -1, true));
  const scaledMinP = k(ops.add(top, k(ops.scalarLike(Math.log(minP), top))));
  let remove = k(ops.less(lp, scaledMinP));

  // Ensure at least min_tokens_to_keep survive the filter
  if (minTokensToKeep > 1) {
    const V = lp.shape[lp.shape.length - 1]!;
    // mx.argpartition(lp, kth=-min_tokens_to_keep): negative kth ≡ V - k
    const part = k(ops.argpartitionAxis(lp, V - minTokensToKeep, -1));
    const topIdx = k(part.slice([0, V - minTokensToKeep], [1, V]));
    const falses = k(ops.zeros([1, minTokensToKeep], Dtype.bool));
    remove = k(ops.putAlongAxis(remove, topIdx, falses, -1));
  }

  const ninf = k(negInfLike(lp));
  const out = ops.where(remove, ninf, lp);
  for (const a of owned) a.dispose();
  return out;
}

/** apply_xtc: with probability xtcProbability, remove every token whose
 *  probability exceeds the minimum above-threshold probability — i.e. drop
 *  the top choices, keeping the least likely token that still clears the
 *  threshold (plus everything below it). Special tokens are never removed.
 *  `key` seeds the per-step uniform draw (the reference uses the global RNG). */
export function applyXtc(
  logits: MlxArray,
  xtcProbability: number,
  xtcThreshold: number,
  xtcSpecialTokens: number[],
  key: MlxArray | null,
): MlxArray {
  if (!(xtcThreshold >= 0 && xtcThreshold <= 0.5))
    throw new Error(`xtcThreshold has to be a float in the [0, 0.5] interval, but is ${xtcThreshold}`);
  if (!(xtcProbability >= 0 && xtcProbability <= 1))
    throw new Error(`xtcProbability has to be a float in the [0, 1] interval, but is ${xtcProbability}`);

  const owned: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => { owned.push(a); return a; };

  const probs = k(ops.softmaxAxis(logits, -1, false));
  // mask = probs > min(where(probs > threshold, probs, inf))
  const thresh = k(ops.scalarLike(xtcThreshold, probs));
  const above = k(ops.less(thresh, probs)); // probs > threshold
  const inf = k(ops.scalarLike(Infinity, probs));
  const aboveProbs = k(ops.where(above, probs, inf));
  // min(x) = -max(-x) (no min reduction in the ops layer)
  const minAbove = k(ops.neg(k(ops.maxAxis(k(ops.neg(aboveProbs)), -1, true))));
  let mask = k(ops.less(minAbove, probs)); // probs > min above-threshold prob
  if (xtcSpecialTokens.length > 0) {
    const n = xtcSpecialTokens.length;
    const idx = k(ops.fromInt32(xtcSpecialTokens, [1, n]));
    const falses = k(ops.zeros([1, n], Dtype.bool));
    mask = k(ops.putAlongAxis(mask, idx, falses, -1));
  }

  // where(uniform() > xtcProbability, logits, where(mask, -inf, logits))
  const u = k(ops.randomUniform([1], Dtype.float32, 0, 1, key));
  const pArr = k(ops.scalarLike(xtcProbability, u));
  const skip = k(ops.less(pArr, u)); // u > xtcProbability → leave logits alone
  const ninf = k(negInfLike(logits));
  const culled = k(ops.where(mask, ninf, logits));
  const out = ops.where(skip, logits, culled);
  for (const a of owned) a.dispose();
  return out;
}
