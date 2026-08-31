// Token fast-forwarding at the serve seam: which requests get a fill table,
// which are refused, and what `usage.fill` looks like on the wire.
// Scripted engine + fake model host — no model, no HTTP server (same shape as
// tests/serve/pipeline.test.ts).
import { describe, expect, test } from "bun:test";
import type { ChatTemplate } from "../../src/chat-template";
import { FillSession } from "../../src/fill/fill-session";
import type { GenerateOptions, GenerateStats } from "../../src/generate";
import type { LoadedTokenizer } from "../../src/tokenizer";
import { configureRuntime, type RuntimeOverrides } from "../../src/runtime-config";
import { ChatRequest } from "../../src/serve/chat-request";
import { ChatStage } from "../../src/serve/chat-stage";
import { CompletionExecutor, type CompletionEngine } from "../../src/serve/completion-executor";
import { InferenceStage } from "../../src/serve/inference-request";
import type { ServerContext } from "../../src/serve/model-host";
import { chatCompletionJson, openAiUsage } from "../../src/serve/openai-wire";
import { createRequestPrep } from "../../src/serve/request-prep";
import {
  jinjaTemplate,
  makeTokenizer,
  NO_TOOL_CALLS_TEMPLATE,
  QWEN_STYLE_TEMPLATE,
  WEATHER_TOOL,
} from "../support/fill-fixtures";

const FILL_STATS: NonNullable<GenerateStats["fill"]> = {
  events: 2, injected: 21, strict: 21, echo: 0, spanLens: [8, 13],
  wastedSamples: 2, parseFallback: 0, indexTruncated: 0, decodeSteps: 40,
  verifyEvents: 0, verifyAccepted: 0, verifyRejected: 0, verifyUnsupported: 0,
  checkpointMs: 0, branchStops: 0,
};

class ScriptedEngine implements CompletionEngine {
  readonly seenOptions: GenerateOptions[] = [];
  constructor(private readonly stats: Partial<GenerateStats> = {}) {}
  place(shape: Parameters<CompletionEngine["place"]>[0]) {
    return Object.freeze({ shape, mechanism: "serial" as const });
  }
  async run(
    _promptIds: number[],
    options: GenerateOptions,
    onToken: (token: number) => void | boolean | Promise<void | boolean>,
  ): Promise<GenerateStats> {
    this.seenOptions.push(options);
    await onToken(1);
    return {
      promptTokens: 3, cachedTokens: 0, generatedTokens: 1,
      prefillTps: 1, decodeTps: 1, prefillMs: 1, decodeMs: 1,
      cacheTokens: [], ...this.stats,
    };
  }
}

function harness(overrides: {
  template?: string;
  draft?: unknown;
  kvScheme?: Record<string, unknown>;
  stats?: Partial<GenerateStats>;
} = {}) {
  const fake = makeTokenizer();
  const template = jinjaTemplate(overrides.template ?? QWEN_STYLE_TEMPLATE);
  const ctx = {
    model: { config: { modelType: "qwen3", eosTokenIds: [0], text: { vocabSize: 4096 } } },
    tokenizer: fake as unknown as LoadedTokenizer,
    template: template as unknown as ChatTemplate,
    modelId: "fake-chat",
    adapters: { resolveSpec: () => [] },
    genDefaults: {},
    draft: overrides.draft ?? null,
    vision: null, loadVision: null,
    audio: null, loadAudio: null, audioTokenIds: null,
    visionTokenIds: { imageTokenId: 1, boiTokenId: 2, eoiTokenId: 3 },
  } as unknown as ServerContext;
  const prep = createRequestPrep({
    ctx, serverOptions: {},
    kvScheme: overrides.kvScheme ?? {},
    defaultGeneratedTokens: undefined,
  });
  const engine = new ScriptedEngine(overrides.stats);
  const chat = new ChatStage(ctx, prep, { peekPrefixLen: () => 0 }, 4096);
  const inference = new InferenceStage(new CompletionExecutor(engine));
  return { chat, inference, engine, tokenizer: fake };
}

