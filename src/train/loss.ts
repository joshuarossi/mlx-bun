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
import { Checkpoint } from "../mlx/checkpoint";
import { CustomVjp } from "../mlx/custom-vjp";
import type { RuntimeModel } from "../model/factory";
import { Gemma4Model } from "../model/gemma4";
import { MiniCPM5Model } from "../model/minicpm5";
import { logitSoftcap } from "../model/gemma4-base";
import { trainForward, trainForwardHidden } from "./forward";
import { setLoraScale, type TrainableLora } from "./lora-params";
import { flashCceForward, flashCceBackward, type FlashCceHead } from "./flash-cce";

/** The quantized LM-head weights + final-logit softcap, accessed uniformly across
 *  models for the fused linear-CE head: Gemma is tied (`embed.asLinear`, softcap
 *  from config), MiniCPM5 is the separate `lmHead` (no softcap). The head is NOT
 *  a default LoRA target, so the base quantized weights are authoritative. */
interface HeadQuant {
  w: MlxArray; scales: MlxArray; biases: MlxArray | null;
  spec: ops.QuantSpec; softcap: number | null;
}
function headQuant(model: RuntimeModel): HeadQuant {
  if (model instanceof Gemma4Model) {
    const e = model.embed;
    return { w: e.w, scales: e.scales, biases: e.biases, spec: e.spec, softcap: model.config.text.finalLogitSoftcapping };
  }
  if (model instanceof MiniCPM5Model) {
    const h = model.lmHead;
    return { w: h.w, scales: h.scales, biases: h.biases, spec: h.spec, softcap: null };
  }
  throw new Error("fused linear-CE head is not wired for this model type");
}

/** Token-chunking context for the ORPO loss head. When `chunkSize > 0`, the B=1
 *  response-only head is computed in token-chunks, each wrapped in a Checkpoint
 *  so its `[chunk, vocab]` logits are RECOMPUTED in the backward instead of all
 *  `[M, vocab]` being retained — bounding the dominant large-vocab term to
 *  `[chunkSize, vocab]`. The checkpoints recompute during the enclosing
 *  value_and_grad backward, so they must outlive `orpoLoss`: they are pushed
 *  into `sink`, which the caller (orpoLoop) disposes AFTER `vag.apply` returns
 *  (i.e. after the backward). Exact — rematerialization is numerically
 *  identical, and MLX computes the (quantized) head backward itself. */
export interface ChunkCtx {
  chunkSize: number;
  /** When set, use the FUSED linear-CE head (`fusedLogpMeanB1`: one CustomVjp with
   *  an analytic softmax−onehot backward, no autograd through the head and no
   *  retained `[M,V]` logits) instead of the per-chunk `Checkpoint` head. Same
   *  token `chunkSize`; the fused path bounds large-vocab memory in both
   *  directions and is the Liger/CCE structure (the moat). Off → the Checkpoint
   *  token-chunked head (unchanged). */
  fused?: boolean;
  /** When set (with `fused`), route the head through the flash-CCE Metal kernel
   *  (`makeFlashCceHeadVjp`): in-kernel quantized logits + online softmax (fwd) and
   *  `dh` accumulation (bwd), so neither `[M,V]` logits nor a dequantized head touch
   *  HBM — the lowest-memory head, and the fastest on large vocab (e4b/CPM). The
   *  Apple-CCE coeff filter is on by default in the backward. */
  flash?: boolean;
  /** Disposables whose lifetime must extend past the enclosing value_and_grad
   *  backward: the per-chunk `Checkpoint`s / the fused `CustomVjp` (they recompute
   *  in the backward) AND the hidden `h` / chunk slices they read (these
   *  deliberately drop their input activations, so freeing them early corrupts the
   *  recompute — and even the forward eval). The caller (orpoLoop) disposes these
   *  only AFTER the step's grads are eval'd (the `afterMicroEval` hook). */
  sink: Array<{ dispose(): void }>;
}
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

/** B=1 response-only length-normalized mean log-prob from pre-computed final-hidden h [1, T, hidden].
 *  Mirror of responseOnlyCe but returns mean response logp (scalar wrapped in [1]) instead of
 *  CE loss. Used by SegmentedBackwardOrpo's head VJP. Disposes nothing; caller owns h and result. */
export function responseOnlyLogpMean(
  model: RuntimeModel,
  h: MlxArray,  // [1, T, hidden] post-finalNorm
  ids: number[],
  mask: number[],
): MlxArray {
  const L = ids.length;
  const T = L - 1; // h has T positions
  // Find response span: supervised positions where mask[t+1] == 1
  let startT = -1; let M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);

  const hidden = h.shape[2]!;
  const start = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hResp = ops.sliceDynamic(h, start, [1], [1, M, hidden]); // [1, M, hidden]
  const logits = model.logitsFromHidden(hResp);                   // [1, M, V]
  const V = logits.shape[2]!;
  const logits2d = ops.reshape(logits, [M, V]);

  const targetsHost = new Int32Array(M);
  for (let i = 0; i < M; i++) targetsHost[i] = ids[startT + 1 + i]!;
  const targets = MlxArray.fromInt32(targetsHost, [M, 1]);

  const lse = ops.logsumexpAxis(logits2d, -1, false);       // [M]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [M, 1]
  const picked = ops.reshape(gathered, [M]);                 // [M]
  const logp = ops.sub(picked, lse);                        // [M] log_softmax at label
  const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const sumLogp = ops.sumAxis(logpF, 0, false);             // scalar
  const meanScalar = ops.mulScalar(sumLogp, 1 / M);
  const mean = ops.reshape(meanScalar, [1]);                 // [1]

  for (const a of [start, hResp, logits, logits2d, targets, lse, gathered, picked, logp, sumLogp, meanScalar]) a.dispose();
  if (logpF !== logp) logpF.dispose();
  return mean;
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

// ---------------------------------------------------------------------------
// ORPO (Odds Ratio Preference Optimization, Hong et al. 2024)
// ---------------------------------------------------------------------------
//
// Reference-FREE: one objective, no reference model (vs DPO's scale-0 ref pass).
//   L = L_NLL(chosen)  +  λ · L_OR
//   L_NLL = -mean_response_logp(chosen)                 (the SFT term; unweighted)
//   L_OR  = -log σ(log_odds)
//   log_odds = (ℓw - ℓr) - (log1mexp(ℓw) - log1mexp(ℓr))
// where ℓ is the LENGTH-NORMALIZED (mean over response tokens) log-prob — the
// paper's choice (and TRL's), distinct from DPO's summed seqLogp. Two facts
// shape the code: (1) ℓw feeds BOTH terms (L_NLL = -ℓw), so the chosen forward
// does double duty; (2) only 2 forwards/step (chosen + rejected), both with
// grad, no reference. This is the naïve full-logits oracle path — the chunked /
// response-only / segmented tiers validate against it (see the design's oracle
// ladder, docs/design/orpo-training.md).

