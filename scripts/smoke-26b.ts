// 26B-A4B MoE bring-up smoke: load, single forward, short greedy decode.
//   bun scripts/smoke-26b.ts [--steps N]

import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { Gemma4Model, argmaxLastPosition } from "../src/model/gemma4";
import { loadTokenizer } from "../src/tokenizer";
import { peakMemory } from "../src/mlx/ffi";

const SNAP =
  `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-26B-A4B-it-OptiQ-4bit/snapshots/dbfd2a779b038b267bb20ff95dad717f42e4de16`;

const stepsArg = process.argv.indexOf("--steps");
const maxSteps = stepsArg > -1 ? Number(process.argv[stepsArg + 1]) : 24;

const t0 = performance.now();
const config = await loadModelConfig(SNAP);
const weights = await Weights.open(SNAP);
const model = new Gemma4Model(weights, config);
console.log(`model constructed in ${(performance.now() - t0).toFixed(0)} ms`);

const tok = await loadTokenizer(SNAP);
const prompt = "<start_of_turn>user\nName the four largest moons of Jupiter.<end_of_turn>\n<start_of_turn>model\n";
const ids = tok.encode(prompt);
console.log(`prompt ids (${ids.length}):`, ids.join(" "));

const cache = model.makeCache();
let tokens = ids;
const out: number[] = [];
const tGen = performance.now();
let tFirst = 0;
for (let step = 0; step < maxSteps; step++) {
  const logits = model.forward(tokens, cache);
  const next = argmaxLastPosition(logits);
  logits.dispose();
  if (step === 0) tFirst = performance.now();
  out.push(next);
  if (config.eosTokenIds.includes(next)) break;
  tokens = [next];
}
const tEnd = performance.now();
console.log(`greedy ids: ${out.join(" ")}`);
console.log(`text: ${JSON.stringify(tok.decode(out))}`);
console.log(
  `prefill+step0 ${(tFirst - tGen).toFixed(0)} ms; ` +
  `decode ${(((out.length - 1) * 1000) / (tEnd - tFirst)).toFixed(1)} tok/s ` +
  `(${out.length - 1} steps); peak mem ${(peakMemory() / 2 ** 30).toFixed(2)} GB`,
);
for (const c of cache) c.dispose();
