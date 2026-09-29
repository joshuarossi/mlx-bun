// The Python verifier behind the verified_code dataset template and the
// standalone scripts/verify-python.ts runner. Generated code runs only inside a
// disposable Docker container from a digest-pinned linux/arm64 image that is
// never pulled here: no network, no host mounts or inherited environment, a
// read-only root, an unprivileged user without capabilities or new privileges,
// the default seccomp profile, and fixed memory, process, CPU, output and time
// limits; only a small `/tmp` tmpfs is writable. The program arrives on stdin.
//
// This module owns the container from create to forced removal and every
// docker CLI process group it spawns. Killing a CLI does not stop its
// container, so each path that may have created one removes it; a removal that
// cannot be confirmed makes the result unverified. Cancellation, timeouts,
// output overflow and OOM never report verified. There is no host-Python
// fallback, and verification takes no inference lease. Each container carries
// its owner's host and pid as a label; a verifier's first run removes leftovers
// whose owner process on this host is gone (a host killed mid-verification).

import { hostname } from "node:os";

/** The verifier image: the linux/arm64 manifest of `python:3.14-slim`
 * (3.14.7-slim-trixie), pinned by digest. It is never pulled here; provisioning
 * is in the app README's Dataset jobs section. */
export const PYTHON_VERIFIER_IMAGE = "python@sha256:67994a05c712036dbfc4385b4bceafc0ce20df950f54b9ea355582c153bf6157";

/** Fixed limits. `runMs` bounds `docker start` (container start and program);
 * `commandMs` bounds each create, inspect and remove; `outputBytes` bounds the
 * program's combined stdout and stderr; `tmp` sizes the writable `/tmp`. */
export const PYTHON_VERIFIER_LIMITS = {
  runMs: 15_000, commandMs: 20_000, outputBytes: 64 * 1024, memory: "256m", pids: 64, cpus: 1, tmp: "16m",
} as const;

/** Label naming a verifier container's owner as `<hostname>:<pid>`. */
export const PYTHON_VERIFIER_OWNER_LABEL = "mlx-bun.python-verifier.owner";

/** Why an outcome could not be established. */
export type UnverifiedReason = "image-unpinned" | "docker-missing" | "daemon-unavailable" | "image-missing"
  | "docker-error" | "timeout" | "cancelled" | "output-overflow" | "oom" | "cleanup-uncertain";

/** `verified` only when the program exited 0 within every limit and its
 * container was removed. `failed` carries the program's stderr (else stdout);
 * `unverified` carries a diagnostic. Both texts are bounded to 400 characters. */
export type PythonVerification =
  | { status: "verified" }
  | { status: "failed"; exitCode: number; error: string }
  | { status: "unverified"; reason: UnverifiedReason; error: string };

/** Verifies one program. Resolves (never rejects for Docker or program
 * failures) only after every docker process it spawned has exited and its
 * container was removed, or `cleanup-uncertain` reports that it may remain.
 * An abort kills the running program and resolves `cancelled` the same way. */
export type VerifyPython = (source: string, signal?: AbortSignal) => Promise<PythonVerification>;

/** One spawned docker CLI invocation. */
export interface DockerProcess {
  readonly stdout: ReadableStream<Uint8Array>;
  readonly stderr: ReadableStream<Uint8Array>;
  /** Exit code, or null when a signal ended the process. */
  readonly exited: Promise<number | null>;
  /** SIGKILL the invocation's whole process group. */
  kill(): void;
}

/** Runs `docker <args>` with exactly `env`. Throws with `code: "ENOENT"` when
 * no docker CLI is on `env.PATH`. */
export type SpawnDocker = (args: string[], options: { env: Record<string, string>; stdin?: Uint8Array }) => DockerProcess;

export interface PythonVerifierOptions {
  /** Digest-pinned image; defaults to {@link PYTHON_VERIFIER_IMAGE}. */
  image?: string;
  /** Forwarded to docker as DOCKER_HOST; the only variable besides PATH. */
  dockerHost?: string;
  spawn?: SpawnDocker;
  /** Tests shorten the fixed time limits. */
  timeouts?: { runMs?: number; commandMs?: number };
}

