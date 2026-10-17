import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.TrellisLinear
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/trellis-linear.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor, type ModelConfig, type QuantSpec } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import { LoraDelta, type LoraState, type LoraWeights } from "./lora";
import { QuantizedLinear } from "./quantized-linear";
import { wordsPerBlock } from "../kernels/trellis/codebook";
import {
  TRELLIS_MATVEC_MAX_M as MATVEC_MAX_M, type TrellisGeometry,
  expandTrellis, trellisReduce, trellisScatter, fusedGateUpSwiglu as gateUpKernel,
  tiledTrellisPrefill, tiledTrellisPrefillEligible,
  splitKTrellisPrefill, splitKTrellisPrefillEligible,
  wideTrellisPrefill, wideTrellisPrefillEligible,
  qualifiedRepresentations, type TrellisRepresentations,
} from "../kernels/trellis/index";
export { TRELLIS_MATVEC_MAX_M, type TrellisGeometry, type MixedGateUpTail } from "../kernels/trellis/index";

/** The decode variant these layers pass the kernels (semantics in
 *  kernels/trellis/index.ts): 13, which passed the M4 Pro closeout matrix.
 *  Benches and tests that compare variants call the kernels directly. */
const VARIANT = 13;

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

/** Can gate and up be served by the fused kernel? Same axis-1 geometry and k. */
export function fusedGateUpEligible(gate: TrellisLinear, up: TrellisLinear): boolean {
  const a = gate.geometry, b = up.geometry;
  return a.axis === 1 && b.axis === 1 &&
    a.k === b.k && a.rows === b.rows && a.cols === b.cols && a.T === b.T && a.L === b.L;
}

/** Borrow the layers' weights; the gate's stored representations choose the decode. */
export function fusedGateUpSwiglu(x: MlxArray, gate: TrellisLinear, up: TrellisLinear): MlxArray {
  return gateUpKernel(x, gate, up, VARIANT, gate.representations.gateUpCodebook);
}

/** Output rows [start, stop) of an axis-1 (row-coded) Trellis projection as an
 *  owned projection: each output row has its own code row and scale, so the
 *  slice decodes exactly the same values. A leading-axis range of row-major
 *  codes is already row-contiguous, so these are views of the parent's memory. */
export function trellisRows(lin: TrellisLinear, start: number, stop: number): TrellisLinear {
  const g = lin.geometry;
  if (g.axis !== 1 || g.blockInterleave || lin.codes.ndim !== 2) throw new Error("trellisRows: needs row-coded (axis 1) codes");
  const codes = lin.codes.slice([start, 0], [stop, lin.codes.shape[1]!]);
  const scales = lin.scales.slice([start], [stop]);
  ops.evalAll([codes, scales]);
  return new TrellisLinear(codes, scales, lin.spec, false, lin.representations);
}

/** Stored rows [start, stop) of an axis-0 Trellis projection (input features of
 *  a down projection): 2D codes slice to a view; block-interleaved 3D codes
 *  [groups, rows, words] slice their middle axis (kernels copy that view). */
export function trellisStoredRows(lin: TrellisLinear, start: number, stop: number): TrellisLinear {
  const g = lin.geometry;
  if (g.axis !== 0) throw new Error("trellisStoredRows: needs axis-0 codes");
  const codes = lin.codes.ndim === 3
    ? lin.codes.slice([0, start, 0], [lin.codes.shape[0]!, stop, lin.codes.shape[2]!])
    : lin.codes.slice([start, 0], [stop, lin.codes.shape[1]!]);
  const scales = lin.scales.slice([start], [stop]);
  ops.evalAll([codes, scales]);
  return new TrellisLinear(codes, scales, lin.spec, false, lin.representations);
}

export class TrellisLinear {
  readonly delta: LoraDelta;
  get adapters(): Map<string, LoraWeights> | null { return this.delta.adapters; }
  set adapters(value: Map<string, LoraWeights> | null) { this.delta.adapters = value; }
  get loraState(): LoraState | null { return this.delta.loraState; }
  set loraState(value: LoraState | null) { this.delta.loraState = value; }
  get dropoutId(): number { return this.delta.dropoutId; }
  set dropoutId(value: number) { this.delta.dropoutId = value; }
  readonly geometry: TrellisGeometry;
  readonly spec: QuantSpec;
  /** The decode variant every kernel over these weights runs (kernels/trellis/index.ts): the row-form layers
   *  built on this projection take it at their construction. */
  readonly variant = VARIANT;
  /** What the kernels take from this machine's GPU family (single-row
   *  representations, wide prefill), fixed here and passed on every call. */
  readonly representations: TrellisRepresentations;

