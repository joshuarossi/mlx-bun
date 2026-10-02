// Capability evaluation over HTTP: main's intelligence suite (scripts/eval.ts
// at 02d723a: GSM8K, MMLU, IFEval, BFCL, HumanEval, HashHop@12k and the
// GSM8K-50 smoketest subset) run against any OpenAI-compatible server started
// from an explicit command, so main's `serve` and the candidate's `serve` are
// evaluated with identical data, prompts, scoring and sampling. Results live
// outside every source tree.
//
//   bun scripts/eval-serve.ts plan --out /abs/plan.json --model /abs/snapshot --data /abs/eval-data
//     --native /abs/libmlxc.dylib [--tasks all|capability|smoketest|gsm8k,mmlu,...]
//     [--enable-thinking] [--python-image python@sha256:<digest>]
//   bun scripts/eval-serve.ts run --plan /abs/plan.json --root /abs/tree
//     --command '["bun","/abs/tree/<cli>","serve"]' --out /abs/empty-dir [--label NAME]
//   bun scripts/eval-serve.ts compare /abs/baseline/result.json /abs/candidate/result.json
//
// Not ported: main's KL gate and perplexity read in-process logits, which no
// HTTP surface exposes (perplexity is scripts/perplexity.ts); the numerical
// parity suites cover numerics. See --help.
import { spawnSync } from "node:child_process";
import { appendFileSync, existsSync, mkdirSync, readFileSync, realpathSync, writeFileSync } from "node:fs";
import { basename, isAbsolute, join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { cellEnvironment, freePort, machine } from "./bench-serve";
import { loadedMlxLibraries, ServerProcess, stopAll, waitReady } from "./bench/measure";
import { checkOutputDirectory, fileSha, outsideTrees, sha256, sourceSnapshot } from "./bench/plan";
import type { ToolPin } from "./bench/report";
import { createSend, emptyStats, REQUEST_DEFAULTS, REQUEST_TIMEOUT_MS, type RequestStats } from "./eval/client";
import { checkPins, DATASETS, listTasks, makePlan, validatePlan, type DatasetPin, type EvalPlan } from "./eval/plan";
import { capabilityOf, compare, markdown, outcomeSummary, qualification, type EvalResult, type TaskResult } from "./eval/report";
import { TASKS, type PythonVerification, type ScoredSample, type Send, type TaskContext, type VerifyPython } from "./eval/tasks";

const TOOL_ROOT = resolve(import.meta.dir, "..");
const USAGE = `Capability evaluation of an OpenAI-compatible server with main's suite.

  bun scripts/eval-serve.ts plan --out /abs/plan.json --model /abs/snapshot --data /abs/eval-data
      --native /abs/libmlxc.dylib [--tasks all|capability|smoketest|<ids>] [--enable-thinking]
      [--python-image python@sha256:<digest>]
  bun scripts/eval-serve.ts run --plan /abs/plan.json --root /abs/tree --command '<JSON argv>'
      --out /abs/empty-dir [--label NAME] [--ready-timeout-ms N]
  bun scripts/eval-serve.ts compare /abs/baseline/result.json /abs/candidate/result.json
  bun scripts/eval-serve.ts tasks [--data /abs/eval-data]      # JSON: every task, its sets, datasets and pins

Tasks (main's scripts/eval.ts): capability = gsm8k mmlu ifeval bfcl humaneval hashhop, main's
default frozen sets in full; smoketest = gsm8k-50 (main's GSM8K-50 draw of the full export);
all = both. KL and perplexity need in-process logits and are not part of this runner (perplexity
is scripts/perplexity.ts); the numerical parity suites cover numerics. Requests are greedy
(temperature 0, repetition penalty disabled), non-streaming, one at a time; thinking is off unless
--enable-thinking (main's MLX_BUN_EVAL_THINK). Main's --n caps were ignored by its default frozen
sets and are not offered.

Datasets are read from --data, never downloaded, and must match the sha256 pins in
scripts/eval/plan.ts. gsm8k.jsonl comes from main's exporter, run natively in the oracle venv:
    git -C <main> show 02d723a:scripts/oracle/export-datasets.py > /tmp/export-datasets.py
    <oracle-venv>/bin/python /tmp/export-datasets.py      # main's exporter writes ~/.cache/mlx-bun/eval-data
The *_optiq_frozen.jsonl files (main's default for every task) are mlx-optiq's captured draws that
no tracked script produces: copy the pinned files from a machine that holds them or from their
published dataset revision. plan refuses a missing file or one whose content differs.

run starts the server as <command> --model <plan model> --port <free port> in a sandboxed HOME
with the plan's MLX library (MLX_BUN_LIBMLXC), evaluates the plan's tasks and stops it. Put serve
options in the command (e.g. '["bun","/abs/main/src/cli.ts","serve","--kv-quant","config"]');
main's eval defaults matched serve's defaults (bf16 KV). HumanEval executes generated programs
only through the datasets module's Docker verifier (packages/module-datasets/src/python-verifier.ts) with the
plan's --python-image; when that module, Docker or the image is unavailable, HumanEval is skipped
as unverified, never run on the host. Outputs: result.json (compact, with provenance),
samples.jsonl (per-sample detail), report.md, server.stderr.log. run exits 0 only for a complete
run of every planned task. compare flags every score difference, sample flip, skip and
provenance mismatch without a tolerance and exits 0 only when both runs are complete and
comparable; acceptance is the reviewer's.

Gate (main versus candidate, same plan, quiet machine):
    P=/abs/evals/<model>
    bun scripts/eval-serve.ts plan --out $P/plan.json --model <snapshot> --data /abs/eval-data \\
      --native <libmlxc.dylib> --python-image python@sha256:<digest>
    bun scripts/eval-serve.ts run --plan $P/plan.json --label main --root <main> \\
      --command '["bun","<main>/src/cli.ts","serve"]' --out $P/main
    bun scripts/eval-serve.ts run --plan $P/plan.json --label candidate --root <candidate> \\
      --command '["bun","<candidate>/apps/mlx-bun/bin/mlx-bun.mjs","serve"]' --out $P/candidate
    bun scripts/eval-serve.ts compare $P/main/result.json $P/candidate/result.json`;

/** The app's Docker verifier (PR #223), resolved from a checkout at run time so
 * this runner never falls back to host execution when the module is absent. */
export const VERIFIER_MODULE = "packages/module-datasets/src/python-verifier.ts";
export async function resolveVerifier(root: string, image: string | null): Promise<{ verify: VerifyPython; image: string | null } | string> {
  const path = join(root, VERIFIER_MODULE);
  if (!existsSync(path)) return `verifier unavailable: ${VERIFIER_MODULE} is not in ${root}`;
  const module = await import(path) as { PYTHON_VERIFIER_IMAGE?: string;
    createPythonVerifier?: (options: { image?: string; dockerHost?: string }) => VerifyPython };
  if (typeof module.createPythonVerifier !== "function") return `verifier unavailable: ${VERIFIER_MODULE} has no createPythonVerifier`;
  return { verify: module.createPythonVerifier({ ...(image ? { image } : {}), ...(process.env.DOCKER_HOST ? { dockerHost: process.env.DOCKER_HOST } : {}) }),
    image: image ?? module.PYTHON_VERIFIER_IMAGE ?? null };
}
/** A trivial program must verify before HumanEval generates anything. */
export async function probeVerifier(verify: VerifyPython, signal?: AbortSignal): Promise<string | null> {
  let result: PythonVerification;
  try { result = await verify("pass\n", signal); }
  catch (error) { return `verifier unavailable: probe threw ${String(error).slice(0, 300)}`; }
  return result.status === "verified" ? null
    : `verifier unavailable: probe ${result.status}${"reason" in result ? ` (${result.reason})` : ""}: ${"error" in result ? result.error : ""}`.trim();
}

/** The runner's own source by content (these scripts and their modules), so
 * two runs compare as one runner even when the checkout's other files move. */
const RUNNER_FILES = new Bun.Glob("{eval-serve.ts,bench-serve.ts,eval/**/*.ts,bench/**/*.ts}");
function runnerPin(): ToolPin {
  const scripts = join(TOOL_ROOT, "scripts"), tree = sourceSnapshot(TOOL_ROOT);
  const files = [...RUNNER_FILES.scanSync({ cwd: scripts })].sort().map(name => [name, fileSha(join(scripts, name))]);
  return { root: TOOL_ROOT, head: tree.head, clean: tree.clean, sha256: sha256(JSON.stringify(files)) };
}

function runtimeOf(argv0: string): EvalResult["server"]["runtime"] {
  const found = isAbsolute(argv0) ? argv0 : Bun.which(argv0);
  if (!found || !existsSync(found)) return null;
  const executable = realpathSync(found);
  const out = spawnSync(executable, ["--version"], { encoding: "utf8", timeout: 10_000 });
  return { executable, version: `${out.stdout ?? ""}${out.stderr ?? ""}`.trim().split("\n")[0] ?? "" };
}

export interface RunTarget { label?: string; root: string; command: string[]; out: string }
export interface RunOptions {
  readyTimeoutMs?: number;
  requestTimeoutMs?: number;
  /** HumanEval's code execution: a verifier (with its image), or why none is available.
   * Default: the app's Docker verifier in this checkout. */
  verifier?: { verify: VerifyPython; image: string | null } | string;
  /** The dataset pins results are qualified against (main's by default). */
  datasetPins?: Readonly<Record<string, DatasetPin>>;
}

export async function run(planPath: string, target: RunTarget, options: RunOptions = {}): Promise<number> {
  const planBytes = readFileSync(planPath);
  const plan: EvalPlan = validatePlan(JSON.parse(planBytes.toString("utf8")));
  if (!isAbsolute(target.root) || !existsSync(target.root)) throw new Error("--root must be an existing absolute path");
  const root = resolve(target.root);
  if (!Array.isArray(target.command) || !target.command.length || target.command.some(part => typeof part !== "string" || !part))
    throw new Error("--command must be a JSON array of strings");
  // The command must start this tree, not some other checkout.
  if (!target.command.some(part => isAbsolute(part) && existsSync(part) && resolve(part).startsWith(root + "/")))
    throw new Error(`--command does not name a file inside ${root}`);
  const out = checkOutputDirectory(target.out, [root, TOOL_ROOT]);
  mkdirSync(out, { recursive: true });
  const snapshot = (dir: string) => { const s = sourceSnapshot(dir); return { root: dir, head: s.head, clean: s.clean, sha256: s.sha256 }; };
  const record: EvalResult = {
    schema: 1, kind: "capability-eval-result", label: target.label ?? basename(root), startedAt: new Date().toISOString(),
    runner: { argv: process.argv, start: runnerPin() }, tree: { root, start: snapshot(root) },
    server: { command: null, runtime: null, readyMs: null, models: null, loadedLibraries: null, processes: [], stderrTail: [] },
    plan: { path: resolve(planPath), sha256: sha256(planBytes), value: plan }, machine: machine(),
    request: { defaults: REQUEST_DEFAULTS, seed: "none sent: greedy decoding consumes no seed; selection seeds are in task settings",
      timeoutMs: options.requestTimeoutMs ?? REQUEST_TIMEOUT_MS, concurrency: 1,
      executionShape: "one non-streaming request in flight, tasks and items in plan order" },
    verifier: { available: false, detail: "not needed: no planned task executes code" },
    pins: { start: [] }, tasks: [], capability: null, detail: "samples.jsonl",
  };
  const save = () => writeFileSync(join(out, "result.json"), JSON.stringify(record, null, 1));
  const samplesPath = join(out, record.detail);
  writeFileSync(samplesPath, "");
  const abort = new AbortController();
  let server: ServerProcess | null = null, cleanup: Promise<unknown> = Promise.resolve();
  const onSignal = (signal: NodeJS.Signals) => {
    if (record.interrupted) return;
    record.interrupted = signal;
    abort.abort(new Error(signal));
    cleanup = stopAll();
  };
  for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"] as const) process.on(signal, onSignal);
  const caffeinate = Bun.spawn(["caffeinate", "-dimsu", "-w", String(process.pid)], { stdio: ["ignore", "ignore", "ignore"] });
  caffeinate.unref();
  try {
    save();
    const start = checkPins(plan);
    record.pins.start = start.problems;
    if (start.problems.length) record.fatal = "pinned inputs did not verify at start";
    const ctx: TaskContext = { chatTemplate: plan.model.chatTemplate, enableThinking: plan.enableThinking };
    let verify: VerifyPython | null = null;
    if (!record.fatal && plan.tasks.some(task => TASKS[task].needsVerifier)) {
      const resolved = options.verifier ?? await resolveVerifier(TOOL_ROOT, plan.pythonImage);
      const problem = typeof resolved === "string" ? resolved : await probeVerifier(resolved.verify, abort.signal);
      if (typeof resolved !== "string" && !problem) verify = resolved.verify;
      record.verifier = { available: !problem, detail: problem ?? `probe verified with image ${typeof resolved === "string" ? "" : resolved.image}` };
    }
    const port = await freePort(), base = `http://127.0.0.1:${port}`;
    const sandbox = join(out, "sandbox");
    if (!record.fatal) {
      record.server.command = [...target.command, "--model", plan.model.path, "--port", String(port)];
      record.server.runtime = runtimeOf(target.command[0]!);
      console.log(`=== ${record.label}: ${record.server.command.join(" ")}`);
      server = new ServerProcess(record.server.command, cellEnvironment(sandbox, plan.native.library), record.server.stderrTail,
        join(out, "server.stderr.log"), sandbox);
      const alive = () => { if (!server!.running) throw new Error(`server exited before ready: code=${server!.exitCode} signal=${server!.signalCode}`); };
      try {
        record.server.readyMs = await waitReady(base, undefined, options.readyTimeoutMs ?? 600_000, alive, abort.signal);
        record.server.models = await (await fetch(`${base}/v1/models`, { signal: AbortSignal.timeout(10_000) })).json();
      } catch (error) { record.fatal = `server did not become ready: ${String(error).slice(0, 300)}`; }
    }
    save();
    for (const id of plan.tasks) {
      const def = TASKS[id]!;
      const entry: TaskResult = { task: id, component: def.component, status: "skipped",
        datasets: def.datasets.map(name => ({ name, sha256: plan.data.files.find(f => f.name === name)!.sha256 })),
        settings: def.settings(ctx), score: null, outcomes: "", errors: [], timing: { wallMs: 0, ...emptyStats() } };
      record.tasks.push(entry);
      if (record.fatal || abort.signal.aborted) { entry.reason = `not run: ${record.fatal ?? "interrupted"}`; save(); continue; }
      if (def.needsVerifier && !verify) { entry.reason = record.verifier.detail; save(); continue; }
      console.log(`--- ${id}`);
      const items = def.select(start.rows), samples: ScoredSample[] = [];
      let stats: RequestStats = emptyStats(), requests: Array<{ route: string; sha256: string }> = [];
      const sendHttp = createSend(base, plan.model.path, () => stats, options.requestTimeoutMs);
      const send: Send = (request, signal) => {
        requests.push({ route: request.route, sha256: sha256(JSON.stringify(request.body)) });
        return sendHttp(request, signal);
      };
      const t0 = performance.now();
      for (let k = 0; k < items.length; k++) {
        const itemId = def.itemId(items[k], k);
        if (record.fatal || abort.signal.aborted) { entry.outcomes += "-"; samples.push({ outcome: "E" }); continue; }
        requests = [];
        try {
          const result = await def.run(items[k], k, { send, ctx, ...(verify ? { verify } : {}), signal: abort.signal });
          entry.outcomes += result.outcome;
          samples.push(result);
          appendFileSync(samplesPath, JSON.stringify({ task: id, index: k, id: itemId, outcome: result.outcome, requests, ...result.detail }) + "\n");
        } catch (error) {
          samples.push({ outcome: "E" });
          if (abort.signal.aborted) { entry.outcomes += "-"; continue; }
          const message = String(error).slice(0, 500);
          entry.outcomes += "E";
          entry.errors.push({ index: k, id: itemId, error: message });
          appendFileSync(samplesPath, JSON.stringify({ task: id, index: k, id: itemId, outcome: "E", requests, error: message }) + "\n");
          // A dead server fails every later request: stop evaluating (its exit can trail the socket).
          if (server && await Promise.race([server.exited.then(() => true), Bun.sleep(1_000).then(() => false)]))
            record.fatal = `server exited (code ${server.exitCode}, signal ${server.signalCode}) during ${id} item ${k}`;
        }
        if ((k + 1) % 25 === 0 || k + 1 === items.length) process.stderr.write(`\r  ${id} ${k + 1}/${items.length}`);
      }
      process.stderr.write("\n");
      entry.score = def.score(items, samples);
      entry.timing = { wallMs: performance.now() - t0, ...stats };
      entry.status = /[EU-]/.test(entry.outcomes) ? "incomplete" : "complete";
      if (entry.status === "incomplete") entry.reason = outcomeSummary(entry.outcomes);
      console.log(`${id}: ${(entry.score.accuracy * 100).toFixed(2)}% (${entry.status})`);
      save();
    }
    if (server?.running) record.server.loadedLibraries = loadedMlxLibraries(server.pid, plan.native.files.map(file => file.name));
  } finally {
    if (server) record.server.processes.push({ pid: server.pid, ...await server.stop() });
    await cleanup;
    caffeinate.kill();
    for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"] as const) process.off(signal, onSignal);
  }
  record.pins.end = checkPins(plan).problems;
  record.runner.end = runnerPin();
  record.tree.end = snapshot(root);
  record.capability = capabilityOf(plan, record.tasks);
  record.finishedAt = new Date().toISOString();
  save();
  const pins = options.datasetPins ?? DATASETS;
  writeFileSync(join(out, "report.md"), markdown(record, pins));
  const q = qualification(record, pins);
  console.log(`${q.complete ? "COMPLETE" : "INCOMPLETE"} (${record.label}; score acceptance unreviewed) → ${out}`);
  for (const problem of q.problems) console.log(`  problem: ${problem}`);
  return record.interrupted ? 130 : q.complete ? 0 : 1;
}

function parseCommand(value: string | undefined): string[] {
  if (!value) throw new Error("--command is required");
  const parsed = JSON.parse(value);
  if (!Array.isArray(parsed) || !parsed.length || parsed.some(part => typeof part !== "string" || !part))
    throw new Error("--command must be a JSON array of strings");
  return parsed;
}

async function main(argv: string[]) {
  const [command, ...rest] = argv;
  if (command === "plan") {
    const { values } = parseArgs({ args: rest, options: { out: { type: "string" }, model: { type: "string" }, data: { type: "string" },
      native: { type: "string" }, tasks: { type: "string" }, "enable-thinking": { type: "boolean", default: false },
      "python-image": { type: "string" } } });
    if (!values.out || !isAbsolute(values.out)) throw new Error("--out must be an absolute file path");
    outsideTrees(values.out, [TOOL_ROOT]);
    const plan = makePlan({ model: values.model!, data: values.data!, native: values.native!, tasks: values.tasks,
      enableThinking: values["enable-thinking"], ...(values["python-image"] ? { pythonImage: values["python-image"] } : {}) });
    writeFileSync(values.out, JSON.stringify(plan, null, 1));
    console.log(`plan → ${values.out}: ${plan.tasks.join(", ")}; model ${plan.model.path} (chat template ${plan.model.chatTemplate ? "yes" : "no"}); ` +
      `${plan.data.files.length} pinned datasets`);
    return 0;
  }
  if (command === "run") {
    const { values } = parseArgs({ args: rest, options: { plan: { type: "string" }, root: { type: "string" }, command: { type: "string" },
      out: { type: "string" }, label: { type: "string" }, "ready-timeout-ms": { type: "string" } } });
    if (!values.plan || !values.root || !values.out) throw new Error("run needs --plan, --root, --command and --out");
    return run(values.plan, { root: values.root, command: parseCommand(values.command), out: values.out,
      ...(values.label ? { label: values.label } : {}) },
    values["ready-timeout-ms"] ? { readyTimeoutMs: Number(values["ready-timeout-ms"]) } : {});
  }
  if (command === "tasks") {
    const { values } = parseArgs({ args: rest, options: { data: { type: "string" } } });
    if (values.data && !isAbsolute(values.data)) throw new Error("--data must be an absolute path");
    console.log(JSON.stringify({ tasks: listTasks(values.data) }, null, 1));
    return 0;
  }
  if (command === "compare") {
    if (rest.length !== 2) throw new Error("compare needs a baseline and a candidate result.json");
    const [a, b] = rest.map(path => JSON.parse(readFileSync(path!, "utf8")) as EvalResult);
    const result = compare(a!, b!);
    console.log(result.markdown);
    return result.problems.length ? 1 : 0;
  }
  console.log(USAGE);
  return command === "--help" || command === "help" || command === "-h" ? 0 : 2;
}

if (import.meta.main) process.exit(await main(process.argv.slice(2)));
