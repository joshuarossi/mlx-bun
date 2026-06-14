// FAST: native autograd (ValueAndGrad) finite-difference check.
//
// Mirrors spikes/phase-train-vag.ts but exercises the encapsulated
// ValueAndGrad class: a LoRA-shaped loss
//   loss = mean( (x + (x@A)@B - y)^2 )
// differentiated w.r.t. A [in,rank] and B [rank,out] only (x, y frozen).
// Asserts the returned grads match central finite differences (<1e-2) and
// that exactly len(argIdx) grads come back.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { ValueAndGrad } from "../src/mlx/autograd";
import { add, sub, mul, matmul, reshape, sumAxis, mulScalar } from "../src/mlx/ops";

const ROWS = 4, IN = 8, RANK = 2, OUT = 8;
const N = ROWS * OUT;

const det = (n: number, f: (i: number) => number) =>
  new Float32Array(Array.from({ length: n }, (_, i) => f(i)));
const xData = det(ROWS * IN, (i) => Math.sin(i * 0.7) * 0.5);
const yData = det(ROWS * OUT, (i) => Math.cos(i * 0.4) * 0.3);
const aData = det(IN * RANK, (i) => ((i * 7 + 3) % 11) / 11 - 0.5);
const bData = det(RANK * OUT, (i) => ((i * 5 + 1) % 9) / 9 - 0.4);

const xConst = MlxArray.fromFloat32(xData, [ROWS, IN]);
const yConst = MlxArray.fromFloat32(yData, [ROWS, OUT]);

/** Differentiable loss graph (disposes its own intermediates). */
function buildLoss(a: MlxArray, b: MlxArray, x: MlxArray, y: MlxArray): MlxArray {
  const xa = matmul(x, a);
  const xab = matmul(xa, b);
  const pred = add(x, xab);
  const resid = sub(pred, y);
  const sq = mul(resid, resid);
  const flat = reshape(sq, [N]);
  const s = sumAxis(flat, 0, false);
  const loss = mulScalar(s, 1 / N);
  for (const t of [xa, xab, pred, resid, sq, flat, s]) t.dispose();
  return loss;
}

/** Eager loss for finite differencing. */
function eagerLoss(a: Float32Array, b: Float32Array): number {
  const aArr = MlxArray.fromFloat32(a, [IN, RANK]);
  const bArr = MlxArray.fromFloat32(b, [RANK, OUT]);
  const loss = buildLoss(aArr, bArr, xConst, yConst);
  const v = loss.toFloat32()[0]!;
  for (const t of [aArr, bArr, loss]) t.dispose();
  return v;
}

describe("ValueAndGrad", () => {
  test("LoRA-shaped grads match finite differences", () => {
    // Differentiate only A and B (argIdx 0,1); x,y are non-diff primals.
    const vag = new ValueAndGrad(
      (primals) => buildLoss(primals[0]!, primals[1]!, primals[2]!, primals[3]!),
      [0, 1],
    );

    const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
    const bArr = MlxArray.fromFloat32(bData, [RANK, OUT]);
    const { value, grads } = vag.apply([aArr, bArr, xConst, yConst]);

    // Exactly len(argIdx) grads.
    expect(grads.length).toBe(2);
    // value equals the eager loss.
    expect(value.toFloat32()[0]!).toBeCloseTo(eagerLoss(aData, bData), 4);

    const dA = grads[0]!.toFloat32();
    const dB = grads[1]!.toFloat32();
    value.dispose();
    for (const g of grads) g.dispose();
    aArr.dispose();
    bArr.dispose();
    vag.dispose();

    const EPS = 1e-3, TOL = 1e-2;
    const check = (name: "A" | "B", base: Float32Array, analytic: Float32Array, size: number) => {
      const coords = [...new Set([0, 1, 3, size - 1, Math.floor(size / 2)])].filter((i) => i < size);
      for (const idx of coords) {
        const plus = base.slice(); plus[idx]! += EPS;
        const minus = base.slice(); minus[idx]! -= EPS;
        const fd = name === "A"
          ? (eagerLoss(plus, bData) - eagerLoss(minus, bData)) / (2 * EPS)
          : (eagerLoss(aData, plus) - eagerLoss(aData, minus)) / (2 * EPS);
        const an = analytic[idx]!;
        const rel = Math.abs(an - fd) / (Math.abs(an) + 1e-4);
        expect(rel).toBeLessThan(TOL);
      }
    };
    check("A", aData, dA, IN * RANK);
    check("B", bData, dB, RANK * OUT);
  });

  test("apply returns one grad per differentiated input", () => {
    // Differentiate all four inputs.
    const vag = new ValueAndGrad(
      (p) => buildLoss(p[0]!, p[1]!, p[2]!, p[3]!),
      [0, 1, 2, 3],
    );
    const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
    const bArr = MlxArray.fromFloat32(bData, [RANK, OUT]);
    const { value, grads } = vag.apply([aArr, bArr, xConst, yConst]);
    expect(grads.length).toBe(4);
    value.dispose();
    for (const g of grads) g.dispose();
    aArr.dispose();
    bArr.dispose();
    vag.dispose();
  });

  test("closure error surfaces from apply, not a crash", () => {
    const vag = new ValueAndGrad((_p) => {
      throw new Error("boom inside loss");
    }, [0]);
    const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
    expect(() => vag.apply([aArr])).toThrow(/boom inside loss/);
    aArr.dispose();
    vag.dispose();
  });
});
