import { expect, test } from "bun:test";

test("flush cancels a retry armed by an in-flight failed background snapshot", async () => {
  // Isolate the native-free attachment port and deterministic timer clock from
  // other tests, while exercising the real coordinator and its retry state.
  const script = `
    import { mock } from "bun:test";
    import assert from "node:assert/strict";
    mock.module(import.meta.resolve("./src/state/checkpoint.ts"), () => ({ cloneAttachments: () => [] }));
    const { SsdDurabilityCoordinator } = await import("./src/state/durability.ts");
    const timers = new Map();
    globalThis.setTimeout = callback => {
      const timer = { unref() {} }; timers.set(timer, callback); return timer;
    };
    globalThis.clearTimeout = timer => { timers.delete(timer); };
    const entered = Promise.withResolvers(); const pending = Promise.withResolvers();
    let writes = 0, succeed = false;
    const queue = { pendingCount: 0, pendingBytes: 0, droppedCount: 0, failedCount: 0,
      enqueue() { writes++; entered.resolve(); return writes === 1 ? pending.promise : Promise.resolve(succeed); },
      async drain() {},
    };
    const cache = { findExact: () => ({ tokens: [1], caches: [], ns: "" }) };
    const durability = new SsdDurabilityCoordinator(cache, queue, value => value);
    durability.schedule([1]);
    const [timer, run] = [...timers][0]; timers.delete(timer); run();
    await entered.promise;
    const flushing = durability.flush();
    // The background attempt was already running at flush entry; its failed
    // write rearms a timer while the flush awaits it, before its forced retry.
    pending.resolve(false);
    const result = await flushing;
    assert.equal(result.durable, false); assert.equal(result.pendingSnapshots, 1);
    assert.equal(writes, 2); assert.equal(timers.size, 0);
    // Failure remains retryable by the owner; cancelling timers loses no data.
    succeed = true;
    assert.equal((await durability.flush()).durable, true);
    assert.equal(writes, 3); assert.equal(timers.size, 0);
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], {
    cwd: new URL("../../", import.meta.url).pathname,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent-durability-test" },
    stdout: "pipe", stderr: "pipe",
  });
  const [code, error] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(error).toBe(""); expect(code).toBe(0);
});
