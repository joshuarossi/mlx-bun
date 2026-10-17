import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.AffineVerifyLinear
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/affine-verify-linear.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { affineRow, affineRowEligible } from "../kernels/quantization/affine-row";
import { affineSplitMma, affineSplitMmaEligible, affineSplitMmaPlan, type AffineSplitMmaPlan } from "../kernels/quantization/affine-split-mma";
import { affine3Rows, affine3RowsEligible } from "../kernels/quantization/affine3-rows";
import { affine3Mma, affine3MmaEligible } from "../kernels/quantization/affine3-mma";
import { affine4Rows, affine4RowsEligible } from "../kernels/quantization/affine4-rows";
import { affine4Mma, affine4MmaEligible } from "../kernels/quantization/affine4-mma";
import type { QuantizedLinear } from "./quantized-linear";

// Decode and verify projections borrow an affine carrier. Each class runs its
// fixed kernel and applies the request's external adapter delta afterward.


function check(name: string, lin: QuantizedLinear, eligible: boolean): void {
  if (!lin.biases || lin.bias || !eligible) throw new Error(`${name}: unsupported projection (width, group 64, affine, no additive bias)`);
}

/** 2..8 activation rows sharing each decoded weight. */
export class Affine4RowsLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine4RowsLinear", linear, affine4RowsEligible(2, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return this.linear.delta.forward(x, affine4Rows(x, this.linear.w, this.linear.scales, this.linear.biases!)); }
}

/** One activation row (3- or 4-bit, the stored width): QuantizedLinear's bits (MLX's one-row quantized matmul),
 *  each threadgroup computing its activation chunks once (M1 Max). */
export class AffineRowLinear {
  readonly #bits: 3 | 4;
  constructor(readonly linear: QuantizedLinear) {
    check("AffineRowLinear", linear, affineRowEligible(1, linear.w, linear.scales, linear.spec));
    this.#bits = linear.spec.bits as 3 | 4;
  }
  forward(x: MlxArray): MlxArray { return this.linear.delta.forward(x, affineRow(x, this.linear.w, this.linear.scales, this.linear.biases!, this.#bits)); }
}

/** 1..8 activation rows on the simdgroup matrix unit. */
export class Affine4MmaLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine4MmaLinear", linear, affine4MmaEligible(1, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return this.linear.delta.forward(x, affine4Mma(x, this.linear.w, this.linear.scales, this.linear.biases!)); }
}

/** 3-bit: 2..8 activation rows sharing each decoded weight. */
export class Affine3RowsLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine3RowsLinear", linear, affine3RowsEligible(2, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return this.linear.delta.forward(x, affine3Rows(x, this.linear.w, this.linear.scales, this.linear.biases!)); }
}

/** 3-bit: 1..8 activation rows on the simdgroup matrix unit. */
export class Affine3MmaLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine3MmaLinear", linear, affine3MmaEligible(1, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return this.linear.delta.forward(x, affine3Mma(x, this.linear.w, this.linear.scales, this.linear.biases!)); }
}

/** Any number of activation rows, in blocks of 8 (3- or 4-bit, the stored width), on the simdgroup matrix unit,
 *  output tiles sharing each activation fragment and K split across the threadgroup (M1 Max); the launch follows
 *  the output width. */
export class AffineSplitMmaLinear {
  readonly #bits: 3 | 4;
  readonly #plan: AffineSplitMmaPlan;
  constructor(readonly linear: QuantizedLinear) {
    check("AffineSplitMmaLinear", linear, affineSplitMmaEligible(1, linear.w, linear.scales, linear.spec));
    this.#bits = linear.spec.bits as 3 | 4;
    this.#plan = affineSplitMmaPlan(linear.outFeatures);
  }
  forward(x: MlxArray): MlxArray {
    return this.linear.delta.forward(x, affineSplitMma(x, this.linear.w, this.linear.scales, this.linear.biases!, this.#bits, this.#plan));
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.AffineVerifyLinear
