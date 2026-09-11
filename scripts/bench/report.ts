#!/usr/bin/env bun
// Offline HTML comparison report for saved benchmark companions
// (decode-speed-program §7.10). Renders ONE self-contained file from:
//   - bench-serve schema-4 raw JSON (`<report>.md.json`), and
//   - scripts/bench/native.ts schema-1 `native-inference-diagnostic` JSON.
// Rendering needs no weights, server, GPU, Python or network. Every metric
// carries a status (measured | recovered | failed | not-measured | unsupported)
// so a failed or skipped cell is never blank and never a number. Ratios are
// computed only within one machine key, one artifact and one workload.
// Saved model output is data: it is escaped, never executed.
//
//   bun scripts/bench/report.ts --out reports/<name>.html <raw.md.json> [...] [<native.json> ...]
//                               [--baseline mlx-lm|mlx-bun-serial|mlx-bun] [--title "..."]
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync } from "node:fs";
import { basename, dirname, resolve } from "node:path";
import type { MachineState } from "../../src/preflight";
import {
  median, probeVerdict, unsupportedBenchmarkArm, PARITY_PAIRS,
  type Arm, type BenchmarkModel, type CellResult, type PhaseFailure, type RawRequest, type RestartDurability,
} from "../bench-serve";
import type { NativeBenchReport, NativeBenchSample } from "./native";

// ---- raw shapes -------------------------------------------------------------

export interface ServeWorkload {
  seed: string; decodeTokens: number; contextTarget: number; withContext: boolean;
  decodeRuns: number; enableThinking: boolean; referencePrefill?: string; allowedCpuProcess?: string;
}

/** The object bench-serve.ts saveRaw() writes (schema 4). Unknown keys are kept. */
export interface ServeRawReport {
  schemaVersion: 4;
  measurement: boolean; diagnostic: boolean; canonical: boolean;
  runtimeEnvironment: Record<string, string>;
  qualification: string;
  machine: string;
  /** Older schema-4 companions omitted these fields. */
  host?: string; os?: string;
  machineBefore: MachineState; machineAtSave: MachineState;
  commit: string; bun: string;
  sourceDiffStart: string; sourceDiffAtSave: string;
  sourceSnapshotStart: { sha256: string; files: { path: string; sha256: string }[]; fileCount?: number };
  sourceSnapshotAtSaveSha256: string;
  identityNote: string;
  workload: ServeWorkload;
  models: Array<{ id: string } & BenchmarkModel>;
  commands: Array<{ model: string; arm: Arm; command: string[] | null }>;
  results: CellResult[];
  failures: Array<{ cell: string; error: string; stderrTail?: string[] }>;
  requests: RawRequest[];
  fixture?: { trimmedFrom: string; rules: string[] };
  [key: string]: unknown;
}

export type NativeRawReport = NativeBenchReport;

export type LoadedReport =
  | { kind: "serve"; path: string; sha256: string; bytes: number; report: ServeRawReport }
  | { kind: "native"; path: string; sha256: string; bytes: number; report: NativeRawReport };

const isObject = (v: unknown): v is Record<string, unknown> => v !== null && typeof v === "object" && !Array.isArray(v);

function fail(where: string, message: string): never {
  throw new Error(`${where}: ${message}`);
}

export function validateServeRaw(json: unknown, where = "serve raw"): ServeRawReport {
  if (!isObject(json)) fail(where, "not a JSON object");
  if (json.schemaVersion !== 4) fail(where, `schemaVersion must be 4 (got ${JSON.stringify(json.schemaVersion)})`);
  for (const key of ["machine", "commit", "bun", "sourceDiffStart", "sourceDiffAtSave", "sourceSnapshotAtSaveSha256"])
    if (typeof json[key] !== "string") fail(where, `${key} must be a string`);
  for (const key of ["diagnostic", "measurement"])
    if (typeof json[key] !== "boolean") fail(where, `${key} must be a boolean`);
  if (!isObject(json.workload) || typeof json.workload.seed !== "string" ||
      typeof json.workload.contextTarget !== "number" || typeof json.workload.decodeTokens !== "number" ||
      typeof json.workload.withContext !== "boolean")
    fail(where, "workload must carry seed, decodeTokens, contextTarget and withContext");
  for (const key of ["models", "commands", "results", "requests", "failures"])
    if (!Array.isArray(json[key])) fail(where, `${key} must be an array`);
  if (!isObject(json.sourceSnapshotStart) || typeof json.sourceSnapshotStart.sha256 !== "string")
    fail(where, "sourceSnapshotStart.sha256 must be a string");
  if (!isObject(json.machineBefore) || !isObject(json.machineAtSave)) fail(where, "machineBefore/machineAtSave must be objects");
  if (!isObject(json.runtimeEnvironment)) fail(where, "runtimeEnvironment must be an object");
  for (const [i, m] of (json.models as unknown[]).entries())
    if (!isObject(m) || typeof m.id !== "string" || typeof m.path !== "string" || typeof m.label !== "string")
      fail(where, `models[${i}] must carry id, path and label`);
  for (const [i, c] of (json.commands as unknown[]).entries())
    if (!isObject(c) || typeof c.model !== "string" || typeof c.arm !== "string" || !(c.command === null || Array.isArray(c.command)))
      fail(where, `commands[${i}] must carry model, arm and command[]|null`);
  for (const [i, r] of (json.results as unknown[]).entries())
    if (!isObject(r) || !isObject(r.cell) || typeof r.readyMs !== "number" || !Array.isArray(r.phaseFailures) || !Array.isArray(r.rssByLeg))
      fail(where, `results[${i}] must be a CellResult (cell, readyMs, rssByLeg, phaseFailures)`);
  for (const [i, q] of (json.requests as unknown[]).entries())
    if (!isObject(q) || !isObject(q.cell) || typeof q.phase !== "string" || typeof q.attempt !== "number" ||
        typeof q.index !== "number" || typeof q.requestSha256 !== "string" || !isObject(q.request))
      fail(where, `requests[${i}] must carry cell, phase, attempt, index, request and requestSha256`);
  return json as unknown as ServeRawReport;
}

export function validateNativeRaw(json: unknown, where = "native raw"): NativeRawReport {
  if (!isObject(json)) fail(where, "not a JSON object");
  if (json.kind !== "native-inference-diagnostic") fail(where, `kind must be "native-inference-diagnostic" (got ${JSON.stringify(json.kind)})`);
  if (json.schemaVersion !== 1) fail(where, `schemaVersion must be 1 (got ${JSON.stringify(json.schemaVersion)})`);
  if (json.stack !== "mlx-bun" && json.stack !== "mlx-lm") fail(where, "stack must be mlx-bun or mlx-lm");
  for (const key of ["artifact", "chip", "host", "configSha256", "promptSha256"])
    if (typeof json[key] !== "string") fail(where, `${key} must be a string`);
  if (typeof json.ramBytes !== "number") fail(where, "ramBytes must be a number");
  if (json.complete !== undefined && typeof json.complete !== "boolean") fail(where, "complete must be a boolean when present");
  if (json.samples !== undefined) {
    if (!Array.isArray(json.samples)) fail(where, "samples must be an array");
    for (const [i, s] of (json.samples as unknown[]).entries())
      if (!isObject(s) || typeof s.wallMs !== "number" || !Array.isArray(s.tokens) ||
          !(s.firstTokenMs === null || typeof s.firstTokenMs === "number") ||
          (s.finishReason !== "stop" && s.finishReason !== "length") || typeof s.peakBytes !== "number")
        fail(where, `samples[${i}] must be a NativeBenchSample`);
  }
  return json as unknown as NativeRawReport;
}

export function loadRawReport(path: string): LoadedReport {
  const full = resolve(path);
  const bytes = readFileSync(full);
  const sha256 = createHash("sha256").update(bytes).digest("hex");
  let json: unknown;
  try { json = JSON.parse(bytes.toString("utf8")); } catch (e) { fail(path, `not valid JSON (${(e as Error).message})`); }
  if (isObject(json) && json.kind === "native-inference-diagnostic")
    return { kind: "native", path, sha256, bytes: bytes.byteLength, report: validateNativeRaw(json, path) };
  if (isObject(json) && json.schemaVersion === 4 && Array.isArray(json.results))
    return { kind: "serve", path, sha256, bytes: bytes.byteLength, report: validateServeRaw(json, path) };
  return fail(path, "unrecognized input: expected bench-serve schemaVersion 4 with results[] or kind \"native-inference-diagnostic\"");
}

// ---- machine identity -------------------------------------------------------

export interface MachineIdentity { chip: string; ramGiB: number | null; host: string; key: string }

/** Older serving companions have no hostname. Never infer machine identity
 * from a filename that can change when a report is copied. */
export function machineKey(report: ServeRawReport | NativeRawReport): MachineIdentity {
  let chip: string, ramGiB: number | null, host: string;
  if (report.kind === "native-inference-diagnostic") {
    const native = report as NativeRawReport;
    chip = native.chip.trim(); ramGiB = Math.round(native.ramBytes / 2 ** 30); host = native.host || "not recorded";
  } else {
    const serve = report as ServeRawReport;
    const parts = serve.machine.split("·").map((p) => p.trim());
    chip = parts[0] || "unknown chip";
    const gb = parts.find((p) => /^\d+(\.\d+)?\s*GB$/i.test(p));
    ramGiB = gb ? Number(gb.replace(/\s*GB$/i, "")) : null;
    host = typeof serve.host === "string" && serve.host ? serve.host : "not recorded";
  }
  const ram = ramGiB == null ? "RAM unknown" : `${ramGiB} GB`;
  return { chip, ramGiB, host, key: `${chip} · ${ram} · host ${host}` };
}

// ---- derived rows ------------------------------------------------------------

