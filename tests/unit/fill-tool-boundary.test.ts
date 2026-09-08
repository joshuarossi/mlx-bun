import { describe, expect, test } from "bun:test";
import { FillSession } from "../../src/fill/fill-session";
import { compileStrictFillRows } from "../../src/fill/schema-rows";
import { ToolCallFillContext } from "../../src/fill/tool-boundary";
import { parseStrictToolCall } from "../../src/tool-call";
import { jinjaTemplate, makeTokenizer, MERGES_XML, QWEN_XML_TEMPLATE, WEATHER_TOOL } from "../support/fill-fixtures";

const template = jinjaTemplate(QWEN_XML_TEMPLATE);
const tools = [WEATHER_TOOL];
const messages = [{ role: "user" as const, content: "hi" }];
function setup() {
  const tokenizer = makeTokenizer(MERGES_XML);
  const plan = compileStrictFillRows({ template, tokenizer, messages, tools, renderOptions: { tools } });
  const prompt = template.render(messages, { tools, addGenerationPrompt: true });
  const session = (rows = plan.rows, withContext = true) => new FillSession(
    { rows, echo: null, eos: [] }, tokenizer.encode(prompt),
    { strictContext: withContext ? plan.createContext?.(tokenizer.encode(prompt)) : undefined, maxSpan: 64 },
  );
  return { tokenizer, plan, prompt, session };
}

