// Spec-decode benchmark: acceptance + realized tok/s across γ on
// agent-style prompts, recorded in the eval DB with commit.
//
//   bun scripts/spec-bench.ts [id]      # id ∈ {e4b, 12B, 26B}; default e4b
//
// ONE target/drafter pair per process (memory-safe: 12B+drafter ≈ 8 GB,
// 26B ≈ 17 GB — never co-resident). To sweep, run once per id.
//
// The economics question (PLAN.md Phase 6): the e4b drafter was a NET
// LOSS at every γ because e4b decode (~54 tok/s) is already too fast for
// a ~23%-acceptance drafter to beat. The drafter's per-step cost is
// ~fixed; the value of each skipped target-forward grows as the target
// slows. 12B (~25 tok/s) and 26B-MoE are the untested slower-target
// regime where the SAME acceptance can flip to a net win. This bench is
// how we find out — it prints the speedup vs the per-model non-spec
// baseline (the only valid denominator; never compare across models).

import { existsSync, readdirSync } from "node:fs";
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

const HUB = `${process.env.HOME}/.cache/huggingface/hub`;

interface Pair {
  id: string;
  target: string; // mlx-community repo name (OptiQ-4bit target)
  drafter: string; // mlx-community repo name (-assistant-bf16 drafter)
}

// Drafters are TARGET-BONDED: each artifact's pre/post projections are
// sized to one backbone_hidden_size (e4b 2560, 12B 3840, 26B 2816), so a
// drafter only pairs with its own target. The port itself is generic over
// that size — no per-pair code, just the matching artifact.
const PAIRS: Pair[] = [
  { id: "e4b", target: "gemma-4-e4b-it-OptiQ-4bit", drafter: "gemma-4-e4b-it-assistant-bf16" },
  { id: "12B", target: "gemma-4-12B-it-OptiQ-4bit", drafter: "gemma-4-12B-it-assistant-bf16" },
  { id: "26B", target: "gemma-4-26B-A4B-it-OptiQ-4bit", drafter: "gemma-4-26B-A4B-it-assistant-bf16" },
];

function snap(repo: string): string | null {
  const base = `${HUB}/models--mlx-community--${repo}/snapshots`;
  if (!existsSync(base)) return null;
  const dirs = readdirSync(base);
  return dirs.length ? `${base}/${dirs[0]}` : null;
}

// agent-transcript-style workloads (tool plans, code, structured output)
const PROMPTS = [
  "List the steps to find all TODO comments in a git repo and summarize them in a table.",
  "Write a TypeScript function that parses a CSV line handling quoted fields, with comments.",
  "Explain what `git rebase -i HEAD~3` does, step by step, briefly.",
  "Produce JSON describing three files in a typical node project: name, purpose, typical size.",
];
const MAX_TOKENS = 96;

const id = process.argv[2] ?? "e4b";
const pair = PAIRS.find((p) => p.id === id);
if (!pair) {
  console.error(`unknown id "${id}" — choose one of: ${PAIRS.map((p) => p.id).join(", ")}`);
  process.exit(2);
}

const targetDir = snap(pair.target);
const drafterDir = snap(pair.drafter);
if (!targetDir || !drafterDir) {
  const missing = [!targetDir && pair.target, !drafterDir && pair.drafter].filter(Boolean);
  console.error(
    `[${pair.id}] not downloaded — missing: ${missing.join(", ")}\n` +
      `download with: hf download mlx-community/${(!drafterDir ? pair.drafter : pair.target)}`,
  );
  process.exit(3);
}

console.log(`[${pair.id}] target=${pair.target} drafter=${pair.drafter}`);

const config = await loadModelConfig(targetDir);
const model = createModel(await Weights.open(targetDir), config) as Gemma4Model; // production dispatch (bit-parity path)
const drafter = await GemmaAssistantDrafter.load(drafterDir);
const tok = await loadTokenizer(targetDir);
const template = await ChatTemplate.load(targetDir);
const db = new EvalDB();
const commit = gitCommit();

const ids = PROMPTS.map((p) => {
  const i = tok.encode(template.render([{ role: "user", content: p }]));
  return i[0] === i[1] && i[0] === tok.bosTokenId ? i.slice(1) : i;
});

// non-spec baseline (the ONLY valid denominator for this pair's speedups)
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
  console.log(`[${pair.id}] non-spec baseline: ${baseTps.toFixed(1)} tok/s`);
  db.record({
    modelPath: targetDir, commitSha: commit, promptTokens: 0, generatedTokens: toks,
    prefillTps: 0, decodeTps: baseTps, peakBytes: peakMemory(),
    notes: `spec-bench[${pair.id}] baseline (non-spec)`,
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
    `[${pair.id}] γ=${gamma}: ${tps.toFixed(1)} tok/s (${(tps / baseTps).toFixed(2)}x base), ` +
    `acceptance ${(acc * 100).toFixed(0)}%`,
  );
  db.record({
    modelPath: targetDir, commitSha: commit, promptTokens: 0, generatedTokens: emitted,
    prefillTps: 0, decodeTps: tps, peakBytes: peakMemory(),
    notes: `spec-bench[${pair.id}] gamma=${gamma} acceptance=${(acc * 100).toFixed(1)}%`,
  });
}
console.log(`[${pair.id}] peak: ${(peakMemory() / 1e9).toFixed(2)} GB`);
