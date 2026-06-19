// Validate the flash-CCE forward Metal kernel: per-token logp must match the
// pure-MLX whole-vocab head (logitsFromHidden → logsumexp − gather) within the
// bf16/f32 class, AND the kernel's peak must be far below the reference's (which
// materializes [M,V]) — the residency win. Uses a synthetic hidden (head-only).
//
//   bun scripts/experiments/flash-cce-parity.ts            # MiniCPM5
//   E4B=1 bun scripts/experiments/flash-cce-parity.ts      # gemma e4b (softcap, 262k vocab)

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { Gemma4Model } from "../../src/model/gemma4";
import { evalAll, randomNormal } from "../../src/mlx/ops";
import * as ops from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { flashCceForward, flashCceBackward, type FlashCceHead } from "../../src/train/flash-cce";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const M = Number(process.env.M ?? 512);
const gb = (b: number) => `${(b / 1e9).toFixed(3)} GB`;

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const H = config.text.hiddenSize;
const V = config.text.vocabSize;

// Head pieces + reference logitsFromHidden.
let head: FlashCceHead;
let logits: (h3d: MlxArray) => MlxArray;
if (model instanceof Gemma4Model) {
  const e = model.embed;
  head = { w: e.w, scales: e.scales, biases: e.biases!, bits: e.spec.bits, groupSize: e.spec.groupSize, softcap: config.text.finalLogitSoftcapping };
  logits = (h3d) => model.logitsFromHidden(h3d);
} else if (model instanceof MiniCPM5Model) {
  const lh = model.lmHead;
  head = { w: lh.w, scales: lh.scales, biases: lh.biases!, bits: lh.spec.bits, groupSize: lh.spec.groupSize, softcap: null };
  logits = (h3d) => model.logitsFromHidden(h3d);
} else throw new Error("unsupported model");

console.log(`### flash-cce-parity  model=${E4B ? "e4b" : "MiniCPM5"} M=${M} H=${H} V=${V} bits=${head.bits} GS=${head.groupSize} softcap=${head.softcap}`);

// REAL=1: run an actual forward pass through the loaded model → genuinely peaked
// logits (the real ORPO regime), with next-token targets — the right way to validate
// the coeff filter (Apple does this in production), instead of random/synthetic h.
// Otherwise: synthetic hidden ~N(0, HSCALE).
let hResp: MlxArray;
let targets: number[];
if (process.env.REAL === "1") {
  const idData = Array.from({ length: M }, (_, i) => (i * 2659 + 13) % V); // in-vocab seq
  const ids = ops.fromInt32(idData, [1, M]);
  const caches = model.makeCache();
  const h3 = model.forwardHidden(ids, caches); // [1, M, H], real model hidden states
  hResp = ops.reshape(h3, [M, H]);
  evalAll([hResp]); h3.dispose(); ids.dispose();
  targets = idData.map((_, i) => idData[(i + 1) % M]!); // next-token (gold) targets
  console.log(`### REAL forward: hidden from model.forwardHidden (peaked logits)`);
} else {
  hResp = ops.mulScalar(randomNormal([M, H], Dtype.bfloat16, 0, 1, null), Number.parseFloat(process.env.HSCALE ?? "0.5"));
  targets = Array.from({ length: M }, (_, i) => (i * 2659 + 7) % V);
}

// --- reference (pure-MLX whole-vocab head): materializes [M,V] ---
clearCache(); resetPeakMemory();
const h3d = ops.reshape(hResp, [1, M, H]);
const lg = logits(h3d); // [1, M, V]
const l2 = ops.reshape(lg, [M, V]);
const lse = ops.logsumexpAxis(l2, -1, false); // [M]
const tgtArr = MlxArray.fromInt32(new Int32Array(targets), [M, 1]);
const gathered = ops.reshape(ops.takeAlongAxis(l2, tgtArr, -1), [M]);
const logpRef = ops.sub(gathered, lse);
evalAll([logpRef]);
const refPeak = peakMemory();
const refLogp = logpRef.toFloat32();
for (const a of [h3d, lg, l2, lse, tgtArr, gathered, logpRef]) a.dispose();

// --- flash-CCE kernel: no [M,V] ---
clearCache(); resetPeakMemory();
const { logp, lse: lseK, blockMax: bmK } = flashCceForward(hResp, head, targets);
bmK.dispose();
evalAll([logp, lseK]);
const kPeak = peakMemory();
const kLogp = logp.toFloat32();
logp.dispose(); lseK.dispose();