const withRuntime = async <T>(env: RuntimeOverrides, fn: () => Promise<T>): Promise<T> => {
  const restore = configureRuntime(env);
  try { return await fn(); } finally { restore(); }
};
const STRICT: RuntimeOverrides = { MLX_BUN_FILL: "strict", MLX_BUN_GRAMMAR: "0" };
const user = [{ role: "user", content: "what is the weather in Paris" }];
const body = (extra: Record<string, unknown> = {}) =>
  new ChatRequest({ messages: user, tools: [WEATHER_TOOL], ...extra });

const fillOf = async (
  h: ReturnType<typeof harness>, request: ChatRequest,
): Promise<FillSession | undefined> =>
  (await h.chat.run(request)).plan.options.fill;

describe("fill is armed for an ordinary tool request", () => {
  test("MLX_BUN_FILL=strict + tools → a compiled session rides on the options", async () => {
    await withRuntime(STRICT, async () => {
      const h = harness();
      const fill = await fillOf(h, body());
      expect(fill).toBeInstanceOf(FillSession);
      // One sole-required-key tool: call open + name + key are ONE determined
      // span (rows are sliced from the real-name rendering, so a merged token
      // is never split — tests/unit/fill-schema-rows.test.ts).
      expect(fill!.plan.rows.map((r) => r.kind)).toEqual(["scaffold"]);
      // The echo index (K3c) is not built: the seam exists, empty.
      expect(fill!.plan.echo).toBeNull();
      // EOS ids come from the served model, so a span can never end the turn.
      expect(fill!.plan.eos).toEqual([0]);
    });
  });

  test("the table reaches the engine as options.fill", async () => {
    await withRuntime(STRICT, async () => {
      const h = harness();
      const admitted = h.inference.admit(await h.chat.run(body()));
      await h.inference.run(admitted, { signal: new AbortController().signal });
      expect(h.engine.seenOptions[0]!.fill).toBeInstanceOf(FillSession);
    });
  });
});

describe("fill is refused by composition", () => {
  const refused = async (
    label: string, request: ChatRequest, h = harness(),
  ): Promise<void> => {
    const fill = await fillOf(h, request);
    expect(`${label}: ${fill === undefined ? "no fill" : "filled"}`)
      .toBe(`${label}: no fill`);
  };

  test("off by default — MLX_BUN_FILL unset never arms a table", async () => {
    await withRuntime({ MLX_BUN_FILL: undefined }, () => refused("default off", body()));
  });

  test("a user-fixed seed (reproducibility), logprobs, and top_logprobs", async () => {
    await withRuntime(STRICT, async () => {
      await refused("seed", body({ seed: 7 }));
      await refused("logprobs", body({ logprobs: true }));
      await refused("top_logprobs", body({ logprobs: true, top_logprobs: 3 }));
    });
  });

  test("structured output owns forced tokens (grammar / guided_*)", async () => {
    await withRuntime(STRICT, async () => {
      await refused("response_format", body({ response_format: { type: "json_object" } }));
      await refused("guided_choice", body({ guided_choice: ["a", "b"] }));
    });
  });

  test("a mounted draft model: the spec loop is a different executor", async () => {
    await withRuntime(STRICT, () =>
      refused("draft", body(), harness({ draft: { model: {} } })));
  });

  test("a quantized-KV scheme (multi-token append after conversion is unvalidated)", async () => {
    await withRuntime(STRICT, async () => {
      await refused("kvBits", body(), harness({ kvScheme: { kvBits: 4, kvGroupSize: 64 } }));
      await refused("turboQuant", body(), harness({ kvScheme: { turboQuant: { kBits: 4, vBits: 4 } } }));
    });
  });

  test("no tools, and a template that does not render tool calls", async () => {
    await withRuntime(STRICT, async () => {
      await refused("no tools", new ChatRequest({ messages: user }));
      await refused("no tool_calls in template", body(),
        harness({ template: NO_TOOL_CALLS_TEMPLATE }));
    });
  });

  // Continuous (batch) placement needs no refusal here: generate() is the only
  // site that reads options.fill, so a batch-placed request simply does not
  // fill. Nothing in this feature forces a request onto the serial lane.
});

