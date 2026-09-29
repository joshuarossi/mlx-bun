// The `events` core service: in-process publish/subscribe that a producer can
// call from the generation path. Publishing only appends to each interested
// subscriber's bounded queue; handlers run later, off the publisher's stack, one
// subscriber at a time in publish order. A slow subscriber loses its oldest
// events (counted) instead of holding memory or the publisher back, and a
// handler that throws is counted and skipped. Nothing here awaits a handler.
import type { AppEvent, CoreEventType, EventBus, Unsubscribe } from "@mlx-bun/app-core";

export interface EventHubOptions {
  /** Events one subscriber may hold undelivered; past it the oldest are dropped. Default 1024. */
  bufferSize?: number;
  /** Events one delivery pass hands a subscriber before yielding to the loop again. Default 256. */
  batchSize?: number;
  /** Runs a delivery pass off the publisher's stack. Default `setImmediate`; tests supply a manual queue. */
  schedule?: (run: () => void) => void;
  /** Called for a handler that throws or rejects; the default only counts it. */
  onHandlerError?: (error: unknown, event: AppEvent) => void;
}

export interface SubscriberStats {
  readonly types: readonly AppEvent["type"][] | "*";
  readonly delivered: number;
  /** Events discarded because this subscriber's queue was full. */
  readonly dropped: number;
  /** Handler calls that threw or rejected. */
  readonly failed: number;
  readonly pending: number;
}

export interface EventHubStats {
  readonly published: number;
  /** Events refused before delivery: not an event object, or a module publishing outside its own prefix. */
  readonly rejected: number;
  readonly subscribers: readonly SubscriberStats[];
}

/** The host's bus, and the scoped views it binds to each module. */
export interface EventHub extends EventBus {
  /** What a module receives: it subscribes to anything and publishes only its own `<moduleId>.*` events, never a core type. */
  scoped(scope: { readonly moduleId: string }): EventBus;
  stats(): EventHubStats;
  /** Drops every subscriber and their undelivered events; later publishes are ignored. Idempotent. */
  close(): void;
}

interface Subscriber {
  readonly types: ReadonlySet<string> | "*";
  readonly declared: readonly AppEvent["type"][] | "*";
  readonly handler: (event: AppEvent) => unknown;
  queue: AppEvent[];
  head: number;
  scheduled: boolean;
  active: boolean;
  delivered: number;
  dropped: number;
  failed: number;
}

/** Every core event type, exhaustive by construction: a module may not publish these even under a prefix that spells one. */
const CORE_TYPES: Readonly<Record<CoreEventType, true>> = {
  "model.load": true, "model.unload": true, "model.memory": true, "request.finished": true, "scheduler.sample": true, "cache.sample": true,
  "catalog.changed": true, "job.state": true,
};

const isEvent = (value: unknown): value is AppEvent =>
  typeof value === "object" && value !== null && typeof (value as { type?: unknown }).type === "string" &&
  typeof (value as { at?: unknown }).at === "number";

export function createEventHub(options: EventHubOptions = {}): EventHub {
  const bufferSize = Math.max(1, Math.floor(options.bufferSize ?? 1024));
  const batchSize = Math.max(1, Math.floor(options.batchSize ?? 256));
  const schedule = options.schedule ?? (run => { setImmediate(run); });
  const subscribers = new Set<Subscriber>();
  let published = 0, rejected = 0, closed = false;

  const pending = (subscriber: Subscriber) => subscriber.queue.length - subscriber.head;

  const fail = (subscriber: Subscriber, error: unknown, event: AppEvent) => {
    subscriber.failed++;
    try { options.onHandlerError?.(error, event); } catch { /* a reporting failure cannot reach the publisher either */ }
  };

  function deliver(subscriber: Subscriber): void {
    subscriber.scheduled = false;
    for (let handed = 0; subscriber.active && pending(subscriber) > 0 && handed < batchSize; handed++) {
      const event = subscriber.queue[subscriber.head++]!;
      // Compact once the consumed prefix dominates, so a long-lived subscriber's array stays small.
      if (subscriber.head >= 64 && subscriber.head * 2 >= subscriber.queue.length) {
        subscriber.queue = subscriber.queue.slice(subscriber.head);
        subscriber.head = 0;
      }
      subscriber.delivered++;
      try {
        const result = subscriber.handler(event);
        if (result instanceof Promise) result.catch(error => fail(subscriber, error, event));
      } catch (error) { fail(subscriber, error, event); }
    }
    if (subscriber.active && pending(subscriber) > 0) enqueue(subscriber);
  }

  function enqueue(subscriber: Subscriber): void {
    if (subscriber.scheduled) return;
    subscriber.scheduled = true;
    schedule(() => deliver(subscriber));
  }

  const publish = (event: AppEvent): void => {
    if (closed) return;
    if (!isEvent(event)) { rejected++; return; }
    published++;
    for (const subscriber of subscribers) {
      if (subscriber.types !== "*" && !subscriber.types.has(event.type)) continue;
      if (pending(subscriber) >= bufferSize) {
        subscriber.head++; subscriber.dropped++;
        // The dead prefix stays bounded even when delivery is starved.
        if (subscriber.head >= bufferSize) { subscriber.queue = subscriber.queue.slice(subscriber.head); subscriber.head = 0; }
      }
      subscriber.queue.push(event);
      enqueue(subscriber);
    }
  };

  const subscribe: EventBus["subscribe"] = (types, handler) => {
    if (closed) return () => {};
    const subscriber: Subscriber = { types: types === "*" ? "*" : new Set(types), declared: types === "*" ? "*" : [...types], handler,
      queue: [], head: 0, scheduled: false, active: true, delivered: 0, dropped: 0, failed: 0 };
    subscribers.add(subscriber);
    const unsubscribe: Unsubscribe = () => {
      subscriber.active = false;
      subscriber.queue = []; subscriber.head = 0;
      subscribers.delete(subscriber);
    };
    return unsubscribe;
  };

  return {
    publish, subscribe,
    scoped({ moduleId }) {
      const prefix = `${moduleId}.`;
      return { subscribe, publish(event) {
        if (!isEvent(event) || !event.type.startsWith(prefix) || Object.hasOwn(CORE_TYPES, event.type)) { rejected++; return; }
        publish(event);
      } };
    },
    stats: () => ({ published, rejected, subscribers: [...subscribers].map(subscriber => ({
      types: subscriber.declared, delivered: subscriber.delivered, dropped: subscriber.dropped, failed: subscriber.failed, pending: pending(subscriber) })) }),
    close() {
      closed = true;
      for (const subscriber of subscribers) { subscriber.active = false; subscriber.queue = []; subscriber.head = 0; }
      subscribers.clear();
    },
  };
}
