import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import * as ops from "../mlx/ops";
import { computeG } from "./qwen3-delta";

// The same recurrent arithmetic as gated_delta_step, with no query/output
// calculation. Each row replays only its retained prefix of the verify window.
const SOURCE = String.raw`
  const int T = Tin[0];
  auto n = thread_position_in_grid.z;
  auto b_idx = n / Hv;
  auto hv_idx = n % Hv;
  auto hk_idx = hv_idx / (Hv / Hk);
  constexpr int n_per_t = Dk / 32;
  auto dk_idx = thread_position_in_threadgroup.x;
  auto dv_idx = thread_position_in_grid.y;
  auto k_ = k + b_idx * T * Hk * Dk + hk_idx * Dk;
  auto v_ = v + b_idx * T * Hv * Dv + hv_idx * Dv;
  auto g_ = g + b_idx * T * Hv;
  auto beta_ = beta + b_idx * T * Hv;
  auto i_state = state_in + (n * Dv + dv_idx) * Dk;
  auto o_state = state_out + (n * Dv + dv_idx) * Dk;
  float state[n_per_t];
  for (int i = 0; i < n_per_t; ++i)
    state[i] = static_cast<float>(i_state[n_per_t * dk_idx + i]);
  const int keep = lengths[b_idx];
  for (int t = 0; t < keep; ++t) {
    float kv_mem = 0.0f;
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      state[i] = state[i] * g_[hv_idx];
      kv_mem += state[i] * k_[s_idx];
    }
    kv_mem = simd_sum(kv_mem);
    auto delta = (v_[dv_idx] - kv_mem) * beta_[hv_idx];
    for (int i = 0; i < n_per_t; ++i) {
      auto s_idx = n_per_t * dk_idx + i;
      state[i] = state[i] + k_[s_idx] * delta;
    }
    k_ += Hk * Dk;
    v_ += Hv * Dv;
    g_ += Hv;
    beta_ += Hv;
  }
  for (int i = 0; i < n_per_t; ++i)
    o_state[n_per_t * dk_idx + i] = state[i];
`;

let kernel: MetalKernel | undefined;

/** State-only prefix replay. Inputs keep their original [B,T,...] strides;
 * lengths are request-owned accepted counts, never scheduling decisions. */
export function gatedDeltaState(
  k: MlxArray, v: MlxArray, a: MlxArray, b: MlxArray,
  aLog: MlxArray, dtBias: MlxArray, state: MlxArray | null,
  lengths: readonly number[],
): MlxArray {
  const [B, T, Hk, Dk] = k.shape as [number, number, number, number];
  const [, , Hv, Dv] = v.shape as [number, number, number, number];
  using beta = ops.sigmoid(b);
  using g = computeG(aLog, a, dtBias);
  using zero = state ? null : ops.zeros([B, Hv, Dv, Dk], Dtype.float32);
  using t = ops.fromInt32([T], [1]);
  using kept = ops.fromInt32([...lengths], [B]);
  kernel ??= new MetalKernel({ name: "gated_delta_prefix_state",
    inputNames: ["k", "v", "g", "beta", "state_in", "Tin", "lengths"],
    outputNames: ["state_out"], source: SOURCE, ensureRowContiguous: true });
  return kernel.apply([k, v, g, beta, state ?? zero!, t, kept], {
    outputs: [{ shape: [B, Hv, Dv, Dk], dtype: Dtype.float32 }],
    grid: [32, Dv, B * Hv], threadGroup: [32, 4, 1],
    templateInts: { Dk, Dv, Hk, Hv },
  })[0]!;
}
