import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.DequantizedLinear
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/dequantized-linear.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { QuantizedLinear } from "./quantized-linear";

// A prompt piece's affine projection over a loaded QuantizedLinear (borrowed
// weights, no additive bias). From its fewest rows the weight is dequantized to
// bf16 for the call and multiplied by MLX's dense GEMM: the same bf16 weights
// MLX's quantized matmul builds in its tiles and the same float accumulation,
// so the output is that matmul's bit for bit, from the GEMM's larger tiles
// (measured on the M1 Max at 3 and 4 bits, group 64, every Qwen3.8 projection
// whose outputs are whole 64-wide tiles: bit-identical at every row count from
// 97 to 1100 above the split-K range below, and 1.0x to 1.3x faster from 128
// rows, 7.8 against 5.7 TFLOPS at 2048). Fewer rows, the rows where MLX's
// dense GEMM splits K (its own accumulation order: while ceil(M/16) ·
// ceil(N/16) <= 2048 on a Max GPU, so k_proj and v_proj's 1024 outputs up to
// 512 rows), and the other projections (DeltaNet's in_proj_a and in_proj_b, 48
// outputs) take MLX's quantized matmul itself. The identity is MLX's kernel
// choice at those shapes, not a property of every shape (at 512 inputs the two
// round differently): a graph selects this layer for the artifact it was
// measured on. The dense weight is a transient of one call (outputs x inputs x
// 2 bytes). Applies the request's external adapter delta after the projection.

/** The fewest rows the dense GEMM takes at any projection: below this the dequantization costs about what the
 *  GEMM saves over MLX's quantized matmul. */
export const DEQUANTIZED_MIN_ROWS = 128;

/** The most tiles of 16 x 16 outputs MLX's dense GEMM runs on its split-K kernel on a Max GPU (the M1 Max's
 *  `applegpu_g13s`), whose accumulation order is not the quantized matmul's. */
const SPLIT_K_TILES = 2048;

/** The fewest rows a projection of `outputs` outputs takes the dense GEMM at: DEQUANTIZED_MIN_ROWS or the first row
 *  count above the GEMM's split-K range at those outputs, whichever is more; never when they are not whole 64-wide
 *  tiles. */
export function dequantizedMinRows(outputs: number): number {
  return outputs % 64 !== 0 ? Infinity : Math.max(DEQUANTIZED_MIN_ROWS, 16 * Math.floor(SPLIT_K_TILES / Math.ceil(outputs / 16)) + 1);
}

export class DequantizedLinear {
  readonly #spec: ops.QuantSpec;
  /** The fewest rows this projection takes the dense GEMM at (`dequantizedMinRows`). */
  readonly #minRows: number;

  constructor(readonly linear: QuantizedLinear) {
    if (!linear.biases || linear.bias || linear.w.ndim !== 2 || linear.spec.mode !== "affine")
      throw new Error("DequantizedLinear: unsupported projection (affine, two-dimensional, no additive bias)");
    this.#spec = linear.spec;
    this.#minRows = dequantizedMinRows(linear.outFeatures);
  }

  /** `x` [.., inputs] (borrowed) to an owned [.., outputs], lazy. */
  forward(x: MlxArray): MlxArray {
    const { w, scales, biases } = this.linear;
    if (x.size / x.shape.at(-1)! < this.#minRows) return this.linear.delta.forward(x, ops.quantizedMatmul(x, w, scales, biases, this.#spec, true));
    using dense = ops.dequantize(w, scales, biases, this.#spec);
    using weightT = ops.transposeAxes(dense, [1, 0]);
    return this.linear.delta.forward(x, ops.matmul(x, weightT));
  }
}

/** One fixed dequantize-and-GEMM operation. The graph declares its measured row range. */
export class DequantizedMatmulLinear {
  constructor(readonly linear: QuantizedLinear) {
    if (!linear.biases || linear.bias || linear.w.ndim !== 2 || linear.spec.mode !== "affine")
      throw new Error("DequantizedMatmulLinear: unsupported projection (affine, two-dimensional, no additive bias)");
  }
  forward(x: MlxArray): MlxArray {
    const {w,scales,biases,spec}=this.linear;
    using dense=ops.dequantize(w,scales,biases,spec);
    using weightT=ops.transposeAxes(dense,[1,0]);
    return this.linear.delta.forward(x,ops.matmul(x,weightT));
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.DequantizedLinear
