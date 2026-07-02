// SHELVED RESEARCH KERNEL (2026-07-02) — custom gather-qmv for the 26B MoE
// decode, built to capture the ~4 ms/tok gather_qmm M=1 gap found by
// moe-expert-read-profile.ts. CORRECT (bounded divergence vs ops.gatherQmm on
// all three 26B dispatch patterns — moe-qmv-parity.ts) but SLOWER than
// gather_qmm across five structural variants, and the post-mortem shows the
// route is structurally capped from the JS layer:
//
//   variant (structure)                                    ms/step (30-layer chain)
//   v1  4 rows/TG, row-major TG x, per-elem shifts           12.5
//   v2  + masked-unshifted dequant + hoisted group-bias      14.4
//   v3  64 rows/TG (amortized staging)                       15.1
//   v4  + place-major (bank-conflict-free) staging           15.25
//   v5  4 rows/TG + place-major + hoisted bias               14.7
//   mx.gather_qmm (the thing to beat)                         8-10
//   dense qmv, same bytes (the prize)                         4.3
//
// Killer measurement (scratch moe-qmv-fixed-cost probe): a DEPENDENT chain of
// mx.fast.metal_kernel dispatches costs ~60-95 µs per dispatch nearly
// independent of the work inside (tiny 64×256 shapes ≈ real 704×2816). At 3
// dispatches/layer × 30 layers that fixed cost alone is ~4.5-8.5 ms — the
// entire theoretical prize — before the kernel body runs. Viable routes, in
// order: (a) fix gather_qmm's M=1 path UPSTREAM in mlx C++ (no JS dispatch
// overhead; pairs with the quantized_matmul M=2/3 bug report), (b) a fused
// whole-MLP kernel (gate+up+gelu in one dispatch, down in a second: 60
// dispatches/step) WITH a qmv-class body — a dedicated fused-decode-v2-style
// session; the five variants above are the starting map (occupancy beats
// staging reuse; the mask trick alone did not pay at these shapes).
//
// Two dispatch patterns, one kernel (XSHARED template):
//   gate/up: y[e, out] = W[idx[e]] @ x        (x shared across the K experts)
//   down:    y[e, out] = W[idx[e]] @ x[e]     (per-expert activation row)
// Indices are read DEVICE-side (no host sync); f32 lane-strided accumulation
// (tier-b vs gather_qmm, like the fused decode kernel).

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
import * as ops from "../../src/mlx/ops";

const LANES = 32;
const SIMD_GROUPS = 4;
const TG_THREADS = LANES * SIMD_GROUPS;
// Rows per THREADGROUP (each simdgroup walks ROWS_TG/SIMD_GROUPS rows against
// the staged x). Measured on the 26B shapes: occupancy beats staging reuse —
// 4 rows/TG (1408 threadgroups on gate/up) outruns 64 rows/TG (88 TGs) even
// though every TG re-stages x. Keep the tile small.
const ROWS_TG = 4;

/** Dispatch counter (tests assert the kernel actually ran). */
export let moeQmvCalls = 0;

