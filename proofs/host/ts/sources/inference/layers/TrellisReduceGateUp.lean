import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisReduceGateUp
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-reduce-gate-up.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { gateUpReduceRow, gateUpReduceRows } from "../kernels/trellis/gate-up";
import { fusedGateUpSwigluMixed, type MixedGateUpTail } from "../kernels/trellis/mixed-gate-up";
import type { TrellisLinear } from "./trellis-linear";

// Fused gate/up/SwiGLU layers over a Qwen MLP's axis-1 Trellis gate and up
// projections on the reduce kernels (one SIMD group per output row, the decoded
// weight times the scale per weight; kernels/trellis/index.ts). Each layer runs
// one kernel for one row form and takes everything that kernel varies on at
// construction: the projections' decode variant and the representations their
// GPU family qualifies (`TrellisLinear.representations`). The owning graph picks
// the layer for the rows of its width class and the weights' bit widths.

function sameAxis1(name: string, gate: TrellisLinear, up: TrellisLinear, sameWidth: boolean): void {
  const a = gate.geometry, b = up.geometry;
  if (a.axis !== 1 || b.axis !== 1 || a.rows !== b.rows || a.cols !== b.cols ||
      a.T !== b.T || a.L !== b.L || (a.k === b.k) !== sameWidth)
    throw new Error(`${name}: gate/up need packed axis-1 codes of one geometry, ${sameWidth ? "the same" : "different"} widths`);
  if (gate.variant !== up.variant) throw new Error(`${name}: gate and up decode with different variants`);
}

/** One activation row; gate and up at the same width. The threadgroup codebook decode where the gate's GPU family
 *  qualifies it (applied by the kernel at the measured artifact shape). */
export class ReduceGateUpRow {
  readonly #variant: number;
  readonly #codebook: boolean;

  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) {
    sameAxis1("ReduceGateUpRow", gate, up, true);
    this.#variant = gate.variant;
    this.#codebook = gate.representations.gateUpCodebook;
  }

  /** `x` [.., in] (borrowed, one row) to an owned [.., rows]. */
  forward(x: MlxArray): MlxArray { return gateUpReduceRow(x, this.gate, this.up, this.#variant, this.#codebook); }
}

/** 2..4 activation rows sharing each decoded weight; gate and up at the same width. */
export class ReduceGateUpRows {
  readonly #variant: number;

  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) {
    sameAxis1("ReduceGateUpRows", gate, up, true);
    this.#variant = gate.variant;
  }

  /** `x` [.., in] (borrowed, 2..4 rows) to an owned [.., rows]. */
  forward(x: MlxArray): MlxArray { return gateUpReduceRows(x, this.gate, this.up, this.#variant); }
}

/** 1..4 activation rows; gate and up at different widths. `tail` is the SwiGLU arithmetic the kernel reproduces
 *  (`"split"`: MLX's compiled swiglu over the two bf16 projections, bit for bit; `"fused"`: the float32 sigmoid of the
 *  same-width kernel). The exact-bits decoder at one row where the gate's GPU family qualifies it. */
export class ReduceMixedGateUp {
  readonly #variant: number;
  readonly #exactBits: boolean;

  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear, readonly tail: MixedGateUpTail) {
    sameAxis1("ReduceMixedGateUp", gate, up, false);
    this.#variant = gate.variant;
    this.#exactBits = gate.representations.mixedExactBits;
  }

  /** `x` [.., in] (borrowed, 1..4 rows) to an owned [.., rows]. */
  forward(x: MlxArray): MlxArray {
    return fusedGateUpSwigluMixed(x, this.gate, this.up, this.#variant, this.tail, this.#exactBits);
  }
}

/** Fixed split activation for the written M1 graph's mixed-width projections. */
export class ReduceSplitMixedGateUp extends ReduceMixedGateUp {
  constructor(gate: TrellisLinear, up: TrellisLinear) { super(gate, up, "split"); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisReduceGateUp
