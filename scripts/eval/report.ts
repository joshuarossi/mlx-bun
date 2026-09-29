// Evaluation result, its qualification, and the paired comparison. Pure over
// saved results: `eval-serve.ts compare` re-renders any two runs without a
// server. Every score difference and every skip is flagged; no tolerance turns
// a difference into a pass. Acceptance is the reviewer's.
import { basename } from "node:path";
import type { StopResult } from "../bench/measure";
import type { ToolPin } from "../bench/report";
import type { RequestStats, REQUEST_DEFAULTS } from "./client";
import { DATASETS, datasetPinProblems, type DatasetPin, type EvalPlan } from "./plan";
import { computeCapabilityScore, type CapabilityScore, type TaskName } from "./scoring";
import { TASKS, type TaskId, type TaskScore } from "./tasks";

export interface TaskResult {
  task: TaskId;
  component: TaskName | null;
  status: "complete" | "incomplete" | "skipped";
  reason?: string;
  datasets: Array<{ name: string; sha256: string }>;
  settings: Record<string, unknown>;
  score: TaskScore | null;
  /** One character per selected item, in order: 1 correct, 0 incorrect, U not
   * scorable by main's rule, E failed request, - not attempted. */
  outcomes: string;
  errors: Array<{ index: number; id: string; error: string }>;
  timing: { wallMs: number } & RequestStats;
}
export interface EvalResult {
  schema: 1;
  kind: "capability-eval-result";
  label: string;
  startedAt: string;
  finishedAt?: string;
  interrupted?: string;
  /** Why the run stopped evaluating (the server exited, a pin failed). */
  fatal?: string;
  /** The runner command, and its own source files by content (sha256) with the checkout head. */
  runner: { argv: string[]; start: ToolPin; end?: ToolPin };
  /** The evaluated server's source tree. */
  tree: { root: string; start: ToolPin; end?: ToolPin };
  server: {
    command: string[] | null;
    runtime: { executable: string; version: string } | null;
    readyMs: number | null;
    /** The server's /v1/models answer. */
    models: unknown;
    /** MLX libraries the server process had mapped at the end (lsof). */
    loadedLibraries: Array<{ path: string; sha256: string }> | null;
    processes: Array<{ pid: number } & StopResult>;
    stderrTail: string[];
  };
  plan: { path: string; sha256: string; value: EvalPlan };
  machine: { chip: string; memoryBytes: number; loadAverage: string; host: string; os: string; bun: string };
  request: { defaults: typeof REQUEST_DEFAULTS; seed: string; timeoutMs: number; concurrency: 1;
    executionShape: string };
  verifier: { available: boolean; detail: string };
  pins: { start: string[]; end?: string[] };
  tasks: TaskResult[];
  capability: (CapabilityScore & { excluded: string[] }) | null;
  /** Per-sample detail beside this file. */
  detail: string;
}

/** Main's aggregation over the capability tasks that completed; any other
 * planned capability task is excluded and named, never zero-filled. */
export function capabilityOf(plan: EvalPlan, tasks: TaskResult[]): EvalResult["capability"] {
  const planned = plan.tasks.filter(task => TASKS[task].component);
  if (!planned.length) return null;
  const percents: Partial<Record<TaskName, number>> = {}, excluded: string[] = [];
  for (const task of planned) {
    const result = tasks.find(t => t.task === task), component = TASKS[task].component!;
    if (result?.status === "complete" && result.score) percents[component] = result.score.accuracy * 100;
    else excluded.push(`${component}: ${result ? result.status : "not run"}${result?.reason ? ` (${result.reason})` : ""}`);
  }
  return { ...computeCapabilityScore(percents, plan.model.diskGb), excluded };
}

