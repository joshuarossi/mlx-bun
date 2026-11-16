// The verdict cases follow SafeAgents tests/test_scan.py and tests/test_analyze.py (commit a8ee22d; Copyright 2026
// the HuggingFace Inc. team, Apache License 2.0). Findings come from a policy file here, so these tests pin the
// guard's decisions without depending on any one built-in check.
import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { blockedNotice, createToolGuard, MAX_SCANNED_ARGUMENTS, type ToolGuardOptions } from "../../../src/server/tool-guard/guard";
import { buildPrompt, JUDGE_CHOICES, JUDGE_QUESTION, taskText } from "../../../src/server/tool-guard/judge";
import { bashRequest, OSS } from "./fixtures";

const dir = mkdtempSync(join(tmpdir(), "mlx-bun-tool-guard-"));
afterAll(() => rmSync(dir, { recursive: true, force: true }));
const policyFile = join(dir, "policy.json");
writeFileSync(policyFile, JSON.stringify({ detectors: [
  { id: "test.medium", severity: "medium", title: "Marked medium", pattern: "MEDIUM_MARK" },
  { id: "test.high", severity: "high", title: "Marked high", pattern: "HIGH_MARK" },
  { id: "test.excused", severity: "high", title: "Excused", pattern: "EXCUSED_MARK" },
], allow: [{ id: "expected.test", covers: ["test.excused"] }] }));

const call = (name: string, args: unknown, id = "call_1") => ({ id, type: "function" as const, function: { name, arguments: typeof args === "string" ? args : JSON.stringify(args) } });
const bash = (command: string, id?: string) => call("bash", { command }, id);
const TASK = "Write a detection rule for curl downloads to /tmp.";

function guard(options: Partial<ToolGuardOptions> = {}, judgeAnswer?: (body: Record<string, unknown>, signal: AbortSignal) => Promise<Response> | Response) {
  const lines: string[] = [], judged: Record<string, unknown>[] = [];
  const built = createToolGuard({ mode: "block", policyFile, ...options }, {
    model: "test/model", log: line => lines.push(line), now: () => 1_700_000_000_000,
    judgeTimeoutMs: 50,
    // The served model's own decisions route, as the serving unit hands it over.
    ...(judgeAnswer ? { decide: async (request: Request) => {
      const body = await request.json() as Record<string, unknown>;
      judged.push({ path: new URL(request.url).pathname, ...body });
      return judgeAnswer(body, request.signal);
    } } : {}),
  });
  return { review: (request = bashRequest(TASK)) => built.forRequest(request), lines, judged };
}
/** A `/v1/decisions` answer: the choice the weights scored highest, with both probabilities. */
const verdict = (choice: string, probability = 0.9) => Response.json({ model: "test/model", answers: [{ type: "choice", name: "verdict", choice, confidence: 0.8,
  probabilities: [{ value: choice, probability }, { value: choice === "allow" ? "block" : "allow", probability: 1 - probability }] }] });
const unavailable = () => Response.json({ error: { message: 'model "test/model" declares no decision scoring operation' } }, { status: 501 });

