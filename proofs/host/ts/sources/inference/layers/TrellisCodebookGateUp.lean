import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisCodebookGateUp
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-codebook-gate-up.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { gateUpCodebookRow } from "../kernels/trellis/gate-up-codebook";
import type { MixedGateUpTail } from "../kernels/trellis/mixed-gate-up";
import type { TrellisLinear } from "./trellis-linear";

// The fused gate/up/SwiGLU layer over a Qwen MLP's axis-1 Trellis gate and up
// projections at one row, decoding through a threadgroup codebook with the reduce
// kernels' output bits (kernels/trellis/gate-up-codebook.ts). It runs one kernel
// and takes everything that kernel varies on at construction.

/** `sameWidth` null: either. */
function sameAxis1(name: string, gate: TrellisLinear, up: TrellisLinear, sameWidth: boolean | null): void {
  const a = gate.geometry, b = up.geometry;
  if (a.axis !== 1 || b.axis !== 1 || a.rows !== b.rows || a.cols !== b.cols ||
      a.T !== b.T || a.L !== b.L || (sameWidth !== null && (a.k === b.k) !== sameWidth))
    throw new Error(`${name}: gate/up need packed axis-1 codes of one geometry${sameWidth === null ? ""
      : `, ${sameWidth ? "the same" : "different"} widths`}`);
  if (gate.variant !== up.variant) throw new Error(`${name}: gate and up decode with different variants`);
}

/** One activation row; gate and up at the same or different widths, decoding through a threadgroup codebook
 *  (kernels/trellis/gate-up-codebook.ts) with fusedGateUpSwiglu's (same widths) and fusedGateUpSwigluMixed's (different
 *  widths) output bits. `mixedTail` is the SwiGLU arithmetic where the widths differ (fusedGateUpSwigluMixed's `tail`);
 *  same widths take the float32 sigmoid. */
export class CodebookGateUpRow {
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear, readonly mixedTail: MixedGateUpTail) {
    sameAxis1("CodebookGateUpRow", gate, up, null);
    if (gate.geometry.L > 12) throw new Error("CodebookGateUpRow: the codebook holds at most 2^12 states");
  }

  /** `x` [.., in] (borrowed, one row) to an owned [.., rows]. */
  forward(x: MlxArray): MlxArray { return gateUpCodebookRow(x, this.gate, this.up, this.mixedTail); }
}

/** The mixed-width split activation tail, fixed for written two-argument bindings. */
export class CodebookSplitGateUpRow {
  constructor(readonly gate:TrellisLinear,readonly up:TrellisLinear) {
    sameAxis1("CodebookSplitGateUpRow",gate,up,null);
    if (gate.geometry.L>12) throw new Error("CodebookSplitGateUpRow: the codebook holds at most 2^12 states");
  }
  forward(x:MlxArray):MlxArray {return gateUpCodebookRow(x,this.gate,this.up,"split");}
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisCodebookGateUp
