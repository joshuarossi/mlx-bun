// Serving what modules declare as sockets: their WebSocket paths on a Bun listener. The host puts
// `upgrade` in its fetch (before its other groups) and `websocket` in its `Bun.serve` options; each
// connection's frames then reach the module's `SocketHandler` through one stable `SocketPeer`.
import type { ServerWebSocket, WebSocketHandler } from "bun";
import type { SocketHandler, SocketPeer } from "@mlx-bun/app-core";
import type { MountedSocket } from "@mlx-bun/app-host";

/** What a connection carries on the listener; `Bun.serve<ModuleSocketData>` types the handler below. */
export interface ModuleSocketData {
  readonly path: string;
  readonly request: Request;
  peer?: SocketPeer;
}

/** The part of a Bun listener an upgrade needs (`server.upgrade`). */
export interface Upgrader {
  upgrade(request: Request, options: { data: ModuleSocketData }): boolean;
}

export interface ModuleSockets {
  /** `null`: the request names none of the declared paths; `undefined`: the connection was upgraded (return it from `fetch`); a `Response`: the path is a socket but the request is not an upgrade. */
  upgrade(request: Request, server: Upgrader): Response | undefined | null;
  readonly websocket: WebSocketHandler<ModuleSocketData>;
}

const text = (raw: string | Buffer | ArrayBuffer | Uint8Array): string =>
  typeof raw === "string" ? raw : new TextDecoder().decode(raw instanceof ArrayBuffer ? new Uint8Array(raw) : raw);

export function createModuleSockets(sockets: readonly Pick<MountedSocket, "path" | "handler">[]): ModuleSockets {
  const handlers = new Map<string, SocketHandler>(sockets.map(socket => [socket.path, socket.handler]));
  const peerOf = (ws: ServerWebSocket<ModuleSocketData>): SocketPeer =>
    ws.data.peer ??= { send: data => { ws.send(data); }, close: (code, reason) => { ws.close(code, reason); } };
  /** A handler that throws must not take the listener's other connections with it. */
  const guarded = async (ws: ServerWebSocket<ModuleSocketData>, work: () => void | Promise<void>) => {
    try { await work(); } catch (error) {
      console.error(`[sockets] ${ws.data.path}: ${error instanceof Error ? error.message : String(error)}`);
      try { ws.close(1011, "socket handler failed"); } catch { /* already closed */ }
    }
  };
  return {
    upgrade(request, server) {
      const { pathname } = new URL(request.url);
      if (request.method !== "GET" || !handlers.has(pathname)) return null;
      if (server.upgrade(request, { data: { path: pathname, request } })) return undefined;
      return new Response("WebSocket upgrade required", { status: 426 });
    },
    websocket: {
      open: ws => guarded(ws, () => handlers.get(ws.data.path)!.open?.(peerOf(ws), ws.data.request)),
      message: (ws, raw) => guarded(ws, () => handlers.get(ws.data.path)!.message(peerOf(ws), text(raw))),
      close: ws => guarded(ws, () => handlers.get(ws.data.path)!.close?.(peerOf(ws))),
    },
  };
}
