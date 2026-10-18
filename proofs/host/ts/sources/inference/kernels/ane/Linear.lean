import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Ane.Linear
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/ane/linear.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { dlopen, FFIType, ptr, toArrayBuffer, type Pointer } from "bun:ffi";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { ANE_LIBRARY as LIBRARY } from "../../runtime/native";

// Apple Neural Engine sidecar (native/ane-bridge.m): programs compiled from MIL
// text through the private AppleNeuralEngine.framework, with IOSurface
// inputs/outputs the host or the GPU (zero-copy MLX wraps) fill. Compiling is
// the install step (`AneProgram.compile`, run for every shipped composition by
// `compileAnePrograms` in models/ane-install); it leaves each program in the
// system compile cache. A graph binding Neural Engine layers
// loads its programs from that cache when it is
// constructed and never compiles one: a bridge that does not load, or a program
// the cache lacks, fails that load with `AneBridgeError`.

/** The Neural Engine bridge did not load, a program is not compiled on this Mac,
 *  or the compiler refused one: loading a graph that binds the bridge fails
 *  with it. */
export class AneBridgeError extends Error {
  override readonly name = "AneBridgeError";
}

/** What a program missing from the compile cache asks for. */
const INSTALL_STEP = "run the install step, `mlx-bun compile-ane`, once " +
  "(a library caller: compileAnePrograms from @mlx-bun/inference/models, under the executable that serves)";

/** One ANE program as the compiler takes it. Programs with the same MIL and
 *  weights are one program: one compile, and one loaded model for the layers
 *  that share it. */
export interface AneProgramSpec {
  /** Names the program in messages, e.g. `MLP slice 5120×9600, 2048 rows`. */
  readonly label: string;
  readonly mil: string;
  /** IOSurface bytes of each MIL input, in symbol order (input names sorted). */
  readonly inputBytes: readonly number[];
  readonly outputBytes: number;
  /** BLOBFILE payloads by file name (already in blob format). */
  readonly weights?: Readonly<Record<string, Uint8Array>>;
}

/** A key equal for two specs exactly when they are one program (same MIL and weights). */
export function aneProgramKey(spec: AneProgramSpec): string {
  const weights = Object.entries(spec.weights ?? {}).sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0)
    .map(([name, data]) => `${name}:${data.byteLength}:${Bun.hash(data).toString(16)}`);
  return `${Bun.hash(spec.mil).toString(16)}:${spec.mil.length}|${weights.join(",")}`;
}

/** `compiled`: the compiler ran now; `cached`: the system compile cache already held the program. */
export type AneCompileStatus = "compiled" | "cached";

type Lib = ReturnType<typeof open>;
function open() {
  const source = [FFIType.ptr, FFIType.i32, FFIType.ptr, FFIType.ptr, FFIType.ptr] as const;
  return dlopen(LIBRARY, {
    mbane_program_create: { args: [...source, FFIType.i32, FFIType.ptr, FFIType.u64, FFIType.ptr, FFIType.ptr, FFIType.ptr,
      FFIType.i32], returns: FFIType.ptr },
    mbane_program_compile: { args: [...source, FFIType.ptr, FFIType.i32], returns: FFIType.i32 },
    mbane_program_cached: { args: [...source, FFIType.ptr, FFIType.i32], returns: FFIType.i32 },
    mbane_program_purge: { args: [...source, FFIType.ptr, FFIType.i32], returns: FFIType.i32 },
    mbane_input: { args: [FFIType.ptr, FFIType.i32], returns: FFIType.ptr },
    mbane_output: { args: [FFIType.ptr], returns: FFIType.ptr },
    mbane_eval_async: { args: [FFIType.ptr], returns: FFIType.i32 },
    mbane_wait: { args: [FFIType.ptr, FFIType.ptr, FFIType.i32], returns: FFIType.i32 },
    mbane_free: { args: [FFIType.ptr], returns: FFIType.void },
  }).symbols;
}
let lib: Lib | undefined;
/** The bridge, loaded on first use. */
function native(): Lib {
  if (lib) return lib;
  try { lib = open(); }
  catch (error) { throw new AneBridgeError(`the Neural Engine bridge did not load (${LIBRARY})`, { cause: error }); }
  return lib;
}

