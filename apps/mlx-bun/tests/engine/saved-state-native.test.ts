import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import type { RunningApp } from "../../src/cli/serve";

// Opt-in: MLX_BUN_TEST_NATIVE=1 and MLX_BUN_APP_TEST_MODEL naming a cached chat
// snapshot. Saved prompt/KV state is on by default: a conversation's first turn
// is written under MLX_BUN_HOME/kv, and after the server is stopped and started
// again the follow-up turn reports the prior conversation as cached_tokens.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

test.skipIf(!native || !modelDir)("saved state defaults on under MLX_BUN_HOME/kv and a restarted server resumes the conversation from it", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { parseCommand } = await import("../../src/cli/args");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const root = mkdtempSync(join(tmpdir(), "mlx-saved-state-"));
  const restore = configureRuntime({ MLX_BUN_HOME: join(root, "home") });
  const serve = () => {
    const options = parseServeOptions(parseCommand("serve", ["--port", "0", "--max-tokens", "24", "--no-open"]));
    expect(options.cache.ssdCacheDir).toBe(join(root, "home", "kv"));
    mkdirSync(join(root, "project"), { recursive: true });
    options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    return startModelServer(model, options);
  };
  const chat = async (app: RunningApp, messages: { role: string; content: string }[]) => {
    const response = await fetch(`http://127.0.0.1:${app.port}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ model: model.repoId, max_tokens: 24, temperature: 0, messages }) });
    expect(response.status).toBe(200);
    return await response.json() as { choices: { message: { content: string } }[]; usage: { prompt_tokens: number; prompt_tokens_details: { cached_tokens: number } } };
  };
  const story = "The lighthouse keeper logged the weather every hour: fog at midnight, drizzle by two, a gale at four, and clear skies by dawn. ".repeat(12);
  const first = [{ role: "user", content: `${story}\nIn one sentence, what was the weather at four?` }];
  let app: RunningApp | undefined;
  try {
    app = await serve();
    const one = await chat(app, first);
    expect(one.usage.prompt_tokens_details.cached_tokens).toBe(0);
    const followUp = [...first, { role: "assistant", content: one.choices[0]!.message.content }, { role: "user", content: "And by dawn?" }];
    await app.close(); app = undefined;
    // Nothing in this process's RAM: the second server can only resume from disk.
    expect(existsSync(join(root, "home", "kv"))).toBe(true);
    expect(readdirSync(join(root, "home", "kv")).length).toBeGreaterThan(0);
    app = await serve();
    const two = await chat(app, followUp);
    expect(two.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(one.usage.prompt_tokens - 1);
    console.log(`turn 1: prompt ${one.usage.prompt_tokens}; after restart, follow-up prompt ${two.usage.prompt_tokens}, cached ${two.usage.prompt_tokens_details.cached_tokens}`);
  } finally {
    await app?.close();
    restore();
    rmSync(root, { recursive: true, force: true });
  }
}, 10 * 60_000);