/** Per-row LENGTH-NORMALIZED response log-prob for one branch (B>=1): the
 *  summed response logp divided by the per-row response-token count. Pad/prompt
 *  positions contribute 0 (mask is 0 there) and never inflate the count.
 *  Returns a [B] MlxArray (caller owns).
 *
 *  B=1 takes the response-only path (mirrors `responseOnlyCe`): the LM head is
 *  applied ONLY at the supervised response positions, so the dominant
 *  `[1, T, vocab]` logits term (and its grad) is never materialized — the same
 *  long-context memory win the SFT B=1 path already gets, doubly important for
 *  ORPO since it forwards two responses. Numerically identical to the B>1
 *  full-logits path (same positions, same count). B>1 uses the full-logits
 *  path (the batched forward already materializes logits). */
function branchLogpMean(
  model: RuntimeModel,
  ids: number[][],
  mask: number[][],
  validLen: number[],
  chunk?: ChunkCtx,
): MlxArray {
  if (ids.length === 1) {
    if (chunk && chunk.chunkSize > 0)
      return chunk.fused
        ? fusedLogpMeanB1(model, ids[0]!, mask[0]!, validLen[0]!, chunk.chunkSize, chunk.sink, 0, chunk.flash ?? false)
        : chunkedLogpMeanB1(model, ids[0]!, mask[0]!, validLen[0]!, chunk.chunkSize, chunk.sink);
    return branchLogpMeanB1(model, ids[0]!, mask[0]!, validLen[0]!);
  }

  const sum = branchLogp(model, ids, mask, validLen); // [B] summed response logp
  // Per-row response-token count = Σ_t mask[b][t+1] (resp_mask[:, 1:]); clamp to
  // >=1 so an all-prompt row (no response) can't divide by zero. Multiply by the
  // host-side reciprocal (avoids needing an elementwise divide op).
  const B = ids.length;
  const L = ids[0]!.length;
  const recip = new Float32Array(B);
  for (let b = 0; b < B; b++) {
    let c = 0;
    for (let t = 0; t < L - 1; t++) c += mask[b]![t + 1]!;
    recip[b] = 1 / Math.max(c, 1);
  }
  const recipArr = MlxArray.fromFloat32(recip, [B]);
  const mean = ops.mul(sum, recipArr); // [B] length-normalized
  sum.dispose();
  recipArr.dispose();
  return mean;
}

/** B=1 response-only length-normalized log-prob → [1]. The supervised input
 *  positions are exactly `{ t in [0, T) : mask[t+1] == 1 }` (the same set the
 *  full-logits seqLogp sums), which for prompt+response data is the contiguous
 *  span `[startT, startT+M)`; the LM head runs only on that slice. Grads to
 *  prompt-position LoRA still flow — the response hidden states depend on the
 *  prompt through causal attention, captured upstream in `h`. */
export function branchLogpMeanB1(
  model: RuntimeModel,
  ids: number[],
  mask: number[],
  validLen: number,
): MlxArray {
  const L = ids.length;
  const T = L - 1;
  // Supervised input positions (contiguous for prompt+response): first/count.
  let startT = -1;
  let M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]); // no response → 0 (matches clamp)

  const inputHost = new Int32Array(T);
  for (let t = 0; t < T; t++) inputHost[t] = ids[t]!;
  const inputIds = MlxArray.fromInt32(inputHost, [1, T]);
  const inputValid = [Math.max(0, Math.min(validLen, L) - 1)];

  const h = trainForwardHidden(model, inputIds, inputValid); // [1, T, hidden]
  const hidden = h.shape[2]!;
  const start = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hResp = ops.sliceDynamic(h, start, [1], [1, M, hidden]); // [1, M, hidden]
  const logits = model.logitsFromHidden(hResp); // [1, M, V] — head only on the response span
  const V = logits.shape[2]!;
  const logits2d = ops.reshape(logits, [M, V]);

  const targetsHost = new Int32Array(M);
  for (let i = 0; i < M; i++) targetsHost[i] = ids[startT + 1 + i]!;
  const targets = MlxArray.fromInt32(targetsHost, [M, 1]);

  const lse = ops.logsumexpAxis(logits2d, -1, false); // [M]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [M, 1]
  const picked = ops.reshape(gathered, [M]); // [M]
  const logp = ops.sub(picked, lse); // [M] log_softmax at the label
  const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const sumLogp = ops.sumAxis(logpF, 0, false); // scalar
  const meanScalar = ops.mulScalar(sumLogp, 1 / M); // scalar (length-normalized)
  const mean = ops.reshape(meanScalar, [1]); // [1] to match the [B] contract

  for (const a of [inputIds, h, start, hResp, logits, logits2d, targets, lse, gathered, picked, logp, sumLogp, meanScalar]) a.dispose();
  if (logpF !== logp) logpF.dispose();
  return mean;
}

/** B=1 chunked response-only mean log-prob → [1]. Same result as
 *  `branchLogpMeanB1` but the LM head over the M response positions is computed
 *  in token-chunks of `chunkSize`, each wrapped in a `Checkpoint`: the
 *  `[chunk, vocab]` logits are recomputed in the backward rather than all
 *  `[M, vocab]` retained, so peak large-vocab memory is bounded to
 *  `[chunkSize, vocab]`. Each checkpoint must survive until the enclosing
 *  value_and_grad backward (it recomputes there), so it is pushed into `sink`
 *  for the caller to dispose after `vag.apply`. Grads flow chunk → slice → `h`
 *  → layer-stack LoRA exactly as the single-shot path. */
