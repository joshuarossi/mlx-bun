// SHARED PROMPT-PREFIX ORPO (lever 7) on Gemma e4b — DEFERRED finding (2026-06-18).
// One forward over [prompt; chosenResp; rejectedResp] with block-wise RoPE
// (setGemmaPrefixPlan) + a block-sparse, LOGICAL-window mask. e4b adds three
// wrinkles over MiniCPM5: per-layer-input, KV-shared donors, and SLIDING-window
// layers (window 512) — the last is why the mask cuts on LOGICAL positions (a
// rejected token at physical P+Rc+k has logical position P+k).
//
//   bun scripts/experiments/prefix-shared-parity-e4b.ts        # forward-only (default, cheap)
//   GRAD=1 bun scripts/experiments/prefix-shared-parity-e4b.ts # + full two-branch backward
//
// FINDING: the CONSTRUCTION is correct — the block-wise-RoPE + block-mask forward
// is BIT-EXACT to a plain forward over the same concat (proven by the companion
// scripts/experiments/prefix-shared-e4b-localize.ts: path (c) == (b) to 0.00% at
// every chosen position; per-layer-inputs bit-exact across lengths). But it does
// NOT reproduce the two-forward path on e4b — the divergence below (~0.08% loss,
// hiddens up to several %) is e4b's own LENGTH-SENSITIVITY, NOT a construction
// bug: the e4b full-forward varies ~1.7% at position 0 (one attention key, can't
// reassociate) up to ~14% later when trailing tokens are appended, even via the
// production TrainingCache, because scale=1.0 attention (headDim 256, peaked
// softmax) amplifies sub-bf16 matmul-tiling roundings that vary with row count.
// MiniCPM5 (standard 1/√d scale) shows 0.00% length-sensitivity → its prefix path
// IS bit-exact to two-forward. So this script DOCUMENTS the divergence; it does
// not gate on bit-exactness. Deferred behind the fused linear-CE head (lever 1).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model } from "../../src/model/gemma4";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { orpoLoss, orpoLossFromLogps } from "../../src/train/loss";
import { orpoLossPrefixSharedGemma, prefixSharedLogpsGemma, prefixSavings } from "../../src/train/prefix-shared";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { createCausalMask, type Cache, type Mask } from "../../src/model/gemma4-base";
import type { DpoBatch } from "../../src/train/dataset";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const P = Number(process.env.P ?? 512);
const RC = Number(process.env.RC ?? 64);
const RR = Number(process.env.RR ?? 80); // chosen/rejected different lengths on purpose
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const RANK = Number(process.env.RANK ?? 8);
const NOGRAD = process.env.GRAD !== "1"; // default forward-only (cheap); GRAD=1 runs the heavy two-branch backward
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
// Match the real e4b training path: fused-GeGLU differentiable wrapper ON (same
// for BOTH paths, so it cancels in the parity). FUSED_GELU=0 to use the spelled path.
if (process.env.FUSED_GELU !== "0") setFusedGeluTraining(true);

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

