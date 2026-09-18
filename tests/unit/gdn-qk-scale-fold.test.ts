// DeltaNet q/k scale folded into the norm before it (GatedDeltaNet.qkScale), model-free.
// MLX's rms_norm kernel writes `w * T(x * inv)`; a weightless call passes w = 1. A weight
// filled with the bf16 scalar must therefore reproduce rms_norm(x, null) * scalar exactly.

import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

function bytes(a: MlxArray): Buffer { ops.evalAll([a]); return Buffer.from(new Uint8Array(a.rawBytesView())); }

test("rms_norm weighted by a filled bf16 scale equals weightless rms_norm then mulScalar, bit for bit", () => {
  for (const dim of [128, 64, 96]) {
    const invScale = Math.pow(dim, -0.5);
    for (const value of [invScale * invScale, invScale]) {
      using weight = ops.filledBf16(value, dim);
      for (const [shape, sigma, seed] of [[[1, 3, 16, dim], 0.5, 1], [[2, 1, 16, dim], 30, 2], [[1, 4, 16, dim], 1e-3, 3]] as const) {
        using key = ops.randomKey(BigInt(seed * 1000 + dim));
        using x = ops.randomNormal([...shape], Dtype.bfloat16, 0, sigma, key);
        using normed = ops.rmsNorm(x, null, 1e-6);
        using reference = ops.mulScalar(normed, value);
        using folded = ops.rmsNorm(x, weight, 1e-6);
        expect(folded.dtype).toBe(Dtype.bfloat16);
        expect(bytes(folded).equals(bytes(reference))).toBe(true);
      }
    }
  }
});
