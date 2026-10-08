// Opt-in with real weights: model-free prompt-lookup drafting (`--draft-kind
// ngram`) through the serve composition on the cached model named by
// MLX_BUN_APP_TEST_MODEL: completions succeed, generate tokens, and report
// speculation telemetry; without a draft the field is absent.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

test.skipIf(!modelDir)("ngram drafting serves completions with speculation telemetry; no draft reports none", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-draft-flags-"));
  let app: RunningApp | undefined;
  try {
    const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir!, "test-model");
    if (!model) throw new Error("Model path has no loadable checkpoint");
    // A copy task: the answer repeats the prompt's own n-grams, so prompt lookup proposes them and the target verifies.
    const prompt = "Copy the following text exactly, word for word: the quick brown fox jumps over the lazy dog near the quiet river bank at dawn. Text: the quick brown fox jumps over the lazy dog near the quiet river bank at dawn.";
    const chat = async (base: URL) => {
      const response = await fetch(new URL("/v1/chat/completions", base), { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ messages: [{ role: "user", content: prompt }], max_tokens: 48, temperature: 0 }) });
      expect(response.status).toBe(200);
      return response.json();
    };
    const serveWith = async (values: Record<string, string | boolean>) => {
      const options = parseServeOptions({ values: { port: "0", "max-tokens": "48", "prompt-cache": "0.125", "no-open": true, thinking: "off", ...values }, positionals: [] });
      options.readOnly = true;
      options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
      options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
      return startModelServer(model, options);
    };
    mkdirSync(join(root, "project"));
    app = await serveWith({ "draft-kind": "ngram", "num-draft-tokens": "4" });
    const drafted = await chat(new URL(`http://127.0.0.1:${app.port}`));
    expect(drafted.choices).toHaveLength(1);
    expect(drafted.usage.completion_tokens).toBeGreaterThan(0);
    // Real speculative work: proposals were drafted, verified by target calls, and some accepted.
    expect(drafted.usage.speculation.drafted).toBeGreaterThan(0);
    expect(drafted.usage.speculation.targetCalls).toBeGreaterThan(0);
    expect(drafted.usage.speculation.accepted).toBeGreaterThan(0);
    expect(drafted.usage.speculation.targetCalls).toBeLessThan(drafted.usage.completion_tokens);
    await app.close(); app = undefined;
    app = await serveWith({});
    const plain = await chat(new URL(`http://127.0.0.1:${app.port}`));
    expect(plain.usage.completion_tokens).toBeGreaterThan(0);
    expect(plain.usage.speculation).toBeUndefined();
    // Greedy outputs agree: drafting is exact by verification.
    expect(plain.choices[0].message.content).toBe(drafted.choices[0].message.content);
  } finally {
    try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 300_000);
