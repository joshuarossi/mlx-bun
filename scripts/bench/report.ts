// Run record, qualification and paired comparison. Pure over the raw record:
// `bench-serve.ts compare` re-renders any saved run without servers.
import type { CellResult, RawRequest, ReqResult, StopResult } from "./measure";
import { decodeStable, median, probeVerdict, spreadOf } from "./measure";
import { basename } from "node:path";
import type { Configuration, Plan, Tree } from "./plan";
import { planCells, REQUIRED_PHASES, WORKLOAD } from "./plan";

export interface CellRecord {
  key: string;
  model: string;
  kind: "tree" | "reference";
  tree?: Tree;
  configuration?: Configuration;
  reference?: string;
  order: number;
  command: string[] | null;
  /** Intent only: the library the environment asked for. `result.loadedLibraries` is the evidence. */
  intendedLibrary: string | null;
  skipped?: string;
  result?: CellResult;
  failure?: { error: string; stderrTail: string[]; processes?: Array<{ pid: number } & StopResult> };
}
export interface ToolPin { root: string; head: string; clean: boolean; sha256: string }
export interface RunRecord {
  schema: 1;
  /** The runner's own source, by content, at start and end. */
  tool: { start: ToolPin; end?: ToolPin };
  plan: Plan;
  machine: { chip: string; memoryBytes: number; loadAverage: string; host: string; os: string; bun: string };
  startedAt: string;
  finishedAt?: string;
  interrupted?: string;
  /** A supervision failure (an unjoined server) that stopped the campaign. */
  fatal?: string;
  /** Servers stopped by the interrupt path, each with its confirmed join. */
  interruptCleanup?: StopResult[];
  pins: { start: string[]; end?: string[] };
  cells: CellRecord[];
  requests: RawRequest[];
}

export const PAIRS = (plan: Plan) => plan.models.flatMap(model => plan.configurations.map(configuration => ({ model: model.id, configuration })));
const cellFor = (run: RunRecord, model: string, tree: Tree, configuration: Configuration) =>
  run.cells.find(cell => cell.kind === "tree" && cell.model === model && cell.tree === tree && cell.configuration === configuration);

/** Each measured phase must hold its full sample set, backed by the successful
 * requests of its final attempt: a label alone proves nothing. */
/** Each phase's final attempt: the accepted samples. Requests of abandoned
 * attempts stay in the raw evidence and never reach a comparison. */
export function finalRequests(run: RunRecord, cell: CellRecord, phase?: string): RawRequest[] {
  const own = run.requests.filter(q => q.cell === cell.key && (phase === undefined || q.phase === phase));
  const last = new Map<string, number>();
  for (const q of own) last.set(q.phase, Math.max(last.get(q.phase) ?? -1, q.attempt));
  return own.filter(q => q.attempt === last.get(q.phase));
}

function sampleProblems(run: RunRecord, cell: CellRecord, r: CellResult): string[] {
  const w = run.plan.workload, problems: string[] = [];
  const expect = (phase: string, ok: boolean, requests: number, what: string) => {
    if (!r.measured.includes(phase as never)) return;
    if (!ok) problems.push(`${phase} result is incomplete (${what})`);
    const final = finalRequests(run, cell, phase), good = final.filter(q => q.result);
    if (good.length !== requests || good.length !== final.length)
      problems.push(`${phase} has ${good.length} successful of ${final.length} final-attempt requests, expected ${requests}`);
  };
  expect("warmup", r.coldStartMs !== null, 1, "cold start");
  expect("parity", !!r.parity?.completion && !!r.parity?.chat, 1, "both probes");
  expect("decode", r.decodeTps?.length === w.decodeRuns, w.decodeRuns, `${r.decodeTps?.length ?? 0} of ${w.decodeRuns} samples`);
  expect("ttft1k", r.ttft?.coldMs.length === w.ttftRuns && r.ttft.prefill1kTps.length === w.ttftRuns, w.ttftRuns + 1,
    `${r.ttft?.coldMs.length ?? 0} cold samples`);
  expect("ctx", r.ctx?.decodeTps.length === 3 && r.ctx.promptTokens > 0, 3, "cold prefill and two repeats");
  expect("restart", !!r.restart, 1, "restart measurement");
  expect("agg", r.agg?.ttftMs.length === w.aggregateStreams, w.aggregateStreams, `${r.agg?.ttftMs.length ?? 0} streams`);
  return problems;
}