const sv = prefixSavings(P, RC, RR);
console.log(`### prefix-shared-parity-e4b  P=${P} Rc=${RC} Rr=${RR} λ=${LAMBDA} rank=${RANK}  T=${P + RC + RR}`);
console.log(`### token throughput: two-forward=${sv.twoForward} shared=${sv.shared} saving=${sv.ratio.toFixed(3)}×`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");
const numDonors = model.numDonors; // capture where the instanceof narrowing holds (lost inside closures)
console.log(`### layers=${model.layers.length} donors=${numDonors} window=${model.windowSize} reusedDonors=${[...model.reusedDonors]}`);
if (P + RC + RR <= model.windowSize)
  console.log(`### WARNING: T=${P + RC + RR} <= window ${model.windowSize} — the logical-window cut is NOT exercised; raise P.`);

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// Shared prompt + two distinct response streams.
const promptIds = Array.from({ length: P }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const chosenResp = Array.from({ length: RC }, (_, i) => ((i * 7 + 11) % 4000) + 1);
const rejectedResp = Array.from({ length: RR }, (_, i) => ((i * 17 + 3) % 4000) + 1);

// Two-forward batch: chosen = [prompt; chosenResp], rejected = [prompt; rejectedResp];
// mask marks the response span (1) vs prompt (0).
const chosenSeq = [...promptIds, ...chosenResp];
const rejectedSeq = [...promptIds, ...rejectedResp];
const chosenMask = chosenSeq.map((_, i) => (i >= P ? 1 : 0));
const rejectedMask = rejectedSeq.map((_, i) => (i >= P ? 1 : 0));
const batch: DpoBatch = {
  chosenIds: [chosenSeq], chosenMask: [chosenMask],
  rejectedIds: [rejectedSeq], rejectedMask: [rejectedMask],
};

// Array-mask two-forward reference: the SAME response-only construction as
// orpoLoss's branchLogpMean, but each branch forward forces mode "array"
// (createCausalMask, honoring the sliding window) — i.e. the SAME sdpa kernel the
// block-sparse prefix-shared path is forced onto. If prefix-shared matches THIS to
// ULPs, the concat/block-rope/logical-mask construction is exact; the residual vs
// the FUSED orpoLoss is purely the fused-causal-vs-array sdpa kernel.
class ArrayMaskCache implements Cache {
  offset = 0;
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)];
  }
  makeMask(N: number, windowSize: number | null): Mask {
    return { mode: "array", arr: createCausalMask(N, 0, windowSize) };
  }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(_n: number): void {}
  dispose(): void {}
}
// Mirrors loss.ts branchLogpMeanB1 (drop-last input, response-only head) but with
// the array-mask cache so the kernel matches the prefix-shared path.
function branchLogpMeanArrayMask(seq: number[], respStart: number): MlxArray {
  const T = seq.length - 1;
  const M = seq.length - respStart;
  const ids = MlxArray.fromInt32(new Int32Array(seq.slice(0, T)), [1, T]);
  const caches: Cache[] = Array.from({ length: numDonors }, () => new ArrayMaskCache());
  const h = model.forwardHidden(ids, caches);
  ids.dispose(); for (const c of caches) c.dispose();
  const hidden = h.shape[2]!;
  const start = MlxArray.fromInt32(new Int32Array([respStart - 1]), [1]);
  const hResp = ops.sliceDynamic(h, start, [1], [1, M, hidden]);
  h.dispose(); start.dispose();
  const logits = model.logitsFromHidden(hResp); hResp.dispose();
  const V = logits.shape[2]!;
  const l2 = ops.reshape(logits, [M, V]); logits.dispose();
  const tgt = MlxArray.fromInt32(new Int32Array(seq.slice(respStart)), [M, 1]);
  const lse = ops.logsumexpAxis(l2, -1, false);
  const picked = ops.reshape(ops.takeAlongAxis(l2, tgt, -1), [M]);
  const logp = ops.sub(picked, lse);
  const lf = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const mean = ops.reshape(ops.mulScalar(ops.sumAxis(lf, 0, false), 1 / M), [1]);
  for (const a of [l2, tgt, lse, picked, logp]) a.dispose();
  if (lf !== logp) lf.dispose();
  return mean;
}
const orpoLossArrayMask = (): MlxArray => {
  const lw = branchLogpMeanArrayMask(chosenSeq, P);
  const lr = branchLogpMeanArrayMask(rejectedSeq, P);
  const loss = orpoLossFromLogps(lw, lr, LAMBDA);
  lw.dispose(); lr.dispose();
  return loss;
};

