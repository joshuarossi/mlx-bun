// Quality-eval CLI — the acceptance gate for non-bit-exact perf work
// (fused kernels). Ports optiq's eval framework: KL drift gate + the
// six-task capability suite (MMLU/GSM8K/IFEval/BFCL/HumanEval/HashHop).
//
//   bun scripts/eval.ts kl         --candidate e4b            # KL drift gate
//   bun scripts/eval.ts gsm8k      --candidate e4b [--n 200]  # one task
//   bun scripts/eval.ts capability --candidate e4b            # all six + score
//   bun scripts/eval.ts smoketest  --candidate e4b            # KL + GSM8K-50
//
// Tasks run through the real quantized-KV serving path (generate() with the
// model's kv_config). Results land in ~/.cache/mlx-bun/evals.sqlite
// (quality_runs); each row records the active perf levers (config_json).

import { readFileSync } from "node:fs";
import { DEFAULT_KL_PROMPTS } from "../src/eval/kl-prompts";
import { evaluateKlSelfFlag, evaluateKlTwoModel, evaluateKlServingDecode, type KLResult } from "../src/eval/kl";
import { loadTaskModel, type TaskModel } from "../src/eval/runner";
import { evaluateGsm8k } from "../src/eval/tasks/gsm8k";
import { evaluateMmlu } from "../src/eval/tasks/mmlu";
import { evaluateIfeval } from "../src/eval/tasks/ifeval";
import { evaluateBfcl } from "../src/eval/tasks/bfcl";
import { evaluateHumaneval } from "../src/eval/tasks/humaneval";
import { evaluateHashhop } from "../src/eval/tasks/hashhop";
import { computeCapabilityScore, diskGbForDir, type TaskName } from "../src/eval/score";
import { QualityDB } from "../src/eval/quality-db";
import { checkMachine, machineStateJson } from "../src/preflight";
import { gitCommit } from "../src/evaldb";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

function loadPromptsFile(path: string): string[] {
  const out: string[] = [];
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const t = line.trim();
    if (!t) continue;
    const s = JSON.parse(t);
    if (typeof s.text === "string") out.push(s.text);
    else if (Array.isArray(s.messages))
      out.push(s.messages.map((m: { role: string; content: string }) => `[${m.role}]: ${m.content}`).join("\n\n"));
  }
  if (!out.length) throw new Error(`no prompts parsed from ${path} (expected jsonl with .text or .messages)`);
  return out;
}

/** Snapshot of the perf levers active for this run (self-describing rows). */
function activeConfig(): Record<string, string> {
  const lever = (k: string, d: string) => process.env[k] ?? d;
  return {
    compiledDecode: lever("MLX_BUN_COMPILED_DECODE", "1"),
    perfKernel: lever("MLX_BUN_PERF_KERNEL", "1"),
    fusedDecode: lever("MLX_BUN_FUSED_DECODE", "0"),
    noFusedSdpa: lever("MLX_BUN_NO_FUSED_SDPA", "0"),
  };
}

// ---- KL drift gate -------------------------------------------------------

async function runKl(): Promise<void> {
  const candidate = opt("candidate");
  if (!candidate) { console.error("kl: --candidate <query|path> is required"); process.exit(1); }

  const promptsFile = opt("prompts-file");
  const prompts = promptsFile ? loadPromptsFile(promptsFile) : DEFAULT_KL_PROMPTS;
  const nPrompts = Number(opt("n", "64"));
  const seqLen = Number(opt("seq", "256"));

  const decode = process.argv.includes("--decode");
  const reference = opt("reference");

  console.log(`[eval/kl] candidate=${candidate}  prompts=${nPrompts}×${seqLen}`);
  let res: KLResult;
  if (decode) {
    // serving-path (M0b): teacher-forced quantized DECODE. Default lever is
    // the one that actually bites in decode today (tiled vs unfused SDPA).
    const flag = opt("self", "MLX_BUN_FUSED_DECODE")!;
    const refValue = opt("ref-value", "0")!;
    const candValue = opt("cand-value", "1")!;
    const decodeSteps = Number(opt("decode-steps", "32"));
    console.log(`[eval/kl] serving-decode  self-flag ${flag}: ${refValue} → ${candValue}  steps=${decodeSteps}`);
    res = await evaluateKlServingDecode({ candidate, flag, refValue, candValue, prompts, nPrompts, seqLen, decodeSteps });
  } else if (reference) {
    console.log(`[eval/kl] two-model reference=${reference}`);
    res = await evaluateKlTwoModel({ candidate, reference, prompts, nPrompts, seqLen });
  } else {
    const selfFlag = opt("self", "MLX_BUN_NO_FUSED_SDPA")!;
    const refValue = opt("ref-value", "1")!;
    const candValue = opt("cand-value", "0")!;
    console.log(`[eval/kl] compat self-flag ${selfFlag}: ${refValue} → ${candValue}`);
    res = await evaluateKlSelfFlag({ candidate, flag: selfFlag, refValue, candValue, prompts, nPrompts, seqLen });
  }

  console.log(
    `\nKL(ref ‖ cand)  mean=${res.meanKl.toFixed(5)}  median=${res.medianKl.toFixed(5)}  ` +
    `p95=${res.p95Kl.toFixed(5)}\n  ref=${res.refLabel}  ${res.nPrompts}×${res.seqLen} tok  ` +
    `elapsed ${res.elapsedSec.toFixed(0)}s`,
  );

  const db = new QualityDB();
  db.record({
    modelPath: candidate, commitSha: gitCommit(), task: "kl", config: activeConfig(),
    nSamples: res.nPrompts, klMean: res.meanKl, klMedian: res.medianKl, klP95: res.p95Kl,
    klRef: res.refLabel, notes: `eval/kl seq=${res.seqLen}`, machineState: machineStateJson(checkMachine()),
  });
  db.close();
}

