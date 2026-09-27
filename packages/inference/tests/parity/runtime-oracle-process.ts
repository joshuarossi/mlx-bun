import { join } from "node:path";

const KEYS = ["MLX_BUN_PARITY_PLAN", "MLX_BUN_PARITY_REFERENCE", "MLX_BUN_PARITY_TIMEOUT_MS", "MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG"] as const;
export const JOIN_TIMEOUT_MS = 5_000;
export const TEST_OVERHEAD_MS = JOIN_TIMEOUT_MS + 30_000;
// Leave room for kill/join before the test runner's own deadline, without timer overflow.
const MAX_TIMEOUT = 2_147_483_647 - TEST_OVERHEAD_MS;

/** Test-only opt-in: even a lone optional setting must not silently skip parity. */
export function parityInputs(env: Record<string, string | undefined>) {
  if (KEYS.every(key => env[key] === undefined)) return null;
  for (const key of KEYS.slice(0, 2)) {
    if (!env[key]?.trim()) throw new Error(`Runtime parity requires nonblank MLX_BUN_PARITY_PLAN and MLX_BUN_PARITY_REFERENCE; missing or blank ${key}`);
  }
  const timeoutMs = Number(env.MLX_BUN_PARITY_TIMEOUT_MS ?? 600_000);
  if (!Number.isFinite(timeoutMs) || timeoutMs <= 0 || timeoutMs > MAX_TIMEOUT)
    throw new Error(`MLX_BUN_PARITY_TIMEOUT_MS must be finite, positive and at most ${MAX_TIMEOUT}`);
  const legacy = env.MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG;
  if (legacy !== undefined && legacy !== "0" && legacy !== "1")
    throw new Error("MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG must be 0 or 1 when provided");
  return { planPath: env.MLX_BUN_PARITY_PLAN!, referencePath: env.MLX_BUN_PARITY_REFERENCE!, timeoutMs, allowLegacy: legacy === "1" };
}

async function bounded<T>(promise: Promise<T>, milliseconds: number, label: string): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([promise, new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error(`${label} timed out after ${milliseconds}ms`)), milliseconds);
    })]);
  } finally { clearTimeout(timer); }
}

/** The emitter is a single native child. Keep its logs and always bound kill/join. */
export async function runParityWorker(command: string[], directory: string, deadline: number): Promise<void> {
  const stdout = Bun.file(join(directory, "worker.stdout"));
  const stderr = Bun.file(join(directory, "worker.stderr"));
  let worker: ReturnType<typeof Bun.spawn> | undefined;
  let failure: unknown;
  try {
    const remaining = deadline - Date.now();
    if (remaining <= 0) throw new Error("Runtime parity deadline expired during input preparation; worker was not started");
    worker = Bun.spawn(command, { stdin: "ignore", stdout, stderr });
    const code = await bounded(worker.exited, remaining, "Runtime parity worker");
    if (code !== 0) throw new Error(`Runtime parity worker exited ${code} (signal ${worker.signalCode ?? "none"})`);
  } catch (error) {
    failure = error;
  } finally {
    if (worker) {
      try {
        if (worker.exitCode === null && worker.signalCode === null) worker.kill("SIGKILL");
      } catch (error) {
        // Exiting between the liveness check and kill is harmless; still join below.
        if ((error as NodeJS.ErrnoException).code !== "ESRCH")
          failure = new AggregateError([failure, error], "Runtime parity worker cleanup failed");
      }
      try { await bounded(worker.exited, JOIN_TIMEOUT_MS, "Runtime parity worker kill/join"); }
      catch (error) { failure = new AggregateError([failure, error], "Runtime parity worker cleanup failed"); }
    }
  }
  if (failure) {
    for (const [name, file] of [["stdout", stdout], ["stderr", stderr]] as const)
      if (await file.exists()) console.error(`Runtime parity worker ${name}:\n${await file.text()}`);
    throw failure;
  }
}
