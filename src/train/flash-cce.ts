// Flash Cut-Cross-Entropy Metal kernel for the ORPO log-prob head — the vocab
// loop lives INSIDE the kernel, so neither the [M,V] logits nor a dequantized
// [V,hidden] head ever touch HBM (the residency bound pure MLX can't reach; see
// docs/design/orpo-training.md → "Vocab-blocked online-softmax"). Computes the
// per-token response log-prob `logp = target_logit − logsumexp_v(h·W_v)`.
//
// TRANSPILE SOURCE — this is, in effect, Apple's Cut Cross Entropy + Liger's
// FusedLinearCrossEntropy Triton kernels transpiled Triton → Metal:
//   - Apple CCE  (github.com/apple/ml-cross-entropy):
//       cce_lse_forward.py — forward: tile (BLOCK_B tokens × BLOCK_V vocab),
//         accum = tl.dot(E_tile, Cᵀ_tile) over a D-loop, per-block
//         this_lse = mx + log(Σ exp(logit−mx)), merged across vocab blocks into a
//         per-token LSE via locked atomic logaddexp; mask offs_v<V → −inf.
//       cce_backward.py — backward: same (token×vocab) tiling, recompute logits,
//         d_accum = exp(accum − lse); d_accum += where(is_target, −1, 0); then
//         dE += d_accum @ C and dC += d_accumᵀ @ E via locked atomic adds;
//         optional skip when |d_accum| < filter_eps.
//   - Liger FusedLinearCrossEntropy — token-chunking + the in-place softmax−onehot
//       gradient written back over the logit buffer.
//
// DIVERGENCES (why this isn't a line-for-line port):
//   1. Our classifier C is the QUANTIZED head (4/8-bit affine). Apple loads C
//      dense (bf16); we keep the in-Metal dequant for `tl.dot` (the qdot pattern
//      from src/model/fused-decode-kernel.ts). This is the one substantive change.
//   2. The head is FROZEN (not a LoRA target) → we need only dE (=dh), NOT dC.
//   3. The LSE cross-vocab-block merge is done in cheap MLX ops on per-block
//      partials, not Metal atomic-logaddexp spinlocks (simpler, same result).
//
// STATUS: v1 (one threadgroup per token, whole vocab serially) is correct +
// memory-bounded (validated MiniCPM5→M=8192, e4b→M=512) but its single-token
// threadgroup runs the full 262k vocab serially → trips the GPU watchdog on e4b
// at higher M. The vocab-PARALLEL form below (grid over token × vocab blocks, à la
// Apple CCE) bounds per-threadgroup work and is the production path.

import { MetalKernel } from "../mlx/metal-kernel";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { STEEL_QMM_HEADER } from "./steel-qmm-header";

/** The quantized head pieces the kernel needs (packed weight + per-group affine
 *  scale/bias + bits/group_size). Mirrors HeadQuant in loss.ts. */
export interface FlashCceHead {
  w: MlxArray; // packed quantized weight, uint32 [V, hidden*bits/32]
  scales: MlxArray; // [V, hidden/groupSize]
  biases: MlxArray; // [V, hidden/groupSize] (affine — required)
  bits: number; // 4 or 8
  groupSize: number; // 64
  softcap: number | null;
}

const H_MAX = 4096; // covers MiniCPM5 (1536) and e4b (2560) hidden sizes
const TG = 128; // threads per token-threadgroup
// Vocab rows per threadgroup (Apple CCE's BLOCK_V analog). Bounds per-threadgroup
// runtime so a single dispatch never loops the whole vocab — the e4b watchdog fix.
const VOCAB_BLOCK = 8192;
// Tokens processed together per threadgroup (Apple CCE's BLOCK_B). Each thread
// dequantizes a vocab row's weights ONCE and reuses them across BLOCK_B tokens,
// amortizing the ALU-bound dequant BLOCK_B× (the dominant cost in the v1
// one-token-per-threadgroup kernel). Forward and backward use different tile
// widths: the backward holds a per-token output accumulator `dacc[BLOCK_B·DPER]`
// in registers, so it is register-bound to a smaller tile (BLOCK_B=8 spills).
const BLOCK_B = 8;       // forward (online stats are only ~7·BLOCK_B floats/thread)
const BLOCK_B_BWD = 4;   // backward (dacc[BLOCK_B·DPER] — 8 overflows the register file)
// simdgroup_matrix forward GEMM tiles (Apple CCE's BLOCK_B×BLOCK_V×BLOCK_D, mapped
// to Metal 8×8 simdgroup_matrix). BB tokens × BV vocab logit tile, accumulated over
// BD hidden chunks. BV/8 = 4 column-blocks → one per simdgroup (TG/32 = 4).
const SG_BB = 8;   // token tile (one 8-row simdgroup block)
const SG_BV = 32;  // vocab tile (4 column-blocks)
const SG_BD = 32;  // hidden chunk (4 k-blocks). BD=64 (GS-aligned, ½ the barriers)
                   // measured SLOWER (fwd 844→1010, bwd 3311→3799): the 8KB Csh tile
                   // cuts occupancy more than fewer barriers help. 32 is the sweet spot.

// VOCAB-PARALLEL forward (Apple CCE cce_lse_forward, transpiled): one threadgroup
// per (token=grid.z, vocab-block=grid.y) handles a bounded V/NBLK vocab slice → no
// single threadgroup runs the whole vocab (the watchdog fix). Each writes per-block
// partials (blockMax, blockSumexp-relative-to-blockMax, target logit) to [M,NBLK];
// the cross-vocab-block LSE merge is done in cheap MLX ops (vs Apple's locked
// atomic logaddexp). 128 threads stride the slice, per-thread online softmax,
// merged across the threadgroup.
const FWD_SOURCE = String.raw`
  const uint tokBlk = threadgroup_position_in_grid.z; // token-block index
  const uint vb  = threadgroup_position_in_grid.y;    // vocab-block index
  const uint tid = thread_position_in_threadgroup.x;  // 0..TG-1
  const uint M    = shape[0];
  const uint V    = shape[1];
  const uint H    = shape[2];
  const uint GS   = shape[3];
  const uint BITS = shape[4];
  const uint WPR  = shape[5];   // uint32 words per packed weight row
  const uint GR   = shape[6];   // groups per row (H/GS)
  const uint NBLK = shape[7];   // number of vocab blocks
  const float cap = capv[0];
  const uint perWord = 32u / BITS;
  const uint qmask = (BITS == 32u) ? 0xffffffffu : ((1u << BITS) - 1u);
  const uint wordsPerGroup = GS / perWord;
  const uint blockV = (V + NBLK - 1u) / NBLK;
  const uint nStart = vb * blockV;
  const uint nEnd = min(nStart + blockV, V);
  const uint tokBase = tokBlk * BLOCK_B;

  // Per-token online state (registers). Each thread keeps BLOCK_B tokens' running
  // softmax stats so one vocab-row dequant feeds all BLOCK_B tokens.
  float mx[BLOCK_B], sumexp[BLOCK_B], tgtLogit[BLOCK_B];
  uint  tgtId[BLOCK_B];
  for (uint b = 0u; b < BLOCK_B; ++b) {
    mx[b] = -INFINITY; sumexp[b] = 0.0f; tgtLogit[b] = 0.0f;
    tgtId[b] = (tokBase + b < M) ? targets[tokBase + b] : 0xffffffffu;
  }

  for (uint n = nStart + tid; n < nEnd; n += TG) {
    const device uint* row = wp + (ulong)n * WPR;
    const uint sbBase = n * GR;
    float partial[BLOCK_B];
    for (uint b = 0u; b < BLOCK_B; ++b) partial[b] = 0.0f;
    // qdot factoring per group; the nibble dequant (q) is computed ONCE per
    // element and reused across all BLOCK_B tokens (the amortization).
    for (uint grp = 0u; grp < GR; ++grp) {
      const float sc = scales[sbBase + grp];
      const float bi = biases[sbBase + grp];
      const uint d0 = grp * GS;
      float gacc[BLOCK_B], ghsum[BLOCK_B];
      for (uint b = 0u; b < BLOCK_B; ++b) { gacc[b] = 0.0f; ghsum[b] = 0.0f; }
      for (uint wi = 0u; wi < wordsPerGroup; ++wi) {
        const uint word = row[d0 / perWord + wi];
        const uint dbase = d0 + wi * perWord;
        for (uint k = 0u; k < perWord; ++k) {
          const float q = (float)((word >> (BITS * k)) & qmask);
          const uint d = dbase + k;
          for (uint b = 0u; b < BLOCK_B; ++b) {
            const uint tb = min(tokBase + b, M - 1u); // clamp padding lanes (last block) — result discarded in merge
            // h is passed TRANSPOSED [H, M], so the BLOCK_B inner reads hit one
            // cache line (h[d, tb..tb+BLOCK_B] contiguous) instead of BLOCK_B
            // separate lines — the memory-access fix for the strided pattern.
            const float hd = (float)h[(ulong)d * M + tb];
            gacc[b] += hd * q; ghsum[b] += hd;
          }
        }
      }
      for (uint b = 0u; b < BLOCK_B; ++b) partial[b] += sc * gacc[b] + bi * ghsum[b];
    }
    for (uint b = 0u; b < BLOCK_B; ++b) {
      float logit = partial[b];
      if (cap > 0.0f) logit = cap * tanh(logit / cap);
      const float nm = max(mx[b], logit);
      sumexp[b] = sumexp[b] * exp(mx[b] - nm) + exp(logit - nm);
      mx[b] = nm;
      if (n == tgtId[b]) tgtLogit[b] = logit;
    }
  }

  // Merge the TG threads' partials per token → per-(token, vocab-block) output.
  threadgroup float mM[TG], mS[TG], mT[TG];
  for (uint b = 0u; b < BLOCK_B; ++b) {
    if (tokBase + b >= M) break;
    mM[tid] = mx[b]; mS[tid] = sumexp[b]; mT[tid] = tgtLogit[b];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (tid == 0u) {
      float gm = -INFINITY, gs = 0.0f, gt = 0.0f;
      for (uint i = 0u; i < TG; ++i) {
        const float im = mM[i];
        const float nm = max(gm, im);
        if (nm > -INFINITY) { gs = gs * exp(gm - nm) + mS[i] * exp(im - nm); gm = nm; }
        gt += mT[i]; // target logit (one thread nonzero), else 0
      }
      blockMax_out[(tokBase + b) * NBLK + vb] = gm;
      blockSum_out[(tokBase + b) * NBLK + vb] = gs;
      blockTgt_out[(tokBase + b) * NBLK + vb] = gt;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
`;

