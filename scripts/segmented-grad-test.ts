// Validate the segmented-backward SFT path on the real MiniCPM5 model:
//   (1) grads bit-match a single full value_and_grad over the whole stack,
//   (2) the loss value matches,
//   (3) peak (live) memory drops vs the full backward.
// Proof harness for Phase A of docs/design/segmented-backward-training.md.
//
//   SEQ=512  SEG=4  bun scripts/segmented-grad-test.ts      # quick correctness
//   SEQ=2048 SEG=4  bun scripts/segmented-grad-test.ts      # memory delta
//
// MODEL defaults to MiniCPM5-1B-OptiQ-4bit. Synthetic batch (arbitrary valid
// token ids) — this is a gradient-equivalence + memory test, not a quality run.

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { MiniCPM5Model } from "../src/model/minicpm5";
import { ValueAndGrad } from "../src/mlx/autograd";
import { evalAll } from "../src/mlx/ops";
import {
  peakMemory, resetPeakMemory, activeMemory, clearCache,
} from "../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora,
  type TrainableLora,
} from "../src/train/lora-params";
import { setTrainingAttn } from "../src/model/flash-attention";
import { sftLoss } from "../src/train/loss";
import { SegmentedBackward, planSegmentsBySize } from "../src/train/segmented";
import type { SftBatch } from "../src/train/dataset";
import type { MlxArray } from "../src/mlx/array";

const HOME = process.env.HOME!;
function resolveModel(): string {
  if (process.env.MODEL) return process.env.MODEL;
  const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
  return `${base}/${readdirSync(base)[0]}`;
}

const MODEL = resolveModel();
const SEQ = Number(process.env.SEQ ?? 512);
const SEG = Number(process.env.SEG ?? 4);
const RANK = Number(process.env.RANK ?? 8);
const PROMPT_FRAC = Number(process.env.PROMPT_FRAC ?? 0.5);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;

// --- swap helpers (mirror trainer.ts swapPrimals/restorePrimals) ----------
function swapPrimals(lora: TrainableLora, primals: MlxArray[]): MlxArray[] {
  const n = lora.targets.length;
  const saved: MlxArray[] = [];
  for (let i = 0; i < n; i++) {
    saved.push(lora.targets[i]!.lw.a, lora.targets[i]!.lw.b);
    lora.targets[i]!.lw.a = primals[i]!;
    lora.targets[i]!.lw.b = primals[n + i]!;
  }
  return saved;
}
function restorePrimals(lora: TrainableLora, saved: MlxArray[]): void {
  for (let i = 0; i < lora.targets.length; i++) {
    lora.targets[i]!.lw.a = saved[2 * i]!;
    lora.targets[i]!.lw.b = saved[2 * i + 1]!;
  }
}

// Attention path. ops.sdpa (default) has a fused-eager vs autograd-forward
// divergence in bf16 (~0.12%); flash uses one forward for both, so segmented is
// bit-exact under it. See docs/design/segmented-backward-training.md §"forward
// fidelity".
const ATTN = process.env.TRAIN_ATTN === "flash" ? "flash" : "sdpa";
if (ATTN === "flash") setTrainingAttn("flash");

