// Model-free op parity: load fixed inputs from scripts/op-parity-dump.py, run
// them through mlx-bun's OWN libmlx kernels, and compare to the oracle's
// outputs. BIT-IDENTICAL ⇒ the two builds' kernels match on this machine.
//   bun scripts/op-parity-check.ts
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";

const load = async (name: string, shape: number[]): Promise<MlxArray> => {
  const f32 = new Float32Array(await Bun.file(`/tmp/op-${name}.f32`).arrayBuffer());
  return MlxArray.fromFloat32(f32, shape).astype(Dtype.bfloat16);
};
const ref = async (name: string): Promise<Float32Array> =>
  new Float32Array(await Bun.file(`/tmp/op-${name}.f32`).arrayBuffer());

function cmp(label: string, mine: Float32Array, refv: Float32Array) {
  let maxAbs = 0, exact = 0;
  for (let i = 0; i < refv.length; i++) {
    const d = Math.abs(mine[i]! - refv[i]!);
    if (d > maxAbs) maxAbs = d;
    if (d === 0) exact++;
  }
  const pct = ((exact / refv.length) * 100).toFixed(2);
  console.log(
    `${label.padEnd(13)} bit-exact=${exact}/${refv.length} (${pct}%)  max|abs|=${maxAbs.toExponential(2)}` +
    ` ${exact === refv.length ? "✅ IDENTICAL" : "❌ DIVERGES"}`,
  );
}

const toF32 = (a: MlxArray): Float32Array => {
  // force contiguous row-major before raw readback — fast SDPA can return a
  // non-contiguous result whose toFloat32() would otherwise misread.
  const c = ops.contiguous(a);
  const f = c.astype(Dtype.float32);
  const out = f.toFloat32();
  c.dispose();
  f.dispose();
  return out;
};

// rms_norm
{
  const x = await load("rms_x", [128, 768]);
  const g = await load("rms_w", [768]);
  const out = ops.rmsNorm(x, g, 1e-6);
  cmp("rms_norm", toF32(out), await ref("rms_out"));
  x.dispose(); g.dispose(); out.dispose();
}
// gelu_approx
{
  const x = await load("gelu_x", [128, 3072]);
  const out = ops.geluApprox(x);
  cmp("gelu_approx", toF32(out), await ref("gelu_out"));
  x.dispose(); out.dispose();
}
// sdpa — moderate scale, bit-exact comparison of both dispatch paths
{
  const [B, H, N, D] = [1, 4, 128, 64];
  const scale = 1.0 / Math.sqrt(D);
  const q = await load("sdpa_q", [B, H, N, D]);
  const k = await load("sdpa_k", [B, H, N, D]);
  const v = await load("sdpa_v", [B, H, N, D]);
  const oNo = ops.sdpa(q, k, v, scale, "", null);
  cmp("sdpa nomask", toF32(oNo), await ref("sdpa_out"));
  oNo.dispose();
  const zero = ops.zeros([B, 1, N, N], Dtype.bfloat16);
  const oMa = ops.sdpa(q, k, v, scale, "array", zero);
  cmp("sdpa arraymask", toF32(oMa), await ref("sdpa_out_mask"));
  zero.dispose(); oMa.dispose();
  q.dispose(); k.dispose(); v.dispose();
}
// bf16 matmul
{
  const a = await load("mm_a", [128, 768]);
  const b = await load("mm_b", [768, 512]);
  cmp("matmul", toF32(ops.matmul(a, b)), await ref("mm_out"));
  a.dispose(); b.dispose();
}
// manual VisionRMSNorm — test ops.square vs ops.pow(x,2) for the x**2 step
{
  const xf32 = new Float32Array(await Bun.file("/tmp/op-vrn_x.f32").arrayBuffer());
  const wf32 = new Float32Array(await Bun.file("/tmp/op-vrn_w.f32").arrayBuffer());
  const refOut = await ref("vrn_out");
  const run = (sq: (a: MlxArray) => MlxArray, label: string) => {
    const x = MlxArray.fromFloat32(xf32, [1, 256, 12, 64]).astype(Dtype.bfloat16);
    const w = MlxArray.fromFloat32(wf32, [64]).astype(Dtype.bfloat16);
    const xf = x.astype(Dtype.float32);
    const s = sq(xf);
    const varr = ops.meanAxis(s, 3, true);
    const eps = ops.scalarLike(1e-6, varr);
    const vare = ops.add(varr, eps);
    const r = ops.rsqrt(vare);
    const normed = ops.mul(xf, r);
    const wf = w.astype(Dtype.float32);
    const out = ops.mul(normed, wf).astype(Dtype.bfloat16);
    cmp(label, toF32(out), refOut);
    [x, w, xf, s, varr, eps, vare, r, normed, wf, out].forEach((a) => a.dispose());
  };
  run((a) => ops.square(a), "vrn square");
  run((a) => ops.pow(a, ops.scalarLike(2, a)), "vrn pow");
}
// clip with bf16 scalar bounds
{
  const x = await load("clip_x", [128, 768]);
  const lo = MlxArray.fromFloat32(new Float32Array([-3.5]), [1]).astype(Dtype.bfloat16);
  const hi = MlxArray.fromFloat32(new Float32Array([3.484375]), [1]).astype(Dtype.bfloat16);
  cmp("clip", toF32(ops.clip(x, lo, hi)), await ref("clip_out"));
  x.dispose(); lo.dispose(); hi.dispose();
}
// cos / sin (f32, RoPE table)
{
  const sx = new Float32Array(await Bun.file("/tmp/op-trig_x.f32").arrayBuffer());
  const x1 = MlxArray.fromFloat32(sx, [256, 16]);
  const x2 = MlxArray.fromFloat32(sx, [256, 16]);
  cmp("cos", toF32(ops.cos(x1)), await ref("cos_out"));
  cmp("sin", toF32(ops.sin(x2)), await ref("sin_out"));
  x1.dispose(); x2.dispose();
}
// pooler: my f32-matmul vs a bf16-matmul, vs optiq's einsum
{
  const [pL, psoft, pd] = [2304, 256, 768];
  const wf = new Float32Array(await Bun.file("/tmp/op-pool_w.f32").arrayBuffer());
  const xf = new Float32Array(await Bun.file("/tmp/op-pool_x.f32").arrayBuffer());
  const refOut = await ref("pool_out");
  // poolW = weights^T [soft, L]; my features() builds it already transposed.
  const wmat = MlxArray.fromFloat32(wf, [pL, psoft]);
  const wT = ops.transposeAxes(wmat, [1, 0]); // [soft, L]
  wmat.dispose();
  const xb = MlxArray.fromFloat32(xf, [pL, pd]).astype(Dtype.bfloat16);
  // (a) my current path: upcast x→f32, f32 matmul, →bf16
  const xfa = xb.astype(Dtype.float32);
  cmp("pool f32mm", toF32(ops.matmul(wT, xfa).astype(Dtype.bfloat16)), refOut);
  xfa.dispose();
  // (b) bf16 matmul (x stays bf16), wT→bf16
  const wTb = wT.astype(Dtype.bfloat16);
  cmp("pool bf16mm", toF32(ops.matmul(wTb, xb).astype(Dtype.bfloat16)), refOut);
  wTb.dispose();
  wT.dispose(); xb.dispose();
}
// SDPA padded+masked (optiq) vs unpadded (siglip) — is the real-token output
// identical? scale=1.0 with RMS-normed q/k, the vision-encoder regime.
{
  const [H, Nr, Np, D] = [12, 2304, 2520, 64];
  const rng = (n: number) => {
    const a = new Float32Array(n);
    let s = 12345;
    for (let i = 0; i < n; i++) { s = (s * 1103515245 + 12345) & 0x7fffffff; a[i] = (s / 0x7fffffff) * 2 - 1; }
    return a;
  };
  const norml = (x: MlxArray) => ops.rmsNorm(x, null, 1e-6); // unit-RMS over last dim
  const mk = (n: number) => norml(MlxArray.fromFloat32(rng(H * Nr * D), [1, H, Nr, D]).astype(Dtype.bfloat16));
  const q = mk(0), k = mk(1), v = MlxArray.fromFloat32(rng(H * Nr * D), [1, H, Nr, D]).astype(Dtype.bfloat16);
  // unpadded
  const ou = ops.sdpa(q, k, v, 1.0, "", null);
  // padded to Np with a -1e4 additive mask on the 216 padded keys
  const pad = (x: MlxArray) => {
    const z = ops.zeros([1, H, Np - Nr, D], Dtype.bfloat16);
    const r = ops.concatAxis([x, z], 2);
    z.dispose();
    return r;
  };
  const qp = pad(q), kp = pad(k), vp = pad(v);
  const valid = new Float32Array(Np); valid.fill(1, 0, Nr);
  const vrow = MlxArray.fromFloat32(valid, [Np]);
  const m4 = ops.reshape(vrow, [1, 1, 1, Np]); vrow.dispose();
  const big = ops.mulScalar(ops.sub(m4, ops.scalarLike(1, m4)), 1e4); // 0 valid / -1e4 pad
  const mask = big.astype(Dtype.bfloat16);
  const op = ops.sdpa(qp, kp, vp, 1.0, "array", mask);
  const opReal = op.slice([0, 0, 0, 0], [1, H, Nr, D]);
  // compare real-token outputs
  let exact = 0, maxAbs = 0;
  const a = toF32(ou), b = toF32(opReal);
  for (let i = 0; i < a.length; i++) { const d = Math.abs(a[i]! - b[i]!); if (d === 0) exact++; if (d > maxAbs) maxAbs = d; }
  console.log(`sdpa pad-vs-unpad  bit-exact=${exact}/${a.length} (${(exact / a.length * 100).toFixed(2)}%)  max|abs|=${maxAbs.toExponential(2)} ${exact === a.length ? "✅ no-op" : "❌ DIFFERS"}`);
  [q, k, v, ou, qp, kp, vp, m4, big, mask, op, opReal].forEach((x) => x.dispose());
}
// full multidimensional RoPE — siglip's table-build + partitioned rotate-half
{
  const L = 256, H = 12, D = 64, theta = 100;
  const cpd = 32, half = 16;
  const pos = new Float32Array(await Bun.file("/tmp/op-rope_pos.f32").arrayBuffer()); // [L,2]
  const px = new Float32Array(L), py = new Float32Array(L);
  for (let i = 0; i < L; i++) { px[i] = pos[i * 2]!; py[i] = pos[i * 2 + 1]!; }
  // cos/sin tables (replicates #ropeTables)
  const ar = ops.arange(0, half, 1, Dtype.float32);
  const freq = ops.mulScalar(ar, 2 / cpd); ar.dispose();
  const ts = ops.pow(ops.scalarLike(theta, freq), freq);
  const perDim = (p: Float32Array, fn: (x: MlxArray) => MlxArray): MlxArray => {
    const pa = MlxArray.fromFloat32(p, [L, 1]);
    const sin = ops.div(pa, ts); pa.dispose();
    const d = fn(sin); sin.dispose();
    const dup = ops.concatAxis([d, d], 1); d.dispose();
    return dup;
  };
  const mkTable = (fn: (x: MlxArray) => MlxArray): MlxArray => {
    const xd = perDim(px, fn), yd = perDim(py, fn);
    const full = ops.concatAxis([xd, yd], 1); xd.dispose(); yd.dispose();
    const r = ops.reshape(full, [1, L, 1, D]).astype(Dtype.bfloat16); full.dispose();
    return r;
  };
  const cosA = mkTable((x) => ops.cos(x));
  const sinA = mkTable((x) => ops.sin(x));
  ts.dispose(); freq.dispose();
  // apply (replicates #rope + #partitionedRotateHalf)
  const qf = new Float32Array(await Bun.file("/tmp/op-rope_q.f32").arrayBuffer());
  const q = MlxArray.fromFloat32(qf, [1, L, H, D]).astype(Dtype.bfloat16);
  const sl = (x: MlxArray, a: number, b: number) => x.slice([0, 0, 0, a], [1, L, H, b]);
  const rot = (x: MlxArray): MlxArray => {
    const parts: MlxArray[] = [];
    for (let d = 0; d < 2; d++) {
      const o = d * cpd;
      const x1 = sl(x, o, o + half), x2 = sl(x, o + half, o + cpd);
      const nx2 = ops.neg(x2);
      parts.push(ops.concatAxis([nx2, x1], 3));
      x1.dispose(); x2.dispose(); nx2.dispose();
    }
    const r = ops.concatAxis(parts, 3); parts.forEach((p) => p.dispose());
    return r;
  };
  const rotated = rot(q);
  const out = ops.add(ops.mul(q, cosA), ops.mul(rotated, sinA));
  cmp("rope", toF32(out), await ref("rope_out"));
  [cosA, sinA, q, rotated, out].forEach((x) => x.dispose());
}
