// L2 flash-attention training kernels — port of optiq/ops/flash_attention_{metal,
// backward_metal}.py. FlashAttention-2 as Metal kernels: the forward runs in one
// dispatch with online softmax (never materializing the [.,L,L] score matrix),
// and the backward is three dispatches (D-vec, dKV, dQ) that recompute scores per
// tile. Memory is O(seq·head_dim), not O(seq²) — this is what lets long-context
// LoRA training fit where stock fast-sdpa (L1) tops out ~2048 tokens.
//
// Bit-exact to OPTIQ (the L2 oracle), NOT to mlx-lm: online softmax accumulates
// in fp32 but stores fp16, so it differs from one-shot SDPA. Wired through
// CustomVjp (the forward is a CustomKernel with no auto-vjp).
//
// Shaders are copied verbatim from optiq; only the host glue is TS.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { MetalKernel } from "../mlx/metal-kernel";
import { CustomVjp } from "../mlx/custom-vjp";
import { createCausalMask, type Mask } from "./gemma4-base";

export const SUPPORTED_HEAD_DIMS = new Set([64, 96, 128, 256, 512]);

/** (BLOCK_Q, BLOCK_KV) for the forward kernel at this head_dim. */
function forwardTiles(headDim: number): [number, number] {
  if (headDim <= 64) return [64, 64];
  if (headDim <= 128) return [32, 32];
  if (headDim <= 256) return [16, 16];
  if (headDim <= 512) return [8, 8];
  throw new Error(`unsupported head_dim=${headDim}`);
}

/** uint32 [n] array (matches optiq's shape/causal input dtype). */
function u32(values: number[]): MlxArray {
  const u = new Uint32Array(values);
  return MlxArray.fromView(new Uint8Array(u.buffer.slice(0)), [values.length], Dtype.uint32);
}

// Forward shader — verbatim from optiq flash_attention_metal.py _KERNEL_SOURCE.
const FWD_SOURCE = `
const uint q_tile_idx = threadgroup_position_in_grid.x;
const uint head       = threadgroup_position_in_grid.y;   // 0..Hq-1
const uint batch      = threadgroup_position_in_grid.z;
const uint tid        = thread_position_in_threadgroup.x;

const uint B   = shape[0];
const uint Hq  = shape[1];
const uint Hkv = shape[2];
const uint Tq  = shape[3];
const uint Tkv = shape[4];
const uint D   = shape[5];

const float fscale = scale[0];
const uint  is_causal = causal[0];

const uint reps    = Hq / Hkv;
const uint kv_head = head / reps;

const uint q_row_global = q_tile_idx * BQ + tid;
const bool q_row_valid  = q_row_global < Tq;

threadgroup half q_tile[BQ * D_MAX];
threadgroup half k_tile[BKV * D_MAX];
threadgroup half v_tile[BKV * D_MAX];

float m_i = -INFINITY;
float l_i = 0.0f;
float o_i[D_MAX];
for (uint d = 0; d < D; ++d) { o_i[d] = 0.0f; }

if (q_row_valid) {
    const uint q_base = ((batch * Hq + head) * Tq + q_row_global) * D;
    for (uint d = 0; d < D; ++d) {
        q_tile[tid * D + d] = q[q_base + d];
    }
} else {
    for (uint d = 0; d < D; ++d) {
        q_tile[tid * D + d] = 0.0h;
    }
}
threadgroup_barrier(mem_flags::mem_threadgroup);

const uint n_kv_tiles = (Tkv + BKV - 1u) / BKV;
for (uint kv_tile = 0u; kv_tile < n_kv_tiles; ++kv_tile) {
    const uint kv_base_row = kv_tile * BKV;

    const uint rows_this_tile = min((uint)BKV, Tkv - kv_base_row);
    if (tid < rows_this_tile) {
        const uint kv_global_row = kv_base_row + tid;
        const uint kv_global = ((batch * Hkv + kv_head) * Tkv + kv_global_row) * D;
        for (uint d = 0; d < D; ++d) {
            k_tile[tid * D + d] = k[kv_global + d];
            v_tile[tid * D + d] = v[kv_global + d];
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (is_causal && kv_base_row > q_row_global) {
        threadgroup_barrier(mem_flags::mem_threadgroup);
        continue;
    }

    float s[BKV];
    float row_max = -INFINITY;
    for (uint j = 0u; j < rows_this_tile; ++j) {
        float dot = 0.0f;
        for (uint d = 0u; d < D; ++d) {
            dot += (float)q_tile[tid * D + d] * (float)k_tile[j * D + d];
        }
        dot *= fscale;
        const uint kpos = kv_base_row + j;
        if (is_causal && kpos > q_row_global) {
            dot = -INFINITY;
        } else if (shape[6] != 0u && q_row_global >= kpos && (q_row_global - kpos) >= shape[6]) {
            dot = -INFINITY;  // sliding window: too far in the past
        }
        s[j] = dot;
        row_max = max(row_max, dot);
    }

    const float m_new = max(m_i, row_max);
    // Skip a tile that is fully masked for this q row (every score -inf) —
    // happens with a sliding window when a past tile is entirely out of range.
    // Without this guard the online softmax does exp(-inf - -inf) = NaN.
    if (m_new > -INFINITY) {
        const float rescale = exp(m_i - m_new);
        float row_sum = 0.0f;
        for (uint j = 0u; j < rows_this_tile; ++j) {
            s[j] = exp(s[j] - m_new);
            row_sum += s[j];
        }
        l_i = rescale * l_i + row_sum;

        for (uint d = 0u; d < D; ++d) {
            float new_contrib = 0.0f;
            for (uint j = 0u; j < rows_this_tile; ++j) {
                new_contrib += s[j] * (float)v_tile[j * D + d];
            }
            o_i[d] = rescale * o_i[d] + new_contrib;
        }
        m_i = m_new;
    }

    threadgroup_barrier(mem_flags::mem_threadgroup);
}

if (q_row_valid) {
    const uint out_base = ((batch * Hq + head) * Tq + q_row_global) * D;
    const float inv_l = 1.0f / l_i;
    for (uint d = 0u; d < D; ++d) {
        o[out_base + d] = (half)(o_i[d] * inv_l);
    }
    const uint lse_base = (batch * Hq + head) * Tq + q_row_global;
    l_out[lse_base] = m_i + log(l_i);
}
`;

