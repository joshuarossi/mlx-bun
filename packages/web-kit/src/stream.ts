// The event-stream client: one `EventSource` wrapper for job streams (`data:` lines of JSON events ending with
// `event: end`), the metrics stream (named `snapshot` events) and any other server-sent route. It parses JSON,
// dispatches named events, closes itself on the terminal event, and can be torn down by `close()` or an
// `AbortSignal`, so a panel that leaves its page leaves no stream behind. Keep-alive comments the server writes
// between events never reach a handler: the browser drops them, and so does the fake `EventSource` in `./testing`.

export interface EventStreamHandlers<T = unknown> {
  /** An unnamed `data:` event, parsed as JSON. */
  message?(data: T, event: MessageEvent): void;
  /** Named events (`event: snapshot`), parsed as JSON. The terminal event closes the stream before its handler runs. */
  events?: Readonly<Record<string, (data: unknown, event: MessageEvent) => void>>;
  /** The stream opened (or reopened after the browser's automatic retry). */
  open?(): void;
  /** The connection dropped. The browser retries on its own unless the stream was closed. */
  error?(): void;
  /** The terminal event arrived (default name `end`): the stream is closed and will not retry. */
  end?(): void;
}

export interface EventStreamOptions {
  signal?: AbortSignal;
  /** The event name that ends the stream for good. Default `end`; null for a stream that never ends on its own. */
  endEvent?: string | null;
  /** The constructor to use; tests pass a fake. */
  EventSource?: typeof EventSource;
}

export interface EventStream {
  readonly url: string;
  readonly closed: boolean;
  close(): void;
}

function parse(event: MessageEvent): unknown {
  const text = typeof event.data === "string" ? event.data : "";
  if (!text) return {};
  try { return JSON.parse(text); } catch { return { type: "unparseable", text: text.slice(0, 200) }; }
}

/** Open a server-sent stream. Returns the handle; nothing is delivered after `close()`. */
export function openEventStream<T = unknown>(url: string, handlers: EventStreamHandlers<T>, options: EventStreamOptions = {}): EventStream {
  const Source = options.EventSource ?? globalThis.EventSource;
  if (!Source) throw new Error("EventSource is not available in this environment");
  const endEvent = options.endEvent === undefined ? "end" : options.endEvent;
  let closed = false;
  const source = new Source(url);
  const close = () => {
    if (closed) return;
    closed = true;
    source.close();
    options.signal?.removeEventListener("abort", close);
  };
  source.onopen = () => { if (!closed) handlers.open?.(); };
  source.onerror = () => { if (!closed) handlers.error?.(); };
  source.onmessage = (event) => { if (!closed) handlers.message?.(parse(event) as T, event); };
  for (const [name, handler] of Object.entries(handlers.events ?? {})) {
    if (name === endEvent) continue;
    source.addEventListener(name, (event) => { if (!closed) handler(parse(event as MessageEvent), event as MessageEvent); });
  }
  if (endEvent !== null) {
    source.addEventListener(endEvent, (event) => {
      if (closed) return;
      close();
      handlers.events?.[endEvent]?.(parse(event as MessageEvent), event as MessageEvent);
      handlers.end?.();
    });
  }
  if (options.signal) {
    if (options.signal.aborted) close();
    else options.signal.addEventListener("abort", close, { once: true });
  }
  return { url, get closed() { return closed; }, close };
}

/** A message handler that dispatches on the event's `type` field, for streams of typed events (job streams). */
export function byType<E extends { type: string }>(handlers: { [K in E["type"]]?: (event: Extract<E, { type: K }>) => void }): (event: E) => void {
  return (event) => {
    const handler = (handlers as Record<string, ((event: E) => void) | undefined>)[event.type];
    handler?.(event);
  };
}
