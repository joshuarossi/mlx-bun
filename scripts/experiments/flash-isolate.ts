// Isolate flash-backward bugs across {H, causal}. Reference = per-head
// materialized SDPA backward (with the causal mask when requested). Reports
// dQ/dK/dV relErr so we can see which dimension (multi-head vs causal) triggers
// which bug.  bun scripts/experiments/flash-isolate.ts
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { flashForward, flashBackward } from "../../src/model/flash-attention";
import { createCausalMask } from "../../src/model/gemma4-base";
import { Vjp } from "../../src/mlx/autograd";

const D = 64;
const T = Number(process.env.T ?? 128);
const scale = 1 / Math.sqrt(D);
const rand = (shape: number[], seed: number) =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);

function ref(q: MlxArray, k: MlxArray, v: MlxArray, dO: MlxArray, H: number, causal: boolean) {
  // q..[1,H,T,D] f16 → [H,T,D] f32
  const q3 = ops.reshape(q, [H, T, D]).astype(Dtype.float32);
  const k3 = ops.reshape(k, [H, T, D]).astype(Dtype.float32);
  const v3 = ops.reshape(v, [H, T, D]).astype(Dtype.float32);
  const dO3 = ops.reshape(dO, [H, T, D]).astype(Dtype.float32);
  let S = ops.mulScalar(ops.matmul(q3, ops.transposeAxes(k3, [0, 2, 1])), scale); // [H,T,T]
  if (causal) {
    const m = createCausalMask(T, 0, null); // [T,T] bool
    const ninf = ops.scalarLike(-3e38, S);
    S = ops.where(m, S, ninf);
  }
  const P = ops.softmaxAxis(S, -1, true);
  const Oref = ops.matmul(P, v3);
  const Dv = ops.sumAxis(ops.mul(Oref, dO3), 2, true); // [H,T,1]
  const dP = ops.matmul(dO3, ops.transposeAxes(v3, [0, 2, 1]));
  const dS = ops.mul(P, ops.sub(dP, Dv));
  const dQ = ops.mulScalar(ops.matmul(dS, k3), scale);
  const dK = ops.mulScalar(ops.matmul(ops.transposeAxes(dS, [0, 2, 1]), q3), scale);
  const dV = ops.matmul(ops.transposeAxes(P, [0, 2, 1]), dO3);
  return { dQ, dK, dV };
}
const rel = (a: MlxArray, b: MlxArray) => {
  const x = ops.contiguous(a.astype(Dtype.float32)).toFloat32(), y = ops.contiguous(b.astype(Dtype.float32)).toFloat32();
  let n = 0, d = 0; for (let i = 0; i < x.length; i++) { const e = x[i]! - y[i]!; n += e * e; d += y[i]! * y[i]!; }
  return (100 * Math.sqrt(n) / (Math.sqrt(d) + 1e-12)).toFixed(1) + "%";
};

for (const H of [1, 8]) for (const causal of [false, true]) {
  const q = rand([1, H, T, D], 1), k = rand([1, H, T, D], 2), v = rand([1, H, T, D], 3), dO = rand([1, H, T, D], 4);
  const [O, L] = flashForward(q, k, v, scale, causal);
  const [dQ, dK, dV] = flashBackward(q, k, v, O, L, dO, scale, causal);
  const r = ref(q, k, v, dO, H, causal);
  // ops.sdpa grads via Vjp with the SAME explicit dO (trusted ground truth).
  const sv = new Vjp((p) => [ops.sdpa(p[0]!, p[1]!, p[2]!, scale, causal ? "causal" : "")], 1);
  const { vjps } = sv.apply([q, k, v], [dO]);
  sv.dispose();
  const rD = (a: MlxArray, b: MlxArray) => rel(a, ops.reshape(b, [1, H, T, D]));
  console.log(`H=${H} causal=${causal ? "Y" : "n"}:`);
  console.log(`  flash vs manualRef:  dQ ${rD(dQ, r.dQ)}  dK ${rD(dK, r.dK)}  dV ${rD(dV, r.dV)}`);
  console.log(`  ops.sdpa vs manualRef: dQ ${rD(vjps[0]!, r.dQ)}  dK ${rD(vjps[1]!, r.dK)}  dV ${rD(vjps[2]!, r.dV)}`);
  console.log(`  flash vs ops.sdpa:   dQ ${rel(dQ, vjps[0]!)}  dK ${rel(dK, vjps[1]!)}  dV ${rel(dV, vjps[2]!)}`);
}