function chunkedLogpMeanB1(
  model: RuntimeModel,
  ids: number[],
  mask: number[],
  validLen: number,
  chunkSize: number,
  sink: Array<{ dispose(): void }>,
): MlxArray {
  const L = ids.length;
  const T = L - 1;
  let startT = -1;
  let M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);

  const inputHost = new Int32Array(T);
  for (let t = 0; t < T; t++) inputHost[t] = ids[t]!;
  const inputIds = MlxArray.fromInt32(inputHost, [1, T]);
  const inputValid = [Math.max(0, Math.min(validLen, L) - 1)];
  const h = trainForwardHidden(model, inputIds, inputValid); // [1, T, hidden]
  inputIds.dispose();
  // `h` and the chunk slices feed Checkpoints, which drop their input
  // activations — so they must NOT be freed until after the backward. Defer to
  // the sink (disposed post-eval by the caller).
  sink.push(h);
  const hidden = h.shape[2]!;

  let total: MlxArray | null = null;
  for (let c0 = startT; c0 < startT + M; c0 += chunkSize) {
    const c1 = Math.min(c0 + chunkSize, startT + M);
    const Cc = c1 - c0;
    const startArr = MlxArray.fromInt32(new Int32Array([c0]), [1]);
    const hChunk = ops.sliceDynamic(h, startArr, [1], [1, Cc, hidden]); // [1, Cc, hidden]
    startArr.dispose();
    sink.push(hChunk); // checkpoint input — alive until post-eval

    // Targets for this chunk, captured immutably by the checkpoint closure so
    // the backward recompute reproduces exactly these positions' logp.
    const tHost = new Int32Array(Cc);
    for (let i = 0; i < Cc; i++) tHost[i] = ids[c0 + 1 + i]!;

    const ckpt = new Checkpoint((inp) => {
      const hc = inp[0]!;
      const logits = model.logitsFromHidden(hc); // [1, Cc, V] — recomputed in backward
      const V = logits.shape[2]!;
      const l2 = ops.reshape(logits, [Cc, V]);
      const targets = MlxArray.fromInt32(tHost, [Cc, 1]);
      const lse = ops.logsumexpAxis(l2, -1, false); // [Cc]
      const gathered = ops.takeAlongAxis(l2, targets, -1); // [Cc, 1]
      const picked = ops.reshape(gathered, [Cc]); // [Cc]
      const logp = ops.sub(picked, lse); // [Cc]
      const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
      const s = ops.sumAxis(logpF, 0, false); // scalar — Σ logp over the chunk
      for (const a of [logits, l2, targets, lse, gathered, picked, logp]) a.dispose();
      if (logpF !== logp) logpF.dispose();
      return [s];
    });
    sink.push(ckpt); // disposed by the caller after the backward (vag.apply)
    const [s] = ckpt.apply([hChunk]);
    if (total === null) total = s!;
    else {
      const sum = ops.add(total, s!);
      total.dispose();
      s!.dispose();
      total = sum;
    }
  }

  const meanScalar = ops.mulScalar(total!, 1 / M); // length-normalized
  total!.dispose();
  const mean = ops.reshape(meanScalar, [1]); // [1] to match the [B] contract
  meanScalar.dispose();
  return mean;
}

/** CHECKPOINT token-chunked response-only mean logp from a PRE-COMPUTED
 *  post-finalNorm hidden `h [1,T,hidden]` (the segmented-backward head variant of
 *  `chunkedLogpMeanB1`). Each token-chunk's `logitsFromHidden` is wrapped in a
 *  `Checkpoint`, so the per-chunk `[chunk,V]` logits are RECOMPUTED in the
 *  backward and freed sequentially — the recompute boundary is what actually
 *  bounds the head term under MLX's lazy eval when nested inside the segmented
 *  `mlx_vjp` (unlike the analytic CustomVjp, whose per-chunk graph isn't freed
 *  incrementally inside an outer vjp). Checkpoints + slices go in `sink`. */
export function chunkedLogpMeanFromHidden(
  model: RuntimeModel,
  h: MlxArray, // [1, T, hidden] post-finalNorm
  ids: number[],
  mask: number[],
  chunkSize: number,
  sink: Array<{ dispose(): void }>,
): MlxArray {
  const L = ids.length;
  const T = L - 1;
  let startT = -1;
  let M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);
  const hidden = h.shape[2]!;

  let total: MlxArray | null = null;
  for (let c0 = startT; c0 < startT + M; c0 += chunkSize) {
    const c1 = Math.min(c0 + chunkSize, startT + M);
    const Cc = c1 - c0;
    const startArr = MlxArray.fromInt32(new Int32Array([c0]), [1]);
    const hChunk = ops.sliceDynamic(h, startArr, [1], [1, Cc, hidden]); // [1, Cc, hidden]
    startArr.dispose();
    sink.push(hChunk);
    const tHost = new Int32Array(Cc);
    for (let i = 0; i < Cc; i++) tHost[i] = ids[c0 + 1 + i]!;
    const ckpt = new Checkpoint((inp) => {
      const hc = inp[0]!;
      const logits = model.logitsFromHidden(hc); // [1, Cc, V] — recomputed in backward
      const V = logits.shape[2]!;
      const l2 = ops.reshape(logits, [Cc, V]);
      const targets = MlxArray.fromInt32(tHost, [Cc, 1]);
      const lse = ops.logsumexpAxis(l2, -1, false);
      const gathered = ops.takeAlongAxis(l2, targets, -1);
      const picked = ops.reshape(gathered, [Cc]);
      const logp = ops.sub(picked, lse);
      const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
      const s = ops.sumAxis(logpF, 0, false);
      for (const a of [logits, l2, targets, lse, gathered, picked, logp]) a.dispose();
      if (logpF !== logp) logpF.dispose();
      return [s];
    });
    sink.push(ckpt);
    const [s] = ckpt.apply([hChunk]);
    if (total === null) total = s!;
    else { const sum = ops.add(total, s!); total.dispose(); s!.dispose(); total = sum; }
  }
  const meanScalar = ops.mulScalar(total!, 1 / M);
  total!.dispose();
  const mean = ops.reshape(meanScalar, [1]);
  meanScalar.dispose();
  return mean;
}

