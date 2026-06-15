// HLG sampling — pure tone-curve transform (fast tier, no weights).
// Gates for Piece 1 (docs/design/hlg-sampling.md):
//   - degeneracy to temperature / identity is BIT-EXACT (the safety anchor);
//   - the curve is monotone in the logprob ⇒ ranking-preserving (argmax held);
//   - `-inf` (masked) tokens survive as `-inf`, no NaN anywhere;
//   - the shoulder compresses the highlight gap; the toe gentles the tail gap.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { applyHlg, applyHlgOetf, applyHlgEotf, applyHlgPipeline, applyHlgShaper, hlgGammaForLw, makeSampler, type HlgConfig, type HlgParams } from "../src/sampler";

function lpArray(values: number[]): MlxArray {
  return MlxArray.fromFloat32(Float32Array.from(values), [1, values.length]);
}

/** apply the curve, read back the row, free the device array. */
function curve(values: number[], p: HlgParams): number[] {
  const lp = lpArray(values);
  const out = applyHlg(lp, p);
  const row = Array.from(out.toFloat32());
  out.dispose();
  lp.dispose();
  return row;
}

// A spread of logprobs. Absolute offset is irrelevant (softmax is shift-invariant);
// what matters is the gaps between tokens.
const LP = [0.0, -0.5, -1.2, -2.0, -3.5, -5.0, -7.0, -9.0, -12.0, -16.0];

describe("applyHlg — degeneracy is bit-exact (the safety anchor)", () => {
  test("width=∞ ≡ temperature T=1/gain (mulScalar), max|Δ| = 0", () => {
    const m = 1 / 0.7;
    const lp = lpArray(LP);
    const got = applyHlg(lp, { gain: m, width: Infinity, shoulder: 4, toe: 6 });
    const want = ops.mulScalar(lp, m);
    const a = got.toFloat32();
    const b = want.toFloat32();
    let maxDiff = 0;
    for (let i = 0; i < a.length; i++) maxDiff = Math.max(maxDiff, Math.abs(a[i]! - b[i]!));
    expect(maxDiff).toBe(0);
    got.dispose();
    want.dispose();
    lp.dispose();
  });

  test("gain=1, no rolloff ≡ identity, bit-exact", () => {
    // Compare device-to-device: gain=1 ⇒ mulScalar(lp, 1.0) ⇒ the input row verbatim.
    const lp = lpArray(LP);
    const got = applyHlg(lp, { gain: 1, width: Infinity, shoulder: 0, toe: 0 });
    const a = got.toFloat32();
    const ref = lp.toFloat32();
    for (let i = 0; i < ref.length; i++) expect(a[i]!).toBe(ref[i]!);
    got.dispose();
    lp.dispose();
  });

  test("shoulder≤0 and toe≤0 ≡ temperature even with finite width", () => {
    const m = 1.3;
    const lp = lpArray(LP);
    const got = applyHlg(lp, { gain: m, width: 4, shoulder: 0, toe: 0 });
    const want = ops.mulScalar(lp, m);
    const a = got.toFloat32();
    const b = want.toFloat32();
    let maxDiff = 0;
    for (let i = 0; i < a.length; i++) maxDiff = Math.max(maxDiff, Math.abs(a[i]! - b[i]!));
    expect(maxDiff).toBe(0);
    got.dispose();
    want.dispose();
    lp.dispose();
  });
});

describe("applyHlg — invariants", () => {
  const params: HlgParams = { gain: 1.5, width: 3, shoulder: 4, toe: 6, pivot: "top", pivotOffset: 5 };

  test("monotone & ranking-preserving (LP is strictly decreasing ⇒ output is too)", () => {
    const out = curve(LP, params);
    for (let i = 0; i + 1 < out.length; i++) expect(out[i]!).toBeGreaterThan(out[i + 1]!);
  });

  test("argmax preserved on an unsorted distribution", () => {
    const shuffled = [-3.5, 0.0, -9.0, -0.5, -16.0, -1.2, -7.0, -2.0, -12.0, -5.0];
    const out = curve(shuffled, params);
    const argmaxIn = shuffled.indexOf(Math.max(...shuffled));
    const argmaxOut = out.indexOf(Math.max(...out));
    expect(argmaxOut).toBe(argmaxIn);
  });

  test("`-inf` masked tokens stay `-inf`, no NaN anywhere", () => {
    const masked = [...LP];
    masked[3] = -Infinity;
    masked[7] = -Infinity;
    const out = curve(masked, params);
    expect(out[3]!).toBe(-Infinity);
    expect(out[7]!).toBe(-Infinity);
    for (const v of out) expect(Number.isNaN(v)).toBe(false);
  });
});