export type MetricStatus = "measured" | "recovered" | "failed" | "not-measured" | "unsupported";
export interface Metric {
  label: string; unit: string; value: number | null; samples?: number[]; n: number; status: MetricStatus; note: string;
}
export const METRIC_KEYS = [
  "readyMs", "coldStartMs", "decodeTps", "decodeWallMs", "endToEndTps", "ttftColdMs", "prefill1kTps", "ttftWarmMs",
  "ctxPromptTokens", "ctxPrefillTps", "ctxTtftMs", "ctxDecodeTps", "ctxRepeatTtftMs",
  "restartCtxTtftMs", "restartReadyMs", "aggTps", "aggPerStream", "idleRssMB", "peakRssMB",
] as const;
export type MetricKey = typeof METRIC_KEYS[number];
/** lower-is-better keys invert the ratio direction so ">1" always means the row beat the baseline. */
export const LOWER_IS_BETTER: ReadonlySet<MetricKey> = new Set<MetricKey>([
  "readyMs", "coldStartMs", "decodeWallMs", "ttftColdMs", "ttftWarmMs", "ctxTtftMs", "ctxRepeatTtftMs",
  "restartCtxTtftMs", "restartReadyMs", "idleRssMB", "peakRssMB",
]);
const METRIC_DEFS: Record<MetricKey, { label: string; unit: string; phase: string }> = {
  readyMs: { label: "load→ready", unit: "ms", phase: "startup" },
  coldStartMs: { label: "cold start (ready + first TTFT)", unit: "ms", phase: "warmup" },
  decodeTps: { label: "decode", unit: "SSE window tok/s", phase: "decode" },
  decodeWallMs: { label: "decode request wall", unit: "ms", phase: "decode" },
  endToEndTps: { label: "actual output / wall", unit: "tok/s (genTokens ÷ wall)", phase: "decode" },
  ttftColdMs: { label: "TTFT cold @~1k", unit: "ms", phase: "ttft1k" },
  prefill1kTps: { label: "prefill @~1k", unit: "tok/s (promptTokens ÷ TTFT)", phase: "ttft1k" },
  ttftWarmMs: { label: "TTFT warm repeat", unit: "ms", phase: "ttft1k" },
  ctxPromptTokens: { label: "ctx measured", unit: "prompt tokens", phase: "ctx" },
  ctxPrefillTps: { label: "prefill @ctx", unit: "tok/s (promptTokens ÷ TTFT)", phase: "ctx" },
  ctxTtftMs: { label: "TTFT @ctx", unit: "ms", phase: "ctx" },
  ctxDecodeTps: { label: "decode @ctx", unit: "SSE window tok/s", phase: "ctx" },
  ctxRepeatTtftMs: { label: "ctx cached repeat TTFT", unit: "ms", phase: "ctx" },
  restartCtxTtftMs: { label: "restart ctx TTFT", unit: "ms", phase: "restart" },
  restartReadyMs: { label: "restart load→ready", unit: "ms", phase: "restart" },
  aggTps: { label: "aggregate ×4 streams", unit: "tok/s", phase: "agg" },
  aggPerStream: { label: "per-stream @4", unit: "SSE window tok/s", phase: "agg" },
  idleRssMB: { label: "idle RSS", unit: "process RSS MB (ps)", phase: "startup" },
  peakRssMB: { label: "peak RSS", unit: "process RSS MB (ps)", phase: "startup" },
};

export interface ServeRow {
  kind: "serve";
  source: string; sourceSha256: string;
  machine: MachineIdentity;
  model: string; modelLabel: string; artifact: string; configSha256: string | null; packedTrellis: boolean;
  /** Path plus config identity. A config hash alone does not identify weights. */
  artifactKey: string;
  runtimeEnvironment: Record<string, string>;
  arm: Arm; command: string[] | null;
  workload: ServeWorkload; workloadKey: string;
  diagnostic: boolean; configured: string[];
  requestChecks: Record<string, Array<{ key: string; output: string | null; prompt: number; cached: number; generated: number; finish: string | null }>>;
  status: "measured" | "unsupported" | "failed" | "not-measured";
  note: string;
  metrics: Record<MetricKey, Metric>;
  flags: string[]; warnings: string[]; parity: string[];
  phaseFailures: PhaseFailure[];
  requestErrors: { phase: string; attempt: number; index: number; error: string }[];
  finishReasons: Record<string, number>;
  rssByLeg: Array<[string, number]>;
  durability: RestartDurability | null;
  decodeSamples: number[];
}

const workloadKeyOf = (w: ServeWorkload): string => JSON.stringify([
  w.seed, w.contextTarget, w.decodeTokens, w.withContext, w.decodeRuns, w.enableThinking, w.referencePrefill ?? "server", w.allowedCpuProcess ?? "",
]);

/** Failed attempts remain in raw data; summaries use the final attempt only,
 * just as the serving harness's returned CellResult does. */
function finalPhaseRequests(requests: RawRequest[], phase: string): RawRequest[] {
  const all = requests.filter(q => q.phase === phase);
  const attempt = Math.max(-1, ...all.map(q => q.attempt));
  return all.filter(q => q.attempt === attempt && q.result && !q.error);
}

function metric(key: MetricKey, value: number | null, status: MetricStatus, note = "", samples?: number[]): Metric {
  const def = METRIC_DEFS[key];
  return { label: def.label, unit: def.unit, value, samples, n: samples ? samples.length : value == null ? 0 : 1, status, note };
}

function allMetrics(status: MetricStatus, note: string): Record<MetricKey, Metric> {
  return Object.fromEntries(METRIC_KEYS.map((k) => [k, metric(k, null, status, note)])) as Record<MetricKey, Metric>;
}

const count = (xs: Array<string | null | undefined>): Record<string, number> => {
  const out: Record<string, number> = {};
  for (const x of xs) out[x ?? "none"] = (out[x ?? "none"] ?? 0) + 1;
  return out;
};
const mixText = (counts: Record<string, number>): string => Object.entries(counts).map(([k, n]) => `${k}×${n}`).join(" ");

const CONFIGURED_FLAGS = ["--draft-model", "--draft-kind", "--num-draft-tokens", "--kv-quant", "--prompt-cache"];

export function serveRows(loaded: { report: ServeRawReport; path: string; sha256: string }): ServeRow[] {
  const { report, path, sha256 } = loaded;
  const machine = machineKey(report);
  const workloadKey = workloadKeyOf(report.workload);
  const warnings: string[] = [];
  if (report.sourceDiffStart !== report.sourceDiffAtSave) warnings.push("tracked source diff changed during the run (sourceDiffStart ≠ sourceDiffAtSave)");
  if (report.sourceSnapshotStart.sha256 !== report.sourceSnapshotAtSaveSha256) warnings.push("source snapshot changed during the run");
  if (!report.machineBefore.ok) warnings.push(`preflight not quiet before the run: ${report.machineBefore.problems.join("; ")}`);
  if (report.machineAtSave && !report.machineAtSave.ok) warnings.push(`machine not quiet at save: ${report.machineAtSave.problems.join("; ")}`);
  const env = Object.entries(report.runtimeEnvironment);
  if (env.length) warnings.push(`runtime overrides: ${env.map(([k, v]) => `${k}=${v}`).join(" ")}`);
  const rows: ServeRow[] = [];
  const models = new Map(report.models.map((m) => [m.id, m]));
  for (const cmd of report.commands) {
    const model = models.get(cmd.model);
    if (!model) continue;
    const key = `${cmd.model}/${cmd.arm}`;
    const configured = cmd.command ? CONFIGURED_FLAGS.flatMap((f) => {
      const i = cmd.command!.indexOf(f); return i < 0 ? [] : [`${f} ${cmd.command![i + 1] ?? ""}`.trim()];
    }) : [];
    const base: Omit<ServeRow, "status" | "note" | "metrics" | "flags" | "parity" | "phaseFailures" | "requestErrors" | "finishReasons" | "rssByLeg" | "durability" | "decodeSamples"> = {
      kind: "serve", source: path, sourceSha256: sha256, machine,
      model: cmd.model, modelLabel: model.label, artifact: model.path, configSha256: model.configSha256 ?? null,
      // Identical configs do not establish identical weights.
      packedTrellis: Boolean(model.packedTrellis), artifactKey: JSON.stringify([model.path, model.configSha256 ?? null]),
      runtimeEnvironment: { ...report.runtimeEnvironment },
      arm: cmd.arm, command: cmd.command, workload: report.workload, workloadKey,
      diagnostic: report.diagnostic, configured, warnings: [...warnings],
      requestChecks: Object.fromEntries([...new Set(report.requests.map(q => q.phase))].map(phase => [phase,
        finalPhaseRequests(report.requests.filter(q => q.cell.model === cmd.model && q.cell.arm === cmd.arm), phase)
          .map(q => ({ key: `${q.attempt}/${q.index}/${q.requestSha256}`,
            output: q.result!.textSha256 ?? (report.fixture ? null : createHash("sha256").update(q.result!.text).digest("hex")),
            prompt: q.result!.promptTokens, cached: q.result!.cachedTokens,
            generated: q.result!.genTokens, finish: q.result!.finishReason }))])),
    };
    const empty = { flags: [] as string[], parity: [] as string[], phaseFailures: [] as PhaseFailure[], requestErrors: [],
      finishReasons: {}, rssByLeg: [] as Array<[string, number]>, durability: null, decodeSamples: [] as number[] };
    const result = report.results.find((r) => r.cell.model === cmd.model && r.cell.arm === cmd.arm);
    if (!cmd.command) {
      const note = unsupportedBenchmarkArm(model, cmd.arm) ?? "required KV config or oracle executable missing";
      rows.push({ ...base, ...empty, status: "unsupported", note, metrics: allMetrics("unsupported", note) });
      continue;
    }
    if (!result) {
      const whole = report.failures.find((f) => f.cell === key);
      const note = whole ? whole.error : "cell never produced a result (run interrupted?)";
      rows.push({ ...base, ...empty, status: whole ? "failed" : "not-measured", note,
        metrics: allMetrics(whole ? "failed" : "not-measured", note) });
      continue;
    }
    rows.push(measuredRow(base, result, report, model));
  }
  // Parity verdicts (PARITY_PAIRS) attach to the candidate row of each pair.
  for (const model of models.keys()) {
    const arm = (a: Arm) => rows.find((r) => r.model === model && r.arm === a && r.status === "measured");
    const res = (a: Arm) => report.results.find((r) => r.cell.model === model && r.cell.arm === a);
    for (const [a, b, label] of PARITY_PAIRS) {
      const ra = arm(a), rb = arm(b);
      if (!ra || !rb) continue;
      ra.parity.push(probeVerdict("completion", label, res(a)?.parity?.completion, res(b)?.parity?.completion));
      ra.parity.push(probeVerdict("chat", label, res(a)?.parity?.chat, res(b)?.parity?.chat));
    }
  }
  return rows;
}

