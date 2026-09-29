// Shared prompt-prefix ORPO (lever 7), B=1.
//
// Chosen and rejected share an identical prompt prefix; the causal mask makes the
// prefix's hidden states independent of which response follows. So instead of two
// forwards [prompt;chosenResp] and [prompt;rejectedResp] (the prompt encoded
// TWICE), run ONE forward over the concatenation
//   X = [ prompt(P) ; chosenResp(Rc) ; rejectedResp(Rr) ]            (T = P+Rc+Rr)
// with (a) a BLOCK-SPARSE mask so each response attends to prompt + itself only
// (never the other response), and (b) BLOCK-WISE RoPE that resets each response to
// position P. Token cost through the layers 2(P+R) → P+2R — a ~2× win when the
// prompt dominates (our chunk/document fine-tunes), ~0 when the response does.
//
// Bit-exact with the two-forward path (validated in
// prefix-shared-parity.ts (deleted 2026-08-23; git history)): each predicted token uses a hidden
// conditioned on exactly the same context + RoPE positions —
//   chosen[k]   from H[P-1+k]                 (k=0..Rc-1; H[P-1] = prompt's last)
//   rejected[k] from H[P-1] (k=0) / H[P+Rc+k-1] (k≥1)
// Both first-response tokens read the SAME prompt-last hidden H[P-1], computed
// once. Differentiability is free: it is one forward graph, so reverse-mode AD
// sums the two branches' cotangents into the shared prefix automatically.
//
// The graph declares the concat forward (`prefixShared`): its block-sparse mask
// (with a LOGICAL-position sliding window where the graph has one), its block-wise
// RoPE and any per-layer-input / donor-KV machinery live with the graph. This
// module owns the loss over the concat's hiddens.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { RuntimeModel } from "@mlx-bun/inference/models";
import { orpoLossFromLogps, fusedRespLogpMean, combineFullNll, logitsFromHiddenPadM, type ChunkCtx, type SftScope } from "./loss";
import { declaredTraining } from "./declared";
import type { DpoBatch } from "./dataset";

/** Length-normalized mean log-prob over the predictions at hidden positions
 *  `gatherIdx`, scoring `targets` (same shape). Mirrors responseOnlyLogpMean but
 *  gathers arbitrary (possibly non-contiguous) positions instead of a slice. */
function gatheredLogpMean(model: RuntimeModel, h: MlxArray, gatherIdx: number[], targets: number[]): MlxArray {
  const M = gatherIdx.length;
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);
  const hidden = h.shape[2]!;
  const idxArr = MlxArray.fromInt32(new Int32Array(gatherIdx), [M]);
  const hSel = ops.takeAxis(h, idxArr, 1); // [1, M, hidden]
  idxArr.dispose();
  if (hSel.shape[2] !== hidden) throw new Error("gatheredLogpMean: hidden mismatch");
  const logits = logitsFromHiddenPadM(model, hSel); // [1, M, V] (M in {2,3} padded — mlx qmm bug)
  hSel.dispose();
  const V = logits.shape[2]!;
  const logits2d = ops.reshape(logits, [M, V]);
  logits.dispose();
  const tgt = MlxArray.fromInt32(new Int32Array(targets), [M, 1]);
  const lse = ops.logsumexpAxis(logits2d, -1, false);
  const gathered = ops.takeAlongAxis(logits2d, tgt, -1);
  const picked = ops.reshape(gathered, [M]);
  const logp = ops.sub(picked, lse);
  const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const sumLogp = ops.sumAxis(logpF, 0, false);
  const meanScalar = ops.mulScalar(sumLogp, 1 / M);
  const mean = ops.reshape(meanScalar, [1]);
  for (const a of [logits2d, tgt, lse, gathered, picked, logp, sumLogp, meanScalar]) a.dispose();
  if (logpF !== logp) logpF.dispose();
  return mean;
}

/** Length-normalized mean log-prob over gathered (possibly non-contiguous) hidden
 *  positions via the FUSED/FLASH head ([M,V]-free analytic backward) when `chunk`
 *  requests it, else the whole-vocab `gatheredLogpMean`. Gathers the branch's
 *  response hiddens [M, hidden] from `h [1,T,hidden]` and hands them to
 *  `fusedRespLogpMean` — so prefix-sharing composes with the steel flash-CCE head
 *  (one model forward + one head fwd/bwd per branch, all [M,V]-free). */