/** What keeps a run from being complete. Performance acceptance is always
 * unreviewed here: no tolerance turns a slower measurement into a pass. */
export function qualification(run: RunRecord) {
  const problems: string[] = [], notes: string[] = [];
  if (run.interrupted) problems.push(`interrupted (${run.interrupted})`);
  for (const stop of run.interruptCleanup ?? []) if (!stop.joined) problems.push(`interrupt cleanup left a server unjoined (${stop.actions.join(", ")})`);
  if (!run.finishedAt) problems.push("run did not finish");
  if (run.pins.start.length) problems.push(...run.pins.start.map(p => `pin at start: ${p}`));
  if (!run.pins.end) problems.push("pins were not verified at the end");
  else problems.push(...run.pins.end.map(p => `pin at end: ${p}`));
  if (run.fatal) problems.push(`campaign stopped: ${run.fatal}`);
  // Reconcile the observed inventory with the matrix recomputed from the plan's
  // own models and configurations (never trusting the stored cell list).
  const matrix = planCells(run.plan);
  if (JSON.stringify(matrix) !== JSON.stringify(run.plan.cells)) problems.push("the plan's predeclared cells do not match its matrix");
  const planned = new Map(matrix.map(cell => [cell.key, cell]));
  const counts = new Map<string, number>();
  for (const cell of run.cells) counts.set(cell.key, (counts.get(cell.key) ?? 0) + 1);
  for (const [key, n] of counts) {
    if (!planned.has(key)) problems.push(`${key}: not in the plan`);
    if (n > 1) problems.push(`${key}: recorded ${n} times`);
  }
  for (const cell of matrix) {
    const seen = run.cells.filter(observed => observed.key === cell.key);
    if (!seen.length) problems.push(`${cell.key}: planned ${cell.skipped ? "N/A cell" : "cell"} was never recorded`);
    for (const observed of seen) {
      if ((observed.skipped ?? null) !== (cell.skipped ?? null)) problems.push(`${cell.key}: applicability differs from the plan`);
      if (observed.kind !== cell.kind || (observed.tree ?? null) !== (cell.tree ?? null) ||
          (observed.configuration ?? null) !== (cell.configuration ?? null) || observed.model !== cell.model)
        problems.push(`${cell.key}: identity differs from the plan`);
    }
  }
  const tool = run.tool;
  if (tool.end && tool.end.sha256 !== tool.start.sha256) problems.push("benchmark tooling changed during the run");
  if (!tool.end) problems.push("tooling was not re-verified at the end");
  const toolClean = tool.start.clean && tool.end?.clean === true;
  // A scoped plan may override main's workload (tests use a looser stability guard);
  // the run then measures something other than main's workload.
  const overridden = Object.entries(WORKLOAD).filter(([key, value]) => (run.plan.workload as Record<string, unknown>)[key] !== value);
  if (overridden.length)
    notes.push(`workload differs from main (${overridden.map(([key]) => `${key} ${(run.plan.workload as Record<string, unknown>)[key]}`).join(", ")}): non-qualifying`);
  if (!toolClean) notes.push("benchmark tooling tree is not clean: this run cannot be full qualification");
  const required = (cell: CellRecord) => REQUIRED_PHASES.filter(phase => run.plan.workload.withContext || (phase !== "ctx" && phase !== "restart"))
    .filter(phase => !cell.result?.measured.includes(phase));
  const [chosen, ...bundled] = run.plan.native.files; // the exact resolved library supplied, then its runtime
  const pinnedByName = new Map(run.plan.native.files.map(file => [file.name, file]));
  for (const cell of run.cells) {
    if (cell.skipped) { notes.push(`${cell.key}: not applicable — ${cell.skipped}`); continue; }
    if (cell.failure) { problems.push(`${cell.key}: failed (${cell.failure.error.slice(0, 160)})`); continue; }
    if (!cell.result) { problems.push(`${cell.key}: no result or failure was recorded`); continue; }
    const result = cell.result;
    const missing = required(cell);
    if (missing.length) problems.push(`${cell.key}: required phases missing: ${missing.join(", ")}`);
    for (const problem of sampleProblems(run, cell, result)) problems.push(`${cell.key}: ${problem}`);
    const retried = result.phaseFailures.filter(f => f.recovered).map(f => f.phase);
    if (retried.length) notes.push(`${cell.key}: recovered on retry: ${retried.join(", ")} (paired by attempt and request hash)`);
    // Recomputed from the recorded samples against the plan's limit, never the stored flag.
    if (result.decodeTps?.length && !decodeStable(result.decodeTps, run.plan.workload.spreadLimit))
      problems.push(`${cell.key}: unstable decode spread ${spreadOf(result.decodeTps).toFixed(2)} exceeds the ${run.plan.workload.spreadLimit} stability guard`);
    for (const stop of result.processes) if (!stop.joined) problems.push(`${cell.key}: server pid ${stop.pid} was not joined`);
    if (cell.kind === "tree") {
      const loaded = result.loadedLibraries;
      if (!loaded) problems.push(`${cell.key}: provenance incomplete — loaded MLX library not observable`);
      else {
        if (!chosen || !loaded.some(lib => lib.path === chosen.path && lib.sha256 === chosen.sha256))
          problems.push(`${cell.key}: the pinned library ${chosen?.path} was not observed loaded`);
        // Every observed MLX runtime file must be the pinned one, by path and content.
        for (const lib of loaded) {
          const pin = pinnedByName.get(basename(lib.path));
          if (!pin) problems.push(`${cell.key}: unpinned MLX runtime file loaded: ${lib.path}`);
          else if (pin.path !== lib.path || pin.sha256 !== lib.sha256)
            problems.push(`${cell.key}: loaded ${lib.path} (${lib.sha256.slice(0, 12)}) is not the pinned ${pin.path} (${pin.sha256.slice(0, 12)})`);
        }
        const unobserved = bundled.filter(pin => !loaded.some(lib => basename(lib.path) === pin.name)).map(pin => pin.name);
        if (unobserved.length) notes.push(`${cell.key}: pinned runtime files not observed mapped (not required): ${unobserved.join(", ")}`);
      }
    } else if (!result.loadedLibraries) notes.push(`${cell.key}: reference loaded libraries not observable`);
  }
  // Baseline and candidate must render the same prompts and produce the same greedy text,
  // and every required phase's final accepted attempt must pair completely.
  for (const { model, configuration } of PAIRS(run.plan)) {
    const ca = cellFor(run, model, "baseline", configuration), cb = cellFor(run, model, "candidate", configuration);
    const a = ca?.result, b = cb?.result;
    if (!a || !b) continue;
    const pairs = pairRequests(run, ca!, cb!);
    for (const phase of REQUIRED_PHASES.filter(p => run.plan.workload.withContext || (p !== "ctx" && p !== "restart"))) {
      const fa = finalRequests(run, ca!, phase), fb = finalRequests(run, cb!, phase);
      const valid = new Set(pairs.filter(p => p.valid && p.phase === phase).map(p => p.id));
      const unpaired = fa.filter(q => !q.result || !valid.has(`${q.phase}|${q.attempt}|${q.index}|${q.requestSha256}`));
      if (!fa.length || fa.length !== fb.length || fb.some(q => !q.result) || unpaired.length) {
        const invalid = pairs.filter(p => p.phase === phase && !p.valid).map(p => p.reason);
        problems.push(`${model}/${configuration} ${phase}: final attempts do not pair (baseline ${fa.length} requests ` +
          `attempt ${fa[0]?.attempt ?? "-"}, candidate ${fb.length} attempt ${fb[0]?.attempt ?? "-"}` +
          `${invalid.length ? `; ${invalid.join("; ")}` : ""})`);
      }
    }
    for (const probe of ["completion", "chat"] as const) {
      const verdict = probeVerdict(probe, `${model}/${configuration}`, a.parity?.[probe], b.parity?.[probe]);
      if (verdict.ok !== true) problems.push(`${model}/${configuration} ${probe} probe: ${verdict.line.replace(/^- /, "")}`);
    }
  }
  const complete = problems.length === 0;
  return { complete, fullQualification: complete && toolClean && run.plan.profile === "all", profile: run.plan.profile,
    performanceAcceptance: "unreviewed" as const, problems, notes };
}

