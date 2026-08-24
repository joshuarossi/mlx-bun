// FAST (no model load): the conv2d FFI binding for the gemma-4 audio SSCP
// subsampler, checked bit-exact against Python mlx conv2d (oracle venv,
// 2026-07-07) on deterministic ramp inputs. The groups case also pins the
// natural stack-argument ABI used by Bun 1.4 and newer.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";

const ramp = (n: number, mod: number, off: number): Float32Array => {
  const a = new Float32Array(n);
  for (let i = 0; i < n; i++) a[i] = (i % mod) + off;
  return a;
};

describe("conv2d (model-free)", () => {
  test("stride+padding bit-exact vs mlx conv2d", () => {
    const x = MlxArray.fromFloat32(ramp(60, 7, -3), [1, 4, 5, 3]);
    const w = MlxArray.fromFloat32(ramp(54, 5, -2), [2, 3, 3, 3]);
    const y = ops.conv2d(x, w, [2, 2], [1, 1]);
    expect(y.shape).toEqual([1, 2, 3, 2]);
    // Oracle: mx.conv2d(x, w, stride=(2,2), padding=(1,1)) — exact values.
    expect([...y.toFloat32()]).toEqual([
      -8, 2, -12, 11, -13, 3, 9, -9, -7, 4, 7, -8,
    ]);
    x.dispose(); w.dispose(); y.dispose();
  });

  test("groups path bit-exact vs mlx conv2d (natural stack args)", () => {
    const x = MlxArray.fromFloat32(ramp(60, 7, -3), [1, 4, 5, 3]);
    const w = MlxArray.fromFloat32(ramp(12, 3, -1), [3, 2, 2, 1]);
    const y = ops.conv2d(x, w, [1, 1], [0, 0], [1, 1], 3);
    expect(y.shape).toEqual([1, 3, 4, 3]);
    // Oracle: mx.conv2d(x, w, stride=(1,1), padding=(0,0), groups=3).
    expect([...y.toFloat32()]).toEqual([
      0, 2, 0, 4, -5, 3, -6, 2, -1, -2, 2, 2, -1, 2, -6, 3, -5, 4,
      0, 2, 0, 4, -5, 3, -2, 2, 2, 2, 2, -2, -1, 2, -6, 3, -5, 4,
    ]);
    x.dispose(); w.dispose(); y.dispose();
  });
});

describe("conv3d (model-free)", () => {
  test("bit-exact vs mlx conv3d (natural stack args)", () => {
    const x = MlxArray.fromFloat32(ramp(16, 7, -3), [1, 2, 2, 2, 2]);
    const w = MlxArray.fromFloat32(ramp(32, 5, -2), [2, 2, 2, 2, 2]);
    const y = ops.conv3d(x, w);
    expect(y.shape).toEqual([1, 1, 1, 1, 2]);
    expect([...y.toFloat32()]).toEqual([-1, 9]);
    x.dispose(); w.dispose(); y.dispose();
  });
});
