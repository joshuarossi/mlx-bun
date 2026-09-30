// The vision 2D RoPE rotates each axis partition of the head by that axis's grid
// coordinate. Expected values are computed here with host doubles from the
// formula, not with the layer's own ops.
import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { applyRope2d, rope2dTables } from "../../src/layers/rope-2d";

/** Deterministic values spread over [-4, 4]. */
const ramp = (n: number, phase: number) => Float32Array.from({ length: n }, (_, i) => 4 * Math.sin(i * 0.37 + phase));

test("2D RoPE rotates each axis partition by its own coordinate, including a padding coordinate", () => {
  const L = 5, H = 2, D = 8, theta = 100, cpd = D / 2, half = cpd / 2;
  const grid = Int32Array.from([0, 0, 1, 0, 2, 3, 7, 1, -1, -1]); // x, y per position
  const x = ramp(L * H * D, 0.5);
  const expected = Float32Array.from(x);
  for (let l = 0; l < L; l++) for (let h = 0; h < H; h++) for (let axis = 0; axis < 2; axis++)
    for (let j = 0; j < half; j++) {
      const angle = grid[l * 2 + axis]! / Math.pow(theta, (2 * j) / cpd);
      const at = (c: number) => ((l * H + h) * D) + axis * cpd + c;
      const a = x[at(j)]!, b = x[at(j + half)]!;
      expected[at(j)] = a * Math.cos(angle) - b * Math.sin(angle);
      expected[at(j + half)] = b * Math.cos(angle) + a * Math.sin(angle);
    }
  const positions = MlxArray.fromInt32(grid, [1, L, 2]);
  const input = MlxArray.fromFloat32(x, [1, L, H, D]);
  const tables = rope2dTables(positions, D, theta, Dtype.float32);
  const out = applyRope2d(input, tables);
  try {
    expect(out.shape).toEqual([1, L, H, D]);
    const actual = out.toFloat32();
    for (let i = 0; i < expected.length; i++) expect(Math.abs(actual[i]! - expected[i]!)).toBeLessThan(2e-5);
  } finally { for (const a of [positions, input, out]) a.dispose(); tables.dispose(); }
});

test("2D RoPE refuses a head dimension its two partitions cannot split evenly", () => {
  const positions = MlxArray.fromInt32(Int32Array.from([0, 0]), [1, 1, 2]);
  try { expect(() => rope2dTables(positions, 6, 100, Dtype.float32)).toThrow("divisible"); }
  finally { positions.dispose(); }
});