type Direction = "higher-is-better" | "lower-is-better";
/** Two requests of the same workload identity whose observed counts agree. */
export interface RequestPair {
  id: string; phase: string; index: number; baseline: ReqResult; candidate: ReqResult;
  valid: boolean; reason?: string;
}
const identity = (q: RawRequest) => `${q.phase}|${q.attempt}|${q.index}|${q.requestSha256}`;
/** Pair each phase's final attempts by phase, attempt, index and request hash; a
 * pair is valid only when prompt, output and cached token counts and the finish
 * reason agree (same work, same cache state). */
export function pairRequests(run: RunRecord, a: CellRecord, b: CellRecord): RequestPair[] {
  const successful = (cell: CellRecord) => finalRequests(run, cell).filter(q => q.result);
  const other = new Map(successful(b).map(q => [identity(q), q]));
  return successful(a).flatMap(q => {
    const match = other.get(identity(q));
    if (!match) return [];
    const x = q.result!, y = match.result!, reasons: string[] = [];
    if (x.promptTokens !== y.promptTokens) reasons.push(`prompt tokens ${x.promptTokens}/${y.promptTokens}`);
    if (x.genTokens !== y.genTokens) reasons.push(`output tokens ${x.genTokens}/${y.genTokens}`);
    if (x.cachedTokens !== y.cachedTokens) reasons.push(`cached tokens ${x.cachedTokens}/${y.cachedTokens}`);
    if (x.finishReason !== y.finishReason) reasons.push(`finish ${x.finishReason}/${y.finishReason}`);
    return [{ id: identity(q), phase: q.phase, index: q.index, baseline: x, candidate: y, valid: !reasons.length,
      ...(reasons.length ? { reason: reasons.join("; ") } : {}) }];
  });
}

