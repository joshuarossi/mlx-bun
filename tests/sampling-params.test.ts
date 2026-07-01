// Sampling-parameter ports (model-free): min-p, XTC, presence/frequency
// penalties, logit bias — hand-computed logits only, no weights, no server.
// Reference semantics: mlx-lm 0.31.3 sample_utils.py.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import {
  applyMinP, applyXtc, makeLogitsProcessors, makeSampler, toLogprobs,
} from "../src/sampler";

/** probabilities → logprobs [1, V] (values must sum to 1). */
function lpFromProbs(probs: number[]): MlxArray {
  const logits = MlxArray.fromFloat32(Float32Array.from(probs.map(Math.log)), [1, probs.length]);
  const lp = toLogprobs(logits);
  logits.dispose();
  return lp;
}

function logits(values: number[]): MlxArray {
  return MlxArray.fromFloat32(Float32Array.from(values), [1, values.length]);
}

describe("applyMinP", () => {
  // p = [0.5, 0.25, 0.125, 0.0625, 0.0625], minP = 0.2 ⇒ cutoff = 0.5·0.2 = 0.1
  // ⇒ tokens 0..2 survive (0.125 ≥ 0.1), tokens 3..4 → -inf.
  test("filters exactly the tokens below minP · p(top)", () => {
    const lp = lpFromProbs([0.5, 0.25, 0.125, 0.0625, 0.0625]);
    const out = applyMinP(lp, 0.2).toFloat32();
    expect(Number.isFinite(out[0]!)).toBe(true);
    expect(Number.isFinite(out[1]!)).toBe(true);
    expect(Number.isFinite(out[2]!)).toBe(true);
    expect(out[3]!).toBe(-Infinity);
    expect(out[4]!).toBe(-Infinity);
    lp.dispose();
  });

  test("survivors keep their original logprobs", () => {
    const lp = lpFromProbs([0.5, 0.25, 0.125, 0.0625, 0.0625]);
    const before = lp.toFloat32();
    const out = applyMinP(lp, 0.2).toFloat32();
    for (const i of [0, 1, 2]) expect(out[i]!).toBeCloseTo(before[i]!, 6);
    lp.dispose();
  });

  // minP = 0.9 ⇒ cutoff 0.45: only token 0 survives — but minTokensToKeep = 2
  // must rescue token 1 (the next most likely).
  test("minTokensToKeep rescues the top tail", () => {
    const lp = lpFromProbs([0.5, 0.25, 0.125, 0.0625, 0.0625]);
    const solo = applyMinP(lp, 0.9).toFloat32();
    expect(Number.isFinite(solo[0]!)).toBe(true);
    for (const i of [1, 2, 3, 4]) expect(solo[i]!).toBe(-Infinity);

    const kept = applyMinP(lp, 0.9, 2).toFloat32();
    expect(Number.isFinite(kept[0]!)).toBe(true);
    expect(Number.isFinite(kept[1]!)).toBe(true);
    for (const i of [2, 3, 4]) expect(kept[i]!).toBe(-Infinity);
    lp.dispose();
  });

  test("rejects out-of-range arguments (reference validation)", () => {
    const lp = lpFromProbs([0.5, 0.5]);
    expect(() => applyMinP(lp, 1.5)).toThrow();
    expect(() => applyMinP(lp, 0.1, 0)).toThrow();
    lp.dispose();
  });
});

describe("applyXtc", () => {
  // p = [0.5, 0.3, 0.15, 0.05], threshold 0.2: above-threshold = {0.5, 0.3},
  // min of those = 0.3 ⇒ mask = p > 0.3 ⇒ ONLY token 0 removed. With
  // xtcProbability = 1 the uniform draw (< 1) never skips the cull.
  test("probability 1: removes the top tokens above the least above-threshold token", () => {
    const lp = lpFromProbs([0.5, 0.3, 0.15, 0.05]);
    const key = ops.randomKey(7n);
    const out = applyXtc(lp, 1.0, 0.2, [], key).toFloat32();
    expect(out[0]!).toBe(-Infinity);
    for (const i of [1, 2, 3]) expect(Number.isFinite(out[i]!)).toBe(true);
    key.dispose();
    lp.dispose();
  });

  // Lower threshold 0.1: above-threshold = {0.5, 0.3, 0.15}, min = 0.15 ⇒
  // tokens 0 AND 1 removed; token 2 (the least likely above-threshold) kept.
  test("keeps the least likely above-threshold token", () => {
    const lp = lpFromProbs([0.5, 0.3, 0.15, 0.05]);
    const key = ops.randomKey(7n);
    const out = applyXtc(lp, 1.0, 0.1, [], key).toFloat32();
    expect(out[0]!).toBe(-Infinity);
    expect(out[1]!).toBe(-Infinity);
    expect(Number.isFinite(out[2]!)).toBe(true);
    expect(Number.isFinite(out[3]!)).toBe(true);
    key.dispose();
    lp.dispose();
  });

  test("special tokens are excluded from removal", () => {
    const lp = lpFromProbs([0.5, 0.3, 0.15, 0.05]);
    const key = ops.randomKey(7n);
    const before = lp.toFloat32();
    const out = applyXtc(lp, 1.0, 0.1, [0], key).toFloat32();
    expect(out[0]!).toBeCloseTo(before[0]!, 6); // protected
    expect(out[1]!).toBe(-Infinity);
    key.dispose();
    lp.dispose();
  });

  test("probability 0: logits pass through untouched", () => {
    const lp = lpFromProbs([0.5, 0.3, 0.15, 0.05]);
    const key = ops.randomKey(7n);
    const before = lp.toFloat32();
    const out = applyXtc(lp, 0.0, 0.2, [], key).toFloat32();
    for (let i = 0; i < before.length; i++) expect(out[i]!).toBeCloseTo(before[i]!, 6);
    key.dispose();
    lp.dispose();
  });

  test("makeSampler chain: XTC(p=1) never emits the culled top token", () => {
    const sampler = makeSampler({ temperature: 1, xtcProbability: 1, xtcThreshold: 0.2, seed: 3 });
    for (let step = 0; step < 8; step++) {
      const lp = lpFromProbs([0.5, 0.3, 0.15, 0.05]);
      const tok = sampler(lp, step);
      expect(ops.itemUint32(tok)).not.toBe(0);
      tok.dispose();
      lp.dispose();
    }
  });
});

