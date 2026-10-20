// The socket client: a JSON-framed WebSocket that reports its status, reconnects after an unexpected close while
// its owner says the page is active, and drops every handler of a superseded connection so a late frame or close
// from an old socket never reaches the controller. `close()` is final: it cancels any pending reconnect.

export type SocketStatus = "connecting" | "open" | "closed" | "error";

export interface SocketOptions<In, Out> {
  url: string | (() => string);
  /** A parsed frame from the server. Frames that are not JSON are dropped. */
  onFrame(frame: In): void;
  onStatus?(status: SocketStatus): void;
  /** Milliseconds before a reconnect attempt after an unexpected close. Default 2200. */
  reconnectMs?: number;
  /** Consulted when the reconnect timer fires; false skips the attempt (the page is hidden) until the next `connect()`. */
  shouldReconnect?(): boolean;
  /** The constructor to use; tests pass a fake. */
  WebSocket?: typeof WebSocket;
  /** Timer functions; tests pass fakes. */
  setTimeout?: typeof setTimeout;
  clearTimeout?: typeof clearTimeout;
  /** Encodes an outgoing frame; default JSON. */
  encode?(frame: Out): string;
}

export interface SocketClient<Out> {
  /** Opens a connection if none is open or connecting. */
  connect(): void;
  /** Sends a frame when the socket is open; false (and nothing sent) otherwise. */
  send(frame: Out): boolean;
  /** Closes for good: no reconnect, no further frames or status reports. */
  close(): void;
  /** Closes the current connection and reconnects at once (the served model changed). */
  reconnect(): void;
  readonly status: SocketStatus;
  readonly connected: boolean;
  readonly closed: boolean;
}

export function createSocket<In = unknown, Out = unknown>(options: SocketOptions<In, Out>): SocketClient<Out> {
  const Socket = options.WebSocket ?? globalThis.WebSocket;
  const setTimer = options.setTimeout ?? globalThis.setTimeout.bind(globalThis);
  const clearTimer = options.clearTimeout ?? globalThis.clearTimeout.bind(globalThis);
  const encode = options.encode ?? ((frame: Out) => JSON.stringify(frame));
  let socket: WebSocket | null = null;
  let status: SocketStatus = "closed";
  let finished = false;
  let timer: ReturnType<typeof setTimeout> | undefined;

  const report = (next: SocketStatus) => { status = next; options.onStatus?.(next); };
  const scheduleReconnect = () => {
    if (finished) return;
    if (timer !== undefined) clearTimer(timer);
    timer = setTimer(() => {
      timer = undefined;
      if (finished) return;
      if (options.shouldReconnect && !options.shouldReconnect()) return;
      connect();
    }, options.reconnectMs ?? 2200);
  };

  function connect(): void {
    if (finished) return;
    if (socket && (socket.readyState === 0 || socket.readyState === 1)) return;
    if (timer !== undefined) { clearTimer(timer); timer = undefined; }
    const url = typeof options.url === "function" ? options.url() : options.url;
    let next: WebSocket;
    try { next = new Socket(url); } catch { report("error"); scheduleReconnect(); return; }
    socket = next;
    report("connecting");
    // Only the current socket may report: a superseded one is detached, whatever it still emits.
    next.onopen = () => { if (socket === next) report("open"); };
    next.onclose = () => { if (socket !== next) return; socket = null; report("closed"); scheduleReconnect(); };
    next.onerror = () => { if (socket === next) report("error"); };
    next.onmessage = (event) => {
      if (socket !== next) return;
      let frame: In;
      try { frame = JSON.parse(String(event.data)); } catch { return; }
      options.onFrame(frame);
    };
  }

  function detach(current: WebSocket): void {
    current.onopen = null; current.onclose = null; current.onerror = null; current.onmessage = null;
  }

  return {
    connect,
    send(frame) {
      if (!socket || socket.readyState !== 1) return false;
      socket.send(encode(frame));
      return true;
    },
    close() {
      finished = true;
      if (timer !== undefined) { clearTimer(timer); timer = undefined; }
      const current = socket;
      socket = null;
      if (current) { detach(current); try { current.close(); } catch { /* already closed */ } }
      if (status !== "closed") report("closed");
    },
    reconnect() {
      if (finished) return;
      const current = socket;
      socket = null;
      if (current) { detach(current); try { current.close(); } catch { /* already closed */ } }
      connect();
    },
    get status() { return status; },
    get connected() { return status === "open"; },
    get closed() { return finished; },
  };
}
