import type { MlxArray } from "@mlx-bun/mlx/array";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

// Sigmoid/tanh follow MLX 0.32.2 unary_ops.h (Apple Inc., MIT).
const HEADER = String.raw`
  template <typename T> T lstm_sigmoid(T x) {
    auto y = 1 / (1 + metal::exp(metal::abs(x)));
    return (x < 0) ? y : 1 - y;
  }
`;
const SOURCE = String.raw`
  const uint j = thread_position_in_grid.x;
  if (j >= uint(H)) return;
  const T i = lstm_sigmoid(gates[j]);
  const T f = lstm_sigmoid(gates[uint(H) + j]);
  const T g = metal::precise::tanh(gates[uint(2 * H) + j]);
  const T o = lstm_sigmoid(gates[uint(3 * H) + j]);
  const T keep = f * cell[j], add = i * g;
  const T c = keep + add;
  const T activated = metal::precise::tanh(c);
  next_cell[j] = c; hidden[j] = o * activated;
`;
/** i,f,g,o gates [1,4H], cell [1,H]. Each primitive's result rounds to T,
 * matching the unfused MLX recurrence. Both returned arrays are owned. */
export class LstmGatesKernel {
  readonly #kernel = new MetalKernel({
    name: "mlx_bun_lstm_gates",
    inputNames: ["gates", "cell"],
    outputNames: ["hidden", "next_cell"],
    source: SOURCE,
    header: HEADER,
  });
  apply(gates: MlxArray, cell: MlxArray): [MlxArray, MlxArray] {
    const h = cell.size;
    return this.#kernel.apply([gates, cell], {
      outputs: [
        { shape: [1, h], dtype: gates.dtype },
        { shape: [1, h], dtype: gates.dtype },
      ],
      grid: [h, 1, 1],
      threadGroup: [Math.min(256, h), 1, 1],
      templateDtypes: { T: gates.dtype },
      templateInts: { H: h },
    }) as [MlxArray, MlxArray];
  }
  dispose(): void {
    this.#kernel.dispose();
  }
}
