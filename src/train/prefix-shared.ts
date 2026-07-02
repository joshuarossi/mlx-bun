// Shared prompt-prefix ORPO (lever 7) — MiniCPM5, B=1.
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
// scripts/experiments/prefix-shared-parity.ts): each predicted token uses a hidden
// conditioned on exactly the same context + RoPE positions —
//   chosen[k]   from H[P-1+k]                 (k=0..Rc-1; H[P-1] = prompt's last)
//   rejected[k] from H[P-1] (k=0) / H[P+Rc+k-1] (k≥1)
// Both first-response tokens read the SAME prompt-last hidden H[P-1], computed
// once. Differentiability is free: it is one forward graph, so reverse-mode AD
// sums the two branches' cotangents into the shared prefix automatically.
//
// e4b (sliding-window mask interaction, donor-KV, per-layer-input) is the
// documented follow-on; this is the MiniCPM5 reference + correctness gate.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { createCausalMask, type Cache, type Mask } from "../model/gemma4-base";
import { MiniCPM5Model, setMiniCpmPrefixPlan } from "../model/minicpm5";
import { Gemma4Model, setGemmaPrefixPlan } from "../model/gemma4";
import { orpoLossFromLogps, fusedRespLogpMean, combineFullNll, type ChunkCtx, type SftScope } from "./loss";
import type { DpoBatch } from "./dataset";

/** A model that can project final-norm hidden states to vocab logits — the only
 *  capability the prefix-shared head needs (MiniCPM5Model and Gemma4Model both). */
interface LogitProjector { logitsFromHidden(h: MlxArray): MlxArray }

/** Block-sparse attention mask [1,1,T,T] (bool, true = attend) for the concat:
 *  causal AND NOT (rejected row → chosen col). Chosen rows already can't see
 *  rejected cols (rejected come later → causal forbids), so the only extra cut is
 *  rejected→chosen. Caller owns the result. */
export function blockSparseMask(P: number, Rc: number, Rr: number): MlxArray {
  const T = P + Rc + Rr;
  const causal = createCausalMask(T, 0, null); // [T,T] bool, j<=i
  const idxFlat = ops.arange(0, T, 1, Dtype.int32);
  const row = ops.reshape(idxFlat, [T, 1]);
  const col = ops.reshape(idxFlat, [1, T]);
  const pp = ops.fromInt32([P], []);
  const pRc = ops.fromInt32([P + Rc], []);
  // notForbid = NOT(rejRow AND chosenCol) = (i < P+Rc) OR (j < P) OR (j >= P+Rc)
  const notRejRow = ops.less(row, pRc);
  const colLtP = ops.less(col, pp);
  const colGePRc = ops.greaterEqual(col, pRc);
  const notChosenCol = ops.logicalOr(colLtP, colGePRc);
  const notForbid = ops.logicalOr(notRejRow, notChosenCol);
  const allow = ops.logicalAnd(causal, notForbid); // [T,T] bool — same rank as createCausalMask
  for (const a of [causal, idxFlat, row, col, pp, pRc, notRejRow, colLtP, colGePRc, notChosenCol, notForbid]) a.dispose();
  return allow;
}

/** Stateless cache for the prefix-shared forward: pass-through KV (offset 0, like
 *  TrainingCache) but `makeMask` returns the block-sparse mask. One per layer;
 *  MiniCPM5's runLayerRange calls makeMask once and disposes the returned arr. */
export class PrefixSharedCache implements Cache {
  offset = 0;
  constructor(private readonly P: number, private readonly Rc: number, private readonly Rr: number) {}
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(_N: number, _windowSize: number | null): Mask {
    return { mode: "array", arr: blockSparseMask(this.P, this.Rc, this.Rr) };
  }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void { /* offset pinned at 0 */ }
  dispose(): void { /* owns no arrays */ }
}

/** Length-normalized mean log-prob over the predictions at hidden positions
 *  `gatherIdx`, scoring `targets` (same shape). Mirrors responseOnlyLogpMean but
 *  gathers arbitrary (possibly non-contiguous) positions instead of a slice. */
