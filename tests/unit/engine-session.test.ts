import { describe, expect, test } from "bun:test";
import type { ExecutionPlanner, GenerationEvent, InferenceMethod, Timer } from "../../src/contracts/generation";
import { createInferenceEngine, type EngineOptions } from "../../src/engine/engine";
import { CancellationSource, throwIfCancelled } from "../../src/engine/cancellation";

class ManualTimer implements Timer {
  callbacks = new Set<() => void>();
  after(_ms: number, callback: () => void): () => void {
    this.callbacks.add(callback);
    return () => { this.callbacks.delete(callback); };
  }
  expire(): void { for (const callback of [...this.callbacks]) callback(); }
}

const tick = async () => { for (let n = 0; n < 20; n++) await Promise.resolve(); };
const deferred = () => {
  let resolve!: () => void;
  const promise = new Promise<void>((r) => { resolve = r; });
  return { promise, resolve };
};
type Metrics = { steps: number };

function fixture(
  execute: Awaited<ReturnType<InferenceMethod<Metrics>["createRun"]>>["execute"],
  options: Partial<EngineOptions> = {}, limit = 8,
) {
  const timer = new ManualTimer();
  let created = 0;
  let closed = 0;
  const method: InferenceMethod<Metrics> = {
    id: "scripted",
    async createRun() { created++; return { execute, async close() { closed++; } }; },
  };
  const planner: ExecutionPlanner<void, Metrics> = {
    async plan() { return { id: "test", outputTokenLimit: limit, method }; },
  };
  return { engine: createInferenceEngine(planner, { timer, ...options }), timer,
    get created() { return created; }, get closed() { return closed; } };
}
const done = { finishReason: "stop" as const, metrics: { steps: 1 } };

test("callback false stops publication normally and still closes the method", async () => {
  const f = fixture(async (output) => {
    for (const id of [1, 2, 3]) if (await output.commit([id]) === false) break;
    return done;
  });
  const ids: number[] = [];
  const session = await f.engine.open(undefined, {
    output: "callback", async onTokens(tokens) { ids.push(...tokens); return false; },
  });
  expect(await session.result).toMatchObject({ status: "completed", committedTokens: 1 });
  expect(ids).toEqual([1]);
  expect(f.closed).toBe(1);
  await f.engine.close();
});

test("a method cannot continue publishing after a callback stop", async () => {
  const f = fixture(async (output) => { await output.commit([1]); await output.commit([2]); return done; });
  const session = await f.engine.open(undefined, { output: "callback", async onTokens() { return false; } });
  expect(await session.result).toMatchObject({ status: "failed", committedTokens: 1,
    error: { message: "method published after the consumer requested a stop" } });
  expect(f.closed).toBe(1);
  await f.engine.close();
});

