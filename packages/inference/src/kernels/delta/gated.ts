// Gated DeltaNet recurrence for Qwen3.5 linear-attention layers.
//
// Port target: mlx_lm.models.gated_delta (compute_g + the `gated_delta_step`
// Metal kernel) and the recurrent-state cache. mlx-lm runs the GPU kernel by
// default (use_kernel = not training), and its float accumulation / simd_sum
// reduction order differ from the pure-ops fallback — so BIT-EXACT parity with
// mlx-lm requires the SAME kernel, dispatched with the SAME grid/threadgroup.
// We port the non-vectorized variant (g.ndim == 3). Padded prefill selects
// the oracle masked specialization; unpadded execution retains its kernel.
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

import { MlxArray } from "@mlx-bun/mlx/array";
import { Vjp } from "@mlx-bun/mlx/autograd";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { CustomVjp } from "@mlx-bun/mlx/custom-vjp";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import * as ops from "@mlx-bun/mlx/ops";

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
let maskedKernel: MetalKernel | null = null;
function getKernel(masked = false): MetalKernel {
  if (masked) return maskedKernel ??= new MetalKernel({
    name: "gated_delta_step_mask",
    inputNames: ["q", "k", "v", "g", "beta", "state_in", "Tin", "mask"],
    outputNames: ["y", "state_out"],
    source: SOURCE.replace("if (true)", "if (mask[b_idx * T + t])"),
    ensureRowContiguous: true,
  });
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

/** The kernel launch shared by the inference and training entries.
 *  q, k: [B, T, Hk, Dk]   v: [B, T, Hv, Dv]   g, beta: [B, T, Hv]
 *  state: [B, Hv, Dv, Dk] f32 (never null here)   mask: [B, T] or null */
function launchRecurrence(
  q: MlxArray, k: MlxArray, v: MlxArray, g: MlxArray, beta: MlxArray, stateIn: MlxArray, mask: MlxArray | null,
): [MlxArray, MlxArray] {
  const [B, T, Hk, Dk] = q.shape as [number, number, number, number];
  const [, , Hv, Dv] = v.shape as [number, number, number, number];
  const tArr = MlxArray.fromInt32(new Int32Array([T]), [1]);
  const inputs = [q, k, v, g, beta, stateIn, tArr];
  if (mask) inputs.push(mask);
  const [y, stateOut] = getKernel(mask !== null).apply(inputs, {
    outputs: [
      { shape: [B, T, Hv, Dv], dtype: q.dtype },
      { shape: [B, Hv, Dv, Dk], dtype: Dtype.float32 },
    ],
    grid: [32, Dv, B * Hv],
    threadGroup: [32, 4, 1],
    templateInts: { Dk, Dv, Hk, Hv },
    templateDtypes: { InT: q.dtype, StT: Dtype.float32 },
  });
  tArr.dispose();
  return [y!, stateOut!];
}

/** [B, T, Hk, D] in any float dtype -> float32 [B, T, Hv, D], head hv reading
 *  key head hv / (Hv / Hk): the kernel's GQA mapping. */
function float32PerValueHead(x: MlxArray, Hv: number): MlxArray {
  const [B, T, Hk, D] = x.shape as [number, number, number, number];
  using wide = x.astype(Dtype.float32);
  using expanded = ops.expandDims(wide, 3);
  using tiled = ops.broadcastTo(expanded, [B, T, Hk, Hv / Hk, D]);
  return ops.reshape(tiled, [B, T, Hv, D]);
}

/** Position `t` of `x` [B, T, ...] with the T axis dropped. */
function atPosition(x: MlxArray, t: number): MlxArray {
  const start = x.shape.map((_, axis) => (axis === 1 ? t : 0));
  const stop = x.shape.map((size, axis) => (axis === 1 ? t + 1 : size));
  using view = x.slice(start, stop);
  return ops.reshape(view, x.shape.filter((_, axis) => axis !== 1));
}

/** The kernel's recurrence written in differentiable ops, float32 throughout
 *  like the kernel (mlx-lm's `gated_delta_ops`, with the state kept in float32).
 *  primals = [q, k, v, g, beta, state]; returns [y (q dtype), state (f32)].
 *  Only the training backward runs it (forward values come from the kernel). */
function recurrenceOps(primals: MlxArray[]): MlxArray[] {
  const [q, k, v, g, beta, state0] = primals as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
  const Hv = v.shape[2]!;
  const T = q.shape[1]!;
  using q32 = float32PerValueHead(q, Hv);
  using k32 = float32PerValueHead(k, Hv);
  using v32 = v.astype(Dtype.float32);
  using beta32 = beta.astype(Dtype.float32);
  let state = state0.astype(Dtype.float32);
  const ys: MlxArray[] = [];
  try {
    for (let t = 0; t < T; t++) {
      using qt = atPosition(q32, t); // [B, Hv, Dk]
      using kt = atPosition(k32, t);
      using vt = atPosition(v32, t); // [B, Hv, Dv]
      using bt = atPosition(beta32, t); // [B, Hv]
      using gt = atPosition(g, t);
      using kRow = ops.expandDims(kt, 2); // [B, Hv, 1, Dk]
      using qRow = ops.expandDims(qt, 2);
      using decay = ops.reshape(gt, [...gt.shape, 1, 1]);
      using decayed = ops.mul(state, decay);
      using kvProduct = ops.mul(decayed, kRow);
      using kvMem = ops.sumAxis(kvProduct, -1, false); // [B, Hv, Dv]
      using residual = ops.sub(vt, kvMem);
      using betaCol = ops.expandDims(bt, 2);
      using delta = ops.mul(residual, betaCol);
      using deltaCol = ops.expandDims(delta, 3); // [B, Hv, Dv, 1]
      using update = ops.mul(kRow, deltaCol);
      const next = ops.add(decayed, update);
      state.dispose();
      state = next;
      using readout = ops.mul(state, qRow);
      ys.push(ops.sumAxis(readout, -1, false));
    }
    using stacked = ops.stackAxis(ys, 1); // [B, T, Hv, Dv]
    return [stacked.astype(q.dtype), state];
  } catch (error) {
    state.dispose();
    throw error;
  } finally {
    for (const y of ys) y.dispose();
  }
}

// Forward = the kernel above, so a training forward is bit-identical to an
// inference forward. The kernel is a CustomKernel with no vjp, so the backward
// recomputes the recurrence in `recurrenceOps` and differentiates that.
// Module-cached (never disposed): the closures read every shape from their
// arguments and must outlive each value_and_grad apply.
let differentiableRecurrence: CustomVjp | null = null;
function getDifferentiableRecurrence(): CustomVjp {
  return differentiableRecurrence ??= new CustomVjp(
    ([q, k, v, g, beta, state]) => launchRecurrence(q!, k!, v!, g!, beta!, state!, null),
    (primals, cotangents) => {
      const backward = new Vjp(recurrenceOps, 2);
      try {
        const { outputs, vjps } = backward.apply(primals, cotangents);
        for (const output of outputs) output.dispose();
        return vjps;
      } finally {
        backward.dispose();
      }
    },
  );
}

/** gated_delta_update (use_kernel path): returns [y, newState].
 *   q, k: [B, S, Hk, Dk] bf16   v: [B, S, Hv, Dv] bf16
 *   a, b: [B, S, Hv] bf16        aLog, dtBias: [Hv]
 *   state: [B, Hv, Dv, Dk] f32 (or null → zeros)
 *  `differentiable` (unpadded training forwards) returns the same values and
 *  attaches a backward, so an enclosing value_and_grad can differentiate
 *  through the recurrence with respect to q, k, v, a, b and the state. */
export function gatedDeltaUpdate(
  q: MlxArray, k: MlxArray, v: MlxArray, a: MlxArray, b: MlxArray,
  aLog: MlxArray, dtBias: MlxArray, state: MlxArray | null, mask: MlxArray | null = null,
  differentiable = false,
): [MlxArray, MlxArray] {
  if (differentiable && mask) throw new Error("gatedDeltaUpdate: the differentiable recurrence takes no padding mask");
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

  const [y, stateOut] = differentiable
    ? getDifferentiableRecurrence().apply([q, k, v, g, beta, stateIn]) as [MlxArray, MlxArray]
    : launchRecurrence(q, k, v, g, beta, stateIn, mask);
  beta.dispose();
  g.dispose();
  if (ownState) stateIn.dispose();
  return [y, stateOut];
}
