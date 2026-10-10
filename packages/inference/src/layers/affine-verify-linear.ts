import type { MlxArray } from "@mlx-bun/mlx/array";
import { affine3Rows, affine3RowsEligible } from "../kernels/quantization/affine3-rows";
import { affine3Mma, affine3MmaEligible } from "../kernels/quantization/affine3-mma";
import { affine4Rows, affine4RowsEligible } from "../kernels/quantization/affine4-rows";
import { affine4Mma, affine4MmaEligible } from "../kernels/quantization/affine4-mma";
import type { QuantizedLinear } from "./quantized-linear";

// Verify-width projections over a loaded 3- or 4-bit, group-64 affine
// QuantizedLinear (borrowed weights, no additive bias). Each layer runs one
// kernel for one bit width and row form; the owning graph picks the layer for
// the projection's stored width and the request's row count. They do
// not apply mounted LoRA adapters: a graph using them serves adapters through
// QuantizedLinear itself.

function check(name: string, lin: QuantizedLinear, eligible: boolean): void {
  if (!lin.biases || lin.bias || !eligible) throw new Error(`${name}: unsupported projection (width, group 64, affine, no additive bias)`);
}

/** 2..8 activation rows sharing each decoded weight. */
export class Affine4RowsLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine4RowsLinear", linear, affine4RowsEligible(2, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return affine4Rows(x, this.linear.w, this.linear.scales, this.linear.biases!); }
}

/** 1..8 activation rows on the simdgroup matrix unit. */
export class Affine4MmaLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine4MmaLinear", linear, affine4MmaEligible(1, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return affine4Mma(x, this.linear.w, this.linear.scales, this.linear.biases!); }
}

/** 3-bit: 2..8 activation rows sharing each decoded weight. */
export class Affine3RowsLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine3RowsLinear", linear, affine3RowsEligible(2, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return affine3Rows(x, this.linear.w, this.linear.scales, this.linear.biases!); }
}

/** 3-bit: 1..8 activation rows on the simdgroup matrix unit. */
export class Affine3MmaLinear {
  constructor(readonly linear: QuantizedLinear) {
    check("Affine3MmaLinear", linear, affine3MmaEligible(1, linear.w, linear.scales, linear.spec));
  }
  forward(x: MlxArray): MlxArray { return affine3Mma(x, this.linear.w, this.linear.scales, this.linear.biases!); }
}
