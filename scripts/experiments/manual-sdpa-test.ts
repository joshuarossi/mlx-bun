// Validate manualSdpa against the (already-validated) flash kernel — GQA,
// causal. If their dQ/dK/dV agree, manualSdpa's GQA reshape + vjp are correct.
//
//   bun scripts/manual-sdpa-test.ts

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { flashAttention, manualSdpa } from "../../src/model/flash-attention";

const T = 64, D = 256, Hq = 16, Hkv = 2;
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

const gF = new ValueAndGrad((p) => sumAll(flashAttention(p[0]!, p[1]!, p[2]!, scale, true)), [0, 1, 2]).apply([q, k, v]).grads;
const gM = new ValueAndGrad((p) => sumAll(manualSdpa(p[0]!, p[1]!, p[2]!, scale, { mode: "causal", arr: null })), [0, 1, 2]).apply([q, k, v]).grads;

console.log(`manual vs flash (GQA causal):  dQ ${rel(f32(gM[0]!), f32(gF[0]!))}  dK ${rel(f32(gM[1]!), f32(gF[1]!))}  dV ${rel(f32(gM[2]!), f32(gF[2]!))}`);
