import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// Opt-in with real weights: the premise of in-process model residency. A model
// loaded, served and closed returns MLX's active and cache memory to where they
// were, however many times it is repeated, so one process can swap models
// without a worker per model. MLX_BUN_TEST_NATIVE=1 and MLX_BUN_APP_TEST_MODEL
// naming a cached chat snapshot; MLX_BUN_APP_TEST_CYCLES (default 5) repeats it.
// The server runs in this process against temporary storage; nothing is downloaded.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;
const cycles = Number(process.env.MLX_BUN_APP_TEST_CYCLES ?? 5);
const MB = 2 ** 20;

test.skipIf(!native || !modelDir)("closing a served model returns MLX active and cache memory to baseline, cycle after cycle", async () => {
  const { createServer, loadContext } = await import("../../src/cli/server-entry");
  const { activeMemory, cacheMemory, clearCache } = await import("@mlx-bun/mlx/ffi");
  const root = mkdtempSync(join(tmpdir(), "mlx-unload-"));
  const paths = {
    storagePaths: { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") },
    memoryPaths: { vault: join(root, "vault"), skills: join(root, "skills") },
    chatPaths: { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") },
  };
  const baseline = { active: activeMemory(), cache: cacheMemory() };
  const rows: string[] = [`baseline active ${(baseline.active / MB).toFixed(0)} MB, cache ${(baseline.cache / MB).toFixed(0)} MB`];
  try {
    for (let cycle = 1; cycle <= cycles; cycle++) {
      const context = await loadContext(modelDir!, "unload-test");
      const server = await createServer(context, 0, { hostname: "127.0.0.1", capacity: 2, cache: { promptCacheBytes: 0.125 * 2 ** 30 }, ownership: "owned", ...paths });
      const response = await fetch(`http://127.0.0.1:${server.port}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ model: "unload-test", max_tokens: 24, temperature: 0, messages: [{ role: "user", content: "Say hello in one sentence." }] }) });
      expect(response.status).toBe(200);
      await response.text();
      const served = activeMemory();
      expect((await server.close()).stopped).toBe(true);
      clearCache();
      const after = { active: activeMemory(), cache: cacheMemory() };
      rows.push(`cycle ${cycle}: served active ${(served / MB).toFixed(0)} MB; after close active ${(after.active / MB).toFixed(0)} MB, cache ${(after.cache / MB).toFixed(0)} MB`);
      // The weights were held while serving, and none of them outlive the close.
      expect(served).toBeGreaterThan(baseline.active + 50 * MB);
      expect(after.active).toBeLessThanOrEqual(baseline.active + 8 * MB);
      expect(after.cache).toBeLessThanOrEqual(baseline.cache + 8 * MB);
    }
  } finally {
    rmSync(root, { recursive: true, force: true });
    console.log(rows.join("\n"));
  }
}, 15 * 60_000);
