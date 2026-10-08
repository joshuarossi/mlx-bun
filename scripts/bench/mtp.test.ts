import { expect, test } from "bun:test";
import { mtpMetrics, pairedMtpComparison, parseMtpPlan, type MtpSample } from "./mtp";

function sample(overrides: Partial<MtpSample> = {}): MtpSample {
  return { variant: "mtp2", mode: "throughput", repetition: 0, prompt: 0,
    tokens: [1, 2, 3, 4, 5], promptTokens: 10, requestMs: 150, prefillMs: 50, decodeMs: 100,
    steps: [{ ms: 25, emitted: 1 }, { ms: 75, emitted: 3 }],
    spec: { drafted: 4, accepted: 2, rounds: 2 }, peakBytes: 100, ...overrides };
}
test("counts proposals separately from delivered correction/bonus tokens; uses ratio of sums", () => {
  const m = mtpMetrics([sample()]);
  expect(m.acceptedDraftsPerRound).toBe(1);
  expect(m.emittedPerRound).toBe(2);
  expect(m.acceptedDraftsPerSecond).toBe(20);
  expect(m.emittedPerSecond).toBe(40);
  expect(m.requestTokensPerSecond).toBeCloseTo(100 / 3);
  expect(m.phaseMsPerRound).toBeNull();
});
test("diagnostic phases cannot be mixed into throughput", () => {
  expect(() => mtpMetrics([sample(), sample({ mode: "diagnostic" })])).toThrow("never combine");
  expect(() => mtpMetrics([sample({ mode: "diagnostic" })])).toThrow("phases missing");
  expect(() => mtpMetrics([sample({ spec: { drafted: 4, accepted: 5, rounds: 2 } })])).toThrow("acceptance");
  expect(() => mtpMetrics([sample({ steps: [] })])).toThrow("no timed steps");
});
test("faster changed output fails the screen; pairs cannot silently disappear", () => {
  const a = sample(), b = sample({ steps: [{ ms: 10, emitted: 1 }, { ms: 40, emitted: 3 }] });
  expect(pairedMtpComparison([a], [b]).screenPass).toBe(true);
  expect(pairedMtpComparison([a], [{ ...b, tokens: [9, 2, 3, 4, 5] }]).screenPass).toBe(false);
  expect(() => pairedMtpComparison([a], [{ ...b, prompt: 1 }])).toThrow("paired sample");
});
test("plan requires balanced repetitions and protects timing controls", () => {
  const p = { target: "/target", draft: "/draft", artifactRevision: "rev", prompts: ["hi"],
    variants: [{ id: "baseline", depth: 2 }, { id: "wide", depth: 4 }], maxTokens: 32, repetitions: 2, warmupTokens: 8 };
  expect(parseMtpPlan(p)).toEqual(p);
  expect(() => parseMtpPlan({ ...p, repetitions: 3 })).toThrow("even");
  expect(() => parseMtpPlan({ ...p, variants: [p.variants[0], { id: "wide", depth: 4, env: { MLX_BUN_SPEC_PHASE_TIMING: "1" } }] })).toThrow("reserved");
});