/** B=1 FUSED linear cross-entropy response-only mean log-prob → [1]. Same result
 *  as `branchLogpMeanB1` but the LM head is a single `CustomVjp` with an ANALYTIC
 *  backward — the Liger `FusedLinearCrossEntropy` structure ported to MLX:
 *   - FORWARD token-chunks the M response rows; per chunk materializes only
 *     `[Cc, V]` logits (= `h_c @ Wᵀ` via `quantizedMatmul`, + Gemma softcap),
 *     reduces to `logp = target_logit − logsumexp`, and DROPS the logits. Returns
 *     Σ logp (the `1/M` mean is applied outside, a cheap linear scale).
 *   - BACKWARD recomputes `[Cc, V]` per chunk and forms the gradient in CLOSED
 *     FORM — `∂(Σlogp)/∂logit = onehot_target − softmax` (× `sech²` through the
 *     softcap), scaled by the incoming cotangent — instead of autograd-ing through
 *     logsumexp+gather (what the `Checkpoint` token-chunked path does). `dh_c =
 *     grad_logits_c @ dequant(W)` uses `quantizedMatmul(…, transpose=false)`, which
 *     IS mlx's own x-vjp of the `transpose=true` head matmul (the path LoRA
 *     training already differentiates through), so it contracts the vocab axis
 *     correctly without dequantizing the full `[V, hidden]` head (1.3 GB at 262k).
 *  Peak large-vocab memory is bounded to `[chunkSize, V]` in BOTH directions, the
 *  full `[M, V]` logits never materialize, and the head backward needs no autograd
 *  graph. The `CustomVjp` recomputes in the backward (it must outlive the
 *  enclosing value_and_grad), so it — and `h` — are pushed into `sink`, disposed
 *  by the caller after the step's grads are eval'd. The head is NOT a LoRA target,
 *  so only `dh` flows back (seeding the layer-stack LoRA backward); a head-LoRA
 *  `∇A/∇B` fold-in is a follow-on. Exact within the established bf16 class. */
export function fusedLogpMeanB1(
  model: RuntimeModel,
  ids: number[],
  mask: number[],
  validLen: number,
  chunkSize: number,
  sink: Array<{ dispose(): void }>,
  vocabBlock = 0,
  flash = false,
): MlxArray {
  const L = ids.length;
  const T = L - 1;
  let startT = -1;
  let M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);

  const inputHost = new Int32Array(T);
  for (let t = 0; t < T; t++) inputHost[t] = ids[t]!;
  const inputIds = MlxArray.fromInt32(inputHost, [1, T]);
  const inputValid = [Math.max(0, Math.min(validLen, L) - 1)];
  const h = trainForwardHidden(model, inputIds, inputValid); // [1, T, hidden]
  inputIds.dispose();
  sink.push(h); // primal of the CustomVjp (via the slice below) — alive until post-eval
  const hidden = h.shape[2]!;

  // Response hiddens [M, hidden] — the CustomVjp primal.
  const startArr = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hRespSlice = ops.sliceDynamic(h, startArr, [1], [1, M, hidden]); // [1, M, hidden]
  startArr.dispose();
  const hResp = ops.reshape(hRespSlice, [M, hidden]); // [M, hidden]
  hRespSlice.dispose();
  sink.push(hResp);

  const targetsHost = new Int32Array(M);
  for (let i = 0; i < M; i++) targetsHost[i] = ids[startT + 1 + i]!;
  return fusedRespLogpMean(model, hResp, targetsHost, chunkSize, sink, vocabBlock, flash);
}

/** Fused linear-CE log-prob from a PRE-COMPUTED post-finalNorm hidden
 *  `h [1, T, hidden]` (the segmented-backward head: finalNorm is applied by the
 *  caller). Mirrors `responseOnlyLogpMean`'s response-span selection but routes
 *  the head through the fused analytic CustomVjp, so the head term inside the
 *  segmented backward is bounded to `[chunk, V]` instead of the full `[M, V]`.
 *  Composes with the segmented `mlx_vjp` (the CustomVjp nests inside it, like the
 *  fused-GeGLU kernel). The CustomVjp + the response slice are pushed into `sink`,
 *  disposed by the caller AFTER the head vjp is eval'd. */
export function fusedLogpMeanFromHidden(
  model: RuntimeModel,
  h: MlxArray, // [1, T, hidden] post-finalNorm
  ids: number[],
  mask: number[],
  chunkSize: number,
  sink: Array<{ dispose(): void }>,
  vocabBlock = 0,
  flash = false,
): MlxArray {
  const L = ids.length;
  const T = L - 1;
  let startT = -1;
  let M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);
  const hidden = h.shape[2]!;
  const startArr = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hRespSlice = ops.sliceDynamic(h, startArr, [1], [1, M, hidden]); // [1, M, hidden]
  startArr.dispose();
  const hResp = ops.reshape(hRespSlice, [M, hidden]); // [M, hidden]
  hRespSlice.dispose();
  sink.push(hResp);
  const targetsHost = new Int32Array(M);
  for (let i = 0; i < M; i++) targetsHost[i] = ids[startT + 1 + i]!;
  return fusedRespLogpMean(model, hResp, targetsHost, chunkSize, sink, vocabBlock, flash);
}

/** The fused linear-CE head core: response hidden `hResp [M, hidden]`
 *  (post-finalNorm) + target ids → length-normalized mean logp [1], via the
 *  analytic CustomVjp (token-chunked forward, softmax−onehot backward, dh through
 *  mlx's quantized x-vjp). Shared by `fusedLogpMeanB1` (re-runs the forward) and
 *  `fusedLogpMeanFromHidden` (segmented head). Pushes the CustomVjp into `sink`;
 *  the caller owns `hResp` (and is responsible for its sink lifetime). */
/** VOCAB-BLOCKED online-softmax fused head (full Cut Cross Entropy structure):
 *  even `[chunk, V]` never exists — the vocab axis is tiled into `vocabBlock`-wide
 *  blocks and the logsumexp is built with the [online-softmax](https://arxiv.org/abs/1805.02867)
 *  running (max `m`, sumexp `d`) recurrence, so only `[chunk, vocabBlock]` is ever
 *  live (MLX frees each block's tensor after the running scalars update — the
 *  blocks are sequentially dependent through `m`/`d`). The target logit is captured
 *  per block (host-side membership mask, so no full-row gather). The backward
 *  recomputes per `(token-chunk, vocab-block)`: `softmax_block = exp(logit_block −
 *  lse)`, `grad = cotangent·(onehot_block − softmax_block)·sech²`, accumulating
 *  `dh += grad @ dequant(W_block)` (mlx x-vjp, `transpose=false`) into a
 *  `[chunk, hidden]` running buffer — `lse` is recomputed by one online pass (the
 *  scalar `[chunk]` lse is cheap; stashing it forward→backward is the FLOP
 *  optimization left as a follow-on). NOT bit-exact to the whole-vocab head (the
 *  block-wise reduction re-associates), but within the bf16 class.
 *  `W_block` = an axis-0 (vocab) row-slice of the quantized `w`/`scales`/`biases`. */
