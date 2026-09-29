// Launching `scripts/bench-serve.ts` runs and keeping their history. The runner
// is the existing one: this module starts `bench-serve.ts run --plan <plan>
// --out <dir>` as a child, streams its output into the job's log, and reduces
// the finished `run.json` to a compact entry under its `history` storage
// entry. Plans (the benchmark's own `plan` output) are read from the `bench`
// entry's `plans/` directory or named by absolute path; each run's full record
// stays in `bench/runs/<id>/`. Everything lives under MLX_BUN_HOME, outside
// the source tree, which bench-serve requires of its outputs.
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { basename, dirname, isAbsolute, join, resolve } from "node:path";
import type { JobRunner, StorageService } from "@mlx-bun/app-core";
import type { BenchCell, BenchHistoryEntry, BenchProfile } from "./protocol";

/** The checkout's benchmark runner, when this package sits in one. */
export const DEFAULT_SCRIPT = resolve(import.meta.dir, "../../../scripts/bench-serve.ts");

export interface BenchOptions {
  storage: Pick<StorageService, "path">;
  /** `bench-serve.ts`; default the checkout's. */
  script?: string;
  /** The Bun executable that runs it; default the one on PATH. */
  bun?: string;
  /** Test seam for process creation. */
  spawn?: typeof Bun.spawn;
  now?: () => number;
  /** SIGTERM first (bench-serve stops its servers and saves the run), then SIGKILL after this. Default 70 s. */
  graceMs?: number;
}

const NAME = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;

export function benchDirectories(storage: Pick<StorageService, "path">) {
  const bench = storage.path("bench");
  return { plans: join(bench, "plans"), runs: join(bench, "runs"), history: storage.path("history") };
}

const median = (values: readonly number[]): number | null => {
  if (!values.length) return null;
  const sorted = values.toSorted((a, b) => a - b), middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[middle]! : (sorted[middle - 1]! + sorted[middle]!) / 2;
};
const numbers = (value: unknown): number[] => Array.isArray(value) ? value.filter((item): item is number => typeof item === "number" && Number.isFinite(item)) : [];
const finite = (value: unknown): number | null => typeof value === "number" && Number.isFinite(value) ? value : null;

/** The plans a run can start from: JSON files in `plans/`, by name. */
export function listProfiles(storage: Pick<StorageService, "path">): BenchProfile[] {
  const { plans } = benchDirectories(storage);
  if (!existsSync(plans)) return [];
  const profiles: BenchProfile[] = [];
  for (const file of readdirSync(plans).filter(name => name.endsWith(".json")).sort()) {
    const name = file.slice(0, -".json".length);
    if (!NAME.test(name)) continue;
    try {
      const plan = JSON.parse(readFileSync(join(plans, file), "utf8")) as { profile?: unknown; models?: { id?: unknown }[] };
      profiles.push({ name, path: join(plans, file), scope: typeof plan.profile === "string" ? plan.profile : null,
        models: (plan.models ?? []).flatMap(model => typeof model.id === "string" ? [model.id] : []) });
    } catch { profiles.push({ name, path: join(plans, file), scope: null, models: [] }); }
  }
  return profiles;
}

interface RunRecordLike {
  plan?: { profile?: string };
  machine?: { chip?: string; memoryBytes?: number; host?: string; os?: string };
  startedAt?: string; finishedAt?: string;
  cells?: {
    key: string; model: string; kind: "tree" | "reference"; tree?: string; configuration?: string; reference?: string; skipped?: string;
    failure?: { error?: string };
    result?: {
      coldStartMs?: number | null; peakRssMB?: number; decodeTps?: number[] | null;
      ttft?: { coldMs?: number[]; prefill1kTps?: number[] } | null; ctx?: { prefillTps?: number } | null; agg?: { tps?: number } | null;
    };
  }[];
}

