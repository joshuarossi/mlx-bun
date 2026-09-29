// The event bus's contract: publishers never wait for or hear from a
// subscriber, delivery keeps publish order, each subscriber's queue is bounded,
// and a module can publish only under its own prefix.
import { expect, test } from "bun:test";
import type { AppEvent, EventOf } from "@mlx-bun/app-core";
import { createEventHub } from "../src";

const at = 0;
const queued = (event: AppEvent): number => (event as EventOf<"scheduler.sample">).queued;
const load = (model: string): AppEvent => ({ type: "model.load", at, model, phase: "started" });
const sample = (queued: number): AppEvent => ({ type: "scheduler.sample", at, model: "m", active: 0, capacity: 4, queued, tokensPerSecond: 0 });

/** A delivery queue the test drains by hand, standing in for the event loop. */
function manual() {
  const runs: (() => void)[] = [];
  return { schedule: (run: () => void) => { runs.push(run); }, drain() { while (runs.length) runs.shift()!(); }, get pending() { return runs.length; } };
}

test("publishing hands nothing to a subscriber on the publisher's stack and delivers in publish order across types", () => {
  const loop = manual(), hub = createEventHub({ schedule: loop.schedule }), seen: string[] = [];
  hub.subscribe("*", event => { seen.push(event.type === "scheduler.sample" ? `sample ${queued(event)}` : event.type); });
  hub.publish(load("a")); hub.publish(sample(1)); hub.publish(sample(2));
  expect(seen).toEqual([]);
  loop.drain();
  expect(seen).toEqual(["model.load", "sample 1", "sample 2"]);
});

test("a subscriber sees only the types it named, and only events published after it subscribed", () => {
  const loop = manual(), hub = createEventHub({ schedule: loop.schedule }), seen: number[] = [];
  hub.publish(sample(0));
  const off = hub.subscribe(["scheduler.sample"], event => { if (event.type === "scheduler.sample") seen.push(queued(event)); });
  hub.publish(load("a")); hub.publish(sample(1));
  loop.drain();
  expect(seen).toEqual([1]);
  off(); off();
  hub.publish(sample(2)); loop.drain();
  expect(seen).toEqual([1]);
});

test("a full queue drops the oldest events and counts them; other subscribers are unaffected", () => {
  const loop = manual(), hub = createEventHub({ bufferSize: 3, schedule: loop.schedule }), slow: number[] = [], other: number[] = [];
  hub.subscribe(["scheduler.sample"], event => { if (event.type === "scheduler.sample") slow.push(queued(event)); });
  for (let index = 0; index < 10; index++) hub.publish(sample(index));
  expect(hub.stats().subscribers[0]).toMatchObject({ pending: 3, dropped: 7 });
  loop.drain();
  expect(slow).toEqual([7, 8, 9]);
  // A subscriber that never drains cannot grow without bound however long it lags.
  const stuck = createEventHub({ bufferSize: 4, schedule: () => {} });
  stuck.subscribe("*", () => {});
  for (let index = 0; index < 10_000; index++) stuck.publish(sample(index));
  expect(stuck.stats().subscribers[0]).toMatchObject({ pending: 4, dropped: 9_996 });
  hub.subscribe(["scheduler.sample"], event => { if (event.type === "scheduler.sample") other.push(queued(event)); });
  hub.publish(sample(10)); loop.drain();
  expect(other).toEqual([10]);
});

test("a handler that throws or rejects is counted and skipped; later events still arrive", async () => {
  const loop = manual(), errors: unknown[] = [], hub = createEventHub({ schedule: loop.schedule, onHandlerError: error => errors.push(error) }), seen: number[] = [];
  hub.subscribe(["scheduler.sample"], async event => {
    if (event.type !== "scheduler.sample") return;
    if (queued(event) === 1) throw new Error("boom");
    if (queued(event) === 2) return Promise.reject(new Error("later"));
    seen.push(queued(event));
  });
  for (const queued of [0, 1, 2, 3]) hub.publish(sample(queued));
  expect(() => loop.drain()).not.toThrow();
  await new Promise(resolve => setTimeout(resolve, 0));
  expect(seen).toEqual([0, 3]);
  expect(errors.map(error => (error as Error).message).sort()).toEqual(["boom", "later"]);
  expect(hub.stats().subscribers[0]).toMatchObject({ delivered: 4, failed: 2 });
});

