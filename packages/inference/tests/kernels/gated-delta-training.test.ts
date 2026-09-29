// The gated-DeltaNet recurrence under value_and_grad. The forward is the
// inference kernel (a CustomKernel with no vjp); `differentiable` attaches a
// backward that differentiates an ops recomputation. Generated tensors, GQA
// (Hv = 2 * Hk), no model.
//   - the differentiable forward is bit-identical to the plain kernel forward;
//   - the gradients w.r.t. q, k, v, a, b match central finite differences of
//     the kernel forward (float32), including the state cotangent path being
//     unused, as in training;
//   - the bf16 gradients agree with the float32 gradients of the same values.
import { describe, expect, test } from "bun:test";
import { Vjp } from "@mlx-bun/mlx/autograd";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { gatedDeltaUpdate } from "../../src/kernels/delta/gated";

const HK = 2, HV = 4, DK = 32, DV = 32, T = 5;
const shapes = {
  q: [1, T, HK, DK], k: [1, T, HK, DK], v: [1, T, HV, DV], a: [1, T, HV], b: [1, T, HV],
} as const;
const names = ["q", "k", "v", "a", "b"] as const;
type Inputs = Record<(typeof names)[number], Float32Array>;

const noise = (count: number, phase: number, scale: number) =>
  Float32Array.from({ length: count }, (_, i) => Math.sin(i * 0.37 + phase) * scale + Math.cos(i * 0.11 + 2 * phase) * scale);
const size = (shape: readonly number[]) => shape.reduce((a, b) => a * b, 1);
const base: Inputs = {
  q: noise(size(shapes.q), 1, 0.3), k: noise(size(shapes.k), 2, 0.3), v: noise(size(shapes.v), 3, 0.5),
  a: noise(size(shapes.a), 4, 0.5), b: noise(size(shapes.b), 5, 0.8),
};
const cotangent = noise(T * HV * DV, 9, 1);
const aLogValues = noise(HV, 6, 0.3);
const dtBiasValues = noise(HV, 7, 0.3);

const tensor = (values: Float32Array, shape: readonly number[], dtype: Dtype) => {
  using wide = MlxArray.fromFloat32(values, [...shape]);
  return wide.astype(dtype);
};
const floats = (a: MlxArray) => { using wide = a.astype(Dtype.float32); using flat = ops.contiguous(wide); return flat.toFloat32(); };

function forward(inputs: Inputs, dtype: Dtype, differentiable: boolean): { y: Uint8Array; state: Uint8Array } {
  const arrays = names.map(name => tensor(inputs[name], shapes[name], dtype));
  using aLog = tensor(aLogValues, [HV], dtype);
  using dtBias = tensor(dtBiasValues, [HV], dtype);
  try {
    const [y, state] = gatedDeltaUpdate(arrays[0]!, arrays[1]!, arrays[2]!, arrays[3]!, arrays[4]!, aLog, dtBias, null, null, differentiable);
    ops.evalAll([y, state]);
    using ys = ops.contiguous(y);
    using states = ops.contiguous(state);
    const out = { y: ys.rawBytes().slice(), state: states.rawBytes().slice() };
    y.dispose(); state.dispose();
    return out;
  } finally { for (const a of arrays) a.dispose(); }
}

/** d/d(inputs) of sum(y * cotangent) through the differentiable recurrence. */
function gradients(inputs: Inputs, dtype: Dtype): Inputs {
  const arrays = names.map(name => tensor(inputs[name], shapes[name], dtype));
  using aLog = tensor(aLogValues, [HV], dtype);
  using dtBias = tensor(dtBiasValues, [HV], dtype);
  using cot = tensor(cotangent, [1, T, HV, DV], dtype);
  const vjp = new Vjp(p => {
    const [y, state] = gatedDeltaUpdate(p[0]!, p[1]!, p[2]!, p[3]!, p[4]!, aLog, dtBias, null, null, true);
    state.dispose(); // the training forward discards the new state
    return [y];
  }, 1);
  try {
    const { outputs, vjps } = vjp.apply(arrays, [cot]);
    ops.evalAll(vjps);
    const result = Object.fromEntries(names.map((name, i) => [name, floats(vjps[i]!)])) as Inputs;
    for (const a of [...outputs, ...vjps]) a.dispose();
    return result;
  } finally { vjp.dispose(); for (const a of arrays) a.dispose(); }
}

/** sum(y * cotangent) of the kernel forward (float32), in double. */
function objective(inputs: Inputs): number {
  const { y } = forward(inputs, Dtype.float32, false);
  const values = new Float32Array(y.buffer, y.byteOffset, y.byteLength / 4);
  let total = 0;
  for (let i = 0; i < values.length; i++) total += values[i]! * cotangent[i]!;
  return total;
}

const moved = (inputs: Inputs, name: (typeof names)[number], direction: Float32Array, step: number): Inputs =>
  ({ ...inputs, [name]: inputs[name].map((x, i) => x + step * direction[i]!) as Float32Array });
const dot = (a: Float32Array, b: Float32Array) => a.reduce((s, x, i) => s + x * b[i]!, 0);

describe("gated-DeltaNet recurrence under value_and_grad", () => {
  test("the differentiable forward is bit-identical to the kernel forward (bf16 and f32)", () => {
    for (const dtype of [Dtype.bfloat16, Dtype.float32]) {
      const plain = forward(base, dtype, false);
      const attached = forward(base, dtype, true);
      expect(attached.y).toEqual(plain.y);
      expect(attached.state).toEqual(plain.state);
      expect(plain.y.some(byte => byte !== 0)).toBe(true);
    }
  });

  const grads = gradients(base, Dtype.float32);
  for (const name of names) {
    test(`d/d${name} matches central finite differences of the kernel forward`, () => {
      const direction = noise(base[name].length, 20 + names.indexOf(name), 1);
      const step = 1e-2;
      const numeric = (objective(moved(base, name, direction, step)) - objective(moved(base, name, direction, -step))) / (2 * step);
      const analytic = dot(grads[name], direction);
      expect(Math.abs(analytic)).toBeGreaterThan(1e-3);
      expect(Math.abs(analytic - numeric)).toBeLessThan(2e-2 * Math.abs(numeric) + 1e-3);
    });
  }

  test("bf16 gradients agree with the float32 gradients of the same values", () => {
    const rounded = Object.fromEntries(names.map(name => {
      using bf = tensor(base[name], shapes[name], Dtype.bfloat16);
      return [name, floats(bf)];
    })) as Inputs;
    const wide = gradients(rounded, Dtype.float32);
    const narrow = gradients(rounded, Dtype.bfloat16);
    for (const name of names) {
      const error = Math.hypot(...narrow[name].map((x, i) => x - wide[name][i]!));
      expect(error).toBeLessThan(0.05 * Math.hypot(...wide[name]));
    }
  });
});
