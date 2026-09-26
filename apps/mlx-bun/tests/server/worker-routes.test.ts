import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ChatBackendFactory } from "../../src/chat/backend";
import { startServer } from "../../src/server/start";
import { createWorkerRoutes } from "../../src/server/worker-routes";

// The worker's admin surface over a real Unix socket, with a fake exclusive
// lease standing in for the gateway. The worker entry test composes the real host.
const idle: ChatBackendFactory = () => ({ async start() {}, async handle() {}, dispose() {} });

/** One holder at a time; waiters queue in order and leave the queue on abort. */
function exclusiveLease() {
  let tail = Promise.resolve(), held = 0;
  return { get held() { return held; }, async acquire(signal: AbortSignal) {
    signal.throwIfAborted();
    const previous = tail;
    let release!: () => void;
    tail = new Promise<void>(resolve => { release = resolve; });
    const abort = new Promise<never>((_, reject) => signal.addEventListener("abort", () => reject(signal.reason), { once: true }));
    try { await Promise.race([previous, abort]); }
    catch (error) { void previous.then(release); throw error; }
    held++;
    let released = false;
    return { dispose() { if (released) return; released = true; held--; release(); } };
  } };
}

async function until(check: () => boolean, what: string) {
  const end = Date.now() + 5000;
  while (!check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(5); }
}

function socketDir() {
  const dir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  return { dir, unix: join(dir, "worker.sock"), remove: () => rmSync(dir, { recursive: true, force: true }) };
}

const model = (slow?: Promise<void>) => ({ async handle(request: Request) {
  const path = new URL(request.url).pathname;
  if (path === "/v1/models") return Response.json({ object: "list", data: [{ id: "org/model" }] });
  if (path === "/health") return Response.json({ status: "ok" });
  if (path === "/slow") { await slow; return Response.json({ done: true }); }
  return null;
} });

test("the worker surface reports readiness, owns a lease per connection, and answers ahead of the model routes", async () => {
  const socket = socketDir(), gate = exclusiveLease();
  const admin = createWorkerRoutes({ modelId: "org/model", pid: 42, acquireExecutionLease: signal => gate.acquire(signal) });
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, chat: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
  const get = (path: string, init: RequestInit = {}) => fetch(`http://worker${path}`, { ...init, unix: socket.unix } as RequestInit);
  try {
    expect(app.server.port).toBeUndefined();
    expect(statSync(socket.unix).mode & 0o777).toBe(0o600);
    expect(await (await get("/health")).json()).toEqual({ status: "ok", state: "ready", model: "org/model", pid: 42, in_flight: 0, leases: 0 });
    expect(await (await get("/v1/models")).json()).toEqual({ object: "list", data: [{ id: "org/model" }] });
    for (const [path, init, status, allow] of [["/health", { method: "POST" }, 405, "GET"], ["/admin/lease", {}, 405, "POST"], ["/admin/drain", {}, 405, "POST"]] as const) {
      const response = await get(path, init);
      expect([response.status, response.headers.get("allow")]).toEqual([status, allow]);
    }
    expect((await get("/api/jobs")).status).toBe(404);
    expect((await get("/engine")).status).toBe(501);
    // The connection owns the lease: the body stays open, a disconnect releases it.
    const holder = new AbortController();
    const leased = await get("/admin/lease", { method: "POST", signal: holder.signal });
    expect([leased.status, leased.headers.get("content-type")]).toEqual([200, "application/octet-stream"]);
    const reader = leased.body!.getReader();
    expect(new TextDecoder().decode((await reader.read()).value)).toBe("leased\n");
    expect(gate.held).toBe(1);
    expect((await (await get("/health")).json()).leases).toBe(1);
    // A second lease queues behind the first; its client giving up leaves the queue.
    await expect(get("/admin/lease", { method: "POST", signal: AbortSignal.timeout(100) })).rejects.toThrow();
    expect(gate.held).toBe(1);
    holder.abort();
    await until(() => gate.held === 0, "the lease release on disconnect");
    expect((await (await get("/health")).json()).leases).toBe(0);
    // Cancelling the body releases it too.
    const cancelled = await get("/admin/lease", { method: "POST" });
    await until(() => gate.held === 1, "the second lease");
    await cancelled.body!.cancel();
    await until(() => gate.held === 0, "the lease release on cancel");
  } finally { await app.close(); }
  expect(existsSync(socket.unix)).toBe(false);
  socket.remove();
});

