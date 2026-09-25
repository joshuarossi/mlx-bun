import { afterEach, expect, test } from "bun:test";
import { Database } from "bun:sqlite";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { JobStore } from "../../src/jobs/db";
import { createJobHost } from "../../src/jobs/host";
import { submitSubprocess, closeSubprocessJobs } from "../../src/jobs/runner";
import { makeEmit } from "../../src/jobs/events";
import { streamJobResponse, tailJob } from "../../src/jobs/sse";
import { createJobRoutes } from "../../src/server/job-routes";
import { startServer } from "../../src/server/start";
import type { JobEvent } from "../../src/jobs/protocol";

const stores: JobStore[] = [], roots: string[] = [];
function fresh() {
  const root = mkdtempSync(join(tmpdir(), "mlx-app-jobs-")); roots.push(root);
  const store = new JobStore(join(root, "jobs.sqlite"), join(root, "logs")); stores.push(store);
  return { root, store };
}
function deferred<T>() { let resolve!: (value: T) => void; const promise = new Promise<T>(r => resolve = r); return { promise, resolve }; }
const tick = () => new Promise(resolve => setImmediate(resolve));
async function terminals(store: JobStore, jobId: string) {
  const events = [];
  for await (const event of tailJob(store, jobId)) {
    if (event.type === "done" || event.type === "failed") events.push(event);
  }
  return events;
}
async function until(check: () => boolean) {
  const end = Date.now() + 3000;
  while (!check()) { if (Date.now() > end) throw new Error("timed out"); await Bun.sleep(5); }
}
function child(stdout?: ReadableStream<Uint8Array>) {
  const exit = deferred<number>();
  const proc = { stdout, stderr: undefined, exited: exit.promise, exitCode: null as number | null,
    kill() { proc.exitCode = 143; exit.resolve(143); } };
  return { proc, exit, spawn: (() => proc) as unknown as typeof Bun.spawn };
}
afterEach(async () => {
  for (const store of stores.splice(0)) { await closeSubprocessJobs(store); store.close(); }
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
});

test("the host opens storage lazily, marks zombies, and refuses work after close", async () => {
  const { store } = fresh(); let opens = 0;
  const old = store.create("quantize", {});
  const host = createJobHost({ entry: "unused", acquire: async () => ({ dispose() {} }), createStore() { opens++; return store; } });
  expect(opens).toBe(0);
  expect(host.ensureStore().get(old.id)?.status).toBe("zombie");
  host.ensureStore(); expect(opens).toBe(1);
  // This host owns its store; remove it from the fixture cleanup list.
  stores.splice(stores.indexOf(store), 1);
  await host.close(); await host.close();
  expect(host.signal.aborted).toBe(true);
  expect(() => host.ensureStore()).toThrow("closed");
});

