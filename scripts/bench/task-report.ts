/** Offline import of saved Pi tasks. This module never runs generated code. */
import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";

export interface TaskRequest {
  index: number; complete: boolean; sha256?: string; renderedSha256?: string;
  wallMs?: number; ttftMs?: number; error?: string; finishReason?: string;
  usage?: { completion_tokens?: number; prompt_tokens?: number;
    prompt_tokens_details?: { cached_tokens?: number } };
}

export interface TaskRawReport {
  kind: "fresh-pi-kanban-task";
  arm: string; host: string; target: string; complete: boolean;
  requests: TaskRequest[];
  promptSha256?: string; startedAt?: string; finishedAt?: string;
  taskWallMs?: number; totalOutputTokens?: number; peakCombinedRssBytes?: number;
  sourceFixed?: boolean; sourceStart?: Record<string, string>;
  draft?: string | null; librarySha256?: string; bunVersion?: string; piVersion?: string;
  contextWindow?: number; seed?: number; temperature?: number; reasoningEffort?: string;
  prefillChunkTokens?: number; engineEnvironment?: Record<string, string>;
  qualification?: string; notes?: string[]; error?: string;
  piExit?: number | { code: number | null; signal?: string | null };
  piOutcome?: { toolErrors?: number; retries?: number; compactions?: number; error?: string | null; completed?: boolean };
  cacheFlush?: { status?: number; result?: { durable?: boolean;
    missingSnapshots?: number; failedSpills?: number; pendingSpills?: number } };
  quality?: unknown;
}

export interface TaskQuality {
  path: string; sha256: string; sourceUnchanged: boolean | null;
  checks: { id: string; expectation: string; passed: boolean | null; evidence: string }[];
  passed: number; failed: number; blocked: number; total: number;
  warnings: string[];
}

export interface LoadedTaskReport {
  kind: "task"; path: string; sha256: string; bytes: number;
  report: TaskRawReport; quality: TaskQuality | null;
}

const object = (x: unknown): x is Record<string, unknown> => x !== null && typeof x === "object" && !Array.isArray(x);
const number = (x: unknown): x is number => typeof x === "number" && Number.isFinite(x) && x >= 0;

export function validateTaskRaw(json: unknown, path: string): TaskRawReport {
  if (!object(json) || json.kind !== "fresh-pi-kanban-task") throw Error(`${path}: expected fresh-pi-kanban-task`);
  for (const key of ["arm", "host", "target"])
    if (typeof json[key] !== "string") throw Error(`${path}: ${key} must be a string`);
  if (typeof json.complete !== "boolean" || !Array.isArray(json.requests))
    throw Error(`${path}: complete and requests[] are required`);
  for (const [i, request] of json.requests.entries())
    if (!object(request) || !number(request.index) || typeof request.complete !== "boolean")
      throw Error(`${path}: requests[${i}] needs an index and completion status`);
  return json as unknown as TaskRawReport;
}

export function taskQuality(json: unknown, path: string, sha256: string): TaskQuality {
  if (!object(json) || !Array.isArray(json.checks)) throw Error(`${path}: quality checks[] are required`);
  const ids = new Set<string>();
  const checks = json.checks.map((value, i) => {
    if (!object(value) || typeof value.id !== "string" || ids.has(value.id))
      throw Error(`${path}: quality check ${i} needs a unique id`);
    ids.add(value.id);
    return { id: value.id, expectation: typeof value.expectation === "string" ? value.expectation : "",
      passed: value.status === "blocked" ? null : typeof value.passed === "boolean" ? value.passed : null,
      evidence: typeof value.evidence === "string" ? value.evidence : "not recorded" };
  });
  const passed = checks.filter(c => c.passed === true).length;
  const failed = checks.filter(c => c.passed === false).length;
  const warnings: string[] = [];
  if (number(json.passedCategories) && json.passedCategories !== passed)
    warnings.push("Reported pass count differs from the individual checks; the table uses the checks.");
  if (number(json.requiredCategories) && json.requiredCategories !== checks.length)
    warnings.push("Reported category count differs from the supplied checks.");
  return { path, sha256, checks, passed, failed, blocked: checks.length - passed - failed,
    total: checks.length, sourceUnchanged: typeof json.sourceUnchanged === "boolean" ? json.sourceUnchanged : null, warnings };
}

