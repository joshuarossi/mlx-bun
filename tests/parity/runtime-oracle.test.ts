// Compare actual same-version logits and live state. No stored goldens are
// rewritten, and the parent never loads MLX. Each child exits before the next.
import { expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { MLX_CORE_VERSION } from "../../src/native-pack";
import { hfSnapshot, ORACLE_PYTHON } from "../support/paths";

const root = resolve(import.meta.dir, "../..");
const enabled = process.env.MLX_BUN_TEST_RUNTIME_ORACLE === "1";
const models = [
  ["MiniCPM5", "models--mlx-community--MiniCPM5-1B-OptiQ-4bit"],
  ["Llama 3.2 1B", "models--mlx-community--Llama-3.2-1B-Instruct-4bit"],
  ["Gemma 4 e4b", "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"],
] as const;

for (const [name, repo] of models) {
  const model = hfSnapshot(repo);
  const available = enabled && existsSync(ORACLE_PYTHON) && existsSync(`${model}/config.json`);
  test.skipIf(!available)(`${name}: bundled MLX matches same-version logits, cache and continuation`, async () => {
    const dir = await mkdtemp(resolve(tmpdir(), "mlx-bun-runtime-oracle-"));
    const planPath = `${dir}/plan.json`;
    await Bun.write(planPath, JSON.stringify({ model, runtime: MLX_CORE_VERSION, contexts: [0, 64], lengths: [1, 8, 128], prefixChunk: 128 }));
    const env = { ...process.env };
    for (const key of Object.keys(env))
      if (/^(MLX_BUN_|MLX_RD_|MLX_MAX_|MLX_BFS_|MLX_METAL_)/.test(key)) delete env[key];
    Object.assign(env, { MLX_BUN_TEST_RUNTIME_ORACLE: "1", HF_HUB_OFFLINE: "1", MLX_BUN_COMPILED_DECODE: "0" });
    let passed = false;
    try {
      for (const [stack, command] of [
        ["bun", [process.execPath, `${root}/tests/support/runtime-oracle-worker.ts`]],
        ["reference", [ORACLE_PYTHON, `${root}/scripts/oracle/check-runtime.py`]],
      ] as const) {
        const child = Bun.spawn([...command, planPath, `${dir}/${stack}.json`], {
          cwd: root, env, stdout: Bun.file(`${dir}/${stack}.stdout`), stderr: Bun.file(`${dir}/${stack}.stderr`),
        });
        const timer = setTimeout(() => child.kill("SIGKILL"), 120_000);
        let code;
        try { code = await child.exited; } finally { clearTimeout(timer); }
        if (code !== 0) throw new Error(`${name} ${stack} exited ${code}; reports in ${dir}\n${await Bun.file(`${dir}/${stack}.stderr`).text()}`);
      }
      const ours = await Bun.file(`${dir}/bun.json`).json();
      const oracle = await Bun.file(`${dir}/reference.json`).json();
      expect(ours.runtime).toBe(MLX_CORE_VERSION);
      expect(oracle.runtime).toBe(MLX_CORE_VERSION);
      expect(ours.configSha256).toBe(oracle.configSha256);
      expect(ours.rows).toHaveLength(6);
      expect(ours.rows).toEqual(oracle.rows);
      passed = true;
    } finally {
      if (passed) await rm(dir, { recursive: true });
      else console.error(`Runtime oracle failure artifacts: ${dir}`);
    }
  }, 250_000);
}
