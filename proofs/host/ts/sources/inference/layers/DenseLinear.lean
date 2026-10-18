import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.DenseLinear
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/dense-linear.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Universal-tier primitives: dense (unquantized) linear/embedding modules
// (mlx nn.Linear / nn.Embedding semantics), quantized-or-dense
// loader helpers, norm loaders, and the load-time weight audit.
//
// The quantized paths delegate to the proven QuantizedLinear/QuantizedEmbedding
// primitives (packages/inference/src/layers/); the
// dense paths are verbatim ports of mlx.nn.Linear (`mx.addmm(bias, x, W.T)`
// / `x @ W.T`) and mlx.nn.Embedding (`weight[ids]`, `x @ weight.T`).

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

/** Plain unquantized linear — mlx nn.Linear:
 *  `mx.addmm(bias, x, weight.T)` when bias is present, else `x @ weight.T`. */
export class DenseLinear {
  readonly wT: MlxArray;

  constructor(readonly w: MlxArray, readonly bias: MlxArray | null) {
    this.wT = ops.transposeAxes(w, [1, 0]); // lazy view, shared across calls
  }

  get inFeatures(): number {
    return this.w.shape[1]!;
  }
  get outFeatures(): number {
    return this.w.shape[0]!;
  }

  forward(x: MlxArray): MlxArray {
    return this.bias ? ops.addmm(this.bias, x, this.wT) : ops.matmul(x, this.wT);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.DenseLinear
