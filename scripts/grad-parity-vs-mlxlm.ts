// Bit-exact GRADIENT parity vs mlx-lm at 2048. mlx-lm (/tmp/mlxlm-grad-parity.py)
// attached LoRA to q_proj on all 42 layers with an identical deterministic A and
// B=0, and dumped dB per layer to /tmp/parity_grads.json. With B=0 the forward is
// the (bit-exact) base forward, dA=0, and dB = scale·(x@A)^T @ dOut is fully
// determined by matched quantities — so our dB must match mlx-lm's if our grad
// path matches theirs. Tests our FULL value_and_grad AND the segmented path.
//   MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 bun scripts/grad-parity-vs-mlxlm.ts

import { readFileSync, readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { evalAll } from "../src/mlx/ops";
import { resolveRanks } from "../src/train/rank";
import { buildTrainableLora, attachForTraining, flatParams, type TrainableLora } from "../src/train/lora-params";
import { sftLoss } from "../src/train/loss";
import { SegmentedBackwardGemma4, planSegmentsBySize } from "../src/train/segmented";
import type { SftBatch } from "../src/train/dataset";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;

const ref = JSON.parse(readFileSync("/tmp/parity.json", "utf8"));
const gref = JSON.parse(readFileSync("/tmp/parity_grads.json", "utf8"));
const { ids, promptLen } = ref;
const { A, A_shape, rank, scale, dB } = gref as { A: number[]; A_shape: number[]; rank: number; scale: number; dB: Record<string, number[]> };
console.log(`### grad-parity-vs-mlxlm  L=${ids.length} rank=${rank} scale=${scale} A_shape=${A_shape}`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");

// q_proj LoRA on all layers, scale matched to mlx-lm.
const ranks = resolveRanks(model, { rank, rankScaling: "constant", targetModules: ["self_attn.q_proj"], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, scale, 0);
attachForTraining(model, lora, "train");
// Override A with mlx-lm's deterministic A (B stays zeros from init).
const Aarr = new Float32Array(A);
for (const t of lora.targets) {
  t.lw.a.dispose();
  t.lw.a = MlxArray.fromFloat32(Aarr.slice(), A_shape);
}
console.log(`### lora targets=${lora.targets.length} (expect 42 q_proj)`);

const batch: SftBatch = { ids: [ids], promptLens: [promptLen] };
const layerOf = (p: string) => Number(p.match(/\.layers\.(\d+)\./)![1]);

// dB lookup by layer index from mlx-lm's dump.
const mlxByLayer = new Map<number, Float32Array>();
for (const [k, v] of Object.entries(dB)) mlxByLayer.set(layerOf(k), new Float32Array(v));

function compareDB(tag: string, ourDB: Map<number, Float32Array>): void {
  let sumDiff2 = 0, sumRef2 = 0, maxAbs = 0, worstLayer = -1, worstRel = 0;
  for (const [li, mlx] of mlxByLayer) {
    const ours = ourDB.get(li)!;
    let d2 = 0, r2 = 0;
    for (let j = 0; j < mlx.length; j++) { const d = ours[j]! - mlx[j]!; d2 += d * d; r2 += mlx[j]! * mlx[j]!; sumDiff2 += d * d; sumRef2 += mlx[j]! * mlx[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
    const rel = Math.sqrt(d2) / (Math.sqrt(r2) || 1);
    if (rel > worstRel) { worstRel = rel; worstLayer = li; }
  }
  const relNorm = Math.sqrt(sumDiff2) / (Math.sqrt(sumRef2) || 1);
  console.log(`### ${tag}: relNorm=${(relNorm * 100).toExponential(3)}%  maxAbs=${maxAbs.toExponential(3)}  worst layer ${worstLayer} ${(worstRel * 100).toExponential(2)}%  ${relNorm === 0 ? "BIT-EXACT" : maxAbs < 1e-4 ? "bf16-class" : "DIVERGES"}`);
}

// --- (a) FULL value_and_grad (our non-segmented trainer path) ---
function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}
const vag = new ValueAndGrad((p) => { const s = swap(lora, p); try { return sftLoss(model, batch); } finally { restore(lora, s); } }, flatParams(lora).map((_, i) => i));
const full = vag.apply(flatParams(lora));
evalAll([full.value, ...full.grads]);
console.log(`### our base loss (LoRA B=0) = ${full.value.toFloat32()[0]!.toFixed(8)}`);
const n = lora.targets.length;
const fullDB = new Map<number, Float32Array>();
lora.targets.forEach((t, i) => fullDB.set(layerOf(t.modulePath), full.grads[n + i]!.toFloat32()));
compareDB("FULL value_and_grad dB vs mlx-lm", fullDB);
full.value.dispose(); full.grads.forEach((g) => g.dispose()); vag.dispose();

// --- (b) SEGMENTED dB ---
const sb = new SegmentedBackwardGemma4(model, lora, planSegmentsBySize(model.layers.length, Number(process.env.SEG ?? 6)));
const seg = sb.step(batch);
evalAll(seg.grads);
const segDB = new Map<number, Float32Array>();
lora.targets.forEach((t, i) => segDB.set(layerOf(t.modulePath), seg.grads[n + i]!.toFloat32()));
compareDB(`SEGMENTED dB vs mlx-lm (seg=${process.env.SEG ?? 6})`, segDB);
seg.value.dispose(); seg.grads.forEach((g) => g.dispose()); sb.dispose();

weights.dispose();