describe("MLX_BUN_FILL=echo (Lab tier)", () => {
  test("strict mode leaves the echo index disarmed", async () => {
    await withRuntime(STRICT, async () => {
      const fill = await fillOf(harness(), body());
      expect(fill!.plan.echo).toBeNull();
    });
  });

  test("echo mode arms the index ON TOP of the strict rows", async () => {
    await withRuntime({ ...STRICT, MLX_BUN_FILL: "echo" }, async () => {
      const fill = await fillOf(harness(), body());
      expect(fill!.plan.rows.length).toBeGreaterThan(0);   // strict still applies
      expect(fill!.plan.echo).toMatchObject({ k: 8, maxCandidates: 24 });
      // Delimiters come from the template probe — they are what lets a copied
      // span stop cleanly (and, only then, be asserted rather than verified).
      expect(fill!.plan.delimiters!.size).toBeGreaterThan(0);
    });
  });

  test("echo carries a request whose template yields no strict rows", async () => {
    const noRows = harness({ template: NO_TOOL_CALLS_TEMPLATE });
    await withRuntime({ ...STRICT, MLX_BUN_FILL: "echo" }, async () => {
      const fill = await fillOf(noRows, body());
      expect(fill).toBeInstanceOf(FillSession);
      expect(fill!.plan.rows).toEqual([]);
      expect(fill!.plan.echo).not.toBeNull();
    });
  });

  test("an unknown mode is a loud error, not a silent downgrade", async () => {
    await withRuntime({ MLX_BUN_FILL: "greedy" }, async () => {
      await expect(harness().chat.run(body())).rejects.toThrow(/expected off\|strict\|echo/);
    });
  });

  test("the body-level refusals apply to echo mode too", async () => {
    await withRuntime({ ...STRICT, MLX_BUN_FILL: "echo" }, async () => {
      expect(await fillOf(harness(), body({ seed: 7 }))).toBeUndefined();
      expect(await fillOf(harness(), body({ logprobs: true }))).toBeUndefined();
    });
  });
});

describe("usage.fill on the wire", () => {
  test("openAiUsage carries the fill block next to speculation", () => {
    expect(openAiUsage({
      promptTokens: 10, cachedTokens: 0, completionTokens: 40, totalTokens: 50,
      fill: FILL_STATS,
    })).toMatchObject({
      completion_tokens: 40,
      fill: { events: 2, injected: 21, strict: 21, echo: 0, wastedSamples: 2 },
    });
  });

  test("a chat completion reports it; a run without fill omits the key", async () => {
    const meta = { id: "chatcmpl-f", created: 1, model: "fake-chat" };
    const withFill = harness({ stats: { fill: FILL_STATS } });
    const filled = await withRuntime(STRICT, async () => {
      const admitted = withFill.inference.admit(await withFill.chat.run(body()));
      return withFill.inference.run(admitted, { signal: new AbortController().signal });
    });
    expect(chatCompletionJson(filled, meta).usage).toMatchObject({
      fill: { events: 2, injected: 21, spanLens: [8, 13] },
    });

    const plain = harness();
    const unfilled = await withRuntime(STRICT, async () => {
      const admitted = plain.inference.admit(await plain.chat.run(body()));
      return plain.inference.run(admitted, { signal: new AbortController().signal });
    });
    expect(chatCompletionJson(unfilled, meta).usage).not.toHaveProperty("fill");
  });
});
