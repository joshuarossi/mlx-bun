// Module sockets on a real Bun listener: only declared paths upgrade, every connection keeps one peer, a handler that
// throws closes only its own connection, and frames are delivered as text.
import { afterEach, expect, test } from "bun:test";
import type { SocketHandler, SocketPeer } from "@mlx-bun/app-core";
import { createModuleSockets, type ModuleSocketData } from "../src";

const servers: ReturnType<typeof Bun.serve>[] = [];
afterEach(() => { for (const server of servers.splice(0)) void server.stop(true); });

function listen(handlers: Record<string, SocketHandler>) {
  const sockets = createModuleSockets(Object.entries(handlers).map(([path, handler]) => ({ path, handler })));
  const server = Bun.serve<ModuleSocketData>({ port: 0, hostname: "127.0.0.1", websocket: sockets.websocket,
    fetch(request, listener) { return sockets.upgrade(request, listener) ?? new Response("not a socket", { status: 404 }); } });
  servers.push(server);
  return server;
}
const open = (server: ReturnType<typeof Bun.serve>, path: string) => new Promise<WebSocket>((resolve, reject) => {
  const socket = new WebSocket(`ws://127.0.0.1:${server.port}${path}`);
  socket.onopen = () => resolve(socket); socket.onerror = () => reject(new Error("no upgrade"));
});
const next = (socket: WebSocket) => new Promise<string>(resolve => { socket.onmessage = event => resolve(String(event.data)); });
const closed = (socket: WebSocket) => new Promise<{ code: number; reason: string }>(resolve => { socket.onclose = event => resolve({ code: event.code, reason: event.reason }); });

test("a declared path upgrades and reaches its handler with the request, one stable peer and text frames", async () => {
  const peers: SocketPeer[] = [], opened: string[] = [], log: string[] = [];
  const server = listen({ "/ws/echo": {
    open(peer, request) { peers.push(peer); opened.push(new URL(request.url).pathname); },
    message(peer, data) { peers.push(peer); peer.send(`echo ${data}`); },
    close(peer) { peers.push(peer); log.push("closed"); },
  } });
  const socket = await open(server, "/ws/echo");
  socket.send("hello");
  expect(await next(socket)).toBe("echo hello");
  socket.send(new TextEncoder().encode("bytes"));
  expect(await next(socket)).toBe("echo bytes");
  socket.close();
  await Bun.sleep(20);
  expect(opened).toEqual(["/ws/echo"]);
  expect(new Set(peers).size).toBe(1);
  expect(log).toEqual(["closed"]);
});

test("a path no module declared, and a non-GET request, fall through; a plain request to a socket path is refused with 426", async () => {
  const server = listen({ "/ws/echo": { message() {} } });
  expect((await fetch(`http://127.0.0.1:${server.port}/ws/other`)).status).toBe(404);
  expect((await fetch(`http://127.0.0.1:${server.port}/ws/echo`, { method: "POST" })).status).toBe(404);
  expect((await fetch(`http://127.0.0.1:${server.port}/ws/echo`)).status).toBe(426);
  await expect(open(server, "/ws/other")).rejects.toThrow("no upgrade");
});

test("the handler closes a connection with a code and reason, and one that throws closes only its own connection", async () => {
  const server = listen({
    "/ws/close": { open(peer) { peer.close(1001, "going away"); }, message() {} },
    "/ws/throws": { message(peer, data) { if (data === "boom") throw new Error("boom"); peer.send("ok"); } },
  });
  const first = await new Promise<WebSocket>(resolve => { const s = new WebSocket(`ws://127.0.0.1:${server.port}/ws/close`); s.onopen = () => resolve(s); });
  expect(await closed(first)).toEqual({ code: 1001, reason: "going away" });
  const a = await open(server, "/ws/throws"), b = await open(server, "/ws/throws");
  const originalError = console.error; const messages: string[] = [];
  console.error = (line: string) => { messages.push(line); };
  try {
    const gone = closed(a);
    a.send("boom");
    expect((await gone).code).toBe(1011);
  } finally { console.error = originalError; }
  b.send("fine");
  expect(await next(b)).toBe("ok");
  expect(messages).toEqual(["[sockets] /ws/throws: boom"]);
});
