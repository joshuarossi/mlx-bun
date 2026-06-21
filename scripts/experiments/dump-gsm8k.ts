// Dump our (bit-exact = his) GSM8K responses + our verdict, so the same responses can
// be scored by HIS extractor in Python to isolate scoring-logic drift.
import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText } from "../../src/eval/runner";
import { extractAnswer } from "../../src/eval/tasks/gsm8k";

const FEW_SHOT = [
  { q: "There are 15 trees in the grove. Grove workers will plant trees in the grove today. After they are done, there will be 21 trees. How many trees did the grove workers plant today?", a: "There are 15 trees originally. Then there were 21 trees after some more were planted. So there must have been 21 - 15 = 6 trees planted.\n#### 6" },
  { q: "If there are 3 cars in the parking lot and 2 more cars arrive, how many cars are in the parking lot?", a: "There are originally 3 cars. 2 more cars arrive. 3 + 2 = 5.\n#### 5" },
  { q: "Leah had 32 chocolates and her sister had 42. If they ate 35, how many pieces do they have left in total?", a: "Originally, Leah had 32 chocolates. Her sister had 42. So in total they had 32 + 42 = 74. After eating 35, they had 74 - 35 = 39.\n#### 39" },
];
const buildPrompt = (q: string) => FEW_SHOT.map((e) => `Q: ${e.q}\nA: ${e.a}\n\n`).join("") + `Q: ${q}\nA:`;
const NUM = String.raw`-?[\d,]+\.?\d*`;
const groundTruth = (a: string) => (a.match(new RegExp(`####\\s*(${NUM})`))?.[1] ?? "").replace(/,/g, "").trim();
const toNum = (s: string | null) => { if (!s) return null; const v = Number(s.replace(/,/g, "")); return Number.isFinite(v) ? v : null; };

const rows = readFileSync(`${process.env.HOME}/.cache/mlx-bun/eval-data/gsm8k_optiq_frozen.jsonl`, "utf8")
  .trim().split("\n").map((l) => JSON.parse(l) as { question: string; answer: string });

const tm = await loadTaskModel("MiniCPM5");
const out: unknown[] = [];
let ourCorrect = 0;
for (let i = 0; i < rows.length; i++) {
  const r = rows[i]!;
  const resp = await generateText(tm, buildPrompt(r.question), { maxTokens: 256, useChat: true });
  const pred = toNum(extractAnswer(resp));
  const gt = toNum(groundTruth(r.answer));
  const correct = gt !== null && pred !== null && Math.abs(gt - pred) < 1e-3;
  if (correct) ourCorrect++;
  out.push({ question: r.question, answer: r.answer, response: resp, ourPred: pred, ourCorrect: correct });
  if ((i + 1) % 25 === 0 || i + 1 === rows.length) process.stderr.write(`\r  gsm8k ${i + 1}/${rows.length} ourCorrect=${ourCorrect}`);
}
process.stderr.write("\n");
writeFileSync("/tmp/gsm8k-ours.jsonl", out.map((o) => JSON.stringify(o)).join("\n"));
console.log(`wrote ${out.length} -> /tmp/gsm8k-ours.jsonl  (our correct=${ourCorrect})`);