function makeVocabBlockedHeadVjp(
  head: HeadQuant, targetsHost: Int32Array, M: number, hidden: number,
  tokenChunk: number, vocabBlock: number,
): CustomVjp {
  const cap = head.softcap;
  const V = head.scales.shape[0]!;
  const wCols = head.w.shape[1]!, scCols = head.scales.shape[1]!, biCols = head.biases?.shape[1] ?? 0;
  const sliceHead = (v0: number, v1: number) => ({
    w: head.w.slice([v0, 0], [v1, wCols]),
    scales: head.scales.slice([v0, 0], [v1, scCols]),
    biases: head.biases ? head.biases.slice([v0, 0], [v1, biCols]) : null,
  });
  // Post-softcap logits [Cc,Vb] for a vocab block, plus sech² (null if no softcap)
  // for the backward chain rule. The block weights `wb` are RETURNED (the backward
  // reuses them for dh = grad @ dequant(W_block)); caller disposes them.
  const blockLogits = (hc: MlxArray, wb: { w: MlxArray; scales: MlxArray; biases: MlxArray | null }):
    { lb: MlxArray; sech2: MlxArray | null } => {
    const raw = ops.quantizedMatmul(hc, wb.w, wb.scales, wb.biases, head.spec, true); // [Cc, Vb]
    if (cap === null) return { lb: raw, sech2: null };
    const capArr = ops.scalarLike(cap, raw);
    const div = ops.div(raw, capArr);
    const th = ops.tanh(div); div.dispose(); // bind the nested div so its wrapper is freed
    raw.dispose();
    const lb = ops.mul(th, capArr); // cap·tanh(raw/cap)
    const th2 = ops.mul(th, th); th.dispose();
    const one = ops.scalarLike(1, th2);
    const sech2 = ops.sub(one, th2); // 1 − tanh²
    one.dispose(); th2.dispose(); capArr.dispose();
    return { lb, sech2 };
  };
  // One online-softmax pass over vocab blocks for a token-chunk hc [Cc,hidden]:
  // running (max m, sumexp d) so only [Cc,Vb] is ever live → lse [Cc] + the
  // captured target logit [Cc]. Used by fwd and (to recompute lse) by the vjp.
  const onlinePass = (hc: MlxArray, c0: number, Cc: number): { lse: MlxArray; tgt: MlxArray } => {
    let m: MlxArray | null = null;   // [Cc] running max
    let d: MlxArray | null = null;   // [Cc] running sumexp (relative to m)
    let tgt: MlxArray | null = null; // [Cc] accumulated (masked) target logit
    for (let v0 = 0; v0 < V; v0 += vocabBlock) {
      const v1 = Math.min(v0 + vocabBlock, V);
      const wb = sliceHead(v0, v1);
      const { lb: lbRaw, sech2 } = blockLogits(hc, wb); // [Cc, Vb]
      sech2?.dispose();
      wb.w.dispose(); wb.scales.dispose(); wb.biases?.dispose();
      // Online (m, d) accumulation in f32 — bf16 across many blocks loses the
      // precision that softmax = exp(logit − lse) is exponentially sensitive to
      // (matches logsumexpAxis's f32-internal reduction).
      const lb = lbRaw.dtype === Dtype.float32 ? lbRaw : lbRaw.astype(Dtype.float32);
      if (lb !== lbRaw) lbRaw.dispose();
      const bmax = ops.maxAxis(lb, -1, false); // [Cc]
      const mNew: MlxArray = m === null ? bmax : ops.maximum(m, bmax);
      if (m !== null) bmax.dispose();
      const mCol = ops.reshape(mNew, [Cc, 1]);
      const shifted = ops.sub(lb, mCol); mCol.dispose();
      const ex = ops.exp(shifted); shifted.dispose(); // [Cc, Vb]
      const blockSum = ops.sumAxis(ex, -1, false); ex.dispose(); // [Cc]
      let dNew: MlxArray;
      if (d === null) dNew = blockSum;
      else {
        const md = ops.sub(m!, mNew); // prevM − mNew  [Cc]
        const sc = ops.exp(md); md.dispose();
        const rescaled = ops.mul(d, sc); sc.dispose();
        dNew = ops.add(rescaled, blockSum);
        rescaled.dispose(); blockSum.dispose();
      }
      // Target logit capture: host membership mask (each target lands in one
      // block), gather the clamped local index, accumulate masked across blocks.
      const locHost = new Int32Array(Cc), maskHost = new Float32Array(Cc);
      for (let t = 0; t < Cc; t++) {
        const tg = targetsHost[c0 + t]!;
        const inb = tg >= v0 && tg < v1;
        locHost[t] = inb ? tg - v0 : 0;
        maskHost[t] = inb ? 1 : 0;
      }
      const locArr = MlxArray.fromInt32(locHost, [Cc, 1]);
      const gathered = ops.reshape(ops.takeAlongAxis(lb, locArr, -1), [Cc]); // [Cc]
      locArr.dispose();
      const maskA = MlxArray.fromFloat32(maskHost, [Cc]);
      const maskM = maskA.dtype === gathered.dtype ? maskA : maskA.astype(gathered.dtype);
      const contrib = ops.mul(gathered, maskM); gathered.dispose();
      if (maskM !== maskA) maskA.dispose();
      maskM.dispose();
      const tgtNew: MlxArray = tgt === null ? contrib : ops.add(tgt, contrib);
      if (tgt !== null) { tgt.dispose(); contrib.dispose(); }
      lb.dispose();
      if (m !== null) m.dispose();
      if (d !== null) d.dispose();
      m = mNew; d = dNew; tgt = tgtNew;
    }
    const logd = ops.log(d!);
    const lse = ops.add(m!, logd);
    logd.dispose(); m!.dispose(); d!.dispose();
    return { lse, tgt: tgt! };
  };

  return new CustomVjp(
    // FORWARD: Σ over the response of (target_logit − lse), token-chunked, with
    // the lse built vocab-block-by-block (online). Only [Cc,Vb] ever materializes.
    (inputs) => {
      const hR = inputs[0]!; // [M, hidden]
      let sum: MlxArray | null = null;
      for (let c0 = 0; c0 < M; c0 += tokenChunk) {
        const c1 = Math.min(c0 + tokenChunk, M);
        const Cc = c1 - c0;
        const hc = hR.slice([c0, 0], [c1, hidden]);
        const { lse, tgt } = onlinePass(hc, c0, Cc);
        hc.dispose();
        const logp = ops.sub(tgt, lse); // [Cc]
        tgt.dispose(); lse.dispose();
        const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
        const s = ops.sumAxis(logpF, 0, false);
        logp.dispose(); if (logpF !== logp) logpF.dispose();
        if (sum === null) sum = s;
        else { const n = ops.add(sum, s); sum.dispose(); s.dispose(); sum = n; }
      }
      const out = ops.reshape(sum!, [1]);
      sum!.dispose();
      return [out];
    },
    // BACKWARD: per token-chunk, recompute lse (online), then per vocab block form
    // softmax_block = exp(logit_block − lse), grad = cot·(onehot − softmax)·sech²,
    // accumulate dh += grad @ dequant(W_block). Peak stays [Cc,Vb].
    (primals, cots) => {
      const hR = primals[0]!; // [M, hidden]
      const c = cots[0]!; // [1] scalar = ∂loss/∂(Σlogp)
      const dtype = hR.dtype;
      const cMatch = c.dtype === dtype ? c : c.astype(dtype);
      const chunks: MlxArray[] = [];
      for (let c0 = 0; c0 < M; c0 += tokenChunk) {
        const c1 = Math.min(c0 + tokenChunk, M);
        const Cc = c1 - c0;
        const hc = hR.slice([c0, 0], [c1, hidden]);
        const { lse, tgt } = onlinePass(hc, c0, Cc);
        tgt.dispose();
        const lseCol = ops.reshape(lse, [Cc, 1]); lse.dispose();
        let dh: MlxArray | null = null; // [Cc, hidden]
        for (let v0 = 0; v0 < V; v0 += vocabBlock) {
          const v1 = Math.min(v0 + vocabBlock, V);
          const Vb = v1 - v0;
          const wb = sliceHead(v0, v1);
          const { lb, sech2 } = blockLogits(hc, wb); // [Cc, Vb]
          const softmax = ops.exp(ops.sub(lb, lseCol)); // [Cc, Vb]
          lb.dispose();
          // onehot_block: global col == target.
          const colFlat = ops.arange(v0, v1, 1, Dtype.int32);
          const col = ops.reshape(colFlat, [1, Vb]); colFlat.dispose();
          const tcol = MlxArray.fromInt32(targetsHost.slice(c0, c1), [Cc, 1]);
          const ge1 = ops.greaterEqual(col, tcol);
          const ge2 = ops.greaterEqual(tcol, col);
          const eqMask = ops.logicalAnd(ge1, ge2); // bind the nested compares so their wrappers free
          ge1.dispose(); ge2.dispose();
          col.dispose(); tcol.dispose();
          const onehot = eqMask.astype(softmax.dtype); eqMask.dispose();
          let g = ops.sub(onehot, softmax); // onehot − softmax  [Cc, Vb]
          onehot.dispose(); softmax.dispose();
          if (sech2) { const gg = ops.mul(g, sech2); g.dispose(); sech2.dispose(); g = gg; }
          const gScaled = ops.mul(g, cMatch); g.dispose();
          const gT = gScaled.dtype === dtype ? gScaled : gScaled.astype(dtype);
          if (gT !== gScaled) gScaled.dispose();
          const dhcBf = ops.quantizedMatmul(gT, wb.w, wb.scales, wb.biases, head.spec, false); // [Cc, hidden]
          gT.dispose();
          wb.w.dispose(); wb.scales.dispose(); wb.biases?.dispose();
          // Accumulate dh in f32: the whole-vocab qmm reduces V in f32 internally,
          // but summing hundreds of bf16 block-dh's re-introduces an error that
          // scales with block count (the dominant grad bug at small vocabBlock).
          const dhc = dhcBf.dtype === Dtype.float32 ? dhcBf : dhcBf.astype(Dtype.float32);
          if (dhc !== dhcBf) dhcBf.dispose();
          if (dh === null) dh = dhc;
          else { const n = ops.add(dh, dhc); dh.dispose(); dhc.dispose(); dh = n; }
        }
        lseCol.dispose(); hc.dispose();
        const dhFinal = dh!.dtype === dtype ? dh! : dh!.astype(dtype);
        if (dhFinal !== dh!) dh!.dispose();
        chunks.push(dhFinal);
      }
      if (cMatch !== c) cMatch.dispose();
      const dh = chunks.length === 1 ? chunks[0]! : ops.concatAxis(chunks, 0); // [M, hidden]
      if (chunks.length > 1) for (const a of chunks) a.dispose();
      return [dh];
    },
  );
}

