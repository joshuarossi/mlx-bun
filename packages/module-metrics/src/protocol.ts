// The module's data protocol: what `/api/metrics` returns and streams, shared
// by the backend and the web panel. Plain data, no imports. Every duration is
// milliseconds, every size bytes, every timestamp epoch milliseconds.

/** A distribution over the finished requests in the window; null when none reported the value. */
export interface Distribution {
  readonly count: number;
  readonly mean: number;
  readonly p50: number;
  readonly p95: number;
  readonly max: number;
}

export type ModelState = "loading" | "resident" | "unloaded" | "failed";

export interface ModelMetrics {
  readonly model: string;
  readonly state: ModelState;
  readonly loads: number;
  readonly unloads: number;
  /** The most recent finished load, including restored state. */
  readonly lastLoadMs: number | null;
  /** The most recent unload's drain and flush together. */
  readonly lastUnloadMs: number | null;
  readonly lastUnloadReason: string | null;
  /** The most recent evicted-then-loaded pair: unload plus load, milliseconds. */
  readonly lastSwapMs: number | null;
  readonly swaps: number;
  readonly weightsBytes: number;
  readonly kvBytes: number;
  readonly prefixCacheBytes: number;
  readonly lastError: string | null;
}

export interface RequestMetrics {
  readonly requestId: string;
  readonly model: string;
  readonly at: number;
  readonly finish: "stop" | "length" | "cancelled" | "error";
  readonly promptTokens: number;
  readonly cachedPromptTokens: number;
  readonly completionTokens: number;
  readonly queueMs: number | null;
  readonly ttftMs: number | null;
  readonly prefillTokensPerSecond: number | null;
  readonly decodeTokensPerSecond: number | null;
  readonly totalMs: number;
}

export interface SchedulerMetrics {
  readonly model: string;
  readonly at: number;
  /** Rows decoding now. */
  readonly active: number;
  /** The batch capacity. */
  readonly capacity: number;
  /** Requests waiting for admission or prefill. */
  readonly queued: number;
  readonly tokensPerSecond: number;
}

export interface CacheMetrics {
  readonly model: string;
  readonly kv: { readonly at: number; readonly bytes: number; readonly capacityBytes: number | null } | null;
  readonly prefix: {
    readonly at: number; readonly bytes: number; readonly capacityBytes: number | null;
    readonly hits: number; readonly misses: number;
    /** Lookups that hit, over all lookups since the server started; null before any. */
    readonly hitRate: number | null;
  } | null;
}

export interface RequestWindow {
  /** Requests the distributions cover: the most recent finished, newest last. */
  readonly count: number;
  readonly queueMs: Distribution | null;
  readonly ttftMs: Distribution | null;
  readonly prefillTokensPerSecond: Distribution | null;
  readonly decodeTokensPerSecond: Distribution | null;
  readonly totalMs: Distribution | null;
  /** Prompt tokens served from the cache, over all prompt tokens in the window; null with no prompts. */
  readonly cachedPromptShare: number | null;
}

export interface SeriesPoint { readonly at: number; readonly tokensPerSecond: number; readonly active: number; readonly queued: number }

export interface MetricsSnapshot {
  readonly at: number;
  readonly startedAt: number;
  readonly models: readonly ModelMetrics[];
  readonly schedulers: readonly SchedulerMetrics[];
  readonly caches: readonly CacheMetrics[];
  readonly requests: {
    readonly finished: number;
    readonly byFinish: Readonly<Record<RequestMetrics["finish"], number>>;
    readonly window: RequestWindow;
    /** Newest last. */
    readonly recent: readonly RequestMetrics[];
  };
  /** Scheduler samples, oldest first, for the live throughput chart. */
  readonly series: readonly SeriesPoint[];
}

/** One measured cell of a benchmark run, reduced to the numbers a history view compares. */
export interface BenchCell {
  readonly key: string;
  readonly model: string;
  readonly kind: "tree" | "reference";
  readonly tree?: string;
  readonly configuration?: string;
  readonly reference?: string;
  readonly status: "measured" | "skipped" | "failed";
  /** Skip reason or failure message. */
  readonly note?: string;
  /** Medians over the run's samples. */
  readonly decodeTokensPerSecond: number | null;
  readonly ttftColdMs: number | null;
  readonly prefill1kTokensPerSecond: number | null;
  readonly contextPrefillTokensPerSecond: number | null;
  readonly aggregateTokensPerSecond: number | null;
  readonly coldStartMs: number | null;
  readonly peakRssMB: number | null;
}

/** A finished `bench-serve` run, stored beside (never inside) the source tree. */
export interface BenchHistoryEntry {
  readonly id: string;
  /** The plan file's name without its extension. */
  readonly profile: string;
  /** `all` or `scoped`, as the plan declared. */
  readonly scope: string;
  readonly startedAt: string;
  readonly finishedAt: string | null;
  readonly durationMs: number;
  /** Whether bench-serve judged every applicable cell measured; performance acceptance stays unreviewed. */
  readonly complete: boolean;
  readonly exitCode: number;
  readonly problems: readonly string[];
  readonly machine: { readonly chip: string; readonly memoryBytes: number; readonly host: string; readonly os: string } | null;
  /** The run's own directory with `run.json` and `report.md`. */
  readonly runDirectory: string;
  readonly cells: readonly BenchCell[];
}

export interface BenchProfile { readonly name: string; readonly path: string; readonly scope: string | null; readonly models: readonly string[] }

/** What the panel and a client see of a launched run. */
export interface BenchJob {
  readonly id: string;
  readonly status: string;
  readonly progress: number;
  readonly message: string | null;
  readonly error: string | null;
  readonly startedAt: string;
  readonly endedAt: string | null;
}

/** Set on the panel element's `connection` property before it connects (`PanelConnection` in app-core, restated because a panel imports only this file). */
export interface PanelConnection {
  /** Absolute or origin-relative base of `/api/metrics`. */
  readonly apiBase: string;
  /** The snapshot stream (`<apiBase>/stream`). */
  readonly eventsUrl: string;
}
