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
import { ValueAndGrad, Vjp } from "../src/mlx/autograd";
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

// Vjp (mlx_vjp) — the segmented-backward backbone (src/train/segmented.ts).
// For a SCALAR loss with cotangent 1.0, the vjps equal the gradient, so they
// must match ValueAndGrad. And a vjp returns one cotangent per primal (all of
// them), unlike ValueAndGrad's selected argnums.
describe("Vjp", () => {
  test("scalar-loss vjp (cotangent 1.0) matches ValueAndGrad grads", () => {
    const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
    const bArr = MlxArray.fromFloat32(bData, [RANK, OUT]);

    // Reference grads via ValueAndGrad (argIdx 0,1 = A,B).
    const vag = new ValueAndGrad((p) => buildLoss(p[0]!, p[1]!, p[2]!, p[3]!), [0, 1]);
    const ref = vag.apply([aArr, bArr, xConst, yConst]);
    const refA = ref.grads[0]!.toFloat32();
    const refB = ref.grads[1]!.toFloat32();
    ref.value.dispose();
    ref.grads.forEach((g) => g.dispose());
    vag.dispose();

    // Vjp of the (scalar) loss with cotangent 1.0 -> vjp per primal [dA,dB,dx,dy].
    const vjp = new Vjp((p) => [buildLoss(p[0]!, p[1]!, p[2]!, p[3]!)], 1);
    const one = MlxArray.fromFloat32(new Float32Array([1]), []);
    const res = vjp.apply([aArr, bArr, xConst, yConst], [one]);
    expect(res.outputs.length).toBe(1); // f(primals)
    expect(res.vjps.length).toBe(4); // one per primal
    expect(res.outputs[0]!.toFloat32()[0]!).toBeCloseTo(eagerLoss(aData, bData), 4);

    const vjA = res.vjps[0]!.toFloat32();
    const vjB = res.vjps[1]!.toFloat32();
    for (let i = 0; i < refA.length; i++) expect(vjA[i]!).toBeCloseTo(refA[i]!, 5);
    for (let i = 0; i < refB.length; i++) expect(vjB[i]!).toBeCloseTo(refB[i]!, 5);

    res.outputs.forEach((o) => o.dispose());
    res.vjps.forEach((v) => v.dispose());
    one.dispose();
    aArr.dispose();
    bArr.dispose();
    vjp.dispose();
  });

  test("vector-output vjp seeds the backward with the cotangent", () => {
    // f(x) = x .* x (elementwise), cotangent c -> vjp = 2x .* c.
    const xData2 = det(6, (i) => i - 2.5);
    const cData = det(6, (i) => 0.1 * (i + 1));
    const x = MlxArray.fromFloat32(xData2, [6]);
    const c = MlxArray.fromFloat32(cData, [6]);
    const vjp = new Vjp((p) => [mul(p[0]!, p[0]!)], 1);
    const res = vjp.apply([x], [c]);
    const g = res.vjps[0]!.toFloat32();
    for (let i = 0; i < 6; i++) expect(g[i]!).toBeCloseTo(2 * xData2[i]! * cData[i]!, 5);
    res.outputs.forEach((o) => o.dispose());
    res.vjps.forEach((v) => v.dispose());
    x.dispose();
    c.dispose();
    vjp.dispose();
  });

  test("closure error surfaces from apply, not a crash", () => {
    const vjp = new Vjp((_p) => { throw new Error("boom inside vjp"); }, 1);
    const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
    const one = MlxArray.fromFloat32(new Float32Array([1]), [IN, RANK]);
    expect(() => vjp.apply([aArr], [one])).toThrow(/boom inside vjp/);
    aArr.dispose();
    one.dispose();
    vjp.dispose();
  });
});
