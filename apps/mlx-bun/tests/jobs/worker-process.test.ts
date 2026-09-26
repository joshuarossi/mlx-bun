import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { executablePath } from "../../src/jobs/executable";
import { decodeLaunch, encodeLaunch, spawnWorker, WorkerExitedError, WORKER_MESSAGE_PREFIX } from "../../src/jobs/worker-process";

// A stand-in worker that speaks the handshake: the launch record is the first
// stdin line, the ready line goes to stdout, everything else is log output.
// `launch.mode` selects the behavior under test.
const fakeWorker = `
const reader = Bun.stdin.stream().getReader(), decoder = new TextDecoder();
let text = "";
while (!text.includes("\\n")) { const { done, value } = await reader.read(); if (done) break; text += decoder.decode(value, { stream: true }); }
const launch = JSON.parse(text.slice(0, text.indexOf("\\n")), (key, value) => value && typeof value === "object" && "$number" in value ? Number(value.$number) : value);
console.error("fake worker starting " + launch.model.repoId + " max=" + launch.options.cache.ssdCacheMaxBytes);
console.log("loading weights");
if (launch.mode === "crash") { console.error("boom"); process.exit(3); }
if (launch.mode === "silent") await new Promise(() => {});
await Bun.write(launch.socketPath, "");
const socketPath = launch.mode === "wrong-socket" ? "/elsewhere.sock" : launch.socketPath;
console.log(${JSON.stringify(WORKER_MESSAGE_PREFIX)} + JSON.stringify({ type: "ready", socketPath, modelId: launch.model.repoId, pid: process.pid }));
console.log("serving");
if (launch.mode === "ignore-sigterm") process.on("SIGTERM", () => { console.error("ignoring SIGTERM"); });
else {
  process.on("SIGTERM", () => { console.error("stopping"); process.exit(0); });
  void (async () => { for (;;) { const { done } = await reader.read(); if (done) { console.error("parent left"); process.exit(0); } } })();
}
await new Promise(() => {});
`;

const launchFor = (socketPath: string, mode?: string) => ({ socketPath, ...(mode ? { mode } : {}),
  model: { repoId: "org/model", path: "/unused" }, options: { cache: { ssdCacheMaxBytes: Infinity }, request: {}, capacity: 8 } });

function fixture() {
  const dir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const entry = join(dir, "fake-worker.ts");
  writeFileSync(entry, fakeWorker);
  const logs: string[] = [], errors: string[] = [];
  return { dir, entry, socketPath: join(dir, "worker.sock"), logs, errors,
    spawn: (mode?: string, extra: Partial<Parameters<typeof spawnWorker>[0]> = {}) => spawnWorker({ entry, socketPath: join(dir, "worker.sock"),
      launch: launchFor(join(dir, "worker.sock"), mode), log: line => logs.push(line), error: line => errors.push(line),
      env: { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" }, ...extra }),
    remove: () => rmSync(dir, { recursive: true, force: true }) };
}

test("the spawn command follows the job runner: the captured executable, then the source entry or the compiled dispatch", async () => {
  for (const entry of ["/source/worker-entry.ts", "/$bunfs/root/worker-entry.ts"]) {
    let command: string[] | undefined, written = "";
    const exit = Promise.withResolvers<number>();
    const worker = spawnWorker({ entry, socketPath: "/unused/worker.sock", launch: launchFor("/unused/worker.sock"),
      spawn: ((argv: string[]) => {
        command = argv;
        return { pid: 1, stdin: { write(chunk: string) { written += chunk; }, flush() {}, end() {} }, stdout: undefined, stderr: undefined,
          exited: exit.promise, exitCode: null, signalCode: null, kill() { exit.resolve(0); } };
      }) as unknown as typeof Bun.spawn });
    expect(command).toEqual([executablePath, entry.includes("$bunfs") ? "__worker" : entry]);
    expect(executablePath).toBe(process.execPath);
    expect(written.endsWith("\n")).toBe(true);
    // The launch record round-trips, including the unbounded SSD cache JSON would null.
    expect(decodeLaunch(written)).toEqual(launchFor("/unused/worker.sock"));
    expect(JSON.parse(encodeLaunch({ max: Infinity, min: -Infinity, n: 1 }))).toEqual({ max: { $number: "Infinity" }, min: { $number: "-Infinity" }, n: 1 });
    expect(worker.modelId).toBeUndefined();
    await worker.close();
  }
});

test("a worker that reports ready resolves with its socket and model, forwards its logs, and stops on SIGTERM", async () => {
  const fake = fixture();
  try {
    const worker = fake.spawn();
    expect(await worker.ready).toEqual({ socketPath: fake.socketPath, modelId: "org/model" });
    expect([worker.modelId, worker.socketPath]).toEqual(["org/model", fake.socketPath]);
    expect(worker.pid).toBeGreaterThan(0);
    expect(fake.errors).toEqual(["fake worker starting org/model max=Infinity"]);
    expect(fake.logs).toContain("loading weights");
    expect(fake.logs.some(line => line.startsWith(WORKER_MESSAGE_PREFIX))).toBe(false);
    expect(existsSync(fake.socketPath)).toBe(true);
    const exit = await worker.close();
    expect(exit).toEqual({ code: 0, signal: null });
    expect(await worker.close()).toBe(exit);
    expect(await worker.exited).toBe(exit);
    expect(fake.errors).toEqual(["fake worker starting org/model max=Infinity", "stopping"]);
    expect(fake.logs).toEqual(["loading weights", "serving"]);
    expect(existsSync(fake.socketPath)).toBe(false);
  } finally { fake.remove(); }
});

test("a worker that ignores SIGTERM is killed after the grace", async () => {
  const fake = fixture();
  try {
    const worker = fake.spawn("ignore-sigterm", { graceMs: 200 });
    await worker.ready;
    const started = Date.now();
    expect(await worker.close()).toEqual({ code: null, signal: "SIGKILL" });
    expect(Date.now() - started).toBeGreaterThanOrEqual(150);
    expect(fake.errors).toContain("ignoring SIGTERM");
    expect(existsSync(fake.socketPath)).toBe(false);
  } finally { fake.remove(); }
});

test("a crash before ready rejects ready with the exit after stderr has drained, and a wrong socket echo rejects too", async () => {
  const fake = fixture();
  try {
    const crashed = fake.spawn("crash");
    const failure = await crashed.ready.then(() => { throw new Error("must not be ready"); }, (error: unknown) => error);
    expect(failure).toBeInstanceOf(WorkerExitedError);
    expect((failure as WorkerExitedError).exit).toEqual({ code: 3, signal: null });
    expect((failure as Error).message).toBe("worker exited with code 3 before ready");
    expect(fake.errors).toEqual(["fake worker starting org/model max=Infinity", "boom"]);
    expect(await crashed.exited).toEqual({ code: 3, signal: null });
    expect(await crashed.close()).toEqual({ code: 3, signal: null });
    const wrong = fake.spawn("wrong-socket");
    await expect(wrong.ready).rejects.toThrow(`worker bound /elsewhere.sock, not ${fake.socketPath}`);
    expect(await wrong.close()).toEqual({ code: 0, signal: null });
  } finally { fake.remove(); }
});

test("a worker that never reports ready is stopped at the ready timeout", async () => {
  const fake = fixture();
  try {
    const worker = fake.spawn("silent", { readyTimeoutMs: 150 });
    await expect(worker.ready).rejects.toThrow("worker did not report ready within 150 ms");
    expect(await worker.exited).toEqual({ code: null, signal: "SIGTERM" });
  } finally { fake.remove(); }
});
