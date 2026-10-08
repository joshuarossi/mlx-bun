// Reduces the event stream into the module's snapshot. Pure: no clock but the
// events' own `at` (and `now` for the snapshot's stamp), no I/O, so a recorded
// stream renders the same snapshot every time.
import type { AppEvent, CoreEvent, CoreEventType } from "@mlx-bun/app-core";
import type {
  CacheMetrics, Distribution, MetricsSnapshot, ModelMetrics, RequestMetrics, RequestWindow, SchedulerMetrics, SeriesPoint,
} from "./protocol";

export interface MetricsStoreOptions {
  /** Finished requests the distributions cover. Default 200. */
  window?: number;
  /** Finished requests `recent` lists. Default 20. */
  recent?: number;
  /** Scheduler samples kept for the throughput chart. Default 120. */
  series?: number;
  /** Stamps snapshots; default `Date.now`. */
  now?: () => number;
  /** An evicting unload and the load that follows it form one swap when the load finishes within this many ms. Default 120 000. */
  swapWithinMs?: number;
}

export interface MetricsStore {
  apply(event: AppEvent): void;
  snapshot(): MetricsSnapshot;
  /** Counts `apply` calls that changed the snapshot; a stream sends when it moves. */
  readonly version: number;
}

const CORE_TYPES: ReadonlySet<string> = new Set<CoreEventType>([
  "model.load", "model.unload", "model.memory", "request.finished", "scheduler.sample", "cache.sample", "catalog.changed", "job.state",
]);

function distribution(values: readonly number[]): Distribution | null {
  if (!values.length) return null;
  const sorted = values.toSorted((a, b) => a - b);
  const at = (fraction: number) => sorted[Math.min(sorted.length - 1, Math.max(0, Math.ceil(fraction * sorted.length) - 1))]!;
  return { count: sorted.length, mean: sorted.reduce((sum, value) => sum + value, 0) / sorted.length, p50: at(0.5), p95: at(0.95), max: sorted.at(-1)! };
}

const present = (values: readonly (number | null)[]) => values.filter((value): value is number => value !== null && Number.isFinite(value));

interface ModelState {
  state: ModelMetrics["state"]; loads: number; unloads: number; lastLoadMs: number | null; lastUnloadMs: number | null;
  lastUnloadReason: string | null; lastSwapMs: number | null; swaps: number;
  weightsBytes: number; kvBytes: number; prefixCacheBytes: number; lastError: string | null;
}

