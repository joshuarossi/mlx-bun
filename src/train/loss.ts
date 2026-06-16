// Training losses: masked cross-entropy (SFT) and DPO.
//
// SFT — port of mlx_lm/tuner/trainer.py default_loss:
//   logits = forward(ids[:, :-1]); targets = ids[:, 1:]
//   ce[b,t]  = logsumexp(logits[b,t]) - logits[b,t, targets[b,t]]
//   mask[b,t] = 1 iff position predicts a response token that is NOT padding,
//               i.e. (t+1) >= promptLen[b]  AND  (t+1) < length[b]
//   loss = sum(ce * mask) / sum(mask)   (token-mean over the whole batch)
// For B=1 with no padding this reduces to exactly the original single-example
// loss (mask[t] = (t+1) >= promptLen, length == ids.length).
//
// DPO — port of optiq/lora/dpo.py: per-sequence response log-prob via
// _seq_logp, reference log-probs computed with the adapter scale forced to 0
// and stop_gradient'd, then L = -log σ(β·((πc-refc) - (πr-refr))) averaged
// over the batch. Padding never contributes: the response mask is 0 at pad
// positions and the batched attention mask hides padded keys.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import { trainForward, trainForwardHidden } from "./forward";
import { setLoraScale, type TrainableLora } from "./lora-params";
import {
  rowLength, dpoChosenLength, dpoRejectedLength,
  type SftBatch, type DpoBatch,
} from "./dataset";

// ---------------------------------------------------------------------------
// SFT
// ---------------------------------------------------------------------------

/** Masked cross-entropy over an SFT batch (B>=1).
 *  Returns a scalar MlxArray (caller owns).
 *
 *  Every row is padded to the batch length L. The forward runs over
 *  ids[:, :-1] (a single [B, L-1] pass) with a padding-aware attention mask;
 *  the loss mask then keeps only (response AND non-padding) target positions.
 *  Loss = sum(ce·mask) / sum(mask) — a token-mean over the whole batch, the
 *  same reduction as mlx-lm default_loss. */
export function sftLoss(model: RuntimeModel, batch: SftBatch): MlxArray {
  const B = batch.ids.length;
  const L = batch.ids[0]!.length;
  if (L < 2) throw new Error("sftLoss: sequence too short (need >= 2 tokens)");
  for (let b = 0; b < B; b++)
    if (batch.ids[b]!.length !== L)
      throw new Error("sftLoss: all rows in a batch must share length L (pad first)");

  // inputs = ids[:, :-1]  (flatten row-major into [B, L-1]).
  const T = L - 1;
  const inputHost = new Int32Array(B * T);
  for (let b = 0; b < B; b++)
    for (let t = 0; t < T; t++) inputHost[b * T + t] = batch.ids[b]![t]!;
  const inputIds = MlxArray.fromInt32(inputHost, [B, T]);

  // Per-input-row valid length = min(rowLength, L) - 1 (inputs dropped the
  // last token). Keys beyond this are padding and must not be attended.
  const inputValid = Array.from({ length: B }, (_, b) =>
    Math.max(0, Math.min(rowLength(batch, b), L) - 1),
  );

  let scalar: MlxArray;
  try {
    if (B === 1) {
      // Response-only path: run the forward to hidden states, then apply the
      // LM head ONLY at supervised positions. Avoids the [1, T, 262k] logits
      // (+ its grad) — the dominant long-context training-memory term.
      const h = trainForwardHidden(model, inputIds, inputValid); // [1, T, hidden]
      scalar = responseOnlyCe(model, h, batch);
      h.dispose();
    } else {
      const logits = trainForward(model, inputIds, inputValid); // [B, T, V]
      scalar = maskedCe(logits, batch);
      logits.dispose();
    }
  } finally {
    inputIds.dispose();
  }
  return scalar;
}

