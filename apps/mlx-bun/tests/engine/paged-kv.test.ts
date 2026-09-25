// Opt-in with real weights: `--paged-kv` on a cached Gemma4 snapshot named by
// MLX_BUN_COMPILED_GEMMA_E4B serves completions through the paged path, and
// on a non-Gemma4 model (MLX_BUN_APP_TEST_MODEL) the request answers the
// typed capability error instead of a hidden serial fallback.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

const gemma = process.env.MLX_BUN_COMPILED_GEMMA_E4B;
const other = process.env.MLX_BUN_APP_TEST_MODEL;

async function serveWithPaging(root: string, snapshot: string) {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(snapshot, "test-model");
  if (!model) throw new Error(`${snapshot} has no loadable checkpoint`);
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "16", "prompt-cache": "0.125", "no-open": true, thinking: "off",
    "paged-kv": true, "paged-kv-block-size": "256" }, positionals: [] });
  options.readOnly = true;
  options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  return startModelServer(model, options);
}
const chat = (app: RunningApp) => fetch(new URL("/v1/chat/completions", `http://127.0.0.1:${app.port}`), { method: "POST",
  headers: { "content-type": "application/json" }, body: JSON.stringify({ messages: [{ role: "user", content: "Say hello." }], max_tokens: 16, temperature: 0 }) });

test.skipIf(!gemma)("paged KV serves a Gemma4 completion", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-paged-")); mkdirSync(join(root, "project"));
  let app: RunningApp | undefined;
  try {
    app = await serveWithPaging(root, gemma!);
    const response = await chat(app);
    expect(response.status).toBe(200);
    const body = await response.json();
    expect(body.usage.completion_tokens).toBeGreaterThan(0);
  } finally { try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); } }
}, 300_000);

test.skipIf(!other)("paged KV on a non-Gemma4 model answers the typed capability error", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-paged-")); mkdirSync(join(root, "project"));
  let app: RunningApp | undefined;
  try {
    app = await serveWithPaging(root, other!);
    const response = await chat(app);
    expect(response.status).toBe(501);
    const body = await response.json();
    expect(body.error).toMatchObject({ type: "not_implemented", code: "unsupported_execution" });
    expect(body.error.reasons).toContain("paged-kv-requires-serial");
  } finally { try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); } }
}, 300_000);
