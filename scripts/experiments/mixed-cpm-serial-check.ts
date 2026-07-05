// Diagnostic: is the SERIAL engine bit-exact vs the cpm5 mixed golden?
// Splits gate-1's 0.0625 into (batch-path bug) vs (golden/composition gap).
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { maybeQuantizeKv } from "../../src/generate";
import { lastPositionLogits } from "../../src/model/gemma4";
import { goldenAt } from "../../tests/goldens";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";
import * as ops from "../../src/mlx/ops";

const golden = (await goldenAt("mixed-kv-cpm.json").json()) as {
  prompt_ids: number[]; mixed: number[]; logit_steps: number;
};
const config = await loadModelConfig(SNAPSHOT_MINICPM5);
const weights = await Weights.open(SNAPSHOT_MINICPM5);
const model = createModel(weights, config);
const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };

const cache = model.makeCache();
const diffAt = async (step: number, logits: any) => {
  const ours = lastPositionLogits(logits);
  const ref = new Float32Array(await goldenAt(`mixedkv-cpm-logits-step${step}.bin`).arrayBuffer());
  let maxDiff = 0;
  for (let i = 0; i < ref.length; i++) maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
  console.log(`step ${step}: maxDiff ${maxDiff}`);
};

let l = model.forward(golden.prompt_ids, cache);
await diffAt(0, l);
l.dispose();
maybeQuantizeKv(cache, kvOpts);
for (let s = 1; s < golden.logit_steps; s++) {
  l = model.forward([golden.mixed[s - 1]!], cache);
  await diffAt(s, l);
  l.dispose();
}
for (const c of cache) c.dispose();