/** flash-CCE head as a CustomVjp: forward runs the Metal kernel → Σ logp (stashing
 *  `lse` for the backward, avoiding a forward recompute); backward runs the kernel's
 *  `dh` for unit cotangent then scales by the scalar cotangent `c` (loss = Σ logp →
 *  ∂loss/∂logp_t = c for all t). The coeff filter + vocab-block skip are OFF by
 *  default (env-gated MLX_BUN_CCE_BWD_*_EPS) — the backward computes the EXACT dh. */
function makeFlashCceHeadVjp(
  head: HeadQuant, targetsHost: Int32Array, M: number,
  sink: Array<{ dispose(): void }>,
): CustomVjp {
  if (!head.biases) throw new Error("flash-CCE head requires affine (biased) quantization");
  const fch: FlashCceHead = {
    w: head.w, scales: head.scales, biases: head.biases,
    bits: head.spec.bits, groupSize: head.spec.groupSize, softcap: head.softcap,
  };
  const targets = Array.from(targetsHost);
  let savedLse: MlxArray | null = null;
  let savedBlockMax: MlxArray | null = null;
  return new CustomVjp(
    (inputs) => {
      const hR = inputs[0]!; // [M, hidden]
      const { logp, lse, blockMax } = flashCceForward(hR, fch, targets); // logp[M], lse[M], blockMax[M,NBLK]
      savedLse = lse; sink.push(lse); // stash lse + blockMax → backward (no recompute;
      savedBlockMax = blockMax; sink.push(blockMax); // blockMax drives the vocab-block skip)
      const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
      const s = ops.sumAxis(logpF, 0, false); // Σ logp (scalar)
      if (logpF !== logp) logpF.dispose();
      logp.dispose();
      const out = ops.reshape(s, [1]); s.dispose();
      return [out];
    },
    (primals, cots) => {
      const hR = primals[0]!; // [M, hidden]
      const c = cots[0]!;      // [1] = ∂loss/∂(Σ logp); uniform over tokens
      // dh for unit cotangent, then × c (avoids a host read of the cotangent).
      const ones = new Array(M).fill(1) as number[];
      // filter + block-skip are OFF by default (env-gated) → EXACT dh. savedBlockMax is
      // passed so the lossless vocab-block skip can be enabled via env without re-plumbing.
      const dhUnit = flashCceBackward(hR, fch, targets, savedLse!, ones, undefined, savedBlockMax!); // [M, hidden] f32
      const cM = c.dtype === dhUnit.dtype ? c : c.astype(dhUnit.dtype);
      const dh = ops.mul(dhUnit, cM); // broadcast [M,hidden]·[1]
      if (cM !== c) cM.dispose();
      dhUnit.dispose();
      const dhO = dh.dtype === hR.dtype ? dh : dh.astype(hR.dtype);
      if (dhO !== dh) dh.dispose();
      return [dhO];
    },
  );
}

