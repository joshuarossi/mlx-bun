// Localize the segmented-vs-full loss discrepancy: compute the SFT loss through
// several forward variants and compare. No LoRA (base model) to isolate.

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { MiniCPM5Model } from "../src/model/minicpm5";
import * as ops from "../src/mlx/ops";
import { MlxArray } from "../src/mlx/array";
import { TrainingCache } from "../src/train/forward";
import { sftLoss, responseOnlyCe } from "../src/train/loss";
import type { SftBatch } from "../src/train/dataset";
import type { Cache } from "../src/model/gemma4-base";
import { ValueAndGrad } from "../src/mlx/autograd";
import { evalAll } from "../src/mlx/ops";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, type TrainableLora,
} from "../src/train/lora-params";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const SEQ = Number(process.env.SEQ ?? 512);

if (process.env.TRAIN_ATTN === "flash") {
  const { setTrainingAttn } = await import("../src/model/flash-attention");
  setTrainingAttn("flash");
  console.log("### training attention = flash");
}

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");
const nLayers = model.layers.length;

const ids = Array.from({ length: SEQ }, (_, i) => ((i * 7 + 3) % 2000) + 1);
const batch: SftBatch = { ids: [ids], promptLens: [Math.floor(SEQ / 2)] };

const T = SEQ - 1;
const inputHost = new Int32Array(T);
for (let t = 0; t < T; t++) inputHost[t] = ids[t]!;

function lossVariant(detach: boolean): number {
  const inputIds = MlxArray.fromInt32(inputHost, [1, T]);
  const caches: Cache[] = Array.from({ length: nLayers }, () => new TrainingCache());
  let h = model.embed.encode(inputIds);
  if (detach) { const d = ops.stopGradient(h); h.dispose(); h = d; h.eval(); }
  const layerOut = model.runLayerRange(h, 0, nLayers, caches);
  h.dispose();
  let lo = layerOut;
  if (detach) { const d = ops.stopGradient(lo); lo.dispose(); lo = d; lo.eval(); }
  const hn = model.finalNorm.forward(lo);
  lo.dispose();
  const loss = responseOnlyCe(model, hn, batch);
  hn.dispose();
  loss.eval();
  const v = loss.toFloat32()[0]!;
  loss.dispose();
  inputIds.dispose();
  for (const c of caches) c.dispose();
  return v;
}

// A: the reference path (sftLoss).
const a = sftLoss(model, batch);
a.eval();
const refLoss = a.toFloat32()[0]!;
a.dispose();

// B: manual embed -> runLayerRange -> finalNorm -> responseOnlyCe (NO detach).
const manualLoss = lossVariant(false);
// C: same but detach+eval at boundaries (segmented-style).
const detachLoss = lossVariant(true);

console.log(`A sftLoss (reference, NO lora)    = ${refLoss.toFixed(6)}`);
console.log(`B manual runLayerRange (nodetach)= ${manualLoss.toFixed(6)}  rel=${(Math.abs(manualLoss - refLoss) / refLoss * 100).toFixed(6)}%`);
console.log(`C manual + detach/eval boundaries= ${detachLoss.toFixed(6)}  rel=${(Math.abs(detachLoss - refLoss) / refLoss * 100).toFixed(6)}%`);

// --- now ATTACH lora (rank 8, b=0) and re-measure ----------------------------
const ranks = resolveRanks(model, {
  rank: 8, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1,
});
const lora: TrainableLora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// D: sftLoss with lora active (b=0 -> residual should be 0 -> base loss).
const d = sftLoss(model, batch); d.eval();
const loraDirect = d.toFloat32()[0]!; d.dispose();

// E: through the trainer's swap closure, OUTSIDE value_and_grad.
function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}
const saved = swap(lora, flatParams(lora));
const e = sftLoss(model, batch); e.eval();
const swapDirect = e.toFloat32()[0]!; e.dispose();
restore(lora, saved);

// F: through value_and_grad (the exact reference path in grad-test).
const vag = new ValueAndGrad((primals) => {
  const s = swap(lora, primals);
  try { return sftLoss(model, batch); } finally { restore(lora, s); }
}, flatParams(lora).map((_, i) => i));
const f = vag.apply(flatParams(lora));
evalAll([f.value]);
const vagValue = f.value.toFloat32()[0]!;
f.value.dispose(); f.grads.forEach((g) => g.dispose()); vag.dispose();

// F2: value_and_grad value with lora scale forced to 0 (kills the lora graph).
const { setLoraScale } = await import("../src/train/lora-params");
setLoraScale(lora, 0);
const vag2 = new ValueAndGrad((primals) => {
  const s = swap(lora, primals);
  try { return sftLoss(model, batch); } finally { restore(lora, s); }
}, flatParams(lora).map((_, i) => i));
const f2 = vag2.apply(flatParams(lora));
evalAll([f2.value]);
const vagScale0 = f2.value.toFloat32()[0]!;
f2.value.dispose(); f2.grads.forEach((g) => g.dispose()); vag2.dispose();
setLoraScale(lora, 1.0);

console.log(`D sftLoss + lora attached (b=0)  = ${loraDirect.toFixed(6)}  rel=${(Math.abs(loraDirect - refLoss) / refLoss * 100).toFixed(6)}%`);
console.log(`E sftLoss via swap closure (b=0) = ${swapDirect.toFixed(6)}  rel=${(Math.abs(swapDirect - refLoss) / refLoss * 100).toFixed(6)}%`);
console.log(`F value_and_grad value (b=0)     = ${vagValue.toFixed(6)}  rel=${(Math.abs(vagValue - refLoss) / refLoss * 100).toFixed(6)}%`);
console.log(`F2 value_and_grad value (scale=0)= ${vagScale0.toFixed(6)}  rel=${(Math.abs(vagScale0 - refLoss) / refLoss * 100).toFixed(6)}%`);

weights.dispose();