function measuredRow(base: Omit<ServeRow, "status" | "note" | "metrics" | "flags" | "parity" | "phaseFailures" | "requestErrors" | "finishReasons" | "rssByLeg" | "durability" | "decodeSamples">,
  r: CellResult, report: ServeRawReport, model: { id: string } & BenchmarkModel): ServeRow {
  const reqs = report.requests.filter((q) => q.cell.model === r.cell.model && q.cell.arm === r.cell.arm);
  const phaseStatus = (phase: string, present: boolean): { status: MetricStatus; note: string } => {
    const hard = r.phaseFailures.find((f) => f.phase === phase && !f.error.includes("recovered on retry"));
    const soft = r.phaseFailures.find((f) => f.phase === phase && f.error.includes("recovered on retry"));
    if (present) return soft ? { status: "recovered", note: soft.error } : { status: "measured", note: "" };
    if (hard) return { status: "failed", note: hard.error };
    if (phase === "ctx" && !report.workload.withContext) return { status: "not-measured", note: "--skip-context: long-context leg not run" };
    if (phase === "restart" && !r.ctx) return { status: "not-measured", note: "restart leg requires a measured ctx leg" };
    return { status: "not-measured", note: `${phase} phase never ran` };
  };
  const m = <K extends MetricKey>(key: K, present: boolean, value: number | null, samples?: number[]): Metric => {
    const ps = phaseStatus(METRIC_DEFS[key].phase, present);
    return metric(key, present ? value : null, ps.status, ps.note, present ? samples : undefined);
  };
  const decodeReqs = finalPhaseRequests(reqs, "decode");
  const wall = decodeReqs.map((q) => q.result!.wallMs);
  const e2e = decodeReqs.map((q) => q.result!.genTokens * 1000 / q.result!.wallMs);
  const metrics: Record<MetricKey, Metric> = {
    readyMs: m("readyMs", true, r.readyMs),
    coldStartMs: m("coldStartMs", r.coldStartMs != null, r.coldStartMs),
    decodeTps: m("decodeTps", r.decodeTps != null, r.decodeTps ? median(r.decodeTps) : null, r.decodeTps ?? undefined),
    decodeWallMs: m("decodeWallMs", wall.length > 0, wall.length ? median(wall) : null, wall),
    endToEndTps: m("endToEndTps", e2e.length > 0, e2e.length ? median(e2e) : null, e2e),
    ttftColdMs: m("ttftColdMs", r.ttft != null, r.ttft ? median(r.ttft.coldMs) : null, r.ttft?.coldMs),
    prefill1kTps: m("prefill1kTps", r.ttft != null, r.ttft ? median(r.ttft.prefill1kTps) : null, r.ttft?.prefill1kTps),
    ttftWarmMs: m("ttftWarmMs", r.ttft != null, r.ttft?.warmMs ?? null),
    ctxPromptTokens: m("ctxPromptTokens", r.ctx != null, r.ctx?.promptTokens ?? null),
    ctxPrefillTps: m("ctxPrefillTps", r.ctx != null, r.ctx?.prefillTps ?? null),
    ctxTtftMs: m("ctxTtftMs", r.ctx != null, r.ctx?.ttftMs ?? null),
    ctxDecodeTps: m("ctxDecodeTps", r.ctx != null, r.ctx ? median(r.ctx.decodeTps) : null, r.ctx?.decodeTps),
    ctxRepeatTtftMs: m("ctxRepeatTtftMs", r.ctx != null, r.ctx?.cachedRepeatTtftMs ?? null),
    restartCtxTtftMs: m("restartCtxTtftMs", r.restart != null, r.restart?.ctxTtftMs ?? null),
    restartReadyMs: m("restartReadyMs", r.restart != null, r.restart?.readyMs ?? null),
    aggTps: m("aggTps", r.agg != null, r.agg?.tps ?? null),
    aggPerStream: m("aggPerStream", r.agg != null, r.agg?.perStream ?? null),
    idleRssMB: m("idleRssMB", true, r.idleRssMB),
    peakRssMB: m("peakRssMB", true, r.peakRssMB),
  };
  const flags: string[] = [];
  if (report.diagnostic) flags.push("DIAGNOSTIC run: not eligible for canonical claims; never a baseline");
  if (base.configured.length) flags.push(`configured experiment (${base.configured.join(" ")}): compare only with matching-policy controls`);
  if (r.decodeTag) flags.push(`decode ${r.decodeTag}`);
  const finishReasons = count(reqs.filter((q) => q.result).map((q) => q.result!.finishReason));
  if (Object.keys(finishReasons).length) flags.push(`finish reasons: ${mixText(finishReasons)}`);
  const early = decodeReqs.filter((q) => q.result!.genTokens < q.request.maxTokens);
  if (early.length) flags.push(`EARLY EOS on ${early.length}/${decodeReqs.length} decode samples (genTokens ${early.map((q) => q.result!.genTokens).join(",")} < requested ${report.workload.decodeTokens}); not the same work as a length-limited sample`);
  if (decodeReqs.length) flags.push(`decode actual output counts ${decodeReqs.map((q) => q.result!.genTokens).join(",")} (requested ${report.workload.decodeTokens})`);
  const noUsage = reqs.filter((q) => q.result && !q.result.usedUsage);
  if (noUsage.length) flags.push(`${noUsage.length} requests without usage: token counts unverified`);
  if (r.ttft) flags.push(r.ttft.warmCachedTokens > 0 ? `warm repeat reused ${r.ttft.warmCachedTokens} cached tokens` : "warm repeat reused 0 cached tokens (no prompt-cache hit reported)");
  if (r.restart) flags.push(r.restart.cachedTokens > 0 ? `restart reused ${r.restart.cachedTokens} cached tokens` : "restart reused 0 cached tokens (full re-prefill)");
  if (r.restart?.durability) {
    const d = r.restart.durability;
    flags.push(`cache durable=${d.durable} · flush ${d.flushMs.toFixed(0)} ms · longest prefix ${d.longestDurablePrefixTokens} tok · entries ${d.entries} · pending ${d.pendingSnapshots}/${d.pendingSpills} · dropped/failed ${d.droppedSpills}/${d.failedSpills}`);
    if (!d.durable || d.failedSpills > 0 || d.droppedSpills > 0) flags.push("DURABILITY: flush reported failed or dropped spills");
  }
  const requestErrors = reqs.filter((q) => q.error).map((q) => ({ phase: q.phase, attempt: q.attempt, index: q.index, error: q.error! }));
  if (requestErrors.length) flags.push(`${requestErrors.length} request errors retained (see raw request table)`);
  const retried = new Set(reqs.filter((q) => q.attempt > 0).map((q) => q.phase));
  if (retried.size) flags.push(`retried phases: ${[...retried].join(", ")} (compare matching attempts only)`);
  for (const f of r.phaseFailures) flags.push(`phase ${f.phase}: ${f.error.includes("recovered on retry") ? "RECOVERED" : "FAILED"} — ${f.error}`);
  const failedAny = r.phaseFailures.some((f) => !f.error.includes("recovered on retry"));
  return {
    ...base, status: "measured", note: failedAny ? "some phases failed; see flags" : "",
    metrics, flags, parity: [], phaseFailures: r.phaseFailures, requestErrors, finishReasons,
    rssByLeg: r.rssByLeg, durability: r.restart?.durability ?? null, decodeSamples: r.decodeTps ?? [],
    packedTrellis: Boolean(model.packedTrellis),
  };
}

// ---- native rows --------------------------------------------------------------

export interface NativeRow {
  kind: "native";
  source: string; sourceSha256: string; machine: MachineIdentity;
  stack: "mlx-bun" | "mlx-lm"; artifact: string; configSha256: string; promptSha256: string; variant: string;
  diagnostic: boolean; complete: boolean; error: string | null; n: number;
  wallMs: { median: number; min: number; max: number } | null;
  firstTokenMs: number | null; peakBytes: number | null;
  finishReasons: Record<string, number>;
  identity: { against: string; identical: boolean; comparedSamples: number; firstDivergence: { sample: number; index: number } | null }[];
  flags: string[];
}

export function nativeIdentity(a: NativeBenchSample[], b: NativeBenchSample[]): { identical: boolean; comparedSamples: number; firstDivergence: { sample: number; index: number } | null } {
  const n = Math.min(a.length, b.length);
  for (let s = 0; s < n; s++) {
    const ta = a[s]!.tokens, tb = b[s]!.tokens;
    const len = Math.max(ta.length, tb.length);
    for (let i = 0; i < len; i++) if (ta[i] !== tb[i]) return { identical: false, comparedSamples: n, firstDivergence: { sample: s, index: i } };
  }
  return { identical: n > 0, comparedSamples: n, firstDivergence: null };
}

export function nativeRows(loaded: Array<{ report: NativeRawReport; path: string; sha256: string }>): NativeRow[] {
  return loaded.map(({ report, path, sha256 }) => {
    const samples = report.samples ?? [];
    const walls = samples.map((s) => s.wallMs);
    const firsts = samples.map((s) => s.firstTokenMs).filter((v): v is number => v != null);
    const flags: string[] = [];
    const complete = report.complete === true;
    if (!complete) flags.push(`INCOMPLETE run${report.error ? `: ${report.error}` : ""}`);
    if (report.canonical === false) flags.push("native diagnostic: not an HTTP measurement");
    if (report.machineBefore && !report.machineBefore.ok) flags.push(`preflight not quiet: ${report.machineBefore.problems.join("; ")}`);
    const identity = loaded.filter((o) => o.report !== report && o.report.configSha256 === report.configSha256 && o.report.promptSha256 === report.promptSha256)
      .map((o) => ({ against: `${o.report.stack} (${basename(o.path)})`, ...nativeIdentity(samples, o.report.samples ?? []) }));
    for (const id of identity) flags.push(id.identical ? `token IDs identical vs ${id.against} over ${id.comparedSamples} samples`
      : `TOKEN IDS DIVERGE vs ${id.against}${id.firstDivergence ? ` at sample ${id.firstDivergence.sample} index ${id.firstDivergence.index}` : " (no samples compared)"}`);
    return {
      kind: "native", source: path, sourceSha256: sha256, machine: machineKey(report),
      stack: report.stack, artifact: report.artifact, configSha256: report.configSha256, promptSha256: report.promptSha256,
      variant: String(report.variant ?? ""), diagnostic: Boolean(report.options?.diagnostic), complete, error: report.error ?? null,
      n: samples.length,
      wallMs: walls.length ? { median: median(walls), min: Math.min(...walls), max: Math.max(...walls) } : null,
      firstTokenMs: firsts.length ? median(firsts) : null,
      peakBytes: samples.length ? Math.max(...samples.map((s) => s.peakBytes)) : null,
      finishReasons: count(samples.map((s) => s.finishReason)), identity, flags,
    };
  });
}

// ---- pairing ------------------------------------------------------------------

export interface Ratio { ratio: number | null; n: number; nA?: number; nB?: number; samplesA?: number[]; samplesB?: number[]; status: MetricStatus | "no-baseline"; note: string }
export interface PairedRow {
  row: ServeRow; baseline: ServeRow | null;
  status: "paired" | "self" | "unsupported" | "no compatible baseline"; note: string;
  ratios: Record<MetricKey, Ratio>;
}

