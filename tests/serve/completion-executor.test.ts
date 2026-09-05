import { describe, expect, test } from "bun:test";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "../../src/generate";
import {
  CompletionExecutor,
  CompletionRejected,
  prepareCompletion,
  type CompletionEngine,
  type CompletionPlacement,
  type CompletionUsage,
} from "../../src/serve/completion-executor";
import {
  type CompletionEvent,
  type TextStopper,
  type ThinkingSplitter,
  type TokenTextRouter,
} from "../../src/serve/completion-sink";
import { clearLaneRegistry, getLane } from "../../src/serve/lane-registry";
import { RequestOwnership } from "../../src/serve/request-plan";
import {
  PromptResponseTrace,
  type P2RTraceRecord,
} from "../../src/serve/prompt-response-trace";

class ScriptedEngine implements CompletionEngine {
  readonly seenOptions: GenerateOptions[] = [];

  place(shape: Parameters<CompletionEngine["place"]>[0]) {
    return Object.freeze({ shape, mechanism: "serial" as const });
  }

  async run(
    _promptIds: number[],
    options: GenerateOptions,
    onToken: (
      token: number,
      info?: TokenLogprobs,
    ) => void | boolean | Promise<void | boolean>,
  ): Promise<GenerateStats> {
    this.seenOptions.push(options);
    for (const token of [1, 2]) {
      const control = await onToken(token, { logprob: -token });
      if (control === false) break;
    }
    return {
      promptTokens: 3,
      cachedTokens: 1,
      generatedTokens: 2,
      prefillTps: 10,
      decodeTps: 20,
      prefillMs: 30,
      decodeMs: 40,
      cacheTokens: [7, 8, 9, 1, 2],
    };
  }
}

const router: TokenTextRouter = {
  push: (token) => token === 1 ? "hello " : "world",
  flush: () => "",
  takeReasoning: () => "",
  toolCalls: () => [],
};

const stopper: TextStopper = {
  stopped: false,
  push: (text) => text,
  flush: () => "",
};

const thinking: ThinkingSplitter = {
  push: (text) => ({ content: text, reasoning: "" }),
  flush: () => ({ content: "", reasoning: "" }),
};