  constructor(
    readonly codes: MlxArray,
    readonly scales: MlxArray,
    spec: QuantSpec,
    readonly useSharedScatterCodebook = false,
    representations: TrellisRepresentations = qualifiedRepresentations(deviceArchitecture()),
  ) {
    this.spec = spec;
    this.geometry = trellisGeometry(codes, spec);
    this.delta = new LoraDelta(this.geometry.inFeatures, this.geometry.outFeatures);
    if (this.geometry.blockInterleave && (scales.ndim !== 1 || scales.size !== this.geometry.rows))
      throw new Error("trellis: interleaved codes require one scale per stored row");
    this.representations = representations;
  }

  static load(weights: Weights, path: string, config: ModelConfig, useSharedScatterCodebook = false, representations?: TrellisRepresentations): TrellisLinear {
    const spec = quantFor(config.quantization, path);
    if (!spec || spec.mode !== "trellis")
      throw new Error(`${path}: expected a trellis quant spec`);
    if (!weights.has(`${path}.scales`)) throw new Error(`${path}: trellis tensor has no .scales`);
    return new TrellisLinear(weights.tensor(`${path}.weight`), weights.tensor(`${path}.scales`), spec, useSharedScatterCodebook, representations);
  }

  static isTrellis(config: ModelConfig, path: string): boolean {
    return quantFor(config.quantization, path)?.mode === "trellis";
  }

  get inFeatures(): number { return this.geometry.inFeatures; }
  get outFeatures(): number { return this.geometry.outFeatures; }

  /** The weight as [out, in] bf16 (decoded; transposed for axis=0). */
  expandWeight(dtype: Dtype = Dtype.bfloat16): MlxArray {
    const g = this.geometry;
    const stored = expandTrellis(this.codes, this.scales, g, dtype, VARIANT);
    if (g.axis === 1) return stored;
    const t = ops.transposeAxes(stored, [1, 0]);
    const w = ops.contiguous(t);
    t.dispose(); stored.dispose();
    return w;
  }

  /** A caller may prove row-contiguous, aligned input from an allocating op
   * such as RMSNorm. Lazy array strides cannot establish that before eval.
   * Rows past the tiled kernels expand the dense weight and multiply; that
   * product is evaluated before returning, so building the next projection
   * never holds a second expansion, unless `boundExpansion` is false: a caller
   * that queues several projections at once (the Neural Engine split's GPU
   * share) holds their expansions until it evaluates them. */
  forward(x: MlxArray, inputRowContiguous = false, boundExpansion = true): MlxArray {
    const g = this.geometry;
    const lead = x.shape.slice(0, -1);
    const M = lead.reduce((a, b) => a * b, 1);
    if (x.shape[x.shape.length - 1] !== g.inFeatures)
      throw new Error(`TrellisLinear: input dim ${x.shape[x.shape.length - 1]} != ${g.inFeatures}`);
    const x2 = ops.reshape(x, [M, g.inFeatures]);
    let y: MlxArray;
    let expandedWeights = false;
    if (M <= MATVEC_MAX_M) y = g.axis === 1 ? trellisReduce(x2, this.codes, this.scales, g, VARIANT) : trellisScatter(x2, this.codes, this.scales, g, VARIANT, this.useSharedScatterCodebook, this.representations.scatter);
    else if (inputRowContiguous && wideTrellisPrefillEligible(g, M, x.dtype, this.representations.widePrefill))
      y = wideTrellisPrefill(x2, this.codes, this.scales, g);
    else if (tiledTrellisPrefillEligible(g, M, x.dtype, this.representations.widePrefill))
      y = tiledTrellisPrefill(x2, this.codes, this.scales, g);
    else if (splitKTrellisPrefillEligible(g, M, x.dtype))
      y = splitKTrellisPrefill(x2, this.codes, this.scales, g);
    else {
      expandedWeights = true;
      const stored = expandTrellis(this.codes, this.scales, g, x.dtype, VARIANT);
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
    if (expandedWeights && boundExpansion) out.eval();
    return this.delta.forward(x, out);
  }
}

/** Packed Trellis weights decoded once, at construction, into 8-bit g64 affine
 *  and served through the stock QuantizedLinear (the eval-carrier numerics,
 *  about -45 dB against the packed kernels): for a machine where the packed
 *  kernels lose. Built explicitly by whoever selects it; holds no packed codes. */
export class ExpandedTrellisLinear {
  readonly carrier: QuantizedLinear;

  constructor(packed: TrellisLinear) {
    const w = packed.expandWeight(Dtype.bfloat16);
    const q = ops.quantize(w, 64, 8, "affine");
    ops.evalAll([q.packed, q.scales, ...(q.biases ? [q.biases] : [])]);
    w.dispose();
    this.carrier = new QuantizedLinear(q.packed, q.scales, q.biases, { bits: 8, groupSize: 64, mode: "affine" });
  }

  get inFeatures(): number { return this.carrier.inFeatures; }
  get outFeatures(): number { return this.carrier.outFeatures; }

  forward(x: MlxArray): MlxArray { return this.carrier.forward(x); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.TrellisLinear
