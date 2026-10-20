// Deterministic fakes of the browser's transports, for the tests of panels, the shell and the app: a fake
// `EventSource` and `WebSocket` whose instances a test can find and drive, and a `fetch` over fixture routes.
// They never touch the network and never schedule anything on their own, so a test decides exactly when a frame
// arrives, when a connection drops and whether anything leaked.
//
// Import from `@mlx-bun/web-kit/testing` in tests only; the production entry does not export these.

type Listener = (event: MessageEvent) => void;

/** A fake `EventSource`. `emit` delivers a named or unnamed event, `fail` fires `error`, `open` fires `open`. */
export class FakeEventSource {
  static instances: FakeEventSource[] = [];
  static readonly CONNECTING = 0; static readonly OPEN = 1; static readonly CLOSED = 2;
  readonly CONNECTING = 0; readonly OPEN = 1; readonly CLOSED = 2;
  readyState = 0;
  withCredentials = false;
  onopen: ((event: Event) => void) | null = null;
  onmessage: Listener | null = null;
  onerror: ((event: Event) => void) | null = null;
  readonly listeners = new Map<string, Set<Listener>>();
  closed = false;

  constructor(readonly url: string, _init?: EventSourceInit) { FakeEventSource.instances.push(this); }

  /** The most recently created instance, or the one for a URL. */
  static last(url?: string): FakeEventSource | undefined {
    const list = url ? FakeEventSource.instances.filter((item) => item.url === url) : FakeEventSource.instances;
    return list[list.length - 1];
  }
  static reset(): void { FakeEventSource.instances = []; }
  /** Instances a test expects to have been closed. */
  static get open(): FakeEventSource[] { return FakeEventSource.instances.filter((item) => !item.closed); }

  addEventListener(type: string, listener: Listener): void {
    if (!this.listeners.has(type)) this.listeners.set(type, new Set());
    this.listeners.get(type)!.add(listener);
  }
  removeEventListener(type: string, listener: Listener): void { this.listeners.get(type)?.delete(listener); }
  dispatchEvent(): boolean { return true; }
  close(): void { this.closed = true; this.readyState = 2; }

  open(): void { this.readyState = 1; this.onopen?.(new Event("open")); }
  /** Delivers one event; unnamed events go to `onmessage`, named ones to their listeners. The data is JSON-encoded unless already a string. */
  emit(data: unknown, name?: string): void {
    if (this.closed) return;
    const payload = typeof data === "string" ? data : JSON.stringify(data);
    const event = new MessageEvent(name ?? "message", { data: payload });
    if (!name) this.onmessage?.(event);
    for (const listener of this.listeners.get(name ?? "message") ?? []) listener(event);
  }
  /** The connection dropped; a real browser would retry. */
  fail(): void { if (!this.closed) { this.readyState = 0; this.onerror?.(new Event("error")); } }
}

/** A fake `WebSocket`. `open()` connects it, `emit` delivers a server frame, `drop()` closes it from the server side. */
export class FakeWebSocket {
  static instances: FakeWebSocket[] = [];
  static readonly CONNECTING = 0; static readonly OPEN = 1; static readonly CLOSING = 2; static readonly CLOSED = 3;
  readyState = 0;
  readonly sent: unknown[] = [];
  onopen: ((event: Event) => void) | null = null;
  onclose: ((event: CloseEvent | Event) => void) | null = null;
  onerror: ((event: Event) => void) | null = null;
  onmessage: Listener | null = null;
  closedByClient = false;

  constructor(readonly url: string, _protocols?: string | string[]) { FakeWebSocket.instances.push(this); }

  static last(): FakeWebSocket | undefined { return FakeWebSocket.instances[FakeWebSocket.instances.length - 1]; }
  static reset(): void { FakeWebSocket.instances = []; }
  /** Sockets neither closed by the client nor dropped. */
  static get live(): FakeWebSocket[] { return FakeWebSocket.instances.filter((item) => item.readyState < 2); }

  addEventListener(): void {}
  removeEventListener(): void {}
  send(data: string): void {
    if (this.readyState !== 1) throw new Error("InvalidStateError: the socket is not open");
    try { this.sent.push(JSON.parse(data)); } catch { this.sent.push(data); }
  }
  close(): void {
    if (this.readyState >= 2) return;
    this.closedByClient = true;
    this.readyState = 3;
    this.onclose?.(new Event("close"));
  }

  open(): void { this.readyState = 1; this.onopen?.(new Event("open")); }
  emit(frame: unknown): void { if (this.readyState === 1) this.onmessage?.(new MessageEvent("message", { data: typeof frame === "string" ? frame : JSON.stringify(frame) })); }
  /** The server went away: an error, then a close the client did not ask for. */
  drop(): void {
    if (this.readyState >= 2) return;
    this.readyState = 3;
    this.onerror?.(new Event("error"));
    this.onclose?.(new Event("close"));
  }
  /** The frames sent so far of one type. */
  sentOfType(type: string): Record<string, unknown>[] {
    return this.sent.filter((frame): frame is Record<string, unknown> => !!frame && typeof frame === "object" && (frame as { type?: string }).type === type);
  }
}

export type FixtureRoute = unknown | ((request: Request, url: URL) => unknown | Response | Promise<unknown | Response>);

/** A `fetch` over fixture routes keyed by `METHOD /path` or `/path` (any method). A value is answered as JSON with
 * status 200; a `Response` is returned as is; a function computes either. Unknown paths answer 404 with an
 * OpenAI-style error envelope. Every request is recorded in `calls`. */
export function fakeFetch(routes: Readonly<Record<string, FixtureRoute>>): typeof fetch & { calls: { method: string; url: string; body: unknown }[] } {
  const calls: { method: string; url: string; body: unknown }[] = [];
  const impl = (async (input: string | URL | Request, init?: RequestInit) => {
    const request = input instanceof Request ? input : new Request(new URL(String(input), "http://localhost/").href, init);
    const url = new URL(request.url);
    const method = request.method.toUpperCase();
    const text = method === "GET" || method === "HEAD" ? "" : await request.clone().text();
    let body: unknown = text;
    try { body = text ? JSON.parse(text) : undefined; } catch { /* keep the text */ }
    calls.push({ method, url: url.pathname + url.search, body });
    const route = routes[`${method} ${url.pathname}`] ?? routes[url.pathname];
    if (route === undefined) return Response.json({ error: { message: `no fixture for ${method} ${url.pathname}` } }, { status: 404 });
    const answer = typeof route === "function" ? await (route as (request: Request, url: URL) => unknown)(request, url) : route;
    return answer instanceof Response ? answer : Response.json(answer);
  }) as typeof fetch & { calls: typeof calls };
  impl.calls = calls;
  return impl;
}

/** Installs fakes on `globalThis` for a test and returns the function that restores the originals. */
export function installFakes(fakes: { fetch?: typeof fetch; EventSource?: unknown; WebSocket?: unknown }): () => void {
  const saved = new Map<string, PropertyDescriptor | undefined>();
  for (const [name, value] of Object.entries(fakes)) {
    if (value === undefined) continue;
    saved.set(name, Object.getOwnPropertyDescriptor(globalThis, name));
    Object.defineProperty(globalThis, name, { value, configurable: true, writable: true });
  }
  return () => {
    for (const [name, descriptor] of saved) {
      if (descriptor) Object.defineProperty(globalThis, name, descriptor);
      else delete (globalThis as Record<string, unknown>)[name];
    }
  };
}