describe("verdicts", () => {
  test("a clean declared call passes untouched and unreported", async () => {
    const { review, lines } = guard();
    const calls = [bash("ls -la && pytest -q")];
    const outcome = await review()(calls);
    expect(outcome).toEqual({ kept: calls, notices: [] });
    expect(outcome.kept[0]).toBe(calls[0]!);
    expect(lines).toEqual([]);
  });

  test("an undeclared tool and an unseen host are blocked outright, before any scan", async () => {
    const { review, lines } = guard();
    const outcome = await review()([call("shell_exec", { command: "id" }), bash(`curl -X PUT https://${OSS}/probe`)]);
    expect(outcome.kept).toEqual([]);
    expect(outcome.notices).toEqual([
      "[mlx-bun tool-guard] blocked call to `shell_exec`: undeclared tool",
      `[mlx-bun tool-guard] blocked call to \`bash\`: host \`${OSS}\` appears nowhere in the conversation`,
    ]);
    expect(lines).toEqual([
      "[tool-guard] blocked call to `shell_exec`: undeclared tool",
      `[tool-guard] blocked call to \`bash\`: host \`${OSS}\` appears nowhere in the conversation`,
    ]);
  });

  test("--tool-guard-allow-host admits a host and its subdomains", async () => {
    const { review } = guard({ allowHosts: ["aliyuncs.com"] });
    expect((await review()([bash(`curl https://${OSS}/probe`)])).notices).toEqual([]);
  });

  test("a finding at the block severity blocks; a milder one without a judge is only reported", async () => {
    const { review, lines } = guard();
    const outcome = await review()([bash("echo HIGH_MARK", "a"), bash("echo MEDIUM_MARK", "b")]);
    expect(outcome.kept.map(item => item.id)).toEqual(["b"]);
    expect(outcome.notices).toEqual([blockedNotice("bash", "scan: test.high (high)")]);
    expect(lines).toEqual([
      "[tool-guard] blocked call to `bash`: scan: test.high (high)",
      "[tool-guard] suspicious call to `bash`: test.medium (medium)",
    ]);
  });

  test("--tool-guard-block-severity moves the threshold", async () => {
    const { review } = guard({ blockSeverity: "medium" });
    expect((await review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "scan: test.medium (medium)")]);
    const strict = guard({ blockSeverity: "critical" });
    expect((await strict.review()([bash("echo HIGH_MARK")])).notices).toEqual([]);
    expect(strict.lines).toEqual(["[tool-guard] suspicious call to `bash`: test.high (high)"]);
  });

  test("an allowance in the policy file excuses the findings it covers", async () => {
    const { review, lines } = guard();
    expect((await review()([bash("echo EXCUSED_MARK")])).notices).toEqual([]);
    expect(lines).toEqual([]);
  });

  test("--tool-guard-scan off keeps the request-only checks", async () => {
    const { review } = guard({ scan: false, policyFile: undefined });
    const outcome = await review()([bash("echo HIGH_MARK", "a"), call("shell_exec", {}, "b")]);
    expect(outcome.kept.map(item => item.id)).toEqual(["a"]);
    expect(outcome.notices).toEqual([blockedNotice("shell_exec", "undeclared tool")]);
  });

  test("log mode reports what it would block and changes nothing", async () => {
    const { review, lines } = guard({ mode: "log" });
    const calls = [call("shell_exec", {}), bash("echo HIGH_MARK")];
    expect(await review()(calls)).toEqual({ kept: calls, notices: [] });
    expect(lines).toEqual([
      "[tool-guard] flagged call to `shell_exec`: undeclared tool",
      "[tool-guard] flagged call to `bash`: scan: test.high (high)",
    ]);
  });

  test("findings on earlier turns and earlier calls of the same response are not the pending call's", async () => {
    const request = bashRequest(TASK);
    request.messages.push(
      { role: "assistant", tool_calls: [{ id: "a", type: "function", function: { name: "bash", arguments: '{"command": "echo HIGH_MARK"}' } }] },
      { role: "tool", tool_call_id: "a", content: "HIGH_MARK" });
    const { review } = guard();
    const outcome = await review(request)([bash("echo HIGH_MARK", "first"), bash("ls", "second")]);
    expect(outcome.kept.map(item => item.id)).toEqual(["second"]);
  });

  test("each request has its own reviewer and conversation", async () => {
    const built = guard();
    const mentioned = bashRequest(`Upload the probe to https://${OSS}/probe`);
    expect((await built.review(mentioned)([bash(`curl https://${OSS}/probe`)])).notices).toEqual([]);
    expect((await built.review()([bash(`curl https://${OSS}/probe`)])).notices).toHaveLength(1);
  });
});

