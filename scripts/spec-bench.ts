// Phase 6 spec-decode benchmark: acceptance + realized tok/s across γ on
// agent-style prompts, recorded in the eval DB with commit.
//   bun scripts/spec-bench.ts

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import type { Gemma4Model } from "../src/model/gemma4";
import { generate } from "../src/generate";
import { specGenerate } from "../src/spec/generate";
import { GemmaAssistantDrafter } from "../src/spec/drafter";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
import { EvalDB, gitCommit } from "../src/evaldb";
import { peakMemory } from "../src/mlx/ffi";

const E4B_BASE = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const DR_BASE = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-assistant-bf16/snapshots`;
const E4B = `${E4B_BASE}/${readdirSync(E4B_BASE)[0]}`;
const DR = `${DR_BASE}/${readdirSync(DR_BASE)[0]}`;

// agent-transcript-style workloads (tool plans, code, structured output)
const PROMPTS = [
  "List the steps to find all TODO comments in a git repo and summarize them in a table.",
  "Write a TypeScript function that parses a CSV line handling quoted fields, with comments.",
  "Explain what `git rebase -i HEAD~3` does, step by step, briefly.",
  "Produce JSON describing three files in a typical node project: name, purpose, typical size.",
];
const MAX_TOKENS = 96;

const config = await loadModelConfig(E4B);
const model = createModel(await Weights.open(E4B), config) as Gemma4Model; // production dispatch (bit-parity path)
const drafter = await GemmaAssistantDrafter.load(DR);
const tok = await loadTokenizer(E4B);
const template = await ChatTemplate.load(E4B);
const db = new EvalDB();
const commit = gitCommit();

const ids = PROMPTS.map((p) => {
  const i = tok.encode(template.render([{ role: "user", content: p }]));
  return i[0] === i[1] && i[0] === tok.bosTokenId ? i.slice(1) : i;
});

// non-spec baseline
let baseTps = 0;
{
  let toks = 0, ms = 0;
  for (const pid of ids) {
    const gen = generate(model, pid, { maxTokens: MAX_TOKENS, temperature: 0 });
    for await (const _ of gen) {}
    toks += gen.stats!.generatedTokens;
    ms += gen.stats!.decodeMs;
  }
  baseTps = (toks / ms) * 1000;
  console.log(`non-spec e4b baseline: ${baseTps.toFixed(1)} tok/s`);
  db.record({
    modelPath: E4B, commitSha: commit, promptTokens: 0, generatedTokens: toks,
    prefillTps: 0, decodeTps: baseTps, peakBytes: peakMemory(),
    notes: "spec-bench baseline (non-spec)",
  });
}

for (const gamma of [1, 2, 3, 4]) {
  let emitted = 0, drafted = 0, accepted = 0, ms = 0;
  for (const pid of ids) {
    const r = specGenerate(model, drafter, pid, { gamma, maxTokens: MAX_TOKENS });
    emitted += r.stats.emitted - 1; // decode-phase tokens
    drafted += r.stats.drafted;
    accepted += r.stats.accepted;
    ms += r.stats.decodeMs;
  }
  const tps = (emitted / ms) * 1000;
  const acc = accepted / drafted;
  console.log(
    `γ=${gamma}: ${tps.toFixed(1)} tok/s (${(tps / baseTps).toFixed(2)}x base), ` +
    `acceptance ${(acc * 100).toFixed(0)}%`,
  );
  db.record({
    modelPath: E4B, commitSha: commit, promptTokens: 0, generatedTokens: emitted,
    prefillTps: 0, decodeTps: tps, peakBytes: peakMemory(),
    notes: `spec-bench gamma=${gamma} acceptance=${(acc * 100).toFixed(1)}%`,
  });
}
console.log(`peak: ${(peakMemory() / 1e9).toFixed(2)} GB (multi-model fit predicted 7.91 GB)`);
