// Launching capability evaluations and keeping their history. The runner is the
// existing one: this module starts `scripts/eval-serve.ts` as children (`plan`
// to pin the model, datasets and MLX library, `run` to evaluate the plan against
// a server it starts from the app's own `serve` command, `compare`, `tasks`),
// streams their output into the job's log, and reduces the finished
// `result.json` to a compact entry under its `history` storage entry. It scores
// nothing itself. Datasets are never downloaded: they must already be in the
// `data` entry (or a directory a programmatic job names) and match the runner's
// sha256 pins. Everything lands under MLX_BUN_HOME, outside the source tree,
// which the runner requires of its outputs.
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { basename, dirname, isAbsolute, join, resolve } from "node:path";
import type { JobRunner, ModelCatalog, ModelHost, StorageService } from "@mlx-bun/app-core";
import type { BenchmarkComparison, BenchmarkTask, BenchmarkTasks, EvalHistoryEntry, TaskSummary } from "./protocol";

/** The checkout this package sits in: where the runner and the app's `serve` command are. */
export const CHECKOUT = resolve(import.meta.dir, "../../..");

export interface EvalOptions {
  storage: Pick<StorageService, "path">;
  /** Names the served model when a run names none. */
  models: Pick<ModelHost, "defaultFor">;
  /** Resolves a model query to its directory. */
  catalog: Pick<ModelCatalog, "find">;
  /** The source tree the evaluated server runs from; default this checkout. */
  root?: string;
  /** `eval-serve.ts`; default the checkout's. */
  script?: string;
  /** The server the runner starts, before `--model` and `--port`; default the checkout's `mlx-bun serve`. */
  serve?: readonly string[];
  /** The MLX library the evaluated server loads; default the checkout's staged one. */
  native?: string;
  /** The Bun executable that runs the runner; default the one on PATH. */
  bun?: string;
  /** Test seam for process creation. */
  spawn?: typeof Bun.spawn;
  now?: () => number;
  /** SIGTERM first (the runner stops its server and saves the run), then SIGKILL after this. Default 70 s. */
  graceMs?: number;
}

const NAME = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;
const TASK_SPEC = /^[A-Za-z0-9][A-Za-z0-9,._-]*$/;

export function evalDirectories(storage: Pick<StorageService, "path">) {
  return { history: storage.path("history"), runs: storage.path("runs"), plans: storage.path("plans"), data: storage.path("data") };
}

// ---- history ------------------------------------------------------------------------------------

/** The parts of the runner's `result.json` the history keeps. */
interface ResultLike {
  label?: string; startedAt?: string; finishedAt?: string;
  machine?: { chip?: string; memoryBytes?: number; host?: string; os?: string };
  plan?: { value?: { enableThinking?: boolean; model?: { path?: string; repo?: string | null; revision?: string | null } } };
  tasks?: { task: string; status: TaskSummary["status"]; reason?: string; score?: { accuracy?: number; nCorrect?: number; nTotal?: number } | null; timing?: { wallMs?: number } }[];
  capability?: { score: number; components: Record<string, number>; excluded: string[] } | null;
}
const finite = (value: unknown): number | null => typeof value === "number" && Number.isFinite(value) ? value : null;

/** The scores a history view compares, and why a run was incomplete. */
export function compactResult(result: ResultLike, meta: { id: string; exitCode: number; problems: readonly string[]; runDirectory: string;
  startedAt: string; finishedAt: string | null; durationMs: number }): EvalHistoryEntry {
  const plan = result.plan?.value;
  const tasks: TaskSummary[] = (result.tasks ?? []).map(task => ({ task: task.task, status: task.status, reason: task.reason ?? null,
    accuracy: task.status === "skipped" ? null : finite(task.score?.accuracy), correct: finite(task.score?.nCorrect), total: task.status === "skipped" ? null : finite(task.score?.nTotal),
    wallMs: finite(task.timing?.wallMs) ?? 0 }));
  const machine = result.machine ? { chip: result.machine.chip ?? "", memoryBytes: result.machine.memoryBytes ?? 0, host: result.machine.host ?? "", os: result.machine.os ?? "" } : null;
  return { id: meta.id, label: result.label ?? meta.id, startedAt: result.startedAt ?? meta.startedAt, finishedAt: result.finishedAt ?? meta.finishedAt,
    durationMs: meta.durationMs, complete: meta.exitCode === 0, exitCode: meta.exitCode, problems: meta.problems,
    model: { path: plan?.model?.path ?? "", repo: plan?.model?.repo ?? null, revision: plan?.model?.revision ?? null }, enableThinking: plan?.enableThinking ?? false,
    machine, tasks, capability: result.capability ? { score: result.capability.score, components: result.capability.components, excluded: result.capability.excluded } : null,
    runDirectory: meta.runDirectory };
}

