// Validate the FUSED linear-CE head wired INSIDE the segmented ORPO backward.
// Compares SegmentedBackwardOrpo with the full-[M,V] head (fusedChunkSize=0) vs
// the fused token-chunked analytic head (fusedChunkSize>0): the grads must match
// within the bf16 class (the head forward is bit-exact; the backward differs only
// by bf16 reassociation), and the peak must drop (the head term is bounded to
// [chunk,V] on TOP of the per-segment layer savings — ORPO pressure compounds:
// layers + response length + head).
//
//   bun scripts/experiments/segmented-fused-ce-orpo.ts            # MiniCPM5 (no softcap)
//   E4B=1 L=512 SEG=6 bun scripts/experiments/segmented-fused-ce-orpo.ts  # gemma e4b (softcap)
//
// MiniCPM5 default; long responses (the head [M,V] term is what fused bounds).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { Gemma4Model } from "../../src/model/gemma4";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import { buildTrainableLora, attachForTraining, disposeLora } from "../../src/train/lora-params";
import { SegmentedBackwardOrpo, SegmentedBackwardOrpoGemma4, planSegmentsBySize } from "../../src/train/segmented";
import type { DpoBatch } from "../../src/train/dataset";
import type { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const baseDir = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${baseDir}/${readdirSync(baseDir)[0]}`;
const L = Number(process.env.L ?? (E4B ? 512 : 768)); // per-branch length (half prompt, half response)
const SEG = Number(process.env.SEG ?? 6);
const CHUNK = Number(process.env.CHUNK ?? 256);
const RANK = Number(process.env.RANK ?? 8);
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
if (process.env.FUSED_GELU !== "0") setFusedGeluTraining(true);

console.log(`### segmented-fused-ce-orpo  model=${E4B ? "e4b" : "MiniCPM5"} L=${L} seg=${SEG} chunk=${CHUNK} rank=${RANK}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const nLayers = model.layers.length;
const ranges = planSegmentsBySize(nLayers, SEG);
const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// chosen/rejected with different lengths; mask marks the response span (second half).
const mkRow = (len: number, salt: number) => {
  const ids = Array.from({ length: len }, (_, i) => ((i * 13 + 5 + salt) % 4000) + 1);
  const promptLen = Math.floor(len / 2);
  const mask = Array.from({ length: len }, (_, i) => (i >= promptLen ? 1 : 0));
  return { ids, mask };
};
const c = mkRow(L, 0), r = mkRow(Math.max(2, L - 17), 7);
const batch: DpoBatch = {
  chosenIds: [c.ids], chosenMask: [c.mask], rejectedIds: [r.ids], rejectedMask: [r.mask],
};

function run(fusedChunk: number): { loss: number; grads: Float32Array[]; peak: number } {
  clearCache();
  resetPeakMemory();
  const sb = E4B
    ? new SegmentedBackwardOrpoGemma4(model as Gemma4Model, lora, ranges, LAMBDA, fusedChunk)
    : new SegmentedBackwardOrpo(model as MiniCPM5Model, lora, ranges, LAMBDA, fusedChunk);
  const out = sb.step(batch);
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g: MlxArray) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g: MlxArray) => g.dispose()); sb.dispose();
  console.log(`### ${(fusedChunk > 0 ? `FUSED(${fusedChunk})` : "FULL head").padEnd(14)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

const full = run(0);
const fused = run(CHUNK);

let d2 = 0, r2 = 0, maxAbs = 0;
for (let i = 0; i < full.grads.length; i++) {
  const a = full.grads[i]!, b = fused.grads[i]!;
  for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; d2 += d * d; r2 += a[j]! * a[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
}
const rel = Math.sqrt(d2) / (Math.sqrt(r2) || 1);
const lossRel = Math.abs(full.loss - fused.loss) / (Math.abs(full.loss) || 1);
console.log(`### loss rel=${(lossRel * 100).toExponential(2)}%   grad relNorm=${(rel * 100).toFixed(4)}%  maxAbs=${maxAbs.toExponential(2)}`);
console.log(`### peak: full-head ${gb(full.peak)} -> fused-head ${gb(fused.peak)} (saved ${gb(full.peak - fused.peak)})`);

// PASS: head forward is bit-exact (loss matches to ~bf16), grads in the bf16 class,
// fused peak not worse (and lower when the head term is significant).
const GRAD = E4B ? 2.5e-2 : 1.5e-2;
const ok = lossRel < 1e-3 && rel < GRAD && fused.peak <= full.peak * 1.02;
console.log(`### ${ok ? "PASS" : "FAIL"} (loss ${lossRel < 1e-3 ? "exact" : "DIVERGED"}; grads ${(rel * 100).toFixed(2)}% < ${(GRAD * 100).toFixed(1)}%; peak ${fused.peak <= full.peak * 1.02 ? "ok" : "WORSE"})`);
disposeLora(lora); weights.dispose();
process.exitCode = ok ? 0 : 1;
