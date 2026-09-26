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