test("main's persisted job rows and logs survive reopening through the app host and HTTP routes", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-prior-jobs-")); roots.push(root);
  const path = join(root, "jobs.sqlite");
  // Frozen disk format from 02d723a: generate it independently of JobStore so
  // an incompatible constructor/schema change cannot silently update the input.
  const prior = new Database(path);
  prior.exec(`CREATE TABLE jobs (
    id TEXT PRIMARY KEY, kind TEXT NOT NULL, status TEXT NOT NULL,
    config_json TEXT NOT NULL, progress REAL NOT NULL DEFAULT 0, message TEXT,
    log_path TEXT NOT NULL, output_path TEXT, error TEXT,
    started_at TEXT NOT NULL DEFAULT (datetime('now')), ended_at TEXT
  ); CREATE INDEX idx_jobs_status_started ON jobs(status, started_at DESC);`);
  const config = JSON.stringify({ model_dir: "/old/model", method: "sft", iters: 3 });
  const output = join(root, "retained-adapter"), log = join(root, "completed.log");
  const events = [{ type: "metric", kind: "train", step: 3, loss: 1.25 },
    { type: "done", ts: 1_790_251_260_000, output_dir: output, summary: { iters: 3 } }];
  writeFileSync(log, events.map(event => JSON.stringify(event)).join("\n") + "\n");
  try {
    const insert = prior.prepare("INSERT INTO jobs VALUES (?, 'finetune', ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    insert.run("job_0000000000000001", "done", config, 1, "finished", log, output, null, "2026-09-24 12:00:00", "2026-09-24 12:01:00");
    insert.run("job_0000000000000002", "failed", config, 0.5, "step 2", log, output, "old failure", "2026-09-24 11:00:00", "2026-09-24 11:01:00");
    for (const [status, id] of [["queued", "job_0000000000000003"], ["running", "job_0000000000000004"]] as const)
      insert.run(id, status, config, 0, null, join(root, `${status}.log`), null, null, "2026-09-24 10:00:00", null);
  } finally { prior.close(); }
  const host = createJobHost({ entry: "unused", acquire: async () => { throw new Error("must not execute old jobs"); },
    createStore: () => new JobStore(path, join(root, "new-logs")) });
  const routes = createJobRoutes(host);
  try {
    const response = await routes.handle(new Request("http://local/api/jobs/job_0000000000000001"));
    expect(response!.status).toBe(200);
    const { ok, job } = await response!.json();
    expect(ok).toBe(true);
    expect(job).toEqual({ id: "job_0000000000000001", kind: "finetune", status: "done", config_json: config,
      progress: 1, message: "finished", log_path: log, output_path: output, error: null,
      started_at: "2026-09-24 12:00:00", ended_at: "2026-09-24 12:01:00" });
    const listing = await (await routes.handle(new Request("http://local/api/jobs?kind=finetune")))!.json();
    expect(listing.jobs).toHaveLength(4);
    expect(host.ensureStore().get("job_0000000000000002")).toMatchObject({ status: "failed", error: "old failure", output_path: output });
    for (const id of ["job_0000000000000003", "job_0000000000000004"])
      expect(host.ensureStore().get(id)).toMatchObject({ status: "zombie", config_json: config });
    const stream = await routes.handle(new Request("http://local/api/jobs/job_0000000000000001/stream"));
    const replay = (await stream!.text()).split("\n\n").filter(frame => !frame.startsWith("event: end"))
      .flatMap(frame => frame.split("\n").filter(line => line.startsWith("data: ")).map(line => JSON.parse(line.slice(6))));
    expect(replay).toEqual(events);
    const newJob = host.ensureStore().create("dataset", { template: "instruction" });
    expect(newJob.status).toBe("queued");
    expect(host.ensureStore().get("job_0000000000000001")).toEqual(job);
  } finally { await host.close(); }
  const reopened = new JobStore(path, join(root, "new-logs"));
  try {
    expect(reopened.get("job_0000000000000001")?.output_path).toBe(output);
    expect(reopened.get("job_0000000000000002")?.error).toBe("old failure");
  } finally { reopened.close(); }
});

test("listener shutdown cancels a live job stream and joins its child before releasing the engine", async () => {
  const { store } = fresh(), running = child();
  const events: string[] = [];
  running.proc.kill = () => { events.push("kill"); };
  const host = createJobHost({ entry: "unused", createStore: () => store,
    acquire: async () => ({ dispose() { events.push("release"); } }), spawn: running.spawn });
  const { jobId } = host.submit("quantize", {}, "unused");
  stores.splice(stores.indexOf(store), 1);
  const app = await startServer({ routes: createJobRoutes(host), web: () => null,
    chat: () => { throw new Error("no chat expected"); }, beforeDrain: () => host.close(),
    closeEngine: async () => { expect(events).toEqual(["kill", "release"]); events.push("engine"); },
  }, { port: 0 });
  try {
    const response = await fetch(new URL(`/api/jobs/${jobId}/stream`, app.server.url));
    expect(response.status).toBe(200);
    const reader = response.body!.getReader();
    expect((await reader.read()).done).toBe(false);
    const drained = (async () => { while (!(await reader.read()).done) {} })();
    const closing = app.close();
    await until(() => events.includes("kill"));
    expect(events).toEqual(["kill"]);
    running.exit.resolve(143);
    await closing; await drained;
    expect(events).toEqual(["kill", "release", "engine"]);
  } finally { running.exit.resolve(143); await app.close(); }
});

