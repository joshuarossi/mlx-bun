// The Docker Python verifier's lifecycle against a scripted docker CLI: the
// container's hardening, stdin delivery, environment, classification of every
// unavailable or unfinished outcome, and removal after each path that may have
// created a container, plus the standalone runner refusing an unpinned image.
// No docker process runs here; the opt-in acceptance in
// python-verifier-docker.test.ts runs real containers.
import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { hostname, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { createPythonVerifier, PYTHON_VERIFIER_OWNER_LABEL, spawnDocker, type DockerProcess, type SpawnDocker } from "../src/python-verifier";

const IMAGE = `python@sha256:${"0".repeat(64)}`;
const PASSING = "def inc(x):\n    return x + 1\n\nassert inc(1) == 2  # mlx-bun-source-marker\n";

type Step = { code?: number; stdout?: string; stderr?: string; hang?: boolean; outputAfterExit?: boolean } | Error;
interface Call { args: string[]; env: Record<string, string>; stdin?: string; process?: DockerProcess & { killed: boolean } }

/** A docker CLI whose invocations follow `steps` (per subcommand); `events` records spawn, kill and exit order.
 * `sweeps` holds the leftover sweep's calls (before the first create), `calls` the verification's. */
function fakeDocker(steps: Partial<Record<string, Step>> = {}, onSpawn?: (command: string) => void) {
  const calls: Call[] = [], sweeps: Call[] = [], events: string[] = [];
  const defaults: Record<string, Step> = { ps: {}, create: { stdout: "0123abcd\n" }, start: {},
    inspect: { stdout: state({}) }, rm: { stdout: "removed\n" } };
  const spawn: SpawnDocker = (args, { env, stdin }) => {
    const command = args[0]!;
    const call: Call = { args, env, ...(stdin ? { stdin: new TextDecoder().decode(stdin) } : {}) };
    (command === "ps" || (command === "rm" && !calls.some(c => c.args[0] === "create")) ? sweeps : calls).push(call);
    onSpawn?.(command);
    const step = steps[command] ?? defaults[command]!;
    if (step instanceof Error) throw step;
    events.push(`spawn ${command}`);
    const controllers: ReadableStreamDefaultController<Uint8Array>[] = [];
    let finish!: (code: number | null) => void;
    const exited = new Promise<number | null>(resolve => { finish = resolve; })
      .then(code => { events.push(`exit ${command}`); return code; });
    const stream = (text?: string) => new ReadableStream<Uint8Array>({ start(controller) {
      controllers.push(controller);
      const write = () => {
        if (text) controller.enqueue(new TextEncoder().encode(text));
        if (!step.hang) controller.close();
      };
      // Output can still be buffered in the pipe after the CLI has exited.
      if (step.outputAfterExit) setTimeout(write, 5); else write();
    } });
    const process = { killed: false, stdout: stream(step.stdout), stderr: stream(step.stderr), exited,
      kill() {
        process.killed = true;
        events.push(`kill ${command}`);
        for (const controller of controllers) try { controller.close(); } catch { /* already closed */ }
        finish(null);
      } };
    if (!step.hang) finish(step.code ?? 0);
    call.process = process;
    return process;
  };
  return { spawn, calls, sweeps, events, commands: () => calls.map(call => call.args[0]) };
}

function state(fields: Record<string, unknown>) {
  return JSON.stringify({ Status: "exited", ExitCode: 0, OOMKilled: false, Error: "", ...fields }) + "\n";
}
const verifier = (docker: ReturnType<typeof fakeDocker>, options: Parameters<typeof createPythonVerifier>[0] = {}) =>
  createPythonVerifier({ image: IMAGE, spawn: docker.spawn, timeouts: { runMs: 50, commandMs: 50 }, ...options });
const missing = () => Object.assign(new Error("docker CLI not found on PATH"), { code: "ENOENT" });
/** The kill of `command` happened, its exit was joined, and only then did removal start. */
function joinedBeforeRemoval(docker: ReturnType<typeof fakeDocker>, command: string) {
  const at = (event: string) => docker.events.indexOf(event);
  expect(at(`kill ${command}`)).toBeGreaterThanOrEqual(0);
  expect(at(`kill ${command}`)).toBeLessThan(at(`exit ${command}`));
  expect(at(`exit ${command}`)).toBeLessThan(at("spawn rm"));
}

const saved: Record<string, string | undefined> = {};
afterEach(() => { for (const [key, value] of Object.entries(saved)) {
  if (value === undefined) delete process.env[key]; else process.env[key] = value;
  delete saved[key];
} });

test("a passing program runs from stdin in a named container that is inspected and force-removed", async () => {
  const docker = fakeDocker();
  expect(await verifier(docker)(PASSING)).toEqual({ status: "verified" });
  expect(docker.commands()).toEqual(["create", "start", "inspect", "rm"]);
  const name = docker.calls[0]!.args[docker.calls[0]!.args.indexOf("--name") + 1]!;
  expect(name).toMatch(/^mlx-bun-python-verify-[0-9a-f-]{36}$/);
  expect(docker.calls.slice(1).map(call => call.args)).toEqual([["start", "--attach", "--interactive", name],
    ["inspect", "--type", "container", "--format", "{{json .State}}", name], ["rm", "--force", name]]);
  expect(docker.calls[1]!.stdin).toBe(PASSING);
  expect(docker.calls.filter(call => call.stdin !== undefined)).toHaveLength(1);
});

test("the container gets every hardening flag, no mount, device, port or environment, and the source only on stdin", async () => {
  const docker = fakeDocker();
  await verifier(docker)(PASSING);
  const create = docker.calls[0]!.args;
  for (const flag of ["--pull=never", "--read-only", "--interactive"]) expect(create).toContain(flag);
  for (const [flag, value] of [["--platform", "linux/arm64"], ["--network", "none"], ["--ipc", "none"], ["--user", "65534:65534"],
    ["--cap-drop", "ALL"], ["--security-opt", "no-new-privileges"], ["--memory", "256m"], ["--memory-swap", "256m"],
    ["--pids-limit", "64"], ["--cpus", "1"], ["--log-driver", "none"]]) expect(create[create.indexOf(flag!) + 1]).toBe(value!);
  // The only writable path is a small, non-executable /tmp; the owner label lets a later run remove leftovers.
  expect(create.filter(arg => arg === "--tmpfs")).toHaveLength(1);
  expect(create[create.indexOf("--tmpfs") + 1]).toBe("/tmp:rw,noexec,nosuid,nodev,size=16m");
  expect(create[create.indexOf("--label") + 1]).toBe(`${PYTHON_VERIFIER_OWNER_LABEL}=${hostname()}:${process.pid}`);
  for (const flag of ["-v", "--volume", "--mount", "--volumes-from", "--device", "-e", "--env", "--env-file",
    "-p", "--publish", "-P", "--privileged", "--cap-add", "--rm", "-t", "--tty"]) expect(create).not.toContain(flag);
  expect(create.filter(arg => /seccomp|apparmor|unconfined|host/.test(arg))).toEqual([]);
  // runMs 50 → a 1 s program deadline plus the 5 s in-container backstop.
  expect(create.slice(create.indexOf(IMAGE))).toEqual([IMAGE, "timeout", "-s", "KILL", "6", "python3", "-I", "-B", "-"]);
  for (const call of docker.calls) expect(call.args.join("\n")).not.toContain("mlx-bun-source-marker");
});

test("docker receives only PATH, plus DOCKER_HOST when the caller configures it", async () => {
  for (const key of ["MLX_BUN_TEST_SECRET", "AWS_SECRET_ACCESS_KEY", "HF_TOKEN"]) { saved[key] = process.env[key]; process.env[key] = "secret"; }
  const plain = fakeDocker();
  await verifier(plain)(PASSING);
  const hosted = fakeDocker();
  await verifier(hosted, { dockerHost: "unix:///private/tmp/docker.sock" })(PASSING);
  expect(plain.sweeps.length).toBeGreaterThan(0);
  for (const call of [...plain.sweeps, ...plain.calls]) expect(call.env).toEqual({ PATH: process.env.PATH ?? "" });
  for (const call of [...hosted.sweeps, ...hosted.calls]) expect(call.env).toEqual({ PATH: process.env.PATH ?? "", DOCKER_HOST: "unix:///private/tmp/docker.sock" });
});

test("a failing program keeps the bounded stderr, else stdout, and its exit code", async () => {
  const traceback = `Traceback (most recent call last):\n  File "<stdin>", line 4, in <module>\nAssertionError: ${"x".repeat(1000)}`;
  const failing = fakeDocker({ start: { code: 1, stderr: traceback }, inspect: { stdout: state({ ExitCode: 1 }) } });
  expect(await verifier(failing)(PASSING)).toEqual({ status: "failed", exitCode: 1, error: traceback.slice(0, 400) });
  expect(failing.commands()).toEqual(["create", "start", "inspect", "rm"]);
  const quiet = fakeDocker({ start: { code: 3, stdout: "wrong answer\n" }, inspect: { stdout: state({ ExitCode: 3 }) } });
  expect(await verifier(quiet)(PASSING)).toEqual({ status: "failed", exitCode: 3, error: "wrong answer\n" });
});

test("a missing docker CLI, unreachable daemon or missing image is unverified, never pulled and needs no removal", async () => {
  const absent = fakeDocker({ create: missing() });
  expect(await verifier(absent)(PASSING)).toMatchObject({ status: "unverified", reason: "docker-missing" });
  expect(absent.commands()).toEqual(["create"]);

  const down = "Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?\n";
  const daemon = fakeDocker({ create: { code: 1, stderr: down } });
  const offline = await verifier(daemon)(PASSING);
  expect(offline).toMatchObject({ status: "unverified", reason: "daemon-unavailable" });
  expect(offline.status === "unverified" && offline.error).toContain("Cannot connect to the Docker daemon");
  expect(daemon.commands()).toEqual(["create"]);

  const image = fakeDocker({ create: { code: 125, stderr: `Error response from daemon: No such image: ${IMAGE}\n` } });
  const absentImage = await verifier(image)(PASSING);
  expect(absentImage).toMatchObject({ status: "unverified", reason: "image-missing" });
  expect(absentImage.status === "unverified" && absentImage.error).toContain(`docker pull --platform linux/arm64 ${IMAGE}`);
  expect(image.commands()).toEqual(["create"]);
  expect(image.calls[0]!.args).toContain("--pull=never");

  const noisy = fakeDocker({ create: { code: 1, stderr: `Cannot connect to the Docker daemon ${"y".repeat(2000)}` } });
  const bounded = await verifier(noisy)(PASSING);
  expect(bounded.status === "unverified" && bounded.error.length).toBe(400);
});

test("the default process runner reports a docker CLI missing from PATH as ENOENT", () => {
  expect(() => spawnDocker(["version"], { env: { PATH: "/nonexistent-mlx-bun-path" } })).toThrow(expect.objectContaining({ code: "ENOENT" }));
});

test("an image reference without a digest is refused before any docker call", async () => {
  for (const image of ["", "python:3.13-slim", "python@sha256:abc", `--privileged@sha256:${"0".repeat(64)}`]) {
    const docker = fakeDocker();
    expect(await verifier(docker, { image })(PASSING)).toMatchObject({ status: "unverified", reason: "image-unpinned" });
    expect(docker.calls).toEqual([]);
    expect(docker.sweeps).toEqual([]);
  }
});

test("a timeout kills and joins the docker CLI group, then removes the container without inspecting it", async () => {
  const docker = fakeDocker({ start: { hang: true } });
  const result = await verifier(docker)(PASSING);
  expect(result).toMatchObject({ status: "unverified", reason: "timeout" });
  expect(docker.commands()).toEqual(["create", "start", "rm"]);
  expect(docker.calls[1]!.process!.killed).toBe(true);
  joinedBeforeRemoval(docker, "start");
});

test("cancellation kills and joins the running CLI, then removes the container", async () => {
  const abort = new AbortController();
  const docker = fakeDocker({ start: { hang: true } }, command => { if (command === "start") setTimeout(() => abort.abort(), 5); });
  const result = await verifier(docker, { timeouts: { runMs: 10_000, commandMs: 50 } })(PASSING, abort.signal);
  expect(result).toMatchObject({ status: "unverified", reason: "cancelled" });
  expect(docker.commands()).toEqual(["create", "start", "rm"]);
  joinedBeforeRemoval(docker, "start");
});

test("cancellation before or during create never starts the program and removes anything created", async () => {
  const before = new AbortController();
  before.abort();
  const idle = fakeDocker();
  expect(await verifier(idle)(PASSING, before.signal)).toMatchObject({ status: "unverified", reason: "cancelled" });
  expect(idle.calls).toEqual([]);
  expect(idle.sweeps).toEqual([]);

  const during = new AbortController();
  const docker = fakeDocker({}, command => { if (command === "create") during.abort(); });
  expect(await verifier(docker)(PASSING, during.signal)).toMatchObject({ status: "unverified", reason: "cancelled" });
  expect(docker.commands()).toEqual(["create", "rm"]);
});

test("output beyond 64 KiB is unverified, whether the CLI is still running or has already exited", async () => {
  const flooding = fakeDocker({ start: { stdout: "x".repeat(70 * 1024), hang: true } });
  expect(await verifier(flooding, { timeouts: { runMs: 10_000, commandMs: 50 } })(PASSING))
    .toMatchObject({ status: "unverified", reason: "output-overflow" });
  expect(flooding.commands()).toEqual(["create", "start", "rm"]);
  joinedBeforeRemoval(flooding, "start");

  const finished = fakeDocker({ start: { stderr: "e".repeat(40 * 1024), stdout: "o".repeat(40 * 1024), outputAfterExit: true } });
  expect(await verifier(finished)(PASSING)).toMatchObject({ status: "unverified", reason: "output-overflow" });
  expect(finished.commands()).toEqual(["create", "start", "rm"]);
});

test("a killed or out-of-memory program is unverified", async () => {
  for (const fields of [{ ExitCode: 137, OOMKilled: true }, { ExitCode: 137, OOMKilled: false }, { ExitCode: 0, OOMKilled: true }]) {
    const docker = fakeDocker({ inspect: { stdout: state(fields) } });
    expect(await verifier(docker)(PASSING)).toMatchObject({ status: "unverified", reason: "oom" });
    expect(docker.commands()).toEqual(["create", "start", "inspect", "rm"]);
  }
});

test("an unknown or incomplete container state is never verified", async () => {
  for (const inspect of [{ code: 1, stderr: "Error: No such object" }, { stdout: "not json" }, { stdout: state({ Status: "running" }) },
    { stdout: state({ Status: "created", ExitCode: 127, Error: "exec: \"python3\": executable file not found" }) },
    { stdout: state({ Error: "OCI runtime error" }) }]) {
    const docker = fakeDocker({ inspect });
    expect(await verifier(docker)(PASSING)).toMatchObject({ status: "unverified", reason: "docker-error" });
    expect(docker.commands()).toEqual(["create", "start", "inspect", "rm"]);
  }
});

test("a hung create is killed and removal is still attempted", async () => {
  const docker = fakeDocker({ create: { hang: true } });
  expect(await verifier(docker)(PASSING)).toMatchObject({ status: "unverified", reason: "daemon-unavailable" });
  expect(docker.commands()).toEqual(["create", "rm"]);
  joinedBeforeRemoval(docker, "create");
});

test("an unconfirmed removal turns any outcome into cleanup-uncertain; an already-absent container is removed", async () => {
  const refused = fakeDocker({ rm: { code: 1, stderr: "Error response from daemon: cannot remove container" } });
  const result = await verifier(refused)(PASSING);
  expect(result).toMatchObject({ status: "unverified", reason: "cleanup-uncertain" });
  expect(result.status === "unverified" && result.error).toContain(refused.calls[3]!.args[2]!);
  expect(result.status === "unverified" && result.error).toContain("outcome before removal: verified");

  const hung = fakeDocker({ rm: { hang: true } });
  expect(await verifier(hung)(PASSING)).toMatchObject({ status: "unverified", reason: "cleanup-uncertain" });
  expect(hung.calls[3]!.process!.killed).toBe(true);

  const vanished = fakeDocker({ rm: missing() });
  expect(await verifier(vanished)(PASSING)).toMatchObject({ status: "unverified", reason: "cleanup-uncertain" });

  const gone = fakeDocker({ rm: { code: 1, stderr: "Error response from daemon: No such container: x" } });
  expect(await verifier(gone)(PASSING)).toEqual({ status: "verified" });
});

test("the standalone runner prints the shared verifier's result and maps it to its exit status", () => {
  const script = resolve(import.meta.dir, "../scripts/verify-python.ts");
  const run = (args: string[], stdin?: string) => {
    const child = Bun.spawnSync([process.execPath, "--no-env-file", script, ...args], { stdin: stdin === undefined ? "ignore" : Buffer.from(stdin) });
    return { code: child.exitCode, stdout: child.stdout.toString(), stderr: child.stderr.toString() };
  };
  const help = run(["--help"]);
  expect(help.code).toBe(0);
  expect(help.stdout).toContain("Verify one Python program in the Docker verifier used by verified_code.");
  // An unpinned image is refused before docker is involved, from stdin or a file.
  const piped = run(["--image", "python:3.13-slim"], PASSING);
  expect(piped.code).toBe(2);
  expect(JSON.parse(piped.stdout)).toMatchObject({ status: "unverified", reason: "image-unpinned" });
  const root = mkdtempSync(join(tmpdir(), "mlx-verify-python-"));
  try {
    writeFileSync(join(root, "program.py"), PASSING);
    const fromFile = run(["--image", "python:3.13-slim", join(root, "program.py")]);
    expect(fromFile.code).toBe(2);
    expect(JSON.parse(fromFile.stdout)).toMatchObject({ status: "unverified", reason: "image-unpinned" });
  } finally { rmSync(root, { recursive: true, force: true }); }
  for (const args of [["--nope"], ["one.py", "two.py"]]) {
    const usage = run(args);
    expect(usage.code).toBe(64);
    expect(usage.stderr).toContain("Verify one Python program");
  }
});

test("the first verification removes leftover containers whose owner on this host is gone, and only those", async () => {
  const exited = Bun.spawnSync(["true"]).pid; // a pid whose process is gone
  const label = (owner: string) => `${PYTHON_VERIFIER_OWNER_LABEL}=${owner}`;
  const listing = [`dead ${hostname()}:${exited}`, `self ${hostname()}:${process.pid}`, `live ${hostname()}:${process.ppid}`,
    `elsewhere other-host.invalid:${exited}`, `garbled ${hostname()}`, ""].join("\n");
  const docker = fakeDocker({ ps: { stdout: listing } });
  const verify = verifier(docker);
  expect(await verify(PASSING)).toEqual({ status: "verified" });
  expect(docker.sweeps.map(call => call.args)).toEqual([
    ["ps", "--all", "--filter", `label=${PYTHON_VERIFIER_OWNER_LABEL}`, "--format", `{{.ID}} {{.Label "${PYTHON_VERIFIER_OWNER_LABEL}"}}`],
    ["rm", "--force", "dead"]]);
  expect(docker.commands()).toEqual(["create", "start", "inspect", "rm"]);
  expect(docker.calls[0]!.args).toContain(label(`${hostname()}:${process.pid}`));
  // One successful sweep per verifier.
  await verify(PASSING);
  expect(docker.sweeps).toHaveLength(2);
});

test("a failed sweep does not change the outcome and is retried by the next verification", async () => {
  const docker = fakeDocker({ ps: { code: 1, stderr: "Cannot connect to the Docker daemon" } });
  const verify = verifier(docker);
  expect(await verify(PASSING)).toEqual({ status: "verified" });
  await verify(PASSING);
  expect(docker.sweeps.map(call => call.args[0])).toEqual(["ps", "ps"]);
});