test("drain stops admission, waits for admitted requests and the execution lease within a deadline, and reports either way", async () => {
  const socket = socketDir(), gate = exclusiveLease(), slow = Promise.withResolvers<void>();
  const admin = createWorkerRoutes({ modelId: "org/model", pid: 7, acquireExecutionLease: signal => gate.acquire(signal), drainTimeoutMs: 5000 });
  const app = await startServer({ routes: admin.wrap(model(slow.promise)), web: () => null, chat: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
  const get = (path: string, init: RequestInit = {}) => fetch(`http://worker${path}`, { ...init, unix: socket.unix } as RequestInit);
  const drain = async (body?: unknown) => (await get("/admin/drain", { method: "POST", ...(body === undefined ? {} : { body: JSON.stringify(body) }) })).json();
  try {
    for (const body of ["not json", { timeout_ms: -1 }, { timeout_ms: "soon" }])
      expect((await get("/admin/drain", { method: "POST", body: typeof body === "string" ? body : JSON.stringify(body) })).status).toBe(400);
    expect(admin.state()).toBe("ready");
    const pending = get("/slow");
    await until(() => admin.state() === "ready" && true, "nothing");
    let health = await (await get("/health")).json();
    await until(() => health.in_flight === 1 || false, "the slow request to be admitted");
    expect(await drain({ timeout_ms: 50 })).toMatchObject({ drained: false, timed_out: true, state: "draining", in_flight: 1, leases: 0 });
    expect(admin.state()).toBe("draining");
    // Admission is shut for model routes; the admin surface keeps answering.
    const refused = await get("/v1/models");
    expect([refused.status, (await refused.json()).error.type]).toEqual([503, "draining"]);
    health = await (await get("/health")).json();
    expect(health).toMatchObject({ state: "draining", in_flight: 1 });
    slow.resolve();
    expect(await (await pending).json()).toEqual({ done: true });
    // A held execution lease (a managed job) also keeps the worker from being drained.
    const holder = new AbortController();
    const leased = await get("/admin/lease", { method: "POST", signal: holder.signal });
    await leased.body!.getReader().read();
    expect(await drain({ timeout_ms: 50 })).toMatchObject({ drained: false, timed_out: true, in_flight: 0, leases: 1 });
    holder.abort();
    await until(() => gate.held === 0, "the lease release");
    const report = await drain();
    expect(report).toMatchObject({ drained: true, timed_out: false, state: "draining", model: "org/model", in_flight: 0, leases: 0 });
    expect(report.waited_ms).toBeLessThan(5000);
    expect((await get("/v1/models")).status).toBe(503);
  } finally { slow.resolve(); await app.close(); }
  socket.remove();
});

test("closing the worker surface ends held lease connections so the listener can drain, and refuses new leases", async () => {
  const socket = socketDir(), gate = exclusiveLease();
  const admin = createWorkerRoutes({ modelId: "org/model", acquireExecutionLease: signal => gate.acquire(signal) });
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, chat: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
  const get = (path: string, init: RequestInit = {}) => fetch(`http://worker${path}`, { ...init, unix: socket.unix } as RequestInit);
  try {
    const leased = await get("/admin/lease", { method: "POST" });
    const reader = leased.body!.getReader();
    await reader.read();
    expect(gate.held).toBe(1);
    expect((await (await get("/health")).json()).pid).toBe(process.pid);
    const closing = app.close();
    expect((await reader.read()).done).toBe(true);
    await closing;
    expect(gate.held).toBe(0);
  } finally { await app.close(); }
  const lease = createWorkerRoutes({ modelId: "org/model", acquireExecutionLease: signal => gate.acquire(signal) });
  lease.close();
  const refused = await lease.wrap(model()).handle(new Request("http://worker/admin/lease", { method: "POST" }));
  expect(refused?.status).toBe(503);
  socket.remove();
});

test("lease failures answer 503, a caller that left answers 499, and the ordinary TCP listener keeps lease and drain unmigrated", async () => {
  const failing = createWorkerRoutes({ modelId: "org/model", async acquireExecutionLease() { throw new Error("gateway is closed"); } });
  const failed = await failing.wrap(model()).handle(new Request("http://worker/admin/lease", { method: "POST" }));
  expect([failed?.status, (await failed?.json()).error.type]).toEqual([503, "lease_failed"]);
  const gone = new AbortController(); gone.abort();
  const left = await failing.wrap(model()).handle(new Request("http://worker/admin/lease", { method: "POST", signal: gone.signal }));
  expect(left?.status).toBe(499);
  const app = await startServer({ routes: model(), web: () => null, chat: idle, async closeEngine() {} }, { port: 0 });
  try {
    for (const path of ["/admin/lease", "/admin/drain"]) {
      const response = await fetch(new URL(path, app.server.url), { method: "POST" });
      expect([response.status, (await response.json()).error.type]).toEqual([501, "not_implemented"]);
    }
    expect(await (await fetch(new URL("/health", app.server.url))).json()).toEqual({ status: "ok" });
  } finally { await app.close(); }
});

test("a lease acquisition still pending at close is cancelled and joined, and one that resolves late is disposed, never published", async () => {
  // Late resolution: the gateway hands the lease over after close() ran.
  let handOver!: (lease: { dispose(): void }) => void;
  let disposed = 0;
  const seen: AbortSignal[] = [];
  const late = createWorkerRoutes({ modelId: "m", acquireExecutionLease: signal => {
    seen.push(signal);
    return new Promise(resolve => { handOver = resolve; });
  } });
  const group = late.wrap({ async handle() { return null; } });
  const leasing = group.handle(new Request("http://worker/admin/lease", { method: "POST" }));
  await until(() => seen.length === 1, "the acquisition to start");
  let closedAt: number | undefined;
  const closing = late.close().then(() => { closedAt = Date.now(); });
  await Bun.sleep(10);
  expect(closedAt).toBeUndefined();
  expect(seen[0]!.aborted).toBe(true);
  handOver({ dispose() { disposed++; } });
  const response = (await leasing)!;
  expect(response.status).toBe(503);
  expect(((await response.json()) as { error: { type: string } }).error.type).toBe("unavailable");
  expect(disposed).toBe(1);
  await closing;
  const health = await group.handle(new Request("http://worker/health"));
  expect(((await health!.json()) as { leases: number }).leases).toBe(0);
  // Cancelled acquisition: the gateway honours the composed signal and rejects.
  const cancelled = createWorkerRoutes({ modelId: "m", acquireExecutionLease: signal =>
    new Promise((_, reject) => signal.addEventListener("abort", () => reject(signal.reason), { once: true })) });
  const cancelledGroup = cancelled.wrap({ async handle() { return null; } });
  const waiting = cancelledGroup.handle(new Request("http://worker/admin/lease", { method: "POST" }));
  await Bun.sleep(5);
  await cancelled.close();
  expect((await waiting)!.status).toBe(503);
  await expect(cancelledGroup.handle(new Request("http://worker/admin/lease", { method: "POST" })).then(r => r!.status)).resolves.toBe(503);
});

test("a drain whose request signal is already aborted returns at once while work is in flight", async () => {
  let finish!: () => void;
  const slow = new Promise<void>(resolve => { finish = resolve; });
  const admin = createWorkerRoutes({ modelId: "m", acquireExecutionLease: async () => ({ dispose() {} }) });
  const group = admin.wrap({ async handle() { await slow; return new Response("done"); } });
  const inflight = group.handle(new Request("http://worker/v1/chat/completions", { method: "POST" }));
  await Bun.sleep(5);
  const gone = new AbortController(); gone.abort(new Error("caller left"));
  const started = Date.now();
  const drain = (await group.handle(new Request("http://worker/admin/drain", { method: "POST", signal: gone.signal })))!;
  expect(Date.now() - started).toBeLessThan(1000);
  const report = (await drain.json()) as { drained: boolean; timed_out: boolean; in_flight: number };
  expect(report).toMatchObject({ drained: false, timed_out: false, in_flight: 1 });
  finish();
  expect(await (await inflight)!.text()).toBe("done");
  await admin.close();
});