test("a queued child waits for admission and holds the lease until process exit", async () => {
  const { store } = fresh(); const lease = deferred<{ dispose(): void }>(), first = child(), second = child();
  const events: string[] = [];
  const one = submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts",
    acquire: () => lease.promise, spawn: (() => { events.push("spawn1"); return first.proc; }) as unknown as typeof Bun.spawn });
  submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts",
    acquire: async () => ({ dispose() { events.push("release2"); } }),
    spawn: (() => { events.push("spawn2"); return second.proc; }) as unknown as typeof Bun.spawn });
  await tick(); expect(events).toEqual([]); expect(store.get(one.jobId)?.status).toBe("queued");
  lease.resolve({ dispose() { events.push("release1"); } });
  await until(() => events.includes("spawn1")); expect(events).toEqual(["spawn1"]);
  first.exit.resolve(1); await until(() => events.includes("spawn2"));
  expect(events).toEqual(["spawn1", "release1", "spawn2"]);
  expect(store.get(one.jobId)?.status).toBe("failed");
  expect(await terminals(store, one.jobId)).toMatchObject([{ type: "failed", error: "exited 1" }]);
  second.exit.resolve(1); await until(() => events.includes("release2"));
});

test("spawn and admission failure release ownership and let the next job proceed", async () => {
  const { store } = fresh(); let released = 0; const next = child();
  const fail = submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts",
    acquire: async () => ({ dispose() { released++; } }), spawn: (() => { throw new Error("spawn failed"); }) as typeof Bun.spawn });
  const rejected = submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts",
    acquire: async () => { throw new Error("admission denied"); }, spawn: next.spawn });
  const last = submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts", acquire: async () => ({ dispose() {} }), spawn: next.spawn });
  await until(() => store.get(rejected.jobId)?.status === "failed");
  expect(store.get(fail.jobId)?.error).toContain("spawn failed"); expect(released).toBe(1);
  expect(await terminals(store, fail.jobId)).toMatchObject([{ type: "failed", error: "Error: spawn failed" }]);
  expect(await terminals(store, rejected.jobId)).toMatchObject([{ type: "failed", error: "Error: admission denied" }]);
  next.exit.resolve(1); await until(() => store.get(last.jobId)?.status === "failed");
});

test("close cancels admission and queued jobs without spawning", async () => {
  const { store } = fresh(); let spawned = 0;
  const acquire = (signal: AbortSignal) => new Promise<{ dispose(): void }>((_, reject) => {
    const abort = () => reject(signal.reason); signal.addEventListener("abort", abort, { once: true }); if (signal.aborted) abort();
  });
  const opts = { entry: "unused", acquire, spawn: (() => { spawned++; throw new Error("must not spawn"); }) as typeof Bun.spawn };
  const first = submitSubprocess(store, "quantize", {}, undefined, opts), second = submitSubprocess(store, "quantize", {}, undefined, opts);
  await tick(); await closeSubprocessJobs(store);
  expect(spawned).toBe(0); expect(store.get(first.jobId)?.status).toBe("failed"); expect(store.get(second.jobId)?.status).toBe("failed");
  expect(await terminals(store, first.jobId)).toMatchObject([{ type: "failed", error: "Error: job host closed" }]);
  expect(await terminals(store, second.jobId)).toMatchObject([{ type: "failed", error: "job host closed" }]);
});