/** What keeps one run from being a complete evaluation of its plan. */
export function qualification(result: EvalResult, pins: Readonly<Record<string, DatasetPin>> = DATASETS) {
  const problems: string[] = [], notes: string[] = [];
  const plan = result.plan.value;
  if (result.interrupted) problems.push(`interrupted (${result.interrupted})`);
  if (result.fatal) problems.push(`stopped: ${result.fatal}`);
  if (!result.finishedAt) problems.push("run did not finish");
  problems.push(...result.pins.start.map(p => `pin at start: ${p}`));
  if (!result.pins.end) problems.push("pins were not verified at the end");
  else problems.push(...result.pins.end.map(p => `pin at end: ${p}`));
  problems.push(...datasetPinProblems(plan, pins));
  const { runner, tree } = result;
  if (!runner.end) problems.push("runner source was not re-verified at the end");
  else if (runner.end.sha256 !== runner.start.sha256) problems.push("runner source changed during the run");
  if (!runner.start.clean) notes.push(`runner checkout ${runner.start.root} is not clean`);
  if (!tree.end) problems.push("server tree was not re-verified at the end");
  else if (tree.end.sha256 !== tree.start.sha256 || tree.end.head !== tree.start.head) problems.push("server tree changed during the run");
  if (!tree.start.clean) problems.push(`server tree ${tree.root} is not clean: its commit does not identify the evaluated source`);
  for (const stop of result.server.processes) if (!stop.joined) problems.push(`server pid ${stop.pid} was not joined`);
  const loaded = result.server.loadedLibraries, [chosen] = plan.native.files;
  const pinnedByName = new Map(plan.native.files.map(file => [file.name, file]));
  if (result.server.command) {
    if (!loaded) problems.push("provenance incomplete: the server's loaded MLX libraries were not observable");
    else {
      if (!chosen || !loaded.some(lib => lib.path === chosen.path && lib.sha256 === chosen.sha256))
        problems.push(`the pinned MLX library ${chosen?.path} was not observed loaded`);
      for (const lib of loaded) {
        const pin = pinnedByName.get(basename(lib.path));
        if (!pin || pin.path !== lib.path || pin.sha256 !== lib.sha256) problems.push(`unpinned MLX runtime file loaded: ${lib.path}`);
      }
    }
  }
  const seen = result.tasks.map(t => t.task);
  if (JSON.stringify(seen) !== JSON.stringify(plan.tasks)) problems.push(`tasks recorded [${seen.join(", ")}] are not the plan's [${plan.tasks.join(", ")}]`);
  for (const task of result.tasks) {
    if (task.status === "skipped") problems.push(`${task.task}: skipped — ${task.reason ?? "no reason"}`);
    else if (task.status === "incomplete") problems.push(`${task.task}: incomplete — ${task.reason ?? outcomeSummary(task.outcomes)}`);
  }
  return { complete: problems.length === 0, problems, notes };
}

export function outcomeSummary(outcomes: string): string {
  const n = (c: string) => [...outcomes].filter(x => x === c).length;
  return `${n("1")} correct, ${n("0")} incorrect, ${n("U")} unscorable/unverified, ${n("E")} failed, ${n("-")} not attempted of ${outcomes.length}`;
}

// ---- rendering ------------------------------------------------------------------------
const pct = (x: number) => `${(x * 100).toFixed(2)}%`;
const short = (sha: string) => sha.slice(0, 12);
const pin = (p: ToolPin | undefined) => p ? `${p.head.slice(0, 12)}${p.clean ? "" : " (dirty)"}, content ${short(p.sha256)}` : "—";
/** Every numeric leaf of a score object, by dotted path. */
function leaves(value: unknown, prefix = ""): Array<[string, number]> {
  if (typeof value === "number") return [[prefix, value]];
  if (!value || typeof value !== "object") return [];
  return Object.entries(value as Record<string, unknown>).flatMap(([key, v]) => leaves(v, prefix ? `${prefix}.${key}` : key));
}
/** Rates as percentages, counts as integers. */
const metricText = (name: string, value: number | undefined) => value === undefined ? "—"
  : /(accuracy|Acc|Coverage|byHops\.)/.test(name) ? pct(value) : String(value);

function header(results: EvalResult[]): string[] {
  const rows: Array<[string, (r: EvalResult) => string]> = [
    ["label", r => r.label],
    ["server tree", r => `${r.tree.root} @ ${pin(r.tree.start)}`],
    ["server command", r => r.server.command ? `\`${r.server.command.join(" ")}\`` : "not started"],
    ["server runtime", r => r.server.runtime ? `${r.server.runtime.executable} ${r.server.runtime.version}` : "—"],
    ["model", r => `${r.plan.value.model.path}${r.plan.value.model.revision ? ` (${r.plan.value.model.repo}@${r.plan.value.model.revision})` : ""}, ` +
      `${r.plan.value.model.files.length} files, chat template ${r.plan.value.model.chatTemplate ? "yes" : "no"}`],
    ["MLX library", r => `${r.plan.value.native.library} (${short(r.plan.value.native.files[0]?.sha256 ?? "")}); loaded: ` +
      (r.server.loadedLibraries?.map(l => `${basename(l.path)} ${short(l.sha256)}`).join(", ") ?? "unobserved")],
    ["datasets", r => r.plan.value.data.files.map(f => `${f.name} ${short(f.sha256)}`).join(", ")],
    ["plan", r => `${r.plan.path} (${short(r.plan.sha256)}); thinking ${r.plan.value.enableThinking ? "on" : "off"}`],
    ["sampling", r => `${JSON.stringify(r.request.defaults)}; seed ${r.request.seed}; ${r.request.executionShape}`],
    ["verifier", r => `${r.verifier.available ? "available" : "unavailable"}: ${r.verifier.detail}`],
    ["runner", r => `${r.runner.start.root} @ ${pin(r.runner.start)}; bun ${r.machine.bun}`],
    ["machine", r => `${r.machine.chip} · ${(r.machine.memoryBytes / 2 ** 30).toFixed(0)} GB · ${r.machine.host} · loadavg ${r.machine.loadAverage}`],
    ["started", r => `${r.startedAt} → ${r.finishedAt ?? "unfinished"}`],
  ];
  return [`| | ${results.map(r => r.label).join(" | ")} |`, `|---|${results.map(() => "---|").join("")}`,
    ...rows.map(([name, get]) => `| ${name} | ${results.map(r => get(r).replaceAll("|", "\\|")).join(" | ")} |`)];
}

/** Plan and provenance fields that differ between the two runs. */
export function provenanceDifferences(a: EvalResult, b: EvalResult): { problems: string[]; flags: string[] } {
  const problems: string[] = [], flags: string[] = [];
  const pa = a.plan.value, pb = b.plan.value;
  if (a.plan.sha256 !== b.plan.sha256) {
    const fields: Array<[string, unknown, unknown]> = [["tasks", pa.tasks, pb.tasks], ["enableThinking", pa.enableThinking, pb.enableThinking],
      ["model files", pa.model.files, pb.model.files], ["datasets", pa.data.files.map(f => [f.name, f.sha256]), pb.data.files.map(f => [f.name, f.sha256])],
      ["MLX library files", pa.native.files, pb.native.files], ["python image", pa.pythonImage, pb.pythonImage]];
    const differing = fields.filter(([, x, y]) => JSON.stringify(x) !== JSON.stringify(y)).map(([name]) => name);
    problems.push(`different plans (${short(a.plan.sha256)} vs ${short(b.plan.sha256)})${differing.length ? `: ${differing.join(", ")} differ` : ""}`);
  }
  if (a.runner.start.sha256 !== b.runner.start.sha256)
    problems.push(`different runner source (${pin(a.runner.start)} vs ${pin(b.runner.start)}): task definitions may differ`);
  if (JSON.stringify(a.request) !== JSON.stringify(b.request)) problems.push("different request settings");
  for (const [name, x, y] of [["machine chip", a.machine.chip, b.machine.chip], ["machine memory", a.machine.memoryBytes, b.machine.memoryBytes],
    ["runner bun", a.machine.bun, b.machine.bun], ["OS", a.machine.os, b.machine.os],
    ["server runtime", a.server.runtime?.version, b.server.runtime?.version]] as const)
    if (x !== y) flags.push(`${name} differs: ${x} vs ${y}`);
  if (a.tree.start.head === b.tree.start.head && a.tree.start.sha256 === b.tree.start.sha256)
    flags.push("both runs evaluated the same source content");
  return { problems, flags };
}

