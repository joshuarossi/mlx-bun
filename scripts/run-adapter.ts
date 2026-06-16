// Run a trained LoRA adapter: load the base model, hot-swap-mount the adapter,
// and greedily generate from a prompt. Same mount path the server uses
// (AdapterManager.mount + loraState.active).
//
//   ADAPTER=~/.cache/mlx-bun-finetunes/minicpm5-chunk-segmented \
//   PROMPT="Split this into chunks: ..." \
//   bun scripts/run-adapter.ts
//
//   # baseline (no adapter) — omit ADAPTER:
//   PROMPT="hello" bun scripts/run-adapter.ts
//
// MODEL defaults to MiniCPM5-1B-OptiQ-4bit; override with MODEL=<dir>.

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
import { generate } from "../src/generate";

const HOME = process.env.HOME!;
function defaultModel(): string {
  const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
  return `${base}/${readdirSync(base)[0]}`;
}
const MODEL = process.env.MODEL ?? defaultModel();
const ADAPTER = process.env.ADAPTER; // omit for the base model
const PROMPT = process.env.PROMPT ?? "Hello! In one sentence, who are you?";
const SYSTEM = process.env.SYSTEM; // optional system prompt
const MAXTOK = Number(process.env.MAXTOK ?? 256);
const TEMP = Number(process.env.TEMP ?? 0); // 0 = greedy

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

if (ADAPTER) {
  const { AdapterManager } = await import("../src/lora");
  const mgr = new AdapterManager(model);
  const info = await mgr.mount("run", ADAPTER);
  model.loraState.active = ["run"]; // activate it for generation
  console.error(`# mounted adapter ${ADAPTER} (${info.mountedLayers} layers)`);
} else {
  console.error(`# base model (no adapter)`);
}

const messages = [
  ...(SYSTEM ? [{ role: "system", content: SYSTEM }] : []),
  { role: "user", content: PROMPT },
];
const text = tmpl.render(messages as never, { addGenerationPrompt: true });
const ids = tok.encode(text);
console.error(`# model=${MODEL.split("/").slice(-3, -2)} prompt_tokens=${ids.length} maxTokens=${MAXTOK} temp=${TEMP}\n`);

const out: number[] = [];
for await (const { token } of generate(model, ids, { maxTokens: MAXTOK, temperature: TEMP })) out.push(token);
process.stdout.write(tok.decode(out, true) + "\n");

weights.dispose();