// SIMDGROUP_MATRIX forward GEMM (the speed tier): per (token-block, vocab-block)
// threadgroup, loop the vocab slice in BV-chunks; for each chunk compute the
// [BB, BV] logit tile with 8×8 simdgroup_matrix mma over BD hidden chunks, then a
// scalar online-softmax update. The classifier tile C [BV, BD] is dequantized into
// threadgroup once per (vocab-chunk, D-chunk) and reused across all BB tokens by
// the matmul — so the dequant is amortized AND the matmul runs at simdgroup-matrix
// throughput (the scalar madd was the bottleneck after BLOCK_B tiling). BV/8 = 4
// column-blocks → one per simdgroup (TG/32 = 4). logit[b,v] = Σ_d E[b,d]·C[v,d] =
// E @ Cᵀ (the C block is loaded transposed).
const FWD_SG_SOURCE = String.raw`
  const uint tokBlk = threadgroup_position_in_grid.z;
  const uint vb  = threadgroup_position_in_grid.y;
  const uint tid = thread_position_in_threadgroup.x;
  const uint sg  = tid / 32u;                 // simdgroup 0..3
  const uint M=shape[0], V=shape[1], H=shape[2], GS=shape[3], BITS=shape[4], WPR=shape[5], GR=shape[6], NBLK=shape[7];
  const float cap = capv[0];
  const uint perWord = 32u / BITS;
  const uint qmask = (BITS == 32u) ? 0xffffffffu : ((1u << BITS) - 1u);
  const uint blockV = (V + NBLK - 1u) / NBLK;
  const uint nStart = vb * blockV;
  const uint nEnd = min(nStart + blockV, V);
  const uint tokBase = tokBlk * BB;

  // +4-float padded leading dims (MLX steel's BK_padded trick): a stride of 32 ==
  // 32 banks → 32-way bank conflicts on every simdgroup_load; 36 breaks alignment.
  threadgroup float Esh[BB * BDX];
  threadgroup float Csh[BV * BDX];
  threadgroup float Lsh[BB * BVX];
  threadgroup float tgMax[BB], tgSum[BB], tgTgt[BB];
  threadgroup uint  tgTid[BB];
  if (tid < BB) {
    tgMax[tid] = -INFINITY; tgSum[tid] = 0.0f; tgTgt[tid] = 0.0f;
    tgTid[tid] = (tokBase + tid < M) ? targets[tokBase + tid] : 0xffffffffu;
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);

  for (uint v0 = nStart; v0 < nEnd; v0 += BV) {
    simdgroup_float8x8 acc = simdgroup_float8x8(0);
    for (uint d0 = 0u; d0 < H; d0 += BD) {
      // E tile [BB, BD] (token hiddens)
      for (uint i = tid; i < BB * BD; i += TG) {
        const uint b = i / BD, dd = i % BD;
        const uint tb = min(tokBase + b, M - 1u);
        Esh[b * BDX + dd] = (float)h[(ulong)tb * H + d0 + dd];
      }
      // C tile [BV, BD] (dequantized head, reused across all BB tokens).
#if CCE_SG_SKIPDQ
      // PROBE: no global loads — isolates whether the staging loads are the limiter.
      for (uint i = tid; i < BV * BD; i += TG) {
        const uint vrow = i / BD, dd = i % BD;
        Csh[vrow * BDX + dd] = (v0 + vrow < nEnd) ? ((float)((i & 7u)) * 0.01f + 0.001f) : 0.0f;
      }
#else
      // ONE THREAD PER PACKED WORD: each word loaded once (was perWord-redundant),
      // and scale/bias once per word's group (was per-element — the whole BD chunk
      // is one GS group, so this collapses ~perWord× of scale/bias traffic too).
      const uint wordsPerRow = BD / perWord;
      for (uint wi = tid; wi < BV * wordsPerRow; wi += TG) {
        const uint vrow = wi / wordsPerRow;
        const uint dloc = (wi % wordsPerRow) * perWord;
        const uint n = v0 + vrow;
        const uint d = d0 + dloc;
        uint word = 0u; float sc = 0.0f, bi = 0.0f;
        if (n < nEnd) {
          word = wp[(ulong)n * WPR + d / perWord];
          const uint grp = d / GS;
          sc = scales[n * GR + grp]; bi = biases[n * GR + grp];
        }
        for (uint k = 0u; k < perWord; ++k) {
          const float q = (float)((word >> (BITS * k)) & qmask);
          Csh[vrow * BDX + dloc + k] = sc * q + bi;
        }
      }
#endif
      threadgroup_barrier(mem_flags::mem_threadgroup);
      // acc(this sg's 8 cols) += E @ Cᵀ over BD/8 k-blocks (padded strides BDX)
      for (uint kk = 0u; kk < BD / 8u; ++kk) {
        simdgroup_float8x8 me, mc;
        simdgroup_load(me, Esh + kk * 8u, BDX);
        simdgroup_load(mc, Csh + (ulong)sg * 8u * BDX + kk * 8u, BDX, ulong2(0, 0), true);
        simdgroup_multiply_accumulate(acc, me, mc, acc);
      }
      threadgroup_barrier(mem_flags::mem_threadgroup);
    }
    simdgroup_store(acc, Lsh + sg * 8u, BVX);  // [0:BB, sg*8 : sg*8+8], padded stride
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // Online-softmax update for BB tokens over this BV chunk (thread b<BB → token b).
    if (tid < BB) {
      const uint b = tid;
      for (uint v = 0u; v < BV; ++v) {
        const uint n = v0 + v;
        if (n >= nEnd) break;
        float logit = Lsh[b * BVX + v];
        if (cap > 0.0f) logit = cap * tanh(logit / cap);
        const float nm = max(tgMax[b], logit);
        tgSum[b] = tgSum[b] * exp(tgMax[b] - nm) + exp(logit - nm);
        tgMax[b] = nm;
        if (n == tgTid[b]) tgTgt[b] = logit;
      }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }

  if (tid < BB && tokBase + tid < M) {
    blockMax_out[(tokBase + tid) * NBLK + vb] = tgMax[tid];
    blockSum_out[(tokBase + tid) * NBLK + vb] = tgSum[tid];
    blockTgt_out[(tokBase + tid) * NBLK + vb] = tgTgt[tid];
  }
`;

