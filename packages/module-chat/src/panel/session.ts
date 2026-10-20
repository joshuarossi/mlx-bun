// The chat's socket session: one JSON-framed WebSocket to the module's `/ws/chat` over the kit's `createSocket`
// (frames are `ClientMessage` out and `ServerMessage` in). The chat is a workspace panel, so leaving its page never
// closes the socket: a turn in flight survives a visit elsewhere. After an unexpected close it reconnects, but only
// while the chat page is showing; otherwise the next `connect()` (the page is entered again) does. Each connection
// starts on a fresh server session, so the session remembers which saved chat it was in (from `sessions` frames)
// and reopens it on the next `ready`. A served-model change (the host's `HOST_EVENTS.modelChanged`) reconnects at
// once when no turn is in flight, so the capabilities `ready` reports describe the model that will answer.
//
// There is no client-side heartbeat: the socket's own close tells the session the server went away.
import { createSocket, HOST_EVENTS, onHostEvent, type Api, type SocketStatus } from "@mlx-bun/web-kit";
import type { ClientMessage, ServerMessage } from "../protocol";

export type { SocketStatus };

export interface ChatSessionOptions {
  /** The socket URL (`chatSocketUrl`), read on every connection. */
  url: string | (() => string);
  onFrame(frame: ServerMessage): void;
  onStatus(status: SocketStatus): void;
  /** The chat page is showing: a dropped connection reconnects only then. */
  isActive(): boolean;
  /** A turn is streaming: a model change does not reconnect under it. */
  busy(): boolean;
}

export interface ChatSession {
  /** Opens a connection unless one is open or opening (the chat page was entered). */
  connect(): void;
  /** Sends a frame; false (and nothing sent) when the socket is not open. */
  send(frame: ClientMessage): boolean;
  readonly connected: boolean;
  /** Closes for good and drops the model-change listener (the panel left the document). */
  close(): void;
}

/** The module's socket (`mount: "root"`, so the path is the shipped one) on the origin of the connection's `apiBase`:
 * this page's own for a relative base, the server's in a native webview. */
export function chatSocketUrl(api: Api): string {
  const url = new URL(api.url("/ws/chat"), document.baseURI);
  url.protocol = url.protocol === "https:" ? "wss:" : "ws:";
  return url.href;
}

/** What the composer's status line says about the connection, and the state its dot shows. */
export function statusCopy(status: SocketStatus): { text: string; tone: "" | "ok" | "bad" } {
  switch (status) {
    case "open": return { text: "Connected. Enter sends, Shift+Enter adds a line, # attaches a file or recalls a memory.", tone: "ok" };
    case "connecting": return { text: "Connecting to the model server…", tone: "" };
    case "error": return { text: "The connection to the model server failed. Reconnecting…", tone: "bad" };
    case "closed": return { text: "Not connected to the model server yet. Reconnecting…", tone: "bad" };
  }
}

export function createChatSession(options: ChatSessionOptions): ChatSession {
  // The saved chat this connection is in, and the one to reopen on the next connection's `ready`.
  let activePath: string | null = null;
  let resumePath: string | null = null;
  const socket = createSocket<ServerMessage, ClientMessage>({
    url: options.url,
    shouldReconnect: () => options.isActive(),
    onStatus(status) {
      if (status === "connecting") resumePath = activePath;
      options.onStatus(status);
    },
    onFrame(frame) {
      if (frame.type === "sessions") activePath = frame.activePath || null;
      options.onFrame(frame);
      // After the controller has re-asserted this browser's settings for the new connection.
      if (frame.type === "ready" && resumePath) {
        const path = resumePath;
        resumePath = null;
        socket.send({ type: "open_session", path });
      }
    },
  });
  const stopListening = onHostEvent(HOST_EVENTS.modelChanged, () => {
    if (!options.busy() && socket.connected) socket.reconnect();
  });
  return {
    connect: () => socket.connect(),
    send: (frame) => socket.send(frame),
    get connected() { return socket.connected; },
    close() { stopListening(); socket.close(); },
  };
}
