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
import { startProxyServer, engineArgv, engineArgvForModel, type EngineChild } from "../../src/serve/isolate";
import { existsSync, rmSync } from "node:fs";

const FIXTURE = new URL("../fixtures/fake-engine.ts", import.meta.url).pathname;
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

describe("engineArgvForModel", () => {
  test("strips model selectors + positional, pins --model, keeps engine flags", () => {
    expect(engineArgvForModel(
      ["serve", "cpm5", "--isolate", "--batch", "4", "--model", "old", "--ssd-cache", "/t", "--port", "9090"],
      "/s.sock", "/models/real",
    )).toEqual(["serve", "--batch", "4", "--ssd-cache", "/t", "--model", "/models/real", "--unix", "/s.sock"]);
  });
  test("bare auto-pick invocation (no subcommand token) gains serve", () => {
    expect(engineArgvForModel(["--isolate"], "/s.sock", "/m"))
      .toEqual(["serve", "--model", "/m", "--unix", "/s.sock"]);
  });
});

describe("model pool (fake engines)", () => {
  const sockFor = (id: string) => join(tmpdir(), `mlxbun-pool-${process.pid}-${id}.sock`);
  const mkPool = (poolMax: number) => {
    const resolve = (q: string) =>
      q === "model-a" ? { repoId: "model-a", path: "/models/a" } :
      q === "model-b" ? { repoId: "model-b", path: "/models/b" } :
      q === "model-c" ? { repoId: "model-c", path: "/models/c" } : null;
    const selfArgv = [process.execPath, "run", FIXTURE];
    const rawArgs = ["serve", "some-query", "--batch", "2"];
    const started = startProxyServer({
      port: 0,
      engine: {
        argv: [...selfArgv, ...engineArgvForModel(rawArgs, sockFor("model-a"), "/models/a")],
        socketPath: sockFor("model-a"),
        readyTimeoutMs: 15_000,
      },
      pool: {
        rawArgs, selfArgv, poolMax, resolve,
        defaultKey: "model-a",
        socketFor: sockFor,
      },
    });
    cleanup.push(() => { started.pool?.stopAll(); started.engine.stop(); started.server.stop(true); });
    return { base: `http://localhost:${started.server.port}`, ...started };
  };
  const ask = async (base: string, model?: string) => {
    const r = await fetch(`${base}/v1/chat/completions`, {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [], ...(model ? { model } : {}) }),
    });
    return await r.json() as { served_by: string; requested: string | null };
  };

  test("routes by model field; unknown/absent ride the default (drop-in)", async () => {
    const { base } = mkPool(2);
    expect((await ask(base)).served_by).toBe("/models/a");
    expect((await ask(base, "gpt-4")).served_by).toBe("/models/a"); // ignored, like mlx-lm
    expect((await ask(base, "model-a")).served_by).toBe("/models/a");
    const b = await ask(base, "model-b"); // spawn-overlap: second child
    expect(b.served_by).toBe("/models/b");
    const eng = await (await fetch(`${base}/engine`)).json() as { pool: { resident: string[] } };
    expect(eng.pool.resident.sort()).toEqual(["model-a", "model-b"]);
  }, 30_000);

  test("concurrent cold switches each reach their selected worker before eviction", async () => {
    const { base } = mkPool(1);
    expect((await ask(base)).served_by).toBe("/models/a");
    const results = await Promise.all([ask(base, "model-b"), ask(base, "model-c")]);
    expect(results.map((result) => result.served_by)).toEqual(["/models/b", "/models/c"]);
  }, 30_000);

  test("pool cap 1: switching drains + demotes + evicts the old model, and back again", async () => {
    const { base, pool } = mkPool(1);
    const drainMarker = `${sockFor("model-a")}.drained`;
    rmSync(drainMarker, { force: true });
    expect((await ask(base, "model-a")).served_by).toBe("/models/a");

    expect((await ask(base, "model-b")).served_by).toBe("/models/b"); // switch
    // eviction ran: model-a got /admin/drain (marker) and left the pool
    for (let i = 0; i < 20 && !existsSync(drainMarker); i++)
      await new Promise((r) => setTimeout(r, 100));
    expect(existsSync(drainMarker)).toBe(true);
    const eng = await (await fetch(`${base}/engine`)).json() as {
      pid: number | null; restarts: number | null; socket: string | null;
      pool: { resident: string[] };
    };
    expect(eng.pool.resident).toEqual(["model-b"]);
    expect(eng.pid).toBeNull();
    expect(eng.restarts).toBeNull();
    expect(eng.socket).toBeNull();
    expect(pool!.residentKeys).toEqual(["model-b"]);

    // ... and switching BACK respawns model-a (state would restore from SSD)
    expect((await ask(base)).served_by).toBe("/models/a");
    const restored = await (await fetch(`${base}/engine`)).json() as { pid: number; socket: string };
    expect(restored.pid).toBe(pool!.child("model-a")!.pid!);
    expect(restored.socket).toBe(pool!.child("model-a")!.spec.socketPath);
    expect((await ask(base, "model-b")).served_by).toBe("/models/b");
    expect((await ask(base, "unknown")).served_by).toBe("/models/a");
  }, 30_000);
});
