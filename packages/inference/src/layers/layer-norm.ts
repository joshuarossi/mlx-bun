// Universal-tier primitives: dense (unquantized) linear/embedding modules
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