let d2 = 0, r2 = 0, maxAbs = 0;
for (let i = 0; i < M; i++) { const d = refLogp[i]! - kLogp[i]!; d2 += d * d; r2 += refLogp[i]! * refLogp[i]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
const rel = Math.sqrt(d2) / (Math.sqrt(r2) || 1);
const probe = Array.from({ length: Math.min(3, M) }, (_, i) => i);
console.log(`### logp[0..] ref=${probe.map((i) => refLogp[i]!.toFixed(4))} kernel=${probe.map((i) => kLogp[i]!.toFixed(4))}`);
console.log(`### logp rel=${(rel * 100).toExponential(2)}%  maxAbs=${maxAbs.toExponential(2)}`);
console.log(`### peak: reference (materializes [M,V]) ${gb(refPeak)}  ->  flash-CCE ${gb(kPeak)}  (saved ${gb(refPeak - kPeak)})`);

// --- backward: dh vs autograd of Σ cot·logp, + kernel peak ---
const { ValueAndGrad } = await import("../../src/mlx/autograd");
const cot = Array.from({ length: M }, (_, i) => 0.3 + 0.01 * (i % 7));
clearCache(); resetPeakMemory();
const vag = new ValueAndGrad((p) => {
  const h3 = ops.reshape(p[0]!, [1, M, H]);
  const lg2 = ops.reshape(logits(h3), [M, V]);
  const ls = ops.logsumexpAxis(lg2, -1, false);
  const tg = MlxArray.fromInt32(new Int32Array(targets), [M, 1]);
  const ga = ops.reshape(ops.takeAlongAxis(lg2, tg, -1), [M]);
  const lp = ops.sub(ga, ls);
  const cv = MlxArray.fromFloat32(new Float32Array(cot), [M]);
  const wl = ops.mul(lp, cv);
  const loss = ops.sumAxis(wl, 0, false);
  for (const a of [h3, lg2, ls, tg, ga, lp, cv, wl]) a.dispose();
  return loss;
}, [0]);
const go = vag.apply([hResp]);
evalAll([go.value, ...go.grads]);
const refBwdPeak = peakMemory();
const dhRef = go.grads[0]!.toFloat32();
go.value.dispose(); go.grads.forEach((g) => g.dispose()); vag.dispose();

clearCache(); resetPeakMemory();
const { logp: lp2, lse: lse2, blockMax: bm2 } = flashCceForward(hResp, head, targets);
// Both approximations default "0" = exact (the gate tests unfiltered kernel math).
// Set MLX_BUN_CCE_BWD_FILTER_EPS / MLX_BUN_CCE_BWD_BLOCK_EPS to validate them —
// meaningful with REAL=1 (peaked logits): dh-vs-autograd shows the true error and the
// `backward (...)` line the speedup, in the actual ORPO regime.
const fEps = process.env.MLX_BUN_CCE_BWD_FILTER_EPS ?? "0";
const blkEps = process.env.MLX_BUN_CCE_BWD_BLOCK_EPS ?? "0";
const bwd = () => flashCceBackward(hResp, head, targets, lse2, cot, fEps, bm2, blkEps);
const dhK = bwd();
evalAll([lp2, lse2, dhK]);
// timed backward (warmed) so the filter + block-skip real-data speedup is visible.
{
  let bw: MlxArray | undefined;
  for (let i = 0; i < 2; i++) { bw?.dispose(); bw = bwd(); evalAll([bw]); }
  const t0 = performance.now();
  for (let i = 0; i < 5; i++) { bw?.dispose(); bw = bwd(); evalAll([bw]); }
  console.log(`### backward (filterEps=${fEps} blockEps=${blkEps}): ${((performance.now() - t0) / 5).toFixed(0)} ms`);
  bw?.dispose();
}
const kBwdPeak = peakMemory();
const dh = dhK.toFloat32();
lp2.dispose(); lse2.dispose(); bm2.dispose(); dhK.dispose();
let bd2 = 0, br2 = 0, bmax = 0;
for (let i = 0; i < M * H; i++) { const d = dhRef[i]! - dh[i]!; bd2 += d * d; br2 += dhRef[i]! * dhRef[i]!; if (Math.abs(d) > bmax) bmax = Math.abs(d); }
const bRel = Math.sqrt(bd2) / (Math.sqrt(br2) || 1);
console.log(`### dh rel=${(bRel * 100).toExponential(2)}%  maxAbs=${bmax.toExponential(2)}`);
console.log(`### bwd peak: reference ${gb(refBwdPeak)}  ->  flash-CCE ${gb(kBwdPeak)}  (saved ${gb(refBwdPeak - kBwdPeak)})`);

const ok = rel < 1e-2 && kPeak < refPeak && bRel < 1e-2 && kBwdPeak < refBwdPeak;
console.log(`### ${ok ? "PASS" : "FAIL"} (logp ${(rel * 100).toFixed(3)}%; dh ${(bRel * 100).toFixed(3)}%; fwd peak ${gb(kPeak)} vs ${gb(refPeak)}; bwd peak ${gb(kBwdPeak)} vs ${gb(refBwdPeak)})`);
hResp.dispose(); weights.dispose();
process.exitCode = ok ? 0 : 1;
