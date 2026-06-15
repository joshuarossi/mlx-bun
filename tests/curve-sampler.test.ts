// curve-sampler — the v2 log-prob transfer-curve sampler over N movable control
// points. Gates the non-negotiables: identity ≡ temperature 1, smooth monotone
// cubic, control points interpolated exactly, gate emergent, stochastic sampler.
import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { applyCurve, buildSpline, evalSpline, curveAt, curveSecants, isMonotone, type CurveParams } from "../src/curve-sampler";
import { makeSampler, toLogprobs } from "../src/sampler";

function lp(values: number[]): MlxArray { return toLogprobs(MlxArray.fromFloat32(Float32Array.from(values), [1, values.length])); }
const pts = (a: [number, number][]): CurveParams => ({ space: "logprob", points: a.map(([x, y]) => ({ x_pct: x, y_pct: y })), monotonic: true });
const IDENTITY = pts([[1e-4, 1e-4], [0.1, 0.1], [1, 1], [9, 9], [100, 100]]);
const ROLLOFF = pts([[1e-4, 1e-4], [0.1, 0.04], [1, 0.6], [9, 7], [100, 100]]);

describe("curve geometry", () => {
  test("identity points ⇒ all secants 1, curve is the identity", () => {
    for (const s of curveSecants(IDENTITY)) expect(s).toBeCloseTo(1, 9);
    for (const x of [-0.5, -2.4, -6, -12]) expect(curveAt(IDENTITY, x)).toBeCloseTo(x, 6);
  });
  test("every control point is interpolated exactly (5 draggable points)", () => {
    const sp = buildSpline(ROLLOFF);
    for (const p of ROLLOFF.points) expect(evalSpline(sp, Math.log(p.x_pct / 100))).toBeCloseTo(Math.log(p.y_pct / 100), 6);
  });
  test("smooth: strictly increasing, no overshoot", () => {
    const sp = buildSpline(ROLLOFF); let prev = -Infinity;
    for (let u = -16; u <= 0; u += 0.05) { const y = evalSpline(sp, u); expect(y).toBeGreaterThanOrEqual(prev - 1e-9); prev = y; }
  });
  test("monotonicity: valid true, inverted false", () => {
    expect(isMonotone(IDENTITY)).toBe(true);
    expect(isMonotone(ROLLOFF)).toBe(true);
    expect(isMonotone(pts([[1e-4, 1e-4], [0.1, 7], [9, 2], [100, 100]]))).toBe(false);
  });
});

describe("applyCurve (device)", () => {
  test("identity curve is a passthrough (≡ temperature 1, float-close)", () => {
    const x = lp([5, 3, 1, -2, -6, -12]);
    const a = applyCurve(x, IDENTITY).toFloat32(), b = x.toFloat32();
    for (let i = 0; i < b.length; i++) expect(a[i]!).toBeCloseTo(b[i]!, 4);
  });
  test("on-device cubic matches the scalar spline (PCHIP correctness, both extrapolations)", () => {
    const x = lp([4, 1, -1, -3, -7, -14]);
    const a = applyCurve(x, ROLLOFF).toFloat32(), sp = buildSpline(ROLLOFF), ref = x.toFloat32();
    for (let i = 0; i < ref.length; i++) expect(a[i]!).toBeCloseTo(evalSpline(sp, ref[i]!), 3);
  });
  test("monotone: order preserved, argmax preserved", () => {
    const x = lp([6, 4, 2, 0, -3, -8, -15]);
    const inArr = Array.from(x.toFloat32()), out = Array.from(applyCurve(x, ROLLOFF).toFloat32());
    for (let i = 0; i + 1 < out.length; i++) expect(out[i]!).toBeGreaterThan(out[i + 1]!);
    expect(out.indexOf(Math.max(...out))).toBe(inArr.indexOf(Math.max(...inArr)));
  });
  test("gate: shadows map below the diagonal (a point dragged down suppresses them)", () => {
    const sp = buildSpline(ROLLOFF);
    for (const u of [-8, -10, -12]) expect(evalSpline(sp, u)).toBeLessThan(u);
    const out = Array.from(applyCurve(lp([1, -3, -8, -12]), ROLLOFF).toFloat32());
    for (const v of out) expect(Number.isFinite(v)).toBe(true);
  });
});

describe("makeSampler with curve", () => {
  test("stochastic, seeded, returns a valid token id", () => {
    const x = lp([8, 2, 1, 0, -5]);
    const s1 = makeSampler({ curve: ROLLOFF, seed: 7 });
    const t0 = ops.itemUint32(s1(x, 0));
    expect(t0).toBeGreaterThanOrEqual(0); expect(t0).toBeLessThan(5);
    expect(ops.itemUint32(makeSampler({ curve: ROLLOFF, seed: 7 })(x, 0))).toBe(t0);
    expect(ops.itemUint32(s1(x, 1))).toBeGreaterThanOrEqual(0);
  });
});
