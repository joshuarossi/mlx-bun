import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import { HEADER } from "../trellis/codebook";
import type { TrellisGeometry } from "../trellis/geometry";

// Fill an ANE weight buffer straight from Trellis codes: the vector-expand
// decode (four weights per thread from one circular word window, the same
// trellis_val_rcp · scale values) of stored rows [0, ROWS) written as fp16 at
// OFFSET into `dst`, a zero-copy MLX wrap of the ANE IOSurface. Reads the full
// code tensor, so block-interleaved axis-0 codes need no slicing copy. `dst` is
// an MLX input the kernel writes through; `done` only carries the dependency.
// One kernel per code layout: row-major [rows, cols·K/32] and the 3-bit block
// interleave [cols/512, rows, 48].
const ROW_MAJOR_SOURCE = String.raw`
  const uint c = thread_position_in_grid.x * 4u;
  const uint r = thread_position_in_grid.y;
  if (c >= (uint)C || r >= (uint)ROWS) return;
  constexpr uint wpb = BT * BITS / 32;
  const uint block = c / BT, t = c % BT;
  const device uint* bw = codes + (ulong)r * (C / BT) * wpb + block * wpb;
  const float scale = float(scales[r]);
  const uint pos = (BT - 1 - (t + 3)) * BITS, wi = pos >> 5, off = pos & 31u;
  const ulong window = (ulong(bw[wi]) | (ulong(bw[wi + 1 == wpb ? 0 : wi + 1]) << 32)) >> off;
  device half* out = (device half*)dst + (ulong)OFFSET + (ulong)r * (uint)C + c;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 4u; i++) {
    const uint s = uint(window >> ((3 - i) * BITS)) & ((1u << L) - 1);
    out[i] = half(trellis_val_rcp(s) * scale);
  }
  if (c == 0u && r == 0u) done[0] = 1;
`;

const K3_INTERLEAVED_SOURCE = String.raw`
  const uint c = thread_position_in_grid.x * 4u;
  const uint r = thread_position_in_grid.y;
  if (c >= (uint)C || r >= (uint)ROWS) return;
  constexpr uint wpb = BT * BITS / 32;
  const uint block = c / BT, t = c % BT;
  const device uint* bw = codes + (ulong)(block / 2) * (ulong)R * 2 * wpb + (ulong)r * 2 * wpb + (block % 2) * wpb;
  const float scale = float(scales[r]);
  const uint pos = (BT - 1 - (t + 3)) * BITS, wi = pos >> 5, off = pos & 31u;
  const ulong window = (ulong(bw[wi]) | (ulong(bw[wi + 1 == wpb ? 0 : wi + 1]) << 32)) >> off;
  device half* out = (device half*)dst + (ulong)OFFSET + (ulong)r * (uint)C + c;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 4u; i++) {
    const uint s = uint(window >> ((3 - i) * BITS)) & ((1u << L) - 1);
    out[i] = half(trellis_val_rcp(s) * scale);
  }
  if (c == 0u && r == 0u) done[0] = 1;
`;

let rowMajor: MetalKernel | undefined, interleaved: MetalKernel | undefined;

export function trellisFillEligible(g: TrellisGeometry): boolean {
  return g.L === 12 && g.T === 256 && (g.k === 2 || g.k === 3 || g.k === 4) && g.cols % 256 === 0 && !g.blockInterleave;
}
export function trellisFillK3InterleavedEligible(g: TrellisGeometry): boolean {
  return g.L === 12 && g.T === 256 && g.k === 3 && g.cols % 512 === 0 && g.blockInterleave === 2;
}

function launch(kernel: MetalKernel, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, rows: number, dst: MlxArray, offset: number): MlxArray {
  const [done] = kernel.apply([codes, scales, dst], {
    outputs: [{ shape: [1], dtype: Dtype.int32 }],
    grid: [g.cols / 4, rows, 1], threadGroup: [128, 1, 1],
    templateInts: { R: g.rows, ROWS: rows, C: g.cols, BT: g.T, BITS: g.k, L: g.L, OFFSET: offset },
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