export function fusedRespLogpMean(
  model: RuntimeModel,
  hResp: MlxArray, // [M, hidden]
  targetsHost: Int32Array,
  chunkSize: number,
  sink: Array<{ dispose(): void }>,
  vocabBlock = 0,
  flash = false,
): MlxArray {
  const M = hResp.shape[0]!;
  const hidden = hResp.shape[1]!;
  const head = headQuant(model);
  const cap = head.softcap;
  const chunk = Math.max(1, chunkSize);
  const V = head.scales.shape[0]!;
  // Vocab-blocked (full CCE) path: even [chunk,V] never materializes — only
  // [chunk,vocabBlock]. Otherwise the whole-vocab analytic head below.
  const vb = vocabBlock > 0 && vocabBlock < V ? vocabBlock : 0;
  let op: CustomVjp;
  if (flash) {
    op = makeFlashCceHeadVjp(head, targetsHost, M, sink);
  } else if (vb > 0) {
    op = makeVocabBlockedHeadVjp(head, targetsHost, M, hidden, chunk, vb);
  } else {

  // logits for one token-chunk [Cc, V] (+ softcap). Shared by fwd and vjp.
  const chunkLogits = (hc: MlxArray): MlxArray => {
    const raw = ops.quantizedMatmul(hc, head.w, head.scales, head.biases, head.spec, true); // [Cc, V]
    if (cap === null) return raw;
    const capped = logitSoftcap(raw, cap); // EXACT match to logitsFromHidden (div by a bf16 cap array)
    raw.dispose();
    return capped;
  };

  op = new CustomVjp(
    // FORWARD: Σ over the response of (target_logit − logsumexp), token-chunked.
    (inputs) => {
      const hR = inputs[0]!; // [M, hidden]
      let sum: MlxArray | null = null;
      for (let c0 = 0; c0 < M; c0 += chunk) {
        const c1 = Math.min(c0 + chunk, M);
        const Cc = c1 - c0;
        const hc = hR.slice([c0, 0], [c1, hidden]); // [Cc, hidden]
        const logits = chunkLogits(hc); // [Cc, V]
        hc.dispose();
        const lse = ops.logsumexpAxis(logits, -1, false); // [Cc]
        const tgt = MlxArray.fromInt32(targetsHost.slice(c0, c1), [Cc, 1]);
        const gathered = ops.takeAlongAxis(logits, tgt, -1); // [Cc, 1]
        const picked = ops.reshape(gathered, [Cc]);
        const logp = ops.sub(picked, lse); // [Cc]
        const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
        const s = ops.sumAxis(logpF, 0, false); // scalar
        for (const a of [logits, lse, tgt, gathered, picked, logp]) a.dispose();
        if (logpF !== logp) logpF.dispose();
        if (sum === null) sum = s;
        else { const n = ops.add(sum, s); sum.dispose(); s.dispose(); sum = n; }
      }
      const out = ops.reshape(sum!, [1]);
      sum!.dispose();
      return [out];
    },
    // BACKWARD: dh = (cotangent · (onehot − softmax) · sech²) @ dequant(W).
    (primals, cots) => {
      const hR = primals[0]!; // [M, hidden]
      const c = cots[0]!; // [1] scalar = ∂loss/∂(Σlogp)
      const dtype = hR.dtype;
      const cMatch = c.dtype === dtype ? c : c.astype(dtype);
      const chunks: MlxArray[] = [];
      for (let c0 = 0; c0 < M; c0 += chunk) {
        const c1 = Math.min(c0 + chunk, M);
        const Cc = c1 - c0;
        const hc = hR.slice([c0, 0], [c1, hidden]); // [Cc, hidden]
        // recompute logits, keeping sech² through the softcap if present
        const raw = ops.quantizedMatmul(hc, head.w, head.scales, head.biases, head.spec, true); // [Cc, V]
        hc.dispose();
        let logits = raw;
        let sech2: MlxArray | null = null;
        if (cap !== null) {
          // Replicate logitSoftcap internals (div by a bf16 cap array) so the
          // recomputed logits match the forward exactly, and keep tanh for sech².
          const capArr = ops.scalarLike(cap, raw);
          const scaled = ops.div(raw, capArr);
          raw.dispose();
          const th = ops.tanh(scaled);
          scaled.dispose();
          logits = ops.mul(th, capArr); // cap·tanh(raw/cap), bit-exact to logitSoftcap
          const th2 = ops.mul(th, th);
          th.dispose();
          const one = ops.scalarLike(1, th2);
          sech2 = ops.sub(one, th2); // 1 − tanh² = sech²
          one.dispose(); th2.dispose(); capArr.dispose();
        }
        const lse = ops.logsumexpAxis(logits, -1, false); // [Cc]
        const lseCol = ops.reshape(lse, [Cc, 1]);
        const softmax = ops.exp(ops.sub(logits, lseCol)); // [Cc, V]
        logits.dispose(); lse.dispose(); lseCol.dispose();
        // onehot via equality (no scatter op): col == target.
        const colFlat = ops.arange(0, softmax.shape[1]!, 1, Dtype.int32);
        const col = ops.reshape(colFlat, [1, softmax.shape[1]!]);
        colFlat.dispose();
        const tcol = MlxArray.fromInt32(targetsHost.slice(c0, c1), [Cc, 1]);
        const ge = ops.greaterEqual(col, tcol);
        const le = ops.greaterEqual(tcol, col);
        const eqMask = ops.logicalAnd(ge, le); // [Cc, V] bool, true at target
        for (const a of [col, tcol, ge, le]) a.dispose();
        const onehot = eqMask.astype(softmax.dtype);
        eqMask.dispose();
        let g = ops.sub(onehot, softmax); // onehot − softmax  [Cc, V]
        onehot.dispose(); softmax.dispose();
        if (sech2) { const gg = ops.mul(g, sech2); g.dispose(); sech2.dispose(); g = gg; }
        const gScaled = ops.mul(g, cMatch); // × cotangent (broadcast [Cc,V]·[1])
        g.dispose();
        const gT = gScaled.dtype === dtype ? gScaled : gScaled.astype(dtype);
        if (gT !== gScaled) gScaled.dispose();
        // dh_c = g @ dequant(W) — mlx's x-vjp of the transpose=true head matmul.
        const dhc = ops.quantizedMatmul(gT, head.w, head.scales, head.biases, head.spec, false); // [Cc, hidden]
        gT.dispose();
        chunks.push(dhc);
      }
      if (cMatch !== c) cMatch.dispose();
      const dh = chunks.length === 1 ? chunks[0]! : ops.concatAxis(chunks, 0); // [M, hidden]
      if (chunks.length > 1) for (const a of chunks) a.dispose();
      return [dh];
    },
  );
  } // end whole-vocab branch
  sink.push(op);

  const [sumLogp] = op.apply([hResp]);
  const mean = ops.mulScalar(sumLogp!, 1 / M); // length-normalized
  sumLogp!.dispose();
  const out = ops.reshape(mean, [1]);
  mean.dispose();
  return out;
}

