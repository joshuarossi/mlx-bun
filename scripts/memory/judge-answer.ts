// The Dreaming — P9-T1 OFFLINE answer grader for the north-star read path.
//
// Headless runs require ANTHROPIC_API_KEY in the environment (pi uses OAuth, so
// the key is NOT present interactively — Josh sets it for headless runs). The
// build-time grading in this project was done by a cloud-judge SUB-AGENT (a
// strong cloud model reading the same artifact this script feeds the API); this
// script is the durable, re-runnable equivalent. The GRADER may be a stronger
// model offline — it is NEVER in the hot path (the local model answers; the
// cloud judge only scores).
//
// What it grades: given a north-star QUESTION, the system's ANSWER (from the
// read path), and the EXPECTED answer, decide TWO things:
//   - correct: binary — does the answer convey the expected position/fact?
//   - silentViolation: when the silent contract is in force, did the answer
//     break the colleague rule — citing the wiki/notes unprompted ("per the
//     wiki", "according to your notes") or greeting ("welcome back") — instead
//     of speaking as a continuation? The contract is the north-star's "SILENTLY,
//     like a colleague" requirement; an otherwise-correct answer that announces
//     its source still fails the silent gate.
//
// The silent-violation detector is DETERMINISTIC (a regex over the named
// phrases) so it runs with no key and is unit-tested directly; the cloud judge
// adds correctness + catches subtler phrasings the regex misses, OR'd with the
// regex. P9-T2's RunJudge stage (or a sub-agent) exercises the model-call path.
//
//   ANTHROPIC_API_KEY=… bun scripts/memory/judge-answer.ts

import Anthropic from "@anthropic-ai/sdk";

const MODEL = process.env.JUDGE_MODEL ?? "claude-opus-4-8";
const MAX_TOKENS = Number(process.env.JUDGE_MAX_TOKENS ?? 1500);

/** One graded case: the user question, the system's answer, the expected
 *  answer, and whether the silent contract is in force for this query. */
export interface AnswerCase {
  id: string;
  question: string;
  answer: string;
  expected: string;
  /** True when the answer must read as a silent continuation (the north-star
   *  default). False only when the user explicitly asked the system to cite its
   *  notes, so naming the source is not a violation. */
  silentContract: boolean;
}

export interface AnswerVerdict {
  id: string;
  correct: boolean; // conveys the expected position/fact
  silentViolation: boolean; // broke the colleague contract (regex ∪ judge)
  reason: string;
}

// ---- deterministic silent-violation detector --------------------------------
// The named tells from the north-star + read-tool descriptions: announcing the
// source ("per the wiki", "according to your notes") or greeting the user
// ("welcome back") instead of just answering. Kept schematic and phrase-level —
// it flags the announcement pattern, not any mention of a noun.
export const SILENT_VIOLATION_PATTERNS: readonly RegExp[] = [
  /\bper (?:the|your|my) (?:wiki|notes|records?)\b/i,
  /\baccording to (?:the|your|my) (?:wiki|notes|records?)\b/i,
  /\bbased on (?:the|your|my) (?:wiki|notes|records?)\b/i,
  /\b(?:the|your|my) (?:wiki|notes|records?) (?:say|says|state|states|show|shows|indicate|indicates|note|notes)\b/i,
  /\b(?:as )?(?:recorded|noted|stored|saved) in (?:the|your|my) (?:wiki|notes|records?)\b/i,
  /\bfrom (?:the|your|my) (?:wiki|notes|records?)\b/i,
  /\bin your (?:wiki|notes|records?)\b/i,
  /\bwelcome back\b/i,
];

/** Pure, key-free: does the answer announce its source or greet the user? */
export function detectSilentViolation(answer: string): {
  violation: boolean;
  phrase: string | null;
} {
  for (const re of SILENT_VIOLATION_PATTERNS) {
    const m = answer.match(re);
    if (m) return { violation: true, phrase: m[0] };
  }
  return { violation: false, phrase: null };
}