/** The numbers a history view compares: medians per cell, the run's identity, and why it was incomplete. */
export function compactRun(run: RunRecordLike, meta: { id: string; profile: string; exitCode: number; problems: readonly string[]; runDirectory: string;
  startedAt: string; finishedAt: string | null; durationMs: number }): BenchHistoryEntry {
  const cells: BenchCell[] = (run.cells ?? []).map(cell => {
    const base = { key: cell.key, model: cell.model, kind: cell.kind, ...(cell.tree ? { tree: cell.tree } : {}),
      ...(cell.configuration ? { configuration: cell.configuration } : {}), ...(cell.reference ? { reference: cell.reference } : {}) };
    const empty = { decodeTokensPerSecond: null, ttftColdMs: null, prefill1kTokensPerSecond: null, contextPrefillTokensPerSecond: null,
      aggregateTokensPerSecond: null, coldStartMs: null, peakRssMB: null };
    if (cell.skipped) return { ...base, status: "skipped", note: cell.skipped, ...empty };
    const result = cell.result;
    if (cell.failure || !result) return { ...base, status: "failed", note: cell.failure?.error ?? "no result recorded", ...empty };
    return { ...base, status: "measured",
      decodeTokensPerSecond: median(numbers(result.decodeTps)), ttftColdMs: median(numbers(result.ttft?.coldMs)),
      prefill1kTokensPerSecond: median(numbers(result.ttft?.prefill1kTps)), contextPrefillTokensPerSecond: finite(result.ctx?.prefillTps),
      aggregateTokensPerSecond: finite(result.agg?.tps), coldStartMs: finite(result.coldStartMs), peakRssMB: finite(result.peakRssMB) };
  });
  const machine = run.machine ? { chip: run.machine.chip ?? "", memoryBytes: run.machine.memoryBytes ?? 0, host: run.machine.host ?? "", os: run.machine.os ?? "" } : null;
  return { id: meta.id, profile: meta.profile, scope: run.plan?.profile ?? "unknown", startedAt: run.startedAt ?? meta.startedAt,
    finishedAt: run.finishedAt ?? meta.finishedAt, durationMs: meta.durationMs, complete: meta.exitCode === 0, exitCode: meta.exitCode,
    problems: meta.problems, machine, runDirectory: meta.runDirectory, cells };
}

function writeAtomic(path: string, text: string) {
  mkdirSync(dirname(path), { recursive: true });
  const temporary = `${path}.${process.pid}.tmp`;
  writeFileSync(temporary, text);
  renameSync(temporary, path);
}

/** Newest first. An unreadable file is skipped, never fatal to the list. */
export function listHistory(storage: Pick<StorageService, "path">, limit = 50): BenchHistoryEntry[] {
  const { history } = benchDirectories(storage);
  if (!existsSync(history)) return [];
  const entries: BenchHistoryEntry[] = [];
  for (const file of readdirSync(history).filter(name => name.endsWith(".json"))) {
    try { entries.push(JSON.parse(readFileSync(join(history, file), "utf8")) as BenchHistoryEntry); } catch { /* skipped */ }
  }
  return entries.toSorted((a, b) => (b.startedAt < a.startedAt ? -1 : b.startedAt > a.startedAt ? 1 : 0)).slice(0, Math.max(1, limit));
}

export function readHistory(storage: Pick<StorageService, "path">, id: string): BenchHistoryEntry | undefined {
  if (!NAME.test(id)) return undefined;
  try { return JSON.parse(readFileSync(join(benchDirectories(storage).history, `${id}.json`), "utf8")) as BenchHistoryEntry; } catch { return undefined; }
}

/** A plan file for a run: a profile by name, or an absolute path. */
export function resolvePlan(storage: Pick<StorageService, "path">, config: Readonly<Record<string, unknown>>): { name: string; path: string } {
  const { profile, plan } = config;
  if (typeof profile === "string" && typeof plan === "string") throw new Error("name a profile or a plan, not both");
  if (typeof profile === "string") {
    if (!NAME.test(profile)) throw new Error(`invalid profile name "${profile}"`);
    const path = join(benchDirectories(storage).plans, `${profile}.json`);
    if (!existsSync(path)) throw new Error(`no profile "${profile}": create it with \`bun scripts/bench-serve.ts plan --out ${path} …\``);
    return { name: profile, path };
  }
  if (typeof plan === "string") {
    if (!isAbsolute(plan) || !plan.endsWith(".json")) throw new Error("plan must be an absolute path to a plan .json file");
    if (!existsSync(plan)) throw new Error(`no plan file at ${plan}`);
    const name = basename(plan, ".json");
    return { name: NAME.test(name) ? name : "plan", path: plan };
  }
  throw new Error("name a profile (a plan in the bench plans directory) or an absolute plan path");
}

function plannedCells(path: string): number {
  try {
    const plan = JSON.parse(readFileSync(path, "utf8")) as { cells?: { skipped?: string }[] };
    return (plan.cells ?? []).filter(cell => !cell.skipped).length;
  } catch { return 0; }
}

