import { expect, test } from "bun:test";
import type { ExecutionGroup } from "../../src/contracts/scheduling";
import { driveExecutionGroup } from "../../src/engine/scheduler";

function fixture(chunks = [1, 1]) {
  const events: string[] = [];
  const state = { active: 0, queued: [...chunks], remaining: 0, held: false, closed: false, time: 0 };
  const group: ExecutionGroup = {
    get active() { return state.active; },
    get queued() { return state.queued.length; },
    get preparing() { return state.remaining > 0; },
    maxActive: 2,
    get admissionHeld() { return state.held; },
    get closed() { return state.closed; },
    pruneCancelled() {},
    admitNext() { events.push("admit"); state.remaining = state.queued.shift()!; return true; },
    canBurst: () => true,
    async advancePreparation() {
      events.push(`prepare:${state.remaining}`);
      if (--state.remaining === 0) state.active++;
    },
    async advance() { events.push(`advance:${state.active}`); state.active = 0; },
    failActive() { events.push("fail-active"); state.active = 0; },
    failAll() { events.push("close"); state.active = 0; state.queued = []; state.remaining = 0; },
    reserveResidency() { events.push("reserve"); return () => { events.push("release-memory"); }; },
    async acquireExecution() { events.push("acquire"); return () => { events.push("release-execution"); }; },
    async waitForWork() { events.push("wait"); state.closed = true; },
  };
  const clock = { now: () => state.time, async yield() { events.push("yield"); state.time += 25; } };
  return { events, state, group, clock, run: () => driveExecutionGroup(group, clock) };
}

test("completed short admissions group before the next execution step", async () => {
  const f = fixture(); await f.run();
  expect(f.events.slice(0, 7)).toEqual(["reserve", "acquire", "admit", "prepare:1", "admit", "prepare:1", "advance:2"]);
  expect(f.events.slice(-4)).toEqual(["release-execution", "release-memory", "wait", "close"]);
});

test("a long joiner advances one preparation unit between active work", async () => {
  const f = fixture([1, 3]); await f.run();
  const first = f.events.indexOf("prepare:3");
  expect(f.events.slice(first, first + 4)).toEqual(["prepare:3", "advance:1", "yield", "prepare:2"]);
});

test("serial drain releases execution before queued work can be admitted", async () => {
  const f = fixture([1]); f.state.active = 1; f.state.held = true;
  f.group.waitForWork = async () => {
    f.events.push("wait");
    if (f.state.held) f.state.held = false;
    else f.state.closed = true;
  };
  await f.run();
  expect(f.events.indexOf("advance:1")).toBeLessThan(f.events.indexOf("wait"));
  expect(f.events.indexOf("release-execution")).toBeLessThan(f.events.indexOf("wait"));
  expect(f.events.indexOf("wait")).toBeLessThan(f.events.indexOf("admit"));
  expect(f.events.filter((e) => e === "acquire")).toHaveLength(2);
});

test("a failed execution group drops active state and may admit fresh queued work", async () => {
  const f = fixture([1, 3]); let fail = true;
  f.group.advance = async () => {
    if (fail) { fail = false; throw new Error("forward failed"); }
    f.events.push("fresh-advance"); f.state.active = 0;
  };
  await f.run();
  expect(f.events.indexOf("fail-active")).toBeGreaterThan(0);
  expect(f.events.indexOf("fresh-advance")).toBeGreaterThan(f.events.indexOf("fail-active"));
  expect(f.events.filter((e) => e === "close")).toHaveLength(1);
});

test("shutdown during acquisition starts no native work and releases the acquired lease", async () => {
  const f = fixture([1]);
  f.group.acquireExecution = async () => { f.state.closed = true; return () => { f.events.push("released"); }; };
  await f.run();
  expect(f.events).toEqual(["reserve", "close", "released", "release-memory"]);
});

test("cleanup failure still releases every scheduling reservation exactly once", async () => {
  const f = fixture([1]);
  f.group.advancePreparation = async () => { throw new Error("prepare failed"); };
  f.group.failAll = (error) => {
    expect(error).toHaveProperty("message", "prepare failed");
    f.events.push("close"); throw new Error("cleanup failed");
  };
  await expect(f.run()).rejects.toThrow("cleanup failed");
  expect(f.events.slice(-3)).toEqual(["close", "release-execution", "release-memory"]);
  expect(f.events.filter((e) => e === "close")).toHaveLength(1);
});
