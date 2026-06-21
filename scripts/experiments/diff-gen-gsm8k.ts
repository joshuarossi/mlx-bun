// Run OUR generation on optiq's exact GSM8K questions through the EVAL path
// (buildPrompt + chat template — NOT raw, to avoid double-BOS) and compare our
// predictions to the per-item predictions optiq's eval prints.
import { readFileSync } from "node:fs";
import { loadTaskModel, generateText } from "../../src/eval/runner";
import { extractAnswer } from "../../src/eval/tasks/gsm8k";

// gsm8k.ts few-shot (verbatim) — reconstruct buildPrompt exactly.
const FEW_SHOT = [
  { q: "There are 15 trees in the grove. Grove workers will plant trees in the grove today. After they are done, there will be 21 trees. How many trees did the grove workers plant today?",
    a: "There are 15 trees originally. Then there were 21 trees after some more were planted. So there must have been 21 - 15 = 6 trees planted.\n#### 6" },
  { q: "If there are 3 cars in the parking lot and 2 more cars arrive, how many cars are in the parking lot?",
    a: "There are originally 3 cars. 2 more cars arrive. 3 + 2 = 5.\n#### 5" },
  { q: "Leah had 32 chocolates and her sister had 42. If they ate 35, how many pieces do they have left in total?",
    a: "Originally, Leah had 32 chocolates. Her sister had 42. So in total they had 32 + 42 = 74. After eating 35, they had 74 - 35 = 39.\n#### 39" },
];
const buildPrompt = (q: string) =>
  FEW_SHOT.map((e) => `Q: ${e.q}\nA: ${e.a}\n\n`).join("") + `Q: ${q}\nA:`;

const rows = readFileSync(`${process.env.HOME}/.cache/mlx-bun/eval-data/gsm8k_optiq_frozen.jsonl`, "utf8")
  .trim().split("\n").map((l) => JSON.parse(l) as { question: string; answer: string });

const HIS: Record<string, string> = {
  "Janet’s ducks": "5",
  "Every day, Wendi": "20",
  "Tom's ship can travel": "5",
  "Cecilia just bought": "5",
  "Josh decides to try flipping": "None",
  "James decides to run 3 sprints": "3",
};

const tm = await loadTaskModel("MiniCPM5");
const gt = (a: string) => (a.match(/####\s*(-?[\d,]+\.?\d*)/)?.[1] ?? "").replace(/,/g, "");

for (const [prefix, hisPred] of Object.entries(HIS)) {
  const row = rows.find((r) => r.question.startsWith(prefix));
  if (!row) { console.log(`  [not found] ${prefix}`); continue; }
  const out = await generateText(tm, buildPrompt(row.question), { maxTokens: 256, useChat: true });
  const ourPred = extractAnswer(out) ?? "None";
  const mark = ourPred === hisPred ? "✅ MATCH" : "❌ DIVERGE";
  console.log(`${mark}  "${prefix}"  GT=${gt(row.answer)}  his=${hisPred}  ours=${ourPred}`);
  if (ourPred !== hisPred) console.log(`     our out[:150]: ${JSON.stringify(out.slice(0, 150))}`);
}
