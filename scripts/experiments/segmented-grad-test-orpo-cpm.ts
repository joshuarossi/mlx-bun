// Validate SegmentedBackwardOrpo (the MiniCPM5 two-branch ORPO segmented backward)
// against the monolithic ORPO value_and_grad, on the real MiniCPM5 model. This is
// the coverage gap the 2026-06-21 audit found: the e4b (Gemma4) and the
// prefix-shared variants are grad-tested, but the plain MiniCPM5 SegmentedBackwardOrpo
// was only assumed-equivalent (structurally = the proven SFT segmented path + a
// trivial chosen+rejected grad sum). MiniCPM5 has no per-layer-input / donor-KV
// sharing, so — unlike e4b — there is no cross-segment cotangent sum, and the
// segmentation should match the full backward very tightly (bf16-class at worst).
//
//   bun scripts/experiments/segmented-grad-test-orpo-cpm.ts            # flash (default)
//   ATTN=sdpa bun scripts/experiments/segmented-grad-test-orpo-cpm.ts  # ops.sdpa
//
// L is the per-branch length; chosen and rejected are given DIFFERENT lengths on
// purpose (the ORPO path must handle Lc != Lr).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, activeMemory, clearCache } from "../../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { setTrainingAttn } from "../../src/model/flash-attention";
import { orpoLoss } from "../../src/train/loss";
import { SegmentedBackwardOrpo, planSegmentsBySize } from "../../src/train/segmented";
import type { DpoBatch } from "../../src/train/dataset";
import type { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const L = Number(process.env.L ?? 256);
const SEG = Number(process.env.SEG ?? 4);
const RANK = Number(process.env.RANK ?? 8);
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const ATTN = process.env.ATTN === "sdpa" ? "sdpa" : "flash";
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
if (ATTN === "flash") setTrainingAttn("flash");

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

console.log(`### segmented-grad-test-orpo-cpm  L=${L} segSize=${SEG} rank=${RANK} λ=${LAMBDA} attn=${ATTN}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");
const nLayers = model.layers.length;

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");
const ranges: [number, number][] = process.env.RANGES
  ? (JSON.parse(process.env.RANGES) as [number, number][])
  : planSegmentsBySize(nLayers, SEG);
console.log(`### layers=${nLayers} lora targets=${lora.targets.length} segments=${ranges.length}`);

// Chosen and rejected with DIFFERENT lengths (Lc != Lr); mask marks the response
// half (the response-only NLL convention).
const Lc = L, Lr = Math.max(2, L - 17);
const V = config.text.vocabSize;
const mkRow = (len: number, salt: number) => {
  const ids = Array.from({ length: len }, (_, i) => ((i * 13 + 5 + salt) % Math.min(4000, V - 1)) + 1);
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
clearCache();
resetPeakMemory();
const vag = new ValueAndGrad((p) => {
  const s = swap(lora, p);
  try { return orpoLoss(model, batch, LAMBDA); } finally { restore(lora, s); }
}, flatParams(lora).map((_, i) => i));
const full = vag.apply(flatParams(lora));
evalAll([full.value, ...full.grads]);
const refPeak = peakMemory();
const refLoss = full.value.toFloat32()[0]!;
const refGrads = full.grads.map((g) => g.toFloat32());
full.value.dispose(); full.grads.forEach((g) => g.dispose()); vag.dispose();
console.log(`### FULL  loss=${refLoss.toFixed(6)}  PEAK(live)=${gb(refPeak)}`);

// --- segmented ORPO ---
clearCache();
resetPeakMemory();
const sb = new SegmentedBackwardOrpo(model, lora, ranges, LAMBDA);
const seg = sb.step(batch);
evalAll([seg.value, ...seg.grads]);
const segPeak = peakMemory();
const segLoss = seg.value.toFloat32()[0]!;
const segGrads = seg.grads.map((g) => g.toFloat32());
seg.value.dispose(); seg.grads.forEach((g) => g.dispose()); sb.dispose();
console.log(`### SEG   loss=${segLoss.toFixed(6)}  PEAK(live)=${gb(segPeak)}  active=${gb(activeMemory())}`);

// --- compare (relative Frobenius norm over all grads) ---
let sumDiff2 = 0, sumRef2 = 0, maxAbs = 0;
for (let i = 0; i < refGrads.length; i++) {
  const a = refGrads[i]!, b = segGrads[i]!;
  if (a.length !== b.length) throw new Error(`grad ${i} length mismatch ${a.length} vs ${b.length}`);
  for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; sumDiff2 += d * d; sumRef2 += a[j]! * a[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
}
const relNorm = Math.sqrt(sumDiff2) / (Math.sqrt(sumRef2) || 1);
const lossRel = Math.abs(refLoss - segLoss) / (Math.abs(refLoss) || 1);

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
console.log(`### grad match (vs full ORPO value_and_grad): relNorm=${(relNorm * 100).toFixed(4)}%  maxAbs=${maxAbs.toExponential(3)}`);
console.log(`### loss rel=${(lossRel * 100).toFixed(6)}%   peak: full ${gb(refPeak)} -> seg ${gb(segPeak)} (saved ${gb(refPeak - segPeak)})`);

// PASS criterion: MiniCPM5 has no donor-KV cross-segment sum, so segmentation is
// the proven SFT mechanism + a chosen+rejected grad add — it should match the full
// backward very tightly. The forward (loss) is exact; grads are bf16-class from the
// boundary copies + cross-branch sum. Thresholds are generous to catch a structural
// bug (which shows as a LARGE relNorm), not to assert a number we haven't pinned yet.
const OVERALL = ATTN === "flash" ? 1e-2 : 2e-2;
const okLoss = lossRel < 1e-4;
const okOverall = relNorm < OVERALL;
const ok = okLoss && okOverall;
console.log(`### loss ${okLoss ? "OK" : "BAD"} (<0.01%); grads ${okOverall ? "OK" : "BAD"} (<${OVERALL} bf16-class for attn=${ATTN})`);
console.log(`### ${ok ? "PASS" : "FAIL"} — segmented MiniCPM5 ORPO matches the full backward (loss exact, grads bf16-class)`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
