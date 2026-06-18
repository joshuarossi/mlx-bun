// Numeric dump of flash dK vs autograd-manual dK for a tiny single-head case,
// to reveal the bug pattern (zero? negated? scaled? row-localized?).
//
//   bun scripts/flash-dk-debug.ts            # causal
//   CAUSAL=0 bun scripts/flash-dk-debug.ts   # non-causal

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { flashAttention } from "../../src/model/flash-attention";

const D = Number(process.env.HD ?? 64), T = Number(process.env.T ?? 64), H = 1;
const causal = process.env.CAUSAL !== "0";
const scale = 1 / Math.sqrt(D);
const mkRand = (shape: number[], seed: number): MlxArray =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed)));
const sumAll = (a: MlxArray): MlxArray => ops.sumAxis(ops.reshape(a, [a.size]), 0, false);

function causalMask(): MlxArray {
  const qi = ops.reshape(ops.arange(0, T, 1, Dtype.float32), [T, 1]);
  const ki = ops.reshape(ops.arange(0, T, 1, Dtype.float32), [1, T]);
  const allow = ops.greaterEqual(qi, ki);
  const zero = MlxArray.fromFloat32(new Float32Array([0]), []);
  const neg = MlxArray.fromFloat32(new Float32Array([-1e9]), []);
  return ops.reshape(ops.where(allow, zero, neg), [1, 1, T, T]);
}
const MASK = causal ? causalMask() : null;

function manualAttn(q: MlxArray, k: MlxArray, v: MlxArray): MlxArray {
  let s = ops.mulScalar(ops.matmul(q, ops.transposeAxes(k, [0, 1, 3, 2])), scale);
  if (MASK) s = ops.add(s, MASK);
  const p = ops.softmaxAxis(s, -1, true);
  return ops.matmul(p, v);
}

const q = mkRand([1, H, T, D], 1), k = mkRand([1, H, T, D], 2), v = mkRand([1, H, T, D], 3);
const q16 = q.astype(Dtype.float16), k16 = k.astype(Dtype.float16), v16 = v.astype(Dtype.float16);

const gM = new ValueAndGrad((p) => sumAll(manualAttn(p[0]!, p[1]!, p[2]!)), [0, 1, 2]).apply([q, k, v]).grads;
const gF = new ValueAndGrad((p) => sumAll(flashAttention(p[0]!, p[1]!, p[2]!, scale, causal, 0)), [0, 1, 2]).apply([q16, k16, v16]).grads;

const mK = gM[1]!.astype(Dtype.float32).toFloat32();
const fK = gF[1]!.astype(Dtype.float32).toFloat32();

console.log(`### dK debug: H=${H} D=${D} T=${T} causal=${causal}`);
// Per-row error: is the error uniform, or localized to some kv-rows?
console.log(`row | manual[0..3]                         | flash[0..3]                          | rowRel%`);
const ROWS = process.env.SMALL ? [0, 1, 2, 3, 4, 5, 6, 7] : [0, 1, 2, 31, 32, 62, 63];
for (const row of ROWS) {
  const off = row * D;
  let d = 0, r = 0;
  for (let j = 0; j < D; j++) { d = Math.max(d, Math.abs(mK[off + j]! - fK[off + j]!)); r = Math.max(r, Math.abs(mK[off + j]!)); }
  const m4 = [0, 1, 2, 3].map((j) => mK[off + j]!.toFixed(3).padStart(7)).join(",");
  const f4 = [0, 1, 2, 3].map((j) => fK[off + j]!.toFixed(3).padStart(7)).join(",");
  console.log(`${String(row).padStart(3)} | ${m4} | ${f4} | ${((d / (r || 1)) * 100).toFixed(1)}`);
}
// Explicit axis-swap check: is flash[i][j] == manual[j][i] for i,j < min(T,D)?
{
  const n = Math.min(T, D);
  let d = 0, r = 0;
  for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) {
    const fv = fK[i * D + j]!, mv = mK[j * D + i]!;
    d = Math.max(d, Math.abs(fv - mv)); r = Math.max(r, Math.abs(mv));
  }
  console.log(`TRANSPOSE check  flash[i][j] vs manual[j][i] (n=${n}): rel=${((d / (r || 1)) * 100).toFixed(2)}%`);
}
// Map each flash[row][k] to the manual (i,j) it matches — reveals the permutation.
if (process.env.MAP) {
  for (const rr of [0, 1, 2]) {
    const out: string[] = [];
    for (let k = 0; k < 6; k++) {
      const target = fK[rr * D + k]!;
      let bi = -1, bj = -1, best = Infinity;
      for (let i = 0; i < T; i++) for (let j = 0; j < D; j++) {
        const e = Math.abs(mK[i * D + j]! - target);
        if (e < best) { best = e; bi = i; bj = j; }
      }
      out.push(`f[${rr}][${k}]=manual[${bi}][${bj}]`);
    }
    console.log(out.join("  "));
  }
}
// FIX hypothesis: flash dK is the correct dK with last-2 axes transposed in the
// buffer. Recover via transpose([..,D,T]) then reshape to [..,T,D].
{
  const fixed = ops.reshape(ops.transposeAxes(gF[1]!, [0, 1, 3, 2]), [1, H, T, D]);
  const fx = fixed.astype(Dtype.float32).toFloat32();
  let d = 0, r = 0;
  for (let j = 0; j < fx.length; j++) { d = Math.max(d, Math.abs(fx[j]! - mK[j]!)); r = Math.max(r, Math.abs(mK[j]!)); }
  console.log(`FIX (transpose+reshape) dK rel: ${((d / (r || 1)) * 100).toFixed(2)}%`);
}
// JS reconstruction of the permutation: manual_linear[m] == flash_linear[(m%T)*D + floor(m/T)] ?
{
  let d = 0, r = 0;
  for (let m = 0; m < T * D; m++) {
    const c = fK[(m % T) * D + Math.floor(m / T)]!;
    d = Math.max(d, Math.abs(c - mK[m]!)); r = Math.max(r, Math.abs(mK[m]!));
  }
  console.log(`JS-FIX dK rel: ${((d / (r || 1)) * 100).toFixed(2)}%`);
}
// dV for reference (should be ~0%)
const mV = gM[2]!.astype(Dtype.float32).toFloat32(), fV = gF[2]!.astype(Dtype.float32).toFloat32();
let dv = 0, rv = 0;
for (let j = 0; j < mV.length; j++) { dv = Math.max(dv, Math.abs(mV[j]! - fV[j]!)); rv = Math.max(rv, Math.abs(mV[j]!)); }
console.log(`dV rel: ${((dv / (rv || 1)) * 100).toFixed(2)}%`);
