// The verdict cases follow SafeAgents tests/test_scan.py and tests/test_analyze.py (commit a8ee22d; Copyright 2026
// the HuggingFace Inc. team, Apache License 2.0). Findings come from a policy file here, so these tests pin the
// guard's decisions without depending on any one built-in check.
import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { blockedNotice, createToolGuard, MAX_SCANNED_ARGUMENTS, type ToolGuardOptions } from "../../../src/server/tool-guard/guard";
import { buildPrompt, JUDGE_SYSTEM, taskText } from "../../../src/server/tool-guard/judge";
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
    fetch: (async (url: string, init: RequestInit) => {
      const body = JSON.parse(init.body as string);
      judged.push({ url, headers: init.headers, ...body });
      return judgeAnswer!(body, init.signal!);
    }) as unknown as typeof fetch,
  });
  return { review: (request = bashRequest(TASK)) => built.forRequest(request), lines, judged };
}
const verdict = (content: string) => Response.json({ choices: [{ message: { content } }] });

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
  const cases: [string, string | null, "allow" | "block", boolean][] = [
    ["a block verdict blocks", '{"verdict": "block", "reason": "reads PID 1 secrets"}', "allow", true],
    ["an allow verdict in a code fence passes", '```json\n{"verdict": "allow", "reason": "the user asked"}\n```', "allow", false],
    ["a failing judge passes by default", null, "allow", false],
    ["a failing judge blocks with --tool-guard-on-error block", null, "block", true],
    ["an unusable verdict is a failure", '{"verdict": "maybe", "reason": ""}', "block", true],
  ];
  for (const [name, answer, onError, blocked] of cases) {
    test(name, async () => {
      const { review } = guard({ judge: { url: "http://judge/v1/", model: "j" }, onError },
        () => (answer === null ? new Response("down", { status: 500 }) : verdict(answer)));
      expect((await review()([bash("echo MEDIUM_MARK")])).notices.length === 1).toBe(blocked);
    });
  }

  test("verdicts are reported with the call, and a block names the judge's reason", async () => {
    const blocking = guard({ judge: { url: "http://judge/v1" } }, () => verdict('{"verdict": "block", "reason": "reads secrets"}'));
    expect((await blocking.review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "test.medium (medium); judge: reads secrets")]);
    const failing = guard({ judge: { url: "http://judge/v1" }, onError: "block" }, () => new Response("down", { status: 500 }));
    expect((await failing.review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "test.medium (medium); judge unavailable")]);
    expect(failing.lines).toEqual(["[tool-guard] blocked call to `bash`: test.medium (medium); judge unavailable (judge error: Error: HTTP 500)"]);
    const allowing = guard({ judge: { url: "http://judge/v1" } }, () => verdict('{"verdict": "allow", "reason": "asked"}'));
    await allowing.review()([bash("echo MEDIUM_MARK")]);
    expect(allowing.lines).toEqual(["[tool-guard] suspicious call to `bash`: test.medium (medium) (judge allow: asked)"]);
  });

  test("the judge is asked only about suspicious calls: never clean ones, never ones already blocked", async () => {
    const { review, judged } = guard({ judge: { url: "http://judge/v1" } }, () => verdict('{"verdict": "block", "reason": "x"}'));
    const outcome = await review()([bash("ls", "clean"), bash("echo HIGH_MARK", "severe"), call("nope", {}, "undeclared")]);
    expect(outcome.kept.map(item => item.id)).toEqual(["clean"]);
    expect(judged).toEqual([]);
  });

  test("the judge sees the user's words, the call and the findings, never reasoning, agent text or tool results", async () => {
    const request = { tools: [{ name: "bash", input_schema: {} }], messages: [
      { role: "system", content: "SYSTEM_PROMPT" },
      { role: "user", content: [{ type: "text", text: "fix the tests" }] },
      { role: "assistant", reasoning_content: "SECRET_REASONING", content: "Running them.",
        tool_calls: [{ id: "t1", type: "function", function: { name: "bash", arguments: '{"command": "pytest"}' } }] },
      { role: "tool", tool_call_id: "t1", content: "1 failed" },
    ] };
    const { review, judged } = guard({ judge: { url: "http://judge/v1/", model: "j" } }, () => verdict('{"verdict": "allow", "reason": "ok"}'));
    await review(request)([bash("echo MEDIUM_MARK")]);
    expect(judged).toHaveLength(1);
    expect(judged[0]).toMatchObject({ url: "http://judge/v1/chat/completions", model: "j", temperature: 0, max_tokens: 256 });
    expect((judged[0]!.response_format as { type: string }).type).toBe("json_schema");
    const messages = judged[0]!.messages as { role: string; content: string }[];
    expect(messages[0]).toEqual({ role: "system", content: JUDGE_SYSTEM });
    expect(messages[1]!.content).toBe('<task>\nfix the tests\n</task>\n\n<tool_call name="bash">\n{"command":"echo MEDIUM_MARK"}\n</tool_call>\n\n<scanner_findings>\n- test.medium (medium): Marked medium\n</scanner_findings>');
    for (const hidden of ["SECRET_REASONING", "Running them.", "1 failed", "SYSTEM_PROMPT"]) expect(JSON.stringify(messages)).not.toContain(hidden);
  });

  test("long tasks keep their end and long arguments their start", () => {
    const long = taskText({ messages: [{ role: "user", content: "a".repeat(7000) }, { role: "user", content: "LATEST" }] });
    expect(long.startsWith("[...]\n")).toBe(true);
    expect(long.endsWith("LATEST")).toBe(true);
    expect(long).toHaveLength(6006);
    expect(buildPrompt("t", "bash", "x".repeat(5000), [])).toContain(`${"x".repeat(4000)} [...]`);
  });

  test("the API key comes from the environment as a bearer token and a slow judge times out as a failure", async () => {
    process.env.MLX_BUN_TOOL_GUARD_JUDGE_API_KEY = "judge-key";
    const { createRuntimeConfig, withRuntimeConfig } = await import("@mlx-bun/inference/runtime/config");
    try {
      const built = withRuntimeConfig(createRuntimeConfig(process.env), () =>
        guard({ judge: { url: "http://judge/v1" } }, () => verdict('{"verdict": "allow", "reason": "ok"}')));
      await built.review()([bash("echo MEDIUM_MARK")]);
      expect(built.judged[0]!.headers).toMatchObject({ authorization: "Bearer judge-key" });
    } finally { delete process.env.MLX_BUN_TOOL_GUARD_JUDGE_API_KEY; }
    const slow = guard({ judge: { url: "http://judge/v1", timeoutMs: 20 }, onError: "block" },
      (_body, signal) => new Promise<Response>((_resolve, reject) => signal.addEventListener("abort", () => reject(signal.reason))));
    expect((await slow.review()([bash("echo MEDIUM_MARK")])).notices).toEqual([blockedNotice("bash", "test.medium (medium); judge unavailable")]);
    expect(slow.lines[0]).toContain("judge error: Timeout: no answer in 20 ms");
  });
});