describe("makeSampler — wiring neutrality (Piece 2, pure, no weights)", () => {
  // Draw `steps` tokens from a sampler fed the same logprob row each step.
  // Fully deterministic (fixed seed); only the sampler config varies.
  function drawTokens(opts: Parameters<typeof makeSampler>[0], values: number[], steps: number): number[] {
    const s = makeSampler(opts);
    const ids: number[] = [];
    for (let step = 0; step < steps; step++) {
      const lp = lpArray(values);
      const tok = s(lp, step);
      ids.push(ops.itemUint32(tok));
      tok.dispose();
      lp.dispose();
    }
    return ids;
  }

  test("HLG in identity config draws the SAME tokens as plain temperature", () => {
    const base = { temperature: 0.8, seed: 7 };
    const off = drawTokens(base, LP, 16);
    const identity: HlgConfig = { enabled: true, width: Infinity, shoulder: 0, toe: 0, pivotOffset: 0, pivot: "top" };
    const on = drawTokens({ ...base, hlg: identity }, LP, 16);
    expect(on).toEqual(off);
  });

  test("HLG with rolloff ON diverges from plain temperature (it is actually wired)", () => {
    const base = { temperature: 1.0, seed: 11 };
    const off = drawTokens(base, LP, 32);
    const rolloff: HlgConfig = { enabled: true, width: 3, shoulder: 4, toe: 6, pivotOffset: 5, pivot: "top" };
    const on = drawTokens({ ...base, hlg: rolloff }, LP, 32);
    expect(on).not.toEqual(off);
  });
});

describe("applyHlgOetf — the literal HLG transfer function", () => {
  test("monotone, ranking-preserving, finite (gamma below 1/12, log above)", () => {
    const lp = lpArray(LP);
    const out = applyHlgOetf(lp);
    const a = Array.from(out.toFloat32());
    out.dispose();
    lp.dispose();
    for (let i = 0; i + 1 < a.length; i++) expect(a[i]!).toBeGreaterThan(a[i + 1]!);
    for (const v of a) expect(Number.isFinite(v)).toBe(true);
  });
});

describe("applyHlgEotf — the literal HLG EOTF (inverse OETF → OOTF gamma)", () => {
  test("γ = 1.2 at L_W = 1000 (spec)", () => {
    expect(hlgGammaForLw(1000)).toBeCloseTo(1.2, 6);
  });

  test("monotone, ranking-preserving, finite", () => {
    const lp = lpArray(LP);
    const out = applyHlgEotf(lp, hlgGammaForLw(1000));
    const a = Array.from(out.toFloat32());
    out.dispose();
    lp.dispose();
    for (let i = 0; i + 1 < a.length; i++) expect(a[i]!).toBeGreaterThan(a[i + 1]!);
    for (const v of a) expect(Number.isFinite(v)).toBe(true);
  });

  test("EOTF suppresses the tail vs the OETF (decode sharpens, encode flattens)", () => {
    // gap between the top token and a deep-tail token, normalized out by the top.
    const lp = lpArray(LP);
    const eotf = Array.from(applyHlgEotf(lp, hlgGammaForLw(1000)).toFloat32());
    const oetf = Array.from(applyHlgOetf(lp).toFloat32());
    lp.dispose();
    const gap = (a: number[]) => a[0]! - a[a.length - 1]!;
    expect(gap(eotf)).toBeGreaterThan(gap(oetf)); // EOTF holds a larger top-to-tail gap ⇒ tail suppressed
  });
});