describe("presence vs frequency penalty", () => {
  // History window [5, 5, 5, 7]: presence subtracts the penalty ONCE per
  // distinct token; frequency subtracts penalty × occurrence count.
  const base = [0, 0, 0, 0, 0, 4, 0, 2]; // V = 8; token 5 and 7 penalized
  const history = () => ops.fromInt32([5, 5, 5, 7], [4]);

  test("presence: −penalty once per distinct token in the window", () => {
    const [proc] = makeLogitsProcessors({ presencePenalty: 1.5 });
    const tokens = history();
    const out = proc!(tokens, logits(base)).toFloat32();
    expect(out[5]!).toBeCloseTo(4 - 1.5, 6);
    expect(out[7]!).toBeCloseTo(2 - 1.5, 6);
    for (const i of [0, 1, 2, 3, 4, 6]) expect(out[i]!).toBeCloseTo(0, 6);
    tokens.dispose();
  });

  test("frequency: −penalty × occurrence count", () => {
    const [proc] = makeLogitsProcessors({ frequencyPenalty: 1.5 });
    const tokens = history();
    const out = proc!(tokens, logits(base)).toFloat32();
    expect(out[5]!).toBeCloseTo(4 - 3 * 1.5, 6); // token 5 occurs 3× in window
    expect(out[7]!).toBeCloseTo(2 - 1 * 1.5, 6);
    for (const i of [0, 1, 2, 3, 4, 6]) expect(out[i]!).toBeCloseTo(0, 6);
    tokens.dispose();
  });

  test("the two differ exactly on the repeated token", () => {
    const [pres] = makeLogitsProcessors({ presencePenalty: 1.0 });
    const [freq] = makeLogitsProcessors({ frequencyPenalty: 1.0 });
    const t1 = history(), t2 = history();
    const a = pres!(t1, logits(base)).toFloat32();
    const b = freq!(t2, logits(base)).toFloat32();
    expect(a[5]! - b[5]!).toBeCloseTo(2, 6); // 3 occurrences vs 1 presence hit
    expect(a[7]!).toBeCloseTo(b[7]!, 6); // single occurrence: identical
    t1.dispose();
    t2.dispose();
  });

  test("context-size windowing only counts recent tokens", () => {
    const [proc] = makeLogitsProcessors({ frequencyPenalty: 1.0, frequencyContextSize: 2 });
    const tokens = ops.fromInt32([5, 5, 5, 7], [4]); // window of 2 → [5, 7]
    const out = proc!(tokens, logits(base)).toFloat32();
    expect(out[5]!).toBeCloseTo(4 - 1, 6);
    expect(out[7]!).toBeCloseTo(2 - 1, 6);
    tokens.dispose();
  });

  test("negative penalties boost (OpenAI semantics allow them)", () => {
    const [proc] = makeLogitsProcessors({ presencePenalty: -2.0 });
    const tokens = history();
    const out = proc!(tokens, logits(base)).toFloat32();
    expect(out[5]!).toBeCloseTo(6, 6);
    tokens.dispose();
  });
});

describe("logit bias", () => {
  test("shifts the argmax", () => {
    const [proc] = makeLogitsProcessors({ logitBias: { 0: 10 } });
    const before = logits([0, 1, 2, 3]);
    const out = proc!(null, before);
    const arg = ops.argmaxAxis(out, -1);
    expect(ops.itemUint32(arg)).toBe(0);
    arg.dispose();
    out.dispose();
  });

  test("adds each bias at its token id, leaving the rest untouched", () => {
    const [proc] = makeLogitsProcessors({ logitBias: { 1: 2.5, 3: -4 } });
    const out = proc!(null, logits([0, 1, 2, 3])).toFloat32();
    expect(out[0]!).toBeCloseTo(0, 6);
    expect(out[1]!).toBeCloseTo(3.5, 6);
    expect(out[2]!).toBeCloseTo(2, 6);
    expect(out[3]!).toBeCloseTo(-1, 6);
  });

  test("empty bias map produces no processor", () => {
    expect(makeLogitsProcessors({ logitBias: {} })).toHaveLength(0);
  });
});

describe("seeded reproducibility with the new chain", () => {
  test("same seed → same draws; different seed → different somewhere", () => {
    const run = (seed: number): number[] => {
      const sampler = makeSampler({ temperature: 1.4, minP: 0.05, xtcProbability: 0.5, xtcThreshold: 0.1, seed });
      const toks: number[] = [];
      for (let step = 0; step < 16; step++) {
        const lp = lpFromProbs([0.4, 0.3, 0.15, 0.1, 0.05]);
        const tok = sampler(lp, step);
        toks.push(ops.itemUint32(tok));
        tok.dispose();
        lp.dispose();
      }
      return toks;
    };
    const a = run(42), b = run(42), c = run(43);
    expect(a).toEqual(b);
    expect(a).not.toEqual(c);
  });
});