const fwdKernels = new Map<number, MetalKernel>();
function fwdKernel(headDim: number): MetalKernel {
  let k = fwdKernels.get(headDim);
  if (!k) {
    const [bq, bkv] = forwardTiles(headDim);
    const header = `#define BQ ${bq}\n#define BKV ${bkv}\n#define D_MAX ${headDim}\n`;
    k = new MetalKernel({
      name: `optiq_flash_attention_fwd_d${headDim}`,
      inputNames: ["q", "k", "v", "shape", "scale", "causal"],
      outputNames: ["o", "l_out"],
      source: FWD_SOURCE,
      header,
      ensureRowContiguous: true,
    });
    fwdKernels.set(headDim, k);
  }
  return k;
}

/** Single-dispatch Metal flash-attention forward. q,k,v are fp16
 *  ([B,Hq,Tq,D] / [B,Hkv,Tkv,D]). Returns [O fp16, L fp32 (log-sum-exp)]. */
export function flashForward(
  q: MlxArray, k: MlxArray, v: MlxArray, scale: number, causal: boolean, window = 0,
): [MlxArray, MlxArray] {
  const [B, Hq, Tq, D] = q.shape as [number, number, number, number];
  const [, Hkv, Tkv] = k.shape as [number, number, number, number];
  const [bq] = forwardTiles(D);
  const nQTiles = Math.ceil(Tq / bq);

  const shape = u32([B, Hq, Hkv, Tq, Tkv, D, window]);
  const scaleArr = MlxArray.fromFloat32(new Float32Array([scale]), [1]);
  const causalArr = u32([causal ? 1 : 0]);
  try {
    const outs = fwdKernel(D).apply([q, k, v, shape, scaleArr, causalArr], {
      outputs: [
        { shape: [B, Hq, Tq, D], dtype: Dtype.float16 },
        { shape: [B, Hq, Tq], dtype: Dtype.float32 },
      ],
      grid: [nQTiles * bq, Hq, B],
      threadGroup: [bq, 1, 1],
    });
    return [outs[0]!, outs[1]!];
  } finally {
    shape.dispose();
    scaleArr.dispose();
    causalArr.dispose();
  }
}

