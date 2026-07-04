// Gated DeltaNet recurrence for Qwen3.5 linear-attention layers.
//
// Port target: mlx_lm.models.gated_delta (compute_g + the `gated_delta_step`
// Metal kernel) and the recurrent-state cache. mlx-lm runs the GPU kernel by
// default (use_kernel = not training), and its float accumulation / simd_sum
// reduction order differ from the pure-ops fallback — so BIT-EXACT parity with
// mlx-lm requires the SAME kernel, dispatched with the SAME grid/threadgroup.
// We port the non-vectorized, non-masked variant (g.ndim == 3, mask is None),
// which is the B=1 single-stream path (ssm_mask is None at batch 1).
//
// Numerics (must match the reference dtypes exactly — mlx infers the kernel's
// pointer element types from the input arrays):
//   q, k        bf16  [B, T, Hk, Dk]   (after inv_scale * rms_norm(., None))
//   v           bf16  [B, T, Hv, Dv]
//   g           f32   [B, T, Hv]        (= exp(-exp(A_log_f32) * softplus(a+dt_bias)))
//   beta        bf16  [B, T, Hv]        (= sigmoid(b))
//   state_in    f32   [B, Hv, Dv, Dk]
//   y (out)     bf16  [B, T, Hv, Dv]    (InT)
//   state_out   f32   [B, Hv, Dv, Dk]   (StT)
// GQA is handled inside the kernel (hk_idx = hv_idx / (Hv/Hk)); q/k stay at Hk.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import { CompiledFunction } from "../mlx/compile";
import * as ops from "../mlx/ops";
import type { Cache, Mask } from "./gemma4-base";

// Verbatim body of mlx-lm's gated_delta_step (has_mask=False, vectorized=False),
// with the only change being that the time count `T` arrives as a 1-element
// int32 input (`Tin`) and is read once — numerically identical to the
// reference (T only drives loop bounds and integer offsets), but avoids a
// kernel recompile per distinct sequence length.
const SOURCE = String.raw`
    const int T = Tin[0];
    auto n = thread_position_in_grid.z;
    auto b_idx = n / Hv;
    auto hv_idx = n % Hv;
    auto hk_idx = hv_idx / (Hv / Hk);
    constexpr int n_per_t = Dk / 32;

    // q, k: [B, T, Hk, Dk]
    auto q_ = q + b_idx * T * Hk * Dk + hk_idx * Dk;
    auto k_ = k + b_idx * T * Hk * Dk + hk_idx * Dk;

    // v, y: [B, T, Hv, Dv]
    auto v_ = v + b_idx * T * Hv * Dv + hv_idx * Dv;
    y += b_idx * T * Hv * Dv + hv_idx * Dv;

    auto dk_idx = thread_position_in_threadgroup.x;
    auto dv_idx = thread_position_in_grid.y;

    // state_in, state_out: [B, Hv, Dv, Dk]
    auto i_state = state_in + (n * Dv + dv_idx) * Dk;
    auto o_state = state_out + (n * Dv + dv_idx) * Dk;

    float state[n_per_t];
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      state[i] = static_cast<float>(i_state[s_idx]);
    }

    // g: [B, T, Hv]
    auto g_ = g + b_idx * T * Hv;
    auto beta_ = beta + b_idx * T * Hv;

    for (int t = 0; t < T; ++t) {
      if (true) {
        float kv_mem = 0.0f;
        for (int i = 0; i < n_per_t; ++i) {
          auto s_idx = n_per_t * dk_idx + i;
          state[i] = state[i] * g_[hv_idx];
          kv_mem += state[i] * k_[s_idx];
        }
        kv_mem = simd_sum(kv_mem);

        auto delta = (v_[dv_idx] - kv_mem) * beta_[hv_idx];

        float out = 0.0f;
        for (int i = 0; i < n_per_t; ++i) {
          auto s_idx = n_per_t * dk_idx + i;
          state[i] = state[i] + k_[s_idx] * delta;
          out += state[i] * q_[s_idx];
        }
        out = simd_sum(out);
        if (thread_index_in_simdgroup == 0) {
          y[dv_idx] = static_cast<InT>(out);
        }
      } else {
        y[dv_idx] = static_cast<InT>(0);
      }
      // Increment data pointers to next time step
      q_ += Hk * Dk;
      k_ += Hk * Dk;
      v_ += Hv * Dv;
      y += Hv * Dv;
      g_ += Hv;
      beta_ += Hv;
    }
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      o_state[s_idx] = static_cast<StT>(state[i]);
    }
`;

