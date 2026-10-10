import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisGeometry } from "./geometry";
import { HEADER, wordsPerBlock } from "./codebook";
import { TRELLIS_THREADS, TRELLIS_SG_PER_TG } from "./launch";

// Axis-0 (down) projections over row-major Trellis codes [rows, cols·K/32]
// with the input scale factored out: each input row's activation is
// pre-multiplied by scale·(1/147.8) and weights contribute their code value y
// (trellis_y_f32). Lane-per-word of a block with running sums per position,
// split-K over input rows into SPLITS f32 partials that one MLX sum folds.
// Same traversal as trellisScatter; reassociated relative to its f32
// code·scale weights (not bit-identical; gate by KL).
const SPLITS = 128;

// One activation row.
const ROW_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint split = thread_position_in_grid.z;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks);
  const uint nbrLane = bi * wpb + ((wi + 1u == wpb) ? 0u : wi + 1u);
  // This lane's positions: symbol offsets p = multiples of K inside [32wi, 32wi+32).
  const uint pBase = 32u * wi;
  const uint p0 = ((pBase + (uint)K - 1u) / (uint)K) * (uint)K;
  uint offs[NP];
  bool valid[NP];
  bool spill[NP];
  uint cols[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) {
    const uint p = p0 + i * (uint)K;
    valid[i] = active && (p < pBase + 32u);
    offs[i] = p - pBase;
    spill[i] = offs[i] + (uint)L > 32u;
    const uint t = (uint)BT - 1u - p / (uint)K;
    cols[i] = blk * (uint)BT + t;
  }
  const ulong rowWords = (ulong)nBlocks * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device uint32_t* col0 = codes + (ulong)blk * wpb + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    const float xr = float(x[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      acc[i] = metal::fma(trellis_y_f32(win), xr * (sr * TRELLIS_RCP), acc[i]);
    }
  }
  const ulong outBase = (ulong)split * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i)
    if (valid[i]) partial[outBase + cols[i]] = acc[i];
`;

// M activation rows sharing each decoded weight.
const ROWS_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint split = thread_position_in_grid.z;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks);
  const uint nbrLane = bi * wpb + ((wi + 1u == wpb) ? 0u : wi + 1u);
  const uint pBase = 32u * wi;
  const uint p0 = ((pBase + (uint)K - 1u) / (uint)K) * (uint)K;
  uint offs[NP];
  bool valid[NP];
  bool spill[NP];
  uint cols[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) {
    const uint p = p0 + i * (uint)K;
    valid[i] = active && (p < pBase + 32u);
    offs[i] = p - pBase;
    spill[i] = offs[i] + (uint)L > 32u;
    const uint t = (uint)BT - 1u - p / (uint)K;
    cols[i] = blk * (uint)BT + t;
  }
  const ulong rowWords = (ulong)nBlocks * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device uint32_t* col0 = codes + (ulong)blk * wpb + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[M][NP];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) acc[m][i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    float xr[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]) * (float(scales[r]) * TRELLIS_RCP);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      const float weight = trellis_y_f32(win);
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i)
      if (valid[i]) partial[outBase + cols[i]] = acc[m][i];
  }
`;

let rowKernel: MetalKernel | undefined, rowsKernel: MetalKernel | undefined;

function launch(kernel: MetalKernel, x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, M: number): MlxArray {
  if (g.axis !== 0 || g.blockInterleave || codes.ndim !== 2) throw new Error("downFactored: needs row-major axis-0 codes");
  const wpb = wordsPerBlock(g.T, g.k), nb = Math.floor(32 / wpb);
  if (nb < 1) throw new Error(`downFactored: block of ${wpb} words exceeds one SIMD group`);
  const groups = Math.ceil((g.cols / g.T) / nb);
  const [partial] = kernel.apply([x2, codes, scales], {
    outputs: [{ shape: [M, SPLITS, g.cols], dtype: Dtype.float32 }],
    grid: [TRELLIS_THREADS, Math.ceil(groups / TRELLIS_SG_PER_TG), SPLITS],
    threadGroup: [TRELLIS_THREADS, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, SG_TG: TRELLIS_SG_PER_TG, SPLITS, NP: Math.ceil(32 / g.k) },
  });
  const sum = ops.sumAxis(partial!, 1, false);
  partial!.dispose();
  const out = sum.astype(x2.dtype);
  sum.dispose();
  return out;
}

/** x2 [1, inFeatures] · W → [1, outFeatures] in x2's dtype. Borrows inputs. */
export function downFactoredRow(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  if (x2.shape[0] !== 1) throw new Error("downFactoredRow: expects one activation row");
  rowKernel ??= new MetalKernel({ name: "mlx_bun_trellis_down_factored_row", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: ROW_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowKernel, x2, codes, scales, g, 1);
}

/** x2 [M, inFeatures] · W → [M, outFeatures] for 2..4 rows sharing each
 *  decoded weight. Borrows inputs. */
export function downFactoredRows(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  const M = x2.shape[0]!;
  if (M < 2 || M > 4) throw new Error(`downFactoredRows: M=${M} outside 2..4`);
  rowsKernel ??= new MetalKernel({ name: "mlx_bun_trellis_down_factored_rows", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: ROWS_SOURCE, header: HEADER, ensureRowContiguous: true });
  return launch(rowsKernel, x2, codes, scales, g, M);
}
