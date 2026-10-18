import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.LayerNorm
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/layer-norm.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
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

/** mlx nn.LayerNorm (weight + bias affine — starcoder2's norm). */
export class LayerNorm {
  constructor(
    readonly weight: MlxArray,
    readonly bias: MlxArray | null,
    readonly eps: number,
  ) {}

  forward(x: MlxArray): MlxArray {
    return ops.layerNorm(x, this.weight, this.bias, this.eps);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.LayerNorm