describe("template fills require an active structural boundary", () => {
  for (const prefix of [
    '<think>Consider this literal fragment:\n',
    'Here is some literal markup:\n```text\n',
    'The string is `',
    '<tool_call>\n<function=get_weather><parameter=city>\nprintf "%s" "',
  ]) for (const kind of ["scaffold", "close"] as const) {
    test(`${kind} declines a trigger inside ${JSON.stringify(prefix)}`, () => {
      const { tokenizer, plan, session } = setup();
      const row = plan.rows.find(row => row.kind === kind)!;
      const fill = session([row]);
      let last = null;
      for (const id of [...tokenizer.encode(prefix), ...row.trigger]) {
        last = fill.push(id, 128);
        if (last) fill.commit(last, 0);
      }
      expect(last).toBeNull();
    });
  }

  test("compiled rows cannot assert when their context was omitted", () => {
    const { plan, session } = setup();
    const row = plan.rows.find(row => row.kind === "scaffold")!;
    const fill = session([row], false);
    for (const id of row.trigger) expect(fill.push(id, 128)).toBeNull();
  });

  test("a cached row plan uses each request's current reasoning state", () => {
    const { tokenizer, plan } = setup();
    const row = plan.rows.find(row => row.kind === "scaffold")!;
    const ready = plan.createContext!(tokenizer.encode('assistant\n'));
    const thinking = plan.createContext!(tokenizer.encode('assistant\n<think>\n'));
    ready.observe(row.trigger); thinking.observe(row.trigger);
    expect(ready.allows(row)).toBe(true);
    expect(thinking.allows(row)).toBe(false);
  });

  test("a tool outside the probe budget cannot be omitted from the choice set", () => {
    const { tokenizer } = setup();
    const many = Array.from({ length: 32 }, (_, i) => ({
      ...WEATHER_TOOL, function: { ...WEATHER_TOOL.function, name: `get_weather_${i}` },
    }));
    many.push({ ...WEATHER_TOOL, function: { ...WEATHER_TOOL.function, name: 'search_docs' } });
    const plan = compileStrictFillRows({ template, tokenizer, messages, tools: many,
      renderOptions: { tools: many } });
    expect(plan.rows).toEqual([]);
  });

  for (const value of ["Paris", 'printf "%s" "</parameterization>"']) {
    test(`real template tokens remain identical through fills: ${value}`, () => {
      const { tokenizer, prompt, session } = setup();
      const rendered = template.render([...messages, { role: "assistant", content: "", tool_calls: [
        { id: "call_real", type: "function", function: { name: "get_weather", arguments: { city: value } } },
      ] }], { tools, addGenerationPrompt: false });
      expect(rendered.startsWith(prompt)).toBe(true);
      const expected = tokenizer.encode(rendered.slice(prompt.length));
      const fill = session(), emitted: number[] = [];
      for (let i = 0; i < expected.length; i++) {
        const id = expected[i]!; emitted.push(id);
        const proposal = fill.push(id, expected.length - i - 1);
        if (!proposal) continue;
        expect(proposal.policy).toBe("assert");
        expect(proposal.ids).toEqual(expected.slice(i + 1, i + 1 + proposal.ids.length));
        emitted.push(...proposal.ids);
        fill.commit(proposal, proposal.ids.length);
        i += proposal.ids.length;
      }
      expect(emitted).toEqual(expected);
      expect(fill.stats.events).toBe(2);
      expect(fill.stats.verifyEvents).toBe(0);
    });
  }

  test("an unfinished reasoning block cannot arm a tool header", () => {
    const { tokenizer, plan } = setup();
    const row = plan.rows.find(row => row.kind === "scaffold")!;
    const context = new ToolCallFillContext(ids => tokenizer.decode([...ids]), tools, '<think>\n');
    context.observe(tokenizer.encode('Consider <tool_call>'));
    expect(context.allows(row)).toBe(false);
    context.observe(tokenizer.encode('</think>\n\n'));
    context.observe(row.trigger);
    expect(context.allows(row)).toBe(true);
  });

  for (const reasoning of [
    'An example:\n```xml\n',
    'An example:\n~~~~text\n',
    'A literal "',
    'Nested <think>reasoning',
  ]) test(`a reasoning-close example cannot arm a header: ${JSON.stringify(reasoning)}`, () => {
    const { tokenizer, plan } = setup();
    const row = plan.rows.find(row => row.kind === "scaffold")!;
    for (const initial of [true, false]) {
      const context = new ToolCallFillContext(ids => tokenizer.decode([...ids]), tools,
        initial ? '<think>\n' : 'assistant\n');
      context.observe(tokenizer.encode((initial ? '' : '<think>\n') + reasoning + '</think>\n'));
      context.observe(row.trigger);
      expect(context.allows(row)).toBe(false);
    }
  });

  test("closed reasoning examples permit the real subsequent tool call", () => {
    const { tokenizer, plan } = setup();
    const row = plan.rows.find(row => row.kind === "scaffold")!;
    const context = new ToolCallFillContext(ids => tokenizer.decode([...ids]), tools, '<think>\n');
    context.observe(tokenizer.encode('An example:\n```text\n"unfinished quote in code\n```\nDone.\n</think>\n'));
    context.observe(row.trigger);
    expect(context.allows(row)).toBe(true);
  });

  test("a completed call permits a subsequent call", () => {
    const { tokenizer, plan } = setup();
    const row = plan.rows.find(row => row.kind === "scaffold")!;
    const complete = '<tool_call><function=get_weather><parameter=city>Paris</parameter></function></tool_call>';
    const context = new ToolCallFillContext(ids => tokenizer.decode([...ids]), tools, 'assistant\n');
    context.observe(tokenizer.encode(complete + '\n'));
    context.observe(row.trigger);
    expect(context.allows(row)).toBe(true);
  });
});

test("strict boundary parsing rejects repair, unknown tools and unconsumed XML", () => {
  const valid = '<tool_call><function=get_weather><parameter=city>Paris</parameter></function></tool_call>';
  expect(parseStrictToolCall(valid, tools)?.arguments).toEqual({ city: "Paris" });
  for (const text of [
    'example ' + valid,
    valid + ' trailing data',
    valid.replace('get_weather', 'unknown'),
    valid.replace('<parameter', 'junk<parameter'),
    valid.replace('</parameter>', '</parameter>junk'),
    valid.replace('</function>', '<parameter=city>Rome</parameter></function>'),
    '<tool_call>{"name":"get_weather","arguments":{"city":"Paris",}}</tool_call>',
  ]) expect(parseStrictToolCall(text, tools)).toBeNull();
  const glm = '<tool_call>get_weather<arg_key>city</arg_key><arg_value>Paris</arg_value></tool_call>';
  expect(parseStrictToolCall(glm, tools)?.arguments).toEqual({ city: "Paris" });
  expect(parseStrictToolCall(glm.replace('</tool_call>',
    '<arg_key>city</arg_key><arg_value>Rome</arg_value></tool_call>'), tools)).toBeNull();
});
