// Row-batched top-p / top-k filtering for a verify window.
//
// The accept walk samples every position of a speculative window. Each position
// runs the same filter chain over the full vocabulary: exp, argsort, gather,
// cumsum, inverse permutation, compare (top-p), then argpartition and a scatter
// (top-k). Done per position that is W independent chains of full-vocabulary
// kernels. Every one of those ops is row-wise along the last axis, so the chain
// over [W, V] computes each row with the same arithmetic as the [1, V] chain.
// Only the FILTERS batch: each row is still drawn separately with its own step
// key on a [1, V] slice, because MLX's categorical takes its inverse-CDF path
// only for that shape, and the draft is coupled to exactly that draw.
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

function negInfLike(a: MlxArray): MlxArray {
  return ops.scalarLike(-Infinity, a);
}

/** apply_top_p over rows: logprobs [W, V] -> logprobs with the tail at -inf. */
export function applyTopPRows(lp: MlxArray, topP: number): MlxArray {
  const V = lp.shape[1]!;
  using probs = ops.exp(lp);
  using sortedIdx = ops.argsortAxis(lp, -1);
  using sortedProbs = ops.takeAlongAxis(probs, sortedIdx, -1);
  using cum = ops.cumsum(sortedProbs, -1);
  using zerosIdx = ops.zeros(sortedIdx.shape, sortedIdx.dtype);
  using ar = ops.arange(0, V, 1, sortedIdx.dtype);
  using arRow = ops.reshape(ar, [1, V]);
  using arRows = ops.add(zerosIdx, arRow); // integer broadcast: exact
  using inverse = ops.putAlongAxis(zerosIdx, sortedIdx, arRows, -1);
  using cumOrig = ops.takeAlongAxis(cum, inverse, -1);
  using threshold = ops.scalarLike(1 - topP, cumOrig);
  using keep = ops.less(threshold, cumOrig);
  using ninf = negInfLike(lp);
  return ops.where(keep, lp, ninf);
}

/** apply_top_k over rows: all but each row's k highest logprobs -> -inf. */
export function applyTopKRows(lp: MlxArray, topK: number): MlxArray {
  const [W, V] = lp.shape as [number, number];
  using negLp = ops.neg(lp);
  using part = ops.argpartitionAxis(negLp, topK - 1, -1);
  using maskIdx = part.slice([0, topK], [W, V]);
  using ninf = negInfLike(lp);
  return ops.putAlongAxis(lp, maskIdx, ninf, -1);
}
