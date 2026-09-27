import { afterEach, beforeEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, realpathSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { CancellationSource, createCompletionClient, createDirectHost, createInferenceEngine, openIsolatedHost,
  type BatchCompletionClient, type CancelReason, type EngineHost, type GenerationEvent, type RunControl, type TaskClient } from "mlx-bun/engine";
import { openLibraryHost, type LibraryHostSeams } from "../src/cli/library-host";
import { WORKER_PROTOCOL_VERSION } from "../src/jobs/worker-process";
import { RestartBudgetExhaustedError } from "../src/jobs/worker-supervisor";

// The public `mlx-bun/engine` entry. Its import is checked in a child process
// with native MLX blocked; `openIsolatedHost` runs over the fake worker
// (tests/fake-worker.ts) as an explicit command, and the internal seams
// (cli/library-host.ts) stand in for the compiled-consumer path check, process
// creation, and the restart budget. No model, no native library, no HOME writes.
// The compiled-consumer check here is the stand-in `$bunfs` module path; an
// actual standalone CLI as `command` is the opt-in native test's
// (tests/engine/library-host.test.ts).

const packageRoot = resolve(import.meta.dir, "..");
const fake = join(import.meta.dir, "fake-worker.ts");
const command = [process.execPath, fake];
const model = "org/model";

// The worker's forwarded output and the supervisor's notices, captured instead of printed.
let logs: string[] = [], errors: string[] = [], spies: { mockRestore(): void }[] = [];
beforeEach(() => {
  logs = []; errors = [];
  spies = [spyOn(console, "log").mockImplementation((...parts: unknown[]) => { logs.push(parts.join(" ")); }),
    spyOn(console, "error").mockImplementation((...parts: unknown[]) => { errors.push(parts.join(" ")); })];
});
afterEach(() => { for (const spy of spies) spy.mockRestore(); });

interface Launch { argv: string[]; pid: number; launch: { kind: string; version: string; socketPath: string; argv: string[] } }
/** A scratch directory, the fake's environment, and a recording spawn seam. */
function fixture(env: Record<string, string> = {}, seams: Omit<LibraryHostSeams, "spawn"> = {}, redirect?: (command: string[]) => string[]) {
  const dir = mkdtempSync(join(tmpdir(), "mlx-engine-entry-"));
  const record = join(dir, "launches.jsonl"), events = join(dir, "events.jsonl");
  const spawned: string[][] = [];
  const spawn = ((spawnCommand: string[], options: Record<string, unknown> & { env?: Record<string, string | undefined> }) => {
    spawned.push([...spawnCommand]);
    return Bun.spawn(redirect ? redirect(spawnCommand) : spawnCommand, { ...options,
      env: { ...options.env, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", FAKE_WORKER_RECORD: record, FAKE_WORKER_EVENTS: events, ...env } });
  }) as unknown as typeof Bun.spawn;
  const lines = (file: string) => existsSync(file) ? readFileSync(file, "utf8").split("\n").filter(Boolean).map(line => JSON.parse(line)) : [];
  return {
    dir, spawned, seams: { ...seams, spawn } satisfies LibraryHostSeams,
    launches: (): Launch[] => lines(record).map(({ argv, pid, launch }) => ({ argv, pid, launch: JSON.parse(launch) })),
    events: (): { event: string; pid: number }[] => lines(events),
    remove: () => rmSync(dir, { recursive: true, force: true }),
  };
}

async function until(check: () => boolean | Promise<boolean>, what: string, timeoutMs = 5_000) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(5); }
}
const rejection = (work: Promise<unknown>) => work.then(() => { throw new Error("must reject"); }, (error: unknown) => error as Error);
/** True while the promise has neither resolved nor rejected. */
const pending = (promise: Promise<unknown>) => Promise.race([promise.then(() => false, () => false), Bun.sleep(20).then(() => true)]);
const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };
const json = async <T = Record<string, unknown>>(host: EngineHost<Request, Response>, path: string, init: RequestInit = {}) =>
  await (await host.forward(new Request(`http://engine${path}`, init))).json() as T;
const chat = (content: string, stream = false, signal?: AbortSignal) => new Request("http://engine/v1/chat/completions", { method: "POST",
  headers: { "content-type": "application/json" }, body: JSON.stringify({ stream, messages: [{ role: "user", content }] }), signal });
type Seen = { pid: number; seen: { path: string; method: string; aborted: boolean; headers: Record<string, string>; body?: unknown }[] };

test("the entry imports through the export map without native MLX and exposes exactly its values", async () => {
  const child = Bun.spawn([process.execPath, "--no-env-file", "-e",
    'const entry = await import("mlx-bun/engine"); console.log(JSON.stringify(Object.keys(entry).sort()));'], {
    cwd: packageRoot, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/mlx-engine-import-test.dylib" },
  });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 10_000);
  try {
    const [stdout, stderr, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    expect({ code, stderr }).toEqual({ code: 0, stderr: "" });
    expect(JSON.parse(stdout)).toEqual(["CancellationSource", "createCompletionClient", "createDirectHost", "createInferenceEngine", "openIsolatedHost"]);
  } finally { clearTimeout(deadline); }
  // The portable session API and its contract types come through the same entry (the typecheck covers the types).
  const cancellation = new CancellationSource(), reasons: CancelReason[] = [];
  cancellation.subscribe(reason => reasons.push(reason));
  cancellation.cancel("requested");
  expect([cancellation.reason, reasons]).toEqual(["requested", ["requested"]]);
  const control: RunControl = { output: "collect", cancellation }, event: GenerationEvent = { type: "progress", completed: 1 };
  expect([control.output, event.type, typeof createInferenceEngine]).toEqual(["collect", "progress", "function"]);
  // Main's batch and task client contracts (types only).
  const batch: BatchCompletionClient<string, number> = { complete: async request => request.length,
    completeBatch: async requests => requests.map(request => request.length) };
  const task: TaskClient<string, number, string> = { async run(request, report, cancel) {
    report(request.length); return `${request}:${cancel?.reason}`; } };
  const progress: number[] = [];
  expect([await batch.completeBatch(["a", "bc"]), await task.run("abc", value => progress.push(value), cancellation), progress])
    .toEqual([[1, 2], "abc:requested", [3]]);
});

test("a blank model, a refused flag, or a bad argument rejects in the caller before anything is spawned; transport-only flags are accepted", async () => {
  const f = fixture();
  try {
    for (const blank of ["", "   "]) {
      await expect(openIsolatedHost(blank, { command: ["/nonexistent/mlx-bun"] })).rejects.toThrow("openIsolatedHost needs a model");
      await expect(openLibraryHost(blank, { command }, f.seams)).rejects.toThrow("an empty query selects one automatically and may download the starter model");
    }
    await expect(openIsolatedHost(model, { command: ["/nonexistent/mlx-bun"], arguments: ["--isolate"] }))
      .rejects.toThrow("--isolate is not supported in a worker app launch");
    await expect(openLibraryHost(model, { command, arguments: ["--model-pool", "2"] }, f.seams)).rejects.toThrow("--model-pool is not supported in a worker app launch");
    await expect(openLibraryHost(model, { command, arguments: ["--bogus"] }, f.seams)).rejects.toThrow("Unknown option '--bogus'");
    await expect(openLibraryHost(model, { command, arguments: ["--port"] }, f.seams)).rejects.toThrow("argument missing");
    // The arguments cannot swap the model for a blank one either.
    await expect(openLibraryHost(model, { command, arguments: ["--model", " "] }, f.seams)).rejects.toThrow("needs a non-empty --model");
    expect(f.spawned).toEqual([]);
    const argv = ["--host", "0.0.0.0", "--port", "9", "--no-open", "--max-tokens", "8"];
    const host = await openLibraryHost(model, { command, arguments: argv }, f.seams);
    try {
      const [launched] = f.launches();
      expect(launched!.launch).toEqual({ kind: "app", version: WORKER_PROTOCOL_VERSION, socketPath: launched!.launch.socketPath, argv: ["--model", model, ...argv] });
      expect(launched!.launch.socketPath).toBe(join(dirname(launched!.launch.socketPath), "engine.sock"));
      expect(Buffer.byteLength(launched!.launch.socketPath)).toBeLessThan(104);
      expect(statSync(dirname(launched!.launch.socketPath)).mode & 0o777).toBe(0o700);
    } finally { await host.close(); }
  } finally { f.remove(); }
});

test("the command: an explicit one runs as [...command, '__worker'], an empty one is refused, a compiled consumer must supply one, and the default is this package's CLI source", async () => {
  await expect(openIsolatedHost(model, { command: [] })).rejects.toThrow("engine command must not be empty");
  const compiled = "/$bunfs/root/consumer/engine-entry.js";
  const explicit = fixture({}, { modulePath: compiled });
  try {
    await expect(openLibraryHost(model, {}, explicit.seams)).rejects.toThrow("a compiled library consumer must supply the mlx-bun executable as command");
    expect(explicit.spawned).toEqual([]);
    const host = await openLibraryHost(model, { command }, explicit.seams);
    await host.close();
    expect(explicit.spawned).toEqual([[...command, "__worker"]]);
  } finally { explicit.remove(); }
  // The default command is recorded, then the fake runs in its place.
  const source = fixture({}, {}, spawned => [process.execPath, fake, ...spawned.slice(2)]);
  try {
    const host = await openLibraryHost(model, {}, source.seams);
    await host.close();
    expect(source.spawned.length).toBe(1);
    const [bin, entry, verb] = source.spawned[0]!;
    expect([bin, realpathSync(entry!), verb]).toEqual([process.execPath, realpathSync(join(packageRoot, "src/cli/main.ts")), "__worker"]);
  } finally { source.remove(); }
  // A command that cannot be spawned fails the open.
  await expect(openIsolatedHost(model, { command: ["/nonexistent/mlx-bun"] })).rejects.toThrow();
});

test("the host forwards the whole surface: the completion client, streams that stay readable and abort, and hop-by-hop headers stripped both ways", async () => {
  const f = fixture();
  const direct = createDirectHost(async request => {
    const body = await request.json() as { messages: { content: string }[] };
    return Response.json({ choices: [{ index: 0, message: { role: "assistant", content: `echo: ${body.messages[0]!.content}` } }] });
  });
  const host = await openLibraryHost(model, { command }, f.seams);
  try {
    await host.ready;
    // Main's contract test: a direct and an isolated host answer the same client call.
    for (const transport of [direct, host]) {
      const client = createCompletionClient({ baseUrl: "http://engine/v1", host: transport });
      expect((await client.complete({ body: { messages: [{ role: "user", content: "same request" }] } })).choices[0]!.message!.content).toBe("echo: same request");
    }
    // A stream passes through byte for byte.
    const socketPath = f.launches()[0]!.launch.socketPath;
    const streamed = await (await host.forward(chat("hello", true))).text();
    expect(streamed).toBe(await (await fetch("http://engine/v1/chat/completions", { method: "POST", body: JSON.stringify({ stream: true, messages: [{ role: "user", content: "hello" }] }),
      unix: socketPath } as RequestInit)).text());
    expect(streamed.endsWith("data: [DONE]\n\n")).toBe(true);
    // An open stream stays readable after forward returns; the caller's abort reaches the worker.
    const abort = new AbortController();
    const hanging = await host.forward(chat("hang", true, abort.signal));
    expect(hanging.headers.get("content-type")).toBe("text/event-stream");
    const reader = hanging.body!.getReader();
    expect(new TextDecoder().decode((await reader.read()).value)).toContain('"role":"assistant"');
    abort.abort(new Error("caller left"));
    await reader.read().catch(() => {});
    await until(async () => (await json<Seen>(host, "/fake/seen")).seen.some(entry => JSON.stringify(entry.body ?? "").includes("hang") && entry.aborted), "the worker to see the abort");
    // Hop-by-hop headers, and those `Connection` names, are stripped both ways.
    const response = await host.forward(new Request("http://engine/fake/headers", { headers: { connection: "x-request-hop", "x-request-hop": "1",
      "keep-alive": "timeout=5", te: "trailers", "proxy-authorization": "secret", upgrade: "h2c", "x-kept": "request" } }));
    expect(await response.text()).toBe("hop");
    expect(Object.fromEntries(["x-kept", "connection", "x-private-hop", "keep-alive", "proxy-authenticate", "trailer", "upgrade"]
      .map(name => [name, response.headers.get(name)]))).toEqual({ "x-kept": "yes", connection: null, "x-private-hop": null,
      "keep-alive": null, "proxy-authenticate": null, trailer: null, upgrade: null });
    const sent = (await json<Seen>(host, "/fake/seen")).seen.find(entry => entry.path === "/fake/headers")!.headers;
    expect(sent["x-kept"]).toBe("request");
    for (const name of ["x-request-hop", "keep-alive", "te", "proxy-authorization", "upgrade"]) expect(sent[name]).toBeUndefined();
    expect(sent.connection).not.toBe("x-request-hop");
    // The worker's output reaches the console as it printed it.
    expect(logs).toContain(`loading ${model}`);
  } finally { await host.close(); await direct.close(); f.remove(); }
  expect(errors).toContain("stopping");
});

test("requests wait for a respawning worker; one aborted while waiting rejects promptly with its reason and never reaches a worker", async () => {
  const f = fixture({}, { restarts: { max: 3, windowMs: 60_000, delayMs: 400 } });
  const host = await openLibraryHost(model, { command }, f.seams);
  try {
    const first = f.launches()[0]!.pid;
    expect(await json<{ crashing: boolean }>(host, "/fake/crash")).toEqual({ crashing: true });
    await until(() => pending(host.ready), "the host to wait for a respawn");
    const abort = new AbortController(), reason = new Error("client left");
    const refused = rejection(host.forward(chat("never sent", false, abort.signal)));
    const waiting = host.forward(chat("after the respawn"));
    await Bun.sleep(20);
    const abortedAt = Date.now();
    abort.abort(reason);
    expect(await refused).toBe(reason);
    expect(Date.now() - abortedAt).toBeLessThan(200);
    expect(await pending(host.ready)).toBe(true);
    const answer = await (await waiting).json() as { choices: { message: { content: string } }[] };
    expect(answer.choices[0]!.message.content).toBe("echo: after the respawn");
    await host.ready;
    const seen = await json<Seen>(host, "/fake/seen");
    expect(seen.pid).not.toBe(first);
    expect(seen.seen.filter(entry => entry.method === "POST").map(entry => JSON.stringify(entry.body))).toEqual([JSON.stringify({ stream: false, messages: [{ role: "user", content: "after the respawn" }] })]);
    expect(f.launches().map(launch => launch.pid)).toEqual([first, seen.pid]);
    expect(errors.some(line => line.startsWith("[isolate] ") && line.includes("respawning"))).toBe(true);
  } finally { await host.close(); f.remove(); }
});

test("a GET that meets a dying worker is retried once after 250 ms and waits out the respawn; a POST is never replayed", async () => {
  const f = fixture({}, { restarts: { max: 5, windowMs: 60_000, delayMs: 0 } });
  const host = await openLibraryHost(model, { command }, f.seams);
  const marker = (name: string) => join(f.dir, name);
  const deaths = (name: string) => existsSync(marker(name)) ? readFileSync(marker(name), "utf8").split("\n").filter(Boolean).map(Number) : [];
  try {
    const first = f.launches()[0]!.pid;
    // One transport failure: the retry reaches the respawned worker.
    const started = Date.now();
    const retried = await json<{ pid: number; method: string }>(host, `/fake/die?marker=${marker("get")}`);
    expect(Date.now() - started).toBeGreaterThanOrEqual(250);
    expect(deaths("get")).toEqual([first]);
    expect(retried.method).toBe("GET");
    expect(retried.pid).not.toBe(first);
    // Two failures: the GET rejects after exactly one retry.
    await expect(host.forward(new Request(`http://engine/fake/die?marker=${marker("twice")}&times=3`))).rejects.toThrow();
    expect(deaths("twice").length).toBe(2);
    // A POST fails with its worker and is not sent again.
    await until(() => f.launches().length === 4, "the respawn");
    await host.ready;
    await expect(host.forward(new Request(`http://engine/fake/die?marker=${marker("post")}`, { method: "POST", body: "{}" }))).rejects.toThrow();
    await until(() => f.launches().length === 5, "the respawn");
    await host.ready;
    expect(deaths("post").length).toBe(1);
    const seen = await json<Seen>(host, "/fake/seen");
    expect(seen.seen.some(entry => entry.path === "/fake/die")).toBe(false);
    expect(f.launches().length).toBe(5);
  } finally { await host.close(); f.remove(); }
});

test("close drains and stops the worker once, removes the socket directory only after the worker exits, and a closed host refuses work", async () => {
  const f = fixture({ FAKE_WORKER_STOP_MS: "400" });
  const host = await openLibraryHost(model, { command }, f.seams);
  const [launched] = f.launches();
  const socketDir = dirname(launched!.launch.socketPath);
  expect(existsSync(launched!.launch.socketPath)).toBe(true);
  try {
    const closing = host.close();
    expect(host.close()).toBe(closing);
    await until(() => f.events().some(entry => entry.event === "stop"), "the worker to receive SIGTERM");
    // The worker is still closing: its socket directory stays.
    expect(alive(launched!.pid)).toBe(true);
    expect(existsSync(socketDir)).toBe(true);
    await closing;
    expect(alive(launched!.pid)).toBe(false);
    expect(existsSync(socketDir)).toBe(false);
    expect(f.events().map(entry => entry.event)).toEqual(["loading", "ready", "drain", "stop"]);
    await expect(host.forward(new Request("http://engine/health"))).rejects.toThrow("engine host is closed");
    await expect(host.ready).rejects.toThrow("engine host is closed");
    await expect(createCompletionClient({ baseUrl: "http://engine/v1", host }).complete({ body: {} })).rejects.toThrow("engine host is closed");
    expect(host.close()).toBe(closing);
  } finally { await host.close(); f.remove(); }
});

test("closing during a restart backoff spawns nothing more, and a request waiting on it rejects as closed", async () => {
  const f = fixture({}, { restarts: { max: 3, windowMs: 60_000, delayMs: 1_000 } });
  const host = await openLibraryHost(model, { command }, f.seams);
  try {
    await json(host, "/fake/crash");
    await until(() => pending(host.ready), "the restart backoff");
    const waiting = rejection(host.forward(chat("never sent")));
    await host.close();
    expect((await waiting).message).toBe("engine host is closed");
    await expect(host.ready).rejects.toThrow("closed");
    await Bun.sleep(50);
    expect(f.launches().length).toBe(1);
  } finally { await host.close(); f.remove(); }
});

test("a spent restart budget rejects ready and forward with the restart limit; close still joins and cleans up", async () => {
  const f = fixture({}, { restarts: { max: 1, windowMs: 60_000, delayMs: 0 } });
  const host = await openLibraryHost(model, { command }, f.seams);
  const socketDir = dirname(f.launches()[0]!.launch.socketPath);
  try {
    await json(host, "/fake/crash");
    await until(() => f.launches().length === 2, "the respawn");
    await host.ready;
    await json(host, "/fake/crash");
    let spent: unknown;
    await until(async () => (spent = await host.ready.then(() => undefined, (error: unknown) => error)) !== undefined, "the budget to be spent");
    expect(spent).toBeInstanceOf(RestartBudgetExhaustedError);
    expect((spent as Error).message).toContain("restart limit");
    await expect(host.forward(new Request("http://engine/health"))).rejects.toThrow("restart limit");
    await expect(host.forward(chat("never sent"))).rejects.toThrow("restart limit");
    expect(f.launches().length).toBe(2);
  } finally { await host.close(); f.remove(); }
  expect(existsSync(socketDir)).toBe(false);
});

// The worker side of these failures (the exit-2 refusal and its reason, the ready
// timeout, a stop or the end of stdin during startup) is C2a's evidence, in
// tests/jobs/worker-process.test.ts and tests/worker-entry.test.ts. Here: the
// host's rejection of the open, no retry of the first load, and its cleanup.
test("a worker that fails before ready rejects the open with its reason, is not retried, and leaves no socket directory", async () => {
  for (const [env, options, message] of [
    [{ FAKE_WORKER_FAIL: "start" }, {}, "worker exited with code 1 before ready"],
    // Another package version refuses the launch record: the rejection carries its reason.
    [{ FAKE_WORKER_VERSION: "9.9.9" }, {}, `worker exited with code 2 before ready: worker protocol version mismatch: the launch record is ${WORKER_PROTOCOL_VERSION}, this worker is 9.9.9`],
    [{ FAKE_WORKER_LOAD_MS: "5000" }, { readyTimeoutMs: 200 }, "worker did not report ready within 200 ms"],
  ] as const) {
    const f = fixture(env);
    try {
      const started = Date.now();
      const error = await rejection(openLibraryHost(model, { command, ...options }, f.seams));
      expect(error.message).toBe(message);
      expect(Date.now() - started).toBeLessThan(4_000);
      expect(f.spawned.length).toBe(1);
      const [launched] = f.launches();
      expect(existsSync(dirname(launched!.launch.socketPath))).toBe(false);
      expect(alive(launched!.pid)).toBe(false);
    } finally { f.remove(); }
  }
  expect(errors).toContain("worker startup failed: fake load failure");
});
