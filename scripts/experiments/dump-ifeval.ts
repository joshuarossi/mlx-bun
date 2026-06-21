// Generate our IFEval responses (bit-exact = his) + our strict verdict, so we can
// run the SAME responses through optiq's verifier and isolate verifier-logic drift.
import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText } from "../../src/eval/runner";
import { verifyResponse, stripThinking } from "../../src/eval/tasks/ifeval";

const rows = readFileSync(`${process.env.HOME}/.cache/mlx-bun/eval-data/ifeval_optiq_frozen.jsonl`, "utf8")
  .trim().split("\n").map((l) => JSON.parse(l) as { key: number; prompt: string; instruction_id_list: string[]; kwargs: Record<string, unknown>[] });

const tm = await loadTaskModel("MiniCPM5");
const out: unknown[] = [];
let ourPass = 0;
for (let i = 0; i < rows.length; i++) {
  const r = rows[i]!;
  const raw = await generateText(tm, r.prompt, { maxTokens: 512, useChat: true });
  const response = stripThinking(raw);
  const ids = r.instruction_id_list ?? [];
  const kw = r.kwargs ?? ids.map(() => ({}));
  const { pass } = verifyResponse(response, ids, kw);
  if (pass) ourPass++;
  out.push({ key: r.key, instruction_id_list: ids, kwargs: kw, response, ourStrict: pass });
  if ((i + 1) % 25 === 0 || i + 1 === rows.length) process.stderr.write(`\r  ifeval ${i + 1}/${rows.length} ourStrict=${(ourPass / (i + 1) * 100).toFixed(1)}%`);
}
process.stderr.write("\n");
writeFileSync("/tmp/ifeval-ours.jsonl", out.map((o) => JSON.stringify(o)).join("\n"));
console.log(`wrote ${out.length} -> /tmp/ifeval-ours.jsonl  (our strict = ${(ourPass / out.length * 100).toFixed(1)}%)`);
