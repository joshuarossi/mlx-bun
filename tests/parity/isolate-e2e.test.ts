// GATED (loads cpm5, spawns a real engine child through the real CLI):
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/isolate-e2e.test.ts
//
// End-to-end runtime isolation (docs/reference/server-config.md): the parent proxy
// serves a real chat completion from an engine child on a unix socket,
// streams SSE incrementally, and stays responsive while the GPU decodes.
// The proxy MACHINERY is gated model-free in tests/isolate-proxy.test.ts;
// this proves the composition with the real server + model.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { SNAPSHOT_MINICPM5 } from "../support/paths";
import { startProxyServer, engineArgv } from "../../src/serve/isolate";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const haveCpm = existsSync(`${SNAPSHOT_MINICPM5}/config.json`);
const CLI = new URL("../../src/cli.ts", import.meta.url).pathname;

describe.skipIf(!optIn || !haveCpm)("runtime isolation E2E (cpm5 engine child)", () => {
  // GUARD: describe bodies run even when skipIf filters the tests — an
  // unguarded spawn here orphaned a model server in every ungated suite
  // run (found live, 2026-07-05). Heavy setup must early-return too.
  if (!optIn || !haveCpm) return;
  const sock = join(tmpdir(), `mlxbun-e2e-engine-${process.pid}.sock`);
  const started = startProxyServer({
    port: 0,
    engine: {
      argv: [process.execPath, "run", CLI,
        ...engineArgv(["serve", SNAPSHOT_MINICPM5, "--no-open"], sock)],
      socketPath: sock,
      readyTimeoutMs: 180_000,
    },
  });
  const base = `http://localhost:${started.server.port}`;
  afterAll(() => { started.engine.stop(); started.server.stop(true); });

  test("chat completion round-trips through the proxy", async () => {
    const r = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Say the word hello." }],
        max_tokens: 16,
      }),
    });
    expect(r.status).toBe(200);
    const j = await r.json() as { choices: Array<{ message: { content: string } }> };
    expect(j.choices[0]!.message.content.length).toBeGreaterThan(0);
  }, 240_000);

  test("streaming SSE arrives incrementally; parent stays responsive mid-decode", async () => {
    const gen = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Count from one to fifty in words." }],
        max_tokens: 96,
        stream: true,
      }),
    });
    expect(gen.status).toBe(200);
    const reader = gen.body!.getReader();
    let reads = 0;
    let sawDone = false;
    let probedMs = -1;
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      reads++;
      const text = new TextDecoder().decode(value);
      if (text.includes("[DONE]")) sawDone = true;
      if (reads === 5 && probedMs < 0) {
        // Mid-decode: the PARENT answers instantly regardless of the GPU
        // (the isolation exit criterion — <50 ms; generous CI bound 250 ms).
        const t0 = performance.now();
        const eng = await fetch(`${base}/engine`);
        probedMs = performance.now() - t0;
        expect(eng.status).toBe(200);
      }
    }
    console.log(`[isolate-e2e] sse reads=${reads} parentProbeMs=${probedMs.toFixed(1)}`);
    expect(reads).toBeGreaterThan(5); // incremental, not one buffered blob
    expect(sawDone).toBe(true);
    expect(probedMs).toBeGreaterThanOrEqual(0);
    expect(probedMs).toBeLessThan(250);
  }, 240_000);
});
