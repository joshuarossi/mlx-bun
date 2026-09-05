import { expect, test } from "bun:test";
import { handleModelAdminRoute } from "../../src/serve/model-admin-routes";
import type { ServingContext } from "../../src/serve/model-host";

test("embeddings wait for the shared execution lease before touching the model", async () => {
  let entered!: () => void;
  const requested = new Promise<void>((resolve) => { entered = resolve; });
  let release!: () => void;
  const held = new Promise<void>((resolve) => { release = resolve; });
  let calls = 0;
  const ctx = { modelId: "embedding-port", serving: {
    embed: () => { calls++; return [{ vector: new Float32Array([1, 0]), tokens: 3 }]; },
  } } as unknown as ServingContext;
  const request = new Request("http://local/v1/embeddings", {
    method: "POST", body: JSON.stringify({ input: "hello" }),
  });
  const response = handleModelAdminRoute(new URL(request.url), request, ctx, {
    async runExclusive(work, _trace, signal) {
      expect(signal).toBe(request.signal);
      entered();
      await held;
      return work();
    },
  });
  await requested;
  expect(calls).toBe(0);
  release();
  const result = await response;
  expect(result?.status).toBe(200);
  expect(calls).toBe(1);
  expect(await result!.json()).toMatchObject({ data: [{ embedding: [1, 0] }], usage: { total_tokens: 3 } });
});