function writeAtomic(path: string, text: string) {
  mkdirSync(dirname(path), { recursive: true });
  const temporary = `${path}.${process.pid}.tmp`;
  writeFileSync(temporary, text);
  renameSync(temporary, path);
}

/** Newest first. An unreadable file is skipped, never fatal to the list. */
export function listHistory(storage: Pick<StorageService, "path">, limit = 50): EvalHistoryEntry[] {
  const { history } = evalDirectories(storage);
  if (!existsSync(history)) return [];
  const entries: EvalHistoryEntry[] = [];
  for (const file of readdirSync(history).filter(name => name.endsWith(".json"))) {
    try { entries.push(JSON.parse(readFileSync(join(history, file), "utf8")) as EvalHistoryEntry); } catch { /* skipped */ }
  }
  return entries.toSorted((a, b) => (b.startedAt < a.startedAt ? -1 : b.startedAt > a.startedAt ? 1 : 0)).slice(0, Math.max(1, limit));
}

export function readHistory(storage: Pick<StorageService, "path">, id: string): EvalHistoryEntry | undefined {
  if (!NAME.test(id)) return undefined;
  try { return JSON.parse(readFileSync(join(evalDirectories(storage).history, `${id}.json`), "utf8")) as EvalHistoryEntry; } catch { return undefined; }
}

// ---- children -----------------------------------------------------------------------------------

async function pump(stream: ReadableStream<Uint8Array> | undefined, sink: (line: string) => void): Promise<string> {
  if (!stream) return "";
  const reader = stream.getReader(), decoder = new TextDecoder();
  let buffered = "", all = "";
  // The runner redraws its per-item progress with carriage returns: each redraw is a line.
  const drain = (final: boolean) => {
    const parts = buffered.split(/\r\n|\r|\n/);
    buffered = final ? "" : parts.pop()!;
    for (const part of parts) sink(part);
  };
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      const text = decoder.decode(value, { stream: true });
      all += text; buffered += text;
      drain(false);
    }
    const rest = decoder.decode();
    all += rest; buffered += rest;
    drain(true);
  } catch { /* the stream ended with its process */ } finally { reader.releaseLock(); }
  return all;
}

interface ChildOptions { spawn: typeof Bun.spawn; cwd: string; signal?: AbortSignal; graceMs: number; onLine?: (line: string) => void }
/** Runs one child to its end; an aborted signal sends SIGTERM, then SIGKILL after the grace. */
async function child(argv: readonly string[], options: ChildOptions): Promise<{ code: number; stdout: string; stderr: string }> {
  const proc = options.spawn([...argv], { stdin: "ignore", stdout: "pipe", stderr: "pipe", cwd: options.cwd, env: process.env });
  const sink = options.onLine ?? (() => {});
  const pumps = [pump(proc.stdout as ReadableStream<Uint8Array>, sink), pump(proc.stderr as ReadableStream<Uint8Array>, sink)] as const;
  let killTimer: ReturnType<typeof setTimeout> | undefined;
  const stop = () => {
    try { proc.kill("SIGTERM"); } catch { /* already gone */ }
    killTimer = setTimeout(() => { try { proc.kill("SIGKILL"); } catch { /* already gone */ } }, options.graceMs);
  };
  if (options.signal?.aborted) stop(); else options.signal?.addEventListener("abort", stop, { once: true });
  let code: number;
  try { code = await proc.exited; }
  finally { options.signal?.removeEventListener("abort", stop); if (killTimer) clearTimeout(killTimer); }
  const [stdout, stderr] = await Promise.all(pumps);
  return { code, stdout, stderr };
}

interface Resolved { root: string; script: string; bun: string; spawn: typeof Bun.spawn; graceMs: number }
function resolved(options: EvalOptions): Resolved {
  const root = options.root ?? CHECKOUT, script = options.script ?? join(root, "scripts/eval-serve.ts");
  if (!existsSync(script)) throw new Error(`the evaluation runner needs a source checkout: ${script} is not there`);
  const bun = options.bun ?? Bun.which("bun");
  if (!bun) throw new Error("the evaluation runner needs the bun executable on PATH");
  return { root, script, bun, spawn: options.spawn ?? Bun.spawn, graceMs: options.graceMs ?? 70_000 };
}
/** Why a child failed: the runner's `error:` message (its continuation lines included, its stack not), else the last line. */
function reason(stderr: string): string {
  const lines = stderr.split("\n"), start = lines.findIndex(line => line.startsWith("error: "));
  if (start < 0) return lines.filter(line => line.trim()).at(-1)?.trim() ?? "";
  const message = [lines[start]!.slice("error: ".length)];
  for (const line of lines.slice(start + 1)) { if (!line.trim() || /^\s+at /.test(line)) break; message.push(line.trim()); }
  return message.join("; ");
}

