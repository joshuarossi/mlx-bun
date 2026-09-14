import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const path = process.env.MLX_BUN_TEST_SHARED_ECHO_MODEL;
const draft = process.env.MLX_BUN_TEST_SHARED_ECHO_DRAFT;
describe.skipIf(!path)("shared echo HTTP and persistent history", async () => {
  if (!path) return;
  const { createServer, loadContext } = await import("../../src/server");
  const { configureRuntime } = await import("../../src/runtime-config");
  const { createRequestPrep } = await import("../../src/serve/request-prep");
  const ctx = await loadContext(path, "shared-echo-test", draft
    ? { draftModelDir: draft, draftKind: "mtp", numDraftTokens: 2 } : {});
  const value = "The amber lantern beside the quiet river illuminates seven silver keys and a small wooden box.";
  const tools = [{ type: "function", function: { name: "save_text", description: "Save the exact supplied text.",
    parameters: { type: "object", properties: { text: { type: "string" } }, required: ["text"], additionalProperties: false } } }];
  const messages = [{ role: "user", content: `Call save_text with this exact text, without changing any character: ${value}` }];
  const prep = createRequestPrep({ ctx, serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: undefined });
  for (const storage of ["ram", "ssd"] as const) for (const kv of ["bf16", "kv4", "k8v3"] as const)
    test(`${storage} ${kv}: verified copy, seeded batching and restart`, async () => {
      const restoreRuntime = configureRuntime({ MLX_BUN_FILL: "echo", MLX_BUN_FILL_K: "4" });
      const dir = mkdtempSync(join(tmpdir(), "mlx-bun-shared-echo-"));
      const options = { promptCacheBytes: storage === "ssd" ? 16 : 512 * 2 ** 20,
        ...(storage === "ssd" ? { ssdCacheDir: dir, ssdCacheVerify: true } : {}),
        ...(kv === "kv4" ? { kvQuant: 4 as const, quantizedKvStart: 0 }
          : kv === "k8v3" ? { turboQuant: { kBits: 8 as const, vBits: 3 as const }, quantizedKvStart: 0 } : {}),
      };
      let server = createServer(ctx, 0, options);
      const chat = async (messages: unknown[], seed = 42) => {
        const response = await fetch(`http://127.0.0.1:${server.port}/v1/chat/completions`, {
          method: "POST", headers: { "content-type": "application/json" },
          body: JSON.stringify({ messages, tools, temperature: 0, seed, max_tokens: 160,
            chat_template_kwargs: { enable_thinking: false } }), signal: AbortSignal.timeout(120_000),
        });
        const body = await response.json() as any;
        expect(response.status, JSON.stringify(body)).toBe(200);
        expect(body.usage.lane).toBe("batched");
        if (draft) expect(body.usage.speculation.targetCalls).toBeGreaterThan(0);
        return body;
      };
      const flush = async () => {
        const result = await (await fetch(`http://127.0.0.1:${server.port}/admin/cache/flush`, { method: "POST" })).json() as any;
        expect(result.durable).toBe(true);
      };
      try {
        const first = await chat(messages);
        if (draft) expect(first.usage.speculation.drafted).toBeGreaterThan(0);
        const call = first.choices[0].message.tool_calls?.[0];
        expect(call?.function.name, JSON.stringify(first)).toBe("save_text");
        expect(JSON.parse(call.function.arguments)).toEqual({ text: value });
        expect(first.usage.fill.verifyAccepted).toBeGreaterThan(0);
        if (storage === "ssd") { await flush(); server.stop(true); server = createServer(ctx, 0, options); }
        const history = [...messages, first.choices[0].message,
          { role: "tool", tool_call_id: call.id, content: "Saved successfully." },
          { role: "user", content: "Call save_text again with the exact same text." }];
        const next = await chat(history);
        const request = { messages, chat_template_kwargs: { enable_thinking: false } };
        const original = prep.promptIdsFor(request, tools as import("../../src/chat-template").ToolDefinition[]).ids;
        const continued = prep.promptIdsFor({ ...request, messages: history }, tools as import("../../src/chat-template").ToolDefinition[]).ids;
        let common = 0;
        while (common < original.length && original[common] === continued[common]) common++;
        // Qwen removes the empty thinking primer from a historical tool turn.
        // Its recurrent state must retain the last actually stable boundary.
        expect(next.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(Math.min(common, original.length - 1));
        expect(JSON.parse(next.choices[0].message.tool_calls[0].function.arguments)).toEqual({ text: value });
        if (storage === "ssd") await flush();
        const concurrent = await Promise.all([chat(messages, 42), chat(messages, 43)]);
        for (const response of concurrent) {
          expect(JSON.parse(response.choices[0].message.tool_calls[0].function.arguments)).toEqual({ text: value });
          expect(response.usage.fill.verifyAccepted).toBeGreaterThan(0);
        }
        if (storage === "ssd") await flush();
      } finally { server.stop(true); restoreRuntime(); rmSync(dir, { recursive: true, force: true }); }
    }, 120_000);
});