// ---------------------------------------------------------------------------
// Backward — three Metal dispatches (D-vec, dKV, dQ), verbatim from optiq
// flash_attention_backward_metal.py.
// ---------------------------------------------------------------------------

/** (BQ_BWD, BKV_BWD) for the backward kernels at this head_dim. */
function backwardTiles(headDim: number): [number, number] {
  if (headDim <= 64) return [32, 32];
  if (headDim <= 128) return [16, 32];
  if (headDim <= 256) return [8, 16];
  if (headDim <= 512) return [4, 8];
  throw new Error(`unsupported head_dim=${headDim}`);
}

// Pass 1: D_i = rowsum(dO_i ⊙ O_i). No tile defines needed.
const D_SOURCE = `
const uint idx = thread_position_in_grid.x;
const uint B   = shape[0];
const uint Hq  = shape[1];
const uint Tq  = shape[2];
const uint D   = shape[3];
const uint total = B * Hq * Tq;
if (idx >= total) return;

const uint base = idx * D;
float acc = 0.0f;
for (uint d = 0u; d < D; ++d) {
    acc += (float)o[base + d] * (float)do_[base + d];
}
d_out[idx] = acc;
`;

// Pass 2: dK, dV — one dispatch per KV tile, inner loop over Q tiles.
const DKV_SOURCE = `
const uint kv_tile_idx = threadgroup_position_in_grid.x;
const uint kv_head     = threadgroup_position_in_grid.y;   // 0..Hkv-1
const uint batch       = threadgroup_position_in_grid.z;
const uint tid         = thread_position_in_threadgroup.x;

const uint B   = shape[0];
const uint Hq  = shape[1];
const uint Hkv = shape[2];
const uint Tq  = shape[3];
const uint Tkv = shape[4];
const uint D   = shape[5];
const uint reps = Hq / Hkv;

const float fscale = scale[0];
const uint  is_causal = causal[0];

const uint kv_row_global = kv_tile_idx * BKV + tid;
const bool kv_row_valid  = kv_row_global < Tkv;

threadgroup half q_tile[BQ * D_MAX];
threadgroup half do_tile[BQ * D_MAX];
threadgroup half k_tile[BKV * D_MAX];
threadgroup half v_tile[BKV * D_MAX];
threadgroup float l_tile[BQ];
threadgroup float dRow[BQ];

float dK_j[D_MAX];
float dV_j[D_MAX];
for (uint d = 0u; d < D; ++d) {
    dK_j[d] = 0.0f;
    dV_j[d] = 0.0f;
}

if (kv_row_valid) {
    const uint kv_base = ((batch * Hkv + kv_head) * Tkv + kv_row_global) * D;
    for (uint d = 0u; d < D; ++d) {
        k_tile[tid * D + d] = k[kv_base + d];
        v_tile[tid * D + d] = v[kv_base + d];
    }
}
threadgroup_barrier(mem_flags::mem_threadgroup);

const uint n_q_tiles = (Tq + BQ - 1u) / BQ;
for (uint q_h_rel = 0u; q_h_rel < reps; ++q_h_rel) {
    const uint q_head = kv_head * reps + q_h_rel;

    for (uint qi = 0u; qi < n_q_tiles; ++qi) {
        const uint q_base_row = qi * BQ;

        if (is_causal && (q_base_row + BQ) <= kv_tile_idx * BKV) {
            threadgroup_barrier(mem_flags::mem_threadgroup);
            continue;
        }

        const uint rows_this_q = min((uint)BQ, Tq - q_base_row);
        if (tid < rows_this_q) {
            const uint q_global_row = q_base_row + tid;
            const uint q_base = ((batch * Hq + q_head) * Tq + q_global_row) * D;
            for (uint d = 0u; d < D; ++d) {
                q_tile[tid * D + d] = q[q_base + d];
                do_tile[tid * D + d] = do_[q_base + d];
            }
            const uint lse_idx = (batch * Hq + q_head) * Tq + q_global_row;
            l_tile[tid] = l_in[lse_idx];
            dRow[tid] = d_vec[lse_idx];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);

        if (kv_row_valid) {
            for (uint i = 0u; i < rows_this_q; ++i) {
                float s = 0.0f;
                for (uint d = 0u; d < D; ++d) {
                    s += (float)q_tile[i * D + d] * (float)k_tile[tid * D + d];
                }
                s *= fscale;
                const uint q_row_global = q_base_row + i;
                if (is_causal && kv_row_global > q_row_global) {
                    s = -INFINITY;
                } else if (shape[6] != 0u && q_row_global >= kv_row_global && (q_row_global - kv_row_global) >= shape[6]) {
                    s = -INFINITY;  // sliding window
                }
                const float p = exp(s - l_tile[i]);

                float dp = 0.0f;
                for (uint d = 0u; d < D; ++d) {
                    dp += (float)do_tile[i * D + d] * (float)v_tile[tid * D + d];
                }
                const float ds = p * (dp - dRow[i]);

                for (uint d = 0u; d < D; ++d) {
                    dV_j[d] += p * (float)do_tile[i * D + d];
                }
                for (uint d = 0u; d < D; ++d) {
                    dK_j[d] += ds * (float)q_tile[i * D + d] * fscale;
                }
            }
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }
}

if (kv_row_valid) {
    const uint out_base = ((batch * Hkv + kv_head) * Tkv + kv_row_global) * D;
    for (uint d = 0u; d < D; ++d) {
        dk_out[out_base + d] = (half)dK_j[d];
        dv_out[out_base + d] = (half)dV_j[d];
    }
}
`;

