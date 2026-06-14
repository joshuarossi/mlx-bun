// Chat template parity with the oracle's apply_chat_template
// (goldens/chat-template.json): identical rendered strings, and identical
// token ids when fed through our tokenizer.

import { describe, expect, test } from "bun:test";
import { normalizeSchemaTypes, normalizeToolSchemas, type ToolDefinition } from "../src/chat-template";
import { goldenAt } from "./goldens";
import { SNAPSHOT, snapshotAvailable } from "./paths";

describe("normalizeSchemaTypes", () => {
  test("adds a type to anyOf/union schemas (the Gemma `| upper` crash)", () => {
    const out = normalizeSchemaTypes({
      anyOf: [{ type: "string", const: "celsius" }, { type: "string", const: "fahrenheit" }],
      description: "unit",
    }) as Record<string, unknown>;
    expect(out.type).toBe("string"); // inferred from the anyOf members
    expect(Array.isArray(out.anyOf)).toBe(true); // original shape preserved
  });

  test("infers type from enum and const", () => {
    expect((normalizeSchemaTypes({ enum: ["a", "b"] }) as Record<string, unknown>).type).toBe("string");
    expect((normalizeSchemaTypes({ enum: [1, 2] }) as Record<string, unknown>).type).toBe("integer");
    expect((normalizeSchemaTypes({ const: true }) as Record<string, unknown>).type).toBe("boolean");
  });

  test("recurses into object properties and array items, leaving valid types intact", () => {
    const out = normalizeSchemaTypes({
      type: "object",
      properties: {
        location: { type: "string" },
        unit: { anyOf: [{ type: "string" }] },
        tags: { type: "array", items: { enum: ["x", "y"] } },
      },
    }) as any;
    expect(out.type).toBe("object");
    expect(out.properties.location.type).toBe("string");
    expect(out.properties.unit.type).toBe("string");
    expect(out.properties.tags.items.type).toBe("string");
  });

  test("does not mutate the input", () => {
    const input = { anyOf: [{ type: "string" }] };
    normalizeSchemaTypes(input);
    expect(input).toEqual({ anyOf: [{ type: "string" }] }); // no `type` added to original
  });
});

describe("normalizeToolSchemas", () => {
  test("normalizes each tool's parameter schema; passes null through", () => {
    expect(normalizeToolSchemas(null)).toBeNull();
    const tools: ToolDefinition[] = [
      { type: "function", function: { name: "weather", parameters: { type: "object", properties: { unit: { anyOf: [{ type: "string" }] } } } } },
    ];
    const out = normalizeToolSchemas(tools)!;
    expect((out[0]!.function.parameters!.properties as any).unit.type).toBe("string");
  });
});

const haveWeights = await snapshotAvailable();
const goldenFile = goldenAt("chat-template.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("chat template oracle parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    cases: { messages: { role: string; content: string }[]; rendered: string; ids: number[] }[];
  };

  const { ChatTemplate } = await import("../src/chat-template");
  const { loadTokenizer } = await import("../src/tokenizer");
  const template = await ChatTemplate.load(SNAPSHOT);
  const tok = await loadTokenizer(SNAPSHOT);

  for (const c of golden.cases) {
    const label = c.messages.map((m) => m.role).join(",");
    test(`render parity: [${label}]`, () => {
      expect(template.render(c.messages)).toBe(c.rendered);
    });
    test(`token ids parity: [${label}]`, () => {
      // oracle encoded with add_special_tokens=False; our encode() adds
      // specials, so compare via the rendered string's raw encoding minus
      // any auto-added BOS — the template already includes bos_token.
      const rendered = template.render(c.messages);
      const ids = tok.encode(rendered);
      // Gemma's tokenizer.json post-processor prepends BOS; rendered text
      // also starts with <bos>. Drop a duplicated leading BOS if present.
      const fixed = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
      expect(fixed).toEqual(c.ids);
    });
  }
});
