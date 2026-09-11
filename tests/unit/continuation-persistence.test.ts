import { expect, test } from "bun:test";
import { ContinuationPersistence } from "../../src/backends/mlx/continuation-persistence";
import type { ContinuationStore } from "../../src/backends/mlx/continuation";
import type { Cache } from "../../src/model/gemma4-base";

function deferred() { let resolve!: () => void; const promise = new Promise<void>(r => { resolve = r; }); return { promise, resolve }; }
function fixture() {
  const started = deferred(), release = deferred(), disposed: number[] = [], writes: number[] = [];
  let durable: number | undefined;
  const store = { async storeGenerationCheckpoint(_tokens: number[], _caches: Cache[], metadata: any) {
    writes.push(metadata.generatedTokens);
    if (metadata.generatedTokens === 1) { started.resolve(); await release.promise; }
    durable = metadata.generatedTokens; return true;
  }, removeGenerationCheckpoints() { durable = undefined; } } as unknown as ContinuationStore;
  const persistence = new ContinuationPersistence(store, { maxBytes: 1024, runStep: async step => step() });
  const snapshot = (value: number) => ({ cacheTokens: [0, value], generatedTokens: value, pendingToken: value + 1,
    caches: [{ state: () => [], dispose() { disposed.push(value); } }] as unknown as Cache[] });
  const metadata = (value: number) => ({ key: "same-request", cacheNs: "adapter-revision", originalPromptTokens: 1,
    generatedTokens: value, pendingToken: value + 1, seed: 0, seedWasExplicit: false });
  return { persistence, started, release, disposed, writes, snapshot, metadata, durable: () => durable };
}

test("enqueue transfers ownership without waiting; completion cannot resurrect state or remove a newer attempt", async () => {
  const f = fixture(), old = f.persistence.begin("same-request");
  f.persistence.enqueue(old, f.snapshot(1), f.metadata(1));
  await f.started.promise;
  expect(f.disposed).toEqual([]);
  f.persistence.enqueue(old, f.snapshot(2), f.metadata(2));
  f.persistence.complete(old);
  expect(f.persistence.canRestore("same-request")).toBe(false);
  expect(f.disposed).toEqual([2]); // queued ownership released immediately
  const next = f.persistence.begin("same-request");
  f.persistence.enqueue(next, f.snapshot(3), f.metadata(3));
  f.persistence.complete(old); // late old completion cannot affect new work
  f.release.resolve();
  expect((await f.persistence.flush()).durable).toBe(true);
  expect(f.writes).toEqual([1, 3]);
  expect(f.durable()).toBe(3);
  expect(f.persistence.canRestore("same-request")).toBe(true);
  expect(f.disposed.sort()).toEqual([1, 2, 3]);
});

test("completed in-flight attempt is removed after its rename and every owner is released", async () => {
  const f = fixture(), attempt = f.persistence.begin("same-request");
  f.persistence.enqueue(attempt, f.snapshot(1), f.metadata(1));
  await f.started.promise;
  f.persistence.complete(attempt); f.release.resolve();
  expect((await f.persistence.flush()).durable).toBe(true);
  expect(f.durable()).toBeUndefined(); expect(f.disposed).toEqual([1]);
});

test("unfinished attempts remain durable across drain, rather than being treated as completed", async () => {
  const f = fixture(), attempt = f.persistence.begin("same-request");
  f.persistence.enqueue(attempt, f.snapshot(3), f.metadata(3));
  f.persistence.release(attempt);
  expect((await f.persistence.flush()).durable).toBe(true);
  expect(f.durable()).toBe(3); expect(f.disposed).toEqual([3]);
});


test("write failure disposes transferred state and reports a nondurable flush", async () => {
  let disposed = false;
  const store = { async storeGenerationCheckpoint() { return false; }, removeGenerationCheckpoints() {} } as unknown as ContinuationStore;
  const queue = new ContinuationPersistence(store, { maxBytes: 1, runStep: async step => step() });
  const attempt = queue.begin("failed");
  queue.enqueue(attempt, { caches: [{ state: () => [], dispose() { disposed = true; } }] as unknown as Cache[],
    cacheTokens: [1, 2], generatedTokens: 1, pendingToken: 3 }, { key: "failed", cacheNs: "", originalPromptTokens: 1,
    generatedTokens: 1, pendingToken: 3, seed: 0, seedWasExplicit: false });
  queue.release(attempt);
  expect(await queue.flush()).toMatchObject({ durable: false, failed: 1, pendingBytes: 0 });
  expect(disposed).toBe(true);
});

test.each([false, true])("two cleanup barriers keep reuse closed until both settle (newer failure=%s)", async newerFailure => {
  const first = deferred(), second = deferred(), enterFirst = deferred(), enterSecond = deferred();
  let calls = 0;
  const store = { removeGenerationCheckpoints() {} } as unknown as ContinuationStore;
  const queue = new ContinuationPersistence(store, { maxBytes: 0, async runStep(step) {
    const call = ++calls;
    if (call === 1) { enterFirst.resolve(); await first.promise; }
    else { enterSecond.resolve(); await second.promise; if (newerFailure) throw new Error("newer unlink failed"); }
    return step();
  } });
  queue.complete(queue.begin("same-key"));
  await enterFirst.promise;
  queue.complete(queue.begin("same-key"));
  expect(queue.canRestore("same-key")).toBe(false);
  first.resolve(); await enterSecond.promise;
  // A has completed successfully; B is still blocked. A must not reopen reuse.
  expect(queue.canRestore("same-key")).toBe(false);
  second.resolve();
  expect((await queue.flush()).durable).toBe(!newerFailure);
  expect(queue.canRestore("same-key")).toBe(!newerFailure);
});

test("a later successful cleanup clears an older failed barrier", async () => {
  let calls = 0;
  const store = { removeGenerationCheckpoints() {} } as unknown as ContinuationStore;
  const queue = new ContinuationPersistence(store, { maxBytes: 0, async runStep(step) {
    if (++calls === 1) throw new Error("older unlink failed"); return step();
  } });
  queue.complete(queue.begin("same-key"));
  expect((await queue.flush()).durable).toBe(false);
  expect(queue.canRestore("same-key")).toBe(false);
  queue.complete(queue.begin("same-key"));
  expect((await queue.flush()).durable).toBe(true);
  expect(queue.canRestore("same-key")).toBe(true);
});