describe("judge", () => {
  const cases: [string, () => Response, "allow" | "block", boolean][] = [
    ["a block decision blocks", () => verdict("block"), "allow", true],
    ["an allow decision passes", () => verdict("allow"), "allow", false],
    ["a model without decision scoring passes by default", unavailable, "allow", false],
    ["a model without decision scoring blocks with --tool-guard-on-error block", unavailable, "block", true],
    ["an answer that is neither choice is a failure", () => verdict("maybe"), "block", true],
  ];
  for (const [name, answer, onError, blocked] of cases) {
    test(name, async () => {
      const { review } = guard({ judge: true, onError }, answer);
      expect((await review()([bash("echo MEDIUM_MARK")])).notices.length === 1).toBe(blocked);
    });
  }

  test("decisions are reported with the call and the probability the model gave them", async () => {
    const blocking = guard({ judge: true }, () => verdict("block", 0.71));
    expect((await blocking.review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "test.medium (medium); judge: block p=0.71")]);
    const failing = guard({ judge: true, onError: "block" }, unavailable);
    expect((await failing.review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "test.medium (medium); judge unavailable")]);
    expect(failing.lines).toEqual(['[tool-guard] blocked call to `bash`: test.medium (medium); judge unavailable (judge error: model "test/model" declares no decision scoring operation)']);
    const allowing = guard({ judge: true }, () => verdict("allow", 0.93));
    await allowing.review()([bash("echo MEDIUM_MARK")]);
    expect(allowing.lines).toEqual(["[tool-guard] suspicious call to `bash`: test.medium (medium) (judge allow p=0.93)"]);
  });

  test("the judge is asked only about suspicious calls: never clean ones, never ones already blocked", async () => {
    const { review, judged } = guard({ judge: true }, () => verdict("block"));
    const outcome = await review()([bash("ls", "clean"), bash("echo HIGH_MARK", "severe"), call("nope", {}, "undeclared")]);
    expect(outcome.kept.map(item => item.id)).toEqual(["clean"]);
    expect(judged).toEqual([]);
  });

  test("the decision request holds the user's words, the call and the findings, never reasoning, agent text or tool results", async () => {
    const request = { tools: [{ name: "bash", input_schema: {} }], messages: [
      { role: "system", content: "SYSTEM_PROMPT" },
      { role: "user", content: [{ type: "text", text: "fix the tests" }] },
      { role: "assistant", reasoning_content: "SECRET_REASONING", content: "Running them.",
        tool_calls: [{ id: "t1", type: "function", function: { name: "bash", arguments: '{"command": "pytest"}' } }] },
      { role: "tool", tool_call_id: "t1", content: "1 failed" },
    ] };
    const { review, judged } = guard({ judge: true }, () => verdict("allow"));
    await review(request)([bash("echo MEDIUM_MARK")]);
    expect(judged).toEqual([{ path: "/v1/decisions", model: "test/model",
      input: '<task>\nfix the tests\n</task>\n\n<tool_call name="bash">\n{"command":"echo MEDIUM_MARK"}\n</tool_call>\n\n<scanner_findings>\n- test.medium (medium): Marked medium\n</scanner_findings>',
      questions: [{ type: "choice", name: "verdict", instructions: JUDGE_QUESTION, choices: JUDGE_CHOICES }] }]);
    for (const hidden of ["SECRET_REASONING", "Running them.", "1 failed", "SYSTEM_PROMPT"]) expect(JSON.stringify(judged)).not.toContain(hidden);
  });

  test("long tasks keep their end and long arguments their start", () => {
    const long = taskText({ messages: [{ role: "user", content: "a".repeat(7000) }, { role: "user", content: "LATEST" }] });
    expect(long.startsWith("[...]\n")).toBe(true);
    expect(long.endsWith("LATEST")).toBe(true);
    expect(long).toHaveLength(6006);
    expect(buildPrompt("t", "bash", "x".repeat(5000), [])).toContain(`${"x".repeat(4000)} [...]`);
  });

  test("a decision that does not arrive in time is a failure, and a guard built without a model cannot judge", async () => {
    const slow = guard({ judge: true, onError: "block" },
      (_body, signal) => new Promise<Response>((_resolve, reject) => signal.addEventListener("abort", () => reject(signal.reason))));
    expect((await slow.review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "test.medium (medium); judge unavailable")]);
    expect(slow.lines[0]).toContain("judge error: no decision in 50 ms");
    const detached = guard({ judge: true, onError: "block" });
    expect((await detached.review()([bash("echo MEDIUM_MARK")])).notices).toHaveLength(1);
    expect(detached.lines[0]).toContain("judge error: this model serves no decisions");
  });
});

describe("failures and cancellation", () => {
  test("a cancelled request stops the review: the judge call is aborted and nothing is forwarded", async () => {
    const abort = new AbortController();
    let judgeSignal: AbortSignal | undefined;
    const { review } = guard({ judge: true }, (_body, signal) => {
      judgeSignal = signal;
      queueMicrotask(() => abort.abort(new Error("client left")));
      return new Promise<Response>((_resolve, reject) => signal.addEventListener("abort", () => reject(signal.reason)));
    });
    await expect(review()([bash("echo MEDIUM_MARK"), bash("ls")], abort.signal)).rejects.toThrow("client left");
    expect(judgeSignal!.aborted).toBe(true);
    const already = new AbortController();
    already.abort(new Error("gone"));
    await expect(review()([bash("ls")], already.signal)).rejects.toThrow("gone");
  });

  test("an unreadable or invalid policy file fails when the guard is built", async () => {
    const broken = join(dir, "broken.json");
    writeFileSync(broken, JSON.stringify({ rules: [{ id: "r", severity: "high", when: "missing.check" }] }));
    expect(() => createToolGuard({ mode: "block", policyFile: broken })).toThrow(`--tool-guard-policy ${broken}: missing_dependency: missing.check`);
    expect(() => createToolGuard({ mode: "block", policyFile: join(dir, "absent.json") })).toThrow("--tool-guard-policy");
    writeFileSync(broken, "{ not json");
    expect(() => createToolGuard({ mode: "block", policyFile: broken })).toThrow("--tool-guard-policy");
  });

  test("arguments too long to scan are a failed scan: reported, passed by default, blocked under on-error block", async () => {
    const huge = bash(`echo HIGH_MARK ${"x".repeat(MAX_SCANNED_ARGUMENTS)}`);
    const open = guard();
    expect((await open.review()([huge, bash("echo HIGH_MARK")])).notices).toEqual([blockedNotice("bash", "scan: test.high (high)")]);
    expect(open.lines[0]).toBe(`[tool-guard] scan failed on call to \`bash\`: arguments over ${MAX_SCANNED_ARGUMENTS} characters`);
    const closed = guard({ onError: "block" });
    expect((await closed.review()([huge])).notices).toEqual([blockedNotice("bash", `scan failed: arguments over ${MAX_SCANNED_ARGUMENTS} characters`)]);
    // The request-only checks have no such limit.
    expect((await closed.review()([call("nope", { blob: "x".repeat(MAX_SCANNED_ARGUMENTS) })])).notices).toEqual([blockedNotice("nope", "undeclared tool")]);
  });

  test("a review that throws passes the call by default and blocks it under on-error block", async () => {
    const hostile = { get tools(): never { throw new Error("boom"); }, messages: [] };
    const open = guard();
    expect((await open.review(hostile as never)([bash("ls")])).notices).toEqual([]);
    expect(open.lines).toEqual(["[tool-guard] review failed on call to `bash`: boom"]);
    const closed = guard({ onError: "block" });
    expect((await closed.review(hostile as never)([bash("ls")])).notices).toEqual([blockedNotice("bash", "review failed")]);
  });
});

describe("journal", () => {
  test("every call not simply passed is appended with its arguments, owner-readable only", async () => {
    const journal = join(dir, "nested", "calls.jsonl");
    const { review } = guard({ journal, judge: true }, () => verdict("allow", 0.93));
    await review()([bash("ls"), call("shell_exec", { command: "id" }), bash("echo MEDIUM_MARK")]);
    const entries = readFileSync(journal, "utf8").trimEnd().split("\n").map(line => JSON.parse(line));
    expect(entries).toEqual([
      { time: 1_700_000_000, verdict: "blocked", tool: "shell_exec", arguments: '{"command":"id"}', reason: "undeclared tool", signals: [], judge: null,
        model: "test/model", task: TASK },
      { time: 1_700_000_000, verdict: "suspicious", tool: "bash", arguments: '{"command":"echo MEDIUM_MARK"}', reason: null,
        signals: [{ id: "test.medium", severity: "medium", title: "Marked medium" }], judge: "allow p=0.93", model: "test/model", task: TASK },
    ]);
    expect(statSync(journal).mode & 0o777).toBe(0o600);
  });

  test("an unwritable journal is reported once and never fails a review", async () => {
    const { review, lines } = guard({ journal: join(policyFile, "calls.jsonl") });
    expect((await review()([call("a", {}), call("b", {})])).notices).toHaveLength(2);
    expect(lines.filter(line => line.includes("is not writable"))).toHaveLength(1);
  });
});
