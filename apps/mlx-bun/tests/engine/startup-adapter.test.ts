// Opt-in with real weights: a small adapter produced by the app's fine-tune
// producer is mounted at startup with `--adapter`, listed on /v1/adapters, and
// used as the default for requests without an adapter field; a bad directory
// fails startup.
import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

test.skipIf(!modelDir)("a startup adapter is mounted before serving, defaults requests, and a bad directory fails startup", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-startup-adapter-")), data = join(root, "data"), adapter = join(root, "adapters", "cli-lora");
  mkdirSync(data);
  writeFileSync(join(data, "train.jsonl"), Array.from({ length: 4 }, (_, i) => JSON.stringify({ text: `Example ${i}: the quick brown fox jumps over the lazy dog.` }) + "\n").join(""));
  let app: RunningApp | undefined;
  try {
    // The same producer the fine-tune job runs, in-process: it loads and releases its own model.
    const { createFinetuneRunner } = await import("../../src/finetune/job");
    const steps: number[] = [];
    await createFinetuneRunner()(event => { if (event.type === "metric" && event.kind === "train") steps.push(event.step); },
      { model_dir: modelDir, data_dir: data, adapter_path: adapter, method: "sft", iters: 3, max_seq_length: 128, steps_per_report: 1 });
    expect(steps).toEqual([1, 2, 3]);
    expect(existsSync(join(adapter, "adapters.safetensors"))).toBe(true);
    const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir!, "test-model");
    if (!model) throw new Error("Model path has no loadable checkpoint");
    const options = parseServeOptions({ values: { port: "0", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true, thinking: "off",
      adapter: `${adapter}/` }, positionals: [] });
    options.readOnly = true;
    options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    mkdirSync(options.chatPaths.cwd!);
    app = await startModelServer(model, options);
    const base = new URL(`http://127.0.0.1:${app.port}`);
    const listed = await (await fetch(new URL("/v1/adapters", base))).json();
    expect(listed.adapters).toHaveLength(1);
    expect(listed.adapters[0]).toMatchObject({ id: "cli-lora", path: adapter });
    expect(listed.adapters[0].mounted_layers).toBeGreaterThan(0);
    const chat = async (body: Record<string, unknown>) => fetch(new URL("/v1/chat/completions", base), { method: "POST",
      headers: { "content-type": "application/json" }, body: JSON.stringify({ messages: [{ role: "user", content: "Say hello." }], max_tokens: 8, temperature: 0, ...body }) });
    for (const body of [{}, { adapter: "none" }, { adapter: "cli-lora" }]) {
      const response = await chat(body);
      expect(response.status).toBe(200);
      expect((await response.json()).choices).toHaveLength(1);
    }
    await app.close(); app = undefined;
    await expect(startModelServer(model, { ...options, adapterDir: join(root, "missing-adapter") })).rejects.toThrow(/^adapter mount failed: /);
  } finally {
    try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 300_000);