export interface MetricComparison {
  metric: string; direction: Direction; unit: string;
  /** Paired values from matched, valid workloads only. */
  pairs: Array<{ id: string; baseline: number; candidate: number }>;
  baselineMedian: number | null; candidateMedian: number | null; ratio: number | null;
  observation: "candidate worse" | "candidate better" | "equal" | "unpaired";
  /** Raw evidence that could not be paired; never a conclusion. */
  unpaired: { baseline: number[]; candidate: number[] };
  excluded: string[];
}

type RequestMetric = { metric: string; unit: string; direction: Direction; phase: string;
  include(index: number, workload: Plan["workload"]): boolean; value(r: ReqResult): number };
const REQUEST_METRICS: RequestMetric[] = [
  { metric: "decode", unit: "tok/s", direction: "higher-is-better", phase: "decode", include: () => true, value: r => r.decodeTps },
  { metric: "short request wall", unit: "ms", direction: "lower-is-better", phase: "decode", include: () => true, value: r => r.wallMs },
  { metric: "TTFT cold (nominal 1k prompt)", unit: "ms", direction: "lower-is-better", phase: "ttft1k", include: (i, w) => i < w.ttftRuns, value: r => r.ttftMs },
  { metric: "prefill (nominal 1k prompt)", unit: "tok/s", direction: "higher-is-better", phase: "ttft1k", include: (i, w) => i < w.ttftRuns,
    value: r => r.promptTokens * 1000 / r.ttftMs },
  { metric: "TTFT warm (repeat)", unit: "ms", direction: "lower-is-better", phase: "ttft1k", include: (i, w) => i === w.ttftRuns, value: r => r.ttftMs },
  { metric: "prefill @ctx", unit: "tok/s", direction: "higher-is-better", phase: "ctx", include: i => i === 0, value: r => r.promptTokens * 1000 / r.ttftMs },
  { metric: "TTFT @ctx", unit: "ms", direction: "lower-is-better", phase: "ctx", include: i => i === 0, value: r => r.ttftMs },
  { metric: "decode @ctx", unit: "tok/s", direction: "higher-is-better", phase: "ctx", include: () => true, value: r => r.decodeTps },
  { metric: "ctx repeat TTFT", unit: "ms", direction: "lower-is-better", phase: "ctx", include: i => i > 0, value: r => r.ttftMs },
  { metric: "restart ctx TTFT", unit: "ms", direction: "lower-is-better", phase: "restart", include: () => true, value: r => r.ttftMs },
  { metric: "aggregate stream TTFT", unit: "ms", direction: "lower-is-better", phase: "agg", include: () => true, value: r => r.ttftMs },
  { metric: "aggregate stream decode", unit: "tok/s", direction: "higher-is-better", phase: "agg", include: () => true, value: r => r.decodeTps },
];
/** Cell-level measurements, paired only when both cells ran an identical, valid workload. */
const CELL_METRICS: Array<{ metric: string; unit: string; direction: Direction; get(r: CellResult): number | null }> = [
  { metric: "aggregate ×4", unit: "tok/s", direction: "higher-is-better", get: r => r.agg?.tps ?? null },
  { metric: "aggregate wall", unit: "ms", direction: "lower-is-better", get: r => r.agg?.wallMs ?? null },
  { metric: "ready", unit: "ms", direction: "lower-is-better", get: r => r.readyMs },
  { metric: "cold start (ready + first TTFT)", unit: "ms", direction: "lower-is-better", get: r => r.coldStartMs },
  { metric: "restart ready", unit: "ms", direction: "lower-is-better", get: r => r.restart?.readyMs ?? null },
  { metric: "idle RSS", unit: "MB", direction: "lower-is-better", get: r => r.idleRssMB },
  { metric: "peak RSS", unit: "MB", direction: "lower-is-better", get: r => r.peakRssMB },
];

