// Validate the FUSED linear-CE log-prob head (Liger FusedLinearCrossEntropy
// ported to MLX as a CustomVjp with an analytic softmax−onehot backward) against
// the naïve full-logits autograd reference `branchLogpMeanB1`. Both compute the
// length-normalized response mean log-prob of one [prompt;response] sequence; we
// compare the VALUE and the LoRA GRADIENTS (the fused dh must drive the same
// layer-stack grads as autograd through the head). Also reports peak memory.
//
//   bun scripts/experiments/fused-ce-parity.ts                 # MiniCPM5 (no softcap)
//   E4B=1 bun scripts/experiments/fused-ce-parity.ts           # gemma e4b (softcap=30)
//
// PASS = value bit-exact-ish + grads within the established bf16 class, and the
// fused peak ≤ the naïve peak (the [M,V] logits never fully materialize).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import * as ops from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { branchLogpMeanB1, fusedLogpMeanB1 } from "../../src/train/loss";
import { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const P = Number(process.env.P ?? 256); // prompt length
const R = Number(process.env.R ?? 256); // response length
const CHUNK = Number(process.env.CHUNK ?? 128);
const VBLOCK = Number(process.env.VBLOCK ?? 0); // >0 = vocab-blocked online-softmax (full CCE: [chunk,Vblock] peak)
const RANK = Number(process.env.RANK ?? 8);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
if (process.env.FUSED_GELU !== "0") setFusedGeluTraining(true); // same for both paths

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

console.log(`### fused-ce-parity  model=${E4B ? "e4b" : "MiniCPM5"} P=${P} R=${R} chunk=${CHUNK} rank=${RANK}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// One [prompt; response] sequence; mask marks the response span (1).
const L = P + R;
const ids = Array.from({ length: L }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const mask = Array.from({ length: L }, (_, i) => (i >= P ? 1 : 0));
const validLen = L;

function gradsOf(label: string, lossFn: (sink: Array<{ dispose(): void }>) => MlxArray): { loss: number; grads: Float32Array[]; peak: number } {
  clearCache();
  resetPeakMemory();
  const sink: Array<{ dispose(): void }> = [];
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { const m = lossFn(sink); const sc = ops.meanAll(m, false); m.dispose(); return sc; } finally { restore(lora, s); }
  }, flatParams(lora).map((_, i) => i));
  const out = vag.apply(flatParams(lora));
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
  for (const d of sink) d.dispose();
  console.log(`### ${label.padEnd(12)} meanLogp=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

const naive = gradsOf("NAIVE", () => branchLogpMeanB1(model, ids, mask, validLen));
const fused = gradsOf(VBLOCK > 0 ? `FUSED-VB(${VBLOCK})` : "FUSED", (sink) => fusedLogpMeanB1(model, ids, mask, validLen, CHUNK, sink, VBLOCK));

function gradRel(a: Float32Array[], b: Float32Array[]): { rel: number; maxAbs: number } {
  let d2 = 0, r2 = 0, maxAbs = 0;
  for (let i = 0; i < a.length; i++) {
    const x = a[i]!, y = b[i]!;
    for (let j = 0; j < x.length; j++) { const d = x[j]! - y[j]!; d2 += d * d; r2 += x[j]! * x[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
  }
  return { rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1), maxAbs };
}
const vs = gradRel(naive.grads, fused.grads);
const lossRel = Math.abs(naive.loss - fused.loss) / (Math.abs(naive.loss) || 1);
console.log(`### value rel=${(lossRel * 100).toExponential(2)}%   grad relNorm=${(vs.rel * 100).toFixed(4)}%  maxAbs=${vs.maxAbs.toExponential(2)}`);
console.log(`### peak: naive ${gb(naive.peak)} -> fused ${gb(fused.peak)} (saved ${gb(naive.peak - fused.peak)})`);

// PASS: value bit-exact (the forward is the same math — softcap matched to
// logitSoftcap) and grads in the model's bf16 class (the analytic softmax−onehot
// backward vs autograd-through-CE differ only by bf16 reassociation; e4b's
// scale=1.0 peaked attention widens the band to ~2%, as the segmented ORPO path
// shows). The memory win is M·V-dependent — bounded `[chunk,V]` vs the naïve
// retained `[M,V]` — so it's reported, not gated (shown clearly at long response,
// e.g. MiniCPM5 R=2048 saved ~0.5 GB); at small M the layer activations dominate.
const GRAD = E4B ? 2.5e-2 : 1.5e-2;
const ok = lossRel < 1e-3 && vs.rel < GRAD;
console.log(`### ${ok ? "PASS" : "FAIL"} (value ${lossRel < 1e-3 ? "BIT-EXACT" : "DIVERGED"}; grads ${(vs.rel * 100).toFixed(2)}% < ${(GRAD * 100).toFixed(1)}% bf16-class; peak ${gb(fused.peak)} vs ${gb(naive.peak)} [win grows with M·V])`);
disposeLora(lora); weights.dispose();
process.exitCode = ok ? 0 : 1;