/** Ratios only within one machine key, one artifact and one workload. Diagnostic
 *  rows never serve as baseline. Unsupported baselines keep their reason. */
export interface BaselineEnvironment { key: string; value: string }

export function pairRows(rows: ServeRow[], baselineArm: Arm | null, baselineEnv?: BaselineEnvironment): PairedRow[] {
  const isBaseline = (row: ServeRow) => row.arm === baselineArm &&
    (!baselineEnv || row.runtimeEnvironment[baselineEnv.key] === baselineEnv.value);
  const baselineLabel = `${baselineArm}${baselineEnv ? ` (${baselineEnv.key}=${baselineEnv.value})` : ""}`;
  const none = (status: MetricStatus | "no-baseline", note: string): Record<MetricKey, Ratio> =>
    Object.fromEntries(METRIC_KEYS.map((k) => [k, { ratio: null, n: 0, status, note }])) as Record<MetricKey, Ratio>;
  const eligible = (row: ServeRow) => !row.diagnostic && !row.warnings.some(w =>
    w.includes("changed during the run") || w.startsWith("preflight not quiet") || w.startsWith("machine not quiet"));
  return rows.map((row) => {
    if (!baselineArm) return { row, baseline: null, status: "no compatible baseline", note: "no baseline selected", ratios: none("no-baseline", "no baseline selected") };
    if (isBaseline(row)) return { row, baseline: row, status: "self", note: "baseline row", ratios: none("no-baseline", "baseline row") };
    if (!eligible(row)) return { row, baseline: null, status: "no compatible baseline",
      note: "diagnostic, nonquiet or changing-source run", ratios: none("no-baseline", "run does not qualify for speed ratios") };
    const modelMeta: BenchmarkModel = { path: row.artifact, label: row.modelLabel, packedTrellis: row.packedTrellis };
    const unsupported = unsupportedBenchmarkArm(modelMeta, baselineArm);
    const baseline = rows.find((b) => b !== row && isBaseline(b) && eligible(b) && b.status === "measured" &&
      b.machine.key === row.machine.key && b.artifactKey === row.artifactKey && b.workloadKey === row.workloadKey &&
      (b.source === row.source || (b.machine.host !== "not recorded" && row.machine.host !== "not recorded")));
    if (!baseline) {
      if (unsupported) return { row, baseline: null, status: "unsupported", note: `${baselineArm}: ${unsupported}`, ratios: none("unsupported", unsupported) };
      const why = rows.some((b) => b.arm === baselineArm && b.artifactKey === row.artifactKey) ?
        `no ${baselineArm} row on the same machine and workload (${row.machine.key}; ${row.workloadKey})` :
        `no ${baselineArm} row for this artifact`;
      return { row, baseline: null, status: "no compatible baseline", note: why, ratios: none("no-baseline", why) };
    }
    const ratios = Object.fromEntries(METRIC_KEYS.map((k) => {
      const a = row.metrics[k], b = baseline.metrics[k];
      if (a.status !== "measured" && a.status !== "recovered") return [k, { ratio: null, n: 0, status: a.status, note: a.note || `${a.status} on this row` }];
      if (b.status !== "measured" && b.status !== "recovered") return [k, { ratio: null, n: 0, status: b.status, note: `baseline ${b.status}${b.note ? `: ${b.note}` : ""}` }];
      const phase = METRIC_DEFS[k].phase;
      if (phase !== "startup") {
        const checks = row.requestChecks[phase] ?? [], other = baseline.requestChecks[phase] ?? [];
        const reason = !checks.length || !other.length ? "no matching request evidence" :
          checks.length !== other.length || checks.some((c, i) => c.key !== other[i]?.key) ? "request/attempt mismatch" :
          checks.some(c => c.output === null) || other.some(c => c.output === null) ? "full output identity not recorded" :
          checks.some((c, i) => c.cached !== other[i]!.cached) ? "cache reuse mismatch" :
          checks.some((c, i) => c.output !== other[i]!.output || c.prompt !== other[i]!.prompt ||
            c.generated !== other[i]!.generated || c.finish !== other[i]!.finish) ? "output or usage mismatch" : null;
        if (reason) return [k, { ratio: null, n: 0, status: "not-measured", note: `${phase}: ${reason}; raw timings remain visible` }];
      }
      if (a.value == null || b.value == null || a.value <= 0 || b.value <= 0) return [k, { ratio: null, n: 0, status: "not-measured" as MetricStatus, note: "positive values required" }];
      const ratio = LOWER_IS_BETTER.has(k) ? b.value / a.value : a.value / b.value;
      const n = Math.min(a.n, b.n);
      return [k, { ratio, n, nA: a.n, nB: b.n, samplesA: a.samples, samplesB: b.samples, status: a.status === "recovered" || b.status === "recovered" ? "recovered" : "measured",
        note: a.status === "recovered" || b.status === "recovered" ? "one side recovered on retry" : "" }];
    })) as Record<MetricKey, Ratio>;
    return { row, baseline, status: "paired", note: `vs ${baselineLabel} · ${baseline.source === row.source ? "same file" : basename(baseline.source)}`, ratios };
  });
}

export const BASELINE_ORDER: readonly Arm[] = ["mlx-lm", "mlx-bun-serial", "mlx-bun"];
export function defaultBaseline(rows: ServeRow[]): Arm | null {
  for (const arm of BASELINE_ORDER) if (rows.some((r) => r.arm === arm && r.status === "measured" && !r.diagnostic)) return arm;
  return null;
}

// ---- fixture trimming -----------------------------------------------------------

const TRIM_TEXT = 48, TRIM_EVENTS = 3;
export const TRIM_RULES = [
  `sourceSnapshotStart.files dropped; sha256 and fileCount kept`,
  `cells filtered to the listed models × arms (models, commands, results, requests, failures)`,
  `requests[].request.content and requests[].result.text cut to ${TRIM_TEXT} chars; parity probe texts kept whole`,
  `requests[].result.outputEventTimesMs cut to the first ${TRIM_EVENTS} entries`,
  `compact JSON`,
];

/** Deterministic and idempotent: trimming a trimmed fixture returns the same object. */
export function trimRawForFixture(raw: ServeRawReport, keep: { models: string[]; arms: string[] }, trimmedFrom?: string): ServeRawReport {
  const r = structuredClone(raw);
  const keepCell = (model: string, arm: string) => keep.models.includes(model) && keep.arms.includes(arm);
  r.sourceSnapshotStart = { sha256: r.sourceSnapshotStart.sha256,
    fileCount: r.sourceSnapshotStart.files.length || r.sourceSnapshotStart.fileCount || 0, files: [] };
  r.models = r.models.filter((m) => keep.models.includes(m.id));
  r.commands = r.commands.filter((c) => keepCell(c.model, c.arm));
  r.results = r.results.filter((c) => keepCell(c.cell.model, c.cell.arm));
  r.failures = r.failures.filter((f) => r.commands.some((c) => f.cell.startsWith(`${c.model}/${c.arm}`)));
  r.requests = r.requests.filter((q) => keepCell(q.cell.model, q.cell.arm)).map((q) => ({
    ...q,
    request: { ...q.request, content: q.request.content.slice(0, TRIM_TEXT) },
    ...(q.result ? { result: { ...q.result,
      ...(q.result.textSha256 || !raw.fixture ? {
        textSha256: q.result.textSha256 ?? createHash("sha256").update(q.result.text).digest("hex"),
      } : {}),
      text: q.result.text.slice(0, TRIM_TEXT), outputEventTimesMs: q.result.outputEventTimesMs.slice(0, TRIM_EVENTS) } } : {}),
  }));
  r.fixture = { trimmedFrom: r.fixture?.trimmedFrom ?? trimmedFrom ?? "unknown", rules: [...TRIM_RULES] };
  return r;
}

// ---- HTML -------------------------------------------------------------------------

export function escapeHtml(s: unknown): string {
  return String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);
}
/** JSON safe inside <script>: no `</script>` break-out, no line terminators the JS parser rejects. */
export function jsonForScript(obj: unknown): string {
  return JSON.stringify(obj).replace(/</g, "\\u003c").replace(/\u2028/g, "\\u2028").replace(/\u2029/g, "\\u2029");
}
const esc = escapeHtml;

/** Percentile bootstrap of independent block log-ratios. Requests inside a
 * block are summarized before this function; they are never extra replicates. */
export function pairedLogRatioInterval(ratios: number[]): { n: number; factor: number; low: number; high: number } | null {
  if (ratios.length < 5 || ratios.some(r => !Number.isFinite(r) || r <= 0)) return null;
  const logs = ratios.map(Math.log), n = logs.length;
  let seed = 0x6d6c7862;
  const draw = (): number => {
    seed ^= seed << 13; seed ^= seed >>> 17; seed ^= seed << 5;
    return (seed >>> 0) / 0x100000000;
  };
  const samples = Array.from({ length: 20_000 }, () => {
    let total = 0;
    for (let i = 0; i < n; i++) total += logs[Math.floor(draw() * n)]!;
    return total / n;
  }).sort((a, b) => a - b);
  return { n, factor: Math.exp(logs.reduce((a, b) => a + b, 0) / n),
    low: Math.exp(samples[499]!), high: Math.exp(samples[19_499]!) };
}

export interface BlockSummary {
  machine: string; model: string; baseline: string; candidate: string;
  metric: MetricKey; blocks: Array<{ seed: string; baseline: string; candidate: string; ratio: number }>;
  interval: ReturnType<typeof pairedLogRatioInterval>;
}

export function summarizeBlocks(inputs: LoadedReport[], pairs: PairedRow[]): BlockSummary[] {
  const sources = new Map(inputs.filter((i): i is Extract<LoadedReport, { kind: "serve" }> => i.kind === "serve")
    .map(i => [i.path, i.report]));
  const groups = new Map<string, BlockSummary>();
  for (const pair of pairs) {
    if (pair.status !== "paired" || !pair.baseline) continue;
    const row = pair.row, baseline = pair.baseline;
    const a = sources.get(baseline.source), b = sources.get(row.source);
    // A recorded seed defines one independent workload block. Repeated files
    // or reruns of the same seed cannot inflate the replication count.
    if (!a || !b || !row.workload.seed) continue;
    const { seed, ...workload } = row.workload;
    const configuration = [row.machine.key, row.artifactKey, baseline.arm, row.arm,
      a.sourceSnapshotStart.sha256, b.sourceSnapshotStart.sha256, a.bun, b.bun,
      a.runtimeEnvironment, b.runtimeEnvironment, baseline.configured, row.configured, workload];
    for (const metric of METRIC_KEYS) {
      const ratio = pair.ratios[metric].ratio;
      if (metric === "ctxPromptTokens" || ratio === null) continue;
      const key = JSON.stringify([...configuration, metric]);
      let group = groups.get(key);
      if (!group) {
        group = { machine: row.machine.key, model: row.modelLabel,
          baseline: [baseline.arm, ...baseline.configured].join(" "),
          candidate: [row.arm, ...row.configured].join(" "), metric, blocks: [], interval: null };
        groups.set(key, group);
      }
      if (!group.blocks.some(block => block.seed === seed))
        group.blocks.push({ seed, baseline: baseline.source, candidate: row.source, ratio });
    }
  }
  for (const group of groups.values()) group.interval = pairedLogRatioInterval(group.blocks.map(b => b.ratio));
  return [...groups.values()];
}