// LANE-SLICED forward (the real memory fix): instead of one thread per vocab row
// (adjacent threads read rows WPR words apart → uncoalesced weight reads, the
// dominant ~43 GB stream at ~7% bandwidth), a SIMDGROUP of 32 lanes cooperates on
// ONE row — lane l reads words {l, l+32, ...} so the 32 lanes hit CONSECUTIVE
// memory each step (coalesced). The lane-partial dots reduce with simd_sum. The
// threadgroup's 4 simdgroups process 4 rows in parallel; BLOCK_B tokens amortize
// the dequant (each row dequantized once, reused across tokens). Same coalesced
// pattern as fused-decode-kernel.ts. h is passed TRANSPOSED [H, M].
const SGN = TG / 32; // simdgroups per threadgroup (4)
const FWD_LANE_SOURCE = String.raw`
  const uint tokBlk = threadgroup_position_in_grid.z;
  const uint vb  = threadgroup_position_in_grid.y;
  const uint lane = thread_index_in_simdgroup;       // 0..31 within the simdgroup
  const uint sg   = thread_position_in_threadgroup.x / 32u; // 0..SGN-1
  const uint M=shape[0], V=shape[1], H=shape[2], GS=shape[3], BITS=shape[4], WPR=shape[5], GR=shape[6], NBLK=shape[7];
  const float cap = capv[0];
  const uint perWord = 32u / BITS;
  const uint qmask = (BITS == 32u) ? 0xffffffffu : ((1u << BITS) - 1u);
  const uint wordsPerLane = WPR / 32u;               // WPR is a multiple of 32
  const uint blockV = (V + NBLK - 1u) / NBLK;
  const uint nStart = vb * blockV;
  const uint nEnd = min(nStart + blockV, V);
  const uint tokBase = tokBlk * BLOCK_B;

  float mx[BLOCK_B], sumexp[BLOCK_B], tgtLogit[BLOCK_B];
  uint  tgtId[BLOCK_B];
  for (uint b = 0u; b < BLOCK_B; ++b) {
    mx[b] = -INFINITY; sumexp[b] = 0.0f; tgtLogit[b] = 0.0f;
    tgtId[b] = (tokBase + b < M) ? targets[tokBase + b] : 0xffffffffu;
  }

  // each simdgroup owns rows {nStart+sg, nStart+sg+SGN, ...}; its 32 lanes share the row
  for (uint n = nStart + sg; n < nEnd; n += SGN) {
    const device uint* row = wp + (ulong)n * WPR;
    const uint sbBase = n * GR;
    float partial[BLOCK_B];
    for (uint b = 0u; b < BLOCK_B; ++b) partial[b] = 0.0f;
    for (uint j = 0u; j < wordsPerLane; ++j) {
      const uint wi = lane + 32u * j;                // coalesced across the 32 lanes
      const uint word = row[wi];
      const uint dbase = wi * perWord;
      for (uint k = 0u; k < perWord; ++k) {
        const uint d = dbase + k;
        const uint grp = d / GS;
        const float w = scales[sbBase + grp] * (float)((word >> (BITS * k)) & qmask) + biases[sbBase + grp];
        for (uint b = 0u; b < BLOCK_B; ++b) {
          const uint tb = min(tokBase + b, M - 1u);
          partial[b] += (float)h[(ulong)d * M + tb] * w; // h transposed [H, M]
        }
      }
    }
    // reduce each token's lane-partials across the simdgroup → full logit
    for (uint b = 0u; b < BLOCK_B; ++b) {
      float logit = simd_sum(partial[b]);
      if (cap > 0.0f) logit = cap * tanh(logit / cap);
      const float nm = max(mx[b], logit);
      sumexp[b] = sumexp[b] * exp(mx[b] - nm) + exp(logit - nm);
      mx[b] = nm;
      if (n == tgtId[b]) tgtLogit[b] = logit;
    }
  }

  // simd_sum broadcasts, so each simdgroup's online state is replicated across its
  // lanes; lane 0 of each sg publishes, then SGN states merge per token.
  threadgroup float mM[SGN * BLOCK_B], mS[SGN * BLOCK_B], mT[SGN * BLOCK_B];
  if (lane == 0u) {
    for (uint b = 0u; b < BLOCK_B; ++b) {
      mM[sg * BLOCK_B + b] = mx[b]; mS[sg * BLOCK_B + b] = sumexp[b]; mT[sg * BLOCK_B + b] = tgtLogit[b];
    }
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  const uint tid = thread_position_in_threadgroup.x;
  if (tid < BLOCK_B && tokBase + tid < M) {
    const uint b = tid;
    float gm = -INFINITY, gs = 0.0f, gt = 0.0f;
    for (uint s = 0u; s < SGN; ++s) {
      const float im = mM[s * BLOCK_B + b];
      const float nm = max(gm, im);
      if (nm > -INFINITY) { gs = gs * exp(gm - nm) + mS[s * BLOCK_B + b] * exp(im - nm); gm = nm; }
      gt += mT[s * BLOCK_B + b];
    }
    blockMax_out[(tokBase + b) * NBLK + vb] = gm;
    blockSum_out[(tokBase + b) * NBLK + vb] = gs;
    blockTgt_out[(tokBase + b) * NBLK + vb] = gt;
  }
`;

let _fwdLaneKernel: MetalKernel | null = null;
function fwdLaneKernel(): MetalKernel {
  if (!_fwdLaneKernel) {
    _fwdLaneKernel = new MetalKernel({
      name: "flash_cce_fwd_lane",
      inputNames: ["h", "wp", "scales", "biases", "targets", "shape", "capv"],
      outputNames: ["blockMax_out", "blockSum_out", "blockTgt_out"],
      source: FWD_LANE_SOURCE,
      header: `#define TG ${TG}\n#define BLOCK_B ${BLOCK_B}\n#define SGN ${SGN}\n`,
      ensureRowContiguous: true,
    });
  }
  return _fwdLaneKernel;
}

let _fwdSgKernel: MetalKernel | null = null;
function fwdSgKernel(): MetalKernel {
  if (!_fwdSgKernel) {
    _fwdSgKernel = new MetalKernel({
      name: "flash_cce_fwd_sg",
      inputNames: ["h", "wp", "scales", "biases", "targets", "shape", "capv"],
      outputNames: ["blockMax_out", "blockSum_out", "blockTgt_out"],
      source: FWD_SG_SOURCE,
      header: `#include <metal_simdgroup_matrix>\n#define TG ${TG}\n#define BB ${SG_BB}\n#define BV ${SG_BV}\n#define BD ${SG_BD}\n#define BDX ${SG_BD + 4}\n#define BVX ${SG_BV + 4}\n#define CCE_SG_SKIPDQ ${process.env.MLX_BUN_CCE_SG_SKIPDQ === "1" ? 1 : 0}\n`,
      ensureRowContiguous: true,
    });
  }
  return _fwdSgKernel;
}
// simdgroup_matrix forward is now the DEFAULT (fastest): the earlier "not faster"
// verdict was confounded — the SG path was bound by the Csh dequant STAGING loads
// (packed weight + per-group scale/bias), not the matmul, so it never reached the
// compute-bound regime. Removing the staging redundancy (one thread per packed
// word; scale/bias once per group) cut it 1629→848 ms, beating the scalar
// kernel's 1097 ms. Fall back to scalar (MLX_BUN_CCE_SCALAR=1) when H % SG_BD != 0.
const USE_SIMDGROUP_FWD = process.env.MLX_BUN_CCE_SCALAR !== "1" && process.env.MLX_BUN_CCE_LANE !== "1";

// Backward: dh[t,d] = Σ_v coeff_v · dequant(W_v)[d], coeff_v = g_t·(onehot_v −
// softmax_v)·sech²_v, softmax_v = exp(softcap(logit_v) − lse_t). Two-phase per
// 128-row vocab block, NO atomics: phase 1 each thread computes coeff for one
// block row (full dot → into threadgroup coeff[]); phase 2 each thread owns
// H/TG OUTPUT dims and accumulates them over the block's rows into per-thread
// registers (dacc), so each output dim is written by exactly one thread. lse is
// reused from the forward (no recompute of the global softmax normalizer).
const DPER_MAX = H_MAX / TG; // 32
const BWD_SOURCE = String.raw`
  const uint tokBlk = threadgroup_position_in_grid.z; // token-block
  const uint vb  = threadgroup_position_in_grid.y;    // vocab-block
  const uint tid = thread_position_in_threadgroup.x;
  const uint M   = shape[0];
  const uint V   = shape[1];
  const uint H   = shape[2];
  const uint GS  = shape[3];
  const uint BITS = shape[4];
  const uint WPR = shape[5];
  const uint GR  = shape[6];
  const uint NBLK = shape[7];
  const float cap = capv[0];
  const uint perWord = 32u / BITS;
  const uint qmask = (BITS == 32u) ? 0xffffffffu : ((1u << BITS) - 1u);
  const uint wordsPerGroup = GS / perWord;
  const uint DPER = H / TG;        // output dims this thread owns
  const uint dStart = tid * DPER;
  const uint blockV = (V + NBLK - 1u) / NBLK;
  const uint nStart = vb * blockV;
  const uint nEnd = min(nStart + blockV, V);
  const uint tokBase = tokBlk * BLOCK_B;

  float lseB[BLOCK_B], gB[BLOCK_B]; uint tgtB[BLOCK_B];
  for (uint b = 0u; b < BLOCK_B; ++b) {
    const uint tk = min(tokBase + b, M - 1u);
    lseB[b] = lse[tk]; gB[b] = gv[tk];
    tgtB[b] = (tokBase + b < M) ? targets[tokBase + b] : 0xffffffffu;
  }

  threadgroup float coeffB[TG * BLOCK_B];  // [row][token]
  // BLOCK_B == 4 → one float4 per output dim holds all 4 tokens, so the phase-2
  // accumulation (the backward's ~98% hotspot — a scalar coeffᵀ@W GEMM) runs as
  // one vector FMA per (row, dim) instead of 4 scalar ones.
  float4 dacc[DACC_N];                     // dacc[j] = (tok0..tok3) for dim dStart+j
  for (uint i = 0u; i < DPER; ++i) dacc[i] = float4(0.0f);
  threadgroup_barrier(mem_flags::mem_threadgroup);

  for (uint blk = nStart; blk < nEnd; blk += TG) {
    // --- phase 1: row n = blk + tid → coeff for each of BLOCK_B tokens (the
    // dequant-dot is computed once per token via shared nibble q) ---
    const uint n = blk + tid;
    float cf[BLOCK_B];
    for (uint b = 0u; b < BLOCK_B; ++b) cf[b] = 0.0f;
    if (n < nEnd) {
      const device uint* row = wp + (ulong)n * WPR;
      const uint sbBase = n * GR;
      float raw[BLOCK_B];
      for (uint b = 0u; b < BLOCK_B; ++b) raw[b] = 0.0f;
      for (uint grp = 0u; grp < GR; ++grp) {
        const float sc = scales[sbBase + grp];
        const float bi = biases[sbBase + grp];
        const uint d0 = grp * GS;
        float gacc[BLOCK_B], ghsum[BLOCK_B];
        for (uint b = 0u; b < BLOCK_B; ++b) { gacc[b] = 0.0f; ghsum[b] = 0.0f; }
        for (uint wi = 0u; wi < wordsPerGroup; ++wi) {
          const uint word = row[d0 / perWord + wi];
          const uint dbase = d0 + wi * perWord;
          for (uint k = 0u; k < perWord; ++k) {
            const float q = (float)((word >> (BITS * k)) & qmask);
            const uint d = dbase + k;
            for (uint b = 0u; b < BLOCK_B; ++b) {
              const uint tk = min(tokBase + b, M - 1u);
              const float hd = (float)h[(ulong)tk * H + d]; // phase-1 h reads aren't the bwd bottleneck (phase 2 is)
              gacc[b] += hd * q; ghsum[b] += hd;
            }
          }
        }
        for (uint b = 0u; b < BLOCK_B; ++b) raw[b] += sc * gacc[b] + bi * ghsum[b];
      }
      for (uint b = 0u; b < BLOCK_B; ++b) {
        float logit = raw[b], sech2 = 1.0f;
        if (cap > 0.0f) { const float th = tanh(raw[b] / cap); logit = cap * th; sech2 = 1.0f - th * th; }
        const float sm = exp(logit - lseB[b]);
        float c = gB[b] * ((n == tgtB[b] ? 1.0f : 0.0f) - sm);
        if (cap > 0.0f) c *= sech2;
        cf[b] = c;
      }
    }
    for (uint b = 0u; b < BLOCK_B; ++b) coeffB[tid * BLOCK_B + b] = cf[b];
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // --- phase 2: the coeffᵀ@W accumulation — the backward's ~98% hotspot. Each
    // weight dequant (wd) feeds all BLOCK_B tokens via one float4 FMA. (Loads are
    // negligible — proven ~137 ms — so the per-element dequant stays; the win is
    // vectorizing the arithmetic.) ---
#if !CCE_BWD_SKIP_P2
    for (uint r = 0u; r < TG; ++r) {
      const uint n2 = blk + r;
      if (n2 >= nEnd) break;
      const device uint* row = wp + (ulong)n2 * WPR;
      const uint sbBase = n2 * GR;
      const float4 cf = *(const threadgroup float4*)(coeffB + r * BLOCK_B); // tok0..3
#if CCE_BWD_SKIP_P2DQ
      for (uint j = 0u; j < DPER; ++j) dacc[j] += cf * ((float)((dStart + j) & 7u) * 0.01f);
#else
      for (uint j = 0u; j < DPER; ++j) {
        const uint d = dStart + j;
        const uint grp = d / GS;
        const uint word = row[d / perWord];
        const float q = (float)((word >> (BITS * (d % perWord))) & qmask);
        const float wd = scales[sbBase + grp] * q + biases[sbBase + grp];
        dacc[j] += cf * wd;
      }
#endif
    }
#else
    // PROBE: skip phase-2 accumulation but consume coeffB so phase 1 isn't DCE'd —
    // isolates phase-1 (the coeff dot) cost from phase-2 accumulation.
    dacc[0] += float4(coeffB[tid * BLOCK_B]);
#endif
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }

  // Atomic-accumulate each token's partial dh across the NBLK vocab-block programs.
  // dacc[j] = (tok0..tok3) for dim dStart+j.
  for (uint b = 0u; b < BLOCK_B; ++b) {
    if (tokBase + b >= M) break;
    for (uint j = 0u; j < DPER; ++j)
      atomic_fetch_add_explicit(&dh[(ulong)(tokBase + b) * H + dStart + j], dacc[j][b], memory_order_relaxed);
  }
`;

