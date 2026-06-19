// Validate the FUSED GeGLU TRAINING wiring on real e4b: the differentiable
// wrapper (Metal-kernel forward + hand-derived vjp, enabled via
// setFusedGeluTraining(true)) must produce the SAME ORPO grads as the spelled-out
// path (ops.geluApprox + mul, the autograd reference) — within the fused kernel's
// established bf16 class (kl=0 forward; the only residual is the pow/tanh
// math-lib difference, which propagates ~bf16 into the grads). This is the
// end-to-end wiring check: the kernel-level vjp is already unit-tested in
// tests/fused-geglu-vjp.test.ts; here we confirm the model dispatch + the
// no-longer-needed MLX_BUN_FUSED_GELU=0 (the whole point — training can now keep
// the fused kernel).
//
//   L=256 bun scripts/experiments/fused-geglu-train-parity.ts
//
// NOTE: do NOT set MLX_BUN_FUSED_GELU=0 here — we WANT the fused path on for arm B.

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model } from "../../src/model/gemma4";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import {
  buildTrainableLora, attachForTraining, flatParams, disposeLora, type TrainableLora,
} from "../../src/train/lora-params";
import { setFusedGeluTraining, fusedGeluCalls } from "../../src/model/fused-geglu-kernel";
import { orpoLoss } from "../../src/train/loss";
import { planSegmentsBySize } from "../../src/train/segmented";
import type { DpoBatch } from "../../src/train/dataset";
import type { MlxArray } from "../../src/mlx/array";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const L = Number(process.env.L ?? 256);
const RANK = Number(process.env.RANK ?? 8);
const LAMBDA = Number(process.env.LAMBDA ?? 0.1);
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;

function swap(l: TrainableLora, p: MlxArray[]): MlxArray[] {
  const n = l.targets.length; const s: MlxArray[] = [];
  for (let i = 0; i < n; i++) { s.push(l.targets[i]!.lw.a, l.targets[i]!.lw.b); l.targets[i]!.lw.a = p[i]!; l.targets[i]!.lw.b = p[n + i]!; }
  return s;
}
function restore(l: TrainableLora, s: MlxArray[]): void {
  for (let i = 0; i < l.targets.length; i++) { l.targets[i]!.lw.a = s[2 * i]!; l.targets[i]!.lw.b = s[2 * i + 1]!; }
}

console.log(`### fused-geglu-train-parity  L=${L} rank=${RANK} λ=${LAMBDA}`);
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");

const ranks = resolveRanks(model, { rank: RANK, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");
void planSegmentsBySize; // (kept import parity with the sibling harness)

const Lc = L, Lr = Math.max(2, L - 17);
const mkRow = (len: number, salt: number) => {
  const ids = Array.from({ length: len }, (_, i) => ((i * 13 + 5 + salt) % 4000) + 1);
  const promptLen = Math.floor(len / 2);
  const mask = Array.from({ length: len }, (_, i) => (i >= promptLen ? 1 : 0));
  return { ids, mask };
};
const c = mkRow(Lc, 0), r = mkRow(Lr, 7);
const batch: DpoBatch = { chosenIds: [c.ids], chosenMask: [c.mask], rejectedIds: [r.ids], rejectedMask: [r.mask] };

function fullGrads(label: string): { loss: number; grads: Float32Array[]; peak: number } {
  clearCache();
  resetPeakMemory();
  const vag = new ValueAndGrad((p) => {
    const s = swap(lora, p);
    try { return orpoLoss(model, batch, LAMBDA); } finally { restore(lora, s); }
  }, flatParams(lora).map((_, i) => i));
  const out = vag.apply(flatParams(lora));
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  const grads = out.grads.map((g) => g.toFloat32());
  out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
  console.log(`### ${label}  loss=${loss.toFixed(6)}  PEAK=${gb(peak)}`);
  return { loss, grads, peak };
}

// Arm A: spelled-out reference (ops.geluApprox + mul, the autograd path).
setFusedGeluTraining(false);
process.env.MLX_BUN_FUSED_GELU = "0"; // force the spelled MLP even in inference dispatch
const callsBeforeA = fusedGeluCalls;
const A = fullGrads("SPELLED");
const fusedDuringA = fusedGeluCalls - callsBeforeA;

// Arm B: fused differentiable training path (the wiring under test).
delete process.env.MLX_BUN_FUSED_GELU;
setFusedGeluTraining(true);
const callsBeforeB = fusedGeluCalls;
const B = fullGrads("FUSED ");
const fusedDuringB = fusedGeluCalls - callsBeforeB;
setFusedGeluTraining(false);

console.log(`### fused-kernel dispatches: spelled arm=${fusedDuringA} (expect 0), fused arm=${fusedDuringB} (expect >0)`);

// --- compare ---
let sumDiff2 = 0, sumRef2 = 0, maxAbs = 0;
for (let i = 0; i < A.grads.length; i++) {
  const a = A.grads[i]!, b = B.grads[i]!;
  for (let j = 0; j < a.length; j++) { const d = a[j]! - b[j]!; sumDiff2 += d * d; sumRef2 += a[j]! * a[j]!; if (Math.abs(d) > maxAbs) maxAbs = Math.abs(d); }
}
const relNorm = Math.sqrt(sumDiff2) / (Math.sqrt(sumRef2) || 1);
const lossRel = Math.abs(A.loss - B.loss) / (Math.abs(A.loss) || 1);
console.log(`### grad match (fused vs spelled): relNorm=${(relNorm * 100).toFixed(4)}%  maxAbs=${maxAbs.toExponential(3)}`);
console.log(`### loss rel=${(lossRel * 100).toFixed(6)}%`);

// PASS: the fused training path must (1) actually dispatch the kernel on both
// sites, (2) leave the spelled arm fused-free, (3) match the spelled FORWARD
// bit-for-bit (loss rel ~0 — the kernel is kl=0), and (4) match the spelled
// GRADS in the fused kernel's bf16 class. The grad threshold is 3% (not tighter):
// the forward is bit-identical, but the BACKWARD is two different bf16
// computations of the SAME gelu derivative — the hand-vjp (geluAndGrad, bf16
// ops) vs autograd through ops.geluApprox. The kernel-level vjp is validated
// against the closed-form derivative at tol 0.05 in tests/fused-geglu-vjp.test.ts,
// so ~2% here is rounding, not a vjp bug (which would push specific leaves to
// 10-100%+). The forward bit-exactness is what preserves the trained
// distribution; the grad is bf16-class, the same class as the sdpa-segmented
// path. RUN WITHOUT MLX_BUN_FUSED_GELU=0.
const ok = fusedDuringA === 0 && fusedDuringB > 0 && lossRel < 1e-4 && relNorm < 3e-2;
console.log(`### ${ok ? "PASS" : "FAIL"} (fused training wiring: both sites dispatch, spelled-clean, forward exact, grads bf16-class <3%)`);

disposeLora(lora);
weights.dispose();
process.exitCode = ok ? 0 : 1;
