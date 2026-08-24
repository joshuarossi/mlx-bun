// Paired decode-throughput probe for the frontier matrix: load one artifact
// through OUR engine, run R greedy generations, report median decode tok/s
// (wall-clock after the first token — the honest number, not SSE-burst) and
// TTFT. Machine-state labeling is the caller's job (quiet-box doctrine:
// numbers from a loaded machine are garbage — run arms back-to-back in one
// sitting and label the host).
//
//   bun scripts/turboquant/tq-tps.ts <model-dir> [maxTokens=256] [repeats=3]

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import { generate } from "../../src/generate";

const dir = process.argv[2]!;
const maxTokens = Number(process.argv[3] ?? 256);
const repeats = Number(process.argv[4] ?? 3);

const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

const rendered = template.render(
  [{ role: "user", content: "Write a detailed, multi-paragraph explanation of how tides work." }],
  { enableThinking: false },
);
const ids = tok.encode(rendered);

const decode: number[] = [];
const ttft: number[] = [];
for (let r = 0; r < repeats; r++) {
  const t0 = performance.now();
  let first = 0;
  let n = 0;
  for await (const t of generate(model, ids, { maxTokens, temperature: 0 })) {
    if (n === 0) first = performance.now();
    n++;
  }
  const end = performance.now();
  ttft.push(first - t0);
  decode.push(((n - 1) / Math.max(end - first, 1e-6)) * 1000);
}
const med = (a: number[]) => [...a].sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
const spread = (a: number[]) => ((Math.max(...a) - Math.min(...a)) / med(a) * 100).toFixed(1);
console.log(
  `TPS ${dir}: decode ${med(decode).toFixed(2)} tok/s (spread ${spread(decode)}%) · ` +
  `TTFT ${med(ttft).toFixed(0)} ms · prompt ${ids.length} tok · gen ${maxTokens} · ${repeats} reps`,
);
