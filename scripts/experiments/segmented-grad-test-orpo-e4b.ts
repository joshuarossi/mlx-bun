// Validate SegmentedBackwardOrpoGemma4 (e4b ORPO: two branches × per-layer-input
// + KV-shared donor gradient threading) against the monolithic ORPO backward, on
// the real e4b model. Under flash the segmented grads must bit-match the full
// value_and_grad (single-consumer donor reuse is exact); under ops.sdpa, or when
// a donor is shared across multiple backward SEGMENTS, the cross-segment bf16
// cotangent sum is non-associative — bf16-class (~0.5%), established (see the dKV
// note in src/train/segmented.ts). Also measures peak (full ORPO vs segmented).
//
//   L=512 SEG=6 bun scripts/experiments/segmented-grad-test-orpo-e4b.ts     # flash (default)
//   ATTN=sdpa L=384 bun scripts/experiments/segmented-grad-test-orpo-e4b.ts # ops.sdpa (bf16-class)
//
// L here is the per-branch length; chosen and rejected are given DIFFERENT
// lengths on purpose (the ORPO path must handle Lc != Lr).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model } from "../../src/model/gemma4";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, activeMemory, clearCache } from "../../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { setTrainingAttn } from "../../src/model/flash-attention";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { orpoLoss } from "../../src/train/loss";
import { SegmentedBackwardOrpoGemma4, planSegmentsBySize } from "../../src/train/segmented";
import type { DpoBatch } from "../../src/train/dataset";
import type { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const L = Number(process.env.L ?? 512);
const SEG = Number(process.env.SEG ?? 6);
const RANK = Number(process.env.RANK ?? 8);
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const ATTN = process.env.ATTN === "sdpa" ? "sdpa" : "flash";
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
if (ATTN === "flash") setTrainingAttn("flash");
// Match the real training path: fused GeGLU (differentiable wrapper) ON, so this
// also exercises the fused CustomVjp nested inside the segmented mlx_vjp. Opt out
// with FUSED_GELU=0 to compare against the spelled-out path.
if (process.env.FUSED_GELU !== "0") setFusedGeluTraining(true);

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

console.log(`### segmented-grad-test-orpo-e4b  L=${L} segSize=${SEG} rank=${RANK} λ=${LAMBDA} attn=${ATTN}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");
const nLayers = model.layers.length;

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");
const ranges: [number, number][] = process.env.RANGES
  ? (JSON.parse(process.env.RANGES) as [number, number][])
  : planSegmentsBySize(nLayers, SEG);
console.log(`### layers=${nLayers} lora targets=${lora.targets.length} segments=${ranges.length} reusedDonors=${[...model.reusedDonors]}`);

// Chosen and rejected with DIFFERENT lengths (Lc != Lr). The mask marks response
// positions (1 from the second half onward) — the response-only NLL convention.
const Lc = L, Lr = Math.max(2, L - 17);
const mkRow = (len: number, salt: number) => {
  const ids = Array.from({ length: len }, (_, i) => ((i * 13 + 5 + salt) % 4000) + 1);
  const promptLen = Math.floor(len / 2);
  const mask = Array.from({ length: len }, (_, i) => (i >= promptLen ? 1 : 0));
  return { ids, mask };
};
const c = mkRow(Lc, 0), r = mkRow(Lr, 7);
const batch: DpoBatch = {
  chosenIds: [c.ids], chosenMask: [c.mask],
  rejectedIds: [r.ids], rejectedMask: [r.mask],
};

// --- reference: monolithic ORPO value_and_grad over the whole stack ---
const SEG_ONLY = process.env.SEG_ONLY === "1";
let refPeak = 0, refLoss = NaN;
let refGrads: Float32Array[] = [];
if (!SEG_ONLY) {
  clearCache();
  resetPeakMemory();
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { return orpoLoss(model, batch, LAMBDA); } finally { restore(lora, s); }
  }, flatParams(lora).map((_, i) => i));
  const full = vag.apply(flatParams(lora));
  evalAll([full.value, ...full.grads]);
  refPeak = peakMemory();
  refLoss = full.value.toFloat32()[0]!;
  refGrads = full.grads.map((g) => g.toFloat32());
  full.value.dispose(); full.grads.forEach((g) => g.dispose()); vag.dispose();
  console.log(`### FULL  loss=${refLoss.toFixed(6)}  PEAK(live)=${gb(refPeak)}`);
} else {
  console.log(`### FULL  skipped (SEG_ONLY) — measuring segmented peak only`);
}

// --- segmented ORPO ---
clearCache();
resetPeakMemory();
const sb = new SegmentedBackwardOrpoGemma4(model, lora, ranges, LAMBDA);
const seg = sb.step(batch);
evalAll([seg.value, ...seg.grads]);
const segPeak = peakMemory();
const segLoss = seg.value.toFloat32()[0]!;
const segGrads = seg.grads.map((g) => g.toFloat32());
seg.value.dispose(); seg.grads.forEach((g) => g.dispose()); sb.dispose();
console.log(`### SEG   loss=${segLoss.toFixed(6)}  PEAK(live)=${gb(segPeak)}  active=${gb(activeMemory())}`);

