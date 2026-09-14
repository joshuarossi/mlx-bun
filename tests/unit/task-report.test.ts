import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { buildReportModel, loadRawReport, renderHtml } from "../../scripts/bench/report";
import { taskQuality, taskRow, validateTaskRaw, type LoadedTaskReport, type TaskRawReport } from "../../scripts/bench/task-report";

const raw = (): TaskRawReport => ({
  kind: "fresh-pi-kanban-task", arm: "synthetic task", host: "test-host", target: "/models/example",
  complete: true, finishedAt: "2026-09-13T00:00:00Z", sourceFixed: true, taskWallMs: 3000,
  piExit: { code: 0, signal: null },
  totalOutputTokens: 30, requests: [
    { index: 0, complete: true, wallMs: 1000, ttftMs: 100, usage: { completion_tokens: 10 } },
    { index: 1, complete: true, wallMs: 1500, ttftMs: 100, usage: { completion_tokens: 20,
      prompt_tokens_details: { cached_tokens: 123 } } },
  ],
});
const loaded = (report = raw()): LoadedTaskReport => ({ kind: "task", path: "synthetic.json",
  sha256: "a".repeat(64), bytes: 0, report, quality: null });
const quality = () => ({ sourceUnchanged: true, passedCategories: 1, requiredCategories: 3, checks: [
  { id: "create", passed: true, evidence: "Created a card through the browser." },
  { id: "filter", passed: false, evidence: "Reset hides all cards." },
  { id: "keyboard", passed: false, status: "blocked", evidence: "Blocked by the modal." },
] });

test("task metrics retain actual work and never enter serve/native speed pairing", () => {
  const model = buildReportModel([loaded(), loadRawReport("fixtures/bench-report/serve-schema4-a.json")]);
  const task = model.taskRows[0]!;
  expect(task.status).toBe("complete");
  expect(task.outputTokens).toBe(30);
  expect(task.postFirstOutputTps).toBeCloseTo(30 / 2.3, 9);
  expect(task.sumTtftMs).toBe(200);
  expect(task.cachedFollowups).toBe(1);
  expect(task.completedFollowups).toBe(1);
  expect(model.nativeRows).toHaveLength(0);
  expect(model.serveRows.every(r => r.sourceSha256 !== "a".repeat(64))).toBe(true);
});

test("failed and partial tasks retain completed tokens without full-task throughput", () => {
  for (const alter of [
    (r: TaskRawReport) => { r.complete = false; },
    (r: TaskRawReport) => { r.requests[1]!.complete = false; },
    (r: TaskRawReport) => { r.requests[1]!.error = "connection lost"; },
    (r: TaskRawReport) => { r.piExit = 1; },
    (r: TaskRawReport) => { r.piExit = { code: null, signal: "SIGTERM" }; },
    (r: TaskRawReport) => { r.piOutcome = { completed: false }; },
  ]) {
    const r = raw(); alter(r);
    const row = taskRow(loaded(r));
    expect(row.status).not.toBe("complete");
    expect(row.outputTokens).toBeGreaterThan(0);
    expect(row.postFirstOutputTps).toBeNull();
  }
});

test("missing timings, usage and cache data remain unknown", () => {
  const r = raw(); delete r.requests[1]!.ttftMs;
  expect(taskRow(loaded(r)).postFirstOutputTps).toBeNull();
  expect(taskRow(loaded(r)).sumTtftMs).toBeNull();
  delete r.requests[1]!.usage;
  const row = taskRow(loaded(r));
  expect(row.outputTokens).toBeNull();
  expect(row.cachedFollowups).toBeNull();
  expect(row.durable).toBeNull();
  expect(renderHtml(buildReportModel([loaded(r)]))).toContain("App acceptance not recorded.");
});

test("quality counts come from unique individual checks, with contradictions visible", () => {
  const q = taskQuality({ ...quality(), passedCategories: 3 }, "quality.json", "sha");
  expect([q.passed, q.failed, q.blocked, q.total]).toEqual([1, 1, 1, 3]);
  expect(q.warnings[0]).toContain("pass count differs");
  expect(() => taskQuality({ checks: [{ id: "a" }, { id: "a" }] }, "q", "sha")).toThrow("unique id");
  const r = raw(); r.sourceFixed = false;
  r.cacheFlush = { result: { durable: true, pendingSpills: 1 } };
  expect(taskRow(loaded(r)).warnings).toHaveLength(2);
});

test("sidecar provenance, escaping and portable CLI import", () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-task-report-"));
  try {
    const r = raw(); r.arm = '</script><img src=x onerror="alert(1)">';
    const p = join(dir, "result.json"), q = join(dir, "quality.json");
    const text = JSON.stringify(quality());
    writeFileSync(p, JSON.stringify(r)); writeFileSync(q, text);
    const input = loadRawReport(p);
    expect(input.kind).toBe("task");
    if (input.kind !== "task") throw Error("wrong import");
    expect(input.quality!.sha256).toBe(createHash("sha256").update(text).digest("hex"));
    expect(input.quality!.path).toBe(q);
    const html = renderHtml(buildReportModel([input]));
    expect(html).not.toContain(r.arm);
    expect(html).toContain("&lt;img");
    expect(html).toContain("1/3 · 1 failed · 1 blocked");
    const cli = Bun.spawnSync([process.execPath, "scripts/bench/report.ts", "--out", join(dir, "report.html"), p]);
    expect(cli.exitCode).toBe(0);
    expect(JSON.parse(cli.stdout.toString()).taskRows).toBe(1);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("task input shape errors identify the source", () => {
  expect(() => validateTaskRaw({ ...raw(), requests: [{}] }, "bad.json")).toThrow("bad.json: requests[0]");
});