export interface ReportModel {
  title: string; generatedAt: string;
  inputs: LoadedReport[];
  serveRows: ServeRow[]; nativeRows: NativeRow[];
  baselineArms: Arm[]; defaultBaseline: Arm | null; baselineEnv?: BaselineEnvironment;
  pairsByBaseline: Record<string, PairedRow[]>;
  machines: MachineIdentity[];
  blockSummaries: BlockSummary[];
}

export function buildReportModel(inputs: LoadedReport[], opts: { baseline?: Arm | null; title?: string; baselineEnv?: BaselineEnvironment } = {}): ReportModel {
  const serve = inputs.filter((i): i is Extract<LoadedReport, { kind: "serve" }> => i.kind === "serve");
  const native = inputs.filter((i): i is Extract<LoadedReport, { kind: "native" }> => i.kind === "native");
  const rows = serve.flatMap((s) => serveRows(s));
  if (opts.baselineEnv) for (const row of rows)
    row.configured.push(`${opts.baselineEnv.key}=${row.runtimeEnvironment[opts.baselineEnv.key] ?? "(unset)"}`);
  const baselineArms = [...new Set(rows.filter((r) => r.status === "measured").map((r) => r.arm))];
  const requested = opts.baseline ?? defaultBaseline(rows);
  const dflt = requested && baselineArms.includes(requested) ? requested : defaultBaseline(rows);
  const pairsByBaseline = Object.fromEntries([...baselineArms, "none"].map((arm) => [arm, pairRows(rows, arm === "none" ? null : arm as Arm, opts.baselineEnv)]));
  const machines = [...new Map([...rows.map((r) => r.machine), ...native.map((n) => machineKey(n.report))].map((m) => [m.key, m])).values()];
  return { title: opts.title ?? "mlx-bun benchmark comparison", generatedAt: new Date().toISOString(), inputs,
    serveRows: rows, nativeRows: nativeRows(native), baselineArms, defaultBaseline: dflt, baselineEnv: opts.baselineEnv, pairsByBaseline, machines,
    blockSummaries: summarizeBlocks(inputs, pairsByBaseline[dflt ?? "none"] ?? []) };
}

const fmt = (v: number | null | undefined, digits = 1): string => v == null || !Number.isFinite(v) ? "—" : v.toFixed(digits);
const digitsFor = (key: MetricKey): number => key === "ctxPromptTokens" ? 0 : /Ms$|MB$/.test(key) ? 0 : 1;

function metricCell(key: MetricKey, m: Metric, ratio: Ratio | null): string {
  const status = m.status;
  const val = status === "measured" || status === "recovered" ? `<b>${fmt(m.value, digitsFor(key))}</b>` : `<span class="st st-${status}">${esc(status)}</span>`;
  const note = m.note ? `<div class="note" title="${esc(m.note)}">${esc(m.note.slice(0, 90))}${m.note.length > 90 ? "…" : ""}</div>` : "";
  const recovered = status === "recovered" ? `<span class="st st-recovered">recovered</span>` : "";
  const n = m.samples && m.samples.length > 1 ? `<span class="n">n=${m.samples.length}</span>` : "";
  let ratioHtml = "";
  if (ratio && ratio.status !== "no-baseline") {
    ratioHtml = ratio.ratio == null
      ? `<div class="ratio st-${esc(ratio.status)}" title="${esc(ratio.note)}">${esc(ratio.status)}</div>`
      : `<div class="ratio ${ratio.ratio >= 1.02 ? "good" : ratio.ratio <= 0.98 ? "bad" : "flat"}" title="${esc(ratio.note)}">×${ratio.ratio.toFixed(2)}${ratio.n > 1 ? ` <span class="n">n=${ratio.nA}/${ratio.nB}</span>` : ""}</div>`;
  }
  return `<td class="m st-${esc(status)}" data-metric="${esc(key)}">${val}${recovered}${n}${ratioHtml}${note}</td>`;
}

function dotStrip(samples: number[], width = 140): string {
  if (!samples.length) return `<span class="st st-not-measured">not measured</span>`;
  const min = Math.min(...samples), max = Math.max(...samples), span = max - min || 1;
  const pts = samples.map((v) => `<circle cx="${(6 + (v - min) / span * (width - 12)).toFixed(1)}" cy="8" r="3.5"/>`).join("");
  return `<svg class="strip" viewBox="0 0 ${width} 16" width="${width}" height="16" role="img" aria-label="${esc(samples.map((v) => v.toFixed(1)).join(", "))}"><line x1="4" y1="8" x2="${width - 4}" y2="8"/>${pts}</svg>` +
    `<span class="n">${esc(fmt(min))}–${esc(fmt(max))}</span>`;
}

function scatterSvg(rows: ServeRow[]): string {
  const pts = rows.filter((r) => r.metrics.decodeTps.value != null && r.metrics.peakRssMB.value != null);
  if (!pts.length) return `<p class="st st-not-measured">not measured: no row has both decode tok/s and peak RSS</p>`;
  const W = 560, H = 300, L = 60, R = 20, T = 20, B = 44;
  const xs = pts.map((r) => r.metrics.peakRssMB.value!), ys = pts.map((r) => r.metrics.decodeTps.value!);
  const xMax = Math.max(...xs) * 1.08, yMax = Math.max(...ys) * 1.08;
  const x = (v: number) => L + v / xMax * (W - L - R), y = (v: number) => T + (1 - v / yMax) * (H - T - B);
  const ticks = (max: number) => [0, 0.25, 0.5, 0.75, 1].map((f) => f * max);
  let out = `<svg class="scatter" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" role="img" aria-label="peak process RSS versus decode tok/s">`;
  out += `<line class="axis" x1="${L}" y1="${H - B}" x2="${W - R}" y2="${H - B}"/><line class="axis" x1="${L}" y1="${T}" x2="${L}" y2="${H - B}"/>`;
  for (const t of ticks(xMax)) out += `<text class="tick" x="${x(t).toFixed(1)}" y="${H - B + 16}" text-anchor="middle">${t.toFixed(0)}</text>`;
  for (const t of ticks(yMax)) out += `<text class="tick" x="${L - 6}" y="${(y(t) + 4).toFixed(1)}" text-anchor="end">${t.toFixed(0)}</text>`;
  out += `<text class="label" x="${(L + (W - R)) / 2}" y="${H - 6}" text-anchor="middle">peak process RSS MB (ps; undercounts GPU-shared pages)</text>`;
  out += `<text class="label" transform="translate(14 ${(T + H - B) / 2}) rotate(-90)" text-anchor="middle">decode SSE window tok/s</text>`;
  for (const r of pts) {
    const title = `${r.modelLabel} · ${r.arm} · ${r.machine.key}: ${fmt(r.metrics.peakRssMB.value, 0)} MB, ${fmt(r.metrics.decodeTps.value)} tok/s`;
    out += `<g class="pt arm-${esc(r.arm)}" data-row="${esc(rowId(r))}"><circle cx="${x(r.metrics.peakRssMB.value!).toFixed(1)}" cy="${y(r.metrics.decodeTps.value!).toFixed(1)}" r="5"><title>${esc(title)}</title></circle>` +
      `<text x="${(x(r.metrics.peakRssMB.value!) + 7).toFixed(1)}" y="${(y(r.metrics.decodeTps.value!) - 6).toFixed(1)}">${esc(r.arm)}</text></g>`;
  }
  return out + `</svg>`;
}

const rowId = (r: ServeRow): string => createHash("sha256").update([r.sourceSha256, r.model, r.arm].join("\0")).digest("hex").slice(0, 12);