// (1) FORWARD parity (plain, no grad) — the construction proof: the single forward
// over the concat computes the SAME ℓw/ℓr (hence loss) as the two separate forwards.
const lossTwoPlain = (() => { const l = orpoLoss(model, batch, LAMBDA); const v = l.toFloat32()[0]!; l.dispose(); return v; })();
const lossArrPlain = (() => { const l = orpoLossArrayMask(); const v = l.toFloat32()[0]!; l.dispose(); return v; })();
const lossSharedPlain = (() => { const l = orpoLossPrefixSharedGemma(model, promptIds, chosenResp, rejectedResp, LAMBDA); const v = l.toFloat32()[0]!; l.dispose(); return v; })();
const fwdRelFused = Math.abs(lossTwoPlain - lossSharedPlain) / (Math.abs(lossTwoPlain) || 1);
const fwdRel = Math.abs(lossArrPlain - lossSharedPlain) / (Math.abs(lossArrPlain) || 1); // vs SAME kernel → the construction proof
console.log(`### FORWARD (plain): fused-two=${lossTwoPlain.toFixed(6)} array-two=${lossArrPlain.toFixed(6)} shared=${lossSharedPlain.toFixed(6)}`);
console.log(`### FORWARD rel: shared-vs-array=${(fwdRel * 100).toExponential(2)}% (SAME kernel → construction)  shared-vs-fused=${(fwdRelFused * 100).toExponential(2)}% (+ causal-vs-array kernel)`);
// Per-branch ℓw/ℓr diagnostic: which branch (chosen / rejected) diverges?
{
  const arrLw = (() => { const m = branchLogpMeanArrayMask(chosenSeq, P); const v = m.toFloat32()[0]!; m.dispose(); return v; })();
  const arrLr = (() => { const m = branchLogpMeanArrayMask(rejectedSeq, P); const v = m.toFloat32()[0]!; m.dispose(); return v; })();
  const ps = prefixSharedLogpsGemma(model, promptIds, chosenResp, rejectedResp);
  console.log(`### branch ℓw: array=${arrLw.toFixed(6)} shared=${ps.lw.toFixed(6)} rel=${(Math.abs(arrLw - ps.lw) / (Math.abs(arrLw) || 1) * 100).toExponential(2)}%`);
  console.log(`### branch ℓr: array=${arrLr.toFixed(6)} shared=${ps.lr.toFixed(6)} rel=${(Math.abs(arrLr - ps.lr) / (Math.abs(arrLr) || 1) * 100).toExponential(2)}%`);
}

if (NOGRAD) {
  // Forward-only (default). Construction correctness is proven by the companion
  // localize script (prefix == plain-concat, bit-exact); HERE we quantify the
  // two-forward divergence = e4b's length-sensitivity (expected, NOT bit-exact).
  // PASS = the divergence is bounded in the e4b length-sensitivity band AND the
  // token saving holds. (A construction bug would blow past this band.)
  const BAND = 5e-3; // e4b loss-level length-sensitivity for these P/R (well above bf16-epsilon, below a real bug)
  const ok = fwdRel < BAND && sv.ratio > 1;
  console.log(`### ${ok ? "PASS" : "FAIL"} (forward-only, DEFERRED finding: two-forward divergence ${(fwdRel * 100).toExponential(2)}% = e4b length-sensitivity < ${(BAND * 100).toFixed(1)}%; construction proven by localize script; ${sv.ratio.toFixed(2)}× fewer prompt-token passes)`);
  disposeLora(lora); weights.dispose(); process.exitCode = ok ? 0 : 1;
}

