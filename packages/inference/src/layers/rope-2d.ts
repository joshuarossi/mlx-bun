// Two-dimensional rotary embedding of the Gemma vision towers (optiq's
// apply_multidimensional_rope): the head is split into one partition per
// spatial axis, and each partition rotates by its own axis position. The tables
// are built on device with the oracle's op sequence (arange -> power -> div ->
// cos/sin -> concat) so they are bit-identical to the reference's; a host-computed
// table rounds to bf16 differently and, applied to q and k in every layer,
// compounds.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

const AXES = 2;

/** cos/sin for every position, [B, L, 1, headDim] (broadcast over heads). */
export interface Rope2dTables {
  readonly cos: MlxArray;
  readonly sin: MlxArray;
  dispose(): void;
}

/** Tables for `positions` [B, L, 2] (integer or float grid coordinates, x then
 *  y), cast to the activation dtype the tables multiply. */
export function rope2dTables(positions: MlxArray, headDim: number, theta: number, dtype: Dtype): Rope2dTables {
  const channelsPerAxis = 2 * Math.floor(headDim / (2 * AXES));
  if (channelsPerAxis * AXES !== headDim) throw new Error(`2D RoPE needs a head dimension divisible by ${2 * AXES}, got ${headDim}`);
  const half = channelsPerAxis / 2;
  const [B, L] = positions.shape as [number, number, number];

  // timescale = theta ** ((2 / channelsPerAxis) * arange(half))
  const arange = ops.arange(0, half, 1, Dtype.float32);
  const exponents = ops.mulScalar(arange, 2 / channelsPerAxis);
  arange.dispose();
  const base = ops.scalarLike(theta, exponents);
  const timescale = ops.pow(base, exponents);
  base.dispose();
  exponents.dispose();

  const cosParts: MlxArray[] = [];
  const sinParts: MlxArray[] = [];
  for (let axis = 0; axis < AXES; axis++) {
    const column = positions.slice([0, 0, axis], [B, L, axis + 1]);
    const coordinate = column.astype(Dtype.float32);
    column.dispose();
    const angle = ops.div(coordinate, timescale); // [B, L, half]
    coordinate.dispose();
    const cos = ops.cos(angle);
    const sin = ops.sin(angle);
    angle.dispose();
    cosParts.push(ops.concatAxis([cos, cos], -1)); // [B, L, channelsPerAxis]
    sinParts.push(ops.concatAxis([sin, sin], -1));
    cos.dispose();
    sin.dispose();
  }
  timescale.dispose();

  const assemble = (parts: MlxArray[]): MlxArray => {
    const full = ops.concatAxis(parts, -1); // [B, L, headDim]
    for (const part of parts) part.dispose();
    const shaped = ops.reshape(full, [B, L, 1, headDim]);
    full.dispose();
    const cast = shaped.astype(dtype);
    shaped.dispose();
    return cast;
  };
  const cos = assemble(cosParts);
  const sin = assemble(sinParts);
  return { cos, sin, dispose() { cos.dispose(); sin.dispose(); } };
}

/** rotate_half applied within each axis partition of the head (not across the
 *  whole head): [-x2, x1] per partition. x: [..., headDim]. */
function partitionedRotateHalf(x: MlxArray): MlxArray {
  const shape = x.shape;
  const last = shape.length - 1;
  const channelsPerAxis = shape[last]! / AXES;
  const half = channelsPerAxis / 2;
  const slice = (from: number, to: number): MlxArray => {
    const start = shape.map(() => 0);
    const stop = [...shape];
    start[last] = from;
    stop[last] = to;
    return x.slice(start, stop);
  };
  const parts: MlxArray[] = [];
  const scratch: MlxArray[] = [];
  for (let axis = 0; axis < AXES; axis++) {
    const origin = axis * channelsPerAxis;
    const x1 = slice(origin, origin + half);
    const x2 = slice(origin + half, origin + channelsPerAxis);
    const negated = ops.neg(x2);
    parts.push(ops.concatAxis([negated, x1], last));
    scratch.push(x1, x2, negated);
  }
  const out = ops.concatAxis(parts, last);
  for (const array of [...scratch, ...parts]) array.dispose();
  return out;
}

/** x * cos + rotate_half(x) * sin. x: [B, L, H, headDim]; returns a new array. */
export function applyRope2d(x: MlxArray, tables: Rope2dTables): MlxArray {
  const rotated = partitionedRotateHalf(x);
  const direct = ops.mul(x, tables.cos);
  const turned = ops.mul(rotated, tables.sin);
  rotated.dispose();
  const out = ops.add(direct, turned);
  direct.dispose();
  turned.dispose();
  return out;
}
