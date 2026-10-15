import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { materializeCopy } from "@mlx-bun/mlx/materialize";
import * as ops from "@mlx-bun/mlx/ops";
import { siluRmsHeads } from "../../src/kernels/delta/silu-rms-heads";
import { CompiledSiluRMSHeads } from "../../src/layers/delta-heads";
import { compiledSilu } from "../../src/models/qwen/blocks";

function tensor(shape: number[], dtype: Dtype, seed: number, magnitude = 1): MlxArray {
  using wide = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) },
    (_, i) => magnitude * (Math.sin(i * 1.72 + seed) + Math.cos(i * 0.23 - seed))), shape);
  return wide.astype(dtype);
}

function reference(x: MlxArray, qScale: MlxArray, kScale: MlxArray, hk: number, hv: number, dv: number): MlxArray[] {
  const [b, s] = x.shape, dk = qScale.size;
  using activated = compiledSilu(x);
  const [q, k, v] = ops.split(activated, [hk * dk, 2 * hk * dk], -1) as [MlxArray, MlxArray, MlxArray];
  try {
    using qh = ops.reshape(q, [b!, s!, hk, dk]);
    using kh = ops.reshape(k, [b!, s!, hk, dk]);
    using vh = ops.reshape(v, [b!, s!, hv, dv]);
    return [ops.rmsNorm(qh, qScale, 1e-6), ops.rmsNorm(kh, kScale, 1e-6), materializeCopy(vh)];
  } finally { q.dispose(); k.dispose(); v.dispose(); }
}

function equal(actual: MlxArray[], expected: MlxArray[]): void {
  try {
    for (let i = 0; i < actual.length; ++i) {
      expect(actual[i]!.shape).toEqual(expected[i]!.shape);
      expect(actual[i]!.dtype).toBe(expected[i]!.dtype);
      expect(Buffer.from(actual[i]!.rawBytes()).equals(Buffer.from(expected[i]!.rawBytes()))).toBe(true);
    }
  } finally { for (const a of [...actual, ...expected]) a.dispose(); }
}

test("fused heads retain SiLU, RMS, and scale rounding without an activated convolution tensor", () => {
  for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
    for (const [hk, hv, dk, dv] of [[4, 16, 64, 64], [16, 48, 128, 128], [2, 6, 63, 128]]) {
      for (const [b, s] of [[1, 1], [2, 4]]) {
        using qScale = tensor([dk!], dtype, 0.4);
        using kScale = tensor([dk!], dtype, 1.7);
        for (const magnitude of [0, 0.01, 1, 100]) {
          using x = tensor([b!, s!, 2 * hk! * dk! + hv! * dv!], dtype, 0.3, magnitude);
          equal(siluRmsHeads(x, qScale, kScale, hk!, hv!, dv!), reference(x, qScale, kScale, hk!, hv!, dv!));
        }
      }
    }
  }
});

test("compiled heads retrace changing grids and read the current scale vectors", () => {
  const operation = new CompiledSiluRMSHeads(4, 16, 64);
  for (const dtype of [Dtype.bfloat16, Dtype.float32]) {
    for (const width of [64, 128, 64]) {
      for (const rows of [1, 4, 1]) {
        using qScale = tensor([width], dtype, rows / 3);
        using kScale = tensor([width], dtype, rows / 7);
        using x = tensor([2, rows, 8 * width + 16 * 64], dtype, rows / 11, 3);
        equal(operation.forward(x, qScale, kScale), reference(x, qScale, kScale, 4, 16, 64));
      }
    }
  }
});

test("fused heads handle strided convolution outputs", () => {
  using full = tensor([2, 3, 2 * 10240], Dtype.bfloat16, 0.3);
  const [x, other] = ops.split(full, [10240], -1) as [MlxArray, MlxArray];
  other.dispose();
  try {
    using qScale = ops.filledBf16(1 / 128, 128);
    using kScale = ops.filledBf16(128 ** -0.5, 128);
    equal(siluRmsHeads(x, qScale, kScale, 16, 48, 128), reference(x, qScale, kScale, 16, 48, 128));
  } finally { x.dispose(); }
});