const ERROR_CHARS = 400;
const DRAIN_MS = 1_000;
const PINNED_IMAGE = /^[a-z0-9][\w.\-/:]*@sha256:[0-9a-f]{64}$/;
const DAEMON_DOWN = /cannot connect to the docker daemon|is the docker daemon running|error during connect|connection refused|dial unix/i;
const IMAGE_MISSING = /no such image|does not match the specified platform|unable to find image|manifest unknown/i;

/** Spawns the docker CLI in its own process group (setsid), so a kill reaches
 * anything it started. */
export const spawnDocker: SpawnDocker = (args, { env, stdin }) => {
  const docker = Bun.which("docker", { PATH: env.PATH ?? "" });
  if (!docker) throw Object.assign(new Error("docker CLI not found on PATH"), { code: "ENOENT" });
  const child = Bun.spawn([docker, ...args], { env, stdin: stdin ?? "ignore", stdout: "pipe", stderr: "pipe", detached: true });
  return {
    stdout: child.stdout, stderr: child.stderr,
    exited: child.exited.then(() => child.signalCode ? null : child.exitCode),
    kill() {
      try { process.kill(-child.pid, "SIGKILL"); } catch { try { child.kill("SIGKILL"); } catch { /* already gone */ } }
    },
  };
};

const bounded = (text: string) => text.trim().slice(0, ERROR_CHARS);
const unverified = (reason: UnverifiedReason, error: string): PythonVerification => ({ status: "unverified", reason, error: bounded(error) });
const seconds = (ms: number) => `${ms / 1000} s`;

type Ending = "timeout" | "cancelled" | "overflow";
interface Outcome { code: number | null; ending?: Ending; stdout: string; stderr: string }

/** Runs one docker invocation to completion. A timeout or abort before it
 * exits, or output beyond `outputBytes` at any point, ends it and kills its
 * process group; the process is always joined. */
async function run(spawn: SpawnDocker, args: string[], env: Record<string, string>,
  limit: { timeoutMs: number; outputBytes: number; stdin?: Uint8Array; signal?: AbortSignal }): Promise<Outcome> {
  const child = spawn(args, { env, ...(limit.stdin ? { stdin: limit.stdin } : {}) });
  let ending: Ending | undefined, exited = false, budget = limit.outputBytes;
  const end = (why: Ending) => {
    if (ending || (exited && why !== "overflow")) return;
    ending = why;
    if (!exited) child.kill();
  };
  const readers = [child.stdout.getReader(), child.stderr.getReader()];
  const texts = readers.map(async reader => {
    const parts: Uint8Array[] = [];
    try {
      for (;;) {
        const { done, value } = await reader.read();
        if (done) break;
        if (budget > 0) parts.push(value.subarray(0, budget));
        budget -= value.byteLength;
        if (budget < 0) { end("overflow"); await reader.cancel().catch(() => {}); break; }
      }
    } catch { /* a broken pipe ends the text; the exit status still decides */ }
    return Buffer.concat(parts).toString("utf8");
  });
  const timer = setTimeout(end, limit.timeoutMs, "timeout");
  const abort = () => end("cancelled");
  limit.signal?.addEventListener("abort", abort, { once: true });
  if (limit.signal?.aborted) abort();
  let drain: ReturnType<typeof setTimeout> | undefined;
  try {
    const code = await child.exited;
    exited = true;
    // The group is gone; a pipe still held open elsewhere does not delay the caller.
    const drained = await Promise.race([Promise.all(texts),
      new Promise<undefined>(resolve => { drain = setTimeout(resolve, DRAIN_MS, undefined); })]);
    if (!drained) for (const reader of readers) await reader.cancel().catch(() => {});
    const [stdout = "", stderr = ""] = drained ?? await Promise.all(texts);
    return { code, ending, stdout, stderr };
  } finally {
    clearTimeout(timer);
    clearTimeout(drain);
    limit.signal?.removeEventListener("abort", abort);
  }
}

function spawnFailure(error: unknown): PythonVerification {
  if ((error as { code?: unknown } | null)?.code === "ENOENT")
    return unverified("docker-missing", "the docker CLI was not found on PATH; install Docker and provision the verifier image to verify generated Python");
  return unverified("docker-error", `could not run docker: ${error instanceof Error ? error.message : String(error)}`);
}

