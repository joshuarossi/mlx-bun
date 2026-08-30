// The chat core behind every chat-shaped surface, exercised through its
// injected seam (createChatHandler) with a scripted engine and a fake
// ServerContext — no model, no HTTP server. Route-level coverage (real
// createServer + fetch) is tests/unit/glm52-model.test.ts.
import { describe, expect, test } from "bun:test";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "../../src/generate";
import type { ChatTemplate } from "../../src/chat-template";
import type { LoadedTokenizer } from "../../src/tokenizer";
import { createChatHandler } from "../../src/serve/chat-handler";
import { createRequestPrep } from "../../src/serve/request-prep";
import { CompletionExecutor, type CompletionEngine } from "../../src/serve/completion-executor";
import type { ServerContext } from "../../src/serve/model-host";

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
  const handle = createChatHandler({
    ctx,
    prep: createRequestPrep({ ctx, serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: undefined }),
    promptCache: { peekPrefixLen: (ids) => { peeks.push(ids); return 0; } },
    completionExecutor: new CompletionExecutor(engine),
    maxSafeContext: overrides.maxSafeContext ?? 4096,
    ...(overrides.defaultAdapter ? { defaultAdapter: overrides.defaultAdapter } : {}),
  });
  return { handle, engine, peeks, resolvedSpecs };
}

const user = [{ role: "user", content: "hi" }];
const signal = new AbortController().signal;

describe("createChatHandler", () => {
  test("rejects malformed requests with mlx-lm's 400 messages before any generation", async () => {
    const { handle, engine } = harness();
    const cases: Array<[Record<string, unknown>, string]> = [
      [{ messages: [] }, "messages required"],
      [{ messages: user, logprobs: "yes" }, "logprobs must be of type bool"],
      [{ messages: user, top_logprobs: 12 }, "top_logprobs must be at most 11"],
      [{ messages: user, reasoning_effort: "hihg" }, "reasoning_effort must be one of"],
      [{ messages: user, logit_bias: { abc: 1 } }, "logit_bias must be a dict of int to float"],
    ];
    for (const [body, message] of cases) {
      const resp = await handle(body as never, signal);
      const json = await resp.json() as { error: { message: string } };
      expect({ status: resp.status, message: json.error.message }).toMatchObject({ status: 400 });
      expect(json.error.message).toContain(message);
    }
    expect(engine.seenOptions).toHaveLength(0);
  });

  test("non-stream: prepares, executes, and frames an OpenAI chat.completion", async () => {
    const { handle, engine, peeks, resolvedSpecs } = harness({ defaultAdapter: "srv-default" });
    const resp = await handle({ messages: user, max_tokens: 8, temperature: 0 } as never, signal, undefined, "chatcmpl-x");
    expect(resp.status).toBe(200);
    expect(await resp.json()).toMatchObject({
      id: "chatcmpl-x",
      object: "chat.completion",
      model: "fake-chat",
      choices: [{ index: 0, message: { role: "assistant", content: "t1 t2" } }],
      usage: { prompt_tokens: 3, completion_tokens: 2, total_tokens: 5, prompt_tokens_details: { cached_tokens: 1 }, lane: "serial" },
    });
    // The server-wide adapter default reaches the resolver; the request's
    // explicit `adapter` wins over it.
    expect(resolvedSpecs).toEqual(["srv-default"]);
    await handle({ messages: user, adapter: "none" } as never, signal);
    expect(resolvedSpecs).toEqual(["srv-default", "none"]);
    // Chat prompts probe the cache before deciding on a snapshot boundary.
    expect(peeks[0]).toEqual([7, 8, 9]);
    expect(engine.seenOptions[0]).toMatchObject({ temperature: 0, maxTokens: 8 });
  });

  test("stream: SSE role primer, content deltas, terminal usage chunk, [DONE]", async () => {
    const { handle } = harness();
    const resp = await handle({ messages: user, stream: true } as never, signal, undefined, "chatcmpl-s");
    expect(resp.headers.get("content-type")).toBe("text/event-stream");
    const text = await resp.text();
    const frames = text.split("\n\n").filter(Boolean).map((f) => f.replace(/^data: /, ""));
    expect(frames.at(-1)).toBe("[DONE]");
    const chunks = frames.slice(0, -1).map((f) => JSON.parse(f) as { choices: Array<{ delta: Record<string, unknown>; finish_reason: string | null }>; usage?: unknown; object: string });
    expect(chunks.every((c) => c.object === "chat.completion.chunk")).toBe(true);
    expect(chunks[0]!.choices[0]!.delta).toEqual({ role: "assistant", content: "" });
    const content = chunks.map((c) => c.choices[0]!.delta.content ?? "").join("");
    expect(content).toBe("t1 t2");
    const last = chunks.at(-1)!;
    expect(last.choices[0]!.finish_reason).not.toBeNull();
    expect(last.usage).toMatchObject({ prompt_tokens: 3, completion_tokens: 2, lane: "serial" });
  });

  test("admission ceiling from the seam: a prompt with no generation room is a 400 rejection", async () => {
    const { handle, engine } = harness({ maxSafeContext: 3 });
    const resp = await handle({ messages: user } as never, signal);
    expect(resp.status).toBe(400);
    expect(await resp.json()).toMatchObject({
      error: { type: "memory_admission", code: "context_over_budget" },
    });
    expect(engine.seenOptions).toHaveLength(0);
  });
});