test("a long batch is delivered in slices so one subscriber cannot hold the loop", () => {
  const passes: (() => void)[] = [], seen: number[] = [];
  const hub = createEventHub({ schedule: run => { passes.push(run); }, batchSize: 2 });
  hub.subscribe("*", event => { if (event.type === "scheduler.sample") seen.push(queued(event)); });
  for (let index = 0; index < 5; index++) hub.publish(sample(index));
  expect(passes).toHaveLength(1);
  passes.shift()!();
  expect(seen).toEqual([0, 1]);
  expect(passes).toHaveLength(1);
  passes.shift()!(); passes.shift()!();
  expect(seen).toEqual([0, 1, 2, 3, 4]);
  expect(passes).toHaveLength(0);
});

test("events published from a handler are delivered after the one being handled", () => {
  const loop = manual(), hub = createEventHub({ schedule: loop.schedule }), seen: string[] = [];
  hub.subscribe(["model.load"], () => { seen.push("load"); hub.publish(sample(9)); });
  hub.subscribe(["scheduler.sample"], () => { seen.push("sample"); });
  hub.publish(load("a"));
  loop.drain();
  expect(seen).toEqual(["load", "sample"]);
});

test("a module's bus publishes only its own prefixed events and subscribes to everything", () => {
  const loop = manual(), hub = createEventHub({ schedule: loop.schedule }), seen: string[] = [];
  const transcription = hub.scoped({ moduleId: "transcription" }), metrics = hub.scoped({ moduleId: "metrics" });
  metrics.subscribe("*", event => { seen.push(event.type); });
  transcription.publish({ type: "transcription.finished", at, data: { ms: 3 } });
  transcription.publish(load("stolen"));
  transcription.publish({ type: "metrics.finished", at });
  transcription.publish({ type: "transcription-x.finished", at });
  hub.publish(load("host"));
  // A module whose id spells a core type's prefix still cannot publish that core type.
  hub.scoped({ moduleId: "model" }).publish(load("forged"));
  hub.scoped({ moduleId: "model" }).publish({ type: "model.custom", at });
  loop.drain();
  expect(seen).toEqual(["transcription.finished", "model.load", "model.custom"]);
  expect(hub.stats().rejected).toBe(4);
});

test("a value that is not an event is rejected, and a closed hub ignores publishes and subscriptions", () => {
  const loop = manual(), hub = createEventHub({ schedule: loop.schedule }), seen: unknown[] = [];
  hub.subscribe("*", event => { seen.push(event); });
  hub.publish(undefined as never); hub.publish({ type: 3 } as never); hub.publish({ type: "x.y" } as never);
  expect(hub.stats()).toMatchObject({ published: 0, rejected: 3 });
  hub.publish(load("a"));
  hub.close(); hub.close();
  loop.drain();
  expect(seen).toEqual([]);
  hub.publish(load("b"));
  hub.subscribe("*", event => { seen.push(event); })();
  loop.drain();
  expect(seen).toEqual([]);
  expect(hub.stats().subscribers).toEqual([]);
});

test("with the real scheduler a publisher's loop is not held by a subscriber that has not run yet", async () => {
  const hub = createEventHub(), seen: number[] = [];
  hub.subscribe(["scheduler.sample"], event => { if (event.type === "scheduler.sample") seen.push(queued(event)); });
  hub.publish(sample(1));
  expect(seen).toEqual([]);
  await new Promise(resolve => setTimeout(resolve, 5));
  expect(seen).toEqual([1]);
});
