const execution = { method: "autoregressive", mechanism: "continuous" as const, promptCache: true, checkpoint: true, fill: false, compiledDecode: false, grammarJump: false, reasons: [] };
import { describe, expect, test } from "bun:test";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "@mlx-bun/inference/generation";
import {
  CompletionExecutor,
  CompletionRejected,
  prepareCompletion,
  type CompletionEngine,
  type CompletionPlacement,
  type CompletionUsage,
} from "../../src/server/completion-executor";
import {
  type CompletionEvent,
  type TextStopper,
  type ThinkingSplitter,
  type TokenTextRouter,
} from "../../src/server/completion-sink";
import { RequestOwnership } from "../../src/server/request-plan";
import {
  PromptResponseTrace,
  type P2RTraceRecord,
} from "@mlx-bun/inference/runtime/trace";

class ScriptedEngine implements CompletionEngine {
  readonly seenOptions: GenerateOptions[] = [];

  place(shape: Parameters<CompletionEngine["place"]>[0]) {
    return Object.freeze({ shape, mechanism: "continuous" as const, execution });
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
        return Object.freeze({ shape, mechanism: "continuous" as const, execution });
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
        requestedMaxTokens: 1, contextLimit: 16, stream: true,
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
      "response.token_route",
    ]);
  });

  test("runs one prepared completion and reports semantic output and usage", async () => {
    const engine = new ScriptedEngine();
    const executor = new CompletionExecutor(engine);
    const events: CompletionEvent[] = [];
    let usageProgress: Readonly<CompletionUsage> | undefined;
    let observedPlacement: CompletionPlacement | undefined;
    const ownership = new RequestOwnership();
    const logitBias: Record<number, number> = { 5: -100 };

    const prepared = prepareCompletion({
      requestId: "chatcmpl-test",
      plan: {
        promptIds: [7, 8, 9],
        options: {
          maxTokens: 8,
          temperature: 0.25,
          stopSequences: [],
          logitBias,
        },
        requestedMaxTokens: 8,
        contextLimit: 32,
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
      lane: "batched",
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
        logitBias,
      }),
    ]);
    expect(engine.seenOptions[0]!.logitBias).toEqual(logitBias);
    expect(engine.seenOptions[0]!.logitBias).not.toBe(logitBias);
    expect(observedPlacement).toMatchObject({
      mechanism: "continuous",
      lane: "batched",
    });
  });

  for (const phase of ["execute", "preflight", "preflight-cleanup-failure"]) test(`releases rejected placement resources during ${phase}`, async () => {
    let disposals = 0;
    const failure = new Error("placement failed"), cleanup = new Error("cleanup failed");
    const ownership = new RequestOwnership();
    ownership.own({ dispose: () => { disposals++; if (phase === "preflight-cleanup-failure") throw cleanup; } });
    const engine: CompletionEngine = {
      place() {
        throw failure;
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
        contextLimit: 2,
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

    const executor = new CompletionExecutor(engine);
    if (phase === "execute") await expect(executor.execute(prepared)).rejects.toBe(failure);
    else {
      let caught: unknown;
      try { executor.place(prepared); } catch (error) { caught = error; }
      if (phase === "preflight-cleanup-failure") {
        expect(caught).toBeInstanceOf(AggregateError);
        expect((caught as AggregateError).errors).toEqual([failure, cleanup]);
      } else expect(caught).toBe(failure);
      await expect(executor.execute(prepared)).rejects.toThrow("already been executed");
    }
    expect(disposals).toBe(1);
  });

  test("refuses a placement created for a different request shape", async () => {
    let disposals = 0;
    let generationStarts = 0;
    const ownership = new RequestOwnership();
    ownership.own({ dispose: () => { disposals++; } });
    const engine: CompletionEngine = {
      place(shape) {
        return Object.freeze({ shape: { ...shape }, mechanism: "continuous" as const, execution });
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
        contextLimit: 2,
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
        contextLimit: 2,
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
        contextLimit: 16,
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
        return Object.freeze({ shape, mechanism: "continuous" as const, execution });
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
        contextLimit: 16,
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
        return Object.freeze({ shape, mechanism: "continuous" as const, execution });
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
        contextLimit: 16,
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

for (const stream of [false, true]) for (const terminal of ["stop", undefined] as const) {
  test(`completion ${stream ? "stream" : "collection"} preserves ${terminal ?? "legacy budget"} termination`, async () => {
    const runtime: CompletionEngine = {
      place: (shape) => ({ shape, mechanism: "continuous", execution }),
      async run(_prompt, _options, onToken) {
        await onToken(1);
        if (!terminal) await onToken(2);
        return {
          promptTokens: 1, cachedTokens: 0, generatedTokens: 2,
          finishReason: terminal, prefillTps: 0, decodeTps: 0,
          prefillMs: 0, decodeMs: 0, cacheTokens: [],
        };
      },
    };
    const prepared = prepareCompletion({
      requestId: `eos-${stream}-${terminal}`,
      plan: {
        promptIds: [7], options: { maxTokens: 2, stopSequences: [] },
        requestedMaxTokens: 2, contextLimit: 16, stream,
        wantLogprobs: false, topLogprobs: 0, adapterIds: [],
        hasVision: false, userSeed: false, hasGrammar: false, hasDraft: false,
        ownership: new RequestOwnership(),
      },
      pipeline: { router, stopper, thinking, collectToolCalls: false },
      idToToken: String,
    });
    const result = await new CompletionExecutor(runtime).execute(prepared);
    expect(result.finishReason).toBe(terminal ?? "length");
    expect(result.usage.completionTokens).toBe(2);
    expect(result.content).toBe(terminal ? "hello " : "hello world");
  });
}

describe("tool-call review", () => {
  const call = (id: string, name: string) => ({ id, type: "function" as const, function: { name, arguments: "{}" } });
  const calls = [call("a", "keep_one"), call("b", "drop"), call("c", "keep_two")];
  const run = async (stream: boolean, reviewToolCalls?: Parameters<typeof prepareCompletion>[0]["reviewToolCalls"], signal?: AbortSignal) => {
    const events: CompletionEvent[] = [];
    const prepared = prepareCompletion({
      requestId: "chatcmpl-review",
      plan: {
        promptIds: [7], options: { maxTokens: 8, stopSequences: [] }, requestedMaxTokens: 8, contextLimit: 16, stream,
        wantLogprobs: false, topLogprobs: 0, adapterIds: [], hasVision: false, userSeed: false, hasGrammar: false, hasDraft: false,
        ownership: new RequestOwnership(),
      },
      pipeline: { router: { ...router, toolCalls: () => calls }, stopper, thinking, collectToolCalls: true },
      ...(reviewToolCalls ? { reviewToolCalls } : {}),
      idToToken: String,
    });
    const summary = await new CompletionExecutor(new ScriptedEngine()).execute(prepared, {
      ...(signal ? { signal } : {}), onEvents: (batch) => { events.push(...batch); } });
    return { summary, events };
  };

  for (const stream of [false, true]) {
    test(`without a reviewer the calls are delivered as generated (${stream ? "stream" : "collection"})`, async () => {
      const { summary, events } = await run(stream);
      expect(summary.toolCalls).toEqual(calls);
      expect(summary.finishReason).toBe("tool_calls");
      expect(summary.content).toBe("hello world");
      expect(events.at(-1)).toEqual({ type: "tool_calls", calls });
    });

    test(`a reviewer that keeps every call changes nothing (${stream ? "stream" : "collection"})`, async () => {
      const plain = await run(stream);
      const reviewed = await run(stream, async (pending) => ({ kept: [...pending], notices: [] }));
      expect(reviewed).toEqual(plain);
    });

    test(`blocked calls are replaced by a notice before the remaining calls are delivered (${stream ? "stream" : "collection"})`, async () => {
      const seen: unknown[] = [];
      const { summary, events } = await run(stream, async (pending) => {
        seen.push(pending);
        return { kept: pending.filter((item) => item.function.name !== "drop"), notices: ["[blocked drop]"] };
      });
      expect(seen).toEqual([calls]);
      expect(summary.toolCalls).toEqual([calls[0]!, calls[2]!]);
      expect(summary.content).toBe("hello world\n[blocked drop]");
      expect(summary.finishReason).toBe("tool_calls");
      expect(events.slice(-2)).toEqual([
        { type: "content", text: "\n[blocked drop]" },
        { type: "tool_calls", calls: [calls[0]!, calls[2]!] },
      ]);
      expect(events.filter((event) => event.type === "tool_calls")).toHaveLength(1);
    });

    test(`with every call blocked no tool-call event is delivered and the turn ends as text (${stream ? "stream" : "collection"})`, async () => {
      const { summary, events } = await run(stream, async () => ({ kept: [], notices: ["[one]", "[two]"] }));
      expect(summary.toolCalls).toEqual([]);
      expect(summary.finishReason).toBe("stop");
      expect(summary.content).toBe("hello world\n[one]\n[two]");
      expect(events.some((event) => event.type === "tool_calls")).toBe(false);
    });

    test(`a reviewer that fails or is cancelled delivers no tool call (${stream ? "stream" : "collection"})`, async () => {
      const abort = new AbortController();
      const cancelled = run(stream, async (pending, signal) => {
        abort.abort(new Error("client left"));
        signal!.throwIfAborted();
        return { kept: [...pending], notices: [] };
      }, abort.signal);
      await expect(cancelled).rejects.toThrow("client left");
      await expect(run(stream, async () => { throw new Error("reviewer bug"); })).rejects.toThrow("reviewer bug");
    });
  }
});
