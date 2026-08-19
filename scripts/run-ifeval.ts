// Run IFEval before/after an ORPO adapter on Gemma e4b (or any model). Generates
// a response per IFEval prompt and scores it with the judge-free verifiable
// canonical checks shared with scripts/eval.ts. Run once WITHOUT --adapter
// (the base model) and once WITH it; compare strict/loose prompt and
// instruction-level accuracy.
//
//   MODEL=/path/to/e4b bun scripts/run-ifeval.ts <ifeval.jsonl> [--adapter <dir>] [--limit N] [--max-new 512]
//
// <ifeval.jsonl> = the IFEval prompt set (google/IFEval input_data.jsonl, fields:
// prompt, instruction_id_list, kwargs). Unknown instruction IDs follow the
// canonical OptiQ prompt contract (they do not fail a prompt), are excluded
// from instruction accuracy, and are reported explicitly as coverage.
// This GENERATES (hundreds of completions); run it yourself, not from a busy box.

import { existsSync } from "node:fs";
import { aggregate, SUPPORTED_INSTRUCTIONS, type IFEvalInstance } from "../src/eval/ifeval";

const args = process.argv.slice(2);
// Flag parsing that FAILS on a missing/invalid value rather than silently changing the
// run mode (e.g. `--adapter` with no path → silently runs the base model; `--limit` with
// no number → NaN → empty run).
const flagStr = (name: string): string | undefined => {
  const i = args.indexOf(name);
  if (i < 0) return undefined;
  const v = args[i + 1];
  if (v === undefined || v.startsWith("--")) { console.error(`${name} requires a value`); process.exit(1); }
  return v;
};
const flagNum = (name: string, def: number): number => {
  const v = flagStr(name);
  if (v === undefined) return def;
  const n = Number(v);
  if (!Number.isFinite(n)) { console.error(`${name} must be a number, got "${v}"`); process.exit(1); }
  return n;
};
const dataPath = args.find((a) => !a.startsWith("--"));
const adapterDir = flagStr("--adapter");
const limit = flagNum("--limit", Infinity);
const maxNew = flagNum("--max-new", 512);
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

// Production generation path (src/generate) — the model-level .generate()
// probe helper leaks per-step arrays and blows Metal's resident-buffer
// limit (499k) across many long generations (2026-08-19 ifeval@qwen3.8).
const { generate: produce } = await import("../src/generate");
const pairs: Array<{ instance: IFEvalInstance; response: string }> = [];
// pause/resume: responses persisted per item, fingerprinted to the artifact.
const { statSync: st, readFileSync: rf, appendFileSync: af, mkdirSync: mk } = await import("node:fs");
const shards = (await import("node:fs")).readdirSync(MODEL).filter(f => f.startsWith("model") && f.endsWith(".safetensors")).sort();
const fp = shards.length ? `${shards.length}-${st(`${MODEL}/${shards[0]}`).size}` : "none";
const progPath = `runs/tq-qwen/progress-ifeval-${MODEL.replace(/[\/.]/g, "_").slice(-80)}.jsonl`;
const doneMap = new Map<number, string>();
try {
  for (const line of rf(progPath, "utf8").split("\n")) {
    if (!line) continue;
    const r = JSON.parse(line);
    if (r.fp === fp) doneMap.set(r.i, r.response);
  }
} catch {}
mk("runs/tq-qwen", { recursive: true });
const t0 = Date.now();
for (let i = 0; i < limited.length; i++) {
  const inst = limited[i]!;
  const cached = doneMap.get(i);
  if (cached !== undefined) { pairs.push({ instance: inst, response: cached }); continue; }
  // Thinking OFF (IFEval convention scores the ANSWER against format
  // constraints; a <think> trace fails word-count/punctuation rules
  // wholesale — 2026-08-19: thinking-on scored 47.5% strict vs ~expected
  // high-70s). Belt-and-braces: also strip any think block from the text.
  const prompt = tmpl.render([{ role: "user", content: inst.prompt }],
    { addGenerationPrompt: true, enableThinking: false });
  const ids = tok.encode(prompt);
  const outIds: number[] = [];
  for await (const t of produce(model, ids, { maxTokens: maxNew, temperature: 0 })) outIds.push(t.token);
  let response = tok.decode(outIds, true);
  const thinkEnd = response.lastIndexOf("</think>");
  if (thinkEnd !== -1) response = response.slice(thinkEnd + "</think>".length).trimStart();
  pairs.push({ instance: inst, response });
  af(progPath, JSON.stringify({ i, fp, response }) + "\n");
  if ((i + 1) % 25 === 0) console.error(`  ${i + 1}/${limited.length} (${((Date.now() - t0) / (i + 1)).toFixed(0)} ms/prompt)`);
}

const rep = aggregate(pairs);
console.log(`\n=== IFEval ${adapterDir ? "WITH adapter" : "BASE"} ===`);
console.log(`strict prompt accuracy:      ${(rep.strictAcc * 100).toFixed(1)}%`);
console.log(`loose prompt accuracy:       ${(rep.looseAcc * 100).toFixed(1)}%`);
console.log(`strict instruction accuracy: ${(rep.strictInstructionAcc * 100).toFixed(1)}%`);
console.log(`loose instruction accuracy:  ${(rep.looseInstructionAcc * 100).toFixed(1)}%`);
console.log(
  `coverage: ${rep.coverage.fullySupportedPrompts}/${rep.nTotal} prompts, ` +
    `${rep.coverage.supportedInstructions}/${rep.coverage.totalInstructions} instructions`,
);
const unhandled = Object.entries(rep.coverage.unhandledInstructionCounts);
if (unhandled.length)
  console.log(
    "unhandled instruction IDs: " +
      unhandled.map(([id, count]) => `${id}(${count})`).join(", "),
  );
weights.dispose();
