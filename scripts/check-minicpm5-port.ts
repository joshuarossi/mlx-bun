// Hard MiniCPM5 port check: no skip guards, prints the load/eval timings,
// and fails if the downloaded snapshot or oracle goldens are absent.

import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { MiniCPM5Model } from "../src/model/minicpm5";
import { argmaxLastPosition, lastPositionLogits } from "../src/model/gemma4-base";
import { Weights } from "../src/weights";
import { goldenPath } from "../tests/goldens";
import { SNAPSHOT_MINICPM5 } from "../tests/paths";

function requireFile(path: string): void {
  if (!existsSync(path)) throw new Error(`required file missing: ${path}`);
}

requireFile(`${SNAPSHOT_MINICPM5}/config.json`);
requireFile(`${SNAPSHOT_MINICPM5}/model.safetensors.index.json`);
requireFile(goldenPath("minicpm5-parity.json"));
const LOGIT_STEPS = 100;
for (let i = 0; i < LOGIT_STEPS; i++) requireFile(goldenPath(`minicpm5-logits-step${i}.bin`));

const golden = (await Bun.file(goldenPath("minicpm5-parity.json")).json()) as {
  prompt_ids: number[];
  greedy_ids: number[];
  logit_steps: number;
};

let t = performance.now();
const config = await loadModelConfig(SNAPSHOT_MINICPM5);
const weights = await Weights.open(SNAPSHOT_MINICPM5);
const openMs = performance.now() - t;

t = performance.now();
const model = new MiniCPM5Model(weights, config);
const constructMs = performance.now() - t;

console.log(`snapshot     ${SNAPSHOT_MINICPM5}`);
console.log(`model        ${config.modelType} hidden=${config.text.hiddenSize} layers=${config.text.numHiddenLayers}`);
console.log(`weights      ${(model.weightsBytes / 1e9).toFixed(3)} GB, tensors=${weights.tensorNames.length}`);
console.log(`open         ${openMs.toFixed(1)} ms`);
console.log(`construct    ${constructMs.toFixed(1)} ms`);

const cache = model.makeCache();
let tokens = golden.prompt_ids;
let firstEvalMs = 0;
let totalMs = 0;
try {
  const start = performance.now();
  for (let step = 0; step < golden.greedy_ids.length; step++) {
    const stepStart = performance.now();
    const logits = model.forward(tokens, cache);
    if (step < golden.logit_steps) {
      const ours = lastPositionLogits(logits);
      const ref = new Float32Array(
        await Bun.file(goldenPath(`minicpm5-logits-step${step}.bin`)).arrayBuffer(),
      );
      let maxDiff = 0;
      for (let i = 0; i < ref.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
      if (maxDiff !== 0) throw new Error(`step ${step}: max logit diff ${maxDiff}`);
    }
    const next = argmaxLastPosition(logits);
    logits.dispose();
    if (step === 0) firstEvalMs = performance.now() - stepStart;
    if (next !== golden.greedy_ids[step])
      throw new Error(`step ${step}: token ${next} !== oracle ${golden.greedy_ids[step]}`);
    tokens = [next];
  }
  totalMs = performance.now() - start;
} finally {
  for (const c of cache) c.dispose();
}

console.log(`first eval   ${firstEvalMs.toFixed(1)} ms`);
console.log(`decode       ${golden.greedy_ids.length} tokens in ${totalMs.toFixed(1)} ms`);
console.log(`parity       100/100 greedy ids, ${golden.logit_steps}/100 full-logit vectors bit-exact`);
