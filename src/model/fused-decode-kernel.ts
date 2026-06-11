// Fused decode-SDPA Metal kernel, v2: flash-decoding split-N
// (optimization_plan.md Phase E). L=1 attention over a QUANTIZED KV
// cache with the dequant inlined — neither the score row nor the
// dequantized cache is ever materialized. Dispatched from Bun via
// mx.fast.metal_kernel (no MLX fork), always OUTSIDE compiled-decode
// closures (CustomKernel has no output_shapes; compiled segments
// reclassify perf-kernel layers as JS layers instead).
//
// v1 post-mortem (git 48c9b10): numerics landed at the accepted tier-b
// envelope but ONE THREADGROUP PER QUERY HEAD (16 total on the 12B)
// could not occupy the GPU — 0.72× @8k. v2 splits the KV rows into
// G = ceil(N/BLOCK) blocks (grid [128, H, G]):
//   kernel A: per-block (max, sumexp) over T-rounded scores
//   kernel C: per-block Σ T(exp(s−M)/denom)·dequant(V) partials, with
//             the full-row (M, denom) derived inline from A's stats —
//             deterministic (no atomics: atomic add order would make
//             rounding nondeterministic)
//   merge:    one mlx sum over G + cast to T (deterministic order)
// Rounding points still MATCH the compat path where it matters (scores
// and normalized probs round to T; f32 accumulation) — per-layer
// divergence stays at the stray-ulp scale the teacher-forced gate is
// calibrated for (tests/perf-kernel-oracle.test.ts).

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import * as ops from "../mlx/ops";

/** Perf-mode lever: MLX_BUN_PERF_KERNEL=1 routes supported L=1 quantized
 *  SDPA dispatches through the fused kernel. Compat (flag off) is the
 *  permanent -O0 reference and differential-testing oracle. */
export function perfKernelEnabled(): boolean {
  return process.env.MLX_BUN_PERF_KERNEL === "1";
}

/** Dispatch counter (the oracle gate asserts the kernel actually ran). */
export let fusedKernelCalls = 0;

const SIMD_GROUPS = 4;
const LANES = 32;
const TG_THREADS = SIMD_GROUPS * LANES;

// Shared per-row score computation: lane-sliced dot product with the
// dequant FACTORED out of the inner loop (the mlx qdot pattern,
// quantized.h, Apache-2.0 — translated into this kernel's dialect):
//   Σ (s·w_e + b)·q_e = s·Σ(w_e·q_e) + b·Σ q_e
// and for 4-bit the nibbles multiply MASKED-BUT-UNSHIFTED against a
// query pre-divided by 16^k — the inner loop is mask+madd only, via
// 16-bit reads. Lane slices are group-aligned for D ∈ {256, 512},
// GS ∈ {32, 64, 128}: one scale/bias per lane per row.
const SCORE_PREAMBLE = String.raw`
  constexpr int SG = ${SIMD_GROUPS};
  constexpr int ELEMS = D / ${LANES};
  constexpr int PER_WORD = 32 / BITS;
  constexpr int WORDS = ELEMS / PER_WORD;

  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint h = thread_position_in_grid.y;
  const uint g = thread_position_in_grid.z;
  const uint kv = h / NREP;
  const int N = kp_shape[2];
  const int G = (N + BLOCK - 1) / BLOCK;
  const int nStart = (int)g * BLOCK;
  const int nEnd = metal::min(nStart + BLOCK, N);
  const int kRowWords = D / PER_WORD;
  const int gRow = D / GS;

  // lane's q slice: raw sum for the bias term, and (4-bit) nibble-place
  // pre-scaled copies for the no-shift masked dot
  float qv[ELEMS];
  float qSum = 0.0f;
  const uint qBase = h * D + lane * ELEMS;
  for (int e = 0; e < ELEMS; e++) {
    const float v = float(q[qBase + e]);
    qSum += v;
    qv[e] = BITS == 4
      ? v * ((e & 3) == 0 ? 1.0f : (e & 3) == 1 ? 0.0625f : (e & 3) == 2 ? 0.00390625f : 0.000244140625f)
      : v;
  }

  const int grpIdx = (lane * ELEMS) / GS;
`;

