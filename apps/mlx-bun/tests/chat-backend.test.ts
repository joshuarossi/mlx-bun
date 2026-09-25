import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
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
  const surface = buildPiAgentSurface({ readOnly: true, toolNames: ["memory_read"], customTools: [], skillPaths: ["/memory/skill"], hint: "Use memory only when relevant." });
  expect(surface.memoryEnabled).toBe(true);
  expect(surface.memoryToolNames).toEqual(["memory_read"]);
  expect(surface.readOnlyToolNames).toEqual(["memory_read"]);
  expect(surface.skillPaths).toEqual(["/memory/skill"]);
  expect(surface.memoryHint).toBe("Use memory only when relevant.");
});

test("shutdown waits for in-flight message cleanup after initiating cancellation", async () => {
  const work = deferred(); const events: string[] = [];
  const handler = makeChatWebSocketHandler(() => ({ async start() {},
    async handle() { events.push("handling"); await work.promise; events.push("late cleanup"); },
    dispose() { events.push("cancel"); },
  }));
  const client = socket(); await handler.websocket.open!(client.ws);
  const operation = handler.websocket.message(client.ws, '{"type":"fork_session","path":"session"}');
  let closed = false; const closing = handler.dispose().then(() => { closed = true; events.push("closed"); });
  await tick(); await tick(); expect(closed).toBe(false); expect(events).toEqual(["handling", "cancel"]);
  expect(client.closes).toBe(1);
  work.resolve(); await operation; await closing;
  expect(events).toEqual(["handling", "cancel", "late cleanup", "closed"]);
});

test("shutdown preserves peer cleanup failures and still waits for every disposer", async () => {
  const firstFailure = new Error("first cleanup"); const secondFailure = new Error("second cleanup");
  const second = deferred(); let count = 0;
  const handler = makeChatWebSocketHandler(() => {
    const index = count++;
    return { async start() {}, async handle() {}, async dispose() {
      if (index === 0) throw firstFailure;
      await second.promise; throw secondFailure;
    } };
  });
  const a = socket(), b = socket(); await handler.websocket.open!(a.ws); await handler.websocket.open!(b.ws);
  // A disconnected peer's failed cleanup must remain observable at shutdown.
  handler.websocket.close!(a.ws, 1000, ""); await tick(); await tick();
  let settled = false; const closing = handler.dispose().catch(error => { settled = true; return error; });
  await tick(); expect(settled).toBe(false); second.resolve();
  const error = await closing; expect(error).toBeInstanceOf(AggregateError);
  expect(error.errors).toEqual([firstFailure, secondFailure]);
  await expect(handler.dispose()).rejects.toBe(error);
});

test("Pi disposal waits for agent abort before runtime release and is idempotent", async () => {
  const idle = deferred(); const events: string[] = [];
  const backend = createPiBackend({ port: 1 })(() => {});
  const session = { async abort() { events.push("abort"); await idle.promise; events.push("idle"); } };
  Object.assign(backend, { runtime: { session, async dispose() { events.push("runtime dispose"); } }, session });
  let closed = false; const first = backend.dispose()!; const second = backend.dispose()!;
  const closing = Promise.resolve(first).then(() => { closed = true; });
  await tick(); expect(closed).toBe(false); expect(events).toEqual(["abort"]);
  idle.resolve(); await closing; await second;
  expect(events).toEqual(["abort", "idle", "runtime dispose"]);
});

test("Pi still releases its runtime when abort fails and retains both failures", async () => {
  const backend = createPiBackend({ port: 1 })(() => {});
  const abortFailure = new Error("abort failure"), disposeFailure = new Error("dispose failure");
  let releases = 0; const session = { async abort() { throw abortFailure; } };
  Object.assign(backend, { runtime: { session, async dispose() { releases++; throw disposeFailure; } }, session });
  const failure = await Promise.resolve(backend.dispose()).catch(error => error);
  expect(failure).toBeInstanceOf(AggregateError); expect(failure.errors).toEqual([abortFailure, disposeFailure]);
  await expect(Promise.resolve(backend.dispose())).rejects.toBe(failure); expect(releases).toBe(1);
});

test("Pi closes the session published by an SDK replacement that finishes during shutdown", async () => {
  const replacement = deferred(); const events: string[] = [];
  const backend = createPiBackend({ port: 1 })(() => {});
  let current = "old";
  const session = { async abort() { events.push("abort"); } };
  Object.assign(backend, { session, runtime: { session,
    async newSession() { events.push("replace started"); await replacement.promise; current = "new"; events.push("replace ended"); },
    async dispose() { events.push(`dispose ${current}`); },
  }, sendSessions: async () => {}, sendHistory() {}, sendCodingToolsState() {} });
  const changing = backend.handle({ type: "new_session" });
  let closed = false; const closing = Promise.resolve(backend.dispose()).then(() => { closed = true; });
  await tick(); await tick(); expect(closed).toBe(false); expect(events).toEqual(["replace started", "abort"]);
  replacement.resolve(); await changing; await closing;
  expect(events).toEqual(["replace started", "abort", "replace ended", "dispose new"]);
});


test("an injected memory surface must attest read-only behavior", () => {
  expect(() => buildPiAgentSurface({ toolNames: ["unclassified"], customTools: [], skillPaths: [], hint: "" } as never))
    .toThrow("explicitly read-only");
});


test("unclassified tools and injected mutation names still pass through the approval gate", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-approval-class-"));
  const frames: ServerMessage[] = [];
  type Event = { toolName: string; toolCallId: string; input: Record<string, unknown> };
  type Gate = (event: Event) => Promise<{ block: true; reason: string } | undefined>;
  type ApprovalBackend = {
    installApprovalGate(pi: { on(name: string, callback: Gate): void }, readOnly: ReadonlySet<string>): void;
    resolveApproval(id: string, decision: "deny"): void;
  };
  const paths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  const backend = createPiBackend({ port: 1, paths })(frame => {
    frames.push(frame);
    if (frame.type === "tool_approval_request") queueMicrotask(() =>
      (backend as unknown as ApprovalBackend).resolveApproval(frame.callId, "deny"));
  });
  const readOnlyBackend = createPiBackend({ port: 1, paths, readOnly: true })(frame => frames.push(frame));
  const installed = (target: typeof backend) => {
    let gate!: Gate;
    (target as unknown as ApprovalBackend).installApprovalGate({ on(name, callback) {
      expect(name).toBe("tool_call"); gate = callback;
    } }, new Set(["memory_read", "bash"]));
    return gate;
  };
  try {
    const gate = installed(backend);
    expect(await gate({ toolName: "memory_read", toolCallId: "read", input: {} })).toBeUndefined();
    for (const tool of ["unknown_tool", "bash"]) {
      expect(await gate({ toolName: tool, toolCallId: tool, input: {} })).toEqual({ block: true, reason: "Denied by user." });
    }
    expect(frames.filter(frame => frame.type === "tool_approval_request").map(frame => frame.tool))
      .toEqual(["unknown_tool", "bash"]);
    frames.length = 0;
    const readOnlyGate = installed(readOnlyBackend);
    for (const tool of ["unknown_tool", "bash"]) {
      expect(await readOnlyGate({ toolName: tool, toolCallId: tool, input: {} }))
        .toEqual({ block: true, reason: "Read-only session: only read-only tools are allowed." });
    }
    expect(frames).toEqual([]);
  } finally {
    await backend.dispose(); await readOnlyBackend.dispose(); rmSync(root, { recursive: true, force: true });
  }
});
