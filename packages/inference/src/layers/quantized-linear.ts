import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { LoraState,loraInputDropout,type LoraWeights } from "../adapters/state";
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
  /** Mounted adapters keyed by id (null until first mount — fast path). */
  adapters: Map<string, LoraWeights> | null = null;
  /** Shared per-model active state (wired by AdapterManager.mount). */
  loraState: LoraState | null = null;
  /** Stable per-target index for keying training-only LoRA dropout (set by
   *  attachForTraining). Gives each adapted linear an independent dropout mask. */
  dropoutId = 0;
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
    // LoRA residual — composition is mlx-lm LoRALinear / optiq apply.py:
    //   y + (scale · ((x @ A) @ B)).astype(x.dtype)
    // (optiq mount.py omits the astype, leaking the f32 residual into the
    // bf16 stream — divergence documented in PLAN Phase 8 findings; the
    // cast form is what the adapters were trained behind.)
    const st = this.loraState;
    if (st && st.active.length > 0 && this.adapters && this.adapters.size > 0) {
      // Training-only LoRA-input dropout (PEFT applies dropout to x before A;
      // the base quantized path is untouched). Keyed by (seed, dropoutId) so the
      // backward recompute reproduces the exact mask.
      let xLora = x;
      let xDrop: MlxArray | null = null;
      if (st.dropoutSeed !== null && st.dropoutRate > 0) {
        xDrop = loraInputDropout(x, st.dropoutRate, st.dropoutSeed, this.dropoutId);
        xLora = xDrop;
      }
      for (const id of st.active) {
        const lw = this.adapters.get(id);
        if (!lw) continue;
        const xa = ops.matmul(xLora, lw.a);
        const z = ops.matmul(xa, lw.b);
        xa.dispose();
        const zs = ops.mulScalar(z, lw.scale);
        z.dispose();
        const zc = zs.astype(x.dtype);
        zs.dispose();
        const previous = out; out = ops.add(out, zc); previous.dispose();
        zc.dispose();
      }
      xDrop?.dispose();
    }
    return out;
  }
}