// Pass 3: dQ — one dispatch per Q tile, inner loop over KV tiles.
const DQ_SOURCE = `
const uint q_tile_idx = threadgroup_position_in_grid.x;
const uint head       = threadgroup_position_in_grid.y;   // 0..Hq-1
const uint batch      = threadgroup_position_in_grid.z;
const uint tid        = thread_position_in_threadgroup.x;

const uint B   = shape[0];
const uint Hq  = shape[1];
const uint Hkv = shape[2];
const uint Tq  = shape[3];
const uint Tkv = shape[4];
const uint D   = shape[5];

const uint reps    = Hq / Hkv;
const uint kv_head = head / reps;

const float fscale = scale[0];
const uint  is_causal = causal[0];

const uint q_row_global = q_tile_idx * BQ + tid;
const bool q_row_valid  = q_row_global < Tq;

threadgroup half k_tile[BKV * D_MAX];
threadgroup half v_tile[BKV * D_MAX];

half q_i[D_MAX];
half do_i[D_MAX];
float l_i = 0.0f;
float D_i = 0.0f;
float dq_i[D_MAX];
for (uint d = 0u; d < D; ++d) { dq_i[d] = 0.0f; }

if (q_row_valid) {
    const uint q_base = ((batch * Hq + head) * Tq + q_row_global) * D;
    for (uint d = 0u; d < D; ++d) {
        q_i[d] = q[q_base + d];
        do_i[d] = do_[q_base + d];
    }
    const uint lse_idx = (batch * Hq + head) * Tq + q_row_global;
    l_i = l_in[lse_idx];
    D_i = d_vec[lse_idx];
}

const uint n_kv_tiles = (Tkv + BKV - 1u) / BKV;
for (uint kj = 0u; kj < n_kv_tiles; ++kj) {
    const uint kv_base_row = kj * BKV;

    const uint rows_this_tile = min((uint)BKV, Tkv - kv_base_row);
    for (uint r = tid; r < rows_this_tile; r += BQ) {
        const uint kv_global_row = kv_base_row + r;
        const uint kv_base = ((batch * Hkv + kv_head) * Tkv + kv_global_row) * D;
        for (uint d = 0u; d < D; ++d) {
            k_tile[r * D + d] = k[kv_base + d];
            v_tile[r * D + d] = v[kv_base + d];
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // Skip a KV tile only when it is entirely beyond this Q tile's last row
    // (fully causally masked). The condition is UNIFORM across the threadgroup
    // (q_tile_idx·BQ is the same for every thread), so the barrier below is hit
    // by all threads — using the per-thread q_row_global here would diverge the
    // barrier (undefined behavior). The per-element mask below still handles the
    // partial diagonal tile.
    if (is_causal && kv_base_row >= (q_tile_idx * BQ + BQ)) {
        threadgroup_barrier(mem_flags::mem_threadgroup);
        continue;
    }

    if (q_row_valid) {
        for (uint j = 0u; j < rows_this_tile; ++j) {
            float s = 0.0f;
            for (uint d = 0u; d < D; ++d) {
                s += (float)q_i[d] * (float)k_tile[j * D + d];
            }
            s *= fscale;
            const uint kpos = kv_base_row + j;
            if (is_causal && kpos > q_row_global) {
                s = -INFINITY;
            } else if (shape[6] != 0u && q_row_global >= kpos && (q_row_global - kpos) >= shape[6]) {
                s = -INFINITY;  // sliding window
            }
            float p = exp(s - l_i);
            float dp = 0.0f;
            for (uint d = 0u; d < D; ++d) {
                dp += (float)do_i[d] * (float)v_tile[j * D + d];
            }
            float ds = p * (dp - D_i);
            for (uint d = 0u; d < D; ++d) {
                dq_i[d] += ds * (float)k_tile[j * D + d] * fscale;
            }
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
}

if (q_row_valid) {
    const uint out_base = ((batch * Hq + head) * Tq + q_row_global) * D;
    for (uint d = 0u; d < D; ++d) {
        dq_out[out_base + d] = (half)dq_i[d];
    }
}
`;

