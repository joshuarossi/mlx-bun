// PERF-02 measurement harness: isolate direct-generation logprob readback cost.
//
// This is intentionally separate from the serving benchmark. It measures the
// generate() pipeline directly so HTTP, SSE, and detokenization cannot obscure
// a per-token synchronization stall.
//
// Recommended quiet-machine run:
//   bun scripts/bench-logprobs-readback.ts \
//     --model Qwen2.5-0.5B --tokens 256 --warmups 2 --runs 5
//
// Raw samples go to the gitignored reports/ directory. Do not curate a result
// into benchmarks/RESULTS.md until both the machine preflight and parity gates
// pass.

import { createHash } from "node:crypto";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve as resolvePath } from "node:path";
import { loadModelConfig } from "../src/config";
import { gitCommit } from "../src/evaldb";
import {
  generate,
  type GenerateOptions,
  type GenerateStats,
  type TokenLogprobs,
} from "../src/generate";
import { ChatTemplate } from "../src/chat-template";
import { createModel } from "../src/model/factory";
import { checkMachine, machineStateJson } from "../src/preflight";
import { Registry } from "../src/registry";
import { loadTokenizer } from "../src/tokenizer";
import { Weights } from "../src/weights";

type ArmName = "off" | "logprobs" | "top_logprobs";
type Model = Parameters<typeof generate>[0];

interface CliOptions {
  model: string;
  tokens: number;
  warmups: number;
  runs: number;
  topK: number;
  prompt: string;
  output: string;
  force: boolean;
}

interface Distribution {
  count: number;
  min: number | null;
  p50: number | null;
  p95: number | null;
  max: number | null;
  mean: number | null;
}

interface CapturedTopLogprob {
  id: number;
  logprob: number;
  float32Bits: string;
}

interface Sample {
  phase: "warmup" | "measure";
  round: number;
  order: number;
  arm: ArmName;
  totalMs: number;
  firstTokenMs: number;
  perTokenMs: number;
  yieldAtMs: number[];
  interTokenMs: number[];
  interTokenSummary: Distribution;
  tokens: number[];
  selectedLogprobs: number[] | null;
  selectedLogprobBits: string[] | null;
  topLogprobs: CapturedTopLogprob[][] | null;
  stats: GenerateStats;
}

interface ParityReport {
  ok: boolean;
  checks: number;
  failures: string[];
  selectedComparisons: number;
  selectedExact: number;
  selectedMaxAbsDelta: number;
  emittedInTopK: number;
  emittedInTopKExact: number;
}

const DEFAULT_PROMPT =
  "Write a detailed essay about the history of computing, starting with mechanical calculators.";
const DEFAULT_MODEL = process.env.PERF02_MODEL ?? "Qwen2.5-0.5B";
const ARM_NAMES: ArmName[] = ["off", "logprobs", "top_logprobs"];
const REPO_ROOT = resolvePath(import.meta.dir, "..");

function gitWorktreeDirty(): boolean | null {
  try {
    const result = Bun.spawnSync(
      ["git", "status", "--porcelain=v1", "--untracked-files=all"],
      { cwd: REPO_ROOT },
    );
    return result.exitCode === 0 ? result.stdout.length > 0 : null;
  } catch {
    return null;
  }
}

function usage(): never {
  console.log(`Usage:
  bun scripts/bench-logprobs-readback.ts [options]

Options:
  --model <path|query>  Local model path or registry query
                        (default: PERF02_MODEL or ${DEFAULT_MODEL})
  --tokens <n>         Generated tokens per sample (default: 256)
  --warmups <n>        Paired warmup rounds (default: 2)
  --runs <n>           Paired measured rounds (default: 5)
  --top-k <n>          top_logprobs width, 1..11 (default: 5)
  --prompt <text>       Override the fixed benchmark prompt
  --output <path>       Raw JSON artifact path (default: reports/perf02-*.json)
  --force               Run despite a failed machine preflight (recorded)
  --help                Show this message

The harness never downloads a model. It resolves only an existing local path
or a model already present in mlx-bun's local registry.`);
  process.exit(0);
}

function optionValue(argv: string[], name: string): string | undefined {
  const i = argv.indexOf(name);
  if (i < 0) return undefined;
  const value = argv[i + 1];
  if (!value || value.startsWith("--")) throw new Error(`${name} requires a value`);
  return value;
}

