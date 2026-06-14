// MMLU 5-shot — multi-domain multiple-choice knowledge. Port of
// optiq/eval/mmlu.py: per-subject dev exemplars, A/B/C/D format, greedy
// decode, extract the predicted answer letter, compare to the gold index.
//
// The Python reference scores via first-letter logit argmax (no generation).
// The mlx-bun harness routes everything through generateText() (decoded
// completion). For an instruct model the faithful argmax-on-raw-text path
// underscores on a small noisy sample, so we drive the chat template: the
// 5-shot exemplars become the priming context and an explicit instruction
// asks for ONLY the single letter A/B/C/D. Extraction is robust to chatty
// formatting (</think> wrappers, "Answer: X", "(X)", "**X**", bare letter).
// Prompt format, header, exemplar selection, and gold mapping are verbatim.

import { generateText, loadJsonl, sampleIndices, type TaskModel } from "../runner";

interface MmluRow {
  question: string;
  subject: string;
  choices: string[];
  answer: number; // 0..3 → A/B/C/D
}

export interface MmluResult {
  nCorrect: number;
  nTotal: number;
  accuracy: number; // 0..1
}

const LETTERS = ["A", "B", "C", "D"] as const;

/** 'high_school_us_history' → 'high school us history'. */
function formatSubject(subject: string): string {
  return subject.replace(/_/g, " ");
}

/** Format one example; append the letter when `answerIdx` is given (demos). */
function formatExample(question: string, choices: string[], answerIdx?: number): string {
  let s = question.trim() + "\n";
  for (let i = 0; i < choices.length; i++) s += `${LETTERS[i]}. ${choices[i]}\n`;
  s += "Answer:";
  if (answerIdx !== undefined) s += ` ${LETTERS[answerIdx]}\n`;
  return s;
}

/** 5-shot prompt: subject header → n demos → open test question.
 *
 * Built for the chat template: the header + worked exemplars prime the model,
 * and a trailing instruction pins the output to a single bare letter. The
 * exemplars still close their "Answer: X" line so the model sees the expected
 * shape, and the final question is left open ("Answer:") for the model. */
function buildPrompt(row: MmluRow, devExamples: MmluRow[], nShots: number): string {
  let prompt = `The following are multiple choice questions (with answers) about ${formatSubject(row.subject)}.\n\n`;
  for (const ex of devExamples.slice(0, nShots)) {
    prompt += formatExample(ex.question, ex.choices, ex.answer);
    prompt += "\n";
  }
  prompt += formatExample(row.question, row.choices);
  prompt += "\n\nRespond with ONLY the single letter (A, B, C, or D) of the correct answer. Do not explain.";
  return prompt;
}

/** Model output → predicted letter index 0..3, else null. Robust to chatty
 * instruct formatting: strips a leading <think>…</think> block, then prefers
 * an explicit "Answer: X" / "(X)" / "**X**" marker, falling back to the first
 * standalone A/B/C/D token (one not glued inside a longer word). */
export function extractAnswer(textIn: string): number | null {
  let text = textIn;
  if (text.includes("</think>")) text = text.split("</think>").pop() ?? text;

  const toIdx = (ch: string): number => LETTERS.indexOf(ch.toUpperCase() as (typeof LETTERS)[number]);

  // Explicit answer markers, in priority order.
  const markers = [
    /(?:answer|correct answer|the answer is)\s*(?:is|:)?\s*\(?\*{0,2}([A-Da-d])\*{0,2}\)?/i,
    /\*\*\s*([A-Da-d])\s*\*\*/, // **X**
    /\(\s*([A-Da-d])\s*\)/, // (X)
  ];
  for (const re of markers) {
    const m = text.match(re);
    if (m) return toIdx(m[1]!);
  }

  // Fallback: first standalone letter (word-boundary, not embedded in a word).
  const standalone = text.match(/\b([A-D])\b/);
  if (standalone) return toIdx(standalone[1]!);

  return null;
}

export async function evaluateMmlu(
  tm: TaskModel,
  opts: { nSamples?: number; nShots?: number; maxTokens?: number; seed?: number } = {},
): Promise<MmluResult> {
  const nShots = opts.nShots ?? 5;
  const maxTokens = opts.maxTokens ?? 16;
  const seed = opts.seed ?? 42;

  const testRows = loadJsonl<MmluRow>("mmlu_test");
  const devRows = loadJsonl<MmluRow>("mmlu_dev");

  // Per-subject dev exemplars for prompt construction.
  const devBySubject = new Map<string, MmluRow[]>();
  for (const ex of devRows) {
    const list = devBySubject.get(ex.subject) ?? [];
    list.push(ex);
    devBySubject.set(ex.subject, list);
  }

  // Stratified sample: roughly equal questions per subject (matches mmlu.py),
  // deterministic via the shared seeded subsampler.
  const testBySubject = new Map<string, number[]>();
  for (let i = 0; i < testRows.length; i++) {
    const subj = testRows[i]!.subject;
    const list = testBySubject.get(subj) ?? [];
    list.push(i);
    testBySubject.set(subj, list);
  }
  const subjects = [...testBySubject.keys()].sort();
  const nSamples = opts.nSamples ?? 1000;
  const perSubject = Math.max(1, Math.floor(nSamples / subjects.length));

  let sampled: number[] = [];
  for (const subj of subjects) {
    const pool = testBySubject.get(subj)!;
    const take = Math.min(perSubject, pool.length);
    for (const j of sampleIndices(pool.length, take, seed)) sampled.push(pool[j]!);
  }
  if (sampled.length > nSamples) {
    const keep = sampleIndices(sampled.length, nSamples, seed);
    sampled = keep.map((k) => sampled[k]!);
  }

  let nCorrect = 0;
  for (let k = 0; k < sampled.length; k++) {
    const item = testRows[sampled[k]!]!;
    const devEx = devBySubject.get(item.subject) ?? [];
    const out = await generateText(tm, buildPrompt(item, devEx, nShots), { maxTokens, useChat: true });
    const pred = extractAnswer(out);
    if (pred !== null && pred === item.answer) nCorrect++;
    if ((k + 1) % 10 === 0 || k + 1 === sampled.length)
      process.stderr.write(`\r  mmlu ${k + 1}/${sampled.length}  acc=${((nCorrect / (k + 1)) * 100).toFixed(1)}%`);
  }
  process.stderr.write("\n");
  return { nCorrect, nTotal: sampled.length, accuracy: sampled.length ? nCorrect / sampled.length : 0 };
}
