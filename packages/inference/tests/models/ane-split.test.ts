// ANE prefill channel splits (layers/ane-prefill-split) on small synthetic
// layers against the GPU-only result: the ANE computes its channels in fp16
// from weights the GPU writes into its buffers, so the outputs agree to fp16
// precision. Opt-in: set MLX_BUN_TEST_ANE=1 on a real Apple Silicon machine (every
// M-series chip has a Neural Engine; a virtual machine such as a hosted CI runner
// loads the framework but cannot compile). Unset skips, which is not evidence of a pass.
import { expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { QuantizedLinear } from "../../src/layers/quantized-linear";
import { TrellisLinear } from "../../src/layers/trellis-linear";
import { AneAffineSplit, AneTrellisMlpSplit, AneTrellisMlpSplitK3i } from "../../src/layers/ane-prefill-split";
import { compiledSwiglu } from "../../src/layers/swiglu";

const D = 512, R = 1024, M = 96, SEQ = 512;

function relErr(actual: MlxArray, expected: MlxArray): number {
  expect(actual.shape).toEqual(expected.shape);
  const a = actual.astype(Dtype.float32).toFloat32(), b = expected.astype(Dtype.float32).toFloat32();
  let err = 0, mag = 0;
  for (let i = 0; i < b.length; i++) { err = Math.max(err, Math.abs(a[i]! - b[i]!)); mag = Math.max(mag, Math.abs(b[i]!)); }
  return err / mag;
}
function hidden(): MlxArray {
  using raw = MlxArray.fromFloat32(Float32Array.from({ length: M * D }, (_, i) => ((i * 73 + 19) % 257 - 128) / 128), [1, M, D]);
  return raw.astype(Dtype.bfloat16);
}
function affine(out: number, inp: number, seed: number): QuantizedLinear {
  using w32 = MlxArray.fromFloat32(Float32Array.from({ length: out * inp }, (_, i) => Math.sin(i * 0.137 + seed) * 0.05), [out, inp]);
  using wb = w32.astype(Dtype.bfloat16);
  const q = ops.quantize(wb, 64, 4);
  return new QuantizedLinear(q.packed, q.scales, q.biases, { bits: 4, groupSize: 64, mode: "affine" });
}
function trellis(rows: number, cols: number, axis: 0 | 1, k: number, seedBase: number, interleave = false): TrellisLinear {
  let seed = seedBase;
  const words = cols * k / 32;
  const shape = interleave ? [cols / 512, rows, 48] : [rows, words];
  using ints = MlxArray.fromInt32(Int32Array.from({ length: rows * words }, () => seed = Math.imul(seed, 1664525) + 1013904223), shape);
  using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => (i % 17 + 1) / 400), [rows]);
  return new TrellisLinear(ints.astype(Dtype.uint32), scale32.astype(Dtype.float16),
    { bits: k, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis } });
}

test.skipIf(!process.env.MLX_BUN_TEST_ANE)("affine projection split matches the GPU projection", () => {
  const lin = affine(256, D, 1);
  using x = hidden();
  using expected = lin.forward(x);
  const split = AneAffineSplit.build(lin, 0.5, SEQ);
  using actual = split.forward(x)!;
  expect(relErr(actual, expected)).toBeLessThan(2e-2);
}, 120_000);

for (const interleave of [false, true])
  test.skipIf(!process.env.MLX_BUN_TEST_ANE)(`Trellis whole-MLP split matches the GPU MLP (${interleave ? "3-bit interleaved" : "row-major"} down)`, () => {
    const gate = trellis(R, D, 1, 3, 11), up = trellis(R, D, 1, 3, 23), down = trellis(R, D, 0, interleave ? 3 : 2, 37, interleave);
    using x = hidden();
    using g = gate.forward(x, true), u = up.forward(x, true);
    using mid = compiledSwiglu(g, u);
    using expected = down.forward(mid, true);
    const split = (interleave ? AneTrellisMlpSplitK3i : AneTrellisMlpSplit).build(gate, up, down, 0.5, SEQ);
    using actual = split.forward(x, compiledSwiglu);
    expect(relErr(actual, expected)).toBeLessThan(2e-2);
  }, 120_000);
