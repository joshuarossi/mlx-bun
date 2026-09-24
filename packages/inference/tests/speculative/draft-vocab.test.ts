import { expect, test } from "bun:test";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { makeSampler, toLogprobs } from "../../src/sampling/index";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { configuredDraftVocabulary, DraftVocabularyHead, makeSubsetDraftSampler } from "../../src/generation/speculative/draft-vocab";

const V = 4096;
function randomLogits(seed: number, dtype: Dtype, rows = 1): MlxArray {
  using key = ops.randomKey(BigInt(seed));
  using noise = ops.randomNormal([rows, V], Dtype.float32, 0, 3, key);
  return noise.astype(dtype);
}

test("a draft vocabulary head is an exact row gather of the quantized head", () => {
  using key = ops.randomKey(5n);
  using dense = ops.randomNormal([512, 128], Dtype.bfloat16, 0, 0.05, key);
  const q = ops.quantize(dense, 64, 4);
  const spec = { bits: 4, groupSize: 64, mode: "affine" };
  const ids = [0, 3, 17, 64, 65, 200, 511];
  const head = new DraftVocabularyHead({ w: q.packed, scales: q.scales, biases: q.biases, spec }, ids);
  try {
    using hk = ops.randomKey(9n);
    using hidden = ops.randomNormal([2, 1, 128], Dtype.bfloat16, 0, 1, hk);
    // Reference: dequantize exactly the listed rows and multiply densely.
    using rowsW = ops.takeAxis(q.packed, head.ids, 0); using rowsS = ops.takeAxis(q.scales, head.ids, 0); using rowsB = ops.takeAxis(q.biases, head.ids, 0);
    using dense7 = ops.dequantize(rowsW, rowsS, rowsB, spec);
    using dense7T = ops.transposeAxes(dense7, [1, 0]);
    using expected = ops.matmul(hidden, dense7T);
    using actual = head.project(hidden);
    expect(actual.shape).toEqual([2, 1, ids.length]);
    using a32 = actual.astype(Dtype.float32); using e32 = expected.astype(Dtype.float32);
    const got = [...a32.toFloat32Host()], want = [...e32.toFloat32Host()];
    const scale = Math.max(...want.map(Math.abs));
    for (const [i, value] of got.entries()) expect(Math.abs(value - want[i]!)).toBeLessThanOrEqual(scale * 2e-2);
  } finally { head.dispose(); q.packed.dispose(); q.scales.dispose(); q.biases.dispose(); }
});

test("with every id listed the subset draw equals the request sampler, filtered or not", () => {
  using key = ops.randomKey(21n);
  using dense = ops.randomNormal([V, 64], Dtype.float32, 0, 0.05, key);
  const q = ops.quantize(dense, 64, 4);
  const head = new DraftVocabularyHead({ w: q.packed, scales: q.scales, biases: q.biases, spec: { bits: 4, groupSize: 64, mode: "affine" } },
    Array.from({ length: V }, (_, id) => id));
  try {
    for (const options of [
      { temperature: 0.6, seed: 42 },
      { temperature: 0.6, topP: 0.95, topK: 20, seed: 42 },
      { temperature: 0.45, topK: 20, minP: 0.05, seed: 7 },
      { temperature: 0 },
    ]) {
      const full = makeSampler(options), subset = makeSubsetDraftSampler(options)!;
      for (let step = 0; step < 25; step++) {
        using logits = randomLogits(step * 31 + 3, Dtype.bfloat16);
        using logprobs = toLogprobs(logits);
        using expected = full(logprobs, step);
        using actual = subset(logits, head, step);
        expect(actual.toIntTokens()).toEqual(expected.toIntTokens());
      }
    }
    expect(makeSubsetDraftSampler({ temperature: 0.6, xtcProbability: 0.5, xtcThreshold: 0.1 })).toBeNull();
  } finally { head.dispose(); q.packed.dispose(); q.scales.dispose(); q.biases.dispose(); }
});

test("a restricted list draws exactly a full-vocabulary draw with no mass outside the list", () => {
  using key = ops.randomKey(33n);
  using dense = ops.randomNormal([V, 64], Dtype.float32, 0, 0.05, key);
  const q = ops.quantize(dense, 64, 4);
  const ids = Array.from({ length: 900 }, (_, i) => i * 4 + 1);
  const head = new DraftVocabularyHead({ w: q.packed, scales: q.scales, biases: q.biases, spec: { bits: 4, groupSize: 64, mode: "affine" } }, ids);
  try {
    const subset = makeSubsetDraftSampler({ temperature: 0.6, seed: 42 })!;
    const full = makeSampler({ temperature: 0.6, seed: 42 });
    const listed = new Set(ids);
    for (let step = 0; step < 25; step++) {
      using logits = randomLogits(step + 100, Dtype.float32);
      using sub = ops.takeAxis(logits, head.ids, 1);
      using token = subset(sub, head, step);
      // Same draw over the full vocabulary with every unlisted id masked out.
      const host = [...logits.toFloat32Host()].map((value, id) => listed.has(id) ? value : -Infinity);
      using masked = MlxArray.fromFloat32(Float32Array.from(host), [1, V]);
      using maskedLp = toLogprobs(masked);
      using expected = full(maskedLp, step);
      expect(token.toIntTokens()).toEqual(expected.toIntTokens());
      expect(listed.has(token.toIntTokens()[0]!)).toBe(true);
    }
  } finally { head.dispose(); q.packed.dispose(); q.scales.dispose(); q.biases.dispose(); }
});

test("the configured list is validated against the target vocabulary", () => {
  const dir = mkdtempSync(join(tmpdir(), "draft-vocab-"));
  const good = join(dir, "good.json"), bad = join(dir, "bad.json");
  writeFileSync(good, JSON.stringify({ ids: [5, 1, 3, 3] }));
  writeFileSync(bad, JSON.stringify({ ids: [] }));
  expect(withRuntimeConfig(createRuntimeConfig({}), () => configuredDraftVocabulary(10))).toBeNull();
  expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_DRAFT_VOCAB: good }), () => configuredDraftVocabulary(10))).toEqual([1, 3, 5]);
  expect(() => withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_DRAFT_VOCAB: good }), () => configuredDraftVocabulary(4))).toThrow(/outside the target vocabulary/);
  expect(() => withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_DRAFT_VOCAB: bad }), () => configuredDraftVocabulary(10))).toThrow(/expected/);
  // Shipped beside the companion: used with no environment, overridable, and disableable.
  const companion = mkdtempSync(join(tmpdir(), "draft-companion-"));
  writeFileSync(join(companion, "draft_vocab.json"), JSON.stringify({ ids: [7, 2] }));
  expect(withRuntimeConfig(createRuntimeConfig({}), () => configuredDraftVocabulary(10, companion))).toEqual([2, 7]);
  expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_DRAFT_VOCAB: good }), () => configuredDraftVocabulary(10, companion))).toEqual([1, 3, 5]);
  for (const off of ["0", "off"])
    expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_DRAFT_VOCAB: off }), () => configuredDraftVocabulary(10, companion))).toBeNull();
  expect(withRuntimeConfig(createRuntimeConfig({}), () => configuredDraftVocabulary(10, dir))).toBeNull();
});
