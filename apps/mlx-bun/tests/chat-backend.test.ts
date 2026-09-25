import { describe, expect, test } from "bun:test";
import type { ServerWebSocket } from "bun";
import { makeChatWebSocketHandler, type ChatBackend, type ChatSocketData, type SendFrame } from "../src/chat/backend";
import { createPiBackend } from "../src/chat/pi-backend";
import { buildPiAgentSurface } from "../src/chat/surface";
import type { ServerMessage } from "../src/chat/protocol";

function socket() {
  const frames: ServerMessage[] = [];
  let closes = 0;
  const ws = { data: { sessionId: crypto.randomUUID() },
    send: (text: string) => { frames.push(JSON.parse(text)); return text.length; },
    close: () => { closes++; },
  } as unknown as ServerWebSocket<ChatSocketData>;
  return { ws, frames, get closes() { return closes; } };
}
function deferred() {
  let resolve!: () => void;
  let reject!: (error: Error) => void;
  const promise = new Promise<void>((yes, no) => { resolve = yes; reject = no; });
  return { promise, resolve, reject };
}
const tick = () => Promise.resolve();

describe("chat socket lifetime", () => {
  test("each handler owns its connections and isolates frame delivery", async () => {
    const senders: SendFrame[] = [];
    const handled: unknown[] = [];
    let disposals = 0;
    const factory = (send: SendFrame): ChatBackend => {
      senders.push(send);
      return { async start() {}, async handle(message) { handled.push(message); }, dispose() { disposals++; } };
    };
    const first = makeChatWebSocketHandler(factory), second = makeChatWebSocketHandler(factory);
    const a = socket(), b = socket();
    await first.websocket.open!(a.ws); await second.websocket.open!(b.ws);
    senders[0]!({ type: "text_delta", delta: "first" });
    expect(a.frames).toEqual([{ type: "text_delta", delta: "first" }]);
    expect(b.frames).toEqual([]);
    await first.websocket.message(a.ws, JSON.stringify({ type: "abort" }));
    expect(handled).toEqual([{ type: "abort" }]);
    await first.dispose();
    expect(disposals).toBe(1);
    senders[0]!({ type: "text_delta", delta: "late" });
    senders[1]!({ type: "text_delta", delta: "second" });
    expect(a.frames).toHaveLength(1);
    expect(b.frames).toEqual([{ type: "text_delta", delta: "second" }]);
    await second.dispose();
    expect(disposals).toBe(2);
  });

  test("failed startup reports the error and releases the backend exactly once", async () => {
    let disposals = 0;
    const handler = makeChatWebSocketHandler(() => ({
      async start() { throw new Error("model unavailable"); }, async handle() {}, dispose() { disposals++; },
    }));
    const client = socket();
    await handler.websocket.open!(client.ws);
    expect(client.frames).toEqual([{ type: "error", message: "model unavailable" }]);
    expect(disposals).toBe(1);
    handler.websocket.close!(client.ws, 1000, "");
    await handler.dispose();
    expect(disposals).toBe(1);
  });

  test("closing during startup cancels ownership and suppresses late frames and errors", async () => {
    const start = deferred();
    let emit!: SendFrame, disposals = 0;
    const handler = makeChatWebSocketHandler(send => {
      emit = send;
      return { start: () => start.promise, async handle() {}, dispose() { disposals++; } };
    });
    const client = socket();
    const opened = handler.websocket.open!(client.ws);
    handler.websocket.close!(client.ws, 1000, "");
    await tick();
    expect(disposals).toBe(1);
    emit({ type: "text_delta", delta: "late" });
    start.reject(new Error("cancelled"));
    await opened; await handler.dispose();
    expect(client.frames).toEqual([]);
    expect(disposals).toBe(1);
  });

  test("shutdown cancels pending turns, awaits cleanup, and stops new sessions", async () => {
    const cleanup = deferred(), startup = deferred();
    let disposals = 0, factories = 0;
    const handler = makeChatWebSocketHandler(() => {
      factories++;
      return { start: () => startup.promise, async handle() {}, async dispose() { disposals++; await cleanup.promise; } };
    });
    const client = socket();
    const opened = handler.websocket.open!(client.ws);
    let done = false;
    const disposing = handler.dispose().then(() => { done = true; });
    await tick();
    expect(disposals).toBe(1); expect(done).toBe(false);
    cleanup.resolve(); await tick(); expect(done).toBe(false);
    startup.resolve(); await opened; await disposing;
    const late = socket(); await handler.websocket.open!(late.ws);
    expect(late.closes).toBe(1); expect(factories).toBe(1);
    await handler.dispose(); expect(disposals).toBe(1);
  });

  test("abort and approval messages stay live while a prompt is pending", async () => {
    const turn = deferred();
    const handled: string[] = [];
    const handler = makeChatWebSocketHandler(() => ({
      async start() {},
      async handle(message) { handled.push(message.type); if (message.type === "prompt") await turn.promise; },
      dispose() { turn.resolve(); },
    }));
    const client = socket(); await handler.websocket.open!(client.ws);
    const prompt = handler.websocket.message(client.ws, '{"type":"prompt","text":"hello"}');
    await handler.websocket.message(client.ws, '{"type":"approval","callId":"x","decision":"deny"}');
    await handler.websocket.message(client.ws, '{"type":"abort"}');
    expect(handled).toEqual(["prompt", "approval", "abort"]);
    await handler.dispose(); await prompt;
  });

  test("bad frames and handler failures become errors without dropping the session", async () => {
    let calls = 0;
    const handler = makeChatWebSocketHandler(() => ({
      async start() {}, async handle() { calls++; throw new Error("bad request"); }, dispose() {},
    }));
    const client = socket(); await handler.websocket.open!(client.ws);
    for (const raw of ["{", "null", "5", "{}", '{"type":"abort"}']) await handler.websocket.message(client.ws, raw);
    expect(calls).toBe(1);
    expect(client.frames).toHaveLength(5);
    expect(client.frames[4]).toEqual({ type: "error", message: "bad request" });
    await handler.dispose();
  });
});

test("Pi construction and absent memory need no native runtime or model", async () => {
  const backend = createPiBackend({ port: 1 })(() => {});
  await backend.dispose();
  await backend.start(); // disposed before startup: no sessions or network are created
  const surface = buildPiAgentSurface();
  expect(surface.memoryEnabled).toBe(false);
  expect(surface.memoryToolNames).toEqual([]);
  expect(surface.skillPaths).toEqual([]);
  expect(surface.memoryHint).toBe("");
  expect(surface.customTools.map(tool => tool.name)).toEqual(["web_search", "web_fetch", "weather"]);
});

test("the memory owner explicitly supplies tool definitions, names, skills, and prompt hint", () => {
  const surface = buildPiAgentSurface({ toolNames: ["memory_read"], customTools: [], skillPaths: ["/memory/skill"], hint: "Use memory only when relevant." });
  expect(surface.memoryEnabled).toBe(true);
  expect(surface.memoryToolNames).toEqual(["memory_read"]);
  expect(surface.skillPaths).toEqual(["/memory/skill"]);
  expect(surface.memoryHint).toBe("Use memory only when relevant.");
});