let kernel: MetalKernel | null = null;
function getKernel(): MetalKernel {
  if (!kernel)
    kernel = new MetalKernel({
      name: "gated_delta_step",
      inputNames: ["q", "k", "v", "g", "beta", "state_in", "Tin"],
      outputNames: ["y", "state_out"],
      source: SOURCE,
      ensureRowContiguous: true,
    });
  return kernel;
}

/** compute_g: exp(-exp(A_log_f32) * softplus(a + dt_bias)). Output is f32
 *  (the f32 exp(A_log) promotes the bf16 softplus term) — the kernel reads g
 *  as float, so this dtype is load-bearing. */
let _computeGFn: CompiledFunction | null = null;
export function computeG(aLog: MlxArray, a: MlxArray, dtBias: MlxArray): MlxArray {
  // mlx-lm gated_delta.py: `@partial(mx.compile, shapeless=True) compute_g` — the
  // WHOLE chain (exp/neg/softplus/mul/exp) is ONE fused kernel there, not five
  // separate dispatches. Traced once, replayed.
  if (!_computeGFn) {
    _computeGFn = new CompiledFunction((inp) => {
      const aL = inp[0]!, aa = inp[1]!, dt = inp[2]!;
      const aLogF = aL.astype(Dtype.float32);
      const expA = ops.exp(aLogF); aLogF.dispose();
      const negExpA = ops.neg(expA); expA.dispose();
      const adt = ops.add(aa, dt);
      // mlx nn.softplus(x) = mx.logaddexp(x, 0), where 0 is a weak Python int
      // (no cast node). ops.softplus builds the 0 via scalarLike (fromFloat32 →
      // f32→bf16 AsType). Build the 0 at adt's dtype from raw bytes so there is
      // no cast — matching mlx's graph exactly.
      const zbytes = adt.dtype === Dtype.float32
        ? new Uint8Array([0, 0, 0, 0])
        : new Uint8Array([0, 0]);
      const zero = MlxArray.fromBytesCopy(zbytes, [], adt.dtype);
      const sp = ops.logaddexp(adt, zero); adt.dispose(); zero.dispose();
      const prod = ops.mul(negExpA, sp); negExpA.dispose(); sp.dispose();
      const g = ops.exp(prod); prod.dispose();
      return [g];
    });
  }
  return _computeGFn.apply([aLog, a, dtBias])[0]!;
}

/** gated_delta_update (use_kernel path): returns [y, newState].
 *   q, k: [B, S, Hk, Dk] bf16   v: [B, S, Hv, Dv] bf16
 *   a, b: [B, S, Hv] bf16        aLog, dtBias: [Hv]
 *   state: [B, Hv, Dv, Dk] f32 (or null → zeros) */
export function gatedDeltaUpdate(
  q: MlxArray, k: MlxArray, v: MlxArray, a: MlxArray, b: MlxArray,
  aLog: MlxArray, dtBias: MlxArray, state: MlxArray | null,
): [MlxArray, MlxArray] {
  const [B, , Hk, Dk] = q.shape as [number, number, number, number];
  const [, , Hv, Dv] = v.shape as [number, number, number, number];

  const beta = ops.sigmoid(b); // bf16
  const g = computeG(aLog, a, dtBias); // f32

  let stateIn = state;
  let ownState = false;
  if (!stateIn) {
    stateIn = ops.zeros([B, Hv, Dv, Dk], Dtype.float32);
    ownState = true;
  }

  const T = q.shape[1]!;
  const tArr = MlxArray.fromInt32(new Int32Array([T]), [1]);
  const [y, stateOut] = getKernel().apply([q, k, v, g, beta, stateIn, tArr], {
    outputs: [
      { shape: [B, T, Hv, Dv], dtype: q.dtype },
      { shape: [B, Hv, Dv, Dk], dtype: Dtype.float32 },
    ],
    grid: [32, Dv, B * Hv],
    threadGroup: [32, 4, 1],
    templateInts: { Dk, Dv, Hk, Hv },
    templateDtypes: { InT: q.dtype, StT: Dtype.float32 },
  });
  beta.dispose();
  g.dispose();
  tArr.dispose();
  if (ownState) stateIn.dispose();
  return [y!, stateOut!];
}

