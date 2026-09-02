// Packed trellis format + Metal kernels (Q2b), model-free: encode a small
// random matrix with the codec, pack it, and check that (a) the host unpack,
// (b) the expand kernel, (c) the reduce matvec (axis=1), (d) the scatter
// matvec (axis=0) and (e) the M>4 expand+matmul path all reproduce the
// codec's own reconstruction — bit-exact where the math is identical
// (decode), within fp32-accumulation tolerance for the matvecs.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import {
  Trellis, lut1mad, packStates, stateAt, unpackDecodeHost, wordsPerBlock,
} from "../../src/quantize/trellis";
import { TrellisLinear, expandTrellis, trellisGeometry, fusedGateUpSwiglu, fusedGateUpEligible } from "../../src/model/trellis-linear";
import { compiledSwiglu } from "../../src/model/qwen3_5";
import type { QuantSpec } from "../../src/config";

const L = 12, T = 256;
const N = 64, C = 512;  // 64 coded rows × 2 blocks — dense coverage of the 1021 code values

function lcg(seed: number): () => number {
  let s = seed >>> 0;
  return () => { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return s / 2 ** 32; };
}
function gaussian(n: number, seed: number): Float32Array {
  const r = lcg(seed), out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const u = Math.max(r(), 1e-12), v = r();
    out[i] = Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v) * 0.02;
  }
  return out;
}
const bf16 = (x: number): number => {
  const f = new Float32Array([x]), u = new Uint32Array(f.buffer);
  u[0] = (u[0]! + 0x7fff + ((u[0]! >> 16) & 1)) & 0xffff0000;
  return f[0]!;
};
const maxAbsDiff = (a: Float32Array, b: Float32Array): number => {
  let m = 0;
  for (let i = 0; i < a.length; i++) m = Math.max(m, Math.abs(a[i]! - b[i]!));
  return m;
};
const spec = (k: number, axis: 0 | 1): QuantSpec =>
  ({ bits: k, groupSize: T, mode: "trellis", trellis: { L, code: "1mad", axis } });

function encoded(k: number, seed = 7) {
  const tr = new Trellis({ L, K: k, T, code: "1mad", tailBiting: true });
  const W = MlxArray.fromFloat32(gaussian(N * C, seed + k), [N, C]);
  const { rec, codes, scales } = tr.fakeQuantRowsPacked(W, 64);
  W.dispose();
  tr.dispose();
  return { rec, codes, scales };
}

describe("packStates / stateAt", () => {
  test("round-trips the state sequence for k=2,3,4 (tail-biting window)", () => {
    for (const k of [2, 3, 4]) {
      const r = lcg(k), states = new Int32Array(T), G = 1 << k;
      // A valid bitshift path: s_t = ((s_{t-1} << k) | b_t) & (2^L-1), tail-biting closed.
      const syms = Array.from({ length: T }, () => Math.floor(r() * G));
      const m = L / k;
      for (let t = 0; t < T; t++) {
        let s = 0;
        for (let j = m - 1; j >= 0; j--) s = (s << k) | syms[(t - j + T) % T]!;
        states[t] = s;
      }
      const wpb = wordsPerBlock(T, k), words = new Uint32Array(wpb);
      packStates(states, 1, T, k, words);
      for (let t = 0; t < T; t++) expect(stateAt(words, 0, wpb, t, T, k, L)).toBe(states[t]!);
    }
  });
});