const LEAK_LOOP = Number(process.env.LEAK_LOOP ?? 0);
console.log(`### segmented-grad-test  model=MiniCPM5-1B  seq=${SEQ} segSize=${SEG} rank=${RANK} attn=${ATTN}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");
const nLayers = model.layers.length;

// LoRA over all layers (the trainer's default targets/scaling).
const ranks = resolveRanks(model, {
  rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1,
});
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");
console.log(`### layers=${nLayers}  lora targets=${lora.targets.length}  params=${2 * lora.targets.length}`);

// Synthetic B=1 batch: deterministic valid token ids, half prompt / half response.
const ids = Array.from({ length: SEQ }, (_, i) => ((i * 7 + 3) % 2000) + 1);
const promptLen = Math.max(1, Math.floor(SEQ * PROMPT_FRAC));
const batch: SftBatch = { ids: [ids], promptLens: [promptLen] };

// Leak isolation: call segmentedSftGrads in a loop, dispose ALL outputs, no
// optimizer. If active grows, the leak is inside segmentedSftGrads itself.
if (LEAK_LOOP > 0) {
  const sb = new SegmentedBackward(model, lora, planSegmentsBySize(nLayers, SEG));
  for (let i = 0; i < LEAK_LOOP; i++) {
    const r = sb.step(batch);
    r.value.dispose();
    r.grads.forEach((g) => g.dispose());
    clearCache();
    console.log(`### leak iter ${i}: active=${gb(activeMemory())}`);
  }
  sb.dispose();
  disposeLora(lora);
  weights.dispose();
  process.exit(0);
}

// --- true (eager) loss: what the model actually computes at inference -------
const eager = sftLoss(model, batch);
eager.eval();
const eagerLoss = eager.toFloat32()[0]!;
eager.dispose();
clearCache();

// --- reference: one full value_and_grad over the whole stack ---------------
resetPeakMemory();
const vag = new ValueAndGrad((primals) => {
  const saved = swapPrimals(lora, primals);
  try {
    return sftLoss(model, batch);
  } finally {
    restorePrimals(lora, saved);
  }
}, flatParams(lora).map((_, i) => i));
const full = vag.apply(flatParams(lora));
evalAll([full.value, ...full.grads]);
const refPeak = peakMemory();
const refLoss = full.value.toFloat32()[0]!;
const refGrads = full.grads.map((g) => g.toFloat32());
full.value.dispose();
full.grads.forEach((g) => g.dispose());
vag.dispose();
console.log(`### EAGER    loss=${eagerLoss.toFixed(6)}  (true forward; value_and_grad forward differs under ops.sdpa)`);
console.log(`### FULL     loss=${refLoss.toFixed(6)}  PEAK(live)=${gb(refPeak)}  active=${gb(activeMemory())}`);

// --- segmented backward ----------------------------------------------------
clearCache();
resetPeakMemory();
const ranges = planSegmentsBySize(nLayers, SEG);
const sb = new SegmentedBackward(model, lora, ranges);
const seg = sb.step(batch);
evalAll([seg.value, ...seg.grads]);
const segPeak = peakMemory();
const segLoss = seg.value.toFloat32()[0]!;
const segGrads = seg.grads.map((g) => g.toFloat32());
seg.value.dispose();
seg.grads.forEach((g) => g.dispose());
sb.dispose();
console.log(`### SEG(${SEG})   loss=${segLoss.toFixed(6)}  PEAK(live)=${gb(segPeak)}  active=${gb(activeMemory())}  (${ranges.length} segments)`);

// --- compare ---------------------------------------------------------------
// Relative Frobenius norm ||seg - ref|| / ||ref|| over ALL grads (robust to the
// near-zero A grads at step 0 — B=0 -> dA=0 -> per-element rel explodes). Also
// the worst single B-grad target as a sanity check, and overall magnitudes.
let sumDiff2 = 0, sumRef2 = 0, maxAbs = 0;
for (let i = 0; i < refGrads.length; i++) {
  const a = refGrads[i]!, b = segGrads[i]!;
  if (a.length !== b.length) throw new Error(`grad ${i} length mismatch ${a.length} vs ${b.length}`);
  for (let j = 0; j < a.length; j++) {
    const d = a[j]! - b[j]!;
    sumDiff2 += d * d;
    sumRef2 += a[j]! * a[j]!;
    if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d);
  }
}
const relNorm = Math.sqrt(sumDiff2) / (Math.sqrt(sumRef2) || 1);
const refRms = Math.sqrt(sumRef2 / refGrads.reduce((s, g) => s + g.length, 0));
const lossRelEager = Math.abs(eagerLoss - segLoss) / (Math.abs(eagerLoss) || 1);
const lossRelVag = Math.abs(refLoss - segLoss) / (Math.abs(refLoss) || 1);

console.log(`### grad match (vs full value_and_grad): relNorm=${(relNorm * 100).toFixed(4)}%  maxAbs=${maxAbs.toExponential(3)}  (ref grad rms=${refRms.toExponential(3)})`);
console.log(`### loss: seg=${segLoss.toFixed(6)}  vs eager(true)=${eagerLoss.toFixed(6)} -> rel ${(lossRelEager * 100).toFixed(6)}%  |  vs value_and_grad=${refLoss.toFixed(6)} -> rel ${(lossRelVag * 100).toFixed(6)}%`);
const peakDelta = refPeak - segPeak;
console.log(`### peak delta: full ${gb(refPeak)} -> seg ${gb(segPeak)}  (${peakDelta >= 0 ? "saved" : "ADDED"} ${gb(Math.abs(peakDelta))})`);

// Mechanism is exact when the attention forward is consistent eager-vs-autograd
// (flash). Under ops.sdpa, expect a bf16-class relNorm (~0.1-0.5%) from the
// fused-vs-autograd forward divergence, NOT from the segmentation.
const PASS_REL = ATTN === "flash" ? 1e-3 : 5e-3;
const ok = relNorm < PASS_REL && lossRelEager < 1e-4;
console.log(`### ${ok ? "PASS" : "FAIL"} (attn=${ATTN}: grad relNorm ${relNorm < PASS_REL ? "<" : ">="} ${PASS_REL}, seg loss matches eager forward ${lossRelEager < 1e-4 ? "✓" : "✗"})`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
