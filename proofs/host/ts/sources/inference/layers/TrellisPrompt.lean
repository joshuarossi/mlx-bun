import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisPrompt
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-prompt.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { expandTrellis, trellisReduce, trellisScatter, wideTrellisPrefill, tiledTrellisPrefill, splitKTrellisPrefill } from "../kernels/trellis/index";
import { LoraOperation, LoraState } from "./lora";
import { compiledSwiglu } from "./swiglu";
import { fusedGateUpSwiglu, type TrellisLinear } from "./trellis-linear";

export interface RowProjection { forward(x: MlxArray): MlxArray }

/** The graph supplies a projection kernel. Shapes preserve the input's leading
 * dimensions; reshaped handles are released while the result remains lazy. */
function project(lin: TrellisLinear, x: MlxArray, kernel: (x: MlxArray) => MlxArray): MlxArray {
  const lead = x.shape.slice(0, -1);
  using rows = ops.reshape(x, [lead.reduce((a, b) => a * b, 1), lin.inFeatures]);
  using out = kernel(rows);
  return lin.delta.forward(x, ops.reshape(out, [...lead, lin.outFeatures]));
}

export class TrellisReducePrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    return project(this.linear, x, rows => trellisReduce(rows, this.linear.codes, this.linear.scales, this.linear.geometry, this.linear.variant));
  }
}
export class TrellisScatterPrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    return project(this.linear, x, rows => trellisScatter(rows, this.linear.codes, this.linear.scales, this.linear.geometry, this.linear.variant, this.linear.useSharedScatterCodebook, this.linear.representations.scatter));
  }
}
export class TrellisWidePrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    return project(this.linear, x, rows => wideTrellisPrefill(rows, this.linear.codes, this.linear.scales, this.linear.geometry));
  }
}
export class TrellisTiledPrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    return project(this.linear, x, rows => tiledTrellisPrefill(rows, this.linear.codes, this.linear.scales, this.linear.geometry));
  }
}
export class TrellisSplitKPrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    return project(this.linear, x, rows => splitKTrellisPrefill(rows, this.linear.codes, this.linear.scales, this.linear.geometry));
  }
}

/** Axis-1 dense expansion; evaluate the matmul before the next projection so
 * the deferred graph does not retain every expanded weight. */
export class TrellisExpandReducePrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    const out = project(this.linear, x, rows => {
      using stored = expandTrellis(this.linear.codes, this.linear.scales, this.linear.geometry, x.dtype, this.linear.variant);
      using wt = ops.transposeAxes(stored, [1, 0]);
      return ops.matmul(rows, wt);
    });
    out.eval();
    return out;
  }
}
export class TrellisExpandScatterPrompt {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    const out = project(this.linear, x, rows => {
      using stored = expandTrellis(this.linear.codes, this.linear.scales, this.linear.geometry, x.dtype, this.linear.variant);
      return ops.matmul(rows, stored);
    });
    out.eval();
    return out;
  }
}

/** Fused gate/up/SwiGLU followed by the literal down projection. */
export class TrellisFusedMLP {
  readonly #operation: LoraOperation;
  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear, readonly down: RowProjection,
    state?: LoraState) {


    const adapted = new TrellisUnfusedMLP(new TrellisReducePrompt(gate), new TrellisReducePrompt(up), down);
    this.#operation = new LoraOperation(x => {
      using hidden = fusedGateUpSwiglu(x, gate, up);
      return down.forward(hidden);
    }, x => adapted.forward(x), state, [gate.delta, up.delta]);
  }
  forward(x: MlxArray): MlxArray { return this.#operation.forward(x); }
  dispose(): void { this.#operation.dispose(); }
}

/** Independent projections followed by the oracle's compiled SwiGLU. */
export class TrellisUnfusedMLP {
  constructor(readonly gate: RowProjection, readonly up: RowProjection, readonly down: RowProjection) {}
  forward(x: MlxArray): MlxArray {
    using gate = this.gate.forward(x);
    using up = this.up.forward(x);
    using hidden = compiledSwiglu(gate, up);
    return this.down.forward(hidden);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisPrompt
