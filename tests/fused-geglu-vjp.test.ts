// VJP test for fusedGegluDifferentiable.
//
// Checks:
//  1. Forward output matches the reference gelu(a)*b (float32, tol 1e-4).
//  2. grad_a and grad_b are finite.
//  3. grad_a and grad_b match a reference computed purely from the
//     closed-form formulas (float32 inputs, tol 0.05 for rounding headroom).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import { ValueAndGrad } from "../src/mlx/autograd";
import {
  fusedGeglu, fusedGegluDifferentiable, setFusedGeluTraining, fusedGeluTraining,
} from "../src/model/fused-geglu-kernel";
import * as ops from "../src/mlx/ops";

// Test values chosen to be well-behaved (not too large) and cover positive/
// negative / near-zero entries.
const aData = new Float32Array([0.5, -1.2, 0.0, 1.8]);
const bData = new Float32Array([1.0, 0.5, -0.7, 0.3]);

const SQRT_2_PI = 0.7978845608028654;
const C_CUBE = 0.044715;

/** Reference gelu_approx in pure JS. */
function refGelu(x: number): number {
  const z = SQRT_2_PI * (x + C_CUBE * x ** 3);
  return 0.5 * x * (1 + Math.tanh(z));
}

/** Reference gelu'(x) in pure JS. */
function refGeluGrad(x: number): number {
  const z = SQRT_2_PI * (x + C_CUBE * x ** 3);
  const t = Math.tanh(z);
  const dzda = SQRT_2_PI * (1 + 3 * C_CUBE * x ** 2);
  return 0.5 * (1 + t) + 0.5 * x * (1 - t * t) * dzda;
}

describe("training-mode flag + differentiable/plain forward parity", () => {
  test("setFusedGeluTraining toggles the flag", () => {
    const before = fusedGeluTraining();
    setFusedGeluTraining(true);
    expect(fusedGeluTraining()).toBe(true);
    setFusedGeluTraining(false);
    expect(fusedGeluTraining()).toBe(false);
    setFusedGeluTraining(before); // restore
  });

  test("differentiable forward == plain fused forward, bit-for-bit (same kernel)", () => {
    // The model picks fusedGegluDifferentiable on the training path and fusedGeglu
    // on the inference path; their FORWARD must be identical (the differentiable
    // wrapper's forward IS the plain Metal kernel), so switching the training flag
    // never moves the trained distribution — only how the backward is taken.
    const a = MlxArray.fromFloat32(new Float32Array([0.5, -1.2, 0.0, 1.8, 2.5, -0.3]), [6]).astype(Dtype.bfloat16);
    const b = MlxArray.fromFloat32(new Float32Array([1.0, 0.5, -0.7, 0.3, -1.1, 0.9]), [6]).astype(Dtype.bfloat16);
    const plain = fusedGeglu(a, b);
    const diff = fusedGegluDifferentiable(a, b);
    ops.evalAll([plain, diff]);
    const pv = plain.toFloat32(), dv = diff.toFloat32();
    for (let i = 0; i < pv.length; i++) expect(dv[i]).toBe(pv[i]); // bit-for-bit
    plain.dispose(); diff.dispose(); a.dispose(); b.dispose();
  });
});

describe("fusedGegluDifferentiable VJP", () => {
  test("forward output matches gelu(a)*b reference", () => {
    const a = MlxArray.fromFloat32(aData, [4]);
    const b = MlxArray.fromFloat32(bData, [4]);

    const out = fusedGegluDifferentiable(a, b);
    const actual = out.toFloat32();

    for (let i = 0; i < 4; i++) {
      const expected = refGelu(aData[i]!) * bData[i]!;
      expect(actual[i]!).toBeCloseTo(expected, 3);
    }

    out.dispose();
    a.dispose();
    b.dispose();
  });

  test("gradients are finite", () => {
    const a = MlxArray.fromFloat32(aData, [4]);
    const b = MlxArray.fromFloat32(bData, [4]);

    const vag = new ValueAndGrad(
      (primals) => {
        const out = fusedGegluDifferentiable(primals[0]!, primals[1]!);
        // Reduce to scalar: sum of all elements
        const s = ops.sumAxis(out, 0, false);
        out.dispose();
        return s;
      },
      [0, 1],
    );

    const { value, grads } = vag.apply([a, b]);

    const dA = grads[0]!.toFloat32();
    const dB = grads[1]!.toFloat32();

    for (let i = 0; i < 4; i++) {
      expect(isFinite(dA[i]!)).toBe(true);
      expect(isFinite(dB[i]!)).toBe(true);
    }

    value.dispose();
    for (const g of grads) g.dispose();
    a.dispose();
    b.dispose();
    vag.dispose();
  });

  test("grad_b matches reference: d(sum gelu(a)*b)/db_i = gelu(a_i)", () => {
    const a = MlxArray.fromFloat32(aData, [4]);
    const b = MlxArray.fromFloat32(bData, [4]);

    const vag = new ValueAndGrad(
      (primals) => {
        const out = fusedGegluDifferentiable(primals[0]!, primals[1]!);
        const s = ops.sumAxis(out, 0, false);
        out.dispose();
        return s;
      },
      [0, 1],
    );

    const { value, grads } = vag.apply([a, b]);
    const dB = grads[1]!.toFloat32();

    for (let i = 0; i < 4; i++) {
      const expected = refGelu(aData[i]!);
      const rel = Math.abs(dB[i]! - expected) / (Math.abs(expected) + 1e-4);
      expect(rel).toBeLessThan(0.05);
    }

    value.dispose();
    for (const g of grads) g.dispose();
    a.dispose();
    b.dispose();
    vag.dispose();
  });

  test("grad_a matches reference: d(sum gelu(a)*b)/da_i = b_i * gelu'(a_i)", () => {
    const a = MlxArray.fromFloat32(aData, [4]);
    const b = MlxArray.fromFloat32(bData, [4]);

    const vag = new ValueAndGrad(
      (primals) => {
        const out = fusedGegluDifferentiable(primals[0]!, primals[1]!);
        const s = ops.sumAxis(out, 0, false);
        out.dispose();
        return s;
      },
      [0, 1],
    );

    const { value, grads } = vag.apply([a, b]);
    const dA = grads[0]!.toFloat32();

    for (let i = 0; i < 4; i++) {
      const expected = bData[i]! * refGeluGrad(aData[i]!);
      const rel = Math.abs(dA[i]! - expected) / (Math.abs(expected) + 1e-4);
      expect(rel).toBeLessThan(0.05);
    }

    value.dispose();
    for (const g of grads) g.dispose();
    a.dispose();
    b.dispose();
    vag.dispose();
  });
});
