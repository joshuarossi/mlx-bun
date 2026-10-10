import { dlopen, FFIType, ptr, toArrayBuffer, type Pointer } from "bun:ffi";
import { existsSync } from "node:fs";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { ANE_LIBRARY as LIBRARY } from "../../runtime/native";

// Apple Neural Engine sidecar (native/ane-bridge.m): programs
// compiled from MIL text through the private AppleNeuralEngine.framework, with
// IOSurface inputs/outputs the host or the GPU (zero-copy MLX wraps) fill.
// Private Apple API; callers treat any failure as "no ANE" and stay on the GPU.

type Lib = ReturnType<typeof open>;
function open() {
  return dlopen(LIBRARY, {
    mbane_available: { args: [], returns: FFIType.i32 },
    mbane_program_create: { args: [FFIType.ptr, FFIType.i32, FFIType.ptr, FFIType.ptr, FFIType.ptr, FFIType.i32, FFIType.ptr,
      FFIType.u64, FFIType.ptr, FFIType.ptr, FFIType.i32], returns: FFIType.ptr },
    mbane_input: { args: [FFIType.ptr, FFIType.i32], returns: FFIType.ptr },
    mbane_output: { args: [FFIType.ptr], returns: FFIType.ptr },
    mbane_eval_async: { args: [FFIType.ptr], returns: FFIType.i32 },
    mbane_wait: { args: [FFIType.ptr, FFIType.ptr, FFIType.i32], returns: FFIType.i32 },
    mbane_free: { args: [FFIType.ptr], returns: FFIType.void },
  }).symbols;
}
let lib: Lib | null | undefined;
function native(): Lib | null {
  if (lib !== undefined) return lib;
  try { lib = existsSync(LIBRARY) ? open() : null; } catch { lib = null; }
  if (lib && !lib.mbane_available()) lib = null;
  return lib;
}

/** The bridge loaded and this machine compiles ANE programs. Loading proves
 *  only that the private framework is present; a VM or a CI runner can load it
 *  and still fail every compile, so the first call compiles one small streamed
 *  matmul and remembers the answer. Any failure is "no ANE". */
let usable: boolean | undefined;
export function aneAvailable(): boolean {
  if (usable === undefined) {
    usable = false;
    if (native() !== null) {
      try { AneStreamedMatmul.create(64, 64, 64).dispose(); usable = true; } catch { usable = false; }
    }
  }
  return usable;
}

const errorBuffer = new Uint8Array(512);
const errorText = () => new TextDecoder().decode(errorBuffer.subarray(0, errorBuffer.indexOf(0)));
const cstring = (text: string) => new TextEncoder().encode(text + "\0");

/** One compiled ANE program. Inputs follow MIL symbol order (input names sorted). */
export class AneProgram implements Disposable {
  readonly #lib: Lib;
  #handle: Pointer | null;

  private constructor(lib: Lib, handle: Pointer, readonly inputBytes: readonly number[], readonly outputBytes: number) {
    this.#lib = lib;
    this.#handle = handle;
  }

