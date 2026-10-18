import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.AnePrefillSplit
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/ane-prefill-split.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { AneProgram, AneStreamedMatmul, mlpSliceProgram, streamedMatmulProgram, type AneProgramSpec } from "../kernels/ane/linear";
import { trellisFillHalf, trellisFillHalfK3Interleaved, writeHalf } from "../kernels/ane/fill";
import type { TrellisGeometry } from "../kernels/trellis/geometry";
import { expandTrellis } from "../kernels/trellis/index";
import { QuantizedLinear, QuantizedLinearPlain } from "./quantized-linear";
import { TrellisLinear, trellisRows, trellisStoredRows } from "./trellis-linear";

// Prompt-piece channel splits between the Apple Neural Engine and the GPU. The
// ANE computes the first n output channels from streamed fp16 weights the GPU
// writes into its program's buffers (zero-copy IOSurface wraps, made once per
// set of buffers), the GPU computes the rest at the same time, and the results
// combine. Each layer holds one program, built for the row count the layer is
// constructed with, and serves inputs of up to that many rows: it writes the
// rows it is given at the front of the program's input and reads as many back.
// The rows behind them hold whatever the last evaluation left; no row it returns
// reads them (each output row of the program depends only on its own input row).
// dispose releases the program. Layers that never run at once may share, named
// at construction (`share`): a layer whose program is identical to the other's
// holds that same loaded program, otherwise its program loads on the other's
// buffers (each at least as large); either lives until every layer holding it is
// disposed. Loaded programs are a machine-wide resource (AneProgram), so a
// graph's layers of one shape share one. Not bit-identical to the GPU path (fp16
// weights and activations on the ANE); gate by KL.
//
// A layer's program depends only on its widths, the fraction, its row count and
// its matmuls' reduction slices, never on the weights it streams, so the program
// each split loads is named here as a function of those (`aneMlpSplitProgram`,
// `aneAffineSplitProgram`): the install step compiles exactly what `build`
// loads.

/** Channels the ANE takes of R rows at `fraction` (64-aligned, at least 64 left on each side). */
export function aneChannels(R: number, fraction: number): number {
  return Math.min(R - 64, Math.max(64, Math.round((fraction * R) / 64) * 64));
}

/** The program either whole-MLP split of hidden width D and intermediate width R
 *  loads at `fraction` for pieces of up to `rows` rows, its matmuls' reductions
 *  in `slices` slices (mlpSliceProgram's default when absent). */
export function aneMlpSplitProgram(D: number, R: number, fraction: number, rows: number, slices?: number): AneProgramSpec {
  return mlpSliceProgram(D, aneChannels(R, fraction), rows, slices);
}

/** The program an affine projection split of K inputs and N outputs loads at
 *  `fraction` for pieces of up to `rows` rows, its reduction in `slices` slices
 *  (streamedMatmulProgram's default when absent). */
export function aneAffineSplitProgram(K: number, N: number, fraction: number, rows: number, slices?: number): AneProgramSpec {
  return streamedMatmulProgram(K, aneChannels(N, fraction), rows, slices);
}

type Fill = (codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number) => MlxArray;
type Swiglu = (g: MlxArray, u: MlxArray) => MlxArray;
type Rest = { gate: TrellisLinear; up: TrellisLinear; down: TrellisLinear };

/** Dense axis-1 expansion queued with the ANE's GPU share, without an
 * intermediate evaluation that would serialize gate, up and down. */
export class AneTrellisExpandReduce {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
    using input = ops.reshape(x, [M, this.linear.inFeatures]);
    using stored = expandTrellis(this.linear.codes, this.linear.scales, this.linear.geometry, x.dtype, this.linear.variant);
    using transposed = ops.transposeAxes(stored, [1, 0]);
    using product = ops.matmul(input, transposed);
    return this.linear.delta.forward(x, ops.reshape(product, [...lead, this.linear.outFeatures]));
  }
}
/** Dense axis-0 expansion with the same submission boundary. */
export class AneTrellisExpandScatter {
  constructor(readonly linear: TrellisLinear) {}
  forward(x: MlxArray): MlxArray {
    const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
    using input = ops.reshape(x, [M, this.linear.inFeatures]);
    using stored = expandTrellis(this.linear.codes, this.linear.scales, this.linear.geometry, x.dtype, this.linear.variant);
    using product = ops.matmul(input, stored);
    return this.linear.delta.forward(x, ops.reshape(product, [...lead, this.linear.outFeatures]));
  }
}
type GpuRest = { gate: { forward(x: MlxArray): MlxArray }; up: { forward(x: MlxArray): MlxArray }; down: { forward(x: MlxArray): MlxArray } };
/** The GPU projections attached to the split's stored row slices. */
export type AneGpuMlpRows = (rest: Rest) => GpuRest;
const expandedGpuRows: AneGpuMlpRows = rest => ({ gate: new AneTrellisExpandReduce(rest.gate),
  up: new AneTrellisExpandReduce(rest.up), down: new AneTrellisExpandScatter(rest.down) });

