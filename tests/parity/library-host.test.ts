import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT_MINICPM5 } from "../support/paths";
import { openIsolatedHost } from "../../src/library";
import { createCompletionClient } from "../../src/client";

const enabled = process.env.MLX_BUN_TEST_BATCH_DECODE === "1" && existsSync(`${SNAPSHOT_MINICPM5}/config.json`);
describe.skipIf(!enabled)("high-level library with a real worker", () => {
  test("bootstrap, completion and shutdown require no native objects at the client", async () => {
    const host = await openIsolatedHost(SNAPSHOT_MINICPM5, { readyTimeoutMs: 180_000 });
    try {
      const client = createCompletionClient({ baseUrl: "http://engine/v1", host });
      const response = await client.complete({ body: {
        messages: [{ role: "user", content: "Say hello." }], max_tokens: 8, temperature: 0,
      } });
      expect(response.choices.length).toBe(1);
    } finally { await host.close(); }
  }, 240_000);
});