let dKernelCache: MetalKernel | null = null;
function dKernel(): MetalKernel {
  if (!dKernelCache)
    dKernelCache = new MetalKernel({
      name: "optiq_flash_attention_D",
      inputNames: ["o", "do_", "shape"],
      outputNames: ["d_out"],
      source: D_SOURCE,
      ensureRowContiguous: true,
    });
  return dKernelCache;
}

const dkvKernels = new Map<number, MetalKernel>();
function dkvKernel(headDim: number): MetalKernel {
  let k = dkvKernels.get(headDim);
  if (!k) {
    const [bq, bkv] = backwardTiles(headDim);
    const header = `#define BQ ${bq}\n#define BKV ${bkv}\n#define D_MAX ${headDim}\n`;
    k = new MetalKernel({
      name: `optiq_flash_attention_dKV_d${headDim}`,
      inputNames: ["q", "k", "v", "do_", "l_in", "d_vec", "shape", "scale", "causal"],
      outputNames: ["dk_out", "dv_out"],
      source: DKV_SOURCE,
      header,
      ensureRowContiguous: true,
    });
    dkvKernels.set(headDim, k);
  }
  return k;
}

const dqKernels = new Map<number, MetalKernel>();
function dqKernel(headDim: number): MetalKernel {
  let k = dqKernels.get(headDim);
  if (!k) {
    const [bq, bkv] = backwardTiles(headDim);
    const header = `#define BQ ${bq}\n#define BKV ${bkv}\n#define D_MAX ${headDim}\n`;
    k = new MetalKernel({
      name: `optiq_flash_attention_dQ_d${headDim}`,
      inputNames: ["q", "k", "v", "do_", "l_in", "d_vec", "shape", "scale", "causal"],
      outputNames: ["dq_out"],
      source: DQ_SOURCE,
      header,
      ensureRowContiguous: true,
    });
    dqKernels.set(headDim, k);
  }
  return k;
}

