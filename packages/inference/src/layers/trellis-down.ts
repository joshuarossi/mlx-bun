import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { TrellisGeometry } from "../kernels/trellis/geometry";
import { downFactoredRow, downFactoredRows } from "../kernels/trellis/down-factored";
import { downK3InterleavedFactoredRow, downK3InterleavedFactoredRows } from "../kernels/trellis/down-k3-interleaved-factored";
import { downK3InterleavedMma, downMma } from "../kernels/trellis/down-mma";
import { TrellisLinear } from "./trellis-linear";

// Down-projection layers over a Qwen MLP's axis-0 Trellis codes. Each layer
// runs one kernel for one row form and one code layout (row-major, or the
// 3-bit block interleave); the owning graph picks the layer for the request's
// row count and the weights' layout. forward(x) keeps x's leading dimensions.

type Kernel = (x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry) => MlxArray;

function project(lin: TrellisLinear, kernel: Kernel, x: MlxArray): MlxArray {
  const g = lin.geometry, lead = x.shape.slice(0, -1);
  using x2 = ops.reshape(x, [lead.reduce((a, b) => a * b, 1), g.inFeatures]);
  using y = kernel(x2, lin.codes, lin.scales, g);
  return ops.reshape(y, [...lead, g.outFeatures]);
}
function rowMajor(name: string, lin: TrellisLinear): void {
  const g = lin.geometry;
  if (g.axis !== 0 || g.blockInterleave || lin.codes.ndim !== 2) throw new Error(`${name}: needs packed row-major axis-0 codes`);
}
function k3Interleaved(name: string, lin: TrellisLinear): void {
  const g = lin.geometry;
  if (g.axis !== 0 || g.blockInterleave !== 2 || g.k !== 3 || g.T !== 256 || g.L !== 12)
    throw new Error(`${name}: needs 3-bit block-interleaved axis-0 codes`);
}

/** One activation row; row-major codes. */
export class FactoredDownRow {
  constructor(readonly down: TrellisLinear) { rowMajor("FactoredDownRow", down); }
  forward(x: MlxArray): MlxArray { return project(this.down, downFactoredRow, x); }
}

/** 2..4 activation rows; row-major codes. */
export class FactoredDownRows {
  constructor(readonly down: TrellisLinear) { rowMajor("FactoredDownRows", down); }
  forward(x: MlxArray): MlxArray { return project(this.down, downFactoredRows, x); }
}

/** One activation row; 3-bit block-interleaved codes. */
export class FactoredDownK3iRow {
  constructor(readonly down: TrellisLinear) { k3Interleaved("FactoredDownK3iRow", down); }
  forward(x: MlxArray): MlxArray { return project(this.down, downK3InterleavedFactoredRow, x); }
}

/** 2..4 activation rows; 3-bit block-interleaved codes. */
export class FactoredDownK3iRows {
  constructor(readonly down: TrellisLinear) { k3Interleaved("FactoredDownK3iRows", down); }
  forward(x: MlxArray): MlxArray { return project(this.down, downK3InterleavedFactoredRows, x); }
}

/** 1..8 activation rows on the simdgroup matrix unit; row-major codes. */
export class MmaDown {
  constructor(readonly down: TrellisLinear) {
    rowMajor("MmaDown", down);
    if (down.geometry.T !== 256 || down.geometry.L > 12) throw new Error("MmaDown: needs T 256, L <= 12");
  }
  forward(x: MlxArray): MlxArray { return project(this.down, downMma, x); }
}

/** 1..8 activation rows on the simdgroup matrix unit; 3-bit block-interleaved codes. */
export class MmaDownK3i {
  constructor(readonly down: TrellisLinear) { k3Interleaved("MmaDownK3i", down); }
  forward(x: MlxArray): MlxArray { return project(this.down, downK3InterleavedMma, x); }
}
