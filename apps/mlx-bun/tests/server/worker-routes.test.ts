import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createModuleSockets } from "@mlx-bun/app-services";
import type { MemoryCompletionClient, MemoryCompletionRequest } from "../../src/memory/model";
import { startServer } from "../../src/server/start";
import { createWorkerRoutes } from "../../src/server/worker-routes";

// The worker's admin surface over a real Unix socket, with a fake exclusive
// lease standing in for the gateway. The worker entry test composes the real host.
const idle = createModuleSockets([]);

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
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, sockets: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
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
    expect((await get("/engine")).status).toBe(404);
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
  const app = await startServer({ routes: admin.wrap(model(slow.promise)), web: () => null, sockets: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
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
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, sockets: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
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

test("lease failures answer 503, a caller that left answers 499, and the ordinary TCP listener has no lease or drain route", async () => {
  const failing = createWorkerRoutes({ modelId: "org/model", async acquireExecutionLease() { throw new Error("gateway is closed"); } });
  const failed = await failing.wrap(model()).handle(new Request("http://worker/admin/lease", { method: "POST" }));
  expect([failed?.status, (await failed?.json()).error.type]).toEqual([503, "lease_failed"]);
  const gone = new AbortController(); gone.abort();
  const left = await failing.wrap(model()).handle(new Request("http://worker/admin/lease", { method: "POST", signal: gone.signal }));
  expect(left?.status).toBe(499);
  const app = await startServer({ routes: model(), web: () => null, sockets: idle, async closeEngine() {} }, { port: 0 });
  try {
    for (const path of ["/admin/lease", "/admin/drain"]) {
      const response = await fetch(new URL(path, app.server.url), { method: "POST" });
      expect([response.status, (await response.json()).error.message]).toEqual([404, "Not found"]);
    }
    // The memory route exists only on a worker's socket: over TCP it is an unknown path.
    const memory = await fetch(new URL("/admin/memory/complete", app.server.url), { method: "POST", body: "{}" });
    expect([memory.status, (await memory.json()).error.message]).toEqual([404, "Not found"]);
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

/** The execution lease with its grants and releases in `events`. */
const logged = (gate: ReturnType<typeof exclusiveLease>, events: string[]) => async (signal: AbortSignal) => {
  const lease = await gate.acquire(signal);
  events.push("lease");
  return { dispose() { events.push("release"); lease.dispose(); } };
};

/** A memory task model whose first call loads it, recording the lease count
 * then; rows answer `out <user>`, `fail` rejects, and `hold…` rows wait for
 * release() or the call's signal, then join `joinMs` later. A batch settles
 * only after every row has, as the in-process task model does. */
function taskModel(gate: { readonly held: number }, events: string[], joinMs = 0) {
  let loaded = false;
  const waiting = new Set<() => void>();
  const signals: AbortSignal[] = [], snapshots: string[] = [];
  const row = async (request: MemoryCompletionRequest, signal: AbortSignal) => {
    const user = request.input.user;
    events.push(`row ${user} held=${gate.held}`);
    if (user.startsWith("hold")) await new Promise<void>((resolve, reject) => {
      const done = () => { waiting.delete(done); resolve(); };
      waiting.add(done);
      signal.addEventListener("abort", () => {
        waiting.delete(done);
        void Bun.sleep(joinMs).then(() => { events.push(`joined ${user}`); reject(signal.reason); });
      }, { once: true });
    });
    if (user === "fail") throw new Error("row failed");
    return `out ${request.stage} ${user}`;
  };
  const load = async () => { if (!loaded) { loaded = true; events.push(`load held=${gate.held}`); } };
  return {
    signals, snapshots,
    get waiting() { return waiting.size; },
    release() { for (const done of [...waiting]) done(); },
    clientFor(signal: AbortSignal, snapshot: string): MemoryCompletionClient {
      signals.push(signal); snapshots.push(snapshot);
      return {
        async complete(request) { await load(); return row(request, signal); },
        async completeBatch(requests) {
          await load();
          const settled = await Promise.allSettled(requests.map(request => row(request, signal)));
          const failed = settled.find((result): result is PromiseRejectedResult => result.status === "rejected");
          if (failed) throw failed.reason;
          return settled.map(result => (result as PromiseFulfilledResult<string>).value);
        },
      };
    },
  };
}
const call = (kind: "complete" | "completeBatch", users: string[], stage = "entity") =>
  ({ call: kind, snapshot: "/hub/task/snapshots/selected", requests: users.map(user => ({ stage, input: { user }, maxTokens: 8 })) });

test("the private memory route runs one call or batch on the task model under the execution lease, taken before the lazy load and released after the rows, and answers the ordered raw outputs", async () => {
  const socket = socketDir(), gate = exclusiveLease(), events: string[] = [];
  const task = taskModel(gate, events);
  const admin = createWorkerRoutes({ modelId: "org/model", acquireExecutionLease: logged(gate, events), memoryTaskModel: task });
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, sockets: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
  const post = (body: unknown, init: RequestInit = {}) => fetch("http://worker/admin/memory/complete", { method: "POST", body: typeof body === "string" ? body : JSON.stringify(body), ...init, unix: socket.unix } as RequestInit);
  try {
    const batch = await post(call("completeBatch", ["a", "b", "c"]));
    expect([batch.status, await batch.json()]).toEqual([200, { outputs: ["out entity a", "out entity b", "out entity c"] }]);
    expect(events).toEqual(["lease", "load held=1", "row a held=1", "row b held=1", "row c held=1", "release"]);
    events.length = 0;
    const single = await post({ call: "complete", snapshot: "/hub/task/snapshots/other", requests: [{ stage: "route", input: { system: "yes or no", user: "x" }, maxTokens: 4 }] });
    expect(await single.json()).toEqual({ outputs: ["out route x"] });
    expect(events).toEqual(["lease", "row x held=1", "release"]);
    expect(task.signals.every(signal => !signal.aborted)).toBe(true);
    // Each call hands the task model the snapshot the parent selected for it.
    expect(task.snapshots).toEqual(["/hub/task/snapshots/selected", "/hub/task/snapshots/other"]);
    // A failed row fails the call with the task model's message; the lease is released.
    events.length = 0;
    const failed = await post(call("completeBatch", ["ok", "fail"]));
    expect([failed.status, await failed.json()]).toEqual([500, { error: { message: "row failed", type: "memory_failed" } }]);
    expect([events.at(-1), gate.held]).toEqual(["release", 0]);
    // Malformed calls never reach the lease or the task model; the route takes POST only.
    events.length = 0;
    const snapshot = "/hub/task/snapshots/selected";
    for (const bad of ["not json", {}, { call: "stream", snapshot, requests: [] }, { call: "complete", snapshot, requests: [] }, call("complete", ["a", "b"]),
      { call: "complete", requests: call("complete", ["a"]).requests }, { ...call("complete", ["a"]), snapshot: "" },
      { call: "completeBatch", snapshot, requests: [{ stage: "entity", input: { user: "a" } }] }, { call: "completeBatch", snapshot, requests: [{ stage: "", input: { user: "a" }, maxTokens: 1 }] },
      { call: "completeBatch", snapshot, requests: [{ stage: "entity", input: { user: "a", system: 1 }, maxTokens: 1 }] }]) {
      const response = await post(bad);
      expect([response.status, (await response.json()).error.type]).toEqual([400, "invalid_request_error"]);
    }
    const wrong = await fetch("http://worker/admin/memory/complete", { unix: socket.unix } as RequestInit);
    expect([wrong.status, wrong.headers.get("allow")]).toEqual([405, "POST"]);
    expect(events).toEqual([]);
  } finally { await app.close(); }
  socket.remove();
  // A worker without a task model or without an execution lease (the app form, the transcription-only app) has no memory route.
  for (const options of [{ acquireExecutionLease: logged(exclusiveLease(), []) }, { memoryTaskModel: taskModel(gate, []) }]) {
    const response = await createWorkerRoutes({ modelId: "m", ...options }).wrap(model())
      .handle(new Request("http://worker/admin/memory/complete", { method: "POST", body: JSON.stringify(call("complete", ["a"])) }));
    expect(response).toBeNull();
  }
  // Likewise a worker without a lease has no /admin/lease route, while /admin/drain still answers.
  const leaseless = createWorkerRoutes({ modelId: "m" }).wrap(model());
  expect(await leaseless.handle(new Request("http://worker/admin/lease", { method: "POST" }))).toBeNull();
  expect((await leaseless.handle(new Request("http://worker/admin/drain", { method: "POST" })))!.status).toBe(200);
});

test("a parent disconnect aborts every row and joins them before the lease is released; draining refuses new calls; close aborts and joins the calls in flight", async () => {
  const socket = socketDir(), gate = exclusiveLease(), events: string[] = [];
  const task = taskModel(gate, events, 20);
  const admin = createWorkerRoutes({ modelId: "org/model", acquireExecutionLease: logged(gate, events), memoryTaskModel: task });
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, sockets: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
  const post = (body: unknown, init: RequestInit = {}) => fetch("http://worker/admin/memory/complete", { method: "POST", body: JSON.stringify(body), ...init, unix: socket.unix } as RequestInit);
  const health = async () => await (await fetch("http://worker/health", { unix: socket.unix } as RequestInit)).json() as { in_flight: number; leases: number };
  try {
    const parent = new AbortController();
    const pending = post(call("completeBatch", ["hold 1", "hold 2", "hold 3"]), { signal: parent.signal }).catch((error: Error) => error.name);
    await until(() => task.waiting === 3, "three rows in flight");
    expect((await health()).in_flight).toBe(1);
    parent.abort();
    expect(await pending).toBe("AbortError");
    await until(() => events.includes("release"), "the lease release");
    expect(events.slice(events.indexOf("row hold 3 held=1") + 1).map(event => event.replace(/ \d$/, ""))).toEqual(["joined hold", "joined hold", "joined hold", "release"]);
    expect([gate.held, (await health()).in_flight]).toEqual([0, 0]);
    // Draining: the gate stays shut for memory calls too.
    expect(await (await fetch("http://worker/admin/drain", { method: "POST", unix: socket.unix } as RequestInit)).json()).toMatchObject({ drained: true, state: "draining" });
    const refused = await post(call("complete", ["late"]));
    expect([refused.status, (await refused.json()).error.type]).toEqual([503, "draining"]);
  } finally { await app.close(); }
  socket.remove();
  // Close: the call in flight is aborted, its rows join, then close resolves; later calls answer 503.
  const closing: string[] = [];
  const held = taskModel(gate, closing, 20);
  const owner = createWorkerRoutes({ modelId: "m", acquireExecutionLease: logged(gate, closing), memoryTaskModel: held });
  const group = owner.wrap(model());
  const inflight = group.handle(new Request("http://worker/admin/memory/complete", { method: "POST", body: JSON.stringify(call("completeBatch", ["hold a", "hold b"])) }));
  await until(() => held.waiting === 2, "two rows in flight");
  await owner.close();
  closing.push("closed");
  expect(closing.slice(-4).map(event => event.replace(/ [ab]$/, ""))).toEqual(["joined hold", "joined hold", "release", "closed"]);
  const response = (await inflight)!;
  expect([response.status, (await response.json()).error.type]).toEqual([503, "unavailable"]);
  const late = await group.handle(new Request("http://worker/admin/memory/complete", { method: "POST", body: JSON.stringify(call("complete", ["a"])) }));
  expect(late!.status).toBe(503);
});

test("a managed job holding the worker's execution lease delays a memory call, lazy load included, and a running memory call delays a job's lease", async () => {
  const socket = socketDir(), gate = exclusiveLease(), events: string[] = [];
  const task = taskModel(gate, events);
  const admin = createWorkerRoutes({ modelId: "org/model", acquireExecutionLease: logged(gate, events), memoryTaskModel: task });
  const app = await startServer({ routes: admin.wrap(model()), web: () => null, sockets: idle, beforeDrain: () => admin.close(), async closeEngine() {} }, { unix: socket.unix });
  const get = (path: string, init: RequestInit = {}) => fetch(`http://worker${path}`, { ...init, unix: socket.unix } as RequestInit);
  const post = (body: unknown) => get("/admin/memory/complete", { method: "POST", body: JSON.stringify(body) });
  try {
    const job = new AbortController();
    const leased = await get("/admin/lease", { method: "POST", signal: job.signal });
    await leased.body!.getReader().read();
    const waiting = post(call("completeBatch", ["a", "b"]));
    await Bun.sleep(50);
    expect(events).toEqual(["lease"]);
    job.abort();
    expect(await (await waiting).json()).toEqual({ outputs: ["out entity a", "out entity b"] });
    expect(events).toEqual(["lease", "release", "lease", "load held=1", "row a held=1", "row b held=1", "release"]);
    // The other way round: a job's lease waits for the memory call's rows.
    const running = post(call("completeBatch", ["hold x"]));
    await until(() => task.waiting === 1, "the memory row");
    await expect(get("/admin/lease", { method: "POST", signal: AbortSignal.timeout(100) })).rejects.toThrow();
    const second = new AbortController();
    const queued = get("/admin/lease", { method: "POST", signal: second.signal });
    await Bun.sleep(20);
    task.release();
    expect(await (await running).json()).toEqual({ outputs: ["out entity hold x"] });
    await (await queued).body!.getReader().read();
    expect(events.slice(-2)).toEqual(["release", "lease"]);
    second.abort();
    await until(() => gate.held === 0, "the job's release");
  } finally { await app.close(); }
  socket.remove();
});
