// GSM8K — grade-school math accuracy. Port of optiq/eval/gsm8k.py:
// 3-shot CoT, greedy decode, extract the numeric answer, compare.

import { generateText, loadJsonl, sampleIndices, type TaskModel } from "../runner";

// 3-shot exemplars (verbatim from gsm8k.py).
const FEW_SHOT: { question: string; answer: string }[] = [
  {
    question: "There are 15 trees in the grove. Grove workers will plant trees in the grove today. After they are done, there will be 21 trees. How many trees did the grove workers plant today?",
    answer: "There are 15 trees originally. Then there were 21 trees after some more were planted. So there must have been 21 - 15 = 6 trees planted.\n#### 6",
  },
  {
    question: "If there are 3 cars in the parking lot and 2 more cars arrive, how many cars are in the parking lot?",
    answer: "There are originally 3 cars. 2 more cars arrive. 3 + 2 = 5.\n#### 5",
  },
  {
    question: "Leah had 32 chocolates and her sister had 42. If they ate 35, how many pieces do they have left in total?",
    answer: "Originally, Leah had 32 chocolates. Her sister had 42. So in total they had 32 + 42 = 74. After eating 35, they had 74 - 35 = 39.\n#### 39",
  },
];

interface Gsm8kRow { question: string; answer: string }

export interface Gsm8kResult {
  nCorrect: number;
  nTotal: number;
  accuracy: number; // 0..1
}

function buildPrompt(question: string, nShots: number): string {
  let p = "";
  for (const ex of FEW_SHOT.slice(0, nShots)) p += `Q: ${ex.question}\nA: ${ex.answer}\n\n`;
  return p + `Q: ${question}\nA:`;
}

const NUM = String.raw`-?[\d,]+\.?\d*`;

/** Model output → numeric answer string (####, then \boxed{}, then last number). */
export function extractAnswer(textIn: string): string | null {
  let text = textIn;
  // Match Python's `split("</think>", 1)[1]`: everything after the FIRST tag.
  if (text.includes("</think>")) text = text.split("</think>").slice(1).join("</think>");

  const hash = text.match(new RegExp(String.raw`####\s*(${NUM})`));
  if (hash) return hash[1]!.replace(/,/g, "").trim();

  const boxed = text.match(new RegExp(String.raw`\\boxed\{\s*(${NUM})\s*\}`));
  if (boxed) return boxed[1]!.replace(/,/g, "").trim();

  const nums = text.match(new RegExp(NUM, "g"));
  return nums && nums.length ? nums[nums.length - 1]!.replace(/,/g, "").trim() : null;
}

function groundTruth(answer: string): string {
  const m = answer.match(new RegExp(String.raw`####\s*(${NUM})`));
  return m ? m[1]!.replace(/,/g, "").trim() : "";
}

function toNum(s: string | null): number | null {
  if (!s) return null;
  const v = Number(s.replace(/,/g, ""));
  return Number.isFinite(v) ? v : null;
}

export async function evaluateGsm8k(
  tm: TaskModel,
  opts: { nSamples?: number; nShots?: number; maxTokens?: number; seed?: number; frozen?: boolean } = {},
): Promise<Gsm8kResult> {
  const nShots = opts.nShots ?? 3;
  const maxTokens = opts.maxTokens ?? 256;

  // Optiq-parity mode (DEFAULT): score optiq's EXACT 1000 questions (the same data
  // his published GSM8K used) but through OUR OWN pipeline — our few-shot builder,
  // our chat template, our scorer. If our number reproduces his, our runtime is
  // faithful. MLX_BUN_GSM8K_FROZEN=0 falls back to our own sampling of the full set.
  const useFrozen = opts.frozen ?? (process.env.MLX_BUN_GSM8K_FROZEN !== "0");
  let rows: Gsm8kRow[];
  if (useFrozen) {
    rows = loadJsonl<Gsm8kRow>("gsm8k_optiq_frozen"); // optiq's exact draw; we use {question, answer}
  } else {
    const all = loadJsonl<Gsm8kRow>("gsm8k");
    rows = sampleIndices(all.length, opts.nSamples ?? 1000, opts.seed ?? 42).map((i) => all[i]!);
  }

  let nCorrect = 0;
  for (let k = 0; k < rows.length; k++) {
    const item = rows[k]!;
    const gt = toNum(groundTruth(item.answer));
    const out = await generateText(tm, buildPrompt(item.question, nShots), { maxTokens, useChat: true });
    const pred = toNum(extractAnswer(out));
    if (gt !== null && pred !== null && Math.abs(gt - pred) < 1e-3) nCorrect++;
    if ((k + 1) % 10 === 0 || k + 1 === rows.length)
      process.stderr.write(`\r  gsm8k ${k + 1}/${rows.length}  acc=${(nCorrect / (k + 1) * 100).toFixed(1)}%`);
  }
  process.stderr.write("\n");
  return { nCorrect, nTotal: rows.length, accuracy: rows.length ? nCorrect / rows.length : 0 };
}
