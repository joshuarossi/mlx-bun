// MLX nn.silu: a shapeless compiled x * sigmoid(x), in the input dtype.
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";

/** A new compiled operation. Its owning layer must dispose it. */
export function compiledSilu(): CompiledFunction {
  return new CompiledFunction(inputs => [ops.silu(inputs[0]!)]);
}
