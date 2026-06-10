// Phase 2 oracle harness: run our model on the golden prompt and compare
// per-step logits + greedy tokens against the Python reference.
//
//   bun scripts/parity-check.ts [--steps N]

import { SNAPSHOT } from "../tests/paths";
import { goldenAt } from "../tests/goldens";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { Gemma4Model, argmaxLastPosition, lastPositionLogits } from "../src/model/gemma4";
import { peakMemory } from "../src/mlx/ffi";

const golden = (await goldenAt("parity.json").json()) as {
  prompt: string;
  prompt_ids: number[];
  greedy_ids: number[];
  logit_steps: number;
};
const stepsArg = process.argv.indexOf("--steps");
const maxSteps = stepsArg > -1 ? Number(process.argv[stepsArg + 1]) : golden.greedy_ids.length;

console.log(`prompt: ${JSON.stringify(golden.prompt)} (${golden.prompt_ids.length} tokens)`);

const t0 = performance.now();
const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = new Gemma4Model(weights, config);
console.log(`model constructed in ${(performance.now() - t0).toFixed(0)} ms`);

const cache = model.makeCache();
let tokens = golden.prompt_ids;
let identical = 0;
let firstDivergence = -1;

const tGen0 = performance.now();
for (let step = 0; step < maxSteps; step++) {
  const logits = model.forward(tokens, cache);

  if (step < golden.logit_steps) {
    const ours = lastPositionLogits(logits);
    const ref = new Float32Array(
      await goldenAt(`logits-step${step}.bin`).arrayBuffer(),
    );
    let maxDiff = 0;
    let maxAt = -1;
    for (let i = 0; i < ref.length; i++) {
      const d = Math.abs(ours[i]! - ref[i]!);
      if (d > maxDiff) { maxDiff = d; maxAt = i; }
    }
    console.log(
      `step ${step}: logits max|Δ| = ${maxDiff.toExponential(2)} at vocab[${maxAt}] ` +
      `(ours ${ours[maxAt]?.toFixed(4)}, ref ${ref[maxAt]?.toFixed(4)})`,
    );
  }

  const next = argmaxLastPosition(logits);
  logits.dispose();

  const want = golden.greedy_ids[step]!;
  if (next === want) {
    identical++;
  } else if (firstDivergence === -1) {
    firstDivergence = step;
    console.log(`step ${step}: DIVERGED — ours ${next}, ref ${want}`);
  }
  tokens = [want]; // continue along the reference path even after divergence
}
const dt = (performance.now() - tGen0) / 1000;

for (const c of cache) c.dispose();

console.log(`\ntokens identical: ${identical}/${maxSteps}` +
  (firstDivergence >= 0 ? ` (first divergence at step ${firstDivergence})` : ""));
console.log(`decode: ${(maxSteps / dt).toFixed(1)} tok/s (unoptimized; incl. prefill+logit reads)`);
console.log(`mlx peak memory: ${(peakMemory() / 1e9).toFixed(2)} GB`);
process.exit(identical === maxSteps ? 0 : 1);
