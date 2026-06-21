import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel } from "../../src/eval/runner";
const FEW = [
  { q: "There are 15 trees in the grove. Grove workers will plant trees in the grove today. After they are done, there will be 21 trees. How many trees did the grove workers plant today?", a: "There are 15 trees originally. Then there were 21 trees after some more were planted. So there must have been 21 - 15 = 6 trees planted.\n#### 6" },
  { q: "If there are 3 cars in the parking lot and 2 more cars arrive, how many cars are in the parking lot?", a: "There are originally 3 cars. 2 more cars arrive. 3 + 2 = 5.\n#### 5" },
  { q: "Leah had 32 chocolates and her sister had 42. If they ate 35, how many pieces do they have left in total?", a: "Originally, Leah had 32 chocolates. Her sister had 42. So in total they had 32 + 42 = 74. After eating 35, they had 74 - 35 = 39.\n#### 39" },
];
const buildPrompt = (q: string) => FEW.map((e) => `Q: ${e.q}\nA: ${e.a}\n\n`).join("") + `Q: ${q}\nA:`;
const rows = readFileSync(`${process.env.HOME}/.cache/mlx-bun/eval-data/gsm8k_optiq_frozen.jsonl`, "utf8").trim().split("\n").map((l) => JSON.parse(l));
const tm = await loadTaskModel("MiniCPM5");
const out = rows.map((r: any) => {
  const text = tm.template!.render([{ role: "user", content: buildPrompt(r.question) }], { addGenerationPrompt: true, enableThinking: false });
  return tm.tokenizer.encode(text, false); // addSpecialTokens=false (the eval path)
});
writeFileSync("/tmp/gsm8k-our-promptids.json", JSON.stringify(out));
console.log(`dumped ${out.length} prompt-id arrays`);
