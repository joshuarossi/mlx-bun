// The request pipeline end to end, with a scripted engine and a fake model
// host — no model, no HTTP server:
//   new ChatRequest(body) → ChatStage.run → InferenceStage.admit/run → result
//   → openai-wire JSON / SSE frames.
// Route-level coverage (real createServer + fetch) is tests/unit/glm52-model.test.ts.
import { describe, expect, test } from "bun:test";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "../../src/generate";
import type { ChatTemplate } from "../../src/chat-template";
import type { LoadedTokenizer } from "../../src/tokenizer";
import { ChatRequest, TextCompletionRequest } from "../../src/serve/chat-request";
import { ChatStage } from "../../src/serve/chat-stage";
import { TextCompletionStage } from "../../src/serve/text-completion-stage";
import { InferenceStage } from "../../src/serve/inference-request";
import { RequestError } from "../../src/serve/pipeline";
import { createRequestPrep } from "../../src/serve/request-prep";
import { CompletionExecutor, type CompletionEngine } from "../../src/serve/completion-executor";
import type { CompletionEvent } from "../../src/serve/completion-sink";
import type { ServerContext } from "../../src/serve/model-host";
import { chatCompletionJson, chatCompletionStream } from "../../src/serve/openai-wire";

class ScriptedEngine implements CompletionEngine {
  readonly seenOptions: GenerateOptions[] = [];
  place(shape: Parameters<CompletionEngine["place"]>[0]) {
    return Object.freeze({ shape, mechanism: "serial" as const });
  }
  async run(
    _promptIds: number[],
    options: GenerateOptions,
    onToken: (token: number, info?: TokenLogprobs) => void | boolean | Promise<void | boolean>,
  ): Promise<GenerateStats> {
    this.seenOptions.push(options);
    for (const token of [1, 2]) {
      const control = await onToken(token, { logprob: -token });
      if (control === false) break;
    }
    return {
      promptTokens: 3, cachedTokens: 1, generatedTokens: 2,
      prefillTps: 10, decodeTps: 20, prefillMs: 30, decodeMs: 40,
      cacheTokens: [7, 8, 9, 1, 2],
    };
  }
}

function harness(overrides: { maxSafeContext?: number; defaultAdapter?: string } = {}) {
  const tokenizer: LoadedTokenizer = {
    encode: () => [7, 8, 9],
    decode: (ids) => ids.map((id) => `t${id}`).join(" "),
    idToToken: (id) => `t${id}`,
    bosTokenId: null,
    eosTokenId: null,
  };
  const template = {
    render: () => "<rendered>",
    supportsThinking: false,
    thinkingFormat: "none",
  } as unknown as ChatTemplate;
  const resolvedSpecs: Array<string | undefined> = [];
  const ctx = {
    model: { config: { modelType: "qwen3", eosTokenIds: [0], text: { vocabSize: 16 } } },
    tokenizer,
    template,
    modelId: "fake-chat",
    adapters: { resolveSpec: (spec?: string) => { resolvedSpecs.push(spec); return []; } },
    genDefaults: {},
    draft: null,
    vision: null, loadVision: null,
    audio: null, loadAudio: null, audioTokenIds: null,
    visionTokenIds: { imageTokenId: 1, boiTokenId: 2, eoiTokenId: 3 },
  } as unknown as ServerContext;
  const engine = new ScriptedEngine();
  const peeks: number[][] = [];
  const prep = createRequestPrep({ ctx, serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: undefined });
  const maxSafeContext = overrides.maxSafeContext ?? 4096;
  const chat = new ChatStage(
    ctx, prep, { peekPrefixLen: (ids: number[]) => { peeks.push(ids); return 0; } },
    maxSafeContext, overrides.defaultAdapter);
  const text = new TextCompletionStage(ctx, prep, maxSafeContext, undefined, overrides.defaultAdapter);
  const inference = new InferenceStage(new CompletionExecutor(engine));
  return { chat, text, inference, engine, peeks, resolvedSpecs };
}

const user = [{ role: "user", content: "hi" }];
const signal = new AbortController().signal;
const rejects = (make: () => unknown, status: number, message: string) => {
  let caught: unknown;
  try { make(); } catch (e) { caught = e; }
  expect(caught).toBeInstanceOf(RequestError);
  expect((caught as RequestError).status).toBe(status);
  expect((caught as RequestError).message).toContain(message);
};

describe("request objects validate at construction (mlx-lm's 400 messages)", () => {
  test("ChatRequest", () => {
    rejects(() => new ChatRequest({ messages: [] }), 400, "messages required");
    rejects(() => new ChatRequest({ messages: user, logprobs: "yes" as never }), 400, "logprobs must be of type bool");
    rejects(() => new ChatRequest({ messages: user, top_logprobs: 12 }), 400, "top_logprobs must be at most 11");
    rejects(() => new ChatRequest({ messages: user, reasoning_effort: "hihg" as never }), 400, "reasoning_effort must be one of");
    expect(new ChatRequest({ messages: user, stream: true }).stream).toBe(true);
  });
  test("TextCompletionRequest", () => {
    rejects(() => new TextCompletionRequest({}), 400, "prompt (a non-empty string) is required");
    rejects(() => new TextCompletionRequest({ prompt: [1, 2] }), 400, "prompt (a non-empty string) is required");
    expect(new TextCompletionRequest({ prompt: "hi" }).params.prompt).toBe("hi");
  });
});

