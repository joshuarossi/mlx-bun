// Validate the INTRA-LAYER MLP SPLIT (lever 4) on real e4b: gradient
// checkpointing is pure recompute, so splitting each layer's checkpoint into an
// attention sub-block + an MLP sub-block (boundary = the post-attn residual)
// must be NUMERICALLY IDENTICAL to the single per-layer checkpoint and to no
// checkpoint at all — only the peak memory differs (attn+MLP → max(attn,MLP)+hMid
// in the backward recompute). Three arms: no-ckpt (ref), single-ckpt, split-ckpt.
//
//   L=512 bun scripts/experiments/mlp-split-checkpoint-e4b.ts
//
// Run WITHOUT MLX_BUN_FUSED_GELU=0 (fused training on, to exercise the fused
// CustomVjp nested inside the Checkpoint). MLX_BUN_PERF_KERNEL=0 still required.

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model, type GradCheckpointCtx, type LayerLoras } from "../../src/model/gemma4";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { sftLoss } from "../../src/train/loss";
import type { SftBatch } from "../../src/train/dataset";
import type { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const L = Number(process.env.L ?? 512);
const RANK = Number(process.env.RANK ?? 8);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
setFusedGeluTraining(true);

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

console.log(`### mlp-split-checkpoint-e4b  L=${L} rank=${RANK}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// Partition LoRA into attn / MLP sub-blocks (as the trainer does).
const byLayer = new Map<number, LayerLoras>();
for (const t of lora.targets) {
  const m = t.modulePath.match(/\.layers\.(\d+)\./);
  if (!m) continue;
  const li = Number(m[1]);
  const ll = byLayer.get(li) ?? byLayer.set(li, { attn: [], mlp: [] }).get(li)!;
  (t.modulePath.includes(".self_attn.") ? ll.attn : ll.mlp).push(t.lw);
}

const ids = Array.from({ length: L }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const batch: SftBatch = { ids: [ids], promptLens: [Math.floor(L / 2)] };

function gradsWith(label: string, ckpt: "off" | "single" | "split"): { loss: number; grads: Float32Array[]; peak: number } {
  const keepAlive: GradCheckpointCtx["keepAlive"] = [];
  model.gradCkpt = ckpt === "off" ? null : { byLayer, splitMlp: ckpt === "split", keepAlive };
  clearCache();
  resetPeakMemory();
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { return sftLoss(model, batch); } finally { restore(lora, s); }
  }, flatParams(lora).map((_, i) => i));
  const out = vag.apply(flatParams(lora));
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
  for (const ck of keepAlive) ck.dispose();
  model.gradCkpt = null;
  console.log(`### ${label.padEnd(8)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

const off = gradsWith("NO-CKPT", "off");
const single = gradsWith("SINGLE", "single");
const split = gradsWith("SPLIT", "split");

function relNorm(a: Float32Array[], b: Float32Array[]): { rel: number; maxAbs: number } {
  let d2 = 0, r2 = 0, maxAbs = 0;
  for (let i = 0; i < a.length; i++) {
    const x = a[i]!, y = b[i]!;
    for (let j = 0; j < x.length; j++) { const d = x[j]! - y[j]!; d2 += d * d; r2 += x[j]! * x[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
  }
  return { rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1), maxAbs };
}

const singleVsOff = relNorm(off.grads, single.grads);
const splitVsOff = relNorm(off.grads, split.grads);
const splitVsSingle = relNorm(single.grads, split.grads);
console.log(`### single vs no-ckpt: relNorm=${(singleVsOff.rel * 100).toFixed(6)}%  maxAbs=${singleVsOff.maxAbs.toExponential(2)}`);
console.log(`### split  vs no-ckpt: relNorm=${(splitVsOff.rel * 100).toFixed(6)}%  maxAbs=${splitVsOff.maxAbs.toExponential(2)}`);
console.log(`### split  vs single : relNorm=${(splitVsSingle.rel * 100).toFixed(6)}%  maxAbs=${splitVsSingle.maxAbs.toExponential(2)}`);
console.log(`### peak: no-ckpt ${gb(off.peak)} -> single ${gb(single.peak)} -> split ${gb(split.peak)}`);

// PASS: checkpointing is pure recompute → bit-exact (deterministic forward), so
// both single and split must match no-ckpt to ~0 (a few ULPs at most), and the
// split must not raise peak above the single checkpoint.
const TOL = 1e-5;
const ok = singleVsOff.rel < TOL && splitVsOff.rel < TOL && splitVsSingle.rel < TOL && split.peak <= single.peak * 1.02;
console.log(`### ${ok ? "PASS" : "FAIL"} (split is numerically identical to no-ckpt/single; peak not raised)`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
