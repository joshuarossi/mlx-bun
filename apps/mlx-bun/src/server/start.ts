import type { ChatBackendFactory, ChatSocketData } from "../chat/backend";
import { makeChatWebSocketHandler } from "../chat/backend";
import type { createCompletionRoutes } from "./routes";

// Temporary migration responses for known surfaces. Remove each entry when its
// owning handler is mounted; unknown routes remain 404.
const pending = [
  /^\/v1\/(?:messages|responses|audio\/(?:transcriptions|translations|speech)|adapters(?:\/[^/]+)?|memory\/synthesize)$/,
  /^\/api\/settings\/hf-token$/,
  /^\/api\/jobs(?:\/[^/]+(?:\/stream)?)?$/,
  /^\/api\/quantize\/(?:inspect|resolve-folder|submit|push)$/,
  /^\/api\/finetune\/(?:inspect-dataset|submit|merge|export|push)$/,
  /^\/api\/dataset\/(?:templates|submit|push)$/,
  /^\/api\/model\/resolve-folder$/,
  /^\/api\/memory\/(?:status|list|search|article|links|history|diff|init)$/,
  /^\/admin\/(?:cache\/(?:session\/close|flush)|lease|drain)$/,
  /^\/(?:generate|signal|fit|stats|curves|dag|engine)$/,
];
export function pendingRoute(path: string): boolean { return pending.some(pattern => pattern.test(path)); }

/** Bind the app's HTTP/WebSocket surfaces. Ownership transfers on entry: a
 * failed bind or close releases chat first, then the caller's engine resources.
 * The web handler serves already-built assets and never loads a model. */
export async function startServer(input: {
  routes: Pick<ReturnType<typeof createCompletionRoutes>, "handle">;
  web(request: Request): Response | null;
  chat: ChatBackendFactory;
  closeEngine(): Promise<void>;
}, options: { port?: number; hostname?: string } = {}) {
  const chat = makeChatWebSocketHandler(input.chat);
  let closing: Promise<void> | undefined;
  let stopped = false;
  let server: ReturnType<typeof Bun.serve<ChatSocketData>> | undefined;
  const close = () => closing ??= (async () => {
    stopped = true;
    const errors: unknown[] = [];
    try { await chat.dispose(); } catch (error) { errors.push(error); }
    try { await server?.stop(true); } catch (error) { errors.push(error); }
    try { await input.closeEngine(); } catch (error) { errors.push(error); }
    if (errors.length) throw new AggregateError(errors, "server cleanup failed");
  })();
  try {
    server = Bun.serve<ChatSocketData>({
      port: options.port ?? 8080,
      hostname: options.hostname ?? "127.0.0.1",
      idleTimeout: 0,
      websocket: chat.websocket,
      async fetch(request, listener) {
        if (stopped) return Response.json({ error: { message: "server is shutting down" } }, { status: 503 });
        const url = new URL(request.url);
        if (url.pathname === "/ws/chat" && request.method === "GET") {
          if (listener.upgrade(request, { data: { sessionId: crypto.randomUUID() } })) return;
          return new Response("WebSocket upgrade required", { status: 426 });
        }
        const page = input.web(request);
        if (page) return page;
        const response = await input.routes.handle(request);
        if (response) return response;
        if (pendingRoute(url.pathname)) return Response.json({ error: {
          message: "This feature has not migrated yet.", type: "not_implemented", path: url.pathname,
        } }, { status: 501 });
        return Response.json({ error: { message: "Not found" } }, { status: 404 });
      },
    });
    return { server, close };
  } catch (error) {
    try { await close(); } catch (cleanup) { throw new AggregateError([error, cleanup], "server startup and cleanup failed"); }
    throw error;
  }
}
