// Definitive 3-way gradient check: hand-rolled softmax attention (fp32, the
// ground truth via mlx autograd over matmul/softmax) vs ops.sdpa (fp32, the
// fused mlx op) vs flash (fp16, our kernel). Tells us whether ops.sdpa's vjp
// is actually wrong, or whether earlier divergence was a GQA-reference artifact.
//
//   bun scripts/sdpa-vs-manual.ts            # non-GQA H=4, head_dim 128
//   HQ=16 HKV=2 bun scripts/sdpa-vs-manual.ts  # GQA (not exercised by manual here)

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { flashAttention } from "../src/model/flash-attention";

const D = Number(process.env.HD ?? 128), T = Number(process.env.T ?? 64);
const H = Number(process.env.H ?? 4); // Hq == Hkv (non-GQA) for the manual ground truth
const scale = 1 / Math.sqrt(D);
const mkRand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed)));
const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);

// Additive causal mask [1,1,T,T]: 0 where q>=k, -1e9 above the diagonal.
function causalMask(): MlxArray {
  const qi = ops.reshape(ops.arange(0, T, 1, Dtype.float32), [T, 1]);
  const ki = ops.reshape(ops.arange(0, T, 1, Dtype.float32), [1, T]);
  const allow = ops.greaterEqual(qi, ki);
  const zero = MlxArray.fromFloat32(new Float32Array([0]), []);
  const neg = MlxArray.fromFloat32(new Float32Array([-1e9]), []);
  const m = ops.where(allow, zero, neg);
  return ops.reshape(m, [1, 1, T, T]);
}
const MASK = causalMask();

function manualAttn(q: MlxArray, k: MlxArray, v: MlxArray): MlxArray {
  const kt = ops.transposeAxes(k, [0, 1, 3, 2]); // [B,H,D,T]
  let s = ops.matmul(q, kt);                       // [B,H,T,T]
  s = ops.mulScalar(s, scale);
  s = ops.add(s, MASK);
  const p = ops.softmaxAxis(s, -1, true);
  return ops.matmul(p, v);                          // [B,H,T,D]
}

const q = mkRand([1, H, T, D], 1);
const k = mkRand([1, H, T, D], 2);
const v = mkRand([1, H, T, D], 3);
const q16 = q.astype(Dtype.float16), k16 = k.astype(Dtype.float16), v16 = v.astype(Dtype.float16);

const gM = new ValueAndGrad((p) => sumAll(manualAttn(p[0]!, p[1]!, p[2]!)), [0, 1, 2]).apply([q, k, v]).grads;
const gS = new ValueAndGrad((p) => sumAll(ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "causal", null)), [0, 1, 2]).apply([q, k, v]).grads;
const gF = new ValueAndGrad((p) => sumAll(flashAttention(p[0]!, p[1]!, p[2]!, scale, true, 0)), [0, 1, 2]).apply([q16, k16, v16]).grads;

function rel(a: MlxArray, b: MlxArray): string {
  const x = a.astype(Dtype.float32).toFloat32(), y = b.astype(Dtype.float32).toFloat32();
  let d = 0, r = 0;
  for (let j = 0; j < x.length; j++) { d = Math.max(d, Math.abs(x[j]! - y[j]!)); r = Math.max(r, Math.abs(y[j]!)); }
  return `${((d / (r || 1)) * 100).toFixed(2)}%`;
}

console.log(`### geometry: H=${H} (non-GQA) D=${D} T=${T} causal`);
for (const [name, i] of [["dQ", 0], ["dK", 1], ["dV", 2]] as const) {
  console.log(`${name}:  sdpa-vs-manual=${rel(gS[i]!, gM[i]!).padStart(8)}   flash-vs-manual=${rel(gF[i]!, gM[i]!).padStart(8)}`);
}
