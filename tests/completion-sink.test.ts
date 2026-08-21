import { describe, expect, test } from "bun:test";
import {
  CompletionSink,
  createTimedFlowControl,
  type CompletionToolCall,
} from "../src/serve/completion-sink";
import { StopMatcher, ThinkingTagSplitter, ToolAwareStream } from "../src/server";

class ScriptedRouter {
  readonly #tokens: Map<number, string>;
  readonly #reasoning: Map<number, string>;
  #pendingReasoning = "";
  readonly calls: CompletionToolCall[];

  constructor(
    tokens: Record<number, string>,
    reasoning: Record<number, string> = {},
    calls: CompletionToolCall[] = [],
  ) {
    this.#tokens = new Map(Object.entries(tokens).map(([id, text]) => [Number(id), text]));
    this.#reasoning = new Map(
      Object.entries(reasoning).map(([id, text]) => [Number(id), text]),
    );
    this.calls = calls;
  }

  push(token: number): string {
    this.#pendingReasoning += this.#reasoning.get(token) ?? "";
    return this.#tokens.get(token) ?? "";
  }

  flush(): string { return ""; }
  takeReasoning(): string {
    const text = this.#pendingReasoning;
    this.#pendingReasoning = "";
    return text;
  }
  toolCalls(): CompletionToolCall[] { return this.calls; }
}

class ScriptedStopper {
  stopped = false;
  #pending = "";
  constructor(readonly stop: string | null) {}
  push(text: string): string {
    if (this.stopped) return "";
    this.#pending += text;
    if (!this.stop) return this.#drain();
    const index = this.#pending.indexOf(this.stop);
    if (index === -1) return this.#drain();
    this.stopped = true;
    const output = this.#pending.slice(0, index);
    this.#pending = "";
    return output;
  }
  flush(): string { return this.#drain(); }
  #drain(): string {
    const output = this.#pending;
    this.#pending = "";
    return output;
  }
}

class ThinkSplitter {
  content = "";
  reasoning = "";
  push(text: string): { content: string; reasoning: string } {
    const match = text.match(/^<think>(.*)<\/think>(.*)$/s);
    const parts = match
      ? { reasoning: match[1]!, content: match[2]! }
      : { reasoning: "", content: text };
    this.content += parts.content;
    this.reasoning += parts.reasoning;
    return parts;
  }
  flush(): { content: string; reasoning: string } {
    return { content: "", reasoning: "" };
  }
}

describe("CompletionSink composition", () => {
  test("composes the real chat router, stop matcher, and thinking splitter", () => {
    const pieces = new Map<number, string>([
      [1, "<thi"],
      [2, "nk>why"],
      [3, "</think>answer"],
      [4, "ST"],
      [5, "OPtail"],
    ]);
    const tokenizer = {
      decode(ids: number[]) {
        return ids.map((id) => pieces.get(id) ?? "").join("");
      },
    };
    const sink = new CompletionSink({
      router: new ToolAwareStream(tokenizer as never, "plain", null),
      stopper: new StopMatcher(["STOP"]),
      thinking: new ThinkingTagSplitter(true),
      collectToolCalls: true,
    });

    const events = [1, 2, 3, 4].flatMap((token) => sink.push(token).events);
    const stopped = sink.push(5);
    expect(stopped.control).toBe(false);
    expect([...events, ...stopped.events]).toEqual([
      { type: "reasoning", text: "why" },
      { type: "content", text: "answer" },
    ]);
    expect(sink.finish()).toEqual({
      events: [],
      content: "answer",
      reasoning: "why",
      toolCalls: [],
      stopped: true,
    });
  });

  test("full chat configuration orders reasoning, content, and tool calls", () => {
    const call: CompletionToolCall = {
      id: "call_1",
      type: "function",
      function: { name: "lookup", arguments: "{}" },
    };
    const sink = new CompletionSink({
      router: new ScriptedRouter(
        { 1: "<think>why</think>answer", 2: "!" },
        { 1: "channel\n" },
        [call],
      ),
      stopper: new ScriptedStopper(null),
      thinking: new ThinkSplitter(),
      collectToolCalls: true,
    });

    expect(sink.push(1).events).toEqual([
      { type: "reasoning", text: "channel\n" },
      { type: "reasoning", text: "why" },
      { type: "content", text: "answer" },
    ]);
    expect(sink.push(2).events).toEqual([{ type: "content", text: "!" }]);
    expect(sink.finish()).toEqual({
      events: [{ type: "tool_calls", calls: [call] }],
      content: "answer!",
      reasoning: "channel\nwhy",
      toolCalls: [call],
      stopped: false,
    });
  });

  test("plain completion configuration halts and never parses tool calls", () => {
    const sink = new CompletionSink({
      router: new ScriptedRouter(
        { 1: "hello ", 2: "STOPignored" },
        {},
        [{ id: "unused", type: "function", function: { name: "x", arguments: "{}" } }],
      ),
      stopper: new ScriptedStopper("STOP"),
      thinking: new ThinkSplitter(),
      collectToolCalls: false,
    });

    expect(sink.push(1)).toEqual({
      events: [{ type: "content", text: "hello " }],
      control: undefined,
    });
    expect(sink.push(2)).toEqual({ events: [], control: false });
    expect(sink.finish()).toEqual({
      events: [],
      content: "hello ",
      reasoning: "",
      toolCalls: [],
      stopped: true,
    });
  });

  test("push surfaces the configured yield promise", async () => {
    let current = 0;
    let yields = 0;
    const flow = createTimedFlowControl(
      true,
      25,
      () => current,
      async () => { yields++; },
    );
    const sink = new CompletionSink({
      router: new ScriptedRouter({ 1: "a", 2: "b" }),
      stopper: new ScriptedStopper(null),
      thinking: new ThinkSplitter(),
      collectToolCalls: false,
      flowControl: flow,
    });

    current = 24;
    expect(sink.push(1).control).toBeUndefined();
    current = 25;
    const control = sink.push(2).control;
    expect(control).toBeInstanceOf(Promise);
    await control;
    expect(yields).toBe(1);
  });
});
