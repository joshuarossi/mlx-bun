// Strata-inspired convolution/heads/recurrence fusion, with mlx-lm's state
// layout, contiguous GQA mapping, bf16 roundings and SIMD reduction order.
// Two groups per head expose more parallel work than a full-head fusion;
// output RMSNorm/gating stays parallel in the layer. Single-position decode.
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import * as ops from "@mlx-bun/mlx/ops";
import type { GatedDeltaDecode } from "../../contracts/mlx/cache";
import { computeG } from "./gated";

const SOURCE = String.raw`
  const int group = threadgroup_position_in_grid.x, batch = threadgroup_position_in_grid.y;
  const int h = group / 2, part = group % 2, hk = h / (HV / HK);
  const int lane = thread_index_in_simdgroup, sg = simdgroup_index_in_threadgroup;
  const int tid = thread_index_in_threadgroup, column = part * 64 + sg * 4;
  threadgroup T qs[128], ks[128], vs[128];
  float st[4][4];
  for (int r = 0; r < 4; ++r)
    for (int i = 0; i < 4; ++i)
      st[r][i] = state[((batch * HV + h) * 128 + column + r) * 128 + lane * 4 + i];
  if (tid < 192) {
    const bool isq = tid < 32, isk = tid >= 32 && tid < 64;
    const int count = tid < 64 ? 4 : 1;
    float sum = 0.0f;
    T vals[4];
    for (int i = 0; i < count; ++i) {
      const int d = tid < 64 ? lane * 4 + i : tid - 64;
      const int ch = isq ? hk * 128 + d : isk ? (HK + hk) * 128 + d : 2 * HK * 128 + h * 128 + d;
      float cv = 0.0f;
      for (int k = 0; k < 4; ++k) {
        const T x = k < 3 ? history[(batch * 3 + k) * C + ch] : qkv[batch * C + ch];
        cv = metal::fma(float(x), float(conv[ch * 4 + k]), cv);
      }
      const T rounded = T(cv);
      const auto sy = 1 / (1 + metal::exp(metal::abs(rounded)));
      const T sigmoid = T(rounded < T(0) ? sy : 1 - sy);
      const T activated = T(rounded * sigmoid);
      vals[i] = activated;
      sum += float(activated) * float(activated);
      if (tid >= 64) {
        vs[d] = activated;
        if (part == 0) values[(batch * HV + h) * 128 + d] = activated;
      }
    }
    if (tid < 64) {
      sum = metal::simd_sum(sum);
      const float inv = metal::precise::rsqrt(sum / 128.0f + 1e-6f);
      for (int i = 0; i < 4; ++i) {
        const int d = lane * 4 + i;
        const T normalized = T(float(vals[i]) * inv);
        if (isq) qs[d] = qscale[d] * normalized;
        else {
          ks[d] = kscale[d] * normalized;
          if (part == 0 && h % (HV / HK) == 0) keys[(batch * HK + hk) * 128 + d] = ks[d];
        }
      }
    }
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  const int th = batch * HV + h;
  for (int r = 0; r < 4; ++r) {
    const int dv = column + r;
    float kv = 0.0f;
    for (int i = 0; i < 4; ++i) {
      st[r][i] = st[r][i] * g[th];
      kv += st[r][i] * ks[lane * 4 + i];
    }
    kv = metal::simd_sum(kv);
    const auto delta = (vs[dv] - kv) * beta[th];
    float out = 0.0f;
    for (int i = 0; i < 4; ++i) {
      st[r][i] = st[r][i] + ks[lane * 4 + i] * delta;
      out += st[r][i] * qs[lane * 4 + i];
      next[((batch * HV + h) * 128 + dv) * 128 + lane * 4 + i] = st[r][i];
    }
    out = metal::simd_sum(out);
    if (lane == 0) y[th * 128 + dv] = T(out);
  }
  // Separate history storage: shared Q/K heads may start after their owner
  // has completed, so writing the borrowed history in place would race.
  if (part == 0 && tid < 384) {
    const int ch = tid < 128 ? hk * 128 + tid : tid < 256 ? (HK + hk) * 128 + tid - 128
      : 2 * HK * 128 + h * 128 + tid - 256;
    if (tid >= 256 || h % (HV / HK) == 0) {
      histout[(batch * 3) * C + ch] = history[(batch * 3 + 1) * C + ch];
      histout[(batch * 3 + 1) * C + ch] = history[(batch * 3 + 2) * C + ch];
      histout[(batch * 3 + 2) * C + ch] = qkv[batch * C + ch];
    }
  }
`;

let kernel: MetalKernel | undefined;
/** All inputs are borrowed. The cache owns the output and every state/head
 * result, including `k`/`v` used by its retained-prefix replay. */
export function convDeltaDecode(qkv: MlxArray, a: MlxArray, b: MlxArray,
  history: MlxArray, state: MlxArray | null, conv: MlxArray, aLog: MlxArray, dt: MlxArray,
  qScale: MlxArray, kScale: MlxArray, hk: number, hv: number): ReturnType<GatedDeltaDecode> {
  const [B, S, C] = qkv.shape;
  if (S !== 1 || C !== (2 * hk + hv) * 128 || hv % hk || conv.shape[1] !== 4)
    throw new Error("convDeltaDecode requires one position, 128-wide heads and four convolution taps");
  using zeros = state ? null : ops.zeros([B!, hv, 128, 128], Dtype.float32);
  using g = computeG(aLog, a, dt);
  using beta = ops.sigmoid(b);
  kernel ??= new MetalKernel({ name: "conv_delta_decode", source: SOURCE,
    inputNames: ["qkv", "history", "conv", "g", "beta", "state", "qscale", "kscale"],
    outputNames: ["y", "next", "histout", "keys", "values"] });
  const [out, recurrent, nextHistory, k, v] = kernel.apply([qkv, history, conv, g, beta, state ?? zeros!, qScale, kScale], {
    outputs: [{ shape: [B!, 1, hv, 128], dtype: qkv.dtype }, { shape: [B!, hv, 128, 128], dtype: Dtype.float32 },
      { shape: history.shape, dtype: qkv.dtype }, { shape: [B!, 1, hk, 128], dtype: qkv.dtype },
      { shape: [B!, 1, hv, 128], dtype: qkv.dtype }],
    grid: [1024 * hv, B!, 1], threadGroup: [512, 1, 1],
    templateInts: { HK: hk, HV: hv, C: C! }, templateDtypes: { T: qkv.dtype },
  });
  return { out: out!, recurrent: recurrent!, conv: nextHistory!, k: k!, v: v! };
}
