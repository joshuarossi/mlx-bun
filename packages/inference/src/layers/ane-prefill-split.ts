import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { AneProgram, AneStreamedMatmul, mlpSliceMil } from "../kernels/ane/linear";
import { trellisFillHalf, trellisFillHalfK3Interleaved, writeHalf } from "../kernels/ane/fill";
import type { TrellisGeometry } from "../kernels/trellis/geometry";
import { QuantizedLinear } from "./quantized-linear";
import { TrellisLinear, trellisRows, trellisStoredRows } from "./trellis-linear";

/** Whether the Apple Neural Engine bridge loaded (graphs build ANE layers only then). */
export { aneAvailable } from "../kernels/ane/linear";

// Prompt-chunk channel splits between the Apple Neural Engine and the GPU.
// The ANE computes the first n output channels from streamed fp16 weights the
// GPU writes into its program's buffers (zero-copy IOSurface wraps), the GPU
// computes the rest at the same time, and the results combine. Each layer owns
// one program, built for exactly the chunk size the layer is constructed with,
// and serves inputs of exactly that many rows; dispose frees the program.
// Layers that never run at once may share buffers, named at construction
// (`share`): the new program reuses the other's IOSurfaces, which live until
// every program holding them is freed. Not bit-identical to the GPU path (fp16
// weights and activations on the ANE); gate by KL.

/** Channels the ANE takes of R rows at `fraction` (64-aligned, at least 64 left on each side). */
export function aneChannels(R: number, fraction: number): number {
  return Math.min(R - 64, Math.max(64, Math.round((fraction * R) / 64) * 64));
}

/** Whole-MLP slice program [D, n] over `rows` rows, on `share`'s buffers when given. */
function mlpProgram(D: number, n: number, rows: number, share: AneProgram | undefined): AneProgram {
  return AneProgram.create(mlpSliceMil(D, n, rows), [n * D * 2, n * D * 2, n * D * 2, rows * D * 2], rows * D * 2, { share });
}

type Fill = (codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number) => MlxArray;
type Swiglu = (g: MlxArray, u: MlxArray) => MlxArray;
type Rest = { gate: TrellisLinear; up: TrellisLinear; down: TrellisLinear };

/** Whole Trellis MLP: the ANE computes the first n intermediate channels end
 *  to end (gate and up rows, SwiGLU, and the down projection's partial sum over
 *  those channels); the GPU computes channels [n, R) through TrellisLinear; the
 *  two [rows, D] partials add. Measured on M4 Pro: one fused slice program at
 *  10.2 TFLOPS (D 5120, n 9600, S 2048). */
function mlpSplit(program: AneProgram, rows: number, n: number, gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear,
  rest: Rest, fillDown: Fill, hidden: MlxArray, swiglu: Swiglu): MlxArray {
  const D = gate.geometry.inFeatures;
  const lead = hidden.shape.slice(0, -1);
  {
    // Inputs in symbol order: wd, wg, wu, x. Filled before any GPU share is
    // queued, so the ANE starts at once.
    using wd = program.inputArray(0, [n * D], Dtype.float16);
    using wg = program.inputArray(1, [n * D], Dtype.float16);
    using wu = program.inputArray(2, [n * D], Dtype.float16);
    using x = program.inputArray(3, [rows * D], Dtype.float16);
    using h2 = ops.reshape(hidden, [rows * D]);
    using d0 = fillDown(down.codes, down.scales, down.geometry, n, wd, 0);
    using d1 = trellisFillHalf(gate.codes, gate.scales, gate.geometry, n, wg, 0);
    using d2 = trellisFillHalf(up.codes, up.scales, up.geometry, n, wu, 0);
    using d3 = writeHalf(x, h2, 0);
    ops.evalAll([d0, d1, d2, d3]);
  }
  program.evalAsync();
  let gpuOut: MlxArray;
  try {
    using g = rest.gate.forward(hidden, true);
    using u = rest.up.forward(hidden, true);
    using mid = swiglu(g, u);
    gpuOut = rest.down.forward(mid, true);
    gpuOut.eval();
  } finally { program.wait(); }
  try {
    using out = program.output([rows, D], Dtype.float16);  // zero-copy partial [rows, D]
    using b = out.astype(hidden.dtype);
    using g2 = ops.reshape(gpuOut, [rows, D]);
    using sum = ops.add(b, g2);
    const result = ops.reshape(sum, [...lead, D]);
    result.eval();                                          // consume the ANE output before a program sharing it runs
    return result;
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
 *  fill differs), so either can lend its buffers to the other. */
export type AneMlpSplit = AneTrellisMlpSplit | AneTrellisMlpSplitK3i;

/** Whole-MLP split for a down projection with row-major codes. */
export class AneTrellisMlpSplit implements Disposable {
  private constructor(readonly program: AneProgram, readonly rows: number, readonly channels: number, readonly gate: TrellisLinear,
    readonly up: TrellisLinear, readonly down: TrellisLinear, readonly rest: Rest) {}

  /** Builds the program for chunks of exactly `rows` rows now. `share`: a
   *  split that never runs at the same time as this one, whose buffers this
   *  program reuses (each at least as large). */
  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, rows: number,
    share?: AneMlpSplit): AneTrellisMlpSplit {
    checkMlp("AneTrellisMlpSplit", gate, up, down, false);
    const R = gate.geometry.rows, n = aneChannels(R, fraction);
    const program = mlpProgram(gate.geometry.inFeatures, n, rows, share?.program);
    return new AneTrellisMlpSplit(program, rows, n, gate, up, down,
      { gate: trellisRows(gate, n, R), up: trellisRows(up, n, R), down: trellisStoredRows(down, n, R) });
  }
  /** hidden [.., rows, D] → MLP(hidden) [.., rows, D]. */
  forward(hidden: MlxArray, swiglu: Swiglu): MlxArray {
    return mlpSplit(this.program, this.rows, this.channels, this.gate, this.up, this.down, this.rest, trellisFillHalf, hidden, swiglu);
  }
  [Symbol.dispose](): void { this.dispose(); }
  /** Frees this layer's program and its GPU rows; shared buffers outlive it while another program holds them. */
  dispose(): void { this.program.dispose(); for (const lin of Object.values(this.rest)) disposeLinear(lin); }
}

