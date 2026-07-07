// Model-free gate for the Phase-1c drafter A/B math
// (src/spec/dspark/ab-stats.ts — runner: scripts/dspark-drafter-ab.ts).

import { describe, expect, test } from "bun:test";
import {
  summarizeArm, pairedVerdict, renderReport, type AbPromptResult,
} from "../src/spec/dspark/ab-stats";

function result(over: Partial<AbPromptResult> = {}): AbPromptResult {
  return {
    prompt: "p",
    generatedTokens: 60,
    drafted: 70,
    accepted: 21, // 30%
    targetCalls: 20, // τ = 3
    wallMs: 2000, // 30 tok/s
    draftedByPos: [10, 10, 10, 10, 10, 10, 10],
    acceptedByPos: [7, 5, 4, 3, 1, 1, 0],
    ...over,
  };
}

describe("summarizeArm", () => {
  test("aggregates acceptance, tau, tok/s over the prompt set", () => {
    const s = summarizeArm([result(), result({ wallMs: 1000 })]);
    expect(s.nPrompts).toBe(2);
    expect(s.generatedTokens).toBe(120);
    expect(s.acceptance).toBeCloseTo(42 / 140, 10);
    expect(s.tau).toBeCloseTo(120 / 40, 10);
    expect(s.tokPerSec).toBeCloseTo((120 / 3000) * 1000, 10);
  });

  test("per-position acceptance divides accepted-by-pos over drafted-by-pos", () => {
    const s = summarizeArm([result()]);
    expect(s.acceptanceByPos).toHaveLength(7);
    expect(s.acceptanceByPos[0]).toBeCloseTo(0.7, 10);
    expect(s.acceptanceByPos[6]).toBe(0);
  });

  test("ragged by-pos arrays (confidence-pruned rounds) align by index", () => {
    const s = summarizeArm([
      result({ draftedByPos: [10, 10], acceptedByPos: [5, 2] }),
      result({ draftedByPos: [10, 10, 10], acceptedByPos: [10, 0, 0] }),
    ]);
    expect(s.acceptanceByPos).toHaveLength(3);
    expect(s.acceptanceByPos[0]).toBeCloseTo(15 / 20, 10);
    expect(s.acceptanceByPos[1]).toBeCloseTo(2 / 20, 10);
    expect(s.acceptanceByPos[2]).toBeCloseTo(0 / 10, 10);
  });

  test("zero drafted yields zero acceptance, no NaN", () => {
    const s = summarizeArm([result({ drafted: 0, accepted: 0, draftedByPos: [], acceptedByPos: [] })]);
    expect(s.acceptance).toBe(0);
    expect(Number.isNaN(s.tau)).toBe(false);
  });
});

describe("pairedVerdict (Phase-1d exit criteria)", () => {
  const armA = [result(), result(), result()];

  test("PASS: acceptance within max-drop AND wall-clock improves", () => {
    // B: acceptance 28% (−2 pts, within 3), 2× faster.
    const armB = armA.map(() => result({ accepted: 19.6, wallMs: 1000 }));
    const v = pairedVerdict(armA, armB, { maxDropPts: 3 });
    expect(v.acceptanceDeltaPts).toBeCloseTo(-2, 5);
    expect(v.speedRatio).toBeCloseTo(2, 5);
    expect(v.pass).toBe(true);
    expect(v.verdict).toContain("PASS");
  });

  test("FAIL: acceptance drop beyond max-drop even when faster", () => {
    // B: acceptance 25% (−5 pts), 2× faster.
    const armB = armA.map(() => result({ accepted: 17.5, wallMs: 1000 }));
    const v = pairedVerdict(armA, armB, { maxDropPts: 3 });
    expect(v.pass).toBe(false);
    expect(v.verdict).toContain("does not preserve");
  });

  test("FAIL: acceptance held but wall-clock did not improve", () => {
    const armB = armA.map(() => result({ wallMs: 2500 }));
    const v = pairedVerdict(armA, armB, { maxDropPts: 3 });
    expect(v.acceptanceDeltaPts).toBeCloseTo(0, 5);
    expect(v.speedRatio).toBeLessThan(1);
    expect(v.pass).toBe(false);
    expect(v.verdict).toContain("wall-clock did not improve");
  });

  test("paired per-prompt hold count uses the same tolerance", () => {
    const armB = [
      result({ accepted: 21 }),   // equal — holds
      result({ accepted: 20.3 }), // −1 pt — holds
      result({ accepted: 14 }),   // −10 pts — does not hold
    ];
    const v = pairedVerdict(armA, armB, { maxDropPts: 3 });
    expect(v.pairedAcceptanceHolds).toBe(2);
  });

  test("throws on mismatched arm sizes (pairing is the whole point)", () => {
    expect(() => pairedVerdict(armA, armA.slice(1))).toThrow(/arm sizes differ/);
  });
});

describe("renderReport", () => {
  test("renders both arms, by-pos rows, and the verdict", () => {
    const armB = [result({ accepted: 19.6, wallMs: 1000 }), result({ accepted: 19.6, wallMs: 1000 }), result({ accepted: 19.6, wallMs: 1000 })];
    const v = pairedVerdict([result(), result(), result()], armB);
    const out = renderReport("bf16", "affine-q4-g64", v);
    expect(out).toContain("A: bf16");
    expect(out).toContain("B: affine-q4-g64");
    expect(out).toContain("by-pos");
    expect(out).toContain("τ");
    expect(out).toContain("PASS");
  });
});
