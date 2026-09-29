// The engine's side of the `events` service: a thin adapter at the app boundary
// that publishes what the engine already measures. It wraps the completion
// engine to time each request (arrival, first token, the scheduler's own
// prefill and decode figures from the run's stats) and samples the gateway and
// caches on an interval. It changes no scheduling or numerics: the wrapper only
// counts tokens on their way through, publishing appends to bounded queues and
// never waits on a subscriber, and the libraries below the app know nothing of it.
import type { AppEvent, EventBus } from "@mlx-bun/app-core";
import type { GenerateStats } from "@mlx-bun/inference/generation";
import type { CompletionEngine } from "./completion";
import type { GenerationGateway } from "./generation-gateway";

export interface EngineTelemetryInput {
  events: Pick<EventBus, "publish">;
  /** The model's exact id, as `/stats` reports it. */
  model: string;
  /** The batch capacity the gateway runs with. */
  capacity: number;
  /** Bytes of resident weights. */
  weightsBytes: number;
  gateway: Pick<GenerationGateway, "activeRows" | "kvBytes">;
  promptCache: { readonly totalBytes: number; readonly maxBytes: number; readonly hits: number; readonly misses: number };
  /** Milliseconds between samples of the scheduler and caches. Default 1000. */
  intervalMs?: number;
  /** Test seams. */
  now?: () => number;
  performanceNow?: () => number;
  timers?: { setInterval(run: () => void, ms: number): unknown; clearInterval(handle: unknown): void };
}

export interface EngineTelemetry {
  /** The same engine with each `run` observed. Everything else passes through untouched. */
  observe<T extends CompletionEngine>(engine: T): T;
  /** Take one sample now, even if nothing changed since the last (the interval's own samples skip an idle, unchanged reading). */
  sample(): void;
  /** Stops sampling; runs still in flight publish their own finish. Idempotent. */
  stop(): void;
}

const realTimers = {
  setInterval: (run: () => void, ms: number) => { const handle = setInterval(run, ms); handle.unref(); return handle; },
  clearInterval: (handle: unknown) => clearInterval(handle as ReturnType<typeof setInterval>),
};

export function createEngineTelemetry(input: EngineTelemetryInput): EngineTelemetry {
  const publish = (event: AppEvent) => { try { input.events.publish(event); } catch { /* the bus never throws; a stand-in must not reach a request */ } };
  const now = input.now ?? Date.now, clock = input.performanceNow ?? (() => performance.now()), timers = input.timers ?? realTimers;
  const { model, capacity } = input;
  let requestCount = 0, inflight = 0, tokensSinceSample = 0, lastSampleAt = clock(), lastSignature = "";
  let stopped = false;

  const sample = (quiet = false) => {
    const at = now(), seconds = Math.max((clock() - lastSampleAt) / 1000, 1e-3);
    const tokens = tokensSinceSample;
    tokensSinceSample = 0; lastSampleAt = clock();
    const active = input.gateway.activeRows, queued = Math.max(0, inflight - active);
    const kv = input.gateway.kvBytes, cache = input.promptCache;
    const tokensPerSecond = tokens / seconds;
    // Nothing moving and nothing changed since the last sample: say nothing, so an idle server keeps its subscribers quiet.
    const signature = [active, queued, kv.projected, kv.budget, cache.totalBytes, cache.hits, cache.misses].join(":");
    if (quiet && tokens === 0 && active === 0 && queued === 0 && signature === lastSignature) return;
    lastSignature = signature;
    publish({ type: "scheduler.sample", at, model, active, capacity, queued, tokensPerSecond });
    publish({ type: "cache.sample", at, model, cache: "kv", bytes: kv.projected, capacityBytes: kv.budget, hits: null, misses: null });
    publish({ type: "cache.sample", at, model, cache: "prefix", bytes: cache.totalBytes, capacityBytes: Number.isFinite(cache.maxBytes) ? cache.maxBytes : null,
      hits: cache.hits, misses: cache.misses });
    publish({ type: "model.memory", at, model, weightsBytes: input.weightsBytes, kvBytes: kv.projected, prefixCacheBytes: cache.totalBytes });
  };

  const timer = timers.setInterval(() => { if (!stopped) sample(true); }, input.intervalMs ?? 1000);

  function finished(prompt: number, stats: GenerateStats | undefined, arrival: number, first: number | null, tokens: number, failure: "cancelled" | "error" | null) {
    const total = clock() - arrival, ttft = first === null ? null : first - arrival;
    // The run's own prefill span starts at admission, so what precedes it in the time to first token was queueing.
    const queueMs = stats && ttft !== null ? Math.max(0, ttft - stats.prefillMs) : null;
    publish({ type: "request.finished", at: now(), model, requestId: `req-${++requestCount}`,
      finish: failure ?? (stats?.finishReason === "length" ? "length" : "stop"),
      promptTokens: prompt, cachedPromptTokens: stats?.cachedTokens ?? 0, completionTokens: stats?.generatedTokens ?? tokens,
      queueMs, ttftMs: ttft, prefillTokensPerSecond: stats && stats.prefillTps > 0 ? stats.prefillTps : null,
      decodeTokensPerSecond: stats && stats.decodeTps > 0 ? stats.decodeTps : null, totalMs: total });
  }

  return {
    sample: () => sample(),
    stop() { if (stopped) return; stopped = true; timers.clearInterval(timer); },
    observe<T extends CompletionEngine>(engine: T): T {
      return { ...engine, async run(prompt: Parameters<T["run"]>[0], options: Parameters<T["run"]>[1], onToken: Parameters<T["run"]>[2], vision: Parameters<T["run"]>[3],
        shape: Parameters<T["run"]>[4], placement: Parameters<T["run"]>[5], signal?: AbortSignal, trace?: Parameters<T["run"]>[7]) {
        const arrival = clock();
        let first: number | null = null, tokens = 0;
        inflight++;
        try {
          const stats = await engine.run(prompt, options, (token, logprobs) => {
            if (first === null) first = clock();
            tokens++; tokensSinceSample++;
            return onToken(token, logprobs);
          }, vision, shape, placement, signal, trace);
          finished(prompt.length, stats, arrival, first, tokens, null);
          return stats;
        } catch (error) {
          finished(prompt.length, undefined, arrival, first, tokens, signal?.aborted ? "cancelled" : "error");
          throw error;
        } finally { inflight--; }
      } } as T;
    },
  };
}
