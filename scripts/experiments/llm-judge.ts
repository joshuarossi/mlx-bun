// LLM-as-judge via `codex exec` — keyless (uses codex's own auth; model gpt-5.4-mini).
// Forces structured {"winner":"A"|"B"|"tie"} via --output-schema, reads the clean
// verdict from --output-last-message. judgePair() runs BOTH orders to cancel the
// position bias small judges are prone to.
//
// Run directly for the judge positive control (good-vs-bad must win both orders):
//   bun scripts/experiments/llm-judge.ts
import { spawnSync } from "node:child_process";
import { writeFileSync, readFileSync, mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const MODEL = process.env.JUDGE_MODEL ?? "gpt-5.4-mini";
const SCHEMA = JSON.stringify({
  type: "object",
  properties: { winner: { type: "string", enum: ["A", "B", "tie"] } },
  required: ["winner"], additionalProperties: false,
});

/** One judgment, fixed order. Returns which slot (A/B) is better, or tie. */
export function judgeOnce(instruction: string, a: string, b: string): "A" | "B" | "tie" {
  const dir = mkdtempSync(join(tmpdir(), "judge-"));
  const schemaPath = join(dir, "schema.json");
  const outPath = join(dir, "out.txt");
  writeFileSync(schemaPath, SCHEMA);
  const prompt = [
    "You are an impartial judge of assistant responses. Judge ONLY on helpfulness,",
    "correctness, and how well each response follows the instruction. Do NOT favor a",
    'response for being first or for being longer. If they are equal, answer "tie".',
    "",
    `[INSTRUCTION]\n${instruction}`,
    `\n[RESPONSE A]\n${a}`,
    `\n[RESPONSE B]\n${b}`,
    "\nReply only with the required JSON.",
  ].join("\n");
  spawnSync("codex", ["exec", "-m", MODEL, "-s", "read-only", "--output-schema", schemaPath, "-o", outPath, prompt],
    { encoding: "utf8", maxBuffer: 16 * 1024 * 1024 });
  try {
    const v = (JSON.parse(readFileSync(outPath, "utf8").trim()) as { winner: string }).winner;
    return v === "A" || v === "B" ? v : "tie";
  } catch {
    return "tie"; // unparseable -> tie (caller can log)
  }
}

/** Judge `first` vs `second` in BOTH orders; position-bias cancelled. */
export function judgePair(instruction: string, first: string, second: string): { first: number; second: number; tie: number } {
  const r1 = judgeOnce(instruction, first, second); // slot A = first
  const r2 = judgeOnce(instruction, second, first); // slot A = second
  let f = 0, s = 0, t = 0;
  if (r1 === "A") f++; else if (r1 === "B") s++; else t++;
  if (r2 === "A") s++; else if (r2 === "B") f++; else t++;
  return { first: f, second: s, tie: t };
}

if (import.meta.main) {
  const cases = [
    { q: "What is the capital of France?", good: "The capital of France is Paris.", bad: "I like turtles. Bananas are blue." },
    { q: "Write a Python function to add two numbers.", good: "def add(a, b):\n    return a + b", bad: "def add(): pass  # TODO maybe later idk" },
    { q: "Summarize this sentence: the cat sat on the mat.", good: "A cat sat on a mat.", bad: "asdkfj qwpoei zzz 12 ::" },
  ];
  console.log(`### judge positive control (model=${MODEL}) — 'good' must win BOTH orders ###`);
  let pass = 0;
  for (const c of cases) {
    const r = judgePair(c.q, c.good, c.bad); // first = good
    const ok = r.first === 2 && r.second === 0; // good wins both orders, no flip
    if (ok) pass++;
    console.log(`${ok ? "PASS" : "FAIL"}  "${c.q.slice(0, 38)}"  good=${r.first} bad=${r.second} tie=${r.tie}`);
  }
  console.log(`\n${pass}/${cases.length} cases passed (good won both orders → no position flip)`);
}
