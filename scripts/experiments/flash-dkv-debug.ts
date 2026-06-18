// Call flashBackward directly (no CustomVjp) and compare dQ/dK/dV to an mlx-ops
// reference, scanning T to find where dK breaks (single tile vs multi tile).
//
//   bun scripts/flash-dkv-debug.ts

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { flashForward, flashBackward } from "../../src/model/flash-attention";

const D = 64;
const scale = 1 / Math.sqrt(D);
const rand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);

function run(T: number): void {
  const q = rand([1, 1, T, D], 1), k = rand([1, 1, T, D], 2), v = rand([1, 1, T, D], 3), dO = rand([1, 1, T, D], 4);
  const [O, L] = flashForward(q, k, v, scale, false);
  const [dQ, dK, dV] = flashBackward(q, k, v, O, L, dO, scale, false);

  // reference (single head, non-causal)
  const q2 = ops.reshape(q, [T, D]).astype(Dtype.float32);
  const k2 = ops.reshape(k, [T, D]).astype(Dtype.float32);
  const v2 = ops.reshape(v, [T, D]).astype(Dtype.float32);
  const dO2 = ops.reshape(dO, [T, D]).astype(Dtype.float32);
  const S = ops.mulScalar(ops.matmul(q2, ops.transposeAxes(k2, [1, 0])), scale); // [T,T]
  const P = ops.softmaxAxis(S, -1, true);
  const Oref = ops.matmul(P, v2);
  const Dv = ops.sumAxis(ops.mul(Oref, dO2), 1, true); // [T,1]
  const dP = ops.matmul(dO2, ops.transposeAxes(v2, [1, 0])); // [T,T]
  const dS = ops.mul(P, ops.sub(dP, Dv)); // [T,T]
  const dKref = ops.mulScalar(ops.matmul(ops.transposeAxes(dS, [1, 0]), q2), scale); // [T,D]
  const dVref = ops.matmul(ops.transposeAxes(P, [1, 0]), dO2); // [T,D]

  const cmp = (name: string, flash: MlxArray, ref: MlxArray): string => {
    const a = flash.astype(Dtype.float32).toFloat32(), b = ref.toFloat32();
    let md = 0, mr = 0;
    for (let i = 0; i < a.length; i++) { md = Math.max(md, Math.abs(a[i]! - b[i]!)); mr = Math.max(mr, Math.abs(b[i]!)); }
    return `${name} rel=${(100 * md / (mr || 1)).toFixed(2)}%`;
  };
  console.log(`T=${T} (q-tiles=${Math.ceil(T / 32)}, kv-tiles=${Math.ceil(T / 32)}): ${cmp("dK", dK, dKref)}  ${cmp("dV", dV, ops.reshape(dVref, [1, 1, T, D]))}`);
}

for (const T of [8, 16, 32, 33, 48, 64]) run(T);