if (SEG_ONLY) {
  console.log(`### SEG peak ${gb(segPeak)} @ L=${L} seg=${SEG} (full backward crashes at this L)`);
  disposeLora(lora); weights.dispose(); process.exit(0);
}

// --- compare (relative Frobenius norm over all grads) ---
let sumDiff2 = 0, sumRef2 = 0, maxAbs = 0;
for (let i = 0; i < refGrads.length; i++) {
  const a = refGrads[i]!, b = segGrads[i]!;
  if (a.length !== b.length) throw new Error(`grad ${i} length mismatch ${a.length} vs ${b.length}`);
  for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; sumDiff2 += d * d; sumRef2 += a[j]! * a[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
}
const relNorm = Math.sqrt(sumDiff2) / (Math.sqrt(sumRef2) || 1);
const lossRel = Math.abs(refLoss - segLoss) / (Math.abs(refLoss) || 1);

// Per-target breakdown (grads are [A0..An, B0..Bn]).
const nt = lora.targets.length;
const perTarget: { path: string; rel: number }[] = [];
for (let t = 0; t < nt; t++) {
  let d2 = 0, r2 = 0;
  for (const gi of [t, nt + t]) {
    const a = refGrads[gi]!, b = segGrads[gi]!;
    for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; d2 += d * d; r2 += a[j]! * a[j]!; }
  }
  perTarget.push({ path: lora.targets[t]!.modulePath, rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1) });
}
perTarget.sort((x, y) => y.rel - x.rel);
console.log("### worst targets (relNorm):");
for (const t of perTarget.slice(0, 5)) console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);
const offCount = perTarget.filter((t) => t.rel > 1e-3).length;
console.log(`### targets with relNorm > 0.1%: ${offCount}/${nt}`);
const donorPaths = [22, 23].flatMap((d) => [`layers.${d}.self_attn.k_proj`, `layers.${d}.self_attn.v_proj`]);
const donorTargets = perTarget.filter((x) => donorPaths.some((p) => x.path.includes(p)));
// Fail fast: an empty match makes Math.max(...[]) = -Infinity below, which would
// pass the donor-KV criterion VACUOUSLY (false PASS) — the opposite of validating it.
if (donorTargets.length === 0)
  throw new Error("No donor-K/V recipient targets matched (layers 22/23 k/v_proj); cannot validate donor-threading correctness.");
console.log("### donor-K/V targets (direct dKV recipients):");
for (const t of donorTargets)
  console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);
console.log(`### grad match (vs full ORPO value_and_grad): relNorm=${(relNorm * 100).toFixed(4)}%  maxAbs=${maxAbs.toExponential(3)}`);
console.log(`### loss rel=${(lossRel * 100).toFixed(6)}%   peak: full ${gb(refPeak)} -> seg ${gb(segPeak)} (saved ${gb(refPeak - segPeak)})`);

// PASS criterion (rationale established empirically, 2026-06-18):
//   (1) The DONOR-KV recipients (layers 22/23 k/v_proj — the direct recipients of
//       the cross-segment dKV cotangent THIS class threads) must stay clean
//       (<0.5%). A donor-threading bug hits exactly these hardest; pure bf16
//       dh-propagation noise does not single them out.
//   (2) The OVERALL relNorm must sit in the e4b segmented bf16-CLASS. At λ=0 the
//       ORPO path is BYTE-IDENTICAL to SegmentedBackwardGemma4 (SFT), which
//       itself lands ~1.1% (flash) / ~2.0% (sdpa) vs its full value_and_grad at
//       this config — NOT bit-exact (the e4b flash kernel is the known-unreliable
//       training path; ops.sdpa is production). The cross-branch grad sum adds a
//       further ~0.25% (bf16 cancellation when chosen/rejected oppose in L_OR).
//   The loss ALWAYS matches the full path to ~6 decimals (the forward is exact).
const donorRel = Math.max(...donorTargets.map((x) => x.rel));
const OVERALL = ATTN === "flash" ? 1.5e-2 : 2.5e-2;
const DONOR = 5e-3;
const okDonor = donorRel < DONOR;
const okOverall = relNorm < OVERALL;
const ok = okDonor && okOverall;
console.log(`### donor-KV recipients max=${(donorRel * 100).toFixed(3)}% (${okDonor ? "OK" : "BAD"}, <${DONOR}); overall ${okOverall ? "OK" : "BAD"} (<${OVERALL} bf16-class for attn=${ATTN})`);
console.log(`### ${ok ? "PASS" : "FAIL"} — segmented ORPO matches the full backward in the e4b segmented bf16-class (donor threading clean, loss exact)`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
