// Validate flash with a sliding WINDOW (the e4b sliding_attention case).
// Ground truth: expand kv-heads, per-head windowed attention (manualSdpa
// reps=1, array mask = causal∧within-window), grad wrt expanded k, sum over
// groups. Compare flashAttention(..., window=W) dQ/dK/dV against it. Also
// re-check window=0 (full causal) for no regression.
//
//   bun scripts/flash-window-test.ts

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { flashAttention, manualSdpa } from "../../src/model/flash-attention";

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
const expand = (x: MlxArray): MlxArray => {
  const slices: MlxArray[] = [];
  for (let h = 0; h < Hkv; h++) { const sl = x.slice([0, h, 0, 0], [1, h + 1, T, D]); for (let r = 0; r < reps; r++) slices.push(sl); }
  return ops.concatAxis(slices, 1);
};
const kE = expand(k), vE = expand(v);

// window mask matching the kernel: allowed iff j<=i AND (i-j) < window
const windowMask = (W: number): MlxArray => {
  const m = new Float32Array(T * T);
  for (let i = 0; i < T; i++) for (let j = 0; j < T; j++) m[i * T + j] = (j <= i && (i - j) < W) ? 1 : 0;
  const fm = MlxArray.fromFloat32(m, [T, T]);
  const half = ops.scalarLike(0.5, fm);
  const b = ops.less(half, fm); // 0.5 < fm → true where allowed
  fm.dispose(); half.dispose();
  return b;
};

function check(label: string, W: number): void {
  const mask = W === 0
    ? { mode: "causal" as const, arr: null }
    : { mode: "array" as const, arr: windowMask(W) };
  // ground truth: per-head (reps=1) then sum dK over groups
  const refGrads = new ValueAndGrad((p) => sumAll(manualSdpa(q, p[0]!, p[1]!, scale, mask)), [0, 1]).apply([kE, vE]).grads;
  const dKref = f32(ops.sumAxis(ops.reshape(refGrads[0]!, [1, Hkv, reps, T, D]), 2, false));
  // also dQ ground truth (per-head, no fold)
  const dQref = f32(new ValueAndGrad((p) => sumAll(manualSdpa(p[0]!, kE, vE, scale, mask)), [0]).apply([q]).grads[0]!);

  const gF = new ValueAndGrad((p) => sumAll(flashAttention(p[0]!, p[1]!, p[2]!, scale, true, W)), [0, 1, 2]).apply([q, k, v]).grads;
  console.log(`${label} (window=${W}): dQ ${rel(f32(gF[0]!), dQref)}  dK ${rel(f32(gF[1]!), dKref)}`);
}

check("full ", 0);
check("slide", 16);
