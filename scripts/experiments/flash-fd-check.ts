// Finite-difference ground truth for dK / dQ. Perturb one element of K (resp Q)
// in a materialized fp32 attention forward, measure d(loss)/d(element) where
// loss = sum(O ⊙ dO_fixed). Compare to: (a) my analytic manual-ref, (b) flash,
// (c) ops.sdpa. Whichever matches FD is correct. H=1, non-causal, small T.
//   bun scripts/experiments/flash-fd-check.ts
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { Vjp } from "../../src/mlx/autograd";
import { flashForward, flashBackward } from "../../src/model/flash-attention";

const D = 64, T = 32, scale = 1 / Math.sqrt(D);
const key = (s: number) => ops.randomKey(BigInt(s));
const q = ops.randomNormal([1, 1, T, D], Dtype.float32, 0, 1, key(1));
const k = ops.randomNormal([1, 1, T, D], Dtype.float32, 0, 1, key(2));
const v = ops.randomNormal([1, 1, T, D], Dtype.float32, 0, 1, key(3));
const dO = ops.randomNormal([1, 1, T, D], Dtype.float32, 0, 1, key(4));

// Materialized fp32 forward O = softmax(scale·Q Kᵀ) V, returns scalar loss = Σ O⊙dO.
function lossWith(qq: MlxArray, kk: MlxArray): number {
  const q2 = ops.reshape(qq, [T, D]), k2 = ops.reshape(kk, [T, D]), v2 = ops.reshape(v, [T, D]);
  const S = ops.mulScalar(ops.matmul(q2, ops.transposeAxes(k2, [1, 0])), scale);
  const P = ops.softmaxAxis(S, -1, true);
  const O = ops.matmul(P, v2);
  const l = ops.sumAxis(ops.reshape(ops.mul(O, ops.reshape(dO, [T, D])), [T * D]), 0, false);
  const val = l.toFloat32()[0]!;
  for (const a of [q2, k2, v2, S, P, O, l]) a.dispose();
  return val;
}
function fd(which: "q" | "k", idx: number): number {
  const eps = 1e-3;
  const base = (which === "q" ? q : k).toFloat32();
  const plus = new Float32Array(base); plus[idx]! += eps;
  const minus = new Float32Array(base); minus[idx]! -= eps;
  const aP = MlxArray.fromFloat32(plus, [1, 1, T, D]), aM = MlxArray.fromFloat32(minus, [1, 1, T, D]);
  const lp = which === "q" ? lossWith(aP, k) : lossWith(q, aP);
  const lm = which === "q" ? lossWith(aM, k) : lossWith(q, aM);
  aP.dispose(); aM.dispose();
  return (lp - lm) / (2 * eps);
}

// analytic refs
const q3 = ops.reshape(q, [1, T, D]), k3 = ops.reshape(k, [1, T, D]), v3 = ops.reshape(v, [1, T, D]), dO3 = ops.reshape(dO, [1, T, D]);
const S = ops.mulScalar(ops.matmul(q3, ops.transposeAxes(k3, [0, 2, 1])), scale);
const P = ops.softmaxAxis(S, -1, true);
const Oref = ops.matmul(P, v3);
const Dv = ops.sumAxis(ops.mul(Oref, dO3), 2, true);
const dP = ops.matmul(dO3, ops.transposeAxes(v3, [0, 2, 1]));
const dS = ops.mul(P, ops.sub(dP, Dv));
const manualDQ = ops.mulScalar(ops.matmul(dS, k3), scale).toFloat32();
const manualDK = ops.mulScalar(ops.matmul(ops.transposeAxes(dS, [0, 2, 1]), q3), scale).toFloat32();

const qh = q.astype(Dtype.float16), kh = k.astype(Dtype.float16), vh = v.astype(Dtype.float16), dOh = dO.astype(Dtype.float16);
const [O, L] = flashForward(qh, kh, vh, scale, false);
const [fdQ, fdK] = flashBackward(qh, kh, vh, O, L, dOh, scale, false);
const flashDQ = fdQ.astype(Dtype.float32).toFloat32(), flashDK = fdK.astype(Dtype.float32).toFloat32();

const sv = new Vjp((p) => [ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "")], 1);
const { vjps } = sv.apply([q, k, v], [dO]);
// Read CONTIGUOUS copies — a Vjp output can be a strided/transposed view, and
// raw toFloat32() would byte-scramble it (the documented contiguity pitfall).
const sdpaDQ = ops.contiguous(vjps[0]!).toFloat32(), sdpaDK = ops.contiguous(vjps[1]!).toFloat32();

// Materialized softmax-attention forward, differentiated by AUTOGRAD (the kind
// of reference bench-attn-backward used). If THIS also disagrees with FD, the
// bench reference was unreliable for dK.
const mv = new Vjp((p) => {
  const q2 = ops.reshape(p[0]!, [T, D]), k2 = ops.reshape(p[1]!, [T, D]), v2 = ops.reshape(p[2]!, [T, D]);
  const S = ops.mulScalar(ops.matmul(q2, ops.transposeAxes(k2, [1, 0])), scale);
  const P = ops.softmaxAxis(S, -1, true);
  const O = ops.matmul(P, v2);
  return [ops.reshape(O, [1, 1, T, D])];
}, 1);
const matDK = ops.contiguous(mv.apply([q, k, v], [dO]).vjps[1]!).toFloat32();

console.log("idx |    FD(dK)  manualDK  flashDK  sdpaDK  matAutogradDK");
for (const idx of [0, 1, 65, 200, 1000]) {
  console.log(`dK[${String(idx).padStart(4)}]  ${fd("k", idx).toFixed(4)}  ${manualDK[idx]!.toFixed(4)}  ${flashDK[idx]!.toFixed(4)}  ${sdpaDK[idx]!.toFixed(4)}  ${matDK[idx]!.toFixed(4)}`);
}
console.log("idx |    FD(dQ)  manualDQ  flashDQ  sdpaDQ");
for (const idx of [0, 1, 65, 200]) {
  console.log(`dQ[${String(idx).padStart(4)}]  ${fd("q", idx).toFixed(4)}  ${manualDQ[idx]!.toFixed(4)}  ${flashDQ[idx]!.toFixed(4)}  ${sdpaDQ[idx]!.toFixed(4)}`);
}