describe("ChatStage: ChatRequest → InferenceRequest", () => {
  test("resolves prompt ids, options, adapters, and the token pipeline", async () => {
    const { chat, peeks, resolvedSpecs } = harness({ defaultAdapter: "srv-default" });
    const req = await chat.run(new ChatRequest({ messages: user, max_tokens: 8, temperature: 0 }), "chatcmpl-x");
    expect(req).toMatchObject({
      requestId: "chatcmpl-x", stream: false, warnings: [],
      plan: { promptIds: [7, 8, 9], requestedMaxTokens: 8, maxSafeContext: 4096, adapterIds: [], hasVision: false, userSeed: false },
    });
    expect(req.plan.options).toMatchObject({ temperature: 0, maxTokens: 8 });
    // The server-wide adapter default reaches the resolver; the request's
    // explicit `adapter` wins over it.
    expect(resolvedSpecs).toEqual(["srv-default"]);
    await chat.run(new ChatRequest({ messages: user, adapter: "none" }));
    expect(resolvedSpecs).toEqual(["srv-default", "none"]);
    // Text chat prompts probe the cache before deciding on a snapshot boundary.
    expect(peeks[0]).toEqual([7, 8, 9]);
  });
  test("a bad logit_bias is a 400 from the stage, resources released", async () => {
    const { chat } = harness();
    await expect(chat.run(new ChatRequest({ messages: user, logit_bias: { abc: 1 } })))
      .rejects.toMatchObject({ status: 400, message: "logit_bias must be a dict of int to float" });
  });
  test("media the served model cannot take is a 400", async () => {
    const { chat } = harness();
    const video = [{ role: "user", content: [{ type: "video_url", video_url: { url: "data:;base64,AA==" } }] }];
    await expect(chat.run(new ChatRequest({ messages: video })))
      .rejects.toMatchObject({ status: 400, message: expect.stringContaining("does not accept video input") });
  });
});

describe("TextCompletionStage: TextCompletionRequest → InferenceRequest", () => {
  test("tokenizes the raw prompt; no invented cap (admission is the limit); no tool routing", async () => {
    const { text } = harness();
    const req = await text.run(new TextCompletionRequest({ prompt: "hi", stream: true }), "cmpl-x");
    expect(req).toMatchObject({
      requestId: "cmpl-x", stream: true,
      plan: { promptIds: [7, 8, 9], requestedMaxTokens: Infinity, hasVision: false },
      pipeline: { collectToolCalls: false },
    });
  });
});

describe("InferenceStage: admit, then run", () => {
  test("the whole pipe: result carries content, finish reason, usage, lane", async () => {
    const { chat, inference } = harness();
    const admitted = inference.admit(await chat.run(new ChatRequest({ messages: user }), "chatcmpl-x"));
    const result = await inference.run(admitted, { signal });
    expect(result).toMatchObject({
      content: "t1 t2", reasoning: "", toolCalls: [], lane: "serial",
      usage: { promptTokens: 3, cachedTokens: 1, completionTokens: 2, totalTokens: 5 },
    });
    expect(typeof result.finishReason).toBe("string");
    // JSON wire shape
    expect(chatCompletionJson(result, { id: "chatcmpl-x", created: 1, model: "fake-chat" })).toMatchObject({
      id: "chatcmpl-x", object: "chat.completion", model: "fake-chat",
      choices: [{ index: 0, message: { role: "assistant", content: "t1 t2" }, finish_reason: result.finishReason }],
      usage: { prompt_tokens: 3, completion_tokens: 2, total_tokens: 5, prompt_tokens_details: { cached_tokens: 1 }, lane: "serial" },
    });
  });
  test("streaming: events reach the caller as the model produces them", async () => {
    const { chat, inference } = harness();
    const admitted = inference.admit(await chat.run(new ChatRequest({ messages: user, stream: true })));
    const seen: CompletionEvent[] = [];
    await inference.run(admitted, { signal, onEvents: (events) => { seen.push(...events); } });
    const content = seen.filter((e) => e.type === "content").map((e) => (e as { text: string }).text).join("");
    expect(content).toBe("t1 t2");
  });
  test("admission: a prompt with no generation room is refused before any run", async () => {
    const { chat, inference, engine } = harness({ maxSafeContext: 3 });
    const req = await chat.run(new ChatRequest({ messages: user }));
    rejects(() => inference.admit(req), 400, "safe context");
    let caught: RequestError | undefined;
    try { inference.admit(await chat.run(new ChatRequest({ messages: user }))); } catch (e) { caught = e as RequestError; }
    expect(caught?.body).toMatchObject({ type: "memory_admission", code: "context_over_budget" });
    expect(engine.seenOptions).toHaveLength(0);
  });
});

describe("OpenAI chat SSE protocol", () => {
  test("role primer, per-event chunks, terminal usage chunk, [DONE]; an error ends the stream", () => {
    const meta = { id: "chatcmpl-s", created: 1, model: "fake-chat" };
    const p = chatCompletionStream(meta);
    const parse = (frames: string[]) => frames.map((f) => f.replace(/^data: /, "").trim());
    expect(JSON.parse(parse(p.start())[0]!)).toMatchObject({ object: "chat.completion.chunk", choices: [{ delta: { role: "assistant", content: "" } }] });
    const events = parse(p.addEvents([{ type: "content", text: "hi" }, { type: "reasoning", text: "why" }] as CompletionEvent[]));
    expect(JSON.parse(events[0]!).choices[0].delta).toEqual({ content: "hi" });
    expect(JSON.parse(events[1]!).choices[0].delta).toEqual({ reasoning: "why" });
    const fin = parse(p.finish("stop", { total_tokens: 5 }));
    expect(JSON.parse(fin[0]!)).toMatchObject({ choices: [{ finish_reason: "stop" }], usage: { total_tokens: 5 } });
    expect(fin[1]).toBe("[DONE]");
    const q = chatCompletionStream(meta);
    expect(JSON.parse(parse(q.error("boom"))[0]!)).toEqual({ error: { message: "boom" } });
    expect(q.finish("stop", {})).toEqual([]);
  });
});
