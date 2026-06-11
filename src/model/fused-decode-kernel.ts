// Fused decode-SDPA Metal kernel (optimization_plan.md Phase E): L=1
// attention over a QUANTIZED KV cache in ONE dispatch — QK^T, online
// softmax, and ×V with the dequant inlined; neither the [1,H,1,N] score
// row nor the dequantized cache ever touches memory. This is the
// mlx-qsdpa shape, dispatched from Bun via mx.fast.metal_kernel
// (src/mlx/metal-kernel.ts) — no MLX fork.
//
// Specialization (Phase D dispatch sites provide all of these):
// - BITS: 4 or 8 (template; the unpack loop is compile-time)
// - GS (group_size): lane slices are group-aligned for D ∈ {256, 512},
//   GS ∈ {32, 64, 128} — one scale/bias load per lane per row
// - D (head_dim) and NREP (GQA ratio) as template ints — no expandDims
//   broadcast; the kernel maps query head → KV head directly
//
// Numerics: f32 accumulation, online softmax (NOT bit-exact with the
// unfused one-shot-softmax path by construction — same tier-b note as
// the tiled prefill). Runs only under the perf-mode flag and is gated
// against the FROZEN compat oracle (goldens/perf-oracle/*, captured
// before this kernel existed) — bounded and measured, never unchecked.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import type * as ops from "../mlx/ops";

/** Perf-mode lever: MLX_BUN_PERF_KERNEL=1 routes supported L=1 quantized
 *  SDPA dispatches through the fused kernel. DEFAULT OFF — v1 is
 *  quality-gated (teacher-forced agreement at the accepted tier-b
 *  envelope, tests/perf-kernel-oracle.test.ts) but measured SLOWER
 *  (0.72× @8k): one threadgroup per query head cannot occupy the GPU.
 *  Documented losing experiment; the v2 lever is flash-decoding split-N
 *  (partial (max,sum,acc) per N-block + a merge pass). Also: the
 *  CustomKernel primitive cannot sit inside compiled-decode closures
 *  (no output_shapes) — compiled segments blacklist themselves and fall
 *  back when the flag is on. */
export function perfKernelEnabled(): boolean {
  return process.env.MLX_BUN_PERF_KERNEL === "1";
}

/** Dispatch counter (the oracle gate asserts the kernel actually ran). */
export let fusedKernelCalls = 0;

// One simdgroup stripe of 4 over the KV rows; 32 lanes slice the head dim.
const SIMD_GROUPS = 4;
const LANES = 32;

