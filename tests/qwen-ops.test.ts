// FAST (no model load): the new primitives the Qwen3.5 port depends on —
// depthwise causal conv1d (the FFI binding + [C,K,1] weight layout) and
// softplus — checked bit-exact against mlx.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";

const conv = await Bun.file(`${import.meta.dir}/fixtures/qwen-conv1d-golden.json`).json();

const bf16 = (vals: number[], shape: number[]): MlxArray => {
  const f = MlxArray.fromFloat32(Float32Array.from(vals), shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
};
const maxAbsDiff = (a: MlxArray, expected: number[]): number => {
  const got = a.toFloat32();
  let m = 0;
  for (let i = 0; i < got.length; i++) m = Math.max(m, Math.abs(got[i]! - expected[i]!));
  return m;
};

describe("Qwen3.5 primitives (model-free)", () => {
  test("depthwise causal conv1d + silu bit-exact vs mlx nn.Conv1d", () => {
    const { B, S, K, C } = conv;
    const x = bf16(conv.x, [B, S + K - 1, C]);
    const w = bf16(conv.w, conv.w_shape);
    const c = ops.conv1d(x, w, 1, 0, 1, C); // groups == channels (depthwise)
    const out = ops.silu(c);
    expect(out.shape).toEqual([B, S, C]);
    expect(maxAbsDiff(out, conv.out)).toBe(0);
    for (const t of [x, w, c, out]) t.dispose();
  });

  test("softplus == log(1+exp(x))", () => {
    // f32 reference values computed in JS (softplus is a logaddexp(x,0)).
    const xs = [-4, -1, 0, 0.5, 3, 10];
    const x = MlxArray.fromFloat32(Float32Array.from(xs), [xs.length]);
    const sp = ops.softplus(x);
    const got = sp.toFloat32();
    for (let i = 0; i < xs.length; i++)
      expect(got[i]!).toBeCloseTo(Math.log1p(Math.exp(xs[i]!)), 4);
    x.dispose();
    sp.dispose();
  });
});
