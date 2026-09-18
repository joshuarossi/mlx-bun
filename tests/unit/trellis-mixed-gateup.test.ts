// Mixed-width fused gate/up (gate and up coded at DIFFERENT k), model-free.
// The kernel must be bit-identical to the path it replaces under each tail:
//   "split": two projection kernels + MLX's compiled swiglu (what a mixed layer
//            runs without the kernel), so adopting it changes no output;
//   "fused": fusedGateUpSwiglu's float32-sigmoid arithmetic (checked at equal k,
//            the only place both kernels can run).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { Trellis } from "../../src/quantize/trellis";
import {
  TrellisLinear, fusedGateUpEligible, fusedGateUpSwiglu, fusedGateUpSwigluMixed, mixedGateUpEligible,
} from "../../src/model/trellis-linear";
import { compiledSwiglu } from "../../src/model/qwen3_5";
import type { QuantSpec } from "../../src/config";

const L = 12, T = 256, N = 64, C = 512;
function lcg(seed: number): () => number {
  let s = seed >>> 0;
  return () => { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return s / 2 ** 32; };
}
function gaussian(n: number, seed: number, sigma: number): Float32Array {
  const r = lcg(seed), out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const u = Math.max(r(), 1e-12), v = r();
    out[i] = Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v) * sigma;
  }
  return out;
}
const spec = (k: number): QuantSpec => ({ bits: k, groupSize: T, mode: "trellis", trellis: { L, code: "1mad", axis: 1 } });
function layer(k: number, seed: number): { linear: TrellisLinear; dispose(): void } {
  const tr = new Trellis({ L, K: k, T, code: "1mad", tailBiting: true });
  const W = MlxArray.fromFloat32(gaussian(N * C, seed, 0.02), [N, C]);
  const { rec, codes, scales } = tr.fakeQuantRowsPacked(W, 64);
  W.dispose(); tr.dispose(); rec.dispose();
  return { linear: new TrellisLinear(codes, scales, spec(k), "kernel"), dispose() { codes.dispose(); scales.dispose(); } };
}
// bf16 -> f32 is exact, so equal Float32Arrays means equal bf16 bit patterns (no NaNs here).
const bits = (a: MlxArray) => Array.from(a.toFloat32());

describe("mixed-width fused gate/up", () => {
  for (const [kg, ku] of [[2, 3], [3, 4], [4, 2]] as const) {
    test(`k${kg}/k${ku}: "split" tail is bit-identical to two projections + compiled swiglu`, () => {
      const gate = layer(kg, 11 + kg), up = layer(ku, 29 + ku);
      expect(fusedGateUpEligible(gate.linear, up.linear)).toBe(false);
      expect(mixedGateUpEligible(gate.linear, up.linear)).toBe(true);
      // sigma 8 drives gate pre-activations across both sigmoid branches and into saturation.
      for (const M of [1, 2, 3, 4]) for (const sigma of [0.5, 8]) {
        const x = MlxArray.fromFloat32(gaussian(M * C, 500 + M, sigma), [1, M, C]).astype(Dtype.bfloat16);
        const mixed = fusedGateUpSwigluMixed(x, gate.linear, up.linear, "split");
        const g = gate.linear.forward(x, true), u = up.linear.forward(x, true);
        const reference = compiledSwiglu(g, u);
        expect(mixed.shape).toEqual([1, M, N]);
        expect(bits(mixed)).toEqual(bits(reference));
        for (const t of [x, mixed, g, u, reference]) t.dispose();
      }
      gate.dispose(); up.dispose();
    }, 30_000);
  }

  test(`equal k: "fused" tail is bit-identical to the same-width fused kernel`, () => {
    const gate = layer(3, 41), up = layer(3, 43);
    expect(mixedGateUpEligible(gate.linear, up.linear)).toBe(false); // the same-width kernel owns this case
    for (const M of [1, 3]) {
      const x = MlxArray.fromFloat32(gaussian(M * C, 600 + M, 8), [1, M, C]).astype(Dtype.bfloat16);
      const mixed = fusedGateUpSwigluMixed(x, gate.linear, up.linear, "fused");
      const stock = fusedGateUpSwiglu(x, gate.linear, up.linear);
      expect(bits(mixed)).toEqual(bits(stock));
      for (const t of [x, mixed, stock]) t.dispose();
    }
    gate.dispose(); up.dispose();
  }, 30_000);
});
