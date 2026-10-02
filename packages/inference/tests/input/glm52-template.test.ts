import { describe, expect, test } from "bun:test";
import {
  renderGlm52Chat,
  type ToolDefinition,
} from "../../src/input/chat-template";

describe("GLM-5.2 chat template", () => {
  test("matches the pinned role and thinking format", () => {
    expect(renderGlm52Chat([
      { role: "system", content: "System" },
      { role: "developer", content: "Developer" },
      { role: "user", content: [{ type: "text", text: "Hi" }] },
      { role: "assistant", content: " Hello " },
      { role: "user", content: "Again" },
    ])).toBe(
      "[gMASK]<sop><|system|>System<|system|>Developer<|user|>Hi" +
      "<|assistant|><think></think>Hello<|user|>Again" +
      "<|assistant|><think></think>",
    );

    expect(renderGlm52Chat(
      [{ role: "user", content: "Hi" }],
      { enableThinking: true },
    )).toBe(
      "[gMASK]<sop><|system|>Reasoning Effort: Max" +
      "<|user|>Hi<|assistant|><think>",
    );
  });

  test("renders tool declarations, calls, and consecutive observations", () => {
    const tools: ToolDefinition[] = [{
      type: "function",
      function: {
        name: "weather",
        description: "Get weather",
        parameters: {
          type: "object",
          properties: { city: { type: "string" } },
        },
      },
    }];
    const rendered = renderGlm52Chat([
      { role: "user", content: "Weather?" },
      {
        role: "assistant",
        content: null,
        tool_calls: [{
          function: {
            name: "weather",
            arguments: { city: "Paris", days: 2 },
          },
        }],
      },
      { role: "tool", content: "sunny" },
      { role: "tool", content: "warm" },
    ], { tools });
    expect(rendered).toContain(
      "# Tools\n\nYou may call one or more functions",
    );
    expect(rendered).toContain(
      '<tool_call>weather<arg_key>city</arg_key><arg_value>Paris</arg_value>' +
      '<arg_key>days</arg_key><arg_value>2</arg_value></tool_call>',
    );
    expect(rendered).toContain(
      "<|observation|><tool_response>sunny</tool_response>" +
      "<tool_response>warm</tool_response>",
    );
  });

  test("rejects non-text content and can omit the generation prompt", () => {
    expect(() => renderGlm52Chat([
      {
        role: "user",
        content: [{ type: "image_url", image_url: { url: "x" } }],
      },
    ])).toThrow(/text content only/);
    expect(renderGlm52Chat(
      [{ role: "user", content: "Hi" }],
      { addGenerationPrompt: false },
    )).toBe("[gMASK]<sop><|user|>Hi");
  });
});