// dacc is sized to the ACTUAL per-thread output dims (ceil(H/TG)) rather than the
// worst-case DPER_MAX — right-sizing the register footprint raises occupancy (the
// backward's limiter). Keyed by daccN so a model with a different H rebuilds.
const _bwdKernels = new Map<number, MetalKernel>();
function bwdKernel(daccN: number): MetalKernel {
  let k = _bwdKernels.get(daccN);
  if (!k) {
    k = new MetalKernel({
      name: "flash_cce_bwd",
      inputNames: ["h", "wp", "scales", "biases", "targets", "lse", "gv", "shape", "capv"],
      outputNames: ["dh"],
      source: BWD_SOURCE,
      header: `#define TG ${TG}\n#define BLOCK_B ${BLOCK_B_BWD}\n#define DACC_N ${daccN}\n#define CCE_BWD_SKIP_P2DQ ${process.env.MLX_BUN_CCE_BWD_SKIP_P2DQ === "1" ? 1 : 0}\n#define CCE_BWD_SKIP_P2 ${process.env.MLX_BUN_CCE_BWD_SKIP_P2 === "1" ? 1 : 0}\n`,
      ensureRowContiguous: true,
      atomicOutputs: true, // dh is summed across the NBLK vocab-block programs
    });
    _bwdKernels.set(daccN, k);
  }
  return k;
}

// SIMDGROUP_MATRIX backward (phase-2 GEMM): the phase-2 accumulation dacc = coeffᵀ@W
// is ~69% of the backward (1733 ms phase-1 + 3779 ms phase-2 at e4b M=512) and is
// compute-bound, NOT register-bound (right-sizing dacc gave 0%) — so we can afford
// simdgroup_matrix's larger accumulator. Phase 1 unchanged (one thread per row →
// coeff into threadgroup, BB=8 tokens). Phase 2: each simdgroup owns H/SGN dims as
// DIMTILES persistent 8×8 acc fragments; per 8-row chunk, load coeffᵀ (transpose)
// and the dequantized W tile, mma. dh atomic-added at the end. Needs H % (SGN*8)==0.
const BB_BWD_SG = 8;
const BWD_SG_SOURCE = String.raw`
  const uint tokBlk = threadgroup_position_in_grid.z;
  const uint vb  = threadgroup_position_in_grid.y;
  const uint tid = thread_position_in_threadgroup.x;
  const uint lane = thread_index_in_simdgroup;
  const uint sg  = tid / 32u;
  const uint M=shape[0],V=shape[1],H=shape[2],GS=shape[3],BITS=shape[4],WPR=shape[5],GR=shape[6],NBLK=shape[7];
  const float cap = capv[0];
  const uint perWord = 32u / BITS;
  const uint qmask = (BITS == 32u) ? 0xffffffffu : ((1u << BITS) - 1u);
  const uint HSG = H / SGN;          // dims owned by this simdgroup
  const uint d0sg = sg * HSG;
  const uint blockV = (V + NBLK - 1u) / NBLK;
  const uint nStart = vb * blockV;
  const uint nEnd = min(nStart + blockV, V);
  const uint tokBase = tokBlk * BB;

  float lseB[BB], gB[BB]; uint tgtB[BB];
  for (uint b = 0u; b < BB; ++b) {
    const uint tk = min(tokBase + b, M - 1u);
    lseB[b] = lse[tk]; gB[b] = gv[tk];
    tgtB[b] = (tokBase + b < M) ? targets[tokBase + b] : 0xffffffffu;
  }

  threadgroup float coeffB[TG * 8];   // [row][token], 8-wide for the simdgroup tile
  threadgroup float Wsh[SGN * 64];    // per-simdgroup 8×8 dequantized W tile
  threadgroup float Csh[SGN * 64];    // per-simdgroup 8×8 store-out buffer
  threadgroup float Esh[BB * BDP];    // phase-1: token hiddens tile (logit GEMM)
  threadgroup float Cstg[BVP * BDP];  // phase-1: dequantized W tile (logit GEMM)
  threadgroup float Lsh[BB * BVP];    // phase-1: logit[token, row] tile

#if CCE_BWD_BLOCKSKIP
  // blockMax vocab-block early exit: this (token-block, vocab-block) program does
  // ~0 work if, for EVERY token, the block's max softmax prob exp(blockMax−lse) is
  // below eps AND the target isn't in this block (so no onehot term lives here).
  // On peaked logits ~all but one vocab block per token is cold → skips phase 1+2.
  // The early return is AFTER the threadgroup decls (uniform across the TG; declaring
  // threadgroup arrays after an early return fails to compile).
  bool warm = false;
  for (uint b = 0u; b < BB; ++b) {
    if (tokBase + b < M) {
      if (exp(blockMax[(tokBase + b) * NBLK + vb] - lseB[b]) >= CCE_BWD_BLOCK_EPS) warm = true;
      if (tgtB[b] >= nStart && tgtB[b] < nEnd) warm = true;
    }
  }
  if (!warm) return;
#endif

  simdgroup_float8x8 acc[DIMTILES];
  for (uint t = 0u; t < DIMTILES; ++t) acc[t] = simdgroup_float8x8(0);

  for (uint blk = nStart; blk < nEnd; blk += TG) {
    // --- phase 1 (SG-matrix): logit[tok, row] = E @ Wᵀ over H (the SAME tile GEMM
    // as the forward, with the sub-block's TG rows as the "vocab"), then coeff. ---
    for (uint vc = 0u; vc < TG; vc += BVP) {           // TG rows in BVP-row chunks
      simdgroup_float8x8 lacc = simdgroup_float8x8(0);
      for (uint d0 = 0u; d0 < H; d0 += BDP) {
        for (uint i = tid; i < BB * BDP; i += TG) {    // E tile [BB tokens, BDP]
          const uint b = i / BDP, dd = i % BDP;
          const uint tk = min(tokBase + b, M - 1u);
          Esh[i] = (float)h[(ulong)tk * H + d0 + dd];
        }
        const uint wordsPerRow = BDP / perWord;        // C tile [BVP rows, BDP] (one thread/word)
        for (uint wi = tid; wi < BVP * wordsPerRow; wi += TG) {
          const uint vrow = wi / wordsPerRow;
          const uint dloc = (wi % wordsPerRow) * perWord;
          const uint n2 = blk + vc + vrow;
          const uint d = d0 + dloc;
          uint word = 0u; float scl = 0.0f, bia = 0.0f;
          if (n2 < nEnd) {
            word = wp[(ulong)n2 * WPR + d / perWord];
            const uint grp = d / GS; scl = scales[n2 * GR + grp]; bia = biases[n2 * GR + grp];
          }
          for (uint k = 0u; k < perWord; ++k) Cstg[vrow * BDP + dloc + k] = scl * (float)((word >> (BITS * k)) & qmask) + bia;
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        for (uint kk = 0u; kk < BDP / 8u; ++kk) {       // lacc(sg's 8 rows) += E @ Cᵀ
          simdgroup_float8x8 me, mc;
          simdgroup_load(me, Esh + kk * 8u, BDP);
          simdgroup_load(mc, Cstg + (ulong)sg * 8u * BDP + kk * 8u, BDP, ulong2(0, 0), true);
          simdgroup_multiply_accumulate(lacc, me, mc, lacc);
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
      }
      simdgroup_store(lacc, Lsh + sg * 8u, BVP);        // Lsh[tok*BVP + row] = logit[tok][row]
      threadgroup_barrier(mem_flags::mem_threadgroup);
      for (uint i = tid; i < BB * BVP; i += TG) {        // derive coeff[row][tok] → coeffB
        const uint tok = i / BVP, row = i % BVP;
        const uint n2 = blk + vc + row;
        float c = 0.0f;
        if (n2 < nEnd && tokBase + tok < M) {
          float logit = Lsh[tok * BVP + row], sech2 = 1.0f;
          if (cap > 0.0f) { const float th = tanh(logit / cap); logit = cap * th; sech2 = 1.0f - th * th; }
          const float sm = exp(logit - lseB[tok]);
          c = gB[tok] * ((n2 == tgtB[tok] ? 1.0f : 0.0f) - sm);
          if (cap > 0.0f) c *= sech2;
        }
        coeffB[(vc + row) * 8u + tok] = c;
      }
      threadgroup_barrier(mem_flags::mem_threadgroup);
    }

    // --- phase 2: acc[t][tok][dim] += Σ_row coeff[row][tok] · W[row][dim] ---
    for (uint rc = 0u; rc < TG; rc += 8u) {
      // Apple-CCE near-zero coeff filter: softmax mass concentrates on a few
      // tokens, so coeff ≈ 0 for almost every vocab row → most 8-row chunks
      // contribute nothing. Skip the chunk's dim-tile dequant+mma when its whole
      // [8 rows × 8 tokens] coeff block is below eps. Safe because the SKIPPED
      // softmax mass (not each element) is what's tiny. Uniform across the
      // simdgroup (all lanes/sgs see the same coeffB[rc]).
#if CCE_BWD_FILTER
      float cmax = 0.0f;
      for (uint i = lane; i < 64u; i += 32u) cmax = max(cmax, fabs(coeffB[rc * 8u + i]));
      if (simd_max(cmax) < CCE_BWD_FILTER_EPS) continue;
#endif
      simdgroup_float8x8 mA;
      simdgroup_load(mA, coeffB + rc * 8u, 8, ulong2(0, 0), true); // mA[tok][row]
      threadgroup float* ws = Wsh + sg * 64u;
      for (uint t = 0u; t < DIMTILES; ++t) {
        const uint d0 = d0sg + t * 8u;
        for (uint i = lane; i < 64u; i += 32u) {     // dequant W[8 rows, 8 dims]
          const uint rr = i / 8u, dd = i % 8u;
          const uint n2 = blk + rc + rr;
          float w = 0.0f;
          if (n2 < nEnd) {
            const uint d = d0 + dd;
            const uint word = wp[(ulong)n2 * WPR + d / perWord];
            const float q = (float)((word >> (BITS * (d % perWord))) & qmask);
            w = scales[n2 * GR + d / GS] * q + biases[n2 * GR + d / GS];
          }
          ws[i] = w;
        }
        simdgroup_barrier(mem_flags::mem_threadgroup);
        simdgroup_float8x8 mB;
        simdgroup_load(mB, ws, 8);                    // mB[row][dim]
        simdgroup_multiply_accumulate(acc[t], mA, mB, acc[t]);
        simdgroup_barrier(mem_flags::mem_threadgroup);
      }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }

  // write each dim-tile's acc → dh (atomic across the NBLK vocab-block programs)
  threadgroup float* cs = Csh + sg * 64u;
  for (uint t = 0u; t < DIMTILES; ++t) {
    simdgroup_store(acc[t], cs, 8);
    simdgroup_barrier(mem_flags::mem_threadgroup);
    const uint d0 = d0sg + t * 8u;
    for (uint i = lane; i < 64u; i += 32u) {
      const uint tok = i / 8u, dd = i % 8u;
      if (tokBase + tok < M)
        atomic_fetch_add_explicit(&dh[(ulong)(tokBase + tok) * H + d0 + dd], cs[i], memory_order_relaxed);
    }
    simdgroup_barrier(mem_flags::mem_threadgroup);
  }
`;