function dockerFailure(step: string, outcome: Outcome, image: string, commandMs: number): PythonVerification {
  if (outcome.ending === "timeout") return unverified("daemon-unavailable", `${step} did not finish within ${seconds(commandMs)}`);
  if (outcome.ending) return unverified("docker-error", `${step} wrote unexpectedly long output`);
  const text = (outcome.stderr || outcome.stdout).trim();
  if (DAEMON_DOWN.test(text))
    return unverified("daemon-unavailable", `the Docker daemon is unavailable (start Docker or set DOCKER_HOST): ${text}`);
  if (IMAGE_MISSING.test(text))
    return unverified("image-missing", `the verifier image is not present locally and is never pulled; provision it with \`docker pull --platform linux/arm64 ${image}\`: ${text}`);
  return unverified("docker-error", `${step} failed (exit ${outcome.code}): ${text}`);
}

const owner = () => `${hostname()}:${process.pid}`;

/** Whether a container labelled `label` belongs to a process on this host that is gone. */
function ownerGone(label: string): boolean {
  const at = label.lastIndexOf(":"), pid = Number(label.slice(at + 1));
  if (at < 0 || label.slice(0, at) !== hostname() || !Number.isInteger(pid) || pid <= 0 || pid === process.pid) return false;
  try { process.kill(pid, 0); return false; } catch (error) { return (error as { code?: unknown }).code === "ESRCH"; }
}

function createArguments(name: string, image: string, runMs: number): string[] {
  const { memory, pids, cpus, tmp } = PYTHON_VERIFIER_LIMITS;
  return ["create", "--pull=never", "--platform", "linux/arm64", "--name", name, "--label", `${PYTHON_VERIFIER_OWNER_LABEL}=${owner()}`,
    "--interactive", "--network", "none", "--ipc", "none", "--read-only", "--tmpfs", `/tmp:rw,noexec,nosuid,nodev,size=${tmp}`,
    "--user", "65534:65534", "--cap-drop", "ALL",
    "--security-opt", "no-new-privileges", "--memory", memory, "--memory-swap", memory,
    "--pids-limit", String(pids), "--cpus", String(cpus), "--log-driver", "none",
    // The in-container deadline only matters if this process dies mid-run.
    image, "timeout", "-s", "KILL", String(Math.ceil(runMs / 1000) + 5), "python3", "-I", "-B", "-"];
}

interface ContainerState { Status?: string; ExitCode: number; OOMKilled?: boolean; Error?: string }

function parseState(text: string): ContainerState | undefined {
  try {
    const state = JSON.parse(text) as ContainerState | null;
    return state && typeof state === "object" && typeof state.ExitCode === "number" ? state : undefined;
  } catch { return undefined; }
}