export function branchLogpMeanGathered(
  model: RuntimeModel, h: MlxArray, gatherIdx: number[], targets: number[], chunk?: ChunkCtx,
): MlxArray {
  if (!chunk || !(chunk.fused || chunk.flash)) return gatheredLogpMean(model, h, gatherIdx, targets);
  const M = gatherIdx.length;
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);
  const hidden = h.shape[2]!;
  const idxArr = MlxArray.fromInt32(new Int32Array(gatherIdx), [M]);
  const hSel = ops.takeAxis(h, idxArr, 1); // [1, M, hidden]
  idxArr.dispose();
  const hResp = ops.reshape(hSel, [M, hidden]); // [M, hidden] for the head
  hSel.dispose();
  const chunkSize = chunk.chunkSize > 0 ? chunk.chunkSize : 512;
  // vocabBlock is unused by the flash path.
  // hResp is the CustomVjp/flash-head PRIMAL — its backward recomputes the head from
  // it (loss.ts fusedRespLogpMean/makeFlashCceHeadVjp), so it must live until the head
  // vjp is eval'd. Push it into the sink (disposed post-eval by the caller) instead of
  // freeing it here, matching responseOnlyLogpMean/fusedLogpMeanFromHidden.
  chunk.sink.push(hResp);
  const mean = fusedRespLogpMean(model, hResp, new Int32Array(targets), chunkSize, chunk.sink, 0, chunk.flash ?? false);
  return mean;
}

/** The response-hidden gather indices for the prefix-shared concat layout
 *  [prompt(P); chosen(Rc); rejected(Rr)]: chosen[k] is predicted from H[P-1+k];
 *  rejected[0] from H[P-1] (the shared prompt-last, same as chosen[0]) and
 *  rejected[k>=1] from H[P+Rc+k-1]. Used by the non-segmented path AND the
 *  segmented prefix backward so both gather identically. */
export function prefixGatherIdx(P: number, Rc: number, Rr: number): { chosenIdx: number[]; rejectedIdx: number[] } {
  const chosenIdx = Array.from({ length: Rc }, (_, k) => P - 1 + k);
  const rejectedIdx = [P - 1, ...Array.from({ length: Rr - 1 }, (_, k) => P + Rc + k)];
  return { chosenIdx, rejectedIdx };
}

/** sft_scope:"full" over the prefix-shared concat: the full-scope chosen NLL
 *  gathers the PROMPT predictions too — hidden position t (t = 0..P-2) predicts
 *  prompt token t+1 — and combines them with the response mean ℓw:
 *  NLL_full = -((P-1)·promptMean + Rc·ℓw) / (P-1+Rc). The prompt head routes
 *  through the same branchLogpMeanGathered tier as the responses (whole-vocab /
 *  fused / flash), sharing the one concat forward's hiddens. Returns [1]
 *  (caller owns); lw is NOT disposed. P=1 (no prompt predictions) → -ℓw. */
export function prefixFullNll(
  model: RuntimeModel, h: MlxArray, promptIds: number[], lw: MlxArray, Rc: number, chunk?: ChunkCtx,
): MlxArray {
  const P = promptIds.length;
  if (P <= 1) return combineFullNll(null, lw, 0, Rc);
  const promptIdx = Array.from({ length: P - 1 }, (_, k) => k); // H[k] predicts promptIds[k+1]
  const promptTargets = promptIds.slice(1);
  const pm = branchLogpMeanGathered(model, h, promptIdx, promptTargets, chunk); // [1]
  const nllFull = combineFullNll(pm, lw, P - 1, Rc);
  pm.dispose();
  return nllFull;
}

/** The post-final-norm hidden [1, T, hidden] of the graph's prefix-shared forward
 *  over the concat [prompt; chosen; rejected] (caller owns). */
function prefixHidden(
  model: RuntimeModel, promptIds: number[], chosenResp: number[], rejectedResp: number[],
): MlxArray {
  const shared = declaredTraining(model, "prefixShared", "prefix-shared training");
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  const T = P + Rc + Rr;
  const concat = new Int32Array(T);
  concat.set(promptIds, 0);
  concat.set(chosenResp, P);
  concat.set(rejectedResp, P + Rc);
  const ids = MlxArray.fromInt32(concat, [1, T]);
  try {
    return shared.forwardHidden(ids, { P, Rc, Rr });
  } finally {
    ids.dispose();
  }
}

/** ORPO loss via the shared prompt-prefix single forward (B=1).
 *  `promptIds` is the shared prefix; `chosenResp`/`rejectedResp` are the response
 *  continuations. Returns the scalar loss (caller owns). Differentiable through
 *  the LoRA primals like the two-forward orpoLoss. `chunk` (when fused/flash) routes
 *  each branch through the [M,V]-free flash-CCE head. The graph must declare
 *  `prefixShared`. */
