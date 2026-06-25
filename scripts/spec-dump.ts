// Dump mlx-bun specGenerate output token ids for GIVEN prompt ids, to
// cross-check against optiq (scripts/oracle-spec.py). The prompt ids come
// from the python side so both stacks run the identical prompt.
//   bun scripts/spec-dump.ts <id> <gamma> <maxtok> <prompt_ids_csv>
import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { Gemma4Model } from "../src/model/gemma4";
import { specGenerate } from "../src/spec/generate";
import { GemmaAssistantDrafter } from "../src/spec/drafter";

const HUB = `${process.env.HOME}/.cache/huggingface/hub`;
const PAIRS: Record<string, [string, string]> = {
  e4b: ["gemma-4-e4b-it-OptiQ-4bit", "gemma-4-e4b-it-assistant-bf16"],
  "12B": ["gemma-4-12B-it-OptiQ-4bit", "gemma-4-12B-it-assistant-bf16"],
  "26B": ["gemma-4-26B-A4B-it-OptiQ-4bit", "gemma-4-26B-A4B-it-assistant-bf16"],
};
const snap = (repo: string) => {
  const b = `${HUB}/models--mlx-community--${repo}/snapshots`;
  return `${b}/${readdirSync(b)[0]}`;
};

const id = process.argv[2] ?? "e4b";
const gamma = Number(process.argv[3] ?? 2);
const maxTokens = Number(process.argv[4] ?? 48);
const promptIds = (process.argv[5] ?? "").split(",").filter(Boolean).map(Number);
if (!promptIds.length) throw new Error("pass prompt ids csv (from oracle-spec.py PROMPT_IDS)");

const [t, d] = PAIRS[id]!;
const config = await loadModelConfig(snap(t));
const model = new Gemma4Model(await Weights.open(snap(t)), config);
const drafter = await GemmaAssistantDrafter.load(snap(d));

const r = specGenerate(model, drafter, promptIds, { gamma, maxTokens });
console.log("OUT_IDS:", r.tokens.join(","));
console.log("STATS:", JSON.stringify({
  accepted: r.stats.accepted, drafted: r.stats.drafted,
  acceptance: +(r.stats.acceptanceRate * 100).toFixed(1), targetCalls: r.stats.targetCalls,
}));
