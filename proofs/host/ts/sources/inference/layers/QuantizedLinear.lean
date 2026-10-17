import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.QuantizedLinear
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/quantized-linear.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { LoraDelta, type LoraState, type LoraWeights } from "./lora";
import { quantFor,type ModelConfig } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import { quantizedMatmulRows } from "../kernels/quantization/affine-rows";

/** Replaceable quantized payload. Inference sees this as read-only through
 *  QuantizedLinear getters; sensitivity analysis exchanges it atomically. */
export interface QuantizedLinearState {
  w: MlxArray;
  scales: MlxArray;
  biases: MlxArray | null;
  spec: ops.QuantSpec;
}

export class QuantizedLinear {
  readonly delta = new LoraDelta();
  get adapters(): Map<string, LoraWeights> | null { return this.delta.adapters; }
  set adapters(value: Map<string, LoraWeights> | null) { this.delta.adapters = value; }
  get loraState(): LoraState | null { return this.delta.loraState; }
  set loraState(value: LoraState | null) { this.delta.loraState = value; }
  get dropoutId(): number { return this.delta.dropoutId; }
  set dropoutId(value: number) { this.delta.dropoutId = value; }
  private _w: MlxArray;
  private _scales: MlxArray;
  private _biases: MlxArray | null;
  private _spec: ops.QuantSpec;

  constructor(
    w: MlxArray,
    scales: MlxArray,
    biases: MlxArray | null,
    spec: ops.QuantSpec,
    /** ADDITIVE bias term (`.bias`, mlx nn.QuantizedLinear's optional bias —
     *  qwen2 qkv, starcoder2, …). Distinct from `biases`, the quantization
     *  zero-points. Applied after the matmul, before any LoRA residual,
     *  exactly like mlx's QuantizedLinear.__call__. */
    readonly bias: MlxArray | null = null,
  ) {
    this._w = w;
    this._scales = scales;
    this._biases = biases;
    this._spec = spec;
  }

  get w(): MlxArray { return this._w; }
  get scales(): MlxArray { return this._scales; }
  get biases(): MlxArray | null { return this._biases; }
  get spec(): ops.QuantSpec { return this._spec; }

  /** Atomically install a quantized payload and return the previous one.
   *  This is the sole mutation capability used by sensitivity sweeps. */
  exchangeQuantizedState(next: QuantizedLinearState): QuantizedLinearState {
    const previous = {
      w: this._w,
      scales: this._scales,
      biases: this._biases,
      spec: this._spec,
    };
    this._w = next.w;
    this._scales = next.scales;
    this._biases = next.biases;
    this._spec = next.spec;
    return previous;
  }

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedLinear {
    if (!weights.has(`${path}.scales`))
      throw new Error(`${path}: expected quantized linear (no .scales tensor)`);
    const spec = quantFor(config.quantization, path);
    if (!spec) throw new Error(`${path}: no quant spec`);
    return new QuantizedLinear(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
      weights.has(`${path}.bias`) ? weights.tensor(`${path}.bias`) : null,
    );
  }

  /** (in_features, out_features) from the quantized tensors (reference
   *  _infer_linear_shape: scales are [out, in/group_size]). */
  get inFeatures(): number {
    return this._scales.shape[1]! * this._spec.groupSize;
  }
  get outFeatures(): number {
    return this._scales.shape[0]!;
  }

  forward(x: MlxArray, independentRows = false): MlxArray {
    let out = independentRows ? quantizedMatmulRows(
      x, this._w, this._scales, this._biases, this._spec,
    ) : ops.quantizedMatmul(
      x,
      this._w,
      this._scales,
      this._biases,
      this._spec,
      true,
    );
    // Additive bias (mlx QuantizedLinear: `x = x + self["bias"]`), before
    // the LoRA residual (LoRALinear calls the base linear bias-inclusive).
    if (this.bias) { const previous = out; out = ops.add(out, this.bias); previous.dispose(); }
    return this.delta.forward(x, out);
  }
}

/** Stock affine projection. The weights and adapter target belong to base. */
export class QuantizedLinearPlain {
  readonly #bias: (out: MlxArray) => MlxArray;
  constructor(readonly base: QuantizedLinear) {
    this.#bias = base.bias ? out => { const next = ops.add(out, base.bias!); out.dispose(); return next; } : out => out;
  }
  static load(weights: Weights, path: string, config: ModelConfig): QuantizedLinearPlain {
    return new QuantizedLinearPlain(QuantizedLinear.load(weights, path, config));
  }
  forward(x: MlxArray): MlxArray {
    const out = ops.quantizedMatmul(x, this.base.w, this.base.scales, this.base.biases, this.base.spec, true);
    return this.base.delta.forward(x, this.#bias(out));
  }
}

/** Each position uses independent one-row affine arithmetic. */
export class QuantizedLinearRows {
  readonly #bias: (out: MlxArray) => MlxArray;
  constructor(readonly base: QuantizedLinear) {
    this.#bias = base.bias ? out => { const next = ops.add(out, base.bias!); out.dispose(); return next; } : out => out;
  }
  static load(weights: Weights, path: string, config: ModelConfig): QuantizedLinearRows {
    return new QuantizedLinearRows(QuantizedLinear.load(weights, path, config));
  }
  forward(x: MlxArray): MlxArray {
    const out = quantizedMatmulRows(x, this.base.w, this.base.scales, this.base.biases, this.base.spec);
    return this.base.delta.forward(x, this.#bias(out));
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.QuantizedLinear
