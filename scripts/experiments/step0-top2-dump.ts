// Per-step greedy transcript with top-2 logprobs — the mlx-bun side of the
// step-0 prefill-convention A/B (parity-12b-completion, 2026-07-07). Pairs
// with scratchpad oracle-12b-top2.py (mlx-lm stream_generate + top-2 dump).
//
//   bun scripts/experiments/step0-top2-dump.ts <model-path> [prompt] [maxTokens]
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { generate } from "../../src/generate";

const path = process.argv[2]!;
const promptText = process.argv[3] ?? "The first eight prime numbers are";
const maxTokens = Number(process.argv[4] ?? 64);

const config = await loadModelConfig(path);
const weights = await Weights.open(path);
const model = createModel(weights, config);
const tok = await loadTokenizer(path);

const promptIds = tok.encode(promptText);
console.log("PROMPT_IDS", JSON.stringify(promptIds));

const steps: { token: number; top: { id: number; logprob: number }[] }[] = [];
const gen = generate(model, promptIds, {
  maxTokens,
  temperature: 0,
  topLogprobs: 2,
});
for await (const t of gen) {
  steps.push({ token: t.token, top: t.logprobs?.top ?? [] });
}
console.log("TEXT", JSON.stringify(tok.decode(steps.map((s) => s.token))));
for (let i = 0; i < steps.length; i++) {
  const s = steps[i]!;
  console.log(
    "STEP", i, s.token,
    s.top.map((p) => `${p.id}:${p.logprob}`).join(" "),
  );
}