// The public builder also supports standalone small inputs. Its compatibility
// projections preserve their original row-dependent kernels; written graph
// bindings use the fixed expanded builders below.
const legacyGpuRows: AneGpuMlpRows = rest => ({
  gate: { forward: x => rest.gate.forward(x, true, false) },
  up: { forward: x => rest.up.forward(x, true, false) },
  down: { forward: x => rest.down.forward(x, true, false) },
});

/** Whole Trellis MLP: the ANE computes the first n intermediate channels end
 *  to end (gate and up rows, SwiGLU, and the down projection's partial sum over
 *  those channels); the GPU computes channels [n, R) through its attached projections; the
 *  two [M, D] partials add. Measured on M4 Pro: one fused slice program at
 *  10.2 TFLOPS (D 5120, n 9600, S 2048). `hidden` holds M <= `rows` rows.
 *  The ANE starts as soon as the GPU has filled its buffers; the GPU's share is
 *  then queued whole (its weight expansions unbounded, one submission) while
 *  the host waits for the ANE. The sum is returned unevaluated: it reads the
 *  ANE output, which the program evaluates before its buffers' next run
 *  (`AneProgram.deferOutput`), unless the caller has by then. */
function mlpSplit(program: AneProgram, rows: number, n: number, gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear,
  rest: GpuRest, fillDown: Fill, hidden: MlxArray, swiglu: Swiglu): MlxArray {
  const D = gate.geometry.inFeatures;
  const lead = hidden.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
  if (M > rows) throw new Error(`ANE MLP split: ${M} rows exceed its program's ${rows}`);
  {
    // Inputs in symbol order: wd, wg, wu, x (borrowed wraps).
    const wd = program.inputArray(0), wg = program.inputArray(1), wu = program.inputArray(2), x = program.inputArray(3);
    using h2 = ops.reshape(hidden, [M * D]);
    using d0 = fillDown(down.codes, down.scales, down.geometry, n, wd, 0);
    using d1 = trellisFillHalf(gate.codes, gate.scales, gate.geometry, n, wg, 0);
    using d2 = trellisFillHalf(up.codes, up.scales, up.geometry, n, wu, 0);
    using d3 = writeHalf(x, h2, 0);
    ops.evalAll([d0, d1, d2, d3]);
  }
  program.evalAsync();
  let gpuOut: MlxArray;
  try {
    using g = rest.gate.forward(hidden);
    using u = rest.up.forward(hidden);
    using mid = swiglu(g, u);
    gpuOut = rest.down.forward(mid);
    ops.asyncEvalAll([gpuOut]);
  } finally { program.wait(); }
  try {
    using used = program.output([M, D]);                    // zero-copy partial, the piece's rows
    using b = used.astype(hidden.dtype);
    using g2 = ops.reshape(gpuOut, [M, D]);
    const sum = ops.add(b, g2);
    program.deferOutput(sum);                               // evaluated (free once the result is) and freed by the program
    return ops.reshape(sum, [...lead, D]);
  } finally { gpuOut.dispose(); }
}

function checkMlp(name: string, gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, interleavedDown: boolean): void {
  const g = gate.geometry, d = down.geometry, rowMajor = (x: TrellisGeometry) => !x.blockInterleave && x.L === 12 && x.T === 256;
  if (g.axis !== 1 || up.geometry.axis !== 1 || !rowMajor(g) || !rowMajor(up.geometry) || d.axis !== 0 ||
      d.rows !== g.rows || d.cols !== g.inFeatures || interleavedDown !== (d.blockInterleave === 2) ||
      (interleavedDown ? d.k !== 3 : !rowMajor(d)))
    throw new Error(`${name}: unsupported MLP geometry`);
}
function disposeLinear(lin: TrellisLinear): void { lin.codes.dispose(); lin.scales.dispose(); }

/** Either whole-MLP split; both build the same slice program (only the GPU
 *  fill differs), so either can share the other's program. */
