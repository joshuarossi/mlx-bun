// Token fast-forwarding through the token→text pipeline: the burst is an
// ordinary one-token-at-a-time stream, so CompletionSink / StopMatcher /
// StreamDecoder cannot tell an injected token from a sampled one — which is
// the whole doctrine, made observable.
//
// The driver below mirrors generate()'s emission order exactly (append, then
// yield the trigger, then yield each injected id) against the SAME scripted
// stream the model would have produced. Strict rows are token-identical by
// construction, so the filled stream must equal the unfilled one id for id.
import { describe, expect, test } from "bun:test";
import type { LoadedTokenizer } from "../../src/tokenizer";
import { FillSession } from "../../src/fill/fill-session";
import { compileStrictFillRows } from "../../src/fill/schema-rows";
import { CompletionSink } from "../../src/serve/completion-sink";
import { StopMatcher, ThinkingTagSplitter, ToolAwareStream } from "../../src/serve/token-streams";
import {
  jinjaTemplate,
  makeTokenizer,
  QWEN_STYLE_TEMPLATE,
  SEARCH_TOOL,
  WEATHER_TOOL,
  type FakeTokenizer,
} from "../support/fill-fixtures";

const messages = [{ role: "user", content: "weather in Paris?" }];
const TOOLS = [WEATHER_TOOL, SEARCH_TOOL];
const EOS = 9999;

function armed(tokenizer: FakeTokenizer) {
  const plan = compileStrictFillRows({
    template: jinjaTemplate(QWEN_STYLE_TEMPLATE),
    tokenizer, messages, tools: TOOLS, renderOptions: { tools: TOOLS },
  });
  expect(plan.rows.length).toBeGreaterThan(0);
  return new FillSession(
    { rows: plan.rows, echo: null, delimiters: new Set(plan.delimiters), eos: [EOS] },
    tokenizer.encode("<|im_start|>assistant\n"),
  );
}

/** generate()'s emission order: a sampled token, then any span the fill table
 *  determines. The injected ids stand in for the next |span| sampled tokens —
 *  the positions the model is no longer consulted about. */
function drive(sampled: number[], fill: FillSession | null): number[] {
  const out: number[] = [];
  let i = 0;
  while (i < sampled.length) {
    const token = sampled[i++]!;
    out.push(token);
    const proposal = fill?.push(token) ?? null;
    if (!proposal) continue;
    // Strict rows are assert-policy: the engine emits the whole span, and the
    // injected ids stand in for the next |span| sampled tokens.
    fill!.commit(proposal, proposal.ids.length);
    out.push(...proposal.ids);
    i += proposal.ids.length;
  }
  return out;
}

function sinkOf(
  tokenizer: FakeTokenizer,
  stops: string[],
  options: { tools?: boolean; onParseFailure?: () => void } = {},
) {
  const tools = options.tools === false ? null : TOOLS;
  return new CompletionSink({
    router: new ToolAwareStream(
      tokenizer as unknown as LoadedTokenizer,
      tools ? "buffered-text" : "plain",
      tools,
      options.onParseFailure),
    stopper: new StopMatcher(stops),
    thinking: new ThinkingTagSplitter(false),
    collectToolCalls: !!tools,
  });
}

const feed = (sink: CompletionSink, ids: number[]) => {
  for (const id of ids) {
    if (sink.push(id).control === false) break;
  }
  return sink.finish();
};

const CALL_TEXT =
  '<tool_call>\n{"name": "get_weather", "arguments": {"city": "Paris"}}\n</tool_call>';

describe("the fill burst is indistinguishable downstream", () => {
  test("strict rows reproduce the model's own stream, id for id", () => {
    const tokenizer = makeTokenizer();
    const fill = armed(tokenizer);
    const sampled = tokenizer.encode(CALL_TEXT);
    expect(drive(sampled, fill)).toEqual(sampled);
    // …and a real share of it never touched the weights.
    expect(fill.stats.injected).toBeGreaterThanOrEqual(10);
    // Two events: the call-open scaffold, then the name row that resumes it.
    expect(fill.stats.events).toBe(2);
  });

  test("the tool call assembles and parses exactly as an unfilled run's does", () => {
    const tokenizer = makeTokenizer();
    const fill = armed(tokenizer);
    const sampled = tokenizer.encode(CALL_TEXT);
    const filled = feed(sinkOf(tokenizer, []), drive(sampled, fill));
    const unfilled = feed(sinkOf(tokenizer, []), drive(sampled, null));
    expect(filled.toolCalls.map((c) => c.function)).toEqual([
      { name: "get_weather", arguments: JSON.stringify({ city: "Paris" }) },
    ]);
    expect(filled.content).toBe(unfilled.content);
    expect(filled.toolCalls.map((c) => c.function))
      .toEqual(unfilled.toolCalls.map((c) => c.function));
  });

  test("a stop sequence inside an injected span fires exactly where it would have", () => {
    // Hand-written row over plain prose: tool markup is withheld from the
    // stop matcher by the router (existing buffered-text behavior), so a
    // stop INSIDE a span is only observable outside tool markup.
    const tokenizer = makeTokenizer();
    const sampled = tokenizer.encode("alpha beta gamma delta");
    const [, , beta, space, gamma] = sampled as [number, number, number, number, number];
    const fill = new FillSession(
      { rows: [{ trigger: [beta], emit: [space, gamma, space], kind: "scaffold" }],
        echo: null, eos: [EOS] },
      [],
    );
    const filled = feed(sinkOf(tokenizer, [" gamma"], { tools: false }), drive(sampled, fill));
    const unfilled = feed(sinkOf(tokenizer, [" gamma"], { tools: false }), drive(sampled, null));
    expect(fill.stats.injected).toBe(3);
    expect(filled.stopped).toBe(true);
    expect(filled.stopped).toBe(unfilled.stopped);
    expect(filled.content).toBe(unfilled.content);
    expect(filled.content).toBe("alpha beta");
  });
});

describe("mismatch policy", () => {
  test("a tool call the parser rejects disarms strict rows and is counted", () => {
    const tokenizer = makeTokenizer();
    const fill = armed(tokenizer);
    const sink = sinkOf(tokenizer, [], { onParseFailure: () => fill.noteParseFailure() });
    // The scaffold fires, then the model emits a body that never closes: the
    // markup is unparseable, so the request's rows are no longer trusted.
    const sampled = tokenizer.encode('<tool_call>\n{"name": "broken\n</tool_call>');
    const result = feed(sink, drive(sampled, fill));
    expect(result.toolCalls).toEqual([]);
    expect(fill.stats.parseFallback).toBe(1);
    expect(fill.strictEnabled).toBe(false);
    // Disarmed: the same trigger no longer fills.
    expect(fill.push(tokenizer.encode("<tool_call>")[0]!)).toBeNull();
  });

  test("a parse failure on a request that never filled is not charged to fill", () => {
    const tokenizer = makeTokenizer();
    const fill = armed(tokenizer);
    const sink = sinkOf(tokenizer, [], { onParseFailure: () => fill.noteParseFailure() });
    feed(sink, tokenizer.encode("<tool_call>nonsense</tool_call>"));
    expect(fill.stats.parseFallback).toBe(0);
    expect(fill.strictEnabled).toBe(true);
  });
});
