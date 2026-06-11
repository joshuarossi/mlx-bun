// Fused decode-SDPA kernel numerics (Phase E step 4): the kernel is NOT
// bit-exact with the unfused path by construction (online softmax, f32
// accumulation), so this gate is bounded-divergence vs
// quantizedSdpaUnfused on the exact dispatch-site shapes Phase D
// recorded for the 12B: (4-bit gs64 nRep=2 d256), (8-bit gs64 nRep=2
// d256), (4-bit gs64 nRep=16 d512). End-to-end quality is gated against
// the frozen perf oracle separately.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { quantizedSdpaUnfused } from "../src/model/gemma4-base";
import { fusedDecodeKernelSupported, fusedDecodeSdpa } from "../src/model/fused-decode-kernel";

function randBf16(shape: number[], seed: number): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const data = new Float32Array(n);
  let s = seed >>> 0;
  for (let i = 0; i < n; i++) {
    s = (s * 1664525 + 1013904223) >>> 0;
    data[i] = ((s / 0xffffffff) * 2 - 1) * 0.5;
  }
  const f = MlxArray.fromFloat32(data, shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
}

const SITES: [string, number, number, number, number, number][] = [
  // name, H, KV, D, gs, bits — the 12B's three dispatch-site configs
  ["sliding 4-bit", 4, 2, 256, 64, 4],
  ["sliding 8-bit", 4, 2, 256, 64, 8],
  ["full-attn 4-bit GQA16", 16, 1, 512, 64, 4],
];

describe("fused decode kernel vs unfused reference", () => {
  for (const [name, H, KV, D, gs, bits] of SITES) {
    test(`${name}: bounded divergence + identical argmax weights (N=333)`, () => {
      const N = 333; // odd: exercises the simdgroup stripe tail
      const q = randBf16([1, H, 1, D], 11);
      const k = randBf16([1, KV, N, D], 22);
      const v = randBf16([1, KV, N, D], 33);
      const kq = ops.quantize(k, gs, bits);
      const vq = ops.quantize(v, gs, bits);

      expect(fusedDecodeKernelSupported(q, bits, gs)).toBe(true);
      const fused = fusedDecodeSdpa(q, kq, vq, gs, bits);
      const ref = quantizedSdpaUnfused(q, kq, vq, 1.0, { mode: "", arr: null }, gs, bits);

      const a = fused.toFloat32();
      const b = ref.toFloat32();
      let maxDiff = 0;
      let meanAbs = 0;
      for (let i = 0; i < b.length; i++) {
        maxDiff = Math.max(maxDiff, Math.abs(a[i]! - b[i]!));
        meanAbs += Math.abs(b[i]!);
      }
      meanAbs /= b.length;
      // bounded: well under one bf16 ulp-of-activation territory
      expect(maxDiff).toBeLessThan(0.02);
      expect(meanAbs).toBeGreaterThan(0.001); // sanity: outputs aren't ~zero

      for (const x of [q, k, v, fused, ref]) x.dispose();
      for (const t of [kq, vq]) for (const c of [t.packed, t.scales, t.biases]) c.dispose();
    });
  }
});
