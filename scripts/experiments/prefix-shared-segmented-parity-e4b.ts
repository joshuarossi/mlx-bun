// Validate the COMPOSITION of the segmented backward + prefix-sharing on e4b
// (Gemma4) — the e4b analogue of prefix-shared-segmented-parity.ts (MiniCPM5).
// The segmented prefix path (SegmentedBackwardOrpoPrefixGemma4) streams the ONE
// prefix-shared concat [prompt; chosen; rejected] (block-sparse logical-window
// mask + block-wise RoPE + donor-KV threading + per-layer-input) segment-by-
// segment; its grads must match the NON-segmented e4b prefix-share path
// (orpoLossPrefixSharedGemma) within the e4b bf16 band, at LOWER peak memory.
//
//   MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 \
//     P=256 RC=64 RR=80 SEG=8 bun scripts/experiments/prefix-shared-segmented-parity-e4b.ts
//
// REQUIRES MLX_BUN_PERF_KERNEL=0 + MLX_BUN_FUSED_GELU=0 (e4b training breaks
// otherwise). e4b weights are ~7 GB; keep the prefix SMALL (P=256 default; P=512
// stays well under ~20 GB) — probes are capped and freed per path.
//
// The reference is orpoLossPrefixSharedGemma (non-segmented, single concat forward,
// whole graph in autograd). Both run the SAME {promptIds, chosenResp, rejectedResp}
// and the SAME LoRA, with the SAME flash-CCE head, so the gap is ONLY:
//   (1) the segmented backward's per-segment bf16 re-association across boundaries
//       (the established e4b-class ~1-2%, tracking segment count; single-segment
//       SEG=nLayers is the FLOOR diagnostic — no boundary reassociation), PLUS
//   (2) the e4b cross-segment donor-K/V cotangent accumulation (bf16 non-assoc,
//       ~0.5% class, established in SegmentedBackwardGemma4.accumulateDKV), PLUS
//   (3) the flash-CCE head's ~0.4% dh class (shared by both heads, mostly cancels).
// This is SAME-PREFIX seg-vs-nonseg, so it is TIGHTER than the e4b two-forward
// length-sensitivity (~2-14%); expect a few % (PASS band ~5% to cover the stack;
// the single-segment floor is printed so the boundary contribution is visible).

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model } from "../../src/model/gemma4";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { orpoLossPrefixSharedGemma, prefixSavings } from "../../src/train/prefix-shared";
import { SegmentedBackwardOrpoPrefixGemma4, planSegmentsBySize } from "../../src/train/segmented";
import type { ChunkCtx } from "../../src/train/loss";
import { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const P = Number(process.env.P ?? 256);
const RC = Number(process.env.RC ?? 64);
const RR = Number(process.env.RR ?? 80); // distinct lengths on purpose
const SEG = Number(process.env.SEG ?? 8);
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const RANK = Number(process.env.RANK ?? 8);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;
// Match the real e4b training path. FUSED_GELU=0 (required) → spelled GeGLU path.
if (process.env.MLX_BUN_FUSED_GELU !== "0") setFusedGeluTraining(true);

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

const sv = prefixSavings(P, RC, RR);
console.log(`### prefix-shared-segmented-parity-e4b  P=${P} Rc=${RC} Rr=${RR} SEG=${SEG} λ=${LAMBDA} rank=${RANK}  T=${P + RC + RR}`);
console.log(`### token throughput (prompt-encode-once): two-forward=${sv.twoForward} shared=${sv.shared} saving=${sv.ratio.toFixed(3)}×`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");
console.log(`### layers=${model.layers.length} donors=${model.numDonors} window=${model.windowSize} reusedDonors=${[...model.reusedDonors]}`);
if (P + RC + RR <= model.windowSize)
  console.log(`### WARNING: T=${P + RC + RR} <= window ${model.windowSize} — the logical-window cut is NOT exercised; raise P.`);

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

// Shared prompt + two distinct responses (same construction as prefix-shared-parity-e4b).
const promptIds = Array.from({ length: P }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const chosenResp = Array.from({ length: RC }, (_, i) => ((i * 7 + 11) % 4000) + 1);
const rejectedResp = Array.from({ length: RR }, (_, i) => ((i * 17 + 3) % 4000) + 1);

// flash-CCE head for ALL paths (the [M,V]-free per-branch head).
const headChunk = (sink: Array<{ dispose(): void }>): ChunkCtx => ({ chunkSize: 512, fused: true, flash: true, sink });

// --- Reference: NON-segmented e4b prefix-share (whole-graph autograd). ---
function refGrads(): { loss: number; grads: Float32Array[]; peak: number } {
  clearCache(); resetPeakMemory();
  const sink: Array<{ dispose(): void }> = [];
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { return orpoLossPrefixSharedGemma(model as Gemma4Model, promptIds, chosenResp, rejectedResp, LAMBDA, headChunk(sink)); }
    finally { restore(lora, s); }
  }, flatParams(lora).map((_, i) => i));
  const out = vag.apply(flatParams(lora));
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
  for (const d of sink) d.dispose();
  console.log(`### ${"NON-SEG-PREFIX".padEnd(18)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

// --- Composition: segmented + prefix-share (the new e4b class). ---
function segGrads(segSize: number, label: string): { loss: number; grads: Float32Array[]; peak: number; nSeg: number } {
  clearCache(); resetPeakMemory();
  const ranges = planSegmentsBySize(model.layers.length, segSize);
  const headSink: Array<{ dispose(): void }> = [];
  const seg = new SegmentedBackwardOrpoPrefixGemma4(model as Gemma4Model, lora, ranges, LAMBDA, headChunk(headSink));
  const out = seg.stepPrefix(promptIds, chosenResp, rejectedResp);
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose());
  seg.dispose();
  console.log(`### ${`${label}(${ranges.length}seg)`.padEnd(18)} loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak, nSeg: ranges.length };
}

function gradRel(a: Float32Array[], b: Float32Array[]): { rel: number; maxAbs: number } {
  let d2 = 0, r2 = 0, maxAbs = 0;
  for (let i = 0; i < a.length; i++) {
    const x = a[i]!, y = b[i]!;
    for (let j = 0; j < x.length; j++) { const d = x[j]! - y[j]!; d2 += d * d; r2 += x[j]! * x[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
  }
  return { rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1), maxAbs };
}

const ref = refGrads();
// Single-segment diagnostic FLOOR: SEG=nLayers → one segment, NO boundary
// reassociation (but STILL the donor-KV cross-segment accumulation is absent too,
// since there is one segment). This isolates the head + single-segment-vjp class
// from the multi-segment boundary + donor-accumulation reassociation.
const floor = segGrads(model.layers.length, "SEG-FLOOR");
const seg = segGrads(SEG, "SEG-PREFIX");

const gFloor = gradRel(ref.grads, floor.grads);
const g = gradRel(ref.grads, seg.grads);
const lossRel = Math.abs(ref.loss - seg.loss) / (Math.abs(ref.loss) || 1);
const lossRelFloor = Math.abs(ref.loss - floor.loss) / (Math.abs(ref.loss) || 1);

// Per-target breakdown; the donor-K/V recipients (the reused donors' k/v_proj) are
// the canary for a donor-KV-threading or block-wise-RoPE bug — they should NOT be
// singled out far beyond the uniform reassociation band.
const nt = lora.targets.length;
const perTarget: { path: string; rel: number }[] = [];
for (let t = 0; t < nt; t++) {
  let d2 = 0, r2 = 0;
  for (const gi of [t, nt + t]) {
    const a = ref.grads[gi]!, b = seg.grads[gi]!;
    for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; d2 += d * d; r2 += a[j]! * a[j]!; }
  }
  perTarget.push({ path: lora.targets[t]!.modulePath, rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1) });
}
perTarget.sort((x, y) => y.rel - x.rel);
console.log("### worst targets (seg vs non-seg relNorm):");
for (const t of perTarget.slice(0, 5)) console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);
const donorPaths = [...model.reusedDonors].flatMap((d) => [`layers.${d}.self_attn.k_proj`, `layers.${d}.self_attn.v_proj`]);
const donorTargets = perTarget.filter((x) => donorPaths.some((p) => x.path.includes(p)));
const donorRel = donorTargets.length ? Math.max(...donorTargets.map((x) => x.rel)) : 0;
console.log("### donor-K/V targets (block-wise RoPE + donor-thread canary):");
for (const t of donorTargets) console.log(`###   ${(t.rel * 100).toFixed(3)}%  ${t.path}`);