/** Recurrent cache for a gated-DeltaNet layer — port of mlx-lm
 *  cache.ArraysCache(size=2): slot 0 = causal-conv state [B, K-1, conv_dim],
 *  slot 1 = recurrent state [B, Hv, Dv, Dk] f32. The linear-attn layer reads
 *  and writes these slots directly; `advance(N)` only tracks token count for
 *  B=1 single-stream (lengths / left_padding are batched-decode concerns).
 *  Not a KVCache, so maybeQuantizeKv skips it. */
export class SSMCache implements Cache {
  conv: MlxArray | null = null;
  recurrent: MlxArray | null = null;
  offset = 0;

  /** Linear-attn layers don't go through the KV update path. */
  updateAndFetch(): [MlxArray, MlxArray] {
    throw new Error("SSMCache has no KV updateAndFetch (gated-DeltaNet layer)");
  }

  makeMask(_N: number, _windowSize: number | null): Mask {
    // ssm_mask is None both single-stream and in the batch lane: rows
    // solo-prefill UNPADDED at B=1 (state never sees pad tokens), and
    // batched decode feeds one real token per row — so unlike mlx-lm's
    // left-padded batch-prefill there is never a pad position to mask.
    return { mode: "", arr: null };
  }

  advance(n: number): void {
    this.offset += n;
  }

  state(): MlxArray[] {
    const out: MlxArray[] = [];
    if (this.conv) out.push(this.conv);
    if (this.recurrent) out.push(this.recurrent);
    return out;
  }

  isTrimmable(): boolean {
    return false; // recurrent state can't be rolled back per token
  }

  trim(_n: number): void {
    throw new Error("SSMCache is not trimmable");
  }

  dispose(): void {
    this.conv?.dispose();
    this.recurrent?.dispose();
    this.conv = null;
    this.recurrent = null;
  }

  // --- batch-lane dynamic-B ops (BatchScheduler only) ----------------------
  // Both state slots are plain [B, ...] tensors with no temporal axis and no
  // left-padding, so the batched twins of mergeKVRows/filterKVRows collapse
  // to B-axis concat/take. `offset` is bookkeeping only for SSM layers (RoPE
  // reads the FULL-attention caches; the linear-attn forward never reads it),
  // so merged rows carrying different token counts share the max.

  /** Merge a fully-prefilled solo row into a running batched cache (`prev`
   *  null ⇒ the solo row becomes the batch). The returned cache owns fresh
   *  arrays — or, when there is nothing to concat, arrays STOLEN from `solo`
   *  (nulled there so the scheduler's unconditional dispose of the solo
   *  caches stays safe). `prev`/`solo` disposal remains the caller's job. */
  static mergeRows(prev: SSMCache | null, solo: SSMCache): SSMCache {
    if (!solo.conv || !solo.recurrent)
      throw new Error("SSMCache.mergeRows: solo row has no state (prefill first)");
    const out = new SSMCache();
    if (prev) {
      if (!prev.conv || !prev.recurrent)
        throw new Error("SSMCache.mergeRows: batched cache has no state");
      out.conv = ops.concatAxis([prev.conv, solo.conv], 0);
      out.recurrent = ops.concatAxis([prev.recurrent, solo.recurrent], 0);
    } else {
      out.conv = solo.conv;
      out.recurrent = solo.recurrent;
      solo.conv = null;
      solo.recurrent = null;
    }
    out.offset = Math.max(prev?.offset ?? 0, solo.offset);
    return out;
  }

  /** Evict rows not in `keep` (ascending row indices), in place. */
  filter(keep: number[]): void {
    if (!this.conv || !this.recurrent) return;
    const idx = ops.fromInt32(keep, [keep.length]);
    const conv = ops.takeAxis(this.conv, idx, 0);
    const recurrent = ops.takeAxis(this.recurrent, idx, 0);
    idx.dispose();
    this.conv.dispose();
    this.recurrent.dispose();
    this.conv = conv;
    this.recurrent = recurrent;
  }
}