// ---- capability tasks ----------------------------------------------------

interface TaskOut { accuracy: number; nTotal: number }

/** label + runner for each capability task (n omitted → the task's default). */
const GEN_TASKS: Record<string, { label: TaskName; run: (tm: TaskModel, n?: number) => Promise<TaskOut> }> = {
  gsm8k: { label: "GSM8K", run: (tm, n) => evaluateGsm8k(tm, { nSamples: n }) },
  mmlu: { label: "MMLU", run: (tm, n) => evaluateMmlu(tm, { nSamples: n }) },
  ifeval: { label: "IFEval", run: (tm, n) => evaluateIfeval(tm, { nSamples: n }) },
  bfcl: { label: "BFCL", run: (tm, n) => evaluateBfcl(tm, { nSamples: n }) },
  humaneval: { label: "HumanEval", run: (tm, n) => evaluateHumaneval(tm, { nSamples: n }) },
  hashhop: { label: "HashHop", run: (tm, n) => evaluateHashhop(tm, n ? { nPerHop: Math.max(1, Math.round(n / 4)) } : {}) },
};

function recordTask(candidate: string, task: string, label: string, res: TaskOut, dir: string): void {
  const { accuracy, nTotal, ...rest } = res as TaskOut & Record<string, unknown>;
  const db = new QualityDB();
  db.record({
    modelPath: candidate, commitSha: gitCommit(), task, config: activeConfig(),
    nSamples: nTotal, pct: accuracy * 100, diskGb: diskGbForDir(dir),
    notes: `eval/${task} ${label} ${JSON.stringify(rest)}`,
    machineState: machineStateJson(checkMachine()),
  });
  db.close();
}

async function runTask(name: string): Promise<void> {
  const candidate = opt("candidate");
  if (!candidate) { console.error(`${name}: --candidate <query|path> is required`); process.exit(1); }
  const adapter = opt("adapter") ?? undefined;
  const label = adapter ? `${candidate}+${adapter}` : candidate;
  const nOpt = opt("n");
  const n = nOpt ? Number(nOpt) : undefined;
  const t = GEN_TASKS[name]!;
  console.log(`[eval/${name}] candidate=${label}${n ? `  n=${n}` : ""}`);
  const tm = await loadTaskModel(candidate, adapter);
  const res = await t.run(tm, n);
  console.log(`\n${t.label}  ${(res.accuracy * 100).toFixed(1)}%  (${res.nTotal} samples)`);
  recordTask(label, name, t.label, res, tm.dir);
}

async function runCapability(): Promise<void> {
  const candidate = opt("candidate");
  if (!candidate) { console.error("capability: --candidate <query|path> is required"); process.exit(1); }
  const adapter = opt("adapter") ?? undefined;
  const label = adapter ? `${candidate}+${adapter}` : candidate;
  const nOpt = opt("n");
  const n = nOpt ? Number(nOpt) : undefined; // per-task cap (for quick runs); omit → full
  console.log(`[eval/capability] candidate=${label}${n ? `  n=${n}/task` : "  (full)"}`);
  const tm = await loadTaskModel(candidate, adapter);

  const pcts: Partial<Record<TaskName, number>> = {};
  for (const [name, t] of Object.entries(GEN_TASKS)) {
    console.log(`\n=== ${t.label} ===`);
    const res = await t.run(tm, n);
    pcts[t.label] = res.accuracy * 100;
    recordTask(label, name, t.label, res, tm.dir);
  }

  const cap = computeCapabilityScore(pcts, diskGbForDir(tm.dir));
  console.log(`\nCapability_Score = ${cap.score.toFixed(2)}   (disk ${cap.diskGb.toFixed(1)} GB)`);
  for (const [k, v] of Object.entries(cap.components)) console.log(`  ${k.padEnd(10)} ${v.toFixed(1)}`);

  const db = new QualityDB();
  db.record({
    modelPath: label, commitSha: gitCommit(), task: "capability", config: activeConfig(),
    nSamples: 0, capabilityScore: cap.score, diskGb: cap.diskGb,
    notes: JSON.stringify(cap.components), machineState: machineStateJson(checkMachine()),
  });
  db.close();
}

async function runSmoketest(): Promise<void> {
  // optiq smoketest = KL + GSM8K-50.
  await runKl();
  const candidate = opt("candidate")!;
  console.log(`\n=== GSM8K-50 ===`);
  const tm = await loadTaskModel(candidate);
  const res = await evaluateGsm8k(tm, { nSamples: 50 });
  console.log(`GSM8K-50  ${(res.accuracy * 100).toFixed(1)}%`);
  recordTask(candidate, "gsm8k", "GSM8K", res, tm.dir);
}

// ---- dispatch ------------------------------------------------------------

const task = process.argv[2];
if (task === "kl") await runKl();
else if (task === "capability") await runCapability();
else if (task === "smoketest") await runSmoketest();
else if (task && GEN_TASKS[task]) await runTask(task);
else {
  console.error(`unknown task '${task ?? ""}'. Tasks: ${["kl", "smoketest", "capability", ...Object.keys(GEN_TASKS)].join(" | ")}`);
  process.exit(1);
}
