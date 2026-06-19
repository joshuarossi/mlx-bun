// Run IFEval before/after an ORPO adapter on Gemma e4b (or any model). Generates
// a response per IFEval prompt and scores it with the judge-free verifiable
// checks in src/eval/ifeval.ts. Run once WITHOUT --adapter (the base model) and
// once WITH it; compare prompt-level / instruction-level accuracy.
//
//   MODEL=/path/to/e4b bun scripts/run-ifeval.ts <ifeval.jsonl> [--adapter <dir>] [--limit N] [--max-new 512]
//
// <ifeval.jsonl> = the IFEval prompt set (google/IFEval input_data.jsonl, fields:
// prompt, instruction_id_list, kwargs). Only instructions in SUPPORTED_INSTRUCTIONS
// are scored (others fail closed) — coverage is reported so the number is honest.
// This GENERATES (hundreds of completions); run it yourself, not from a busy box.

import { existsSync } from "node:fs";
import { aggregate, SUPPORTED_INSTRUCTIONS, type IFEvalInstance } from "../src/eval/ifeval";

const args = process.argv.slice(2);
const dataPath = args.find((a) => !a.startsWith("--"));
const adapterDir = args[args.indexOf("--adapter") + 1] && args.includes("--adapter")
  ? args[args.indexOf("--adapter") + 1] : undefined;
const limit = args.includes("--limit") ? Number(args[args.indexOf("--limit") + 1]) : Infinity;
const maxNew = args.includes("--max-new") ? Number(args[args.indexOf("--max-new") + 1]) : 512;
const MODEL = process.env.MODEL ??
  `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;

if (!dataPath || !existsSync(dataPath)) { console.error("usage: bun scripts/run-ifeval.ts <ifeval.jsonl> [--adapter <dir>] [--limit N]"); process.exit(1); }
if (!existsSync(`${MODEL}/config.json`)) { console.error(`model not found: ${MODEL}`); process.exit(1); }

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");
const { ChatTemplate } = await import("../src/chat-template");

const text = await Bun.file(dataPath).text();
const instances: IFEvalInstance[] = [];
for (const line of text.split("\n")) {
  const t = line.trim();
  if (!t) continue;
  const r = JSON.parse(t) as Record<string, unknown>;
  instances.push({
    prompt: r.prompt as string,
    instruction_id_list: (r.instruction_id_list as string[]) ?? [],
    kwargs: (r.kwargs as Array<Record<string, unknown>>) ?? [],
  });
}
const limited = instances.slice(0, Number.isFinite(limit) ? limit : instances.length);
const coverage = limited.filter((i) => i.instruction_id_list.every((id) => SUPPORTED_INSTRUCTIONS.has(id))).length;
console.log(`IFEval: ${limited.length} prompts (${coverage} fully-supported by this scorer), model=${MODEL.split("/").pop()}, adapter=${adapterDir ?? "(base)"}`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

if (adapterDir) {
  const { AdapterManager } = await import("../src/lora");
  const mgr = new AdapterManager(model);
  await mgr.mount("orpo", adapterDir);
  model.loraState.active = ["orpo"];
}

const eos = tok.eosTokenId != null ? [tok.eosTokenId] : [];
const pairs: Array<{ instance: IFEvalInstance; response: string }> = [];
const t0 = Date.now();
for (let i = 0; i < limited.length; i++) {
  const inst = limited[i]!;
  const prompt = tmpl.render([{ role: "user", content: inst.prompt }], { addGenerationPrompt: true });
  const ids = tok.encode(prompt);
  const outIds = model.generate(ids, maxNew, eos);
  pairs.push({ instance: inst, response: tok.decode(outIds, true) });
  if ((i + 1) % 25 === 0) console.error(`  ${i + 1}/${limited.length} (${((Date.now() - t0) / (i + 1)).toFixed(0)} ms/prompt)`);
}

const rep = aggregate(pairs);
console.log(`\n=== IFEval ${adapterDir ? "WITH adapter" : "BASE"} ===`);
console.log(`prompt-level accuracy:      ${(rep.promptAccuracy * 100).toFixed(1)}%`);
console.log(`instruction-level accuracy: ${(rep.instructionAccuracy * 100).toFixed(1)}%`);
console.log(`(n=${rep.n})`);
weights.dispose();
