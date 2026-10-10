import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import { HEADER } from "./codebook";
import type { TrellisGeometry } from "./geometry";

// Verify-width down projection on the simdgroup matrix unit, 1..8 activation
// rows (one block of 8). A simdgroup owns 8·S consecutive positions of one
// 256-position coded block and a split of the input rows. Per 8-row step every
// lane decodes 2S contiguous positions of one input row (its bit window
// realigned once) into the B fragments of S output sub-tiles; the A fragments
// hold x·scale·(1/147.8) and each feeds S multiplies. Sub-tile s, fragment
// column i is position P_g + S·i + s (output column 255 - that, per block).
// SPLITS f32 partials [M, SPLITS, C] fold in one MLX sum. Two kernels, one per
// code layout: row-major [rows, cols·K/32] and the 3-bit block interleave
// [cols/512, rows, 48]. Not bit-identical to the matvec kernels; gate by KL.
const SG_TG = 4, MT = 1, S = 16, SPLITS = 8;

const SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint id = threadgroup_position_in_grid.y * (uint)SG_TG + simdgroup_index_in_threadgroup;
  const uint groupsPerBlock = 32u / (uint)S;
  const uint nGroups = ((uint)C / 256u) * groupsPerBlock;
  if (id >= nGroups * (uint)SPLITS) return;
  const uint cg = id % nGroups, split = id / nGroups;
  const uint block = cg / groupsPerBlock, pg = (cg % groupsPerBlock) * 8u * (uint)S;
  const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
  const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
  const uint wpb = 8u * (uint)K;
  const ulong rowWords = (ulong)(INTERLEAVE ? 2u : (uint)C / 256u) * wpb;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2u) * (ulong)R * 2u * wpb + (block % 2u) * wpb : (ulong)block * wpb);
  // This lane's 2S positions start at p0; realign its bit window to bit 0.
  const uint p0 = pg + (uint)S * fn;
  const uint bit0 = p0 * (uint)K, w0 = bit0 >> 5, off0 = bit0 & 31u;
  const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
  const uint rowsPer = (((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS + 7u) & ~7u;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  metal::simdgroup_float8x8 acc[S][MT];
  #pragma clang loop unroll(full)
  for (uint s = 0; s < (uint)S; ++s)
    #pragma clang loop unroll(full)
    for (uint bk = 0; bk < (uint)MT; ++bk) acc[s][bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  for (uint r = r0; r < r1; r += 8u) {
    const uint rw = r + fm;
    const device uint32_t* rowCodes = words + (ulong)metal::min(rw, (uint)R - 1u) * rowWords;
    uint raw[NW + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)NW; ++i) {
      const uint wi = w0 + i;
      raw[i] = rowCodes[wi % wpb];
    }
    uint w[NW];
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NW; ++i) w[i] = off0 ? (raw[i] >> off0) | (raw[i + 1] << (32u - off0)) : raw[i];
    metal::simdgroup_float8x8 a[MT];
    const uint ra = r + fn;
    const float sa = ra < r1 ? float(scales[ra]) * TRELLIS_RCP : 0.0f;
    const float sb = ra + 1u < r1 ? float(scales[ra + 1u]) * TRELLIS_RCP : 0.0f;
    #pragma clang loop unroll(full)
    for (uint bk = 0; bk < (uint)MT; ++bk) {
      const uint m = mBase + 8u * bk + fm;
      const bool ok = m < (uint)M;
      const device T* xm = x + (ulong)(ok ? m : 0u) * (ulong)R;
      a[bk].thread_elements()[0] = ok && ra < r1 ? float(xm[ra]) * sa : 0.0f;
      a[bk].thread_elements()[1] = ok && ra + 1u < r1 ? float(xm[ra + 1u]) * sb : 0.0f;
    }
    const bool rowOk = rw < r1;
    #pragma clang loop unroll(full)
    for (uint s = 0; s < (uint)S; ++s) {
      metal::simdgroup_float8x8 b;
      b.thread_elements()[0] = rowOk ? trellis_y_f32((block_state<K, L>(w, s))) : 0.0f;
      b.thread_elements()[1] = rowOk ? trellis_y_f32((block_state<K, L>(w, s + (uint)S))) : 0.0f;
      #pragma clang loop unroll(full)
      for (uint bk = 0; bk < (uint)MT; ++bk)
        metal::simdgroup_multiply_accumulate(acc[s][bk], a[bk], b, acc[s][bk]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    const uint m = mBase + 8u * bk + fm;
    if (m >= (uint)M) continue;
    device float* out = partial + ((ulong)m * (ulong)SPLITS + split) * (ulong)C + (ulong)block * 256u + 255u - p0;
    #pragma clang loop unroll(full)
    for (uint s = 0; s < (uint)S; ++s) {
      out[-(int)s] = acc[s][bk].thread_elements()[0];
      out[-(int)((uint)S + s)] = acc[s][bk].thread_elements()[1];
    }
  }
`;

// State at position t of a realigned window (bit t·K of w, LSB first).
const STATE_HEADER = String.raw`
template <int K, int L_>
inline uint block_state(thread const uint* w, uint t) {
  const uint b = t * (uint)K;
  const uint wi = b >> 5;
  const uint off = b & 31u;
  uint win = w[wi] >> off;
  if (off + (uint)L_ > 32u) win |= w[wi + 1] << (32u - off);
  return win & ((1u << (uint)L_) - 1u);
}
`;


function launch(kernel: MetalKernel, x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, interleave: 0 | 1): MlxArray {
  const M = x2.shape[0]!;
  if (M < 1 || M > 8) throw new Error(`downMma: M=${M} outside 1..8`);
  if (g.axis !== 0 || g.T !== 256 || g.cols % 256 !== 0 || g.L > 12) throw new Error("downMma: unsupported geometry");
  const nGroups = (g.cols / 256) * (32 / S);
  // Words covering 2S positions plus the L-bit window, after realignment.
  const NW = Math.ceil((2 * S * g.k + g.L - 1) / 32) + 1;
  const [partial] = kernel.apply([x2, codes, scales], {
    outputs: [{ shape: [M, SPLITS, g.cols], dtype: Dtype.float32 }],
    grid: [32 * SG_TG, Math.ceil((nGroups * SPLITS) / SG_TG), 1], threadGroup: [32 * SG_TG, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { M, R: g.rows, C: g.cols, K: g.k, L: g.L, SPLITS, SG_TG, INTERLEAVE: interleave, MT, S, NW },
  });
  const sum = ops.sumAxis(partial!, 1, false);
  partial!.dispose();
  const out = sum.astype(x2.dtype);
  sum.dispose();
  return out;
}

let rowMajor: MetalKernel | undefined, interleaved: MetalKernel | undefined;

/** x2 [M, inFeatures] · W → [M, outFeatures] in x2's dtype for row-major
 *  axis-0 codes (T 256). Borrows inputs. */
export function downMma(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  if (g.blockInterleave || codes.ndim !== 2) throw new Error("downMma: needs row-major codes");
  rowMajor ??= new MetalKernel({ name: "mlx_bun_trellis_down_mma", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: SOURCE, header: HEADER + STATE_HEADER, ensureRowContiguous: true });
  return launch(rowMajor, x2, codes, scales, g, 0);
}

/** downMma for 3-bit block-interleaved codes [cols/512, rows, 48]. */
export function downK3InterleavedMma(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  if (g.blockInterleave !== 2 || g.k !== 3) throw new Error("downK3InterleavedMma: needs 3-bit block-interleaved codes");
  interleaved ??= new MetalKernel({ name: "mlx_bun_trellis_down_k3i_mma", inputNames: ["x", "codes", "scales"],
    outputNames: ["partial"], source: SOURCE, header: HEADER + STATE_HEADER, ensureRowContiguous: true });
  return launch(interleaved, x2, codes, scales, g, 1);
}