// Two passes so the rounding points MATCH the compat (unfused) path —
// the per-layer difference must stay at stray-ulp scale or 48 residual
// layers amplify it chaotically (measured: f32-throughout drifted the
// step-1 logits by ~36; bf16-rounded scores alone, ~10):
// - scores round to T (compat's qmm emits T scores)
// - softmax is ONE-SHOT over the full row (pass 1 finds max + denom,
//   like compat's precise softmax), and each normalized prob rounds to
//   T (compat's prob dtype) before the V accumulation in f32 (compat's
//   qmm accumulator). K is dequantized twice (compute is cheap next to
//   the bytes); V is read once; nothing is ever materialized.
const SOURCE = String.raw`
  constexpr int SG = ${SIMD_GROUPS};
  constexpr int ELEMS = D / ${LANES};
  constexpr int PER_WORD = 32 / BITS;
  constexpr int WORDS = ELEMS / PER_WORD;
  constexpr uint MASKV = (1u << BITS) - 1u;

  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint h = thread_position_in_grid.y;
  const uint kv = h / NREP;
  const int N = kp_shape[2];
  const int kRowWords = D / PER_WORD;
  const int gRow = D / GS;

  // this lane's q slice, f32
  float qv[ELEMS];
  const uint qBase = h * D + lane * ELEMS;
  for (int e = 0; e < ELEMS; e++) qv[e] = float(q[qBase + e]);

  const int grpIdx = (lane * ELEMS) / GS; // lane slice is group-aligned

  // ---- pass 1: full-row max and denominator over T-rounded scores ----
  float mx = -INFINITY;
  float sumexp = 0.0f;
  for (int n = (int)sg; n < N; n += SG) {
    const ulong rowOff = ((ulong)kv * (ulong)N + (ulong)n);
    const device uint32_t* krow = kp + rowOff * kRowWords;
    const float kScale = float(ks[rowOff * gRow + grpIdx]);
    const float kBias = float(kb[rowOff * gRow + grpIdx]);
    float partial = 0.0f;
    for (int w = 0; w < WORDS; w++) {
      const uint32_t word = krow[lane * WORDS + w];
      for (int j = 0; j < PER_WORD; j++) {
        const float x = float(T(float((word >> (BITS * j)) & MASKV) * kScale + kBias));
        partial += qv[w * PER_WORD + j] * x;
      }
    }
    const float s = float(T(simd_sum(partial)));
    const float newmax = metal::max(mx, s);
    sumexp = sumexp * metal::exp(mx - newmax) + metal::exp(s - newmax);
    mx = newmax;
  }

  threadgroup float tgMax[SG];
  threadgroup float tgSum[SG];
  if (lane == 0) {
    tgMax[sg] = mx;
    tgSum[sg] = sumexp;
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  float M = -INFINITY;
  for (int g = 0; g < SG; g++) M = metal::max(M, tgMax[g]);
  float denom = 0.0f;
  for (int g = 0; g < SG; g++) denom += tgSum[g] * metal::exp(tgMax[g] - M);

  // ---- pass 2: T-rounded normalized probs × dequant(V), f32 accum ----
  float oacc[ELEMS];
  for (int e = 0; e < ELEMS; e++) oacc[e] = 0.0f;
  for (int n = (int)sg; n < N; n += SG) {
    const ulong rowOff = ((ulong)kv * (ulong)N + (ulong)n);
    const device uint32_t* krow = kp + rowOff * kRowWords;
    const float kScale = float(ks[rowOff * gRow + grpIdx]);
    const float kBias = float(kb[rowOff * gRow + grpIdx]);
    float partial = 0.0f;
    for (int w = 0; w < WORDS; w++) {
      const uint32_t word = krow[lane * WORDS + w];
      for (int j = 0; j < PER_WORD; j++) {
        const float x = float(T(float((word >> (BITS * j)) & MASKV) * kScale + kBias));
        partial += qv[w * PER_WORD + j] * x;
      }
    }
    const float s = float(T(simd_sum(partial)));
    const float p = float(T(metal::exp(s - M) / denom));

    const device uint32_t* vrow = vp + rowOff * kRowWords;
    const float vScale = float(vs[rowOff * gRow + grpIdx]);
    const float vBias = float(vb[rowOff * gRow + grpIdx]);
    for (int w = 0; w < WORDS; w++) {
      const uint32_t word = vrow[lane * WORDS + w];
      for (int j = 0; j < PER_WORD; j++) {
        const float x = float(T(float((word >> (BITS * j)) & MASKV) * vScale + vBias));
        oacc[w * PER_WORD + j] += p * x;
      }
    }
  }

  // plain cross-simdgroup sum (probs already normalized)
  threadgroup float tgO[SG * D];
  for (int e = 0; e < ELEMS; e++) tgO[sg * D + lane * ELEMS + e] = oacc[e];
  threadgroup_barrier(mem_flags::mem_threadgroup);
  if (sg == 0) {
    for (int e = 0; e < ELEMS; e++) {
      const int d = lane * ELEMS + e;
      float o = 0.0f;
      for (int g = 0; g < SG; g++) o += tgO[g * D + d];
      out[h * D + d] = T(o);
    }
  }
`;

const kernels = new Map<string, MetalKernel>();

function kernelFor(): MetalKernel {
  // one compiled pipeline per (D, GS, BITS, NREP) via template args; the
  // MSL source is shared, so a single MetalKernel instance suffices and
  // mlx JIT-caches per template-arg set under the hood
  let k = kernels.get("fused-qsdpa");
  if (!k) {
    k = new MetalKernel({
      name: "mlx_bun_fused_qsdpa_decode",
      inputNames: ["q", "kp", "ks", "kb", "vp", "vs", "vb"],
      outputNames: ["out"],
      source: SOURCE,
      ensureRowContiguous: true,
    });
    kernels.set("fused-qsdpa", k);
  }
  return k;
}

/** Is this dispatch site servable by the fused kernel? All checks are
 *  cheap or generation-time-known (Phase D bakes bits/gs; shape checks
 *  guard runtime drift). */
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
  if ((elems * 32) % (32 / bits) !== 0) return false;
  // lane slice must sit inside one quantization group
  if (elems > groupSize || groupSize % elems !== 0) return false;
  return true;
}

/** Fused decode attention over quantized KV. Caller guarantees
 *  fusedDecodeKernelSupported and mask mode "" (decode attends the whole
 *  fetched window). q [1,H,1,D] bf16; kq/vq packed triples [1,KV,N,*]. */
export function fusedDecodeSdpa(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  groupSize: number, bits: number,
): MlxArray {
  const [, H, , D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const nRep = H / KV;
  fusedKernelCalls++;
  const [outArr] = kernelFor().apply(
    [q, kq.packed, kq.scales, kq.biases, vq.packed, vq.scales, vq.biases],
    {
      outputs: [{ shape: [1, H, 1, D], dtype: q.dtype }],
      grid: [SIMD_GROUPS * LANES, H, 1],
      threadGroup: [SIMD_GROUPS * LANES, 1, 1],
      templateInts: { D, GS: groupSize, BITS: bits, NREP: nRep },
      templateDtypes: { T: q.dtype },
    },
  );
  return outArr!;
}
