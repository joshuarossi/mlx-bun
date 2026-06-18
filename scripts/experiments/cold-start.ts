// Phase 5 exit-criterion harness: cold process → model open → KV-cache
// load (zero-copy mmap) → first token of a cached-prefix prompt. The
// criterion is < 1s end-to-end (excluding bun startup itself).
//
//   bun scripts/cold-start.ts          # prepares the cache file if absent

import { SNAPSHOT } from "../../tests/paths";
import { goldenAt } from "../../tests/goldens";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import type { Gemma4Model } from "../../src/model/gemma4";
import { generate } from "../../src/generate";
import { saveKvCache, loadKvCache } from "../../src/kv-store";
import * as ops from "../../src/mlx/ops";

const CACHE_FILE = `${process.env.HOME}/.cache/mlx-bun/cold-start-demo.mlxkv`;

const t0 = performance.now();
const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = createModel(weights, config) as Gemma4Model; // production dispatch (bit-parity path)
const tModel = performance.now();

const golden = (await goldenAt("parity.json").json()) as {
  prompt_ids: number[];
  greedy_ids: number[];
};

if (!(await Bun.file(CACHE_FILE).exists())) {
  console.log("preparing cache file (one-time)...");
  const caches = model.makeCache();
  const ids = ops.fromInt32(golden.prompt_ids, [1, golden.prompt_ids.length]);
  const h = model.forwardHidden(ids, caches);
  ops.evalAll(caches.flatMap((c) => c.state()));
  h.dispose();
  ids.dispose();
  saveKvCache(CACHE_FILE, golden.prompt_ids, caches);
  for (const c of caches) c.dispose();
  console.log("done — rerun for the cold measurement");
  process.exit(0);
}

const loaded = loadKvCache(CACHE_FILE, model);
const tKv = performance.now();

const prompt = [...golden.prompt_ids, golden.greedy_ids[0]!];
const gen = generate(model, prompt, {
  maxTokens: 4, temperature: 0, cache: loaded.caches,
});
let tFirst = 0;
for await (const t of gen) {
  if (!tFirst) tFirst = performance.now();
}

console.log(`model open:      ${(tModel - t0).toFixed(0)} ms`);
console.log(`kv-cache load:   ${(tKv - tModel).toFixed(0)} ms`);
console.log(`first token:     ${(tFirst - tKv).toFixed(0)} ms`);
console.log(`TOTAL cold start → first token: ${(tFirst - t0).toFixed(0)} ms ` +
  `(criterion: < 1000 ms) → ${tFirst - t0 < 1000 ? "PASS" : "FAIL"}`);
process.exit(tFirst - t0 < 1000 ? 0 : 1);
