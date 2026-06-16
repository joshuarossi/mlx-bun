// Filter the lucien chunk SFT data to examples whose rendered length (with the
// target model's chat template) fits within a token budget, so every training
// iter has a real (response-preserving) example — the trainer front-truncates,
// which would otherwise silently drop the assistant JSON on long examples.
//
//   MAXTOK=4000 bun scripts/chunk-filter.ts   # -> $OUT/{train,valid}.jsonl

import { mkdirSync, readFileSync, writeFileSync, readdirSync } from "node:fs";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const SRC = "/Users/joshrossi/Code/lucien/benchmark/finetune/chunk";
const MAXTOK = Number(process.env.MAXTOK ?? 4000);
const OUT = process.env.OUT ?? `${HOME}/.cache/mlx-bun-finetunes/chunk-data-le${MAXTOK}`;

mkdirSync(OUT, { recursive: true });
const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

for (const split of ["train", "valid"]) {
  const lines = readFileSync(`${SRC}/${split}.jsonl`, "utf8").split("\n").map((l) => l.trim()).filter(Boolean);
  const kept: string[] = [];
  for (const line of lines) {
    const rec = JSON.parse(line) as { messages: { role: string; content: string }[] };
    const rendered = tmpl.render(rec.messages as any, { addGenerationPrompt: false });
    const n = tok.encode(rendered).length;
    if (n <= MAXTOK) kept.push(line);
  }
  writeFileSync(`${OUT}/${split}.jsonl`, kept.join("\n") + "\n");
  console.log(`${split}: kept ${kept.length}/${lines.length}  (<=${MAXTOK} tok)`);
}
console.log(`### filtered data -> ${OUT}`);
