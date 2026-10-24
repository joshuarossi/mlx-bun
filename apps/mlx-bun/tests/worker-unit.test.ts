import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { parseCommand } from "../src/cli/args";
import { parseServeOptions } from "../src/cli/serve";
import { spawnWorkerUnit } from "../src/cli/worker-unit";

test("a restarting worker reserves its reload estimate until the replacement reports memory", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-worker-memory-"));
  const record = { repoId: "org/model", path: root, sizeBytes: 100 } as ModelRecord;
  const unit = await spawnWorkerUnit({
    options: parseServeOptions(parseCommand("serve", [])), startup: record, socketDir: root,
    entry: fileURLToPath(new URL("./fake-worker.ts", import.meta.url)),
    env: { FAKE_WORKER_MEMORY: JSON.stringify({ "*": [250, 50, 350, 1000] }) },
    restarts: { max: 1, windowMs: 60_000, delayMs: 500 }, publish() {}, notice() {}, log() {}, error() {},
  }, record, "primary", 500);
  const until = async (check: () => boolean) => {
    const end = Date.now() + 5000;
    while (!check()) { if (Date.now() > end) throw new Error("worker state did not change"); await Bun.sleep(5); }
  };
  try {
    expect(unit.bytes()).toBe(300);
    expect(unit.measured()).toBeDefined();
    process.kill(unit.supervisor.pid!, "SIGKILL");
    await until(() => unit.supervisor.state === "restarting");
    expect(unit.measured()).toBeUndefined();
    expect(unit.bytes()).toBe(500);
    await until(() => unit.supervisor.state === "ready");
    await unit.refresh?.();
    expect(unit.bytes()).toBe(300);
  } finally { await unit.close({ flush: true }); rmSync(root, { recursive: true, force: true }); }
});