/** Three-dispatch Metal backward. q,k,v,O,dO fp16; L fp32. Returns [dQ,dK,dV]. */
export function flashBackward(
  q: MlxArray, k: MlxArray, v: MlxArray, O: MlxArray, L: MlxArray, dO: MlxArray,
  scale: number, causal: boolean, window = 0,
): [MlxArray, MlxArray, MlxArray] {
  const [B, Hq, Tq, D] = q.shape as [number, number, number, number];
  const [, Hkv, Tkv] = k.shape as [number, number, number, number];
  const [bq, bkv] = backwardTiles(D);

  const dShape = u32([B, Hq, Tq, D]);
  const Dvec = dKernel().apply([O, dO, dShape], {
    outputs: [{ shape: [B, Hq, Tq], dtype: Dtype.float32 }],
    grid: [B * Hq * Tq, 1, 1],
    threadGroup: [256, 1, 1],
  })[0]!;
  dShape.dispose();

  const shape = u32([B, Hq, Hkv, Tq, Tkv, D, window]);
  const scaleArr = MlxArray.fromFloat32(new Float32Array([scale]), [1]);
  const causalArr = u32([causal ? 1 : 0]);
  try {
    const nKvTiles = Math.ceil(Tkv / bkv);
    const dkv = dkvKernel(D).apply([q, k, v, dO, L, Dvec, shape, scaleArr, causalArr], {
      outputs: [
        { shape: [B, Hkv, Tkv, D], dtype: Dtype.float16 },
        { shape: [B, Hkv, Tkv, D], dtype: Dtype.float16 },
      ],
      grid: [nKvTiles * bkv, Hkv, B],
      threadGroup: [bkv, 1, 1],
    });
    const nQTiles = Math.ceil(Tq / bq);
    const dq = dqKernel(D).apply([q, k, v, dO, L, Dvec, shape, scaleArr, causalArr], {
      outputs: [{ shape: [B, Hq, Tq, D], dtype: Dtype.float16 }],
      grid: [nQTiles * bq, Hq, B],
      threadGroup: [bq, 1, 1],
    });
    // dK is written by the kernel in the correct [B,Hkv,Tkv,D] layout
    // (dK_j[d] → [kv_row][d]); no post-transpose. (An earlier "fix" transposed
    // it on the false belief the buffer was swapped — that transpose is only the
    // identity at Tkv==D and corrupted dK for Tkv≠D; removed after
    // scripts/experiments/flash-dkv-debug.ts showed the raw output is correct.)
    return [dq[0]!, dkv[0]!, dkv[1]!];
  } finally {
    Dvec.dispose();
    shape.dispose();
    scaleArr.dispose();
    causalArr.dispose();
  }
}

// ---------------------------------------------------------------------------
// Differentiable op: flash forward + manual backward via CustomVjp.
// ---------------------------------------------------------------------------

// One CustomVjp per (head_dim, scale, causal) — the closures capture those as
// constants and read q/k/v from the input vector, so a single instance is
// reused across layers/steps. Module-cached (never disposed): the closures
// must outlive every value_and_grad apply.
const faCache = new Map<string, CustomVjp>();
function faOp(headDim: number, scale: number, causal: boolean, window: number): CustomVjp {
  const key = `${headDim}|${scale}|${causal ? 1 : 0}|${window}`;
  let cv = faCache.get(key);
  if (!cv) {
    cv = new CustomVjp(
      (ins) => {
        const [O, L] = flashForward(ins[0]!, ins[1]!, ins[2]!, scale, causal, window);
        return [O, L];
      },
      (primals, cots, outs) => {
        // primals=[q,k,v]; cots=[dO, dL] (dL=0, discarded); outs=[O, L]
        return flashBackward(primals[0]!, primals[1]!, primals[2]!, outs[0]!, outs[1]!, cots[0]!, scale, causal, window);
      },
    );
    faCache.set(key, cv);
  }
  return cv;
}

/** Differentiable flash attention matching optiq's training kernel. q,k,v are
 *  [B,Hq,Tq,D]/[B,Hkv,Tkv,D]; bf16 is cast to fp16 (kernel dtype) and the
 *  output cast back. Only causal/full attention (sliding-window masks fall
 *  back to ops.sdpa at the call site, mirroring optiq's router). */
export function flashAttention(
  q: MlxArray, k: MlxArray, v: MlxArray, scale: number, causal: boolean, window = 0,
): MlxArray {
  const D = q.shape[3]!;
  const inDtype = q.dtype;
  const f16 = inDtype === Dtype.float16;
  const q16 = f16 ? q : q.astype(Dtype.float16);
  const k16 = f16 ? k : k.astype(Dtype.float16);
  const v16 = f16 ? v : v.astype(Dtype.float16);

  const outs = faOp(D, scale, causal, window).apply([q16, k16, v16]);
  const O = outs[0]!;
  outs[1]?.dispose(); // L — only needed inside the vjp (mlx keeps it via the graph)
  const result = f16 ? O : O.astype(inDtype);
  if (!f16) {
    O.dispose();
    q16.dispose();
    k16.dispose();
    v16.dispose();
  }
  return result;
}

