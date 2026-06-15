// curve-sampler.ts — the v2 log-prob transfer-curve sampler. Replaces the whole
// temperature+softmax stage with a drawn MONOTONE CUBIC curve in log-probability
// space:
//
//   p_out_i = exp(curve(log p_in_i)) / Σ_j exp(curve(log p_in_j))
//
// `lp` reaching the sampler is already log p_in (toLogprobs = logits − logsumexp),
// so the curve maps it directly and an identity curve reproduces temperature 1.
// The curve is a Fritsch–Carlson monotone cubic Hermite (PCHIP) through N movable
// control points in nat log-prob space (DaVinci-curves style — the endpoints start
// at the corners but are draggable too). Smooth, never overshoots, monotone. A
// control point dragged below the diagonal suppresses those tokens; the gate is
// emergent from the curve shape, not a separate threshold.
//
// Reading the curve: at a given p_in, ABOVE the diagonal raises those tokens,
// BELOW lowers them (renorm makes the literal number an intent); the SLOPE across
// a region sets how evenly the tokens inside it spread (flat<1 even, steep>1 separated).

import { MlxArray } from "./mlx/array";
import * as ops from "./mlx/ops";

export interface CurvePoint { x_pct: number; y_pct: number; }
export interface CurveParams {
  space?: "logprob";
  points: CurvePoint[]; // ≥2 control points, all movable; first/last are the endpoints
  monotonic?: boolean;
}

/** Bottom-left default anchor / plot floor (p = 1e-6). */
export const CURVE_UMIN = Math.log(1e-6);
const L = (pt: CurvePoint): [number, number] => [Math.log(Math.max(pt.x_pct, 1e-9) / 100), Math.log(Math.max(pt.y_pct, 1e-9) / 100)];

/** Control points in nat log-prob space, sorted ascending in x. */
function knotArrays(p: CurveParams): { X: number[]; Y: number[] } {
  const k = p.points.map(L).sort((a, b) => a[0] - b[0]);
  return { X: k.map((q) => q[0]), Y: k.map((q) => q[1]) };
}

/** Consecutive-point secants, top→bottom (region slopes; what the editor readout shows). */
export function curveSecants(p: CurveParams): number[] {
  const { X, Y } = knotArrays(p);
  const s: number[] = [];
  for (let i = X.length - 1; i > 0; i--) s.push((Y[i]! - Y[i - 1]!) / (X[i]! - X[i - 1]!));
  return s;
}
/** True iff every consecutive-point secant is ≥ 0 (monotone non-decreasing). */
export function isMonotone(p: CurveParams): boolean {
  return p.points.length >= 2 && curveSecants(p).every((s) => s >= -1e-12);
}

interface Seg { A: number; B: number; C: number; D: number } // cubic in u: A+Bu+Cu²+Du³
export interface Spline { X: number[]; Y: number[]; M: number[]; segs: Seg[] }

function cubicInU(x0: number, h: number, y0: number, y1: number, m0: number, m1: number): Seg {
  const c0 = y0, c1 = h * m0;
  const c2 = -3 * y0 - 2 * h * m0 + 3 * y1 - h * m1;
  const c3 = 2 * y0 + h * m0 - 2 * y1 + h * m1;
  const s = 1 / h, s2 = s * s, s3 = s2 * s;
  let A = c0, B = 0, C = 0, D = 0;
  B += c1 * s; A += -c1 * s * x0;
  C += c2 * s2; B += -2 * x0 * c2 * s2; A += x0 * x0 * c2 * s2;
  D += c3 * s3; C += -3 * x0 * c3 * s3; B += 3 * x0 * x0 * c3 * s3; A += -x0 * x0 * x0 * c3 * s3;
  return { A, B, C, D };
}

/** Monotone cubic (Fritsch–Carlson) over the N control points. */
export function buildSpline(p: CurveParams): Spline {
  const { X, Y } = knotArrays(p);
  const n = X.length;
  const Dsec: number[] = [];
  for (let i = 0; i < n - 1; i++) Dsec.push((Y[i + 1]! - Y[i]!) / (X[i + 1]! - X[i]!));
  const M = new Array<number>(n);
  M[0] = Dsec[0]!; M[n - 1] = Dsec[n - 2]!;
  for (let i = 1; i < n - 1; i++) {
    if (Dsec[i - 1]! * Dsec[i]! <= 0) { M[i] = 0; continue; }
    const h1 = X[i]! - X[i - 1]!, h2 = X[i + 1]! - X[i]!;
    const w1 = 2 * h2 + h1, w2 = h2 + 2 * h1;
    M[i] = (w1 + w2) / (w1 / Dsec[i - 1]! + w2 / Dsec[i]!);
  }
  const segs: Seg[] = [];
  for (let i = 0; i < n - 1; i++) segs.push(cubicInU(X[i]!, X[i + 1]! - X[i]!, Y[i]!, Y[i + 1]!, M[i]!, M[i + 1]!));
  return { X, Y, M, segs };
}

/** Scalar eval (editor preview / tests). Extrapolates linearly past both endpoints. */
export function evalSpline(sp: Spline, u: number): number {
  const n = sp.X.length;
  if (u < sp.X[0]!) return sp.Y[0]! + Math.max(sp.M[0]!, 1) * (u - sp.X[0]!); // deep tail: slope ≥1, stays gated
  if (u > sp.X[n - 1]!) return sp.Y[n - 1]! + sp.M[n - 1]! * (u - sp.X[n - 1]!);
  let i = sp.segs.length - 1;
  while (i > 0 && u < sp.X[i]!) i--;
  const s = sp.segs[i]!;
  return s.A + s.B * u + s.C * u * u + s.D * u * u * u;
}
export function curveAt(p: CurveParams, u: number): number { return evalSpline(buildSpline(p), u); }

/** Apply the monotone-cubic transfer to normalized logprobs `lp` [.., V] (on-device). */
export function applyCurve(lp: MlxArray, p: CurveParams): MlxArray {
  const sp = buildSpline(p);
  const n = sp.X.length;
  const tmp: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => { tmp.push(a); return a; };
  const C = (v: number): MlxArray => k(ops.scalarLike(v, lp));
  const lp2 = k(ops.mul(lp, lp));
  const lp3 = k(ops.mul(lp2, lp));
  const seg = (s: Seg): MlxArray => k(ops.add(
    k(ops.add(C(s.A), k(ops.mulScalar(lp, s.B)))),
    k(ops.add(k(ops.mulScalar(lp2, s.C)), k(ops.mulScalar(lp3, s.D)))),
  ));
  // below the bottom point: slope ≥ 1 (deep tail stays gated)
  const lowSlope = Math.max(sp.M[0]!, 1);
  let out: MlxArray = k(ops.add(C(sp.Y[0]! - lowSlope * sp.X[0]!), k(ops.mulScalar(lp, lowSlope))));
  for (let i = 0; i < sp.segs.length; i++) {
    const next = ops.where(k(ops.greaterEqual(lp, C(sp.X[i]!))), seg(sp.segs[i]!), out);
    tmp.push(next); out = next;
  }
  // above the top point: linear extrapolation with the top tangent (if it was dragged left of 100%)
  const aboveExt = k(ops.add(C(sp.Y[n - 1]! - sp.M[n - 1]! * sp.X[n - 1]!), k(ops.mulScalar(lp, sp.M[n - 1]!))));
  const result = ops.where(k(ops.greaterEqual(lp, C(sp.X[n - 1]!))), aboveExt, out);
  for (const a of tmp) a.dispose();
  return result;
}
