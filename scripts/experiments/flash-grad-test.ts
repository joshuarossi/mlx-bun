// Validate the full differentiable flash attention (forward + 3 backward
// kernels via CustomVjp) by comparing its dQ/dK/dV against the gradients of
// mlx-bun's stock ops.sdpa on identical inputs. Flash uses fp16 online-softmax
// recompute, so expect small (not zero) diffs; a low relative error confirms
// the backward kernels compute correct attention gradients.
//
//   bun scripts/flash-grad-test.ts

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { flashAttention } from "../../src/model/flash-attention";

const D = Number(process.env.HD ?? 256), T = Number(process.env.T ?? 64);
const Hq = Number(process.env.HQ ?? 16), Hkv = Number(process.env.HKV ?? 2);
const scale = 1 / Math.sqrt(D);
const mkRand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);
const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);

const q = mkRand([1, Hq, T, D], 1);
const k = mkRand([1, Hkv, T, D], 2);
const v = mkRand([1, Hkv, T, D], 3);

const causal = process.env.CAUSAL !== "0";
const vagFlash = new ValueAndGrad((p) => sumAll(flashAttention(p[0]!, p[1]!, p[2]!, scale, causal)), [0, 1, 2]);
const { value: vF, grads: gF } = vagFlash.apply([q, k, v]);

const vagRef = new ValueAndGrad((p) => sumAll(ops.sdpa(p[0]!, p[1]!, p[2]!, scale, causal ? "causal" : "", null)), [0, 1, 2]);
const { value: vR, grads: gR } = vagRef.apply([q, k, v]);

console.log(`value: flash=${vF.toFloat32()[0]!.toFixed(4)} ref=${vR.toFloat32()[0]!.toFixed(4)}`);
{
  // Aliasing check: do the two same-shape outputs (dK, dV) come back identical?
  const dk = gF[1]!.astype(Dtype.float32).toFloat32();
  const dv = gF[2]!.astype(Dtype.float32).toFloat32();
  let same = 0;
  for (let j = 0; j < dk.length; j++) if (dk[j] === dv[j]) same++;
  console.log(`flash dK vs flash dV identical: ${same}/${dk.length} elements equal${same === dk.length ? "  ← ALIASED!" : ""}`);
}
let allOk = true;
for (const [name, i] of [["dQ", 0], ["dK", 1], ["dV", 2]] as const) {
  const a = gF[i]!.astype(Dtype.float32).toFloat32();
  const b = gR[i]!.astype(Dtype.float32).toFloat32();
  let maxDiff = 0, maxRef = 0;
  for (let j = 0; j < a.length; j++) {
    maxDiff = Math.max(maxDiff, Math.abs(a[j]! - b[j]!));
    maxRef = Math.max(maxRef, Math.abs(b[j]!));
  }
  const rel = maxDiff / (maxRef || 1);
  const ok = rel < 0.05;
  allOk &&= ok;
  console.log(`${name}: maxAbsDiff=${maxDiff.toExponential(2)} maxRef=${maxRef.toFixed(3)} rel=${(rel * 100).toFixed(2)}% → ${ok ? "ok" : "HIGH"}`);
  if (!ok) {
    console.log(`   flash ${name}[0..6]=${[...a.slice(0, 6)].map((x) => x.toFixed(4))}`);
    console.log(`   ref   ${name}[0..6]=${[...b.slice(0, 6)].map((x) => x.toFixed(4))}`);
  }
}
console.log(allOk ? "PASS — flash backward matches standard attention gradients" : "FAIL");
