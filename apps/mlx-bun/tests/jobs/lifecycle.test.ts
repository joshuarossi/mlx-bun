import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { JobStore } from "../../src/jobs/db";
import { createJobHost } from "../../src/jobs/host";
import { submitSubprocess, closeSubprocessJobs } from "../../src/jobs/runner";
import { makeEmit } from "../../src/jobs/events";
import { streamJobResponse, tailJob } from "../../src/jobs/sse";
import { createJobRoutes } from "../../src/server/job-routes";

const stores: JobStore[] = [], roots: string[] = [];
function fresh() {
  const root = mkdtempSync(join(tmpdir(), "mlx-app-jobs-")); roots.push(root);
  const store = new JobStore(join(root, "jobs.sqlite"), join(root, "logs")); stores.push(store);
  return { root, store };
}
function deferred<T>() { let resolve!: (value: T) => void; const promise = new Promise<T>(r => resolve = r); return { promise, resolve }; }
const tick = () => new Promise(resolve => setImmediate(resolve));
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
  await ended;
  const tail = tailJob(store, row.id, { signal: controller.signal });
  expect((await tail[Symbol.asyncIterator]().next()).done).toBe(true);
});
