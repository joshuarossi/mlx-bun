import { chmodSync, rmSync } from "node:fs";
import type { ChatBackendFactory, ChatSocketData } from "../chat/backend";
import { makeChatWebSocketHandler } from "../chat/backend";
import type { createCompletionRoutes } from "./routes";

// Temporary migration responses for known surfaces. Remove each entry when its
// owning handler is mounted; unknown routes remain 404. Main's lab pages
// (/generate, /signal, /curves, /curve-terrain, /dag) are not product surface
// and answer 404. Lease, drain, and /engine wait on the isolation decision.
const pending = [
  /^\/admin\/(?:lease|drain)$/,
  /^\/engine$/,
];
export function pendingRoute(path: string): boolean { return pending.some(pattern => pattern.test(path)); }

/** Bind the app's HTTP/WebSocket surfaces. Ownership transfers on entry: a
 * failed bind or close releases chat first, then the caller's engine resources.
 * The web handler serves already-built assets and never loads a model. */
export async function startServer(input: {
  routes: Pick<ReturnType<typeof createCompletionRoutes>, "handle">;
  web(request: Request): Response | null;
  chat: ChatBackendFactory;
  /** Stop background producers and cancel managed jobs while the engine is alive,
   * before waiting for HTTP/SSE responses to drain. */
  beforeDrain?(): void | Promise<void>;
  closeEngine(): Promise<void>;
}, options: { port?: number; hostname?: string;
  /** Internal (worker mode): bind this Unix socket path instead of TCP; `port`
   * and `hostname` are then ignored. A stale file is replaced, the socket is
   * narrowed to owner-only right after the bind, and close removes it. */
  unix?: string } = {}) {
  const chat = makeChatWebSocketHandler(input.chat);
  let closing: Promise<void> | undefined;
  let stopped = false;
  let server: ReturnType<typeof Bun.serve<ChatSocketData>> | undefined;
  const close = () => closing ??= (async () => {
    stopped = true;
    const errors: unknown[] = [];
    try { await input.beforeDrain?.(); } catch (error) { errors.push(error); }
    try { await chat.dispose(); } catch (error) { errors.push(error); }
    try { await server?.stop(false); } catch (error) { errors.push(error); }
    finally { if (options.unix) rmSync(options.unix, { force: true }); }
    try { await input.closeEngine(); } catch (error) { errors.push(error); }
    if (errors.length) throw new AggregateError(errors, "server cleanup failed");
  })();
  try {
    if (options.unix) rmSync(options.unix, { force: true });
    const handlers = {
      idleTimeout: 0,
      websocket: chat.websocket,
      async fetch(request: Request, listener: ReturnType<typeof Bun.serve<ChatSocketData>>) {
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
    };
    // bun-types declares idleTimeout for TCP listeners only; the runtime takes
    // the same options for a Unix listener, where a job's idle lease connection
    // must never time out either.
    server = options.unix
      ? Bun.serve<ChatSocketData>({ unix: options.unix, ...handlers } as unknown as Parameters<typeof Bun.serve<ChatSocketData>>[0])
      : Bun.serve<ChatSocketData>({ port: options.port ?? 8080, hostname: options.hostname ?? "127.0.0.1", ...handlers });
    if (options.unix) chmodSync(options.unix, 0o600);
    return { server, close };
  } catch (error) {
    try { await close(); } catch (cleanup) { throw new AggregateError([error, cleanup], "server startup and cleanup failed"); }
    throw error;
  }
}
