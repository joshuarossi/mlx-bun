// gather_qmm binding correctness (fast tier, no model weights): the
// gathered quantized matmul must equal a per-expert quantized_matmul
// loop on the same packed weights. Exercises the 13-arg FFI signature
// (an arg shift would corrupt shapes/values immediately — Phase 1 rule:
// read full signatures from headers; this pins the binding).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";

const E = 4; // experts
const OUT = 16;
const IN = 64;
const GROUP = 32;

function randomFloats(n: number, seed: number): Float32Array {
  // deterministic LCG — no RNG dependency in tests
  const out = new Float32Array(n);
  let s = seed >>> 0;
  for (let i = 0; i < n; i++) {
    s = (s * 1664525 + 1013904223) >>> 0;
    out[i] = (s / 2 ** 32) * 2 - 1;
  }
  return out;
}

describe("gather_qmm", () => {
  for (const bits of [4, 8]) {
    test(`matches per-expert quantized_matmul (bits=${bits})`, () => {
      const spec: ops.QuantSpec = { bits, groupSize: GROUP, mode: "affine" };
      const wFull = MlxArray.fromFloat32(randomFloats(E * OUT * IN, 7), [E, OUT, IN]);
      const q = ops.quantize(wFull, GROUP, bits);

      // 2 tokens × top-2 experts each, unsorted path (size < 64)
      const x = MlxArray.fromFloat32(randomFloats(2 * IN, 11), [1, 2, IN]);
      const indices = ops
        .fromInt32([2, 0, 1, 3], [1, 2, 2])
        .astype(3 /* uint32 */);

      // x [1,2,IN] → [1,2,1,1,IN] like SwitchGLU does
      let h = ops.expandDims(x, -2);
      h = ops.expandDims(h, -3);
      const gathered = ops.gatherQmm(h, q.packed, q.scales, q.biases, indices, spec, false);
      expect(gathered.shape).toEqual([1, 2, 2, 1, OUT]);
      const got = gathered.toFloat32();

      // reference: slice each expert's packed weights, plain quantized_matmul
      const expected = new Float32Array(2 * 2 * OUT);
      const idxFlat = [2, 0, 1, 3];
      for (let t = 0; t < 2; t++) {
        const row = x.slice([0, t, 0], [1, t + 1, IN]); // [1,1,IN]
        for (let j = 0; j < 2; j++) {
          const e = idxFlat[t * 2 + j]!;
          const we = q.packed.slice([e, 0, 0], [e + 1, OUT, q.packed.shape[2]!]);
          const se = q.scales.slice([e, 0, 0], [e + 1, OUT, q.scales.shape[2]!]);
          const be = q.biases.slice([e, 0, 0], [e + 1, OUT, q.biases.shape[2]!]);
          const w2 = ops.reshape(we, [OUT, q.packed.shape[2]!]);
          const s2 = ops.reshape(se, [OUT, q.scales.shape[2]!]);
          const b2 = ops.reshape(be, [OUT, q.biases.shape[2]!]);
          const y = ops.quantizedMatmul(row, w2, s2, b2, spec, true);
          expected.set(y.toFloat32(), (t * 2 + j) * OUT);
          for (const a of [we, se, be, w2, s2, b2, y]) a.dispose();
        }
        row.dispose();
      }

      let maxDiff = 0;
      for (let i = 0; i < expected.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(got[i]! - expected[i]!));
      // gather_qmm and quantized_matmul are different kernels with
      // different f32 accumulation order — bounded tolerance here.
      // Cross-stack parity stays bit-exact (the oracle uses gather_qmm
      // too): see tests/parity-26b.test.ts.
      expect(maxDiff).toBeLessThan(1e-5);

      for (const a of [wFull, q.packed, q.scales, q.biases, x, indices, h, gathered])
        a.dispose();
    });
  }
});
