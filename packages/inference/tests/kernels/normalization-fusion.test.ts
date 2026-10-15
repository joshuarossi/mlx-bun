import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { residualRmsNorm } from "../../src/kernels/residual-rms-norm";
import { gatedRmsNorm } from "../../src/kernels/gated-rms-norm";
import { CompiledGatedRMSNorm, CompiledResidualRMSNorm } from "../../src/layers/compiled-normalization";
import { compiledPreciseSwiglu } from "../../src/models/qwen/blocks";

function tensor(shape: number[], dtype: Dtype, phase: number, scale = 1): MlxArray {
  using wide = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) },
    (_, i) => Math.sin(i * 7.13 + phase) * scale + Math.cos(i * 3.9 - phase) * scale / 2), shape);
  return wide.astype(dtype);
}
function equal(actual: MlxArray, expected: MlxArray): void {
  expect(actual.shape).toEqual(expected.shape);
  expect(actual.dtype).toBe(expected.dtype);
  expect(Buffer.from(actual.rawBytes()).equals(Buffer.from(expected.rawBytes()))).toBe(true);
}

test("residual fusion retains add, normalization, and weighted-product rounding", () => {
  // Both MLX reduction forms: <=4096 caches four values per thread; 5120 loops.
  for (const width of [63, 128, 256, 512, 4096, 5120]) {
    for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
      for (const rows of [1, 8]) {
        using x = tensor([2, rows, width], dtype, 0.3, 3);
        using update = tensor(x.shape, dtype, 1.7, 2);
        using weight = tensor([width], dtype, 0.8);
        using expectedResidual = ops.add(x, update);
        for (const eps of [1e-6, 1e-5]) {
          using expectedNorm = ops.rmsNorm(expectedResidual, weight, eps);
          const [residual, normalized] = residualRmsNorm(x, update, weight, eps);
          try { equal(residual, expectedResidual); equal(normalized, expectedNorm); }
          finally { residual.dispose(); normalized.dispose(); }
        }
      }
    }
  }
});

test("gated fusion retains bf16/half normalization before the float32 SiLU gate", () => {
  for (const width of [63, 64, 128, 256, 512, 4096, 5120]) {
    for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
      using x = tensor([2, 4, width], dtype, 0.3, 3);
      using weight = tensor([width], dtype, 0.8);
      for (const magnitude of [0, 0.01, 1, 32]) {
        using gate = tensor(x.shape, dtype, 1.7, magnitude);
        using norm = ops.rmsNorm(x, weight, 1e-6);
        using expected = compiledPreciseSwiglu(x, gate, norm);
        using actual = gatedRmsNorm(x, gate, weight, 1e-6);
        equal(actual, expected);
      }
    }
  }
});

test("compiled normalization changes grids and uses the current layer weights and dtype", () => {
  for (const width of [64, 128, 5120]) {
    for (const dtype of [Dtype.bfloat16, Dtype.float32]) {
      using first = tensor([width], dtype, 0.2);
      using second = tensor([width], dtype, 2.3);
      // The shared traces must take each layer's weight as a runtime input.
      for (const weight of [first, second, first]) {
        const residualNorm = new CompiledResidualRMSNorm(weight, 1e-6);
        const gatedNorm = new CompiledGatedRMSNorm(weight, 1e-6);
        for (const rows of [1, 8, 3, 1]) {
          using x = tensor([1, rows, width], dtype, rows / 7, 3);
          using update = tensor(x.shape, dtype, rows / 3, 2);
          using sum = ops.add(x, update);
          using expectedNorm = ops.rmsNorm(sum, weight, 1e-6);
          const [residual, normalized] = residualNorm.forward(x, update);
          try { equal(residual, sum); equal(normalized, expectedNorm); }
          finally { residual.dispose(); normalized.dispose(); }
          using norm = ops.rmsNorm(x, weight, 1e-6);
          using expectedGate = compiledPreciseSwiglu(x, update, norm);
          using actualGate = gatedNorm.forward(x, update);
          equal(actualGate, expectedGate);
        }
      }
    }
  }
});

test("fusion handles exact cancellation, zero rows, and strided inputs", () => {
  for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
    using source = tensor([1, 2, 256], dtype, 0.3);
    const [x, unused] = ops.split(source, [128], -1) as [MlxArray, MlxArray];
    unused.dispose();
    try {
      using negative = ops.neg(x);
      using weight = tensor([128], dtype, 1.2);
      using sum = ops.add(x, negative);
      using expected = ops.rmsNorm(sum, weight, 1e-6);
      const [residual, normalized] = residualRmsNorm(x, negative, weight, 1e-6);
      try { equal(residual, sum); equal(normalized, expected); }
      finally { residual.dispose(); normalized.dispose(); }
      using norm = ops.rmsNorm(x, weight, 1e-6);
      using expectedGate = compiledPreciseSwiglu(x, negative, norm);
      using actualGate = gatedRmsNorm(x, negative, weight, 1e-6);
      equal(actualGate, expectedGate);
    } finally { x.dispose(); }
  }
});
