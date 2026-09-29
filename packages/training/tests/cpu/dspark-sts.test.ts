// STS calibration fit (§3.2.1): pure math over (confidence, accepted) samples.
import { describe, expect, test } from "bun:test";
import { fitStsThresholds, type ConfSample } from "../../src/dspark/sts";

function rng(seed: number) {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

const GAMMA = 5;
// A demanding target (0.9) so the fit is forced up near the step edge: at 0.5
// precision already clears the bar at very low thresholds whenever the base
// acceptance is high, which says nothing about separation.
const TARGET = 0.9;

/** Acceptance is a hard step at conf > 0.6, except position 3 (under-sampled)
 *  and position 4 (all rejected regardless of conf). */
function samples(): ConfSample[] {
  const r = rng(42), out: ConfSample[] = [];
  for (let k = 0; k < GAMMA; k++) {
    const n = k === 3 ? 10 : 200;
    for (let i = 0; i < n; i++) { const conf = r(); out.push({ pos: k, conf, accepted: k === 4 ? false : conf > 0.6 }); }
  }
  return out;
}

describe("fitStsThresholds", () => {
  test("position 0 is always 0: the scheduler never prunes it", () => {
    expect(fitStsThresholds(samples(), GAMMA, TARGET, 50).thresholds[0]).toBe(0);
  });

  test("well-sampled, cleanly separated positions fit the smallest confidence clearing the target", () => {
    const { thresholds } = fitStsThresholds(samples(), GAMMA, TARGET, 50);
    for (const k of [1, 2]) { expect(thresholds[k]).toBeGreaterThan(0.5); expect(thresholds[k]).toBeLessThan(0.65); }
  });

  test("an under-sampled position is left unpruned (0)", () => {
    expect(fitStsThresholds(samples(), GAMMA, TARGET, 50).thresholds[3]).toBe(0);
  });

  test("a position the head cannot call is pruned unconditionally (1)", () => {
    expect(fitStsThresholds(samples(), GAMMA, TARGET, 50).thresholds[4]).toBe(1);
  });

  test("the fit depends on the multiset of samples, not their order", () => {
    const all = samples();
    expect(fitStsThresholds([...all].reverse(), GAMMA, TARGET, 50)).toEqual(fitStsThresholds(all, GAMMA, TARGET, 50));
  });

  test("provenance: target and sample count are recorded", () => {
    const all = samples(), sts = fitStsThresholds(all, GAMMA, TARGET, 50);
    expect(sts.target).toBe(TARGET);
    expect(sts.samples).toBe(all.length);
  });

  test("no samples: every position stays unpruned", () => {
    expect(fitStsThresholds([], GAMMA, TARGET, 50).thresholds).toEqual([0, 0, 0, 0, 0]);
  });

  test("a non-finite confidence is dropped at intake, not fitted into the thresholds", () => {
    // Unguarded, a NaN candidate keeps nothing and its smoothed precision (0+1)/(0+2) = 0.5 clears the default target.
    const nan: ConfSample[] = Array.from({ length: 60 }, () => ({ pos: 1, conf: NaN, accepted: false }));
    expect(fitStsThresholds(nan, GAMMA, 0.5, 50).thresholds).toEqual([0, 0, 0, 0, 0]);
  });
});
