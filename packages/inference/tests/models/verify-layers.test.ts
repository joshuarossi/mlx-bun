// Verify-width layers (layers/trellis-gate-up, layers/trellis-down,
// layers/affine-verify-linear) on small synthetic projections against the
// projections they replace: TrellisLinear (+ compiled SwiGLU) and
// QuantizedLinear. Each layer runs one kernel that reassociates the reduction,
// so they agree to bf16 precision. Each layer also refuses weights it was not
// built for.
import { describe, expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { QuantizedLinear } from "../../src/layers/quantized-linear";
import { TrellisLinear } from "../../src/layers/trellis-linear";
import { compiledSwiglu } from "../../src/layers/swiglu";
import { FactoredGateUpRow, FactoredGateUpRows, FactoredMixedGateUp, MmaGateUp } from "../../src/layers/trellis-gate-up";
import { FactoredDownK3iRow, FactoredDownK3iRows, FactoredDownRow, FactoredDownRows, MmaDown, MmaDownK3i } from "../../src/layers/trellis-down";
import { Affine3MmaLinear, Affine3RowsLinear, Affine4MmaLinear, Affine4RowsLinear } from "../../src/layers/affine-verify-linear";

const D = 512, R = 256;

function relErr(actual: MlxArray, expected: MlxArray): number {
  expect(actual.shape).toEqual(expected.shape);
  const a = actual.astype(Dtype.float32).toFloat32(), b = expected.astype(Dtype.float32).toFloat32();
  let err = 0, mag = 0;
  for (let i = 0; i < b.length; i++) { err = Math.max(err, Math.abs(a[i]! - b[i]!)); mag = Math.max(mag, Math.abs(b[i]!)); }
  return err / mag;
}
function rows(m: number, width: number): MlxArray {
  using raw = MlxArray.fromFloat32(Float32Array.from({ length: m * width }, (_, i) => ((i * 73 + 19) % 257 - 128) / 128), [1, m, width]);
  return raw.astype(Dtype.bfloat16);
}
function trellis(stored: number, cols: number, axis: 0 | 1, k: number, seedBase: number, interleave = false): TrellisLinear {
  let seed = seedBase;
  const words = cols * k / 32;
  const shape = interleave ? [cols / 512, stored, 48] : [stored, words];
  using ints = MlxArray.fromInt32(Int32Array.from({ length: stored * words }, () => seed = Math.imul(seed, 1664525) + 1013904223), shape);
  using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: stored }, (_, i) => (i % 17 + 1) / 400), [stored]);
  return new TrellisLinear(ints.astype(Dtype.uint32), scale32.astype(Dtype.float16),
    { bits: k, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis } });
}

describe("Trellis verify layers", () => {
  test("gate/up layers match the projections plus SwiGLU", () => {
    for (const [kg, ku] of [[3, 3], [2, 3]] as const) {
      const gate = trellis(R, D, 1, kg, 11), up = trellis(R, D, 1, ku, 23);
      for (const m of [1, 2, 4, 5, 8]) {
        using x = rows(m, D);
        using g = gate.forward(x, true), u = up.forward(x, true);
        using expected = compiledSwiglu(g, u);
        const layer = m > 4 ? new MmaGateUp(gate, up) : kg !== ku ? new FactoredMixedGateUp(gate, up)
          : m === 1 ? new FactoredGateUpRow(gate, up) : new FactoredGateUpRows(gate, up);
        using actual = layer.forward(x);
        expect(relErr(actual, expected), `k${kg}/${ku} m${m}`).toBeLessThan(2e-2);
      }
    }
  }, 60_000);

  test("down layers match the projection for both code layouts", () => {
    for (const interleave of [false, true]) {
      const down = trellis(R, D, 0, interleave ? 3 : 2, 37, interleave);
      for (const m of [1, 3, 4, 8]) {
        using x = rows(m, R);
        using expected = down.forward(x, true);
        const layer = interleave
          ? m === 1 ? new FactoredDownK3iRow(down) : m < 4 ? new FactoredDownK3iRows(down) : new MmaDownK3i(down)
          : m === 1 ? new FactoredDownRow(down) : m < 4 ? new FactoredDownRows(down) : new MmaDown(down);
        using actual = layer.forward(x);
        expect(relErr(actual, expected), `${interleave ? "k3i" : "row-major"} m${m}`).toBeLessThan(2e-2);
      }
    }
  }, 60_000);

  test("layers refuse weights they were not built for", () => {
    const rowMajor = trellis(R, D, 0, 3, 41), interleaved = trellis(R, D, 0, 3, 43, true);
    const gate = trellis(R, D, 1, 3, 47), up = trellis(R, D, 1, 2, 53);
    expect(() => new FactoredDownRow(interleaved)).toThrow();
    expect(() => new FactoredDownK3iRows(rowMajor)).toThrow();
    expect(() => new FactoredGateUpRows(gate, up)).toThrow();
    expect(() => new FactoredMixedGateUp(gate, gate)).toThrow();
  });
});

describe("affine verify layers", () => {
  test("3- and 4-bit layers match QuantizedLinear", () => {
    using w32 = MlxArray.fromFloat32(Float32Array.from({ length: R * D }, (_, i) => Math.sin(i * 0.137) * 0.05), [R, D]);
    using wb = w32.astype(Dtype.bfloat16);
    for (const bits of [3, 4] as const) {
      const q = ops.quantize(wb, 64, bits);
      const lin = new QuantizedLinear(q.packed, q.scales, q.biases, { bits, groupSize: 64, mode: "affine" });
      const rowsLayer = bits === 3 ? new Affine3RowsLinear(lin) : new Affine4RowsLinear(lin);
      const mmaLayer = bits === 3 ? new Affine3MmaLinear(lin) : new Affine4MmaLinear(lin);
      for (const m of [2, 4, 5, 8]) {
        using x = rows(m, D);
        using expected = lin.forward(x);
        using a = rowsLayer.forward(x);
        using b = mmaLayer.forward(x);
        expect(relErr(a, expected), `rows ${bits}-bit m${m}`).toBeLessThan(1e-2);
        expect(relErr(b, expected), `mma ${bits}-bit m${m}`).toBeLessThan(1e-2);
      }
      expect(() => bits === 3 ? new Affine4RowsLinear(lin) : new Affine3RowsLinear(lin)).toThrow();
    }
  }, 60_000);
});
