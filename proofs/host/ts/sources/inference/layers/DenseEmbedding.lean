import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.DenseEmbedding
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/dense-embedding.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
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

/** Plain unquantized embedding — mlx nn.Embedding (+ as_linear tied head). */
export class DenseEmbedding {
  readonly wT: MlxArray;

  constructor(readonly w: MlxArray) {
    this.wT = ops.transposeAxes(w, [1, 0]);
  }

  encode(ids: MlxArray): MlxArray {
    return ops.takeAxis(this.w, ids, 0);
  }

  /** nn.Embedding.as_linear: `x @ weight.T`. */
  asLinear(h: MlxArray): MlxArray {
    return ops.matmul(h, this.wT);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.DenseEmbedding
