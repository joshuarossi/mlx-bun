import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

// Opt-in: `--isolate` against a cached model (MLX_BUN_APP_TEST_MODEL, e.g. the
// MiniCPM checkpoint the README names) with MLX_BUN_TEST_NATIVE=1. The worker
// loads the model natively; this process never does. A supplied invalid model
// path or a missing native runtime must fail rather than skip.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

async function until(check: () => Promise<boolean>, what: string, timeoutMs: number) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(100); }
}

test.skipIf(!native || !modelDir)("--isolate serves a real model through the worker, answers 502 while a killed worker respawns, then serves again and closes", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const root = mkdtempSync(join(tmpdir(), "mlx-isolate-real-"));
  const cwd = join(root, "project");
  mkdirSync(cwd);
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true, isolate: true }, positionals: [] });
  options.chatPaths = { cwd, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  let app: RunningApp | undefined, socket = "";
  try {
    app = await startModelServer(model, options);
    const base = `http://127.0.0.1:${app.port}`;
    const engine = async () => await (await fetch(`${base}/engine`)).json() as { isolated: boolean; state: string; pid: number | null; restarts: number; model: string; socket: string };
    const report = await engine();
    expect(report).toMatchObject({ isolated: true, state: "ready", restarts: 0, model: model.repoId });
    expect(report.pid).toBeGreaterThan(0);
    socket = report.socket;
    expect(existsSync(socket)).toBe(true);
    expect((await (await fetch(`${base}/health`)).json() as { engine: { state: string } }).engine.state).toBe("ready");
    // One streamed completion through the proxy; the content is what the worker produced.
    const completion = async () => {
      const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ model: model.repoId, stream: true, max_tokens: 8, temperature: 0, messages: [{ role: "user", content: "Say hi." }] }) });
      expect(response.status).toBe(200);
      const text = await response.text();
      expect(text.trim().endsWith("data: [DONE]")).toBe(true);
      expect(text).not.toContain("engine_unavailable");
      return text.split("\n\n").flatMap(frame => {
        if (!frame.startsWith("data: ") || frame === "data: [DONE]") return [];
        const chunk = JSON.parse(frame.slice(6)) as { choices: { delta: { content?: string } }[] };
        return [chunk.choices[0]?.delta.content ?? ""];
      }).join("");
    };
    const first = await completion();
    expect(first.trim().length).toBeGreaterThan(0);
    // Kill the worker: the next answer is a 502 while it is down, then a respawned worker serves the same greedy completion.
    process.kill(report.pid!, "SIGKILL");
    let down: Response | undefined;
    await until(async () => {
      const response = await fetch(`${base}/v1/models`);
      if (response.status === 502) { down = response; return true; }
      await response.arrayBuffer();
      return false;
    }, "the parent to notice the killed worker", 10_000);
    expect((await down!.json() as { error: { type: string } }).error.type).toBe("engine_unavailable");
    await until(async () => { const current = await engine(); return current.state === "ready" && current.pid !== report.pid; }, "the respawned worker", 5 * 60_000);
    expect((await engine()).restarts).toBe(1);
    expect(await completion()).toBe(first);
  } finally {
    await app?.close();
    rmSync(root, { recursive: true, force: true });
  }
  expect(existsSync(dirname(socket))).toBe(false);
}, 15 * 60_000);

