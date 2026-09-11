import { expect, test, spyOn } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { createRowSampling as bindSampling } from "../../src/backends/mlx/row-sampling";
import { makeStepSampler, readStepExtras, type StepSamplerOptions } from "../../src/sampler";
import type { TokenLogprobs } from "../../src/contracts/generation";

const logits = (values: number[]) => MlxArray.fromFloat32(new Float32Array(values), [1, values.length]);
function createRowSampling(options: StepSamplerOptions & { logprobs?: boolean; topLogprobs?: number },
  prompt: number[], sink: Parameters<typeof bindSampling>[1]) {
  return bindSampling(makeStepSampler(options, {
    tokenRepresentation: "device", grammarWait: "external", historyUpdate: "after-sample",
    initialHistory: prompt, captureSelectedLogprob: options.logprobs,
    captureTopLogprobs: options.topLogprobs,
  }), sink);
}
function sample(row: ReturnType<typeof createRowSampling>, values: number[], step: number) {
  const input = logits(values);
  try {
    const token = row.sample(input, step);
    try { return token.toIntTokens()[0]!; } finally { token.dispose(); }
  } finally { input.dispose(); }
}
function check(entry: { token: number; lp?: TokenLogprobs }, values: number[], bias = 0) {
  const adjusted = values.map((v, i) => v + (i === 1 ? bias : 0));
  const norm = Math.log(adjusted.reduce((sum, v) => sum + Math.exp(v), 0));
  expect(entry.lp!.logprob).toBeCloseTo(adjusted[entry.token]! - norm, 5);
  expect(entry.lp!.top!.map(p => p.id)).toEqual(adjusted.map((_, i) => i).sort((a, b) => adjusted[b]! - adjusted[a]!).slice(0, 2));
  for (const pair of entry.lp!.top!) expect(pair.logprob).toBeCloseTo(adjusted[pair.id]! - norm, 5);
}

test("pipelined captures stay aligned across interleaved requests and logits processors", () => {
  const a: { token: number; lp?: TokenLogprobs }[] = [], b: typeof a = [];
  const first = createRowSampling({ temperature: 0, logprobs: true, topLogprobs: 2,
    logitBias: { 1: 2 } }, [9], (token, lp) => { a.push({ token, lp }); });
  const second = createRowSampling({ temperature: 0, logprobs: true, topLogprobs: 2 },
    [8], (token, lp) => { b.push({ token, lp }); });
  try {
    expect(first.plainGreedy).toBe(false);
    const a0 = sample(first, [0, 4, -2], 0), b0 = sample(second, [1, 0, 6], 0);
    const a1 = sample(first, [5, 0, 1], 1), b1 = sample(second, [3, 0, 1], 1);
    first.onToken(a0); second.onToken(b0); second.onToken(b1); first.onToken(a1);
    check(a[0]!, [0, 4, -2], 2); check(a[1]!, [5, 0, 1], 2);
    check(b[0]!, [1, 0, 6]); check(b[1]!, [3, 0, 1]);
  } finally { first.dispose(); second.dispose(); }
});

test("token-only requests keep their original output callback and vectorized eligibility", () => {
  const sink = () => false;
  const row = createRowSampling({ temperature: 0 }, [9], sink);
  try {
    expect(row.onToken).toBe(sink);
    expect(row.plainGreedy).toBe(true);
    expect(sample(row, [0, 4, 1], 0)).toBe(1);
  } finally { row.dispose(); }
});

test("seeded sampling and penalty history are independent of interleaved requests", () => {
  const values = Array.from({ length: 16 }, (_, i) => i / 12);
  const options = { temperature: 0.8, seed: 734, topP: 0.92, topK: 12,
    minP: 0.02, xtcProbability: 0.3, xtcThreshold: 0.1,
    repetitionPenalty: 1.1, presencePenalty: 0.15, frequencyPenalty: 0.05,
    logprobs: true, topLogprobs: 3 };
  const run = (interleave: boolean) => {
    const output: { token: number; lp?: TokenLogprobs }[] = [];
    const row = createRowSampling(options, [1, 2, 1], (token, lp) => { output.push({ token, lp }); });
    const other = createRowSampling({ ...options, seed: 319 }, [5, 6], () => {});
    try {
      for (let step = 0; step < 32; step++) {
        if (interleave) other.onToken(sample(other, values.map(v => -v), step));
        row.onToken(sample(row, values, step));
      }
      return output;
    } finally { row.dispose(); other.dispose(); }
  };
  expect(run(true)).toEqual(run(false));
});

test.each(["stop", "throw", "cancel"] as const)("%s releases unconsumed lookahead captures", (end) => {
  const arrays: MlxArray[] = [];
  const original = ops.asyncEvalAll;
  const dispatch = spyOn(ops, "asyncEvalAll").mockImplementation((values) => {
    arrays.push(...values.slice(1));
    return original(values);
  });
  const row = createRowSampling({ logprobs: true, topLogprobs: 2, temperature: 0 }, [9], () => {
    if (end === "throw") throw new Error("consumer failed");
    return false;
  });
  try {
    const token = sample(row, [0, 4, 1], 0);
    sample(row, [5, 0, 1], 1);
    if (end === "throw") expect(() => row.onToken(token)).toThrow("consumer failed");
    else if (end === "stop") expect(row.onToken(token)).toBe(false);
  } finally { row.dispose(); dispatch.mockRestore(); }
  expect(arrays).toHaveLength(6);
  for (const array of arrays) expect(() => array.handle).toThrow();
});

test("top-only capture omits selected logprob, and a read failure frees sibling arrays", () => {
  let output: TokenLogprobs | undefined;
  const row = createRowSampling({ temperature: 0, topLogprobs: 2 }, [9], (_token, lp) => { output = lp; });
  try { row.onToken(sample(row, [0, 4, 1], 0)); }
  finally { row.dispose(); }
  expect(output!.logprob).toBeUndefined();
  expect(output!.top!.map(p => p.id)).toEqual([1, 2]);
  const sel = logits([1]), topIdx = ops.fromInt32([1], [1, 1]), topVals = logits([1]);
  sel.dispose();
  expect(() => readStepExtras({ sel, topIdx, topVals })).toThrow();
  expect(() => topIdx.handle).toThrow(); expect(() => topVals.handle).toThrow();
});