export function createPythonVerifier(options: PythonVerifierOptions = {}): VerifyPython {
  const image = options.image ?? PYTHON_VERIFIER_IMAGE;
  const spawn = options.spawn ?? spawnDocker;
  const runMs = options.timeouts?.runMs ?? PYTHON_VERIFIER_LIMITS.runMs;
  const commandMs = options.timeouts?.commandMs ?? PYTHON_VERIFIER_LIMITS.commandMs;
  const env: Record<string, string> = { PATH: process.env.PATH ?? "" };
  if (options.dockerHost) env.DOCKER_HOST = options.dockerHost;
  const docker = (args: string[], extra: { stdin?: Uint8Array; signal?: AbortSignal; timeoutMs?: number } = {}) =>
    run(spawn, args, env, { timeoutMs: commandMs, outputBytes: PYTHON_VERIFIER_LIMITS.outputBytes, ...extra });

  /** Creates, runs and inspects the container; `created.mayExist` tells the caller whether to remove it. */
  async function execute(name: string, source: string, signal: AbortSignal | undefined, created: { mayExist: boolean }): Promise<PythonVerification> {
    let outcome: Outcome;
    created.mayExist = true;
    try { outcome = await docker(createArguments(name, image, runMs)); }
    catch (error) { created.mayExist = false; return spawnFailure(error); }
    if (outcome.ending || outcome.code !== 0) {
      const failure = dockerFailure("docker create", outcome, image, commandMs);
      // A refused connection or a missing image means the daemon created nothing.
      if (!outcome.ending && failure.status === "unverified" && ["daemon-unavailable", "image-missing"].includes(failure.reason))
        created.mayExist = false;
      return failure;
    }
    if (signal?.aborted) return unverified("cancelled", "cancelled before the program started");

    let started: Outcome;
    try {
      started = await docker(["start", "--attach", "--interactive", name],
        { stdin: new TextEncoder().encode(source), timeoutMs: runMs, signal });
    } catch (error) { return spawnFailure(error); }
    if (started.ending === "cancelled" || signal?.aborted) return unverified("cancelled", "cancelled while the program ran");
    if (started.ending === "timeout") return unverified("timeout", `the program did not finish within ${seconds(runMs)}`);
    if (started.ending === "overflow")
      return unverified("output-overflow", `the program wrote more than ${PYTHON_VERIFIER_LIMITS.outputBytes / 1024} KiB of output`);

    try { outcome = await docker(["inspect", "--type", "container", "--format", "{{json .State}}", name]); }
    catch (error) { return spawnFailure(error); }
    if (outcome.ending || outcome.code !== 0) return dockerFailure("docker inspect", outcome, image, commandMs);
    const state = parseState(outcome.stdout);
    if (!state) return unverified("docker-error", `docker inspect returned no container state: ${outcome.stdout}`);
    if (state.OOMKilled || state.ExitCode === 137)
      return unverified("oom", `the program was killed (exit ${state.ExitCode}${state.OOMKilled ? ", out of memory" : ""}); memory is limited to ${PYTHON_VERIFIER_LIMITS.memory}`);
    if (state.Status !== "exited" || state.Error)
      return unverified("docker-error", `the container did not run to completion (${state.Status}${state.Error ? `: ${state.Error}` : ""}) ${started.stderr}`);
    if (state.ExitCode === 0) return { status: "verified" };
    return { status: "failed", exitCode: state.ExitCode, error: (started.stderr || started.stdout).slice(0, ERROR_CHARS) };
  }

  /** Force-removes the container; returns a problem when removal is not confirmed. */
  async function remove(name: string): Promise<string | undefined> {
    let outcome: Outcome;
    try { outcome = await docker(["rm", "--force", name]); }
    catch (error) { return `docker rm --force ${name} could not run: ${error instanceof Error ? error.message : String(error)}`; }
    if (!outcome.ending && (outcome.code === 0 || /no such container/i.test(outcome.stderr))) return undefined;
    return outcome.ending ? `docker rm --force ${name} did not finish within ${seconds(commandMs)}`
      : `docker rm --force ${name} failed: ${(outcome.stderr || outcome.stdout).trim()}`;
  }

  /** Removes containers left by verifier processes on this host that are gone.
   * Best effort: a failed sweep is retried at the next verification. */
  let swept = false;
  async function sweep(): Promise<void> {
    try {
      const listed = await docker(["ps", "--all", "--filter", `label=${PYTHON_VERIFIER_OWNER_LABEL}`,
        "--format", `{{.ID}} {{.Label "${PYTHON_VERIFIER_OWNER_LABEL}"}}`]);
      if (listed.ending || listed.code !== 0) return;
      const stale = listed.stdout.split("\n").flatMap(line => {
        const [id, label] = line.trim().split(" ");
        return id && label && ownerGone(label) ? [id] : [];
      });
      if (stale.length) {
        const removed = await docker(["rm", "--force", ...stale]);
        if (removed.ending || removed.code !== 0) return;
      }
      swept = true;
    } catch { /* no docker CLI: the verification reports it */ }
  }

  return async (source, signal) => {
    if (!PINNED_IMAGE.test(image))
      return unverified("image-unpinned", `no digest-pinned verifier image is configured (${JSON.stringify(image)}); provision one as the app README's Dataset jobs section describes`);
    if (signal?.aborted) return unverified("cancelled", "cancelled before the container was created");
    if (!swept) await sweep();
    const name = `mlx-bun-python-verify-${crypto.randomUUID()}`;
    const created = { mayExist: false };
    let result: PythonVerification = unverified("docker-error", "verification did not complete");
    try {
      result = await execute(name, source, signal, created);
    } finally {
      if (created.mayExist) {
        const problem = await remove(name);
        if (problem) result = unverified("cleanup-uncertain", `${problem}; the container may still exist (outcome before removal: ${result.status})`);
      }
    }
    return result;
  };
}

/** The production verifier; DOCKER_HOST, when set, selects the daemon. */
export const verifyPython: VerifyPython = createPythonVerifier({ dockerHost: process.env.DOCKER_HOST });
