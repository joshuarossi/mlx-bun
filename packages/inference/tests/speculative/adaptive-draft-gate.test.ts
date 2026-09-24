import { describe, expect, test } from "bun:test";
import { AdaptiveDraftGate } from "../../src/generation/speculative/adaptive-draft-gate";

const costs = new Map([[1, 1], [2, 1.11], [3, 1.25], [5, 1.60], [9, 2.30]]);

describe("adaptive speculative draft gate", () => {
  test("drafts deeply when acceptance is high and gates when it collapses", () => {
    const gate = new AdaptiveDraftGate(costs, { maxDraftTokens: 8 });
    for (let i = 0; i < 8; i++) gate.observe(8, 0);
    expect(gate.choose(8)).toBeGreaterThan(1);
    for (let i = 0; i < 32; i++) gate.observe(0, 1);
    expect(gate.choose(8)).toBe(0);
  });

  test("charges recurrent replay and selects no deeper than the budget", () => {
    const plain = new AdaptiveDraftGate(costs, { maxDraftTokens: 8 });
    const replay = new AdaptiveDraftGate(costs, { maxDraftTokens: 8, replayOnReject: true });
    expect(replay.expectedRate(4)).toBeLessThan(plain.expectedRate(4));
    expect(plain.choose(2)).toBeLessThanOrEqual(2);
  });
});
