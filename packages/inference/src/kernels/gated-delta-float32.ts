// The gated delta recurrence over float32 inputs from a zero state: transformers'
// `torch_chunk_gated_delta_rule` takes q, k, v, beta and g in float32 after the
// bf16 l2 normalization, and returns float32 values without a final state.
//
// The per-row arithmetic is kernels/delta/gated.ts's body (mlx-lm's
// gated_delta_step, not vectorized) with every input and the output in float32
// instead of the input dtype, the state starting at zero instead of read from an
// input, and no state written back. The reference evaluates the same rule in
// 64-token chunks with the decay as `exp` of cumulative log-decays; this kernel
// steps token by token with each step's decay, so the two agree to float32
// rounding, not bit for bit.
//
//   q, k   float32 [B, T, Hk, Dk]   (q already scaled by Dk ** -0.5)
//   v      float32 [B, T, Hv, Dv]
//   decay  float32 [B, T, Hv]       (exp of the step's log-decay g)
//   beta   float32 [B, T, Hv]
//   y      float32 [B, T, Hv, Dv]
// Key heads map to value heads as hk = hv / (Hv / Hk); Dk is a multiple of 32.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";

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

    float state[n_per_t];
    for (int i = 0; i < n_per_t; ++i) {
      state[i] = 0.0f;
    }

    // decay, beta: [B, T, Hv]
    auto g_ = decay + b_idx * T * Hv;
    auto beta_ = beta + b_idx * T * Hv;

    for (int t = 0; t < T; ++t) {
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
        y[dv_idx] = out;
      }
      // Increment data pointers to next time step
      q_ += Hk * Dk;
      k_ += Hk * Dk;
      v_ += Hv * Dv;
      y += Hv * Dv;
      g_ += Hv;
      beta_ += Hv;
    }
`;

let kernel: MetalKernel | undefined;

/** The recurrence's outputs for float32 `q`, `k` `[B, T, Hk, Dk]`, `v`
 * `[B, T, Hv, Dv]`, `decay` and `beta` `[B, T, Hv]` (all borrowed, row-contiguous
 * on launch). Returns an owned float32 `[B, T, Hv, Dv]`. */
export function gatedDeltaFloat32(q: MlxArray, k: MlxArray, v: MlxArray, decay: MlxArray, beta: MlxArray): MlxArray {
  const [B, T, Hk, Dk] = q.shape as [number, number, number, number];
  const [, , Hv, Dv] = v.shape as [number, number, number, number];
  kernel ??= new MetalKernel({
    name: "mlx_bun_gated_delta_float32",
    inputNames: ["q", "k", "v", "decay", "beta", "Tin"],
    outputNames: ["y"],
    source: SOURCE,
    ensureRowContiguous: true,
  });
  using length = MlxArray.fromInt32(new Int32Array([T]), [1]);
  const [y] = kernel.apply([q, k, v, decay, beta, length], {
    outputs: [{ shape: [B, T, Hv, Dv], dtype: Dtype.float32 }],
    grid: [32, Dv, B * Hv],
    threadGroup: [32, 4, 1],
    templateInts: { Dk, Dv, Hk, Hv },
  });
  return y!;
}
