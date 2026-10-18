import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.ServingBlocks
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/serving-blocks.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../contracts/mlx/cache";
import { CompiledGegluMLP, PlainGegluMLP } from "../../layers/geglu";
import { disposing } from "../../layers/helpers";
import { QuantizedLinearPlain } from "../../layers/quantized-linear";
import { DecoderLayer, FixedExperts, type DonorRead, type Gemma4Phase, type Router } from "./blocks";
import { isExpertTracing, recordRouting } from "../../runtime/expert-trace";

/** Serving operations borrow the same projections that training and LoRA mount. */
export class ServingRouter {
  readonly projection: QuantizedLinearPlain;
  constructor(readonly base: Router) { this.projection = new QuantizedLinearPlain(base.proj); }
  forward(x: MlxArray): { indices: MlxArray; weights: MlxArray } {
    using normed = ops.rmsNorm(x, this.base.normWeight, this.base.eps);
    using scores = this.projection.forward(normed);
    using part = ops.argpartitionAxis(scores, this.base.numExperts - this.base.topK, -1);
    const [B, L] = scores.shape;
    const indices = part.slice([0, 0, this.base.numExperts - this.base.topK], [B!, L!, this.base.numExperts]);
    let weights = ops.takeAlongAxis(scores, indices, -1);
    weights = disposing(weights, ops.softmaxAxis(weights, -1, false));
    using gathered = ops.takeAxis(this.base.perExpertScale, indices, 0);
    weights = disposing(weights, ops.mul(weights, gathered));
    if (isExpertTracing()) recordRouting(this.base.layerIdx, indices);
    return { indices, weights };
  }
}

export class ServingDenseLayer {
  readonly finish: (hidden: MlxArray, input: MlxArray | null) => MlxArray;
  constructor(readonly base: DecoderLayer, readonly mlp: CompiledGegluMLP | PlainGegluMLP) {
    // Artifact features are composed once; the request executes these operations.
    const input = base.perLayerGate ? (h: MlxArray, p: MlxArray | null) => base.perLayerGated(h, p!) : (h: MlxArray) => h;
    const scale = base.layerScalar ? (h: MlxArray) => base.scaled(h) : (h: MlxArray) => h;
    this.finish = (h, p) => scale(input(h, p));
  }
  forwardAttn(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null) { return this.base.forwardAttn(x, cache, phase, donor); }
  forwardMlp(h: MlxArray, input: MlxArray | null): MlxArray {
    let f = this.base.preFfNorm.forward(h);
    f = disposing(f, this.mlp.forward(f));
    f = disposing(f, this.base.postFfNorm.forward(f));
    const out = ops.add(h, f); f.dispose();
    return this.finish(out, input);
  }
  forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null, input: MlxArray | null) {
    const result = this.forwardAttn(x, cache, phase, donor);
    try { return {h:this.forwardMlp(result.h,input),donor:result.donor}; }
    catch(error) { result.donor?.dispose(); throw error; }
    finally { result.h.dispose(); }
  }
}

export class ServingMoeLayer extends ServingDenseLayer {
  readonly router: ServingRouter;
  constructor(base: DecoderLayer, mlp: CompiledGegluMLP, readonly experts: FixedExperts) {
    super(base, mlp); this.router = new ServingRouter(base.router!);
  }
  override forwardMlp(h: MlxArray, input: MlxArray | null): MlxArray {
    let dense = this.base.preFfNorm.forward(h);
    dense = disposing(dense, this.mlp.forward(dense));
    dense = disposing(dense, this.base.postFfNorm1!.forward(dense));
    const {indices,weights} = this.router.forward(h);
    let expert = this.base.preFfNorm2!.forward(h);
    expert = disposing(expert, this.experts.forward(expert,indices,weights));
    expert = disposing(expert, this.base.postFfNorm2!.forward(expert));
    indices.dispose(); weights.dispose();
    let f = ops.add(dense,expert); dense.dispose(); expert.dispose();
    f = disposing(f,this.base.postFfNorm.forward(f));
    const out = ops.add(h,f); f.dispose();
    return this.finish(out,input);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.ServingBlocks
