import { expect, test } from "bun:test";
import { startServer } from "../src/server/start";
import type { ChatBackendFactory } from "../src/chat/backend";

const idle: ChatBackendFactory = () => ({ async start() {}, async handle() {}, dispose() {} });
function connection(url: URL) {
  const socket = new WebSocket(new URL("/ws/chat", url).href.replace("http:", "ws:"));
  const opened = new Promise<void>((resolve, reject) => {
    socket.addEventListener("open", () => resolve(), { once: true });
    socket.addEventListener("error", () => reject(new Error("socket failed")), { once: true });
  });
  return { socket, opened };
}

test("the mounted app serves implemented routes, explicit migration gaps, and unknown paths separately", async () => {
  let disposals = 0;
  const app = await startServer({
    web: request => new URL(request.url).pathname === "/" ? new Response("web") : null,
    routes: { async handle(request) { return new URL(request.url).pathname === "/health" ? Response.json({ status: "ok" }) : null; } },
    chat: idle, async closeEngine() { disposals++; },
  }, { port: 0 });
  try {
    expect(await (await fetch(app.server.url)).text()).toBe("web");
    expect(await (await fetch(new URL("/health", app.server.url))).json()).toEqual({ status: "ok" });
    for (const path of ["/api/settings/hf-token", "/api/quantize/submit", "/api/jobs/id/stream", "/api/memory/status", "/v1/audio/transcriptions", "/admin/cache/flush", "/stats"]) {
      const response = await fetch(new URL(path, app.server.url));
      expect(response.status).toBe(501);
      expect((await response.json()).error.type).toBe("not_implemented");
    }
    for (const path of ["/unknown", "/api/quantize/nonsense", "/toString"]) {
      expect((await fetch(new URL(path, app.server.url))).status).toBe(404);
    }
    expect((await fetch(new URL("/ws/chat", app.server.url))).status).toBe(426);
  } finally { await app.close(); }
  await app.close();
  expect(disposals).toBe(1);
});

test("live WebSocket chat handles frames and cancels before engine disposal", async () => {
  const events: string[] = [];
  const app = await startServer({
    web: () => null, routes: { async handle() { return null; } },
    chat: send => ({
      async start() { events.push("start"); },
      async handle(message) { events.push(message.type); send({ type: "text_delta", delta: "ready" }); },
      async dispose() { events.push("chat-close"); },
    }),
    async closeEngine() { events.push("engine-close"); },
  }, { port: 0 });
  const client = connection(app.server.url);
  try {
    await client.opened;
    const frame = new Promise<unknown>(resolve => client.socket.addEventListener("message", event => resolve(JSON.parse(event.data)), { once: true }));
    client.socket.send(JSON.stringify({ type: "abort" }));
    expect(await frame).toEqual({ type: "text_delta", delta: "ready" });
    await Promise.all([app.close(), app.close()]);
    expect(events).toEqual(["start", "abort", "chat-close", "engine-close"]);
  } finally { client.socket.close(); await app.close(); }
});

test("bind failure transfers cleanup ownership without requiring a returned server", async () => {
  const occupied = Bun.serve({ hostname: "127.0.0.1", port: 0, fetch: () => new Response() });
  let disposed = 0;
  try {
    await expect(startServer({ web: () => null, routes: { async handle() { return null; } }, chat: idle,
      async closeEngine() { disposed++; },
    }, { port: occupied.port })).rejects.toThrow();
    expect(disposed).toBe(1);
  } finally { await occupied.stop(true); }
});

test("engine cleanup errors are reported once after the listener has stopped", async () => {
  let disposed = 0;
  const app = await startServer({ web: () => null, routes: { async handle() { return null; } }, chat: idle,
    async closeEngine() { disposed++; throw new Error("cache flush failed"); },
  }, { port: 0 });
  await expect(app.close()).rejects.toThrow("server cleanup failed");
  await expect(app.close()).rejects.toThrow("server cleanup failed");
  expect(disposed).toBe(1);
  await expect(fetch(app.server.url)).rejects.toThrow();
});

test("shutdown aborts an active HTTP stream before releasing engine resources", async () => {
  const events: string[] = [];
  const app = await startServer({
    web: () => null, chat: idle,
    routes: { async handle(request) {
      request.signal.addEventListener("abort", () => events.push("request-abort"), { once: true });
      return new Response(new ReadableStream({ start(controller) { controller.enqueue(new TextEncoder().encode("data: ready\n\n")); } }),
        { headers: { "content-type": "text/event-stream" } });
    } },
    async closeEngine() { events.push("engine-close"); },
  }, { port: 0 });
  const request = new AbortController();
  try {
    const response = await fetch(app.server.url, { signal: request.signal });
    const reader = response.body!.getReader();
    expect((await reader.read()).done).toBe(false);
    await app.close();
    expect(events).toEqual(["request-abort", "engine-close"]);
    await reader.cancel().catch(() => {});
  } finally { request.abort(); await app.close(); }
});
