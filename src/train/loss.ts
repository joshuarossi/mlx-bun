// Training losses: masked cross-entropy (SFT) and DPO.
//
// SFT — port of mlx_lm/tuner/trainer.py default_loss restricted to B=1:
//   logits = forward(ids[:, :-1]); targets = ids[:, 1:]
//   ce[t]  = logsumexp(logits[t]) - logits[t, targets[t]]
//   loss   = sum(ce * mask) / sum(mask)
// where mask[t] = 1 iff the predicted token (ids[t+1]) is a response token,
// i.e. (t+1) >= promptLen.
//
// DPO — port of optiq/lora/dpo.py: per-sequence response log-prob via
// _seq_logp, reference log-probs computed with the adapter scale forced to 0
// and stop_gradient'd, then L = -log σ(β·((πc-refc) - (πr-refr))).

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import { trainForward } from "./forward";
import { setLoraScale, type TrainableLora } from "./lora-params";
import type { SftBatch, DpoBatch } from "./dataset";

// ---------------------------------------------------------------------------
// SFT
// ---------------------------------------------------------------------------

/** Masked cross-entropy over a single SFT example (B=1).
 *  Returns a scalar MlxArray (caller owns). */
export function sftLoss(model: RuntimeModel, batch: SftBatch): MlxArray {
  const ids = batch.ids[0]!;
  const promptLen = batch.promptLens[0]!;
  const L = ids.length;
  if (L < 2) throw new Error("sftLoss: sequence too short (need >= 2 tokens)");

  // inputs = ids[:-1], targets = ids[1:]
  const inputIds = MlxArray.fromInt32(new Int32Array(ids.slice(0, L - 1)), [1, L - 1]);
  let scalar: MlxArray;
  try {
    const logits = trainForward(model, inputIds); // [1, L-1, V]
    scalar = maskedCe(logits, ids, promptLen);
    logits.dispose();
  } finally {
    inputIds.dispose();
  }
  return scalar;
}

/** Build the masked-CE scalar from full logits [1, L-1, V] and the host ids. */
function maskedCe(logits: MlxArray, ids: number[], promptLen: number): MlxArray {
  const L = ids.length;
  const T = L - 1; // number of prediction positions

  const targetsHost = new Int32Array(T);
  const maskHost = new Float32Array(T);
  let ntoks = 0;
  for (let t = 0; t < T; t++) {
    targetsHost[t] = ids[t + 1]!;
    // predicted token is ids[t+1]; supervised iff it's a response token.
    if (t + 1 >= promptLen) {
      maskHost[t] = 1;
      ntoks++;
    }
  }
  if (ntoks === 0) throw new Error("sftLoss: no response tokens to supervise");

  const logits2d = ops.reshape(logits, [T, logits.shape[2]!]); // [T, V]
  const targets = MlxArray.fromInt32(targetsHost, [T, 1]);
  const mask = MlxArray.fromFloat32(maskHost, [T]);

  // ce[t] = logsumexp(logits[t]) - logits[t, target[t]]
  const lse = ops.logsumexpAxis(logits2d, -1, false); // [T]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [T, 1]
  const picked = ops.reshape(gathered, [T]); // [T]
  const ce = ops.sub(lse, picked); // [T]
  const ceF = ce.dtype === Dtype.float32 ? ce : ce.astype(Dtype.float32);

  const masked = ops.mul(ceF, mask); // [T]
  const sumCe = ops.sumAxis(masked, 0, false); // scalar
  const loss = ops.mulScalar(sumCe, 1 / ntoks); // scalar

  for (const a of [logits2d, targets, mask, lse, gathered, picked, ce, masked, sumCe]) a.dispose();
  if (ceF !== ce) ceF.dispose();
  return loss;
}

// ---------------------------------------------------------------------------
// DPO
// ---------------------------------------------------------------------------

/** Per-sequence sum of response-position log-probs (B=1), port of
 *  dpo.py _seq_logp. `ids`/`mask` are host arrays of equal length L; logits
 *  are [1, L-1, V] (the forward over ids[:-1]). Returns a scalar MlxArray. */
