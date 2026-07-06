// FAST (model-free): the runtime-isolation proxy machinery
// (src/serve/isolate.ts) against a fake UDS engine (tests/fixtures/
// fake-engine.ts). Proves the parent-side contract without weights:
// health gating, body/header passthrough, SSE chunk GRANULARITY (no
// coalescing — the user-visible smoothness property), client-abort
// propagation into the engine, crash → respawn, and engineArgv's
// parent-flag stripping. The real-model E2E is gated in
// tests/isolate-e2e.test.ts.

import { afterAll, describe, expect, test } from "bun:test";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { startProxyServer, engineArgv, type EngineChild } from "../src/serve/isolate";

const FIXTURE = new URL("./fixtures/fake-engine.ts", import.meta.url).pathname;
const sock = join(tmpdir(), `mlxbun-test-engine-${process.pid}.sock`);

let cleanup: Array<() => void> = [];
afterAll(() => { for (const c of cleanup) c(); });

function startFake(): { base: string; engine: EngineChild; stop: () => void } {
  const { server, engine } = startProxyServer({
    port: 0,
    engine: {
      argv: [process.execPath, "run", FIXTURE, sock],
      socketPath: sock,
      readyTimeoutMs: 15_000,
    },
  });
  const stop = () => { engine.stop(); server.stop(true); };
  cleanup.push(stop);
  return { base: `http://localhost:${server.port}`, engine, stop };
}

describe("engineArgv", () => {
  test("strips parent-only flags, keeps engine flags, appends --unix", () => {
    expect(engineArgv(
      ["serve", "cpm5", "--isolate", "--port", "8080", "--host", "0.0.0.0",
       "--batch", "4", "--ssd-cache", "/tmp/x", "--no-open"],
      "/tmp/e.sock",
    )).toEqual(["serve", "cpm5", "--batch", "4", "--ssd-cache", "/tmp/x", "--unix", "/tmp/e.sock"]);
  });
});

describe("isolate proxy (fake engine)", () => {
  const { base, engine } = startFake();

  test("health-gates then passes bodies and headers through", async () => {
    const r = await fetch(`${base}/echo`, {
      method: "POST", body: "hello-engine", headers: { "x-probe": "42" },
    });
    expect(r.status).toBe(200);
    const j = await r.json() as { method: string; body: string; header: string };
    expect(j).toEqual({ method: "POST", body: "hello-engine", header: "42" });
  });

  test("/engine reports the child", async () => {
    const j = await (await fetch(`${base}/engine`)).json() as { isolated: boolean; pid: number };
    expect(j.isolated).toBe(true);
    expect(j.pid).toBeGreaterThan(0);
  });

  test("SSE streams through with chunk granularity preserved", async () => {
    const r = await fetch(`${base}/sse`);
    expect(r.headers.get("content-type")).toContain("text/event-stream");
    const reader = r.body!.getReader();
    const arrivals: number[] = [];
    let text = "";
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      arrivals.push(performance.now());
      text += new TextDecoder().decode(value);
    }
    expect(text).toContain("chunk0");
    expect(text).toContain("chunk3");
    // Granularity: 4 chunks emitted 40 ms apart must NOT arrive as one
    // buffered read; require ≥3 separate reads with a real gap.
    expect(arrivals.length).toBeGreaterThanOrEqual(3);
    expect(arrivals[arrivals.length - 1]! - arrivals[0]!).toBeGreaterThan(60);
  });

  test("client abort propagates into the engine", async () => {
    const ac = new AbortController();
    const r = await fetch(`${base}/sse-forever`, { signal: ac.signal });
    const reader = r.body!.getReader();
    await reader.read(); // stream is live
    ac.abort();
    await new Promise((rr) => setTimeout(rr, 200)); // let the abort travel
    const j = await (await fetch(`${base}/abort-status`)).json() as { aborted: boolean | null };
    expect(j.aborted).toBe(true);
  });

  test("engine crash → respawn → next request succeeds", async () => {
    const j = await (await fetch(`${base}/die`)).json() as { dying: boolean };
    expect(j.dying).toBe(true);
    // The child exits; the proxy respawns it (fresh fake, fast). Requests
    // racing the crash may 502 (by design); within a few seconds the
    // respawned engine serves again.
    // Wait for the exit to register (the fake dies 10 ms after replying).
    let restarts = 0;
    for (let i = 0; i < 60 && restarts < 1; i++) {
      await new Promise((rr) => setTimeout(rr, 250));
      restarts = ((await (await fetch(`${base}/engine`)).json()) as { restarts: number }).restarts;
    }
    expect(restarts).toBeGreaterThanOrEqual(1);
    let ok = false;
    for (let i = 0; i < 40 && !ok; i++) {
      const r = await fetch(`${base}/health`);
      ok = r.status === 200;
      if (!ok) await new Promise((rr) => setTimeout(rr, 250));
    }
    expect(ok).toBe(true);
  }, 20_000);
});