if (!NOGRAD) {
  function gradsOf(label: string, lossFn: () => MlxArray): { loss: number; grads: Float32Array[]; peak: number } {
    clearCache();
    resetPeakMemory();
    const vag = new ValueAndGrad((p) => {
      const s = swap(lora, p);
      try { return lossFn(); } finally { restore(lora, s); }
    }, flatParams(lora).map((_, i) => i));
    const out = vag.apply(flatParams(lora));
    evalAll([out.value, ...out.grads]);
    const peak = peakMemory();
    const loss = out.value.toFloat32()[0]!;
    const grads = out.grads.map((g) => g.toFloat32());
    out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
    console.log(`### ${label.padEnd(12)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
    return { loss, grads, peak };
  }

  // (2) GRADIENT parity + peak/throughput.
  const two = gradsOf("TWO-FORWARD", () => orpoLoss(model, batch, LAMBDA));
  const shared = gradsOf("PREFIX-SHARE", () => orpoLossPrefixSharedGemma(model, promptIds, chosenResp, rejectedResp, LAMBDA));

  function gradRel(a: Float32Array[], b: Float32Array[]): { rel: number; maxAbs: number } {
    let d2 = 0, r2 = 0, maxAbs = 0;
    for (let i = 0; i < a.length; i++) {
      const x = a[i]!, y = b[i]!;
      for (let j = 0; j < x.length; j++) { const d = x[j]! - y[j]!; d2 += d * d; r2 += x[j]! * x[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
    }
    return { rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1), maxAbs };
  }
  const vs = gradRel(two.grads, shared.grads);
  const lossRel = Math.abs(two.loss - shared.loss) / (Math.abs(two.loss) || 1);

  // Per-target breakdown; the KV-shared donor recipients (layers 22/23 k/v_proj)
  // are the canary — a block-wise-RoPE or donor-sharing bug hits them hardest.
  const nt = lora.targets.length;
  const perTarget: { path: string; rel: number }[] = [];
  for (let t = 0; t < nt; t++) {
    let d2 = 0, r2 = 0;
    for (const gi of [t, nt + t]) {
      const a = two.grads[gi]!, b = shared.grads[gi]!;
      for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; d2 += d * d; r2 += a[j]! * a[j]!; }
    }
    perTarget.push({ path: lora.targets[t]!.modulePath, rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1) });
  }
  perTarget.sort((x, y) => y.rel - x.rel);
  console.log("### worst targets (relNorm):");
  for (const t of perTarget.slice(0, 5)) console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);
  const donorPaths = [...model.reusedDonors].flatMap((d) => [`layers.${d}.self_attn.k_proj`, `layers.${d}.self_attn.v_proj`]);
  const donorTargets = perTarget.filter((x) => donorPaths.some((p) => x.path.includes(p)));
  const donorRel = donorTargets.length ? Math.max(...donorTargets.map((x) => x.rel)) : 0;
  console.log("### donor-K/V targets (block-wise RoPE + sharing canary):");
  for (const t of donorTargets) console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);

  console.log(`### grad match (shared vs two-forward): relNorm=${(vs.rel * 100).toFixed(4)}%  maxAbs=${vs.maxAbs.toExponential(2)}  loss rel=${(lossRel * 100).toFixed(5)}%`);
  console.log(`### peak: two-forward ${gb(two.peak)} -> shared ${gb(shared.peak)}   token saving ${sv.ratio.toFixed(3)}×`);

  // DEFERRED-finding criterion (NOT bit-exactness — see header). The grads here
  // diverge from two-forward by e4b's length-sensitivity (NOT a construction bug —
  // construction proven by the localize script). PASS = the divergence is bounded
  // in the e4b length band and the saving holds. The donor-KV recipients are still
  // worth watching: a true block-wise-RoPE/sharing bug would single them out far
  // beyond the uniform length-sensitivity (donorRel ≫ overall vs.rel).
  const BAND_FWD = 5e-3, BAND_GRAD = 1.0e-1;
  const ok = fwdRel < BAND_FWD && vs.rel < BAND_GRAD && donorRel < 2 * vs.rel + 1e-3 && sv.ratio > 1;
  console.log(`### ${ok ? "PASS" : "FAIL"} (DEFERRED finding: fwd div ${(fwdRel * 100).toExponential(2)}% < ${(BAND_FWD * 100).toFixed(1)}%; grad div ${(vs.rel * 100).toFixed(2)}% (e4b length-sensitivity, not bf16-epsilon); donor-KV ${(donorRel * 100).toFixed(2)}% not singled out; ${sv.ratio.toFixed(2)}× fewer prompt-token passes)`);
  disposeLora(lora); weights.dispose(); process.exitCode = ok ? 0 : 1;
}
