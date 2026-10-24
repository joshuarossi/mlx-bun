// MLX nn.softplus is the shapeless compiled logaddexp(x, 0) operation.
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";

/** A new compiled operation. Its owning layer must dispose it. */
export function compiledSoftplus(): CompiledFunction {
  return new CompiledFunction(inputs => {
    using zero = ops.scalarLike(0, inputs[0]!);
    return [ops.logaddexp(inputs[0]!, zero)];
  });
}