export function orpoLossPrefixShared(
  model: RuntimeModel,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
  lambda: number, chunk?: ChunkCtx, sftScope: SftScope = "response",
): MlxArray {
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  if (P < 1 || Rc < 1 || Rr < 1) throw new Error("orpoLossPrefixShared: need P,Rc,Rr >= 1");
  const h = prefixHidden(model, promptIds, chosenResp, rejectedResp); // [1, T, hidden], post-finalNorm

  // chosen[k] predicted from H[P-1+k]; rejected[0] from H[P-1] (prompt's last,
  // shared with chosen[0]); rejected[k>=1] from H[P+Rc+k-1].
  const { chosenIdx, rejectedIdx } = prefixGatherIdx(P, Rc, Rr);

  // On the fused/flash head, the gathered hResp (sliced from h) is the backward
  // recompute primal — keep h alive in the sink until the head vjp is eval'd. The
  // whole-vocab path builds a normal autograd graph, so h can free immediately.
  const keepForBwd = !!chunk && (chunk.fused || chunk.flash);
  if (keepForBwd) chunk!.sink.push(h);
  const lw = branchLogpMeanGathered(model, h, chosenIdx, chosenResp, chunk);
  const lr = branchLogpMeanGathered(model, h, rejectedIdx, rejectedResp, chunk);
  // sft_scope:"full": add the prompt predictions (H[0..P-2] → promptIds[1..P-1])
  // from the SAME concat forward; ℓw/ℓr stay response-only for the odds ratio.
  const nllFull = sftScope === "full" ? prefixFullNll(model, h, promptIds, lw, Rc, chunk) : null;
  if (!keepForBwd) h.dispose();
  const loss = orpoLossFromLogps(lw, lr, lambda, nllFull ?? undefined);
  lw.dispose();
  lr.dispose();
  nllFull?.dispose();
  return loss;
}

/** Debug: the two branch mean-logps (ℓw, ℓr) from the prefix-shared forward, no
 *  grad. For parity diagnostics (compare against the two-forward branch logps). */
export function prefixSharedLogps(
  model: RuntimeModel,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
): { lw: number; lr: number } {
  const P = promptIds.length, Rc = chosenResp.length;
  const h = prefixHidden(model, promptIds, chosenResp, rejectedResp);
  const { chosenIdx, rejectedIdx } = prefixGatherIdx(P, Rc, rejectedResp.length);
  const lwA = gatheredLogpMean(model, h, chosenIdx, chosenResp);
  const lrA = gatheredLogpMean(model, h, rejectedIdx, rejectedResp);
  h.dispose();
  const lw = lwA.toFloat32()[0]!, lr = lrA.toFloat32()[0]!;
  lwA.dispose(); lrA.dispose();
  return { lw, lr };
}

/** Split a DpoBatch row (B=1) into the shared prompt prefix + the two response
 *  continuations. The chosen/rejected sequences must share an identical prompt
 *  (the masked prefix where mask==0); `response` tokens are mask==1. Returns null
 *  if the prompts differ or either response is empty (caller falls back to the
 *  two-forward orpoLoss). */
export function splitPrefixBatch(batch: DpoBatch): {
  promptIds: number[]; chosenResp: number[]; rejectedResp: number[];
} | null {
  if (batch.chosenIds.length !== 1) return null;
  const cIds = batch.chosenIds[0]!, cMask = batch.chosenMask[0]!;
  const rIds = batch.rejectedIds[0]!, rMask = batch.rejectedMask[0]!;
  // Prompt = leading mask==0 run (response = mask==1). Find first response token.
  const cStart = cMask.indexOf(1);
  const rStart = rMask.indexOf(1);
  if (cStart < 1 || rStart < 1) return null; // need a non-empty prompt + response
  const P = cStart;
  if (rStart !== P) return null; // prompts must be the same length
  for (let i = 0; i < P; i++) if (cIds[i] !== rIds[i]) return null; // ...and identical
  const promptIds = cIds.slice(0, P);
  const chosenResp = cIds.slice(P);
  const rejectedResp = rIds.slice(P);
  if (chosenResp.length < 1 || rejectedResp.length < 1) return null;
  return { promptIds, chosenResp, rejectedResp };
}

/** Token-throughput accounting: tokens pushed through the layer stack by the
 *  two-forward path vs the prefix-shared single forward, and the saving ratio.
 *  (Each two-forward branch processes L-1 = P+R-1 input tokens; the shared path
 *  processes T = P+Rc+Rr.) */
export function prefixSavings(P: number, Rc: number, Rr: number): { twoForward: number; shared: number; ratio: number } {
  const twoForward = (P + Rc - 1) + (P + Rr - 1);
  const shared = P + Rc + Rr;
  return { twoForward, shared, ratio: twoForward / shared };
}