function provenancePanel(input: LoadedReport): string {
  const li = (k: string, v: unknown) => `<tr><th>${esc(k)}</th><td>${esc(v == null || v === "" ? "not recorded" : v)}</td></tr>`;
  if (input.kind === "serve") {
    const r = input.report, mk = machineKey(r);
    const cmds = r.commands.map((c) => `<li><code>${esc(c.model)}/${esc(c.arm)}</code>: ${c.command ? `<code>${esc(c.command.join(" "))}</code>` : `<span class="st st-unsupported">unsupported</span> ${esc(unsupportedBenchmarkArm(r.models.find((m) => m.id === c.model) ?? { path: "", label: c.model }, c.arm) ?? "required KV config or oracle executable missing")}`}</li>`).join("");
    return `<details class="prov" open><summary><code>${esc(basename(input.path))}</code> · serve schema ${esc(r.schemaVersion)} · ${esc(mk.key)}${r.diagnostic ? ' <span class="st st-failed">DIAGNOSTIC</span>' : ""}${r.fixture ? ' <span class="st st-not-measured">trimmed fixture</span>' : ""}</summary>
<table class="kv">${li("file", input.path)}${li("file sha256", input.sha256)}${li("file bytes", input.bytes)}${li("machine", r.machine)}${li("host", r.host)}${li("commit", r.commit)}${li("Bun", r.bun)}${li("MLX / native library", r.nativeLibrary ?? "not recorded in schema 4 (see native reports)")}${li("qualification", r.qualification)}${li("diagnostic", r.diagnostic)}${li("workload seed", r.workload.seed)}${li("decode tokens requested", r.workload.decodeTokens)}${li("context target", r.workload.contextTarget)}${li("with context", r.workload.withContext)}${li("reference prefill", r.workload.referencePrefill ?? "server (stock; legacy report)")}${li("thinking", r.workload.enableThinking ? "enable_thinking=true pinned on every arm" : "not pinned")}${li("runtime env overrides", Object.keys(r.runtimeEnvironment).length ? JSON.stringify(r.runtimeEnvironment) : "none")}${li("source snapshot sha256 (start)", r.sourceSnapshotStart.sha256)}${li("source snapshot sha256 (at save)", r.sourceSnapshotAtSaveSha256)}${li("source snapshot files", r.sourceSnapshotStart.files.length || r.sourceSnapshotStart.fileCount)}${li("source diff sha256 (start / at save)", `${r.sourceDiffStart} / ${r.sourceDiffAtSave}`)}${li("preflight before", `${r.machineBefore.ok ? (r.machineBefore.allowedCpuProcesses?.length ? "passed with CPU allowance" : "quiet") : "NOT quiet"} · swap ${r.machineBefore.swapUsedMB} MB · free ${r.machineBefore.freePercent}% · load1m ${r.machineBefore.loadAvg1m} · ${r.machineBefore.problems.join("; ") || "no problems"} · ${r.machineBefore.at}`)}${li("preflight at save", `${r.machineAtSave.ok ? (r.machineAtSave.allowedCpuProcesses?.length ? "passed with CPU allowance" : "quiet") : "NOT quiet"} · ${r.machineAtSave.problems.join("; ") || "no problems"} · ${r.machineAtSave.at}`)}${li("models", r.models.map((m) => `${m.id} = ${m.label} @ ${m.path}${m.configSha256 ? ` (config ${m.configSha256})` : ""}${m.packedTrellis ? " [packed trellis]" : ""}`).join(" | "))}${li("requests retained", r.requests.length)}${li("whole-cell failures", r.failures.length)}${r.fixture ? li("fixture", `trimmed from ${r.fixture.trimmedFrom}: ${r.fixture.rules.join("; ")}`) : ""}${li("identity note", r.identityNote)}</table>
<p>commands (ports/SSD dirs as recorded):</p><ul class="cmds">${cmds}</ul></details>`;
  }
  const r = input.report, mk = machineKey(r);
  return `<details class="prov" open><summary><code>${esc(basename(input.path))}</code> · native schema ${esc(r.schemaVersion)} · ${esc(r.stack)} · ${esc(mk.key)}${r.complete === false ? ' <span class="st st-failed">INCOMPLETE</span>' : ""}</summary>
<table class="kv">${li("file", input.path)}${li("file sha256", input.sha256)}${li("host", r.host)}${li("chip / RAM", `${r.chip} / ${(r.ramBytes / 2 ** 30).toFixed(0)} GB`)}${li("artifact", r.artifact)}${li("config sha256", r.configSha256)}${li("index sha256", r.indexSha256)}${li("prompt sha256", r.promptSha256)}${li("prompt tokens", r.promptIds?.length)}${li("variant", r.variant)}${li("options", r.options ? JSON.stringify(r.options) : undefined)}${li("source commit / diff sha256", `${r.sourceCommit ?? "not recorded"} / ${r.sourceDiffSha256 ?? "not recorded"}`)}${li("native library", r.nativeLibrary ? `${r.nativeLibrary.path} sha256 ${r.nativeLibrary.sha256}` : "not recorded (oracle stack)")}${li("worker command", r.workerCommand?.join(" "))}${li("preflight before", r.machineBefore ? `${r.machineBefore.ok ? (r.machineBefore.allowedCpuProcesses?.length ? "passed with CPU allowance" : "quiet") : "NOT quiet"} · ${r.machineBefore.problems.join("; ") || "no problems"}` : undefined)}${li("complete", r.complete)}${li("error", r.error)}${li("note", r.note)}</table></details>`;
}

const STATUS_LEGEND = `<p class="legend"><span class="st st-measured">measured</span> <span class="st st-recovered">recovered</span> phase failed once and succeeded on retry · <span class="st st-failed">failed</span> phase failed after retry · <span class="st st-not-measured">not-measured</span> leg not run · <span class="st st-unsupported">unsupported</span> no same-artifact loader/oracle. Ratios: ×&gt;1 means this row beat the baseline (direction inverted for ms/MB). "decode" is the visible SSE interval, not GPU time; "actual output / wall" is completion tokens ÷ request wall time. RSS is the server process RSS from <code>ps</code>, never native peak allocation.</p>`;

