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
// Template containment proves token boundaries, not the model's next choice.
// This gate compares actual output. Any divergence means the row compiler
// needs a narrower trigger or the asserted span is not valid for this artifact.
//
// Gated: skips cleanly without the Qwen3.5-0.8B snapshot. Run with
//   MLX_BUN_FILL=strict bun test tests/parity/fill-strict.test.ts
// Select the real 27B artifact with MLX_BUN_TEST_FILL_MODEL=<local-dir>.
// TEST_FILL_REPORT records warm paired request timings; TEST_FILL_BLOCKS,
// TEST_FILL_PROMPT and TEST_FILL_REVERSE select the diagnostic workload.
// One artifact per process; never run this beside a resident model or training.
//
// 2026-08-31: the first weights run on this model caught the row compiler
// probing with PLACEHOLDER tool names. Qwen3.5 renders `<function=get_weather>`
// and the tokenizer merges `=get` into one token; a placeholder name split it
// into `=` + `zzalpha…`, so the scaffold injected a bare `=` and the model then
// emitted `get` instead of `=get`. Decoded text was byte-identical, token ids
// were not. Rows are now sliced only from real-name renderings, and the id
// containment check below is the gate that catches a relapse WITHOUT weights.
import { afterAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync } from "node:fs";
import { hostname } from "node:os";
import { dirname, resolve } from "node:path";
import { SNAPSHOT_QWEN35_08B, snapshotQwen35_08bAvailable } from "../support/paths";
import type { ToolDefinition } from "../../src/chat-template";
import { configureRuntime } from "../../src/runtime-config";

const selectedModel = process.env.MLX_BUN_TEST_FILL_MODEL;
if (selectedModel && !existsSync(`${selectedModel}/config.json`))
  throw new Error(`MLX_BUN_TEST_FILL_MODEL has no config.json: ${selectedModel}`);
const modelPath = selectedModel ?? SNAPSHOT_QWEN35_08B;
const haveWeights = selectedModel ? true : await snapshotQwen35_08bAvailable();

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
const MESSAGES = [{ role: "user", content: process.env.MLX_BUN_TEST_FILL_PROMPT ??
  "What is the weather in Paris right now?" }];
const thinking = process.env.MLX_BUN_TEST_FILL_THINKING;
if (thinking !== undefined && thinking !== "0" && thinking !== "1")
  throw new Error("MLX_BUN_TEST_FILL_THINKING must be 0 or 1");
const renderOptions = { tools: TOOLS,
  ...(thinking === undefined ? {} : { enableThinking: thinking === "1" }) };
const maxTokens = Number(process.env.MLX_BUN_TEST_FILL_TOKENS ?? "160");
if (!Number.isInteger(maxTokens) || maxTokens < 1 || maxTokens > 512)
  throw new Error("MLX_BUN_TEST_FILL_TOKENS must be 1..512");
const reportPath = process.env.MLX_BUN_TEST_FILL_REPORT;
const blocks = Number(process.env.MLX_BUN_TEST_FILL_BLOCKS ?? "6");
if (!Number.isInteger(blocks) || blocks < 1 || blocks > 12)
  throw new Error("MLX_BUN_TEST_FILL_BLOCKS must be 1..12");

