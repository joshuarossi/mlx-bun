// The engine's event adapter: one observed `run` publishes one finished
// request with the timings the run itself measured, samples publish the
// gateway's and caches' readings, and the wrapper changes nothing a request
// sees (tokens, stats, errors) or waits on the bus.
import { expect, test } from "bun:test";
import type { AppEvent, CoreEvent, EventOf } from "@mlx-bun/app-core";
import type { GenerateStats } from "@mlx-bun/inference/generation";
import type { CompletionEngine } from "../../src/engine/completion";
import { createEngineTelemetry } from "../../src/engine/telemetry";

const stats = (over: Partial<GenerateStats> = {}): GenerateStats => ({ promptTokens: 12, cachedTokens: 4, generatedTokens: 5, finishReason: "stop", prefillMs: 20,
  decodeMs: 40, prefillTps: 400, decodeTps: 100, cacheTokens: [], ...over });

function setup(run: CompletionEngine["run"], input: { publish?: (event: AppEvent) => void } = {}) {
  const published: CoreEvent[] = [], clock = { ms: 0 }, wall = { at: 1_000 };
  const gateway = { activeRows: 0, kvBytes: { projected: 0, budget: null as number | null } };
  const promptCache = { totalBytes: 0, maxBytes: 8e9, hits: 0, misses: 0 };
  const intervals: (() => void)[] = [];
  const engine: CompletionEngine & { marker: string } = { marker: "kept", place: () => { throw new Error("unused"); }, run };
  const telemetry = createEngineTelemetry({ events: { publish: input.publish ?? (event => { published.push(event as CoreEvent); }) }, model: "org/model", capacity: 4,
    weightsBytes: 700, gateway, promptCache, now: () => wall.at, performanceNow: () => clock.ms,
    timers: { setInterval: run => { intervals.push(run); return intervals.length; }, clearInterval: () => { intervals.length = 0; } } });
  const observed = telemetry.observe(engine);
  const call = (signal?: AbortSignal, onToken: (token: number) => unknown = () => {}) =>
    observed.run([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], {}, onToken as never, undefined, {} as never, {} as never, signal);
  return { published, clock, wall, gateway, promptCache, intervals, telemetry, observed, engine, call };
}
const only = <T extends CoreEvent["type"]>(events: CoreEvent[], type: T) => events.filter((event): event is EventOf<T> => event.type === type);

test("a finished request publishes its arrival-to-token, queue, prefill and decode figures from the run's own stats", async () => {
  const seen: number[] = [];
  const context = setup(async (_prompt, _options, onToken) => {
    context.clock.ms += 70;              // waited for admission (50) and prefilled (20)
    await onToken(7); await onToken(8);
    context.clock.ms += 40;
    return stats();
  });
  context.wall.at = 5_000;
  const result = await context.call(undefined, token => { seen.push(token); });
  expect(seen).toEqual([7, 8]);
  expect(result).toEqual(stats());
  expect(context.published).toEqual([{ type: "request.finished", at: 5_000, model: "org/model", requestId: "req-1", finish: "stop",
    promptTokens: 12, cachedPromptTokens: 4, completionTokens: 5, queueMs: 50, ttftMs: 70, prefillTokensPerSecond: 400, decodeTokensPerSecond: 100, totalMs: 110 }]);
});

test("a length stop, a request that produced no token, a cancelled run and a failed run each finish once with what is known", async () => {
  let script: () => Promise<GenerateStats>;
  const context = setup(async () => script());
  script = async () => stats({ finishReason: "length", prefillTps: 0, decodeTps: 0, generatedTokens: 1 });
  await context.call();
  expect(only(context.published, "request.finished")[0]).toMatchObject({ finish: "length", prefillTokensPerSecond: null, decodeTokensPerSecond: null, ttftMs: null, queueMs: null });

  const abort = new AbortController();
  script = async () => { context.clock.ms += 30; abort.abort(); throw new DOMException("cancelled", "AbortError"); };
  await expect(context.call(abort.signal)).rejects.toThrow("cancelled");
  script = async () => { throw new Error("native failure"); };
  await expect(context.call()).rejects.toThrow("native failure");
  const finished = only(context.published, "request.finished");
  expect(finished.map(event => [event.requestId, event.finish, event.completionTokens])).toEqual([["req-1", "length", 1], ["req-2", "cancelled", 0], ["req-3", "error", 0]]);
  expect(finished[1]).toMatchObject({ totalMs: 30, ttftMs: null, queueMs: null });
});

test("the wrapper passes everything else through and returns what the engine returned", async () => {
  const context = setup(async () => stats());
  expect(context.observed.marker).toBe("kept");
  expect(context.observed.place).toBe(context.engine.place);
  expect(await context.call()).toEqual(stats());
});

test("a bus that throws or never delivers cannot reach a request", async () => {
  const context = setup(async () => stats(), { publish() { throw new Error("bus down"); } });
  expect(await context.call()).toEqual(stats());
  context.telemetry.sample();
});

test("a sample reports rows, the queue, tokens per second, both caches and the model's memory, then goes quiet while idle and unchanged", async () => {
  const gate = Promise.withResolvers<void>();
  const context = setup(async (_prompt, _options, onToken) => { await onToken(1); await onToken(2); await onToken(3); await gate.promise; return stats(); });
  context.gateway.activeRows = 1; context.gateway.kvBytes = { projected: 250, budget: 1_000 };
  context.promptCache.totalBytes = 300; context.promptCache.hits = 3; context.promptCache.misses = 1;
  const first = context.call(), second = context.call();
  await Bun.sleep(0);
  context.clock.ms = 500; context.wall.at = 2_000;
  context.telemetry.sample();
  expect(context.published.map(event => event.type)).toEqual(["scheduler.sample", "cache.sample", "cache.sample", "model.memory"]);
  expect(context.published).toEqual([
    // Two requests are in flight and one row decodes, so one waits; six tokens over half a second.
    { type: "scheduler.sample", at: 2_000, model: "org/model", active: 1, capacity: 4, queued: 1, tokensPerSecond: 12 },
    { type: "cache.sample", at: 2_000, model: "org/model", cache: "kv", bytes: 250, capacityBytes: 1_000, hits: null, misses: null },
    { type: "cache.sample", at: 2_000, model: "org/model", cache: "prefix", bytes: 300, capacityBytes: 8e9, hits: 3, misses: 1 },
    { type: "model.memory", at: 2_000, model: "org/model", weightsBytes: 700, kvBytes: 250, prefixCacheBytes: 300 }]);
  gate.resolve(); await first; await second;
  context.gateway.activeRows = 0;
  context.published.length = 0;
  context.intervals[0]!();                          // the finish changed the counters' picture: one more sample
  expect(context.published.length).toBe(4);
  context.published.length = 0;
  context.intervals[0]!(); context.intervals[0]!();
  expect(context.published).toEqual([]);
  context.telemetry.sample();                       // an explicit sample is never suppressed
  expect(context.published.length).toBe(4);
});

test("the interval samples until stopped, and stop is idempotent", () => {
  const context = setup(async () => stats());
  expect(context.intervals).toHaveLength(1);
  context.gateway.activeRows = 2;
  context.intervals[0]!();
  expect(context.published.length).toBe(4);
  context.telemetry.stop(); context.telemetry.stop();
  expect(context.intervals).toHaveLength(0);
});
