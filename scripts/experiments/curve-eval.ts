// curve-eval.ts — the degradation gate for the v2 curve sampler.
// Runs the 6-task capability suite under TWO sampler arms on one model load:
//   A) the model's DEFAULT chat recipe (T=1 + top-p + top-k) — the honest baseline
//   B) the drawn CURVE (replaces temperature+softmax)        — the candidate
// Both stochastic and seeded the same way, so the diff isolates the curve's effect
// on capability (math / knowledge / instruction-following / tools / code / retrieval).
//
//   bun scripts/curve-eval.ts [--candidate e4b] [--n 100] [--curve /tmp/curve.json] [--seed 42]
import { readFileSync } from "node:fs";
import { loadTaskModel, type TaskModel } from "../../src/eval/runner";
import { evaluateGsm8k } from "../../src/eval/tasks/gsm8k";
import { evaluateMmlu } from "../../src/eval/tasks/mmlu";
import { evaluateIfeval } from "../../src/eval/tasks/ifeval";
import { evaluateBfcl } from "../../src/eval/tasks/bfcl";
import { evaluateHumaneval } from "../../src/eval/tasks/humaneval";
import { evaluateHashhop } from "../../src/eval/tasks/hashhop";
import { computeCapabilityScore, type TaskName } from "../../src/eval/score";

const opt = (k: string, d: string) => { const i = process.argv.indexOf(`--${k}`); return i >= 0 ? process.argv[i + 1]! : d; };
const CANDIDATE = opt("candidate", "gemma-4-e4b-it-OptiQ-4bit");
const N = Number(opt("n", "100"));
const SEED = Number(opt("seed", "42"));
const CURVE = JSON.parse(readFileSync(opt("curve", "/tmp/curve.json"), "utf8"));

const TASKS: [TaskName, (tm: TaskModel) => Promise<{ accuracy: number; nTotal: number }>][] = [
  ["GSM8K", (tm) => evaluateGsm8k(tm, { nSamples: N })],
  ["MMLU", (tm) => evaluateMmlu(tm, { nSamples: N })],
  ["IFEval", (tm) => evaluateIfeval(tm, { nSamples: N })],
  ["BFCL", (tm) => evaluateBfcl(tm, { nSamples: N })],
  ["HumanEval", (tm) => evaluateHumaneval(tm, { nSamples: N })],
  ["HashHop", (tm) => evaluateHashhop(tm, { nPerHop: Math.max(1, Math.round(N / 4)) })],
];
const ARMS: [string, TaskModel["samplerOverride"]][] = [
  ["default", { temperature: 1, topP: 0.95, topK: 64, seed: SEED }], // e4b's chat recipe
  ["curve", { curve: CURVE, seed: SEED }],
];

console.log(`[curve-eval] candidate=${CANDIDATE}  n=${N}/task  seed=${SEED}  curve points=${CURVE.points?.length}`);
const tm = await loadTaskModel(CANDIDATE);
const out: Record<string, { pcts: Partial<Record<TaskName, number>>; score: number }> = {};
for (const [arm, override] of ARMS) {
  tm.samplerOverride = override;
  const pcts: Partial<Record<TaskName, number>> = {};
  console.log(`\n===== ARM: ${arm} =====`);
  for (const [label, run] of TASKS) {
    const t0 = Bun.nanoseconds();
    const res = await run(tm);
    pcts[label] = res.accuracy * 100;
    console.log(`  ${label.padEnd(10)} ${(res.accuracy * 100).toFixed(1).padStart(5)}%  (n=${res.nTotal}, ${((Bun.nanoseconds() - t0) / 1e9).toFixed(0)}s)`);
  }
  out[arm] = { pcts, score: computeCapabilityScore(pcts, 0).score };
  console.log(`  ${"Capability".padEnd(10)} ${out[arm]!.score.toFixed(2).padStart(5)}`);
}

console.log(`\n================  CURVE vs DEFAULT (n=${N}/task)  ================`);
console.log(`${"TASK".padEnd(11)} ${"default".padStart(8)} ${"curve".padStart(8)} ${"Δ".padStart(8)}`);
for (const [label] of TASKS) {
  const d = out.default!.pcts[label]!, c = out.curve!.pcts[label]!;
  console.log(`${label.padEnd(11)} ${d.toFixed(1).padStart(8)} ${c.toFixed(1).padStart(8)} ${(c - d >= 0 ? "+" : "") + (c - d).toFixed(1)}`.padEnd(40));
}
const ds = out.default!.score, cs = out.curve!.score;
console.log(`${"CAPABILITY".padEnd(11)} ${ds.toFixed(2).padStart(8)} ${cs.toFixed(2).padStart(8)} ${(cs - ds >= 0 ? "+" : "") + (cs - ds).toFixed(2)}`);
console.log(`\n${cs >= ds - 0.5 ? "✅ curve holds capability (within 0.5 pt)" : "⚠️  curve degrades capability by " + (ds - cs).toFixed(2) + " pts"}`);
