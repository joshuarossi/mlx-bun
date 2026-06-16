// Ground-truth GQA dK: expand kv-heads to Hq (each repeated reps times), run
// per-head attention (manualSdpa at reps=1, validated), grad wrt the expanded
// k, then SUM over each group → the correct dK[h_kv]. Compare flash-GQA dK and
// manualSdpa-GQA dK against it to decide which folds GQA correctly.
//
//   bun scripts/gqa-dk-ref.ts

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { flashAttention, manualSdpa } from "../src/model/flash-attention";

const T = 64, D = 256, Hq = 16, Hkv = 2, reps = Hq / Hkv;
const scale = 1 / Math.sqrt(D);
const rand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);
const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);
const rel = (a: Float32Array, b: Float32Array): string => {
  let md = 0, mr = 0;
  for (let i = 0; i < a.length; i++) { md = Math.max(md, Math.abs(a[i]! - b[i]!)); mr = Math.max(mr, Math.abs(b[i]!)); }
  return `${(100 * md / (mr || 1)).toFixed(2)}%`;
};
const f32 = (a: MlxArray) => a.astype(Dtype.float32).toFloat32();

const q = rand([1, Hq, T, D], 1), k = rand([1, Hkv, T, D], 2), v = rand([1, Hkv, T, D], 3);

// expand kv heads → [1, Hq, T, D] (head h_kv repeated reps times, consecutively)
const expand = (x: MlxArray): MlxArray => {
  const slices: MlxArray[] = [];
  for (let h = 0; h < Hkv; h++) {
    const sl = x.slice([0, h, 0, 0], [1, h + 1, T, D]); // slice(start, end-exclusive)
    for (let r = 0; r < reps; r++) slices.push(sl);
  }
  return ops.concatAxis(slices, 1);
};
const kE = expand(k), vE = expand(v);

// reference: grad wrt kE (per-head), then sum over groups
const gRef = new ValueAndGrad((p) => sumAll(manualSdpa(q, p[0]!, vE, scale, { mode: "causal", arr: null })), [0]).apply([kE]).grads[0]!;
const dKErefSummed = ops.sumAxis(ops.reshape(gRef, [1, Hkv, reps, T, D]), 2, false); // [1,Hkv,T,D]
const ref = f32(dKErefSummed);

// flash-GQA dK and manual-GQA dK (wrt k)
const dKflash = f32(new ValueAndGrad((p) => sumAll(flashAttention(q, p[0]!, v, scale, true)), [0]).apply([k]).grads[0]!);
const dKmanual = f32(new ValueAndGrad((p) => sumAll(manualSdpa(q, p[0]!, v, scale, { mode: "causal", arr: null })), [0]).apply([k]).grads[0]!);

console.log(`flash-GQA  dK vs ground-truth: ${rel(dKflash, ref)}`);
console.log(`manual-GQA dK vs ground-truth: ${rel(dKmanual, ref)}`);
