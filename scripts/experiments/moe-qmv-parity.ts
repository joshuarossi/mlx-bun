// gather-qmv Metal kernel numerics: NOT bit-exact with mx.gather_qmm by
// construction (lane-strided f32 accumulation vs the GEMM tile order), so the
// gate is bounded divergence vs ops.gatherQmm on the exact 26B MoE dispatch
// shapes (hidden 2816, moe_intermediate 704, 128 experts, top-8, 4-bit gs64;
// plus an 8-bit arm). Speed is gated separately
// (scripts/experiments/moe-expert-read-profile.ts arm F).

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { moeQmvDecode, moeQmvSupported } from "./moe-qmv-kernel";

const NE = 128, TOPK = 8;

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

const CASES: [string, number, number, number, boolean][] = [
  // name, OUT, IN, bits, sharedX — the three 26B dispatch patterns + 8-bit
  ["gate/up 4-bit (shared x)", 704, 2816, 4, true],
  ["down 4-bit (per-expert x)", 2816, 704, 4, false],
  ["gate/up 8-bit (shared x)", 704, 2816, 8, true],
];

for (const [name, OUT, IN, bits, shared] of CASES) {
    console.log(`--- ${name}`);
      const gs = 64;
      const spec: ops.QuantSpec = { bits, groupSize: gs, mode: "affine" };
      const w = randBf16([NE, OUT, IN], 7);
      const q = ops.quantize(w, gs, bits);
      w.dispose();
      const idxHost = [3, 17, 42, 42, 99, 0, 127, 64]; // dup + edges
      const idxI = ops.fromInt32(idxHost, [TOPK]);
      const idx = idxI.astype(Dtype.uint32);
      idxI.dispose();

      const xRows = shared ? 1 : TOPK;
      const x = randBf16([xRows, IN], 21);

      if (!moeQmvSupported(xRows, TOPK, OUT, IN, bits, gs, x.dtype)) throw new Error("unsupported");
      const got = moeQmvDecode(x, q.packed, q.scales, q.biases!, idx, TOPK, OUT, IN, bits, gs);

      // reference: ops.gatherQmm with the gather_qmm row layout
      // x [1,1,xRows(->K),1,IN], indices [1,1,K] -> out [1,1,K,1,OUT]
      const xRef = shared
        ? ops.reshape(x, [1, 1, 1, 1, IN])
        : ops.reshape(x, [1, 1, TOPK, 1, IN]);
      const idxRef = ops.reshape(idx, [1, 1, TOPK]);
      const ref = ops.gatherQmm(xRef, q.packed, q.scales, q.biases, idxRef, spec, false);
      const refFlat = ops.reshape(ref, [TOPK, OUT]);
      ops.evalAll([got, refFlat]);

      const a = got.toFloat32();
      const b = refFlat.toFloat32();
      let maxDiff = 0, meanAbs = 0;
      for (let i = 0; i < b.length; i++) {
        maxDiff = Math.max(maxDiff, Math.abs(a[i]! - b[i]!));
        meanAbs += Math.abs(b[i]!);
      }
      meanAbs /= b.length;
      if (!(meanAbs > 0.01)) throw new Error("outputs ~zero");
      if (!(maxDiff < 0.5)) throw new Error(`divergence ${maxDiff}`);
      console.log(`maxDiff=${maxDiff.toFixed(4)} meanAbs=${meanAbs.toFixed(4)} OK`);

      for (const t of [x, got, xRef, idxRef, ref, refFlat, idx]) t.dispose();
      for (const c of [q.packed, q.scales, q.biases!]) c.dispose();
}