function summarize(metric: string, unit: string, direction: Direction, pairs: MetricComparison["pairs"],
  unpaired: MetricComparison["unpaired"], excluded: string[]): MetricComparison {
  if (!pairs.length) return { metric, unit, direction, pairs, baselineMedian: null, candidateMedian: null, ratio: null,
    observation: "unpaired", unpaired, excluded };
  const bm = median(pairs.map(p => p.baseline)), cm = median(pairs.map(p => p.candidate)), ratio = bm === 0 ? null : cm / bm;
  const worse = direction === "higher-is-better" ? cm < bm : cm > bm, better = direction === "higher-is-better" ? cm > bm : cm < bm;
  return { metric, unit, direction, pairs, baselineMedian: bm, candidateMedian: cm, ratio, unpaired, excluded,
    observation: worse ? "candidate worse" : better ? "candidate better" : "equal" };
}

export function comparePair(run: RunRecord, model: string, configuration: Configuration): MetricComparison[] | null {
  const a = cellFor(run, model, "baseline", configuration), b = cellFor(run, model, "candidate", configuration);
  if (!a?.result || !b?.result) return null;
  const pairs = pairRequests(run, a, b), workload = run.plan.workload;
  const successful = (cell: CellRecord) => run.requests.filter(q => q.cell === cell.key && q.result);
  const byRequests = REQUEST_METRICS.map(m => {
    const inPhase = pairs.filter(p => p.phase === m.phase && m.include(p.index, workload));
    const values = (cell: CellRecord) => successful(cell).filter(q => q.phase === m.phase && m.include(q.index, workload)).map(q => m.value(q.result!));
    return summarize(m.metric, m.unit, m.direction,
      inPhase.filter(p => p.valid).map(p => ({ id: p.id, baseline: m.value(p.baseline), candidate: m.value(p.candidate) })),
      { baseline: values(a), candidate: values(b) }, inPhase.filter(p => !p.valid).map(p => `${p.id}: ${p.reason}`));
  });
  // Identical workload: every successful request on each side is matched by a valid pair.
  const identical = pairs.length > 0 && pairs.every(p => p.valid) &&
    pairs.length === successful(a).length && pairs.length === successful(b).length;
  const legs = [...new Set([...a.result.rssByLeg, ...b.result.rssByLeg].map(([leg]) => leg))];
  const cellMetrics = [...CELL_METRICS, ...legs.map(leg => ({ metric: `RSS during ${leg}`, unit: "MB", direction: "lower-is-better" as Direction,
    get: (r: CellResult) => r.rssByLeg.find(([name]) => name === leg)?.[1] ?? null }))];
  const byCell = cellMetrics.map(m => {
    const x = m.get(a.result!), y = m.get(b.result!);
    const raw = { baseline: x === null ? [] : [x], candidate: y === null ? [] : [y] };
    return summarize(m.metric, m.unit, m.direction, identical && x !== null && y !== null ? [{ id: "cell", baseline: x, candidate: y }] : [],
      raw, identical ? [] : ["workloads differ (retries, failures or count mismatches); cell-level values are raw only"]);
  });
  return [...byRequests, ...byCell];
}