const SCORE_ROW = String.raw`
    const ulong rowOff = ((ulong)kv * (ulong)N + (ulong)n);
    const float kScale = float(ks[rowOff * gRow + grpIdx]);
    const float kBias = float(kb[rowOff * gRow + grpIdx]);
    float accum = 0.0f;
    if (BITS == 4) {
      const device uint16_t* kw =
        ((const device uint16_t*)(kp + rowOff * kRowWords)) + lane * (ELEMS / 4);
      for (int i = 0; i < ELEMS / 4; i++) {
        const uint16_t wv = kw[i];
        accum += qv[4 * i]     * (float)(wv & 0x000f)
               + qv[4 * i + 1] * (float)(wv & 0x00f0)
               + qv[4 * i + 2] * (float)(wv & 0x0f00)
               + qv[4 * i + 3] * (float)(wv & 0xf000);
      }
    } else {
      const device uint8_t* kw8 =
        ((const device uint8_t*)(kp + rowOff * kRowWords)) + lane * ELEMS;
      for (int e = 0; e < ELEMS; e++) accum += qv[e] * (float)kw8[e];
    }
    const float partial = kScale * accum + qSum * kBias;
    const float s = float(T(simd_sum(partial)));
`;

// kernel: single-pass per-block ONLINE softmax — K and V each read
// exactly once (the two-pass v2.0 read K twice and measured 0.945);
// per-block (max, sumexp) and unnormalized o land in stats/opart for
// the merge kernel.
const BLOCK_SOURCE = SCORE_PREAMBLE + String.raw`
  float mx = -INFINITY;
  float sumexp = 0.0f;
  // V accumulates RAW masked nibbles per slot (factor 16^k folds once at
  // the end) with the bias term collapsed to one scalar: Σ p·b — the
  // qdot factoring applied to the value side.
  float oacc[ELEMS];
  for (int e = 0; e < ELEMS; e++) oacc[e] = 0.0f;
  float pbSum = 0.0f;

  for (int n = nStart + (int)sg; n < nEnd; n += SG) {
${SCORE_ROW}
    const float newmax = metal::max(mx, s);
    const float factor = metal::exp(mx - newmax);
    const float p = metal::exp(s - newmax);
    sumexp = sumexp * factor + p;
    mx = newmax;

    const float vScale = float(vs[rowOff * gRow + grpIdx]);
    const float vBias = float(vb[rowOff * gRow + grpIdx]);
    const float ps = p * vScale;
    pbSum = pbSum * factor + p * vBias;
    if (BITS == 4) {
      const device uint16_t* vw =
        ((const device uint16_t*)(vp + rowOff * kRowWords)) + lane * (ELEMS / 4);
      for (int i = 0; i < ELEMS / 4; i++) {
        const uint16_t wv = vw[i];
        oacc[4 * i]     = oacc[4 * i]     * factor + ps * (float)(wv & 0x000f);
        oacc[4 * i + 1] = oacc[4 * i + 1] * factor + ps * (float)(wv & 0x00f0);
        oacc[4 * i + 2] = oacc[4 * i + 2] * factor + ps * (float)(wv & 0x0f00);
        oacc[4 * i + 3] = oacc[4 * i + 3] * factor + ps * (float)(wv & 0xf000);
      }
    } else {
      const device uint8_t* vw8 =
        ((const device uint8_t*)(vp + rowOff * kRowWords)) + lane * ELEMS;
      for (int e = 0; e < ELEMS; e++)
        oacc[e] = oacc[e] * factor + ps * (float)vw8[e];
    }
  }
  // fold the nibble-place factors and the bias sum (once per block)
  for (int e = 0; e < ELEMS; e++) {
    const float inv = BITS == 4
      ? ((e & 3) == 0 ? 1.0f : (e & 3) == 1 ? 0.0625f : (e & 3) == 2 ? 0.00390625f : 0.000244140625f)
      : 1.0f;
    oacc[e] = oacc[e] * inv + pbSum;
  }

  // cross-simdgroup online merge within the block
  threadgroup float tgMax[SG];
  threadgroup float tgSum[SG];
  threadgroup float tgO[SG * D];
  if (lane == 0) {
    tgMax[sg] = mx;
    tgSum[sg] = sumexp;
  }
  for (int e = 0; e < ELEMS; e++) tgO[sg * D + lane * ELEMS + e] = oacc[e];
  threadgroup_barrier(mem_flags::mem_threadgroup);
  if (sg == 0) {
    float M = -INFINITY;
    for (int gg = 0; gg < SG; gg++) M = metal::max(M, tgMax[gg]);
    float S = 0.0f;
    float wgt[SG];
    for (int gg = 0; gg < SG; gg++) {
      wgt[gg] = metal::exp(tgMax[gg] - M);
      S += tgSum[gg] * wgt[gg];
    }
    for (int e = 0; e < ELEMS; e++) {
      const int d = lane * ELEMS + e;
      float o = 0.0f;
      for (int gg = 0; gg < SG; gg++) o += tgO[gg * D + d] * wgt[gg];
      opart[((ulong)h * (ulong)G + (ulong)g) * (ulong)D + (ulong)d] = o;
    }
    if (lane == 0) {
      stats[(h * (uint)G + g) * 2 + 0] = M;
      stats[(h * (uint)G + g) * 2 + 1] = S;
    }
  }
`;