// `--isolate` synthesis: this process keeps the pipeline, vault and SSE, and
// every stage call runs on the default worker's memory task model (e4b; with
// MLX_BUN_APP_TEST_MEMORY_ADAPTER its chunk adapter is linked read only and
// mounted), loaded in that worker by its first call: never on the served model
// (MLX_BUN_APP_TEST_MODEL, not e4b) and never in this process. Needs e4b in the
// Hugging Face cache (HF_HUB_CACHE; found, never downloaded) and a temporary
// HOME (the registry, memory database and adapter link live there). Residency
// is each process's phys_footprint (macOS `footprint`, which counts the Metal
// allocations). Claim limits: the vault holds articles only, so the calls
// exercise the wikify sweep on the base task model, not chunk-adapter
// activation (tests/engine/memory-native.test.ts covers the adapter); the
// cancellation aborts a call the worker has admitted (in_flight counts it
// before parsing and the lease), not necessarily one in native decoding.
const adapter = process.env.MLX_BUN_APP_TEST_MEMORY_ADAPTER;
test.skipIf(!native || !modelDir)("--isolate synthesis runs on the default worker's memory task model, not on the served model or in this process; a run cancelled while its call is admitted in the worker leaves the worker idle and serving; close stops the worker", async () => {
  const { readdirSync, realpathSync, statSync, symlinkSync, writeFileSync } = await import("node:fs");
  const { homedir } = await import("node:os");
  if (![realpathSync(tmpdir()), "/private/tmp"].some(dir => realpathSync(homedir()).startsWith(`${dir}/`))) throw new Error("run with a temporary HOME");
  if (adapter) {
    mkdirSync(join(homedir(), ".cache/mlx-bun/adapters"), { recursive: true });
    symlinkSync(adapter, join(homedir(), ".cache/mlx-bun/adapters/memory-chunk"));
  }
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const { MEMORY_TASK_MODEL, locateTaskModel } = await import("../../src/memory/model");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const snapshot = await locateTaskModel(MEMORY_TASK_MODEL);
  if (realpathSync(model.path) === realpathSync(snapshot)) throw new Error("MLX_BUN_APP_TEST_MODEL must not be the memory task model");
  const taskBytes = readdirSync(snapshot).filter(name => name.endsWith(".safetensors")).reduce((sum, name) => sum + statSync(realpathSync(join(snapshot, name))).size, 0);
  const footprint = async (pid: number) => {
    const child = Bun.spawn(["/usr/bin/footprint", "-f", "bytes", "--noCategories", "-p", String(pid)], { stdout: "pipe", stderr: "pipe" });
    const [text] = await Promise.all([new Response(child.stdout).text(), child.exited]);
    const bytes = /phys_footprint: (\d+) B/.exec(text)?.[1];
    if (!bytes) throw new Error(`footprint -p ${pid} reported no phys_footprint: ${text.slice(0, 200)}`);
    return Number(bytes);
  };
  const root = mkdtempSync(join(tmpdir(), "mlx-isolate-synthesis-"));
  const vault = join(root, "vault");
  mkdirSync(join(vault, "articles"), { recursive: true });
  writeFileSync(join(vault, "articles", "Alpha.md"), "# Alpha\n\nAlpha is a test article about lenses. See [[Beta]].\n");
  writeFileSync(join(vault, "articles", "Beta.md"), "# Beta\n\nBeta links to [[Alpha]].\n");
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true, isolate: true }, positionals: [] });
  options.chatPaths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault, skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  let app: RunningApp | undefined, socket = "", worker = 0;
  try {
    app = await startModelServer(model, options);
    const base = `http://127.0.0.1:${app.port}`;
    const report = await (await fetch(`${base}/engine`)).json() as { state: string; pid: number; socket: string };
    expect(report.state).toBe("ready");
    worker = report.pid; socket = report.socket;
    const health = async () => (await (await fetch(`${base}/health`)).json() as { engine: { state: string; pid: number; in_flight: number; leases: number } }).engine;
    // The served model's prompt-cache lookups, from the worker's /stats: every served completion moves them.
    const lookups = async () => { const { prompt_cache } = await (await fetch(`${base}/stats`)).json() as { prompt_cache: { hits: number; misses: number } };
      return prompt_cache.hits + prompt_cache.misses; };
    const served = async () => {
      const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ model: model.repoId, max_tokens: 4, temperature: 0, messages: [{ role: "user", content: "Say hi." }] }) });
      expect(response.status).toBe(200);
      await response.arrayBuffer();
    };
    const before = await lookups();
    await served();
    const afterServed = await lookups();
    expect(afterServed).toBeGreaterThan(before);
    const [workerBefore, parentBefore] = [await footprint(worker), await footprint(process.pid)];
    // Cancellation: the run is cancelled once the worker has admitted its first call (in_flight counts it before
    // parsing and the lease, so the call may not have reached native decoding); the worker aborts and joins
    // the call and goes idle.
    const cancel = new AbortController();
    const cancelled = fetch(`${base}/v1/memory/synthesize`, { signal: cancel.signal }).then(response => response.text()).catch((error: Error) => error.name);
    await until(async () => (await health()).in_flight > 0, "the first memory call in the worker", 60_000);
    cancel.abort();
    expect(await cancelled).toBe("AbortError");
    await until(async () => { const engine = await health(); return engine.in_flight === 0 && engine.leases === 0; }, "the worker to go idle", 5 * 60_000);
    expect(await health()).toMatchObject({ state: "ready", pid: worker });
    // A full run: every stage call runs on the worker's task model, none on the served model.
    const text = await (await fetch(`${base}/v1/memory/synthesize`)).text();
    expect(text).toContain('"type":"summary"');
    expect(text.trim().endsWith("data: [DONE]")).toBe(true);
    expect(text).not.toContain('"type":"error"');
    expect(text).toContain("wikify");
    expect(text).not.toContain("skipped (error");
    expect(await lookups()).toBe(afterServed);
    // e4b is resident in the worker, not in this process.
    expect(await footprint(worker) - workerBefore).toBeGreaterThan(0.8 * taskBytes);
    expect(await footprint(process.pid) - parentBefore).toBeLessThan(0.2 * taskBytes);
    // The served model still serves beside the resident task model.
    await served();
    expect(await health()).toMatchObject({ state: "ready", pid: worker, in_flight: 0, leases: 0 });
  } finally {
    await app?.close();
    rmSync(root, { recursive: true, force: true });
  }
  expect(existsSync(dirname(socket))).toBe(false);
  expect(() => process.kill(worker, 0)).toThrow();
}, 15 * 60_000);