console.log(`### grad relNorm: SEG-FLOOR(${floor.nSeg}seg)=${(gFloor.rel * 100).toFixed(4)}%  SEG-PREFIX(${seg.nSeg}seg)=${(g.rel * 100).toFixed(4)}%  maxAbs=${g.maxAbs.toExponential(2)}`);
console.log(`### loss rel: SEG-FLOOR=${(lossRelFloor * 100).toFixed(5)}%  SEG-PREFIX=${(lossRel * 100).toFixed(5)}%`);
console.log(`### peak: non-seg ${gb(ref.peak)} -> seg ${gb(seg.peak)}   (${((1 - seg.peak / ref.peak) * 100).toFixed(1)}% lower)`);

// PASS: the segmented e4b prefix backward matches the non-segmented e4b prefix-share
// within the e4b bf16 grad class AND has lower peak memory. The divergence stacks
// (all established, not logic bugs):
//   (1) segmented per-segment bf16 re-association across boundaries (tracks segment
//       count — the SEG-FLOOR row, one segment, is the floor),
//   (2) e4b cross-segment donor-K/V cotangent accumulation (bf16 non-assoc ~0.5%),
//   (3) the flash-CCE head's ~0.4% dh class (shared by both heads).
// SAME-prefix seg-vs-nonseg → tighter than the e4b two-forward length-sensitivity
// (~2-14%). Band 5% to cover the stacked e4b sources; donor-KV not singled out.
const GRAD_BF16 = 5e-2;
const ok = g.rel < GRAD_BF16 && lossRel < 5e-3 && seg.peak < ref.peak && donorRel < 2 * g.rel + 1e-2;
console.log(`### ${ok ? "PASS" : "FAIL"} (grads ${(g.rel * 100).toFixed(2)}% e4b-bf16-class < ${(GRAD_BF16 * 100).toFixed(0)}% [floor ${(gFloor.rel * 100).toFixed(2)}%]; loss ${(lossRel * 100).toExponential(2)}% < 0.5%; donor-KV ${(donorRel * 100).toFixed(2)}% not singled out; seg peak ${seg.peak < ref.peak ? "<" : ">="} non-seg)`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