describe("failures and cancellation", () => {
  test("a cancelled request stops the review: the judge call is aborted and nothing is forwarded", async () => {
    const abort = new AbortController();
    let judgeSignal: AbortSignal | undefined;
    const { review } = guard({ judge: { url: "http://judge/v1" } }, (_body, signal) => {
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
    const { review } = guard({ journal, judge: { url: "http://judge/v1" } }, () => verdict('{"verdict": "allow", "reason": "asked"}'));
    await review()([bash("ls"), call("shell_exec", { command: "id" }), bash("echo MEDIUM_MARK")]);
    const entries = readFileSync(journal, "utf8").trimEnd().split("\n").map(line => JSON.parse(line));
    expect(entries).toEqual([
      { time: 1_700_000_000, verdict: "blocked", tool: "shell_exec", arguments: '{"command":"id"}', reason: "undeclared tool", signals: [], judge: null,
        model: "test/model", task: TASK },
      { time: 1_700_000_000, verdict: "suspicious", tool: "bash", arguments: '{"command":"echo MEDIUM_MARK"}', reason: null,
        signals: [{ id: "test.medium", severity: "medium", title: "Marked medium" }], judge: "allow: asked", model: "test/model", task: TASK },
    ]);
    expect(statSync(journal).mode & 0o777).toBe(0o600);
  });

  test("an unwritable journal is reported once and never fails a review", async () => {
    const { review, lines } = guard({ journal: join(policyFile, "calls.jsonl") });
    expect((await review()([call("a", {}), call("b", {})])).notices).toHaveLength(2);
    expect(lines.filter(line => line.includes("is not writable"))).toHaveLength(1);
  });
});