/** B=1 masked CE that applies the LM head only at the supervised (response)
 *  span. The supervised input positions are the contiguous range
 *  [promptLen-1, len-1) (each predicts the next, response, token). The LM head
 *  is position-independent and prompt positions get zero loss weight, so this
 *  is numerically identical to maskedCe for B=1 — but it never materializes
 *  logits at prompt positions. Gradients to prompt-position LoRA params still
 *  flow: the response hidden states depend on the prompt through causal
 *  attention, which is fully captured upstream in `h`. */
export function responseOnlyCe(model: RuntimeModel, h: MlxArray, batch: SftBatch): MlxArray {
  const L = batch.ids[0]!.length;
  const promptLen = batch.promptLens[0]!;
  const len = Math.min(rowLength(batch, 0), L);
  const startT = Math.max(0, promptLen - 1); // first supervised input position
  const M = (len - 1) - startT; // # supervised positions (predict ids[startT+1 .. len-1])
  if (M <= 0) throw new Error("sftLoss: no response tokens to supervise");

  // h[:, startT : startT+M, :]  → [1, M, hidden]  (sliceSize is the full output shape)
  const hidden = h.shape[2]!;
  const start = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hResp = ops.sliceDynamic(h, start, [1], [1, M, hidden]);
  const logits = model.logitsFromHidden(hResp); // [1, M, V]
  const V = logits.shape[2]!;
  const logits2d = ops.reshape(logits, [M, V]);

  const targetsHost = new Int32Array(M);
  for (let i = 0; i < M; i++) targetsHost[i] = batch.ids[0]![startT + 1 + i]!;
  const targets = MlxArray.fromInt32(targetsHost, [M, 1]);

  const lse = ops.logsumexpAxis(logits2d, -1, false); // [M]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [M, 1]
  const picked = ops.reshape(gathered, [M]); // [M]
  const ce = ops.sub(lse, picked); // [M]
  const ceF = ce.dtype === Dtype.float32 ? ce : ce.astype(Dtype.float32);
  const sumCe = ops.sumAxis(ceF, 0, false); // scalar
  const loss = ops.mulScalar(sumCe, 1 / M); // token-mean over the response

  for (const a of [start, hResp, logits, logits2d, targets, lse, gathered, picked, ce, sumCe]) a.dispose();
  if (ceF !== ce) ceF.dispose();
  return loss;
}

/** Build the token-mean masked-CE scalar from batched logits [B, T, V]
 *  (T = L-1) and the batch's host ids/boundaries. */
export function maskedCe(logits: MlxArray, batch: SftBatch): MlxArray {
  const B = batch.ids.length;
  const L = batch.ids[0]!.length;
  const T = L - 1;
  const V = logits.shape[2]!;

  const targetsHost = new Int32Array(B * T);
  const maskHost = new Float32Array(B * T);
  let ntoks = 0;
  for (let b = 0; b < B; b++) {
    const promptLen = batch.promptLens[b]!;
    const len = Math.min(rowLength(batch, b), L);
    for (let t = 0; t < T; t++) {
      const flat = b * T + t;
      targetsHost[flat] = batch.ids[b]![t + 1]!;
      // predicted token is ids[t+1]; supervised iff it is a response token
      // (t+1 >= promptLen) AND a real (non-pad) token (t+1 < len).
      if (t + 1 >= promptLen && t + 1 < len) {
        maskHost[flat] = 1;
        ntoks++;
      }
    }
  }
  if (ntoks === 0) throw new Error("sftLoss: no response tokens to supervise");

  const N = B * T;
  const logits2d = ops.reshape(logits, [N, V]); // [B*T, V]
  const targets = MlxArray.fromInt32(targetsHost, [N, 1]);
  const mask = MlxArray.fromFloat32(maskHost, [N]);

  // ce[n] = logsumexp(logits[n]) - logits[n, target[n]]
  const lse = ops.logsumexpAxis(logits2d, -1, false); // [N]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [N, 1]
  const picked = ops.reshape(gathered, [N]); // [N]
  const ce = ops.sub(lse, picked); // [N]
  const ceF = ce.dtype === Dtype.float32 ? ce : ce.astype(Dtype.float32);

  const masked = ops.mul(ceF, mask); // [N]
  const sumCe = ops.sumAxis(masked, 0, false); // scalar
  const loss = ops.mulScalar(sumCe, 1 / ntoks); // scalar (token-mean)

  for (const a of [logits2d, targets, mask, lse, gathered, picked, ce, masked, sumCe]) a.dispose();
  if (ceF !== ce) ceF.dispose();
  return loss;
}

