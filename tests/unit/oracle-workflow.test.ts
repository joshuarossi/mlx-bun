import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const repo = resolve(import.meta.dir, "../..");

describe("public oracle workflow", () => {
  test("isolated fixtures never fall back to checked-in goldens", () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-goldens-"));
    try {
      const result = Bun.spawnSync([process.execPath, "-e", `
        import { goldenPath, goldenOutDir } from './tests/support/goldens';
        console.log(JSON.stringify([goldenOutDir(), goldenPath('minicpm5-parity.json')]));
      `], { cwd: repo, env: { ...process.env, MLX_BUN_GOLDEN_DIR: dir } });
      expect(result.exitCode).toBe(0);
      expect(JSON.parse(result.stdout.toString())).toEqual([dir, `${dir}/minicpm5-parity.json`]);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });

  test("comparison without an oracle fails before model download or GPU work", () => {
    const result = Bun.spawnSync(["bash", "scripts/oracle/compare-minicpm5.sh"], {
      cwd: repo, env: { ...process.env, MLX_BUN_ORACLE_VENV: "" },
    });
    expect(result.exitCode).toBe(1);
    expect(result.stderr.toString()).toContain("setup.sh");
    expect(result.stdout.toString()).not.toContain("passed");
  });

  test("help works without Python, weights or a Metal runtime", () => {
    for (const script of ["setup.sh", "compare-minicpm5.sh"]) {
      const result = Bun.spawnSync(["bash", `scripts/oracle/${script}`, "--help"], { cwd: repo });
      expect(result.exitCode).toBe(0);
      expect(result.stdout.toString()).toContain("Usage:");
    }
  });
});
