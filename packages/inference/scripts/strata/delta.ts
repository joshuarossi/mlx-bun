// Experimental screen, not a serving binding. Inspired by Strata 296b59d2's
// gdn_step: keep convolution, heads, recurrence and gated norm in one dispatch.
// Retains mlx-bun's state layout, contiguous GQA mapping and bf16 roundings.
// RMS and recurrence arithmetic follow Apple's MIT-licensed MLX/mlx-lm code
// already used by kernels/delta/gated.ts and kernels/gated-rms-norm.ts.
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import { materializeCopy } from "@mlx-bun/mlx/materialize";
import * as ops from "@mlx-bun/mlx/ops";
import { computeG, gatedDeltaUpdate } from "../../src/kernels/delta/gated";
import { siluRmsHeads } from "../../src/kernels/delta/silu-rms-heads";
import { gatedRmsNorm } from "../../src/kernels/gated-rms-norm";

export interface DeltaInput {
  qkv: MlxArray; history: MlxArray; conv: MlxArray; a: MlxArray; b: MlxArray;
  aLog: MlxArray; dt: MlxArray; state: MlxArray; z: MlxArray; norm: MlxArray;
  qScale: MlxArray; kScale: MlxArray; hk: number; hv: number;
}

// 16 simdgroups/head, each owns eight value columns. Lanes divide the key
// dimension exactly as the oracle, preserving both simd_sum reduction trees.
// The complete head fits one group, allowing its output RMSNorm in the same
// dispatch. Unlike Strata this does not transpose the stored recurrent state.
const SOURCE = String.raw`
  const int group = threadgroup_position_in_grid.x, batch = threadgroup_position_in_grid.y;
  const int h = group / PARTS, part = group % PARTS;
  const int hk = h / (HV / HK), lane = thread_index_in_simdgroup;
  const int sg = simdgroup_index_in_threadgroup, tid = thread_index_in_threadgroup;
  threadgroup T qs[128], ks[128], vs[128], ys[128];
  const int column = part * (128 / PARTS) + sg * COLS;
  float st[COLS][4];
  for (int r = 0; r < COLS; ++r)
    for (int i = 0; i < 4; ++i)
      st[r][i] = state[((batch * HV + h) * 128 + column + r) * 128 + lane * 4 + i];
  for (int t = 0; t < SEQ; ++t) {
    for (int task = tid; task < 192; task += THREADS) {
      const bool isq = task < 32, isk = task >= 32 && task < 64;
      const int count = task < 64 ? 4 : 1;
      float sum = 0.0f;
      T vals[4];
      for (int i = 0; i < count; ++i) {
        const int d = task < 64 ? lane * 4 + i : task - 64;
        const int ch = isq ? hk * 128 + d : isk ? (HK + hk) * 128 + d : 2 * HK * 128 + h * 128 + d;
        float cv = 0.0f;
        for (int k = 0; k < 4; ++k) {
          const int p = t - 3 + k;
          const T x = p < 0 ? history[(batch * 3 + p + 3) * C + ch] : qkv[(batch * SEQ + p) * C + ch];
          cv = metal::fma(float(x), float(conv[ch * 4 + k]), cv);
        }
        const T rounded = T(cv);
        const auto sy = 1 / (1 + metal::exp(metal::abs(rounded)));
        const T sigmoid = T(rounded < T(0) ? sy : 1 - sy);
        const T activated = T(rounded * sigmoid);
        vals[i] = activated;
        sum += float(activated) * float(activated);
        if (task >= 64) vs[d] = activated;
      }
      if (task < 64) {
        sum = metal::simd_sum(sum);
        const float inv = metal::precise::rsqrt(sum / 128.0f + 1e-6f);
        for (int i = 0; i < 4; ++i) {
          const int d = lane * 4 + i;
          const T normalized = T(float(vals[i]) * inv);
          if (isq) qs[d] = qscale[d] * normalized;
          else ks[d] = kscale[d] * normalized;
        }
      }
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    const int th = (batch * SEQ + t) * HV + h;
    for (int r = 0; r < COLS; ++r) {
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
        if (SAVE_FIRST && t == 0)
          first[((batch * HV + h) * 128 + dv) * 128 + lane * 4 + i] = st[r][i];
      }
      out = metal::simd_sum(out);
      if (lane == 0) {
        if (FUSE_TAIL) ys[dv] = T(out);
        else y[th * 128 + dv] = T(out);
      }
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    if (FUSE_TAIL && tid < 32) {
      float sum = 0.0f;
      for (int i = 0; i < 4; ++i) {
        const float v = float(ys[tid * 4 + i]);
        sum += v * v;
      }
      sum = metal::simd_sum(sum);
      const float inv = metal::precise::rsqrt(sum / 128.0f + 1e-6f);
      for (int i = 0; i < 4; ++i) {
        const int d = tid * 4 + i, idx = th * 128 + d;
        const T normalized = norm[d] * T(float(ys[d]) * inv);
        const float zz = float(z[idx]);
        const float sy = 1.0f / (1.0f + metal::exp(metal::abs(zz)));
        const float sig = zz < 0.0f ? sy : 1.0f - sy;
        y[idx] = T((zz * sig) * float(normalized));
      }
    }
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  for (int r = 0; r < COLS; ++r)
    for (int i = 0; i < 4; ++i)
      next[((batch * HV + h) * 128 + column + r) * 128 + lane * 4 + i] = st[r][i];
  // Value heads own their value history; the first value head of a GQA group
  // owns its shared Q/K history. No in-place history writes.
  for (int ch0 = tid; part == 0 && ch0 < 384; ch0 += THREADS) {
    const int ch = ch0 < 128 ? hk * 128 + ch0 : ch0 < 256 ? (HK + hk) * 128 + ch0 - 128
      : 2 * HK * 128 + h * 128 + ch0 - 256;
    if (ch0 < 256 && h % (HV / HK) != 0) continue;
    for (int k = 0; k < 3; ++k) {
      const int p = SEQ - 3 + k;
      histout[(batch * 3 + k) * C + ch] = p < 0 ? history[(batch * 3 + p + 3) * C + ch]
        : qkv[(batch * SEQ + p) * C + ch];
    }
  }
`;