/** Numerically-guarded log(1 - exp(x)) for x < 0 (x = a mean log-prob, so
 *  exp(x) ∈ (0,1) and comfortably below 1 — average per-token logp is well
 *  negative). Clamp `1 - exp(x)` to >= eps so the log never hits -inf in the
 *  pathological near-zero case. Caller owns the result. */
export function log1mexp(x: MlxArray): MlxArray {
  const ex = ops.exp(x);
  const one = ops.scalarLike(1, x);
  const oneMinus = ops.sub(one, ex);
  const eps = ops.scalarLike(1e-7, x);
  const clamped = ops.maximum(oneMinus, eps);
  const out = ops.log(clamped);
  for (const a of [ex, one, oneMinus, eps, clamped]) a.dispose();
  return out;
}

/** Per-row ORPO log-odds from the two length-normalized log-probs ([B] each):
 *  `log_odds = (ℓw - ℓr) - (log1mexp(ℓw) - log1mexp(ℓr))`. Caller owns lw/lr
 *  (not disposed here) and the [B] result. */
function orpoLogOdds(lw: MlxArray, lr: MlxArray): MlxArray {
  const diff = ops.sub(lw, lr);
  const lmw = log1mexp(lw);
  const lmr = log1mexp(lr);
  const lmDiff = ops.sub(lmw, lmr);
  const logOdds = ops.sub(diff, lmDiff); // [B]
  for (const a of [diff, lmw, lmr, lmDiff]) a.dispose();
  return logOdds;
}

/** The pure ORPO reduction from the two length-normalized log-probs ([B] each):
 *  `L_NLL + λ·L_OR` with `L_NLL = mean(-ℓw)` (unweighted SFT term) and
 *  `L_OR = mean(softplus(-log_odds))`. Model-free and graph-preserving — the
 *  forwards live in `orpoLoss`, the math (and its grad path) lives here, so the
 *  loss can be unit-tested against a hand reference with synthetic lw/lr. Does
 *  NOT dispose lw/lr (the caller owns them); returns the scalar loss. */
export function orpoLossFromLogps(lw: MlxArray, lr: MlxArray, lambda: number): MlxArray {
  const negLw = ops.neg(lw);
  const nll = ops.meanAll(negLw, false); // scalar  L_NLL = mean(-ℓw)
  const logOdds = orpoLogOdds(lw, lr); // [B]
  const negLO = ops.neg(logOdds);
  const orPer = ops.softplus(negLO); // [B]  -log σ(log_odds)
  const orLoss = ops.meanAll(orPer, false); // scalar L_OR
  const lamOr = ops.mulScalar(orLoss, lambda);
  const loss = ops.add(nll, lamOr);
  for (const a of [negLw, nll, logOdds, negLO, orPer, orLoss, lamOr]) a.dispose();
  return loss;
}

/** ORPO loss for one preference batch (B>=1). Runs the chosen + rejected policy
 *  forwards (adapter active), reduces via {@link orpoLossFromLogps}. No
 *  reference forward. Returns a scalar MlxArray (caller owns). */
export function orpoLoss(model: RuntimeModel, batch: DpoBatch, lambda: number, chunk?: ChunkCtx): MlxArray {
  const cLen = chosenLengths(batch);
  const rLen = rejectedLengths(batch);
  const lw = branchLogpMean(model, batch.chosenIds, batch.chosenMask, cLen, chunk); // [B]
  const lr = branchLogpMean(model, batch.rejectedIds, batch.rejectedMask, rLen, chunk); // [B]
  const loss = orpoLossFromLogps(lw, lr, lambda);
  // Safe to drop the lw/lr wrappers now — the loss graph retains the underlying
  // nodes (same pattern as dpoLoss disposing piC/piR before returning).
  lw.dispose();
  lr.dispose();
  return loss;
}

/** ORPO diagnostics (no grad): the total loss and its `nll`/`or` split,
 *  preference accuracy (mean of ℓw > ℓr), and reward margin (mean log_odds).
 *  Runs its own two forwards. */
export function orpoMetrics(
  model: RuntimeModel,
  batch: DpoBatch,
  lambda: number,
): { loss: number; nll: number; or: number; accuracy: number; margin: number } {
  const cLen = chosenLengths(batch);
  const rLen = rejectedLengths(batch);
  const lw = branchLogpMean(model, batch.chosenIds, batch.chosenMask, cLen); // [B]
  const lr = branchLogpMean(model, batch.rejectedIds, batch.rejectedMask, rLen); // [B]

  const negLw = ops.neg(lw);
  const nllArr = ops.meanAll(negLw, false);
  const logOdds = orpoLogOdds(lw, lr); // [B]
  const negLO = ops.neg(logOdds);
  const orPer = ops.softplus(negLO);
  const orArr = ops.meanAll(orPer, false);

  const lwVals = lw.toFloat32();
  const lrVals = lr.toFloat32();
  const loVals = logOdds.toFloat32();
  const nll = nllArr.toFloat32()[0]!;
  const or = orArr.toFloat32()[0]!;
  const loss = nll + lambda * or;
  let acc = 0;
  let margin = 0;
  for (let b = 0; b < lwVals.length; b++) {
    if (lwVals[b]! > lrVals[b]!) acc++;
    margin += loVals[b]!;
  }
  acc /= lwVals.length;
  margin /= loVals.length;

  for (const a of [lw, lr, negLw, nllArr, logOdds, negLO, orPer, orArr]) a.dispose();
  return { loss, nll, or, accuracy: acc, margin };
}