function positiveInt(value: string | undefined, fallback: number, name: string): number {
  const parsed = value === undefined ? fallback : Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0)
    throw new Error(`${name} must be a positive integer`);
  return parsed;
}

function parseCli(argv: string[]): CliOptions {
  if (argv.includes("--help") || argv.includes("-h")) usage();
  const known = new Set([
    "--model", "--tokens", "--warmups", "--runs", "--top-k", "--prompt",
    "--output", "--force", "--help", "-h",
  ]);
  for (const arg of argv) {
    if (arg.startsWith("--") && !known.has(arg))
      throw new Error(`unknown option: ${arg}`);
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const tokens = positiveInt(optionValue(argv, "--tokens"), 256, "--tokens");
  const warmups = positiveInt(optionValue(argv, "--warmups"), 2, "--warmups");
  const runs = positiveInt(optionValue(argv, "--runs"), 5, "--runs");
  const topK = positiveInt(optionValue(argv, "--top-k"), 5, "--top-k");
  if (tokens < 2) throw new Error("--tokens must be at least 2");
  if (runs < 2) throw new Error("--runs must be at least 2");
  if (topK > 11) throw new Error("--top-k must be at most 11");

  return {
    model: optionValue(argv, "--model") ?? DEFAULT_MODEL,
    tokens,
    warmups,
    runs,
    topK,
    prompt: optionValue(argv, "--prompt") ?? DEFAULT_PROMPT,
    output:
      optionValue(argv, "--output") ??
      join(REPO_ROOT, `reports/perf02-logprobs-readback-${timestamp}.json`),
    force: argv.includes("--force"),
  };
}

async function resolveLocalModel(query: string): Promise<{
  path: string;
  repoId: string | null;
}> {
  const direct = resolvePath(query);
  if (existsSync(join(direct, "config.json"))) return { path: direct, repoId: null };

  const registry = new Registry();
  try {
    try {
      const record = registry.resolve(query);
      return { path: record.path, repoId: record.repoId };
    } catch {
      // scan() only indexes local model stores; it does not download.
      await registry.scan();
      const record = registry.resolve(query);
      return { path: record.path, repoId: record.repoId };
    }
  } finally {
    registry.close();
  }
}

function percentile(sorted: number[], p: number): number | null {
  if (sorted.length === 0) return null;
  const i = Math.min(sorted.length - 1, Math.ceil(sorted.length * p) - 1);
  return sorted[i]!;
}

function distribution(values: number[]): Distribution {
  if (values.length === 0) {
    return { count: 0, min: null, p50: null, p95: null, max: null, mean: null };
  }
  const sorted = [...values].sort((a, b) => a - b);
  return {
    count: values.length,
    min: sorted[0]!,
    p50: percentile(sorted, 0.5),
    p95: percentile(sorted, 0.95),
    max: sorted.at(-1)!,
    mean: values.reduce((sum, value) => sum + value, 0) / values.length,
  };
}

function median(values: number[]): number {
  const sorted = [...values].sort((a, b) => a - b);
  const middle = sorted.length >> 1;
  return sorted.length % 2
    ? sorted[middle]!
    : (sorted[middle - 1]! + sorted[middle]!) / 2;
}

function float32Bits(value: number): string {
  const floats = new Float32Array(1);
  floats[0] = value;
  const bits = new Uint32Array(floats.buffer)[0]!;
  return `0x${bits.toString(16).padStart(8, "0")}`;
}

function armOptions(name: ArmName, topK: number): Pick<
  GenerateOptions,
  "logprobs" | "topLogprobs"
> {
  if (name === "off") return {};
  if (name === "logprobs") return { logprobs: true };
  // This mirrors the served surface: top_logprobs is requested together with
  // logprobs, retaining the selected-token value as a direct parity signal.
  return { logprobs: true, topLogprobs: topK };
}

function rotatedOrder(round: number): ArmName[] {
  return ARM_NAMES.map((_, i) => ARM_NAMES[(i + round) % ARM_NAMES.length]!);
}

async function runSample(
  model: Model,
  promptTokens: number[],
  cli: CliOptions,
  phase: Sample["phase"],
  round: number,
  order: number,
  arm: ArmName,
): Promise<Sample> {
  const generation = generate(model, promptTokens, {
    maxTokens: cli.tokens,
    temperature: 0,
    eosTokenIds: [],
    ...armOptions(arm, cli.topK),
  });
  const tokens: number[] = [];
  const yieldAtMs: number[] = [];
  const selectedLogprobs: number[] = [];
  const selectedLogprobBits: string[] = [];
  const topLogprobs: CapturedTopLogprob[][] = [];
  const started = performance.now();

  for await (const item of generation) {
    yieldAtMs.push(performance.now() - started);
    tokens.push(item.token);
    if (arm !== "off") {
      const selected = item.logprobs?.logprob;
      if (selected === undefined)
        throw new Error(`${arm} token ${item.index} did not include selected logprob`);
      selectedLogprobs.push(selected);
      selectedLogprobBits.push(float32Bits(selected));
    }
    if (arm === "top_logprobs") {
      const top = item.logprobs?.top;
      if (!top) throw new Error(`top_logprobs token ${item.index} did not include top-k values`);
      topLogprobs.push(
        top.map(({ id, logprob }) => ({
          id,
          logprob,
          float32Bits: float32Bits(logprob),
        })),
      );
    }
  }

  const totalMs = performance.now() - started;
  const stats = generation.stats;
  if (!stats) throw new Error(`${arm} generation completed without stats`);
  if (tokens.length !== cli.tokens)
    throw new Error(`${arm} emitted ${tokens.length} tokens; expected ${cli.tokens}`);
  const interTokenMs = yieldAtMs.slice(1).map((at, i) => at - yieldAtMs[i]!);

  return {
    phase,
    round,
    order,
    arm,
    totalMs,
    firstTokenMs: yieldAtMs[0]!,
    perTokenMs: totalMs / tokens.length,
    yieldAtMs,
    interTokenMs,
    interTokenSummary: distribution(interTokenMs),
    tokens,
    selectedLogprobs: arm === "off" ? null : selectedLogprobs,
    selectedLogprobBits: arm === "off" ? null : selectedLogprobBits,
    topLogprobs: arm === "top_logprobs" ? topLogprobs : null,
    stats,
  };
}

function compareNumberArrays(
  left: number[],
  right: number[],
  label: string,
  report: ParityReport,
): void {
  report.checks++;
  if (
    left.length !== right.length ||
    left.some((value, i) => value !== right[i])
  ) {
    const first = Math.max(0, left.findIndex((value, i) => value !== right[i]));
    report.failures.push(
      `${label}: mismatch at ${first} (${String(left[first])} vs ${String(right[first])})`,
    );
  }
}

function checkParity(samples: Sample[], topK: number): ParityReport {
  const report: ParityReport = {
    ok: true,
    checks: 0,
    failures: [],
    selectedComparisons: 0,
    selectedExact: 0,
    selectedMaxAbsDelta: 0,
    emittedInTopK: 0,
    emittedInTopKExact: 0,
  };
  const measured = samples.filter((sample) => sample.phase === "measure");

  for (const round of [...new Set(measured.map((sample) => sample.round))]) {
    const byArm = new Map(
      measured.filter((sample) => sample.round === round).map((sample) => [sample.arm, sample]),
    );
    const off = byArm.get("off")!;
    const selected = byArm.get("logprobs")!;
    const top = byArm.get("top_logprobs")!;
    compareNumberArrays(off.tokens, selected.tokens, `round ${round}: off vs logprobs tokens`, report);
    compareNumberArrays(off.tokens, top.tokens, `round ${round}: off vs top_logprobs tokens`, report);

    const selectedBits = selected.selectedLogprobBits!;
    const topBits = top.selectedLogprobBits!;
    report.checks++;
    for (let i = 0; i < selectedBits.length; i++) {
      report.selectedComparisons++;
      const delta = Math.abs(selected.selectedLogprobs![i]! - top.selectedLogprobs![i]!);
      report.selectedMaxAbsDelta = Math.max(report.selectedMaxAbsDelta, delta);
      if (selectedBits[i] === topBits[i]) report.selectedExact++;
      else if (report.failures.length < 20)
        report.failures.push(
          `round ${round}: selected logprob token ${i} differs ` +
          `(${selectedBits[i]} vs ${topBits[i]}, abs=${delta})`,
        );
    }

    report.checks++;
    for (let i = 0; i < top.tokens.length; i++) {
      const emitted = top.tokens[i]!;
      const match = top.topLogprobs![i]!.find((entry) => entry.id === emitted);
      if (match) report.emittedInTopK++;
      else {
        if (report.failures.length < 20)
          report.failures.push(
            `round ${round}: emitted token ${emitted} missing from top-${topK} at ${i}`,
          );
        continue;
      }
      if (match.float32Bits === top.selectedLogprobBits![i]) report.emittedInTopKExact++;
      else if (report.failures.length < 20)
        report.failures.push(
          `round ${round}: emitted token ${emitted} top-k logprob differs from selected at ${i}`,
        );
    }
  }

  // Determinism across repetitions is part of the paired design: each arm
  // should reproduce its first measured stream exactly.
  for (const arm of ARM_NAMES) {
    const armSamples = measured.filter((sample) => sample.arm === arm);
    const reference = armSamples[0]!;
    for (const sample of armSamples.slice(1)) {
      compareNumberArrays(
        reference.tokens,
        sample.tokens,
        `${arm}: token repeat 0 vs ${sample.round}`,
        report,
      );
      if (arm !== "off") {
        report.checks++;
        const expected = reference.selectedLogprobBits!;
        const actual = sample.selectedLogprobBits!;
        if (
          expected.length !== actual.length ||
          expected.some((value, i) => value !== actual[i])
        ) {
          report.failures.push(`${arm}: selected-logprob repeat 0 vs ${sample.round} differs`);
        }
      }
    }
  }

  report.ok =
    report.failures.length === 0 &&
    report.selectedComparisons === report.selectedExact &&
    report.emittedInTopK === report.emittedInTopKExact;
  return report;
}

function summarize(samples: Sample[]): Record<ArmName, {
  medianTotalMs: number;
  medianPerTokenMs: number;
  medianFirstTokenMs: number;
  medianSteadyP50Ms: number;
  medianSteadyP95Ms: number;
  medianDecodeTps: number;
  totalTimeRatioVsOff: number;
}> {
  const measured = samples.filter((sample) => sample.phase === "measure");
  const offMedian = median(
    measured.filter((sample) => sample.arm === "off").map((sample) => sample.totalMs),
  );
  return Object.fromEntries(
    ARM_NAMES.map((arm) => {
      const armSamples = measured.filter((sample) => sample.arm === arm);
      const medianTotalMs = median(armSamples.map((sample) => sample.totalMs));
      return [
        arm,
        {
          medianTotalMs,
          medianPerTokenMs: median(armSamples.map((sample) => sample.perTokenMs)),
          medianFirstTokenMs: median(armSamples.map((sample) => sample.firstTokenMs)),
          medianSteadyP50Ms: median(
            armSamples.map((sample) => sample.interTokenSummary.p50!),
          ),
          medianSteadyP95Ms: median(
            armSamples.map((sample) => sample.interTokenSummary.p95!),
          ),
          medianDecodeTps: median(armSamples.map((sample) => sample.stats.decodeTps)),
          totalTimeRatioVsOff: medianTotalMs / offMedian,
        },
      ];
    }),
  ) as ReturnType<typeof summarize>;
}

const cli = parseCli(process.argv.slice(2));
const machine = checkMachine();
if (!machine.ok && !cli.force) {
  for (const problem of machine.problems) console.error(`preflight: ${problem}`);
  throw new Error(
    "machine not clear; refusing to benchmark (reboot/close apps, or use --force and record the override)",
  );
}
if (!machine.ok) {
  console.warn("WARNING: machine preflight failed; --force override will be recorded");
  for (const problem of machine.problems) console.warn(`preflight: ${problem}`);
}

const resolvedModel = await resolveLocalModel(cli.model);
console.log(`model: ${resolvedModel.path}`);
console.log(
  `design: ${cli.warmups} paired warmup round(s), ${cli.runs} paired measured round(s), ` +
  `${cli.tokens} tokens, top-k=${cli.topK}`,
);

const config = await loadModelConfig(resolvedModel.path);
const weights = await Weights.open(resolvedModel.path);
try {
  const model = createModel(weights, config);
  const tokenizer = await loadTokenizer(resolvedModel.path);
  const template = await ChatTemplate.load(resolvedModel.path);
  const rendered = template.render([{ role: "user", content: cli.prompt }]);
  const encoded = tokenizer.encode(rendered);
  const promptTokens =
    encoded[0] === encoded[1] && encoded[0] === tokenizer.bosTokenId
      ? encoded.slice(1)
      : encoded;

  // One unmeasured tiny generation materializes lazy weights and first-use
  // kernels before any arm-specific warmup. This is not included in artifacts.
  const materialize = generate(
    model,
    promptTokens.slice(0, Math.max(1, Math.min(8, promptTokens.length - 1))),
    { maxTokens: 1, temperature: 0, eosTokenIds: [] },
  );
  for await (const _ of materialize) { /* drain */ }

  const samples: Sample[] = [];
  for (let round = 0; round < cli.warmups; round++) {
    const order = rotatedOrder(round);
    for (let i = 0; i < order.length; i++) {
      const arm = order[i]!;
      console.log(`warmup ${round + 1}/${cli.warmups}: ${arm}`);
      samples.push(await runSample(model, promptTokens, cli, "warmup", round, i, arm));
    }
  }
  for (let round = 0; round < cli.runs; round++) {
    const order = rotatedOrder(round + cli.warmups);
    for (let i = 0; i < order.length; i++) {
      const arm = order[i]!;
      console.log(`measure ${round + 1}/${cli.runs}: ${arm}`);
      samples.push(await runSample(model, promptTokens, cli, "measure", round, i, arm));
    }
  }

  const parity = checkParity(samples, cli.topK);
  const summary = summarize(samples);
  const artifact = {
    schemaVersion: 1,
    kind: "perf02-logprobs-readback",
    createdAt: new Date().toISOString(),
    commitSha: gitCommit(),
    worktreeDirty: gitWorktreeDirty(),
    bunVersion: Bun.version,
    hypothesis:
      "readExtras creates astype(float32) after the next decode step is async-dispatched, " +
      "so logprob readback may synchronize behind one full next-step computation",
    trace: {
      affected: "src/generate.ts generateInner.readExtras",
      ordering:
        "sample/asyncEval nextPending -> token readback -> readExtras(curExtras) -> yield",
      analogousFix:
        "src/mlx/array.ts MlxArray.toIntTokens reads uint32/int32 directly to avoid a cast queued behind dispatched GPU work",
    },
    cli: {
      ...cli,
      output: resolvePath(cli.output),
    },
    machine: JSON.parse(machineStateJson(machine)),
    forcedPreflight: cli.force && !machine.ok,
    model: {
      query: cli.model,
      path: resolvedModel.path,
      repoId: resolvedModel.repoId,
      modelType: config.modelType,
    },
    prompt: {
      text: cli.prompt,
      sha256: createHash("sha256").update(cli.prompt).digest("hex"),
      tokens: promptTokens.length,
    },
    method: {
      temperature: 0,
      eosTokenIds: [],
      interleaved: true,
      rotatingStartArm: true,
      arms: {
        off: {},
        logprobs: { logprobs: true },
        top_logprobs: { logprobs: true, topLogprobs: cli.topK },
      },
    },
    parity,
    summary,
    samples,
  };

  const output = resolvePath(cli.output);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, `${JSON.stringify(artifact, null, 2)}\n`);

  console.log("\nmedian measured results:");
  for (const arm of ARM_NAMES) {
    const row = summary[arm];
    console.log(
      `${arm.padEnd(14)} total ${row.medianTotalMs.toFixed(1)} ms  ` +
      `steady p50 ${row.medianSteadyP50Ms.toFixed(2)} ms/token  ` +
      `decode ${row.medianDecodeTps.toFixed(2)} tok/s  ` +
      `${row.totalTimeRatioVsOff.toFixed(3)}x off`,
    );
  }
  console.log(`parity: ${parity.ok ? "PASS" : "FAIL"} (${parity.checks} checks)`);
  console.log(`raw artifact: ${output}`);

  if (!parity.ok) {
    for (const failure of parity.failures.slice(0, 20)) console.error(`parity: ${failure}`);
    process.exitCode = 2;
  }
} finally {
  weights.dispose();
}