describe("applyHlgPipeline — full chain (OETF shape → OOTF scale)", () => {
  test("monotone, ranking-preserving, finite", () => {
    const lp = lpArray(LP);
    const out = applyHlgPipeline(lp, 5, hlgGammaForLw(1000));
    const a = Array.from(out.toFloat32());
    out.dispose();
    lp.dispose();
    for (let i = 0; i + 1 < a.length; i++) expect(a[i]!).toBeGreaterThan(a[i + 1]!);
    for (const v of a) expect(Number.isFinite(v)).toBe(true);
  });
});

describe("applyHlgShaper — the user-specified shaper (windowed anchor)", () => {
  test("monotone (non-strict: deep tail ties at the gated floor), finite", () => {
    const lp = lpArray(LP);
    const out = applyHlgShaper(lp); // W=10: LP tokens ≤ −10 clamp to the toe floor (tie)
    const a = Array.from(out.toFloat32());
    out.dispose();
    lp.dispose();
    for (let i = 0; i + 1 < a.length; i++) expect(a[i]!).toBeGreaterThanOrEqual(a[i + 1]!);
    for (const v of a) expect(Number.isFinite(v)).toBe(true);
  });

  test("within the window it is strictly monotone (top W nats separated)", () => {
    const inWindow = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9]; // all within W=10 of the top
    const lp = lpArray(inWindow);
    const arr = Array.from(applyHlgShaper(lp).toFloat32());
    lp.dispose();
    for (let i = 0; i + 1 < arr.length; i++) expect(arr[i]!).toBeGreaterThan(arr[i + 1]!);
  });
});

describe("applyHlg — three pivot methods, same curve", () => {
  for (const pivot of ["top", "entropy", "median"] as const) {
    test(`${pivot}: monotone, ranking-preserving, finite`, () => {
      const out = curve(LP, { gain: 1.2, width: 3, shoulder: 4, toe: 4, pivot, pivotOffset: pivot === "top" ? 6 : 0 });
      for (let i = 0; i + 1 < out.length; i++) expect(out[i]!).toBeGreaterThan(out[i + 1]!);
      for (const v of out) expect(Number.isFinite(v)).toBe(true);
    });
  }

  test("the three pivots place middle grey differently ⇒ different curves", () => {
    const top = curve(LP, { gain: 1.2, width: 3, shoulder: 4, toe: 4, pivot: "top", pivotOffset: 6 });
    const ent = curve(LP, { gain: 1.2, width: 3, shoulder: 4, toe: 4, pivot: "entropy", pivotOffset: 0 });
    const med = curve(LP, { gain: 1.2, width: 3, shoulder: 4, toe: 4, pivot: "median", pivotOffset: 0 });
    expect(top).not.toEqual(ent);
    expect(ent).not.toEqual(med);
    expect(top).not.toEqual(med);
  });
});

describe("applyHlg — the curve actually shapes the regions", () => {
  // gain=1 isolates the rolloff from the mid contrast: the mids are identity,
  // so any gap change at the extremes is purely the toe/shoulder.
  const p: HlgParams = { gain: 1, width: 3, shoulder: 4, toe: 6, pivot: "top", pivotOffset: 5 };

  test("shoulder compresses the highlight gap (top two tokens, both in shoulder)", () => {
    // μ = ℓ_max − 5 = −5, so z_top = 5 and z_2 = 4.5, both past the +w=3 knot.
    const out = curve(LP, p);
    const gapIn = LP[0]! - LP[1]!; // 0.5
    const gapOut = out[0]! - out[1]!;
    expect(gapOut).toBeGreaterThan(0); // still ranked
    expect(gapOut).toBeLessThan(gapIn); // …but compressed (rolled off)
  });

  test("toe gentles the tail gap (deep-tail tokens spread less than linear)", () => {
    // z(−12) = −7 and z(−16) = −11, both below the −w=3 knot (in the toe).
    const out = curve(LP, p);
    const gapIn = LP[8]! - LP[9]!; // 4.0
    const gapOut = out[8]! - out[9]!;
    expect(gapOut).toBeGreaterThan(0); // still ranked
    expect(gapOut).toBeLessThan(gapIn); // gain=1 ⇒ linear would preserve 4.0; toe shrinks it
  });
});
