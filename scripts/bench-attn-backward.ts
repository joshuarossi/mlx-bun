// Attention-backward parity + MEMORY/time bench. Two questions this settles:
//   1. CORRECTNESS: does each path's dQ/dK/dV match a materialized reference?
//   2. VALUE: is ops.sdpa's backward O(L²) memory (so a correct O(L) flash
//      kernel would beat it at long context), or already O(L)?
// The custom flash kernel currently gives WRONG grads — but its MEMORY profile
// is independent of that, so measuring peak vs T tells us whether fixing it is
// worth it. No model weights needed.
//
//   bun scripts/bench-attn-backward.ts

import { MlxArray } from "../src/mlx/array";
import { Dtype, peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { Vjp } from "../src/mlx/autograd";
import { createCausalMask } from "../src/model/gemma4-base";
import { flashAttention, flashSupported } from "../src/model/flash-attention";

const B = 1, H = 8, D = 64;
const scale = 1 / Math.sqrt(D);

/** Materialized reference attention (matmul → causal mask → softmax → matmul),
 *  GQA-aware — standard ops with correct vjps → the trusted backward baseline. */
function refSdpa(q: MlxArray, k: MlxArray, v: MlxArray): MlxArray {
  const [Bq, Hq, T, Dh] = q.shape as [number, number, number, number];
  const Hkv = k.shape[1]!, Tk = k.shape[2]!, reps = Hq / Hkv;
  const q5 = ops.reshape(q, [Bq, Hkv, reps, T, Dh]);
  const k5 = ops.reshape(k, [Bq, Hkv, 1, Tk, Dh]);
  const v5 = ops.reshape(v, [Bq, Hkv, 1, Tk, Dh]);
  const kT = ops.transposeAxes(k5, [0, 1, 2, 4, 3]);
  let scores = ops.matmul(q5, kT); k5.dispose(); kT.dispose();
  const s2 = ops.mulScalar(scores, scale); scores.dispose(); scores = s2;
  const mBool = createCausalMask(T, 0, null);
  const ninf = ops.scalarLike(-3.0e38, scores);
  const masked = ops.where(mBool, scores, ninf);
  scores.dispose(); ninf.dispose(); mBool.dispose();
  const probs = ops.softmaxAxis(masked, -1, true); masked.dispose();
  const out5 = ops.matmul(probs, v5); probs.dispose(); v5.dispose(); q5.dispose();
  const out = ops.reshape(out5, [Bq, Hq, T, Dh]); out5.dispose();
  return out;
}
const sdpaAttn = (q: MlxArray, k: MlxArray, v: MlxArray) => ops.sdpa(q, k, v, scale, "causal");
const flashAttn = (q: MlxArray, k: MlxArray, v: MlxArray) => flashAttention(q, k, v, scale, true);

function rand(shape: number[], key: MlxArray) { return ops.randomUniform(shape, Dtype.bfloat16, -1, 1, key); }
function relErr(a: MlxArray, ref: MlxArray): number {
  // ops.contiguous BEFORE readback — a vjp/grad output can be a strided view,
  // and raw toFloat32() would byte-scramble it (documented contiguity pitfall).
  const af = ops.contiguous(a.astype(Dtype.float32)).toFloat32();
  const rf = ops.contiguous(ref.astype(Dtype.float32)).toFloat32();
  let n = 0, d = 0;
  for (let i = 0; i < af.length; i++) { const e = af[i]! - rf[i]!; n += e * e; d += rf[i]! * rf[i]!; }
  return Math.sqrt(n) / (Math.sqrt(d) + 1e-12);
}
// Differentiate with an explicit RANDOM cotangent dO (NOT mean — a uniform
// mean-cotangent makes grads shrink with T and amplifies relative precision
// noise into a fake "growing error"). Vjp gives the exact grads for this dO.
function gradsOf(attn: (q: MlxArray, k: MlxArray, v: MlxArray) => MlxArray, q: MlxArray, k: MlxArray, v: MlxArray, dO: MlxArray) {
  const vjp = new Vjp((p) => [attn(p[0]!, p[1]!, p[2]!)], 1);
  const { outputs, vjps } = vjp.apply([q, k, v], [dO]);
  ops.evalAll([...outputs, ...vjps]);
  for (const o of outputs) o.dispose(); // forward outputs are owned too — free them so peak GB is real
  vjp.dispose();
  return vjps;
}

console.log(`\nattn backward — B=${B} H=${H} D=${D}, causal  (relErr vs materialized reference)\n`);
console.log(`${"T".padStart(5)} ${"path".padEnd(9)} ${"dQ".padStart(9)} ${"dK".padStart(9)} ${"dV".padStart(9)} ${"ms".padStart(8)} ${"peak GB".padStart(9)}`);
for (const T of [512, 2048, 4096]) {
  const key = ops.randomKey(0n), ks = ops.randomSplitNum(key, 4);
  const sk = (i: number) => { const r = ks.slice([i, 0], [i + 1, 2]); const s = ops.reshape(r, [2]); r.dispose(); return s; };
  const k0 = sk(0), k1 = sk(1), k2 = sk(2), k3 = sk(3);
  const q = rand([B, H, T, D], k0), k = rand([B, H, T, D], k1), v = rand([B, H, T, D], k2);
  const dO = rand([B, H, T, D], k3); // explicit random cotangent
  for (const a of [key, ks, k0, k1, k2, k3]) a.dispose();

  const ref = gradsOf(refSdpa, q, k, v, dO); // materialized reference grads
  for (const [name, attn] of [["ops.sdpa", sdpaAttn], ["flash", flashAttn]] as const) {
    if (name === "flash" && !flashSupported(q)) { console.log(`${String(T).padStart(5)} ${name.padEnd(9)}  (unsupported)`); continue; }
    try {
      clearCache(); resetPeakMemory();
      const t0 = Date.now();
      const g = gradsOf(attn, q, k, v, dO);
      const ms = Date.now() - t0, peak = peakMemory() / 1e9;
      console.log(`${String(T).padStart(5)} ${name.padEnd(9)} ${relErr(g[0]!, ref[0]!).toExponential(1).padStart(9)} ${relErr(g[1]!, ref[1]!).toExponential(1).padStart(9)} ${relErr(g[2]!, ref[2]!).toExponential(1).padStart(9)} ${ms.toFixed(0).padStart(8)} ${peak.toFixed(3).padStart(9)}`);
      for (const a of g) a.dispose();
    } catch (e) {
      console.log(`${String(T).padStart(5)} ${name.padEnd(9)}  THREW: ${((e as Error).message.split("\n")[0] ?? "").slice(0, 50)}`);
    }
  }
  for (const a of [...ref, q, k, v, dO]) a.dispose();
}
