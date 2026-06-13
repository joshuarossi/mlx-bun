// MiniCPM5 chat-template regression: multi-turn tool history uses the
// template's `[a, b]|min` branch, which @huggingface/jinja cannot run
// without the ChatTemplate.load() min/max rewrite. The expected string is
// the oracle venv's transformers apply_chat_template output (enable_thinking
// False, tools active) — byte-for-byte.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT_MINICPM5 } from "./paths";

if (!existsSync(`${SNAPSHOT_MINICPM5}/chat_template.jinja`))
  throw new Error(`required MiniCPM5 template missing: ${SNAPSHOT_MINICPM5}`);

const TOOLS = [{
  type: "function" as const,
  function: {
    name: "read",
    parameters: { type: "object", properties: { path: { type: "string" } } },
  },
}];

const MESSAGES = [
  { role: "user", content: "read foo.txt" },
  {
    role: "assistant",
    content: "",
    tool_calls: [{
      id: "c1",
      type: "function" as const,
      function: { name: "read", arguments: { path: "foo.txt" } },
    }],
  },
  { role: "tool", tool_call_id: "c1", content: "hello world" },
];

// Oracle: /Users/joshrossi/Code/mlx-lm-example/.venv transformers
// apply_chat_template(messages, tools=..., add_generation_prompt=True,
// enable_thinking=False), captured 2026-06-12.
const ORACLE_RENDER = "<s><|im_start|>system\n# Tools\n\nYou are provided with function signatures within <tools></tools> XML tags:\n<tools>\n{\"type\": \"function\", \"function\": {\"name\": \"read\", \"parameters\": {\"type\": \"object\", \"properties\": {\"path\": {\"type\": \"string\"}}}}}\n</tools>\n\nTool usage guidelines:\n- You may call zero or more functions. If no function calls are needed, just answer normally and do not include any <function ... </function>.\n- When calling a function, return an XML object within <function ... </function> using:\n<function name=\"function-name\"><param name=\"param-name\">param-value</param></function>\n- param-value may be multi-line. If it contains <, & or newline characters, wrap it in a CDATA block: <param name=\"param-name\"><![CDATA[...multi-line value...]]></param><|im_end|>\n<|im_start|>user\nread foo.txt<|im_end|>\n<|im_start|>assistant\n<function name=\"read\"><param name=\"path\">foo.txt</param></function><|im_end|>\n<|im_start|>user\n<tool_response>\nhello world\n</tool_response><|im_end|>\n<|im_start|>assistant\n<think>\n\n</think>\n\n";

describe("MiniCPM5 template multi-turn tool history", async () => {
  const { ChatTemplate } = await import("../src/chat-template");
  const template = await ChatTemplate.load(SNAPSHOT_MINICPM5);

  test("agent round-trip render matches the oracle byte-for-byte", () => {
    const rendered = template.render(MESSAGES as any, {
      tools: TOOLS,
      enableThinking: false,
    });
    expect(rendered).toBe(ORACLE_RENDER);
  });
});
