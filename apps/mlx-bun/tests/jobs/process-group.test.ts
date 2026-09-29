// Real processes, no native MLX: a managed job child leads its own process
// group, and the job host joins that whole group (not only the child) on
// shutdown, on the child's own exit, and when the host disappears.
import { afterEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { JobStore } from "../../src/jobs/db";
import { closeSubprocessJobs, submitSubprocess } from "../../src/jobs/runner";

const jobEntry = resolve(import.meta.dir, "../../src/cli/job-entry.ts");
const roots: string[] = [], stores: JobStore[] = [], strays: number[] = [];
afterEach(async () => {
  for (const store of stores.splice(0)) { await closeSubprocessJobs(store); store.close(); }
  for (const pid of strays.splice(0)) { try { process.kill(pid, "SIGKILL"); } catch { /* already gone */ } }
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
});
function fresh() {
  const root = mkdtempSync(join(tmpdir(), "mlx-job-group-")); roots.push(root);
  const store = new JobStore(join(root, "jobs.sqlite"), join(root, "logs")); stores.push(store);
  return { root, store };
}
const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };
async function until(check: () => boolean, ms = 5_000) {
  const end = Date.now() + ms;
  while (!check()) { if (Date.now() > end) throw new Error("timed out"); await Bun.sleep(10); }
}
/** A stand-in job child: it starts `sleep 60` sharing its stdout and stderr
 * (a descendant holding the job's log pipes), records both pids, then either
 * stays up or exits at once. */
function childEntry(root: string, exitAtOnce: boolean) {
  const entry = join(root, "child.ts"), pids = join(root, "pids.json");
  writeFileSync(entry, `
    const descendant = Bun.spawn(["sleep", "60"], { stdout: "inherit", stderr: "inherit" });
    require("node:fs").writeFileSync(${JSON.stringify(pids)}, JSON.stringify({ leader: process.pid, descendant: descendant.pid }));
    ${exitAtOnce ? "process.exit(0);" : "setInterval(() => {}, 1000);"}`);
  const read = () => {
    if (!existsSync(pids)) return undefined;
    const value = JSON.parse(readFileSync(pids, "utf8")) as { leader: number; descendant: number };
    strays.push(value.leader, value.descendant);
    return value;
  };
  return { entry, read };
}

test("shutdown stops a descendant holding the child's output with the child, instead of waiting for it", async () => {
  const { root, store } = fresh(), child = childEntry(root, false);
  let released = false;
  const { jobId } = submitSubprocess(store, "quantize", {}, undefined, { entry: child.entry,
    acquire: async () => ({ dispose() { released = true; } }) });
  await until(() => child.read() !== undefined);
  const { leader, descendant } = child.read()!;
  const started = Date.now();
  await closeSubprocessJobs(store);
  expect(Date.now() - started).toBeLessThan(5_000);
  expect(released).toBe(true);
  expect(alive(leader)).toBe(false);
  expect(alive(descendant)).toBe(false);
  expect(store.get(jobId)?.status).toBe("failed");
}, 20_000);

test("a child that exits leaving a descendant on its output releases the lease once that descendant is stopped", async () => {
  const { root, store } = fresh(), child = childEntry(root, true);
  const released = Promise.withResolvers<void>();
  submitSubprocess(store, "quantize", {}, undefined, { entry: child.entry,
    acquire: async () => ({ dispose() { released.resolve(); } }) });
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    await Promise.race([released.promise, new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error("the lease waited on the descendant")), 5_000);
    })]);
  } finally { clearTimeout(timer); }
  expect(alive(child.read()!.descendant)).toBe(false);
}, 20_000);

