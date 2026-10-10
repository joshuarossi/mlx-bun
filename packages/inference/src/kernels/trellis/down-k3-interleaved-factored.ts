import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisGeometry } from "./geometry";
import { HEADER } from "./codebook";
import { TRELLIS_THREADS, TRELLIS_SG_PER_TG } from "./launch";

// Axis-0 (down) projections over 3-bit Trellis codes in the block-interleaved
// layout [cols/512, rows, 48] (T 256, L 12): every lane owns 8 consecutive
// positions (24 bits) of one block, so all 32 lanes are busy. The input scale
// is factored out: each input row's activation is pre-multiplied by
// scale·(1/147.8) and weights contribute their code value y. Split-K over
// input rows into SPLITS f32 partials folded by one MLX sum. Same traversal as
// the balanced trellisScatter; reassociated relative to its f32 code·scale
// weights (not bit-identical; gate by KL).
const SPLITS = 128, K = 3, BT = 256, L = 12, WPB = BT * K / 32;

// One activation row.
const ROW_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / ${BT}u;
  const uint split = thread_position_in_grid.z;
  if (block >= nBlocks) return;
  const ulong rowWords = 2ul * ${WPB}u;
  const uint pBase = lane * 8u * ${K}u;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == ${WPB}u) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (ulong)(block / 2) * R * 2 * ${WPB}u + (block % 2) * ${WPB}u;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  float acc[8];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    const float xr = float(x[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * ${K}u;
      uint win = lo >> shift;
      if (shift + ${L}u > 32u) win |= hi << (32u - shift);
      win &= (1u << ${L}u) - 1u;
      acc[i] = metal::fma(trellis_y_f32(win), xr * (sr * TRELLIS_RCP), acc[i]);
    }
  }
  const ulong outBase = (ulong)split * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i)
    partial[outBase + block * ${BT}u + ${BT - 1}u - lane * 8u - i] = acc[i];
`;

// M activation rows sharing each decoded weight.
const ROWS_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / ${BT}u;
  const uint split = thread_position_in_grid.z;
  if (block >= nBlocks) return;
  const ulong rowWords = 2ul * ${WPB}u;
  const uint pBase = lane * 8u * ${K}u;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == ${WPB}u) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (ulong)(block / 2) * R * 2 * ${WPB}u + (block % 2) * ${WPB}u;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  float acc[M][8];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) acc[m][i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    float xr[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]) * (float(scales[r]) * TRELLIS_RCP);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * ${K}u;
      uint win = lo >> shift;
      if (shift + ${L}u > 32u) win |= hi << (32u - shift);
      win &= (1u << ${L}u) - 1u;
      const float weight = trellis_y_f32(win);
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i)
      partial[outBase + block * ${BT}u + ${BT - 1}u - lane * 8u - i] = acc[m][i];
  }
`;

let rowKernel: MetalKernel | undefined, rowsKernel: MetalKernel | undefined;

function launch(kernel: MetalKernel, x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, M: number): MlxArray {
  if (g.axis !== 0 || g.blockInterleave !== 2 || g.k !== K || g.T !== BT || g.L !== L)
    throw new Error("downK3InterleavedFactored: needs 3-bit block-interleaved axis-0 codes (T 256, L 12)");
  const [partial] = kernel.apply([x2, codes, scales], {
    outputs: [{ shape: [M, SPLITS, g.cols], dtype: Dtype.float32 }],
    grid: [TRELLIS_THREADS, Math.ceil(g.cols / BT / TRELLIS_SG_PER_TG), SPLITS],
    threadGroup: [TRELLIS_THREADS, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { M, R: g.rows, C: g.cols, SG_TG: TRELLIS_SG_PER_TG, SPLITS },
  });
  const sum = ops.sumAxis(partial!, 1, false);
  partial!.dispose();
  const out = sum.astype(x2.dtype);
  sum.dispose();
  return out;
}

/** x2 [1, inFeatures] · W → [1, outFeatures] in x2's dtype. Borrows inputs. */
export function downK3InterleavedFactoredRow(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  if (x2.shape[0] !== 1) throw new Error("downK3InterleavedFactoredRow: expects one activation row");
  rowKernel ??= new MetalKernel({ name: "mlx_bun_trellis_down_k3i_factored_row", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: ROW_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowKernel, x2, codes, scales, g, 1);
}

/** x2 [M, inFeatures] · W → [M, outFeatures] for 2..4 rows sharing each
 *  decoded weight. Borrows inputs. */
export function downK3InterleavedFactoredRows(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  const M = x2.shape[0]!;
  if (M < 2 || M > 4) throw new Error(`downK3InterleavedFactoredRows: M=${M} outside 2..4`);
  rowsKernel ??= new MetalKernel({ name: "mlx_bun_trellis_down_k3i_factored_rows", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: ROWS_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowsKernel, x2, codes, scales, g, M);
}
