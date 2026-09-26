import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { RunningApp } from "../../src/cli/serve";

// Opt-in: `--isolate --model-pool` against two cached models (MLX_BUN_APP_TEST_MODEL
// and MLX_BUN_APP_TEST_BF16_MODEL, e.g. the MiniCPM checkpoints the README names)
// with MLX_BUN_TEST_NATIVE=1. Each worker loads its model natively; this process
// never does. The second model is resolved by its exact id through the registry
// hook, so no download or scan happens. A supplied invalid model path or a
// missing native runtime must fail rather than skip.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const firstDir = process.env.MLX_BUN_APP_TEST_MODEL, secondDir = process.env.MLX_BUN_APP_TEST_BF16_MODEL;

async function until(check: () => Promise<boolean>, what: string, timeoutMs: number) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(100); }
}
const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };

interface Report { isolated: boolean; state: string; pid: number | null; socket: string | null; model: string;
  pool: { cap: number; default: string; resident: { id: string; pid: number | null; state: string; socket: string }[]; loading: string[] } }

test.skipIf(!native || !firstDir || !secondDir)("--isolate --model-pool 2 keeps two real models resident, routes each exact id to its own worker, evicts at cap 1 and respawns on switch-back, then closes every worker", async () => {
  const { parseServeOptions } = await import("../../src/cli/serve");
  const { startIsolatedServer } = await import("../../src/cli/serve-isolated");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const first = await scanSnapshot(firstDir!, "test-model"), second = await scanSnapshot(secondDir!, "test-model-bf16");
  if (!first || !second) throw new Error("A model path has no loadable checkpoint");
  const registry = () => ({ listCanonical: () => [first, second] as ModelRecord[], close() {} });
  const root = mkdtempSync(join(tmpdir(), "mlx-pool-real-"));
  mkdirSync(join(root, "project"));
  const serve = async (cap: number) => {
    const options = parseServeOptions({ values: { port: "0", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true, isolate: true, "model-pool": String(cap) }, positionals: [] });
    options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    options.storagePaths = { jobsDb: join(root, `jobs-${cap}.sqlite`), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    return startIsolatedServer(first, options, { createRegistry: registry });
  };
  const completion = async (base: string, model: string) => {
    const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ model, stream: false, max_tokens: 8, temperature: 0, messages: [{ role: "user", content: "Say hi." }] }) });
    expect(response.status).toBe(200);
    const body = await response.json() as { model: string; choices: { message: { content: string } }[] };
    expect(body.model).toBe(model);
    return body.choices[0]!.message.content;
  };
  const pids: number[] = [];
  let socketDir = "";
  let app: RunningApp | undefined;
  try {
    // Cap 2: both models resident, each answering under its own id.
    app = await serve(2);
    const base = `http://127.0.0.1:${app.port}`;
    const engine = async () => await (await fetch(`${base}/engine`)).json() as Report;
    const one = await engine();
    expect(one).toMatchObject({ isolated: true, state: "ready", model: first.repoId, pool: { cap: 2, default: first.repoId, loading: [] } });
    socketDir = dirname(one.socket!);
    pids.push(one.pid!);
    expect((await completion(base, first.repoId)).trim().length).toBeGreaterThan(0);
    expect((await completion(base, second.repoId)).trim().length).toBeGreaterThan(0);
    const two = await engine();
    expect(two.pool.resident.map(worker => worker.id)).toEqual([first.repoId, second.repoId]);
    expect(two.pool.resident.every(worker => worker.state === "ready" && existsSync(worker.socket) && dirname(worker.socket) === socketDir)).toBe(true);
    pids.push(two.pool.resident[1]!.pid!);
    expect(new Set(pids).size).toBe(2);
    const listing = await (await fetch(`${base}/v1/models`)).json() as { data: { id: string; resident?: boolean }[] };
    expect(listing.data.filter(row => row.resident).map(row => row.id).sort()).toEqual([first.repoId, second.repoId].sort());
    await app.close();
    app = undefined;
    for (const pid of pids) expect(alive(pid)).toBe(false);
    expect(existsSync(socketDir)).toBe(false);
    // Cap 1: the second id evicts the default (drained, cache demoted, stopped); the default id brings it back and evicts the second.
    app = await serve(1);
    const base1 = `http://127.0.0.1:${app.port}`;
    const engine1 = async () => await (await fetch(`${base1}/engine`)).json() as Report;
    const start = await engine1();
    pids.push(start.pid!);
    socketDir = dirname(start.socket!);
    expect((await completion(base1, second.repoId)).trim().length).toBeGreaterThan(0);
    const switched = await engine1();
    expect([switched.state, switched.pid, switched.pool.resident.map(worker => worker.id)]).toEqual(["evicted", null, [second.repoId]]);
    pids.push(switched.pool.resident[0]!.pid!);
    await until(async () => !alive(start.pid!), "the evicted default worker to exit", 60_000);
    expect((await completion(base1, first.repoId)).trim().length).toBeGreaterThan(0);
    const back = await engine1();
    expect([back.state, back.pool.resident.map(worker => worker.id)]).toEqual(["ready", [first.repoId]]);
    expect(back.pid).not.toBe(start.pid);
    pids.push(back.pid!);
  } finally {
    await app?.close();
    rmSync(root, { recursive: true, force: true });
  }
  for (const pid of pids) expect(alive(pid)).toBe(false);
  expect(existsSync(socketDir)).toBe(false);
}, 30 * 60_000);