const fmt = (n: number | null, digits = 1) => n === null ? "—" : n.toFixed(digits);
/** Prompt tokens the servers actually counted on each arm's accepted requests. The
 * workload's token counts are nominal: main's filler is sized by characters. */
function promptTokenRows(run: RunRecord, a: CellRecord, b: CellRecord): string[] {
  const w = run.plan.workload;
  const nominal: Array<[string, string]> = [["decode", "short"], ["ttft1k", "1024"],
    ...(w.withContext ? [["ctx", String(w.contextTokens)] as [string, string]] : []),
    ["agg", w.aggregateContext ? String(w.aggregateContext) : "short"]];
  const actual = (cell: CellRecord, phase: string) => {
    const counts = [...new Set(finalRequests(run, cell, phase).flatMap(q => q.result ? [q.result.promptTokens] : []))];
    return counts.length ? counts.join(", ") : "—";
  };
  return ["| prompt tokens | nominal target | baseline actual | candidate actual |", "|---|---|---|---|",
    ...nominal.map(([phase, target]) => `| ${phase} | ${target} | ${actual(a, phase)} | ${actual(b, phase)} |`)];
}

export function markdown(run: RunRecord): string {
  const q = qualification(run), lines: string[] = [];
  lines.push(`# paired serve benchmark — ${run.startedAt.slice(0, 10)}`, "",
    `machine: ${run.machine.chip} · ${(run.machine.memoryBytes / 2 ** 30).toFixed(0)} GB · loadavg ${run.machine.loadAverage} · ${run.machine.host} · Bun ${run.machine.bun}`,
    `baseline: ${run.plan.trees.baseline.root} @ ${run.plan.trees.baseline.commit} — \`${run.plan.trees.baseline.command.join(" ")}\``,
    `candidate: ${run.plan.trees.candidate.root} @ ${run.plan.trees.candidate.commit} — \`${run.plan.trees.candidate.command.join(" ")}\``,
    ...run.plan.references.map(ref => `reference ${ref.label}${ref.version ? ` ${ref.version}` : ""}: \`${ref.command.join(" ")}\`` +
      (ref.registerCommand ? ` (register: \`${ref.registerCommand.join(" ")}\`)` : "")),
    `pinned native library: ${run.plan.native.library}`,
    "memory: RSS summed across the server process family, including inference workers; shared pages may be counted more than once.",
    `workload seed ${run.plan.seed}; ${run.plan.workload.decodeRuns} decode samples of ${run.plan.workload.decodeTokens} tokens, ` +
      `${run.plan.workload.ttftRuns} cold TTFT samples (nominal 1k-token prompt), ` +
      `${run.plan.workload.withContext ? `nominal context target ${run.plan.workload.contextTokens}` : "context skipped"}, ` +
      `${run.plan.workload.aggregateStreams} × ${run.plan.workload.aggregateTokens}-token concurrent streams.`,
    `Prompt sizes are nominal targets for main's character-based filler; each pair lists the prompt tokens its servers actually counted.`, "",
    `## Qualification`, "",
    `- profile: **${q.profile}**${q.profile === "all" ? " (main's full matrix)" : " (scoped: not full qualification)"}`,
    `- complete: **${q.complete ? "yes" : "no"}**; full qualification: **${q.fullQualification ? "yes" : "no"}**`,
    `- performance acceptance: **unreviewed** — matched samples below; slower or higher-memory observations are flagged, not tolerated.`);
  for (const problem of q.problems) lines.push(`- problem: ${problem}`);
  for (const note of q.notes) lines.push(`- note: ${note}`);
  lines.push("");
  for (const { model, configuration } of PAIRS(run.plan)) {
    const comparison = comparePair(run, model, configuration);
    lines.push(`## ${model} · ${configuration}`, "");
    if (!comparison) { lines.push("No paired measurement (see problems and skips).", ""); continue; }
    lines.push("| metric | unit | direction | paired samples (baseline → candidate) | baseline median | candidate median | candidate/baseline | observation |",
      "|---|---|---|---|---|---|---|---|");
    for (const c of comparison) {
      const samples = c.pairs.length ? c.pairs.map(p => `${p.baseline.toFixed(1)}→${p.candidate.toFixed(1)}`).join(", ")
        : `unpaired raw: baseline [${c.unpaired.baseline.map(v => v.toFixed(1)).join(", ")}], candidate [${c.unpaired.candidate.map(v => v.toFixed(1)).join(", ")}]`;
      lines.push(`| ${c.metric} | ${c.unit} | ${c.direction === "higher-is-better" ? "↑" : "↓"} | ${samples} | ${fmt(c.baselineMedian)} | ` +
        `${fmt(c.candidateMedian)} | ${fmt(c.ratio, 3)} | ${c.observation === "candidate worse" ? "**⚠ candidate worse**" :
          c.observation === "unpaired" ? "unpaired — no conclusion" : c.observation} |`);
    }
    for (const c of comparison) for (const reason of c.excluded) lines.push(`- ${c.metric}: excluded ${reason}`);
    lines.push("", ...promptTokenRows(run, cellFor(run, model, "baseline", configuration)!, cellFor(run, model, "candidate", configuration)!), "");
  }
  const references = run.cells.filter(cell => cell.kind === "reference" && cell.result);
  if (references.length) {
    lines.push("## Reference servers (context, not the baseline)", "",
      "| cell | decode tok/s | TTFT cold ms | prefill (nominal 1k) tok/s | ctx prompt tokens | peak RSS MB |", "|---|---|---|---|---|---|");
    for (const cell of references) {
      const r = cell.result!;
      lines.push(`| ${cell.key} | ${fmt(r.decodeTps ? median(r.decodeTps) : null)} | ${fmt(r.ttft ? median(r.ttft.coldMs) : null, 0)} | ` +
        `${fmt(r.ttft ? median(r.ttft.prefill1kTps) : null, 0)} | ${r.ctx?.promptTokens ?? "—"} | ${fmt(r.peakRssMB, 0)} |`);
    }
    lines.push("");
  }
  const failed = run.cells.filter(cell => cell.failure || cell.result?.phaseFailures.length);
  if (failed.length) {
    lines.push("## Failures and retries", "");
    for (const cell of failed) {
      if (cell.failure) lines.push(`- ${cell.key}: ${cell.failure.error}`, ...cell.failure.stderrTail.map(line => `    ${line}`));
      for (const f of cell.result?.phaseFailures ?? [])
        lines.push(`- ${cell.key} [${f.phase}] ${f.recovered ? "recovered" : "failed"}: ${f.error}`, ...f.stderrTail.map(line => `    ${line}`));
    }
    lines.push("");
  }
  return lines.join("\n");
}