// Apple-CCE coeff filter epsilon (phase-2 per-tile skip). DEFAULT OFF ("0") — the
// Apple-production shortcut skips vocab tiles whose whole coeff block < eps, which gave
// the OLD (slow, phase-2-dominated) SG kernel ~3.5×. On the steel kernel — whose phase-2
// is now QuantizedBlockLoader-fast — it is a BAD trade: measured e4b M=512 REAL it cut dh
// accuracy 0.66%→2.7% for only ~7% speedup (the win was already captured by the fast
// dequant). Opt in with MLX_BUN_CCE_BWD_FILTER_EPS=1e-5 only on genuinely peaked data.
const BWD_FILTER_EPS = process.env.MLX_BUN_CCE_BWD_FILTER_EPS ?? "0";
// blockMax vocab-block early-exit eps (skip whole cold (token-block,vocab-block) programs
// — attacks BOTH phases). DEFAULT OFF ("0"). It is LOSSLESS when it fires (only skips
// blocks whose max prob < eps AND which lack the target → ~0 contribution), so it is the
// SAFE skip; but it only pays off on genuinely peaked real text where whole 8192-vocab
// blocks go cold (the M=512 synthetic probe found nothing cold → pure overhead). Opt in
// with MLX_BUN_CCE_BWD_BLOCK_EPS=1e-5 for long real-text training; needs blockMax supplied.
const BWD_BLOCK_EPS = process.env.MLX_BUN_CCE_BWD_BLOCK_EPS ?? "0";
const _bwdSgKernels = new Map<string, MetalKernel>();
function bwdSgKernel(dimTiles: number, filterEps: string, blockEps: string): MetalKernel {
  const filterOn = Number.parseFloat(filterEps) > 0 ? 1 : 0;
  const blockOn = Number.parseFloat(blockEps) > 0 ? 1 : 0;
  const key = `${dimTiles}:${filterEps}:${blockEps}`;
  let k = _bwdSgKernels.get(key);
  if (!k) {
    const inputNames = ["h", "wp", "scales", "biases", "targets", "lse", "gv", "shape", "capv"];
    if (blockOn) inputNames.push("blockMax"); // [M, NBLK] forward partial, for the skip
    k = new MetalKernel({
      name: "flash_cce_bwd_sg",
      inputNames,
      outputNames: ["dh"],
      source: BWD_SG_SOURCE,
      header: `#include <metal_simdgroup_matrix>\n#define TG ${TG}\n#define BB ${BB_BWD_SG}\n#define SGN ${SGN}\n#define DIMTILES ${dimTiles}\n#define BVP ${SG_BV}\n#define BDP ${SG_BD}\n#define CCE_BWD_FILTER ${filterOn}\n#define CCE_BWD_FILTER_EPS ${filterEps}f\n#define CCE_BWD_BLOCKSKIP ${blockOn}\n#define CCE_BWD_BLOCK_EPS ${blockEps}f\n`,
      ensureRowContiguous: true,
      atomicOutputs: true,
    });
    _bwdSgKernels.set(key, k);
  }
  return k;
}

