// The agent-session reader (K3d) — the TS port of the corpus study's
// `load_session` / `serialize_tool_call` (reports/k3-replication/analyze.py),
// plus the turn reconstruction the replay harness builds on it.
//
// Ported, not re-derived: the same record filter, the same block handling, the
// same `excludeFromContext` rule, and the same corrupt-line tolerance. If the
// two readers drift, the corpus rates quoted in PLAN K3 stop describing what
// the harness actually replays — so this file pins the behavior.
import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  canonicalJson,
  firstDivergence,
  inferTools,
  iterSessionMessages,
  loadSession,
  replayTurns,
  serializeToolCall,
  taskOutputsAgree,
} from "../../scripts/fill/session-replay";

const FIXTURES = join(import.meta.dir, "..", "fixtures", "fill-sessions");
const read = (name: string) => readFileSync(join(FIXTURES, `${name}.jsonl`), "utf8");

describe("serializeToolCall (the generated-text proxy)", () => {
  test("compact call syntax with exact key spans", () => {
    const { text, keysSeen } = serializeToolCall("edit", { path: "a.ts", n: 2 });
    expect(text).toBe('edit({"path":"a.ts","n":2})');
    // Spans bound the BARE identifier so a caller can map it onto tokenizer
    // offsets instead of re-encoding the key in isolation.
    expect(keysSeen.map((k) => [k.key, text.slice(k.start, k.end)]))
      .toEqual([["path", "path"], ["n", "n"]]);
  });

  test("nested objects and arrays carry their path", () => {
    const { text, keysSeen } = serializeToolCall("x", { a: { b: [1, { c: "d" }] } });
    expect(text).toBe('x({"a":{"b":[1,{"c":"d"}]}})');
    expect(keysSeen.map((k) => [k.key, k.path.join(".")]))
      .toEqual([["a", ""], ["b", "a"], ["c", "a.b.1"]]);
  });
});

describe("loadSession", () => {
  test("a corrupt line is skipped, not fatal", () => {
    const raw = read("read-edit-loop");
    expect(raw).toContain('{"type":"message","message":{"role":"assistant","content":[{"type":"text","text":"tru');
    expect(() => loadSession(raw)).not.toThrow();
    expect(iterSessionMessages(raw).length).toBe(raw.trim().split("\n").length - 1);
  });

  test("user / toolResult / assistant blocks in chronological order", () => {
    const events = loadSession(read("read-edit-loop"));
    expect(events.map((e) => e.kind)).toEqual([
      "user", "assistant", "tool_result", "assistant", "tool_result",
      "assistant", "tool_result", "assistant",
    ]);
    const first = events[1]!;
    if (first.kind !== "assistant") throw new Error("expected assistant");
    expect(first.blocks.map((b) => b.btype)).toEqual(["thinking", "toolcall"]);
    expect(first.model).toBe("qwen3.8-27b");
  });

  test("bashExecution becomes a tool result — unless excludeFromContext", () => {
    const events = loadSession(read("bash-suite"));
    const results = events.filter((e) => e.kind === "tool_result");
    expect(results).toHaveLength(2);
    expect(results.every((r) => r.kind === "tool_result" && r.toolName === "bashExecution")).toBe(true);
    // The excluded execution never enters the replayed context.
    expect(JSON.stringify(events)).not.toContain("secret");
    expect(results[0]!.kind === "tool_result" && results[0]!.text)
      .toBe("bun test tests/unit\n1509 pass 0 fail");
  });

  test("records that are not messages (model_change) are ignored", () => {
    const events = loadSession(read("read-edit-loop"));
    expect(events.some((e) => (e as { kind: string }).kind === "other")).toBe(false);
  });
});

