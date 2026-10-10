// Folded-GQA attention over a quantized cache (layers/quantized-attention):
// each KV head's query rows share one quantized matmul. Same arithmetic as the
// unfused path, rows regrouped, so it agrees to bf16 rounding.
import { describe, expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { foldedQuantizedSdpa, foldedQuantizedSdpaEligible, quantizedSdpaUnfused } from "../../src/layers/quantized-attention";

const H = 24, KVH = 4, D = 256, scale = 1 / Math.sqrt(D);
const rand = (shape: number[], seed: number) => {
  const n = shape.reduce((a, b) => a * b, 1);
  using f = MlxArray.fromFloat32(Float32Array.from({ length: n }, (_, i) => Math.sin(i * 0.7311 + seed) * 0.8), shape);
  return f.astype(Dtype.bfloat16);
};
const maxDiff = (a: MlxArray, b: MlxArray) => {
  const x = a.astype(Dtype.float32).toFloat32(), y = b.astype(Dtype.float32).toFloat32();
  let e = 0; for (let i = 0; i < x.length; i++) e = Math.max(e, Math.abs(x[i]! - y[i]!));
  return e;
};

describe("folded-GQA quantized attention", () => {
  for (const bits of [4, 8]) for (const [N, L] of [[300, 1], [300, 8], [1100, 5]] as const) {
    test(`${bits}-bit KV, ${N} keys, ${L} rows`, () => {
      using q = rand([1, H, L, D], 1);
      using k = rand([1, KVH, N, D], 2);
      using v = rand([1, KVH, N, D], 3);
      const kq = ops.quantize(k, 64, bits), vq = ops.quantize(v, 64, bits);
      try {
        const mask = { mode: L > 1 ? "causal" : "", arr: null } as const;
        expect(foldedQuantizedSdpaEligible(q, kq, mask)).toBe(true);
        using ref = quantizedSdpaUnfused(q, kq, vq, scale, mask, 64, bits);
        using folded = foldedQuantizedSdpa(q, kq, vq, scale, 64, bits);
        expect(folded.shape).toEqual([1, H, L, D]);
        expect(maxDiff(ref, folded)).toBeLessThan(1e-2);
      } finally { for (const t of [kq, vq]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); } }
    });
  }
});