export interface Comparison { problems: string[]; differences: number; markdown: string }
/** Pair a baseline result with a candidate result: flag every difference. */
export function compare(a: EvalResult, b: EvalResult, pins: Readonly<Record<string, DatasetPin>> = DATASETS): Comparison {
  const qa = qualification(a, pins), qb = qualification(b, pins), provenance = provenanceDifferences(a, b);
  const problems = [...qa.problems.map(p => `${a.label}: ${p}`), ...qb.problems.map(p => `${b.label}: ${p}`), ...provenance.problems];
  let differences = 0;
  const lines = [`# capability evaluation — ${a.label} vs ${b.label}`, "", ...header([a, b]), "", "## Qualification", "",
    `- ${a.label}: ${qa.complete ? "complete" : "INCOMPLETE"}; ${b.label}: ${qb.complete ? "complete" : "INCOMPLETE"}; ` +
      `comparable: ${provenance.problems.length ? "NO" : "yes"}; score acceptance: **unreviewed** (every difference is flagged, no tolerance)`,
    ...problems.map(p => `- problem: ${p}`), ...provenance.flags.map(f => `- flag: ${f}`),
    ...qa.notes.map(n => `- note (${a.label}): ${n}`), ...qb.notes.map(n => `- note (${b.label}): ${n}`), "",
    "## Scores", "", `| task | metric | ${a.label} | ${b.label} | observation |`, "|---|---|---|---|---|"];
  const tasks = [...new Set([...a.tasks.map(t => t.task), ...b.tasks.map(t => t.task)])];
  const flips: string[] = [];
  for (const task of tasks) {
    const ta = a.tasks.find(t => t.task === task), tb = b.tasks.find(t => t.task === task);
    const status = (t: TaskResult | undefined) => !t ? "not run" : t.status === "complete" ? "complete" : `${t.status}${t.reason ? `: ${t.reason}` : ""}`;
    if (!ta || !tb || ta.status !== "complete" || tb.status !== "complete") {
      differences++;
      lines.push(`| ${task} | status | ${status(ta)} | ${status(tb)} | **⚠ ${ta?.status === "skipped" || tb?.status === "skipped" ? "skipped" : "not complete"}** |`);
    }
    const la = new Map(leaves(ta?.score)), lb = new Map(leaves(tb?.score));
    for (const name of [...new Set([...la.keys(), ...lb.keys()])]) {
      const x = la.get(name), y = lb.get(name), differs = x !== y;
      if (differs) differences++;
      lines.push(`| ${task} | ${name} | ${metricText(name, x)} | ${metricText(name, y)} | ${differs ? "**⚠ differs**" : "equal"} |`);
    }
    if (ta && tb) {
      if (ta.outcomes.length !== tb.outcomes.length) flips.push(`- ${task}: ${ta.outcomes.length} vs ${tb.outcomes.length} samples (different selections)`);
      else {
        const changed = [...ta.outcomes].flatMap((o, i) => o !== tb.outcomes[i] ? [`${i} (${o}→${tb.outcomes[i]})`] : []);
        if (changed.length) flips.push(`- ${task}: ${changed.length} of ${ta.outcomes.length} samples differ: ${changed.slice(0, 40).join(", ")}${changed.length > 40 ? ", …" : ""}`);
      }
    }
  }
  const ca = a.capability, cb = b.capability;
  if (ca || cb) {
    const differs = ca?.score !== cb?.score || JSON.stringify(ca?.components) !== JSON.stringify(cb?.components);
    if (differs) differences++;
    lines.push(`| capability | Capability_Score | ${ca ? ca.score.toFixed(4) : "—"} | ${cb ? cb.score.toFixed(4) : "—"} | ${differs ? "**⚠ differs**" : "equal"} |`);
    for (const [label, c] of [[a.label, ca], [b.label, cb]] as const)
      if (c?.excluded.length) lines.push("", `- ${label} capability excludes ${c.excluded.join("; ")}`);
  }
  lines.push("", "## Per-sample outcome changes", "", ...(flips.length ? flips : ["- none"]), "", "## Failures and skips", "");
  const failures = [a, b].flatMap(r => r.tasks.flatMap(t => [
    ...(t.status !== "complete" ? [`- ${r.label} ${t.task}: ${t.status}${t.reason ? ` — ${t.reason}` : ""} (${outcomeSummary(t.outcomes)})`] : []),
    ...t.errors.slice(0, 10).map(e => `    - #${e.index} ${e.id}: ${e.error}`)]));
  lines.push(...(failures.length ? failures : ["- none"]), "", "## Timings (information, not flagged)", "",
    `| task | ${a.label} wall s | ${b.label} wall s | ${a.label} requests | ${b.label} requests | ${a.label} completion tokens | ${b.label} completion tokens |`,
    "|---|---|---|---|---|---|---|");
  for (const task of tasks) {
    const ta = a.tasks.find(t => t.task === task)?.timing, tb = b.tasks.find(t => t.task === task)?.timing;
    lines.push(`| ${task} | ${ta ? (ta.wallMs / 1000).toFixed(1) : "—"} | ${tb ? (tb.wallMs / 1000).toFixed(1) : "—"} | ${ta?.requests ?? "—"} | ` +
      `${tb?.requests ?? "—"} | ${ta?.completionTokens ?? "—"} | ${tb?.completionTokens ?? "—"} |`);
  }
  lines.push("", `${differences} difference${differences === 1 ? "" : "s"} flagged.`);
  return { problems, differences, markdown: lines.join("\n") };
}

/** One run's summary (the report written beside result.json). */
export function markdown(result: EvalResult, pins: Readonly<Record<string, DatasetPin>> = DATASETS): string {
  const q = qualification(result, pins);
  const lines = [`# capability evaluation — ${result.label}`, "", ...header([result]), "", "## Qualification", "",
    `- ${q.complete ? "complete" : "INCOMPLETE"}`, ...q.problems.map(p => `- problem: ${p}`), ...q.notes.map(n => `- note: ${n}`), "",
    "## Scores", "", "| task | status | metric | value |", "|---|---|---|---|"];
  for (const task of result.tasks) {
    const values = leaves(task.score);
    if (!values.length) lines.push(`| ${task.task} | ${task.status}${task.reason ? `: ${task.reason}` : ""} | — | — |`);
    for (const [name, value] of values) lines.push(`| ${task.task} | ${task.status} | ${name} | ${metricText(name, value)} |`);
  }
  if (result.capability) lines.push(`| capability | — | Capability_Score | ${result.capability.score.toFixed(4)} |`,
    ...(result.capability.excluded.length ? ["", `- capability excludes ${result.capability.excluded.join("; ")}`] : []));
  return lines.join("\n");
}
