// Qwen3.8-27B serve smoke (OPT-IN heavy tier — loads the 17.4 GB model).
//
//   MLX_BUN_TEST_QWEN38_SERVE=1 bun test tests/qwen38-serve.test.ts
//
// End-to-end through the in-process server: thinking default-on with the
// <think> channel split into OpenAI `reasoning`, instruct mode + eos stop,
// reasoning_effort depth through the request path, and the Qwen3.8 XML
// tool-call format parsed into OpenAI tool_calls. Opt-in + run alone (same
// GPU-budget reasoning as tests/qwen-parity.test.ts); generous timeouts —
// the 27B swaps hard on 24 GB machines and wall-clock is meaningless.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT_QWEN38, snapshotQwen38Available } from "../support/paths";

const optIn = process.env.MLX_BUN_TEST_QWEN38_SERVE === "1";
const have = await snapshotQwen38Available();

describe.skipIf(!optIn || !have)("Qwen3.8-27B serve smoke", async () => {
  if (!optIn || !have) return;
  const { createServer, loadContext } = await import("../../src/server");
  const ctx = await loadContext(SNAPSHOT_QWEN38, "mlx-community/Qwen3.8-27B-OptiQ-4bit");
  // Explicit budget: the default (~80% of RAM) refuses this model on 24 GB
  // machines — shard bytes are 20.35 GB, and admission counts the in-shard
  // vision tower pages that text-only serving never touches. A smoke at
  // small context is fine; wall-clock under swap is meaningless here.
  const server = createServer(ctx, 0, { owner: "embedded", memoryBudgetBytes: 22_500_000_000 });
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  const chat = async (body: Record<string, unknown>): Promise<any> => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ model: "qwen38", ...body }),
      // Bun's fetch defaults to a 5-minute timeout; a 27B generating under
      // swap on a 24 GB machine legitimately exceeds it. The bun:test
      // per-test timeout is the real ceiling.
      // @ts-expect-error Bun extension
      timeout: false,
    });
    expect(res.status).toBe(200);
    return res.json();
  };

  test("thinking is on by default and splits into `reasoning`", async () => {
    const json = await chat({
      messages: [{ role: "user", content: "What is 2+2?" }],
      max_tokens: 32,
      temperature: 0,
    });
    const msg = json.choices[0].message;
    // Generation opens inside <think>, so the first tokens are reasoning.
    expect((msg.reasoning ?? "").length).toBeGreaterThan(0);
    // Whatever content exists must not leak think markup.
    expect(msg.content ?? "").not.toContain("<think>");
    expect(msg.reasoning ?? "").not.toContain("<think>");
  }, 1_800_000);

  test("instruct mode: no reasoning, direct answer, eos stop", async () => {
    const json = await chat({
      messages: [{ role: "user", content: "Reply with exactly: OK" }],
      max_tokens: 32,
      temperature: 0,
      chat_template_kwargs: { enable_thinking: false },
    });
    const choice = json.choices[0];
    expect(choice.finish_reason).toBe("stop"); // hit eos, not the cap
    expect(choice.message.content).toContain("OK");
    expect(choice.message.reasoning ?? "").toBe("");
  }, 1_800_000);

  test("reasoning_effort depth flows through the request path", async () => {
    const json = await chat({
      messages: [{ role: "user", content: "What is 3+3?" }],
      max_tokens: 32,
      temperature: 0,
      reasoning_effort: "low",
    });
    // "low" keeps thinking ON (only "none" disables) at the low template depth;
    // the render must not 500 (the template raises on unmapped level names).
    expect((json.choices[0].message.reasoning ?? "").length).toBeGreaterThan(0);
  }, 1_800_000);

  test("Qwen3.8 XML tool call parses into OpenAI tool_calls", async () => {
    const json = await chat({
      messages: [{
        role: "user",
        content: "Read the file /tmp/notes.txt using the read tool.",
      }],
      tools: [{
        type: "function",
        function: {
          name: "read",
          description: "Read a file from disk",
          parameters: {
            type: "object",
            properties: { path: { type: "string" } },
            required: ["path"],
          },
        },
      }],
      max_tokens: 160,
      temperature: 0,
      chat_template_kwargs: { enable_thinking: false },
    });
    const choice = json.choices[0];
    expect(choice.finish_reason).toBe("tool_calls");
    const call = choice.message.tool_calls[0];
    expect(call.function.name).toBe("read");
    expect(JSON.parse(call.function.arguments).path).toBe("/tmp/notes.txt");
  }, 1_800_000);
});
