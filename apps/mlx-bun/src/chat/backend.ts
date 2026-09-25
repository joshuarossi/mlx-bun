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
  let stopped = false;
  const send = (socket: Socket, message: ServerMessage) => {
    try { socket.send(JSON.stringify(message)); } catch { /* disconnected */ }
  };
  const error = (socket: Socket, cause: unknown) => send(socket, {
    type: "error", message: cause instanceof Error ? cause.message : String(cause),
  });
  const release = (connection: Connection): Promise<void> => {
    if (connection.closed) return Promise.resolve();
    connection.closed = true;
    const done = Promise.resolve().then(() => connection.backend.dispose()).then(() => {}, () => {});
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
        try { await connection.backend.handle(message); }
        catch (cause) { if (!connection.closed) error(socket, cause); }
      },
      close(socket) {
        const connection = connections.get(socket);
        connections.delete(socket);
        if (connection) void release(connection);
      },
    },
    async dispose() {
      stopped = true;
      for (const connection of connections.values()) void release(connection);
      connections.clear();
      await Promise.all([...disposing]);
      await Promise.allSettled([...starting]);
    },
  };
}