export function loadTaskQuality(report: TaskRawReport, path: string): TaskQuality | null {
  const companion = join(dirname(path), "quality.json");
  if (existsSync(companion)) {
    const bytes = readFileSync(companion);
    return taskQuality(JSON.parse(bytes.toString("utf8")), companion, createHash("sha256").update(bytes).digest("hex"));
  }
  if (object(report.quality)) {
    const text = JSON.stringify(report.quality);
    return taskQuality(report.quality, `${path}#quality`, createHash("sha256").update(text).digest("hex"));
  }
  return null;
}

export interface TaskRow {
  input: LoadedTaskReport;
  status: "complete" | "incomplete" | "failed";
  completedRequests: number; totalRequests: number;
  outputTokens: number | null; taskWallMs: number | null;
  sumTtftMs: number | null; postFirstOutputTps: number | null;
  cachedFollowups: number | null; completedFollowups: number;
  durable: boolean | null; warnings: string[];
}

export function taskRow(input: LoadedTaskReport): TaskRow {
  const r = input.report, completed = r.requests.filter(q => q.complete);
  const exitFailed = typeof r.piExit === "number" ? r.piExit !== 0
    : r.piExit != null && (r.piExit.code !== 0 || Boolean(r.piExit.signal));
  const failed = Boolean(r.error || r.piOutcome?.error) || exitFailed
    || r.requests.some(q => Boolean(q.error));
  const complete = !failed && r.complete && Boolean(r.finishedAt) && r.piOutcome?.completed !== false
    && completed.length > 0 && completed.length === r.requests.length;
  const warnings = [...(input.quality?.warnings ?? [])];
  if (r.complete && !complete) warnings.push("Completion flag conflicts with the saved request or finish records.");
  if (r.sourceFixed !== true) warnings.push("Unchanged engine source is not established by this record.");
  const tokensKnown = completed.length > 0 && completed.every(q => number(q.usage?.completion_tokens));
  const outputTokens = tokensKnown ? completed.reduce((n, q) => n + q.usage!.completion_tokens!, 0) : null;
  if (outputTokens !== null && number(r.totalOutputTokens) && outputTokens !== r.totalOutputTokens)
    warnings.push("Reported token total differs from completed request usage; the table uses request usage.");
  const timesKnown = complete && completed.every(q => number(q.wallMs) && number(q.ttftMs) && q.wallMs! >= q.ttftMs!);
  const sumTtftMs = timesKnown ? completed.reduce((n, q) => n + q.ttftMs!, 0) : null;
  const decodeMs = timesKnown ? completed.reduce((n, q) => n + q.wallMs! - q.ttftMs!, 0) : 0;
  const followups = completed.filter(q => q.index > 0);
  const cachedFollowups = followups.every(q => number(q.usage?.prompt_tokens_details?.cached_tokens))
    ? followups.filter(q => q.usage!.prompt_tokens_details!.cached_tokens! > 0).length : null;
  const flush = r.cacheFlush?.result;
  const durable = typeof flush?.durable === "boolean" ? flush.durable : null;
  if (durable && [flush?.missingSnapshots, flush?.failedSpills, flush?.pendingSpills].some(n => number(n) && n > 0))
    warnings.push("Durability flag conflicts with nonzero pending, failed or missing snapshots.");
  return { input, status: failed ? "failed" : complete ? "complete" : "incomplete",
    completedRequests: completed.length, totalRequests: r.requests.length, outputTokens,
    taskWallMs: number(r.taskWallMs) ? r.taskWallMs : null, sumTtftMs,
    postFirstOutputTps: outputTokens !== null && decodeMs > 0 ? outputTokens * 1000 / decodeMs : null,
    cachedFollowups, completedFollowups: followups.length, durable, warnings };
}
