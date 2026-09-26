import { expect, test } from "bun:test";
import { createMemorySynthesis } from "../../src/server/memory-synthesis";
import { createMemoryRoutes } from "../../src/server/memory-routes";

test("shutdown cancels all run clients, stops admission, and joins pipeline cleanup", async () => {
  const ready = Promise.withResolvers<void>(), cleanup = Promise.withResolvers<void>();
  let started = 0, cancelled = 0, cleaned = 0, closed = false;
  const owner = createMemorySynthesis({ root: "/unused-test-vault", apiUrl: () => "http://test",
    http: { fetch: (async (_url, init) => {
      if (++started === 2) ready.resolve();
      return new Promise<Response>((_resolve, reject) => {
        init!.signal!.addEventListener("abort", () => { cancelled++; reject(init!.signal!.reason); }, { once: true });
      });
    }) as typeof fetch },
    run: async (options = {}) => {
      expect(options.root).toBe("/unused-test-vault");
      try {
        await options.client!.complete({ stage: "entity", input: { user: "x" }, maxTokens: 8 });
        throw new Error("unexpected completion");
      } finally { await cleanup.promise; cleaned++; }
    },
  });
  const runs = Promise.allSettled([owner.run({}, () => {}), owner.run({}, () => {})]);
  try {
    await ready.promise;
    const closing = owner.close().then(() => { closed = true; });
    expect(cancelled).toBe(2);
    expect(closed).toBe(false);
    expect(cleaned).toBe(0);
    await expect(owner.run({}, () => {})).rejects.toThrow("owner closed");
    cleanup.resolve();
    await closing;
    expect(cleaned).toBe(2);
    expect((await runs).every(result => result.status === "rejected")).toBe(true);
  } finally { cleanup.resolve(); await owner.close(); await runs; }
});

test("aborting one synthesis Request cancels only its run and emits no success", async () => {
  const ready = Promise.withResolvers<void>();
  let starts = 0;
  const signals: AbortSignal[] = [];
  const owner = createMemorySynthesis({ root: "/unused-test-vault", apiUrl: () => "http://test",
    run: async (options = {}) => {
      signals.push(options.signal!);
      if (++starts === 2) ready.resolve();
      await new Promise<void>(resolve => options.signal!.addEventListener("abort", () => resolve(), { once: true }));
      options.signal!.throwIfAborted();
      return { implemented: true, stages: [], note: "unexpected success" };
    },
  });
  const routes = createMemoryRoutes({ synthesize: owner.run });
  const a = new AbortController(), b = new AbortController();
  try {
    const first = (await routes.handle(new Request("http://test/v1/memory/synthesize", { signal: a.signal })))!;
    const second = (await routes.handle(new Request("http://test/v1/memory/synthesize", { signal: b.signal })))!;
    await ready.promise;
    a.abort(new Error("request disconnected"));
    expect(await first.text()).toBe("");
    expect(signals[0]!.aborted).toBe(true);
    expect(signals[1]!.aborted).toBe(false);
    await owner.close();
    const stopped = await second.text();
    expect(stopped).toContain("owner closed");
    expect(stopped).not.toContain("summary");
    expect(stopped).not.toContain("[DONE]");
  } finally { await owner.close(); }
});

test("cancelling the synthesis response body aborts the run and waits for its cleanup", async () => {
  const ready = Promise.withResolvers<void>(), cleanup = Promise.withResolvers<void>();
  let signal: AbortSignal | undefined, joined = false;
  const owner = createMemorySynthesis({ root: "/unused-test-vault", apiUrl: () => "http://test",
    run: async (options = {}) => {
      signal = options.signal;
      ready.resolve();
      await new Promise<void>(resolve => signal!.addEventListener("abort", () => resolve(), { once: true }));
      await cleanup.promise;
      signal!.throwIfAborted();
      return { implemented: true, stages: [], note: "unexpected success" };
    },
  });
  try {
    const routes = createMemoryRoutes({ synthesize: owner.run });
    const response = (await routes.handle(new Request("http://test/v1/memory/synthesize")))!;
    await ready.promise;
    const cancel = response.body!.cancel().then(() => { joined = true; });
    expect(signal!.aborted).toBe(true);
    expect(joined).toBe(false);
    cleanup.resolve();
    await cancel;
    expect(joined).toBe(true);
  } finally { cleanup.resolve(); await owner.close(); }
});