// ---------------------------------------------------------------------------
// DPO
// ---------------------------------------------------------------------------

/** Per-sequence sum of response-position log-probs (B>=1), port of
 *  dpo.py _seq_logp. `ids`/`mask` are `[B][L]` host arrays; `logits` are
 *  [B, L-1, V] (the forward over ids[:, :-1]). Returns a [B] MlxArray — one
 *  summed response log-prob per row. Pad positions contribute 0 because the
 *  response mask is 0 there. */
function seqLogp(logits: MlxArray, ids: number[][], mask: number[][]): MlxArray {
  const B = ids.length;
  const L = ids[0]!.length;
  const T = L - 1;
  const V = logits.shape[2]!;
  const N = B * T;

  const targetsHost = new Int32Array(N);
  const maskHost = new Float32Array(N);
  for (let b = 0; b < B; b++)
    for (let t = 0; t < T; t++) {
      const flat = b * T + t;
      targetsHost[flat] = ids[b]![t + 1]!;
      maskHost[flat] = mask[b]![t + 1]!; // resp_mask[:, 1:]
    }
  const logits2d = ops.reshape(logits, [N, V]);
  const targets = MlxArray.fromInt32(targetsHost, [N, 1]);
  const m = MlxArray.fromFloat32(maskHost, [N]);

  const lse = ops.logsumexpAxis(logits2d, -1, false); // [N]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [N,1]
  const picked = ops.reshape(gathered, [N]); // [N]
  const logp = ops.sub(picked, lse); // log_softmax at the label
  const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const masked = ops.mul(logpF, m); // [N]
  const masked2d = ops.reshape(masked, [B, T]); // [B, T]
  const perRow = ops.sumAxis(masked2d, 1, false); // [B]

  for (const a of [logits2d, targets, m, lse, gathered, picked, logp, masked, masked2d]) a.dispose();
  if (logpF !== logp) logpF.dispose();
  return perRow;
}

/** Forward + per-sequence response log-prob for one branch (B>=1). `validLen`
 *  is each row's true (unpadded) length, used to mask padded keys in the
 *  attention; passing it makes the batched forward ignore padding bit-for-bit
 *  the way separate per-row forwards would. */
function branchLogp(
  model: RuntimeModel,
  ids: number[][],
  mask: number[][],
  validLen: number[],
): MlxArray {
  const B = ids.length;
  const L = ids[0]!.length;
  const T = L - 1;
  const inputHost = new Int32Array(B * T);
  for (let b = 0; b < B; b++)
    for (let t = 0; t < T; t++) inputHost[b * T + t] = ids[b]![t]!;
  const inputIds = MlxArray.fromInt32(inputHost, [B, T]);
  // input row valid length = min(len, L) - 1 (last token dropped from inputs).
  const inputValid = validLen.map((v) => Math.max(0, Math.min(v, L) - 1));
  try {
    const logits = trainForward(model, inputIds, inputValid);
    const lp = seqLogp(logits, ids, mask);
    logits.dispose();
    return lp;
  } finally {
    inputIds.dispose();
  }
}