test("close awaits child death and its final stdout before releasing the lease", async () => {
  const { store } = fresh(); const events: string[] = [];
  let output!: ReadableStreamDefaultController<Uint8Array>;
  const running = child(new ReadableStream({ start(c) { output = c; } }));
  running.proc.kill = () => { events.push("kill"); };
  const { jobId } = submitSubprocess(store, "quantize", {}, undefined, { entry: "unused", acquire: async () => ({ dispose() { events.push("release"); } }), spawn: running.spawn });
  await tick(); let closed = false; const close = closeSubprocessJobs(store).then(() => { closed = true; });
  await tick(); expect(events).toEqual(["kill"]); expect(closed).toBe(false);
  running.exit.resolve(143); await tick(); expect(closed).toBe(false);
  output.enqueue(new TextEncoder().encode("final message")); output.close();
  await close; expect(events).toEqual(["kill", "release"]);
  expect(await Bun.file(store.get(jobId)!.log_path).text()).toContain("final message");
});

test("a real CPU-only child entry records an unsupported producer failure without native MLX", async () => {
  const { store } = fresh(); let released = false;
  const entry = new URL("../../src/cli/job-entry.ts", import.meta.url).pathname;
  const { jobId } = submitSubprocess(store, "unsupported", {}, undefined, { entry, acquire: async () => ({ dispose() { released = true; } }) });
  await until(() => released);
  expect(store.get(jobId)?.status).toBe("failed");
  expect(store.get(jobId)?.error).toContain('no runner registered for kind "unsupported"');
  expect(await Bun.file(store.get(jobId)!.log_path).text()).toContain('"type":"failed"');
});

test("a real finetune child validates its config and persists failure before native model loading", async () => {
  const { store } = fresh(); let released = false;
  const entry = new URL("../../src/cli/job-entry.ts", import.meta.url).pathname;
  const { jobId } = submitSubprocess(store, "finetune", {}, undefined, { entry,
    acquire: async () => ({ dispose() { released = true; } }) });
  await until(() => released);
  expect(store.get(jobId)?.status).toBe("failed");
  expect(store.get(jobId)?.error).toContain("finetune job: missing model_dir");
  const log = await Bun.file(store.get(jobId)!.log_path).text();
  expect(log).toContain('"type":"started"');
  expect(log).toContain('"type":"failed"');
});

for (const dispatch of ["direct", "cli"] as const) test(`${dispatch} child exits after terminal persistence even with a lingering producer handle`, async () => {
  const { root, store } = fresh(), row = store.create("unsupported", {});
  const preload = join(root, "keepalive.ts");
  writeFileSync(preload, "setInterval(() => {}, 1000);\n");
  const child = Bun.spawn([process.execPath, "--no-env-file", "--preload", preload,
    ...(dispatch === "direct" ? [new URL("../../src/cli/job-entry.ts", import.meta.url).pathname, row.id]
      : [new URL("../../src/cli/main.ts", import.meta.url).pathname, "__job", row.id])], {
    env: { ...process.env, MLX_BUN_LIBMLXC: "/does-not-exist", MLX_BUN_JOBS_DB: store.dbPath, MLX_BUN_JOBS_DIR: store.logsDir },
    stdout: "ignore", stderr: "ignore",
  });
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    const code = await Promise.race([child.exited, new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error("child retained its event loop")), 2000);
    })]);
    expect(code).toBe(1);
    expect(store.get(row.id)?.status).toBe("failed");
    expect(await Bun.file(row.log_path).text()).toContain('"type":"failed"');
  } finally { if (timer) clearTimeout(timer); if (child.exitCode === null) child.kill("SIGKILL"); await child.exited; }
});

