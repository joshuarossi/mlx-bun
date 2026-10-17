import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisCodebookDown
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-codebook-down.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { downCodebookRow, downK3InterleavedCodebookRow } from "../kernels/trellis/down-codebook";
import type { TrellisLinear } from "./trellis-linear";

// Packed down-projection layers over a Qwen MLP's axis-0 Trellis codes at one
// row, with the scatter kernels' output bits (trellisScatter; kernels/trellis/index.ts)
// through a threadgroup codebook. Each layer runs one kernel for one code layout
// (row-major 2- or 4-bit codes, or the 3-bit block interleave) and checks the
// projection at construction. forward(x) keeps x's leading dimensions.

function project(lin: TrellisLinear, x: MlxArray, kernel: (x2: MlxArray) => MlxArray): MlxArray {
  const g = lin.geometry, lead = x.shape.slice(0, -1);
  using x2 = ops.reshape(x, [lead.reduce((a, b) => a * b, 1), g.inFeatures]);
  using y = kernel(x2);
  return ops.reshape(y, [...lead, g.outFeatures]);
}
function rowMajor(name: string, lin: TrellisLinear): void {
  const g = lin.geometry;
  if (g.axis !== 0 || g.blockInterleave || lin.codes.ndim !== 2 || (g.k === 3 && g.T === 256 && g.L <= 12))
    throw new Error(`${name}: needs packed row-major axis-0 codes the balanced kernels do not decode (3-bit codes take the K3i layers)`);
}
function k3Interleaved(name: string, lin: TrellisLinear): void {
  const g = lin.geometry;
  if (g.axis !== 0 || g.blockInterleave !== 2 || g.k !== 3 || g.T !== 256 || g.L !== 12)
    throw new Error(`${name}: needs 3-bit block-interleaved axis-0 codes`);
}

/** One activation row; row-major 2- or 4-bit codes at T 256, decoding through a threadgroup codebook with
 *  word-aligned lanes (kernels/trellis/down-codebook.ts): trellisScatter's single-row output bit for bit. */
export class CodebookDownRow {
  constructor(readonly down: TrellisLinear) {
    rowMajor("CodebookDownRow", down);
    const g = down.geometry;
    if ((g.k !== 2 && g.k !== 4) || g.T !== 256 || g.L > 12) throw new Error("CodebookDownRow: needs 2- or 4-bit codes at T 256, L <= 12");
  }

  forward(x: MlxArray): MlxArray {
    const { codes, scales, geometry } = this.down;
    return this.down.delta.forward(x, project(this.down, x, x2 => downCodebookRow(x2, codes, scales, geometry)));
  }
}

/** One activation row; 3-bit block-interleaved codes, the same way: trellisScatter's single-row output bit for bit. */
export class CodebookDownK3iRow {
  constructor(readonly down: TrellisLinear) { k3Interleaved("CodebookDownK3iRow", down); }

  forward(x: MlxArray): MlxArray {
    const { codes, scales, geometry } = this.down;
    return this.down.delta.forward(x, project(this.down, x, x2 => downK3InterleavedCodebookRow(x2, codes, scales, geometry)));
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisCodebookDown
