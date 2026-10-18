import host.ts.Source
namespace Host.Ts.Sources.Inference.Kernels.Trellis.Scatter
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/kernels/trellis/scatter.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisGeometry } from "./geometry";
import { HEADER, lutFor, decoderVariant, wordsPerBlock } from "./codebook";
import { TRELLIS_THREADS } from "./launch";
import { qualifiedRepresentations, type ScatterRepresentation } from "./qualified";

const SCATTER_SPLITS = 128;

const SCATTER_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2 || FLOAT_CODEBOOK) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += (uint)THREADS)
      lutTG[i] = FLOAT_CODEBOOK ? trellis_unrefined_bits_y(trellis_y(i)) : lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint zi = thread_position_in_grid.z;
  const uint sample = zi / (uint)SPLITS;
  const uint split = zi - sample * (uint)SPLITS;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks) && (sample < (uint)M);
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
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device T* xs = x + (ulong)sample * (ulong)R;
  const device uint32_t* col0 = codes + (INTERLEAVE
    ? (ulong)(blk / 2) * R * 2 * wpb + (blk % 2) * wpb : (ulong)blk * wpb) + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    const float xr = float(xs[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      const float value = FLOAT_CODEBOOK ? lutTG[win] : (BITS_Y ? trellis_unrefined_bits_y(trellis_y(win)) : TRELLIS_DECODE(win, lutTG, lut));
      acc[i] = metal::fma(TRELLIS_ROUND(value * sr), xr, acc[i]);
    }
  }
  const ulong outBase = ((ulong)sample * (ulong)SPLITS + split) * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i)
    if (valid[i]) partial[outBase + cols[i]] = acc[i];
`;

const BALANCED_SCATTER_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if (FLOAT_CODEBOOK) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += (uint)THREADS)
      lutTG[i] = trellis_unrefined_bits_y(trellis_y(i));
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / (uint)BT;
  const uint zi = thread_position_in_grid.z;
  const uint sample = zi / (uint)SPLITS;
  const uint split = zi - sample * (uint)SPLITS;
  if (block >= nBlocks || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint pBase = lane * 8u * (uint)K;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == wpb) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2) * R * 2 * wpb + (block % 2) * wpb : (ulong)block * wpb);
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device T* xs = x + (ulong)sample * (ulong)R;
  float acc[8];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    const float xr = float(xs[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * (uint)K;
      uint win = lo >> shift;
      if (shift + (uint)L > 32u) win |= hi << (32u - shift);
      win &= (1u << (uint)L) - 1u;
      const int y = trellis_y(win);
      const float value = FLOAT_CODEBOOK ? lutTG[win] : (BITS_Y ? trellis_unrefined_bits_y(y) : trellis_unrefined_y(y));
      acc[i] = metal::fma(value * sr, xr, acc[i]);
    }
  }
  const ulong outBase = ((ulong)sample * (ulong)SPLITS + split) * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i)
    partial[outBase + block * (uint)BT + (uint)BT - 1u - lane * 8u - i] = acc[i];
`;

const SCATTER_SHARED_M_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += ${TRELLIS_THREADS}u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint zi = thread_position_in_grid.z;
  const uint sample = 0u;
  const uint split = zi;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks) && (sample < (uint)M);
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
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);

  const device uint32_t* col0 = codes + (INTERLEAVE
    ? (ulong)(blk / 2) * R * 2 * wpb + (blk % 2) * wpb : (ulong)blk * wpb) + wi;
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
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      const float weight = TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * sr);
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

const BALANCED_SCATTER_SHARED_M_SOURCE = String.raw`
  // Model-owned tuning selects this table for measured small-M shapes.
  // Store integers so the reciprocal multiply retains its original rounding.
  threadgroup short codebookY[CODEBOOK ? 4096 : 1];
  if (CODEBOOK) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += threads_per_threadgroup.x)
      codebookY[i] = (short)trellis_y(i);
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / (uint)BT;
  const uint zi = thread_position_in_grid.z;
  const uint sample = 0u;
  const uint split = zi;
  if (block >= nBlocks || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint pBase = lane * 8u * (uint)K;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == wpb) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2) * R * 2 * wpb + (block % 2) * wpb : (ulong)block * wpb);
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
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * (uint)K;
      uint win = lo >> shift;
      if (shift + (uint)L > 32u) win |= hi << (32u - shift);
      win &= (1u << (uint)L) - 1u;
      const float value = trellis_unrefined_y(CODEBOOK ? (int)codebookY[win] : trellis_y(win));
      const float weight = value * sr;
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i)
      partial[outBase + block * (uint)BT + (uint)BT - 1u - lane * 8u - i] = acc[m][i];
  }
`;

let balancedScatter: MetalKernel | null = null;
let sharedScatter: { generic: MetalKernel; balanced: MetalKernel } | null = null;
function sharedScatterKernelSet() {
  return sharedScatter ??= {
    generic: new MetalKernel({
      name: "mlx_bun_trellis_scatter_shared_m", inputNames: ["x", "codes", "scales", "lut"],
      outputNames: ["partial"], source: SCATTER_SHARED_M_SOURCE, header: HEADER, ensureRowContiguous: true,
    }),
    balanced: new MetalKernel({
      name: "mlx_bun_trellis_scatter_balanced3_shared_m", inputNames: ["x", "codes", "scales", "lut"],
      outputNames: ["partial"], source: BALANCED_SCATTER_SHARED_M_SOURCE, header: HEADER, ensureRowContiguous: true,
    }),
  };
}
function balancedScatterKernel() {
  return balancedScatter ??= new MetalKernel({
    name: "mlx_bun_trellis_scatter_balanced3", inputNames: ["x", "codes", "scales", "lut"],
    outputNames: ["partial"], source: BALANCED_SCATTER_SOURCE, header: HEADER, ensureRowContiguous: true,
  });
}
let base: MetalKernel | undefined;
function scatterKernel(): MetalKernel {
  return base ??= new MetalKernel({ name: "mlx_bun_trellis_scatter",
    inputNames: ["x", "codes", "scales", "lut"], outputNames: ["partial"],
    source: SCATTER_SOURCE, header: HEADER, ensureRowContiguous: true });
}

/** Geometry qualified for the single-row exact-representation kernels. */
export function scatterBitsEligible(g: TrellisGeometry, m: number, dtype: Dtype, selected: number): boolean {
  return selected === 13 && m === 1 && dtype === Dtype.bfloat16 && g.axis === 0 &&
    g.T === 256 && g.L === 12 && g.rows === 17408 && g.cols === 5120 &&
    (g.k === 3 ? g.blockInterleave === 2 : (g.k === 2 || g.k === 4) && !g.blockInterleave);
}

/** Keep the generated float table behind the measured M1 geometry. */
export function scatterFloatCodebookEligible(g: TrellisGeometry, m: number, dtype: Dtype, selected: number,
  architecture: string): boolean {
  return qualifiedRepresentations(architecture).scatter.floatCodebook && scatterBitsEligible(g, m, dtype, selected);
}

/** Variants 8..13 decode 3-bit codes at T 256, L <= 12 with the balanced kernels. */
const balancedFor = (g: TrellisGeometry, selected: number) => selected >= 8 && selected <= 13 && g.k === 3 && g.T === 256 && g.L <= 12;
/** Variants 10..13 share each decoded weight across rows. */
const sharesRows = (selected: number) => selected >= 10 && selected <= 13;
/** The shared-row codebook at 3..4 bf16 rows of the 3-bit block interleave (variant 13), where the layer composes it. */
const sharedCodebookShape = (g: TrellisGeometry, M: number, dtype: Dtype, selected: number) => selected === 13 &&
  (M === 3 || M === 4) && dtype === Dtype.bfloat16 && g.k === 3 && g.L === 12 && g.T === 256 && g.blockInterleave === 2;

/** One activation row of axis-0 codes the balanced kernels do not take (`scatterRow`'s kernel, `SCATTER_SOURCE`):
 * borrow [1, inFeatures]; return owned lazy [1, outFeatures]. `representation` applies where
 * `scatterBitsEligible` holds; layers pass the one they resolved at construction. */
export function scatterRow(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number,
  representation: ScatterRepresentation): MlxArray {
  if (x2.shape[0] !== 1) throw new Error("scatterRow: expects one activation row");
  if (balancedFor(g, selected)) throw new Error("scatterRow: 3-bit codes at T 256 take balancedScatterRow");
  const qualified = scatterBitsEligible(g, 1, x2.dtype, selected);
  return launch(scatterKernel(), x2, codes, scales, g, selected, false,
    qualified && (g.k === 2 || g.k === 4) && representation.genericBits, qualified && representation.floatCodebook, false);
}

/** One activation row of 3-bit axis-0 codes at T 256 (`BALANCED_SCATTER_SOURCE`, variants 8..13). */
export function balancedScatterRow(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number,
  representation: ScatterRepresentation): MlxArray {
  if (x2.shape[0] !== 1) throw new Error("balancedScatterRow: expects one activation row");
  if (!balancedFor(g, selected)) throw new Error("balancedScatterRow: needs 3-bit codes at T 256, L <= 12 (variants 8..13)");
  const qualified = scatterBitsEligible(g, 1, x2.dtype, selected);
  return launch(balancedScatterKernel(), x2, codes, scales, g, selected, false,
    qualified && representation.bits, qualified && representation.floatCodebook, false);
}

/** 2..4 activation rows sharing each decoded weight (variants 10..13) of axis-0 codes the balanced kernels do not take. */
export function scatterRows(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number): MlxArray {
  const M = x2.shape[0]!;
  if (M < 2 || M > 4) throw new Error(`scatterRows: M=${M} outside 2..4`);
  if (!sharesRows(selected) || balancedFor(g, selected)) throw new Error("scatterRows: needs a row-sharing variant (10..13) and codes the balanced kernels do not take");
  return launch(sharedScatterKernelSet().generic, x2, codes, scales, g, selected, true, false, false, false);
}

/** 2..4 activation rows sharing each decoded weight of 3-bit axis-0 codes at T 256 (variants 10..13);
 * `sharedCodebook` applies at three and four bf16 rows of the block interleave (layers pass what they composed). */
export function balancedScatterRows(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number,
  sharedCodebook: boolean): MlxArray {
  const M = x2.shape[0]!;
  if (M < 2 || M > 4) throw new Error(`balancedScatterRows: M=${M} outside 2..4`);
  if (!sharesRows(selected) || !balancedFor(g, selected)) throw new Error("balancedScatterRows: needs a row-sharing variant (10..13) and 3-bit codes at T 256");
  return launch(sharedScatterKernelSet().balanced, x2, codes, scales, g, selected, true, false, false,
    sharedCodebook && sharedCodebookShape(g, M, x2.dtype, selected));
}

/** Borrow [M, inFeatures] and axis-0 weights; return owned lazy [M, outFeatures].
 * The caller selects a supported variant and limits M to 1..4. `representation`
 * applies where `scatterBitsEligible` holds; layers pass the one they resolved
 * at construction (`qualifiedRepresentations`), benches and tests the one they compare. */
export function trellisScatter(x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number,
  useSharedScatterCodebook: boolean, representation: ScatterRepresentation): MlxArray {
  const M = x2.shape[0]!;
  const balanced = balancedFor(g, selected);
  const shared = sharesRows(selected) && M > 1;
  const qualifiedShape = scatterBitsEligible(g, M, x2.dtype, selected);
  const bitsY = qualifiedShape && (balanced ? representation.bits
    : (g.k === 2 || g.k === 4) && representation.genericBits);
  const floatCodebook = qualifiedShape && representation.floatCodebook;
  const codebook = useSharedScatterCodebook && sharedCodebookShape(g, M, x2.dtype, selected);
  const kernel = shared
    ? balanced ? sharedScatterKernelSet().balanced : sharedScatterKernelSet().generic
    : balanced ? balancedScatterKernel() : scatterKernel();
  return launch(kernel, x2, codes, scales, g, selected, shared, bitsY, floatCodebook, codebook);
}

function launch(kernel: MetalKernel, x2: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry, selected: number,
  shared: boolean, bitsY: boolean, floatCodebook: boolean, codebook: boolean): MlxArray {
  const M = x2.shape[0]!;
  const wpb = wordsPerBlock(g.T, g.k);
  const nb = Math.floor(32 / wpb);
  if (nb < 1) throw new Error(`trellis scatter: block of ${wpb} words exceeds one SIMD group`);
  const groups = Math.ceil((g.cols / g.T) / nb);
  const NP = Math.ceil(32 / g.k);
  const threads = floatCodebook ? (g.k === 3 ? 512 : g.k === 4 ? 256 : 128) : TRELLIS_THREADS;
  const groupsPerThreadgroup = threads / 32;
  const [partial] = kernel.apply([x2, codes, scales, lutFor(g.L)], {
    outputs: [{ shape: [M, SCATTER_SPLITS, g.cols], dtype: Dtype.float32 }],
    grid: [threads, Math.ceil(groups / groupsPerThreadgroup), (shared ? 1 : M) * SCATTER_SPLITS],
    threadGroup: [threads, 1, 1],
    templateDtypes: { T: x2.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, SG_TG: groupsPerThreadgroup,
      SPLITS: SCATTER_SPLITS, NP, VARIANT: decoderVariant(selected), INTERLEAVE: g.blockInterleave ?? 0, CODEBOOK: Number(codebook), BITS_Y: Number(bitsY),
      FLOAT_CODEBOOK: Number(floatCodebook), THREADS: threads },
  });
  const sum = ops.sumAxis(partial!, 1, false);
  partial!.dispose();
  const out = sum.astype(x2.dtype);
  sum.dispose();
  return out;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Kernels.Trellis.Scatter
