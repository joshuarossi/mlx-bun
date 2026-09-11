import { expect, test } from "bun:test";
import type { ExecutionGroup } from "../../src/contracts/scheduling";
import { driveExecutionGroup } from "../../src/engine/scheduler";

function fixture(chunks = [1, 1], yieldAfterPreparation = false) {
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
  return { events, state, group, clock, run: () => driveExecutionGroup(group, clock, yieldAfterPreparation) };
}

test("an enabled lone admission yields before decode and retains its execution lease", async () => {
  const f = fixture([1], true); await f.run();
  expect(f.events.slice(0, 6)).toEqual(["reserve", "acquire", "admit", "prepare:1", "yield", "advance:1"]);
  expect(f.events.filter((event) => event === "acquire")).toHaveLength(1);
  expect(f.events.filter((event) => event === "release-execution")).toHaveLength(1);
});

test("the early preparation yield preserves queued short-admission grouping", async () => {
  const f = fixture([1, 1], true); await f.run();
  expect(f.events.slice(0, 7)).toEqual(["reserve", "acquire", "admit", "prepare:1", "admit", "prepare:1", "advance:2"]);
});

test("a joiner with active work does not trigger the early preparation yield", async () => {
  const f = fixture([1], true); f.state.active = 1; await f.run();
  expect(f.events.slice(0, 5)).toEqual(["reserve", "acquire", "admit", "prepare:1", "advance:2"]);
});

test("unfinished preparation still interleaves active work", async () => {
  const f = fixture([1, 3], true); await f.run();
  const first = f.events.indexOf("prepare:3");
  expect(f.events.slice(first, first + 4)).toEqual(["prepare:3", "advance:1", "yield", "prepare:2"]);
});

test("shutdown at the early yield releases both reservations without decoding", async () => {
  const f = fixture([1], true);
  f.clock.yield = async () => { f.events.push("yield"); f.state.closed = true; };
  await f.run();
  expect(f.events).toEqual(["reserve", "acquire", "admit", "prepare:1", "yield", "close", "release-execution", "release-memory"]);
});

test("a cancelled arrival at the early yield is pruned before admission", async () => {
  const f = fixture([1], true); let first = true;
  f.clock.yield = async () => {
    f.events.push("yield"); f.state.time += 25;
    if (first) { first = false; f.state.queued.push(1); }
  };
  f.group.pruneCancelled = () => {
    if (!first && f.state.queued.length) { f.state.queued = []; f.events.push("pruned"); }
  };
  await f.run();
  expect(f.events.slice(3, 7)).toEqual(["prepare:1", "yield", "pruned", "advance:1"]);
  expect(f.events.filter((event) => event === "admit")).toHaveLength(1);
});

test("an admission hold acquired at the early yield drains active work before a joiner", async () => {
  const f = fixture([1], true); let first = true;
  f.clock.yield = async () => {
    f.events.push("yield"); f.state.time += 25;
    if (first) { first = false; f.state.held = true; f.state.queued.push(1); }
  };
  f.group.waitForWork = async () => {
    f.events.push("wait");
    if (f.state.held) f.state.held = false;
    else f.state.closed = true;
  };
  await f.run();
  const prepare = f.events.indexOf("prepare:1");
  expect(f.events.slice(prepare, prepare + 3)).toEqual(["prepare:1", "yield", "advance:1"]);
  const nextAdmission = f.events.lastIndexOf("admit");
  expect(f.events.indexOf("release-execution")).toBeLessThan(nextAdmission);
  expect(f.events.indexOf("wait")).toBeLessThan(nextAdmission);
  expect(f.events.filter((event) => event === "acquire")).toHaveLength(2);
});

test("a failed early yield closes the group and releases reservations once", async () => {
  const f = fixture([1], true);
  f.clock.yield = async () => { throw new Error("yield failed"); };
  const close = f.group.failAll;
  f.group.failAll = (error) => { expect(error).toHaveProperty("message", "yield failed"); close(error); };
  await f.run();
  expect(f.events.slice(-3)).toEqual(["close", "release-execution", "release-memory"]);
  expect(f.events).not.toContain("advance:1");
});

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

test("published preparation output yields through the readiness interface without a method-specific policy", async () => {
  const f = fixture([1]);
  Object.defineProperty(f.group, "preparationPublishedOutput", { value: true });
  await f.run();
  expect(f.events.slice(0, 6)).toEqual(["reserve", "acquire", "admit", "prepare:1", "yield", "advance:1"]);
  expect(f.events.filter(event => event === "acquire")).toHaveLength(1);
});

test("published preparation still groups queued short jobs before advancing", async () => {
  const f = fixture([1, 1]);
  Object.defineProperty(f.group, "preparationPublishedOutput", { value: true });
  await f.run();
  expect(f.events.slice(0, 9)).toEqual(["reserve", "acquire", "admit", "prepare:1", "yield", "admit", "prepare:1", "yield", "advance:2"]);
  expect(f.events).not.toContain("advance:1");
});

test("preparation work budgets group short requests and run oversized requests in the same executor", async () => {
  const pending = [5000, 1200, 1200, 16, 8], preparing: number[] = [], forwards: number[][] = [];
  let active = 0, closed = false, admitted = 0;
  const group: ExecutionGroup = {
    get active() { return active; }, get queued() { return pending.length; },
    get preparing() { return preparing.length > 0; }, get preparingRows() { return preparing.length; },
    canPrepareMore: true, get preparingTokens() { return preparing.reduce((a, b) => a + b, 0); },
    get nextPreparationTokens() { return pending[0] ?? 0; }, maxPreparationTokens: 2048,
    maxActive: 4, admissionHeld: false, get closed() { return closed; },
    pruneCancelled() {}, canBurst: () => true,
    admitNext() { preparing.push(pending.shift()!); admitted++; return true; },
    async advancePreparation() { forwards.push([...preparing]); active += preparing.length; preparing.splice(0); },
    async advance() { active = 0; },
    failActive(error) { throw error; }, failAll(error) { if (!closed) throw error; },
    reserveResidency: () => () => {}, async waitForWork() { closed = true; },
  };
  await driveExecutionGroup(group, { now: () => 0, async yield() {} });
  expect(admitted).toBe(5);
  expect(forwards).toEqual([[5000], [1200], [1200, 16], [8]]);
});

test("remaining preparation work can admit a late request after an earlier chunk finishes", async () => {
  const pending = [3000, 1000], preparing: number[] = [], forwards: number[][] = [];
  let active = 0, closed = false;
  const group: ExecutionGroup = {
    get active() { return active; }, get queued() { return pending.length; },
    get preparing() { return preparing.length > 0; }, get preparingRows() { return preparing.length; },
    canPrepareMore: true, get preparingTokens() { return preparing.reduce((a, b) => a + b, 0); },
    get nextPreparationTokens() { return pending[0] ?? 0; }, maxPreparationTokens: 2048,
    maxActive: 2, admissionHeld: false, get closed() { return closed; },
    pruneCancelled() {}, canBurst: () => true,
    admitNext() { preparing.push(pending.shift()!); return true; },
    async advancePreparation() {
      forwards.push([...preparing]);
      if (forwards.length === 1) preparing[0]! -= 2048;
      else { active += preparing.length; preparing.splice(0); }
    },
    async advance() { active = 0; },
    failActive(error) { throw error; }, failAll(error) { if (!closed) throw error; },
    reserveResidency: () => () => {}, async waitForWork() { closed = true; },
  };
  await driveExecutionGroup(group, { now: () => 25, async yield() {} });
  expect(forwards).toEqual([[3000], [952, 1000]]);
});