function gatheredLogpMean(model: LogitProjector, h: MlxArray, gatherIdx: number[], targets: number[]): MlxArray {
  const M = gatherIdx.length;
  if (M <= 0) return MlxArray.fromFloat32(new Float32Array([0]), [1]);
  const hidden = h.shape[2]!;
  const idxArr = MlxArray.fromInt32(new Int32Array(gatherIdx), [M]);
  const hSel = ops.takeAxis(h, idxArr, 1); // [1, M, hidden]
  idxArr.dispose();
  if (hSel.shape[2] !== hidden) throw new Error("gatheredLogpMean: hidden mismatch");
  const logits = model.logitsFromHidden(hSel); // [1, M, V]
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
  model: LogitProjector, h: MlxArray, gatherIdx: number[], targets: number[], chunk?: ChunkCtx,
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
  // fusedRespLogpMean requires a RuntimeModel (headQuant); the prefix-shared models
  // (MiniCPM5Model/Gemma4Model) satisfy it. vocabBlock is unused by the flash path.
  // hResp is the CustomVjp/flash-head PRIMAL — its backward recomputes the head from
  // it (loss.ts fusedRespLogpMean/makeFlashCceHeadVjp), so it must live until the head
  // vjp is eval'd. Push it into the sink (disposed post-eval by the caller) instead of
  // freeing it here, matching responseOnlyLogpMean/fusedLogpMeanFromHidden.
  chunk.sink.push(hResp);
  const mean = fusedRespLogpMean(model as any, hResp, new Int32Array(targets), chunkSize, chunk.sink, 0, chunk.flash ?? false);
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
  model: LogitProjector, h: MlxArray, promptIds: number[], lw: MlxArray, Rc: number, chunk?: ChunkCtx,
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

/** ORPO loss via the shared prompt-prefix single forward (MiniCPM5, B=1).
 *  `promptIds` is the shared prefix; `chosenResp`/`rejectedResp` are the response
 *  continuations. Returns the scalar loss (caller owns). Differentiable through
 *  the LoRA primals like the two-forward orpoLoss. `chunk` (when fused/flash) routes
 *  each branch through the [M,V]-free flash-CCE head. */
export function orpoLossPrefixShared(
  model: MiniCPM5Model,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
  lambda: number, chunk?: ChunkCtx, sftScope: SftScope = "response",
): MlxArray {
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  if (P < 1 || Rc < 1 || Rr < 1) throw new Error("orpoLossPrefixShared: need P,Rc,Rr >= 1");
  const T = P + Rc + Rr;
  const concat = new Int32Array(T);
  concat.set(promptIds, 0);
  concat.set(chosenResp, P);
  concat.set(rejectedResp, P + Rc);
  const ids = MlxArray.fromInt32(concat, [1, T]);
  const caches: Cache[] = model.layers.map(() => new PrefixSharedCache(P, Rc, Rr));

  let h: MlxArray;
  setMiniCpmPrefixPlan({ P, Rc, Rr });
  try {
    h = model.forwardHidden(ids, caches); // [1, T, hidden], post-finalNorm
  } finally {
    setMiniCpmPrefixPlan(null);
    ids.dispose();
    for (const c of caches) c.dispose();
  }

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
  model: MiniCPM5Model,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
): { lw: number; lr: number } {
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  const T = P + Rc + Rr;
  const concat = new Int32Array(T);
  concat.set(promptIds, 0); concat.set(chosenResp, P); concat.set(rejectedResp, P + Rc);
  const ids = MlxArray.fromInt32(concat, [1, T]);
  const caches: Cache[] = model.layers.map(() => new PrefixSharedCache(P, Rc, Rr));
  setMiniCpmPrefixPlan({ P, Rc, Rr });
  let h: MlxArray;
  try { h = model.forwardHidden(ids, caches); }
  finally { setMiniCpmPrefixPlan(null); ids.dispose(); for (const c of caches) c.dispose(); }
  const chosenIdx = Array.from({ length: Rc }, (_, k) => P - 1 + k);
  const rejectedIdx = [P - 1, ...Array.from({ length: Rr - 1 }, (_, k) => P + Rc + k)];
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

// ===========================================================================
// Gemma e4b prefix-shared ORPO (lever 7 for the per-layer-input + KV-shared +
// sliding-window family). The CONSTRUCTION is the same as MiniCPM5 (one forward
// over [prompt; chosen; rejected] with block-wise RoPE + a block-sparse mask),
// reusing Gemma4Model.forwardHidden — which already drives per-layer inputs and
// the donor-KV sharing through forwardLayers, building one mask per layer-type
// from each donor cache's makeMask. Two e4b-specific wrinkles:
//   (1) Block-wise RoPE rides in via setGemmaPrefixPlan (gemma4.ts Attention),
//       so donor AND sharer layers rope identically to the two-forward path.
//   (2) The SLIDING-window mask must be cut on LOGICAL positions, not physical:
//       a rejected token at physical P+Rc+k has logical position P+k, so its
//       window to the prompt tail differs from its physical distance by Rc. The
//       branch VISIBILITY (who-may-attend-whom) is identical under the physical
//       layout (physical causal + the rejected→chosen cut, exactly as MiniCPM5),
//       so only the window DISTANCE needs logical positions — added as one extra
//       AND on top of the MiniCPM5 mask. Full-attention layers (window=null) get
//       the plain block-sparse causal mask (no sliding term).
// ===========================================================================

/** Block-sparse attention mask [T,T] (bool) for the gemma concat. Same as
 *  MiniCPM5's blockSparseMask (physical causal AND NOT rejected→chosen) plus, for
 *  sliding layers, a LOGICAL-position window AND: allow only where
 *  `logpos[row] - logpos[col] < window`, with `logpos[i] = i` for the
 *  prompt+chosen run and `i - Rc` for the rejected block (reset to P). Caller
 *  owns the result. */
export function blockSparsePrefixMaskGemma(P: number, Rc: number, Rr: number, window: number | null): MlxArray {
  const T = P + Rc + Rr;
  const causal = createCausalMask(T, 0, null); // [T,T] physical causal (window applied separately, on logical pos)
  const idxFlat = ops.arange(0, T, 1, Dtype.int32);
  const row = ops.reshape(idxFlat, [T, 1]);
  const col = ops.reshape(idxFlat, [1, T]);
  const pp = ops.fromInt32([P], []);
  const pRc = ops.fromInt32([P + Rc], []);
  // notForbid = NOT(rejRow AND chosenCol) = (i < P+Rc) OR (j < P) OR (j >= P+Rc)
  const notRejRow = ops.less(row, pRc);
  const colLtP = ops.less(col, pp);
  const colGePRc = ops.greaterEqual(col, pRc);
  const notChosenCol = ops.logicalOr(colLtP, colGePRc);
  const notForbid = ops.logicalOr(notRejRow, notChosenCol);
  let allow = ops.logicalAnd(causal, notForbid); // [T,T] bool

  if (window !== null) {
    // logical positions: prompt+chosen keep physical index; rejected resets to P.
    const logposArr = new Int32Array(T);
    for (let i = 0; i < T; i++) logposArr[i] = i < P + Rc ? i : i - Rc;
    const logpos = MlxArray.fromInt32(logposArr, [T]);
    const lrow = ops.reshape(logpos, [T, 1]);
    const lcol = ops.reshape(logpos, [1, T]);
    const dist = ops.sub(lrow, lcol); // logpos[row] - logpos[col] (>=0 wherever causal allows)
    const w = ops.fromInt32([window], []);
    const slidingOK = ops.less(dist, w); // attend only within `window` logical positions
    const next = ops.logicalAnd(allow, slidingOK);
    allow.dispose();
    allow = next;
    for (const a of [logpos, lrow, lcol, dist, w, slidingOK]) a.dispose();
  }

  for (const a of [causal, idxFlat, row, col, pp, pRc, notRejRow, colLtP, colGePRc, notChosenCol, notForbid]) a.dispose();
  return allow;
}

/** Pass-through cache (offset 0) for the gemma prefix-shared forward whose
 *  makeMask returns the block-sparse + logical-window mask. forwardLayers builds
 *  one mask per layer-type, calling makeMask(L, window) with window = the model's
 *  sliding window for sliding layers and null for full layers — so a single cache
 *  type serves both (the window arg selects the sliding term). One per DONOR
 *  layer (sharers reuse donors' fetched KV). */
class Gemma4PrefixSharedCache implements Cache {
  offset = 0;
  constructor(private readonly P: number, private readonly Rc: number, private readonly Rr: number) {}
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(N: number, windowSize: number | null): Mask {
    if (N !== this.P + this.Rc + this.Rr)
      throw new Error(`Gemma4PrefixSharedCache: N=${N} != P+Rc+Rr=${this.P + this.Rc + this.Rr}`);
    return { mode: "array", arr: blockSparsePrefixMaskGemma(this.P, this.Rc, this.Rr, windowSize) };
  }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void { /* offset pinned at 0 */ }
  dispose(): void { /* owns no arrays */ }
}

/** ORPO loss via the shared prompt-prefix single forward on Gemma e4b (B=1).
 *  Mirrors `orpoLossPrefixShared` (MiniCPM5) but uses the gemma prefix plan
 *  (block-wise RoPE in Attention) and donor-count prefix caches, reusing
 *  `Gemma4Model.forwardHidden` for the per-layer-input + donor-KV machinery.
 *  Returns the scalar loss (caller owns); differentiable through the LoRA
 *  primals like the two-forward orpoLoss. */
export function orpoLossPrefixSharedGemma(
  model: Gemma4Model,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
  lambda: number, chunk?: ChunkCtx, sftScope: SftScope = "response",
): MlxArray {
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  if (P < 1 || Rc < 1 || Rr < 1) throw new Error("orpoLossPrefixSharedGemma: need P,Rc,Rr >= 1");
  const T = P + Rc + Rr;
  const concat = new Int32Array(T);
  concat.set(promptIds, 0);
  concat.set(chosenResp, P);
  concat.set(rejectedResp, P + Rc);
  const ids = MlxArray.fromInt32(concat, [1, T]);
  // One prefix cache per DONOR layer (sharers consume donors' fetched KV inside
  // forwardLayers); makeCache() also returns numDonors entries.
  const caches: Cache[] = Array.from({ length: model.numDonors }, () => new Gemma4PrefixSharedCache(P, Rc, Rr));

  let h: MlxArray;
  setGemmaPrefixPlan({ P, Rc, Rr });
  try {
    h = model.forwardHidden(ids, caches); // [1, T, hidden], post-finalNorm
  } finally {
    setGemmaPrefixPlan(null);
    ids.dispose();
    for (const c of caches) c.dispose();
  }

  // Same gather as MiniCPM5 (identical concat layout): chosen[k] from H[P-1+k];
  // rejected[0] from H[P-1] (shared prompt-last), rejected[k>=1] from H[P+Rc+k-1].
  const chosenIdx = Array.from({ length: Rc }, (_, k) => P - 1 + k);
  const rejectedIdx = [P - 1, ...Array.from({ length: Rr - 1 }, (_, k) => P + Rc + k)];

  // Same head-primal lifetime as orpoLossPrefixShared: keep h alive in the sink
  // through the fused/flash backward recompute; free it now on the whole-vocab path.
  const keepForBwd = !!chunk && (chunk.fused || chunk.flash);
  if (keepForBwd) chunk!.sink.push(h);
  const lw = branchLogpMeanGathered(model, h, chosenIdx, chosenResp, chunk);
  const lr = branchLogpMeanGathered(model, h, rejectedIdx, rejectedResp, chunk);
  // sft_scope:"full": prompt predictions from the same concat forward (see
  // orpoLossPrefixShared); ℓw/ℓr stay response-only for the odds ratio.
  const nllFull = sftScope === "full" ? prefixFullNll(model, h, promptIds, lw, Rc, chunk) : null;
  if (!keepForBwd) h.dispose();
  const loss = orpoLossFromLogps(lw, lr, lambda, nllFull ?? undefined);
  lw.dispose();
  lr.dispose();
  nllFull?.dispose();
  return loss;
}

/** Debug: the raw [1,T,hidden] post-finalNorm hidden of the gemma prefix-shared
 *  forward (caller owns/disposes). For localizing forward divergence per position. */
export function prefixForwardHiddenGemma(
  model: Gemma4Model,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
): MlxArray {
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  const T = P + Rc + Rr;
  const concat = new Int32Array(T);
  concat.set(promptIds, 0); concat.set(chosenResp, P); concat.set(rejectedResp, P + Rc);
  const ids = MlxArray.fromInt32(concat, [1, T]);
  const caches: Cache[] = Array.from({ length: model.numDonors }, () => new Gemma4PrefixSharedCache(P, Rc, Rr));
  setGemmaPrefixPlan({ P, Rc, Rr });
  try { return model.forwardHidden(ids, caches); }
  finally { setGemmaPrefixPlan(null); ids.dispose(); for (const c of caches) c.dispose(); }
}

/** Debug: the two branch mean-logps (ℓw, ℓr) from the gemma prefix-shared forward,
 *  no grad. For parity diagnostics (compare against the two-forward branch logps). */
export function prefixSharedLogpsGemma(
  model: Gemma4Model,
  promptIds: number[], chosenResp: number[], rejectedResp: number[],
): { lw: number; lr: number } {
  const P = promptIds.length, Rc = chosenResp.length, Rr = rejectedResp.length;
  const T = P + Rc + Rr;
  const concat = new Int32Array(T);
  concat.set(promptIds, 0); concat.set(chosenResp, P); concat.set(rejectedResp, P + Rc);
  const ids = MlxArray.fromInt32(concat, [1, T]);
  const caches: Cache[] = Array.from({ length: model.numDonors }, () => new Gemma4PrefixSharedCache(P, Rc, Rr));
  setGemmaPrefixPlan({ P, Rc, Rr });
  let h: MlxArray;
  try { h = model.forwardHidden(ids, caches); }
  finally { setGemmaPrefixPlan(null); ids.dispose(); for (const c of caches) c.dispose(); }
  const chosenIdx = Array.from({ length: Rc }, (_, k) => P - 1 + k);
  const rejectedIdx = [P - 1, ...Array.from({ length: Rr - 1 }, (_, k) => P + Rc + k)];
  const lwA = gatheredLogpMean(model, h, chosenIdx, chosenResp);
  const lrA = gatheredLogpMean(model, h, rejectedIdx, rejectedResp);
  h.dispose();
  const lw = lwA.toFloat32()[0]!, lr = lrA.toFloat32()[0]!;
  lwA.dispose(); lrA.dispose();
  return { lw, lr };
}