// ---- cloud-judge prompt (reusable) ------------------------------------------
export const ANSWER_JUDGE_SYSTEM =
  "You are a strict offline cloud judge grading a personal-wiki memory system's " +
  "ANSWER to a user QUESTION, against the EXPECTED answer. Judge TWO things:\n" +
  "1. correct: true only if the ANSWER conveys the same position/fact as the " +
  "EXPECTED answer (paraphrase is fine; a missing key claim, a contradiction, or " +
  "a confabulated fact makes it false). For a negative-control question where the " +
  "EXPECTED answer is that there is no recorded position, 'correct' means the " +
  "answer says so plainly and invents nothing.\n" +
  "2. silentViolation: only when SILENT-CONTRACT is ON. The system should answer " +
  "like a colleague continuing a conversation — NOT announce its source. Mark " +
  "true if the answer cites the wiki/notes unprompted (e.g. phrasing that points " +
  "at where the fact is stored) or opens with a greeting like a returning-user " +
  "welcome. Speaking the answer directly, with no source announcement, is NOT a " +
  "violation. When SILENT-CONTRACT is OFF, always return false.\n" +
  "Reply with ONLY a JSON object, no prose, no markdown fences:\n" +
  '{"correct":true|false,"silentViolation":true|false,"reason":"…"}';

export function buildAnswerPrompt(c: AnswerCase): string {
  return (
    `SILENT-CONTRACT: ${c.silentContract ? "ON" : "OFF"}\n\n` +
    `QUESTION:\n${c.question}\n\n` +
    `EXPECTED ANSWER:\n${c.expected}\n\n` +
    `SYSTEM ANSWER:\n${c.answer}\n\n` +
    "Grade per the rubric and return the JSON object."
  );
}

export function parseAnswerVerdict(id: string, text: string): {
  correct: boolean;
  silentViolation: boolean;
  reason: string;
} {
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  const raw = (fenced?.[1] ?? text).trim();
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end < 0) throw new Error(`no JSON object in judge reply for ${id}`);
  const obj = JSON.parse(raw.slice(start, end + 1)) as {
    correct?: unknown;
    silentViolation?: unknown;
    reason?: unknown;
  };
  return {
    correct: obj.correct === true,
    silentViolation: obj.silentViolation === true,
    reason: typeof obj.reason === "string" ? obj.reason : "",
  };
}

/**
 * Full grade for one case: the cloud judge scores correctness and a subtler
 * silent-contract read, then the deterministic regex is OR'd in so a named
 * phrase is never missed. With SILENT-CONTRACT off, no violation is ever
 * reported regardless of phrasing.
 */
export async function gradeAnswer(client: Anthropic, c: AnswerCase): Promise<AnswerVerdict> {
  const res = await client.messages.create({
    model: MODEL,
    max_tokens: MAX_TOKENS,
    system: ANSWER_JUDGE_SYSTEM,
    messages: [{ role: "user", content: buildAnswerPrompt(c) }],
  });
  let text = "";
  for (const block of res.content) if (block.type === "text") text += block.text;
  const judged = parseAnswerVerdict(c.id, text);
  const det = detectSilentViolation(c.answer);
  const silentViolation = c.silentContract ? judged.silentViolation || det.violation : false;
  const reason =
    det.violation && c.silentContract
      ? `silent-contract tell "${det.phrase}"; ${judged.reason}`
      : judged.reason;
  return { id: c.id, correct: judged.correct, silentViolation, reason };
}

// ---- labeled self-test set (the P9-T1 acceptance: 5 graded cases) -----------
// Schematic answers in the fixture-vault (lens) domain; each carries its
// expected verdict. The silentViolation dimension is fully determinable by the
// regex (no key), which is what tests/memory-judge-answer.test.ts asserts; the
// `correct` dimension is what the model-call path (RunJudge / sub-agent) scores.
export interface AnswerFixture {
  case: AnswerCase;
  expect: { correct: boolean; silentViolation: boolean };
}

