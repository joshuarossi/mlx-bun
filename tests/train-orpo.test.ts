// ORPO loss math — validated against a standalone JS reference (the oracle
// ladder's base rung; no model weights, pure mlx array ops). Covers log1mexp
// stability, the log-odds, the L_NLL + λ·L_OR reduction, and that the loss is
// differentiable through lw/lr (the autograd path the trainer relies on).
//
// Reference (paper / TRL ORPO):
//   logodds = (ℓw - ℓr) - (log(1-e^ℓw) - log(1-e^ℓr))
//   L_NLL   = mean(-ℓw)            (unweighted SFT term)
//   L_OR    = mean(softplus(-logodds))
//   loss    = L_NLL + λ·L_OR

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { log1mexp, orpoLossFromLogps } from "../src/train/loss";

const arr = (xs: number[]) => MlxArray.fromFloat32(new Float32Array(xs), [xs.length]);
const scalar = (a: MlxArray) => a.toFloat32()[0]!;

// --- JS reference --------------------------------------------------------
const refLog1mexp = (x: number) => Math.log(1 - Math.exp(x));
const softplus = (x: number) => Math.log1p(Math.exp(-Math.abs(x))) + Math.max(x, 0);
function refOrpoLoss(lw: number[], lr: number[], lambda: number): number {
  const B = lw.length;
  let nll = 0;
  let or = 0;
  for (let b = 0; b < B; b++) {
    nll += -lw[b]!;
    const logodds = lw[b]! - lr[b]! - (refLog1mexp(lw[b]!) - refLog1mexp(lr[b]!));
    or += softplus(-logodds);
  }
  return nll / B + lambda * (or / B);
}

describe("log1mexp", () => {
  test("matches log(1-exp(x)) for well-negative x", () => {
    const x = arr([-1.0, -0.5, -2.0, -3.5]);
    const got = log1mexp(x);
    const g = got.toFloat32();
    for (const [i, xi] of [-1.0, -0.5, -2.0, -3.5].entries())
      expect(g[i]!).toBeCloseTo(refLog1mexp(xi), 5);
    x.dispose();
    got.dispose();
  });

  test("does not produce NaN/-inf as x→0⁻ (clamped)", () => {
    const x = arr([-1e-6, -1e-4]);
    const got = log1mexp(x);
    for (const v of got.toFloat32()) expect(Number.isFinite(v)).toBe(true);
    x.dispose();
    got.dispose();
  });
});

describe("orpoLossFromLogps vs JS reference", () => {
  for (const lambda of [0.1, 0.5, 1.0]) {
    test(`λ=${lambda}`, () => {
      const lwv = [-0.5, -1.2, -0.8];
      const lrv = [-1.5, -1.0, -2.3]; // mix: chosen better, rejected better, chosen better
      const lw = arr(lwv);
      const lr = arr(lrv);
      const loss = orpoLossFromLogps(lw, lr, lambda);
      expect(scalar(loss)).toBeCloseTo(refOrpoLoss(lwv, lrv, lambda), 4);
      lw.dispose();
      lr.dispose();
      loss.dispose();
    });
  }

  test("preferring chosen (higher ℓw) lowers the OR term", () => {
    // Same NLL (same ℓw), but a worse rejected → larger margin → smaller L_OR.
    const lw = arr([-0.8]);
    const close = orpoLossFromLogps(lw, arr([-0.9]), 1.0);
    const far = orpoLossFromLogps(lw, arr([-3.0]), 1.0);
    expect(scalar(far)).toBeLessThan(scalar(close));
    lw.dispose();
    close.dispose();
    far.dispose();
  });
});

describe("orpoLossFromLogps is differentiable through lw/lr", () => {
  test("value_and_grad over [lw, lr] matches the value and gives finite grads", () => {
    const lwv = [-0.5, -1.2];
    const lrv = [-1.5, -1.0];
    const lambda = 0.1;
    const vag = new ValueAndGrad(
      (primals) => orpoLossFromLogps(primals[0]!, primals[1]!, lambda),
      [0, 1],
    );
    const lw = arr(lwv);
    const lr = arr(lrv);
    const { value, grads } = vag.apply([lw, lr]);
    ops.evalAll([value, ...grads]);
    expect(scalar(value)).toBeCloseTo(refOrpoLoss(lwv, lrv, lambda), 4);
    expect(grads.length).toBe(2);
    for (const g of grads) for (const v of g.toFloat32()) expect(Number.isFinite(v)).toBe(true);
    value.dispose();
    for (const g of grads) g.dispose();
    vag.dispose();
    lw.dispose();
    lr.dispose();
  });
});
