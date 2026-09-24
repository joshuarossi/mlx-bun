import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, activeMemory, maxRecommendedWorkingSetSize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor, type ModelConfig, type QuantSpec } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import { runtimeFlag, runtimeNumber, runtimeValue } from "../runtime/config";
import { QuantizedLinear } from "./quantized-linear";
import { wordsPerBlock } from "../kernels/trellis/codebook";
import {
  TRELLIS_MATVEC_MAX_M as MATVEC_MAX_M, type TrellisGeometry,
  expandTrellis, trellisReduce, trellisScatter,
  fusedGateUpSwiglu as gateUpKernel, fusedGateUpSwigluMixed as mixedGateUpKernel,
  tiledTrellisPrefill, tiledTrellisPrefillEligible,
  splitKTrellisPrefill, splitKTrellisPrefillEligible,
  wideTrellisPrefill, wideTrellisPrefillEligible, type MixedGateUpTail,
} from "../kernels/trellis/index";
export { TRELLIS_MATVEC_MAX_M, type TrellisGeometry, type MixedGateUpTail } from "../kernels/trellis/index";

/** Decode variant (see HEADER). Default passed the M4 Pro closeout matrix;
 *  `MLX_BUN_TRELLIS_VARIANT` overrides for experiments. */
let variantOverride: number | null = null;
/** Explicit override (benches); otherwise the runtime flag — read per call so
 *  the self-flag KL gate (`eval.ts kl --decode --self MLX_BUN_TRELLIS_VARIANT`)
 *  can A/B two decodes on one loaded model. */
export function setTrellisVariant(v: number | null): void { variantOverride = v; }
function variant(): number {
  return variantOverride ?? runtimeNumber("MLX_BUN_TRELLIS_VARIANT", 13);
}

export function trellisGeometry(codes: MlxArray, spec: QuantSpec): TrellisGeometry {
  const tr = spec.trellis;
  if (spec.mode !== "trellis" || !tr) throw new Error("trellisGeometry: spec is not a trellis spec");
  const k = spec.bits, T = spec.groupSize;
  if (codes.ndim === 3) {
    const [groups, rows, words] = codes.shape as [number, number, number];
    if (codes.dtype !== Dtype.uint32 || tr.axis !== 0 || k !== 3 || T !== 256 ||
        tr.L !== 12 || tr.code !== "1mad" || words !== 48 || groups < 1 || rows < 1)
      throw new Error("trellis: unsupported interleaved code shape or quantization");
    const cols = groups * 512;
    return { k, L: tr.L, T, axis: 0, rows, cols, inFeatures: rows,
      outFeatures: cols, blockInterleave: 2 };
  }
  if (codes.ndim !== 2) throw new Error("trellis: expected a 2D or interleaved 3D code tensor");
  const [rows, words] = codes.shape as [number, number];
  if ((words * 32) % k !== 0) throw new Error(`trellis: ${words} words not a whole number of ${k}-bit symbols`);
  const cols = (words * 32) / k;
  if (cols % T !== 0) throw new Error(`trellis: ${cols} coded columns not a multiple of block ${T}`);
  wordsPerBlock(T, k);
  return {
    k, L: tr.L, T, axis: tr.axis, rows, cols,
    inFeatures: tr.axis === 1 ? cols : rows,
    outFeatures: tr.axis === 1 ? rows : cols,
  };
}

export type TrellisMode = "kernel" | "expand";

export function trellisModeFromEnv(): TrellisMode {
  const v = runtimeValue("MLX_BUN_TRELLIS");
  if (v === "expand") return "expand";
  return "kernel";
}

/** Can gate and up be served by the fused kernel? Same axis-1 geometry and k,
 *  neither in the expand fallback. */
export function fusedGateUpEligible(gate: TrellisLinear, up: TrellisLinear): boolean {
  const a = gate.geometry, b = up.geometry;
  return !gate.fallback && !up.fallback && a.axis === 1 && b.axis === 1 &&
    a.k === b.k && a.rows === b.rows && a.cols === b.cols && a.T === b.T && a.L === b.L;
}

/** Gate and up share their axis-1 geometry but NOT their bit width: the case a
 *  per-tensor bit allocation creates and the same-k fused kernel refuses.
 *  Geometry only; whether to use it is the owning graph's decision. */
export function mixedGateUpEligible(gate: TrellisLinear, up: TrellisLinear): boolean {
  const a = gate.geometry, b = up.geometry;
  return !gate.fallback && !up.fallback && a.axis === 1 && b.axis === 1 && a.k !== b.k &&
    a.rows === b.rows && a.cols === b.cols && a.T === b.T && a.L === b.L;
}

/** Borrow the layers' weights and preserve the active execution's variant. */
export function fusedGateUpSwiglu(x: MlxArray, gate: TrellisLinear, up: TrellisLinear): MlxArray {
  return gateUpKernel(x, gate, up, variant());
}
export function fusedGateUpSwigluMixed(x: MlxArray, gate: TrellisLinear, up: TrellisLinear, tail: MixedGateUpTail = "fused"): MlxArray {
  return mixedGateUpKernel(x, gate, up, variant(), tail);
}

export class TrellisLinear {
  readonly geometry: TrellisGeometry;
  readonly spec: QuantSpec;
  #expansionCeiling: number | undefined;
  /** `MLX_BUN_TRELLIS=expand`: the load-time 8-bit affine carrier. */
  readonly fallback: QuantizedLinear | null;

