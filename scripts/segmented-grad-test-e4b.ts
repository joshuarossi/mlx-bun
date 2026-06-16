// Validate SegmentedBackwardGemma4 (e4b: per-layer-input + KV-shared donor
// gradient threading) against the full backward, on the real e4b model. Under
// flash the segmented grads must bit-match the full value_and_grad (the donor-KV
// second-boundary-stream cotangent accumulation is exact). Also measures peak.
//
//   L=512 SEG=6 bun scripts/segmented-grad-test-e4b.ts            # flash (default)
//   ATTN=sdpa L=384 bun scripts/segmented-grad-test-e4b.ts        # ops.sdpa (bf16-class)

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { Gemma4Model } from "../src/model/gemma4";
import { ValueAndGrad } from "../src/mlx/autograd";
import { evalAll } from "../src/mlx/ops";
import { peakMemory, resetPeakMemory, activeMemory, clearCache } from "../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../src/train/lora-params";
import { setTrainingAttn } from "../src/model/flash-attention";
import { sftLoss } from "../src/train/loss";
import { SegmentedBackwardGemma4, planSegmentsBySize } from "../src/train/segmented";
import type { SftBatch } from "../src/train/dataset";
import type { MlxArray } from "../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const L = Number(process.env.L ?? 512);
const SEG = Number(process.env.SEG ?? 6);
const RANK = Number(process.env.RANK ?? 8);
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

console.log(`### segmented-grad-test-e4b  L=${L} segSize=${SEG} rank=${RANK} attn=${ATTN}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");
const nLayers = model.layers.length;

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");
const ranges = planSegmentsBySize(nLayers, SEG);
console.log(`### layers=${nLayers} lora targets=${lora.targets.length} segments=${ranges.length} reusedDonors=${[...model.reusedDonors]}`);

const ids = Array.from({ length: L }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const batch: SftBatch = { ids: [ids], promptLens: [Math.floor(L / 2)] };

// --- reference: full value_and_grad over the whole stack (skipped for SEG_ONLY,
// e.g. at long context where the full backward crashes) ---
const SEG_ONLY = process.env.SEG_ONLY === "1";
let refPeak = 0, refLoss = NaN;
let refGrads: Float32Array[] = [];
if (!SEG_ONLY) {
  clearCache();
  resetPeakMemory();
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { return sftLoss(model, batch); } finally { restore(lora, s); }
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

// --- segmented ---
clearCache();
resetPeakMemory();
const sb = new SegmentedBackwardGemma4(model, lora, ranges);
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

// Per-target breakdown: which LoRA leaves are off? grads are [A0..An, B0..Bn].
const nt = lora.targets.length;
const perTarget: { path: string; rel: number }[] = [];
for (let t = 0; t < nt; t++) {
  let d2 = 0, r2 = 0;
  for (const gi of [t, nt + t]) { // A leaf and B leaf
    const a = refGrads[gi]!, b = segGrads[gi]!;
    for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; d2 += d * d; r2 += a[j]! * a[j]!; }
  }
  perTarget.push({ path: lora.targets[t]!.modulePath, rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1) });
}
perTarget.sort((x, y) => y.rel - x.rel);
console.log("### worst targets (relNorm):");
for (const t of perTarget.slice(0, 10)) console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);
const offCount = perTarget.filter((t) => t.rel > 1e-3).length;
console.log(`### targets with relNorm > 0.1%: ${offCount}/${nt}`);
console.log(`### grad match (vs full value_and_grad): relNorm=${(relNorm * 100).toFixed(4)}%  maxAbs=${maxAbs.toExponential(3)}`);
console.log(`### loss rel=${(lossRel * 100).toFixed(6)}%   peak: full ${gb(refPeak)} -> seg ${gb(segPeak)} (saved ${gb(refPeak - segPeak)})`);
const PASS = ATTN === "flash" ? 1e-3 : 1e-2;
const ok = relNorm < PASS;
console.log(`### ${ok ? "PASS" : "FAIL"} (attn=${ATTN}: grad relNorm ${relNorm < PASS ? "<" : ">="} ${PASS})`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
