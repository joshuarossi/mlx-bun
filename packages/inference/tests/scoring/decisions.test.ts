import { expect, test } from "bun:test";
import type { DecisionScoringGraph } from "../../src/scoring/decisions";
import type { Cache } from "../../src/contracts/mlx/cache";
import * as ops from "@mlx-bun/mlx/ops";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { scoreDecisionAnswers, sequenceLogProbabilities } from "../../src/scoring";

const width = 8;
const row = (token: number) => Array.from({ length: width }, (_, i) => ((token + 1) * (i + 2) % 11 - 5) / 3);
const logp = (token: number, target: number) => {
  const logits = row(token), max = Math.max(...logits);
  return logits[target]! - max - Math.log(logits.reduce((sum, value) => sum + Math.exp(value - max), 0));
};
function fixture() {
  const forwards: number[][] = [], heads: number[] = [];
  let disposed = 0;
  const graph: DecisionScoringGraph = {
    makeCache: () => [{ dispose() { disposed++; } }] as unknown as Cache[],
    forward: ids => {
      const tokens = ids.toIntTokens(); forwards.push(tokens);
      return MlxArray.fromFloat32(Float32Array.from(tokens.flatMap(row)), [1, tokens.length, width]);
    },
    logits: hidden => { heads.push(hidden.shape[1]!); return ops.contiguous(hidden); },
  };
  return { graph, forwards, heads, disposed: () => disposed };
}

test("teacher forcing scores every supplied token, masks prompts, and averages the DPO sum", async () => {
  const f = fixture(), prompt = [1, 2], answers = [[3, 4, 0], [3, 5, 0], [6, 0]];
  const result = await scoreDecisionAnswers(f.graph, prompt, answers);
  expect(f.forwards).toEqual(answers.map(answer => [...prompt, ...answer.slice(0, -1)]));
  const expected = answers.map(answer => answer.reduce((sum, token, i) => sum + logp(i ? answer[i - 1]! : prompt.at(-1)!, token), 0) / answer.length);
  for (let i = 0; i < expected.length; i++) expect(result.meanLogLikelihoods[i]!).toBeCloseTo(expected[i]!, 5);
  expect(result.probabilities.reduce((sum, p) => sum + p, 0)).toBeCloseTo(1, 12);
  expect(result.probabilities[0]).not.toBe(result.probabilities[1]); // shared first token, distinct completions
  expect(f.heads).toEqual([4, 4, 4]); // exact existing two/three-row DPO/ORPO padding
  expect(f.disposed()).toBe(3);
  // A prompt-only token changes neither the predictions nor the response average.
  const second = await scoreDecisionAnswers(f.graph, [7, ...prompt], answers);
  expect(second.meanLogLikelihoods).toEqual(result.meanLogLikelihoods);
});

test("equal per-token likelihood gives equal decision weight regardless of answer length", async () => {
  const f = fixture();
  f.graph.forward = ids => ops.zeros([1, ids.shape[1]!, width], Dtype.float32);
  const result = await scoreDecisionAnswers(f.graph, [1, 2, 3], [[4, 0], [4, 5, 6, 7, 0]]);
  for (const score of result.meanLogLikelihoods) expect(score).toBeCloseTo(-Math.log(width), 6);
  for (const probability of result.probabilities) expect(probability).toBeCloseTo(0.5, 6);
  expect(f.disposed()).toBe(2);
});

test("DPO's shared response mask excludes prompt and right-padding positions", () => {
  const tokens = [[1, 2, 3, 4, 0], [5, 6, 7, 0, 0]], masks = [[0, 0, 1, 1, 1], [0, 0, 1, 1, 0]];
  using logits = MlxArray.fromFloat32(Float32Array.from(tokens.flatMap(tokens => tokens.slice(0, -1).flatMap(row))), [2, 4, width]);
  using scores = sequenceLogProbabilities(logits, tokens, masks);
  const actual = scores.toFloat32();
  for (let b = 0; b < 2; b++) expect(actual[b]!).toBeCloseTo(tokens[b]!.slice(1).reduce((sum, target, i) =>
    sum + (masks[b]![i + 1] ? logp(tokens[b]![i]!, target) : 0), 0), 5);
});

test("cancellation between candidates and a failing head release private caches", async () => {
  const f = fixture(), controller = new AbortController();
  await expect(scoreDecisionAnswers(f.graph, [1], [[2, 0], [3, 0]], { signal: controller.signal,
    execute: async work => { const result = await work(); controller.abort(new Error("stop")); return result; } })).rejects.toThrow("stop");
  expect(f.forwards).toHaveLength(1); expect(f.disposed()).toBe(1);
  const failure = fixture(); failure.graph.logits = () => { throw new Error("head failed"); };
  await expect(scoreDecisionAnswers(failure.graph, [1], [[2, 0], [3, 0]])).rejects.toThrow("head failed");
  expect(failure.disposed()).toBe(1);
});

test("prepared media feeds known answer tokens without sampling and preserves borrowed input", async () => {
  const f = fixture(), visited: number[][] = [];
  const result = await scoreDecisionAnswers(f.graph, [1, 2], [[3, 4, 0], [3, 5, 0]], { input: {
    prefill: ids => {
      const tokens = ids.toIntTokens(); visited.push(tokens);
      return MlxArray.fromFloat32(Float32Array.from(row(tokens.at(-1)!)), [1, 1, width]);
    },
  } });
  expect(f.forwards).toHaveLength(0);
  expect(visited).toEqual([[1, 2], [3], [4], [1, 2], [3], [5]]);
  expect(result.meanLogLikelihoods[0]!).toBeCloseTo((logp(2, 3) + logp(3, 4) + logp(4, 0)) / 3, 5);
  expect(f.disposed()).toBe(2);
});
