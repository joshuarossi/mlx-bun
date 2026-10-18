import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisGateUp
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-gate-up.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { gateUpFactoredRow, gateUpFactoredRows } from "../kernels/trellis/gate-up-factored";
import { mixedGateUpFactoredRows } from "../kernels/trellis/mixed-gate-up-factored";
import { gateUpMma } from "../kernels/trellis/gate-up-mma";
import { gateUpMmaWide } from "../kernels/trellis/gate-up-mma-wide";
import { gateUpCodebookMma } from "../kernels/trellis/gate-up-codebook-mma";
import { TrellisLinear } from "./trellis-linear";

// Fused gate/up/SwiGLU layers over a Qwen MLP's axis-1 Trellis gate and up
// projections. Each layer runs one kernel for one row form; the owning graph
// picks the layer for the request's row count and the weights' bit widths.

function sameAxis1(name: string, gate: TrellisLinear, up: TrellisLinear, sameWidth: boolean): void {
  const a = gate.geometry, b = up.geometry;
  if (a.axis !== 1 || b.axis !== 1 || a.rows !== b.rows || a.cols !== b.cols ||
      a.T !== b.T || a.L !== b.L || (a.k === b.k) !== sameWidth)
    throw new Error(`${name}: gate/up need packed axis-1 codes of one geometry, ${sameWidth ? "the same" : "different"} widths`);
}

/** One activation row; gate and up at the same width. */
export class FactoredGateUpRow {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) { sameAxis1("FactoredGateUpRow", gate, up, true); }
  forward(x: MlxArray): MlxArray { return gateUpFactoredRow(x, this.gate, this.up); }
}

/** 2..4 activation rows sharing each decoded weight; same widths. */
export class FactoredGateUpRows {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) { sameAxis1("FactoredGateUpRows", gate, up, true); }
  forward(x: MlxArray): MlxArray { return gateUpFactoredRows(x, this.gate, this.up); }
}

/** 1..4 activation rows; gate and up at different widths. */
export class FactoredMixedGateUp {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) { sameAxis1("FactoredMixedGateUp", gate, up, false); }
  forward(x: MlxArray): MlxArray { return mixedGateUpFactoredRows(x, this.gate, this.up); }
}

/** 1..8 activation rows on the simdgroup matrix unit; widths may differ. */
export class MmaGateUp {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) {
    const a = gate.geometry, b = up.geometry;
    if (a.axis !== 1 || b.axis !== 1 || a.rows !== b.rows || a.cols !== b.cols ||
        a.T !== b.T || a.L !== b.L || a.rows % 8 !== 0 || a.cols % 256 !== 0)
      throw new Error("MmaGateUp: gate/up need packed axis-1 codes of one geometry (rows % 8, cols % 256)");
  }
  forward(x: MlxArray): MlxArray { return gateUpMma(x, this.gate, this.up); }
}

/** Any number of activation rows on the simdgroup matrix unit, each decoded weight fragment feeding several 8-row
 *  blocks (a threadgroup codebook, activations staged in threadgroup memory); widths may differ. */
export class MmaGateUpWide {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) {
    const a = gate.geometry, b = up.geometry;
    if (a.axis !== 1 || b.axis !== 1 || a.rows !== b.rows || a.cols !== b.cols ||
        a.T !== b.T || a.L !== b.L || a.rows % 8 !== 0 || a.cols % 256 !== 0 || a.L > 12)
      throw new Error("MmaGateUpWide: gate/up need packed axis-1 codes of one geometry (rows % 8, cols % 256, L <= 12)");
  }
  forward(x: MlxArray): MlxArray { return gateUpMmaWide(x, this.gate, this.up); }
}

/** 1..8 activation rows on the simdgroup matrix unit, each code value read from a threadgroup codebook (MmaGateUp's
 *  bits); widths may differ. */
export class CodebookMmaGateUp {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear) {
    const a = gate.geometry, b = up.geometry;
    if (a.axis !== 1 || b.axis !== 1 || a.rows !== b.rows || a.cols !== b.cols ||
        a.T !== b.T || a.L !== b.L || a.rows % 8 !== 0 || a.cols % 256 !== 0 || a.L > 12)
      throw new Error("CodebookMmaGateUp: gate/up need packed axis-1 codes of one geometry (rows % 8, cols % 256, L <= 12)");
  }
  forward(x: MlxArray): MlxArray { return gateUpCodebookMma(x, this.gate, this.up); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisGateUp
