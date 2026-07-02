// moe-expert-read-profile.ts — the profile-first pass for the 26B decode gap
// (decode-roofline-lookagain §6 item 2: ~4 ms/tok GPU overhead over floor).
// Synthetic weights at the EXACT 26B MoE shapes (hidden 2816, moe_intermediate
// 704, 128 experts, top-8, 30 layers, 4-bit gs64).
//
// FINDINGS (2026-07-02, M1 Max — anchored by real 26B decode @600 = 21.0-22.6
// ms/tok via decode-roofline-step.ts, matching the roofline row):
//   A  gather_qmm chain            8.10 ms/step  (~99 GB/s over 803 MB expert bytes)
//   A' sorted indices              8.26          — sorting: no effect
//   A" ONE expert repeated ×8      7.97          — 1/8 the unique bytes, SAME time:
//                                                  NOT bandwidth-bound, NOT locality
//   B  dense qmv, same bytes       4.45          (~180 GB/s — the kernel ceiling)
//   C  router chain ×30            1.6-2.6       (tiny-op dispatch tax, secondary)
//   E  gate+up MERGED (2 gqmm/lyr) 9.60          — FEWER dispatches is SLOWER:
//                                                  refutes the fixed-launch-cost model
// Upstream python mlx 0.31.2 reproduces the core gap (gather chain 6.18 vs
// dense 4.01 ms) — gather_qmm at M=1 is COMPUTE-bound, missing a qmv-class
// fast path; each per-expert [1,2816]->[704] product runs on mostly-idle GEMM
// tiles. Verdicts: expert-contiguous layout REFUTED (A"), dispatch-count
// reduction REFUTED (E); the real fix is a KERNEL — a custom Metal
// gather-qmv (MetalKernel infra + the fused-decode qdot pattern, indices read
// device-side), expected ~3.5-4 ms/tok ≈ +18-20% 26B decode @600 — or an
// upstream gather_qmm M=1 specialization.
//
//   bun scripts/experiments/moe-expert-read-profile.ts

import { MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

const HID = 2816, MOE = 704, NE = 128, TOPK = 8, LAYERS = 30;
const SPEC: ops.QuantSpec = { bits: 4, groupSize: 64, mode: "affine" };
const COPIES = 3; // distinct weight sets cycled so reads defeat the SLC

let seed = 3;
const rnd = (): number => { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return (seed / 0x7fffffff) - 0.5; };
const randArr = (shape: number[]): MlxArray => {
  const n = shape.reduce((a, b) => a * b, 1);
  const d = new Float32Array(n);
  for (let i = 0; i < n; i++) d[i] = rnd() * 0.3;
  const f = MlxArray.fromFloat32(d, shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
};
const quantStack = (out: number, inn: number): ops.QuantizedTensor => {
  const w = randArr([NE, out, inn]);
  const q = ops.quantize(w, SPEC.groupSize, SPEC.bits);
  ops.evalAll([q.packed, q.scales, q.biases]);
  w.dispose();
  return q;
};

console.log("### building synthetic 26B MoE stacks…");
const sets = Array.from({ length: COPIES }, () => ({
  gate: quantStack(MOE, HID),
  up: quantStack(MOE, HID),
  down: quantStack(HID, MOE),
}));
clearCache();

// expert bytes actually read per layer per token (top-8 rows of each stack)
const bytesPerRow = (t: ops.QuantizedTensor): number =>
  (t.packed.nbytes + t.scales.nbytes + t.biases.nbytes) / NE;
const perLayer = TOPK * (bytesPerRow(sets[0]!.gate) + bytesPerRow(sets[0]!.up) + bytesPerRow(sets[0]!.down));
console.log(`### expert bytes/layer/tok = ${(perLayer / 1e6).toFixed(1)} MB; ×${LAYERS} layers = ${(perLayer * LAYERS / 1e6).toFixed(0)} MB/tok`);

const gb = (bytes: number, ms: number): string => (bytes / 1e6 / ms).toFixed(0);
const med = (a: number[]): number => a.slice().sort((x, y) => x - y)[Math.floor(a.length / 2)]!;

const time = (fn: () => MlxArray, reps = 7): number => {
  for (let i = 0; i < 2; i++) { const o = fn(); ops.evalAll([o]); o.dispose(); }
  const times: number[] = [];
  for (let i = 0; i < reps; i++) {
    const t0 = performance.now();
    const o = fn();
    ops.evalAll([o]);
    times.push(performance.now() - t0);
    o.dispose();
  }
  return med(times);
};

// deterministic per-layer top-8 indices (distinct experts, unsorted order)
const idxFor = (l: number, sorted: boolean, repeated = false): MlxArray => {
  const v = Array.from({ length: TOPK }, (_, i) => repeated ? 7 : ((l * 37 + i * 17) % NE));
  const arr = repeated ? v : [...new Set(v)];
  while (arr.length < TOPK) arr.push((arr[arr.length - 1]! + 1) % NE);
  if (sorted) arr.sort((a, b) => a - b);
  return MlxArray.fromInt32(new Int32Array(arr), [1, 1, TOPK]);
};

// ---- arm A: the real MoE chain (weights fixed uniform 1/8 for simplicity) ----
const moeChain = (sorted: boolean, repeated = false) => (): MlxArray => {
  let h = randArr([1, 1, HID]);
  for (let l = 0; l < LAYERS; l++) {
    const s = sets[l % COPIES]!;
    const idx = idxFor(l, sorted, repeated);
    const x4 = ops.reshape(h, [1, 1, 1, HID]); // [.., 1, HID] per gather_qmm row shape
    const xg = ops.gatherQmm(x4, s.gate.packed, s.gate.scales, s.gate.biases, idx, SPEC, sorted);
    const xu = ops.gatherQmm(x4, s.up.packed, s.up.scales, s.up.biases, idx, SPEC, sorted);
    const act = ops.mul(ops.geluApprox(xg), xu); // [1,1,8,MOE]
    const xd = ops.gatherQmm(act, s.down.packed, s.down.scales, s.down.biases, idx, SPEC, sorted); // [1,1,8,HID]
    const summed = ops.sumAxis(xd, 2, false); // uniform expert weights
    const hn = ops.mulScalar(ops.reshape(summed, [1, 1, HID]), 1 / TOPK);
    for (const a of [h, idx, x4, xg, xu, act, xd, summed]) a.dispose();
    h = hn;
  }
  return h;
};

// ---- arm B: same bytes as dense qmv (one [3*8*MOE=16896, HID] weight per layer) ----
const denseSets = Array.from({ length: COPIES }, () => {
  const w = randArr([3 * TOPK * MOE, HID]);
  const q = ops.quantize(w, SPEC.groupSize, SPEC.bits);
  ops.evalAll([q.packed, q.scales, q.biases]);
  w.dispose();
  return q;
});
clearCache();
const denseChain = (): MlxArray => {
  let h = randArr([1, HID]);
  for (let l = 0; l < LAYERS; l++) {
    const s = denseSets[l % COPIES]!;
    const y = ops.quantizedMatmul(h, s.packed, s.scales, s.biases, SPEC, true); // [1, 16896]
    // fold back to [1, HID] so the chain stays shape-stable (cheap ops)
    const y2 = ops.reshape(y, [3 * TOPK, MOE]);
    const ysum = ops.sumAxis(y2, 0, false); // [MOE]
    const pad = ops.zeros([HID - MOE], Dtype.bfloat16);
    const hn = ops.reshape(ops.concatAxis([ysum.astype(Dtype.bfloat16), pad], 0), [1, HID]);
    for (const a of [h, y, y2, ysum, pad]) a.dispose();
    h = hn;
  }
  return h;
};

// ---- arm C: router chain alone ×30 ----
const routerW = quantStack(NE, HID); // reuse stack shape trick: rows 0..NE as a [NE,HID] proj? build dense instead
const routerDense = (() => { const w = randArr([NE, HID]); const q = ops.quantize(w, SPEC.groupSize, SPEC.bits); ops.evalAll([q.packed, q.scales, q.biases]); w.dispose(); return q; })();
const routerChain = (): MlxArray => {
  let h = randArr([1, 1, HID]);
  let acc: MlxArray | null = null;
  for (let l = 0; l < LAYERS; l++) {
    const scores = ops.quantizedMatmul(ops.reshape(h, [1, HID]), routerDense.packed, routerDense.scales, routerDense.biases, SPEC, true); // [1,128]
    const s3 = ops.reshape(scores, [1, 1, NE]);
    const part = ops.argpartitionAxis(s3, NE - TOPK, -1);
    const start = ops.fromInt32([NE - TOPK], [1]);
    const idx = ops.sliceDynamic(part, start, [2], [1, 1, TOPK]);
    const w = ops.takeAlongAxis(s3, idx, -1);
    const sm = ops.softmaxAxis(w, -1, false);
    const one = ops.sumAxis(ops.reshape(sm.astype(Dtype.float32), [TOPK]), 0, false);
    acc = acc === null ? one : (() => { const n = ops.add(acc!, one); acc!.dispose(); one.dispose(); return n; })();
    for (const a of [scores, s3, part, start, idx, w, sm]) a.dispose();
  }
  h.dispose();
  return acc!;
};

// ---- arm E: gate+up merged into ONE stack ([NE, 2*MOE, HID]) -> 2 dispatches/layer ----
const mergedSets = sets.map((s) => ({
  gateUp: {
    packed: ops.concatAxis([s.gate.packed, s.up.packed], 1),
    scales: ops.concatAxis([s.gate.scales, s.up.scales], 1),
    biases: ops.concatAxis([s.gate.biases, s.up.biases], 1),
  },
  down: s.down,
}));
for (const m of mergedSets) ops.evalAll([m.gateUp.packed, m.gateUp.scales, m.gateUp.biases]);
clearCache();
const mergedChain = (sorted: boolean) => (): MlxArray => {
  let h = randArr([1, 1, HID]);
  for (let l = 0; l < LAYERS; l++) {
    const s = mergedSets[l % COPIES]!;
    const idx = idxFor(l, sorted);
    const x4 = ops.reshape(h, [1, 1, 1, HID]);
    const gu = ops.gatherQmm(x4, s.gateUp.packed, s.gateUp.scales, s.gateUp.biases, idx, SPEC, sorted); // [..., 8, 1, 2*MOE]
    const guShape = gu.shape;
    const lastAt = guShape.length - 1;
    const half = (hi: number, lo = 0): MlxArray => {
      const start = guShape.map(() => 0);
      const stop = [...guShape];
      start[lastAt] = lo;
      stop[lastAt] = hi;
      return gu.slice(start, stop);
    };
    const xg = half(MOE);
    const xu = half(2 * MOE, MOE);
    const act = ops.mul(ops.geluApprox(xg), xu);
    const xd = ops.gatherQmm(act, s.down.packed, s.down.scales, s.down.biases, idx, SPEC, sorted);
    const summed = ops.sumAxis(xd, 2, false);
    const hn = ops.mulScalar(ops.reshape(summed, [1, 1, HID]), 1 / TOPK);
    for (const a of [h, idx, x4, gu, xg, xu, act, xd, summed]) a.dispose();
    h = hn;
  }
  return h;
};

const expertBytes = perLayer * LAYERS;
const msA = time(moeChain(false));
console.log(`A  gather_qmm chain (unsorted)     : ${msA.toFixed(2)} ms/step  ~${gb(expertBytes, msA)} GB/s over expert bytes`);
const msAs = time(moeChain(true));
console.log(`A' gather_qmm chain (sorted)       : ${msAs.toFixed(2)} ms/step  ~${gb(expertBytes, msAs)} GB/s`);
const msAr = time(moeChain(false, true));
console.log(`A" gather_qmm chain (1 expert ×8)  : ${msAr.toFixed(2)} ms/step  (${(perLayer / TOPK * LAYERS / 1e6).toFixed(0)} MB unique)`);
const msB = time(denseChain);
console.log(`B  dense qmv same bytes            : ${msB.toFixed(2)} ms/step  ~${gb(expertBytes, msB)} GB/s (ceiling)`);
const msC = time(routerChain);
console.log(`C  router chain ×30 alone          : ${msC.toFixed(2)} ms/step`);
const msE = time(mergedChain(false));
console.log(`E  gate+up MERGED (2 gqmm/layer)   : ${msE.toFixed(2)} ms/step  ~${gb(expertBytes, msE)} GB/s  (${(msA - msE).toFixed(2)} ms vs A)`);
console.log(`### gather-vs-dense gap = ${(msA - msB).toFixed(2)} ms/step; router = ${msC.toFixed(2)} ms; merge saves ${(msA - msE).toFixed(2)} ms`);
routerW.packed.dispose(); routerW.scales.dispose(); routerW.biases.dispose();
