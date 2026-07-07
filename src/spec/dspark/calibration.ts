// Threshold calibration for the confidence scheduler — fits per-position
// confidence thresholds from real (confidence, accepted) verify outcomes, so
// the scheduler in module-dflash.ts#forwardInfer prunes positions the
// confidence head can't actually call. Pure math, no MLX/GPU here: the
// caller (scripts/dspark-calibrate.ts) collects samples off a live model via
// dflashGenerate's onRound hook, this module just fits.
//
// VERIFIED vs the paper + reference (2026-07-06 audit, arXiv:2607.05147 +
// github.com/deepseek-ai/DeepSpec): the RELEASED reference schedules exactly
// this way — per-position threshold truncation on sigmoid confidence
// (default 0 = off) — so this calibrator fits the reference-shaped consumer.
// The PAPER's §3.2.1 "STS" is a different mechanism (Sequential Temperature
// Scaling: per-position temperatures by ECE grid search on cumulative
// survival products, feeding Alg-1's throughput-maximizing scheduler with a
// profiled SPS(B) cost table) — that machinery lives in DeepSeek's UNRELEASED
// production serving layer, not in DeepSpec. Paper-faithful STS/Alg-1 is a
// future Lab item; details in docs/design/dspark-speculative-decoding.md
// "DeepSpec ground truth". The isotonic-style "smallest τ meeting a target
// precision, Laplace-smoothed" fit below is ours (the reference ships no
// calibrator at all — raw sigmoid vs a hand-set threshold).

import type { StsCalibration } from "./module-dflash";

/** One verify-time observation: the drafter's predicted confidence at draft
 *  position `pos`, and whether the target ACTUALLY accepted that position
 *  (k < kAccept in the round that produced it). */
export interface ConfSample {
  pos: number;
  conf: number;
  accepted: boolean;
}

/**
 * Fit per-position STS thresholds from observed (conf, accepted) pairs.
 *
 * For each position k, we want the smallest τ_k such that pruning on
 * `conf_k < τ_k` still keeps empirical acceptance precision at or above
 * `target` among the samples that WOULD be kept (conf ≥ τ_k). Smaller τ_k
 * keeps more of the block (better speedup); we want the smallest one that
 * still meets the target, i.e. we scan candidate thresholds from low to
 * high (in the order of observed conf values) and stop at the first that
 * clears the bar.
 *
 * Candidate thresholds are exactly the position's observed conf values
 * (a threshold only ever needs to sit at an observed value — moving it
 * between two observed values changes no sample's keep/drop outcome, so a
 * finer sweep can't do better). Sorted ascending; a candidate τ's precision
 * is P(accepted | conf ≥ τ) over the position's samples, with Laplace
 * (+1 accept, +2 total) smoothing so single-sample / early candidates near
 * the tail can't spike to a false 100%.
 *
 * Edge rules (in priority order):
 *  1. Position 0 → threshold 0. Alg-1 never prunes position 0 anyway (the
 *     scheduler in forwardInfer special-cases `k > 0`), so any fit would be
 *     dead code; 0 documents that explicitly and short-circuits the fit.
 *  2. Fewer than `minSamples` observations at position k → threshold 0
 *     (insufficient evidence: don't prune on a guess).
 *  3. No candidate τ clears `target` (including τ = 1, i.e. "prune always")
 *     → threshold 1.0 (the head can't call this position at all; prune it
 *     unconditionally rather than risk emitting a token the head has no
 *     signal on).
 *  4. Otherwise → the smallest candidate τ meeting the target.
 *
 * Pure and deterministic: same `samples` array (any order) → same output,
 * since scoring only depends on the multiset of (conf, accepted) pairs per
 * position, and ties in conf sort stably by value (order-independent).
 */
export function fitStsThresholds(
  samples: ConfSample[],
  gamma: number,
  target = 0.5,
  minSamples = 50,
): StsCalibration {
  const byPos: ConfSample[][] = Array.from({ length: gamma }, () => []);
  for (const s of samples) {
    // Non-finite conf would poison the fit: a NaN candidate τ makes every
    // `conf >= τ` comparison false, and the empty keep-set's Laplace
    // precision (0+1)/(0+2)=0.5 clears the default target — serializing NaN
    // (→ null in JSON) into the thresholds. Drop such samples at intake; a
    // NaN-emitting confidence head surfaces via the sample counts instead.
    if (Number.isFinite(s.conf) && s.pos >= 0 && s.pos < gamma) byPos[s.pos]!.push(s);
  }

  const thresholds: number[] = new Array(gamma).fill(0);

  for (let k = 1; k < gamma; k++) {
    const pos = byPos[k]!;
    if (pos.length < minSamples) {
      thresholds[k] = 0; // rule 2 — insufficient evidence, don't prune
      continue;
    }

    // Candidates = observed conf values, ascending (smallest-τ-first scan).
    const cands = pos.map((s) => s.conf).slice().sort((a, b) => a - b);

    let chosen: number | null = null;
    for (const tau of cands) {
      let accept = 0, total = 0;
      for (const s of pos) {
        if (s.conf >= tau) { total++; if (s.accepted) accept++; }
      }
      // Laplace (+1/+2) smoothing: precision = (accept+1)/(total+2).
      const precision = (accept + 1) / (total + 2);
      if (precision >= target) { chosen = tau; break; }
    }

    thresholds[k] = chosen ?? 1.0; // rule 3 if nothing clears the bar
  }
  thresholds[0] = 0; // rule 1 — always, regardless of samples

  return { thresholds, target, samples: samples.length };
}
