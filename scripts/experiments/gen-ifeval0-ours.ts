import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText } from "../../src/eval/runner";
const rows = readFileSync(`${process.env.HOME}/.cache/mlx-bun/eval-data/ifeval_optiq_frozen.jsonl`,"utf8").trim().split("\n").map((l)=>JSON.parse(l));
const tm = await loadTaskModel("MiniCPM5");
const resp = await generateText(tm, rows[0].prompt, { maxTokens: 512, useChat: true });
writeFileSync("/tmp/ifeval0-ours.txt", resp);
console.log(`OURS len=${resp.length} tail=${JSON.stringify(resp.slice(-50))}`);
