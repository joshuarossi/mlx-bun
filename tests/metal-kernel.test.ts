// mx.fast.metal_kernel toolchain derisk (docs/design/optimization_plan.md Phase E
// step 3): a trivial kernel proves the .metal → mlx-c → bun:ffi pipeline
// end-to-end, so the real fused-SDPA kernel debugs numerics OR plumbing,
// never both at once.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { MetalKernel } from "../src/mlx/metal-kernel";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";

describe("MetalKernel", () => {
  test("scale-by-two kernel runs from Bun and matches ops.mulScalar", () => {
    const kernel = new MetalKernel({
      name: "scale2",
      inputNames: ["inp"],
      outputNames: ["out"],
      source: `
        uint elem = thread_position_in_grid.x;
        out[elem] = inp[elem] * 2.0f;
      `,
    });
    const x = MlxArray.fromFloat32(new Float32Array([1, 2, 3, 4, 5, 6, 7, 8]), [8]);
    const [y] = kernel.apply([x], {
      outputs: [{ shape: [8], dtype: Dtype.float32 }],
      grid: [8, 1, 1],
      threadGroup: [8, 1, 1],
    });
    const expected = ops.mulScalar(x, 2);
    expect([...y!.toFloat32()]).toEqual([...expected.toFloat32()]);
    for (const a of [x, y!, expected]) a.dispose();
    kernel.dispose();
  });

  test("templated dtype kernel on bf16", () => {
    const kernel = new MetalKernel({
      name: "addone",
      inputNames: ["inp"],
      outputNames: ["out"],
      source: `
        uint elem = thread_position_in_grid.x;
        out[elem] = inp[elem] + T(1.0);
      `,
    });
    const f = MlxArray.fromFloat32(new Float32Array([0.5, -1.25, 3]), [3]);
    const x = f.astype(Dtype.bfloat16);
    f.dispose();
    const [y] = kernel.apply([x], {
      outputs: [{ shape: [3], dtype: Dtype.bfloat16 }],
      grid: [3, 1, 1],
      threadGroup: [3, 1, 1],
      templateDtypes: { T: Dtype.bfloat16 },
    });
    expect([...y!.toFloat32()]).toEqual([1.5, -0.25, 4]);
    for (const a of [x, y!]) a.dispose();
    kernel.dispose();
  });
});