// STEEL backward (the production path): MLX's verbatim BlockMMA GEMM (steel-qmm-
// header.ts) for BOTH phases of dh = Σ_v coeff_v·dequant(W_v), at MLX speed AND
// [M,V]-free. Per (token-block z = BM=8 tokens, vocab-block y) threadgroup:
//   phase 1 — logit[8,32] = X[8,H] @ Wᵀ[H,32] via the SAME steel logit GEMM as the
//     forward (mma_t + QuantizedBlockLoader, K-pipelined over H) → coeff epilogue.
//   phase 2 — dh[8,H] += coeff[8,32] @ W[32,H], accumulated over the vocab tiles in a
//     persistent register accumulator D = MMATile<1, H/32>. To keep threadgroup
//     bounded (the full Wd[32,H] is 320 KB at e4b), H is tiled into HTw=128 columns:
//     per H-tile a TEMP BlockMMA over a bounded Wd[32,HTw] dequant, whose Ctile is
//     accumulated into D's frags LANE-LOCALLY (frag += frag — no get_coord math, the
//     per-lane element mapping is identical between temp and D). dh atomic-added
//     across the NBLK vocab-block programs. Validated dh ~1e-4 rel vs autograd.
//     (Design + parity: scripts/experiments/steel-bwd-htile-test.ts.)
//   PHASE-2 DEQUANT: the Wd[32,HTw] staging uses MLX's vectorized+fused
//     QuantizedBlockLoader (the SAME loader the forward uses), NOT a manual scalar
//     dequant. The wrinkle: phase-2's GEMM contracts over vocab (K=32) and outputs H
//     (the dim the quant groups run along), so the loader must run with reduction_dim=0
//     and one group per H-tile → HTw is pinned to group_size (so each H-tile is exactly
//     one quant group, satisfying BCOLS<=group_size && group_size%BCOLS==0). The loader
//     is built fresh per H-tile (correct src/scales/biases group offsets) + a single
//     load_unsafe (no next()). TN = HTw/32 = group_size/32 frags per H-tile. The earlier
//     manual scalar dequant (recomputing grp/scale/bias per element) was the bottleneck;
//     this matches the forward's qmm staging. (Validated: steel-bwd-htile-test.ts.)
// HTw (the phase-2 H-tile width) is pinned to the quant group_size in-kernel (HTw=GS_T),
// so it is not a standalone constant here — the JS side derives NHT_T/NHT4_T from gs.
const BWD_STEEL_SOURCE = String.raw`
  const uint M=shape[0], V=shape[1], H=shape[2], NBLK=shape[7], WPR=shape[5];
  const uint tokBlk=threadgroup_position_in_grid.z, vb=threadgroup_position_in_grid.y;
  // HTw is pinned to the quant group_size so each phase-2 H-tile is exactly one group
  // (lets QuantizedBlockLoader stage Wd with reduction_dim=0). TNv = HTw/32 frags/tile;
  // NHTc = H/HTw tiles; total accumulator frags = NHTc*TNv = H/32 (= NHT4_T from JS).
  constexpr int BM=8,BNv=32,BK=32,WM=1,WN=4,gs=GS_T,bts=BITS_T,HTw=GS_T,NHTc=NHT_T,TNv=GS_T/32;
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>(), BKp=BK+16/sizeof(float);
  threadgroup float Xs[BM*BKp]; threadgroup float Ws[BNv*BKp]; threadgroup float Ls[BM*BNv];
  threadgroup float coeffS[BM*BNv]; threadgroup float Wd[BNv*HTw];
  threadgroup float redMax[4]; threadgroup float tileMaxSh;   // coeff-filter reduction scratch
  using lmma_t=mlx::steel::BlockMMA<float,float,BM,BNv,BK,WM,WN,false,true,BKp,BKp>;
  using dmma_t=mlx::steel::BlockMMA<float,float,BM,HTw,BNv,WM,WN,false,false,BNv,HTw>;
  using lx_t=mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<float,BNv,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  // phase-2 W loader: BROWS=32 vocab (GEMM K), BCOLS=HTw=group_size (one group/tile),
  // reduction_dim=0, dst_ld=HTw — built fresh per H-tile, single load_unsafe.
  using lw2_t=QuantizedBlockLoader<float,BNv,HTw,HTw,0,WM*WN*SIMD_SIZE,gs,bts>;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup, lid=thread_position_in_threadgroup.x;
  const float cap=capv[0];
  const int Hh=(int)H, K_w=Hh*bpp/pf, K_g=Hh/gs, tokBase=(int)tokBlk*BM;
  const int blockV=((int)V+(int)NBLK-1)/(int)NBLK, nStart=(int)vb*blockV, nEnd=min(nStart+blockV,(int)V);
  const short num_els=(short)min(BM,(int)M-tokBase);
  short2 sc2=mlx::steel::BaseMMAFrag<float,8,8>::get_coord(sl); const short fm=sc2.y, fn=sc2.x;
  const uint perWord=32u/bts, qmask=(bts==32u)?0xffffffffu:((1u<<bts)-1u);

#if CCE_BWD_BLOCKSKIP
  // Apple-CCE vocab-block early exit: this (token-block, vocab-block) program does ~0
  // work if, for EVERY token, the block's max softmax prob exp(blockMax−lse) is below
  // eps AND the target isn't in this block (no onehot term lives here). On peaked
  // logits ~all but a couple of vocab blocks per token are cold → skips BOTH phases.
  // Uniform across the threadgroup (all threads read the same blockMax/lse/targets), so
  // the early return can't desync barriers; it is AFTER the threadgroup decls (required).
  bool warm = false;
  for (int b=0; b<BM; ++b){ int tk=tokBase+b; if (tk<(int)M){
    if (exp(blockMax[tk*(int)NBLK + (int)vb] - lse[tk]) >= CCE_BWD_BLOCK_EPS) warm=true;
    int tg2=(int)targets[tk]; if (tg2>=nStart && tg2<nEnd) warm=true; } }
  if (!warm) return;
#endif

  mlx::steel::MMATile<float,1,NHT4_T> D;   // persistent dh accumulator (H/32 frags/sg)

  for (int v0=nStart; v0<nEnd; v0+=BNv){
    // phase 1: logit tile → coeff
    lmma_t lmma(sg,sl);
    lx_t loader_x(h+(int64_t)tokBase*Hh, Hh, Xs, sg, sl);
    lw_t loader_w((const device uint8_t*)wp+v0*K_w, scales+v0*K_g, biases+v0*K_g, Hh, Ws, sg, sl);
    for(int k=0;k<Hh;k+=BK){ threadgroup_barrier(mem_flags::mem_threadgroup);
      if(num_els<BM) loader_x.load_safe(short2(BK,num_els)); else loader_x.load_unsafe();
      loader_w.load_unsafe();
      threadgroup_barrier(mem_flags::mem_threadgroup); lmma.mma(Xs,Ws); loader_x.next(); loader_w.next(); }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    lmma.Ctile.store<float,WM,WN,BNv,1>(Ls + lmma.sm*BNv + lmma.sn);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (lid<(uint)BM){ uint b=lid;
      if(tokBase+(int)b<(int)M){ const float lseb=lse[tokBase+b], gb=gv[tokBase+b]; const uint tgt=targets[tokBase+b];
        for(int v=0;v<BNv;++v){ int n=v0+v; float logit=Ls[b*BNv+v],sech2=1.0f; if(cap>0.0f){float th=tanh(logit/cap);logit=cap*th;sech2=1.0f-th*th;} float sm=exp(logit-lseb); float c=(n<nEnd)?gb*(((uint)n==tgt?1.0f:0.0f)-sm):0.0f; if(cap>0.0f)c*=sech2; coeffS[b*BNv+v]=c; } }
      else { for(int v=0;v<BNv;++v) coeffS[b*BNv+v]=0.0f; } }
    threadgroup_barrier(mem_flags::mem_threadgroup);

#if CCE_BWD_FILTER
    // Apple-CCE coeff filter: softmax mass concentrates on a few tokens, so coeff ≈ 0 for
    // almost every vocab tile even within a warm block → skip the whole phase-2 (Wd staging
    // + temp BlockMMA × NHT) when the entire coeff[8,32] tile is below eps. Parallel max
    // over the 256 coeff elems (each thread 2, simd_max per simdgroup, combine 4). Uniform
    // continue (all threads read the same tileMaxSh) so there is no barrier desync.
    { float lm=max(fabs(coeffS[lid]), fabs(coeffS[lid+128u])); lm=simd_max(lm);
      if (sl==0u) redMax[sg]=lm; }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (lid==0u) tileMaxSh=max(max(redMax[0],redMax[1]),max(redMax[2],redMax[3]));
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (tileMaxSh < CCE_BWD_FILTER_EPS) continue;
#endif

    // phase 2: per H-tile stage Wd[32,HTw] via QuantizedBlockLoader, temp BlockMMA, accum into D
    for (int ht=0; ht<NHTc; ++ht){
      const int hbase=ht*HTw;
      // src at byte addr of W[v0, hbase]; scales/biases at group ht of vocab row v0.
      lw2_t loader_w2((const device uint8_t*)wp + (int64_t)v0*K_w + (int64_t)hbase*bpp/pf,
                      scales + (int64_t)v0*K_g + ht, biases + (int64_t)v0*K_g + ht, Hh, Wd, sg, sl);
      loader_w2.load_unsafe();
      threadgroup_barrier(mem_flags::mem_threadgroup);
      dmma_t tmp(sg,sl); tmp.mma(coeffS, Wd);
      for(int j=0;j<TNv;++j) D.frag_at(0, ht*TNv+j) += tmp.Ctile.frag_at(0,j);
      threadgroup_barrier(mem_flags::mem_threadgroup);
    }
  }

  // store D → dh (atomic-add across the NBLK vocab-block programs)
  for(int gj=0; gj<NHT4_T; ++gj){
    int ht=gj/TNv, j=gj%TNv; int row=tokBase+(int)fm; int col=ht*HTw + 8*(int)sg + (int)fn + j*32;
    if(row<(int)M && col+1<=Hh){ thread auto& fr=D.frag_at(0,gj);
      atomic_fetch_add_explicit(&dh[(int64_t)row*Hh + col], fr[0], memory_order_relaxed);
      atomic_fetch_add_explicit(&dh[(int64_t)row*Hh + col+1], fr[1], memory_order_relaxed); }
  }
`;
const BWD_STEEL_BM = 8;
const _bwdSteelKernels = new Map<string, MetalKernel>();
function bwdSteelKernel(gs: number, bits: number, H: number, filterEps: string, blockEps: string): MetalKernel {
  // HTw == group_size (one quant group per phase-2 H-tile → QuantizedBlockLoader).
  const nht = H / gs;            // # H-tiles
  const nFrags = nht * (gs / 32); // total accumulator frags/sg = H/32 (NHT4_T name kept)
  // Apple-CCE skips: coeff filter (phase-2 per-tile) + blockMax vocab-block early exit
  // (whole-program). Both compile out when eps=0 → zero overhead, exact dh (the parity
  // gate). blockMax skip needs the forward's [M,NBLK] blockMax as an extra input.
  const filterOn = Number.parseFloat(filterEps) > 0 ? 1 : 0;
  const blockOn = Number.parseFloat(blockEps) > 0 ? 1 : 0;
  const key = `${gs}:${bits}:${H}:${filterEps}:${blockEps}`;
  let k = _bwdSteelKernels.get(key);
  if (!k) {
    const inputNames = ["h", "wp", "scales", "biases", "targets", "lse", "gv", "shape", "capv"];
    if (blockOn) inputNames.push("blockMax"); // [M, NBLK] forward partial, for the vocab-block skip
    k = new MetalKernel({
      name: "flash_cce_bwd_steel",
      inputNames,
      outputNames: ["dh"],
      source: BWD_STEEL_SOURCE,
      header: `${STEEL_QMM_HEADER}\n#define GS_T ${gs}\n#define BITS_T ${bits}\n#define NHT_T ${nht}\n#define NHT4_T ${nFrags}\n#define CCE_BWD_FILTER ${filterOn}\n#define CCE_BWD_FILTER_EPS ${filterEps}f\n#define CCE_BWD_BLOCKSKIP ${blockOn}\n#define CCE_BWD_BLOCK_EPS ${blockEps}f\n`,
      ensureRowContiguous: true,
      atomicOutputs: true,
    });
    _bwdSteelKernels.set(key, k);
  }
  return k;
}

