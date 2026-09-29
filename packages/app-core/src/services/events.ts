/** Events the core services publish and modules subscribe to. Payloads carry
 * counters, durations and byte sizes, never prompt or completion text. */
export type ModelUnloadReason = "evicted" | "requested" | "idle" | "failed";

export type CoreEvent =
  | { type: "model.load"; at: number; model: string; phase: "started" | "finished" | "failed";
      /** Set on `finished`; includes any restored state. */
      ms?: number; weightsBytes?: number; resumed?: boolean }
  | { type: "model.unload"; at: number; model: string; reason: ModelUnloadReason;
      drainMs: number; flushed: boolean; flushMs?: number }
  | { type: "model.memory"; at: number; model: string; weightsBytes: number; kvBytes: number; prefixCacheBytes: number }
  | { type: "request.finished"; at: number; model: string; requestId: string;
      finish: "stop" | "length" | "cancelled" | "error";
      promptTokens: number; cachedPromptTokens: number; completionTokens: number;
      queueMs: number; ttftMs: number | null; decodeTokensPerSecond: number | null }
  | { type: "scheduler.sample"; at: number; model: string; active: number; capacity: number; queued: number;
      tokensPerSecond: number }
  | { type: "cache.sample"; at: number; model: string; cache: "kv" | "prefix"; bytes: number;
      capacityBytes: number | null; hits: number; misses: number }
  | { type: "catalog.changed"; at: number }
  | { type: "job.state"; at: number; jobId: string; kind: string; status: string };

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