const errorBuffer = new Uint8Array(512);
const errorText = () => new TextDecoder().decode(errorBuffer.subarray(0, errorBuffer.indexOf(0)));
const cstring = (text: string) => new TextEncoder().encode(text + "\0");

/** A spec's MIL and weights as the bridge's leading five arguments. The buffers
 *  live in the returned array, so it must stay reachable for the call. */
function source(spec: AneProgramSpec): [Pointer, number, Pointer | null, Pointer | null, Pointer | null, ...unknown[]] {
  const entries = Object.entries(spec.weights ?? {});
  const names = entries.map(([name]) => cstring(name));
  const namePtrs = BigUint64Array.from(names.map(n => BigInt(ptr(n))));
  const dataPtrs = BigUint64Array.from(entries.map(([, data]) => BigInt(ptr(data))));
  const dataLens = BigUint64Array.from(entries.map(([, data]) => BigInt(data.byteLength)));
  const text = cstring(spec.mil);
  const some = entries.length > 0;
  return [ptr(text), entries.length, some ? ptr(namePtrs) : null, some ? ptr(dataPtrs) : null, some ? ptr(dataLens) : null,
    text, names, namePtrs, dataPtrs, dataLens];
}

/** Bytes the bridge allocates for a buffer of `bytes` (native/ane-bridge.m make_surface: whole 64 KiB units), so a
 *  wrap of the allocation is a page multiple, which Metal maps without a copy. */
const allocated = (bytes: number) => Math.max(65536, Math.ceil(bytes / 65536) * 65536);

/** The MLX wraps of one set of program buffers (IOSurfaces), each a no-copy
 *  Metal buffer that MLX also enters in its residency set: made once per
 *  buffer, on first use, and shared by every program loaded on the buffers, the
 *  last of which releases them before the buffers. Also the one array that may
 *  still read the output lazily (`defer`), evaluated before the next run. */
