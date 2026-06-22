// Why does warm (re-decode the boundary token) differ from cold (prefill it)?
// MiniCPM5's bf16 path uses ONE ops.sdpa for both — so the only difference is HOW
// the boundary is presented to SDPA:
//   cold prefill: it's the LAST of T queries, with a CAUSAL mask.
//   warm decode:  it's a SINGLE query, with NO mask (attends all cached keys).
// Both should give the boundary the identical result (same q, same K/V, same keys
// in scope). This isolates whether mx.fast.scaled_dot_product_attention is
// position-consistent. If `single` != `full[last]`, that's the warm-vs-cold cause.
//
//   bun scripts/experiments/sdpa-position-consistency.ts
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";

const B = 1, H = 24, T = 18, D = 64;
const scale = 1 / Math.sqrt(D);
function rand(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const f = new Float32Array(n);
  for (let i = 0; i < n; i++) f[i] = Math.random() * 2 - 1;
  return MlxArray.fromFloat32(f, shape);
}
function bf16(a: MlxArray): MlxArray { const b = a.astype(Dtype.bfloat16); a.dispose(); return b; }

for (const dt of ["f32", "bf16"] as const) {
  let q = rand([B, H, T, D]), k = rand([B, H, T, D]), v = rand([B, H, T, D]);
  if (dt === "bf16") { q = bf16(q); k = bf16(k); v = bf16(v); }

  // cold: full causal SDPA over T queries → take the LAST query's output
  const full = ops.sdpa(q, k, v, scale, "causal", null); // [B,H,T,D]
  const start = MlxArray.fromInt32(new Int32Array([T - 1]), [1]);
  const fullLast = ops.sliceDynamic(full, start, [2], [B, H, 1, D]); // [B,H,1,D]

  // warm: the SAME last query as a SINGLE query, no mask (attends all T keys)
  const qLast = ops.sliceDynamic(q, start, [2], [B, H, 1, D]); // [B,H,1,D]
  const single = ops.sdpa(qLast, k, v, scale, "", null); // [B,H,1,D]

  evalAll([fullLast, single]);
  const a = fullLast.toFloat32(), b = single.toFloat32();
  let mx = 0, n = 0; for (let i = 0; i < a.length; i++) { const d = Math.abs(a[i]! - b[i]!); if (d > mx) mx = d; if (d !== 0) n++; }
  console.log(`### ${dt} boundary  prefill[causal,last] vs decode[single,nomask]: maxAbsΔ=${mx.toExponential(3)}  ${mx === 0 ? "BIT-IDENTICAL ✓" : "DIFFERS"}`);

  // L-invariance of the PREFIX: prefill[T] vs prefill[T-1] for positions 0..T-2.
  // (cold computes the prefix KV in a T-query SDPA; warm cached it from a T-1 one.)
  const startPrefix = MlxArray.fromInt32(new Int32Array([0]), [1]);
  const qm = ops.sliceDynamic(q, startPrefix, [2], [B, H, T - 1, D]);
  const km = ops.sliceDynamic(k, startPrefix, [2], [B, H, T - 1, D]);
  const vm = ops.sliceDynamic(v, startPrefix, [2], [B, H, T - 1, D]);
  const fullTm1 = ops.sdpa(qm, km, vm, scale, "causal", null);      // [B,H,T-1,D]
  const fullPrefix = ops.sliceDynamic(full, startPrefix, [2], [B, H, T - 1, D]);
  evalAll([fullTm1, fullPrefix]);
  const c = fullPrefix.toFloat32(), e = fullTm1.toFloat32();
  let mx2 = 0; for (let i = 0; i < c.length; i++) { const d = Math.abs(c[i]! - e[i]!); if (d > mx2) mx2 = d; }
  console.log(`### ${dt} prefix    prefill[T][0:T-1] vs prefill[T-1]:               maxAbsΔ=${mx2.toExponential(3)}  ${mx2 === 0 ? "BIT-IDENTICAL ✓ (SDPA is L-invariant)" : "DIFFERS"}`);

  // CAUSAL SANITY: with a real causal mask, position 0 attends ONLY key 0 → out[0] == v[0].
  const v0 = ops.sliceDynamic(v, startPrefix, [2], [B, H, 1, D]);
  const out0 = ops.sliceDynamic(full, startPrefix, [2], [B, H, 1, D]);
  evalAll([v0, out0]); const vv = v0.toFloat32(), oo = out0.toFloat32();
  let mx0 = 0; for (let i = 0; i < vv.length; i++) { const d = Math.abs(vv[i]! - oo[i]!); if (d > mx0) mx0 = d; }
  console.log(`### ${dt} causal?   out[0] == v[0] (true iff causal actually masks):  maxAbsΔ=${mx0.toExponential(3)}  ${mx0 === 0 ? "CAUSAL OK" : "NOT MASKED ← prefix test was non-causal, the 2.0 is bogus"}`);
  for (const x of [q, k, v, full, fullLast, qLast, single, start, startPrefix, qm, km, vm, fullTm1, fullPrefix, v0, out0]) x.dispose();
}
