// Is ops.sdpa's wrong dK specific to the STRING mask modes ("causal"/"")?
// Compare dK from ops.sdpa with (a) the "causal" string vs (b) an explicit
// boolean array causal mask, against the manual causal attention-backward.
// If the array-mask dK is correct, the string-mode vjp is the culprit and the
// training fix is "use array masks (like mlx-lm) or flash", not ops.sdpa string modes.
//
//   bun scripts/sdpa-mask-test.ts

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { createCausalMask } from "../src/model/gemma4-base";

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

// manual causal reference (dO = ones)
const q2 = ops.reshape(q, [T, D]).astype(Dtype.float32), k2 = ops.reshape(k, [T, D]).astype(Dtype.float32), v2 = ops.reshape(v, [T, D]).astype(Dtype.float32);
const dO2 = MlxArray.fromFloat32(new Float32Array(T * D).fill(1), [T, D]);
// additive causal mask [T,T]: 0 on/below diag, -1e9 above
const maskAdd = new Float32Array(T * T);
for (let i = 0; i < T; i++) for (let j = 0; j < T; j++) maskAdd[i * T + j] = j <= i ? 0 : -1e9;
const Sm = ops.add(ops.mulScalar(ops.matmul(q2, ops.transposeAxes(k2, [1, 0])), scale), MlxArray.fromFloat32(maskAdd, [T, T]));
const P = ops.softmaxAxis(Sm, -1, true);
const Oref = ops.matmul(P, v2);
const Dv = ops.sumAxis(ops.mul(Oref, dO2), 1, true);
const dP = ops.matmul(dO2, ops.transposeAxes(v2, [1, 0]));
const dS = ops.mul(P, ops.sub(dP, Dv));
const dKref = ops.mulScalar(ops.matmul(ops.transposeAxes(dS, [1, 0]), q2), scale).toFloat32();

const f32 = (a: MlxArray) => a.astype(Dtype.float32).toFloat32();

// (a) string "causal"
const vagStr = new ValueAndGrad((p) => sumAll(ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "causal", null)), [0, 1, 2]);
const dkStr = f32(vagStr.apply([q, k, v]).grads[1]!);

// (b) array bool causal mask
const cmask = createCausalMask(T, 0, null); // [T,T] bool
const vagArr = new ValueAndGrad((p) => sumAll(ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "array", cmask)), [0, 1, 2]);
const dkArr = f32(vagArr.apply([q, k, v]).grads[1]!);

console.log(`ops.sdpa dK, "causal" string vs manual: ${rel(dkStr, dKref)}`);
console.log(`ops.sdpa dK, bool array mask vs manual: ${rel(dkArr, dKref)}`);