let _fwdKernel: MetalKernel | null = null;
function fwdKernel(): MetalKernel {
  if (!_fwdKernel) {
    _fwdKernel = new MetalKernel({
      name: "flash_cce_fwd",
      inputNames: ["h", "wp", "scales", "biases", "targets", "shape", "capv"],
      outputNames: ["blockMax_out", "blockSum_out", "blockTgt_out"],
      source: FWD_SOURCE,
      header: `#define TG ${TG}\n#define BLOCK_B ${BLOCK_B}\n`,
      ensureRowContiguous: true,
    });
  }
  return _fwdKernel;
}

function u32(values: number[]): MlxArray {
  // COPY into an mlx-owned array (fromBytesCopy = mlx_array_new_data), NOT the
  // pinning fromView. These tiny kernel-arg arrays (shape, targets) feed a LAZY
  // kernel and are disposed before it evaluates; pinning leaks one host buffer
  // per call, never released (unbounded `pinned` map + a deferred native
  // use-after-free under memory pressure — the seg/accum crash). A few-int copy
  // is free; correctness is not.
  return MlxArray.fromBytesCopy(new Uint8Array(new Uint32Array(values).buffer), [values.length], Dtype.uint32);
}

/** Flash-CCE forward: per-token response log-prob [M] (f32) + lse [M] (f32),
 *  computing logits in-kernel from the quantized head — no [M,V] materialized.
 *  `hResp` is [M, hidden] (any float dtype; cast to f32 for the kernel). `targets`
 *  are the response target token ids [M]. Caller owns the returned arrays. */
// STEEL forward: MLX's verbatim quantized BlockMMA GEMM (steel-qmm-header.ts) for the
// logit tile (BM=BN=BK=32, WM=WN=2 → 4 simdgroups × 16×16 register tiles, BK_padded),
// with ONLY the ORPO epilogue diverging — softcap + online-softmax over each BN vocab
// tile (no [M,V]). Per (token-block z, vocab-block y) threadgroup; partials [M,NBLK]
// merged in MLX. Same logit math as quantizedMatmul (validated 1e-5) at MLX speed
// (e4b logits 101 ms vs MLX 106 ms; 8.4× our old hand-rolled forward).
const FWD_STEEL_SOURCE = String.raw`
  const uint M=shape[0], V=shape[1], H=shape[2], NBLK=shape[7];
  const uint tokBlk=threadgroup_position_in_grid.z, vb=threadgroup_position_in_grid.y;
  constexpr int BM=32,BK=32,BN=32,WM=2,WN=2,gs=GS_T,bts=BITS_T;
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>(), BKp=BK+16/sizeof(float);
  threadgroup float Xs[BM*BKp]; threadgroup float Ws[BN*BKp]; threadgroup float Ls[BM*BN];
  threadgroup float tgMax[BM], tgSum[BM], tgTgt[BM]; threadgroup uint tgTid[BM];
  using mma_t=mlx::steel::BlockMMA<float,float,BM,BN,BK,WM,WN,false,true,BKp,BKp>;
  using lx_t=mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<float,BN,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup, lid=thread_position_in_threadgroup.x;
  const float cap=capv[0];
  const int Hh=(int)H, K_w=Hh*bpp/pf, K_g=Hh/gs;
  const int blockV=((int)V+(int)NBLK-1)/(int)NBLK;
  const int nStart=(int)vb*blockV, nEnd=min(nStart+blockV,(int)V), tokBase=(int)tokBlk*BM;
  const short num_els=(short)min(BM,(int)M-tokBase);
  if (lid<(uint)BM){ tgMax[lid]=-INFINITY; tgSum[lid]=0.0f; tgTgt[lid]=0.0f; tgTid[lid]=(tokBase+(int)lid<(int)M)?targets[tokBase+lid]:0xffffffffu; }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (int v0=nStart; v0<nEnd; v0+=BN){
    mma_t mma_op(sg,sl);
    lx_t loader_x(h+(int64_t)tokBase*Hh, Hh, Xs, sg, sl);
    lw_t loader_w((const device uint8_t*)wp+v0*K_w, scales+v0*K_g, biases+v0*K_g, Hh, Ws, sg, sl);
    for(int k=0;k<Hh;k+=BK){ threadgroup_barrier(mem_flags::mem_threadgroup);
      if(num_els<BM) loader_x.load_safe(short2(BK,num_els)); else loader_x.load_unsafe();
      loader_w.load_unsafe();
      threadgroup_barrier(mem_flags::mem_threadgroup); mma_op.mma(Xs,Ws); loader_x.next(); loader_w.next(); }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    mma_op.Ctile.store<float,WM,WN,BN,1>(Ls + mma_op.sm*BN + mma_op.sn);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (lid<(uint)BM && tokBase+(int)lid<(int)M){ uint b=lid;
      for (int v=0; v<BN; ++v){ int n=v0+v; if(n>=nEnd) break;
        float logit=Ls[b*BN+v]; if(cap>0.0f) logit=cap*tanh(logit/cap);
        float nm=max(tgMax[b],logit); tgSum[b]=tgSum[b]*exp(tgMax[b]-nm)+exp(logit-nm); tgMax[b]=nm;
        if((uint)n==tgTid[b]) tgTgt[b]=logit; }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
  if (lid<(uint)BM && tokBase+(int)lid<(int)M){ uint t=tokBase+lid;
    blockMax_out[t*NBLK+vb]=tgMax[lid]; blockSum_out[t*NBLK+vb]=tgSum[lid]; blockTgt_out[t*NBLK+vb]=tgTgt[lid]; }
`;
const STEEL_BM = 32;
const _fwdSteelKernels = new Map<string, MetalKernel>();
function fwdSteelKernel(gs: number, bits: number): MetalKernel {
  const key = `${gs}:${bits}`;
  let k = _fwdSteelKernels.get(key);
  if (!k) {
    k = new MetalKernel({
      name: "flash_cce_fwd_steel",
      inputNames: ["h", "wp", "scales", "biases", "targets", "shape", "capv"],
      outputNames: ["blockMax_out", "blockSum_out", "blockTgt_out"],
      source: FWD_STEEL_SOURCE,
      header: `${STEEL_QMM_HEADER}\n#define GS_T ${gs}\n#define BITS_T ${bits}\n`,
      ensureRowContiguous: true,
    });
    _fwdSteelKernels.set(key, k);
  }
  return k;
}