// ---- tasks and comparison -----------------------------------------------------------------------

/** The runner's own task listing (`eval-serve.ts tasks`), with each dataset's presence in the data directory. */
export async function listTasks(options: EvalOptions): Promise<BenchmarkTasks> {
  const { root, script, bun, spawn, graceMs } = resolved(options), data = evalDirectories(options.storage).data;
  const { code, stdout, stderr } = await child([bun, script, "tasks", "--data", data], { spawn, cwd: root, graceMs });
  if (code !== 0) throw new Error(`eval-serve tasks exited ${code}: ${reason(stderr)}`);
  const { tasks } = JSON.parse(stdout) as { tasks: (Omit<BenchmarkTask, "datasets"> & { datasets: (Omit<BenchmarkTask["datasets"][number], "present"> & { present?: boolean })[] })[] };
  return { dataDirectory: data, tasks: tasks.map(task => ({ ...task, datasets: task.datasets.map(dataset => ({ ...dataset, present: dataset.present === true })) })) };
}

/** The runner's paired comparison of two finished runs, from their full `result.json` files. */
export async function compareRuns(options: EvalOptions, base: EvalHistoryEntry, candidate: EvalHistoryEntry): Promise<BenchmarkComparison> {
  const { root, script, bun, spawn, graceMs } = resolved(options);
  const files = [base, candidate].map(entry => join(entry.runDirectory, "result.json"));
  for (const file of files) if (!existsSync(file)) throw new Error(`${file} is gone: the run's directory was removed`);
  const { code, stdout, stderr } = await child([bun, script, "compare", ...files], { spawn, cwd: root, graceMs });
  // 0: both complete and comparable; 1: differences or problems, which the report lists. Anything else is a failure to compare.
  if (code !== 0 && code !== 1) throw new Error(`eval-serve compare exited ${code}: ${reason(stderr)}`);
  const names = [...new Set([...base.tasks, ...candidate.tasks].map(task => task.task))];
  const accuracy = (entry: EvalHistoryEntry, task: string) => entry.tasks.find(item => item.task === task)?.accuracy ?? null;
  return { base: base.id, candidate: candidate.id, comparable: code === 0, markdown: stdout,
    tasks: names.map(task => { const a = accuracy(base, task), b = accuracy(candidate, task); return { task, base: a, candidate: b, delta: a !== null && b !== null ? b - a : null }; }) };
}

// ---- the job ------------------------------------------------------------------------------------

/** The model a run evaluates: the one named, else the served one, resolved to its directory by the catalog. */
export async function resolveModel(options: Pick<EvalOptions, "models" | "catalog">, config: Readonly<Record<string, unknown>>): Promise<{ id: string; directory: string }> {
  const named = typeof config.model === "string" && config.model ? config.model : undefined;
  const query = named ?? await options.models.defaultFor("generate");
  if (!query) throw new Error("no model is served: name one with `model`");
  const entry = await options.catalog.find(query);
  if (!entry.operations.includes("generate")) throw new Error(`model ${entry.id} does not declare generate`);
  return { id: entry.id, directory: entry.directory };
}

/** `tasks` as the runner's `--tasks` value: ids or set names, comma separated. The runner validates them. */
export function taskSpec(config: Readonly<Record<string, unknown>>): string {
  const { tasks } = config;
  const spec = tasks === undefined ? "smoketest" : Array.isArray(tasks) && tasks.every(item => typeof item === "string") ? tasks.join(",") : tasks;
  if (typeof spec !== "string" || !TASK_SPEC.test(spec)) throw new Error("tasks must be task ids or a set name (capability, smoketest, all), comma separated");
  return spec;
}

/** The runner's own line-by-line report: `--- <task>` starts a task; a redrawn `  <task> k/n` counts items. */
const ITEMS = /^\s+(\S+) (\d+)\/(\d+)$/;

