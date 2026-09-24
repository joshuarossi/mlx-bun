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
import * as ops from "@mlx-bun/mlx/ops";
import { LogitsProcessor,LogitsProcessorOptions } from "./types";

/** Start of the recent-token window, matching Python's `tokens[-context_size:]`
 *  slice semantics exactly (context_size 0 ⇒ `[-0:]` ⇒ the WHOLE history). */
function windowStart(n: number, contextSize: number): number {
  return contextSize === 0 ? 0 : Math.max(0, n - contextSize);
}

/** Retain only tokens an enabled processor can inspect. Bias uses no history.
 * Zero-sized windows mean unlimited history, matching Python's [-0:]. */
export function logitsHistoryLimit(options: LogitsProcessorOptions): number {
  let limit = 0;
  for (const [penalty, context = 20] of [
    [options.repetitionPenalty, options.repetitionContextSize],
    [options.presencePenalty, options.presenceContextSize],
    [options.frequencyPenalty, options.frequencyContextSize],
  ]) {
    if (penalty === undefined || penalty === 0) continue;
    // Preserve existing processor behavior for unusual programmatic values.
    if (!Number.isSafeInteger(context) || context <= 0) return Infinity;
    limit = Math.max(limit, context);
  }
  return limit;
}

export function makeLogitsProcessors(opts: LogitsProcessorOptions = {}): LogitsProcessor[] {
  const out: LogitsProcessor[] = [];
  const {
    logitBias,
    repetitionPenalty, repetitionContextSize = 20,
    presencePenalty, presenceContextSize = 20,
    frequencyPenalty, frequencyContextSize = 20,
  } = opts;

  // logit_bias first, as in mlx-lm's make_logits_processors. Reference:
  // `logits.at[:, indices].add(values)` — dict keys are unique, so a
  // gather → add → put round-trip is exactly equivalent to the scatter-add.
  const biasIds = logitBias ? Object.keys(logitBias).map(Number) : [];
  if (logitBias && biasIds.length > 0) {
    const biasVals = Float32Array.from(biasIds.map((id) => logitBias[id]!));
    out.push((_tokens, logits) => {
      const K = biasIds.length;
      const idx = ops.fromInt32(biasIds, [1, K]);
      const vals32 = MlxArray.fromFloat32(biasVals, [1, K]);
      const vals = vals32.astype(logits.dtype);
      const selected = ops.takeAlongAxis(logits, idx, -1);
      const biased = ops.add(selected, vals);
      const updated = ops.putAlongAxis(logits, idx, biased, -1);
      for (const a of [idx, vals32, vals, selected, biased]) a.dispose();
      return updated;
    });
  }

  if (repetitionPenalty !== undefined && repetitionPenalty !== 0) {
    if (repetitionPenalty < 0)
      throw new Error("repetitionPenalty must be non-negative");
    out.push((tokens, logits) => {
      if (!tokens) return logits;
      const n = tokens.shape[0]!;
      if (n === 0) return logits;
      const start = windowStart(n, repetitionContextSize);
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

  // make_presence_penalty: `logits[:, tokens] -= penalty` — a plain
  // fancy-index assignment, so duplicate occurrences all write the SAME
  // value (original − penalty): the penalty applies once per distinct token.
  if (presencePenalty !== undefined && presencePenalty !== 0) {
    out.push((tokens, logits) => {
      if (!tokens) return logits;
      const n = tokens.shape[0]!;
      if (n === 0) return logits;
      const start = windowStart(n, presenceContextSize);
      const recent = tokens.slice([start], [n]);
      const idx = ops.reshape(recent, [1, n - start]);
      const selected = ops.takeAlongAxis(logits, idx, -1);
      const pen = ops.scalarLike(presencePenalty, selected);
      const penalized = ops.sub(selected, pen);
      const updated = ops.putAlongAxis(logits, idx, penalized, -1);
      for (const a of [recent, idx, selected, pen, penalized]) a.dispose();
      return updated;
    });
  }

  // make_frequency_penalty: `logits.at[:, tokens].subtract(penalty)` — a
  // scatter-subtract that ACCUMULATES over duplicates: each token loses
  // penalty × (occurrence count in the window). We compute the count per
  // position ([m,m] equality matrix summed over a row — m ≤ contextSize, tiny)
  // so every duplicate writes the identical final value and a put_along_axis
  // reproduces the scatter-accumulate exactly.
  if (frequencyPenalty !== undefined && frequencyPenalty !== 0) {
    out.push((tokens, logits) => {
      if (!tokens) return logits;
      const n = tokens.shape[0]!;
      if (n === 0) return logits;
      const start = windowStart(n, frequencyContextSize);
      const m = n - start;
      const recent = tokens.slice([start], [n]);
      const col = ops.reshape(recent, [m, 1]);
      const idx = ops.reshape(recent, [1, m]);
      const eq = ops.equal(col, idx); // [m, m]
      const counts = ops.sumAxis(eq, -1, false); // [m] occurrences of tokens[i]
      const countsF = counts.astype(logits.dtype);
      const countsRow = ops.reshape(countsF, [1, m]);
      const selected = ops.takeAlongAxis(logits, idx, -1);
      const pen = ops.scalarLike(frequencyPenalty, selected);
      const penTotal = ops.mul(countsRow, pen); // penalty × count
      const penalized = ops.sub(selected, penTotal);
      const updated = ops.putAlongAxis(logits, idx, penalized, -1);
      for (const a of [recent, col, idx, eq, counts, countsF, countsRow, selected, pen, penTotal, penalized])
        a.dispose();
      return updated;
    });
  }

  return out;
}
