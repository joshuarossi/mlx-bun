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
// computes the rest at the same time, and the results combine. Programs have a
// fixed sequence length; a chunk runs the smallest 512-row bucket that fits,
// and every bucket shares the largest program's buffers. Not bit-identical to
// the GPU path (fp16 weights and activations on the ANE); gate by KL.
const BUCKET = 512;

/** Channels the ANE takes of R rows at `fraction` (64-aligned, at least 64 left on each side). */
export function aneChannels(R: number, fraction: number): number {
  return Math.min(R - 64, Math.max(64, Math.round((fraction * R) / 64) * 64));
}
const bucketFor = (maxSeq: number, rows: number) => Math.min(maxSeq, Math.ceil(rows / BUCKET) * BUCKET);

// Whole-MLP slice programs, one shape at a time (layers run one at a time).
let mlpPrograms: Map<number, AneProgram> | null = null;
let mlpKey = "";
function mlpProgram(D: number, n: number, maxSeq: number, rows: number): { program: AneProgram; seq: number } {
  const key = `${D}:${n}:${maxSeq}`;
  if (key !== mlpKey) {
    for (const program of mlpPrograms?.values() ?? []) program.dispose();
    mlpPrograms = new Map(); mlpKey = key;
  }
  const make = (seq: number, share?: AneProgram) => AneProgram.create(mlpSliceMil(D, n, seq),
    [n * D * 2, n * D * 2, n * D * 2, seq * D * 2], seq * D * 2, { share });
  let largest = mlpPrograms!.get(maxSeq);
  if (!largest) mlpPrograms!.set(maxSeq, largest = make(maxSeq));
  const seq = bucketFor(maxSeq, rows);
  let program = mlpPrograms!.get(seq);
  if (!program) mlpPrograms!.set(seq, program = make(seq, largest));
  return { program, seq };
}

// Streamed matmul programs per projection shape.
const affinePrograms = new Map<string, Map<number, AneStreamedMatmul>>();
function affineProgram(K: number, n: number, maxSeq: number, rows: number): AneStreamedMatmul {
  const key = `${K}:${n}`;
  let bank = affinePrograms.get(key);
  if (!bank) affinePrograms.set(key, bank = new Map());
  let largest = bank.get(maxSeq);
  if (!largest) bank.set(maxSeq, largest = AneStreamedMatmul.create(K, n, maxSeq));
  const seq = bucketFor(maxSeq, rows);
  let program = bank.get(seq);
  if (!program) bank.set(seq, program = AneStreamedMatmul.create(K, n, seq, largest));
  return program;
}

/** Create every bucket of a whole-MLP slice program [D, R] from minRows to
 *  maxSeq now, not on the first chunk of each size. Compiled programs persist
 *  in the system ANE cache, so only a machine's first run compiles (1-5 s per
 *  program); later loads take a few milliseconds. */
export function precompileAneMlp(D: number, R: number, fraction: number, maxSeq: number, minRows: number): void {
  const n = aneChannels(R, fraction);
  for (let seq = Math.ceil(minRows / BUCKET) * BUCKET; seq <= maxSeq; seq += BUCKET) mlpProgram(D, n, maxSeq, seq);
}

/** The same for an affine projection [K inputs, N outputs]. */
export function precompileAneAffine(K: number, N: number, fraction: number, maxSeq: number, minRows: number): void {
  const n = aneChannels(N, fraction);
  for (let seq = Math.ceil(minRows / BUCKET) * BUCKET; seq <= maxSeq; seq += BUCKET) affineProgram(K, n, maxSeq, seq);
}

type Fill = (codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number) => MlxArray;
type Swiglu = (g: MlxArray, u: MlxArray) => MlxArray;

/** Whole Trellis MLP: the ANE computes the first n intermediate channels end
 *  to end (gate and up rows, SwiGLU, and the down projection's partial sum over
 *  those channels); the GPU computes channels [n, R) through TrellisLinear; the
 *  two [M, D] partials add. Measured on M4 Pro: one fused slice program at
 *  10.2 TFLOPS (D 5120, n 9600, S 2048). */