test("a descendant ignoring SIGTERM is killed after the grace period before the job counts as joined", async () => {
  const { root, store } = fresh(), pids = join(root, "pids.json"), entry = join(root, "child.ts");
  writeFileSync(entry, `
    const descendant = Bun.spawn(["sh", "-c", "trap '' TERM; sleep 60"], { stdout: "inherit", stderr: "inherit" });
    require("node:fs").writeFileSync(${JSON.stringify(pids)}, JSON.stringify({ descendant: descendant.pid }));
    await Bun.sleep(100); process.exit(0);`);
  const released = Promise.withResolvers<void>();
  submitSubprocess(store, "quantize", {}, undefined, { entry, graceMs: 200, acquire: async () => ({ dispose() { released.resolve(); } }) });
  await until(() => existsSync(pids));
  const { descendant } = JSON.parse(readFileSync(pids, "utf8")) as { descendant: number };
  strays.push(descendant);
  const started = Date.now();
  await released.promise;
  expect(Date.now() - started).toBeLessThan(5_000);
  expect(alive(descendant)).toBe(false);
}, 20_000);

test("the child leads its own process group and holds a parent pipe it is told to watch", async () => {
  const { store } = fresh();
  let options: Parameters<typeof Bun.spawn>[1] | undefined;
  const exit = Promise.withResolvers<number>();
  submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts", acquire: async () => ({ dispose() {} }),
    spawn: ((_command: string[], supplied: Parameters<typeof Bun.spawn>[1]) => {
      options = supplied;
      return { pid: -1, stdout: undefined, stderr: undefined, stdin: { end() {} }, exited: exit.promise, exitCode: null, kill() {} };
    }) as unknown as typeof Bun.spawn });
  await until(() => options !== undefined);
  expect(options).toMatchObject({ detached: true, stdin: "pipe", stdout: "pipe", stderr: "pipe" });
  expect(options!.env).toMatchObject({ MLX_BUN_JOB_PARENT_PIPE: "1", MLX_BUN_JOBS_DB: store.dbPath, MLX_BUN_JOBS_DIR: store.logsDir });
  exit.resolve(1);
});

test("a job child whose host is gone stops itself and its descendants", async () => {
  const { root } = fresh(), pids = join(root, "pids.json");
  // The job entry's watch, in a group-leading child with a descendant, as the runner spawns it.
  const child = Bun.spawn([process.execPath, "-e", `
    const { stopWithParent } = await import(${JSON.stringify(jobEntry)});
    stopWithParent(Bun.stdin.stream());
    const descendant = Bun.spawn(["sleep", "60"]);
    require("node:fs").writeFileSync(${JSON.stringify(pids)}, JSON.stringify({ descendant: descendant.pid }));
    setInterval(() => {}, 1000);`], { detached: true, stdin: "pipe", stdout: "ignore", stderr: "inherit",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" } });
  strays.push(child.pid);
  await until(() => existsSync(pids));
  const { descendant } = JSON.parse(readFileSync(pids, "utf8")) as { descendant: number };
  strays.push(descendant);
  expect(alive(child.pid)).toBe(true);
  child.stdin.end(); // what the kernel does when the host exits
  await until(() => child.exitCode !== null || child.signalCode !== null);
  expect(child.signalCode).toBe("SIGTERM");
  await until(() => !alive(descendant));
}, 20_000);

test("a job row that cannot be read after admission is failed without spawning a child", async () => {
  const { store } = fresh();
  let spawned = 0, released = false;
  const get = store.get.bind(store);
  const { jobId } = submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts",
    acquire: async () => {
      // The row read that follows admission fails (e.g. SQLITE_BUSY past the timeout).
      store.get = (id: string) => { store.get = get; throw new Error("database is locked"); };
      return { dispose() { released = true; } };
    },
    spawn: (() => { spawned++; return { pid: -1, stdout: undefined, stderr: undefined, stdin: { end() {} },
      exited: new Promise<number>(() => {}), exitCode: null, kill() {} }; }) as unknown as typeof Bun.spawn });
  await until(() => released);
  expect(spawned).toBe(0);
  expect(store.get(jobId)).toMatchObject({ status: "failed", error: "Error: database is locked" });
});