for (const mode of ["incremental", "final-only"] as const) {
  describe(`shared method lifecycle: ${mode}`, () => {
    const publish = async (output: Parameters<Awaited<ReturnType<InferenceMethod<Metrics>["createRun"]>>["execute"]>[0]) => {
      if (mode === "incremental") for (const token of [1, 2, 3]) await output.commit([token]);
      else { await output.progress(1, 1); await output.commit([1, 2, 3]); }
    };
    test("collect and stream have identical committed output and one cleanup", async () => {
      const f = fixture(async (output) => { await publish(output); return done; }, { maxQueuedTokens: 1 });
      for (const output of ["collect", "stream"] as const) {
        const session = await f.engine.open(undefined, { output });
        const tokens: number[] = [];
        if (output === "stream") for await (const event of session.events)
          if (event.type === "committed") tokens.push(...event.tokenIds);
        const result = await session.result;
        expect(result.status).toBe("completed");
        expect(output === "collect" ? [...result.output!] : tokens).toEqual([1, 2, 3]);
      }
      expect(f.closed).toBe(2);
      await f.engine.close();
    });
    test("callback delivery waits for the consumer and uses the same cleanup", async () => {
      const gate = deferred();
      let returned = false;
      const f = fixture(async (output) => { await publish(output); returned = true; return done; });
      const tokens: number[] = [];
      const session = await f.engine.open(undefined, {
        output: "callback", async onTokens(ids) { tokens.push(...ids); await gate.promise; },
      });
      await tick();
      expect(returned).toBe(false);
      expect(f.closed).toBe(0);
      gate.resolve();
      expect(await session.result).toMatchObject({ status: "completed", committedTokens: 3 });
      expect(tokens).toEqual([1, 2, 3]);
      expect(f.closed).toBe(1);
      expect(f.timer.callbacks.size).toBe(0);
      await f.engine.close();
    });
    test("abandoned output cancels blocked publication and closes once", async () => {
      const f = fixture(async (output) => { await publish(output); return done; },
        { maxQueuedTokens: 1, maxQueuedEvents: 1 });
      const session = await f.engine.open(undefined, { output: "stream" });
      await session.events[Symbol.asyncIterator]().next();
      await tick();
      f.timer.expire();
      expect((await session.result).status).toBe("cancelled");
      await session.close();
      expect(f.closed).toBe(1);
    });
    test("execution failure preserves partial output and releases the method", async () => {
      const f = fixture(async (output) => { await publish(output); throw new Error("method failure"); });
      const session = await f.engine.open(undefined, { output: "collect" });
      const result = await session.result;
      expect(result).toMatchObject({ status: "failed", committedTokens: 3 });
      expect([...result.output!]).toEqual([1, 2, 3]);
      expect(f.closed).toBe(1);
    });
    test("unread and already-cancelled sessions allocate no method state", async () => {
      const f = fixture(async (output) => { await publish(output); return done; });
      const unread = await f.engine.open(undefined, { output: "stream" });
      f.timer.expire();
      expect((await unread.result).status).toBe("cancelled");
      const cancellation = new CancellationSource();
      cancellation.cancel("requested");
      const cancelled = await f.engine.open(undefined, { output: "collect", cancellation });
      expect((await cancelled.result).status).toBe("cancelled");
      expect(f.created).toBe(0);
      expect(f.closed).toBe(0);
    });
  });
}