export type AneMlpSplit = AneTrellisMlpSplit | AneTrellisMlpSplitK3i;

/** Whole-MLP split for a down projection with row-major codes. */
export class AneTrellisMlpSplit implements Disposable {
  private constructor(readonly program: AneProgram, readonly rows: number, readonly channels: number, readonly gate: TrellisLinear,
    readonly up: TrellisLinear, readonly down: TrellisLinear, readonly rest: Rest, readonly gpu: GpuRest) {}

  /** Loads `aneMlpSplitProgram(D, R, fraction, rows, slices)` for pieces of up
   *  to `rows` rows now, from the compile cache the install step filled (a
   *  program not compiled on this Mac throws `AneBridgeError`). `share`: a split
   *  that never runs at the same time as this one; this split holds its program
   *  when the two are identical, otherwise loads one on its buffers (each at
   *  least as large). */
  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, rows: number,
    share?: AneMlpSplit, slices?: number, gpuRows: AneGpuMlpRows = legacyGpuRows): AneTrellisMlpSplit {
    checkMlp("AneTrellisMlpSplit", gate, up, down, false);
    const R = gate.geometry.rows, n = aneChannels(R, fraction);
    const program = AneProgram.create(aneMlpSplitProgram(gate.geometry.inFeatures, R, fraction, rows, slices), share?.program);
    const rest = { gate: trellisRows(gate, n, R), up: trellisRows(up, n, R), down: trellisStoredRows(down, n, R) };
    return new AneTrellisMlpSplit(program, rows, n, gate, up, down, rest, gpuRows(rest));
  }
  /** hidden [.., M, D], M <= rows → MLP(hidden) [.., M, D], unevaluated (mlpSplit). */
  forward(hidden: MlxArray, swiglu: Swiglu): MlxArray {
    return mlpSplit(this.program, this.rows, this.channels, this.gate, this.up, this.down, this.gpu, trellisFillHalf, hidden, swiglu);
  }
  [Symbol.dispose](): void { this.dispose(); }
  /** Releases this layer's program and frees its GPU rows; a shared program or buffers outlive it while another layer holds them. */
  dispose(): void { this.program.dispose(); for (const lin of Object.values(this.rest)) disposeLinear(lin); }
}

/** Whole-MLP split for a 3-bit block-interleaved down projection. */
export class AneTrellisMlpSplitK3i implements Disposable {
  private constructor(readonly program: AneProgram, readonly rows: number, readonly channels: number, readonly gate: TrellisLinear,
    readonly up: TrellisLinear, readonly down: TrellisLinear, readonly rest: Rest, readonly gpu: GpuRest) {}

  /** As AneTrellisMlpSplit.build. */
  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, rows: number,
    share?: AneMlpSplit, slices?: number, gpuRows: AneGpuMlpRows = legacyGpuRows): AneTrellisMlpSplitK3i {
    checkMlp("AneTrellisMlpSplitK3i", gate, up, down, true);
    const R = gate.geometry.rows, n = aneChannels(R, fraction);
    const program = AneProgram.create(aneMlpSplitProgram(gate.geometry.inFeatures, R, fraction, rows, slices), share?.program);
    const rest = { gate: trellisRows(gate, n, R), up: trellisRows(up, n, R), down: trellisStoredRows(down, n, R) };
    return new AneTrellisMlpSplitK3i(program, rows, n, gate, up, down, rest, gpuRows(rest));
  }
  /** hidden [.., M, D], M <= rows → MLP(hidden) [.., M, D], unevaluated (mlpSplit). */
  forward(hidden: MlxArray, swiglu: Swiglu): MlxArray {
    return mlpSplit(this.program, this.rows, this.channels, this.gate, this.up, this.down, this.gpu, trellisFillHalfK3Interleaved,
      hidden, swiglu);
  }
  [Symbol.dispose](): void { this.dispose(); }
  /** As AneTrellisMlpSplit.dispose. */
  dispose(): void { this.program.dispose(); for (const lin of Object.values(this.rest)) disposeLinear(lin); }
}

/** Fixed dense GPU share for written row-major ANE graph bindings. */
export class AneTrellisExpandedMlpSplit {
  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, rows: number,
    share?: AneMlpSplit, slices?: number): AneTrellisMlpSplit {
    return AneTrellisMlpSplit.build(gate, up, down, fraction, rows, share, slices, expandedGpuRows);
  }
}
/** Fixed dense GPU share for written block-interleaved ANE graph bindings. */
export class AneTrellisExpandedMlpSplitK3i {
  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, rows: number,
    share?: AneMlpSplit, slices?: number): AneTrellisMlpSplitK3i {
    return AneTrellisMlpSplitK3i.build(gate, up, down, fraction, rows, share, slices, expandedGpuRows);
  }
}