export function renderHtml(model: ReportModel): string {
  const { serveRows: rows, nativeRows: natives } = model;
  const byMachine = new Map<string, ServeRow[]>();
  for (const r of rows) byMachine.set(r.machine.key, [...(byMachine.get(r.machine.key) ?? []), r]);
  const pairs = model.pairsByBaseline[model.defaultBaseline ?? "none"] ?? pairRows(rows, null);
  const pairOf = (r: ServeRow) => pairs.find((p) => p.row === r)!;
  const filterOptions = (values: string[]) => [...new Set(values)].map((v) => `<option value="${esc(v)}">${esc(v)}</option>`).join("");

  // matrix per machine
  let matrix = "";
  for (const [key, group] of byMachine) {
    const machine = group[0]!.machine;
    matrix += `<h3 class="machine" data-machine="${esc(key)}">${esc(machine.chip)} · ${machine.ramGiB == null ? "RAM unknown" : `${machine.ramGiB} GB`} · host ${esc(machine.host)}</h3>`;
    matrix += `<div class="scroll"><table class="matrix"><thead><tr><th>model</th><th>arm</th><th>status</th>${METRIC_KEYS.map((k) => `<th title="${esc(METRIC_DEFS[k].unit)}">${esc(METRIC_DEFS[k].label)}<br><small>${esc(METRIC_DEFS[k].unit)}</small></th>`).join("")}<th>decode samples</th><th>flags</th></tr></thead><tbody>`;
    for (const r of group) {
      const p = pairOf(r);
      const pairNote = p.status === "paired" ? `<div class="pair">${esc(p.note)}</div>` : p.status === "self" ? `<div class="pair">baseline</div>` : `<div class="pair st-${p.status === "unsupported" ? "unsupported" : "not-measured"}" title="${esc(p.note)}">${esc(p.status)}: ${esc(p.note)}</div>`;
      const flags = [...r.warnings.map((w) => `<li class="warn">${esc(w)}</li>`), ...r.flags.map((f) => `<li>${esc(f)}</li>`), ...r.parity.map((v) => `<li class="parity">${esc(v.replace(/^- \*\*|\*\*/g, ""))}</li>`)].join("");
      matrix += `<tr class="row" data-row="${esc(rowId(r))}" data-machine="${esc(key)}" data-model="${esc(r.modelLabel)}" data-arm="${esc(r.arm)}" data-kind="${r.packedTrellis ? "packed-trellis" : "affine/other"}" data-source="${esc(basename(r.source))}">` +
        `<td><b>${esc(r.modelLabel)}</b><div class="note" title="${esc(r.artifact)}">${esc(r.model)}${r.configSha256 ? ` · config ${esc(r.configSha256.slice(0, 12))}` : ""}${r.packedTrellis ? " · packed trellis" : ""}</div><div class="note">${esc(r.workloadKey)}</div></td>` +
        `<td><b>${esc(r.arm)}</b>${r.diagnostic ? '<div class="st st-failed">diagnostic</div>' : ""}${r.configured.length ? `<div class="note">${esc(r.configured.join(" "))}</div>` : ""}${pairNote}</td>` +
        `<td><span class="st st-${esc(r.status)}">${esc(r.status)}</span>${r.note ? `<div class="note" title="${esc(r.note)}">${esc(r.note.slice(0, 120))}</div>` : ""}</td>` +
        METRIC_KEYS.map((k) => metricCell(k, r.metrics[k], p.ratios[k])).join("") +
        `<td>${dotStrip(r.decodeSamples)}</td><td><ul class="flags">${flags || "<li>none</li>"}</ul></td></tr>`;
    }
    matrix += `</tbody></table></div>`;
  }
  if (!rows.length) matrix = `<p class="st st-not-measured">not measured: no serve report loaded</p>`;

  // per-machine comparison columns
  const setting = (r: ServeRow): string => model.baselineEnv ? `${model.baselineEnv.key}=${r.runtimeEnvironment[model.baselineEnv.key] ?? "unset"}` : "";
  const cellKey = (r: ServeRow): string => JSON.stringify([r.modelLabel, r.arm, r.workloadKey, setting(r)]);
  const cellKeys = [...new Map(rows.map((r) => [cellKey(r), r])).values()];
  let machineTable = `<div class="scroll"><table class="machines"><thead><tr><th>model</th><th>arm</th><th>workload</th>${model.machines.map((m) => `<th class="machine-col">${esc(m.key)}</th>`).join("")}</tr></thead><tbody>`;
  for (const c of cellKeys) {
    machineTable += `<tr><td>${esc(c.modelLabel)}</td><td>${esc(c.arm)}${setting(c) ? `<div class="note">${esc(setting(c))}</div>` : ""}</td><td>${esc(c.workloadKey)}</td>` + model.machines.map((m) => {
      const r = rows.find((x) => cellKey(x) === cellKey(c) && x.machine.key === m.key);
      if (!r) return `<td class="st-not-measured"><span class="st st-not-measured">not measured</span></td>`;
      const d = r.metrics.decodeTps, e = r.metrics.endToEndTps, rss = r.metrics.peakRssMB;
      const one = (mm: Metric, digits: number) => mm.status === "measured" || mm.status === "recovered" ? `<b>${fmt(mm.value, digits)}</b>` : `<span class="st st-${mm.status}">${esc(mm.status)}</span>`;
      return `<td class="st-${esc(r.status)}">${r.status === "measured" ? `decode ${one(d, 1)} SSE tok/s · actual ${one(e, 2)} tok/s · RSS ${one(rss, 0)} MB${r.phaseFailures.length ? ` <span class="st st-failed">${r.phaseFailures.length} phase issue(s)</span>` : ""}` : `<span class="st st-${esc(r.status)}">${esc(r.status)}</span> ${esc(r.note.slice(0, 80))}`}</td>`;
    }).join("") + `</tr>`;
  }
  machineTable += `</tbody></table></div>`;
  if (!rows.length) machineTable = "";

  const intervals = model.blockSummaries.filter(g => g.blocks.length > 1);
  const intervalTable = intervals.length ? `<div class="scroll"><table><thead><tr><th>machine / model</th><th>baseline → candidate</th><th>metric</th><th>independent blocks</th><th>factor</th><th>95% interval</th></tr></thead><tbody>${intervals.map(g =>
    `<tr><td>${esc(g.machine)}<br>${esc(g.model)}</td><td>${esc(g.baseline)} → ${esc(g.candidate)}</td><td>${esc(METRIC_DEFS[g.metric].label)}</td><td title="${esc(g.blocks.map(b => b.seed).join(", "))}">${g.blocks.length}</td><td>${g.interval ? fmt(g.interval.factor, 3) : "not measured"}</td><td>${g.interval ? `${fmt(g.interval.low, 3)}–${fmt(g.interval.high, 3)}` : "needs at least five blocks"}</td></tr>`).join("")}</tbody></table></div>` : `<p>Not measured: no repeated compatible blocks for the selected baseline.</p>`;

  // native table
  let nativeTable = `<p class="st st-not-measured">not measured: no native report loaded</p>`;
  if (natives.length) {
    nativeTable = `<div class="scroll"><table class="native"><thead><tr><th>stack</th><th>artifact</th><th>machine</th><th>n</th><th>wall ms median (min–max)</th><th>first token ms median</th><th>native peak bytes</th><th>finish</th><th>token identity</th><th>flags</th></tr></thead><tbody>` +
      natives.map((n) => `<tr><td><b>${esc(n.stack)}</b>${n.diagnostic ? '<div class="st st-failed">diagnostic</div>' : ""}</td><td title="${esc(n.artifact)}">${esc(basename(n.artifact))}<div class="note">config ${esc(n.configSha256.slice(0, 12))} · prompt ${esc(n.promptSha256.slice(0, 12))}${n.variant ? ` · variant ${esc(n.variant)}` : ""}</div></td><td>${esc(n.machine.key)}</td><td>${n.n}</td>` +
        `<td>${n.wallMs ? `<b>${fmt(n.wallMs.median, 0)}</b> (${fmt(n.wallMs.min, 0)}–${fmt(n.wallMs.max, 0)})` : `<span class="st st-${n.complete ? "not-measured" : "failed"}">${n.complete ? "not measured" : "failed"}</span>`}</td>` +
        `<td>${n.firstTokenMs == null ? '<span class="st st-not-measured">not measured</span>' : fmt(n.firstTokenMs, 0)}</td><td>${n.peakBytes == null ? '<span class="st st-not-measured">not measured</span>' : (n.peakBytes / 2 ** 20).toFixed(0) + " MiB"}</td>` +
        `<td>${esc(mixText(n.finishReasons) || "none")}</td><td>${n.identity.length ? n.identity.map((i) => `<div class="${i.identical ? "good" : "bad"}">${i.identical ? "identical" : "DIVERGES"} vs ${esc(i.against)} (${i.comparedSamples} samples${i.firstDivergence ? `, first at sample ${i.firstDivergence.sample} index ${i.firstDivergence.index}` : ""})</div>`).join("") : '<span class="st st-not-measured">no same-artifact/prompt native report to compare</span>'}</td>` +
        `<td><ul class="flags">${n.flags.map((f) => `<li>${esc(f)}</li>`).join("") || "<li>none</li>"}</ul></td></tr>`).join("") + `</tbody></table></div>`;
  }

  // failures
  const failureItems: string[] = [];
  for (const input of model.inputs) {
    if (input.kind !== "serve") { if (input.report.complete === false) failureItems.push(`<li><b>${esc(basename(input.path))}</b> native ${esc(input.report.stack)}: incomplete — ${esc(input.report.error ?? "no error text")}${input.report.workerStderr ? `<pre>${esc(String(input.report.workerStderr).slice(-2000))}</pre>` : ""}</li>`); continue; }
    for (const f of input.report.failures)
      failureItems.push(`<li><b>${esc(basename(input.path))}</b> ${esc(f.cell)}: ${esc(f.error)}${f.stderrTail?.length ? `<pre>${esc(f.stderrTail.join("\n"))}</pre>` : ""}</li>`);
    for (const r of input.report.results) for (const pf of r.phaseFailures)
      if (!input.report.failures.some((f) => f.cell === `${r.cell.model}/${r.cell.arm} [phase ${pf.phase}]`))
        failureItems.push(`<li><b>${esc(basename(input.path))}</b> ${esc(r.cell.model)}/${esc(r.cell.arm)} [phase ${esc(pf.phase)}]: ${esc(pf.error)}${pf.stderrTail?.length ? `<pre>${esc(pf.stderrTail.join("\n"))}</pre>` : ""}</li>`);
    for (const q of input.report.requests) if (q.error)
      failureItems.push(`<li><b>${esc(basename(input.path))}</b> request ${esc(q.cell.model)}/${esc(q.cell.arm)} ${esc(q.phase)} attempt ${q.attempt} #${q.index} (${esc(q.requestSha256.slice(0, 12))}): ${esc(q.error)}${q.processAtFailure ? ` · process pid ${q.processAtFailure.pid} exit ${esc(q.processAtFailure.exitCode)} signal ${esc(q.processAtFailure.signal)}` : ""}${q.stderrTail?.length ? `<pre>${esc(q.stderrTail.join("\n"))}</pre>` : ""}</li>`);
  }
  const failures = failureItems.length ? `<ul class="failures">${failureItems.join("")}</ul>` : `<p class="good">no failures, phase failures or request errors recorded</p>`;

  // raw request table, paired by phase/attempt/index/requestSha256 across arms of one model in one input
  let requestTables = "";
  for (const input of model.inputs) {
    if (input.kind !== "serve") continue;
    for (const m of input.report.models) {
      const reqs = input.report.requests.filter((q) => q.cell.model === m.id);
      if (!reqs.length) continue;
      const arms = [...new Set(reqs.map((q) => q.cell.arm))];
      const keys = [...new Map(reqs.map((q) => [`${q.phase}\0${q.attempt}\0${q.index}\0${q.requestSha256}`, q])).values()];
      requestTables += `<details><summary><code>${esc(basename(input.path))}</code> · ${esc(m.label)} · ${reqs.length} requests</summary><div class="scroll"><table class="requests"><thead><tr><th>phase</th><th>attempt</th><th>#</th><th>request sha256</th><th>max_tokens</th>${arms.map((a) => `<th>${esc(a)}</th>`).join("")}</tr></thead><tbody>`;
      for (const k of keys) {
        requestTables += `<tr><td>${esc(k.phase)}</td><td>${k.attempt}</td><td>${k.index}</td><td><code>${esc(k.requestSha256.slice(0, 16))}</code></td><td>${k.request.maxTokens}</td>` + arms.map((a) => {
          const q = reqs.find((x) => x.cell.arm === a && x.phase === k.phase && x.attempt === k.attempt && x.index === k.index && x.requestSha256 === k.requestSha256);
          if (!q) return `<td><span class="st st-not-measured">no matching request</span></td>`;
          if (q.error || !q.result) return `<td class="st-failed"><span class="st st-failed">error</span> ${esc(q.error ?? "no result")}</td>`;
          const r = q.result;
          return `<td>TTFT ${fmt(r.ttftMs, 0)} · wall ${fmt(r.wallMs, 0)} ms · SSE ${fmt(r.decodeTps)} tok/s · actual ${fmt(r.endToEndTps, 2)} tok/s · prompt ${r.promptTokens} (cached ${r.cachedTokens}) · gen ${r.genTokens} · <em>${esc(r.finishReason)}</em>${r.usedUsage ? "" : ' <span class="st st-failed">no usage</span>'}${r.toolCallChunks ? ` · tool chunks ${r.toolCallChunks}` : ""}<div class="note" title="${esc(r.text)}">${esc(r.text.slice(0, 60))}${r.text.length > 60 ? "…" : ""}</div></td>`;
        }).join("") + `</tr>`;
      }
      requestTables += `</tbody></table></div></details>`;
    }
  }
  if (!requestTables) requestTables = `<p class="st st-not-measured">not measured: no requests loaded</p>`;

  const payload = jsonForScript({
    generatedAt: model.generatedAt, defaultBaseline: model.defaultBaseline, baselineArms: model.baselineArms,
    inputs: model.inputs.map((i) => ({ kind: i.kind, path: i.path, sha256: i.sha256 })),
    rows: rows.map((r) => ({ id: rowId(r), machine: r.machine.key, model: r.modelLabel, arm: r.arm, kind: r.packedTrellis ? "packed-trellis" : "affine/other", source: basename(r.source), status: r.status, metrics: r.metrics })),
    pairsByBaseline: Object.fromEntries(Object.entries(model.pairsByBaseline).map(([arm, ps]) => [arm, ps.map((p) => ({ id: rowId(p.row), status: p.status, note: p.note, ratios: p.ratios }))])),
    metricKeys: METRIC_KEYS, lowerIsBetter: [...LOWER_IS_BETTER],
  });

  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="referrer" content="no-referrer">
<title>${esc(model.title)}</title>
<style>
:root{--bg:#fbfbf8;--ink:#1c1e1a;--muted:#5d625a;--panel:#ffffff;--line:#d9dcd3;--good:#1f7a3a;--bad:#b03a2e;--warn:#9a6a0a;--flat:#5d625a;--meas:#e8f2ea;--rec:#fff3d6;--fail:#fbe1de;--nm:#eeeeea;--uns:#e6e8f5}
@media(prefers-color-scheme:dark){:root{--bg:#111310;--ink:#eff1e9;--muted:#a9aca2;--panel:#191c18;--line:#353a32;--good:#67c981;--bad:#ef786d;--warn:#e1a34c;--flat:#a9aca2;--meas:#1e2f22;--rec:#3a2e12;--fail:#3f1e1a;--nm:#25282300;--uns:#23264a}}
body{margin:0;padding:18px 22px;background:var(--bg);color:var(--ink);font:13px/1.45 -apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif}
h1{font-size:20px;margin:0 0 4px}h2{font-size:16px;margin:26px 0 8px;border-bottom:1px solid var(--line);padding-bottom:4px}h3.machine{font-size:14px;margin:14px 0 6px;color:var(--muted)}
code,pre{font:12px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace}pre{white-space:pre-wrap;background:var(--panel);border:1px solid var(--line);padding:6px;max-height:240px;overflow:auto}
table{border-collapse:collapse;background:var(--panel)}th,td{border:1px solid var(--line);padding:4px 6px;text-align:left;vertical-align:top}th{background:var(--bg);font-weight:600}th small{color:var(--muted);font-weight:400}
.scroll{overflow-x:auto;max-width:100%}.kv th{width:220px;color:var(--muted)}.kv td{word-break:break-all}
.st{display:inline-block;padding:0 5px;border-radius:3px;font-size:11px;font-weight:600}.st-measured{background:var(--meas)}.st-recovered{background:var(--rec)}.st-failed{background:var(--fail)}.st-not-measured{background:var(--nm)}.st-unsupported{background:var(--uns)}
td.m{white-space:nowrap}td.m.st-failed,td.st-failed{background:var(--fail)}td.m.st-not-measured{background:var(--nm)}td.m.st-unsupported{background:var(--uns)}td.m.st-recovered{background:var(--rec)}
.n{color:var(--muted);font-size:11px;margin-left:4px}.note{color:var(--muted);font-size:11px;white-space:normal;max-width:260px}.pair{font-size:11px;color:var(--muted);max-width:220px;white-space:normal}
.ratio{font-size:11px}.ratio.good,.good{color:var(--good)}.ratio.bad,.bad{color:var(--bad)}.ratio.flat{color:var(--flat)}
ul.flags{margin:0;padding-left:14px;font-size:11px;max-width:420px}ul.flags li.warn{color:var(--warn)}ul.flags li.parity{color:var(--muted)}
ul.cmds{font-size:11px}ul.failures li{margin-bottom:8px}.legend{color:var(--muted);font-size:12px}
svg.strip line{stroke:var(--line);stroke-width:1}svg.strip circle{fill:var(--ink);opacity:.75}
svg.scatter{background:var(--panel);border:1px solid var(--line)}svg.scatter .axis{stroke:var(--muted)}svg.scatter text{fill:var(--muted);font-size:10px}svg.scatter .pt circle{fill:var(--ink);opacity:.8}svg.scatter .pt.arm-mlx-lm circle{fill:var(--bad)}svg.scatter .pt.arm-mlx-bun circle{fill:var(--good)}svg.scatter .pt text{fill:var(--ink);font-size:10px}
.filters{display:flex;gap:10px;flex-wrap:wrap;align-items:center;margin:8px 0}.filters label{font-size:12px;color:var(--muted)}select{font:inherit}
.hidden{display:none}details.prov{margin:8px 0;background:var(--panel);border:1px solid var(--line);padding:6px 10px}summary{cursor:pointer}
footer{margin-top:28px;color:var(--muted);font-size:11px}
</style></head><body>
<h1>${esc(model.title)}</h1>
<p class="legend">Generated ${esc(model.generatedAt)} by <code>scripts/bench/report.ts</code> from ${model.inputs.length} saved input(s); no model, server, GPU, Python or network was used to render. Every summary below derives from the raw JSON listed in Provenance. Saved model output is escaped text, never executed.</p>

<h2>Provenance</h2>
${model.inputs.map(provenancePanel).join("\n")}

<h2>Serving matrix (bench-serve schema 4)</h2>
${STATUS_LEGEND}
<div class="filters">
${model.baselineEnv ? `<span>baseline setting: ${esc(model.baselineEnv.key)}=${esc(model.baselineEnv.value)}</span>` : ""}
<label>baseline <select id="baseline">${["none", ...model.baselineArms].map((a) => `<option value="${esc(a)}"${a === (model.defaultBaseline ?? "none") ? " selected" : ""}>${esc(a)}</option>`).join("")}</select></label>
<label>machine <select id="f-machine"><option value="">all</option>${filterOptions(rows.map((r) => r.machine.key))}</select></label>
<label>model <select id="f-model"><option value="">all</option>${filterOptions(rows.map((r) => r.modelLabel))}</select></label>
<label>arm <select id="f-arm"><option value="">all</option>${filterOptions(rows.map((r) => r.arm))}</select></label>
<label>artifact kind <select id="f-kind"><option value="">all</option>${filterOptions(rows.map((r) => r.packedTrellis ? "packed-trellis" : "affine/other"))}</select></label>
<label>source <select id="f-source"><option value="">all</option>${filterOptions(rows.map((r) => basename(r.source)))}</select></label>
<span id="row-count" class="n"></span>
</div>
<div id="matrix">${matrix}</div>

<h2>Per-machine comparison columns</h2>
<p class="legend">One column per machine key (chip · RAM · host). Same model/arm/workload cells line up across machines; ratios are never computed across machines.</p>
${machineTable}

<h2>Paired block uncertainty</h2>
<p class="legend">Fixed baseline ${esc(model.defaultBaseline ?? "none")}${model.baselineEnv ? ` with ${esc(model.baselineEnv.key)}=${esc(model.baselineEnv.value)}` : ""}. Each seed contributes one block ratio of the displayed summaries; repeated files do not add replicates. Groups require the same source snapshots, settings, artifact, machine and workload apart from seed. Factors above one favor the candidate. Intervals use 20,000 deterministic bootstrap resamples of block log-ratios and require five blocks. Small samples describe these trials; they do not establish tail latency or task quality. The baseline selector above changes only the serving matrix.</p>
${intervalTable}

<h2>Memory versus speed</h2>
<p class="legend">Peak server-process RSS (ps) against median decode SSE tok/s. Python arms' KV never shows in RSS; mlx-bun --ssd-cache arms read high on the ctx/restart legs because hashing makes live KV pages visible. Native active-memory peaks are in the native table, never mixed into RSS.</p>
${scatterSvg(rows)}

<h2>Native generation (scripts/bench/native.ts schema 1)</h2>
${nativeTable}

<h2>Quality versus size</h2>
<p><span class="st st-not-measured">not measured</span> — the loaded companions carry no quality results or artifact byte totals. Packed trellis and other quantizations need a separate quality/size input; a carrier artifact cannot be a same-artifact speed denominator.</p>

<h2>Failures, phase failures, request errors and stderr tails</h2>
${failures}

<h2>Raw requests (paired by phase / attempt / index / request sha256)</h2>
<p class="legend">A cold request and its warm repeat share a request hash; phase/attempt/index tell them apart. Prompt text is recorded as data only.</p>
${requestTables}

<footer>Inputs: ${model.inputs.map((i) => `<code>${esc(basename(i.path))}</code> sha256 <code>${esc(i.sha256)}</code>`).join(" · ")}</footer>
<script>
const DATA=${payload};
const q=(s)=>document.querySelector(s);
const fmt=(v,d)=>v==null||!isFinite(v)?"—":Number(v).toFixed(d);
function applyFilters(){
  const f={machine:q("#f-machine").value,model:q("#f-model").value,arm:q("#f-arm").value,kind:q("#f-kind").value,source:q("#f-source").value};
  let shown=0;const visible=new Set();
  document.querySelectorAll("tr.row").forEach((tr)=>{
    const ok=(!f.machine||tr.dataset.machine===f.machine)&&(!f.model||tr.dataset.model===f.model)&&(!f.arm||tr.dataset.arm===f.arm)&&(!f.kind||tr.dataset.kind===f.kind)&&(!f.source||tr.dataset.source===f.source);
    tr.classList.toggle("hidden",!ok);if(ok){shown++;visible.add(tr.dataset.row);}
  });
  document.querySelectorAll("h3.machine").forEach((h)=>h.classList.toggle("hidden",Boolean(f.machine)&&h.dataset.machine!==f.machine));
  document.querySelectorAll("svg.scatter .pt").forEach((g)=>g.classList.toggle("hidden",!visible.has(g.dataset.row)));
  q("#row-count").textContent=shown+" of "+DATA.rows.length+" rows";
}
function applyBaseline(){
  const arm=q("#baseline").value;const pairs=DATA.pairsByBaseline[arm]||[];
  document.querySelectorAll("tr.row").forEach((tr)=>{
    const p=pairs.find((x)=>x.id===tr.dataset.row);if(!p)return;
    const pairEl=tr.querySelector(".pair");
    if(pairEl){pairEl.className="pair"+(p.status==="paired"||p.status==="self"?"":p.status==="unsupported"?" st-unsupported":" st-not-measured");pairEl.textContent=p.status==="paired"?p.note:p.status==="self"?"baseline":p.status+": "+p.note;pairEl.title=p.note;}
    tr.querySelectorAll("td.m").forEach((td)=>{
      const r=p.ratios[td.dataset.metric];let el=td.querySelector(".ratio");
      if(!r||r.status==="no-baseline"){if(el)el.remove();return;}
      if(!el){el=document.createElement("div");td.appendChild(el);}
      if(r.ratio==null){el.className="ratio st-"+r.status;el.textContent=r.status;el.title=r.note;}
      else{el.className="ratio "+(r.ratio>=1.02?"good":r.ratio<=0.98?"bad":"flat");el.textContent="\\u00d7"+fmt(r.ratio,2)+(r.n>1?" n="+r.nA+"/"+r.nB:"");el.title=r.note;}
    });
  });
}
["#f-machine","#f-model","#f-arm","#f-kind","#f-source"].forEach((s)=>q(s).addEventListener("change",applyFilters));
q("#baseline").addEventListener("change",applyBaseline);
applyFilters();
</script>
</body></html>
`;
}

// ---- CLI ---------------------------------------------------------------------------

export interface ReportCliOptions { inputs: string[]; out: string; baseline: Arm | null; title?: string; baselineEnv?: BaselineEnvironment }

export function parseReportArgs(argv: string[]): ReportCliOptions {
  const inputs: string[] = [];
  let out = "", baseline: Arm | null = null, title: string | undefined, baselineEnv: BaselineEnvironment | undefined;
  const named = new Set(["out", "baseline", "title", "baseline-env"]);
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i]!;
    if (!arg.startsWith("--")) { inputs.push(arg); continue; }
    const key = arg.slice(2);
    if (!named.has(key)) throw new Error(`unknown option ${arg}`);
    const value = argv[i + 1];
    if (value === undefined || value.startsWith("--")) throw new Error(`${arg} requires a value`);
    i++;
    if (key === "out") out = value;
    else if (key === "title") title = value;
    else if (key === "baseline-env") {
      const match = value.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
      if (!match) throw new Error("--baseline-env requires KEY=VALUE");
      baselineEnv = { key: match[1]!, value: match[2]! };
    } else {
      if (!BASELINE_ORDER.includes(value as Arm) && !["mlx-bun-mixed", "mlx-bun-isolated", "optiq-mixed"].includes(value))
        throw new Error(`--baseline must be an arm name (got ${value})`);
      baseline = value as Arm;
    }
  }
  if (!inputs.length) throw new Error("at least one raw JSON input is required");
  if (!out) throw new Error("--out <file.html> is required");
  return { inputs, out, baseline, title, ...(baselineEnv ? { baselineEnv } : {}) };
}

export async function main(argv: string[]): Promise<{ out: string; inputs: number; serveRows: number; nativeRows: number }> {
  const options = parseReportArgs(argv);
  const loaded = options.inputs.map(loadRawReport);
  const model = buildReportModel(loaded, { baseline: options.baseline, title: options.title, baselineEnv: options.baselineEnv });
  mkdirSync(dirname(resolve(options.out)), { recursive: true });
  await Bun.write(options.out, renderHtml(model));
  return { out: options.out, inputs: loaded.length, serveRows: model.serveRows.length, nativeRows: model.nativeRows.length };
}

if (import.meta.main) {
  if (process.argv.includes("--help")) {
    console.log("bun scripts/bench/report.ts --out reports/<name>.html <raw.md.json> [...] [<native.json> ...] [--baseline mlx-lm|mlx-bun-serial|mlx-bun] [--baseline-env KEY=VALUE] [--title \"...\"]");
  } else {
    try { console.log(JSON.stringify(await main(process.argv.slice(2)))); }
    catch (error) { console.error(String((error as Error).message ?? error)); process.exit(1); }
  }
}