function mlpSplit(maxSeq: number, n: number, gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear,
  rest: { gate: TrellisLinear; up: TrellisLinear; down: TrellisLinear }, fillDown: Fill, hidden: MlxArray, swiglu: Swiglu): MlxArray {
  const D = gate.geometry.inFeatures;
  const lead = hidden.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
  if (M > maxSeq) throw new Error(`ANE MLP split: ${M} rows exceed ${maxSeq}`);
  const { program, seq } = mlpProgram(D, n, maxSeq, M);
  {
    // Inputs in symbol order: wd, wg, wu, x. Filled before any GPU share is
    // queued, so the ANE starts at once.
    using wd = program.inputArray(0, [n * D], Dtype.float16);
    using wg = program.inputArray(1, [n * D], Dtype.float16);
    using wu = program.inputArray(2, [n * D], Dtype.float16);
    using x = program.inputArray(3, [seq * D], Dtype.float16);
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
    using g = rest.gate.forward(hidden, true);
    using u = rest.up.forward(hidden, true);
    using mid = swiglu(g, u);
    gpuOut = rest.down.forward(mid, true);
    gpuOut.eval();
  } finally { program.wait(); }
  try {
    using out = program.output([seq, D], Dtype.float16);   // zero-copy partial [S, D]
    using used = out.slice([0, 0], [M, D]);
    using b = used.astype(hidden.dtype);
    using g2 = ops.reshape(gpuOut, [M, D]);
    using sum = ops.add(b, g2);
    const result = ops.reshape(sum, [...lead, D]);
    result.eval();                                          // consume the ANE output before the next layer reuses it
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

/** Whole-MLP split for a down projection with row-major codes. */
export class AneTrellisMlpSplit implements Disposable {
  private constructor(readonly maxSeq: number, readonly channels: number, readonly gate: TrellisLinear, readonly up: TrellisLinear,
    readonly down: TrellisLinear, readonly rest: { gate: TrellisLinear; up: TrellisLinear; down: TrellisLinear }) {}

  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, seq: number): AneTrellisMlpSplit {
    checkMlp("AneTrellisMlpSplit", gate, up, down, false);
    const R = gate.geometry.rows, n = aneChannels(R, fraction);
    mlpProgram(gate.geometry.inFeatures, n, seq, seq);
    return new AneTrellisMlpSplit(seq, n, gate, up, down,
      { gate: trellisRows(gate, n, R), up: trellisRows(up, n, R), down: trellisStoredRows(down, n, R) });
  }
  /** hidden [.., M, D] (M <= seq) → MLP(hidden) [.., M, D]. */
  forward(hidden: MlxArray, swiglu: Swiglu): MlxArray {
    return mlpSplit(this.maxSeq, this.channels, this.gate, this.up, this.down, this.rest, trellisFillHalf, hidden, swiglu);
  }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void { for (const lin of Object.values(this.rest)) disposeLinear(lin); }
}

/** Whole-MLP split for a 3-bit block-interleaved down projection. */
export class AneTrellisMlpSplitK3i implements Disposable {
  private constructor(readonly maxSeq: number, readonly channels: number, readonly gate: TrellisLinear, readonly up: TrellisLinear,
    readonly down: TrellisLinear, readonly rest: { gate: TrellisLinear; up: TrellisLinear; down: TrellisLinear }) {}

  static build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear, fraction: number, seq: number): AneTrellisMlpSplitK3i {
    checkMlp("AneTrellisMlpSplitK3i", gate, up, down, true);
    const R = gate.geometry.rows, n = aneChannels(R, fraction);
    mlpProgram(gate.geometry.inFeatures, n, seq, seq);
    return new AneTrellisMlpSplitK3i(seq, n, gate, up, down,
      { gate: trellisRows(gate, n, R), up: trellisRows(up, n, R), down: trellisStoredRows(down, n, R) });
  }
  forward(hidden: MlxArray, swiglu: Swiglu): MlxArray {
    return mlpSplit(this.maxSeq, this.channels, this.gate, this.up, this.down, this.rest, trellisFillHalfK3Interleaved, hidden, swiglu);
  }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void { for (const lin of Object.values(this.rest)) disposeLinear(lin); }
}

/** Affine projection split: the first n output rows of an MLX affine
 *  projection run on the ANE from fp16 rows the GPU dequantizes straight into
 *  the streamed program's weight buffer; the GPU computes the remaining rows;
 *  outputs concatenate in row order. */
export class AneAffineSplit implements Disposable {
  private constructor(readonly maxSeq: number, readonly rows: number, readonly head: { w: MlxArray; scales: MlxArray; biases: MlxArray },
    readonly rest: QuantizedLinear, readonly spec: ops.QuantSpec) {}

  static build(lin: QuantizedLinear, fraction: number, seq: number): AneAffineSplit {
    const N = lin.outFeatures, K = lin.inFeatures;
    if (!lin.biases || lin.bias || lin.w.ndim !== 2 || lin.spec.mode !== "affine") throw new Error("AneAffineSplit: unsupported projection");
    const n = aneChannels(N, fraction);
    const rowsOf = (a: MlxArray, start: number, stop: number) => a.slice([start, 0], [stop, a.shape[1]!]);
    const head = { w: rowsOf(lin.w, 0, n), scales: rowsOf(lin.scales, 0, n), biases: rowsOf(lin.biases, 0, n) };
    const rest = new QuantizedLinear(rowsOf(lin.w, n, N), rowsOf(lin.scales, n, N), rowsOf(lin.biases, n, N), lin.spec);
    affineProgram(K, n, seq, seq);
    return new AneAffineSplit(seq, n, head, rest, lin.spec);
  }

  /** x [.., M, K] (M <= seq) → [.., M, N]. */
  forward(x: MlxArray): MlxArray {
    const K = this.head.w.shape[1]! * 32 / this.spec.bits, n = this.rows;
    const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
    if (M > this.maxSeq) throw new Error(`AneAffineSplit: ${M} rows exceed ${this.maxSeq}`);
    const ane = affineProgram(K, n, this.maxSeq, M), S = ane.seq;
    ane.prepare();
    {
      using w = MlxArray.fromPointer(ane.weightsPointer, [n * K], Dtype.float16);
      using xs = MlxArray.fromPointer(ane.inputPointer, [S * K], Dtype.float16);
      using dense = ops.dequantize(this.head.w, this.head.scales, this.head.biases, this.spec);
      using flat = ops.reshape(dense, [n * K]);
      using x2 = ops.reshape(x, [M * K]);
      using d0 = writeHalf(w, flat, 0);
      using d1 = writeHalf(xs, x2, 0);
      ops.evalAll([d0, d1]);
    }
    ane.evalAsync();
    let gpu: MlxArray;
    try { gpu = this.rest.forward(x); gpu.eval(); }
    finally { ane.wait(); }
    try {
      using out = ane.output();                               // [S, n] fp16
      using used = out.slice([0, 0], [M, n]);
      using b = used.astype(x.dtype);
      using g2 = ops.reshape(gpu, [M, this.rest.outFeatures]);
      using both = ops.concatAxis([b, g2], -1);
      const result = ops.reshape(both, [...lead, n + this.rest.outFeatures]);
      result.eval();
      return result;
    } finally { gpu.dispose(); }
  }

  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void {}
}