let fused: MetalKernel | undefined;
export function fusedDelta(x: DeltaInput, saveFirst = false): MlxArray[] {
  return applyDelta(x, saveFirst, 1, 8, true);
}

/** Leave the output norm/gate parallel over tokens, and split each head's
 * state across more threadgroups. Repeats the small convolution/head work
 * per partition, trading that work for more independent recurrence groups. */
export function splitDelta(x: DeltaInput, parts: 2 | 4 | 8 | 16, saveFirst = false): MlxArray[] {
  const result = applyDelta(x, saveFirst, parts, 4, false);
  using raw = result[0]!;
  result[0] = gatedRmsNorm(raw, x.z, x.norm, 1e-6);
  return result;
}

function applyDelta(x: DeltaInput, saveFirst: boolean, parts: number, columns: number, fuseTail: boolean): MlxArray[] {
  const [B, S, C] = x.qkv.shape;
  if (C !== (2 * x.hk + x.hv) * 128 || x.hv % x.hk || x.conv.shape[1] !== 4 || x.state.shape[2] !== 128 || x.state.shape[3] !== 128)
    throw new Error("fused screen requires 128-wide heads, four-tap convolution and integral GQA");
  using g = computeG(x.aLog, x.a, x.dt);
  using beta = ops.sigmoid(x.b);
  fused ??= new MetalKernel({ name: "strata_screen_delta", inputNames: ["qkv", "history", "conv", "g", "beta", "state", "z", "norm", "qscale", "kscale"],
    outputNames: ["y", "next", "histout", "first"], source: SOURCE });
  const threads = 128 / parts / columns * 32;
  const result = fused.apply([x.qkv, x.history, x.conv, g, beta, x.state, x.z, x.norm, x.qScale, x.kScale], {
    outputs: [{ shape: [B!, S!, x.hv, 128], dtype: x.qkv.dtype }, { shape: x.state.shape, dtype: Dtype.float32 },
      { shape: x.history.shape, dtype: x.qkv.dtype }, { shape: saveFirst ? x.state.shape : [1], dtype: Dtype.float32 }],
    grid: [threads * parts * x.hv, B!, 1], threadGroup: [threads, 1, 1], templateDtypes: { T: x.qkv.dtype },
    templateInts: { HK: x.hk, HV: x.hv, C: C!, SEQ: S!, SAVE_FIRST: Number(saveFirst),
      PARTS: parts, COLS: columns, THREADS: threads, FUSE_TAIL: Number(fuseTail) },
  });
  if (!saveFirst) result.pop()!.dispose();
  return result;
}

/** Native compiled replay separates GPU work from repeated JS/FFI graph
 * construction. Shape-aware traces retain no caller weights or state. */
export class CompiledDeltaPair {
  readonly baseline: CompiledFunction;
  readonly candidate: CompiledFunction;
  readonly inputs: MlxArray[];
  constructor(x: DeltaInput, candidate: (x: DeltaInput) => MlxArray[] = fusedDelta) {
    const keys = ["qkv", "history", "conv", "a", "b", "aLog", "dt", "state", "z", "norm", "qScale", "kScale"] as const;
    this.inputs = keys.map(k => x[k]);
    const rebuild = (inputs: MlxArray[]) => Object.fromEntries(keys.map((k, i) => [k, inputs[i]!])) as unknown as DeltaInput;
    const bind = (inputs: MlxArray[]): DeltaInput => ({ ...rebuild(inputs), hk: x.hk, hv: x.hv });
    this.baseline = new CompiledFunction(inputs => referenceDelta(bind(inputs)), false);
    this.candidate = new CompiledFunction(inputs => candidate(bind(inputs)), false);
  }
  dispose() { this.baseline.dispose(); this.candidate.dispose(); }
  [Symbol.dispose]() { this.dispose(); }
}

export function referenceDelta(x: DeltaInput): MlxArray[] {
  const [, S, C] = x.qkv.shape;
  using joined = ops.concatAxis([x.history, x.qkv], 1);
  using raw = ops.conv1d(joined, x.conv, 1, 0, 1, C!);
  const heads = siluRmsHeads(raw, x.qScale, x.kScale, x.hk, x.hv, 128);
  try {
    const [out, state] = gatedDeltaUpdate(heads[0]!, heads[1]!, heads[2]!, x.a, x.b, x.aLog, x.dt, x.state);
    using hidden = out;
    using tail = joined.slice([0, S!, 0], [x.qkv.shape[0]!, S! + 3, C!]);
    // Force separate tail storage, as the actual cache does.
    return [gatedRmsNorm(hidden, x.z, x.norm, 1e-6), state, materializeCopy(tail)];
  } finally { for (const a of heads) a.dispose(); }
}
