// Attention kernels for Qwen3.8 geometry (24 query heads, 4 KV heads, head dim
// 256): the fused one-row decode over a 4-bit affine cache against the
// unfused quantized path, and multi-query flash decoding against MLX sdpa.
// Both reorder the reduction (online softmax, f32 accumulation), so they agree
// to bf16 precision rather than bit for bit.
import { describe, expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { quantizedSdpaUnfused } from "../../src/layers/quantized-attention";
import { kvq4DecodeEligible, kvq4DecodeSdpa } from "../../src/kernels/attention/kvq4-decode";
import { multiQueryCausalSdpa } from "../../src/kernels/attention/multi-query";

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

describe("fused one-row decode over a 4-bit cache", () => {
  const bits = 4;
  for (const N of [300, 1100]) {
    test(`${N} keys`, () => {
      using q = rand([1, H, 1, D], 1);
      using k = rand([1, KVH, N, D], 2);
      using v = rand([1, KVH, N, D], 3);
      const kq = ops.quantize(k, 64, bits), vq = ops.quantize(v, 64, bits);
      try {
        expect(kvq4DecodeEligible(q, kq, 64, bits)).toBe(true);
        using ref = quantizedSdpaUnfused(q, kq, vq, scale, { mode: "", arr: null }, 64, bits);
        using fused = kvq4DecodeSdpa(q, kq, vq, scale);
        expect(maxDiff(ref, fused)).toBeLessThan(2e-2);
      } finally { for (const t of [kq, vq]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); } }
    });
  }
});

test("multi-query flash decoding matches causal sdpa for 2..8 rows", () => {
  for (const [N, L] of [[300, 2], [700, 4], [1100, 8]] as const) {
    using q = rand([1, H, L, D], 4);
    using k = rand([1, KVH, N, D], 5);
    using v = rand([1, KVH, N, D], 6);
    using ref = ops.sdpa(q, k, v, scale, "causal", null);
    using mq = multiQueryCausalSdpa(q, k, v, scale);
    expect(maxDiff(ref, mq), `N${N} L${L}`).toBeLessThan(2e-2);
  }
}, 30_000);
