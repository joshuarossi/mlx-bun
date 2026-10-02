import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { expandTrellis } from "@mlx-bun/inference/kernels/trellis";
import { nativeTrellisWidePrefill, wideTrellisPrefill, wideTrellisPrefillEligible } from "@mlx-bun/inference/kernels/trellis";

function packed(rows: number, bits: number) {
  const words = new Uint32Array(rows * 5120 * bits / 32);
  for (let i = 0; i < words.length; i++) words[i] = Math.imul(i + 31, 0x9e3779b1) >>> 0;
  const codes = MlxArray.fromBytesCopy(new Uint8Array(words.buffer), [rows, 5120 * bits / 32], Dtype.uint32);
  const f = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => 0.0003 + (i % 71) / 500), [rows]);
  const scales = f.astype(Dtype.float16); f.dispose();
  return { codes, scales, geometry: { k: bits, L: 12, T: 256, axis: 1 as const, rows, cols: 5120, inFeatures: 5120, outFeatures: rows } };
}

function input(m: number, transposed = false) {
  const f = MlxArray.fromFloat32(Float32Array.from({ length: m * 5120 }, (_, i) => ((i * 73 + 19) % 257 - 128) / 31), transposed ? [5120, m] : [m, 5120]);
  const x = f.astype(Dtype.bfloat16); f.dispose();
  if (!transposed) return x;
  const t = ops.transposeAxes(x, [1, 0]); x.dispose(); return t;
}

test("wide Trellis eligibility follows native arithmetic and the measured geometry", () => {
  const g = { k: 3, L: 12, T: 256, axis: 1 as const, rows: 17408, cols: 5120, inFeatures: 5120, outFeatures: 17408 };
  for (const m of [5, 8, 12, 15]) expect(wideTrellisPrefillEligible(g, m, Dtype.bfloat16)).toBe(nativeTrellisWidePrefill(m));
  for (const m of [1, 4, 16, 32]) expect(wideTrellisPrefillEligible(g, m, Dtype.bfloat16)).toBe(false);
  for (const changed of [{ axis: 0 as const }, { T: 128 }, { L: 10 }, { k: 1 }, { inFeatures: 4096 }, { outFeatures: 512 }, { blockInterleave: 2 as const }])
    expect(wideTrellisPrefillEligible({ ...g, ...changed }, 8, Dtype.bfloat16)).toBe(false);
  expect(wideTrellisPrefillEligible(g, 8, Dtype.float16)).toBe(false);
});

test.skipIf(!nativeTrellisWidePrefill(8))("wide Trellis matches complete native bf16 outputs at every affected row count", () => {
  {
    for (const bits of [2, 3, 4]) {
      const { codes, scales, geometry } = packed(128, bits);
      const e = expandTrellis(codes, scales, geometry, Dtype.bfloat16, 6), w = ops.transposeAxes(e, [1, 0]);
      try {
        for (let m = 5; m <= 15; m++) {
          const x = input(m), expected = ops.matmul(x, w), actual = wideTrellisPrefill(x, codes, scales, geometry);
          try { expect(Buffer.from(actual.rawBytes()).equals(Buffer.from(expected.rawBytes()))).toBe(true); }
          finally { x.dispose(); expected.dispose(); actual.dispose(); }
        }
      } finally { w.dispose(); e.dispose(); codes.dispose(); scales.dispose(); }
    }
  }
});
