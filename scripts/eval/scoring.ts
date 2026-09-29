// Prompt construction, answer extraction and scoring for GSM8K, MMLU, HumanEval
// and HashHop, plus the deterministic subsampler and the capability score:
// copied verbatim from main at 02d723a (src/eval/tasks/*.ts, runner.ts and
// score.ts, ports of optiq/eval/*.py). Only colliding prompt builders are
// renamed, helpers are exported, and diskGbForDir reads the pinned file list
// instead of the directory. Nothing here loads a model or runs code.

// ---- runner.ts ----------------------------------------------------------------
/** Deterministic seeded subsample of [0, total): mulberry32 shuffle, sorted. */
export function sampleIndices(total: number, n: number, seed = 42): number[] {
  let s = seed >>> 0;
  const rand = (): number => {
    s = (s + 0x6d2b79f5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const idx = Array.from({ length: total }, (_, i) => i);
  for (let i = total - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [idx[i], idx[j]] = [idx[j]!, idx[i]!];
  }
  return idx.slice(0, Math.min(n, total)).sort((a, b) => a - b);
}

// ---- tasks/gsm8k.ts -------------------------------------------------------------
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

export function gsm8kPrompt(question: string, nShots: number): string {
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

export function groundTruth(answer: string): string {
  const m = answer.match(new RegExp(String.raw`####\s*(${NUM})`));
  return m ? m[1]!.replace(/,/g, "").trim() : "";
}

export function toNum(s: string | null): number | null {
  if (!s) return null;
  const v = Number(s.replace(/,/g, ""));
  return Number.isFinite(v) ? v : null;
}

// ---- tasks/mmlu.ts --------------------------------------------------------------

export interface MmluRow {
  question: string;
  subject: string;
  choices: string[];
  answer: number; // 0..3 → A/B/C/D
}

export const LETTERS = ["A", "B", "C", "D"] as const;

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
export function mmluPrompt(row: MmluRow, devExamples: MmluRow[], nShots: number): string {
  let prompt = `The following are multiple choice questions (with answers) about ${formatSubject(row.subject)}.\n\n`;
  for (const ex of devExamples.slice(0, nShots)) {
    prompt += formatExample(ex.question, ex.choices, ex.answer);
    prompt += "\n";
  }
  prompt += formatExample(row.question, row.choices);
  return prompt;
}


// ---- tasks/humaneval.ts ---------------------------------------------------------
// Stop sequences — mirror humaneval.py's _STOP_SEQS exactly.
const STOP_SEQS = ["\nclass ", "\ndef ", "\n#", "\nif __name__", "\nprint(", "\n```"];

/** Last fenced ```python|py? ... ``` block, or null (port of _extract_code_block). */
function extractCodeBlock(text: string): string | null {
  const re = /```(?:python|py)?\n([\s\S]*?)\n```/g;
  let last: string | null = null;
  for (const m of text.matchAll(re)) last = m[1]!;
  return last;
}

/** Escape a string for use as a literal inside a RegExp (re.escape). */
function reEscape(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Strip the `def entry_point(...):` header + docstring, keep just the body
 * (port of _strip_function_def). Falls through if no such def is found.
 */
function stripFunctionDef(body: string, entryPoint: string): string {
  const pat = new RegExp(`def\\s+${reEscape(entryPoint)}\\s*\\([^)]*\\)[^:]*:\\s*\\n`);
  const m = body.match(pat);
  if (!m || m.index === undefined) return body;
  const after = body.slice(m.index + m[0].length);
  // Skip leading blank lines + a possible docstring.
  let rest = after.replace(/^\n+/, "");
  const doc = rest.match(/^\s*(["']{3})([\s\S]*?)\1\s*\n/);
  if (doc) rest = rest.slice(doc[0].length);
  return rest;
}

/**
 * Reduce the model response to a function body suitable for concatenating
 * onto the HumanEval prompt (port of _truncate_completion).
 */
export function truncateCompletion(text: string, entryPoint = ""): string {
  let out = text;
  if (out.includes("</think>")) out = out.split("</think>").slice(1).join("</think>");
  if (out.includes("<channel|>")) out = out.split("<channel|>").slice(1).join("<channel|>");

  // Prefer the last fenced code block (conversational models).
  const block = extractCodeBlock(out);
  if (block !== null) {
    return entryPoint ? stripFunctionDef(block, entryPoint) : block;
  }

  // Legacy / completion-mode path: strip a leading fence, then cut at the
  // first stop sequence.
  out = out.replace(/^\s+/, "");
  if (out.startsWith("```python\n")) out = out.slice("```python\n".length);
  else if (out.startsWith("```\n")) out = out.slice("```\n".length);

  let earliest = out.length;
  for (const stop of STOP_SEQS) {
    const i = out.indexOf(stop);
    if (i !== -1 && i < earliest) earliest = i;
  }
  return out.slice(0, earliest);
}

/** Concatenate prompt + completion + test driver (port of _build_program). */
export function buildProgram(prompt: string, completion: string, test: string, entryPoint: string): string {
  return prompt + completion + "\n\n" + test + "\n\n" + `check(${entryPoint})\n`;
}

// ---- tasks/hashhop.ts -----------------------------------------------------------
/** First 16-char alphabetic run in the output (port of _extract_pred). */
export function extractPred(out: string): string {
  const m = out.match(/[A-Za-z]{16}/);
  return m ? m[0] : out.trim();
}

// ---- score.ts --------------------------------------------------------------------
// Capability score — port of optiq/eval/score.py.
//
// A single scalar: the simple UNWEIGHTED mean of whichever of the six
// benchmarks (MMLU, GSM8K, IFEval, BFCL, HumanEval, HashHop) were run.
// Disk size is reported alongside but NEVER enters the score — no hidden
// quality/disk tradeoff baked into the number (optiq's explicit design
// choice). Missing components are skipped, not zero-filled.

export interface CapabilityScore {
  /** 0–100, simple mean of the provided benchmark percents. */
  score: number;
  /** Per-benchmark contribution to the mean (only the ones that ran). */
  components: Record<string, number>;
  /** Reported separately; does NOT affect `score`. */
  diskGb: number;
}

export type TaskName = "MMLU" | "GSM8K" | "IFEval" | "BFCL" | "HumanEval" | "HashHop";

/** Unweighted mean of the provided task percents (each 0–100). */
export function computeCapabilityScore(
  percents: Partial<Record<TaskName, number>>,
  diskGb: number,
): CapabilityScore {
  const components: Record<string, number> = {};
  for (const [name, val] of Object.entries(percents))
    if (val !== undefined && val !== null && Number.isFinite(val))
      components[name] = val;

  const keys = Object.keys(components);
  const score = keys.length === 0
    ? 0
    : keys.reduce((a, k) => a + components[k]!, 0) / keys.length;

  return { score, components, diskGb };
}

/** Main's diskGbForDir over the pinned file list: `*.safetensors` shard bytes in GB. */
export function diskGb(files: ReadonlyArray<{ name: string; bytes: number }>): number {
  let total = 0;
  for (const file of files) if (file.name.endsWith(".safetensors")) total += file.bytes;
  return total / 1024 ** 3;
}
