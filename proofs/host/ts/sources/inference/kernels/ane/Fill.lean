import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Ane.Fill
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/ane/fill.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import { HEADER } from "../trellis/codebook";
import type { TrellisGeometry } from "../trellis/geometry";

// Fill an ANE weight buffer straight from Trellis codes: the vector-expand
// decode (four weights from one circular word window, the same
// trellis_val_rcp · scale values) of stored rows [0, ROWS) written as fp16 at
// OFFSET into `dst`, a zero-copy MLX wrap of the ANE IOSurface. Each thread
// decodes PER consecutive weights of a row, each four from one window and
// stored as one half4 (OFFSET a multiple of 4). Reads the full code tensor, so
// block-interleaved axis-0 codes need no slicing copy. `dst` is an MLX input
// the kernel writes through; `done` only carries the dependency. One kernel
// per code layout: row-major [rows, cols·K/32] and the 3-bit block interleave
// [cols/512, rows, 48].

/** The kernel body for one code layout, `blockWords` the address of the PER weights' code block. */
const source = (blockWords: string) => String.raw`
  const uint c = thread_position_in_grid.x * PER;
  const uint r = thread_position_in_grid.y;
  if (c >= (uint)C || r >= (uint)ROWS) return;
  constexpr uint wpb = BT * BITS / 32;
  const uint block = c / BT, t = c % BT;
  const device uint* bw = ${blockWords};
  const float scale = float(scales[r]);
  device half4* out = (device half4*)((device half*)dst + (ulong)OFFSET + (ulong)r * (uint)C + c);
  #pragma clang loop unroll(full)
  for (uint q = 0; q < PER / 4; q++) {
    const uint pos = (BT - 1 - (t + 4 * q + 3)) * BITS, wi = pos >> 5, off = pos & 31u;
    const ulong window = (ulong(bw[wi]) | (ulong(bw[wi + 1 == wpb ? 0 : wi + 1]) << 32)) >> off;
    half4 v;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 4u; i++) v[i] = half(trellis_val_rcp(uint(window >> ((3 - i) * BITS)) & ((1u << L) - 1)) * scale);
    out[q] = v;
  }
  if (c == 0u && r == 0u) done[0] = 1;
`;
const ROW_MAJOR_SOURCE = source("codes + (ulong)r * (C / BT) * wpb + block * wpb");
const K3_INTERLEAVED_SOURCE = source("codes + (ulong)(block / 2) * (ulong)R * 2 * wpb + (ulong)r * 2 * wpb + (block % 2) * wpb");

let rowMajor: MetalKernel | undefined, interleaved: MetalKernel | undefined;

export function trellisFillEligible(g: TrellisGeometry): boolean {
  return g.L === 12 && g.T === 256 && (g.k === 2 || g.k === 3 || g.k === 4) && g.cols % 256 === 0 && !g.blockInterleave;
}
export function trellisFillK3InterleavedEligible(g: TrellisGeometry): boolean {
  return g.L === 12 && g.T === 256 && g.k === 3 && g.cols % 512 === 0 && g.blockInterleave === 2;
}

/** Weights per thread by code width, measured on the M1 Max over one layer's 5888 rows: at 16, the 2-bit gate fills
 *  in 0.45 ms, the 3-bit gate in 0.79 and the 3-bit interleaved down in 0.72, against 0.57, 0.95 and 1.01 at four
 *  weights and four half stores per thread (the same values); the 4-bit gate in 0.51 at 8, against 0.97 at four and
 *  0.70 at 16. */
const perThread = (g: TrellisGeometry) => g.k === 4 ? 8 : 16;

function launch(kernel: MetalKernel, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number): MlxArray {
  if (offset % 4) throw new Error(`ANE fill: offset ${offset} is not a multiple of 4 (half4 stores)`);
  const per = perThread(g);
  const [done] = kernel.apply([codes, scales, dst], {
    outputs: [{ shape: [1], dtype: Dtype.int32 }],
    grid: [g.cols / per, rows, 1], threadGroup: [128, 1, 1],
    templateInts: { R: g.rows, ROWS: rows, C: g.cols, BT: g.T, BITS: g.k, L: g.L, OFFSET: offset, PER: per },
  });
  return done!;
}

/** Decode stored rows [0, rows) of row-major codes into dst[OFFSET + r·C + c] (fp16). */
export function trellisFillHalf(codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number): MlxArray {
  if (!trellisFillEligible(g)) throw new Error("trellisFillHalf: needs row-major codes (L 12, T 256)");
  rowMajor ??= new MetalKernel({ name: "mlx_bun_ane_trellis_fill", inputNames: ["codes", "scales", "dst"], outputNames: ["done"],
    source: ROW_MAJOR_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowMajor, codes, scales, g, rows, dst, offset);
}

/** trellisFillHalf for 3-bit block-interleaved codes [cols/512, rows, 48]. */
export function trellisFillHalfK3Interleaved(codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number): MlxArray {
  if (!trellisFillK3InterleavedEligible(g)) throw new Error("trellisFillHalfK3Interleaved: needs 3-bit block-interleaved codes");
  interleaved ??= new MetalKernel({ name: "mlx_bun_ane_trellis_fill_k3i", inputNames: ["codes", "scales", "dst"], outputNames: ["done"],
    source: K3_INTERLEAVED_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(interleaved, codes, scales, g, rows, dst, offset);
}

// Copy src (any float dtype) as fp16 into dst at OFFSET (elements): the
// activation and dequantized-weight writes into ANE input buffers.
const WRITE_SOURCE = String.raw`
  const uint i = thread_position_in_grid.x;
  if (i < (uint)N) ((device half*)dst)[OFFSET + i] = half(float(src[i]));
  if (i == 0u) done[0] = 1;
`;
let writer: MetalKernel | undefined;

/** dst[OFFSET + i] = half(src[i]) for every element of src; `done` carries the dependency. */
export function writeHalf(dst: MlxArray, src: MlxArray, offset: number): MlxArray {
  writer ??= new MetalKernel({ name: "mlx_bun_ane_write_half", inputNames: ["src", "dst"], outputNames: ["done"],
    source: WRITE_SOURCE, ensureRowContiguous: true });
  const [done] = writer.apply([src, dst], { outputs: [{ shape: [1], dtype: Dtype.int32 }],
    grid: [Math.ceil(src.size / 256) * 256, 1, 1], threadGroup: [256, 1, 1],
    templateDtypes: { T: src.dtype }, templateInts: { N: src.size, OFFSET: offset } });
  return done!;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Ane.Fill
