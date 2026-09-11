import { describe, expect, spyOn, test } from "bun:test";
import type { ChatMessage, ToolDefinition } from "../../src/chat-template";

const enabled = Bun.env.MLX_BUN_TEST_MTP_PREFIX === "1";
describe.skipIf(!enabled)("generated IDs across chat rendering", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { ToolAwareStream, ThinkingTagSplitter } = await import("../../src/serve/token-streams");
  const { disposeResources } = await import("../../src/engine/resources");
  const { disposeAttachments } = await import("../../src/backends/mlx/checkpoint-state");
  const { clearCache } = await import("../../src/mlx/ffi");

  test.each([false, true])("a tool turn reuses sampled IDs with thinking=%s", async (thinking) => {
    const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const weights = await Weights.open(target), model = new Qwen35Model(weights, await loadModelConfig(target));
    const provider = await QwenMtpProvider.load(draft), tokenizer = await loadTokenizer(target), template = await ChatTemplate.load(target);
    const cache = new PromptCache(2 * 1024 ** 3), group = new MlxBatchExecutionGroup(model, { maxBatch: 4, promptCache: cache });
    const messages: ChatMessage[] = [{ role: "user", content: "Call the echo tool once with message hello. Do not add any other text." }];
    const tools: ToolDefinition[] = [{ type: "function", function: { name: "echo", description: "Echo a message.",
      parameters: { type: "object", properties: { message: { type: "string" } }, required: ["message"] } } }];
    const render = { tools, enableThinking: thinking, preserveThinking: true, reasoningEffort: "low" as const };
    const promptText = template.render(messages, render), prompt = tokenizer.encode(promptText);
    const route = new ToolAwareStream(tokenizer, "buffered-text", tools);
    const split = new ThinkingTagSplitter(true, promptText.trimEnd().endsWith("<think>"));
    const ids: number[] = []; let published: number[] = [], namespace = "";
    const put = cache.put;
    const spy = spyOn(cache, "put").mockImplementation(function (this: InstanceType<typeof PromptCache>, ...args) {
      if (args[0].length > prompt.length) { published = [...args[0]]; namespace = args[2]!; }
      return put.apply(this, args);
    });
    try {
      const options = { temperature: 0, seed: 42, kvBits: 4, kvGroupSize: 64, quantizedKvStart: 0, maxTokens: 256 };
      const result = await group.submit({ method: bindSpeculativeGroupRequests(model, provider, 3)(options), promptIds: prompt,
        eosTokenIds: [...model.config.eosTokenIds, ...(tokenizer.eosTokenId === null ? [] : [tokenizer.eosTokenId])],
        maxTokens: 256, onToken(token) { ids.push(token); split.push(route.push(token)); } });
      split.push(route.flush()); split.flush();
      const calls = route.toolCalls();
      expect(result.finishReason).toBe("stop");
      expect(calls.length).toBe(1);
      expect(calls[0]!.function.name).toBe("echo");
      const assistant: ChatMessage = { role: "assistant", content: split.content,
        reasoning_content: split.reasoning, tool_calls: calls.map(call => ({ ...call,
          function: { ...call.function, arguments: JSON.parse(call.function.arguments) } })) };
      const next = tokenizer.encode(template.render([...messages, assistant,
        { role: "tool", tool_call_id: calls[0]!.id, content: "hello" }], render));
      const actual = [...prompt, ...ids];
      let common = 0; while (common < actual.length && actual[common] === next[common]) common++;
      console.error(JSON.stringify({ thinking, promptTokens: prompt.length, sampledTokens: ids.length,
        publishedTokens: published.length, nextTokens: next.length, commonPrefix: common,
        mismatch: common < published.length ? { generated: actual.slice(common, common + 12), rendered: next.slice(common, common + 12),
          generatedText: tokenizer.decode(actual.slice(common, common + 12), false), renderedText: tokenizer.decode(next.slice(common, common + 12), false) } : null }));
      expect(published.length).toBeGreaterThan(prompt.length);
      expect(published).toEqual(actual.slice(0, published.length));
      expect(next.slice(0, published.length)).toEqual(published);
      const hit = cache.take(next, namespace)!;
      try { expect(hit.tokens).toEqual(published); }
      finally { disposeResources([...hit.caches, { dispose: () => disposeAttachments(hit.attachments) }, { dispose: () => hit.retain?.() }]); }
    } finally { spy.mockRestore(); await group.close(); cache.clear(); provider.dispose(); weights.dispose(); clearCache(); }
  }, 600000);
});
