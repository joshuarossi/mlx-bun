import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisDown
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-down.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { TrellisGeometry } from "../kernels/trellis/geometry";
import { downFactoredRow, downFactoredRows } from "../kernels/trellis/down-factored";
import { downK3InterleavedFactoredRow, downK3InterleavedFactoredRows } from "../kernels/trellis/down-k3-interleaved-factored";
import { downK3InterleavedMma, downMma } from "../kernels/trellis/down-mma";
import {
  DOWN_ONE_BLOCK, downK3InterleavedMmaWide, downK3InterleavedMmaWidePass, downMmaWide, downMmaWidePass,
} from "../kernels/trellis/down-mma-wide";
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
  return lin.delta.forward(x, ops.reshape(y, [...lead, g.outFeatures]));
}
// The any-row codebook down kernel in one block of 8 rows per pass, fixed for the 1..8-row layers.
const oneBlockDown: Kernel = (x2, codes, scales, g) => downMmaWidePass(x2, codes, scales, g, DOWN_ONE_BLOCK);
const oneBlockDownK3i: Kernel = (x2, codes, scales, g) => downK3InterleavedMmaWidePass(x2, codes, scales, g, DOWN_ONE_BLOCK);

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

/** Any number of activation rows on the simdgroup matrix unit through a threadgroup codebook, each decoded fragment
 *  feeding up to three 8-row blocks (MmaDown's bits per block); row-major codes. */
export class MmaDownWide {
  constructor(readonly down: TrellisLinear) {
    rowMajor("MmaDownWide", down);
    const g = down.geometry;
    if (g.T !== 256 || g.L > 12 || g.rows % 8 !== 0) throw new Error("MmaDownWide: needs T 256, L <= 12, rows % 8");
  }
  forward(x: MlxArray): MlxArray { return project(this.down, downMmaWide, x); }
}

/** Any number of activation rows on the simdgroup matrix unit through a threadgroup codebook (MmaDownK3i's bits per
 *  block of 8); 3-bit block-interleaved codes. */
export class MmaDownWideK3i {
  constructor(readonly down: TrellisLinear) {
    k3Interleaved("MmaDownWideK3i", down);
    if (down.geometry.rows % 8 !== 0) throw new Error("MmaDownWideK3i: needs rows % 8");
  }
  forward(x: MlxArray): MlxArray { return project(this.down, downK3InterleavedMmaWide, x); }
}

/** 1..8 activation rows on the simdgroup matrix unit through a threadgroup codebook, one block of 8 rows per pass (the
 *  any-row kernel's one-block pass; MmaDown's bits); row-major codes. */
export class CodebookMmaDown {
  constructor(readonly down: TrellisLinear) {
    rowMajor("CodebookMmaDown", down);
    const g = down.geometry;
    if (g.T !== 256 || g.L > 12 || g.rows % 8 !== 0) throw new Error("CodebookMmaDown: needs T 256, L <= 12, rows % 8");
  }
  forward(x: MlxArray): MlxArray { return project(this.down, oneBlockDown, x); }
}

/** CodebookMmaDown for 3-bit block-interleaved codes (MmaDownK3i's bits). */
export class CodebookMmaDownK3i {
  constructor(readonly down: TrellisLinear) {
    k3Interleaved("CodebookMmaDownK3i", down);
    if (down.geometry.rows % 8 !== 0) throw new Error("CodebookMmaDownK3i: needs rows % 8");
  }
  forward(x: MlxArray): MlxArray { return project(this.down, oneBlockDownK3i, x); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisDown
