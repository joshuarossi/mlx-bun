import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.WrittenBlocks
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/written-blocks.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import type { Cache } from "../../contracts/mlx/cache";
import { RMSNorm } from "../../layers/normalization";
import { QuantizedLinear, QuantizedLinearPlain } from "../../layers/quantized-linear";
import { GegluMLP, PlainGegluMLP, CompiledGegluMLP, CompiledGeglu } from "../../layers/geglu";
import { Attention, Router, SwitchGLU, SortedSwitchGLU, UnsortedSwitchGLU, FixedExperts, type DonorRead, type Gemma4Phase } from "./blocks";
import { disposing } from "../../layers/helpers";

export class SlidingAttention extends Attention {
  constructor(weights: Weights, config: ModelConfig, prefix: string) { super(weights, config, prefix, "sliding_attention", true, undefined, false); }
  override forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, _donor: DonorRead | null) { return this.forwardSeparate(x, cache!, phase); }
}
export class FullAttention extends Attention {
  constructor(weights: Weights, config: ModelConfig, prefix: string) { super(weights, config, prefix, "full_attention", true, undefined, false); }
  override forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, _donor: DonorRead | null) { return this.forwardSeparate(x, cache!, phase); }
}
export class FullKEqVAttention extends Attention {
  constructor(weights: Weights, config: ModelConfig, prefix: string) { super(weights, config, prefix, "full_attention", true, undefined, true); }
  override forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, _donor: DonorRead | null) { return this.forwardKEqV(x, cache!, phase); }
}
export class SharedSlidingAttention extends Attention {
  constructor(weights: Weights, config: ModelConfig, prefix: string) { super(weights, config, prefix, "sliding_attention", false, undefined, false); }
  override forward(x: MlxArray, _cache: Cache | null, _phase: Gemma4Phase, donor: DonorRead | null) { return this.forwardShared(x, donor!); }
}
export class SharedFullAttention extends Attention {
  constructor(weights: Weights, config: ModelConfig, prefix: string) { super(weights, config, prefix, "full_attention", false, undefined, false); }
  override forward(x: MlxArray, _cache: Cache | null, _phase: Gemma4Phase, donor: DonorRead | null) { return this.forwardShared(x, donor!); }
}

/** Stored MLP projections. Each operation view names its activation literally. */
export class GemmaMlpWeights extends GegluMLP {
  constructor(weights: Weights, config: ModelConfig, prefix: string) { super(weights, config, prefix, true); }
}

/** Norms and scale owned by one written layer; model features are supplied as
 * concrete attention and feed-forward operations by the file. */
export class GemmaLayerWeights {
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  readonly layerScalar: MlxArray;
  readonly layerType: string;
  readonly mlp: GemmaMlpWeights;
  constructor(weights: Weights, config: ModelConfig, readonly prefix: string, readonly attn: Attention) {
    const norm = (name: string) => new RMSNorm(weights.tensor(`${prefix}.${name}.weight`), config.text.rmsNormEps);
    this.inputNorm = norm("input_layernorm"); this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm"); this.postFfNorm = norm("post_feedforward_layernorm");
    this.layerScalar = weights.tensor(`${prefix}.layer_scalar`);
    this.layerType = attn.isSliding ? "sliding_attention" : "full_attention";
    this.mlp = new GemmaMlpWeights(weights, config, `${prefix}.mlp`);
  }
  forwardAttn(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null): { h: MlxArray; donor: DonorRead | null } {
    const normed = this.inputNorm.forward(x);
    let result: { out: MlxArray; donor: DonorRead | null };
    try { result = this.attn.forward(normed, cache, phase, donor); } finally { normed.dispose(); }
    let hidden = result.out;
    try {
      hidden = disposing(hidden, this.postAttnNorm.forward(hidden));
      hidden = disposing(hidden, ops.add(x, hidden));
      return { h: hidden, donor: result.donor };
    } catch (error) { hidden.dispose(); result.donor?.dispose(); throw error; }
  }
  scaled(x: MlxArray): MlxArray { return disposing(x, ops.mul(x, this.layerScalar)); }
}

export class GemmaInputLayerWeights extends GemmaLayerWeights {
  readonly perLayerGate: QuantizedLinear;
  readonly perLayerProjection: QuantizedLinear;
  readonly postPerLayerNorm: RMSNorm;
  readonly #gate: QuantizedLinearPlain;
  readonly #projection: QuantizedLinearPlain;
  constructor(weights: Weights, config: ModelConfig, prefix: string, attn: Attention) {
    super(weights, config, prefix, attn);
    this.perLayerGate = QuantizedLinear.load(weights, `${prefix}.per_layer_input_gate`, config);
    this.perLayerProjection = QuantizedLinear.load(weights, `${prefix}.per_layer_projection`, config);
    this.postPerLayerNorm = new RMSNorm(weights.tensor(`${prefix}.post_per_layer_input_norm.weight`), config.text.rmsNormEps);
    this.#gate = new QuantizedLinearPlain(this.perLayerGate); this.#projection = new QuantizedLinearPlain(this.perLayerProjection);
  }
  perLayerGated(h: MlxArray, input: MlxArray): MlxArray {
    let gate = this.#gate.forward(h);
    gate = disposing(gate, ops.geluApprox(gate));
    gate = disposing(gate, ops.mul(gate, input));
    gate = disposing(gate, this.#projection.forward(gate));
    gate = disposing(gate, this.postPerLayerNorm.forward(gate));
    const out = ops.add(h, gate); h.dispose(); gate.dispose(); return out;
  }
}

export class GemmaMoeLayerWeights extends GemmaLayerWeights {
  readonly router: Router;
  readonly experts: SwitchGLU;
  readonly postFfNorm1: RMSNorm;
  readonly postFfNorm2: RMSNorm;
  readonly preFfNorm2: RMSNorm;
  constructor(weights: Weights, config: ModelConfig, prefix: string, attn: Attention) {
    super(weights, config, prefix, attn);
    this.router = new PlainRouter(weights, config, `${prefix}.router`);
    this.experts = new SwitchGLU(weights, config, `${prefix}.experts.switch_glu`, true);
    const norm = (name: string) => new RMSNorm(weights.tensor(`${prefix}.${name}.weight`), config.text.rmsNormEps);
    this.postFfNorm1 = norm("post_feedforward_layernorm_1"); this.postFfNorm2 = norm("post_feedforward_layernorm_2");
    this.preFfNorm2 = norm("pre_feedforward_layernorm_2");
  }
}

export class GemmaDenseLayer {
  constructor(readonly weights: GemmaLayerWeights, readonly mlp: PlainGegluMLP | CompiledGegluMLP) {}
  get attn(): Attention { return this.weights.attn; }
  get layerType(): string { return this.weights.layerType; }
  forwardAttn(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null) { return this.weights.forwardAttn(x, cache, phase, donor); }
  feedforward(h: MlxArray): MlxArray {
    let feedforward = this.weights.preFfNorm.forward(h);
    feedforward = disposing(feedforward, this.mlp.forward(feedforward));
    feedforward = disposing(feedforward, this.weights.postFfNorm.forward(feedforward));
    const output = ops.add(h, feedforward); feedforward.dispose();
    return this.weights.scaled(output);
  }
  forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null, _input: MlxArray | null = null) {
    const { h, donor: made } = this.forwardAttn(x, cache, phase, donor);
    try { return { h: this.feedforward(h), donor: made }; }
    catch (error) { made?.dispose(); throw error; } finally { h.dispose(); }
  }
}

export class GemmaInputLayer {
  constructor(readonly weights: GemmaInputLayerWeights, readonly mlp: PlainGegluMLP | CompiledGegluMLP) {}
  get attn(): Attention { return this.weights.attn; }
  get layerType(): string { return this.weights.layerType; }
  forwardAttn(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null) { return this.weights.forwardAttn(x, cache, phase, donor); }
  feedforward(h: MlxArray, input: MlxArray): MlxArray {
    let feedforward = this.weights.preFfNorm.forward(h);
    feedforward = disposing(feedforward, this.mlp.forward(feedforward));
    feedforward = disposing(feedforward, this.weights.postFfNorm.forward(feedforward));
    const output = ops.add(h, feedforward); feedforward.dispose();
    return this.weights.scaled(this.weights.perLayerGated(output, input));
  }
  forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null, input: MlxArray | null) {
    const { h, donor: made } = this.forwardAttn(x, cache, phase, donor);
    try { return { h: this.feedforward(h, input!), donor: made }; }
    catch (error) { made?.dispose(); throw error; } finally { h.dispose(); }
  }
}