/** Whole-MLP split for a 3-bit block-interleaved down projection. */
export class AneTrellisMlpSplitK3i implements Disposable {
  private constructor(readonly program: AneProgram, readonly rows: number, readonly channels: number, readonly gate: TrellisLinear,
    readonly up: TrellisLinear, readonly down: TrellisLinear, readonly rest: Rest) {}

  /** As AneTrellisMlpSplit.build. */
  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, rows: number,
    share?: AneMlpSplit): AneTrellisMlpSplitK3i {
    checkMlp("AneTrellisMlpSplitK3i", gate, up, down, true);
    const R = gate.geometry.rows, n = aneChannels(R, fraction);
    const program = mlpProgram(gate.geometry.inFeatures, n, rows, share?.program);
    return new AneTrellisMlpSplitK3i(program, rows, n, gate, up, down,
      { gate: trellisRows(gate, n, R), up: trellisRows(up, n, R), down: trellisStoredRows(down, n, R) });
  }
  /** hidden [.., rows, D] → MLP(hidden) [.., rows, D]. */
  forward(hidden: MlxArray, swiglu: Swiglu): MlxArray {
    return mlpSplit(this.program, this.rows, this.channels, this.gate, this.up, this.down, this.rest, trellisFillHalfK3Interleaved,
      hidden, swiglu);
  }
  [Symbol.dispose](): void { this.dispose(); }
  /** As AneTrellisMlpSplit.dispose. */
  dispose(): void { this.program.dispose(); for (const lin of Object.values(this.rest)) disposeLinear(lin); }
}

/** Affine projection split: the first n output rows of an MLX affine
 *  projection run on the ANE from fp16 rows the GPU dequantizes straight into
 *  the streamed program's weight buffer; the GPU computes the remaining rows;
 *  outputs concatenate in row order. */
export class AneAffineSplit implements Disposable {
  private constructor(readonly program: AneStreamedMatmul, readonly head: { w: MlxArray; scales: MlxArray; biases: MlxArray },
    readonly rest: QuantizedLinear, readonly spec: ops.QuantSpec) {}

  /** Builds the program for chunks of exactly `rows` rows now. `share`: a
   *  split that never runs at the same time as this one, whose buffers this
   *  program reuses (each at least as large). */
  static build(lin: QuantizedLinear, fraction: number, rows: number, share?: AneAffineSplit): AneAffineSplit {
    const N = lin.outFeatures, K = lin.inFeatures;
    if (!lin.biases || lin.bias || lin.w.ndim !== 2 || lin.spec.mode !== "affine") throw new Error("AneAffineSplit: unsupported projection");
    const n = aneChannels(N, fraction);
    const program = AneStreamedMatmul.create(K, n, rows, share?.program);
    const rowsOf = (a: MlxArray, start: number, stop: number) => a.slice([start, 0], [stop, a.shape[1]!]);
    const head = { w: rowsOf(lin.w, 0, n), scales: rowsOf(lin.scales, 0, n), biases: rowsOf(lin.biases, 0, n) };
    const rest = new QuantizedLinear(rowsOf(lin.w, n, N), rowsOf(lin.scales, n, N), rowsOf(lin.biases, n, N), lin.spec);
    return new AneAffineSplit(program, head, rest, lin.spec);
  }

  /** x [.., rows, K] → [.., rows, N]. */
  forward(x: MlxArray): MlxArray {
    const ane = this.program, K = ane.cin, n = ane.cout, rows = ane.seq;
    const lead = x.shape.slice(0, -1);
    ane.prepare();
    {
      using w = MlxArray.fromPointer(ane.weightsPointer, [n * K], Dtype.float16);
      using xs = MlxArray.fromPointer(ane.inputPointer, [rows * K], Dtype.float16);
      using dense = ops.dequantize(this.head.w, this.head.scales, this.head.biases, this.spec);
      using flat = ops.reshape(dense, [n * K]);
      using x2 = ops.reshape(x, [rows * K]);
      using d0 = writeHalf(w, flat, 0);
      using d1 = writeHalf(xs, x2, 0);
      ops.evalAll([d0, d1]);
    }
    ane.evalAsync();
    let gpu: MlxArray;
    try { gpu = this.rest.forward(x); gpu.eval(); }
    finally { ane.wait(); }
    try {
      using out = ane.output();                               // [rows, n] fp16
      using b = out.astype(x.dtype);
      using g2 = ops.reshape(gpu, [rows, this.rest.outFeatures]);
      using both = ops.concatAxis([b, g2], -1);
      const result = ops.reshape(both, [...lead, n + this.rest.outFeatures]);
      result.eval();
      return result;
    } finally { gpu.dispose(); }
  }

  [Symbol.dispose](): void { this.dispose(); }
  /** Frees this layer's program and its weight rows; shared buffers outlive it while another program holds them. */
  dispose(): void {
    this.program.dispose();
    for (const a of [this.head.w, this.head.scales, this.head.biases, this.rest.w, this.rest.scales, this.rest.biases!]) a.dispose();
  }
}