function seqLogp(logits: MlxArray, ids: number[], mask: number[]): MlxArray {
  const L = ids.length;
  const T = L - 1;
  const targetsHost = new Int32Array(T);
  const maskHost = new Float32Array(T);
  for (let t = 0; t < T; t++) {
    targetsHost[t] = ids[t + 1]!;
    maskHost[t] = mask[t + 1]!; // resp_mask[1:]
  }
  const logits2d = ops.reshape(logits, [T, logits.shape[2]!]);
  const targets = MlxArray.fromInt32(targetsHost, [T, 1]);
  const m = MlxArray.fromFloat32(maskHost, [T]);

  const lse = ops.logsumexpAxis(logits2d, -1, false); // [T]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [T,1]
  const picked = ops.reshape(gathered, [T]); // [T]
  const logp = ops.sub(picked, lse); // log_softmax at the label
  const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const masked = ops.mul(logpF, m); // [T]
  const sum = ops.sumAxis(masked, 0, false); // scalar

  for (const a of [logits2d, targets, m, lse, gathered, picked, logp, masked]) a.dispose();
  if (logpF !== logp) logpF.dispose();
  return sum;
}

/** Forward + per-sequence response log-prob for one branch (B=1). */
function branchLogp(model: RuntimeModel, ids: number[], mask: number[]): MlxArray {
  const L = ids.length;
  const inputIds = MlxArray.fromInt32(new Int32Array(ids.slice(0, L - 1)), [1, L - 1]);
  try {
    const logits = trainForward(model, inputIds);
    const lp = seqLogp(logits, ids, mask);
    logits.dispose();
    return lp;
  } finally {
    inputIds.dispose();
  }
}

/** Reference log-probs for a DPO batch: forward with the adapter disabled
 *  (scale 0), materialized + stop_gradient'd so the policy forwards don't
 *  hold the reference activations. Returns detached scalars (caller owns). */
export function dpoRefLogps(
  model: RuntimeModel,
  lora: TrainableLora,
  batch: DpoBatch,
): { refChosen: MlxArray; refRejected: MlxArray } {
  const original = lora.targets[0]?.lw.scale ?? lora.scale;
  setLoraScale(lora, 0);
  try {
    const c = branchLogp(model, batch.chosenIds[0]!, batch.chosenMask[0]!);
    const r = branchLogp(model, batch.rejectedIds[0]!, batch.rejectedMask[0]!);
    ops.evalAll([c, r]); // free reference activations before policy forwards
    const refChosen = ops.stopGradient(c);
    const refRejected = ops.stopGradient(r);
    c.dispose();
    r.dispose();
    return { refChosen, refRejected };
  } finally {
    setLoraScale(lora, original);
  }
}

/** DPO loss for one batch given precomputed reference log-probs. Runs the two
 *  policy forwards (adapter active). Returns a scalar MlxArray (caller owns). */
export function dpoLoss(
  model: RuntimeModel,
  batch: DpoBatch,
  beta: number,
  refChosen: MlxArray,
  refRejected: MlxArray,
): MlxArray {
  const piC = branchLogp(model, batch.chosenIds[0]!, batch.chosenMask[0]!);
  const piR = branchLogp(model, batch.rejectedIds[0]!, batch.rejectedMask[0]!);

  const logrC = ops.sub(piC, refChosen); // πc - refc
  const logrR = ops.sub(piR, refRejected); // πr - refr
  const diff = ops.sub(logrC, logrR);
  const adv = ops.mulScalar(diff, beta); // β·(logrC - logrR), scalar
  // -log σ(adv) = softplus(-adv) = logaddexp(0, -adv)
  const negAdv = ops.neg(adv);
  const zero = ops.scalarLike(0, adv);
  const loss = ops.logaddexp(zero, negAdv); // scalar

  for (const a of [piC, piR, logrC, logrR, diff, adv, negAdv, zero]) a.dispose();
  return loss;
}

/** DPO diagnostics (no grad): loss, accuracy (adv>0), reward margin.
 *  Computes its own reference forwards. All host floats. */
export function dpoMetrics(
  model: RuntimeModel,
  lora: TrainableLora,
  batch: DpoBatch,
  beta: number,
): { loss: number; accuracy: number; margin: number } {
  const { refChosen, refRejected } = dpoRefLogps(model, lora, batch);
  const piC = branchLogp(model, batch.chosenIds[0]!, batch.chosenMask[0]!);
  const piR = branchLogp(model, batch.rejectedIds[0]!, batch.rejectedMask[0]!);

  const logrC = ops.sub(piC, refChosen);
  const logrR = ops.sub(piR, refRejected);
  const diff = ops.sub(logrC, logrR);
  const adv = ops.mulScalar(diff, beta);
  const negAdv = ops.neg(adv);
  const zero = ops.scalarLike(0, adv);
  const loss = ops.logaddexp(zero, negAdv);

  const advVal = adv.toFloat32()[0]!;
  const lossVal = loss.toFloat32()[0]!;

  for (const a of [refChosen, refRejected, piC, piR, logrC, logrR, diff, adv, negAdv, zero, loss]) a.dispose();
  return { loss: lossVal, accuracy: advVal > 0 ? 1 : 0, margin: advVal };
}
