// 3-way comparison of attention gradients (dO = ones): flash kernels vs a
// manual mlx-ops attention-backward vs mlx-bun ops.sdpa. Resolves whether the
// earlier "dK fail" was a flash bug or a faulty ops.sdpa reference.
//
//   bun scripts/flash-cv-debug.ts

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { flashForward, flashBackward } from "../src/model/flash-attention";

const T = 64, D = 64;
const scale = 1 / Math.sqrt(D);
const rand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);
const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);
const rel = (a: Float32Array, b: Float32Array): string => {
  let md = 0, mr = 0;
  for (let i = 0; i < a.length; i++) { md = Math.max(md, Math.abs(a[i]! - b[i]!)); mr = Math.max(mr, Math.abs(b[i]!)); }
  return `${(100 * md / (mr || 1)).toFixed(2)}%`;
};

const q = rand([1, 1, T, D], 1), k = rand([1, 1, T, D], 2), v = rand([1, 1, T, D], 3);

// flash (dO = ones)
const [O, L] = flashForward(q, k, v, scale, false);
const ones = MlxArray.fromFloat32(new Float32Array(T * D).fill(1), [1, 1, T, D]).astype(Dtype.float16);
const [dQf, dKf, dVf] = flashBackward(q, k, v, O, L, ones, scale, false);

// manual reference
const q2 = ops.reshape(q, [T, D]).astype(Dtype.float32), k2 = ops.reshape(k, [T, D]).astype(Dtype.float32), v2 = ops.reshape(v, [T, D]).astype(Dtype.float32);
const dO2 = MlxArray.fromFloat32(new Float32Array(T * D).fill(1), [T, D]);
const S = ops.mulScalar(ops.matmul(q2, ops.transposeAxes(k2, [1, 0])), scale);
const P = ops.softmaxAxis(S, -1, true);
const Oref = ops.matmul(P, v2);
const Dv = ops.sumAxis(ops.mul(Oref, dO2), 1, true);
const dP = ops.matmul(dO2, ops.transposeAxes(v2, [1, 0]));
const dS = ops.mul(P, ops.sub(dP, Dv));
const dQref = ops.mulScalar(ops.matmul(dS, k2), scale).toFloat32();
const dKref = ops.mulScalar(ops.matmul(ops.transposeAxes(dS, [1, 0]), q2), scale).toFloat32();
const dVref = ops.matmul(ops.transposeAxes(P, [1, 0]), dO2).toFloat32();

// ops.sdpa
const vag = new ValueAndGrad((p) => sumAll(ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "", null)), [0, 1, 2]);
const { grads: gS } = vag.apply([q, k, v]);

const f32 = (a: MlxArray) => a.astype(Dtype.float32).toFloat32();
console.log("            dQ        dK        dV");
console.log(`flash vs manual:  ${rel(f32(dQf), dQref)}   ${rel(f32(dKf), dKref)}   ${rel(f32(dVf), dVref)}`);
console.log(`sdpa  vs manual:  ${rel(f32(gS[0]!), dQref)}   ${rel(f32(gS[1]!), dKref)}   ${rel(f32(gS[2]!), dVref)}`);