class Surfaces {
  holders = 1;
  readonly #inputs = new Map<number, MlxArray>();
  #output: MlxArray | undefined;
  #reader: MlxArray | undefined;
  /** Byte sizes of the buffers: the first program's (any program loaded on them needs no more). */
  constructor(readonly inputBytes: readonly number[], readonly outputBytes: number) {}
  input(i: number, address: number): MlxArray {
    let wrap = this.#inputs.get(i);
    if (!wrap) this.#inputs.set(i, wrap = MlxArray.fromPointer(address, [allocated(this.inputBytes[i]!) / 2], Dtype.float16));
    return wrap;
  }
  output(address: number): MlxArray {
    return this.#output ??= MlxArray.fromPointer(address, [allocated(this.outputBytes) / 2], Dtype.float16);
  }
  defer(reader: MlxArray): void { this.settle(); this.#reader = reader; }
  /** Evaluates and releases the deferred reader, if any (nothing to wait for once its graph ran). */
  settle(): void {
    const reader = this.#reader;
    if (!reader) return;
    this.#reader = undefined;
    try { reader.eval(); } finally { reader.dispose(); }
  }
  dispose(): void {
    this.#reader?.dispose();
    this.#reader = undefined;
    for (const wrap of this.#inputs.values()) wrap.dispose();
    this.#inputs.clear();
    this.#output?.dispose();
    this.#output = undefined;
  }
}

/** One loaded ANE program. Inputs follow MIL symbol order (input names sorted).
 *  A loaded program holds one of the ANE driver's direct-path clients, about a
 *  thousand on the whole machine, until its last holder is disposed; creating
 *  one while none is free blocks (native/ane-bridge.m). */
export class AneProgram implements Disposable {
  readonly #lib: Lib;
  #handle: Pointer | null;
  readonly #surfaces: Surfaces;

  private constructor(lib: Lib, handle: Pointer, surfaces: Surfaces, readonly inputBytes: readonly number[], readonly outputBytes: number) {
    this.#lib = lib;
    this.#handle = handle;
    this.#surfaces = surfaces;
  }

  /** Loads `spec` from the system compile cache (about 4 ms); never compiles.
   *  `share`: a program that never runs at the same time as this one. With the
   *  same MIL and weights the result holds that same loaded program; otherwise
   *  a new program loads on its buffers (each at least as large). Either way
   *  the shared resources live until every holder is disposed. Throws
   *  `AneBridgeError` when the bridge does not load, when the program is not
   *  compiled on this Mac (naming the install step, {@link AneProgram.compile}),
   *  or when it does not load. */
  static create(spec: AneProgramSpec, share?: AneProgram): AneProgram {
    const l = native(), args = source(spec), uncompiled = new Int32Array(1);
    const sizes = BigUint64Array.from(spec.inputBytes.map(BigInt));
    errorBuffer.fill(0);
    const handle = l.mbane_program_create(args[0], args[1], args[2], args[3], args[4], spec.inputBytes.length, ptr(sizes),
      spec.outputBytes, share ? share.#handle : null, ptr(uncompiled), ptr(errorBuffer), errorBuffer.length);
    if (!handle) throw new AneBridgeError(uncompiled[0]
      ? `Neural Engine program ${spec.label} is not compiled on this Mac; ${INSTALL_STEP}`
      : `${spec.label}: ${errorText() || "ANE program creation failed"}`);
    const surfaces = share ? share.#surfaces : new Surfaces(spec.inputBytes, spec.outputBytes);
    if (share) surfaces.holders++;
    return new AneProgram(l, handle, surfaces, spec.inputBytes, spec.outputBytes);
  }

  /** The install step for one program: compiles `spec` into the system compile
   *  cache unless it is there already. Loads nothing and holds no ANE driver
   *  client. The cache is per code-signing identity, so the executable that will
   *  serve is the one that compiles. Throws `AneBridgeError` when the bridge does
   *  not load or the compiler refuses the program. */
  static compile(spec: AneProgramSpec): AneCompileStatus {
    const args = source(spec);
    errorBuffer.fill(0);
    const status = native().mbane_program_compile(args[0], args[1], args[2], args[3], args[4], ptr(errorBuffer), errorBuffer.length);
    if (status === 0) throw new AneBridgeError(`${spec.label}: ${errorText() || "ANE compile failed"}`);
    return status === 1 ? "compiled" : "cached";
  }

  /** Whether the system compile cache holds `spec` for this process (the framework's `compiledModelExists`). */
  static cached(spec: AneProgramSpec): boolean {
    const args = source(spec);
    errorBuffer.fill(0);
    const status = native().mbane_program_cached(args[0], args[1], args[2], args[3], args[4], ptr(errorBuffer), errorBuffer.length);
    if (status < 0) throw new AneBridgeError(`${spec.label}: ${errorText()}`);
    return status === 1;
  }

  /** Removes `spec` from the system compile cache (the framework's
   *  `purgeCompiledModel`): `create` refuses it until it is compiled again.
   *  Programs already loaded keep running. */
  static purge(spec: AneProgramSpec): void {
    const args = source(spec);
    errorBuffer.fill(0);
    const status = native().mbane_program_purge(args[0], args[1], args[2], args[3], args[4], ptr(errorBuffer), errorBuffer.length);
    if (status !== 1) throw new AneBridgeError(`${spec.label}: ${status < 0 ? errorText() : "still in the compile cache after the purge"}`);
  }

  /** Base address of input i, locked for writes until the next evaluation. */
  input(i: number): number { return Number(this.#lib.mbane_input(this.#handle!, i)); }
  inputView(i: number): Uint8Array { return new Uint8Array(toArrayBuffer(this.#lib.mbane_input(this.#handle!, i)!, 0, this.inputBytes[i]!)); }
  /** Zero-copy fp16 MLX wrap of input i's whole buffer (at least its
   *  `inputBytes`), locked for writes until the next evaluation (the GPU writes
   *  it through a kernel). Borrowed: the buffers own it, and every program
   *  loaded on them returns the same array, so a caller never disposes it. */
  inputArray(i: number): MlxArray { return this.#surfaces.input(i, this.input(i)); }
  /** Zero-copy fp16 MLX wrap of the whole output buffer, valid until the next
   *  evaluation; borrowed as {@link inputArray}. */
  outputArray(): MlxArray { return this.#surfaces.output(Number(this.#lib.mbane_output(this.#handle!))); }
  /** The output's first `shape` elements as an owned fp16 view (row-major). */
  output(shape: number[]): MlxArray {
    using front = this.outputArray().slice([0], [shape.reduce((a, b) => a * b, 1)]);
    return ops.reshape(front, shape);
  }
  /** Takes `reader` (owned), an array that reads the output lazily: the next
   *  evaluation of any program on these buffers evaluates it first, so an
   *  output is never overwritten before it is read, and then releases it. */
  deferOutput(reader: MlxArray): void { this.#surfaces.defer(reader); }

  /** Starts the evaluation, once a deferred output reader (`deferOutput`) has run. */
  evalAsync(): void {
    if (this.#handle) this.#surfaces.settle();
    if (!this.#lib.mbane_eval_async(this.#handle!)) throw new Error("ANE evaluation already pending");
  }
  wait(): void {
    errorBuffer.fill(0);
    if (!this.#lib.mbane_wait(this.#handle!, ptr(errorBuffer), errorBuffer.length)) throw new Error(errorText());
  }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void {
    if (!this.#handle) return;
    if (--this.#surfaces.holders === 0) this.#surfaces.dispose();
    this.#lib.mbane_free(this.#handle);
    this.#handle = null;
  }
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

/** Reduction slices summed inside a streamed-weight program unless its caller
 *  names others: 8 runs ~2.5x faster than one on M4 Pro. A reduction not
 *  divisible by the slices stays whole. */
const CHUNKS = 8;

/** a[1,1,rows,red] · b[1,1,cols,red]ᵀ → out, the reduction split into `slices`
 *  slices summed inside the program. `tag` keeps value names unique. */
function chunkedMatmulT(lines: string[], out: string, a: string, b: string, rows: number, cols: number, red: number, tag: string,
  slices = CHUNKS): void {
  const chunks = red % slices ? 1 : slices;
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

/** y[S, Cout] = x[S, Cin] · w[Cout, Cin]ᵀ, w streamed (inputs: w=0, x=1), the
 *  reduction in `slices` slices (default CHUNKS). */
export function streamedMatmulProgram(cin: number, cout: number, seq: number, slices = CHUNKS): AneProgramSpec {
  const lines = [`  func main<ios18>(tensor<fp16, [1, 1, ${seq}, ${cin}]> x, tensor<fp16, [1, 1, ${cout}, ${cin}]> w) {`, ...BOOLS];
  chunkedMatmulT(lines, "y", "x", "w", seq, cout, cin, "m", slices);
  return { label: `projection ${cin}→${cout}, ${seq} rows${slices === CHUNKS ? "" : `, ${slices} slices`}`,
    mil: MIL_HEADER + lines.join("\n") + `\n  } -> (y);\n}\n`,
    inputBytes: [cout * cin * 2, seq * cin * 2], outputBytes: seq * cout * 2 };
}

/** One MLP channel slice with streamed weights:
 *  y[S, D] = (silu(x·wgᵀ) ⊙ (x·wuᵀ)) · wd, wg/wu/wd [N, D] (wd: the down
 *  projection's rows for the same N channels), each matmul's reduction in
 *  `slices` slices (default CHUNKS). Inputs in symbol order: wd=0, wg=1, wu=2,
 *  x=3. Measured 10.2 TFLOPS (D 5120, N 9600, S 2048, 8 slices, M4 Pro). */
export function mlpSliceProgram(D: number, N: number, S: number, slices = CHUNKS): AneProgramSpec {
  return { label: `MLP slice ${D}×${N}, ${S} rows${slices === CHUNKS ? "" : `, ${slices} slices`}`, mil: mlpSliceMil(D, N, S, slices),
    inputBytes: [N * D * 2, N * D * 2, N * D * 2, S * D * 2], outputBytes: S * D * 2 };
}

function mlpSliceMil(D: number, N: number, S: number, slices: number): string {
  const lines = [`  func main<ios18>(tensor<fp16, [1, 1, ${N}, ${D}]> wd, tensor<fp16, [1, 1, ${N}, ${D}]> wg, ` +
    `tensor<fp16, [1, 1, ${N}, ${D}]> wu, tensor<fp16, [1, 1, ${S}, ${D}]> x) {`, ...BOOLS];
  chunkedMatmulT(lines, "g", "x", "wg", S, N, D, "G", slices);
  chunkedMatmulT(lines, "u", "x", "wu", S, N, D, "U", slices);
  lines.push(`    tensor<fp16, [1, 1, ${S}, ${N}]> sg = silu(x=g)[name=string("sg")];`,
    `    tensor<fp16, [1, 1, ${S}, ${N}]> h = mul(x=sg, y=u)[name=string("h")];`);
  const chunksDown = N % slices ? 1 : slices;
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

/** INT8 const-weight linear over channel-major activations: y[1, Cout, 1, S],
 *  weights `q` [Cout, Cin] with one fp16 scale (bits) per output row. */
export function int8LinearProgram(cin: number, cout: number, seq: number, q: Int8Array, scales: Uint16Array): AneProgramSpec {
  return { label: `INT8 linear ${cin}→${cout}, ${seq} rows`, mil: int8LinearMil(cin, cout, seq),
    inputBytes: [cin * seq * 2], outputBytes: cout * seq * 2,
    weights: { "weight_data.bin": weightBlob(new Uint8Array(q.buffer, q.byteOffset, q.byteLength)),
      "weight_scale.bin": weightBlob(new Uint8Array(scales.buffer, scales.byteOffset, scales.byteLength)) } };
}

function int8LinearMil(cin: number, cout: number, seq: number): string {
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
  /** Loads `int8LinearProgram(cin, cout, seq, q, scales)`, compiled by the install step. */
  static create(cin: number, cout: number, seq: number, q: Int8Array, scales: Uint16Array, share?: AneLinear): AneLinear {
    if (seq % 32 !== 0) throw new Error(`AneLinear: S=${seq} must be a multiple of 32`);
    return new AneLinear(AneProgram.create(int8LinearProgram(cin, cout, seq, q, scales), share?.program), cin, cout, seq);
  }
  writeInput(bytes: Uint8Array): void { this.program.inputView(0).set(bytes); }
  evalAsync(): void { this.program.evalAsync(); }
  wait(): void { this.program.wait(); }
  output(): MlxArray { return this.program.output([this.cout, this.seq]); }
  [Symbol.dispose](): void { this.dispose(); }
  dispose(): void { this.program.dispose(); }
}

/** Streamed-weight matmul y[S, Cout] = x[S, Cin] · w[Cout, Cin]ᵀ (row-major fp16). */
export class AneStreamedMatmul implements Disposable {
  private constructor(readonly program: AneProgram, readonly cin: number, readonly cout: number, readonly seq: number) {}
  /** Loads `streamedMatmulProgram(cin, cout, seq, slices)`, compiled by the install step. */
  static create(cin: number, cout: number, seq: number, share?: AneStreamedMatmul, slices?: number): AneStreamedMatmul {
    return new AneStreamedMatmul(AneProgram.create(streamedMatmulProgram(cin, cout, seq, slices), share?.program), cin, cout, seq);
  }
  /** The weight buffer [Cout·Cin] and the input buffer [S·Cin], borrowed fp16 wraps (AneProgram.inputArray). */
  weights(): MlxArray { return this.program.inputArray(0); }
  input(): MlxArray { return this.program.inputArray(1); }
  evalAsync(): void { this.program.evalAsync(); }
  wait(): void { this.program.wait(); }
  /** The first `rows` rows of y [S, Cout], an owned fp16 view; valid until the next evaluation. */
  output(rows = this.seq): MlxArray { return this.program.output([rows, this.cout]); }
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
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Ane.Linear
