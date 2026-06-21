// MMLU 5-shot — multi-domain multiple-choice knowledge. Faithful port of
// optiq/eval/mmlu.py: per-subject dev exemplars, A/B/C/D format, and scoring by
// **last-token logit argmax over the " A"/" B"/" C"/" D" tokens** on the RAW
// 5-shot prompt — NO chat template, NO generation. This is the standard
// (Hendrycks/Unsloth) MMLU methodology; the earlier chat-wrap+generate variant
// scored ~5 pts low vs optiq's published number, so we match optiq exactly.
//
// Questions: by DEFAULT we score optiq's EXACT frozen draw (mmlu_optiq_frozen, the
// same ~969 his published 52.4 used) so base/adapter are directly comparable to his
// table. MLX_BUN_MMLU_FROZEN=0 falls back to our own sampling of the full 14k set.

import { loadJsonl, sampleIndices, type TaskModel } from "../runner";

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

/** 5-shot prompt (verbatim optiq _build_prompt): subject header → n demos →
 *  open test question ending in "Answer:". Fed raw (no chat template). */
function buildPrompt(row: MmluRow, devExamples: MmluRow[], nShots: number): string {
  let prompt = `The following are multiple choice questions (with answers) about ${formatSubject(row.subject)}.\n\n`;
  for (const ex of devExamples.slice(0, nShots)) {
    prompt += formatExample(ex.question, ex.choices, ex.answer);
    prompt += "\n";
  }
  prompt += formatExample(row.question, row.choices);
  return prompt;
}

/** Forward the prompt (prefill + last token) and return the index 0..3 of the
 *  highest-logit answer letter — optiq's argmax-on-last-token scoring. */
function lastTokenArgmax(model: TaskModel["model"], ids: number[], letterIds: number[]): number {
  const cache = model.makeCache();
  try {
    if (ids.length > 1) model.forward(ids.slice(0, -1), cache).dispose(); // prefill (cache only)
    const logits = model.forward([ids[ids.length - 1]!], cache); // [1, 1, V]
    const v = logits.toFloat32();
    logits.dispose();
    let best = 0, bestVal = -Infinity;
    for (let i = 0; i < letterIds.length; i++) {
      const val = v[letterIds[i]!]!;
      if (val > bestVal) { bestVal = val; best = i; }
    }
    return best;
  } finally {
    for (const c of cache) c.dispose();
  }
}

export async function evaluateMmlu(
  tm: TaskModel,
  opts: { nSamples?: number; nShots?: number; seed?: number; frozen?: boolean } = {},
): Promise<MmluResult> {
  const nShots = opts.nShots ?? 5;
  const seed = opts.seed ?? 42;

  // Optiq-parity mode (DEFAULT): score optiq's EXACT frozen draw — the same ~969
  // questions + dev exemplars his published table used — so base/adapter numbers are
  // DIRECTLY comparable to optiq's. Any remaining gap is then pure forward-logit
  // parity, not sampling. Set MLX_BUN_MMLU_FROZEN=0 (or frozen:false) to fall back to
  // our own stratified sampling of the full 14k test set (a DIFFERENT subset: JS RNG
  // ≠ numpy RandomState, so it does not match optiq's questions even at the same seed).
  const useFrozen = opts.frozen ?? (process.env.MLX_BUN_MMLU_FROZEN !== "0");

  const testRows = loadJsonl<MmluRow>(useFrozen ? "mmlu_optiq_frozen" : "mmlu_test");
  const devRows = loadJsonl<MmluRow>(useFrozen ? "mmlu_optiq_dev" : "mmlu_dev");

  // Per-subject dev exemplars for prompt construction.
  const devBySubject = new Map<string, MmluRow[]>();
  for (const ex of devRows) {
    const list = devBySubject.get(ex.subject) ?? [];
    list.push(ex);
    devBySubject.set(ex.subject, list);
  }

  let sampled: number[];
  if (useFrozen) {
    // Already optiq's exact draw — score ALL of it, in his order, NO resampling
    // (re-sampling here would re-introduce exactly the divergence we're removing).
    sampled = testRows.map((_, i) => i);
  } else {
    // Stratified sample: roughly equal questions per subject (mirrors mmlu.py).
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
    sampled = [];
    for (const subj of subjects) {
      const pool = testBySubject.get(subj)!;
      const take = Math.min(perSubject, pool.length);
      for (const j of sampleIndices(pool.length, take, seed)) sampled.push(pool[j]!);
    }
    if (sampled.length > nSamples) {
      const keep = sampleIndices(sampled.length, nSamples, seed);
      sampled = keep.map((k) => sampled[k]!);
    }
  }

  // Answer-letter token ids — " A".." D" first token, matching how Hendrycks
  // scores the token after "Answer:". Strip a leading BOS (≈ add_special_tokens=False).
  const bos = tm.tokenizer.bosTokenId;
  const stripBos = (ids: number[]) => (bos !== null && ids[0] === bos ? ids.slice(1) : ids);
  const letterIds = LETTERS.map((L) => {
    const ids = stripBos(tm.tokenizer.encode(` ${L}`));
    return ids[0]!;
  });

  // Re-assert the mounted adapter for our direct forward()s: generation tasks reset
  // loraState.active to [] when they finish, and MMLU bypasses generate() entirely,
  // so without this the argmax would silently score BASE even with --adapter set.
  if (tm.activeAdapters) tm.model.loraState.active = tm.activeAdapters;

  let nCorrect = 0;
  for (let k = 0; k < sampled.length; k++) {
    const item = testRows[sampled[k]!]!;
    const devEx = devBySubject.get(item.subject) ?? [];
    const ids = stripBos(tm.tokenizer.encode(buildPrompt(item, devEx, nShots)));
    const pred = lastTokenArgmax(tm.model, ids, letterIds);
    if (pred === item.answer) nCorrect++;
    if ((k + 1) % 25 === 0 || k + 1 === sampled.length)
      process.stderr.write(`\r  mmlu ${k + 1}/${sampled.length}  acc=${((nCorrect / (k + 1)) * 100).toFixed(1)}%`);
  }
  process.stderr.write("\n");
  return { nCorrect, nTotal: sampled.length, accuracy: sampled.length ? nCorrect / sampled.length : 0 };
}
