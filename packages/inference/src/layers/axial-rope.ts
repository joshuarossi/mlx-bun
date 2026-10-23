// Rotate-half rotary embedding over several coordinate axes. Each position
// carries one coordinate per axis; the head's first half pairs with its second,
// and the rotation angle of pair `a * K + k` is `coordinate[a] * bands[k]`
// (axis-major). Tables are computed on the host in float32 at the reference's
// rounding points (`coordinate * band` in float32, then sin/cos) and cast once
// to the activation dtype, as MOSS-Image's `_RoPE` builds them.

import { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

const f32 = Math.fround;

/** cos/sin `[1, N, 1, 2 * axes * bands]`, broadcast over heads. Owned. */
export interface AxialRopeTables extends Disposable {
  readonly cos: MlxArray;
  readonly sin: MlxArray;
  readonly positions: number;
  dispose(): void;
}

function ownedTables(cos: MlxArray, sin: MlxArray, positions: number): AxialRopeTables {
  const dispose = () => { cos.dispose(); sin.dispose(); };
  return { cos, sin, positions, dispose, [Symbol.dispose]: dispose };
}

/** Tables for `coordinates` (N rows of `axes` values, row-major) and the
 * per-pair frequencies `bands`, in `dtype`. */
export function axialRopeTables(coordinates: Float32Array, axes: number, bands: Float32Array, dtype: Dtype): AxialRopeTables {
  if (coordinates.length % axes !== 0) throw new Error(`axial RoPE: ${coordinates.length} coordinates do not split into ${axes} axes`);
  const positions = coordinates.length / axes, half = axes * bands.length, width = 2 * half;
  const cos = new Float32Array(positions * width), sin = new Float32Array(positions * width);
  for (let n = 0; n < positions; n++)
    for (let a = 0; a < axes; a++)
      for (let k = 0; k < bands.length; k++) {
        const phase = f32(coordinates[n * axes + a]! * bands[k]!);
        const c = Math.cos(phase), s = Math.sin(phase), at = n * width + a * bands.length + k;
        cos[at] = c; cos[at + half] = c;
        sin[at] = s; sin[at + half] = s;
      }
  const cast = (values: Float32Array) => {
    using wide = MlxArray.fromFloat32(values, [1, positions, 1, width]);
    return wide.astype(dtype);
  };
  return ownedTables(cast(cos), cast(sin), positions);
}

/** Rows `[from, to)` of `tables` as their own (owned) tables. */
export function sliceAxialRope(tables: AxialRopeTables, from: number, to: number): AxialRopeTables {
  const width = tables.cos.shape[3]!;
  const cos = tables.cos.slice([0, from, 0, 0], [1, to, 1, width]);
  const sin = tables.sin.slice([0, from, 0, 0], [1, to, 1, width]);
  return ownedTables(cos, sin, to - from);
}

/** `x * cos + rotate_half(x) * sin` for `x` `[B, N, H, D]` (borrowed), where
 * `rotate_half(x) = [-x2, x1]` over the head's halves. Returns an owned result. */
export function applyAxialRope(x: MlxArray, tables: AxialRopeTables): MlxArray {
  const shape = x.shape, head = shape[3]!, half = head / 2;
  using first = x.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, shape[2]!, half]);
  using second = x.slice([0, 0, 0, half], [shape[0]!, shape[1]!, shape[2]!, head]);
  using negated = ops.neg(second);
  using rotated = ops.concatAxis([negated, first], -1);
  using direct = ops.mul(x, tables.cos);
  using turned = ops.mul(rotated, tables.sin);
  return ops.add(direct, turned);
}