/** A supplied child process that never ends on its own; `exited` settles it. */
function fakeChild(pid: number, exited: Promise<number>) {
  return (() => ({ pid, stdout: undefined, stderr: undefined, stdin: { end() {} }, exited, exitCode: null, kill() {} })) as unknown as typeof Bun.spawn;
}
async function within<T>(work: Promise<T>, ms: number, what: string): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([work, new Promise<never>((_, reject) => { timer = setTimeout(() => reject(new Error(what)), ms); })]);
  } finally { clearTimeout(timer); }
}

test("a group member surviving SIGKILL is left behind one grace later instead of holding the lease", async () => {
  const { store } = fresh(), group = 2_000_000_001, kill = process.kill.bind(process);
  // An unkillable group (uninterruptible sleep): it always exists, and every signal to it is lost.
  const signals: (string | number | undefined)[] = [];
  const killSpy = spyOn(process, "kill").mockImplementation(((pid: number, signal?: string | number) => {
    if (pid !== -group) return kill(pid, signal);
    signals.push(signal);
    return true;
  }) as typeof process.kill);
  const errorSpy = spyOn(console, "error").mockImplementation(() => {});
  try {
    const released = Promise.withResolvers<void>();
    submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts", graceMs: 100, spawn: fakeChild(group, Promise.resolve(0)),
      acquire: async () => ({ dispose() { released.resolve(); } }) });
    await within(released.promise, 5_000, "the lease waited on a process that outlived SIGKILL");
    expect(signals).toContain("SIGTERM");
    expect(signals).toContain("SIGKILL");
    expect(errorSpy.mock.calls.flat().join(" ")).toContain("outlived SIGKILL");
  } finally { killSpy.mockRestore(); errorSpy.mockRestore(); }
}, 20_000);

test("a process that left the group holding the child's output does not hold the lease past the grace", async () => {
  const { root, store } = fresh(), pids = join(root, "pids.json"), entry = join(root, "child.ts");
  // The descendant leads a group of its own, so stopping the child's group cannot reach it.
  writeFileSync(entry, `
    const escaped = Bun.spawn(["sleep", "60"], { detached: true, stdout: "inherit", stderr: "inherit" });
    require("node:fs").writeFileSync(${JSON.stringify(pids)}, JSON.stringify({ escaped: escaped.pid }));
    process.exit(0);`);
  const errorSpy = spyOn(console, "error").mockImplementation(() => {});
  try {
    const released = Promise.withResolvers<void>();
    submitSubprocess(store, "quantize", {}, undefined, { entry, graceMs: 200, acquire: async () => ({ dispose() { released.resolve(); } }) });
    await until(() => existsSync(pids));
    strays.push((JSON.parse(readFileSync(pids, "utf8")) as { escaped: number }).escaped);
    await within(released.promise, 5_000, "the lease waited on output held outside the group");
    expect(errorSpy.mock.calls.flat().join(" ")).toContain("outlived SIGKILL or its output");
  } finally { errorSpy.mockRestore(); }
}, 20_000);

test("shutdown releases the lease one grace after SIGKILL when the child itself does not die", async () => {
  const { store } = fresh();
  const errorSpy = spyOn(console, "error").mockImplementation(() => {});
  try {
    let released = false, spawned = false;
    const child = fakeChild(-1, new Promise<number>(() => {}));
    submitSubprocess(store, "quantize", {}, undefined, { entry: "child.ts", graceMs: 100,
      spawn: ((...args: Parameters<typeof Bun.spawn>) => { spawned = true; return child(...args); }) as typeof Bun.spawn,
      acquire: async () => ({ dispose() { released = true; } }) });
    await until(() => spawned);
    await within(closeSubprocessJobs(store), 5_000, "shutdown waited on a child that outlived SIGKILL");
    expect(released).toBe(true);
    expect(errorSpy.mock.calls.flat().join(" ")).toContain("outlived SIGKILL");
  } finally { errorSpy.mockRestore(); }
}, 20_000);
