// Isolate Qwen3.8 token-zero work from the transformer prefill.
//
//   MODEL=/path/to/snapshot bun scripts/experiments/qwen-token-zero-head.ts
//
// Measures the first and warmed output-head + greedy-sampling evaluations.
// The first call is deliberately cold: mlx-bun maps model weights lazily.

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Qwen35Model } from "../../src/model/qwen3_5";
import { MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

const MODEL = process.env.MODEL;
if (!MODEL) throw new Error("set MODEL to a local Qwen3.8 snapshot");

const median = (xs: number[]): number => {
  const sorted = [...xs].sort((a, b) => a - b);
  return sorted[Math.floor(sorted.length / 2)]!;
};

const config = await loadModelConfig(MODEL);
const loadStarted = performance.now();
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const loadMs = performance.now() - loadStarted;
if (!(model instanceof Qwen35Model))
  throw new Error(`expected Qwen35Model, got ${model.constructor.name}`);

const H = config.text.hiddenSize;
const V = config.text.vocabSize;
const head = model.lmHead ?? model.embed;
const hiddenF32 = MlxArray.fromFloat32(new Float32Array(H), [1, 1, H]);
const hidden = hiddenF32.astype(Dtype.bfloat16);
hiddenF32.dispose();
ops.evalAll([hidden]);

function headOnly(): { ms: number; logits: MlxArray } {
  const started = performance.now();
  const logits = model.logitsFromHidden(hidden);
  ops.evalAll([logits]);
  return { ms: performance.now() - started, logits };
}

function sampleEvaluated(logits: MlxArray): { ms: number; token: number } {
  const started = performance.now();
  const lse = ops.logsumexpAxis(logits, -1, true);
  const logprobs = ops.sub(logits, lse);
  const tokenArray = ops.argmaxAxis(logprobs, -1);
  ops.evalAll([tokenArray]);
  const token = ops.itemUint32(tokenArray);
  tokenArray.dispose();
  logprobs.dispose();
  lse.dispose();
  return { ms: performance.now() - started, token };
}

function headAndSample(): { ms: number; token: number } {
  const started = performance.now();
  const logits = model.logitsFromHidden(hidden);
  const lse = ops.logsumexpAxis(logits, -1, true);
  const logprobs = ops.sub(logits, lse);
  const tokenArray = ops.argmaxAxis(logprobs, -1);
  ops.evalAll([tokenArray]);
  const token = ops.itemUint32(tokenArray);
  tokenArray.dispose();
  logprobs.dispose();
  lse.dispose();
  logits.dispose();
  return { ms: performance.now() - started, token };
}

console.log(JSON.stringify({
  runtime: "mlx-bun",
  model: MODEL,
  loadMs,
  hiddenSize: H,
  vocabSize: V,
  tied: model.tied,
  headSpec: head.spec,
  headWeightShape: head.w.shape,
  headScalesShape: head.scales.shape,
}));

// This is the request-visible cold path under investigation.
const cold = headAndSample();

const warmE2e: number[] = [];
for (let i = 0; i < 7; i++) warmE2e.push(headAndSample().ms);

// With the head output already evaluated, this leaves only normalization,
// argmax, and the scalar host read.
const { ms: warmHeadOnce, logits } = headOnly();
const sampleTimes: number[] = [];
let token = cold.token;
for (let i = 0; i < 7; i++) {
  const sample = sampleEvaluated(logits);
  sampleTimes.push(sample.ms);
  token = sample.token;
}

console.log(JSON.stringify({
  coldHeadSampleMs: cold.ms,
  warmHeadSampleMs: warmE2e,
  warmHeadSampleMedianMs: median(warmE2e),
  warmHeadOnlyMs: warmHeadOnce,
  warmSampleOnlyMs: sampleTimes,
  warmSampleOnlyMedianMs: median(sampleTimes),
  token,
}));

logits.dispose();
hidden.dispose();
weights.dispose();
clearCache();