/** The layer that computes an affine split's GPU rows from the projection's
 *  remaining rows (default: QuantizedLinearPlain). */
export type AneGpuRows = (rest: QuantizedLinear) => { forward(x: MlxArray): MlxArray };

/** Affine projection split: the first n output rows of an MLX affine
 *  projection run on the ANE from fp16 rows the GPU dequantizes straight into
 *  the streamed program's weight buffer; the GPU computes the remaining rows;
 *  outputs concatenate in row order. */
export class AneAffineSplit implements Disposable {
  private constructor(readonly program: AneStreamedMatmul, readonly head: { w: MlxArray; scales: MlxArray; biases: MlxArray },
    readonly rest: QuantizedLinear, readonly gpu: { forward(x: MlxArray): MlxArray }, readonly spec: ops.QuantSpec,
    readonly linear: QuantizedLinear) {}

  /** Loads `aneAffineSplitProgram(K, N, fraction, rows, slices)` for pieces of
   *  up to `rows` rows now, as AneTrellisMlpSplit.build loads its program.
   *  `share`: as AneTrellisMlpSplit.build. `gpuRows`: the layer over the GPU's
   *  rows. */
  static build(lin: QuantizedLinear, fraction: number, rows: number, share?: AneAffineSplit, slices?: number,
    gpuRows?: AneGpuRows): AneAffineSplit {
    const N = lin.outFeatures, K = lin.inFeatures;
    if (!lin.biases || lin.bias || lin.w.ndim !== 2 || lin.spec.mode !== "affine") throw new Error("AneAffineSplit: unsupported projection");
    const n = aneChannels(N, fraction);
    const program = AneStreamedMatmul.create(K, n, rows, share?.program, slices);
    const rowsOf = (a: MlxArray, start: number, stop: number) => a.slice([start, 0], [stop, a.shape[1]!]);
    const head = { w: rowsOf(lin.w, 0, n), scales: rowsOf(lin.scales, 0, n), biases: rowsOf(lin.biases, 0, n) };
    const rest = new QuantizedLinear(rowsOf(lin.w, n, N), rowsOf(lin.scales, n, N), rowsOf(lin.biases, n, N), lin.spec);
    return new AneAffineSplit(program, head, rest, gpuRows ? gpuRows(rest) : new QuantizedLinearPlain(rest), lin.spec, lin);
  }

  /** x [.., M, K], M <= rows → [.., M, N], unevaluated as the MLP split's
   *  (mlpSplit): the ANE starts once its buffers are written, the GPU's rows
   *  queued after. */
  forward(x: MlxArray): MlxArray {
    const ane = this.program, K = ane.cin, n = ane.cout, rows = ane.seq;
    const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
    if (M > rows) throw new Error(`AneAffineSplit: ${M} rows exceed its program's ${rows}`);
    {
      using dense = ops.dequantize(this.head.w, this.head.scales, this.head.biases, this.spec);
      using flat = ops.reshape(dense, [n * K]);
      using x2 = ops.reshape(x, [M * K]);
      using d0 = writeHalf(ane.weights(), flat, 0);
      using d1 = writeHalf(ane.input(), x2, 0);
      ops.evalAll([d0, d1]);
    }
    ane.evalAsync();
    let gpu: MlxArray;
    try { gpu = this.gpu.forward(x); ops.asyncEvalAll([gpu]); }
    finally { ane.wait(); }
    try {
      using used = ane.output(M);                             // the piece's rows of [rows, n] fp16
      using b = used.astype(x.dtype);
      using g2 = ops.reshape(gpu, [M, this.rest.outFeatures]);
      const both = ops.concatAxis([b, g2], -1);
      ane.program.deferOutput(both);                          // evaluated (free once the result is) and freed by the program
      return this.linear.delta.forward(x, ops.reshape(both, [...lead, n + this.rest.outFeatures]));
    } finally { gpu.dispose(); }
  }

  [Symbol.dispose](): void { this.dispose(); }
  /** Releases this layer's program and frees its weight rows; a shared program or buffers outlive it while another layer holds them. */
  dispose(): void {
    this.program.dispose();
    for (const a of [this.head.w, this.head.scales, this.head.biases, this.rest.w, this.rest.scales, this.rest.biases!]) a.dispose();
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.AnePrefillSplit