export function flashCceForward(
  hResp: MlxArray, head: FlashCceHead, targets: number[],
): { logp: MlxArray; lse: MlxArray; blockMax: MlxArray } {
  const M = hResp.shape[0]!;
  const H = hResp.shape[1]!;
  const V = head.scales.shape[0]!;
  const GR = head.scales.shape[1]!;
  const GS = head.groupSize;
  const WPR = head.w.shape[1]!;
  if (H > H_MAX) throw new Error(`flashCceForward: hidden ${H} > H_MAX ${H_MAX}`);
  if (GR * GS !== H) throw new Error(`flashCceForward: GR*GS ${GR * GS} != H ${H}`);

  // Vocab blocks sized so each threadgroup handles a bounded slice (≈ VOCAB_BLOCK
  // rows) — independent of V, so a single threadgroup never runs the whole vocab
  // (the e4b watchdog fix). NBLK = ceil(V / VOCAB_BLOCK).
  const NBLK = Math.max(1, Math.ceil(V / VOCAB_BLOCK));
  const hF = hResp.dtype === Dtype.float32 ? hResp : hResp.astype(Dtype.float32);
  const scF = head.scales.dtype === Dtype.float32 ? head.scales : head.scales.astype(Dtype.float32);
  const biF = head.biases.dtype === Dtype.float32 ? head.biases : head.biases.astype(Dtype.float32);
  const tgtArr = u32(targets);
  const shape = u32([M, V, H, GS, head.bits, WPR, GR, NBLK]);
  const capv = MlxArray.fromFloat32(new Float32Array([head.softcap ?? 0]), [1]);

  // DEFAULT = simdgroup_matrix kernel with efficient dequant staging (848 ms, the
  // fastest measured — matmul throughput once the staging loads stopped bounding
  // it). MLX_BUN_CCE_SCALAR=1 → one-thread-per-row scalar+coalesced-h (1097 ms;
  // also the H % SG_BD != 0 fallback). MLX_BUN_CCE_LANE=1 → lane-sliced (2.6×
  // slower; scatters the h broadcast — recorded dead end).
  // DEFAULT = STEEL (verbatim MLX BlockMMA GEMM, 8.4× the old SG forward) when the
  // tiling is clean (H,V,blockV all % 32). MLX_BUN_CCE_NOSTEEL=1 falls back to the
  // old kernels (simdgroup / scalar / lane).
  const blockV0 = Math.ceil(V / NBLK);
  const useSteel = process.env.MLX_BUN_CCE_NOSTEEL !== "1" && H % 32 === 0 && V % 32 === 0 && blockV0 % 32 === 0;
  const useSimd = !useSteel && USE_SIMDGROUP_FWD && H % SG_BD === 0;
  const useLane = !useSteel && !useSimd && process.env.MLX_BUN_CCE_LANE === "1" && WPR % 32 === 0;
  const kernel = useSteel ? fwdSteelKernel(GS, head.bits) : useSimd ? fwdSgKernel() : useLane ? fwdLaneKernel() : fwdKernel();
  const tokTile = useSteel ? STEEL_BM : useSimd ? SG_BB : BLOCK_B;
  // steel + simdgroup read h as [M, H] (M on axis 0); lane + scalar read h TRANSPOSED
  // [H, M] (M on axis 1) — they stage E into threadgroup themselves.
  const transposedH = !useSteel && !useSimd;
  const hIn = transposedH ? ops.transposeAxes(hF, [1, 0]) : hF;
  let bMax: MlxArray | undefined, bSum: MlxArray | undefined, bTgt: MlxArray | undefined;
  try {
    const outs = kernel.apply([hIn, head.w, scF, biF, tgtArr, shape, capv], {
      // Derive outputs + grid from the input shapes (hResp = inputs[0]) so the
      // kernel composes inside an mx.compile'd closure: [M,NBLK] f32 partials, one
      // threadgroup per (token-block, vocab-block). NBLK is fixed (from V).
      outputShapeFn: (ins) => {
        const m = transposedH ? ins[0]!.shape[1]! : ins[0]!.shape[0]!;
        return [
          { shape: [m, NBLK], dtype: Dtype.float32 },
          { shape: [m, NBLK], dtype: Dtype.float32 },
          { shape: [m, NBLK], dtype: Dtype.float32 },
        ];
      },
      grid: (ins) => [TG, NBLK, Math.ceil((transposedH ? ins[0]!.shape[1]! : ins[0]!.shape[0]!) / tokTile)],
      threadGroup: [TG, 1, 1],
    });
    [bMax, bSum, bTgt] = outs as [MlxArray, MlxArray, MlxArray];
    // Cross-vocab-block merge in MLX: gMax = max_b; gSum = Σ_b sum_b·exp(max_b−gMax);
    // lse = gMax + log(gSum); logp = target − lse. (Apple CCE does this with a
    // locked atomic logaddexp in-kernel; the partials are tiny [M,NBLK] so an MLX
    // reduction is simpler and just as exact.)
    const gMax = ops.maxAxis(bMax, 1, false); // [M]
    const gMaxCol = ops.reshape(gMax, [M, 1]);
    // Bind every nested intermediate so its MlxArray wrapper gets disposed — a
    // bare `ops.exp(ops.sub(...))` leaks the inner `sub` (stays live in `active`
    // until the GC finalizer backstop), and this runs TWICE per step (chosen +
    // rejected). gMax was also missing from the dispose list below.
    const sub = ops.sub(bMax, gMaxCol);
    const shifted = ops.exp(sub); // [M, NBLK]
    const prod = ops.mul(bSum, shifted);
    const gSum = ops.sumAxis(prod, 1, false); // [M]
    const logG = ops.log(gSum);
    const lse = ops.add(gMax, logG); // [M]
    const tgt = ops.sumAxis(bTgt, 1, false); // [M] (owning block only is nonzero)
    const logp = ops.sub(tgt, lse);
    for (const a of [gMax, gMaxCol, sub, shifted, prod, gSum, logG, tgt]) a.dispose();
    const blockMax = bMax!; bMax = undefined; // hand off to caller (backward block-skip)
    return { logp, lse, blockMax };
  } finally {
    bMax?.dispose(); bSum?.dispose(); bTgt?.dispose();
    if (hIn !== hF) hIn.dispose();
    if (hF !== hResp) hF.dispose();
    if (scF !== head.scales) scF.dispose();
    if (biF !== head.biases) biF.dispose();
    tgtArr.dispose();
    shape.dispose();
    capv.dispose();
  }
}

/** Flash-CCE backward: dh [M, hidden] (f32) = ∂(Σ_t cotangent_t · logp_t)/∂h.
 *  `lse` is the forward's saved log-sum-exp [M]; `cot` is the per-token cotangent
 *  ∂loss/∂logp_t [M]. Recomputes logits in-kernel (no [M,V]); writes dh directly
 *  (no atomics). Caller owns the result. */
export function flashCceBackward(
  hResp: MlxArray, head: FlashCceHead, targets: number[], lse: MlxArray, cot: number[],
  // Apple-CCE coeff filter eps. Default ON (BWD_FILTER_EPS) for the ORPO training
  // path — a pretrained model's softmax is peaked, so skipping near-zero-coeff rows
  // is near-lossless and ~3.5× faster. Pass "0" for exact gradients (the parity gate
  // does this, since synthetic-flat softmax has no negligible rows to skip).
  filterEps: string = BWD_FILTER_EPS,
  // The forward's `blockMax [M, NBLK]` enables the vocab-block early exit (skips
  // whole cold programs — attacks phase 1). Omit (or set blockEps "0") for exact.
  blockMax?: MlxArray, blockEps: string = BWD_BLOCK_EPS,
): MlxArray {
  const M = hResp.shape[0]!;
  const H = hResp.shape[1]!;
  const V = head.scales.shape[0]!;
  const GR = head.scales.shape[1]!;
  const GS = head.groupSize;
  const WPR = head.w.shape[1]!;
  if (H > H_MAX) throw new Error(`flashCceBackward: hidden ${H} > H_MAX ${H_MAX}`);
  if (H % TG !== 0) throw new Error(`flashCceBackward: hidden ${H} not divisible by TG ${TG}`);

  const hF = hResp.dtype === Dtype.float32 ? hResp : hResp.astype(Dtype.float32);
  const scF = head.scales.dtype === Dtype.float32 ? head.scales : head.scales.astype(Dtype.float32);
  const biF = head.biases.dtype === Dtype.float32 ? head.biases : head.biases.astype(Dtype.float32);
  const lseF = lse.dtype === Dtype.float32 ? lse : lse.astype(Dtype.float32);
  const NBLK = Math.max(1, Math.ceil(V / VOCAB_BLOCK));
  const tgtArr = u32(targets);
  const gv = MlxArray.fromFloat32(new Float32Array(cot), [M]);
  const shape = u32([M, V, H, GS, head.bits, WPR, GR, NBLK]);
  const capv = MlxArray.fromFloat32(new Float32Array([head.softcap ?? 0]), [1]);

  // STEEL is the DEFAULT (verbatim MLX BlockMMA GEMM for both phases, [M,V]-free) when
  // the tiling is clean (H,V,blockV all %32 AND H % HTw for the H-tiled accumulator).
  // MLX_BUN_CCE_BWD_NOSTEEL=1 falls back to the old kernels. The steel backward now
  // carries the SAME Apple-CCE skips as the SG kernel — coeff filter (phase-2 per-tile)
  // + blockMax vocab-block early exit (whole-program) — both compiled out at eps=0
  // (exact, the parity gate) and default-on for training (peaked softmax → ~all vocab cold).
  const blockV0 = Math.ceil(V / NBLK);
  // HTw == group_size for the phase-2 QuantizedBlockLoader (one group per H-tile); needs
  // H % GS == 0 (always, GR*GS=H) and GS % 32 == 0 (TNv = GS/32 frags per H-tile integral).
  const useSteel = process.env.MLX_BUN_CCE_BWD_NOSTEEL !== "1" && H % 32 === 0 && V % 32 === 0 && blockV0 % 32 === 0 && H % GS === 0 && GS % 32 === 0;
  // simdgroup_matrix phase-2 GEMM is the next tier (5512→3913 ms, 1.41×) when the H
  // tiling is clean; MLX_BUN_CCE_BWD_SCALAR=1 forces the float4 scalar kernel.
  const useSg = !useSteel && process.env.MLX_BUN_CCE_BWD_SCALAR !== "1" && H % (SGN * 8) === 0 && H % SG_BD === 0;
  // Block-skip is on (either kernel) only when blockMax is supplied AND blockEps>0 (the
  // kernel reads it as an extra input). The coeff filter needs no extra input (just eps).
  const useBlockSkip = (useSteel || useSg) && blockMax != null && Number.parseFloat(blockEps) > 0;
  const bmF = useBlockSkip ? (blockMax!.dtype === Dtype.float32 ? blockMax! : blockMax!.astype(Dtype.float32)) : null;
  const kernel = useSteel
    ? bwdSteelKernel(GS, head.bits, H, filterEps, useBlockSkip ? blockEps : "0")
    : useSg ? bwdSgKernel(H / SGN / 8, filterEps, useBlockSkip ? blockEps : "0") : bwdKernel(Math.ceil(H / TG));
  const tokTile = useSteel ? BWD_STEEL_BM : useSg ? BB_BWD_SG : BLOCK_B_BWD;
  const baseInputs = [hF, head.w, scF, biF, tgtArr, lseF, gv, shape, capv];
  try {
    const outs = kernel.apply(useBlockSkip ? [...baseInputs, bmF!] : baseInputs, {
      outputShapeFn: (ins) => [{ shape: [ins[0]!.shape[0]!, H], dtype: Dtype.float32 }], // dh [M, hidden]
      grid: (ins) => [TG, NBLK, Math.ceil(ins[0]!.shape[0]! / tokTile)],
      threadGroup: [TG, 1, 1],
      initValue: 0, // dh starts at 0; vocab-block programs atomic-add into it
    });
    return outs[0]!;
  } finally {
    if (hF !== hResp) hF.dispose();
    if (bmF && bmF !== blockMax) bmF.dispose();
    if (scF !== head.scales) scF.dispose();
    if (biF !== head.biases) biF.dispose();
    if (lseF !== lse) lseF.dispose();
    tgtArr.dispose();
    gv.dispose();
    shape.dispose();
    capv.dispose();
  }
}