describe("CompletionExecutor", () => {
  test("threads one request trace through placement and engine run", async () => {
    let seenTrace: PromptResponseTrace | undefined;
    const engine: CompletionEngine = {
      place(shape) {
        return Object.freeze({ shape, mechanism: "serial" as const });
      },
      async run(...args: Parameters<CompletionEngine["run"]>) {
        seenTrace = args[7];
        await args[2](1);
        return {
          promptTokens: 1, cachedTokens: 0, generatedTokens: 1,
          prefillTps: 1, decodeTps: 1, prefillMs: 1, decodeMs: 1,
          cacheTokens: [7],
        };
      },
    };
    const prepared = prepareCompletion({
      requestId: "chatcmpl-traced",
      plan: {
        promptIds: [7], options: { maxTokens: 1, stopSequences: [] },
        requestedMaxTokens: 1, maxSafeContext: 16, stream: true,
        wantLogprobs: false, topLogprobs: 0, adapterIds: [],
        hasVision: false, userSeed: false, hasGrammar: false, hasDraft: false,
        ownership: new RequestOwnership(),
      },
      pipeline: { router, stopper, thinking, collectToolCalls: false },
      idToToken: String,
    });
    const records: P2RTraceRecord[] = [];
    const trace = new PromptResponseTrace({
      traceId: "trace-executor",
      requestId: "chatcmpl-traced",
      route: "/v1/chat/completions",
      emit: (record) => records.push(record),
    });

    await new CompletionExecutor(engine).execute(prepared, { trace });
    trace.finish("success");

    expect(seenTrace).toBe(trace);
    expect(records[0]!.events.map((event) => event.phase)).toEqual([
      "completion.total",
      "completion.placement",
    ]);
  });

  test("runs one prepared completion and reports semantic output and usage", async () => {
    clearLaneRegistry();
    const engine = new ScriptedEngine();
    const executor = new CompletionExecutor(engine);
    const events: CompletionEvent[] = [];
    let usageProgress: Readonly<CompletionUsage> | undefined;
    let observedPlacement: CompletionPlacement | undefined;
    const ownership = new RequestOwnership();
    const kvConfig = [{ layerIdx: 0, bits: 4, groupSize: 64 }];

    const prepared = prepareCompletion({
      requestId: "chatcmpl-test",
      plan: {
        promptIds: [7, 8, 9],
        options: {
          maxTokens: 8,
          temperature: 0.25,
          stopSequences: [],
          kvConfig,
          quantizedKvStart: 0,
        },
        requestedMaxTokens: 8,
        maxSafeContext: 32,
        stream: true,
        wantLogprobs: false,
        topLogprobs: 0,
        adapterIds: ["careful-adapter"],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership,
      },
      pipeline: {
        router,
        stopper,
        thinking,
        collectToolCalls: false,
      },
      onPlacement(placement) {
        observedPlacement = placement;
      },
      idToToken: (id) => String(id),
    });

    const summary = await executor.execute(prepared, {
      onEvents(batch) {
        events.push(...batch);
      },
      onUsageProgress(usage) {
        usageProgress = usage;
      },
    });

    expect(events).toEqual([
      { type: "content", text: "hello " },
      { type: "content", text: "world" },
    ]);
    expect(summary).toMatchObject({
      content: "hello world",
      reasoning: "",
      toolCalls: [],
      stopped: false,
      finishReason: "stop",
      lane: "serial",
      usage: {
        promptTokens: 3,
        cachedTokens: 1,
        completionTokens: 2,
        totalTokens: 5,
      },
    });
    expect(usageProgress).toEqual({
      promptTokens: 3,
      cachedTokens: 1,
      completionTokens: 2,
      totalTokens: 5,
    });
    expect(engine.seenOptions).toEqual([
      expect.objectContaining({
        maxTokens: 8,
        temperature: 0.25,
        adapters: ["careful-adapter"],
        quantizedKvStart: 0,
      }),
    ]);
    expect(engine.seenOptions[0]!.kvConfig).toEqual(kvConfig);
    expect(engine.seenOptions[0]!.kvConfig).not.toBe(kvConfig);
    expect(observedPlacement).toMatchObject({
      mechanism: "serial",
      lane: "serial",
    });
    expect(getLane("chatcmpl-test")).toBe("serial");
  });

  test("releases prepared resources when placement fails before generation", async () => {
    let disposals = 0;
    const ownership = new RequestOwnership();
    ownership.own({ dispose: () => { disposals++; } });
    const engine: CompletionEngine = {
      place() {
        throw new Error("placement failed");
      },
      run() {
        throw new Error("generation must not start");
      },
    };
    const prepared = prepareCompletion({
      requestId: "chatcmpl-placement-failure",
      plan: {
        promptIds: [1],
        options: { maxTokens: 1, stopSequences: [] },
        requestedMaxTokens: 1,
        maxSafeContext: 2,
        stream: false,
        wantLogprobs: false,
        topLogprobs: 0,
        adapterIds: [],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership,
      },
      pipeline: {
        router,
        stopper,
        thinking,
        collectToolCalls: false,
      },
      idToToken: String,
    });

    await expect(new CompletionExecutor(engine).execute(prepared))
      .rejects.toThrow("placement failed");
    expect(disposals).toBe(1);
  });

  test("refuses a placement created for a different request shape", async () => {
    let disposals = 0;
    let generationStarts = 0;
    const ownership = new RequestOwnership();
    ownership.own({ dispose: () => { disposals++; } });
    const engine: CompletionEngine = {
      place(shape) {
        return Object.freeze({ shape: { ...shape }, mechanism: "serial" as const });
      },
      run() {
        generationStarts++;
        throw new Error("generation must not start");
      },
    };
    const prepared = prepareCompletion({
      requestId: "chatcmpl-stale-placement",
      plan: {
        promptIds: [1],
        options: { maxTokens: 1, stopSequences: [] },
        requestedMaxTokens: 1,
        maxSafeContext: 2,
        stream: false,
        wantLogprobs: false,
        topLogprobs: 0,
        adapterIds: [],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership,
      },
      pipeline: { router, stopper, thinking, collectToolCalls: false },
      idToToken: String,
    });

    await expect(new CompletionExecutor(engine).execute(prepared))
      .rejects.toThrow("generation placement does not belong");
    expect(generationStarts).toBe(0);
    expect(disposals).toBe(1);
  });

  test("rejects over-budget preparation before a stream can start", () => {
    let disposals = 0;
    const ownership = new RequestOwnership();
    ownership.own({ dispose: () => { disposals++; } });

    expect(() => prepareCompletion({
      requestId: "chatcmpl-rejected",
      plan: {
        promptIds: [1, 2],
        options: { maxTokens: 4, stopSequences: [] },
        requestedMaxTokens: 4,
        maxSafeContext: 2,
        stream: true,
        wantLogprobs: false,
        topLogprobs: 0,
        adapterIds: [],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership,
      },
      pipeline: { router, stopper, thinking, collectToolCalls: false },
      idToToken: String,
    })).toThrow(CompletionRejected);
    expect(disposals).toBe(1);
  });

  test("collects non-stream logprobs across every generated token", async () => {
    const engine = new ScriptedEngine();
    const prepared = prepareCompletion({
      requestId: "chatcmpl-logprobs",
      plan: {
        promptIds: [7],
        options: { maxTokens: 4, stopSequences: [] },
        requestedMaxTokens: 4,
        maxSafeContext: 16,
        stream: false,
        wantLogprobs: true,
        topLogprobs: 0,
        adapterIds: [],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership: new RequestOwnership(),
      },
      pipeline: {
        router,
        stopper,
        thinking,
        collectToolCalls: false,
      },
      idToToken: String,
    });

    const summary = await new CompletionExecutor(engine).execute(prepared);

    expect(summary.logprobs).toEqual({
      content: [
        { id: 1, logprob: -1 },
        { id: 2, logprob: -2 },
      ],
    });
    expect(engine.seenOptions[0]).toMatchObject({ logprobs: true, topLogprobs: 0 });
  });

  test("lets a semantic event consumer stop generation", async () => {
    const engine: CompletionEngine = {
      place(shape) {
        return Object.freeze({ shape, mechanism: "serial" as const });
      },
      async run(_ids, _options, onToken) {
        let generatedTokens = 0;
        for (const token of [1, 2]) {
          generatedTokens++;
          if (await onToken(token) === false) break;
        }
        return {
          promptTokens: 1,
          cachedTokens: 0,
          generatedTokens,
          prefillTps: 0,
          decodeTps: 0,
          prefillMs: 0,
          decodeMs: 0,
          cacheTokens: [],
        };
      },
    };
    const prepared = prepareCompletion({
      requestId: "chatcmpl-consumer-stop",
      plan: {
        promptIds: [7],
        options: { maxTokens: 4, stopSequences: [] },
        requestedMaxTokens: 4,
        maxSafeContext: 16,
        stream: true,
        wantLogprobs: false,
        topLogprobs: 0,
        adapterIds: [],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership: new RequestOwnership(),
      },
      pipeline: { router, stopper, thinking, collectToolCalls: false },
      idToToken: String,
    });

    const events: CompletionEvent[] = [];
    const summary = await new CompletionExecutor(engine).execute(prepared, {
      onEvents(batch) {
        events.push(...batch);
        return false;
      },
    });

    expect(events).toEqual([{ type: "content", text: "hello " }]);
    expect(summary.content).toBe("hello ");
    expect(summary.usage.completionTokens).toBe(1);
  });

  test("reports accumulated usage before propagating a mid-stream failure", async () => {
    const engine: CompletionEngine = {
      place(shape) {
        return Object.freeze({ shape, mechanism: "serial" as const });
      },
      async run(_ids, _options, onToken) {
        await onToken(1);
        throw new Error("mid-stream failure");
      },
    };
    const prepared = prepareCompletion({
      requestId: "chatcmpl-usage-on-error",
      plan: {
        promptIds: [7, 8, 9],
        options: { maxTokens: 4, stopSequences: [] },
        requestedMaxTokens: 4,
        maxSafeContext: 16,
        stream: true,
        wantLogprobs: false,
        topLogprobs: 0,
        adapterIds: [],
        hasVision: false,
        userSeed: false,
        hasGrammar: false,
        hasDraft: false,
        ownership: new RequestOwnership(),
      },
      pipeline: { router, stopper, thinking, collectToolCalls: false },
      idToToken: String,
    });
    let usageProgress: Readonly<CompletionUsage> | undefined;

    await expect(new CompletionExecutor(engine).execute(prepared, {
      onUsageProgress: (usage) => { usageProgress = usage; },
    })).rejects.toThrow("mid-stream failure");

    expect(usageProgress).toEqual({
      promptTokens: 3,
      cachedTokens: 0,
      completionTokens: 1,
      totalTokens: 4,
    });
  });
});
