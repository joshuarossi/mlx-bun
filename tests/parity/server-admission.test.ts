// Run admission with a fresh model process. The general server suite loads
// a vision tower and retains another server's caches outside this budget.
import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "../support/paths";

const haveWeights = await snapshotAvailable();
describe.skipIf(!haveWeights)("server memory admission", async () => {
  if (!haveWeights) return;
  const { createServer, loadContext } = await import("../../src/server");
  const ctx = await loadContext(SNAPSHOT, "gemma-4-12b-it-optiq");

  test.each([1, 8])("batch %s attempts generation even when the estimate says no context fits", async (batch) => {
    // Corrupt accounting only, leaving the actual loaded model unchanged.
    // A false-positive estimate must not prevent real execution on either lane.
    const weightsBytes = ctx.model.weightsBytes;
    Object.defineProperty(ctx.model, "weightsBytes", { value: Number.MAX_SAFE_INTEGER, configurable: true });
    let server: ReturnType<typeof createServer> | undefined;
    try {
      server = createServer(ctx, 0, { batch });
      const stats = await (await fetch(`http://localhost:${server.port}/stats`)).json() as any;
      expect(stats.admission.max_safe_context).toBe(0);
      expect(stats.admission.enforced_context_tokens).toBeNull();
      expect(stats.admission.memory_budget_bytes).toBeNull();
      const response = await fetch(`http://localhost:${server.port}/v1/completions`, {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ prompt: "Hello", max_tokens: 2, temperature: 0 }),
      });
      expect(response.status).toBe(200);
      expect((await response.json() as any).usage.completion_tokens).toBe(2);
    } finally {
      server?.stop(true);
      Object.defineProperty(ctx.model, "weightsBytes", { value: weightsBytes, configurable: true });
    }
  }, 120_000);

  // An explicit operator budget remains an opt-in restriction.
  test("admission: broad completion cap is clamped, in-budget passes unchanged", async () => {
    const { fit } = await import("../../src/fit");
    const { setMemoryLimit } = await import("../../src/mlx/ffi");
    // The client's 4096-token completion cap exceeds this 2048-token
    // context envelope, which must still admit a short prompt.
    const budget = fit(ctx.model.config, ctx.model.weightsBytes, 2048).totalBytes;
    const report = fit(ctx.model.config, ctx.model.weightsBytes, 1,
      undefined, undefined, 0, budget);
    expect(report.maxSafeContext).toBeGreaterThan(0);
    expect(report.maxSafeContext).toBe(2048);

    // the budgeted server caps the process-global mlx allocator — capture
    // and restore so later suites keep the default
    const prevLimit = setMemoryLimit(budget);
    setMemoryLimit(prevLimit);
    const tight = createServer(ctx, 0, { memoryBudgetBytes: budget });
    try {
      const tightBase = `http://localhost:${tight.port}`;

      const stats = (await (await fetch(`${tightBase}/stats`)).json()) as any;
      expect(stats.admission.max_safe_context).toBe(report.maxSafeContext);
      expect(stats.admission.memory_budget_bytes).toBe(budget);

      const over = await fetch(`${tightBase}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "hi" }],
          max_tokens: 4096,
          temperature: 0,
        }),
      });
      expect(over.status).toBe(200);
      const overBody = (await over.json()) as any;
      expect(overBody.error).toBeUndefined();
      expect(overBody.usage.completion_tokens).toBeLessThanOrEqual(report.maxSafeContext);

      const ok = await fetch(`${tightBase}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "Reply with exactly the word: ping" }],
          max_tokens: 8,
          temperature: 0,
        }),
      });
      expect(ok.status).toBe(200);
    } finally {
      tight.stop(true);
      setMemoryLimit(prevLimit);
    }
  }, 240_000);

  test("admission: budget below weights serves diagnostics but refuses generation and load", async () => {
    const diagnostic = createServer(ctx, 0, { memoryBudgetBytes: 1e9 });
    try {
      const response = await fetch(`http://localhost:${diagnostic.port}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "hi" }],
          max_tokens: 1,
          temperature: 0,
        }),
      });
      expect(response.status).toBe(400);
      const body = (await response.json()) as any;
      expect(body.error.type).toBe("memory_admission");
    } finally {
      diagnostic.stop(true);
    }
    await expect(loadContext(SNAPSHOT, undefined, { memoryBudgetBytes: 1e9 }))
      .rejects.toThrow(/does not fit the memory budget/);
  });
});
