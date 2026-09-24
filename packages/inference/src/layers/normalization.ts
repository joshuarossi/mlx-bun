import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

export class RMSNorm {
  constructor(readonly weight: MlxArray | null, readonly eps: number) {}
  forward(x: MlxArray): MlxArray {
    return ops.rmsNorm(x, this.weight, this.eps);
  }
}