  /** `weights`: BLOBFILE payloads by file name (already in blob format). */
  static create(mil: string, inputBytes: readonly number[], outputBytes: number,
    options: { weights?: Record<string, Uint8Array>; share?: AneProgram } = {}): AneProgram {
    const l = native();
    if (!l) throw new Error("ANE bridge unavailable");
    const entries = Object.entries(options.weights ?? {});
    const names = entries.map(([name]) => cstring(name));
    const namePtrs = BigUint64Array.from(names.map(n => BigInt(ptr(n))));
    const dataPtrs = BigUint64Array.from(entries.map(([, data]) => BigInt(ptr(data))));
    const dataLens = BigUint64Array.from(entries.map(([, data]) => BigInt(data.byteLength)));
    const sizes = BigUint64Array.from(inputBytes.map(BigInt));
    const text = cstring(mil);
    errorBuffer.fill(0);
    const handle = l.mbane_program_create(ptr(text), entries.length, entries.length ? ptr(namePtrs) : null,
      entries.length ? ptr(dataPtrs) : null, entries.length ? ptr(dataLens) : null, inputBytes.length, ptr(sizes),
      outputBytes, options.share ? options.share.#handle : null, ptr(errorBuffer), errorBuffer.length);
    if (!handle) throw new Error(errorText() || "ANE program creation failed");
    return new AneProgram(l, handle, inputBytes, outputBytes);
  }

  /** Base address of input i, locked for writes until the next evaluation. */
  input(i: number): number { return Number(this.#lib.mbane_input(this.#handle!, i)); }
  inputView(i: number): Uint8Array { return new Uint8Array(toArrayBuffer(this.#lib.mbane_input(this.#handle!, i)!, 0, this.inputBytes[i]!)); }
  /** Zero-copy MLX wrap of input i (the GPU may write it through a kernel). */
  inputArray(i: number, shape: number[], dtype: Dtype): MlxArray { return MlxArray.fromPointer(this.input(i), shape, dtype); }
  /** Zero-copy MLX view of the output; valid until the next evaluation. */
  output(shape: number[], dtype: Dtype): MlxArray { return MlxArray.fromPointer(Number(this.#lib.mbane_output(this.#handle!)), shape, dtype); }

  evalAsync(): void { if (!this.#lib.mbane_eval_async(this.#handle!)) throw new Error("ANE evaluation already pending"); }
  wait(): void {
    errorBuffer.fill(0);
    if (!this.#lib.mbane_wait(this.#handle!, ptr(errorBuffer), errorBuffer.length)) throw new Error(errorText());
  }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void { if (this.#handle) { this.#lib.mbane_free(this.#handle); this.#handle = null; } }
}

// ---- MIL builders ----------------------------------------------------------

const MIL_HEADER = `program(1.3)
[buildInfo = dict<string, string>({{"coremlc-component-MIL", "3510.2.1"}, {"coremlc-version", "3505.4.1"}, {"coremltools-component-milinternal", ""}, {"coremltools-version", "9.0"}})]
{
`;

/** BLOBFILE payload (offset 64 holds the data header, data at 128). */
export function weightBlob(bytes: Uint8Array): Uint8Array {
  const out = new Uint8Array(128 + bytes.byteLength);
  const view = new DataView(out.buffer);
  out[0] = 0x01; out[4] = 0x02;
  out.set([0xef, 0xbe, 0xad, 0xde, 0x01], 64);
  view.setUint32(72, bytes.byteLength, true);
  view.setUint32(80, 128, true);
  out.set(bytes, 128);
  return out;
}

const BOOLS = [`    bool ff = const()[name=string("ff"), val=bool(false)];`, `    bool tt = const()[name=string("tt"), val=bool(true)];`];

/** Reduction slices summed inside a streamed-weight program: 8 runs ~2.5x
 *  faster than one on M4 Pro. A reduction not divisible by 8 stays whole. */
const CHUNKS = 8;

/** a[1,1,rows,red] · b[1,1,cols,red]ᵀ → out, the reduction split into CHUNKS
 *  slices summed inside the program. `tag` keeps value names unique. */
function chunkedMatmulT(lines: string[], out: string, a: string, b: string, rows: number, cols: number, red: number, tag: string): void {
  const chunks = red % CHUNKS ? 1 : CHUNKS;
  const cc = red / chunks;
  let last = "";
  for (let c = 0; c < chunks; c++) {
    lines.push(`    tensor<int32, [4]> ${tag}b${c} = const()[name=string("${tag}b${c}"), val=tensor<int32, [4]>([0, 0, 0, ${c * cc}])];`,
      `    tensor<int32, [4]> ${tag}ea${c} = const()[name=string("${tag}ea${c}"), val=tensor<int32, [4]>([1, 1, ${rows}, ${(c + 1) * cc}])];`,
      `    tensor<int32, [4]> ${tag}eb${c} = const()[name=string("${tag}eb${c}"), val=tensor<int32, [4]>([1, 1, ${cols}, ${(c + 1) * cc}])];`,
      `    tensor<fp16, [1, 1, ${rows}, ${cc}]> ${tag}sa${c} = slice_by_index(x=${a}, begin=${tag}b${c}, end=${tag}ea${c})[name=string("${tag}sa${c}")];`,
      `    tensor<fp16, [1, 1, ${cols}, ${cc}]> ${tag}sb${c} = slice_by_index(x=${b}, begin=${tag}b${c}, end=${tag}eb${c})[name=string("${tag}sb${c}")];`,
      `    tensor<fp16, [1, 1, ${rows}, ${cols}]> ${tag}p${c} = matmul(transpose_x=ff, transpose_y=tt, x=${tag}sa${c}, y=${tag}sb${c})[name=string("${tag}p${c}")];`);
    const p = `${tag}p${c}`;
    if (last) {
      lines.push(`    tensor<fp16, [1, 1, ${rows}, ${cols}]> ${tag}s${c} = add(x=${last}, y=${p})[name=string("${tag}s${c}")];`);
      last = `${tag}s${c}`;
    } else last = p;
  }
  lines.push(`    tensor<fp16, [1, 1, ${rows}, ${cols}]> ${out} = identity(x=${last})[name=string("${out}")];`);
}

/** y[S, Cout] = x[S, Cin] · w[Cout, Cin]ᵀ, w streamed (inputs: w=0, x=1). */
export function streamedMatmulMil(cin: number, cout: number, seq: number): string {
  const lines = [`  func main<ios18>(tensor<fp16, [1, 1, ${seq}, ${cin}]> x, tensor<fp16, [1, 1, ${cout}, ${cin}]> w) {`, ...BOOLS];
  chunkedMatmulT(lines, "y", "x", "w", seq, cout, cin, "m");
  return MIL_HEADER + lines.join("\n") + `\n  } -> (y);\n}\n`;
}

/** One MLP channel slice with streamed weights:
 *  y[S, D] = (silu(x·wgᵀ) ⊙ (x·wuᵀ)) · wd, wg/wu/wd [N, D] (wd: the down
 *  projection's rows for the same N channels). Inputs in symbol order: wd=0,
 *  wg=1, wu=2, x=3. Measured 10.2 TFLOPS (D 5120, N 9600, S 2048). */
export function mlpSliceMil(D: number, N: number, S: number): string {
  const lines = [`  func main<ios18>(tensor<fp16, [1, 1, ${N}, ${D}]> wd, tensor<fp16, [1, 1, ${N}, ${D}]> wg, ` +
    `tensor<fp16, [1, 1, ${N}, ${D}]> wu, tensor<fp16, [1, 1, ${S}, ${D}]> x) {`, ...BOOLS];
  chunkedMatmulT(lines, "g", "x", "wg", S, N, D, "G");
  chunkedMatmulT(lines, "u", "x", "wu", S, N, D, "U");
  lines.push(`    tensor<fp16, [1, 1, ${S}, ${N}]> sg = silu(x=g)[name=string("sg")];`,
    `    tensor<fp16, [1, 1, ${S}, ${N}]> h = mul(x=sg, y=u)[name=string("h")];`);
  const chunksDown = N % CHUNKS ? 1 : CHUNKS;
  const cc = N / chunksDown;
  let last = "";
  for (let c = 0; c < chunksDown; c++) {
    lines.push(`    tensor<int32, [4]> Hb${c} = const()[name=string("Hb${c}"), val=tensor<int32, [4]>([0, 0, 0, ${c * cc}])];`,
      `    tensor<int32, [4]> He${c} = const()[name=string("He${c}"), val=tensor<int32, [4]>([1, 1, ${S}, ${(c + 1) * cc}])];`,
      `    tensor<int32, [4]> Wb${c} = const()[name=string("Wb${c}"), val=tensor<int32, [4]>([0, 0, ${c * cc}, 0])];`,
      `    tensor<int32, [4]> We${c} = const()[name=string("We${c}"), val=tensor<int32, [4]>([1, 1, ${(c + 1) * cc}, ${D}])];`,
      `    tensor<fp16, [1, 1, ${S}, ${cc}]> hs${c} = slice_by_index(x=h, begin=Hb${c}, end=He${c})[name=string("hs${c}")];`,
      `    tensor<fp16, [1, 1, ${cc}, ${D}]> ws${c} = slice_by_index(x=wd, begin=Wb${c}, end=We${c})[name=string("ws${c}")];`,
      `    tensor<fp16, [1, 1, ${S}, ${D}]> d${c} = matmul(transpose_x=ff, transpose_y=ff, x=hs${c}, y=ws${c})[name=string("d${c}")];`);
    if (last) { lines.push(`    tensor<fp16, [1, 1, ${S}, ${D}]> ds${c} = add(x=${last}, y=d${c})[name=string("ds${c}")];`); last = `ds${c}`; }
    else last = `d${c}`;
  }
  return MIL_HEADER + lines.join("\n") + `\n  } -> (${last});\n}\n`;
}

/** INT8 const-weight linear over channel-major activations: y[1, Cout, 1, S]. */
export function int8LinearMil(cin: number, cout: number, seq: number): string {
  return MIL_HEADER + [
    `  func main<ios18>(tensor<fp16, [1, ${cin}, 1, ${seq}]> x) {`,
    `    tensor<int8, [${cout}, ${cin}, 1, 1]> wd = const()[name=string("wd"), val=tensor<int8, [${cout}, ${cin}, 1, 1]>(BLOBFILE(path=string("@model_path/weights/weight_data.bin"), offset=uint64(64)))];`,
    `    tensor<fp16, [${cout}, 1, 1, 1]> ws = const()[name=string("ws"), val=tensor<fp16, [${cout}, 1, 1, 1]>(BLOBFILE(path=string("@model_path/weights/weight_scale.bin"), offset=uint64(64)))];`,
    `    tensor<fp16, [${cout}, ${cin}, 1, 1]> w = constexpr_blockwise_shift_scale(data=wd, scale=ws)[name=string("dequant")];`,
    `    string pt = const()[name=string("pt"), val=string("valid")];`,
    `    tensor<int32, [2]> st = const()[name=string("st"), val=tensor<int32, [2]>([1,1])];`,
    `    tensor<int32, [4]> pd = const()[name=string("pd"), val=tensor<int32, [4]>([0,0,0,0])];`,
    `    tensor<int32, [2]> dl = const()[name=string("dl"), val=tensor<int32, [2]>([1,1])];`,
    `    int32 gr = const()[name=string("gr"), val=int32(1)];`,
    `    tensor<fp16, [1, ${cout}, 1, ${seq}]> y = conv(dilations=dl, groups=gr, pad=pd, pad_type=pt, strides=st, weight=w, x=x)[name=string("conv")];`,
  ].join("\n") + `\n  } -> (y);\n}\n`;
}

// ---- Convenience wrappers --------------------------------------------------

/** INT8 linear with resident weights; channel-major [C, S] fp16 buffers (S % 32 == 0). */
export class AneLinear implements Disposable {
  private constructor(readonly program: AneProgram, readonly cin: number, readonly cout: number, readonly seq: number) {}
  static create(cin: number, cout: number, seq: number, q: Int8Array, scales: Uint16Array, share?: AneLinear): AneLinear {
    if (seq % 32 !== 0) throw new Error(`AneLinear: S=${seq} must be a multiple of 32`);
    const program = AneProgram.create(int8LinearMil(cin, cout, seq), [cin * seq * 2], cout * seq * 2, {
      weights: { "weight_data.bin": weightBlob(new Uint8Array(q.buffer, q.byteOffset, q.byteLength)),
        "weight_scale.bin": weightBlob(new Uint8Array(scales.buffer, scales.byteOffset, scales.byteLength)) },
      share: share?.program });
    return new AneLinear(program, cin, cout, seq);
  }
  writeInput(bytes: Uint8Array): void { this.program.inputView(0).set(bytes); }
  evalAsync(): void { this.program.evalAsync(); }
  wait(): void { this.program.wait(); }
  output(): MlxArray { return this.program.output([this.cout, this.seq], Dtype.float16); }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void { this.program.dispose(); }
}

/** Streamed-weight matmul y[S, Cout] = x[S, Cin] · w[Cout, Cin]ᵀ (row-major fp16). */
export class AneStreamedMatmul implements Disposable {
  private constructor(readonly program: AneProgram, readonly cin: number, readonly cout: number, readonly seq: number) {}
  static create(cin: number, cout: number, seq: number, share?: AneStreamedMatmul): AneStreamedMatmul {
    const program = AneProgram.create(streamedMatmulMil(cin, cout, seq), [cout * cin * 2, seq * cin * 2], seq * cout * 2,
      { share: share?.program });
    return new AneStreamedMatmul(program, cin, cout, seq);
  }
  get weightsPointer(): number { return this.program.input(0); }
  get inputPointer(): number { return this.program.input(1); }
  prepare(): void { this.program.input(0); this.program.input(1); }
  evalAsync(): void { this.program.evalAsync(); }
  wait(): void { this.program.wait(); }
  output(): MlxArray { return this.program.output([this.seq, this.cout], Dtype.float16); }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void { this.program.dispose(); }
}

/** Per-output-row symmetric INT8 of a dense [rows, cols] weight (GPU), as the
 *  ANE program's int8 data and fp16 scale bits. */
export function quantizeRowsInt8(w: MlxArray): { q: Int8Array; scales: Uint16Array } {
  using w32 = w.astype(Dtype.float32);
  using a = ops.abs(w32);
  using amax = ops.maxAxis(a, 1, true);
  using raw = ops.mulScalar(amax, 1 / 127);
  using floor = ops.scalarLike(1e-8, raw);
  using scale = ops.maximum(raw, floor);
  using scaled = ops.div(w32, scale);
  using rounded = ops.round(scaled);
  using lo = ops.scalarLike(-127, rounded), hi = ops.scalarLike(127, rounded);
  using floored = ops.maximum(rounded, lo);
  using clipped = ops.minimum(floored, hi);
  using q8 = clipped.astype(Dtype.int8);
  using s16 = scale.astype(Dtype.float16);
  q8.eval(); s16.eval();
  return { q: new Int8Array(q8.rawBytes().buffer), scales: new Uint16Array(s16.rawBytes().buffer) };
}
