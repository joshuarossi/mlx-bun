import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { normalizedArgmax } from "../../src/mlx/normalized-argmax";
import { toLogprobs, makeSampler, makeStepSampler } from "../../src/sampler";
import { CompiledFunction } from "../../src/mlx/compile";

function compare(input: MlxArray) {
  using scores = toLogprobs(input);
  using expected = ops.argmaxAxis(scores, -1);
  using actual = normalizedArgmax(input);
  expect(actual.shape).toEqual(expected.shape);
  expect(actual.toIntTokens()).toEqual(expected.toIntTokens());
}

test("tiled normalized selection matches native rounding, ties, nonfinite values and strided rows", () => {
  for (const dtype of [Dtype.float32, Dtype.float16, Dtype.bfloat16]) {
    for (const vocab of [1, 4, 31, 127, 1023, 1024, 1025, 4096, 248320, 262144]) {
      using raw = MlxArray.fromFloat32(Float32Array.from({ length: 8 * vocab }, (_, i) =>
        Math.sin(i * 0.3) * 4 + Math.cos(i * 0.21)), [2, 4, vocab]);
      using input = raw.astype(dtype);
      compare(input);
      using transposed = ops.transposeAxes(input, [1, 0, 2]);
      compare(transposed);
      using flat = ops.reshape(input, [vocab, 8]);
      using stridedVocabulary = ops.transposeAxes(flat, [1, 0]);
      compare(stridedVocabulary);
    }
    for (const values of [
      [0, 1e-8, 0, 0], [0, -0, 0, -0], [1, 1, 1, 1],
      [0, NaN, 1, 2], [NaN, 0, NaN, 1], [0, Infinity, Infinity, 1],
      [-Infinity, -Infinity, -Infinity, -Infinity], [NaN, NaN, NaN, NaN],
      [-Infinity, -3, -2, -Infinity], [65504, 65500, -65504, 0],
    ]) {
      using raw = MlxArray.fromFloat32(new Float32Array(values), [values.length]);
      using input = raw.astype(dtype);
      compare(input);
    }
    const values = new Float32Array(4097).fill(-1);
    values[2048] = 1e-8; values[31] = 0;
    using raw = MlxArray.fromFloat32(values, [1, 4097]);
    using input = raw.astype(dtype);
    compare(input);
  }
}, 30000);

test("greedy session composes processors and grammar before fused selection", async () => {
  const grammar = { isTerminated: false, async ready() {},
    applyMask(input: MlxArray) { return ops.mulScalar(input, 1); }, accept() {} };
  const options = { temperature: 0, grammar, repetitionPenalty: 1.2, logitBias: { 7: 0.25 } };
  const config = { tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
    initialHistory: [7, 19], acceptGrammar: true } as const;
  const candidate = makeStepSampler(options, config);
  const reference = makeStepSampler(options, { ...config, sampler: makeSampler(options) });
  try {
    for (let step = 0; step < 16; step++) {
      using logits = MlxArray.fromFloat32(Float32Array.from({ length: 4096 }, (_, i) => Math.sin(i * 0.3 + step)), [1, 4096]);
      expect((await candidate.sample(logits, step)).token).toBe((await reference.sample(logits, step)).token);
    }
  } finally { candidate.dispose(); reference.dispose(); }
});

test("shapeless enclosing graphs preserve native selection as row dimensions change", () => {
  const graph = new CompiledFunction(([input]) => [normalizedArgmax(input!)]);
  try {
    for (const rows of [1, 4, 9, 1]) {
      using input = MlxArray.fromFloat32(Float32Array.from({ length: rows * 4096 }, (_, i) => Math.cos(i * 0.3)), [rows, 4096]);
      using expectedScores = toLogprobs(input);
      using expected = ops.argmaxAxis(expectedScores, -1);
      using actual = graph.apply([input])[0]!;
      expect(actual.toIntTokens()).toEqual(expected.toIntTokens());
    }
    expect(graph.traceCount).toBe(1);
  } finally { graph.dispose(); }
});
