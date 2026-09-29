// The reducer over a recorded event stream: every metric the module renders
// comes out of these events, and the same stream always gives the same snapshot.
import { expect, test } from "bun:test";
import { createMetricsStore } from "../src/store";
import { RECORDED } from "./support";

const replay = (events = RECORDED, options = {}) => {
  const store = createMetricsStore({ now: () => 9_000, ...options });
  for (const event of events) store.apply(event);
  return store;
};

test("a recorded stream renders load, unload and swap times, per-model memory and failures", () => {
  const { models } = replay().snapshot();
  expect(models.map(model => model.model)).toEqual(["org/chat", "org/other", "org/broken"]);
  expect(models[0]).toMatchObject({ state: "unloaded", loads: 1, unloads: 1, lastLoadMs: 900, lastUnloadMs: 500, lastUnloadReason: "evicted",
    weightsBytes: 400_000_000, kvBytes: 0, prefixCacheBytes: 0 });
  // The eviction and the load that followed are one swap: unload 500 ms plus load 600 ms, credited to the incoming model.
  expect(models[1]).toMatchObject({ state: "resident", loads: 1, lastLoadMs: 600, swaps: 1, lastSwapMs: 1_100, weightsBytes: 900_000_000 });
  expect(models[2]).toMatchObject({ state: "failed", loads: 0, lastError: "no weights" });
});

test("a load that does not follow an eviction is not a swap, and one long after it is not either", () => {
  const first = replay(RECORDED.slice(0, 2)).snapshot().models[0]!;
  expect(first).toMatchObject({ swaps: 0, lastSwapMs: null });
  const late = replay(RECORDED, { swapWithinMs: 50 }).snapshot().models.find(model => model.model === "org/other")!;
  expect(late).toMatchObject({ swaps: 0, lastSwapMs: null });
});

test("scheduler, caches and the throughput series reflect the latest samples", () => {
  const snapshot = replay(RECORDED.slice(0, 11)).snapshot();
  expect(snapshot.schedulers).toEqual([{ model: "org/chat", at: 3_000, active: 3, capacity: 4, queued: 2, tokensPerSecond: 512 }]);
  expect(snapshot.caches).toEqual([{ model: "org/chat",
    kv: { at: 3_000, bytes: 30_000_000, capacityBytes: 1_000_000_000 },
    prefix: { at: 3_000, bytes: 5_000_000, capacityBytes: 8_000_000_000, hits: 3, misses: 1, hitRate: 0.75 } }]);
  expect(snapshot.series).toEqual([{ at: 2_000, tokensPerSecond: 0, active: 0, queued: 0 }, { at: 3_000, tokensPerSecond: 512, active: 3, queued: 2 }]);
  expect(snapshot.models[0]).toMatchObject({ kvBytes: 30_000_000, prefixCacheBytes: 5_000_000 });
  // The model leaving drops what only a resident model has.
  expect(replay().snapshot().schedulers).toEqual([]);
});

test("request timings are distributions over the finished requests that reported them", () => {
  const { requests } = replay().snapshot();
  expect(requests).toMatchObject({ finished: 3, byFinish: { stop: 1, length: 1, cancelled: 1, error: 0 } });
  expect(requests.recent.map(request => request.requestId)).toEqual(["req-1", "req-2", "req-3"]);
  expect(requests.window.count).toBe(3);
  expect(requests.window.queueMs).toEqual({ count: 3, mean: 20.666666666666668, p50: 10, p95: 50, max: 50 });
  // The cancelled request never produced a token, so it is absent from the token-rate and TTFT distributions.
  expect(requests.window.ttftMs).toMatchObject({ count: 2, p50: 40, max: 120 });
  expect(requests.window.decodeTokensPerSecond).toMatchObject({ count: 2, p50: 190, max: 210 });
  expect(requests.window.prefillTokensPerSecond).toMatchObject({ count: 2, max: 1_000 });
  expect(requests.window.totalMs).toMatchObject({ count: 3, p50: 320, max: 400 });
  expect(requests.window.cachedPromptShare).toBeCloseTo(100 / 300, 10);
});

test("the windows are bounded: old requests leave the distributions, old samples leave the series, and totals keep counting", () => {
  const store = createMetricsStore({ window: 2, recent: 1, series: 2, now: () => 0 });
  for (let index = 0; index < 5; index++) {
    store.apply({ type: "request.finished", at: index, model: "m", requestId: `r${index}`, finish: "stop", promptTokens: 1, cachedPromptTokens: 0, completionTokens: 1,
      queueMs: index, ttftMs: index, prefillTokensPerSecond: 1, decodeTokensPerSecond: 1, totalMs: index });
    store.apply({ type: "scheduler.sample", at: index, model: "m", active: 1, capacity: 1, queued: 0, tokensPerSecond: index });
  }
  const snapshot = store.snapshot();
  expect(snapshot.requests.finished).toBe(5);
  expect(snapshot.requests.window.queueMs).toMatchObject({ count: 2, p50: 3, max: 4 });
  expect(snapshot.requests.recent.map(request => request.requestId)).toEqual(["r4"]);
  expect(snapshot.series.map(point => point.at)).toEqual([3, 4]);
});

test("samples of two models in one tick add into one series point", () => {
  const store = createMetricsStore({ now: () => 0 });
  store.apply({ type: "scheduler.sample", at: 10, model: "a", active: 1, capacity: 2, queued: 0, tokensPerSecond: 100 });
  store.apply({ type: "scheduler.sample", at: 10, model: "b", active: 2, capacity: 2, queued: 1, tokensPerSecond: 50 });
  expect(store.snapshot().series).toEqual([{ at: 10, tokensPerSecond: 150, active: 3, queued: 1 }]);
  expect(store.snapshot().schedulers.map(sample => sample.model)).toEqual(["a", "b"]);
});

test("the version moves only when an event changed the snapshot; other events are not this store's", () => {
  const store = createMetricsStore({ now: () => 0 });
  store.apply({ type: "catalog.changed", at: 1 });
  store.apply({ type: "job.state", at: 1, jobId: "j", kind: "k", status: "running" });
  store.apply({ type: "transcription.finished", at: 1, data: {} });
  expect(store.version).toBe(0);
  store.apply(RECORDED[0]!);
  expect(store.version).toBe(1);
});

test("replaying the same stream twice gives the same snapshot", () => {
  expect(replay().snapshot()).toEqual(replay().snapshot());
});
