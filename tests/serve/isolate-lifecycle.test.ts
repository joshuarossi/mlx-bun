import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { EngineChild } from "../../src/serve/isolate";
import { createCompletionClient, createDirectHost } from "../../src/client";

const pause = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

test("close waits for startup admission to settle and release its lease", async () => {
  let admit!: (lease: { dispose(): void }) => void;
  let released = false;
  const child = new EngineChild({ argv: [process.execPath, "-e", "process.exit(0)"],
    socketPath: join(tmpdir(), `mlx-close-startup-${crypto.randomUUID()}.sock`),
    acquire: () => new Promise((resolve) => { admit = resolve; }),
  });
  let closed = false;
  const closing = child.close().then(() => { closed = true; });
  try {
    await pause(10);
    expect(closed).toBe(false);
  } finally {
    admit({ dispose() { released = true; } });
    await closing;
  }
  expect(released).toBe(true);
  expect(child.pid).toBeNull();
});

test("direct and isolated hosts satisfy the same completion client contract", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-host-contract-"));
  const socket = join(dir, "engine.sock");
  const code = `Bun.serve({unix: process.argv[1], async fetch(request) {
    if (new URL(request.url).pathname === '/health') return new Response('ok');
    const body = await request.json(); return Response.json({choices: [{text: body.prompt}]});
  }});`;
  const isolated = new EngineChild({ argv: [process.execPath, "-e", code, socket], socketPath: socket, maxRestarts: 0 });
  const direct = createDirectHost(async (request) => {
    const body = await request.json() as { prompt: string };
    return Response.json({ choices: [{ text: body.prompt }] });
  });
  try {
    for (const host of [direct, isolated]) {
      await host.ready;
      const client = createCompletionClient({ baseUrl: "http://engine/v1", host });
      expect(await client.complete({ route: "completions", body: { prompt: "same request" } }))
        .toEqual({ choices: [{ text: "same request" }] });
    }
  } finally { await direct.close(); await isolated.close(); rmSync(dir, { recursive: true, force: true }); }
});

test("startup crash loops stop at the restart budget", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-host-crash-"));
  const child = new EngineChild({ argv: [process.execPath, "-e", "process.exit(7)"],
    socketPath: join(dir, "engine.sock"), maxRestarts: 2, restartDelayMs: 5, readyTimeoutMs: 1000 });
  try {
    for (let i = 0; i < 100 && child.restarts < 2; i++) await pause(10);
    await pause(100);
    await expect(child.ready).rejects.toThrow("restart limit");
    expect(child.restarts).toBe(2);
    await pause(100);
    expect(child.restarts).toBe(2);
  } finally { await child.close(); rmSync(dir, { recursive: true, force: true }); }
});

test("closing during restart backoff prevents another spawn", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-host-stop-"));
  const child = new EngineChild({ argv: [process.execPath, "-e", "process.exit(7)"],
    socketPath: join(dir, "engine.sock"), restartDelayMs: 1000, readyTimeoutMs: 1000 });
  try {
    for (let i = 0; i < 100 && child.restarts === 0; i++) await pause(10);
    await child.close();
    const count = child.restarts;
    await pause(30);
    await expect(child.ready).rejects.toThrow("closed");
    expect(child.restarts).toBe(count);
  } finally { await child.close(); rmSync(dir, { recursive: true, force: true }); }
});

test("disconnect while waiting for startup rejects promptly without forwarding a POST", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-host-abort-"));
  const child = new EngineChild({ argv: [process.execPath, "-e", "setInterval(() => {}, 1000)"],
    socketPath: join(dir, "engine.sock"), maxRestarts: 0, readyTimeoutMs: 1000 });
  const abort = new AbortController();
  try {
    const result = child.forward(new Request("http://engine/v1/completions", {
      method: "POST", body: "{}", signal: abort.signal,
    })).then(() => null, (error) => error);
    abort.abort(new Error("client left"));
    expect((await result).message).toBe("client left");
    await child.close();
    await expect(child.forward(new Request("http://engine/health"))).rejects.toThrow("closed");
  } finally { await child.close(); rmSync(dir, { recursive: true, force: true }); }
});

test("parent application state remains available through worker death", async () => {
  const { startProxyServer } = await import("../../src/serve/isolate");
  const { JobStore } = await import("../../src/jobs/db");
  const dir = mkdtempSync(join(tmpdir(), "mlx-parent-state-"));
  const socket = join(dir, "engine.sock");
  const store = new JobStore(join(dir, "jobs.db"), join(dir, "logs"));
  const row = store.create("noop", {});
  store.setStatus(row.id, "done");
  let opened = 0;
  const host = startProxyServer({ port: 0,
    createJobStore: async () => { opened++; return store; },
    engine: { argv: [process.execPath, "-e", "setInterval(() => {}, 1000)"],
      socketPath: socket, maxRestarts: 0, readyTimeoutMs: 1000 },
  });
  try {
    const get = async () => (await (await fetch(`http://localhost:${host.server.port}/api/jobs/${row.id}`)).json()) as any;
    expect((await get()).job.status).toBe("done");
    host.engine.stop();
    const shell = await fetch(`http://localhost:${host.server.port}/`);
    expect(shell.status).toBe(200);
    expect(shell.headers.get("content-type")).toContain("text/html");
    expect((await get()).job.id).toBe(row.id);
    expect(opened).toBe(1);
  } finally { await host.close(); rmSync(dir, { recursive: true, force: true }); }
});

test("GPU admission also blocks worker startup; closing cancels that wait without spawning", async () => {
  const { ExecutionCoordinator } = await import("../../src/engine/execution-coordinator");
  const { acquireReservation } = await import("../../src/serve/preparation");
  const coordinator = new ExecutionCoordinator();
  const job = await coordinator.acquire("exclusive");
  const dir = mkdtempSync(join(tmpdir(), "mlx-startup-lease-"));
  const child = new EngineChild({ argv: [process.execPath, "-e", "setInterval(() => {}, 1000)"],
    socketPath: join(dir, "engine.sock"),
    acquire: (signal) => acquireReservation({ acquire: (cancel) => coordinator.acquire("shared", cancel) }, signal),
  });
  try {
    await pause(20); expect(child.pid).toBeNull();
    await child.close();
    await expect(child.ready).rejects.toThrow("cancelled");
    job.dispose(); await pause(20); expect(child.pid).toBeNull();
  } finally { await child.close(); job.dispose(); coordinator.close(); rmSync(dir, { recursive: true, force: true }); }
});
