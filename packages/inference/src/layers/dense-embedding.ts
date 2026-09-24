// Universal-tier primitives: dense (unquantized) linear/embedding modules
// (Phase 1.5 — mlx nn.Linear / nn.Embedding semantics), quantized-or-dense
// loader helpers, norm loaders, and the load-time weight audit.
//
// The quantized paths delegate to the proven gemma4-base primitives; the
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