describe("portable generation sessions", () => {
  test("streaming is demand-started; collecting needs no event reader", async () => {
    const f = fixture(async (output) => { await output.commit([3, 4]); return done; });
    const stream = await f.engine.open(undefined, { output: "stream" });
    await tick();
    expect(f.created).toBe(0);
    const events = await Array.fromAsync(stream.events);
    expect(events).toEqual([{ type: "committed", sequence: 0, tokenIds: [3, 4] }]);
    expect(await stream.result).toMatchObject({ status: "completed", committedTokens: 2, result: done });
    const collect = await f.engine.open(undefined, { output: "collect" });
    const result = await collect.result;
    expect(result.status).toBe("completed");
    expect([...result.output!]).toEqual([3, 4]);
    expect(f.closed).toBe(2);
    expect(f.timer.callbacks.size).toBe(0);
    await f.engine.close();
  });

  test("AR spans and final-only methods use the same session consumer", async () => {
    for (const mode of ["ar", "final"]) {
      const f = fixture(async (output) => {
        if (mode === "ar") for (const id of [2, 3, 4]) await output.commit([id]);
        else { await output.progress(1, 2); await output.commit([2, 3, 4]); }
        return done;
      });
      const session = await f.engine.open(undefined, { output: "stream" });
      const tokens: number[] = [];
      for await (const event of session.events) if (event.type === "committed") tokens.push(...event.tokenIds);
      expect(tokens).toEqual([2, 3, 4]);
      expect((await session.result).status).toBe("completed");
      await f.engine.close();
    }
  });

  test("large committed spans split under bounded backpressure without losing order", async () => {
    let producerFinished = false;
    const f = fixture(async (output) => {
      await output.commit([1, 2, 3, 4, 5]); producerFinished = true; return done;
    }, { maxQueuedEvents: 1, maxQueuedTokens: 2 });
    const session = await f.engine.open(undefined, { output: "stream" });
    const reader = session.events[Symbol.asyncIterator]();
    expect((await reader.next()).value).toMatchObject({ sequence: 0, tokenIds: [1, 2] });
    await tick();
    expect(producerFinished).toBe(false);
    expect((await reader.next()).value).toMatchObject({ sequence: 1, tokenIds: [3, 4] });
    expect((await reader.next()).value).toMatchObject({ sequence: 2, tokenIds: [5] });
    expect((await reader.next()).done).toBe(true);
    expect(producerFinished).toBe(true);
    expect((await session.result).committedTokens).toBe(5);
  });

  test("an unread stream expires without constructing method state", async () => {
    const f = fixture(async () => done);
    const session = await f.engine.open(undefined, { output: "stream" });
    f.timer.expire();
    expect(await session.result).toMatchObject({ status: "cancelled", reason: "consumer_idle" });
    expect(f.created).toBe(0);
    expect(f.timer.callbacks.size).toBe(0);
  });

  test("an abandoned reader cancels a backpressured producer and releases it once", async () => {
    const f = fixture(async (output) => {
      for (const id of [1, 2, 3, 4]) await output.commit([id]);
      return done;
    }, { maxQueuedEvents: 1 });
    const session = await f.engine.open(undefined, { output: "stream" });
    await session.events[Symbol.asyncIterator]().next();
    await tick();
    f.timer.expire();
    expect(await session.result).toMatchObject({ status: "cancelled", reason: "consumer_idle" });
    await session.close();
    await session.cancel();
    expect(f.closed).toBe(1);
  });

  test("early iterator return cancels and waits for native cleanup", async () => {
    const cleanup = deferred();
    let closed = false;
    const timer = new ManualTimer();
    const engine = createInferenceEngine({ async plan() { return {
      id: "cleanup", outputTokenLimit: 2, method: { id: "cleanup", async createRun() { return {
        async execute(output, cancellation) {
          await output.commit([1]);
          await new Promise<void>((resolve) => cancellation.subscribe(() => resolve()));
          throwIfCancelled(cancellation);
          return done;
        },
        async close() { await cleanup.promise; closed = true; },
      }; } },
    }; } } satisfies ExecutionPlanner<void, Metrics>, { timer });
    const session = await engine.open(undefined, { output: "stream" });
    const reader = session.events[Symbol.asyncIterator]();
    await reader.next();
    let returned = false;
    const returning = reader.return!().then(() => { returned = true; });
    await tick();
    expect(returned).toBe(false);
    expect(session.state).toBe("settling");
    cleanup.resolve();
    await returning;
    expect(closed).toBe(true);
    expect(await session.result).toMatchObject({ status: "cancelled", reason: "consumer_closed" });
  });

  test("external cancellation before open does no work and unsubscribes", async () => {
    const source = new CancellationSource();
    source.cancel("requested");
    const f = fixture(async () => done);
    const session = await f.engine.open(undefined, { output: "collect", cancellation: source });
    expect((await session.result).status).toBe("cancelled");
    expect(f.created).toBe(0);
    await f.engine.close();
  });

  test("cancellation during asynchronous preparation closes a late-created run", async () => {
    const gate = deferred();
    let closed = 0;
    const timer = new ManualTimer();
    const engine = createInferenceEngine({ async plan() { return {
      id: "late", outputTokenLimit: 1, method: { id: "late", async createRun() {
        await gate.promise;
        return { async execute() { throw new Error("must not execute"); }, async close() { closed++; } };
      } },
    }; } }, { timer });
    const session = await engine.open(undefined, { output: "collect" });
    await tick();
    const cancelling = session.cancel();
    gate.resolve();
    await cancelling;
    expect((await session.result).status).toBe("cancelled");
    expect(closed).toBe(1);
  });

  test("method failure keeps delivered output and settles after cleanup", async () => {
    const f = fixture(async (output) => { await output.commit([7]); throw new Error("worker died"); });
    const session = await f.engine.open(undefined, { output: "stream" });
    expect(await Array.fromAsync(session.events)).toHaveLength(1);
    expect(await session.result).toMatchObject({ status: "failed", committedTokens: 1,
      error: { message: "worker died" } });
    expect(f.closed).toBe(1);
  });

  test("collect admission fails before creating method state and releases capacity", async () => {
    const gate = deferred();
    const f = fixture(async (output) => { await gate.promise; await output.commit([1]); return done; },
      { maxCollectTokens: 8 });
    const first = await f.engine.open(undefined, { output: "collect" });
    await tick();
    const second = await f.engine.open(undefined, { output: "collect" });
    expect(await second.result).toMatchObject({ status: "failed", error: { message: "collection output capacity exceeded" } });
    expect(f.created).toBe(1);
    gate.resolve();
    await first.result;
    const third = await f.engine.open(undefined, { output: "collect" });
    expect((await third.result).status).toBe("completed");
    expect(f.created).toBe(2);
  });

  test("output budget overruns fail instead of truncating", async () => {
    const f = fixture(async (output) => { await output.commit([1, 2]); return done; }, {}, 1);
    const session = await f.engine.open(undefined, { output: "collect" });
    expect(await session.result).toMatchObject({ status: "failed", committedTokens: 0 });
    expect(f.closed).toBe(1);
  });

  test("one consumer owns events; engine close is idempotent and prevents new sessions", async () => {
    const f = fixture(async () => done);
    const session = await f.engine.open(undefined, { output: "stream" });
    session.events[Symbol.asyncIterator]();
    expect(() => session.events[Symbol.asyncIterator]()).toThrow("one consumer");
    await Promise.all([f.engine.close(), f.engine.close()]);
    expect(await session.result).toMatchObject({ status: "cancelled", reason: "engine_closed" });
    await expect(f.engine.open(undefined, { output: "stream" })).rejects.toThrow("closed");
  });

  test("progress-only output is bounded too", async () => {
    const f = fixture(async (output) => {
      for (let n = 0; n < 10; n++) await output.progress(n, 10);
      return done;
    }, { maxQueuedEvents: 1 });
    const session = await f.engine.open(undefined, { output: "stream" });
    const events: GenerationEvent[] = [];
    for await (const event of session.events) events.push(event);
    expect(events).toHaveLength(10);
    expect((await session.result).status).toBe("completed");
  });

  test("scratch token and logprob arrays are copied at publication", async () => {
    const f = fixture(async (output) => {
      const ids = [3]; const lp = [{ logprob: -1, top: [{ id: 3, logprob: -1 }] }];
      await output.commit(ids, lp);
      ids[0] = 99; lp[0]!.top[0]!.id = 99;
      return done;
    });
    const session = await f.engine.open(undefined, { output: "stream" });
    const events = await Array.fromAsync(session.events);
    expect(events[0]).toMatchObject({ tokenIds: [3], logprobs: [{ top: [{ id: 3 }] }] });
  });

  test("metadata cannot bypass the bounded output queue", async () => {
    const f = fixture(async (output) => {
      await output.commit([3], [{ top: [{ id: 3, logprob: -1 }, { id: 4, logprob: -2 }] }]);
      return done;
    }, { maxTopLogprobs: 1 });
    const session = await f.engine.open(undefined, { output: "stream" });
    expect(await Array.fromAsync(session.events)).toEqual([]);
    expect(await session.result).toMatchObject({ status: "failed",
      error: { message: "top logprobs exceed session delivery capacity" } });
  });

  test("cleanup failures retain the original execution error", async () => {
    const engine = createInferenceEngine({ async plan() { return {
      id: "failure", outputTokenLimit: 1, method: { id: "failure", async createRun() { return {
        async execute() { throw new Error("device failed"); },
        async close() { throw new Error("release failed"); },
      }; } },
    }; } }, { timer: new ManualTimer() });
    const session = await engine.open(undefined, { output: "collect" });
    expect(await session.result).toMatchObject({ status: "failed", error: {
      code: "cleanup_failed", message: "device failed", cleanupError: "release failed",
    } });
    await engine.close();
  });
});
