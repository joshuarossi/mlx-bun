import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel } from "../../src/eval/runner";
import { generate } from "../../src/generate";
const promptIds: number[] = JSON.parse(readFileSync("/tmp/prompt_ids.json", "utf8"));
const tm = await loadTaskModel("MiniCPM5");
const gen = generate(tm.model, promptIds, { maxTokens: 8000, temperature: 0, eosTokenIds: [] });
const out: number[] = [];
for await (const { token } of gen) { out.push(token); if (out.length % 1000 === 0) process.stderr.write(`\r${out.length}/8000`); }
process.stderr.write("\n");
writeFileSync("/tmp/our_gen_ids.json", JSON.stringify(out));
console.log(`generate(): ${out.length} tokens first15=${JSON.stringify(out.slice(0, 15))}`);
