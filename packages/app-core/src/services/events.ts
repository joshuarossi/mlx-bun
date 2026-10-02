/** Events the core services publish and modules subscribe to. Payloads carry
 * counters, durations and byte sizes, never prompt or completion text. */
export type ModelUnloadReason = "evicted" | "requested" | "idle" | "failed";

export type CoreEvent =
  | { type: "model.load"; at: number; model: string; phase: "started" | "finished" | "failed";
      /** Set on `finished`; includes any restored state. */
      ms?: number; weightsBytes?: number; resumed?: boolean;
      /** Set on `failed`. */
      error?: string }
  | { type: "model.unload"; at: number; model: string; reason: ModelUnloadReason;
      drainMs: number; flushed: boolean; flushMs?: number }
  | { type: "model.memory"; at: number; model: string; weightsBytes: number; kvBytes: number; prefixCacheBytes: number }
  | { type: "request.finished"; at: number; model: string; requestId: string;
      finish: "stop" | "length" | "cancelled" | "error";
      promptTokens: number; cachedPromptTokens: number; completionTokens: number;
      /** Milliseconds from the request's arrival to its admission into the batch; null when it never produced a token, so admission is unknown. */
      queueMs: number | null;
      /** Milliseconds from arrival to the first token; null when none was produced. */
      ttftMs: number | null;
      /** Prompt tokens not served from the cache, per second of prefill; null without a prefill. */
      prefillTokensPerSecond: number | null;
      /** Tokens after the first, per second of decode; null under two tokens. */
      decodeTokensPerSecond: number | null;
      /** Arrival to completion. */
      totalMs: number }
  /** A periodic reading of the scheduler: `active` rows decode, `queued` requests wait for admission or prefill.
   * `tokensPerSecond` is every row's tokens over the interval since the previous sample. */
  | { type: "scheduler.sample"; at: number; model: string; active: number; capacity: number; queued: number;
      tokensPerSecond: number }
  /** A periodic reading of a cache. `kv` is the batch's projected KV (no lookups, so `hits` and `misses` are null);
   * `prefix` is the prompt cache, whose counters are lookups since start. */
  | { type: "cache.sample"; at: number; model: string; cache: "kv" | "prefix"; bytes: number;
      capacityBytes: number | null; hits: number | null; misses: number | null }
  | { type: "catalog.changed"; at: number }
  | { type: "job.state"; at: number; jobId: string; kind: string; status: string };

export type CoreEventType = CoreEvent["type"];
/** One core event by its type. A module's `AppEvent` cannot be narrowed by `type` alone, since a module's own
 * type strings overlap the core's at the type level; narrow with a guard returning `event is EventOf<T>`. */
export type EventOf<T extends CoreEventType> = Extract<CoreEvent, { type: T }>;

/** A module's own event. The type is prefixed with the module id (`transcription.finished`). */
export interface ModuleEvent { readonly type: `${string}.${string}`; readonly at: number; readonly data?: unknown }

export type AppEvent = CoreEvent | ModuleEvent;
export type Unsubscribe = () => void;

/** In-process publish/subscribe. The model host and the scheduler adapter
 * publish; modules and the host's event stream subscribe. */
export interface EventBus {
  /** Never throws and never waits for a subscriber: a slow or failing subscriber cannot slow generation. */
  publish(event: AppEvent): void;
  /** `"*"` receives every event. A subscriber added later does not see earlier events. */
  subscribe(types: readonly AppEvent["type"][] | "*", handler: (event: AppEvent) => void): Unsubscribe;
}
