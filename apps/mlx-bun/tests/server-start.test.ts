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
    for (const path of ["/api/settings/hf-token", "/api/quantize/push", "/api/dataset/submit", "/api/memory/status", "/v1/audio/transcriptions", "/admin/cache/flush", "/stats", "/api/hub/local", "/api/hub/search", "/api/hub/download",
      "/api/hub/serve", "/api/sessions/search", "/api/sessions/export", "/curve-terrain",
      "/v1/audio/sessions", "/v1/audio/sessions/session/audio", "/v1/audio/sessions/session/finish",
      "/admin/transcription/unload"]) {
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

test("shutdown stops background work then drains a delayed HTTP stream before releasing engine resources", async () => {
  const events: string[] = [];
  let stream!: ReadableStreamDefaultController<Uint8Array>;
  const app = await startServer({
    web: () => null, chat: idle,
    beforeDrain() { events.push("timer stop"); },
    routes: { async handle(request) {
      request.signal.addEventListener("abort", () => events.push("request-abort"), { once: true });
      return new Response(new ReadableStream({ start(controller) {
        stream = controller; controller.enqueue(new TextEncoder().encode("data: ready\n\n"));
      } }), { headers: { "content-type": "text/event-stream" } });
    } },
    async closeEngine() { events.push("engine-close"); },
  }, { port: 0 });
  const request = new AbortController();
  try {
    const response = await fetch(app.server.url, { signal: request.signal });
    const reader = response.body!.getReader();
    expect((await reader.read()).done).toBe(false);
    const closing = app.close();
    await Bun.sleep(5);
    expect(events).toEqual(["timer stop"]);
    stream.enqueue(new TextEncoder().encode("data: complete\n\n")); stream.close();
    expect(new TextDecoder().decode((await reader.read()).value)).toContain("data: complete");
    expect((await reader.read()).done).toBe(true);
    await closing;
    expect(events).toEqual(["timer stop", "engine-close"]);
  } finally { request.abort(); await app.close(); }
});

test("shutdown joins delayed chat work and reports cleanup failure after engine disposal", async () => {
  const events: string[] = [];
  const handled = Promise.withResolvers<void>();
  const finish = Promise.withResolvers<void>();
  const disposed = Promise.withResolvers<void>();
  const app = await startServer({
    web: () => null, routes: { async handle() { return null; } },
    chat: () => ({
      async start() {},
      async handle() { handled.resolve(); await finish.promise; events.push("late-cleanup"); },
      dispose() { events.push("chat-close"); disposed.resolve(); throw new Error("chat cleanup failed"); },
    }),
    async closeEngine() { events.push("engine-close"); },
  }, { port: 0 });
  const client = connection(app.server.url);
  try {
    await client.opened;
    client.socket.send(JSON.stringify({ type: "abort" }));
    await handled.promise;
    const closed = app.close().then(() => undefined, error => error);
    await disposed.promise;
    expect(events).toEqual(["chat-close"]);
    finish.resolve();
    expect((await closed).message).toBe("server cleanup failed");
    expect(events).toEqual(["chat-close", "late-cleanup", "engine-close"]);
  } finally { finish.resolve(); client.socket.close(); await app.close().catch(() => {}); }
});


test("the listener preserves handler 499 and 501 envelopes on the HTTP wire", async () => {
  const app = await startServer({ web: () => null, chat: idle, async closeEngine() {},
    routes: { async handle(request) {
      const status = new URL(request.url).pathname === "/cancelled" ? 499 : 501;
      return Response.json({ error: { message: status === 499 ? "Request cancelled" : "unsupported execution" } }, { status });
    } },
  }, { port: 0 });
  try {
    for (const [path, status, message] of [["/cancelled", 499, "Request cancelled"], ["/unsupported", 501, "unsupported execution"]] as const) {
      const response = await fetch(new URL(path, app.server.url));
      expect(response.status).toBe(status); expect(await response.json()).toEqual({ error: { message } });
    }
  } finally { await app.close(); }
});


test("shutdown awaits producer cancellation before listener drain and engine release", async () => {
  const events: string[] = [], cancel = Promise.withResolvers<void>();
  const app = await startServer({ web: () => null, routes: { async handle() { return new Response("ready"); } }, chat: idle,
    async beforeDrain() { events.push("cancel jobs"); await cancel.promise; events.push("jobs closed"); },
    async closeEngine() { events.push("engine-close"); },
  }, { port: 0 });
  const closing = app.close();
  try {
    expect(events).toEqual(["cancel jobs"]);
    expect((await fetch(app.server.url)).status).toBe(503);
    expect(events).toEqual(["cancel jobs"]);
    cancel.resolve(); await closing;
    expect(events).toEqual(["cancel jobs", "jobs closed", "engine-close"]);
  } finally { cancel.resolve(); await closing; }
});

test("failed chat startup closes its transport so graceful listener drain can finish", async () => {
  let disposed = 0;
  const app = await startServer({ web: () => null, routes: { async handle() { return null; } },
    chat: () => ({ async start() { throw new Error("session failed"); }, async handle() {}, dispose() {} }),
    async closeEngine() { disposed++; },
  }, { port: 0 });
  const client = connection(app.server.url);
  const closed = new Promise<void>(resolve => client.socket.addEventListener("close", () => resolve(), { once: true }));
  try { await client.opened; await closed; await app.close(); expect(disposed).toBe(1); }
  finally { client.socket.close(); await app.close(); }
});
