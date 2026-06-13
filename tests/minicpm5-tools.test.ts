// MiniCPM5 tool-call server regression: its template emits XML using
// added special tokens (`<function`, `<param`). The server must preserve
// those while parsing tools and must not apply Gemma token sentinels.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT_MINICPM5 } from "./paths";

function requireFile(path: string): void {
  if (!existsSync(path)) throw new Error(`required MiniCPM5 tool-test file missing: ${path}`);
}

const TOOLS = [{
  type: "function" as const,
  function: {
    name: "read",
    description: "Read a file",
    parameters: {
      type: "object",
      properties: { path: { type: "string" } },
      required: ["path"],
    },
  },
}];

describe("MiniCPM5 tool calls", async () => {
  requireFile(`${SNAPSHOT_MINICPM5}/config.json`);
  requireFile(`${SNAPSHOT_MINICPM5}/tokenizer.json`);
  requireFile(`${SNAPSHOT_MINICPM5}/chat_template.jinja`);

  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT_MINICPM5, "mlx-community/MiniCPM5-1B-OptiQ-4bit");
  const server = createServer(ctx, 0, { owner: "embedded" });
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  const body = {
    model: "mlx-community/MiniCPM5-1B-OptiQ-4bit",
    messages: [{
      role: "user",
      content: "Read /Users/joshrossi/Code/mlx-bun/AGENTS.md using the read tool.",
    }],
    tools: TOOLS,
    max_tokens: 128,
    temperature: 0,
    chat_template_kwargs: { enable_thinking: false },
  };

  test("non-streaming parses native XML into OpenAI tool_calls", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    });
    expect(res.status).toBe(200);
    const json = await res.json() as any;
    expect(json.choices[0].finish_reason).toBe("tool_calls");
    expect(json.choices[0].message.content).toBeNull();
    expect(json.choices[0].message.tool_calls[0].function.name).toBe("read");
    expect(JSON.parse(json.choices[0].message.tool_calls[0].function.arguments).path)
      .toBe("/Users/joshrossi/Code/mlx-bun/AGENTS.md");
  }, 120_000);

  test("streaming emits tool_calls and no stripped XML fragments", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ ...body, stream: true }),
    });
    expect(res.status).toBe(200);
    const text = await res.text();
    expect(text).toContain('"tool_calls"');
    expect(text).toContain('"finish_reason":"tool_calls"');
    expect(text).toContain("data: [DONE]");
    expect(text).not.toContain('name=\\"read\\"> name=\\"path');
  }, 120_000);
});
