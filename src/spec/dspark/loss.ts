// DSpark training objective (paper §3.3, Eq 9–12).
//
//   L = α_ce·L_ce + α_tv·L_tv + α_conf·L_conf      (defaults 0.1 / 0.9 / 1.0)
//
// all three position-weighted by w_k = exp(−(k−1)/γ) (emphasizes earlier
// block positions, which contribute most to prefix-based accepted length):
//
//   L_ce   = −Σ_k w_k · log p^d_k(x*_k)                       (Eq 9)
//   L_tv   =  Σ_k w_k · ‖p^d_k − p^t_k‖₁                       (Eq 10)
//   L_conf = −Σ_k w_k · [ c*_k·log c_k + (1−c*_k)·log(1−c_k) ] (Eq 11)
//
// where the analytic acceptance label c*_k = 1 − ½‖p^d_k − p^t_k‖₁ (Eq 8) is
// STOP-GRADIENT'd — it supervises the confidence head without leaking BCE
// gradient back into the draft distribution (L_tv already drives p^d→p^t).
//
// p^t is the FROZEN target's true distribution at each block position; the
// caller computes targetLogits = model.logitsFromHidden(targetHidden) (same
// head DSpark drafts with) and passes it as a constant. M = A·γ is small
// (γ≈5–7), so plain MLX materialization is fine; a fused TV kernel (the
// flash-cce vocab-blocked pattern) is only worth porting if measurement
// shows this term bottlenecks — it does not at these sizes.

import { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { DSparkTrainOut } from "./module";

export interface LossWeights {
  ce: number;
  tv: number;
  conf: number;
}

export const DEFAULT_LOSS_WEIGHTS: LossWeights = { ce: 0.1, tv: 0.9, conf: 1.0 };

/** Position weights w_k = exp(−(k−1)/γ) as a [1, γ] float32 row. */
export function positionWeights(gamma: number): MlxArray {
  const w = new Float32Array(gamma);
  for (let j = 0; j < gamma; j++) w[j] = Math.exp(-j / gamma);
  return MlxArray.fromFloat32(w, [1, gamma]).eval();
}

/** mean_A( Σ_k w_k · perPos[A,k] ) → scalar. */
function weightedReduce(perPos: MlxArray, w: MlxArray): MlxArray {
  const A = perPos.shape[0]!;
  const weighted = ops.mul(perPos, w); // [A,γ] · [1,γ] broadcast
  const overK = ops.sumAxis(weighted, 1, false); // [A]
  weighted.dispose();
  const summed = ops.sumAxis(overK, 0, false); // scalar
  overK.dispose();
  const out = ops.mulScalar(summed, 1 / A);
  summed.dispose();
  return out;
}

/** Per-position L1 distance ‖p^d − p^t‖₁ → [A, γ]. Caller owns the result. */
function l1PerPos(pd: MlxArray, pt: MlxArray): MlxArray {
  const diff = ops.sub(pd, pt);
  const ad = ops.abs(diff);
  diff.dispose();
  const l1 = ops.sumAxis(ad, 2, false); // [A,γ]
  ad.dispose();
  return l1;
}

/**
 * Full DSpark loss. Returns the scalar to differentiate plus the three term
 * scalars (for logging — they share the graph; read them with .toFloat32()
 * AFTER the backward, or eval them alongside the value).
 *
 *  - out.draftLogits [A,γ,V] (U+B, pre-softmax, float32)
 *  - out.conf        [A,γ]   (sigmoid output ∈ (0,1))
 *  - targetLogits    [A,γ,V] (frozen target logits; constant)
 *  - xStar           [A,γ]   int32 ground-truth next tokens
 */
export function dsparkLoss(
  out: DSparkTrainOut,
  targetLogits: MlxArray,
  xStar: MlxArray,
  gamma: number,
  w: MlxArray,
  weights: LossWeights = DEFAULT_LOSS_WEIGHTS,
): { loss: MlxArray; ce: MlxArray; tv: MlxArray; conf: MlxArray } {
  const dl = out.draftLogits; // [A,γ,V]
  const A = dl.shape[0]!;

  const pd = ops.softmaxAxis(dl, 2, true); // [A,γ,V]
  const ptRaw = ops.softmaxAxis(targetLogits, 2, true);
  const pt = ops.stopGradient(ptRaw); // target is constant
  ptRaw.dispose();

  // --- L_ce: −log p^d(x*) ---
  const lse = ops.logsumexpAxis(dl, 2, true); // [A,γ,1]
  const logp = ops.sub(dl, lse); // [A,γ,V]
  lse.dispose();
  const xsIdx = ops.expandDims(xStar, 2); // [A,γ,1] int32
  const logpStar = ops.takeAlongAxis(logp, xsIdx, 2); // [A,γ,1]
  logp.dispose(); xsIdx.dispose();
  const cePos0 = ops.reshape(logpStar, [A, gamma]); // [A,γ]
  logpStar.dispose();
  const cePos = ops.neg(cePos0); // −log p^d(x*)
  cePos0.dispose();
  const ceTerm = weightedReduce(cePos, w);
  cePos.dispose();

  // --- L1 / TV / c* (share the L1) ---
  const l1 = l1PerPos(pd, pt); // [A,γ]
  pd.dispose(); pt.dispose();
  const tvTerm = weightedReduce(l1, w);

  // c*_k = 1 − ½·l1, stop-gradient (supervision label)
  const half = ops.mulScalar(l1, 0.5);
  const cStarRaw = rsubScalar(half, 1.0); // 1 − ½l1
  half.dispose();
  const cStar = ops.stopGradient(cStarRaw);
  cStarRaw.dispose();
  l1.dispose();

  // --- L_conf: BCE(c, c*) ---
  const eps = 1e-6;
  const c = clampUnit(out.conf, eps);
  const omc = rsubScalar(c, 1.0); // 1 − c
  const logc = ops.log(c);
  const log1mc = ops.log(omc);
  c.dispose(); omc.dispose();
  const t1 = ops.mul(cStar, logc); // c*·log c
  const omcStar = rsubScalar(cStar, 1.0); // 1 − c*
  cStar.dispose(); logc.dispose();
  const t2 = ops.mul(omcStar, log1mc); // (1−c*)·log(1−c)
  omcStar.dispose(); log1mc.dispose();
  const bcePos0 = ops.add(t1, t2);
  t1.dispose(); t2.dispose();
  const bcePos = ops.neg(bcePos0);
  bcePos0.dispose();
  const confTerm = weightedReduce(bcePos, w);
  bcePos.dispose();

  // --- weighted sum ---
  const a = ops.mulScalar(ceTerm, weights.ce);
  const b = ops.mulScalar(tvTerm, weights.tv);
  const cc = ops.mulScalar(confTerm, weights.conf);
  const ab = ops.add(a, b); a.dispose(); b.dispose();
  const loss = ops.add(ab, cc); ab.dispose(); cc.dispose();
  return { loss, ce: ceTerm, tv: tvTerm, conf: confTerm };
}

/**
 * Held-out monitoring (NO gradient): analytic per-position acceptance
 * a_k = 1 − ½‖p^d_k − p^t_k‖₁ and the expected accepted length
 * τ = 1 + Σ_{j=1}^{γ} Π_{i≤j} a_i (the +1 is the target bonus token). This is
 * the cheap proxy to early-stop on — τ is the number that matters, not loss.
 * Returns means over the batch.
 */
export function analyticAcceptance(
  out: DSparkTrainOut,
  targetLogits: MlxArray,
): { perPos: number[]; tau: number } {
  const dl = out.draftLogits;
  const A = dl.shape[0]!;
  const gamma = dl.shape[1]!;
  const pd = ops.softmaxAxis(dl, 2, true);
  const pt = ops.softmaxAxis(targetLogits, 2, true);
  const l1 = l1PerPos(pd, pt); // [A,γ]
  pd.dispose(); pt.dispose();
  const half = ops.mulScalar(l1, 0.5);
  l1.dispose();
  const aMat = rsubScalar(half, 1.0); // [A,γ] = a_k per anchor
  half.dispose();
  const flat = aMat.toFloat32(); // [A*γ]
  aMat.dispose();

  const perPos: number[] = new Array(gamma).fill(0);
  let tauSum = 0;
  for (let row = 0; row < A; row++) {
    let cum = 1;
    let tau = 1; // bonus token
    for (let j = 0; j < gamma; j++) {
      const a = flat[row * gamma + j]!;
      perPos[j]! += a;
      cum *= a;
      tau += cum;
    }
    tauSum += tau;
  }
  for (let j = 0; j < gamma; j++) perPos[j]! /= A;
  return { perPos, tau: tauSum / A };
}

// --- small scalar helpers (no direct rsub/clamp binding) ---------------

/** value − a, elementwise (value + (−a)). */
function rsubScalar(a: MlxArray, value: number): MlxArray {
  const neg = ops.neg(a);
  const res = addScalarF32(neg, value);
  neg.dispose();
  return res;
}

/** a + value (float32). */
function addScalarF32(a: MlxArray, value: number): MlxArray {
  const s = MlxArray.fromFloat32(new Float32Array([value]), [1]);
  const out = ops.add(a, s);
  s.dispose();
  return out;
}

/** clamp x into [eps, 1−eps]. */
function clampUnit(x: MlxArray, eps: number): MlxArray {
  const lo = MlxArray.fromFloat32(new Float32Array([eps]), [1]);
  const hi = MlxArray.fromFloat32(new Float32Array([1 - eps]), [1]);
  const out = ops.clip(x, lo, hi);
  lo.dispose(); hi.dispose();
  return out;
}