/** The `eval-serve` job: exclusive of the GPU, `plan` then `run` as children, cancelled by killing the run. */
export function createEvalRunner(options: EvalOptions): JobRunner {
  const now = options.now ?? Date.now;
  return async (emit, config, signal) => {
    const { root, script, bun, spawn, graceMs } = resolved(options);
    const directories = evalDirectories(options.storage);
    const startedAt = new Date(now());
    let plan: string, name: string;
    if (typeof config.plan === "string") {
      // Programmatic only: a plan carries paths the runner opens, so the routes never accept one.
      if (!isAbsolute(config.plan) || !config.plan.endsWith(".json") || !existsSync(config.plan)) throw new Error("plan must be an absolute path to an existing plan .json file");
      plan = config.plan; name = basename(plan, ".json");
    } else name = taskSpec(config).replace(/[^A-Za-z0-9._-]+/g, "-");
    if (!NAME.test(name)) name = "plan";
    const id = `${startedAt.toISOString().replace(/[:.]/g, "-")}-${name}`;
    const runDirectory = join(directories.runs, id);
    emit({ type: "stage", stage: "start", progress: 0, message: `evaluation ${name}` });

    if (typeof config.plan !== "string") {
      const model = await resolveModel(options, config);
      const native = typeof config.native === "string" ? config.native : options.native ?? join(root, "packages/mlx/dist/native/libmlxc.dylib");
      if (!isAbsolute(native) || !existsSync(native)) throw new Error(`the MLX library ${native} is not there: stage it (bun run --cwd packages/mlx stage:native) or name it in the job's \`native\``);
      const data = typeof config.data === "string" ? config.data : directories.data;
      if (!isAbsolute(data)) throw new Error("data must be an absolute directory");
      plan = join(directories.plans, `${id}.json`);
      mkdirSync(directories.plans, { recursive: true });
      emit({ type: "stage", stage: "plan", progress: 0, message: `pinning ${model.id} and the datasets in ${data}` });
      const made = await child([bun, script, "plan", "--out", plan, "--model", model.directory, "--data", data, "--native", native, "--tasks", taskSpec(config),
        ...(config.enableThinking === true ? ["--enable-thinking"] : [])], { spawn, cwd: root, signal, graceMs, onLine: line => { if (line) emit({ type: "log", line }); } });
      signal.throwIfAborted();
      // The runner refuses a missing dataset or one whose sha256 is not its pin, and says which.
      if (made.code !== 0) throw new Error(`the plan was not made: ${reason(made.stderr) || `eval-serve plan exited ${made.code}`}`);
    }

    let planned: string[] = [];
    try { planned = (JSON.parse(readFileSync(plan!, "utf8")) as { tasks?: string[] }).tasks ?? []; } catch { /* the runner reports an unreadable plan */ }
    const total = planned.length, problems: string[] = [];
    const server = options.serve ?? [bun, join(root, "apps/mlx-bun/bin/mlx-bun.mjs"), "serve"];
    mkdirSync(directories.runs, { recursive: true });
    const line = (text: string) => {
      if (!text) return;
      const task = /^--- (\S+)$/.exec(text), items = ITEMS.exec(text), problem = /^\s+problem: (.+)$/.exec(text);
      if (items) {
        const at = planned.indexOf(items[1]!), fraction = Number(items[2]) / Math.max(1, Number(items[3]));
        emit({ type: "stage", stage: items[1]!, progress: total && at >= 0 ? Math.min(0.99, (at + fraction) / total) : 0, message: `${items[1]} ${items[2]}/${items[3]}` });
        return;
      }
      emit({ type: "log", line: text });
      if (task) emit({ type: "stage", stage: task[1]!, progress: total && planned.includes(task[1]!) ? Math.min(0.99, planned.indexOf(task[1]!) / total) : 0, message: `task ${task[1]}` });
      if (problem) problems.push(problem[1]!);
    };
    const ran = await child([bun, script, "run", "--plan", plan!, "--root", root, "--command", JSON.stringify(server), "--out", runDirectory, "--label", id],
      { spawn, cwd: root, signal, graceMs, onLine: line });
    const finishedAt = new Date(now());
    let result: ResultLike | undefined;
    try { result = JSON.parse(readFileSync(join(runDirectory, "result.json"), "utf8")) as ResultLike; } catch { /* no record: the run failed before writing one */ }
    if (result) {
      const entry = compactResult(result, { id, exitCode: ran.code, problems, runDirectory, startedAt: startedAt.toISOString(),
        finishedAt: finishedAt.toISOString(), durationMs: finishedAt.getTime() - startedAt.getTime() });
      writeAtomic(join(directories.history, `${id}.json`), JSON.stringify(entry, null, 1));
    }
    signal.throwIfAborted();
    if (ran.code !== 0) throw new Error(result
      ? `eval-serve exited ${ran.code}: the run is incomplete${problems.length ? ` (${problems[0]})` : ""}; its record is in the history`
      : `eval-serve exited ${ran.code} before writing a result${reason(ran.stderr) ? `: ${reason(ran.stderr)}` : ""}`);
    emit({ type: "stage", stage: "done", progress: 1, message: `recorded ${id}` });
    return { outputPath: runDirectory };
  };
}
