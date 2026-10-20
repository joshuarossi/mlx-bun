// The socket client over the fake WebSocket: status reporting, frames, sends while closed, reconnect after an
// unexpected close, no reconnect after close(), a superseded socket's late events, and reconnect() on demand.
import { beforeEach, describe, expect, it } from "bun:test";
import { createSocket, type SocketStatus } from "../src";
import { FakeWebSocket } from "../src/testing";

/** Fake timers: a reconnect fires when the test says so. */
function timers() {
  const queue: { id: number; fn: () => void }[] = [];
  let next = 1;
  return {
    setTimeout: ((fn: () => void) => { const id = next++; queue.push({ id, fn }); return id; }) as unknown as typeof setTimeout,
    clearTimeout: ((id: number) => { const index = queue.findIndex((item) => item.id === id); if (index >= 0) queue.splice(index, 1); }) as unknown as typeof clearTimeout,
    fire() { for (const item of queue.splice(0)) item.fn(); },
    get pending() { return queue.length; },
  };
}

beforeEach(() => FakeWebSocket.reset());

describe("createSocket", () => {
  it("connects, reports status, delivers parsed frames, and sends only while open", () => {
    const clock = timers();
    const frames: unknown[] = [], status: SocketStatus[] = [];
    const client = createSocket<{ type: string }, { type: string }>({ url: "ws://x/ws/chat", onFrame: (frame) => frames.push(frame), onStatus: (s) => status.push(s), WebSocket: FakeWebSocket as unknown as typeof WebSocket, ...clock });
    expect(client.send({ type: "early" })).toBe(false);
    client.connect();
    const socket = FakeWebSocket.last()!;
    expect(socket.url).toBe("ws://x/ws/chat");
    expect(client.status).toBe("connecting");
    client.connect(); // no second socket while one is connecting
    expect(FakeWebSocket.instances).toHaveLength(1);
    socket.open();
    expect(client.connected).toBe(true);
    expect(client.send({ type: "prompt" })).toBe(true);
    expect(socket.sent).toEqual([{ type: "prompt" }]);
    socket.emit({ type: "ready" });
    socket.emit("not json");
    expect(frames).toEqual([{ type: "ready" }]);
    expect(status).toEqual(["connecting", "open"]);
  });

  it("reconnects after an unexpected close when the owner allows it, and only then", () => {
    const clock = timers();
    let active = true;
    const status: SocketStatus[] = [];
    const client = createSocket({ url: () => "ws://x/ws", onFrame() {}, onStatus: (s) => status.push(s), shouldReconnect: () => active, WebSocket: FakeWebSocket as unknown as typeof WebSocket, ...clock });
    client.connect();
    FakeWebSocket.last()!.open();
    FakeWebSocket.last()!.drop();
    expect(status).toEqual(["connecting", "open", "error", "closed"]);
    expect(clock.pending).toBe(1);
    active = false;
    clock.fire();
    expect(FakeWebSocket.instances).toHaveLength(1); // hidden page: no attempt
    active = true;
    client.connect();
    expect(FakeWebSocket.instances).toHaveLength(2);
    FakeWebSocket.last()!.open();
    FakeWebSocket.last()!.drop();
    clock.fire();
    expect(FakeWebSocket.instances).toHaveLength(3);
    expect(client.status).toBe("connecting");
  });

  it("close() is final: the socket closes, no reconnect fires, and nothing more is reported", () => {
    const clock = timers();
    const status: SocketStatus[] = [], frames: unknown[] = [];
    const client = createSocket({ url: "ws://x", onFrame: (f) => frames.push(f), onStatus: (s) => status.push(s), WebSocket: FakeWebSocket as unknown as typeof WebSocket, ...clock });
    client.connect();
    const socket = FakeWebSocket.last()!;
    socket.open();
    client.close();
    expect(socket.closedByClient).toBe(true);
    expect(client.closed).toBe(true);
    expect(clock.pending).toBe(0);
    socket.emit({ type: "late" });
    client.connect();
    expect(FakeWebSocket.instances).toHaveLength(1);
    expect(frames).toEqual([]);
    expect(status).toEqual(["connecting", "open", "closed"]);
    expect(FakeWebSocket.live).toEqual([]);
  });

  it("reconnect() replaces the connection at once and a superseded socket's events are ignored", () => {
    const clock = timers();
    const status: SocketStatus[] = [], frames: unknown[] = [];
    const client = createSocket({ url: "ws://x", onFrame: (f) => frames.push(f), onStatus: (s) => status.push(s), WebSocket: FakeWebSocket as unknown as typeof WebSocket, ...clock });
    client.connect();
    const first = FakeWebSocket.last()!;
    first.open();
    client.reconnect();
    const second = FakeWebSocket.last()!;
    expect(second).not.toBe(first);
    expect(first.closedByClient).toBe(true);
    first.onmessage?.(new MessageEvent("message", { data: JSON.stringify({ type: "stale" }) }));
    first.onclose?.(new Event("close"));
    expect(frames).toEqual([]);
    expect(clock.pending).toBe(0); // the old socket's close scheduled nothing
    second.open();
    second.emit({ type: "fresh" });
    expect(frames).toEqual([{ type: "fresh" }]);
    expect(status).toEqual(["connecting", "open", "connecting", "open"]);
  });

  it("a constructor failure reports an error and schedules a retry", () => {
    const clock = timers();
    const status: SocketStatus[] = [];
    class Broken { constructor() { throw new Error("SecurityError"); } }
    const client = createSocket({ url: "ws://x", onFrame() {}, onStatus: (s) => status.push(s), WebSocket: Broken as unknown as typeof WebSocket, ...clock });
    client.connect();
    expect(status).toEqual(["error"]);
    expect(clock.pending).toBe(1);
    client.close();
    expect(clock.pending).toBe(0);
  });
});