// ---------------------------------------------------------------------------
// Training-attention routing (opt-in; default null = ops.sdpa).
//
// Parity oracle, made explicit:
//  - DEFAULT (ops.sdpa) is the L1 path: mlx-lm's tuner differentiates the same
//    mx.fast.scaled_dot_product_attention, so training through it is bit-faithful
//    to mlx-lm. Exact dQ/dK/dV (finite-difference cross-checked), fast, but
//    O(L²) backward memory (materializes the score matrix).
//  - This flash kernel is the L2 path: a port of mlx-optiq's
//    flash_attention_metal (O(L) backward memory). Its parity oracle is OPTIQ,
//    not finite differences. Confirmed: optiq's flash dK == ops.sdpa to f16
//    (scripts/flash-optiq-check.py, rel 0.0%), and mlx-bun's flash == ops.sdpa
//    (tests/flash-attention.test.ts) ⟹ mlx-bun flash == optiq flash (L2 parity).
//
// Two real port bugs were fixed to reach that parity (the original diverged
// ~100% from optiq on dK): a spurious dK transpose in flashBackward (corrupted
// dK for Tkv≠D), and a per-thread (divergent) threadgroup_barrier in the dQ
// causal tile-skip. flash is opt-in (MLX_BUN_TRAIN_ATTN=flash) for memory-bound
// long context; it is ~30× slower than ops.sdpa. flashSupported gates
// head_dim/seq; sliding-window (array-mask) layers fall back to manualSdpa.
// ---------------------------------------------------------------------------

let trainAttnMode: "flash" | "manual" | null = null;
export function setTrainingAttn(mode: "flash" | "manual" | null): void {
  trainAttnMode = mode;
}
export function getTrainingAttn(): "flash" | "manual" | null {
  return trainAttnMode;
}

/** Can the flash kernel handle this q? (head_dim supported, seq≥32, fp16/bf16.) */
export function flashSupported(q: MlxArray): boolean {
  const T = q.shape[2]!;
  const D = q.shape[3]!;
  return SUPPORTED_HEAD_DIMS.has(D) && T >= 32 &&
    (q.dtype === Dtype.float16 || q.dtype === Dtype.bfloat16);
}

/** Materialized differentiable attention (matmul → mask → softmax → matmul),
 *  GQA-aware. The correct-vjp fallback for masks flash doesn't take (sliding
 *  window) and for any case where ops.sdpa's broken dK can't be used. O(L²) —
 *  pair with gradient checkpointing. */
export function manualSdpa(q: MlxArray, k: MlxArray, v: MlxArray, scale: number, mask: Mask): MlxArray {
  const [B, Hq, T, Dh] = q.shape as [number, number, number, number];
  const Hkv = k.shape[1]!;
  const Tk = k.shape[2]!;
  const reps = Hq / Hkv;

  const q5 = ops.reshape(q, [B, Hkv, reps, T, Dh]);
  const k5 = ops.reshape(k, [B, Hkv, 1, Tk, Dh]);
  const v5 = ops.reshape(v, [B, Hkv, 1, Tk, Dh]);
  const kT = ops.transposeAxes(k5, [0, 1, 2, 4, 3]); // [B,Hkv,1,Dh,Tk]
  let scores = ops.matmul(q5, kT); // [B,Hkv,reps,T,Tk]
  k5.dispose();
  kT.dispose();
  if (scale !== 1.0) {
    const s2 = ops.mulScalar(scores, scale);
    scores.dispose();
    scores = s2;
  }
  if (mask.mode === "causal" || mask.mode === "array") {
    const mBool = mask.mode === "causal" ? createCausalMask(T, 0, null) : mask.arr!;
    const ninf = ops.scalarLike(-3.0e38, scores);
    const masked = ops.where(mBool, scores, ninf);
    scores.dispose();
    ninf.dispose();
    if (mask.mode === "causal") mBool.dispose();
    scores = masked;
  }
  const probs = ops.softmaxAxis(scores, -1, true);
  scores.dispose();
  const out5 = ops.matmul(probs, v5); // [B,Hkv,reps,T,Dh]
  probs.dispose();
  v5.dispose();
  q5.dispose();
  const out = ops.reshape(out5, [B, Hq, T, Dh]);
  out5.dispose();
  return out;
}

