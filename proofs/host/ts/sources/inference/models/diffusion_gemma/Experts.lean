import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.DiffusionGemma.Experts
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/diffusion-gemma/experts.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { CompiledGeglu } from "../../layers/geglu";
import type { QuantizedSwitchLinear } from "../../layers/quantized-switch-linear";

export interface DiffExpertWeights {
  readonly gateUp: QuantizedSwitchLinear;
  readonly down: QuantizedSwitchLinear;
  readonly hiddenDims: number;
}

/** Fused gate/up experts in their original token order. */
export class UnsortedDiffExperts {
  readonly activation = new CompiledGeglu();
  constructor(readonly base: DiffExpertWeights) {}
  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    using expanded = ops.expandDims(x,-2);
    using h = ops.expandDims(expanded,-3);
    using gateUp = this.base.gateUp.forward(h,indices,false);
    const [gate,up] = ops.split(gateUp,[this.base.hiddenDims],-1);
    using mid = this.activation.forward(gate!,up!);
    using projected = this.base.down.forward(mid,indices,false);
    const shape = projected.shape; shape.splice(shape.length-2,1);
    using y = ops.reshape(projected,shape);
    using w = ops.expandDims(weights,-1);
    using weighted = ops.mul(y,w);
    return ops.sumAxis(weighted,-2,false);
  }
}

/** Expert-sorted rows and inverse permutation, bound by the graph. */
export class SortedDiffExperts {
  readonly activation = new CompiledGeglu();
  constructor(readonly base: DiffExpertWeights) {}
  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    using expanded = ops.expandDims(x,-2);
    using h = ops.expandDims(expanded,-3);
    const k = indices.shape.at(-1)!;
    using idxFlat = ops.reshape(indices,[indices.size]);
    using order = ops.argsortAxis(idxFlat,0);
    using inverse = ops.argsortAxis(order,0);
    using kScalar = ops.scalarLike(k,order);
    using rows = ops.floorDivide(order,kScalar);
    using flat = ops.reshape(h,[-1,1,h.shape.at(-1)!]);
    using sorted = ops.takeAxis(flat,rows,0);
    using idx = ops.takeAxis(idxFlat,order,0);
    using gateUp = this.base.gateUp.forward(sorted,idx,true);
    const [gate,up] = ops.split(gateUp,[this.base.hiddenDims],-1);
    using mid = this.activation.forward(gate!,up!);
    using projected = this.base.down.forward(mid,idx,true);
    using restored = ops.takeAxis(projected,inverse,0);
    using unsorted = ops.reshape(restored,[...indices.shape,1,restored.shape.at(-1)!]);
    const shape = unsorted.shape; shape.splice(shape.length-2,1);
    using y = ops.reshape(unsorted,shape);
    using w = ops.expandDims(weights,-1);
    using weighted = ops.mul(y,w);
    return ops.sumAxis(weighted,-2,false);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.DiffusionGemma.Experts