describe("inferTools (the schema the recording never carried)", () => {
  test("union of observed keys; keys present in EVERY call are required", () => {
    const tools = inferTools(loadSession(read("read-edit-loop")));
    expect(tools.map((t) => t.function.name).sort()).toEqual(["edit", "read"]);
    const read0 = tools.find((t) => t.function.name === "read")!.function.parameters;
    expect(read0.properties).toEqual({ path: { type: "string" } });
    expect(read0.required).toEqual(["path"]);
    expect(read0.additionalProperties).toBe(false);
    const edit = tools.find((t) => t.function.name === "edit")!.function.parameters;
    expect(Object.keys(edit.properties).sort()).toEqual(["new", "old", "path"]);
  });

  test("types come from the observed values", () => {
    const tools = inferTools(loadSession(read("bash-suite")));
    expect(tools[0]!.function.parameters.properties).toEqual({ command: { type: "string" } });
  });
});

describe("replayTurns", () => {
  test("one request per assistant message, with the context up to that point", () => {
    const events = loadSession(read("read-edit-loop"));
    const turns = replayTurns(events);
    expect(turns).toHaveLength(4);
    // The first turn sees only the user message.
    expect(turns[0]!.messages).toEqual([{ role: "user", content: "Fix the off-by-one in the ring cache." }]);
    expect(turns[0]!.expected.toolCalls).toEqual([
      { name: "read", arguments: { path: "src/model/ring-cache.ts" } },
    ]);
    expect(turns[0]!.toolName).toBe("read");
  });

  test("tool results are mocked verbatim and answer the call that opened them", () => {
    const turns = replayTurns(loadSession(read("read-edit-loop")));
    const second = turns[1]!.messages;
    const assistant = second.find((m) => m.role === "assistant")!;
    const tool = second.find((m) => m.role === "tool")!;
    expect(assistant.tool_calls![0]!.function).toEqual({
      name: "read", arguments: JSON.stringify({ path: "src/model/ring-cache.ts" }),
    });
    expect(tool.tool_call_id).toBe(assistant.tool_calls![0]!.id);
    expect(tool.content).toContain("export class RingCache");
  });

  test("the last turn is a prose reply with no tool call", () => {
    const turns = replayTurns(loadSession(read("read-edit-loop")));
    const last = turns[turns.length - 1]!;
    expect(last.expected.toolCalls).toEqual([]);
    expect(last.expected.text).toBe("The clamp is in place; the off-by-one is fixed.");
    expect(last.toolName).toBeNull();
  });

  test("every fixture session reconstructs without an orphan tool result", () => {
    for (const name of ["read-edit-loop", "bash-suite", "grep-repeat"]) {
      const turns = replayTurns(loadSession(read(name)));
      expect(turns.length).toBeGreaterThan(0);
      for (const t of turns) {
        for (const m of t.messages) {
          if (m.role === "tool") expect(m.tool_call_id).not.toContain("orphan");
        }
      }
    }
  });
});

describe("scoring", () => {
  test("task agreement is the CALL, not the token stream", () => {
    const a = { toolCalls: [{ name: "read", arguments: { path: "x.ts" } }], text: "" };
    const b = { toolCalls: [{ name: "read", arguments: { path: "x.ts" } }], text: "different prose" };
    expect(taskOutputsAgree(a, b)).toBe(true);
    const c = { toolCalls: [{ name: "read", arguments: { path: "y.ts" } }], text: "" };
    expect(taskOutputsAgree(a, c)).toBe(false);
  });

  test("argument key order is the model's choice, not a disagreement", () => {
    expect(canonicalJson({ a: 1, b: 2 })).toBe(canonicalJson({ b: 2, a: 1 }));
    expect(taskOutputsAgree(
      { toolCalls: [{ name: "e", arguments: { a: 1, b: 2 } }], text: "" },
      { toolCalls: [{ name: "e", arguments: { b: 2, a: 1 } }], text: "" },
    )).toBe(true);
  });

  test("prose turns compare on whitespace-normalized text", () => {
    expect(taskOutputsAgree(
      { toolCalls: [], text: "all  green" },
      { toolCalls: [], text: "all green\n" },
    )).toBe(true);
  });

  test("firstDivergence reports where the streams part", () => {
    expect(firstDivergence("abcdef", "abcXef")).toBe(3);
    expect(firstDivergence("abc", "abc")).toBeNull();
    expect(firstDivergence("abc", "abcdef")).toBe(3);
  });
});