export const SELF_TEST_FIXTURES: readonly AnswerFixture[] = [
  {
    // correct, silent — speaks as a continuation, names no source.
    case: {
      id: "f1-reach-silent",
      question: "What's the best lens for really long reach that isn't crazy expensive?",
      answer:
        "Since you already shoot the 75-300, the Sigma 150-600 is the sane pick for real reach without spending a fortune.",
      expected: "The Sigma 150-600 is the sane affordable long-reach pick given the 75-300.",
      silentContract: true,
    },
    expect: { correct: true, silentViolation: false },
  },
  {
    // correct content, but announces the source → silent violation.
    case: {
      id: "f2-reach-cited",
      question: "What's the best lens for really long reach that isn't crazy expensive?",
      answer:
        "According to your notes, the Sigma 150-600 is the affordable long-reach pick.",
      expected: "The Sigma 150-600 is the sane affordable long-reach pick given the 75-300.",
      silentContract: true,
    },
    expect: { correct: true, silentViolation: true },
  },
  {
    // negative control — correct (says no recorded position), silent.
    case: {
      id: "f3-negative-control",
      question: "What's my take on astrophotography?",
      answer: "You don't have a recorded position on astrophotography.",
      expected: "There is no personal opinion on file for astrophotography.",
      silentContract: true,
    },
    expect: { correct: true, silentViolation: false },
  },
  {
    // greeting opener → silent violation, content still on-point.
    case: {
      id: "f4-welcome-back",
      question: "Why did I go with the L-Mount body?",
      answer:
        "Welcome back! You chose the L-Mount body for its native lens range and adaptability.",
      expected: "The L-Mount body was chosen for native lenses and mount adaptability.",
      silentContract: true,
    },
    expect: { correct: true, silentViolation: true },
  },
  {
    // wrong fact, no source announcement → incorrect but no silent violation.
    case: {
      id: "f5-wrong-fact",
      question: "What's the best lens for really long reach that isn't crazy expensive?",
      answer: "The 75-300 is your best option for serious long reach.",
      expected: "The Sigma 150-600 is the sane affordable long-reach pick given the 75-300.",
      silentContract: true,
    },
    expect: { correct: false, silentViolation: false },
  },
];

/** Grade the silent dimension of the self-test set deterministically (no key).
 *  Returns how many fixtures' silentViolation label the regex reproduces. */
export function gradeFixturesSilent(
  fixtures: readonly AnswerFixture[] = SELF_TEST_FIXTURES,
): { graded: number; matched: number } {
  let matched = 0;
  for (const f of fixtures) {
    const det = f.case.silentContract && detectSilentViolation(f.case.answer).violation;
    if (det === f.expect.silentViolation) matched++;
  }
  return { graded: fixtures.length, matched };
}

async function main(): Promise<void> {
  // The deterministic gate runs anywhere — it is the key-free half of P9-T1.
  const det = gradeFixturesSilent();
  console.log(
    `silent-detector self-test: ${det.matched}/${det.graded} fixtures' silentViolation reproduced`,
  );
  for (const f of SELF_TEST_FIXTURES) {
    const d = detectSilentViolation(f.case.answer);
    const flag = f.case.silentContract ? d.violation : false;
    const ok = flag === f.expect.silentViolation ? "ok " : "MISS";
    console.log(`  [${ok}] ${f.case.id} silent=${flag}${d.phrase ? ` ("${d.phrase}")` : ""}`);
  }

  if (!process.env.ANTHROPIC_API_KEY) {
    console.log(
      "\nno ANTHROPIC_API_KEY — skipping the cloud-judge correctness pass " +
        "(Josh sets it for headless runs; the RunJudge stage / sub-agent exercises it).",
    );
    return;
  }

  // Full grade: correctness via the cloud judge, silent via regex ∪ judge.
  const client = new Anthropic();
  let correctMatched = 0;
  let silentMatched = 0;
  for (const f of SELF_TEST_FIXTURES) {
    const v = await gradeAnswer(client, f.case);
    const cOk = v.correct === f.expect.correct;
    const sOk = v.silentViolation === f.expect.silentViolation;
    if (cOk) correctMatched++;
    if (sOk) silentMatched++;
    console.log(
      `  [${cOk && sOk ? "ok " : "MISS"}] ${f.case.id} correct=${v.correct} ` +
        `silent=${v.silentViolation} — ${v.reason}`,
    );
  }
  console.log(
    `\ncloud-judge self-test: correct ${correctMatched}/${SELF_TEST_FIXTURES.length}, ` +
      `silent ${silentMatched}/${SELF_TEST_FIXTURES.length}`,
  );
}

if (import.meta.main) await main();
