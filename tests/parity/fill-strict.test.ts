// Strict token fast-forwarding against real weights (K3b follow-up gate).
//
// The model-free tiers prove the mechanism (tests/unit/fill-generate-loop.ts:
// one forward carries the span, the cache stays aligned) and the row compiler
// (tests/unit/fill-schema-rows.ts: token-exact spans from template probing).
// What only weights can show is the claim that matters for shipping:
//
//   at temperature 0, a filled generation emits the SAME token sequence as an
//   unfilled one, with strictly fewer model forwards.
//
// Strict rows are token-identical by construction — they are sliced out of the
// model's own chat template — so this is a gate, not a measurement. Any
// divergence means the template's rendering of `tool_calls` disagrees with
// what the model actually emits, and the row compiler must get stricter.
//
// Gated: skips cleanly without the Qwen3.5-0.8B snapshot. Run with
//   MLX_BUN_FILL=strict bun test tests/parity/fill-strict.test.ts
//
// 2026-08-31: the first weights run on this model caught the row compiler
// probing with PLACEHOLDER tool names. Qwen3.5 renders `<function=get_weather>`
// and the tokenizer merges `=get` into one token; a placeholder name split it
// into `=` + `zzalpha…`, so the scaffold injected a bare `=` and the model then
// emitted `get` instead of `=get`. Decoded text was byte-identical, token ids
// were not. Rows are now sliced only from real-name renderings, and the id
// containment check below is the gate that catches a relapse WITHOUT weights.
import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT_QWEN35_08B, snapshotQwen35_08bAvailable } from "../support/paths";
import type { ToolDefinition } from "../../src/chat-template";
import { configureRuntime } from "../../src/runtime-config";

const haveWeights = await snapshotQwen35_08bAvailable();

const TOOLS: ToolDefinition[] = [
  {
    type: "function",
    function: {
      name: "get_weather",
      description: "Current weather for a city",
      parameters: {
        type: "object",
        properties: { city: { type: "string", description: "City name" } },
        required: ["city"],
        additionalProperties: false,
      },
    },
  },
  {
    type: "function",
    function: {
      name: "search_docs",
      description: "Search the documentation",
      parameters: {
        type: "object",
        properties: { query: { type: "string" }, limit: { type: "integer" } },
        required: ["query"],
      },
    },
  },
];
const MESSAGES = [{ role: "user", content: "What is the weather in Paris right now?" }];

describe.skipIf(!haveWeights)("strict fill rows on a real tokenizer + template", async () => {
  if (!haveWeights) return;
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { compileStrictFillRows } = await import("../../src/fill/schema-rows");

  const tokenizer = await loadTokenizer(SNAPSHOT_QWEN35_08B);
  const template = await ChatTemplate.load(SNAPSHOT_QWEN35_08B);

  const CALLS = [
    { name: "get_weather", args: { city: "Paris" } },
    { name: "search_docs", args: { query: "kv cache", limit: 5 } },
  ];
  const renderCall = (name: string, args: Record<string, unknown>): number[] =>
    tokenizer.encode(template.render(
      [...MESSAGES, {
        role: "assistant", content: "",
        tool_calls: [{ id: "call_1", type: "function", function: { name, arguments: args } }],
      }],
      { tools: TOOLS, addGenerationPrompt: false },
    ));
  const idRunAt = (haystack: number[], needle: number[]): number => {
    for (let i = 0; i + needle.length <= haystack.length; i++) {
      let ok = true;
      for (let j = 0; j < needle.length; j++) {
        if (haystack[i + j] !== needle[j]) { ok = false; break; }
      }
      if (ok) return i;
    }
    return -1;
  };

  test("scaffold probing finds determined spans in the shipped template", () => {
    const { rows } = compileStrictFillRows({
      template, tokenizer, messages: MESSAGES, tools: TOOLS,
      renderOptions: { tools: TOOLS },
    });
    expect(rows.length).toBeGreaterThan(0);
    expect(rows.map((r) => r.kind)).toContain("scaffold");
  });

  test("every row is a contiguous ID subsequence of a real call rendering", () => {
    // The gate the 2026-08-31 divergence needed. A TEXT check passes even when
    // a span splits a merged token (`=` + `get` decodes the same as `=get`);
    // only id containment proves the row is a slice of a stream the model can
    // actually produce.
    const { rows } = compileStrictFillRows({
      template, tokenizer, messages: MESSAGES, tools: TOOLS,
      renderOptions: { tools: TOOLS },
    });
    const renderings = CALLS.map((c) => renderCall(c.name, c.args));
    for (const r of rows) {
      const seq = [...r.trigger, ...r.emit];
      const found = renderings.some((ids) => idRunAt(ids, seq) !== -1);
      expect({ kind: r.kind, text: tokenizer.decode(seq, false), found })
        .toMatchObject({ found: true });
    }
  });
});

describe.skipIf(!haveWeights)("filled vs unfilled greedy generation (weights)", async () => {
  if (!haveWeights) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { compileStrictFillRows } = await import("../../src/fill/schema-rows");
  const { FillSession } = await import("../../src/fill/fill-session");
  const { generate } = await import("../../src/generate");

  const config = await loadModelConfig(SNAPSHOT_QWEN35_08B);
  const weights = await Weights.open(SNAPSHOT_QWEN35_08B);
  const model = createModel(weights, config);
  const tokenizer = await loadTokenizer(SNAPSHOT_QWEN35_08B);
  const template = await ChatTemplate.load(SNAPSHOT_QWEN35_08B);

  const promptIds = tokenizer.encode(
    template.render(MESSAGES, { tools: TOOLS, addGenerationPrompt: true }));
  const { rows, delimiters } = compileStrictFillRows({
    template, tokenizer, messages: MESSAGES, tools: TOOLS,
    renderOptions: { tools: TOOLS },
  });

  const run = async (fill: boolean) => {
    const restore = configureRuntime({ MLX_BUN_FILL: fill ? "strict" : undefined });
    try {
      const session = fill
        ? new FillSession(
          {
            rows, echo: null, delimiters: new Set(delimiters),
            eos: config.eosTokenIds,
          },
          promptIds,
        )
        : undefined;
      const gen = generate(model, promptIds, {
        temperature: 0, maxTokens: 160,
        ...(session ? { fill: session } : {}),
      });
      const tokens: number[] = [];
      for await (const t of gen) tokens.push(t.token);
      return { tokens, stats: gen.stats! };
    } finally {
      restore();
    }
  };

  afterAll(async () => {
    weights.dispose();
    (await import("../../src/mlx/ffi")).clearCache();
  });

  test("token-identical output, fewer forwards", async () => {
    expect(rows.length).toBeGreaterThan(0);
    const off = await run(false);
    const on = await run(true);
    expect(on.tokens).toEqual(off.tokens);
    // If this is 0 the prompt did not elicit a tool call — change the prompt
    // (or set tool_choice) rather than weakening the gate.
    expect(on.stats.fill!.injected).toBeGreaterThan(0);
    // Injected positions are forwards the model never ran.
    expect(on.stats.fill!.decodeSteps + on.stats.fill!.injected)
      .toBeLessThanOrEqual(on.stats.generatedTokens);
    expect(on.stats.fill!.decodeSteps).toBeLessThan(off.stats.generatedTokens);
  });
});
