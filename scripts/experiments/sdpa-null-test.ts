// Root-cause test for the ops.sdpa dK bug: Python passes mask=None (NULL),
// mlx-bun passes a non-null mask_mode pointer (even ""). Does a NULL mask_mode
// give the correct dK where "" does not?
//
//   bun scripts/sdpa-null-test.ts

import { C, outArray, Dtype } from "../../src/mlx/ffi";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";

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

// sdpa with mask_mode = NULL pointer (like Python mask=None)
function sdpaNull(q: MlxArray, k: MlxArray, v: MlxArray): MlxArray {
  return new MlxArray(outArray("fast_sdpa_null", (o) =>
    C.mlx_fast_scaled_dot_product_attention(o, q.handle, k.handle, v.handle, scale, null as never, 0n, 0n, gpuStream)));
}

const q = rand([1, 1, T, D], 1), k = rand([1, 1, T, D], 2), v = rand([1, 1, T, D], 3);

// manual non-causal reference, dO = ones
const q2 = ops.reshape(q, [T, D]).astype(Dtype.float32), k2 = ops.reshape(k, [T, D]).astype(Dtype.float32), v2 = ops.reshape(v, [T, D]).astype(Dtype.float32);
const dO2 = MlxArray.fromFloat32(new Float32Array(T * D).fill(1), [T, D]);
const S = ops.mulScalar(ops.matmul(q2, ops.transposeAxes(k2, [1, 0])), scale);
const P = ops.softmaxAxis(S, -1, true);
const Oref = ops.matmul(P, v2);
const Dv = ops.sumAxis(ops.mul(Oref, dO2), 1, true);
const dP = ops.matmul(dO2, ops.transposeAxes(v2, [1, 0]));
const dS = ops.mul(P, ops.sub(dP, Dv));
const dKref = ops.mulScalar(ops.matmul(ops.transposeAxes(dS, [1, 0]), q2), scale).toFloat32();
const f32 = (a: MlxArray) => a.astype(Dtype.float32).toFloat32();

const dkEmpty = f32(new ValueAndGrad((p) => sumAll(ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "", null)), [0, 1, 2]).apply([q, k, v]).grads[1]!);
const dkNull = f32(new ValueAndGrad((p) => sumAll(sdpaNull(p[0]!, p[1]!, p[2]!)), [0, 1, 2]).apply([q, k, v]).grads[1]!);

console.log(`ops.sdpa dK, mask_mode="" vs manual:   ${rel(dkEmpty, dKref)}`);
console.log(`ops.sdpa dK, mask_mode=NULL vs manual: ${rel(dkNull, dKref)}`);
