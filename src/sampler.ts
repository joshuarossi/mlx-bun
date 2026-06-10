// Sampling — port of mlx-lm's sample_utils.make_sampler /
// make_logits_processors (temperature, top-p, top-k, repetition penalty).
// All filtering happens on-device; only the chosen token id crosses to JS.
// Seeded: each step derives a fresh key from (seed, step) so runs are
// reproducible without sharing global RNG state.

import { Dtype } from "./mlx/ffi";
import { MlxArray } from "./mlx/array";
import * as ops from "./mlx/ops";

export interface SamplerOptions {
  temperature?: number;
  topP?: number;
  topK?: number;
  seed?: number;
}

export interface LogitsProcessorOptions {
  repetitionPenalty?: number;
  repetitionContextSize?: number;
}

/** logprobs [1, V] → sampled token array (uint32, shape [1]). */
export type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

/** (deviceTokens [n] | null, logits [1, V]) → logits [1, V]. */
export type LogitsProcessor = (tokens: MlxArray | null, logits: MlxArray) => MlxArray;

const GOLDEN = 0x9e3779b97f4a7c15n;

function stepKey(seed: number, step: number): MlxArray {
  const mixed = (BigInt(seed) ^ ((BigInt(step) + 1n) * GOLDEN)) & 0xffffffffffffffffn;
  return ops.randomKey(mixed);
}

function negInfLike(a: MlxArray): MlxArray {
  return ops.scalarLike(-Infinity, a);
}

/** apply_top_p: keep the smallest set of tokens whose cumulative
 *  probability exceeds top_p; others → -inf. */
function applyTopP(lp: MlxArray, topP: number): MlxArray {
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
function applyTopK(lp: MlxArray, topK: number): MlxArray {
  const V = lp.shape[lp.shape.length - 1]!;
  const negLp = ops.neg(lp);
  const part = ops.argpartitionAxis(negLp, topK - 1, -1);
  const maskIdx = part.slice([0, topK], [1, V]);
  const ninf = negInfLike(lp);
  const out = ops.putAlongAxis(lp, maskIdx, ninf, -1);
  for (const a of [negLp, part, maskIdx, ninf]) a.dispose();
  return out;
}

export function makeSampler(opts: SamplerOptions = {}): Sampler {
  const { temperature = 0, topP = 0, topK = 0, seed = 0 } = opts;

  if (temperature === 0)
    return (lp) => ops.argmaxAxis(lp, -1);

  return (lp, step) => {
    let cur = lp;
    const owned: MlxArray[] = [];
    if (topP > 0 && topP < 1) { cur = applyTopP(cur, topP); owned.push(cur); }
    if (topK > 0) { cur = applyTopK(cur, topK); owned.push(cur); }
    const scaled = ops.mulScalar(cur, 1 / temperature);
    const key = stepKey(seed, step);
    const tok = ops.randomCategorical(scaled, key);
    scaled.dispose();
    key.dispose();
    for (const a of owned) a.dispose();
    return tok;
  };
}

export function makeLogitsProcessors(opts: LogitsProcessorOptions = {}): LogitsProcessor[] {
  const out: LogitsProcessor[] = [];
  const { repetitionPenalty, repetitionContextSize = 20 } = opts;

  if (repetitionPenalty && repetitionPenalty !== 0) {
    if (repetitionPenalty < 0)
      throw new Error("repetitionPenalty must be non-negative");
    out.push((tokens, logits) => {
      if (!tokens) return logits;
      const n = tokens.shape[0]!;
      if (n === 0) return logits;
      const start = Math.max(0, n - repetitionContextSize);
      const recent = tokens.slice([start], [n]);
      const idx = ops.reshape(recent, [1, n - start]);
      const selected = ops.takeAlongAxis(logits, idx, -1);
      const zero = ops.scalarLike(0, selected);
      const isNeg = ops.less(selected, zero);
      const timesP = ops.mulScalar(selected, repetitionPenalty);
      const pen = ops.scalarLike(repetitionPenalty, selected);
      const overP = ops.div(selected, pen);
      const penalized = ops.where(isNeg, timesP, overP);
      const updated = ops.putAlongAxis(logits, idx, penalized, -1);
      for (const a of [recent, idx, selected, zero, isNeg, timesP, pen, overP, penalized])
        a.dispose();
      return updated;
    });
  }
  return out;
}

/** logits [1, V] → logprobs [1, V] (logits - logsumexp). */
export function toLogprobs(logits: MlxArray): MlxArray {
  const lse = ops.logsumexpAxis(logits, -1, true);
  const out = ops.sub(logits, lse);
  lse.dispose();
  return out;
}

export { Dtype };
