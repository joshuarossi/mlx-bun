import { expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { TEST_OVERHEAD_MS, parityInputs } from "./runtime-oracle-process";

const helper = resolve(import.meta.dir, "runtime-oracle-process.ts");
const suite = resolve(import.meta.dir, "runtime-oracle.test.ts");
const environment = () => Object.fromEntries(Object.entries(process.env)
  .filter(([key]) => !key.startsWith("MLX_BUN_PARITY_")));
const full = { MLX_BUN_PARITY_PLAN: "/plan", MLX_BUN_PARITY_REFERENCE: "/reference" };

test("runtime parity skips only a wholly absent opt-in and rejects invalid deadlines before launch", () => {
  expect(parityInputs({})).toBeNull();
  expect(parityInputs(full)).toMatchObject({ timeoutMs: 600_000, allowLegacy: false });
  for (const env of [{ MLX_BUN_PARITY_PLAN: "/plan" }, { MLX_BUN_PARITY_REFERENCE: "/reference" },
    { MLX_BUN_PARITY_TIMEOUT_MS: "10" }, { MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG: "1" },
    { ...full, MLX_BUN_PARITY_REFERENCE: " " }])
    expect(() => parityInputs(env)).toThrow("requires nonblank");
  for (const timeout of ["", " ", "NaN", "Infinity", "0", "-1", "2147483648"])
    expect(() => parityInputs({ ...full, MLX_BUN_PARITY_TIMEOUT_MS: timeout })).toThrow("must be finite, positive");
  const maximum = 2_147_483_647 - TEST_OVERHEAD_MS;
  expect(parityInputs({ ...full, MLX_BUN_PARITY_TIMEOUT_MS: String(maximum) })!.timeoutMs + TEST_OVERHEAD_MS).toBe(2_147_483_647);
  expect(() => parityInputs({ ...full, MLX_BUN_PARITY_TIMEOUT_MS: String(maximum + 1) })).toThrow("must be finite, positive");
  expect(() => parityInputs({ ...full, MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG: " " })).toThrow("must be 0 or 1");
});

test("the actual test entry rejects partial configuration without loading native libraries", () => {
  for (const patch of [{ MLX_BUN_PARITY_PLAN: "/unused" },
    { ...full, MLX_BUN_PARITY_REFERENCE: "" }, { ...full, MLX_BUN_PARITY_TIMEOUT_MS: "NaN" }]) {
    const child = spawnSync(process.execPath, ["test", suite, "--test-name-pattern", "local model matches"], {
      env: { ...environment(), ...patch, MLX_BUN_LIBMLXC: "/native-must-not-load" },
      encoding: "utf8", timeout: 5_000, killSignal: "SIGKILL",
    });
    expect(child.error).toBeUndefined();
    expect(child.status).not.toBe(0);
    expect(child.stderr).toContain("MLX_BUN_PARITY_");
    expect(child.stderr).not.toContain("native-must-not-load");
  }
});

function workerCase(source: string, timeoutMs: number, preflightMs = 0) {
  const directory = mkdtempSync(join(tmpdir(), "runtime-parity-process-"));
  const worker = join(directory, "worker.ts"), pidPath = join(directory, "pid");
  writeFileSync(worker, `await Bun.write(${JSON.stringify(pidPath)}, String(process.pid));\n${source}`);
  // Run the actual owner in a fresh CPU process: a leaked 60s timer prevents prompt exit.
  const script = `import { runParityWorker } from ${JSON.stringify(helper)};
    const deadline = Date.now() + ${timeoutMs};
    ${preflightMs ? `await new Promise(resolve => setTimeout(resolve, ${preflightMs}));` : ""}
    await runParityWorker(${JSON.stringify([process.execPath, worker])}, ${JSON.stringify(directory)}, deadline);`;
  const child = spawnSync(process.execPath, ["--eval", script], {
    env: { ...environment(), MLX_BUN_LIBMLXC: "/native-must-not-load" },
    encoding: "utf8", timeout: 10_000, killSignal: "SIGKILL",
  });
  return { directory, pidPath, child };
}

function expectGone(pidPath: string) {
  const pid = Number(readFileSync(pidPath, "utf8"));
  expect(Number.isSafeInteger(pid) && pid > 0).toBe(true);
  let code: unknown;
  try { process.kill(pid, 0); } catch (error) { code = (error as NodeJS.ErrnoException).code; }
  expect(code).toBe("ESRCH");
}

test("worker excludes only opt-in controls without reloading dotenv or changing its parent environment", () => {
  const directory = mkdtempSync(join(tmpdir(), "runtime-parity-environment-"));
  const controls = { ...full, MLX_BUN_PARITY_TIMEOUT_MS: "60000", MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG: "1" };
  const numerical = { MLX_BUN_COMPILED_DECODE: "0", MLX_BUN_PREFILL_TAIL_SPLIT: "0",
    MLX_BUN_PARITY_FUTURE_RUNTIME_OPTION: "keep", MLX_BUN_LIBMLXC: "/native-must-not-load" };
  const keys = [...Object.keys(controls), ...Object.keys(numerical), "PARITY_DOTENV_ONLY"];
  const snapshot = `Object.fromEntries(${JSON.stringify(keys)}.filter(key => process.env[key] !== undefined)
    .map(key => [key, process.env[key]]))`;
  const worker = join(directory, "worker.ts"), pidPath = join(directory, "pid");
  writeFileSync(join(directory, ".env"), Object.keys(controls).map(key => `${key}=from-dotenv`).join("\n") +
    "\nPARITY_DOTENV_ONLY=must-not-load\n");
  writeFileSync(worker, `await Bun.write(${JSON.stringify(pidPath)}, String(process.pid));
    console.log(JSON.stringify(${snapshot}));`);
  const script = `import { runParityWorker } from ${JSON.stringify(helper)};
    const before = JSON.stringify(process.env);
    await runParityWorker(${JSON.stringify([process.execPath, "--no-env-file", worker])},
      ${JSON.stringify(directory)}, Date.now() + 5000);
    console.log(JSON.stringify({ unchanged: before === JSON.stringify(process.env), after: ${snapshot} }));`;
  try {
    // Prove this fixture is discoverable by Bun before checking the emitter's opt-out.
    const dotenv = spawnSync(process.execPath, [worker], {
      cwd: directory, env: { ...environment(), ...numerical },
      encoding: "utf8", timeout: 5_000, killSignal: "SIGKILL",
    });
    expect(dotenv.error).toBeUndefined();
    expect(dotenv.status).toBe(0);
    const reloaded = JSON.parse(dotenv.stdout);
    for (const key of Object.keys(controls)) expect(reloaded[key]).toBe("from-dotenv");
    expect(reloaded.PARITY_DOTENV_ONLY).toBe("must-not-load");
    const child = spawnSync(process.execPath, ["--no-env-file", "--eval", script], {
      cwd: directory, env: { ...environment(), ...controls, ...numerical },
      encoding: "utf8", timeout: 10_000, killSignal: "SIGKILL",
    });
    expect(child.error).toBeUndefined();
    expect(child.status).toBe(0);
    const emitted = JSON.parse(readFileSync(join(directory, "worker.stdout"), "utf8"));
    for (const key of Object.keys(controls)) expect(emitted).not.toHaveProperty(key);
    expect(emitted).not.toHaveProperty("PARITY_DOTENV_ONLY");
    expect(emitted).toMatchObject(numerical);
    const parent = JSON.parse(child.stdout);
    expect(parent.after).toMatchObject({ ...controls, ...numerical });
    expect(parent.unchanged).toBe(true);
    expectGone(pidPath);
  } finally {
    try { process.kill(Number(readFileSync(pidPath, "utf8")), "SIGKILL"); } catch {}
    rmSync(directory, { recursive: true, force: true });
  }
}, 15_000);

test("successful worker joins and clears its long deadline timer", () => {
  const { directory, pidPath, child } = workerCase('console.log("done");', 60_000);
  try {
    expect(child.error).toBeUndefined();
    expect(child.status).toBe(0);
    expect(readFileSync(join(directory, "worker.stdout"), "utf8")).toContain("done");
    expectGone(pidPath);
  } finally { rmSync(directory, { recursive: true, force: true }); }
}, 15_000);

test("a failed worker is joined and prints both retained output streams", () => {
  const { directory, pidPath, child } = workerCase('console.log("out-seven"); console.error("err-seven"); process.exit(7);', 60_000);
  try {
    expect(child.error).toBeUndefined();
    expect(child.status).not.toBe(0);
    expect(child.stderr).toContain("exited 7");
    expect(child.stderr).toContain("out-seven");
    expect(child.stderr).toContain("err-seven");
    expectGone(pidPath);
  } finally { rmSync(directory, { recursive: true, force: true }); }
}, 15_000);

test("a deadline kills and joins a live worker, retaining diagnostics and clearing timers", () => {
  const { directory, pidPath, child } = workerCase('console.log("before-deadline"); process.on("SIGTERM", () => {}); setInterval(() => {}, 1000);', 500);
  try {
    expect(child.error).toBeUndefined();
    expect(child.status).not.toBe(0);
    expect(child.stderr).toContain("Runtime parity worker timed out after");
    expect(child.stderr).toContain("before-deadline");
    expectGone(pidPath);
  } finally {
    // Keep a failing test itself from leaving its synthetic worker behind.
    try { process.kill(Number(readFileSync(pidPath, "utf8")), "SIGKILL"); } catch {}
    rmSync(directory, { recursive: true, force: true });
  }
}, 15_000);

test("preflight consumes the same deadline and an exhausted budget never starts a worker", () => {
  const { directory, pidPath, child } = workerCase('throw new Error("must never execute");', 50, 100);
  try {
    expect(child.error).toBeUndefined();
    expect(child.status).not.toBe(0);
    expect(child.stderr).toContain("deadline expired during input preparation; worker was not started");
    expect(existsSync(pidPath)).toBe(false);
  } finally { rmSync(directory, { recursive: true, force: true }); }
}, 15_000);