describe.skipIf(!haveWeights)("strict fill rows on a real tokenizer + template", async () => {
  if (!haveWeights) return;
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { compileStrictFillRows } = await import("../../src/fill/schema-rows");

  const tokenizer = await loadTokenizer(modelPath);
  const template = await ChatTemplate.load(modelPath);

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
      { ...renderOptions, addGenerationPrompt: false },
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
      renderOptions,
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
      renderOptions,
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
  const { FillSession, fillMaxSpan } = await import("../../src/fill/fill-session");
  const { generate } = await import("../../src/generate");
  const ops = await import("../../src/mlx/ops");
  const { activeMemory, clearCache } = await import("../../src/mlx/ffi");

  const config = await loadModelConfig(modelPath);
  const weights = await Weights.open(modelPath);
  const model = createModel(weights, config);
  const tokenizer = await loadTokenizer(modelPath);
  const template = await ChatTemplate.load(modelPath);
  // Match loadRuntimeModel: packed text configs can omit the chat terminator.
  // Without the tokenizer EOS this test measures invented subsequent turns.
  if (tokenizer.eosTokenId != null && !config.eosTokenIds.includes(tokenizer.eosTokenId))
    config.eosTokenIds = [...config.eosTokenIds, tokenizer.eosTokenId];

  const promptIds = tokenizer.encode(
    template.render(MESSAGES, { ...renderOptions, addGenerationPrompt: true }));
  const { rows, delimiters, createContext } = compileStrictFillRows({
    template, tokenizer, messages: MESSAGES, tools: TOOLS,
    renderOptions,
  });

  // Compare live state, excluding unused capacity in the growing KV buffers.
  const snapshot = (cache: ReturnType<typeof model.makeCache>) => cache.map(c => ({
    offset: c.offset, signature: c.signature(), arrays: c.state().map(a => {
      const shape = a.shape;
      const live = c.signature() !== "ssm" && shape.length === 4 && c.offset < shape[2]!
        ? a.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, c.offset, shape[3]!]) : null;
      const value = ops.contiguous(live ?? a);
      try {
        return { shape: value.shape, dtype: value.dtype,
          sha256: createHash("sha256").update(value.rawBytesView()).digest("hex") };
      } finally { value.dispose(); live?.dispose(); }
    }),
  }));

  const run = async (fill: boolean, limit = maxTokens, inspectState = false) => {
    const start = performance.now();
    const restore = configureRuntime({ MLX_BUN_FILL: fill ? "strict" : undefined });
    const cache = inspectState ? model.makeCache() : undefined;
    try {
      const session = fill
        ? new FillSession(
          {
            rows, echo: null, delimiters: new Set(delimiters),
            eos: config.eosTokenIds,
          },
          promptIds,
          { strictContext: createContext?.(promptIds) },
        )
        : undefined;
      const gen = generate(model, promptIds, {
        temperature: 0, seed: 42, maxTokens: limit, cache,
        ...(session ? { fill: session } : {}),
      });
      const tokens: number[] = [];
      let firstTokenMs: number | undefined;
      for await (const t of gen) {
        firstTokenMs ??= performance.now() - start;
        tokens.push(t.token);
      }
      const wallMs = performance.now() - start;
      let state, probes;
      if (cache) {
        expect(cache.every(c => c.offset === gen.stats!.cacheTokens!.length)).toBe(true);
        state = snapshot(cache);
        probes = [];
        for (const token of [911, 912, 913, 914]) {
          const logits = model.forward([token], cache);
          try {
            ops.evalAll([logits, ...cache.flatMap(c => c.state())]);
            probes.push({ token, logits: createHash("sha256").update(logits.rawBytesView()).digest("hex"),
              state: snapshot(cache) });
          } finally { logits.dispose(); }
        }
      }
      return { tokens, stats: gen.stats!, firstTokenMs, wallMs, state, probes };
    } finally {
      if (cache) { for (const c of cache) c.dispose(); clearCache(); }
      restore();
    }
  };

  afterAll(async () => {
    weights.dispose();
    (await import("../../src/mlx/ffi")).clearCache();
  });

  test("committed appends preserve live state and continuation logits", async () => {
    const off = await run(false, maxTokens, true), offActive = activeMemory();
    const on = await run(true, maxTokens, true), onActive = activeMemory();
    expect(on.tokens).toEqual(off.tokens);
    expect(on.stats.cacheTokens).toEqual(off.stats.cacheTokens);
    expect(on.state).toEqual(off.state);
    expect(on.probes).toEqual(off.probes);
    expect(onActive).toBe(offActive);
    expect(on.stats.fill!.verifyEvents).toBe(0);
    if (!process.env.MLX_BUN_TEST_FILL_PROMPT)
      expect(on.stats.fill!.injected).toBeGreaterThan(0);
  }, 300_000);

  test("token-identical output, fewer forwards", async () => {
    expect(rows.length).toBeGreaterThan(0);
    if (reportPath) {
      const { checkMachine } = await import("../../src/preflight");
      const { peakMemory } = await import("../../src/mlx/ffi");
      const machineBefore = checkMachine();
      // Warm a complete answer so strict spans and their append shapes run.
      await run(false); await run(true);
      const trials = [];
      for (let block = 0; block < blocks; block++) {
        const reversed = process.env.MLX_BUN_TEST_FILL_REVERSE === "1";
        const order = Boolean(block % 2) !== reversed ? [true, false] : [false, true];
        const results = new Map<boolean, Awaited<ReturnType<typeof run>>>();
        for (const fill of order) results.set(fill, await run(fill));
        const baseline = results.get(false)!, candidate = results.get(true)!;
        trials.push({ block, order, tokenIdentity: JSON.stringify(baseline.tokens) ===
          JSON.stringify(candidate.tokens), baseline, candidate });
      }
      const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
      const command = (args: string[]) => Bun.spawnSync(args,
        { stdout: "pipe", stderr: "pipe" }).stdout.toString().trim();
      const report = { kind: "native-strict-fill-diagnostic", httpMeasurement: false,
        host: hostname(), chip: command(["sysctl", "-n", "machdep.cpu.brand_string"]),
        ramBytes: Number(command(["sysctl", "-n", "hw.memsize"])),
        artifact: resolve(modelPath), variant: process.env.MLX_BUN_TRELLIS_VARIANT ?? "6",
        configSha256: sha(await Bun.file(`${modelPath}/config.json`).bytes()),
        sourceCommit: command(["git", "rev-parse", "HEAD"]),
        sourceDiffSha256: sha(new TextEncoder().encode(command(["git", "diff", "HEAD", "--", "src"]))),
        kernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-shared-m.ts", import.meta.url)).bytes()),
        scatterKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-balanced-scatter.ts", import.meta.url)).bytes()),
        sharedScatterKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-shared-scatter.ts", import.meta.url)).bytes()),
        tiledPrefillKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-tiled-prefill.ts", import.meta.url)).bytes()),
        harnessSha256: sha(await Bun.file(import.meta.path).bytes()),
        machineBefore, machineAfter: checkMachine(), peakBytes: peakMemory(),
        messages: MESSAGES, tools: TOOLS, promptIds, rows, delimiters,
        maxTokens, temperature: 0, maxSpan: fillMaxSpan(), renderOptions,
        eosTokenIds: config.eosTokenIds,
        note: "Fresh request caches, one resident model, complete-answer warmup per arm. Wall time includes prefill, generation and cache cleanup. Assert skips verification but computes hidden states for injected tokens. A fixture match does not prove deterministic validity on arbitrary prompts.", trials };
      mkdirSync(dirname(resolve(reportPath)), { recursive: true });
      await Bun.write(reportPath, JSON.stringify(report, null, 2) + "\n");
      for (const trial of trials) {
        expect(trial.tokenIdentity).toBe(true);
        expect(trial.baseline.tokens.some((t) => config.eosTokenIds.includes(t))).toBe(false);
        expect(trial.candidate.tokens.some((t) => config.eosTokenIds.includes(t))).toBe(false);
        expect(trial.candidate.stats.fill!.verifyEvents).toBe(0);
        if (!process.env.MLX_BUN_TEST_FILL_PROMPT)
          expect(trial.candidate.stats.fill!.injected).toBeGreaterThan(0);
      }
      return;
    }
    const off = await run(false);
    const on = await run(true);
    expect(on.tokens).toEqual(off.tokens);
    // If this is 0 the prompt did not elicit a tool call — change the prompt
    // (or set tool_choice) rather than weakening the gate.
    expect(on.stats.fill!.injected).toBeGreaterThan(0);
    // Injected positions skip individual decode steps. The chunk append still
    // computes their hidden states and advances all attention/recurrent caches.
    expect(on.stats.fill!.decodeSteps + on.stats.fill!.injected)
      .toBeLessThanOrEqual(on.stats.generatedTokens);
    expect(on.stats.fill!.decodeSteps).toBeLessThan(off.stats.generatedTokens);
    console.log(`[strict-fill] ${JSON.stringify({ model: modelPath,
      generatedTokens: on.stats.generatedTokens, tokenIdentity: true,
      baselineGeneratedTokens: off.stats.generatedTokens, fill: on.stats.fill })}`);
  }, reportPath ? 600_000 : 300_000);
});