// merge kernel: out[h,d] = Σ_g opart[h,g,d]·exp(m_g−M) / denom, cast T.
// Deterministic (fixed g order), one tiny dispatch.
const MERGE_SOURCE = String.raw`
  const uint d = thread_position_in_grid.x;
  const uint h = thread_position_in_grid.y;
  const int G = stats_shape[2];
  if ((int)d >= D) return;
  float M = -INFINITY;
  for (int g = 0; g < G; g++)
    M = metal::max(M, stats[(h * (uint)G + (uint)g) * 2 + 0]);
  float denom = 0.0f;
  for (int g = 0; g < G; g++)
    denom += stats[(h * (uint)G + (uint)g) * 2 + 1] *
             metal::exp(stats[(h * (uint)G + (uint)g) * 2 + 0] - M);
  float o = 0.0f;
  for (int g = 0; g < G; g++)
    o += opart[((ulong)h * (ulong)G + (ulong)g) * (ulong)D + (ulong)d] *
         metal::exp(stats[(h * (uint)G + (uint)g) * 2 + 0] - M);
  out[h * (uint)D + d] = T(o / denom);
`;

let blockKernel: MetalKernel | null = null;
let mergeKernel: MetalKernel | null = null;

function kernels(): { block: MetalKernel; merge: MetalKernel } {
  if (!blockKernel) {
    blockKernel = new MetalKernel({
      name: "mlx_bun_fqsdpa_block",
      inputNames: ["q", "kp", "ks", "kb", "vp", "vs", "vb"],
      outputNames: ["opart", "stats"],
      source: BLOCK_SOURCE,
      ensureRowContiguous: true,
    });
    mergeKernel = new MetalKernel({
      name: "mlx_bun_fqsdpa_merge",
      inputNames: ["opart", "stats"],
      outputNames: ["out"],
      source: MERGE_SOURCE,
      ensureRowContiguous: true,
    });
  }
  return { block: blockKernel, merge: mergeKernel! };
}

/** Split width: enough blocks to occupy the GPU at small N without
 *  shrinking blocks into per-dispatch overhead at large N. */
function blockSize(n: number): number {
  return n <= 2048 ? 128 : 512;
}

/** Is this dispatch site servable by the fused kernel? (Phase D bakes
 *  bits/gs at generation time; shape checks guard runtime drift.) */
export function fusedDecodeKernelSupported(
  q: MlxArray, bits: number, groupSize: number,
): boolean {
  if (bits !== 4 && bits !== 8) return false;
  if (groupSize !== 32 && groupSize !== 64 && groupSize !== 128) return false;
  if (q.dtype !== Dtype.bfloat16) return false;
  const [B, , L, D] = q.shape as [number, number, number, number];
  if (B !== 1 || L !== 1) return false;
  if (D % LANES !== 0) return false;
  const elems = D / LANES;
  if ((elems * bits) % 32 !== 0) return false; // whole u32 words per lane
  // lane slice must sit inside one quantization group
  if (elems > groupSize || groupSize % elems !== 0) return false;
  return true;
}

/** Fused decode attention over quantized KV (flash-decoding split-N).
 *  Caller guarantees fusedDecodeKernelSupported and mask mode "" (decode
 *  attends the whole fetched window). q [1,H,1,D] bf16. */
export function fusedDecodeSdpa(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  groupSize: number, bits: number,
): MlxArray {
  const [, H, , D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const N = kq.packed.shape[2]!;
  const nRep = H / KV;
  const BLOCK = blockSize(N);
  const G = Math.ceil(N / BLOCK);
  fusedKernelCalls++;

  const { block, merge } = kernels();
  const tmpl = { D, GS: groupSize, BITS: bits, NREP: nRep, BLOCK };

  const [opart, statsArr] = block.apply(
    [q, kq.packed, kq.scales, kq.biases, vq.packed, vq.scales, vq.biases],
    {
      outputs: [
        { shape: [1, H, G, D], dtype: Dtype.float32 },
        { shape: [1, H, G, 2], dtype: Dtype.float32 },
      ],
      grid: [TG_THREADS, H, G],
      threadGroup: [TG_THREADS, 1, 1],
      templateInts: tmpl,
      templateDtypes: { T: q.dtype },
    },
  );
  const [out] = merge.apply([opart!, statsArr!], {
    outputs: [{ shape: [1, H, 1, D], dtype: q.dtype }],
    grid: [D, H, 1],
    threadGroup: [Math.min(D, 256), 1, 1],
    templateInts: { D },
    templateDtypes: { T: q.dtype },
  });
  opart!.dispose();
  statsArr!.dispose();
  return out!;
}
