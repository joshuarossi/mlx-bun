import type { ServerWebSocket, WebSocketHandler } from "bun";
import type { ClientMessage, ServerMessage } from "./protocol";

/** One connection owns one backend. Disposal cancels active turns and pending approvals.
 * It may race start(); implementations must release resources acquired after disposal. */
export interface ChatBackend {
  start(): Promise<void>;
  handle(message: ClientMessage): Promise<void>;
  dispose(): void | Promise<void>;
}
export type SendFrame = (message: ServerMessage) => void;
export type ChatBackendFactory = (send: SendFrame) => ChatBackend;
export interface ChatSocketData { sessionId: string }

type Socket = ServerWebSocket<ChatSocketData>;
interface Connection {
  backend: ChatBackend;
  closed: boolean;
  disposal?: Promise<void>;
}

/** Transport owns socket lifetime; the backend owns agent/session lifetime.
 * Messages remain concurrent so abort/approval frames can interrupt an active prompt. */
export function makeChatWebSocketHandler(factory: ChatBackendFactory): {
  websocket: WebSocketHandler<ChatSocketData>;
  dispose(): Promise<void>;
} {
  const connections = new Map<Socket, Connection>();
  const disposing = new Set<Promise<void>>();
  const starting = new Set<Promise<void>>();
  const handling = new Set<Promise<void>>();
  const cleanupErrors: unknown[] = [];
  let closing: Promise<void> | undefined;
  let stopped = false;
  const send = (socket: Socket, message: ServerMessage) => {
    try { socket.send(JSON.stringify(message)); } catch { /* disconnected */ }
  };
  const error = (socket: Socket, cause: unknown) => send(socket, {
    type: "error", message: cause instanceof Error ? cause.message : String(cause),
  });
  const release = (connection: Connection): Promise<void> => {
    if (connection.disposal) return connection.disposal;
    connection.closed = true;
    // Socket callbacks cannot return disposal errors to an owner. Retain them
    // for handler shutdown while observing each rejection immediately.
    const done = connection.disposal = Promise.resolve().then(() => connection.backend.dispose())
      .catch(cause => { cleanupErrors.push(cause); });
    disposing.add(done);
    void done.finally(() => disposing.delete(done));
    return done;
  };
  return {
    websocket: {
      async open(socket) {
        if (stopped) { socket.close(); return; }
        let connection: Connection | undefined;
        try {
          const backend = factory(message => {
            if (!stopped && connection && !connection.closed) send(socket, message);
          });
          connection = { backend, closed: false };
          connections.set(socket, connection);
          const start = backend.start();
          starting.add(start);
          try { await start; } finally { starting.delete(start); }
        } catch (cause) {
          if (!stopped && !connection?.closed) error(socket, cause);
          connections.delete(socket);
          if (connection) await release(connection);
          // Failed startup must not leave an untracked transport blocking listener drain.
          socket.close(1011, "Chat startup failed");
        }
      },
      async message(socket, raw) {
        const connection = connections.get(socket);
        if (!connection || connection.closed) { if (!stopped) error(socket, "no active session"); return; }
        let message: ClientMessage;
        try {
          const parsed: unknown = JSON.parse(typeof raw === "string" ? raw : raw.toString("utf8"));
          if (!parsed || typeof parsed !== "object" || typeof (parsed as { type?: unknown }).type !== "string") throw new Error();
          message = parsed as ClientMessage;
        } catch { error(socket, "invalid JSON message"); return; }
        try {
          const operation = connection.backend.handle(message);
          handling.add(operation);
          try { await operation; } finally { handling.delete(operation); }
        } catch (cause) { if (!connection.closed) error(socket, cause); }
      },
      close(socket) {
        const connection = connections.get(socket);
        connections.delete(socket);
        if (connection) void release(connection);
      },
    },
    dispose() {
      return closing ??= (async () => {
        stopped = true;
        for (const [socket, connection] of [...connections]) {
          void release(connection);
          try { socket.close(1001, "Server shutting down"); } catch (error) { cleanupErrors.push(error); }
        }
        connections.clear();
        await Promise.all([...disposing]);
        // Cancel first, then join work that can acquire/release resources after
        // an await. Messages remain concurrent during the connection lifetime.
        await Promise.allSettled([...starting, ...handling]);
        await Promise.all([...disposing]);
        if (cleanupErrors.length === 1) throw cleanupErrors[0];
        if (cleanupErrors.length) throw new AggregateError(cleanupErrors, "chat cleanup failed");
      })();
    },
  };
}
