// Paired serve benchmark: a baseline tree and a candidate tree, each started
// through its own explicit command, measured over HTTP exactly as main's
// scripts/bench-serve.ts measured (same phases, samples and budgets), with
// labeled external reference servers. Captures live outside every source tree.
//
//   bun scripts/bench-serve.ts plan --out /abs/plan.json --profile all|scoped [--seed S]
//     --baseline-root DIR --baseline-command '["bun","DIR/src/cli.ts","serve"]'
//     --candidate-root DIR --candidate-command '["bun","DIR/apps/mlx-bun/bin/mlx-bun.mjs","serve"]'
//     --native /abs/libmlxc.dylib --model ID=PATH[=LABEL] ...
//     [--reference 'LABEL={"command":[...],"registerCommand":[...],"version":"..."}' ...]
//     [--configurations default,serial,mixed] [--skip-context]
//   bun scripts/bench-serve.ts run --plan /abs/plan.json --out /abs/empty-dir
//   bun scripts/bench-serve.ts compare /abs/run/run.json
//
// `run` exits nonzero unless every applicable cell measured every required
// phase with stable decode, verified provenance and equal probe prompts.
// Performance acceptance stays unreviewed: the report flags every slower or
// higher-memory observation and never applies a tolerance.
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { hostname, release } from "node:os";
import { isAbsolute, join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { runCell, stopAll, type Workload } from "./bench/measure";
import { cellArgs, checkOutputDirectory, CONFIGURATIONS, describeModel, nativeFiles, outsideTrees, pinProblems, planCells,
  sourceSnapshot, validatePlan, WORKLOAD, type Configuration, type Plan, type ReferenceSpec, type Tree } from "./bench/plan";
import { markdown, qualification, type CellRecord, type RunRecord } from "./bench/report";

const TOOL_ROOT = resolve(import.meta.dir, "..");
const USAGE = `Paired serve benchmark: baseline tree versus candidate tree over real HTTP.

  bun scripts/bench-serve.ts plan --out /abs/plan.json --profile all|scoped [--seed S]
      --baseline-root DIR --baseline-command '["bun","DIR/src/cli.ts","serve"]'
      --candidate-root DIR --candidate-command '["bun","DIR/apps/mlx-bun/bin/mlx-bun.mjs","serve"]'
      --native /abs/libmlxc.dylib --model ID=/abs/snapshot[=LABEL] ...
      [--reference 'LABEL={"command":["PY","-m","mlx_lm.server"],"registerCommand":[...],"version":"..."}' ...]
      [--configurations default,serial,mixed] [--skip-context]
  bun scripts/bench-serve.ts run --plan /abs/plan.json --out /abs/empty-dir [--ready-timeout-ms N]
  bun scripts/bench-serve.ts compare /abs/run-dir/run.json

Profile all must be main's full matrix (cpm5, e4b, 12B, qwen27b × default, serial, mixed, plus the
mlx-lm reference); anything narrower is scoped and never full qualification. Outputs must lie outside
every tree. run exits 0 only when every applicable cell measured every required phase with stable
decode, verified library provenance and matching probes; performance acceptance stays unreviewed.`;

function machine(): RunRecord["machine"] {
  const sysctl = (name: string) => Bun.spawnSync(["sysctl", "-n", name]).stdout.toString().trim();
  return { chip: sysctl("machdep.cpu.brand_string"), memoryBytes: Number(sysctl("hw.memsize")),
    loadAverage: sysctl("vm.loadavg"), host: hostname(), os: release(), bun: Bun.version };
}

async function freePort(): Promise<number> {
  const listener = Bun.listen({ hostname: "127.0.0.1", port: 0, socket: { data() {} } });
  const { port } = listener;
  listener.stop(true);
  return port;
}

/** A cell's environment: a sandbox HOME and caches, offline, and the intended
 * library (intent only; the loaded library is observed from the process). */
function cellEnvironment(sandbox: string, library: string | null): Record<string, string> {
  for (const sub of ["home", "tmp", "cache", "config", "data", "hf"]) mkdirSync(join(sandbox, sub), { recursive: true });
  return { PATH: process.env.PATH ?? "", LANG: process.env.LANG ?? "en_US.UTF-8", HOME: join(sandbox, "home"),
    TMPDIR: join(sandbox, "tmp"), XDG_CACHE_HOME: join(sandbox, "cache"), XDG_CONFIG_HOME: join(sandbox, "config"),
    XDG_DATA_HOME: join(sandbox, "data"), HF_HOME: join(sandbox, "hf"), HF_HUB_OFFLINE: "1", TRANSFORMERS_OFFLINE: "1",
    ...(library ? { MLX_BUN_LIBMLXC: library } : {}) };
}

export async function run(planPath: string, outDir: string, options: { readyTimeoutMs?: number; settleMs?: number } = {}): Promise<number> {
  const plan = validatePlan(JSON.parse(readFileSync(planPath, "utf8")));
  const out = checkOutputDirectory(outDir, [plan.trees.baseline.root, plan.trees.candidate.root, TOOL_ROOT]);
  mkdirSync(join(out, "logs"), { recursive: true });
  const toolPin = () => { const snapshot = sourceSnapshot(TOOL_ROOT);
    return { root: TOOL_ROOT, head: snapshot.head, clean: snapshot.clean, sha256: snapshot.sha256 }; };
  const record: RunRecord = { schema: 1, tool: { start: toolPin() }, plan, machine: machine(),
    startedAt: new Date().toISOString(), pins: { start: pinProblems(plan) }, cells: [], requests: [] };
  const save = () => writeFileSync(join(out, "run.json"), JSON.stringify(record, null, 1));
  const finish = () => {
    record.tool.end = toolPin();
    save();
    writeFileSync(join(out, "report.md"), markdown(record));
    const q = qualification(record);
    console.log(`${q.complete ? "COMPLETE" : "INCOMPLETE"} (${q.profile}; full qualification ${q.fullQualification ? "yes" : "no"}; performance acceptance unreviewed) → ${out}`);
    for (const problem of q.problems) console.log(`  problem: ${problem}`);
    return q.complete ? 0 : 1;
  };
  // A signal stops every live server group (unblocking the running cell);
  // the main flow then records the cell, saves and exits 130.
  let interrupted = false, cleanup: Promise<void> = Promise.resolve();
  const abort = new AbortController();
  const onSignal = (signal: NodeJS.Signals) => {
    if (interrupted) return;
    interrupted = true;
    record.interrupted = signal;
    abort.abort(new Error(signal)); // no retry or respawn once interrupted
    cleanup = stopAll().then(stops => { record.interruptCleanup = stops; });
    setTimeout(() => { finish(); process.exit(130); }, 60_000).unref();
  };
  for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"] as const) process.on(signal, onSignal);
  save();
  if (record.pins.start.length) { record.finishedAt = new Date().toISOString(); return finish(); }
  const caffeinate = Bun.spawn(["caffeinate", "-dimsu", "-w", String(process.pid)], { stdio: ["ignore", "ignore", "ignore"] });
  caffeinate.unref();
  const workload: Workload = { seed: plan.seed, ...plan.workload };
  let fatal = false;
  for (const cell of planCells(plan)) {
    if (interrupted) break;
    const entry: CellRecord = { key: cell.key, model: cell.model, kind: cell.kind, order: cell.order, command: null,
      intendedLibrary: cell.kind === "tree" ? plan.native.library : null,
      ...(cell.tree ? { tree: cell.tree } : {}), ...(cell.configuration ? { configuration: cell.configuration } : {}),
      ...(cell.reference ? { reference: cell.reference } : {}), ...(cell.skipped ? { skipped: cell.skipped } : {}) };
    record.cells.push(entry);
    if (cell.skipped) { save(); continue; }
    const safe = cell.key.replaceAll("/", "-"), ssd = mkdtempSync(join(out, `ssd-${safe}-`));
    try {
      const port = await freePort();
      entry.command = cellArgs(plan, cell, port, ssd);
      console.log(`=== ${cell.key} ===`);
      entry.result = await runCell({ key: cell.key, model: plan.models.find(m => m.id === cell.model)!, command: entry.command,
        env: cellEnvironment(join(out, "sandboxes", safe), entry.intendedLibrary), cwd: join(out, "sandboxes", safe), port,
        ...(cell.kind === "reference" && plan.references.find(r => r.label === cell.reference)?.apiKey
          ? { apiKey: plan.references.find(r => r.label === cell.reference)!.apiKey } : {}),
        flushBeforeRestart: cell.kind === "tree", logPath: join(out, "logs", `${safe}.stderr.log`),
        pinnedLibraries: plan.native.files.map(file => file.name) }, workload, record.requests,
        { ...options, signal: abort.signal });
    } catch (error) {
      const detail = error as { processes?: NonNullable<CellRecord["failure"]>["processes"]; stderrTail?: string[] };
      entry.failure = { error: String(error).slice(0, 500), stderrTail: detail.stderrTail ?? [], ...(detail.processes ? { processes: detail.processes } : {}) };
      console.log(`  FAILED: ${entry.failure.error.slice(0, 200)}`);
      // A server that could not be joined may still hold the GPU: stop the campaign.
      if ((error as Error).name === "UnjoinedServerError") { fatal = true; record.fatal = String(error); }
    } finally { rmSync(ssd, { recursive: true, force: true }); save(); }
    if (fatal) break;
  }
  caffeinate.kill();
  if (interrupted) {
    await cleanup;
    record.interruptCleanup = [...(record.interruptCleanup ?? []), ...await stopAll()];
    finish();
    return 130;
  }
  record.pins.end = pinProblems(plan);
  record.finishedAt = new Date().toISOString();
  return finish();
}

function parseCommand(name: string, value: string | undefined): string[] {
  if (!value) throw new Error(`--${name} is required`);
  const parsed = JSON.parse(value);
  if (!Array.isArray(parsed) || !parsed.length || parsed.some(part => typeof part !== "string" || !part))
    throw new Error(`--${name} must be a JSON array of strings`);
  return parsed;
}

export function makePlan(args: string[]): Plan {
  const { values } = parseArgs({ args, options: {
    out: { type: "string" }, profile: { type: "string" }, seed: { type: "string", default: "bench-serve-v2" },
    "baseline-root": { type: "string" }, "baseline-command": { type: "string" },
    "candidate-root": { type: "string" }, "candidate-command": { type: "string" },
    native: { type: "string" }, model: { type: "string", multiple: true }, reference: { type: "string", multiple: true },
    configurations: { type: "string", default: "default,serial,mixed" }, "skip-context": { type: "boolean", default: false },
  } });
  const trees = Object.fromEntries((["baseline", "candidate"] as Tree[]).map(tree => {
    const root = values[`${tree}-root`];
    if (!root || !isAbsolute(root) || !existsSync(root)) throw new Error(`--${tree}-root must be an existing absolute path`);
    const command = parseCommand(`${tree}-command`, values[`${tree}-command`]);
    // The command must start this tree, not some other checkout.
    if (!command.some(part => isAbsolute(part) && existsSync(part) && resolve(part).startsWith(resolve(root) + "/")))
      throw new Error(`--${tree}-command does not name a file inside ${root}`);
    return [tree, { root: resolve(root), commit: sourceSnapshot(root).head, command }];
  })) as Plan["trees"];
  const references: ReferenceSpec[] = (values.reference ?? []).map(spec => {
    const at = spec.indexOf("=");
    const body = JSON.parse(spec.slice(at + 1)) as Omit<ReferenceSpec, "label">;
    return { label: spec.slice(0, at), command: body.command, ...(body.registerCommand ? { registerCommand: body.registerCommand } : {}),
      ...(body.version ? { version: body.version } : {}), ...(body.apiKey ? { apiKey: body.apiKey } : {}) };
  });
  if (!values.native) throw new Error("--native is required");
  const models = (values.model ?? []).map(spec => { const [id, path, label] = spec.split("="); return describeModel(id!, path!, label); });
  const partial = { schema: 1 as const, profile: values.profile as Plan["profile"], seed: values.seed!,
    workload: { ...WORKLOAD, withContext: !values["skip-context"] }, trees, references,
    configurations: values.configurations!.split(",") as Configuration[], models,
    native: { library: resolve(values.native), files: nativeFiles(values.native) }, cells: [] };
  for (const name of partial.configurations) if (!(name in CONFIGURATIONS)) throw new Error(`unknown configuration ${name}`);
  const plan = { ...partial, cells: planCells(partial as Plan) };
  return validatePlan(plan);
}

async function main(argv: string[]) {
  const [command, ...rest] = argv;
  if (command === "plan") {
    const out = parseArgs({ args: rest, options: { out: { type: "string" } }, strict: false }).values.out as string | undefined;
    if (!out || !isAbsolute(out)) throw new Error("--out must be an absolute file path");
    const plan = makePlan(rest);
    outsideTrees(out, [plan.trees.baseline.root, plan.trees.candidate.root, TOOL_ROOT]);
    writeFileSync(out, JSON.stringify(plan, null, 1));
    const applicable = plan.cells.filter(cell => !cell.skipped).length;
    console.log(`plan → ${out}: ${plan.profile}, ${applicable} applicable cells, ${plan.cells.length - applicable} not applicable`);
    for (const cell of plan.cells.filter(c => c.skipped)) console.log(`  N/A ${cell.key}: ${cell.skipped}`);
    return 0;
  }
  if (command === "run") {
    const { values } = parseArgs({ args: rest, options: { plan: { type: "string" }, out: { type: "string" },
      "ready-timeout-ms": { type: "string" } } });
    if (!values.plan || !values.out) throw new Error("run needs --plan and --out");
    return run(values.plan, values.out, values["ready-timeout-ms"] ? { readyTimeoutMs: Number(values["ready-timeout-ms"]) } : {});
  }
  if (command === "compare") {
    const record = JSON.parse(readFileSync(rest[0]!, "utf8")) as RunRecord;
    console.log(markdown(record));
    return qualification(record).complete ? 0 : 1;
  }
  console.log(USAGE);
  return command === "--help" || command === "help" || command === "-h" ? 0 : 2;
}

if (import.meta.main) process.exit(await main(process.argv.slice(2)));