// One output row per simdgroup. Lanes stride the row's packed u32 words; each
// word's PER_WORD elements lie inside ONE quantization group (PER_WORD ∈ {4,8}
// divides GS ∈ {32,64,128}), so the scale loads once per word:
//   acc += scale·Σ(q_j·x_j)                    (the qdot factoring, dw side)
// The dequant is the fused-decode kernel's MASKED-UNSHIFTED trick: xs[] holds
// x pre-divided by the nibble/byte place value (16^k / 256^k — exact powers of
// two), so the inner loop is mask+convert+fma only, no shifts. The bias term
// b·Σx is hoisted OUT of the inner loop entirely: per-group x sums (xg[]) are
// precomputed once per threadgroup, and each row adds Σ_g bias[g]·xg[g].
const SOURCE = String.raw`
  constexpr int PER_WORD = 32 / BITS;
  constexpr int WORDS = IN / PER_WORD;   // packed u32 words per row
  constexpr int GROUPS = IN / GS;
  constexpr int SG = ${SIMD_GROUPS};

  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint tid = thread_position_in_threadgroup.x;
  const uint z = thread_position_in_grid.z;              // expert slot 0..K-1

  // grid = [TG_THREADS, OUT/SG, K] with threadgroup [TG_THREADS, 1, 1] →
  // thread_position_in_grid.y IS the row-tile index (same convention as the
  // fused decode kernel's h/g dims).
  const uint tileY = thread_position_in_grid.y;
  const uint rowBase = tileY * (uint)ROWS_TG;            // this TG's first output row

  const uint expert = idx[z];

  // threadgroup caches: PLACE-MAJOR (transposed) place-scaled activation +
  // per-group raw sums. Place-major (xsT[k*WORDS + word]) makes the inner
  // loop's lane accesses CONSECUTIVE (lane -> word) — the natural row layout
  // put all 32 lanes on 4 banks (8-way conflicts, the v2/v3 bottleneck).
  threadgroup float xsT[IN];
  threadgroup float xg[GROUPS];
  const uint xBase = XSHARED ? 0u : z * (uint)IN;
  for (uint i = tid; i < (uint)IN; i += ${TG_THREADS}) {
    const float v = float(x[xBase + i]);
    const uint p = BITS == 4 ? (i & 7u) : (i & 3u);
    const float inv = BITS == 4
      ? (p == 0u ? 1.0f : p == 1u ? 0.0625f : p == 2u ? 0.00390625f
        : p == 3u ? 2.44140625e-4f : p == 4u ? 1.52587890625e-5f
        : p == 5u ? 9.5367431640625e-7f : p == 6u ? 5.9604644775390625e-8f
        : 3.725290298461914e-9f)
      : (p == 0u ? 1.0f : p == 1u ? 0.00390625f : p == 2u ? 1.52587890625e-5f
        : 5.9604644775390625e-8f);
    const uint word = BITS == 4 ? (i >> 3) : (i >> 2);
    xsT[p * (uint)WORDS + word] = v * inv;
  }
  // group sums of the RAW x (straight from device — one-time, cached reads)
  for (uint g0 = tid; g0 < (uint)GROUPS; g0 += ${TG_THREADS}) {
    float sgSum = 0.0f;
    for (int j = 0; j < GS; j++) sgSum += float(x[xBase + g0 * (uint)GS + (uint)j]);
    xg[g0] = sgSum;
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);

  for (uint row = rowBase + sg; row < rowBase + (uint)ROWS_TG; row += SG) {
  const ulong rowOff = ((ulong)expert * (ulong)OUT + (ulong)row);
  const device uint32_t* wrow = wq + rowOff * (ulong)WORDS;
  const device T* srow = scales + rowOff * (ulong)GROUPS;
  const device T* brow = biases + rowOff * (ulong)GROUPS;

  float acc = 0.0f;
  for (int wi = (int)lane; wi < WORDS; wi += ${LANES}) {
    const uint32_t wv = wrow[wi];
    const float s = float(srow[(wi * PER_WORD) / GS]);
    float dw;
    if (BITS == 4) {
      dw = (float)(wv & 0x0000000Fu) * xsT[0 * WORDS + wi]
         + (float)(wv & 0x000000F0u) * xsT[1 * WORDS + wi]
         + (float)(wv & 0x00000F00u) * xsT[2 * WORDS + wi]
         + (float)(wv & 0x0000F000u) * xsT[3 * WORDS + wi]
         + (float)(wv & 0x000F0000u) * xsT[4 * WORDS + wi]
         + (float)(wv & 0x00F00000u) * xsT[5 * WORDS + wi]
         + (float)(wv & 0x0F000000u) * xsT[6 * WORDS + wi]
         + (float)(wv & 0xF0000000u) * xsT[7 * WORDS + wi];
    } else {
      dw = (float)(wv & 0x000000FFu) * xsT[0 * WORDS + wi]
         + (float)(wv & 0x0000FF00u) * xsT[1 * WORDS + wi]
         + (float)(wv & 0x00FF0000u) * xsT[2 * WORDS + wi]
         + (float)(wv & 0xFF000000u) * xsT[3 * WORDS + wi];
    }
    acc += s * dw;
  }
  // bias term: Σ_g bias[g]·(Σ x over group g), lane-strided over the groups
  for (int g = (int)lane; g < GROUPS; g += ${LANES}) acc += float(brow[g]) * xg[g];
  const float y = simd_sum(acc);
  if (lane == 0) out[(ulong)z * (ulong)OUT + (ulong)row] = T(y);
  }
`;

let kernel: MetalKernel | null = null;
function getKernel(): MetalKernel {
  if (!kernel) {
    kernel = new MetalKernel({
      name: "mlx_bun_moe_gather_qmv",
      inputNames: ["x", "wq", "scales", "biases", "idx"],
      outputNames: ["out"],
      source: SOURCE,
      ensureRowContiguous: true,
    });
  }
  return kernel;
}

/** Is this gather_qmm dispatch servable by the gather-qmv kernel? Decode
 *  shape only: x rows == 1 (shared) or == K (per-expert), transpose=true
 *  stacked weights, 4/8-bit, PER_WORD | GS, IN % 32 == 0 (word-aligned rows),
 *  OUT % SIMD_GROUPS == 0 (whole row tiles), threadgroup x cache ≤ 32 KB. */
export function moeQmvSupported(
  xRows: number, K: number, OUT: number, IN: number, bits: number, groupSize: number, dtype: Dtype,
): boolean {
  if (process.env.MLX_BUN_MOE_QMV === "0") return false;
  if (bits !== 4 && bits !== 8) return false;
  if (groupSize !== 32 && groupSize !== 64 && groupSize !== 128) return false;
  if (dtype !== Dtype.bfloat16) return false;
  if (xRows !== 1 && xRows !== K) return false;
  const perWord = 32 / bits;
  if (IN % (perWord * 4) !== 0) return false; // whole u32 words per row
  if (IN % groupSize !== 0) return false;
  if (OUT % ROWS_TG !== 0) return false; // whole row tiles per threadgroup
  if (IN * 4 > 32 * 1024) return false; // threadgroup x cache budget
  return true;
}

/** y [K, OUT] (bf16) = gather-qmv over the stacked quantized weights.
 *  `x` is [xRows, IN] with xRows == 1 (shared across experts — gate/up) or
 *  == K (per-expert — down). `idx` is [K] uint32 expert ids (device-side). */
export function moeQmvDecode(
  x: MlxArray, wq: MlxArray, scales: MlxArray, biases: MlxArray, idx: MlxArray,
  K: number, OUT: number, IN: number, bits: number, groupSize: number,
): MlxArray {
  moeQmvCalls++;
  const shared = x.shape[0] === 1 ? 1 : 0;
  const [out] = getKernel().apply([x, wq, scales, biases, idx], {
    outputs: [{ shape: [K, OUT], dtype: x.dtype }],
    grid: [TG_THREADS, OUT / ROWS_TG, K],
    threadGroup: [TG_THREADS, 1, 1],
    templateInts: { OUT, IN, GS: groupSize, BITS: bits, XSHARED: shared, ROWS_TG },
    templateDtypes: { T: x.dtype },
  });
  return out!;
}