/** Branch valid lengths from a DPO batch (defaults to full length for B=1). */
function chosenLengths(batch: DpoBatch): number[] {
  return batch.chosenIds.map((_, i) => dpoChosenLength(batch, i));
}
function rejectedLengths(batch: DpoBatch): number[] {
  return batch.rejectedIds.map((_, i) => dpoRejectedLength(batch, i));
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
  const cLen = chosenLengths(batch);
  const rLen = rejectedLengths(batch);
  setLoraScale(lora, 0);
  try {
    const c = branchLogp(model, batch.chosenIds, batch.chosenMask, cLen); // [B]
    const r = branchLogp(model, batch.rejectedIds, batch.rejectedMask, rLen); // [B]
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

/** DPO loss for one batch given precomputed reference log-probs ([B] each).
 *  Runs the two policy forwards (adapter active) and reduces to the scalar
 *  mean over the batch of -logσ(adv) (matching dpo.py _policy_dpo_loss).
 *  Returns a scalar MlxArray (caller owns). */
export function dpoLoss(
  model: RuntimeModel,
  batch: DpoBatch,
  beta: number,
  refChosen: MlxArray,
  refRejected: MlxArray,
): MlxArray {
  const cLen = chosenLengths(batch);
  const rLen = rejectedLengths(batch);
  const piC = branchLogp(model, batch.chosenIds, batch.chosenMask, cLen); // [B]
  const piR = branchLogp(model, batch.rejectedIds, batch.rejectedMask, rLen); // [B]

  const logrC = ops.sub(piC, refChosen); // [B] πc - refc
  const logrR = ops.sub(piR, refRejected); // [B] πr - refr
  const diff = ops.sub(logrC, logrR);
  const adv = ops.mulScalar(diff, beta); // [B] β·(logrC - logrR)
  // -log σ(adv) = softplus(-adv) = logaddexp(0, -adv); mean over the batch.
  const negAdv = ops.neg(adv);
  const zero = ops.scalarLike(0, adv);
  const perRow = ops.logaddexp(zero, negAdv); // [B]
  const loss = ops.meanAll(perRow, false); // scalar

  for (const a of [piC, piR, logrC, logrR, diff, adv, negAdv, zero, perRow]) a.dispose();
  return loss;
}

/** DPO diagnostics (no grad): loss, accuracy (mean of adv>0), reward margin
 *  (mean of β·(logrC-logrR)) over the batch. Computes its own references. */
export function dpoMetrics(
  model: RuntimeModel,
  lora: TrainableLora,
  batch: DpoBatch,
  beta: number,
): { loss: number; accuracy: number; margin: number } {
  const { refChosen, refRejected } = dpoRefLogps(model, lora, batch);
  const cLen = chosenLengths(batch);
  const rLen = rejectedLengths(batch);
  const piC = branchLogp(model, batch.chosenIds, batch.chosenMask, cLen); // [B]
  const piR = branchLogp(model, batch.rejectedIds, batch.rejectedMask, rLen); // [B]

  const logrC = ops.sub(piC, refChosen);
  const logrR = ops.sub(piR, refRejected);
  const diff = ops.sub(logrC, logrR);
  const adv = ops.mulScalar(diff, beta); // [B]
  const negAdv = ops.neg(adv);
  const zero = ops.scalarLike(0, adv);
  const perRow = ops.logaddexp(zero, negAdv); // [B]
  const loss = ops.meanAll(perRow, false);

  const advVals = adv.toFloat32(); // [B]
  const lossVal = loss.toFloat32()[0]!;
  let acc = 0;
  let margin = 0;
  for (let b = 0; b < advVals.length; b++) {
    if (advVals[b]! > 0) acc++;
    margin += advVals[b]!;
  }
  acc /= advVals.length;
  margin /= advVals.length;

  for (const a of [refChosen, refRejected, piC, piR, logrC, logrR, diff, adv, negAdv, zero, perRow, loss]) a.dispose();
  return { loss: lossVal, accuracy: acc, margin };
}