describe("TrellisLinear kernels", () => {
  for (const k of [2, 3, 4]) {
    test(`k=${k}: host unpack and expand kernel reproduce the codec (bit-exact)`, () => {
      const { rec, codes, scales } = encoded(k);
      const recF = rec.toFloat32();
      const bytes = codes.rawBytes();
      const words = new Uint32Array(bytes.buffer, bytes.byteOffset, bytes.byteLength / 4);
      const sc = scales.astype(Dtype.float32).toFloat32();
      const host = unpackDecodeHost(words, sc, N, C, k, T, lut1mad(L));
      expect(maxAbsDiff(host, recF)).toBe(0);

      const g = trellisGeometry(codes, spec(k, 1));
      const ex = expandTrellis(codes, scales, g, Dtype.bfloat16);
      const exF = ex.toFloat32();
      const want = Float32Array.from(recF, bf16);
      expect(maxAbsDiff(exF, want)).toBe(0);
      for (const a of [rec, codes, scales, ex]) a.dispose();
    });

    test(`k=${k}: reduce (axis=1) and scatter (axis=0) matvecs match a bf16 matmul`, () => {
      const { rec, codes, scales } = encoded(k);
      const w = rec.astype(Dtype.bfloat16);           // stored matrix [N, C], bf16
      for (const M of [1, 3]) {
        // axis=1: W = stored [out=N, in=C]; y = x @ Wᵀ
        const lin1 = new TrellisLinear(codes, scales, spec(k, 1), "kernel");
        const x1 = MlxArray.fromFloat32(gaussian(M * C, 100 + M), [M, C]).astype(Dtype.bfloat16);
        const y1 = lin1.forward(x1);
        const wt = ops.transposeAxes(w, [1, 0]);
        const ref1 = ops.matmul(x1, wt);
        expect(y1.shape).toEqual([M, N]);
        expect(maxAbsDiff(y1.toFloat32(), ref1.toFloat32())).toBeLessThan(2e-3);
        // axis=0: stored is Wᵀ [in=N, out=C]; y = x @ stored
        const lin0 = new TrellisLinear(codes, scales, spec(k, 0), "kernel");
        const x0 = MlxArray.fromFloat32(gaussian(M * N, 200 + M), [M, N]).astype(Dtype.bfloat16);
        const y0 = lin0.forward(x0);
        const ref0 = ops.matmul(x0, w);
        expect(y0.shape).toEqual([M, C]);
        expect(maxAbsDiff(y0.toFloat32(), ref0.toFloat32())).toBeLessThan(2e-3);
        for (const a of [x1, y1, wt, ref1, x0, y0, ref0]) a.dispose();
      }
      for (const a of [rec, codes, scales, w]) a.dispose();
    });

    test(`k=${k}: M>4 takes the expand+matmul path; MLX_BUN_TRELLIS=expand carrier agrees`, () => {
      const { rec, codes, scales } = encoded(k);
      const w = rec.astype(Dtype.bfloat16);
      const M = 6;
      const lin = new TrellisLinear(codes, scales, spec(k, 1), "kernel");
      const x = MlxArray.fromFloat32(gaussian(M * C, 300), [1, M, C]).astype(Dtype.bfloat16);
      const y = lin.forward(x);
      const wt = ops.transposeAxes(w, [1, 0]);
      const x2 = ops.reshape(x, [M, C]);
      const ref = ops.matmul(x2, wt);
      expect(y.shape).toEqual([1, M, N]);
      expect(maxAbsDiff(y.toFloat32(), ref.toFloat32())).toBeLessThan(2e-3);
      const carrier = new TrellisLinear(codes, scales, spec(k, 1), "expand");
      expect(carrier.fallback).not.toBeNull();
      const yc = carrier.forward(x);
      expect(maxAbsDiff(yc.toFloat32(), ref.toFloat32())).toBeLessThan(2e-2);
      for (const a of [rec, codes, scales, w, x, y, wt, x2, ref, yc]) a.dispose();
    });

    test(`k=${k}: fused gate/up/swiglu kernel matches the two-matvec + compiled swiglu graph`, () => {
      const a = encoded(k), b = encoded(k, 17);
      const gate = new TrellisLinear(a.codes, a.scales, spec(k, 1), "kernel");
      const up = new TrellisLinear(b.codes, b.scales, spec(k, 1), "kernel");
      expect(fusedGateUpEligible(gate, up)).toBe(true);
      for (const M of [1, 4]) {
        const x = MlxArray.fromFloat32(gaussian(M * C, 400 + M), [1, M, C]).astype(Dtype.bfloat16);
        const fused = fusedGateUpSwiglu(x, gate, up);
        const g = gate.forward(x), u = up.forward(x);
        const ref = compiledSwiglu(g, u);
        expect(fused.shape).toEqual([1, M, N]);
        expect(maxAbsDiff(fused.toFloat32(), ref.toFloat32())).toBeLessThan(2e-3);
        for (const t of [x, fused, g, u, ref]) t.dispose();
      }
      for (const t of [a.rec, a.codes, a.scales, b.rec, b.codes, b.scales]) t.dispose();
    });
  }
});