export class GemmaMoeLayer {
  constructor(readonly weights: GemmaMoeLayerWeights, readonly mlp: CompiledGegluMLP, readonly experts: FixedExperts) {}
  get attn(): Attention { return this.weights.attn; }
  get layerType(): string { return this.weights.layerType; }
  forwardAttn(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null) { return this.weights.forwardAttn(x, cache, phase, donor); }
  feedforward(h: MlxArray): MlxArray {
    let dense = this.weights.preFfNorm.forward(h);
    dense = disposing(dense, this.mlp.forward(dense));
    dense = disposing(dense, this.weights.postFfNorm1.forward(dense));
    const { indices, weights } = this.weights.router.forward(h);
    let expert = this.weights.preFfNorm2.forward(h);
    expert = disposing(expert, this.experts.forward(expert, indices, weights));
    expert = disposing(expert, this.weights.postFfNorm2.forward(expert));
    indices.dispose(); weights.dispose();
    let feedforward = ops.add(dense, expert); dense.dispose(); expert.dispose();
    feedforward = disposing(feedforward, this.weights.postFfNorm.forward(feedforward));
    const out = ops.add(h, feedforward); feedforward.dispose(); return this.weights.scaled(out);
  }
  forward(x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null, _input: MlxArray | null = null) {
    const { h, donor: made } = this.forwardAttn(x, cache, phase, donor);
    try { return { h: this.feedforward(h), donor: made }; }
    catch (error) { made?.dispose(); throw error; } finally { h.dispose(); }
  }
}

export { PlainGegluMLP, CompiledGegluMLP, CompiledGeglu, SortedSwitchGLU, UnsortedSwitchGLU, FixedExperts };

/** Ordinary layer-input slices; trace slices have their own named layer. */
export class FixedPerLayerInputs extends PerLayerInputs {
  readonly #projection: QuantizedLinearPlain;
  readonly #layerCount: number;
  readonly #hiddenSize: number;
  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    super(weights, config, prefix);
    this.#projection = new QuantizedLinearPlain(this.modelProjection);
    this.#layerCount = config.text.numHiddenLayers; this.#hiddenSize = config.text.hiddenSize;
  }
  override compute(ids: MlxArray, hidden: MlxArray): MlxArray {
    const [B, L] = ids.shape;
    let inputs = this.embed.encode(ids);
    inputs = disposing(inputs, ops.mulScalar(inputs, Math.sqrt(this.width)));
    inputs = disposing(inputs, ops.reshape(inputs, [B!, L!, this.#layerCount, this.width]));
    let projection = this.#projection.forward(hidden);
    projection = disposing(projection, ops.mulScalar(projection, 1 / Math.sqrt(this.#hiddenSize)));
    projection = disposing(projection, ops.reshape(projection, [B!, L!, this.#layerCount, this.width]));
    projection = disposing(projection, this.projectionNorm.forward(projection));
    const combined = ops.add(projection, inputs); projection.dispose(); inputs.dispose();
    return disposing(combined, ops.mulScalar(combined, Math.SQRT1_2));
  }
  override layer(inputs: MlxArray, index: number, batch: number, length: number): MlxArray {
    using slice = inputs.slice([0, 0, index, 0], [batch, length, index + 1, this.width]);
    return ops.reshape(slice, [batch, length, this.width]);
  }
}
export class TracePerLayerInputs extends FixedPerLayerInputs {
  override layer(inputs: MlxArray, index: number, batch: number, length: number): MlxArray {
    using start = ops.fromInt32([index], [1]);
    using slice = ops.sliceDynamic(inputs, start, [2], [batch, length, 1, this.width]);
    return ops.reshape(slice, [batch, length, this.width]);
  }
}

import { PerLayerInputs } from "./blocks";

/** Ordinary router slice, with no compiled-trace form selection. */
export class PlainRouter extends Router {
  readonly #projection: QuantizedLinearPlain;
  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    super(weights, config, prefix); this.#projection = new QuantizedLinearPlain(this.proj);
  }
  override forward(x: MlxArray): { indices: MlxArray; weights: MlxArray } {
    using normed = ops.rmsNorm(x, this.normWeight, this.eps);
    using scores = this.#projection.forward(normed);
    using part = ops.argpartitionAxis(scores, this.numExperts - this.topK, -1);
    const [B, L] = scores.shape;
    const indices = part.slice([0, 0, this.numExperts - this.topK], [B!, L!, this.numExperts]);
    let weights = ops.takeAlongAxis(scores, indices, -1);
    weights = disposing(weights, ops.softmaxAxis(weights, -1, false));
    using gathered = ops.takeAxis(this.perExpertScale, indices, 0);
    weights = disposing(weights, ops.mul(weights, gathered));
    if (isExpertTracing()) recordRouting(this.layerIdx, indices);
    return { indices, weights };
  }
}

import { isExpertTracing, recordRouting } from "../../runtime/expert-trace";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.WrittenBlocks
