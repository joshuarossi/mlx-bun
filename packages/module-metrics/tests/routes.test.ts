// The snapshot JSON and the SSE stream: shape, ordering, throttling, keep-alive
// and cleanup. Timers are manual so the stream's schedule is exact.
import { expect, test } from "bun:test";
import { createMetricsRoutes, type StreamTimers } from "../src/routes";
import { createMetricsStore } from "../src/store";
import type { MetricsSnapshot } from "../src/protocol";
import { fakeJobs, fakeStorage, RECORDED } from "./support";

function manualTimers() {
  const timeouts = new Map<number, { at: number; run: () => void }>(), intervals = new Map<number, { every: number; next: number; run: () => void }>();
  let id = 0, clock = 0;
  const timers: StreamTimers = {
    setTimeout: (run, ms) => { timeouts.set(++id, { at: clock + ms, run }); return id; },
    clearTimeout: handle => { timeouts.delete(handle as number); },
    setInterval: (run, every) => { intervals.set(++id, { every, next: clock + every, run }); return id; },
    clearInterval: handle => { intervals.delete(handle as number); },
  };
  const dueAt = (timer: { at: number } | { next: number }) => "at" in timer ? timer.at : timer.next;
  return { timers, get clock() { return clock; }, get open() { return timeouts.size + intervals.size; },
    advance(ms: number) {
      const target = clock + ms;
      for (;;) {
        const due = [...timeouts.entries(), ...intervals.entries()].filter(([, timer]) => dueAt(timer) <= target).sort((a, b) => dueAt(a[1]) - dueAt(b[1]))[0];
        if (!due) break;
        const [key, timer] = due;
        clock = dueAt(timer);
        if ("at" in timer) timeouts.delete(key); else timer.next += timer.every;
        timer.run();
      }
      clock = target;
    } };
}

function setup() {
  const store = createMetricsStore({ now: () => 1 }), listeners = new Set<() => void>(), clock = manualTimers();
  const apply = (event: Parameters<typeof store.apply>[0]) => { store.apply(event); for (const listener of listeners) listener(); };
  const routes = createMetricsRoutes({ store, storage: fakeStorage("/nowhere"), jobs: fakeJobs(), timers: clock.timers, now: () => clock.clock,
    minIntervalMs: 500, keepAliveMs: 15_000, onChange: listener => { listeners.add(listener); return () => { listeners.delete(listener); }; } });
  return { store, apply, routes, clock, listeners };
}

const decoder = new TextDecoder();
const text = (chunk: { value?: Uint8Array }) => decoder.decode(chunk.value);
const payload = (frame: string) => JSON.parse(frame.split("data: ")[1]!) as MetricsSnapshot;

test("the snapshot route returns the reduced state as JSON", async () => {
  const { routes, apply } = setup();
  for (const event of RECORDED) apply(event);
  const snapshot = await routes.snapshot(new Request("http://x")) as Response;
  expect(snapshot.headers.get("content-type")).toContain("application/json");
  const body = await snapshot.json() as MetricsSnapshot;
  expect(Object.keys(body).sort()).toEqual(["at", "caches", "models", "requests", "schedulers", "series", "startedAt"]);
  expect(body.requests.recent.map(request => request.requestId)).toEqual(["req-1", "req-2", "req-3"]);
  expect(body.models[1]).toMatchObject({ model: "org/other", state: "resident", lastSwapMs: 1_100 });
});

test("the stream opens with a retry hint and the current snapshot, then sends at most one snapshot per interval, newest state", async () => {
  const { routes, apply, clock } = setup();
  apply(RECORDED[0]!);
  const abort = new AbortController();
  const response = await routes.stream(new Request("http://x/stream", { signal: abort.signal })) as Response;
  expect(response.headers.get("content-type")).toBe("text/event-stream");
  const reader = response.body!.getReader();
  expect(text(await reader.read())).toBe("retry: 1500\n\n");
  const first = text(await reader.read());
  expect(first.startsWith("event: snapshot\ndata: ")).toBe(true);
  expect(payload(first).models[0]).toMatchObject({ state: "loading" });

  // Changes inside one interval collapse into one frame carrying the last of them.
  apply(RECORDED[1]!); apply(RECORDED[2]!); apply(RECORDED[3]!);
  clock.advance(499);
  const pending = reader.read();
  clock.advance(1);
  const snapshot = payload(text(await pending));
  expect(snapshot.models[0]).toMatchObject({ state: "resident", lastLoadMs: 900 });
  expect(snapshot.schedulers).toHaveLength(1);
  abort.abort();
});

test("an idle stream sends comment frames to stay open, and nothing else", async () => {
  const { routes, clock } = setup();
  const abort = new AbortController();
  const reader = ((await routes.stream(new Request("http://x/stream", { signal: abort.signal }))) as Response).body!.getReader();
  await reader.read(); await reader.read();
  const beat = reader.read();
  clock.advance(15_000);
  expect(text(await beat)).toBe(": keepalive\n\n");
  abort.abort();
});

test("a disconnected client releases its listener and timers, whether it cancels or aborts", async () => {
  const { routes, apply, listeners, clock } = setup();
  const response = await routes.stream(new Request("http://x/stream")) as Response;
  const reader = response.body!.getReader();
  await reader.read(); await reader.read();
  apply(RECORDED[0]!);
  expect(listeners.size).toBe(1);
  expect(clock.open).toBeGreaterThan(0);
  await reader.cancel();
  expect(listeners.size).toBe(0);
  expect(clock.open).toBe(0);
  const aborted = new AbortController();
  const second = await routes.stream(new Request("http://x/stream", { signal: aborted.signal })) as Response;
  await second.body!.getReader().read();
  aborted.abort();
  expect(listeners.size).toBe(0);
  expect(clock.open).toBe(0);
});

test("a reader that falls behind skips frames instead of buffering them, then catches up with the newest state", async () => {
  const { routes, apply, clock } = setup();
  const abort = new AbortController();
  const reader = ((await routes.stream(new Request("http://x/stream", { signal: abort.signal }))) as Response).body!.getReader();
  // Nothing is read while 50 changes arrive; the queue holds at most its high-water mark.
  for (let round = 0; round < 50; round++) { apply({ type: "scheduler.sample", at: round, model: "m", active: round, capacity: 100, queued: 0, tokensPerSecond: round }); clock.advance(500); }
  // A read that times out stays pending, so the next look reuses it instead of queuing a second.
  let waiting: Promise<string> | undefined;
  const look = async (ms: number) => {
    waiting ??= reader.read().then(text);
    const chunk = await Promise.race([waiting, Bun.sleep(ms).then(() => null)]);
    if (chunk !== null) waiting = undefined;
    return chunk;
  };
  const buffered: string[] = [];
  for (let chunk = await look(10); chunk !== null; chunk = await look(10)) buffered.push(chunk);
  // 50 changes were offered; only what fit the queue (the retry hint included) was kept.
  expect(buffered.length).toBeLessThanOrEqual(4);
  // Reading woke the stream, which sends the state as it is now once its interval has passed.
  clock.advance(500);
  expect(payload((await look(50))!).schedulers[0]!.active).toBe(49);
  abort.abort();
});