/** The `bench-serve` job: exclusive of the GPU, one child, cancelled by killing it. */
export function createBenchRunner(options: BenchOptions): JobRunner {
  const script = options.script ?? DEFAULT_SCRIPT, now = options.now ?? Date.now, graceMs = options.graceMs ?? 70_000;
  return async (emit, config, signal) => {
    if (!existsSync(script)) throw new Error(`bench-serve needs a source checkout: ${script} is not there`);
    const bun = options.bun ?? Bun.which("bun");
    if (!bun) throw new Error("bench-serve needs the bun executable on PATH");
    const { name, path: plan } = resolvePlan(options.storage, config);
    const directories = benchDirectories(options.storage);
    const startedAt = new Date(now());
    const id = `${startedAt.toISOString().replace(/[:.]/g, "-")}-${name}`;
    const runDirectory = join(directories.runs, id);
    mkdirSync(directories.runs, { recursive: true });
    const total = plannedCells(plan);
    let done = 0;
    emit({ type: "stage", stage: "start", progress: 0, message: `bench-serve ${name}: ${total || "?"} cells` });
    const problems: string[] = [];
    const proc = (options.spawn ?? Bun.spawn)([bun, script, "run", "--plan", plan, "--out", runDirectory],
      { stdin: "ignore", stdout: "pipe", stderr: "pipe", cwd: resolve(dirname(script), ".."), env: process.env });
    const line = (text: string) => {
      if (!text) return;
      emit({ type: "log", line: text });
      const cell = /^=== (.+) ===$/.exec(text);
      if (cell) { done++; emit({ type: "stage", stage: cell[1]!, progress: total ? Math.min(0.99, (done - 1) / total) : 0, message: `cell ${done}${total ? `/${total}` : ""}: ${cell[1]}` }); }
      const problem = /^\s+problem: (.+)$/.exec(text);
      if (problem) problems.push(problem[1]!);
    };
    const pumps = [pump(proc.stdout as ReadableStream<Uint8Array>, line), pump(proc.stderr as ReadableStream<Uint8Array>, line)];
    let killTimer: ReturnType<typeof setTimeout> | undefined;
    const stop = () => {
      try { proc.kill("SIGTERM"); } catch { /* already gone */ }
      killTimer = setTimeout(() => { try { proc.kill("SIGKILL"); } catch { /* already gone */ } }, graceMs);
    };
    if (signal.aborted) stop(); else signal.addEventListener("abort", stop, { once: true });
    let code: number;
    try { code = await proc.exited; }
    finally { signal.removeEventListener("abort", stop); if (killTimer) clearTimeout(killTimer); }
    await Promise.all(pumps);
    const finishedAt = new Date(now());
    let record: RunRecordLike | undefined;
    try { record = JSON.parse(readFileSync(join(runDirectory, "run.json"), "utf8")) as RunRecordLike; } catch { /* no record: the run failed before writing one */ }
    if (record) {
      const entry = compactRun(record, { id, profile: name, exitCode: code, problems, runDirectory, startedAt: startedAt.toISOString(),
        finishedAt: finishedAt.toISOString(), durationMs: finishedAt.getTime() - startedAt.getTime() });
      writeAtomic(join(directories.history, `${id}.json`), JSON.stringify(entry, null, 1));
    }
    signal.throwIfAborted();
    if (code !== 0) throw new Error(record
      ? `bench-serve exited ${code}: the run is incomplete${problems.length ? ` (${problems[0]})` : ""}; its record is in the history`
      : `bench-serve exited ${code} before writing a run record`);
    emit({ type: "stage", stage: "done", progress: 1, message: `recorded ${id}` });
    return { outputPath: runDirectory };
  };
}

async function pump(stream: ReadableStream<Uint8Array> | undefined, sink: (line: string) => void): Promise<void> {
  if (!stream) return;
  const reader = stream.getReader(), decoder = new TextDecoder();
  let buffered = "";
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      buffered += decoder.decode(value, { stream: true });
      for (let newline = buffered.indexOf("\n"); newline !== -1; newline = buffered.indexOf("\n")) { sink(buffered.slice(0, newline)); buffered = buffered.slice(newline + 1); }
    }
    buffered += decoder.decode();
    if (buffered) sink(buffered);
  } catch { /* the stream ended with its process */ } finally { reader.releaseLock(); }
}