test("queued persistence failure still joins the child before closing its store and engine", async () => {
  const { store } = fresh(); const running = child(); const events: string[] = [];
  running.proc.kill = () => { events.push("kill"); };
  const host = createJobHost({ entry: "unused", createStore: () => store,
    acquire: async () => ({ dispose() { events.push("release"); } }), spawn: running.spawn });
  const active = host.submit("quantize", {}, "unused");
  await tick();
  const queued = host.submit("quantize", {}, "unused");
  const failure = new Error("SQLITE_BUSY while cancelling queued job");
  const setStatus = store.setStatus.bind(store), closeStore = store.close.bind(store);
  store.setStatus = (id, status, opts) => {
    if (id === queued.jobId) throw failure;
    setStatus(id, status, opts);
  };
  store.close = () => {
    expect(store.get(active.jobId)?.status).toBe("failed");
    events.push("store.close"); closeStore();
  };
  stores.splice(stores.indexOf(store), 1); // The host owns this connection.
  const closing = (async () => { try { await host.close(); } finally { events.push("engine.close"); } })();
  const result = closing.catch(error => error);
  await tick(); expect(events).toEqual(["kill"]);
  running.proc.exitCode = 143; running.exit.resolve(143);
  const error = await result;
  expect(error).toBeInstanceOf(AggregateError);
  expect(error.errors).toEqual([failure]);
  expect(events).toEqual(["kill", "release", "store.close", "engine.close"]);
  await expect(host.close()).rejects.toBe(error);
});

test("job HTTP responses preserve rows, filters, missing IDs and SSE framing", async () => {
  const { store } = fresh(); const row = store.create("quantize", {});
  makeEmit(store, row.id, row.log_path)({ type: "stage", stage: "test", progress: 0.5 });
  store.setStatus(row.id, "done");
  const routes = createJobRoutes({ ensureStore: () => store, signal: new AbortController().signal });
  const response = await routes.handle(new Request(`http://x/api/jobs/${row.id}`));
  expect((await response!.json()).job.progress).toBe(0.5);
  expect((await routes.handle(new Request("http://x/api/jobs/missing")))?.status).toBe(404);
  expect((await (await routes.handle(new Request("http://x/api/jobs?kind=other")))!.json()).jobs).toEqual([]);
  const stream = await routes.handle(new Request(`http://x/api/jobs/${row.id}/stream`));
  expect(await stream!.text()).toContain('retry: 1500\n\ndata: {"type":"stage"');
  expect(stream!.headers.get("content-type")).toBe("text/event-stream");
  expect(await routes.handle(new Request("http://x/api/dataset/submit"))).toBeNull();
});

test("SSE disconnect and host cancellation stop polling a nonterminal job", async () => {
  const { store } = fresh(); const row = store.create("quantize", {});
  const response = streamJobResponse(store, row.id), reader = response.body!.getReader();
  expect(new TextDecoder().decode((await reader.read()).value)).toBe("retry: 1500\n\n");
  await reader.cancel();
  const controller = new AbortController();
  const ended = streamJobResponse(store, row.id, controller.signal).text(); controller.abort();
  const output = await ended;
  expect(output).not.toContain('"type":"done"');
  expect(output).not.toContain('"type":"failed"');
  const tail = tailJob(store, row.id, { signal: controller.signal });
  expect((await tail[Symbol.asyncIterator]().next()).done).toBe(true);
});

test("terminal row recovery covers the status-before-log race without duplicating replayed events", async () => {
  const { store } = fresh();
  for (const status of ["done", "failed"] as const) {
    const row = store.create("quantize", {}, "/temporary/output");
    store.setStatus(row.id, status, { error: status === "failed" ? "producer failed" : undefined,
      endedAt: "2026-09-25 00:00:00" });
    // Pause the simulated child between its SQLite terminal write and emit.
    const expected: JobEvent = status === "done"
      ? { type: "done", ts: Date.UTC(2026, 8, 25), output_dir: "/temporary/output" }
      : { type: "failed", ts: Date.UTC(2026, 8, 25), error: "producer failed" };
    expect(await terminals(store, row.id)).toEqual([expected]);
    const logged = { ...expected, ts: Date.UTC(2026, 8, 25) + 1 };
    makeEmit(store, row.id, row.log_path)(logged);
    expect(await terminals(store, row.id)).toEqual([logged]);
    const sse = await streamJobResponse(store, row.id).text();
    expect(sse.indexOf(`"type":"${status}"`)).toBeLessThan(sse.indexOf("event: end"));
  }
});
