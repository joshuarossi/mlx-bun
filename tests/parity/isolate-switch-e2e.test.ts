// GATED (spawns two real model engines through the real CLI):
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/isolate-switch-e2e.test.ts
//
// THE MULTI-MODEL SWITCH STORY, end to end (docs/reference/server-config.md P2 +
// Josh's scenario 2026-07-05): converse with model A → request model B
// (pool cap 1: B spawn-overlaps while A serves, then A drains, DEMOTES its
// prompt cache to the SSD tier, and exits) → switch back to A → continue
// the ORIGINAL conversation → `cached_tokens` proves the KV came back from
// disk instead of a re-prefill. "Feels like running both models at once."
// Also records spawn→ready and switch wall-clock as measured numbers.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { SNAPSHOT_MINICPM5, hfSnapshot } from "../support/paths";
import { startProxyServer, engineArgvForModel } from "../../src/serve/isolate";

const QWEN08 = hfSnapshot("models--mlx-community--Qwen3.5-0.8B-OptiQ-4bit");
const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const haveModels = existsSync(`${SNAPSHOT_MINICPM5}/config.json`) && existsSync(`${QWEN08}/config.json`);
const CLI = new URL("../../src/cli.ts", import.meta.url).pathname;

describe.skipIf(!optIn || !haveModels)("multi-model switch E2E (cpm5 ⇄ qwen0.8b, pool 1, SSD state)", () => {
  if (!optIn || !haveModels) return; // describe bodies run under skipIf
  const ssdDir = mkdtempSync(join(tmpdir(), "mlxbun-switch-ssd-"));
  const sockFor = (id: string) => join(tmpdir(), `mlxbun-sw-${process.pid}-${id.slice(-24).replace(/[^a-zA-Z0-9.-]+/g, "_")}.sock`);
  const A = "cpm5-a";
  const B = "qwen-b";
  const resolve = (q: string) =>
    q === A ? { repoId: A, path: SNAPSHOT_MINICPM5 } :
    q === B ? { repoId: B, path: QWEN08 } : null;
  const selfArgv = [process.execPath, "run", CLI];
  const rawArgs = ["serve", SNAPSHOT_MINICPM5, "--no-open", "--ssd-cache", ssdDir];
  const started = startProxyServer({
    port: 0,
    engine: {
      argv: [...selfArgv, ...engineArgvForModel(rawArgs, sockFor(A), SNAPSHOT_MINICPM5)],
      socketPath: sockFor(A),
      readyTimeoutMs: 300_000,
    },
    pool: { rawArgs, selfArgv, poolMax: 1, resolve, defaultKey: A, socketFor: sockFor },
  });
  const base = `http://localhost:${started.server.port}`;
  afterAll(async () => {
    await started.close();
    rmSync(ssdDir, { recursive: true, force: true });
  });

  const chat = async (model: string, content: string, max = 24) => {
    const r = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ model, messages: [{ role: "user", content }], max_tokens: max }),
    });
    expect(r.status).toBe(200);
    return await r.json() as {
      model?: string;
      choices: Array<{ message: { content: string } }>;
      usage: { prompt_tokens: number; prompt_tokens_details?: { cached_tokens?: number } };
    };
  };
  const LONG = "Here is some shared context about a codebase we are working on together. " +
    "It uses TypeScript and Bun and MLX for GPU compute on Apple Silicon. ".repeat(4) +
    "Now answer briefly: what language is the codebase in?";

  test("converse on A → switch to B → back to A with cached_tokens from disk", async () => {
    // Turn 1 on model A (cold).
    const t1 = await chat(A, LONG);
    expect(t1.choices[0]!.message.content.length).toBeGreaterThan(0);
    expect(t1.usage.prompt_tokens_details?.cached_tokens ?? 0).toBe(0);

    // Switch to B (spawn-overlap; A drains + demotes to SSD + exits).
    const tSwitch = performance.now();
    const b1 = await chat(B, "Say hello in one word.", 8);
    const switchMs = performance.now() - tSwitch;
    expect(b1.choices[0]!.message.content.length).toBeGreaterThan(0);
    let resident: string[] = [];
    for (let i = 0; i < 40; i++) {
      resident = ((await (await fetch(`${base}/engine`)).json()) as { pool: { resident: string[] } }).pool.resident;
      if (resident.length === 1 && resident[0] === B) break;
      await new Promise((r) => setTimeout(r, 250));
    }
    expect(resident).toEqual([B]);

    // Switch BACK to A: fresh child, state restored from the SSD tier —
    // the same conversation prefix comes back as cached_tokens, no re-prefill.
    const tBack = performance.now();
    const t2 = await chat(A, LONG);
    const backMs = performance.now() - tBack;
    const cached = t2.usage.prompt_tokens_details?.cached_tokens ?? 0;
    console.log(`[switch-e2e] switch A→B ${switchMs.toFixed(0)}ms · back B→A ${backMs.toFixed(0)}ms · cached_tokens on return ${cached}/${t2.usage.prompt_tokens}`);
    expect(cached).toBeGreaterThan(0); // THE headline: KV survived the eviction
  }, 600_000);
});
