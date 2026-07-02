// decode-roofline-bw.ts — measure THIS machine's achieved GPU memory
// bandwidth, three ways, to put a real floor under the M=1 decode roofline
// (re-examination of the megakernel post-mortem's "~4.5ms pure weight-read
// floor / mlx is 0.12ms off it" claim, 2026-07-01).
//
//   1. RAW streaming read: sum-reduce a large bf16 array (read-bound).
//   2. GEMV effective BW: ops.quantizedMatmul at M=1 over decode-shaped
//      quantized matrices (what a decode step actually does per layer).
//   3. bf16 GEMV matmul for comparison.
//
// Directional numbers (session, loaded-machine caveat) — decomposition,
// not a press release. bun scripts/experiments/decode-roofline-bw.ts

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";

const MB = 1024 * 1024;
const GB = 1024 * MB;

// fn returns EVERY output it created; all are evaluated (mlx is lazy —
// disposing an unevaluated array silently skips its compute) then disposed.
function timeMs(fn: () => MlxArray[], warm = 3, iters = 10): number {
  const runOnce = () => {
    const outs = fn();
    evalAll(outs);
    for (const o of outs) o.dispose();
  };
  for (let i = 0; i < warm; i++) runOnce();
  const t0 = performance.now();
  for (let i = 0; i < iters; i++) runOnce();
  return (performance.now() - t0) / iters;
}

// ---------- 1. raw streaming read (sum-reduce, bf16) ----------
for (const gib of [1, 2, 4]) {
  const n = (gib * GB) / 2; // bf16 = 2 bytes
  const rows = n / 65536;
  const a = ops.randomNormal([rows, 65536], Dtype.bfloat16, 0, 1, null);
  evalAll([a]);
  const ms = timeMs(() => [ops.meanAll(a)]);
  const gbps = (n * 2) / (ms / 1000) / 1e9;
  console.log(
    `raw-read  ${gib} GiB bf16 sum: ${ms.toFixed(2)} ms  -> ${gbps.toFixed(1)} GB/s`,
  );
  a.dispose();
}

// ---------- 2. quantized GEMV at M=1 (decode-shaped) ----------
// bytes read = packed weights + scales + biases (+ negligible x/out).
// REPS independent copies of the matrix are cycled back-to-back inside ONE
// eval (like a decode step's ~200-op command buffer), so the number is the
// in-step per-GEMV cost, not the eval round-trip latency. Distinct copies
// defeat the SLC/cache (a real step never reads the same weight twice).
function qgemv(label: string, N: number, H: number, bits: number, gs: number, reps: number) {
  const copies: { p: MlxArray; s: MlxArray; b: MlxArray }[] = [];
  const nCopies = Math.min(reps, 8);
  for (let c = 0; c < nCopies; c++) {
    const wf = ops.randomNormal([N, H], Dtype.float32, 0, 1, null);
    const qt = ops.quantize(wf, gs, bits);
    wf.dispose();
    const s = qt.scales.astype(Dtype.bfloat16);
    const b = qt.biases.astype(Dtype.bfloat16);
    evalAll([qt.packed, s, b]);
    qt.scales.dispose();
    qt.biases.dispose();
    copies.push({ p: qt.packed, s, b });
  }
  const x = ops.randomNormal([1, H], Dtype.bfloat16, 0, 1, null);
  evalAll([x]);
  const spec = { groupSize: gs, bits, mode: "affine" } as const;
  const ms = timeMs(() => {
    const outs: MlxArray[] = [];
    for (let i = 0; i < reps; i++) {
      const c = copies[i % nCopies]!;
      outs.push(ops.quantizedMatmul(x, c.p, c.s, c.b, spec, true));
    }
    return outs;
  }) / reps;
  const bytes = (N * H * bits) / 8 + 2 * (N * (H / gs)) * 2;
  const gbps = bytes / (ms / 1000) / 1e9;
  console.log(
    `qmv ${label}  [${N}x${H}] ${bits}b gs${gs} x${reps}: ${ms.toFixed(3)} ms/gemv  ${(bytes / MB).toFixed(1)} MiB -> ${gbps.toFixed(1)} GB/s`,
  );
  for (const c of copies) {
    c.p.dispose();
    c.s.dispose();
    c.b.dispose();
  }
  x.dispose();
}

qgemv("12B-head-like ", 262144, 3840, 4, 64, 4); // tied head, biggest single GEMV
qgemv("12B-mlp-like  ", 15360, 3840, 4, 64, 32);
qgemv("12B-mlp-8b    ", 15360, 3840, 8, 64, 32);
qgemv("e4b-head-like ", 262144, 2560, 4, 64, 4);
qgemv("cpm-head-like ", 130560, 1536, 4, 64, 8);
qgemv("cpm-mlp-like  ", 4608, 1536, 4, 64, 64);
qgemv("small-qkv-like", 1536, 1536, 4, 64, 64); // tiny GEMV: dispatch-bound?

// ---------- 3. bf16 GEMV ----------
{
  const N = 15360, H = 3840;
  const w = ops.randomNormal([N, H], Dtype.bfloat16, 0, 1, null);
  const x = ops.randomNormal([1, H], Dtype.bfloat16, 0, 1, null);
  evalAll([w, x]);
  const wT = ops.transposeAxes(w, [1, 0]);
  const REPS = 8; // 118 MiB matrix > SLC, reuse is safe; chain in one eval
  const ms = timeMs(() => {
    const outs: MlxArray[] = [];
    for (let i = 0; i < REPS; i++) outs.push(ops.matmul(x, wT));
    return outs;
  }) / REPS;
  const bytes = N * H * 2;
  console.log(
    `bf16 gemv [${N}x${H}]: ${ms.toFixed(3)} ms  -> ${(bytes / (ms / 1000) / 1e9).toFixed(1)} GB/s`,
  );
  w.dispose();
  wT.dispose();
  x.dispose();
}

// ---------- 4. per-dispatch overhead: chain of K trivial dependent ops ----------
for (const K of [50, 200]) {
  const a0 = ops.randomNormal([1, 2048], Dtype.bfloat16, 0, 1, null);
  evalAll([a0]);
  const ms = timeMs(() => {
    let cur = a0;
    const temps: MlxArray[] = [];
    for (let i = 0; i < K; i++) {
      const nx = ops.mulScalar(cur, 1.0000001);
      temps.push(nx);
      cur = nx;
    }
    return temps;
  });
  console.log(
    `dispatch-chain K=${K}: ${ms.toFixed(3)} ms total -> ${((ms / K) * 1000).toFixed(1)} us/op (encode+dispatch+tiny kernel)`,
  );
  a0.dispose();
}
