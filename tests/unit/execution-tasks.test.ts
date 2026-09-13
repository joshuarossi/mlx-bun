import { expect, test } from "bun:test";
import { ExecutionTasks } from "../../src/engine/execution-tasks";
import { CancellationSource } from "../../src/engine/cancellation";

test("execution tasks wait for a driver boundary and isolate a failed preparation", async () => {
  const tasks = new ExecutionTasks(), events: string[] = [];
  const failed = tasks.enqueue(async () => { events.push("failed"); throw new Error("encoder failed"); });
  const failure = failed.catch(error => error.message);
  const success = tasks.enqueue(async () => { events.push("success"); return 42; });
  expect(events).toEqual([]);
  expect(tasks.pending).toBe(2);
  await tasks.advance();
  expect(await failure).toBe("encoder failed");
  expect(events).toEqual(["failed"]);
  await tasks.advance();
  expect(await success).toBe(42);
  expect(tasks.pending).toBe(0);
});

test("cancellation removes only pending work and preserves the running task's lifetime", async () => {
  const tasks = new ExecutionTasks(), pending = new CancellationSource(), running = new CancellationSource();
  let release!: () => void, settled = false;
  const active = tasks.enqueue(async () => { await new Promise<void>(resolve => { release = resolve; }); return 7; }, running);
  void active.then(() => { settled = true; });
  const cancelled = tasks.enqueue(async () => { throw new Error("cancelled task ran"); }, pending).catch(error => error);
  const advancing = tasks.advance();
  running.cancel("requested"); pending.cancel("requested");
  expect(await cancelled).toHaveProperty("reason", "requested");
  expect(settled).toBe(false);
  expect(tasks.pending).toBe(0);
  release(); await advancing;
  expect(await active).toBe(7);
});

test("shutdown rejects queued tasks without executing them", async () => {
  const tasks = new ExecutionTasks(), error = new Error("shutdown");
  const waiting = [1, 2].map(() => tasks.enqueue(async () => { throw new Error("must not run"); }).catch(e => e));
  tasks.rejectAll(error);
  expect(await Promise.all(waiting)).toEqual([error, error]);
  expect(tasks.pending).toBe(0);
});