export function createMetricsStore(options: MetricsStoreOptions = {}): MetricsStore {
  const windowSize = Math.max(1, options.window ?? 200), recentSize = Math.max(1, options.recent ?? 20), seriesSize = Math.max(1, options.series ?? 120);
  const now = options.now ?? Date.now, swapWithin = options.swapWithinMs ?? 120_000;
  const startedAt = now();
  const models = new Map<string, ModelState>();
  const schedulers = new Map<string, SchedulerMetrics>();
  const caches = new Map<string, { kv: CacheMetrics["kv"]; prefix: CacheMetrics["prefix"] }>();
  const requests: RequestMetrics[] = [];
  const byFinish: Record<RequestMetrics["finish"], number> = { stop: 0, length: 0, cancelled: 0, error: 0 };
  const series: SeriesPoint[] = [];
  let finished = 0, version = 0, evicted: { at: number; ms: number } | null = null;

  const model = (id: string): ModelState => {
    let state = models.get(id);
    if (!state) models.set(id, state = { state: "unloaded", loads: 0, unloads: 0, lastLoadMs: null, lastUnloadMs: null, lastUnloadReason: null,
      lastSwapMs: null, swaps: 0, weightsBytes: 0, kvBytes: 0, prefixCacheBytes: 0, lastError: null });
    return state;
  };

  function applyCore(event: CoreEvent): boolean {
    switch (event.type) {
      case "model.load": {
        const state = model(event.model);
        if (event.phase === "started") { state.state = "loading"; state.lastError = null; return true; }
        if (event.phase === "failed") { state.state = "failed"; state.lastError = event.error ?? "load failed"; return true; }
        state.state = "resident"; state.loads++; state.lastLoadMs = event.ms ?? null; state.lastError = null;
        if (event.weightsBytes !== undefined) state.weightsBytes = event.weightsBytes;
        if (evicted && event.ms !== undefined && event.at - evicted.at <= swapWithin) {
          state.swaps++; state.lastSwapMs = evicted.ms + event.ms;
        }
        evicted = null;
        return true;
      }
      case "model.unload": {
        const state = model(event.model);
        state.state = "unloaded"; state.unloads++;
        state.lastUnloadMs = event.drainMs + (event.flushMs ?? 0); state.lastUnloadReason = event.reason;
        state.kvBytes = 0; state.prefixCacheBytes = 0;
        schedulers.delete(event.model); caches.delete(event.model);
        evicted = event.reason === "evicted" ? { at: event.at, ms: state.lastUnloadMs } : null;
        return true;
      }
      case "model.memory": {
        const state = model(event.model);
        state.weightsBytes = event.weightsBytes; state.kvBytes = event.kvBytes; state.prefixCacheBytes = event.prefixCacheBytes;
        return true;
      }
      case "request.finished": {
        const { type: _type, ...request } = event;
        requests.push(request);
        if (requests.length > windowSize) requests.shift();
        finished++; byFinish[event.finish]++;
        return true;
      }
      case "scheduler.sample": {
        const { type: _type, ...sample } = event;
        schedulers.set(event.model, sample);
        // The chart sums models sampled in the same tick (the host samples them together).
        const last = series.at(-1);
        if (last?.at === event.at)
          series[series.length - 1] = { at: event.at, tokensPerSecond: last.tokensPerSecond + event.tokensPerSecond, active: last.active + event.active,
            queued: last.queued + event.queued };
        else series.push({ at: event.at, tokensPerSecond: event.tokensPerSecond, active: event.active, queued: event.queued });
        while (series.length > seriesSize) series.shift();
        return true;
      }
      case "cache.sample": {
        const entry = caches.get(event.model) ?? { kv: null, prefix: null };
        if (event.cache === "kv") entry.kv = { at: event.at, bytes: event.bytes, capacityBytes: event.capacityBytes };
        else {
          const hits = event.hits ?? 0, misses = event.misses ?? 0;
          entry.prefix = { at: event.at, bytes: event.bytes, capacityBytes: event.capacityBytes, hits, misses, hitRate: hits + misses ? hits / (hits + misses) : null };
        }
        caches.set(event.model, entry);
        return true;
      }
      default: return false;
    }
  }

  function window(): RequestWindow {
    const promptTokens = requests.reduce((sum, request) => sum + request.promptTokens, 0);
    const cached = requests.reduce((sum, request) => sum + request.cachedPromptTokens, 0);
    return {
      count: requests.length,
      queueMs: distribution(present(requests.map(request => request.queueMs))),
      ttftMs: distribution(present(requests.map(request => request.ttftMs))),
      prefillTokensPerSecond: distribution(present(requests.map(request => request.prefillTokensPerSecond))),
      decodeTokensPerSecond: distribution(present(requests.map(request => request.decodeTokensPerSecond))),
      totalMs: distribution(requests.map(request => request.totalMs)),
      cachedPromptShare: promptTokens ? cached / promptTokens : null,
    };
  }

  return {
    get version() { return version; },
    apply(event) {
      // A module's event that shares a core type's spelling is still a core event; anything else is not this store's.
      if (!CORE_TYPES.has(event.type)) return;
      if (applyCore(event as CoreEvent)) version++;
    },
    snapshot: () => ({
      at: now(), startedAt,
      models: [...models].map(([id, state]) => ({ model: id, ...state })),
      schedulers: [...schedulers.values()],
      caches: [...caches].map(([id, entry]) => ({ model: id, ...entry })),
      requests: { finished, byFinish: { ...byFinish }, window: window(), recent: requests.slice(-recentSize) },
      series: [...series],
    }),
  };
}