  constructor(
    readonly codes: MlxArray,
    readonly scales: MlxArray,
    spec: QuantSpec,
    mode: TrellisMode = trellisModeFromEnv(),
    readonly useSharedScatterCodebook = false,
  ) {
    this.spec = spec;
    this.geometry = trellisGeometry(codes, spec);
    if (this.geometry.blockInterleave && (scales.ndim !== 1 || scales.size !== this.geometry.rows))
      throw new Error("trellis: interleaved codes require one scale per stored row");
    this.fallback = mode === "expand" ? this.#expandToAffine() : null;
  }

  static load(weights: Weights, path: string, config: ModelConfig, useSharedScatterCodebook = false): TrellisLinear {
    const spec = quantFor(config.quantization, path);
    if (!spec || spec.mode !== "trellis")
      throw new Error(`${path}: expected a trellis quant spec`);
    if (!weights.has(`${path}.scales`)) throw new Error(`${path}: trellis tensor has no .scales`);
    return new TrellisLinear(weights.tensor(`${path}.weight`), weights.tensor(`${path}.scales`), spec, undefined, useSharedScatterCodebook);
  }

  static isTrellis(config: ModelConfig, path: string): boolean {
    return quantFor(config.quantization, path)?.mode === "trellis";
  }

  get inFeatures(): number { return this.geometry.inFeatures; }
  get outFeatures(): number { return this.geometry.outFeatures; }

  /** The weight as [out, in] bf16 (decoded; transposed for axis=0). */
  expandWeight(dtype: Dtype = Dtype.bfloat16): MlxArray {
    const g = this.geometry;
    const stored = expandTrellis(this.codes, this.scales, g, dtype, variant());
    if (g.axis === 1) return stored;
    const t = ops.transposeAxes(stored, [1, 0]);
    const w = ops.contiguous(t);
    t.dispose(); stored.dispose();
    return w;
  }

  #expandToAffine(): QuantizedLinear {
    const w = this.expandWeight(Dtype.bfloat16);
    const q = ops.quantize(w, 64, 8, "affine");
    ops.evalAll([q.packed, q.scales, ...(q.biases ? [q.biases] : [])]);
    w.dispose();
    return new QuantizedLinear(q.packed, q.scales, q.biases, { bits: 8, groupSize: 64, mode: "affine" });
  }

  /** A caller may prove row-contiguous, aligned input from an allocating op
   * such as RMSNorm. Lazy array strides cannot establish that before eval. */
  forward(x: MlxArray, inputRowContiguous = false): MlxArray {
    if (this.fallback) return this.fallback.forward(x);
    const g = this.geometry;
    const selected = variant();
    const lead = x.shape.slice(0, -1);
    const M = lead.reduce((a, b) => a * b, 1);
    if (x.shape[x.shape.length - 1] !== g.inFeatures)
      throw new Error(`TrellisLinear: input dim ${x.shape[x.shape.length - 1]} != ${g.inFeatures}`);
    const x2 = ops.reshape(x, [M, g.inFeatures]);
    let y: MlxArray;
    let expandedWeights = false;
    if (M <= MATVEC_MAX_M) y = g.axis === 1 ? trellisReduce(x2, this.codes, this.scales, g, selected) : trellisScatter(x2, this.codes, this.scales, g, selected, this.useSharedScatterCodebook);
    else if (selected >= 11 && selected <= 13 && inputRowContiguous && wideTrellisPrefillEligible(g, M, x.dtype))
      y = wideTrellisPrefill(x2, this.codes, this.scales, g);
    else if (selected >= 11 && selected <= 13 && tiledTrellisPrefillEligible(g, M, x.dtype))
      y = tiledTrellisPrefill(x2, this.codes, this.scales, g);
    else if ((selected === 12 || selected === 13) && splitKTrellisPrefillEligible(g, M, x.dtype))
      y = splitKTrellisPrefill(x2, this.codes, this.scales, g);
    else {
      expandedWeights = true;
      const stored = expandTrellis(this.codes, this.scales, g, x.dtype, selected);
      if (g.axis === 1) {
        const wt = ops.transposeAxes(stored, [1, 0]);
        y = ops.matmul(x2, wt);
        wt.dispose();
      } else y = ops.matmul(x2, stored);
      stored.dispose();
    }
    x2.dispose();
    const out = ops.reshape(y, [...lead, g.outFeatures]);
    y.dispose();
    // Bound dense weight expansions before building the next projection.
    // Disposing `stored` above releases only its JS handle, not the lazy
    // matmul's reference. Direct tiles and packed matvecs stay lazy: they
    // hold activations and bounded partials, without a dense weight matrix.
    // Experimental v9 retains Qwen35Model's layer-end state/output barrier,
    // but permits the three MLP expansions within that layer to overlap.
    // Standalone callers must bound their own live graph. Default v6 and
    // variants 7/8 retain the tighter per-projection memory bound.
    if (expandedWeights && selected !== 9) {
      // Opt-in v13 scheduling keeps the caller's layer barrier and submits
      // early only below the tested working-set ceiling. This is a scheduling
      // threshold, not a cap on total allocation. Read policy from the current
      // execution snapshot; cache only the device's fixed hardware budget.
      if (selected === 13 && runtimeFlag("MLX_BUN_TRELLIS_ASYNC_EXPAND", false) &&
          activeMemory() < (this.#expansionCeiling ??= 0.75 * maxRecommendedWorkingSetSize())) {
        ops.asyncEvalAll([out]);
      } else out.eval();
    }
    return out;
  }

}
