// ANE prefill channel splits (layers/ane-prefill-split) on small synthetic
// layers against the GPU-only result: the ANE computes its channels in fp16
// from weights the GPU writes into its buffers, so the outputs agree to fp16
// precision. Each layer owns one program built for exactly its chunk size.
// Requires the ANE bridge (dist/native/libmlx_bun_ane.dylib) and an Apple
// Neural Engine; skipped otherwise, which is not evidence of a pass.
import { expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { QuantizedLinear } from "../../src/layers/quantized-linear";
import { TrellisLinear } from "../../src/layers/trellis-linear";
import { AneAffineSplit, AneTrellisMlpSplit, AneTrellisMlpSplitK3i, aneAvailable } from "../../src/layers/ane-prefill-split";
import { compiledSwiglu } from "../../src/layers/swiglu";

const D = 512, R = 1024, M = 96;

function relErr(actual: MlxArray, expected: MlxArray): number {
  expect(actual.shape).toEqual(expected.shape);
  const a = actual.astype(Dtype.float32).toFloat32(), b = expected.astype(Dtype.float32).toFloat32();
  let err = 0, mag = 0;
  for (let i = 0; i < b.length; i++) { err = Math.max(err, Math.abs(a[i]! - b[i]!)); mag = Math.max(mag, Math.abs(b[i]!)); }
  return err / mag;
}
function hidden(rows = M, d = D): MlxArray {
  using raw = MlxArray.fromFloat32(Float32Array.from({ length: rows * d }, (_, i) => ((i * 73 + 19) % 257 - 128) / 128), [1, rows, d]);
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
/** Synthetic Trellis MLP [d, r] and its GPU-only output on `x`. */
function mlp(d: number, r: number, interleave: boolean, seed: number, x: MlxArray) {
  const gate = trellis(r, d, 1, 3, seed), up = trellis(r, d, 1, 3, seed + 12), down = trellis(r, d, 0, interleave ? 3 : 2, seed + 26, interleave);
  using g = gate.forward(x, true), u = up.forward(x, true);
  using mid = compiledSwiglu(g, u);
  return { gate, up, down, expected: down.forward(mid, true) };
}

test.skipIf(!aneAvailable())("affine projection split matches the GPU projection", () => {
  const lin = affine(256, D, 1);
  using x = hidden();
  using expected = lin.forward(x);
  using split = AneAffineSplit.build(lin, 0.5, M);
  using actual = split.forward(x)!;
  expect(relErr(actual, expected)).toBeLessThan(2e-2);
}, 120_000);

for (const interleave of [false, true])
  test.skipIf(!aneAvailable())(`Trellis whole-MLP split matches the GPU MLP (${interleave ? "3-bit interleaved" : "row-major"} down)`, () => {
    using x = hidden();
    const { gate, up, down, expected } = mlp(D, R, interleave, 11, x);
    using split = (interleave ? AneTrellisMlpSplitK3i : AneTrellisMlpSplit).build(gate, up, down, 0.5, M);
    using actual = split.forward(x, compiledSwiglu);
    expect(relErr(actual, expected)).toBeLessThan(2e-2);
    expected.dispose();
  }, 120_000);

test.skipIf(!aneAvailable())("two split layers of different shapes each own their program; disposing one leaves the other", () => {
  using xa = hidden(M, D), xb = hidden(2 * M, 2 * D);
  const a = mlp(D, R, false, 11, xa), b = mlp(2 * D, 2 * R, true, 41, xb);
  const splitA = AneTrellisMlpSplit.build(a.gate, a.up, a.down, 0.5, M);
  using splitB = AneTrellisMlpSplitK3i.build(b.gate, b.up, b.down, 0.5, 2 * M);
  using outA = splitA.forward(xa, compiledSwiglu);
  using outB = splitB.forward(xb, compiledSwiglu);
  splitA.dispose();
  using againB = splitB.forward(xb, compiledSwiglu);
  expect(relErr(outA, a.expected)).toBeLessThan(2e-2);
  expect(relErr(outB, b.expected)).toBeLessThan(2e-2);
  expect(relErr(againB, b.expected)).toBeLessThan(2e-2);
  a.expected.dispose(); b.expected.dispose();
}, 120_000);

test.skipIf(!aneAvailable())("a split built on another's buffers keeps them after that split is disposed", () => {
  using x = hidden();
  const a = mlp(D, R, false, 11, x), b = mlp(D, R, true, 53, x);
  const lender = AneTrellisMlpSplit.build(a.gate, a.up, a.down, 0.5, M);
  using borrower = AneTrellisMlpSplitK3i.build(b.gate, b.up, b.down, 0.5, M, lender);
  using outA = lender.forward(x, compiledSwiglu);
  using outB = borrower.forward(x, compiledSwiglu);
  lender.dispose();
  using againB = borrower.forward(x, compiledSwiglu);
  expect(relErr(outA, a.expected)).toBeLessThan(2e-2);
  expect(relErr(outB, b.expected)).toBeLessThan(2e-2);
  expect(relErr(againB, b.expected)).toBeLessThan(2e-2);
  a.expected.dispose(); b.expected.dispose();
}, 120_000);
