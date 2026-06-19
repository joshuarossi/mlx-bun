// Validate the COMPOSITION of the segmented backward + prefix-sharing on MiniCPM5
// (M3-composition). The segmented prefix path streams the ONE prefix-shared concat
// forward [prompt; chosen; rejected] (block-sparse mask + block-wise RoPE) segment-
// by-segment; its grads must match the NON-segmented prefix-share path within bf16,
// at LOWER peak memory.
//
//   P=512 RC=64 RR=80 SEG=8 bun scripts/experiments/prefix-shared-segmented-parity.ts
//
// The reference is orpoLossPrefixShared (non-segmented, single concat forward, whole
// graph in autograd). Both run the SAME {promptIds, chosenResp, rejectedResp} and the
// SAME LoRA, with the SAME flash-CCE head, so the only divergence is the segmented
// backward's bf16 re-association across segment boundaries (the established ~1-2%
// grad class, same band the segmented + flash and prefix parity scripts show).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { orpoLossPrefixShared, prefixSavings } from "../../src/train/prefix-shared";
import { SegmentedBackwardOrpoPrefix, planSegmentsBySize } from "../../src/train/segmented";
import type { ChunkCtx } from "../../src/train/loss";
import { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const P = Number(process.env.P ?? 512);
const RC = Number(process.env.RC ?? 64);
const RR = Number(process.env.RR ?? 80); // distinct lengths on purpose
const SEG = Number(process.env.SEG ?? 8);
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const RANK = Number(process.env.RANK ?? 8);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

const sv = prefixSavings(P, RC, RR);
const nSeg = Math.ceil(48 / SEG); // cpm5-1b has 48 layers; printed precisely below
console.log(`### prefix-shared-segmented-parity  P=${P} Rc=${RC} Rr=${RR} SEG=${SEG} λ=${LAMBDA} rank=${RANK}`);
console.log(`### token throughput (prompt-encode-once): two-forward=${sv.twoForward} shared=${sv.shared} saving=${sv.ratio.toFixed(3)}×`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// Shared prompt + two distinct responses (same construction as prefix-shared-parity).
const promptIds = Array.from({ length: P }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const chosenResp = Array.from({ length: RC }, (_, i) => ((i * 7 + 11) % 4000) + 1);
const rejectedResp = Array.from({ length: RR }, (_, i) => ((i * 17 + 3) % 4000) + 1);

// flash-CCE head for both paths (the [M,V]-free per-branch head).
const headChunk = (sink: Array<{ dispose(): void }>): ChunkCtx => ({ chunkSize: 512, fused: true, flash: true, sink });

// --- Reference: NON-segmented prefix-share (whole-graph autograd). ---
function refGrads(): { loss: number; grads: Float32Array[]; peak: number } {
  clearCache(); resetPeakMemory();
  const sink: Array<{ dispose(): void }> = [];
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { return orpoLossPrefixShared(model as MiniCPM5Model, promptIds, chosenResp, rejectedResp, LAMBDA, headChunk(sink)); }
    finally { restore(lora, s); }
  }, flatParams(lora).map((_, i) => i));
  const out = vag.apply(flatParams(lora));
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
  for (const d of sink) d.dispose();
  console.log(`### ${"NON-SEG-PREFIX".padEnd(16)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

// --- Composition: segmented + prefix-share. ---
function segGrads(): { loss: number; grads: Float32Array[]; peak: number } {
  clearCache(); resetPeakMemory();
  const ranges = planSegmentsBySize(model.layers.length, SEG);
  const headSink: Array<{ dispose(): void }> = [];
  const seg = new SegmentedBackwardOrpoPrefix(model as MiniCPM5Model, lora, ranges, LAMBDA, headChunk(headSink));
  const out = seg.stepPrefix(promptIds, chosenResp, rejectedResp);
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose());
  seg.dispose();
  console.log(`### ${`SEG-PREFIX(${ranges.length}seg)`.padEnd(16)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

const ref = refGrads();
const seg = segGrads();

function gradRel(a: Float32Array[], b: Float32Array[]): { rel: number; maxAbs: number } {
  let d2 = 0, r2 = 0, maxAbs = 0;
  for (let i = 0; i < a.length; i++) {
    const x = a[i]!, y = b[i]!;
    for (let j = 0; j < x.length; j++) { const d = x[j]! - y[j]!; d2 += d * d; r2 += x[j]! * x[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
  }
  return { rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1), maxAbs };
}
const g = gradRel(ref.grads, seg.grads);
const lossRel = Math.abs(ref.loss - seg.loss) / (Math.abs(ref.loss) || 1);
console.log(`### grad relNorm = ${(g.rel * 100).toFixed(4)}%   loss rel = ${(lossRel * 100).toFixed(5)}%   maxAbs = ${g.maxAbs.toExponential(2)}`);
console.log(`### peak: non-seg ${gb(ref.peak)} -> seg ${gb(seg.peak)}   (${((1 - seg.peak / ref.peak) * 100).toFixed(1)}% lower)`);

// PASS: the segmented prefix backward matches the non-segmented prefix-share within
// the bf16 grad class AND has lower peak memory. The grad divergence is purely bf16
// non-associativity that STACKS two sources here (both confirmed, not logic bugs):
//   (1) the segmented backward's per-segment re-association across boundaries
//       (~1-2% e4b-class; tracks segment count — measured 1.16% @ SEG=48/1 segment,
//       2.32% @ SEG=8/3 segments at P=512), and
//   (2) the flash-CCE head's ~0.4% dh bf16 class (shared by BOTH paths' heads here,
//       so it mostly cancels, but the segmented vjp path differs slightly).
// Loss matches to ~0.05% (construction exact); the band ceiling is ~3% stacked.
const GRAD_BF16 = 3e-2;
const ok = g.rel < GRAD_BF16 && lossRel < 1e-3 && seg.peak < ref.peak;
console.log(`### ${ok ? "PASS" : "FAIL"} (grads ${(g.rel * 100).toFixed(2)}% bf16-class < ${(GRAD_BF16 * 100).toFixed(0)}%; loss ${(lossRel * 100).toExponential(2)}%; seg peak ${seg.peak < ref.peak ? "<" : ">="} non-seg)`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
